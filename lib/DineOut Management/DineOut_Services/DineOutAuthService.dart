import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../API/Apiclient.dart';
import '../../Models/food&beverages/dish.dart';
import '../DineOut_Model/DineOut_CartModel.dart';
import '../DineOut_Model/TableRequestModel.dart';

Future<int?> _vendorId() async {
  final prefs = await SharedPreferences.getInstance();
  final id = prefs.getInt('vendorId');
  if (id == null || id == 0)
    // debugPrint('⚠️ vendorId not found');
    return (id == null || id == 0) ? null : id;
}

class DineoutAuthService {
  static Future<List<Map<String, dynamic>>> fetchTables(int vendorId) async {
    try {
      final response = await ApiClient.get(
        'api/seating/all/vendor/$vendorId',
        service: 'food',
        requiresAuth: true,
      );

      if (response.statusCode == 200) {
        final List<dynamic> tablesData = jsonDecode(response.body);

        // Fetch today's bookings
        final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
        final bookingsResponse = await ApiClient.get(
          'api/seatingdetails/vendor/$vendorId/vendor-bookings?date=$today',
          service: 'food',
          requiresAuth: true,
        );

        // Group bookings by seatingId
        Map<int, List<Map<String, dynamic>>> bookingsByTable = {};

        if (bookingsResponse.statusCode == 200) {
          final List<dynamic> bookingsData = jsonDecode(bookingsResponse.body);
          for (var booking in bookingsData) {
            final seatingId = booking['seatingId'];
            if (seatingId != null) {
              if (!bookingsByTable.containsKey(seatingId)) {
                bookingsByTable[seatingId] = [];
              }
              bookingsByTable[seatingId]!.add({
                'bookingId': booking['id'],
                'customerName': booking['guestName'] ?? '',
                'phoneNumber': booking['phoneNumber'] ?? '',
                'guests': booking['capacity'] ?? 0,
                'startTime': booking['startTime'] ?? '',
                'durationMinutes': booking['durationMinutes'] ?? 60,
                'userId': booking['userId'],
              });
            }
          }
        }

        // Helper function to convert time to minutes
        int timeToMinutes(String timeStr) {
          if (timeStr.isEmpty) return 0;
          final parts = timeStr.split(':');
          if (parts.length < 2) return 0;
          return (int.tryParse(parts[0]) ?? 0) * 60 +
              (int.tryParse(parts[1]) ?? 0);
        }

        final now = DateTime.now();
        final currentMinutes = now.hour * 60 + now.minute;

        List<Map<String, dynamic>> tables = [];

        for (var table in tablesData) {
          final tableId = table['id'];
          final tableBookings = bookingsByTable[tableId] ?? [];

          // Find active booking (same logic as React)
          Map<String, dynamic>? activeBooking;

          if (tableBookings.isNotEmpty) {
            // First, check for currently active booking
            for (var booking in tableBookings) {
              final startMinutes = timeToMinutes(booking['startTime']);
              final endMinutes =
                  startMinutes + (booking['durationMinutes'] as int);

              if (currentMinutes >= startMinutes &&
                  currentMinutes <= endMinutes) {
                activeBooking = booking;
                break;
              }
            }

            // If no active booking, check for upcoming within 30 minutes
            if (activeBooking == null) {
              Map<String, dynamic>? upcomingBooking;
              int? closestStartMinutes;

              for (var booking in tableBookings) {
                final startMinutes = timeToMinutes(booking['startTime']);
                if (startMinutes > currentMinutes &&
                    (startMinutes - currentMinutes) <= 30) {
                  if (closestStartMinutes == null ||
                      startMinutes < closestStartMinutes) {
                    closestStartMinutes = startMinutes;
                    upcomingBooking = booking;
                  }
                }
              }
              activeBooking = upcomingBooking;
            }
          }

          tables.add({
            'name': table['name'] ?? '',
            'code': table['code'] ?? '',
            'count': 1,
            'seats': table['capacity'] ?? 2,
            'id': table['id'],
            'status': table['seatingStatus'] ?? 'Available',
            'bookingId': activeBooking?['bookingId'] ?? 0,
            'customerName': activeBooking?['customerName'] ?? '',
            'customerPhone': activeBooking?['phoneNumber'] ?? '',
            'bookingStartTime': activeBooking?['startTime'] ?? '',
            'bookingDuration': activeBooking?['durationMinutes'] ?? 0,
          });
        }
        return tables;
      }
      return [];
    } catch (e) {
      // debugPrint('Error fetching tables: $e');
      return [];
    }
  }

  static Future<bool> createTable({
    required int vendorId,
    required int numberOfTables,
    required int capacityPerTable,
    required String name,
    required String code,
  }) async {
    try {
      // Format cleaningTime as string "HH:MM:SS"
      String cleaningTime = "00:30:00";

      final response = await ApiClient.post('api/seating/vendor/$vendorId', {
        "numberOfTables": numberOfTables,
        "capacityPerTable": capacityPerTable,
        "name": name,
        "cleaningTime": cleaningTime, // Send as string, not object
        "code": code,
      }, service: 'food');

      // debugPrint('👉 Creating Table for Vendor ID: $vendorId');
      // debugPrint('📤 Request URL: api/seating/vendor/$vendorId');
      // debugPrint(
      //   '📦 Request Body: {numberOfTables: $numberOfTables, capacityPerTable: $capacityPerTable, name: $name, cleaningTime: $cleaningTime, code: $code}',
      // );
      // debugPrint('✅ Response Status Code: ${response.statusCode}');
      // debugPrint('📥 Response Body: ${response.body}');

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      // debugPrint('Error creating table: $e');
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> fetchReservations({
    required int vendorId,
    required String date,
  }) async {
    try {
      // debugPrint('📡 API CALL START');
      // debugPrint('➡️ Vendor ID: $vendorId');
      // debugPrint('➡️ Date: $date');

      final response = await ApiClient.get(
        'api/seatingdetails/vendor/$vendorId/vendor-bookings?date=$date',
        service: 'food',
        requiresAuth: true,
      );

      if (response.statusCode == 200) {
        final List<dynamic> bookingsData = jsonDecode(response.body);

        List<Map<String, dynamic>> bookings = [];

        for (var i = 0; i < bookingsData.length; i++) {
          final booking = bookingsData[i];

          // Format createdAt - extract only the date part (YYYY-MM-DD)
          String createdAtDateOnly = '';
          if (booking['createdAt'] != null) {
            try {
              DateTime createdAt = DateTime.parse(booking['createdAt']);
              createdAtDateOnly = DateFormat(
                'yyyy-MM-dd',
              ).format(createdAt); // Only date, no time
            } catch (e) {
              // If parsing fails, try to extract just the date part
              String createdAtStr = booking['createdAt'].toString();
              if (createdAtStr.contains(' ')) {
                createdAtDateOnly = createdAtStr.split(
                  ' ',
                )[0]; // Get part before space
              } else {
                createdAtDateOnly = createdAtStr;
              }
            }
          }

          final mappedBooking = {
            'id': booking['id'],
            'code': booking['code'] ?? '',
            'name': booking['guestName'] ?? '',
            'phone': booking['phoneNumber'] ?? '',
            'guests': booking['capacity'] ?? 0,
            'date': booking['bookingDate'] ?? '', // Reservation date
            'time': booking['startTime'] ?? '',
            'duration': '${booking['durationMinutes'] ?? 0} mins',
            'status': booking['arrivalStatus'] ?? 'Pending',
            'table': booking['code'] ?? booking['seating']?['code'] ?? 'A1',
            'tableName': booking['seating']?['name'] ?? '',
            'notes': booking['types'] ?? '',
            'seatingId': booking['seatingId'],
            'seatingStatus': booking['seating']?['seatingStatus'] ?? '',
            'employeeAccept': booking['employeeAccept'],
            'userId': booking['userId'],
            'createdAt': createdAtDateOnly, // ← Only date (YYYY-MM-DD)
          };

          bookings.add(mappedBooking);
        }

        return bookings;
      }
      return [];
    } catch (e) {
      // debugPrint('❌ Error fetching reservations: $e');
      return [];
    }
  }

  // ================== DINEOUT AUTH SERVICE ==================
  static Future<bool> createReservation({
    required int vendorId,
    required String guestName,
    required String phoneNumber,
    required int capacity,
    required String bookingDate,
    required String startTime,
    required int durationMinutes,
    required int seatingId,
    required String types,
    Map<String, dynamic>? seating,
  }) async {
    try {
      final Map<String, dynamic> requestBody = {
        "guestName": guestName,
        "phoneNumber": phoneNumber,
        "capacity": capacity,
        "bookingDate": bookingDate,
        "startTime": startTime,
        "durationMinutes": durationMinutes,
        "seatingId": seatingId,
        "types": types,
      };

      if (seating != null) {
        requestBody["seating"] = seating;
      }

      final response = await ApiClient.post(
        'api/seatingdetails/vendor/$vendorId',
        requestBody,
        service: 'food',
      );

      // debugPrint('📤 Creating Reservation');
      // debugPrint('📦 Request Body: ${jsonEncode(requestBody)}');
      // debugPrint('📡 Response Status Code: ${response.statusCode}');
      // debugPrint('📥 Response Body: ${response.body}');

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      // debugPrint('❌ Error creating reservation: $e');
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> fetchEmployeeBookings({
    required int vendorId,
  }) async {
    try {
      // debugPrint('📡 FETCHING EMPLOYEE BOOKINGS');
      // debugPrint('➡️ Vendor ID: $vendorId');
      // debugPrint(
      //   '🌐 Request URL: api/seatingdetails/getall/employee/bookings/vendor/$vendorId',
      // );

      final response = await ApiClient.get(
        'api/seatingdetails/getall/employee/bookings/vendor/$vendorId',
        service: 'food',
        requiresAuth: true,
      );
      //
      // debugPrint('📥 Response Status Code: ${response.statusCode}');
      // debugPrint('📥 Raw Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> bookingsData = jsonDecode(response.body);
        // debugPrint('✅ Parsed JSON Length: ${bookingsData.length}');

        List<Map<String, dynamic>> bookings = [];

        for (var i = 0; i < bookingsData.length; i++) {
          final booking = bookingsData[i];
          // debugPrint('🔍 Processing Booking Index: $i');
          // debugPrint('🔍 Booking Data: $booking');

          final mappedBooking = {
            'id': booking['id'], // Booking ID
            'code': booking['code'] ?? '', // ← TABLE CODE from root level
            'name': booking['guestName'] ?? '',
            'phone': booking['phoneNumber'] ?? '',
            'guests': booking['capacity'] ?? 0,
            'date': booking['bookingDate'] ?? '',
            'time': booking['startTime'] ?? '',
            'duration': '${booking['durationMinutes'] ?? 0} mins',
            'status': booking['arrivalStatus'] ?? 'Pending',
            'table': booking['code'] ?? booking['seating']?['code'] ?? 'A1',
            'tableName': booking['seating']?['name'] ?? '',
            'notes': booking['types'] ?? '',
            'seatingId': booking['seatingId'],
          };

          // debugPrint(
          //   '✅ Mapped Booking - ID: ${mappedBooking['id']}, Table Code: ${mappedBooking['code']}',
          // );
          bookings.add(mappedBooking);
        }

        // debugPrint('🎯 Final Employee Bookings Count: ${bookings.length}');
        return bookings;
      }
      return [];
    } catch (e) {
      // debugPrint('❌ Error fetching employee bookings: $e');
      return [];
    }
  }

  static Future<bool> acceptBooking({
    required int vendorId,
    required int bookingId,
    required String employeeAccept,
  }) async {
    try {
      // debugPrint('=' * 60);
      // debugPrint('🔵 ACCEPT BOOKING API CALL STARTED');
      // debugPrint('🔵 Vendor ID: $vendorId');
      // debugPrint('🔵 Booking ID: $bookingId');
      // debugPrint('🔵 Employee Accept Status: $employeeAccept');
      // debugPrint(
      //   '🔵 API URL: api/seatingdetails/accept/waiting/SeatingDetails',
      // );

      final response = await ApiClient.put(
        'api/seatingdetails/accept/waiting/SeatingDetails',
        {
          "vendorId": vendorId,
          "employeeAccept": employeeAccept,
          "id": bookingId,
        },
        service: 'food',
      );
      //
      // debugPrint('📤 Accepting Booking Request');
      // debugPrint(
      //   '📦 Request Body: ${jsonEncode({"vendorId": vendorId, "employeeAccept": employeeAccept, "id": bookingId})}',
      // );
      // debugPrint('📡 Response Status Code: ${response.statusCode}');
      // debugPrint('📥 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        // debugPrint('✅ Booking accepted successfully!');
      } else {
        // debugPrint(
        //   '❌ Failed to accept booking. Status code: ${response.statusCode}',
        // );
      }
      // debugPrint('=' * 60);

      return response.statusCode == 200;
    } catch (e) {
      // debugPrint('💥 Exception in acceptBooking: $e');
      // debugPrint('📚 Stack trace: ${StackTrace.current}');
      return false;
    }
  }

  static Future<DineoutCartmodel?> fetchCartByTable({
    required int vendorId,
    required int seatingId,
  }) async {
    try {
      // debugPrint('=' * 50);
      // debugPrint('🟢 FETCH CART BY TABLE STARTED');
      // debugPrint('📦 Vendor ID: $vendorId');
      // debugPrint('🪑 Seating ID: $seatingId');
      // debugPrint('🌐 API Endpoint: api/cart/getby/table/$vendorId/$seatingId');

      final response = await ApiClient.get(
        'api/cart/getby/table/$vendorId/$seatingId',
        service: 'food',
      );
      //
      // debugPrint('📡 Response Status Code: ${response.statusCode}');
      // debugPrint('📡 Response Body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        // debugPrint('✅ Successfully parsed cart data');
        // debugPrint('📊 Cart ID: ${jsonData['cartId']}');
        // debugPrint(
        //   '📊 Items count: ${(jsonData['cartItems'] as List?)?.length ?? 0}',
        // );
        // debugPrint('💰 Grand Total: ${jsonData['grandTotal']}');
        // debugPrint('=' * 50);
        return DineoutCartmodel.fromJson(jsonData);
      } else if (response.statusCode == 404) {
        // debugPrint('⚠️ No cart found for this table (404)');
        // debugPrint('=' * 50);
        return null;
      } else {
        // debugPrint('❌ API returned error: ${response.statusCode}');
        // debugPrint('=' * 50);
        return null;
      }
    } catch (e) {
      // debugPrint('💥 Exception in fetchCartByTable: $e');
      // debugPrint('📚 Stack trace: ${StackTrace.current}');
      // debugPrint('=' * 50);
      return null;
    }
  }

  static Future<bool> addToCart({
    required int vendorId,
    required int seatingId,
    required int dishId,
    required int quantity,
    required String orderType,
  }) async {
    try {
      // debugPrint('=' * 60);
      // debugPrint('🟢🟢🟢 ADD TO CART STARTED 🟢🟢🟢');
      // debugPrint('=' * 60);
      // debugPrint('📦 Vendor ID: $vendorId');
      // debugPrint('🪑 Seating ID (Booking ID): $seatingId');
      // debugPrint('🍽️ Dish ID: $dishId');
      // debugPrint('🔢 Quantity: $quantity');
      // debugPrint('📋 Order Type: $orderType');
      // debugPrint('=' * 60);

      if (vendorId == 0) {
        // debugPrint('❌ ERROR: Vendor ID is 0 - invalid vendor');
        return false;
      }

      if (seatingId == 0) {
        // debugPrint('❌ ERROR: Seating ID is 0 - invalid seating/booking');
        return false;
      }

      if (dishId == 0) {
        // debugPrint('❌ ERROR: Dish ID is 0 - invalid dish');
        return false;
      }

      if (quantity <= 0) {
        // debugPrint('❌ ERROR: Quantity is $quantity - must be greater than 0');
        return false;
      }

      final String apiUrl =
          'api/cart/add/$vendorId/$seatingId?dishId=$dishId&quantity=$quantity&orderType=$orderType';

      // debugPrint('🌐 API URL: $apiUrl');

      final response = await ApiClient.post(apiUrl, {}, service: 'food');
      //
      // debugPrint('📡 Response Status Code: ${response.statusCode}');
      // debugPrint('📥 Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // debugPrint('✅ SUCCESS: Item added to cart successfully!');

        // After adding, check if the item was created with null status
        try {
          final responseData = jsonDecode(response.body);
          // debugPrint('📦 Response data: $responseData');
        } catch (e) {
          // debugPrint('⚠️ Could not parse response body as JSON');
        }

        // debugPrint('=' * 60);
        // debugPrint('🟢🟢🟢 ADD TO CART COMPLETED SUCCESSFULLY 🟢🟢🟢');
        // debugPrint('=' * 60);
        return true;
      } else {
        // debugPrint(
        //   '❌ FAILED: Server returned error status code ${response.statusCode}',
        // );
        // debugPrint('=' * 60);
        return false;
      }
    } catch (e, stackTrace) {
      // debugPrint('💥 Exception in addToCart: $e');
      // debugPrint('📚 Stack trace: $stackTrace');
      // debugPrint('=' * 60);
      return false;
    }
  }

  static Future<List<Dish>> fetchDishes({
    int? parentId,
    bool filterByMenuStatus = false,
  }) async {
    try {
      // debugPrint('🟢 ========== FETCH DISHES STARTED ==========');
      // debugPrint(
      //   '📋 Parameters: parentId=$parentId, filterByMenuStatus=$filterByMenuStatus',
      // );

      final vendorId = await _vendorId();
      // debugPrint('🏪 Vendor ID: $vendorId');

      if (vendorId == null) {
        // debugPrint('❌ Vendor ID is null - cannot fetch dishes');
        return [];
      }

      if (vendorId == 0) {
        // debugPrint('❌ Vendor ID is 0 - invalid vendor');
        return [];
      }

      final apiUrl = 'api/dish/getbyvendor/$vendorId';
      // debugPrint('🌐 API URL: $apiUrl');
      // debugPrint('📡 Sending GET request to food service...');

      final response = await ApiClient.get(apiUrl, service: 'food');

      // debugPrint('📊 Response Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseBody = response.body;
        // debugPrint(
        //   '📦 Response body length: ${responseBody.length} characters',
        // );

        final List<dynamic> data = json.decode(responseBody);
        // debugPrint('✅ Successfully parsed JSON');
        // debugPrint('📊 Total dishes received from API: ${data.length}');

        if (data.isEmpty) {
          // debugPrint('⚠️ No dishes found for vendor $vendorId');
          return [];
        }

        // Log first dish for debugging
        if (data.isNotEmpty) {
          // debugPrint('📝 Sample dish (first item): ${data[0]}');
        }

        List<Dish> dishes = data.map((j) {
          try {
            return Dish.fromJson(j);
          } catch (e) {
            // debugPrint('❌ Error parsing dish: $e');
            // debugPrint('⚙️ Problematic JSON: $j');
            rethrow;
          }
        }).toList();
        //
        // debugPrint(
        //   '✅ Successfully mapped ${dishes.length} dishes to Dish objects',
        // );

        // Log some stats about the dishes
        int parentCount = dishes.where((d) => d.parentId == 0).length;
        int subDishCount = dishes.where((d) => d.parentId != 0).length;
        // debugPrint(
        //   '📊 Statistics: Parent categories: $parentCount, Sub-dishes: $subDishCount',
        // );

        if (filterByMenuStatus) {
          final beforeFilter = dishes.length;
          dishes = dishes
              .where((d) => d.menuStatus?.toLowerCase() == 'enable')
              .toList();
          // debugPrint(
          //   '🔍 Filtered by menuStatus=enable: $beforeFilter → ${dishes.length} dishes',
          // );
        }

        if (parentId != null && parentId != 0) {
          final beforeFilter = dishes.length;
          dishes = dishes.where((d) => d.parentId == parentId).toList();
          // debugPrint(
          //   '🔍 Filtered by parentId=$parentId: $beforeFilter → ${dishes.length} dishes',
          // );
        }

        // Log dish names for debugging
        if (dishes.isNotEmpty) {
          // debugPrint('📋 Dish names in result:');
          for (var i = 0; i < dishes.length && i < 5; i++) {
            // debugPrint(
            //   '   ${i + 1}. ${dishes[i].dishName} (ID: ${dishes[i].dishId}, Parent: ${dishes[i].parentId})',
            // );
          }
          if (dishes.length > 5) {
            // debugPrint('   ... and ${dishes.length - 5} more');
          }
        }
        //
        // debugPrint(
        //   '✅ ========== FETCH DISHES COMPLETED SUCCESSFULLY ==========',
        // );
        return dishes;
      } else {
        // debugPrint('❌ API Error: Status code ${response.statusCode}');
        // debugPrint('❌ Response body: ${response.body}');
        // debugPrint('❌ ========== FETCH DISHES FAILED ==========');
        return [];
      }
    } catch (e, stack) {
      // debugPrint('💥 ========== FETCH DISHES EXCEPTION ==========');
      // debugPrint('💥 Error: $e');
      // debugPrint('📚 Stack trace:');
      // debugPrintStack(stackTrace: stack);
      // debugPrint('💥 ========== FETCH DISHES EXCEPTION END ==========');
      return [];
    }
  }

  static Future<Map<String, dynamic>?> addToCartByTable({
    required int vendorId,
    required int bookingId,
    required String tableCode,
    required List<Map<String, dynamic>> items,
    int? userId,
  }) async {
    try {
      // debugPrint('🟢 ADD TO CART CALLED');

      final String apiUrl;

      // ✅ USER ORDER
      if (userId != null && userId > 0) {
        apiUrl =
            'api/cart/add/table/cart/add-item?userId=$userId&seatingId=$bookingId';

        // debugPrint('👤 USER EXISTS');
        // debugPrint('🌐 USER API: $apiUrl');
      }
      // ✅ WAITER ORDER
      else {
        apiUrl =
            'api/cart/waiter-order/$vendorId/$bookingId?tableCode=$tableCode';
        //
        // debugPrint('👨‍🍳 WAITER ORDER');
        // debugPrint('🌐 WAITER API: $apiUrl');
      }

      final processedItems = items.map((item) {
        return {"dishId": item['dishId'], "quantity": item['quantity']};
      }).toList();

      final response = await ApiClient.post(
        apiUrl,
        processedItems,
        service: 'food',
      );

      // debugPrint('📡 Status Code: ${response.statusCode}');
      // debugPrint('📥 Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      }

      return null;
    } catch (e) {
      // debugPrint('💥 Add To Cart Error: $e');
      return null;
    }
  }

  static Future<DineoutCartmodel?> fetchCartByBooking({
    required int vendorId,
    required int bookingId,
  }) async {
    try {
      // debugPrint('🔄 Fetching cart for Booking ID: $bookingId');

      final response = await ApiClient.get(
        '/api/cart/getby/table/$vendorId/$bookingId',
        service: 'food',
      );

      // debugPrint('📡 Cart fetch response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        return DineoutCartmodel.fromJson(jsonData);
      } else if (response.statusCode == 404) {
        // debugPrint('⚠️ No cart found for booking');
        return null;
      } else {
        // debugPrint('❌ Failed to fetch cart: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      // debugPrint('💥 Error fetching cart: $e');
      return null;
    }
  }

  static Future<bool> updateReservation({
    required int vendorId,
    required int bookingId,
    required String guestName,
    required String phoneNumber,
    required int capacity,
    required String bookingDate,
    required String startTime,
    required int durationMinutes,
  }) async {
    try {
      if (vendorId == 0) {
        // debugPrint('❌ ERROR: Vendor ID is 0');
        return false;
      }
      if (bookingId == 0) {
        // debugPrint('❌ ERROR: Booking ID is 0');
        return false;
      }
      if (guestName.isEmpty) {
        // debugPrint('❌ ERROR: Guest name is empty');
        return false;
      }
      if (phoneNumber.isEmpty) {
        // debugPrint('❌ ERROR: Phone number is empty');
        return false;
      }
      if (capacity <= 0) {
        // debugPrint('❌ ERROR: Capacity is $capacity');
        return false;
      }
      if (durationMinutes <= 0) {
        // debugPrint('❌ ERROR: Duration is $durationMinutes minutes');
        return false;
      }

      String formattedStartTime = startTime;
      if (!formattedStartTime.contains(':') ||
          formattedStartTime.contains('AM') ||
          formattedStartTime.contains('PM')) {
        try {
          final parsedTime = DateFormat('h:mm a').parse(startTime);
          formattedStartTime = DateFormat('HH:mm:ss').format(parsedTime);
        } catch (e) {
          formattedStartTime = '12:00:00';
        }
      }

      final Map<String, dynamic> requestBody = {
        "id": bookingId,
        "vendorId": vendorId,
        "guestName": guestName,
        "phoneNumber": phoneNumber,
        "capacity": capacity,
        "bookingDate": bookingDate,
        "durationMinutes": durationMinutes,
        "startTime": formattedStartTime, // Send as string
      };

      final String apiUrl = 'api/seatingdetails/seating-details/$bookingId';
      //
      // debugPrint('🌐 API URL: $apiUrl');
      // debugPrint('📦 Request Body: ${jsonEncode(requestBody)}');

      final response = await ApiClient.put(
        apiUrl,
        requestBody,
        service: 'food',
      );

      // debugPrint('📡 Response Status Code: ${response.statusCode}');
      // debugPrint('📥 Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // debugPrint('✅ SUCCESS: Booking updated successfully!');
        // debugPrint('=' * 60);
        // debugPrint('🟢 UPDATE RESERVATION COMPLETED SUCCESSFULLY 🟢');
        // debugPrint('=' * 60);
        return true;
      } else {
        // debugPrint(
        //   '❌ FAILED: Server returned error status code ${response.statusCode}',
        // );
        // debugPrint('=' * 60);
        // debugPrint('🔴 UPDATE RESERVATION FAILED 🔴');
        // debugPrint('=' * 60);
        return false;
      }
    } catch (e, stackTrace) {
      // debugPrint('=' * 60);
      // debugPrint('💥 EXCEPTION IN UPDATE RESERVATION 💥');
      // debugPrint('💥 Exception: $e');
      // debugPrint('📚 Stack Trace:');
      // debugPrintStack(stackTrace: stackTrace);
      // debugPrint('=' * 60);
      return false;
    }
  }

  static Future<Map<String, dynamic>?> placeDirectOrder({
    required int vendorId,
    required int cartId,
    required String paymentMethod,
    required String razorpayPaymentId,
    required String razorpayOrderId,
    int? userId,
    bool isUserOrder = false,
    String? walletType,
    int? couponId,
    String? phoneNumber,
    double? amount,
    List<Map<String, dynamic>>? cashPaymentData,
  }) async {
    // debugPrint('=' * 80);
    // debugPrint('💰 PLACE DIRECT ORDER - STARTED');
    // debugPrint('=' * 80);
    // debugPrint('📋 Parameters:');
    // debugPrint('   - vendorId: $vendorId');
    // debugPrint('   - cartId: $cartId');
    // debugPrint('   - paymentMethod: $paymentMethod');
    // debugPrint('   - userId: $userId');
    // debugPrint('   - isUserOrder: $isUserOrder');
    // debugPrint('   - walletType: $walletType');
    // debugPrint('   - couponId: $couponId');
    // debugPrint('   - phoneNumber: $phoneNumber');
    // debugPrint('   - amount: $amount');

    try {
      if (cartId == 0) {
        throw Exception('Invalid cart ID');
      }

      final Map<String, String> queryParams = {'paymentMethod': paymentMethod};

      if (isUserOrder && userId != null && userId > 0) {
        queryParams['userId'] = userId.toString();
        // debugPrint('👤 Using USER order endpoint with userId: $userId');
      } else {
        queryParams['vendorId'] = vendorId.toString();
        // debugPrint('👥 Using GUEST order endpoint with vendorId: $vendorId');
      }

      // Add optional parameters if they exist
      if (razorpayPaymentId.isNotEmpty) {
        queryParams['razorpayPaymentId'] = razorpayPaymentId;
      }

      if (razorpayOrderId.isNotEmpty) {
        queryParams['razorpayOrderId'] = razorpayOrderId;
      }

      if (walletType != null && walletType.isNotEmpty) {
        queryParams['walletTypes'] =
            walletType; // Note: walletTypes (plural) as per your API
      }

      if (couponId != null && couponId > 0) {
        queryParams['couponId'] = couponId.toString();
      }

      if (phoneNumber != null && phoneNumber.isNotEmpty) {
        queryParams['phoneNumber'] = phoneNumber;
      }

      if (amount != null && amount > 0) {
        queryParams['amount'] = amount.toString();
      }

      final queryString = Uri(queryParameters: queryParams).query;

      final String endpoint;
      if (isUserOrder && userId != null && userId > 0) {
        endpoint = 'api/orders/orders/create/$cartId?$queryString';
      } else {
        endpoint = 'api/orders/orders/vendor/create/$cartId?$queryString';
      }

      final List<dynamic> body =
          (cashPaymentData != null && cashPaymentData.isNotEmpty)
          ? cashPaymentData
          : [];

      // debugPrint('📤 Endpoint: $endpoint');
      // debugPrint('📦 Request Body: ${jsonEncode(body)}');

      final response = await ApiClient.post(endpoint, body, service: 'food');

      // debugPrint('📡 Response Status: ${response.statusCode}');
      // debugPrint('📡 Response Body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final result = jsonDecode(response.body) as Map<String, dynamic>;
        // debugPrint('✅ Order placed successfully!');
        // debugPrint('=' * 80);
        return result;
      }

      // debugPrint('❌ Direct Order Failed: ${response.statusCode}');
      // debugPrint('=' * 80);
      return null;
    } catch (e, stack) {
      // debugPrint('💥 placeDirectOrder error: $e');
      // debugPrintStack(stackTrace: stack);
      // debugPrint('=' * 80);
      return null;
    }
  }

  static Future<bool> removeCartItem({
    required int itemId,
    required int vendorId,
    required int bookingId,
  }) async {
    try {
      final cart = await fetchCartByBooking(
        vendorId: vendorId,
        bookingId: bookingId,
      );

      if (cart == null || cart.cartId == 0) {
        return false;
      }

      final response = await ApiClient.delete(
        'api/cart/vendor/items/$vendorId/${cart.cartId}/$itemId',
        service: 'food',
      );

      if (response.statusCode >= 200 && response.statusCode < 300) return true;

      if (response.statusCode == 500) {
        try {
          final body = jsonDecode(response.body);
          if (body['message'] == 'Cart not found' ||
              body['message'] == 'Item not found')
            return true;
        } catch (_) {}
      }
      return false;
    } catch (e) {
      // debugPrint('removeCartItem error: $e');
      return false;
    }
  }

  static Future<bool> removeCartItemByBooking({
    required int vendorId,
    required int cartId,
    required int itemId,
  }) async {
    try {
      final response = await ApiClient.delete(
        'api/cart/vendor/items/$vendorId/$cartId/$itemId',
        service: 'food',
      );

      if (response.statusCode >= 200 && response.statusCode < 300) return true;

      if (response.statusCode == 500) {
        try {
          final body = jsonDecode(response.body);
          if (body['message'] == 'Cart not found' ||
              body['message'] == 'Item not found')
            return true;
        } catch (_) {}
      }
      return false;
    } catch (e, stack) {
      // debugPrint('removeCartItemByBooking error: $e');
      // debugPrintStack(stackTrace: stack);
      return false;
    }
  }

  static Future<bool> sendItemToKitchen({
    required int itemId,
    required String status,
    String note = '',
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('authToken') ?? '';
      final sessionCookie = prefs.getString('sessionCookie') ?? '';

      final endpoint =
          "api/cart/cartitem/status/$itemId?status=$status&note=${Uri.encodeComponent(note)}";

      // Prepare headers
      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': '*/*',
      };

      if (sessionCookie.isNotEmpty) {
        headers['Cookie'] = sessionCookie;
      } else if (authToken.isNotEmpty) {
        headers['Authorization'] = 'Bearer $authToken';
      }

      final response = await ApiClient.put(endpoint, {}, service: "food");

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      // debugPrint('❌ Error sending item to kitchen: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>> sendItemsToKitchen({
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      final List<Future<bool>> futures = [];

      for (var item in items) {
        final itemId = item['itemId'];
        final note = item['note'] ?? '';

        futures.add(
          sendItemToKitchen(itemId: itemId, status: 'CONFIRMED', note: note),
        );
      }

      final results = await Future.wait(futures);

      final successCount = results.where((r) => r).length;
      final failedCount = results.length - successCount;

      return {
        'success': failedCount == 0,
        'successCount': successCount,
        'failedCount': failedCount,
      };
    } catch (e) {
      // debugPrint('❌ Error sending items to kitchen: $e');

      return {
        'success': false,
        'successCount': 0,
        'failedCount': items.length,
        'error': e.toString(),
      };
    }
  }

  static Future<bool> sendItemToKitchenWithQuantity({
    required int itemId,
    required int quantity,
    String note = '',
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('authToken') ?? '';
      final sessionCookie = prefs.getString('sessionCookie') ?? '';

      final endpoint =
          "api/cart/cartitem/status/$itemId?status=CONFIRMED&note=${Uri.encodeComponent(note)}&quantity=$quantity";

      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': '*/*',
      };

      if (sessionCookie.isNotEmpty) {
        headers['Cookie'] = sessionCookie;
      } else if (authToken.isNotEmpty) {
        headers['Authorization'] = 'Bearer $authToken';
      }

      final response = await ApiClient.put(endpoint, {}, service: "food");

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      // debugPrint('❌ Error sending item to kitchen with quantity: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>> sendItemsToKitchenWithQuantities({
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      final List<Future<bool>> futures = [];

      for (var item in items) {
        final itemId = item['itemId'];
        final note = item['note'] ?? '';
        final quantity = item['quantity'] ?? 1;

        futures.add(
          sendItemToKitchenWithQuantity(
            itemId: itemId,
            quantity: quantity,
            note: note,
          ),
        );
      }

      final results = await Future.wait(futures);

      final successCount = results.where((r) => r).length;
      final failedCount = results.length - successCount;

      return {
        'success': failedCount == 0,
        'successCount': successCount,
        'failedCount': failedCount,
      };
    } catch (e) {
      // debugPrint('❌ Error sending items to kitchen: $e');
      return {
        'success': false,
        'successCount': 0,
        'failedCount': items.length,
        'error': e.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>?> updateCartItemQuantity({
    required int cartId,
    required int itemId,
    required int quantity,
    String status = 'CONFIRMED',
  }) async {
    try {
      final endpoint =
          'api/cart/update/table/quantity/status/$cartId?itemId=$itemId&quantity=$quantity&status=$status';

      final response = await ApiClient.put(endpoint, {}, service: 'food');

      // debugPrint('📡 updateCartItemQuantity: ${response.statusCode}');
      // debugPrint('📥 Body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      // debugPrint('💥 updateCartItemQuantity error: $e');
      return null;
    }
  }

  static Future<bool> applyVendorDiscount({
    required int cartId,
    required double discountAmount,
  }) async {
    try {
      // debugPrint('=' * 60);
      // debugPrint('🏷️ APPLY VENDOR DISCOUNT STARTED');
      // debugPrint('=' * 60);
      // debugPrint('📦 Cart ID: $cartId');
      // debugPrint('💰 Discount Amount: $discountAmount');
      // debugPrint('=' * 60);

      if (cartId == 0) {
        // debugPrint('❌ ERROR: Cart ID is 0 - invalid cart');
        return false;
      }

      if (discountAmount <= 0) {
        // debugPrint('❌ ERROR: Discount amount must be greater than 0');
        return false;
      }

      final String apiUrl =
          'api/cart/apply/discount/from/vendor/$cartId?discountAmount=$discountAmount';

      // debugPrint('🌐 API URL: $apiUrl');

      final response = await ApiClient.put(apiUrl, {}, service: 'food');
      //
      // debugPrint('📡 Response Status Code: ${response.statusCode}');
      // debugPrint('📥 Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        // debugPrint('✅ SUCCESS: Discount applied successfully!');
        // debugPrint('=' * 60);
        return true;
      } else {
        // debugPrint(
        //   '❌ FAILED: Server returned error status code ${response.statusCode}',
        // );

        try {
          final errorBody = jsonDecode(response.body);
          // debugPrint(
          //   '❌ Error message: ${errorBody['message'] ?? 'Unknown error'}',
          // );
        } catch (_) {}

        // debugPrint('=' * 60);
        return false;
      }
    } catch (e, stackTrace) {
      // debugPrint('💥 Exception in applyVendorDiscount: $e');
      // debugPrint('📚 Stack trace: $stackTrace');
      // debugPrint('=' * 60);
      return false;
    }
  }

  static Future<bool> saveItemToCart({
    required int itemId,
    required String status,
    String note = '',
  }) async {
    try {
      final endpoint =
          "api/cart/cartitem/status/$itemId?status=$status&note=${Uri.encodeComponent(note)}";

      final response = await ApiClient.put(endpoint, {}, service: "food");

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      // debugPrint('❌ Error saving item to cart: $e');
      return false;
    }
  }

  static Future<List<dynamic>> fetchIsBookedByUser({
    required int vendorId,
  }) async {
    try {
      final response = await ApiClient.get(
        'api/seatingdetails/isBooked/user/$vendorId',
        service: 'subscription',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data is List) {
          return data;
        }
      }

      return [];
    } catch (e) {
      // debugPrint('❌ fetchIsBookedByUser error: $e');
      return [];
    }
  }

  static Future<bool> updateCartQuantity({
    required int cartId,
    required int itemId,
    required int quantity,
    String status = 'PENDING',
  }) async {
    try {
      final endpoint =
          'api/cart/update/table/quantity/status/$cartId'
          '?itemId=$itemId'
          '&quantity=$quantity'
          '&status=$status';

      // debugPrint('📤 UPDATE CART API: $endpoint');

      final response = await ApiClient.put(endpoint, {}, service: 'food');
      //
      // debugPrint('📥 STATUS: ${response.statusCode}');
      // debugPrint('📥 BODY: ${response.body}');

      return response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204;
    } catch (e) {
      // debugPrint('❌ updateCartQuantity Error: $e');
      return false;
    }
  }

  static Future<bool> createTableRequest({
    required int vendorId,
    int? userId,
    int? itemId,
    int? cartId,
    int? tableBookingId,
    String? tableCode,
    required String requestType,
    int? employeeId,
    String? reason,
    String? status,
    String? itemName,
    int? quantity,
  }) async {
    try {
      final requestBody = TableRequestModel(
        vendorId: vendorId,
        userId: userId,
        itemId: itemId,
        cartId: cartId,
        tableBookingId: tableBookingId,
        tableCode: tableCode,
        requestType: requestType,
        employeeId: employeeId,
        reason: reason,
        status: status,
        itemName: itemName,
        quantity: quantity,
      ).toJson();

      // debugPrint('📤 Creating table request: ${jsonEncode(requestBody)}');

      final response = await ApiClient.post(
        'api/table-requests/create',
        requestBody,
        service: 'food',
      );

      // debugPrint('📡 Response: ${response.statusCode} - ${response.body}');

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      // debugPrint('❌ createTableRequest error: $e');
      return false;
    }
  }

  static Future<bool> updateCartRemovalRequest({
    required int cartId,
    required int vendorId,
    required int? userId,
    required int itemId,
    required int quantity,
    required String itemName,
    required String tableCode,
    required int tableBookingId,
    String? reason,
  }) async {
    try {
      final requestBody = {
        "vendorId": vendorId,
        "userId": userId,
        "itemId": itemId,
        "cartId": cartId,
        "tableBookingId": tableBookingId,
        "tableCode": tableCode,
        "status": "PENDING",
        "requestType": "REMOVAL_QUANTITY",
        "itemName": itemName,
        "quantity": quantity,
        if (reason != null && reason.isNotEmpty) "reason": reason,
      };

      // debugPrint('📤 Updating cart removal: ${jsonEncode(requestBody)}');

      final response = await ApiClient.post(
        'api/table-requests/cart/$cartId',
        requestBody,
        service: 'food',
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      // debugPrint('❌ updateCartRemovalRequest error: $e');
      return false;
    }
  }
}
