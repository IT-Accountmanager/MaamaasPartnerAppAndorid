// import 'dart:convert';
// import 'package:flutter/foundation.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import '../models/catering_models.dart';
//
// const String _base = 'http://staging.maamaas.com:8080';
//
// class CateringService {
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
//     if (kDebugMode) debugPrint('🍽️ [$tag] $msg');
//   }
//
//   // LEADS
//
//   static Future<List<CateringLead>> fetchLeads() async {
//     final token = await _token();
//     final vid = await _vid();
//     final url = '$_base/catering/api/vendor/$vid';
//     _log('LEADS', 'GET $url');
//
//     try {
//       final res = await http.get(Uri.parse(url), headers: _headers(token));
//       _log('LEADS', 'status=${res.statusCode}');
//       if (res.statusCode != 200) return [];
//
//       final body = jsonDecode(res.body) as Map<String, dynamic>;
//       final data = body['data'] as Map<String, dynamic>? ?? {};
//
//       final fullLeads = (data['fullLeads'] as List? ?? [])
//           .whereType<Map<String, dynamic>>()
//           .map(CateringLead.fromJson)
//           .toList();
//       final maskedLeads = (data['maskedLeads'] as List? ?? [])
//           .whereType<Map<String, dynamic>>()
//           .map(CateringLead.fromJson)
//           .toList();
//
//       // Masked leads first, then unmasked sorted newest-first by id
//       final unmasked = fullLeads.where((l) => !l.masked).toList()
//         ..sort((a, b) => b.orderId.compareTo(a.orderId));
//       final masked = [...fullLeads.where((l) => l.masked), ...maskedLeads];
//
//       return [...masked, ...unmasked];
//     } catch (e) {
//       _log('LEADS', 'ERROR: $e');
//       return [];
//     }
//   }
//
//   // QUOTATIONS
//
//   static Future<List<Quotation>> fetchQuotations() async {
//     final token = await _token();
//     final vid = await _vid();
//     final url = '$_base/catering/api/vendor/quotations/$vid';
//     _log('QUOTATIONS', 'GET $url');
//
//     try {
//       final res = await http.get(Uri.parse(url), headers: _headers(token));
//       _log('QUOTATIONS', 'status=${res.statusCode}');
//       if (res.statusCode != 200) return [];
//
//       final body = jsonDecode(res.body) as Map<String, dynamic>;
//       if (body['success'] == true && body['data'] is List) {
//         return (body['data'] as List)
//             .whereType<Map<String, dynamic>>()
//             .map(Quotation.fromJson)
//             .toList();
//       }
//     } catch (e) {
//       _log('QUOTATIONS', 'ERROR: $e');
//     }
//     return [];
//   }
//
//   static Future<bool> sendQuotation({
//     required int leadId,
//     required Quotation quotation,
//   }) async {
//     final token = await _token();
//     final vid = await _vid();
//     final url = '$_base/catering/api/vendor/lead/quotation/$leadId/$vid';
//     _log('SEND_QUOTATION', 'POST $url  body=${jsonEncode(quotation.toJson())}');
//
//     try {
//       final res = await http.post(
//         Uri.parse(url),
//         headers: _headers(token),
//         body: jsonEncode(quotation.toJson()),
//       );
//       _log('SEND_QUOTATION', 'status=${res.statusCode}');
//       return res.statusCode >= 200 && res.statusCode < 300;
//     } catch (e) {
//       _log('SEND_QUOTATION', 'ERROR: $e');
//       return false;
//     }
//   }
//
//   // LEAD PAYMENT (Pay Now to unlock full lead details)
//
//   static Future<String?> createLeadPaymentOrder(double amount) async {
//     final vid = await _vid();
//     for (final url in [
//       '$_base/subscription/api/user/create-order',
//       '$_base/food/api/payments/create-order/user',
//     ]) {
//       try {
//         _log('CREATE_ORDER', 'POST $url  amount=$amount');
//         final res = await http.post(
//           Uri.parse(url),
//           headers: {
//             'Content-Type': 'application/json',
//             'Accept': 'application/json',
//           },
//           body: jsonEncode({
//             'amount': amount.round(),
//             'currency': 'INR',
//             'vendorId': vid,
//           }),
//         );
//         _log('CREATE_ORDER', 'status=${res.statusCode}');
//         if (res.statusCode >= 200 && res.statusCode < 300) {
//           final data = jsonDecode(res.body) as Map<String, dynamic>;
//           final id = data['orderId']?.toString() ?? data['id']?.toString();
//           if (id != null) return id;
//         }
//       } catch (e) {
//         _log('CREATE_ORDER', 'endpoint failed: $url  error: $e');
//       }
//     }
//     return null;
//   }
//
//   static Future<bool> initiateLeadPayment({
//     required int leadId,
//     required double amount,
//     required int orderId,
//   }) async {
//     final token = await _token();
//     final vid = await _vid();
//     final url =
//         '$_base/catering/api/vendor/payment/initiate'
//         '?leadId=$leadId&vendorId=$vid&amount=$amount&orderid=$orderId';
//     _log('INITIATE_PAYMENT', 'POST $url');
//
//     try {
//       final res = await http.post(
//         Uri.parse(url),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Accept': 'application/json',
//         },
//       );
//       _log('INITIATE_PAYMENT', 'status=${res.statusCode}');
//       return res.statusCode >= 200 && res.statusCode < 300;
//     } catch (e) {
//       _log('INITIATE_PAYMENT', 'ERROR: $e');
//       return false;
//     }
//   }
//
//   static Future<bool> captureLeadPayment({
//     required String paymentId,
//     required double amount,
//   }) async {
//     final vid = await _vid();
//     const url = '$_base/subscription/api/user/capture';
//     _log('CAPTURE', 'POST $url  paymentId=$paymentId  amount=$amount');
//
//     try {
//       final res = await http.post(
//         Uri.parse(url),
//         headers: {
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//         },
//         body: jsonEncode({
//           'paymentId': paymentId,
//           'amount': amount.round(),
//           'currency': 'INR',
//           'vendorId': vid,
//         }),
//       );
//       _log('CAPTURE', 'status=${res.statusCode}');
//       return res.statusCode >= 200 && res.statusCode < 300;
//     } catch (e) {
//       _log('CAPTURE', 'ERROR: $e');
//       return false;
//     }
//   }
//
//   // CAMPAIGN PAYMENT  (handlePayment from handlepymentdata.txt)
//
//   static Future<String?> createCampaignPaymentOrder(double amountRupees) async {
//     final token = await _token();
//     const url = '$_base/promotions/api/payments/create-order/user';
//     _log('CAMPAIGN_ORDER', 'POST $url  amount=$amountRupees');
//
//     try {
//       final res = await http.post(
//         Uri.parse(url),
//         headers: _headers(token),
//         body: jsonEncode({'amount': amountRupees, 'currency': 'INR'}),
//       );
//       _log('CAMPAIGN_ORDER', 'status=${res.statusCode}');
//       if (res.statusCode >= 200 && res.statusCode < 300) {
//         final data = jsonDecode(res.body) as Map<String, dynamic>;
//         return data['orderId']?.toString() ?? data['id']?.toString();
//       }
//     } catch (e) {
//       _log('CAMPAIGN_ORDER', 'ERROR: $e');
//     }
//     return null;
//   }
//
//   static Future<bool> captureCampaignPayment({
//     required String paymentId,
//     required String orderId,
//     required String signature,
//     required double amountRupees,
//   }) async {
//     final token = await _token();
//     const url = '$_base/promotions/api/payments/capture';
//     _log('CAMPAIGN_CAPTURE', 'POST $url  paymentId=$paymentId');
//
//     try {
//       final res = await http.post(
//         Uri.parse(url),
//         headers: _headers(token),
//         body: jsonEncode({
//           'paymentId': paymentId,
//           'orderId': orderId,
//           'signature': signature,
//           'amount': amountRupees,
//           'currency': 'INR',
//         }),
//       );
//       _log('CAMPAIGN_CAPTURE', 'status=${res.statusCode}');
//       return res.statusCode >= 200 && res.statusCode < 300;
//     } catch (e) {
//       _log('CAMPAIGN_CAPTURE', 'ERROR: $e');
//       return false;
//     }
//   }
// }
// import 'dart:convert';
// import 'package:flutter/foundation.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../API/Apiclient.dart';
// import '../models/catering_models.dart';
//
// const String _base = 'http://staging.maamaas.com:8080';
//
// class CateringService {
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
//     if (kDebugMode) debugPrint('🍽️ [$tag] $msg');
//   }
//
//   // Helper to handle API responses with refresh token logic
//   static Future<http.Response> _requestWithAuth(
//       Future<http.Response> Function() requestFunc,
//       ) async {
//     try {
//       http.Response response = await requestFunc();
//
//       // If unauthorized, try refresh token
//       if (response.statusCode == 401 || response.statusCode == 403) {
//         _log('AUTH', 'Token expired, attempting refresh...');
//         final newToken = await ApiClient.refreshAccessToken();
//
//         if (newToken != null) {
//           _log('AUTH', 'Token refreshed successfully');
//           // Retry the request with new token
//           response = await requestFunc();
//         } else {
//           _log('AUTH', 'Refresh failed, session expired');
//           if (ApiClient.onSessionExpired != null) {
//             await ApiClient.onSessionExpired!();
//           }
//           throw Exception('Session expired. Please login again.');
//         }
//       }
//
//       return response;
//     } catch (e) {
//       _log('AUTH', 'Request failed: $e');
//       rethrow;
//     }
//   }
//
//   // LEADS
//   static Future<List<CateringLead>> fetchLeads() async {
//     final vid = await _vid();
//     final endpoint = 'catering/api/vendor/$vid';
//
//     try {
//       final response = await _requestWithAuth(() async {
//         final token = await _token();
//         return await http.get(
//           Uri.parse('$_base/$endpoint'),
//           headers: _headers(token),
//         );
//       });
//
//       _log('LEADS', 'status=${response.statusCode}');
//       if (response.statusCode != 200) return [];
//
//       final body = jsonDecode(response.body) as Map<String, dynamic>;
//       final data = body['data'] as Map<String, dynamic>? ?? {};
//
//       final fullLeads = (data['fullLeads'] as List? ?? [])
//           .whereType<Map<String, dynamic>>()
//           .map(CateringLead.fromJson)
//           .toList();
//       final maskedLeads = (data['maskedLeads'] as List? ?? [])
//           .whereType<Map<String, dynamic>>()
//           .map(CateringLead.fromJson)
//           .toList();
//
//       // Masked leads first, then unmasked sorted newest-first by id
//       final unmasked = fullLeads.where((l) => !l.masked).toList()
//         ..sort((a, b) => b.orderId.compareTo(a.orderId));
//       final masked = [...fullLeads.where((l) => l.masked), ...maskedLeads];
//
//       return [...masked, ...unmasked];
//     } catch (e) {
//       _log('LEADS', 'ERROR: $e');
//       return [];
//     }
//   }
//
//   // QUOTATIONS
//   static Future<List<Quotation>> fetchQuotations() async {
//     final vid = await _vid();
//     final endpoint = 'catering/api/vendor/quotations/$vid';
//
//     try {
//       final response = await _requestWithAuth(() async {
//         final token = await _token();
//         return await http.get(
//           Uri.parse('$_base/$endpoint'),
//           headers: _headers(token),
//         );
//       });
//
//       _log('QUOTATIONS', 'status=${response.statusCode}');
//       if (response.statusCode != 200) return [];
//
//       final body = jsonDecode(response.body) as Map<String, dynamic>;
//       if (body['success'] == true && body['data'] is List) {
//         return (body['data'] as List)
//             .whereType<Map<String, dynamic>>()
//             .map(Quotation.fromJson)
//             .toList();
//       }
//     } catch (e) {
//       _log('QUOTATIONS', 'ERROR: $e');
//     }
//     return [];
//   }
//
//   static Future<bool> sendQuotation({
//     required int leadId,
//     required Quotation quotation,
//   }) async {
//     final vid = await _vid();
//     final endpoint = 'catering/api/vendor/lead/quotation/$leadId/$vid';
//
//     try {
//       final response = await _requestWithAuth(() async {
//         final token = await _token();
//         return await http.post(
//           Uri.parse('$_base/$endpoint'),
//           headers: _headers(token),
//           body: jsonEncode(quotation.toJson()),
//         );
//       });
//
//       _log('SEND_QUOTATION', 'status=${response.statusCode}');
//       return response.statusCode >= 200 && response.statusCode < 300;
//     } catch (e) {
//       _log('SEND_QUOTATION', 'ERROR: $e');
//       return false;
//     }
//   }
//
//   // LEAD PAYMENT (Pay Now to unlock full lead details)
//   static Future<String?> createLeadPaymentOrder(double amount) async {
//     final vid = await _vid();
//     for (final url in [
//       '$_base/subscription/api/user/create-order',
//       '$_base/food/api/payments/create-order/user',
//     ]) {
//       try {
//         _log('CREATE_ORDER', 'POST $url  amount=$amount');
//         final res = await http.post(
//           Uri.parse(url),
//           headers: {
//             'Content-Type': 'application/json',
//             'Accept': 'application/json',
//           },
//           body: jsonEncode({
//             'amount': amount.round(),
//             'currency': 'INR',
//             'vendorId': vid,
//           }),
//         );
//         _log('CREATE_ORDER', 'status=${res.statusCode}');
//         if (res.statusCode >= 200 && res.statusCode < 300) {
//           final data = jsonDecode(res.body) as Map<String, dynamic>;
//           final id = data['orderId']?.toString() ?? data['id']?.toString();
//           if (id != null) return id;
//         }
//       } catch (e) {
//         _log('CREATE_ORDER', 'endpoint failed: $url  error: $e');
//       }
//     }
//     return null;
//   }
//
//   static Future<bool> initiateLeadPayment({
//     required int leadId,
//     required double amount,
//     required int orderId,
//   }) async {
//     final vid = await _vid();
//     final endpoint = 'catering/api/vendor/payment/initiate'
//         '?leadId=$leadId&vendorId=$vid&amount=$amount&orderid=$orderId';
//
//     try {
//       final response = await _requestWithAuth(() async {
//         final token = await _token();
//         return await http.post(
//           Uri.parse('$_base/$endpoint'),
//           headers: {
//             'Authorization': 'Bearer $token',
//             'Accept': 'application/json',
//           },
//         );
//       });
//
//       _log('INITIATE_PAYMENT', 'status=${response.statusCode}');
//       return response.statusCode >= 200 && response.statusCode < 300;
//     } catch (e) {
//       _log('INITIATE_PAYMENT', 'ERROR: $e');
//       return false;
//     }
//   }
//
//   static Future<bool> captureLeadPayment({
//     required String paymentId,
//     required double amount,
//   }) async {
//     final vid = await _vid();
//     const endpoint = 'subscription/api/user/capture';
//     _log('CAPTURE', 'POST $endpoint  paymentId=$paymentId  amount=$amount');
//
//     try {
//       final res = await http.post(
//         Uri.parse('$_base/$endpoint'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//         },
//         body: jsonEncode({
//           'paymentId': paymentId,
//           'amount': amount.round(),
//           'currency': 'INR',
//           'vendorId': vid,
//         }),
//       );
//       _log('CAPTURE', 'status=${res.statusCode}');
//       return res.statusCode >= 200 && res.statusCode < 300;
//     } catch (e) {
//       _log('CAPTURE', 'ERROR: $e');
//       return false;
//     }
//   }
//
//   // CAMPAIGN PAYMENT
//   static Future<String?> createCampaignPaymentOrder(double amountRupees) async {
//     try {
//       final response = await _requestWithAuth(() async {
//         final token = await _token();
//         return await http.post(
//           Uri.parse('$_base/promotions/api/payments/create-order/user'),
//           headers: _headers(token),
//           body: jsonEncode({'amount': amountRupees, 'currency': 'INR'}),
//         );
//       });
//
//       _log('CAMPAIGN_ORDER', 'status=${response.statusCode}');
//       if (response.statusCode >= 200 && response.statusCode < 300) {
//         final data = jsonDecode(response.body) as Map<String, dynamic>;
//         return data['orderId']?.toString() ?? data['id']?.toString();
//       }
//     } catch (e) {
//       _log('CAMPAIGN_ORDER', 'ERROR: $e');
//     }
//     return null;
//   }
//
//   static Future<bool> captureCampaignPayment({
//     required String paymentId,
//     required String orderId,
//     required String signature,
//     required double amountRupees,
//   }) async {
//     try {
//       final response = await _requestWithAuth(() async {
//         final token = await _token();
//         return await http.post(
//           Uri.parse('$_base/promotions/api/payments/capture'),
//           headers: _headers(token),
//           body: jsonEncode({
//             'paymentId': paymentId,
//             'orderId': orderId,
//             'signature': signature,
//             'amount': amountRupees,
//             'currency': 'INR',
//           }),
//         );
//       });
//
//       _log('CAMPAIGN_CAPTURE', 'status=${response.statusCode}');
//       return response.statusCode >= 200 && response.statusCode < 300;
//     } catch (e) {
//       _log('CAMPAIGN_CAPTURE', 'ERROR: $e');
//       return false;
//     }
//   }
// }

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../API/Apiclient.dart';
import '../models/catering_models.dart';

class CateringService {
  // ─────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────

  static Future<int> _vid() async {
    final p = await SharedPreferences.getInstance();
    return p.getInt('vendorId') ??
        int.tryParse(p.getString('vendorId') ?? '') ??
        0;
  }

  static void _log(String tag, String msg) {
    if (kDebugMode) debugPrint('🍽️ [$tag] $msg');
  }

  // ─────────────────────────────────────────────
  // LEADS
  // ─────────────────────────────────────────────

  static Future<List<CateringLead>> fetchLeads() async {
    final vid = await _vid();

    try {
      final response = await ApiClient.get(
        "api/vendor/$vid",
        service: "catering",
      );

      _log('LEADS', 'status=${response.statusCode}');
      if (response.statusCode != 200) return [];

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>? ?? {};

      final fullLeads = (data['fullLeads'] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(CateringLead.fromJson)
          .toList();

      final maskedLeads = (data['maskedLeads'] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(CateringLead.fromJson)
          .toList();

      final unmasked = fullLeads.where((l) => !l.masked).toList()
        ..sort((a, b) => b.orderId.compareTo(a.orderId));

      final masked = [...fullLeads.where((l) => l.masked), ...maskedLeads];

      return [...masked, ...unmasked];
    } catch (e) {
      _log('LEADS', 'ERROR: $e');
      return [];
    }
  }

  // ─────────────────────────────────────────────
  // QUOTATIONS
  // ─────────────────────────────────────────────

  static Future<List<Quotation>> fetchQuotations() async {
    final vid = await _vid();

    try {
      final response = await ApiClient.get(
        "api/vendor/quotations/$vid",
        service: "catering",
      );

      _log('QUOTATIONS', 'status=${response.statusCode}');
      if (response.statusCode != 200) return [];

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (body['success'] == true && body['data'] is List) {
        return (body['data'] as List)
            .whereType<Map<String, dynamic>>()
            .map(Quotation.fromJson)
            .toList();
      }
    } catch (e) {
      _log('QUOTATIONS', 'ERROR: $e');
    }

    return [];
  }

  static Future<bool> sendQuotation({
    required int leadId,
    required Quotation quotation,
  }) async {
    final vid = await _vid();

    try {
      final response = await ApiClient.post(
        "api/vendor/lead/quotation/$leadId/$vid",
        quotation.toJson(),
        service: "catering",
      );

      _log('SEND_QUOTATION', 'status=${response.statusCode}');
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      _log('SEND_QUOTATION', 'ERROR: $e');
      return false;
    }
  }

  // ─────────────────────────────────────────────
  // LEAD PAYMENT
  // ─────────────────────────────────────────────

  static Future<String?> createLeadPaymentOrder(double amount) async {
    final vid = await _vid();

    final endpoints = [
      {"service": "subscription", "url": "api/user/create-order"},
      {"service": "food", "url": "api/payments/create-order/user"},
    ];

    for (final ep in endpoints) {
      try {
        _log('CREATE_ORDER', 'Trying ${ep['url']}');

        final res = await ApiClient.post(ep['url']!, {
          'amount': amount.round(),
          'currency': 'INR',
          'vendorId': vid,
        }, service: ep['service']!);

        if (res.statusCode >= 200 && res.statusCode < 300) {
          final data = jsonDecode(res.body);
          final id = data['orderId']?.toString() ?? data['id']?.toString();
          if (id != null) return id;
        }
      } catch (e) {
        _log('CREATE_ORDER', 'Failed ${ep['url']} → $e');
      }
    }

    return null;
  }

  static Future<bool> initiateLeadPayment({
    required int leadId,
    required double amount,
    required int orderId,
  }) async {
    final vid = await _vid();

    try {
      final response = await ApiClient.post(
        "api/vendor/payment/initiate"
        "?leadId=$leadId&vendorId=$vid&amount=$amount&orderid=$orderId",
        null,
        service: "catering",
        sendJson: false,
      );

      _log('INITIATE_PAYMENT', 'status=${response.statusCode}');
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      _log('INITIATE_PAYMENT', 'ERROR: $e');
      return false;
    }
  }

  static Future<bool> captureLeadPayment({
    required String paymentId,
    required double amount,
  }) async {
    final vid = await _vid();

    try {
      final res = await ApiClient.post("api/user/capture", {
        'paymentId': paymentId,
        'amount': amount.round(),
        'currency': 'INR',
        'vendorId': vid,
      }, service: "subscription");

      _log('CAPTURE', 'status=${res.statusCode}');
      return res.statusCode >= 200 && res.statusCode < 300;
    } catch (e) {
      _log('CAPTURE', 'ERROR: $e');
      return false;
    }
  }

  // ─────────────────────────────────────────────
  // CAMPAIGN PAYMENT
  // ─────────────────────────────────────────────

  static Future<String?> createCampaignPaymentOrder(double amountRupees) async {
    try {
      final response = await ApiClient.post("api/payments/create-order/user", {
        'amount': amountRupees,
        'currency': 'INR',
      }, service: "promotions");

      _log('CAMPAIGN_ORDER', 'status=${response.statusCode}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        return data['orderId']?.toString() ?? data['id']?.toString();
      }
    } catch (e) {
      _log('CAMPAIGN_ORDER', 'ERROR: $e');
    }

    return null;
  }

  static Future<bool> captureCampaignPayment({
    required String paymentId,
    required String orderId,
    required String signature,
    required double amountRupees,
  }) async {
    try {
      final response = await ApiClient.post("api/payments/capture", {
        'paymentId': paymentId,
        'orderId': orderId,
        'signature': signature,
        'amount': amountRupees,
        'currency': 'INR',
      }, service: "promotions");

      _log('CAMPAIGN_CAPTURE', 'status=${response.statusCode}');
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      _log('CAMPAIGN_CAPTURE', 'ERROR: $e');
      return false;
    }
  }
}
