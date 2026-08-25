import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../../../API/Apiclient.dart';

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
      // debugPrint('❌ fetchCart: $e');
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
      // debugPrint('❌ fetchAvailableTables: $e');
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
      // debugPrint('❌ fetchRemovalRequests: $e');
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
      // debugPrint('❌ createBooking: $e');
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
      // debugPrint('❌ addItemsToCart: $e');
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
      // debugPrint('❌ updateItemStatus: $e');
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
      // debugPrint('❌ removeItem: $e');
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
      // debugPrint('❌ addTip: $e');
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
      // debugPrint('❌ applyDiscount: $e');
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
      // debugPrint('❌ updateRequestStatus: $e');
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
      // debugPrint('❌ fetchBillingConfig: $e');
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
      // debugPrint('❌ updateCartDetails: $e');
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
      // debugPrint('❌ deleteSeatingDetail: $e');
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
      // debugPrint('❌ createVendorOrder: $e');
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
      // debugPrint('❌ fetchOrderDetails: $e');
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
      // debugPrint('❌ createDynamicQr error: $e');
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
      // debugPrint('❌ checkPaymentStatus error: $e');
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
      // debugPrint('❌ addCashBilling error: $e');
      return false;
    }
  }
}
