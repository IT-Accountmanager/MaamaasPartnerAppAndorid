// import 'dart:convert';
// import 'package:dio/dio.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
//
// const String _food = 'http://staging.maamaas.com:8080/food';
//
// class CartService {
//   static const _storage = FlutterSecureStorage();
//   static final Dio _dio = Dio();
//
//
//   static Future<Map<String, String>> _headers() async {
//     final token = await _storage.read(key: 'token');
//     return {
//       'Content-Type': 'application/json',
//       if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
//     };
//   }
//
//   static Future<Map<String, dynamic>?> fetchCart(
//     int vendorId,
//     int bookingId,
//   ) async {
//     try {
//       final h = await _headers();
//       final res = await _dio.get(
//         '$_food/api/cart/getby/table/$vendorId/$bookingId',
//         options: Options(headers: h),
//       );
//       if (res.statusCode == 200) return res.data as Map<String, dynamic>;
//     } catch (e) {
//       debugPrint('❌ fetchCart: $e');
//     }
//     return null;
//   }
//
//   static Future<List<dynamic>> fetchAvailableTables(int vendorId) async {
//     try {
//       final h = await _headers();
//       final res = await _dio.get(
//         '$_food/api/seating/all/vendor/$vendorId',
//         options: Options(headers: h),
//       );
//       if (res.statusCode == 200) {
//         final all = res.data as List<dynamic>;
//         return all
//             .where(
//               (t) =>
//                   (t['seatingStatus'] as String?)?.toLowerCase() == 'available',
//             )
//             .toList();
//       }
//     } catch (e) {
//       debugPrint('❌ fetchAvailableTables: $e');
//     }
//     return [];
//   }
//
//   // ─── Fetch removal/table requests ─────────────────────────────────────────
//   static Future<List<dynamic>> fetchRemovalRequests(int cartId) async {
//     try {
//       final h = await _headers();
//       final res = await _dio.get(
//         '$_food/api/table-requests/cart/$cartId',
//         options: Options(headers: h),
//       );
//       if (res.statusCode == 200) {
//         final list = res.data as List<dynamic>;
//         return list.where((r) => r['status'] == 'PENDING').toList();
//       }
//     } catch (e) {
//       debugPrint('❌ fetchRemovalRequests: $e');
//     }
//     return [];
//   }
//
//   // ─── Create booking (seating detail) ─────────────────────────────────────
//   static Future<int?> createBooking({
//     required int vendorId,
//     required int seatingId,
//     required String tableCode,
//     required int capacity,
//     required String tableName,
//     String guestName = '',
//     String phoneNumber = '',
//   }) async {
//     try {
//       final h = await _headers();
//       final now = DateTime.now();
//       final time =
//           '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
//       final date =
//           '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
//
//       final payload = {
//         'startTime': time,
//         'phoneNumber': phoneNumber,
//         'guestName': guestName,
//         'bookingDate': date,
//         'arrivalStatus': 'ARRIVED',
//         'types': 'BOOK_NOW',
//         'capacity': capacity,
//         'durationMinutes': '',
//         'seating': {
//           'id': seatingId,
//           'name': tableName,
//           'seatingStatus': 'Occupied',
//           'code': tableCode,
//           'capacity': capacity,
//           'description': '',
//           'remarks': '',
//           'manuallyUpdated': true,
//         },
//         'seatingId': seatingId,
//         'vendorId': vendorId,
//         'code': tableCode,
//       };
//
//       final res = await _dio.post(
//         '$_food/api/seatingdetails/vendor/$vendorId',
//         data: payload,
//         options: Options(headers: h),
//       );
//       return res.data?['id'] as int?;
//     } catch (e) {
//       debugPrint('❌ createBooking: $e');
//       rethrow;
//     }
//   }
//
//   // ─── Add items to cart ────────────────────────────────────────────────────
//   static Future<dynamic> addItemsToCart({
//     required int vendorId,
//     required int bookingId,
//     required String tableCode,
//     required List<Map<String, dynamic>> items,
//     int? userId,
//   }) async {
//     try {
//       final h = await _headers();
//       final String url;
//       if (userId != null) {
//         url =
//             '$_food/api/cart/add/table/cart/add-item?userId=$userId&seatingId=$bookingId';
//       } else {
//         url =
//             '$_food/api/cart/waiter-order/$vendorId/$bookingId?tableCode=$tableCode';
//       }
//       final res = await _dio.post(
//         url,
//         data: items,
//         options: Options(headers: h),
//       );
//       return res.data;
//     } catch (e) {
//       debugPrint('❌ addItemsToCart: $e');
//       rethrow;
//     }
//   }
//
//   // ─── Update item status / quantity ───────────────────────────────────────
//   static Future<void> updateItemStatus({
//     required int cartId,
//     required int itemId,
//     required int quantity,
//     required String status,
//     String note = '',
//   }) async {
//     try {
//       final h = await _headers();
//       await _dio.put(
//         '$_food/api/cart/update/table/quantity/status/$cartId?itemId=$itemId&quantity=$quantity&status=$status&note=${Uri.encodeComponent(note)}',
//         options: Options(headers: h),
//       );
//     } catch (e) {
//       debugPrint('❌ updateItemStatus: $e');
//       rethrow;
//     }
//   }
//
//   // ─── Remove item from cart ────────────────────────────────────────────────
//   static Future<void> removeItem(int vendorId, int cartId, int itemId) async {
//     try {
//       final h = await _headers();
//       await _dio.delete(
//         '$_food/api/cart/vendor/items/$vendorId/$cartId/$itemId',
//         options: Options(headers: h),
//       );
//     } catch (e) {
//       debugPrint('❌ removeItem: $e');
//       rethrow;
//     }
//   }
//
//   // ─── Add tip ──────────────────────────────────────────────────────────────
//   static Future<void> addTip({
//     required int cartId,
//     required double amount,
//     required bool apply,
//   }) async {
//     try {
//       final h = await _headers();
//       await _dio.post(
//         '$_food/api/cart/add/tip/$cartId?tipAmount=$amount&apply=$apply',
//         options: Options(headers: h),
//       );
//     } catch (e) {
//       debugPrint('❌ addTip: $e');
//       rethrow;
//     }
//   }
//
//   // ─── Apply / remove discount ──────────────────────────────────────────────
//   static Future<void> applyDiscount({
//     required int cartId,
//     required double discountAmount,
//     required bool apply,
//   }) async {
//     try {
//       final h = await _headers();
//       await _dio.put(
//         '$_food/api/cart/apply/discount/from/vendor/$cartId?discountAmount=$discountAmount&isPercentage=true&apply=$apply',
//         options: Options(headers: h),
//       );
//     } catch (e) {
//       debugPrint('❌ applyDiscount: $e');
//       rethrow;
//     }
//   }
//
//   // ─── Update request status ────────────────────────────────────────────────
//   static Future<void> updateRequestStatus(int requestId, String status) async {
//     try {
//       final h = await _headers();
//       await _dio.put(
//         '$_food/api/table-requests/update/$requestId?status=$status',
//         options: Options(headers: h),
//       );
//     } catch (e) {
//       debugPrint('❌ updateRequestStatus: $e');
//       rethrow;
//     }
//   }
//
//   // ─── Fetch billing config ─────────────────────────────────────────────────
//   static Future<Map<String, dynamic>?> fetchBillingConfig(int vendorId) async {
//     try {
//       final h = await _headers();
//       final res = await _dio.get(
//         '$_food/api/billing/get/$vendorId',
//         options: Options(headers: h),
//       );
//       return res.data as Map<String, dynamic>?;
//     } catch (e) {
//       debugPrint('❌ fetchBillingConfig: $e');
//     }
//     return null;
//   }
//
//   // ─── Update cart table details ────────────────────────────────────────────
//   static Future<void> updateCartDetails({
//     required int cartId,
//     required int newSeatingId,
//     required String customerName,
//     required String phoneNumber,
//   }) async {
//     try {
//       final h = await _headers();
//       await _dio.put(
//         '$_food/api/cart/update/cart/details/$cartId',
//         data: {
//           'seatingId': newSeatingId,
//           'customerName': customerName,
//           'phoneNumber': phoneNumber,
//         },
//         options: Options(headers: h),
//       );
//     } catch (e) {
//       debugPrint('❌ updateCartDetails: $e');
//       rethrow;
//     }
//   }
//
//   // ─── Delete old seating detail ────────────────────────────────────────────
//   static Future<void> deleteSeatingDetail(int seatingDetailId) async {
//     try {
//       final h = await _headers();
//       await _dio.delete(
//         '$_food/api/seatingdetails/seatingdetails/$seatingDetailId',
//         options: Options(headers: h),
//       );
//     } catch (e) {
//       debugPrint('❌ deleteSeatingDetail: $e');
//     }
//   }
//
//   // ─── Create vendor order (cash / UPI) ─────────────────────────────────────
//   static Future<Map<String, dynamic>?> createVendorOrder({
//     required int cartId,
//     required int vendorId,
//     required String paymentMethod,
//     required String phoneNumber,
//   }) async {
//     try {
//       final h = await _headers();
//       final res = await _dio.post(
//         '$_food/api/orders/orders/vendor/create/$cartId?vendorId=$vendorId&paymentMethod=$paymentMethod&phoneNumber=$phoneNumber',
//         data: [],
//         options: Options(headers: h),
//       );
//       return res.data as Map<String, dynamic>?;
//     } catch (e) {
//       debugPrint('❌ createVendorOrder: $e');
//       rethrow;
//     }
//   }
//
//   // ─── Fetch order details ──────────────────────────────────────────────────
//   static Future<Map<String, dynamic>?> fetchOrderDetails(int orderId) async {
//     try {
//       final h = await _headers();
//       final res = await _dio.get(
//         '$_food/api/orders/order/$orderId',
//         options: Options(headers: h),
//       );
//       return res.data as Map<String, dynamic>?;
//     } catch (e) {
//       debugPrint('❌ fetchOrderDetails: $e');
//     }
//     return null;
//   }
//
//
//   // Add these methods to your CartService class
//
//   static Future<Map<String, dynamic>?> createDynamicQr({
//     required double amount,
//     required int cartId,
//     required int vendorId,
//     required String phone,
//     required String orderId,
//   }) async {
//     try {
//       final response = await _dio.post(
//         '$_food/api/payments/create/qr',
//         data: {
//           'amount': amount,
//           'cartId': cartId,
//           'vendorId': vendorId,
//           'phone': phone,
//           'orderId': orderId,
//         },
//         options: Options(headers: await _headers()),
//       );
//
//       if (response.statusCode == 200) {
//         return response.data as Map<String, dynamic>;
//       }
//       return null;
//     } catch (e) {
//       debugPrint('❌ createDynamicQr error: $e');
//       return null;
//     }
//   }
//
//   static Future<String?> checkPaymentStatus(int cartId) async {
//     try {
//       final response = await _dio.get(
//         '$_food/api/orders/order/check/status',
//         queryParameters: {'cartId': cartId.toString()},
//         options: Options(headers: await _headers()),
//       );
//
//       if (response.statusCode == 200) {
//         final data = response.data;
//         final status = (data['status'] ?? data['paymentStatus'] ?? 'pending').toString().toLowerCase();
//         return status;
//       }
//       return null;
//     } catch (e) {
//       debugPrint('❌ checkPaymentStatus error: $e');
//       return null;
//     }
//   }
//
//   static Future<bool> addCashBilling(int orderId, Map<String, dynamic> payload) async {
//     try {
//       final response = await _dio.post(
//         '$_food/api/cash-billing/addCash/$orderId',
//         data: payload,
//         options: Options(headers: await _headers()),
//       );
//       return response.statusCode == 200 || response.statusCode == 201;
//     } catch (e) {
//       debugPrint('❌ addCashBilling error: $e');
//       return false;
//     }
//   }
// }
import 'dart:convert';

import 'package:flutter/foundation.dart';
import '../../API/Apiclient.dart';

class CartService {
  static Future<Map<String, dynamic>?> fetchCart(
    int vendorId,
    int bookingId,
  ) async {
    try {
      final response = await ApiClient.get(
        'api/cart/getby/table/$vendorId/$bookingId',
        service: 'food',
      );
      if (response.statusCode == 200) return jsonDecode(response.body);
    } catch (e) {
      debugPrint('❌ fetchCart: $e');
    }
    return null;
  }

  static Future<List<dynamic>> fetchAvailableTables(int vendorId) async {
    try {
      final response = await ApiClient.get(
        'api/seating/all/vendor/$vendorId',
        service: 'food',
      );
      if (response.statusCode == 200) {
        final all = jsonDecode(response.body) as List<dynamic>;
        return all.where((t) {
          return (t['seatingStatus'] as String?)?.toLowerCase() == 'available';
        }).toList();
      }
    } catch (e) {
      debugPrint('❌ fetchAvailableTables: $e');
    }
    return [];
  }

  static Future<List<dynamic>> fetchRemovalRequests(int cartId) async {
    try {
      final response = await ApiClient.get(
        'api/table-requests/cart/$cartId',
        service: 'food',
      );
      if (response.statusCode == 200) {
        final list = jsonDecode(response.body) as List<dynamic>;
        return list.where((r) => r['status'] == 'PENDING').toList();
      }
    } catch (e) {
      debugPrint('❌ fetchRemovalRequests: $e');
    }
    return [];
  }

  static Future<int?> createBooking({
    required int vendorId,
    required int seatingId,
    required String tableCode,
    required int capacity,
    required String tableName,
    String guestName = '',
    String phoneNumber = '',
  }) async {
    try {
      final now = DateTime.now();
      final payload = {
        'startTime':
            '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}',
        'phoneNumber': phoneNumber,
        'guestName': guestName,
        'bookingDate':
            '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}',
        'arrivalStatus': 'ARRIVED',
        'types': 'BOOK_NOW',
        'capacity': capacity,
        'durationMinutes': '',
        'seating': {
          'id': seatingId,
          'name': tableName,
          'seatingStatus': 'Occupied',
          'code': tableCode,
          'capacity': capacity,
          'description': '',
          'remarks': '',
          'manuallyUpdated': true,
        },
        'seatingId': seatingId,
        'vendorId': vendorId,
        'code': tableCode,
      };

      final response = await ApiClient.post(
        'api/seatingdetails/vendor/$vendorId',
        payload,
        service: 'food',
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body)['id'];
      }
    } catch (e) {
      debugPrint('❌ createBooking: $e');
      rethrow;
    }
    return null;
  }

  static Future<dynamic> addItemsToCart({
    required int vendorId,
    required int bookingId,
    required String tableCode,
    required List<Map<String, dynamic>> items,
    int? userId,
  }) async {
    try {
      final String endpoint;
      if (userId != null) {
        endpoint =
            'api/cart/add/table/cart/add-item?userId=$userId&seatingId=$bookingId';
      } else {
        endpoint =
            'api/cart/waiter-order/$vendorId/$bookingId?tableCode=$tableCode';
      }

      final response = await ApiClient.post(endpoint, items, service: 'food');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint('❌ addItemsToCart: $e');
      rethrow;
    }
    return null;
  }

  static Future<void> updateItemStatus({
    required int cartId,
    required int itemId,
    required int quantity,
    required String status,
    String note = '',
  }) async {
    try {
      // Build query string into the endpoint since ApiClient.put doesn't support queryParams
      final endpoint =
          'api/cart/update/table/quantity/status/$cartId?itemId=$itemId&quantity=$quantity&status=$status&note=$note';

      await ApiClient.put(endpoint, null, service: 'food');
    } catch (e) {
      debugPrint('❌ updateItemStatus: $e');
      rethrow;
    }
  }

  static Future<void> removeItem(int vendorId, int cartId, int itemId) async {
    try {
      await ApiClient.delete(
        'api/cart/vendor/items/$vendorId/$cartId/$itemId',
        service: 'food',
      );
    } catch (e) {
      debugPrint('❌ removeItem: $e');
      rethrow;
    }
  }

  static Future<void> addTip({
    required int cartId,
    required double amount,
    required bool apply,
  }) async {
    try {
      final endpoint =
          'api/cart/add/tip/$cartId?tipAmount=$amount&apply=$apply';
      await ApiClient.post(endpoint, null, service: 'food');
    } catch (e) {
      debugPrint('❌ addTip: $e');
      rethrow;
    }
  }

  static Future<void> applyDiscount({
    required int cartId,
    required double discountAmount,
    required bool apply,
  }) async {
    try {
      final endpoint =
          'api/cart/apply/discount/from/vendor/$cartId?discountAmount=$discountAmount&isPercentage=true&apply=$apply';
      await ApiClient.put(endpoint, null, service: 'food');
    } catch (e) {
      debugPrint('❌ applyDiscount: $e');
      rethrow;
    }
  }

  static Future<void> updateRequestStatus(int requestId, String status) async {
    try {
      await ApiClient.put(
        'api/table-requests/update/$requestId?status=$status',
        null,
        service: 'food',
      );
    } catch (e) {
      debugPrint('❌ updateRequestStatus: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>?> fetchBillingConfig(int vendorId) async {
    try {
      final response = await ApiClient.get(
        'api/billing/get/$vendorId',
        service: 'food',
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>?;
      }
    } catch (e) {
      debugPrint('❌ fetchBillingConfig: $e');
    }
    return null;
  }

  static Future<void> updateCartDetails({
    required int cartId,
    required int newSeatingId,
    required String customerName,
    required String phoneNumber,
  }) async {
    try {
      await ApiClient.put('api/cart/update/cart/details/$cartId', {
        'seatingId': newSeatingId,
        'customerName': customerName,
        'phoneNumber': phoneNumber,
      }, service: 'food');
    } catch (e) {
      debugPrint('❌ updateCartDetails: $e');
      rethrow;
    }
  }

  static Future<void> deleteSeatingDetail(int seatingDetailId) async {
    try {
      await ApiClient.delete(
        'api/seatingdetails/seatingdetails/$seatingDetailId',
        service: 'food',
      );
    } catch (e) {
      debugPrint('❌ deleteSeatingDetail: $e');
    }
  }

  static Future<Map<String, dynamic>?> createVendorOrder({
    required int cartId,
    required int vendorId,
    required String paymentMethod,
    required String phoneNumber,
  }) async {
    try {
      final response = await ApiClient.post(
        'api/orders/orders/vendor/create/$cartId?vendorId=$vendorId&paymentMethod=$paymentMethod&phoneNumber=$phoneNumber',
        [],
        service: 'food',
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body) as Map<String, dynamic>?;
      }
    } catch (e) {
      debugPrint('❌ createVendorOrder: $e');
      rethrow;
    }
    return null;
  }

  static Future<Map<String, dynamic>?> fetchOrderDetails(int orderId) async {
    try {
      final response = await ApiClient.get(
        'api/orders/order/$orderId',
        service: 'food',
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>?;
      }
    } catch (e) {
      debugPrint('❌ fetchOrderDetails: $e');
    }
    return null;
  }

  static Future<Map<String, dynamic>?> createDynamicQr({
    required double amount,
    required int cartId,
    required int vendorId,
    required String phone,
    required String orderId,
  }) async {
    try {
      final response = await ApiClient.post('api/payments/create/qr', {
        'amount': amount,
        'cartId': cartId,
        'vendorId': vendorId,
        'phone': phone,
        'orderId': orderId,
      }, service: 'food');
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('❌ createDynamicQr error: $e');
    }
    return null;
  }

  static Future<String?> checkPaymentStatus(int cartId) async {
    try {
      final response = await ApiClient.get(
        'api/orders/order/check/status?cartId=$cartId',
        service: 'food',
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['status'] ?? data['paymentStatus'] ?? 'pending')
            .toString()
            .toLowerCase();
      }
    } catch (e) {
      debugPrint('❌ checkPaymentStatus error: $e');
    }
    return null;
  }

  static Future<bool> addCashBilling(
    int orderId,
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await ApiClient.post(
        'api/cash-billing/addCash/$orderId',
        payload,
        service: 'food',
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('❌ addCashBilling error: $e');
      return false;
    }
  }
}
