import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/src/response.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Api/APIclient.dart';
import '../Models/advertisement_model.dart';
import '../Models/coupon_model.dart';
import '../Models/food/aboutus_model.dart';
import '../Models/food/cart_model.dart';
import '../Models/food/category_dish.dart';
import '../Models/food/discount_model.dart';
import '../Models/food/dish.dart';
import '../Models/food/favorites_model.dart';
import '../Models/food/food_categries_model.dart';
import '../Models/food/restaurent_banner_model.dart';
import '../Models/food/table_confirmedlist_model.dart';
import '../Models/food/table_waitinglist_model.dart';
import '../Models/food/tablecartmodel.dart' hide CartItem;
import '../Models/food/timings_model.dart';
import '../Models/food/toprestaurentbanner_model.dart';
import '../Models/ticket_model.dart';
import '../screens/Food&beverages/menu_screen.dart';
import 'Apiclient.dart';

class food_Authservice {
  static Future<List<Discount>> fetchAllDiscountDishes() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    final endpoint = 'api/dish/discount/$userId';
    try {
      final response = await ApiClient.get(endpoint, service: "food");

      if (response.statusCode != 200 || response.body.isEmpty) {
        return [];
      }

      final List<dynamic> decoded = json.decode(response.body);
      if (decoded.isEmpty) return [];

      return decoded
          .map((e) => Discount.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // print('Error fetching dishes: $e');
      return [];
    }
  }

  Future<List<BannerItemtoprestaurents>> fetchBanners() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    final endpoint = 'api/banner/toprated/restaurants?userId=$userId';

    try {
      final response = await ApiClient.get(endpoint, service: "food");

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData
            .map((item) => BannerItemtoprestaurents.fromJson(item))
            .toList();
      } else {
        throw Exception('Failed to load banners: ${response.statusCode}');
      }
    } catch (e) {
      // print("⚠️ Exception while fetching banners: $e");
      throw Exception('Failed to load banners');
    }
  }

  Future<List<Restaurent_Banner>> fetchnearbyresturents() async {
    final prefs = await SharedPreferences.getInstance();
    final customerId = prefs.getString('customerId');

    final endpoint = "api/user/nearby-vendors/get?customerId=$customerId";

    try {
      final response = await ApiClient.get(endpoint, service: "food");

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        // print("response :${response.body}");
        return jsonData
            .map((item) => Restaurent_Banner.fromJson(item))
            .toList();
      } else {
        throw Exception('Failed to load banners: ${response.statusCode}');
      }
    } catch (e) {
      // print("⚠️ Exception while fetching banners: $e");
      throw Exception('Failed to load banners');
    }
  }

  Future<Restaurent_Banner> fetchVendorBanner(int vendorId) async {
    final endpoint = 'api/banner/$vendorId';

    try {
      // Use ApiService to automatically add token
      final response = await ApiClient.get(endpoint, service: "food");

      // print(
      //   "📩 Vendor Banner Response: ${response.statusCode} → ${response.body}",
      // );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return Restaurent_Banner.fromJson(jsonData);
      } else {
        throw Exception('Failed to load banner data: ${response.statusCode}');
      }
    } catch (e) {
      // print("⚠️ Exception while fetching vendor banner: $e");
      throw Exception('Failed to load banner data');
    }
  }

  static Future<AboutUsModel?> fetchAboutUsData(int vendorId) async {
    final endpoint = 'api/vendor/aboutus/get/$vendorId';

    try {
      // Using ApiClient for token handling + refresh
      final response = await ApiClient.get(endpoint, service: "food");

      // print("📩 About Us Response: ${response.statusCode} → ${response.body}");
      // print("🔎 Fetching About Us Data for vendorId: $vendorId");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // ✅ Assuming AboutUsModel already includes image URLs and text fields
        return AboutUsModel.fromJson(data);
      } else {
        jsonDecode(response.body);
        // print(
        //   "❌ Failed to load About Us: ${error['message'] ?? response.body}",
        // );
        return null;
      }
    } catch (e) {
      // print("⚠️ Exception while fetching About Us: $e");
      return null;
    }
  }

  static Future<Timing?> fetchVendorTimingForToday(int vendorId) async {
    final endpoint = "api/timings/get/timings/$vendorId";

    try {
      final response = await ApiClient.get(endpoint, service: "food");
      // print(
      //   "📩 Vendor Timings Response: ${response.statusCode} → ${response.body}",
      // );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final List<Timing> allTimings = data
            .map((e) => Timing.fromJson(e))
            .toList();

        final String today = _getTodayDayName();

        final Timing timingForToday = allTimings.firstWhere(
          (t) => t.day.toLowerCase() == today.toLowerCase(),
          orElse: () => Timing(day: today, startTime: "", lastTime: ""),
        );

        return timingForToday.startTime.isEmpty ? null : timingForToday;
      } else {
        // print("❌ Failed to fetch timings: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      // print("⚠️ Error fetching timings: $e");
      return null;
    }
  }

  /// Utility function to get today’s day name
  static String _getTodayDayName() {
    final now = DateTime.now();
    switch (now.weekday) {
      case DateTime.monday:
        return "Monday";
      case DateTime.tuesday:
        return "Tuesday";
      case DateTime.wednesday:
        return "Wednesday";
      case DateTime.thursday:
        return "Thursday";
      case DateTime.friday:
        return "Friday";
      case DateTime.saturday:
        return "Saturday";
      case DateTime.sunday:
        return "Sunday";
      default:
        return "";
    }
  }

  static Future<String?> fetchUserPlanForVendor(int vendorId) async {
    final endpoint = "api/get/vendor_subscription/$vendorId/FOOD_AND_BEVERAGES";
    // print("🔹 [fetchUserPlanForVendor] Called with vendorId: $vendorId");
    // print("🔹 API Endpoint: $endpoint");

    try {
      // print("🌐 Sending GET request...");
      final response = await ApiClient.get(endpoint, service: "subscription");
      // print("📩 Response Code: ${response.statusCode}");

      if (response.statusCode == 200) {
        // print("✅ Response successful. Parsing JSON...");
        final List<dynamic> data = jsonDecode(response.body);
        // print("📊 Parsed ${data.length} subscription(s).");

        if (data.isNotEmpty) {
          final plan = data.first;
          final planType = plan['subscriptionPlan']?['planType'];

          // print("✅ Vendor Plan Found:");
          // print("   → Plan Type: $planType");
          // print("   → Status: $status");
          // print("   → Start: $startDate");
          // print("   → End: $endDate");

          return planType?.toString();
        } else {
          // print("⚠️ No active subscription found for vendorId: $vendorId");
          return null;
        }
      } else {
        // print("❌ Failed to fetch subscription. Status: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      // print("🚨 Exception in fetchUserPlanForVendor:");
      // print("   Error: $e");
      // print("   Stack: $stack");
      return null;
    }
  }
  // static Future<List<Dish>> getAllDishes(int vendorId) async {
  //   final endpoint = "api/dish/getbyvendor/$vendorId";
  //   // print("🔎 Fetching all dishes for vendorId=$vendorId from $endpoint");
  //
  //   try {
  //     final response = await ApiClient.get(endpoint, service: "food");
  //     // print("📩 Response Status: ${response.statusCode}");
  //     // print("📩 Response Body: ${response.body}");
  //
  //     if (response.statusCode == 200) {
  //       final List<dynamic> data = jsonDecode(response.body);
  //       // print("✅ Total dishes received: ${data.length}");
  //
  //       final dishes = data
  //           .map((dishJson) {
  //             try {
  //               final dish = Dish.fromJson(dishJson);
  //               // print(
  //               //   "🍽️ Parsed Dish: ${dish.dishName}, Tag: ${dish.tag}, Stock: ${dish.stockQuantity}",
  //               // );
  //               return dish;
  //             } catch (e) {
  //               // print("⚠️ Error parsing dish: $e\nData: $dishJson");
  //               return null;
  //             }
  //           })
  //           .whereType<Dish>()
  //           .toList();
  //
  //       // print("✅ Successfully parsed ${dishes.length} dishes");
  //       return dishes;
  //     } else {
  //       // print("❌ Failed to load dishes: ${response.statusCode}");
  //       return [];
  //     }
  //   } catch (e) {
  //     // print("⚠️ Exception while loading dishes: $e");
  //     return [];
  //   }
  // }

  static Future<List<Dish>> getAllDishes(int vendorId) async {
    final prefs = await SharedPreferences.getInstance();
    final int userId = prefs.getInt('userId') ?? 0;

    final endpoint = "api/dish/getby/vendor/user/$vendorId/$userId";
    // print("🔎 Fetching all dishes for vendorId=$vendorId from $endpoint");

    try {
      final response = await ApiClient.get(endpoint, service: "food");
      print("📩 Response Status: ${response.statusCode}");
      print("📩 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print("✅ Total dishes received: ${data.length}");

        final dishes = data
            .map((dishJson) {
              try {
                final dish = Dish.fromJson(dishJson);
                // print(
                //   "🍽️ Parsed Dish: ${dish.dishName}, Tag: ${dish.tag}, Stock: ${dish.stockQuantity}",
                // );
                return dish;
              } catch (e) {
                // print("⚠️ Error parsing dish: $e\nData: $dishJson");
                return null;
              }
            })
            .whereType<Dish>()
            .toList();

        // print("✅ Successfully parsed ${dishes.length} dishes");
        return dishes;
      } else {
        // print("❌ Failed to load dishes: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      // print("⚠️ Exception while loading dishes: $e");
      return [];
    }
  }

  // static Future<List<CategoryDish>> fetchCategories(int vendorId) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final int userId = prefs.getInt('userId') ?? 0;
  //   final endpoint = "api/dish/getby/vendor/user/$vendorId/$userId";
  //
  //   try {
  //     final response = await ApiClient.get(endpoint, service: "food");
  //     // print(
  //     //   "📩 Fetch Categories Response: ${response.statusCode} → ${response.body}",
  //     // );
  //
  //     if (response.statusCode == 200) {
  //       final List<dynamic> jsonData = jsonDecode(response.body);
  //       return jsonData.map((json) => CategoryDish.fromJson(json)).toList();
  //     } else {
  //       // print("❌ Failed to fetch categories: ${response.statusCode}");
  //       return [];
  //     }
  //   } catch (e) {
  //     // print("⚠️ Exception while fetching categories: $e");
  //     return [];
  //   }
  // }

  static Future<MenuResponse> fetchMenu(int vendorId) async {
    final prefs = await SharedPreferences.getInstance();
    final customerId = prefs.getString('customerId');

    final endpoint =
        "api/dish/getby/vendor/user/dishes?vendorId=$vendorId&customerId=$customerId";

    try {
      final response = await ApiClient.get(endpoint, service: "food");

      debugPrint("📩 Status: ${response.statusCode}");
      debugPrint("📩 Body: ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        final List<CategoryDish> categories = [];
        final List<Dish> dishes = [];

        for (final item in data) {
          if (item['isCategory'] == true || item['parentId'] == 0) {
            categories.add(CategoryDish.fromJson(item));
          } else {
            dishes.add(Dish.fromJson(item));
          }
        }

        return MenuResponse(categories: categories, dishes: dishes);
      }

      // 🔴 BACKEND ERROR (400 / 500)
      final errorJson = jsonDecode(response.body);
      return MenuResponse(
        categories: [],
        dishes: [],
        hasError: true,
        errorMessage: errorJson['message'] ?? 'Something went wrong',
      );
    } catch (e) {
      // 🔴 NETWORK / PARSING ERROR
      return MenuResponse(
        categories: [],
        dishes: [],
        hasError: true,
        errorMessage: 'Unable to load menu. Please try again.',
      );
    }
  }

  static Future<void> saveOrderId(int orderId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('orderId', orderId);
    // print("💾 orderId saved locally: $orderId");
  }

  static Future<Map<String, dynamic>?> fetchOrderById([int? orderId]) async {
    final endpoint = "api/orders/order/$orderId";

    try {
      if (orderId == null) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        orderId = prefs.getInt('orderId');
        // print("🔎 Trying to read 'orderId' from SharedPreferences");

        if (orderId == null) {
          // print("❌ No orderId found in local storage.");
          return null;
        }
      }

      // print("📡 Fetching order with ID: $orderId");
      final response = await ApiClient.get(endpoint, service: "food");

      if (response.statusCode == 200) {
        // print("✅ Order fetched successfully");
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        // print("⚠️ Failed to fetch order. Status: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      // print("❌ Error fetching order: $e");
      return null;
    }
  }

  static Future<void> updateOrderType(String orderType) async {
    final prefs = await SharedPreferences.getInstance();
    final int userId = prefs.getInt('userId') ?? 0;

    final endpoint = "api/cart/change/orderType/$orderType?userId=$userId";

    // Pass empty body since API only uses path
    final res = await ApiClient.put(endpoint, {}, service: "food");
    print("${res.body}");

    if (res.statusCode != 200) {
      throw Exception("Failed to update order type: ${res.body}");
    }
  }

  static Future<bool> removeCartItem(int itemId) async {
    final prefs = await SharedPreferences.getInstance();
    final Object customerId = prefs.getString('customerId') ?? 0;

    // ✅ Relative endpoint only, no base URL
    final endpoint = "api/cart/items/$itemId?customerId=$customerId";

    try {
      final response = await ApiClient.delete(endpoint, service: 'food');

      return response.statusCode == 200;
    } catch (e) {
      // print("⚠️ Error removing cart item: $e");
      return false;
    }
  }

  static Future<Map<String, dynamic>?> scheduleOrder({
    // required int userId,
    required int cartId,
    required DateTime date,
    required TimeOfDay time,
    required String paymentMethod,
    required String razorpayPaymentId,
    required String razorpayOrderId,
    List<String>? walletTypes,
    double? amount,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final Object customerId = prefs.getString('customerId') ?? 0;

    final endpoint = "api/orders/shedule/order/$cartId?customerId=$customerId";

    final body = {
      "date":
          "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
      "time":
          "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00",
      "paymentMethod": paymentMethod,
      "razorpayPaymentId": razorpayPaymentId,
      "razorpayOrderId": razorpayOrderId,
      if (walletTypes != null && walletTypes.isNotEmpty)
        "walletTypes": walletTypes,

      // ✅ AMOUNT
      if (amount != null) "amount": amount,
    };

    try {
      debugPrint("📤 Scheduled Order API URL: $endpoint");
      debugPrint("📦 Request Body: ${jsonEncode(body)}");

      final response = await ApiClient.post(endpoint, body, service: "food");

      debugPrint("📥 Response Status: ${response.statusCode}");
      debugPrint("📥 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error =
            jsonDecode(response.body)['message'] ?? "Failed to place order";
        throw Exception(error);
      }
    } catch (e) {
      debugPrint("❌ Exception in scheduleOrder: $e");
      return null;
    }
  }

  static Future<Map<String, dynamic>?> placeDirectOrder({
    // required int userId,
    required int cartId,
    required String paymentMethod,
    required String razorpayPaymentId,
    required String razorpayOrderId,
    List<String>? walletTypes,
    required double amount, // 🔴 make REQUIRED
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final Object customerId = prefs.getString('customerId') ?? 0;
    // final buffer = StringBuffer(
    //   "api/orders/orders/create/$cartId"
    //   "?userId=$userId"
    //   "&paymentMethod=$paymentMethod"
    //   "&razorpayPaymentId=$razorpayPaymentId"
    //   "&razorpayOrderId=$razorpayOrderId",
    // );

    final buffer = StringBuffer(
      "api/orders/orders/create/$cartId?customerId=$customerId"
      "&paymentMethod=$paymentMethod&razorpayPaymentId=$razorpayPaymentId&razorpayOrderId=$razorpayOrderId",
    );

    for (final type in walletTypes ?? []) {
      buffer.write("&walletTypes=$type");
    }

    buffer.write("&amount=${amount.toStringAsFixed(2)}");

    final endpoint = buffer.toString();

    debugPrint("📤 Direct Order API URL: $endpoint");

    try {
      final response = await ApiClient.post(endpoint, {}, service: "food");
      debugPrint("📥 Response Body: ${response.body}");
      return jsonDecode(response.body);
    } catch (e) {
      debugPrint("❌ Exception: $e");
      return {"message": "Failed to connect to server"};
    }
  }

  static Future<bool> updateCartQuantity(
    // int cartId,
    int itemId,
    int quantity,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final customerId = prefs.getString('customerId');

    // ✅ Relative endpoint only
    final uri = Uri.parse("api/cart/update/item").replace(
      queryParameters: {
        "customerId": customerId,
        "quantity": quantity.toString(),
        "itemId": itemId.toString(),
      },
    );

    final body = {"quantity": quantity};

    try {
      final response = await ApiClient.put(
        uri.toString(),
        body,
        service: 'food',
      );

      print("📝 Update Cart URL: $uri");
      print("📦 Update Cart Body: $body");
      print("📥 Response: ${response.statusCode} → ${response.body}");

      return response.statusCode == 200;
    } catch (e) {
      // print("⚠️ Error updating cart quantity: $e");
      return false;
    }
  }

  static Future<Map<String, dynamic>?> addToCart({
    required int dishId,
    required int quantity,
    required bool sheduleorder,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final customerId = prefs.getString('customerId');

    final endpoint =
        "api/cart/add/item?customerId=$customerId&sheduleorder=$sheduleorder";

    final body = {"dishId": dishId, "quantity": quantity};

    try {
      final response = await ApiClient.post(endpoint, body, service: "food");

      debugPrint("📩 [AddToCart] Status: ${response.statusCode}");
      debugPrint("📩 [AddToCart] Body: ${response.body}");

      final data = jsonDecode(response.body);
      final int? cartId = data['cartId'];

      if (cartId == null) return null;

      /// ✅ Store cartId
      await prefs.setInt('cartId', cartId);

      /// ✅ Return the full response data so caller can extract item details
      return data;
    } catch (e) {
      debugPrint("❌ [AddToCart] Error: $e");
      return null;
    }
  }

  static Future<bool> updateCartItem({
    required int itemId,
    required int quantity,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String customerId = prefs.getString('customerId') ?? "";

      final uri = Uri.parse("api/cart/update/item").replace(
        queryParameters: {
          "customerId": customerId,
          "quantity": quantity,
          "itemId": itemId,
        },
      );

      // print("🟡 [UpdateCartItem] PUT → $endpoint");

      final response = await ApiClient.put(
        uri.toString(),
        {},
        service: "food",
      ); // body optional
      // print(
      //   "📩 UpdateCart Response: ${response.statusCode} → ${response.body}",
      // );

      return response.statusCode == 200;
    } catch (e) {
      // print("❌ [UpdateCartItem] Exception: $e");
      return false;
    }
  }

  static Future<int?> getItemIdByDishId(int dishId) async {
    try {
      final cart = await fetchCart();
      if (cart == null) return null;

      final item = cart.cartItems
          .cast<dynamic>()
          .where((i) => i.dishId == dishId)
          .toList();

      if (item.isNotEmpty) {
        return item.first.itemId;
      } else {
        return null;
      }
    } catch (e) {
      // print("❌ [GetItemIdByDishId] Error: $e");
      return null;
    }
  }

  static Future<int?> getTableItemIdByDishId(int dishId, int seatingId) async {
    try {
      final List<TaleCartModel>? cartList = await fetchTableCart(seatingId);

      if (cartList == null || cartList.isEmpty) {
        return null;
      }

      final TaleCartModel cart = cartList.first;

      final matched = cart.cartItems
          .where((item) => item.dishId == dishId)
          .toList();

      if (matched.isNotEmpty) {
        return matched.first.itemId;
      } else {
        return null;
      }
    } catch (e) {
      // print("❌ [GetItemIdByDishId] Error: $e");
      return null;
    }
  }

  static Future<CartModel?> fetchCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final customerId = prefs.getString('customerId');

      final endpoint =
          "api/cart/get/user/without-seating?customerId=$customerId";

      // print("🔹 Fetching cart for userId: $userId → $endpoint");

      final response = await ApiClient.get(endpoint, service: "food");

      // print("📩 Cart Response: ${response.statusCode} → ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          return CartModel.fromJson(data.first);
        } else {
          // print("⚠️ Cart is empty");
          return null;
        }
      } else {
        throw Exception("Failed to load cart (${response.statusCode})");
      }
    } catch (e) {
      // print("❌ Error fetching cart: $e");
      return null;
    }
  }

  static Future<bool> deleteCart() async {
    final prefs = await SharedPreferences.getInstance();
    final int userId = prefs.getInt("userId") ?? 0;
    final endpoint = "api/cart/delete/user/cart?userId=$userId";

    try {
      final response = await ApiClient.delete(endpoint, service: "food");

      if (response.statusCode == 200) {
        // print("✅ Cart deleted successfully");
        return true;
      } else {
        // print("❌ Failed to delete cart: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      // print("⚠️ Error deleting cart: $e");
      return false;
    }
  }

  static Future<bool> addToTableCart({
    required int dishId,
    required int quantity,
    required int seatingId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final int userId = prefs.getInt('userId') ?? 0;

    final endpoint =
        "api/cart/add/table/cart/$userId/$seatingId"; // ✅ leading /
    final body = {"dishId": dishId, "quantity": quantity};

    print("🛒 Attempting to add to table cart...");
    print("🔹 Endpoint: $endpoint");
    print("🔹 Body: $body");

    try {
      final response = await ApiClient.post(endpoint, body, service: "food");

      print("🔹 Response: ${response.statusCode} → ${response.body}");

      if (response.statusCode != 200 && response.statusCode != 201) {
        return false;
      }

      /// ✅ Decode response
      final data = jsonDecode(response.body);

      /// adjust key name if backend uses different one
      final int? cartId = data['cartId'];

      if (cartId != null) {
        await prefs.setInt('cartId', cartId);
      }

      return true;
    } catch (e) {
      print("⚠️ Error adding to table cart: $e");
      return false;
    }
  }

  static Future<List<FavoriteDish>> getFavoritesByUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final int userId = prefs.getInt('userId') ?? 0;
    final endpoint = "/api/favourite/getallbyuserid/$userId";
    try {
      final response = await ApiClient.get(endpoint, service: "food");

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((item) => FavoriteDish.fromJson(item)).toList();
      } else {
        throw Exception(
          "Failed to load favorite dishes: ${response.statusCode}",
        );
      }
    } catch (e) {
      // debugPrint("❌ Exception in getFavoritesByUserId: $e");
      rethrow;
    }
  }

  static Future<bool> submitBooking({
    required int vendorId,
    required String guestName,
    required String phoneNumber,
    required String bookingDate,
    required String startTime,
    required int capacity,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final int userId = prefs.getInt('userId') ?? 0;
    if (userId == 0) {
      debugPrint("❌ No userId provided");
      return false;
    }

    final endpoint =
        "api/seatingdetails/shedule/advance/booking/$userId/$vendorId";
    final body = {
      "guestName": guestName,
      "phoneNumber": phoneNumber,
      "bookingDate": bookingDate,
      "startTime": startTime,
      "capacity": capacity,
    };

    try {
      final response = await ApiClient.post(endpoint, body, service: "food");

      debugPrint("📤 Booking request: ${jsonEncode(body)}");
      debugPrint(
        "📥 Booking response: ${response.statusCode} ${response.body}",
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint("⚠️ Error submitting booking: $e");
      return false;
    }
  }

  static Future<bool> bookNow({
    required int vendorId,
    required String guestName,
    required String phoneNumber,
    required int capacity,
    int durationMinutes = 45,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final int userId = prefs.getInt('userId') ?? 0;
    // debugPrint("🟠 [BOOK_API] Preparing booking request...");

    if (userId == 0) {
      // debugPrint("❌ [BOOK_API] No userId provided");
      return false;
    }

    final endpoint =
        "api/seatingdetails/booknow/$userId/$vendorId?capacity=$capacity&guestName=$guestName&phoneNumber=$phoneNumber";

    try {
      // debugPrint("📤 [BOOK_API] Sending POST to: $endpoint");

      final response = await ApiClient.post(endpoint, {}, service: "food");

      // debugPrint("📥 [BOOK_API] Response: ${response.statusCode} → ${response.body}");

      final ok = response.statusCode == 200 || response.statusCode == 202;
      // debugPrint(
      //   ok
      //       ? "✅ [BOOK_API] Booking succeeded"
      //       : "⚠️ [BOOK_API] Booking failed with status ${response.statusCode}",
      // );

      return ok;
    } catch (e) {
      // debugPrint("🚨 [BOOK_API] Error submitting booking: $e");
      return false;
    }
  }

  static Future<bool> addToFavorites(int dishId) async {
    final prefs = await SharedPreferences.getInstance();
    final int userId = prefs.getInt('userId') ?? 0;

    final endpoint = 'api/favourite/add/$userId/$dishId';
    final body = {
      'userId': userId,
      'dishId': dishId,
    }; // safer if backend expects body

    try {
      // print("📤 Body: ${jsonEncode(body)}");

      final response = await ApiClient.post(endpoint, body, service: "food");

      // print("📥 Response: ${response.statusCode} → ${response.body}");

      return response.statusCode == 200;
    } catch (e) {
      // print('⚠️ FavoriteService error: $e');
      return false;
    }
  }

  static Future<bool> unfavoriteDish(int favId) async {
    final endpoint = "api/favourite/delete/$favId";

    try {
      final response = await ApiClient.delete(endpoint, service: "food");
      // print(
      //   "📩 Unfavorite Response: ${response.statusCode} → ${response.body}",
      // );

      return response.statusCode == 200;
    } catch (e) {
      // print("⚠️ FavoriteService error: $e");
      return false;
    }
  }

  static Future<List<WaitingItem>> fetchWaitingList() async {
    final prefs = await SharedPreferences.getInstance();
    final int userId = prefs.getInt('userId') ?? 0;

    if (userId == 0) {
      // debugPrint("❌ No userId found in SharedPreferences");
      return [];
    }

    final endpoint = "api/seatingdetails/waiting/user/$userId";

    try {
      final response = await ApiClient.get(
        endpoint,
        service: "food",
      ); // Using API helper
      // debugPrint(
      //   "📥 Waiting list response: ${response.statusCode} ${response.body}",
      // );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);

        if (body is Map<String, dynamic>) {
          return [WaitingItem.fromJson(body)];
        } else if (body is List) {
          return body.map((e) => WaitingItem.fromJson(e)).toList();
        }
      }

      // debugPrint("❌ Failed to fetch waiting list: ${response.body}");
      return [];
    } catch (e) {
      // debugPrint("⚠️ Error fetching waiting list: $e");
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getAllOrdersByUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final customerId = prefs.getString('customerId');

    if (customerId == null) {
      // print("❌ User ID is null");
      return [];
    }

    // ✅ Relative endpoint only
    final endpoint = "api/orders/user/orders?customerId=$customerId";

    try {
      // ✅ Use correct service if needed
      final response = await ApiClient.get(endpoint, service: 'food');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data is List) {
          return data.cast<Map<String, dynamic>>();
        } else if (data is Map && data.containsKey('orders')) {
          return (data['orders'] as List).cast<Map<String, dynamic>>();
        } else {
          // print('⚠️ Unexpected data format');
          return [];
        }
      } else {
        // print('❌ Failed to fetch orders: ${response.statusCode}');
        // print('❌ Body: ${response.body}');
        return [];
      }
    } catch (e) {
      // print('⚠️ Error fetching orders: $e');
      return [];
    }
  }

  static Future<int> fetchRating(int orderId) async {
    // ✅ Relative endpoint only
    final endpoint = "api/orders/order/$orderId";
    try {
      // ✅ Use ApiClient.get and specify service if needed
      final response = await ApiClient.get(endpoint, service: 'food');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["ratings"] ?? 0;
      } else {
        // print("❌ Failed to fetch rating: ${response.statusCode}");
        // print("❌ Body: ${response.body}");
        return 0;
      }
    } catch (e) {
      // print("⚠️ Error fetching rating: $e");
      return 0;
    }
  }

  static Future<bool> submitRating(int userId, int orderId, int rating) async {
    final endpoint = "api/orders/feedback/$orderId";

    try {
      final response = await ApiClient.put(endpoint, {
        "ratings": rating,
      }, service: 'food');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // print("✅ Rating submitted: $rating");
        return true;
      } else {
        // print("❌ Failed to submit rating. Status: ${response.statusCode}");
        // print("❌ Body: ${response.body}");
        return false;
      }
    } catch (e) {
      // print("⚠️ Error submitting rating: $e");
      return false;
    }
  }

  static Future<List<Ticket>> fetchTicketsByUser() async {
    final prefs = await SharedPreferences.getInstance();
    final int userId = prefs.getInt('userId') ?? 0;
    if (userId == 0) {
      // debugPrint("❌ Invalid userId: $userId");
      return [];
    }

    final endpoint = "api/tickets/user/$userId"; // relative path
    // debugPrint("📡 Fetching tickets from: $endpoint");

    try {
      final response = await ApiClient.get(endpoint, service: 'food');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        try {
          final List<dynamic> data = jsonDecode(response.body);
          // debugPrint("✅ Tickets fetched: ${data.length}");
          return data.map((json) => Ticket.fromJson(json)).toList();
        } catch (jsonError) {
          // debugPrint("⚠️ Failed to parse tickets JSON: $jsonError");
          return [];
        }
      } else {
        // debugPrint(
        //   "⚠️ Failed to fetch tickets: ${response.statusCode} → ${response.body}",
        // );
        return [];
      }
    } catch (e) {
      // debugPrint("❌ Exception in fetchTicketsByUser: $e");
      return [];
    }
  }

  static Future<Response> createTicket({
    int? orderId,
    required String message,
    String? category,
    File? attachmentFile,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final int userId = prefs.getInt('userId') ?? 0;

    // 🔹 Endpoint logic
    final String endpoint = orderId != null
        ? "api/tickets/create/$orderId"
        : "api/tickets/create";

    // 🔹 Ticket type logic
    final String ticketType = orderId != null
        ? "DELIVERY_ISSUE"
        : (category?.toUpperCase().replaceAll(' ', '_') ?? "GENERAL");

    // 🔹 Normal multipart fields
    final Map<String, dynamic> ticketData = {
      "userId": userId,
      "ticketType": ticketType,
      "message": message.trim(),
    };

    // 🔹 Optional file
    final Map<String, File>? files = attachmentFile != null
        ? {"attachment": attachmentFile}
        : null;

    final Map<String, dynamic> multipartData = {
      "ticketData": jsonEncode(ticketData), // ✅ KEY FIX
    };

    debugPrint("📤 Multipart POST → $endpoint");
    debugPrint("📤 Fields → $ticketData");
    if (files != null) {
      debugPrint("📤 File attached → ${attachmentFile!.path}");
    }

    try {
      final response = await ApiClient.sendMultipartRequest(
        endpoint: endpoint,
        method: "POST",
        service: "food",
        data: multipartData,
        files: files,
      );

      debugPrint("📥 Response ${response.statusCode} → ${response.body}");
      return response;
    } catch (e) {
      debugPrint("❌ Error creating ticket (multipart): $e");
      rethrow;
    }
  }

  static Future<List<ConfirmedList>> fetchConfirmedList() async {
    final prefs = await SharedPreferences.getInstance();
    final int userId = prefs.getInt('userId') ?? 0;

    if (userId == 0) {
      // debugPrint("❌ No userId found in SharedPreferences");
      return [];
    }

    final endpoint = "api/seatingdetails/get/by/$userId";

    try {
      final response = await ApiClient.get(
        endpoint,
        service: "food",
      ); // Using API helper
      // debugPrint(
      //   "📥 Confirmed list response: ${response.statusCode} ${response.body}",
      // );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);

        if (body is Map<String, dynamic>) {
          return [ConfirmedList.fromJson(body)];
        } else if (body is List) {
          return body.map((e) => ConfirmedList.fromJson(e)).toList();
        }
      }

      // debugPrint("❌ Failed to fetch confirmed list: ${response.body}");
      return [];
    } catch (e) {
      // debugPrint("⚠️ Error fetching confirmed list: $e");
      return [];
    }
  }

  static Future<bool> sendArrivalStatus(int seatingId) async {
    final endpoint = "api/seatingdetails/seating-details/$seatingId";
    final body = {'arrivalStatus': 'ARRIVED'};

    try {
      final response = await ApiClient.put(endpoint, body, service: "food");

      if (response.statusCode == 200 || response.statusCode == 201) {
        // SAVE TO LOCAL STORAGE
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('id', seatingId);

        // debugPrint("Stored seatingId = $seatingId");

        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<List<TaleCartModel>> fetchTableCart(int seatingId) async {
    final prefs = await SharedPreferences.getInstance();
    final int userId = prefs.getInt('userId') ?? 0;

    final endpoint = "api/cart/$userId/with-seating";

    try {
      final response = await ApiClient.get(endpoint, service: "food");

      debugPrint("📡 Fetch table cart URL: $endpoint");
      debugPrint("📥 Response status: ${response.statusCode}");
      debugPrint("📥 Response body: ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => TaleCartModel.fromJson(json)).toList();
      } else {
        debugPrint('❌ Failed to load cart data: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('⚠️ Error fetching table cart: $e');
      return [];
    }
  }

  static Future<bool> updateCartItemStatus({
    required int itemId,
    required String status,
    String? note,
  }) async {
    final endpoint = "api/cart/cartitem/status/$itemId?status=$status";

    try {
      // Call PUT with just the endpoint
      final response = await ApiClient.put(endpoint, {}, service: "food");

      // debugPrint("🛠️ PUT Request URL: $endpoint");
      // debugPrint("🔹 Response: ${response.statusCode} ${response.body}");

      return response.statusCode == 200;
    } catch (e) {
      // debugPrint("❌ Error updating cart item status: $e");
      return false;
    }
  }

  static Future<bool> updateCartItemQuantity({
    required int itemId,
    required int quantity,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final int? userId = prefs.getInt('userId');
      if (userId == null || userId == 0) {
        // debugPrint("❌ Invalid or missing userId in SharedPreferences");
        return false;
      }

      final endpoint =
          "api/cart/update/$userId?quantity=$quantity&itemId=$itemId";

      // Use an empty body if your API does not expect one
      final response = await ApiClient.put(endpoint, {}, service: "food");

      debugPrint("🛠️ PUT Request URL: $endpoint");
      debugPrint("🔹 Response: ${response.statusCode} ${response.body}");

      return response.statusCode == 200;
    } catch (e) {
      debugPrint("❌ Exception while updating cart item quantity: $e");
      return false;
    }
  }

  static Future<Map<String, dynamic>?> placeOrder({
    required int userId,
    required String paymentMethod,
    required String razorpayPaymentId,
    required String razorpayOrderId,
    String? walletType,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final cartId = prefs.getInt('cartId');

    if (cartId == null) {
      // debugPrint("❌ No cartId found in SharedPreferences");
      return {"success": false, "error": "Cart ID missing"};
    }

    final buffer = StringBuffer(
      "api/orders/orders/create/$cartId"
      "?userId=$userId"
      "&paymentMethod=$paymentMethod"
      "&razorpayPaymentId=$razorpayPaymentId"
      "&razorpayOrderId=$razorpayOrderId",
    );

    if (walletType != null) {
      buffer.write("&walletType=$walletType");
    }

    final url = buffer.toString();
    debugPrint("📤 Placing order with URL: $url");

    try {
      final response = await ApiClient.post(url, {}, service: 'food');
      debugPrint("📥 Response Status: ${response.statusCode}");
      debugPrint("📥 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final orderId = data['orderId'];
        if (orderId == null) {
          debugPrint("⚠️ orderId missing in API response");
          return {
            "success": false,
            "error": "Invalid response: orderId missing",
          };
        }

        await prefs.setInt('orderId', orderId);
        return {"success": true, "orderId": orderId};
      } else {
        return {
          "success": false,
          "error": "Failed to place order: ${response.body}",
        };
      }
    } catch (e) {
      debugPrint("⚠️ Error placing order: $e");
      return {"success": false, "error": e.toString()};
    }
  }

  // 🔥 FIXED updateCartSettings - Handles both apply & remove correctly
  static Future<CouponResult> updateCartSettings({
    required int cartId,
    dynamic couponId, // nullable
    required String applyCoupon,
  }) async {
    try {
      final endpoint = "api/cart/coupon/$cartId";

      final Map<String, dynamic> body = {"applyCoupon": applyCoupon};

      if (couponId != null) {
        body["id"] = couponId is String ? int.parse(couponId) : couponId;
      }

      debugPrint("🔥 PUT $endpoint");
      debugPrint("🔥 BODY: ${jsonEncode(body)}");

      final response = await ApiClient.put(endpoint, body, service: "food");

      debugPrint("🔥 STATUS: ${response.statusCode}");
      debugPrint("🔥 RESPONSE: ${response.body}");

      if (response.statusCode == 200) {
        return CouponResult(success: true);
      } else {
        // Try to parse error message from backend
        // ignore: unnecessary_null_comparison
        final errorMsg = response.body != null
            ? jsonDecode(response.body)["message"] ?? "Failed to apply coupon"
            : "Failed to apply coupon";

        return CouponResult(success: false, error: errorMsg);
      }
    } catch (e) {
      debugPrint("❌ updateCartSettings Error: $e");
      return CouponResult(success: false, error: e.toString());
    }
  }

  static Future<bool> updateServiceCharges({
    required int cartId,
    required String serviceCharge,
  }) async {
    final endpoint = "api/cart/coupon/$cartId";

    final body = {"serviceCharge": serviceCharge};

    // debugPrint("🔹 PUT Endpoint: $endpoint");
    // debugPrint("🔹 Request Body: $body");

    try {
      final response = await ApiClient.put(endpoint, body, service: "food");

      // debugPrint("🔹 Status Code: ${response.statusCode}");
      // debugPrint("🔹 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        // debugPrint("✅ Service charges updated successfully");
        return true;
      } else {
        // debugPrint("❌ Failed to update service charges");
        return false;
      }
    } catch (e) {
      // debugPrint("❌ Exception updating service charges: $e");
      return false;
    }
  }

  static Future<bool> createCart(String orderType) async {
    final prefs = await SharedPreferences.getInstance();
    final customerId = prefs.getString('customerId') ?? '';

    final endpoint =
        'api/cart/create/cart/orderType?customerId=$customerId&orderType=$orderType';

    try {
      final response = await ApiClient.post(endpoint, {}, service: "food");

      debugPrint(
        "📩 Cart Create Response: ${response.statusCode} → ${response.body}",
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final int? cartId = data['cartId'];

        if (cartId != null) {
          // Store cartId and orderType in local storage
          await prefs.setInt('cartId', cartId);
          await prefs.setString('orderType', orderType);

          // debugPrint("🛒 Cart Created with ID: $cartId");
          // debugPrint("📦 OrderType saved: $orderType");
          return true;
        } else {
          // debugPrint("⚠️ CartId missing in response: $data");
          return false;
        }
      } else {
        // debugPrint("❌ Failed to create cart: ${response.body}");
        return false;
      }
    } catch (e) {
      // debugPrint("⚠️ Exception while creating cart: $e");
      return false;
    }
  }

  static Future<List<Restaurent_Banner>> fetchBanner() async {
    final endpoint = 'api/bannner/getall';

    try {
      final response = await ApiClient.get(
        endpoint,
        service: "food",
      ); // token included

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((e) => Restaurent_Banner.fromJson(e)).toList();
      } else {
        // debugPrint("Failed to fetch banners: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      // debugPrint("Error fetching banners: $e");
      return [];
    }
  }

  static Future<String?> createOrder(double amount) async {
    try {
      String endpoint = "api/payments/create-order/user";

      final body = {
        "amount": amount,
        "currency": "INR",
        "receipt": "receipt#${DateTime.now().millisecondsSinceEpoch}",
        "notes": {"key1": "value3", "key2": "value2"},
      };

      final res = await ApiClient.post(endpoint, body, service: "food");

      // debugPrint("📤 CreateOrder Response: ${res.statusCode} ${res.body}");

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data["orderId"] ?? data["id"]; // ensure correct key
      }

      // debugPrint("❌ Order creation failed: ${res.body}");
      return null;
    } catch (e) {
      // debugPrint("⚠️ Exception in createOrder: $e");
      return null;
    }
  }

  // 2️⃣ CAPTURE PAYMENT
  static Future<bool> capturePayment({
    required String paymentId,
    required double amount,
  }) async {
    try {
      String endpoint = "api/payments/capture";

      final body = {
        "paymentId": paymentId,
        "amount": amount,
        "currency": "INR",
        "receipt":
            "order#${DateTime.now().millisecondsSinceEpoch} for wallet top-up",
      };

      final res = await ApiClient.post(endpoint, body, service: "food");
      // debugPrint("💰 Capture Payment Response: ${res.statusCode} ${res.body}");

      return res.statusCode == 200;
    } catch (e) {
      // debugPrint("❌ Capture API Exception: $e");
      return false;
    }
  }

  static Future<List<Advertisement>> fetchAdvertisements() async {
    const String endpoint = 'api/advertisements/valid';

    try {
      final response = await ApiClient.get(endpoint, service: "food");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint(" fetch advertisements: ${response.body}");

        // Supports API returning object OR list
        final List<dynamic> adsList = data is List ? data : [data];

        return adsList.map((e) => Advertisement.fromJson(e)).toList();
      } else {
        debugPrint("❌ Failed to fetch advertisements: ${response.statusCode}");

        return [];
      }
    } catch (e) {
      debugPrint("⚠️ Error fetching advertisements: $e");
      return [];
    }
  }

  static Future<int> fetchCartCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');

      if (userId == null) return 0;

      final response = await ApiClient.get(
        "api/cart/user/count/$userId",
        service: "food", // or "Mamaswebsite" depending on your setup
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // debugPrint("🛒 Cart count → $data");
        return data is int ? data : int.tryParse(data.toString()) ?? 0;
      } else {
        // debugPrint("❌ Failed to fetch cart count → ${response.statusCode}");
        return 0;
      }
    } catch (e) {
      // debugPrint("💥 Error fetching cart count: $e");
      return 0;
    }
  }

  static Future<bool> updateDeliveryAddress({
    required int cartId,
    required int addressId,
  }) async {
    try {
      final body = {"addressId": addressId, "cartId": cartId};

      final response = await ApiClient.post(
        "api/cart/delivery/$cartId/address/$addressId",
        body,
        service: "food",
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Update Address Error: $e");
      return false;
    }
  }

  Future<List<FoodCategory>> fetchFoodCategories() async {
    debugPrint("🚀 START fetchFoodCategories");

    try {
      final prefs = await SharedPreferences.getInstance();
      final customerId = prefs.getString('customerId');

      if (customerId == null || customerId.isEmpty) {
        debugPrint("❌ customerId is NULL or EMPTY");
        return [];
      }

      final endpoint = "api/dish/dish/getall/categeory?customerId=$customerId";

      final response = await ApiClient.get(endpoint, service: "food");

      debugPrint("Status Code → ${response.statusCode}");
      debugPrint("Response Body → ${response.body}");

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        // Case 1: Direct List
        if (decoded is List) {
          return decoded.map((e) => FoodCategory.fromJson(e)).toList();
        }

        // Case 2: Wrapped inside "data"
        if (decoded is Map && decoded['data'] is List) {
          return (decoded['data'] as List)
              .map((e) => FoodCategory.fromJson(e))
              .toList();
        }
      }

      debugPrint("❌ Failed to fetch categories");
      return [];
    } catch (e, stack) {
      debugPrint("🔥 EXCEPTION: $e");
      debugPrint("$stack");
      return [];
    }
  }
}
