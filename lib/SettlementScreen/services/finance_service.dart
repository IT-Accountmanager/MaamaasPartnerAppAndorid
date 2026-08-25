// import 'dart:convert';
// import 'package:flutter/foundation.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import '../models/finance_models.dart';
//
// const String _base = 'http://staging.maamaas.com:8080';
//
// class FinanceService {
//   // ── Credentials ──────────────────────────────────────────────────────────────
//   static Future<String> _token() async {
//     final p = await SharedPreferences.getInstance();
//     return p.getString('token') ??
//         p.getString('authToken') ??
//         p.getString('auth_token') ??
//         '';
//   }
//
//   static Future<int> _vid() async {
//     final p = await SharedPreferences.getInstance();
//     return p.getInt('vendorId') ??
//         int.tryParse(p.getString('vendorId') ?? '') ??
//         0;
//   }
//
//   static Map<String, String> _headers(String token) => {
//     'Content-Type': 'application/json',
//     'Accept': 'application/json',
//     'Authorization': 'Bearer $token',
//   };
//
//   static void _log(String tag, String msg) {
//     if (kDebugMode) debugPrint('💰 [$tag] $msg');
//   }
//
//   // ── GET helper ────────────────────────────────────────────────────────────────
//   static Future<dynamic> _get(String url) async {
//     final token = await _token();
//     _log('GET', url);
//     try {
//       final res = await http.get(Uri.parse(url), headers: _headers(token));
//       _log('GET', 'status=${res.statusCode}');
//       if (res.statusCode == 200) return jsonDecode(res.body);
//       _log(
//         'GET',
//         'error body=${res.body.substring(0, res.body.length.clamp(0, 300))}',
//       );
//     } catch (e) {
//       _log('GET', 'ERROR: $e');
//     }
//     return null;
//   }
//
//   // ── PUT helper ────────────────────────────────────────────────────────────────
//   static Future<bool> _put(String url, Map<String, dynamic> body) async {
//     final token = await _token();
//     _log('PUT', '$url  body=${jsonEncode(body)}');
//     try {
//       final res = await http.put(
//         Uri.parse(url),
//         headers: _headers(token),
//         body: jsonEncode(body),
//       );
//       _log(
//         'PUT',
//         'status=${res.statusCode}  body=${res.body.substring(0, res.body.length.clamp(0, 200))}',
//       );
//       return res.statusCode >= 200 && res.statusCode < 300;
//     } catch (e) {
//       _log('PUT', 'ERROR: $e');
//       return false;
//     }
//   }
//
//   // ── POST helper ───────────────────────────────────────────────────────────────
//   static Future<Map<String, dynamic>?> _post(
//     String url,
//     Map<String, dynamic> body,
//   ) async {
//     final token = await _token();
//     _log('POST', '$url  body=${jsonEncode(body)}');
//     try {
//       final res = await http.post(
//         Uri.parse(url),
//         headers: _headers(token),
//         body: jsonEncode(body),
//       );
//       _log('POST', 'status=${res.statusCode}');
//       if (res.statusCode >= 200 && res.statusCode < 300) {
//         final decoded = jsonDecode(res.body);
//         if (decoded is Map<String, dynamic>) return decoded;
//       }
//       _log(
//         'POST',
//         'error body=${res.body.substring(0, res.body.length.clamp(0, 300))}',
//       );
//     } catch (e) {
//       _log('POST', 'ERROR: $e');
//     }
//     return null;
//   }
//
//   // SETTLEMENTS
//
//   static Future<SettlementSummary?> fetchSettlements() async {
//     final vid = await _vid();
//     final data = await _get('$_base/food/api/settlements/vendor/$vid');
//     if (data == null) return null;
//     try {
//       if (data is Map<String, dynamic>) return SettlementSummary.fromJson(data);
//     } catch (e) {
//       _log('settlements', 'parse error: $e');
//     }
//     return null;
//   }
//
//   // CREDITS
//
//   static Future<CreditStats?> fetchCreditStats() async {
//     final vid = await _vid();
//     final data = await _get('$_base/food/api/vendor/credit/$vid');
//     if (data == null) return null;
//     try {
//       if (data is Map<String, dynamic>) return CreditStats.fromJson(data);
//     } catch (e) {
//       _log('credits', 'parse error: $e');
//     }
//     return null;
//   }
//
//   // PAY CREDITS
//
//   static Future<bool> payCredits({
//     required double amount,
//     required String transactionId,
//   }) async {
//     final vid = await _vid();
//     return _put('$_base/food/api/settlements/pay-credits/vendor', {
//       'vendorId': vid,
//       'paidAmount': amount,
//       'transactionId': transactionId,
//     });
//   }
//
//   static Future<List<LedgerOrder>> fetchOrdersByDateRange(
//     String startDate,
//     String endDate,
//   ) async {
//     final vid = await _vid();
//     final url =
//         '$_base/food/api/orders/vendor/date-range/$vid?startDate=$startDate&endDate=$endDate';
//     final data = await _get(url);
//     if (data == null) return [];
//     try {
//       if (data is List)
//         return data
//             .whereType<Map<String, dynamic>>()
//             .map(LedgerOrder.fromJson)
//             .toList();
//     } catch (e) {
//       _log('ledger', 'parse error: $e');
//     }
//     return [];
//   }
//
//   static List<DailyLedger> groupOrdersByDay(List<LedgerOrder> orders) {
//     final map = <String, List<LedgerOrder>>{};
//     for (final o in orders) {
//       if (o.date.isNotEmpty) map.putIfAbsent(o.date, () => []).add(o);
//     }
//     final result = map.entries.map((e) {
//       final total = e.value.fold(0.0, (s, o) => s + o.netAmount);
//       return DailyLedger(
//         date: e.key,
//         totalNetAmount: total,
//         orderCount: e.value.length,
//         orders: e.value,
//       );
//     }).toList();
//     result.sort((a, b) => b.date.compareTo(a.date));
//     return result;
//   }
//
//   static Future<String?> createRazorpayOrder(double amount) async {
//     final vid = await _vid();
//     final data = await _post('$_base/subscription/api/user/create-order', {
//       'amount': amount,
//       'currency': 'INR',
//       'receipt': 'credit_payment_${DateTime.now().millisecondsSinceEpoch}',
//       'vendorId': vid,
//     });
//     if (data == null) return null;
//     return data['orderId']?.toString() ?? data['id']?.toString();
//   }
//
//   static Future<bool> captureRazorpayPayment(
//     String paymentId,
//     double amount,
//   ) async {
//     final vid = await _vid();
//     final data = await _post('$_base/subscription/api/user/capture', {
//       'paymentId': paymentId,
//       'amount': amount,
//       'currency': 'INR',
//       'vendorId': vid,
//     });
//     return data != null;
//   }
//
//
// }
//
//
// const String _bases = 'http://staging.maamaas.com:8080/food/api';
//
// class CashBillingService {
//   static Future<String> _token() async {
//     final p = await SharedPreferences.getInstance();
//     return p.getString('token') ??
//         p.getString('authToken') ??
//         p.getString('auth_token') ??
//         '';
//   }
//
//   static Future<int> _vid() async {
//     final p = await SharedPreferences.getInstance();
//     return p.getInt('vendorId') ??
//         int.tryParse(p.getString('vendorId') ?? '') ??
//         0;
//   }
//
//   static Map<String, String> _headers(String tok) => {
//     'Content-Type': 'application/json',
//     'Accept': 'application/json',
//     'Authorization': 'Bearer $tok',
//   };
//
//   static void _log(String msg) {
//     if (kDebugMode) debugPrint('💵 [CashBilling] $msg');
//   }
//
//   // GET
//
//   static Future<CashBillingPage?> fetchBillingPage({
//     required int page,
//     required int pageSize,
//     String? startDate,
//     String? endDate,
//   }) async {
//     final tok = await _token();
//     final vid = await _vid();
//
//     final params = <String, String>{
//       'vendorId': vid.toString(),
//       'page': page.toString(),
//       'size': pageSize.toString(),
//       'sortField': 'id',
//       'sortDir': 'desc',
//     };
//     if (startDate != null) params['startDate'] = startDate;
//     if (endDate != null) params['endDate'] = endDate;
//
//     final uri = Uri.parse(
//       '$_bases/cash-billing/vendor/billing',
//     ).replace(queryParameters: params);
//     _log('GET $uri');
//
//     try {
//       final res = await http.get(uri, headers: _headers(tok));
//       _log('status=${res.statusCode}');
//       if (res.statusCode == 200 && res.body.isNotEmpty) {
//         final data = jsonDecode(res.body) as Map<String, dynamic>;
//         return CashBillingPage.fromJson(data);
//       }
//     } catch (e) {
//       _log('ERROR: $e');
//     }
//     return null;
//   }
//
//   // GET
//   static Future<CashBillingRecord?> fetchByOrderId(String orderId) async {
//     final tok = await _token();
//     final uri = Uri.parse('$_bases/cash-billing/order/$orderId');
//     _log('GET $uri');
//
//     try {
//       final res = await http.get(uri, headers: _headers(tok));
//       _log('status=${res.statusCode}');
//       if (res.statusCode == 200 && res.body.isNotEmpty) {
//         return CashBillingRecord.fromJson(
//           jsonDecode(res.body) as Map<String, dynamic>,
//         );
//       }
//     } catch (e) {
//       _log('ERROR: $e');
//     }
//     return null;
//   }
// }
// import 'dart:convert';
// import 'package:flutter/foundation.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../API/Apiclient.dart';
// import '../models/finance_models.dart';
//
// const _ss = FlutterSecureStorage();
//
// class FinanceService {
//   // ─────────────────────────────────────────────
//   // HELPERS
//   // ─────────────────────────────────────────────
//
//   static Future<int> _vendorId() async {
//     String? v = await _ss.read(key: 'vendorId');
//
//     if (v == null || v.isEmpty) {
//       final p = await SharedPreferences.getInstance();
//       v = p.getString('vendorId') ?? p.getInt('vendorId')?.toString();
//     }
//
//     final vid = int.tryParse(v ?? '') ?? 0;
//     debugPrint('🏪 vendorId=$vid');
//     return vid;
//   }
//
//   static void _log(String tag, String msg) {
//     if (kDebugMode) debugPrint('💰 [$tag] $msg');
//   }
//
//   // ─────────────────────────────────────────────
//   // SETTLEMENTS
//   // ─────────────────────────────────────────────
//
//   static Future<SettlementSummary?> fetchSettlements() async {
//     try {
//       final vid = await _vendorId();
//
//       final response = await ApiClient.get(
//         'settlements/vendor/$vid',
//         service: 'food',
//       );
//
//       _log('SETTLEMENTS', 'status=${response.statusCode}');
//
//       if (response.statusCode == 200 && response.body.isNotEmpty) {
//         return SettlementSummary.fromJson(jsonDecode(response.body));
//       }
//     } catch (e) {
//       _log('SETTLEMENTS', 'ERROR: $e');
//     }
//     return null;
//   }
//
//   // ─────────────────────────────────────────────
//   // CREDITS
//   // ─────────────────────────────────────────────
//
//   static Future<CreditStats?> fetchCreditStats() async {
//     try {
//       final vid = await _vendorId();
//
//       final response = await ApiClient.get(
//         'vendor/credit/$vid',
//         service: 'food',
//       );
//
//       _log('CREDITS', 'status=${response.statusCode}');
//
//       if (response.statusCode == 200 && response.body.isNotEmpty) {
//         return CreditStats.fromJson(jsonDecode(response.body));
//       }
//     } catch (e) {
//       _log('CREDITS', 'ERROR: $e');
//     }
//     return null;
//   }
//
//   // ─────────────────────────────────────────────
//   // PAY CREDITS
//   // ─────────────────────────────────────────────
//
//   static Future<bool> payCredits({
//     required double amount,
//     required String transactionId,
//   }) async {
//     try {
//       final vid = await _vendorId();
//
//       final response = await ApiClient.put('settlements/pay-credits/vendor', {
//         'vendorId': vid,
//         'paidAmount': amount,
//         'transactionId': transactionId,
//       }, service: 'food');
//
//       _log('PAY_CREDITS', 'status=${response.statusCode}');
//
//       return response.statusCode >= 200 && response.statusCode < 300;
//     } catch (e) {
//       _log('PAY_CREDITS', 'ERROR: $e');
//       return false;
//     }
//   }
//
//   // ─────────────────────────────────────────────
//   // LEDGER
//   // ─────────────────────────────────────────────
//
//   static Future<List<LedgerOrder>> fetchOrdersByDateRange(
//     String startDate,
//     String endDate,
//   ) async {
//     try {
//       final vid = await _vendorId();
//
//       final response = await ApiClient.get(
//         'orders/vendor/date-range/$vid?startDate=$startDate&endDate=$endDate',
//         service: 'food',
//       );
//
//       _log('LEDGER', 'status=${response.statusCode}');
//
//       if (response.statusCode == 200 && response.body.isNotEmpty) {
//         final list = jsonDecode(response.body) as List;
//
//         return list
//             .whereType<Map<String, dynamic>>()
//             .map(LedgerOrder.fromJson)
//             .toList();
//       }
//     } catch (e) {
//       _log('LEDGER', 'ERROR: $e');
//     }
//
//     return [];
//   }
//
//   static List<DailyLedger> groupOrdersByDay(List<LedgerOrder> orders) {
//     final map = <String, List<LedgerOrder>>{};
//
//     for (final o in orders) {
//       if (o.date.isNotEmpty) {
//         map.putIfAbsent(o.date, () => []).add(o);
//       }
//     }
//
//     final result = map.entries.map((e) {
//       final total = e.value.fold(0.0, (s, o) => s + o.netAmount);
//
//       return DailyLedger(
//         date: e.key,
//         totalNetAmount: total,
//         orderCount: e.value.length,
//         orders: e.value,
//       );
//     }).toList();
//
//     result.sort((a, b) => b.date.compareTo(a.date));
//     return result;
//   }
//
//   // ─────────────────────────────────────────────
//   // RAZORPAY
//   // ─────────────────────────────────────────────
//
//   static Future<String?> createRazorpayOrder(double amount) async {
//     try {
//       final vid = await _vendorId();
//
//       final response = await ApiClient.post('api/user/create-order', {
//         'amount': amount,
//         'currency': 'INR',
//         'receipt': 'credit_${DateTime.now().millisecondsSinceEpoch}',
//         'vendorId': vid,
//       }, service: 'subscription');
//
//       _log('RAZORPAY_ORDER', 'status=${response.statusCode}');
//
//       if (response.statusCode >= 200 && response.statusCode < 300) {
//         final data = jsonDecode(response.body);
//         return data['orderId']?.toString() ?? data['id']?.toString();
//       }
//     } catch (e) {
//       _log('RAZORPAY_ORDER', 'ERROR: $e');
//     }
//
//     return null;
//   }
//
//   static Future<bool> captureRazorpayPayment(
//     String paymentId,
//     double amount,
//   ) async {
//     try {
//       final vid = await _vendorId();
//
//       final response = await ApiClient.post('api/user/capture', {
//         'paymentId': paymentId,
//         'amount': amount,
//         'currency': 'INR',
//         'vendorId': vid,
//       }, service: 'subscription');
//
//       _log('RAZORPAY_CAPTURE', 'status=${response.statusCode}');
//
//       return response.statusCode >= 200 && response.statusCode < 300;
//     } catch (e) {
//       _log('RAZORPAY_CAPTURE', 'ERROR: $e');
//       return false;
//     }
//   }
// }
//
// class CashBillingService {
//   // ─────────────────────────────────────────────
//   // HELPERS
//   // ─────────────────────────────────────────────
//
//   static Future<int> _vendorId() async {
//     String? v = await _ss.read(key: 'vendorId');
//
//     if (v == null || v.isEmpty) {
//       final p = await SharedPreferences.getInstance();
//       v = p.getString('vendorId') ?? p.getInt('vendorId')?.toString();
//     }
//
//     return int.tryParse(v ?? '') ?? 0;
//   }
//
//   static void _log(String msg) {
//     if (kDebugMode) debugPrint('💵 [CashBilling] $msg');
//   }
//
//   // ─────────────────────────────────────────────
//   // FETCH BILLING PAGE
//   // ─────────────────────────────────────────────
//
//   static Future<CashBillingPage?> fetchBillingPage({
//     required int page,
//     required int pageSize,
//     String? startDate,
//     String? endDate,
//   }) async {
//     try {
//       final vid = await _vendorId();
//
//       String url =
//           'cash-billing/vendor/billing?vendorId=$vid&page=$page&size=$pageSize&sortField=id&sortDir=desc';
//
//       if (startDate != null) url += '&startDate=$startDate';
//       if (endDate != null) url += '&endDate=$endDate';
//
//       final response = await ApiClient.get(url, service: 'food');
//
//       _log('GET status=${response.statusCode}');
//
//       if (response.statusCode == 200 && response.body.isNotEmpty) {
//         return CashBillingPage.fromJson(jsonDecode(response.body));
//       }
//     } catch (e) {
//       _log('ERROR: $e');
//     }
//
//     return null;
//   }
//
//   // ─────────────────────────────────────────────
//   // FETCH BY ORDER ID
//   // ─────────────────────────────────────────────
//
//   static Future<CashBillingRecord?> fetchByOrderId(String orderId) async {
//     try {
//       final response = await ApiClient.get(
//         'cash-billing/order/$orderId',
//         service: 'food',
//       );
//
//       _log('GET status=${response.statusCode}');
//
//       if (response.statusCode == 200 && response.body.isNotEmpty) {
//         return CashBillingRecord.fromJson(jsonDecode(response.body));
//       }
//     } catch (e) {
//       _log('ERROR: $e');
//     }
//
//     return null;
//   }
// }
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../API/Apiclient.dart';
import '../models/finance_models.dart';

class FinanceService {
  static const _storage = FlutterSecureStorage();

  static void _log(String tag, String msg) {
    if (kDebugMode) debugPrint('💰 [$tag] $msg');
  }

  // ✅ LOCAL TOKEN
  static Future<String?> _getToken() async {
    String? token = await _storage.read(key: 'token');

    if (token == null || token.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      token =
          prefs.getString('token') ??
          prefs.getString('authToken') ??
          prefs.getString('auth_token');
    }

    return token;
  }

  // ✅ LOCAL VENDOR ID
  static Future<String> _getVendorId() async {
    String? vid = await _storage.read(key: 'vendorId');

    if (vid == null || vid.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      vid = prefs.getString('vendorId') ?? prefs.getInt('vendorId')?.toString();
    }

    return vid ?? "0";
  }

  static Future<List<dynamic>> fetchCreditTransactions() async {
    final vid = await _getVendorId();

    try {
      final res = await ApiClient.get(
        "api/vendor/credit/transaction/$vid",
        service: "food",
      );

      _log("credit_tx", "status=${res.statusCode}");

      if (res.statusCode == 200 && res.body.isNotEmpty) {
        final data = jsonDecode(res.body);
        if (data is List) return data;
      }
    } catch (e) {
      _log("credit_tx", "ERROR: $e");
    }

    return [];
  }

  // ── SETTLEMENTS ─────────────────────────────
  static Future<SettlementSummary?> fetchSettlements() async {
    final vid = await _getVendorId();

    final res = await ApiClient.get(
      "api/settlements/vendor/$vid",
      service: "food",
    );

    if (res.statusCode == 200) {
      try {
        return SettlementSummary.fromJson(jsonDecode(res.body));
      } catch (e) {
        _log("settlements", "parse error: $e");
      }
    }

    return null;
  }

  static Future<CreditStats?> fetchCreditStats() async {
    final vid = await _getVendorId();

    final res = await ApiClient.get("api/vendor/credit/$vid", service: "food");

    if (res.statusCode == 200) {
      try {
        return CreditStats.fromJson(jsonDecode(res.body));
      } catch (e) {
        _log("credits", "parse error: $e");
      }
    }

    return null;
  }

  static Future<bool> payCredits({
    required double amount,
    required String transactionId,
  }) async {
    final vid = await _getVendorId();

    final res = await ApiClient.put("api/settlements/pay-credits/vendor", {
      "vendorId": int.parse(vid),
      "paidAmount": amount,
      "transactionId": transactionId,
    }, service: "food");

    return res.statusCode >= 200 && res.statusCode < 300;
  }

  static Future<List<LedgerOrder>> fetchOrdersByDateRange(
    String startDate,
    String endDate,
  ) async {
    final vid = await _getVendorId();

    final res = await ApiClient.get(
      "api/orders/vendor/date-range/$vid",
      service: "food",
      queryParams: {"startDate": startDate, "endDate": endDate},
    );

    if (res.statusCode == 200) {
      try {
        final data = jsonDecode(res.body);
        if (data is List) {
          return data
              .whereType<Map<String, dynamic>>()
              .map(LedgerOrder.fromJson)
              .toList();
        }
      } catch (e) {
        _log("ledger", "parse error: $e");
      }
    }

    return [];
  }

  static List<DailyLedger> groupOrdersByDay(List<LedgerOrder> orders) {
    final map = <String, List<LedgerOrder>>{};

    for (final o in orders) {
      if (o.date.isNotEmpty) {
        map.putIfAbsent(o.date, () => []).add(o);
      }
    }

    final result = map.entries.map((e) {
      final total = e.value.fold(0.0, (s, o) => s + o.netAmount);

      return DailyLedger(
        date: e.key,
        totalNetAmount: total,
        orderCount: e.value.length,
        orders: e.value,
      );
    }).toList();

    result.sort((a, b) => b.date.compareTo(a.date));
    return result;
  }

  static Future<String?> createRazorpayOrder(double amount) async {
    final vid = await _getVendorId();

    final res = await ApiClient.post("api/user/create-order", {
      "amount": amount,
      "currency": "INR",
      "receipt": "credit_payment_${DateTime.now().millisecondsSinceEpoch}",
      "vendorId": int.parse(vid),
    }, service: "subscription");

    if (res.statusCode >= 200 && res.statusCode < 300) {
      final data = jsonDecode(res.body);
      return data['orderId']?.toString() ?? data['id']?.toString();
    }

    return null;
  }

  static Future<bool> captureRazorpayPayment(
    String paymentId,
    double amount,
  ) async {
    final vid = await _getVendorId();

    final res = await ApiClient.post("api/user/capture", {
      "paymentId": paymentId,
      "amount": amount,
      "currency": "INR",
      "vendorId": int.parse(vid),
    }, service: "subscription");

    return res.statusCode >= 200 && res.statusCode < 300;
  }
}

class CashBillingService {
  static const _storage = FlutterSecureStorage();

  static void _log(String msg) {
    if (kDebugMode) debugPrint('💵 [CashBilling] $msg');
  }

  static Future<String> _getVendorId() async {
    String? vid = await _storage.read(key: 'vendorId');

    if (vid == null || vid.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      vid = prefs.getString('vendorId') ?? prefs.getInt('vendorId')?.toString();
    }

    return vid ?? "0";
  }

  static Future<CashBillingPage?> fetchBillingPage({
    required int page,
    required int pageSize,
    String? startDate,
    String? endDate,
  }) async {
    final vid = await _getVendorId();

    final res = await ApiClient.get(
      "api/cash-billing/vendor/billing",
      service: "food",
      queryParams: {
        "vendorId": vid,
        "page": page.toString(),
        "size": pageSize.toString(),
        "sortField": "id",
        "sortDir": "desc",
        if (startDate != null) "startDate": startDate,
        if (endDate != null) "endDate": endDate,
      },
    );

    if (res.statusCode == 200 && res.body.isNotEmpty) {
      try {
        return CashBillingPage.fromJson(jsonDecode(res.body));
      } catch (e) {
        _log("parse error: $e");
      }
    }

    return null;
  }

  static Future<CashBillingRecord?> fetchByOrderId(String orderId) async {
    final res = await ApiClient.get(
      "api/cash-billing/order/$orderId",
      service: "food",
    );

    if (res.statusCode == 200 && res.body.isNotEmpty) {
      try {
        return CashBillingRecord.fromJson(
          jsonDecode(res.body) as Map<String, dynamic>,
        );
      } catch (e) {
        _log("parse error: $e");
      }
    }

    return null;
  }
}
