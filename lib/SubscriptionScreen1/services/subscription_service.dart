// import 'dart:convert';
// import 'package:flutter/foundation.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import '../models/sub_models.dart';
//
// const String _base = 'http://staging.maamaas.com:8080';
// const String _planType         = 'STANDARD';
// const String _businessVertical = 'FOOD_AND_BEVERAGES';
//
// class SubscriptionService {
//
//   static Future<String> _token() async {
//     final p = await SharedPreferences.getInstance();
//     return p.getString('token') ?? p.getString('authToken') ?? '';
//   }
//
//   static Future<int> _vid() async {
//     final p = await SharedPreferences.getInstance();
//     return p.getInt('vendorId') ?? int.tryParse(p.getString('vendorId') ?? '') ?? 0;
//   }
//
//   static Map<String, String> _headers(String tok, {bool auth = false}) => {
//     'Content-Type': 'application/json',
//     'Accept': 'application/json',
//     if (auth && tok.isNotEmpty) 'Authorization': 'Bearer $tok',
//   };
//
//   static void _log(String tag, String msg) {
//     if (kDebugMode) debugPrint('🔔 [Sub/$tag] $msg');
//   }
//
//   // ════════════════════════════════════════════════════════════════════════════
//   // GET /subscription/api/subscription/plans
//   //   ?planType=STANDARD&businessVertical=FOOD_AND_BEVERAGES
//   // ════════════════════════════════════════════════════════════════════════════
//   static Future<List<SubModule>> fetchPlans() async {
//     final url = '$_base/subscription/api/subscription/plans?planType=$_planType&businessVertical=$_businessVertical';
//     _log('PLANS', 'GET $url');
//     try {
//       final res = await http.get(Uri.parse(url), headers: _headers(''));
//       _log('PLANS', 'status=${res.statusCode}');
//       if (res.statusCode == 200) {
//         final data = jsonDecode(res.body) as Map<String, dynamic>;
//         final modules = data['modules'] as List? ?? [];
//         final list = modules.whereType<Map<String, dynamic>>().map(SubModule.fromJson).toList();
//         list.sort((a, b) {
//           if (a.categoryOrder != b.categoryOrder) return a.categoryOrder.compareTo(b.categoryOrder);
//           return a.id.compareTo(b.id);
//         });
//         return list;
//       }
//     } catch (e) { _log('PLANS', 'ERROR: $e'); }
//     return [];
//   }
//
//   // ════════════════════════════════════════════════════════════════════════════
//   // GET /subscription/api/subscription/vendor/vendor_subscription/{vendorId}/active
//   //   ?businessVertical=FOOD_AND_BEVERAGES
//   // ════════════════════════════════════════════════════════════════════════════
//   static Future<ActiveSubscription?> fetchActiveSubscription() async {
//     final tok = await _token(); final vid = await _vid();
//     final url = '$_base/subscription/api/subscription/vendor/vendor_subscription/$vid/active?businessVertical=$_businessVertical';
//     _log('ACTIVE', 'GET $url');
//     try {
//       final res = await http.get(Uri.parse(url), headers: _headers(tok, auth: true));
//       _log('ACTIVE', 'status=${res.statusCode}');
//       if (res.statusCode == 200) {
//         final data = jsonDecode(res.body) as Map<String, dynamic>;
//         final sub = ActiveSubscription.fromJson(data);
//         // Cache
//         final p = await SharedPreferences.getInstance();
//         await p.setString('activeSubscription', jsonEncode(data));
//         await p.setInt('remainingDays', sub.remainingDays);
//         await p.setString('subscriptionEndDate', sub.endDate ?? '');
//         await p.setString('currentModules', jsonEncode(sub.selectedModules));
//         await p.setInt('subscriptionId', sub.subscriptionId);
//         if (sub.status == 'TRIAL' || sub.billingCycle == 'FREE_TRAIL') {
//           await p.setBool('hasUsedTrial', true);
//         }
//         return sub;
//       }
//     } catch (e) { _log('ACTIVE', 'ERROR: $e'); }
//     // Clear cache on failure
//     final p = await SharedPreferences.getInstance();
//     await p.remove('activeSubscription');
//     await p.remove('remainingDays');
//     await p.remove('subscriptionEndDate');
//     await p.remove('currentModules');
//     await p.remove('subscriptionId');
//     return null;
//   }
//
//   // ════════════════════════════════════════════════════════════════════════════
//   // POST /subscription/api/subscription/api/vendor/subscription  — new subscription
//   // POST /subscription/api/subscription/vendor/subscription/renew?vendorId=X — renew
//   // ════════════════════════════════════════════════════════════════════════════
//   static Future<Map<String, dynamic>?> createSubscription({
//     required List<String> selectedModules,
//     required double totalAmount,
//     required String transactionId,
//     bool renew = false,
//   }) async {
//     final vid = await _vid();
//     final url = renew
//         ? '$_base/subscription/api/subscription/vendor/subscription/renew?vendorId=$vid'
//         : '$_base/subscription/api/subscription/api/vendor/subscription';
//     _log('CREATE', 'POST $url  renew=$renew');
//     try {
//       final body = {
//         'vendorId': vid,
//         'planType': _planType,
//         'businessVertical': _businessVertical,
//         'billingCycle': 'YEARLY',
//         'selectedModules': selectedModules,
//         'transactionId': transactionId,
//         'paymentMethod': 'Online_Payment',
//         'totalAmount': totalAmount,
//         'termsAccepted': true,
//       };
//       final res = await http.post(Uri.parse(url), headers: _headers(''), body: jsonEncode(body));
//       _log('CREATE', 'status=${res.statusCode}');
//       if (res.statusCode >= 200 && res.statusCode < 300) {
//         return jsonDecode(res.body) as Map<String, dynamic>;
//       }
//     } catch (e) { _log('CREATE', 'ERROR: $e'); }
//     return null;
//   }
//
//   // ════════════════════════════════════════════════════════════════════════════
//   // POST /subscription/api/subscription/api/vendor/subscription  — free trial
//   //   billingCycle: FREE_TRAIL, totalAmount: 0
//   // ════════════════════════════════════════════════════════════════════════════
//   static Future<Map<String, dynamic>?> startFreeTrial(List<String> allModules) async {
//     final vid = await _vid();
//     final url = '$_base/subscription/api/subscription/api/vendor/subscription';
//     _log('TRIAL', 'POST $url');
//     try {
//       final body = {
//         'vendorId': vid,
//         'planType': _planType,
//         'businessVertical': _businessVertical,
//         'billingCycle': 'FREE_TRAIL',
//         'selectedModules': allModules,
//         'totalAmount': 0,
//         'termsAccepted': true,
//       };
//       final res = await http.post(Uri.parse(url), headers: _headers(''), body: jsonEncode(body));
//       _log('TRIAL', 'status=${res.statusCode}');
//       if (res.statusCode >= 200 && res.statusCode < 300) {
//         final p = await SharedPreferences.getInstance();
//         await p.setBool('hasUsedTrial', true);
//         return jsonDecode(res.body) as Map<String, dynamic>;
//       }
//     } catch (e) { _log('TRIAL', 'ERROR: $e'); }
//     return null;
//   }
//
//   // ════════════════════════════════════════════════════════════════════════════
//   // PUT /subscription/api/subscription/vendor/{subscriptionId}/modules — modify
//   // ════════════════════════════════════════════════════════════════════════════
//   static Future<bool> updateModules({
//     required int subscriptionId,
//     required List<String> modules,
//     required String paymentMethod,  // Online_Payment | Maamaas_Wallet
//     required double amount,
//     required String transactionId,
//   }) async {
//     final tok = await _token();
//     final url = '$_base/subscription/api/subscription/vendor/$subscriptionId/modules';
//     _log('UPDATE_MODULES', 'PUT $url');
//     try {
//       final body = {
//         'modules': modules,
//         'paymentMethod': paymentMethod,
//         'amount': amount,
//         'transactionId': transactionId,
//       };
//       final res = await http.put(Uri.parse(url), headers: _headers(tok, auth: true), body: jsonEncode(body));
//       _log('UPDATE_MODULES', 'status=${res.statusCode}');
//       return res.statusCode >= 200 && res.statusCode < 300;
//     } catch (e) { _log('UPDATE_MODULES', 'ERROR: $e'); return false; }
//   }
//
//   // ════════════════════════════════════════════════════════════════════════════
//   // POST /subscription/api/user/create-order  — Razorpay order
//   // POST /subscription/api/user/capture       — capture payment
//   // ════════════════════════════════════════════════════════════════════════════
//   static Future<String?> createRazorpayOrder(double amount) async {
//     final vid = await _vid();
//     final url = '$_base/subscription/api/user/create-order';
//     _log('CREATE_ORDER', 'amount=$amount');
//     try {
//       final body = {
//         'amount': amount,
//         'currency': 'INR',
//         'receipt': 'subscription_${DateTime.now().millisecondsSinceEpoch}',
//         'vendorId': vid,
//       };
//       final res = await http.post(Uri.parse(url), headers: _headers(''), body: jsonEncode(body));
//       _log('CREATE_ORDER', 'status=${res.statusCode}');
//       if (res.statusCode >= 200 && res.statusCode < 300) {
//         final data = jsonDecode(res.body) as Map<String, dynamic>;
//         return data['orderId']?.toString() ?? data['id']?.toString();
//       }
//     } catch (e) { _log('CREATE_ORDER', 'ERROR: $e'); }
//     return null;
//   }
//
//   static Future<bool> capturePayment({
//     required String paymentId, required double amount, required String vendorIdStr,
//   }) async {
//     final url = '$_base/subscription/api/user/capture';
//     _log('CAPTURE', 'paymentId=$paymentId');
//     try {
//       final body = {
//         'paymentId': paymentId,
//         'amount': amount,
//         'currency': 'INR',
//         'vendorId': vendorIdStr,
//       };
//       final res = await http.post(Uri.parse(url), headers: _headers(''), body: jsonEncode(body));
//       return res.statusCode >= 200 && res.statusCode < 300;
//     } catch (e) { _log('CAPTURE', 'ERROR: $e'); return false; }
//   }
// }
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../API/Apiclient.dart';
import '../models/sub_models.dart';

const _ss = FlutterSecureStorage();

const String _planType = 'STANDARD';
const String _businessVertical = 'FOOD_AND_BEVERAGES';

class SubscriptionService {
  // ─── Helpers ────────────────────────────────────────────────────────────
  static Future<int> _vendorId() async {
    String? v = await _ss.read(key: 'vendorId');

    if (v == null || v.isEmpty) {
      final p = await SharedPreferences.getInstance();
      v = p.getString('vendorId') ?? p.getInt('vendorId')?.toString();
    }

    final vid = int.tryParse(v ?? '') ?? 0;
    debugPrint('🏪 vendorId=$vid');
    return vid;
  }

  static void _log(String tag, String msg) {
    if (kDebugMode) debugPrint('🔔 [Sub/$tag] $msg');
  }

  // FETCH PLANS
  static Future<List<SubModule>> fetchPlans() async {
    try {
      final response = await ApiClient.get(
        'api/subscription/plans',
        service: 'subscription',
        requiresAuth: false,
        queryParams: {
          'planType': _planType,
          'businessVertical': _businessVertical,
        },
      );

      _log('PLANS', 'status=${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final modules = data['modules'] as List? ?? [];

        final list = modules
            .whereType<Map<String, dynamic>>()
            .map(SubModule.fromJson)
            .toList();

        list.sort((a, b) {
          if (a.categoryOrder != b.categoryOrder) {
            return a.categoryOrder.compareTo(b.categoryOrder);
          }
          return a.id.compareTo(b.id);
        });

        return list;
      }
    } catch (e) {
      _log('PLANS', 'ERROR: $e');
    }

    return [];
  }

  // ACTIVE SUBSCRIPTION

  static Future<ActiveSubscription?> fetchActiveSubscription() async {
    try {
      final vid = await _vendorId();

      final response = await ApiClient.get(
        'api/subscription/vendor/vendor_subscription/$vid/active',
        service: 'subscription',
        queryParams: {'businessVertical': _businessVertical},
      );

      _log('ACTIVE', 'status=${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final sub = ActiveSubscription.fromJson(data);

        final p = await SharedPreferences.getInstance();
        await p.setString('activeSubscription', jsonEncode(data));
        await p.setInt('remainingDays', sub.remainingDays);
        await p.setString('subscriptionEndDate', sub.endDate ?? '');
        await p.setString('currentModules', jsonEncode(sub.selectedModules));
        await p.setInt('subscriptionId', sub.subscriptionId);

        if (sub.status == 'TRIAL' || sub.billingCycle == 'FREE_TRAIL') {
          await p.setBool('hasUsedTrial', true);
        }

        return sub;
      }
    } catch (e) {
      _log('ACTIVE', 'ERROR: $e');
    }

    return null;
  }

  // CREATE / RENEW SUBSCRIPTION
  static Future<Map<String, dynamic>?> createSubscription({
    required List<String> selectedModules,
    required double totalAmount,
    required String transactionId,
    bool renew = false,
  }) async {
    try {
      final vid = await _vendorId();

      final endpoint = renew
          ? 'api/subscription/vendor/subscription/renew'
          : 'api/subscription/api/vendor/subscription';

      final response =
          await ApiClient.post(renew ? '$endpoint?vendorId=$vid' : endpoint, {
            'vendorId': vid,
            'planType': _planType,
            'businessVertical': _businessVertical,
            'billingCycle': 'YEARLY',
            'selectedModules': selectedModules,
            'transactionId': transactionId,
            'paymentMethod': 'Online_Payment',
            'totalAmount': totalAmount,
            'termsAccepted': true,
          }, service: 'subscription');

      _log('CREATE', 'status=${response.statusCode}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      _log('CREATE', 'ERROR: $e');
    }

    return null;
  }

  // FREE TRIAL

  static Future<Map<String, dynamic>?> startFreeTrial(
    List<String> modules,
  ) async {
    try {
      final vid = await _vendorId();

      final response =
          await ApiClient.post('api/subscription/api/vendor/subscription', {
            'vendorId': vid,
            'planType': _planType,
            'businessVertical': _businessVertical,
            'billingCycle': 'FREE_TRAIL',
            'selectedModules': modules,
            'totalAmount': 0,
            'termsAccepted': true,
          }, service: 'subscription');

      _log('TRIAL', 'status=${response.statusCode}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final p = await SharedPreferences.getInstance();
        await p.setBool('hasUsedTrial', true);
        return jsonDecode(response.body);
      }
    } catch (e) {
      _log('TRIAL', 'ERROR: $e');
    }

    return null;
  }

  // UPDATE MODULES

  static Future<bool> updateModules({
    required int subscriptionId,
    required List<String> modules,
    required String paymentMethod,
    required double amount,
    required String transactionId,
  }) async {
    try {
      final response = await ApiClient.put(
        'api/subscription/vendor/$subscriptionId/modules',
        {
          'modules': modules,
          'paymentMethod': paymentMethod,
          'amount': amount,
          'transactionId': transactionId,
        },
        service: 'subscription',
      );

      _log('UPDATE_MODULES', 'status=${response.statusCode}');

      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      _log('UPDATE_MODULES', 'ERROR: $e');
      return false;
    }
  }

  // RAZORPAY ORDER
  static Future<String?> createRazorpayOrder(double amount) async {
    try {
      final vid = await _vendorId();

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

  // CAPTURE PAYMENT

  static Future<bool> capturePayment({
    required String paymentId,
    required double amount,
    required String vendorIdStr,
  }) async {
    try {
      final response = await ApiClient.post('api/user/capture', {
        'paymentId': paymentId,
        'amount': amount,
        'currency': 'INR',
        'vendorId': vendorIdStr,
      }, service: 'subscription');

      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      _log('CAPTURE', 'ERROR: $e');
      return false;
    }
  }
}
