// import 'dart:convert';
// import 'package:flutter/foundation.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import '../models/sub_models.dart';
//
// const String _base = 'http://staging.maamaas.com:8080';
//
// class SubscriptionService {
//   static void _log(String tag, String msg) {
//     if (kDebugMode) debugPrint('💳 [Sub/$tag] $msg');
//   }
//
//   static Future<int> _vid() async {
//     final p = await SharedPreferences.getInstance();
//     return p.getInt('vendorId') ??
//         int.tryParse(p.getString('vendorId') ?? '') ??
//         0;
//   }
//
//   static Future<Map<String, dynamic>?> getSubscriptionPlans() async {
//     const url =
//         '$_base/subscription/api/subscription/plans'
//         '?planType=STANDARD&businessVertical=FOOD_AND_BEVERAGES';
//     _log('GET_PLANS', url);
//     try {
//       final res = await http.get(
//         Uri.parse(url),
//         headers: {
//           'Accept': 'application/json',
//           'Content-Type': 'application/json',
//         },
//       );
//       _log('GET_PLANS', 'status=${res.statusCode}');
//       if (res.statusCode == 200)
//         return jsonDecode(res.body) as Map<String, dynamic>;
//     } catch (e) {
//       _log('GET_PLANS', 'ERROR: $e');
//     }
//     return null;
//   }
//
//
//   static Future<ActiveSubscription?> getVendorActiveSubscription({
//     int? vendorId,
//   }) async {
//     final vid = vendorId ?? await _vid();
//     if (vid == 0) {
//       _log('GET_ACTIVE', 'vendorId=0 — skipping');
//       return null;
//     }
//     final url =
//         '$_base/subscription/api/subscription/vendor/vendor_subscription/$vid/active'
//         '?businessVertical=FOOD_AND_BEVERAGES';
//     _log('GET_ACTIVE', url);
//     try {
//       final res = await http.get(
//         Uri.parse(url),
//         headers: {
//           'Accept': 'application/json',
//           'Content-Type': 'application/json',
//         },
//       );
//       _log('GET_ACTIVE', 'status=${res.statusCode}');
//       if (res.statusCode == 200)
//         return ActiveSubscription.fromJson(
//           jsonDecode(res.body) as Map<String, dynamic>,
//         );
//     } catch (e) {
//       _log('GET_ACTIVE', 'ERROR: $e');
//     }
//     return null;
//   }
//
//   static Future<String?> createOrder(double amount) async {
//     final vid = await _vid();
//     const url = '$_base/subscription/api/user/create-order';
//     _log('CREATE_ORDER', 'amount=$amount');
//     try {
//       final res = await http.post(
//         Uri.parse(url),
//         headers: {
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//         },
//         body: jsonEncode({
//           'amount': amount,
//           'currency': 'INR',
//           'receipt': 'subscription_${DateTime.now().millisecondsSinceEpoch}',
//           'vendorId': vid,
//         }),
//       );
//       _log('CREATE_ORDER', 'status=${res.statusCode}');
//       if (res.statusCode >= 200 && res.statusCode < 300) {
//         final data = jsonDecode(res.body) as Map<String, dynamic>;
//         return data['orderId']?.toString() ?? data['id']?.toString();
//       }
//     } catch (e) {
//       _log('CREATE_ORDER', 'ERROR: $e');
//     }
//     return null;
//   }
//
//
//   static Future<bool> capturePayment({
//     required String paymentId,
//     required double amount,
//   }) async {
//     final vid = await _vid();
//     const url = '$_base/subscription/api/user/capture';
//     _log('CAPTURE', 'paymentId=$paymentId');
//     try {
//       final res = await http.post(
//         Uri.parse(url),
//         headers: {
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//         },
//         body: jsonEncode({
//           'paymentId': paymentId,
//           'amount': amount,
//           'currency': 'INR',
//           'vendorId': vid,
//         }),
//       );
//       return res.statusCode >= 200 && res.statusCode < 300;
//     } catch (e) {
//       _log('CAPTURE', 'ERROR: $e');
//       return false;
//     }
//   }
//   static Future<Map<String, dynamic>?> createSubscription({
//     required List<String> selectedModules,
//     required String transactionId,
//     required double totalAmount,
//   }) async {
//     final vid = await _vid();
//     const url = '$_base/subscription/api/subscription/api/vendor/subscription';
//     _log('CREATE_SUB', url);
//     final payload = {
//       'vendorId': vid,
//       'planType': 'STANDARD',
//       'businessVertical': 'FOOD_AND_BEVERAGES',
//       'billingCycle': 'YEARLY',
//       'selectedModules': selectedModules,
//       'transactionId': transactionId,
//       'paymentMethod': 'Online_Payment',
//       'totalAmount': totalAmount,
//       'termsAccepted': true,
//     };
//     try {
//       final res = await http.post(
//         Uri.parse(url),
//         headers: {
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//         },
//         body: jsonEncode(payload),
//       );
//       _log('CREATE_SUB', 'status=${res.statusCode}');
//       if (res.statusCode >= 200 && res.statusCode < 300) {
//         return jsonDecode(res.body) as Map<String, dynamic>? ??
//             {'success': true};
//       }
//       // Check if already has active subscription → call renew
//       final body = res.body.toLowerCase();
//       if (body.contains('already has an active subscription'))
//         return {'needsRenew': true, 'payload': payload};
//     } catch (e) {
//       _log('CREATE_SUB', 'ERROR: $e');
//     }
//     return null;
//   }
//
//   static Future<bool> renewSubscription({
//     required Map<String, dynamic> payload,
//   }) async {
//     final vid = await _vid();
//     final url =
//         '$_base/subscription/api/subscription/vendor/subscription/renew?vendorId=$vid';
//     _log('RENEW', url);
//     try {
//       final res = await http.post(
//         Uri.parse(url),
//         headers: {
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//         },
//         body: jsonEncode(payload),
//       );
//       _log('RENEW', 'status=${res.statusCode}');
//       if (res.statusCode >= 200 && res.statusCode < 300) {
//         final data = jsonDecode(res.body) as Map<String, dynamic>? ?? {};
//         if (data['statusCodeValue'] == 400 ||
//             data['statusCode'] == 'BAD_REQUEST')
//           return false;
//         return true;
//       }
//     } catch (e) {
//       _log('RENEW', 'ERROR: $e');
//     }
//     return false;
//   }
// }

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../API/Apiclient.dart';
import '../models/sub_models.dart';

class SubscriptionService {
  static void _log(String tag, String msg) {
    if (kDebugMode) {
      debugPrint('💳 [Sub/$tag] $msg');
    }
  }

  static Future<int> _vid() async {
    final p = await SharedPreferences.getInstance();

    return p.getInt('vendorId') ??
        int.tryParse(p.getString('vendorId') ?? '') ??
        0;
  }

  /// GET SUBSCRIPTION PLANS
  static Future<Map<String, dynamic>?> getSubscriptionPlans() async {
    try {
      final response = await ApiClient.get(
        'api/subscription/plans',
        service: 'subscription',
        requiresAuth: false,
        queryParams: {
          'planType': 'STANDARD',
          'businessVertical': 'FOOD_AND_BEVERAGES',
        },
      );

      _log('GET_PLANS', 'status=${response.statusCode}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (e) {
      _log('GET_PLANS', 'ERROR: $e');
    }

    return null;
  }

  /// GET ACTIVE SUBSCRIPTION
  static Future<ActiveSubscription?> getVendorActiveSubscription({
    int? vendorId,
  }) async {
    final vid = vendorId ?? await _vid();

    if (vid == 0) {
      _log('GET_ACTIVE', 'vendorId=0');
      return null;
    }

    try {
      final response = await ApiClient.get(
        'api/subscription/vendor/vendor_subscription/$vid/active',
        service: 'subscription',
        queryParams: {'businessVertical': 'FOOD_AND_BEVERAGES'},
      );

      _log('GET_ACTIVE', 'status=${response.statusCode}');

      if (response.statusCode == 200) {
        return ActiveSubscription.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      _log('GET_ACTIVE', 'ERROR: $e');
    }

    return null;
  }

  /// CREATE ORDER
  static Future<String?> createOrder(double amount) async {
    final vid = await _vid();

    try {
      final response = await ApiClient.post('api/user/create-order', {
        'amount': amount,
        'currency': 'INR',
        'receipt': 'subscription_${DateTime.now().millisecondsSinceEpoch}',
        'vendorId': vid,
      }, service: 'subscription');

      _log('CREATE_ORDER', 'status=${response.statusCode}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);

        return data['orderId']?.toString() ?? data['id']?.toString();
      }
    } catch (e) {
      _log('CREATE_ORDER', 'ERROR: $e');
    }

    return null;
  }

  /// CAPTURE PAYMENT
  static Future<bool> capturePayment({
    required String paymentId,
    required double amount,
  }) async {
    final vid = await _vid();

    try {
      final response = await ApiClient.post('api/user/capture', {
        'paymentId': paymentId,
        'amount': amount,
        'currency': 'INR',
        'vendorId': vid,
      }, service: 'subscription');

      _log('CAPTURE', 'status=${response.statusCode}');

      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      _log('CAPTURE', 'ERROR: $e');
      return false;
    }
  }

  /// CREATE SUBSCRIPTION
  static Future<Map<String, dynamic>?> createSubscription({
    required List<String> selectedModules,
    required String transactionId,
    required double totalAmount,
  }) async {
    final vid = await _vid();

    final payload = {
      'vendorId': vid,
      'planType': 'STANDARD',
      'businessVertical': 'FOOD_AND_BEVERAGES',
      'billingCycle': 'YEARLY',
      'selectedModules': selectedModules,
      'transactionId': transactionId,
      'paymentMethod': 'Online_Payment',
      'totalAmount': totalAmount,
      'termsAccepted': true,
    };

    try {
      final response = await ApiClient.post(
        'api/subscription/api/vendor/subscription',
        payload,
        service: 'subscription',
      );

      _log('CREATE_SUB', 'status=${response.statusCode}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body) as Map<String, dynamic>? ??
            {'success': true};
      }

      final body = response.body.toLowerCase();

      if (body.contains('already has an active subscription')) {
        return {'needsRenew': true, 'payload': payload};
      }
    } catch (e) {
      _log('CREATE_SUB', 'ERROR: $e');
    }

    return null;
  }

  /// RENEW SUBSCRIPTION
  static Future<bool> renewSubscription({
    required Map<String, dynamic> payload,
  }) async {
    final vid = await _vid();

    try {
      final response = await ApiClient.post(
        'api/subscription/vendor/subscription/renew?vendorId=$vid',
        payload,
        service: 'subscription',
      );

      _log('RENEW', 'status=${response.statusCode}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body) as Map<String, dynamic>? ?? {};

        if (data['statusCodeValue'] == 400 ||
            data['statusCode'] == 'BAD_REQUEST') {
          return false;
        }

        return true;
      }
    } catch (e) {
      _log('RENEW', 'ERROR: $e');
    }

    return false;
  }
}
