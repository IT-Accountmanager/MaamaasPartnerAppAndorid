
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../Models/food&beverages/subsctiption_plans.dart';

class SubscriptionApiService {
  static const String _baseUrl = 'http://staging.maamaas.com:8080';
  static const String _planType = 'STANDARD';
  static const String _businessVertical = 'FOOD_AND_BEVERAGES';
  static const String _razorpayKey = 'rzp_test_TJECsclCivENpY';

  String get razorpayKey => _razorpayKey;

  // ── Auth headers (for protected endpoints) ──────────────────────────────────
  Future<Map<String, String>> _authHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken') ?? '';
    return {
      'Content-Type': 'application/json',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Map<String, String> get _publicHeaders => {
    'Content-Type': 'application/json',
  };

  // ── Fetch subscription plan modules (public — no auth) ─────────────────────
  /// GET /subscription/api/subscription/plans?planType=STANDARD&businessVertical=FOOD_AND_BEVERAGES
  Future<SubscriptionPlan?> fetchSubscriptionPlan() async {
    try {
      final uri = Uri.parse('$_baseUrl/subscription/api/subscription/plans')
          .replace(
            queryParameters: {
              'planType': _planType,
              'businessVertical': _businessVertical,
            },
          );

      final response = await http.get(uri, headers: _publicHeaders);
      // debugPrint('fetchSubscriptionPlan [${response.statusCode}]');

      if (response.statusCode == 200) {
        return SubscriptionPlan.fromJson(jsonDecode(response.body));
      }
      // debugPrint('fetchSubscriptionPlan error body: ${response.body}');
      return null;
    } catch (e) {
      // debugPrint('fetchSubscriptionPlan EXCEPTION: $e');
      return null;
    }
  }

//
  Future<ActiveSubscription?> fetchActiveSubscription(int vendorId) async {
    try {
      final uri = Uri.parse(
        '$_baseUrl/subscription/api/subscription/vendor/vendor_subscription/$vendorId/active',
      ).replace(queryParameters: {'businessVertical': _businessVertical});

      final response = await http.get(uri, headers: await _authHeaders());
      // debugPrint('fetchActiveSubscription [${response.statusCode}]');
      //
      if (response.statusCode == 200) {
        return ActiveSubscription.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      // debugPrint('fetchActiveSubscription EXCEPTION: $e');
      return null;
    }
  }


  Future<Map<String, dynamic>> createOrder({
    required double amount,
    required int vendorId,
  }) async {
    final body = jsonEncode({
      'amount': amount,
      'currency': 'INR',
      'receipt': 'subscription_${DateTime.now().millisecondsSinceEpoch}',
      'vendorId': vendorId,
    });

    final response = await http.post(
      Uri.parse('$_baseUrl/subscription/api/user/create-order'),
      headers: _publicHeaders,
      body: body,
    );

    // debugPrint('createOrder [${response.statusCode}]: ${response.body}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    }
    throw Exception(
      'Create order failed [${response.statusCode}]: ${response.body}',
    );
  }

  // ── Capture payment (public) ───────────────────────────────────────────────
  /// POST /subscription/api/user/capture
  Future<void> capturePayment({
    required String paymentId,
    required double amount,
    required int vendorId,
  }) async {
    final body = jsonEncode({
      'paymentId': paymentId,
      'amount': amount,
      'currency': 'INR',
      'vendorId': vendorId.toString(),
    });

    final response = await http.post(
      Uri.parse('$_baseUrl/subscription/api/user/capture'),
      headers: _publicHeaders,
      body: body,
    );

    // debugPrint('capturePayment [${response.statusCode}]: ${response.body}');
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
        'Capture failed [${response.statusCode}]: ${response.body}',
      );
    }
  }

  // ── Create new subscription (public) ──────────────────────────────────────
  /// POST /subscription/api/subscription/api/vendor/subscription
  Future<Map<String, dynamic>> createSubscription({
    required int vendorId,
    required List<String> selectedModules,
    required String paymentId,
    required double totalAmount,
    required bool termsAccepted,
  }) async {
    final body = jsonEncode({
      'vendorId': vendorId,
      'planType': _planType,
      'businessVertical': _businessVertical,
      'billingCycle': 'YEARLY',
      'selectedModules': selectedModules,
      'transactionId': paymentId,
      'paymentMethod': 'Online_Payment',
      'totalAmount': totalAmount,
      'termsAccepted': termsAccepted,
    });

    final response = await http.post(
      Uri.parse(
        '$_baseUrl/subscription/api/subscription/api/vendor/subscription',
      ),
      headers: _publicHeaders,
      body: body,
    );

    // debugPrint('createSubscription [${response.statusCode}]: ${response.body}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    }
    throw Exception(
      'Subscription creation failed [${response.statusCode}]: ${response.body}',
    );
  }

  // ── Renew subscription (public) ────────────────────────────────────────────
  /// POST /subscription/api/subscription/vendor/subscription/renew?vendorId=...
  Future<Map<String, dynamic>> renewSubscription({
    required int vendorId,
    required List<String> selectedModules,
    required String paymentId,
    required double totalAmount,
    required bool termsAccepted,
  }) async {
    final body = jsonEncode({
      'vendorId': vendorId,
      'planType': _planType,
      'businessVertical': _businessVertical,
      'billingCycle': 'YEARLY',
      'selectedModules': selectedModules,
      'transactionId': paymentId,
      'paymentMethod': 'Online_Payment',
      'totalAmount': totalAmount,
      'termsAccepted': termsAccepted,
    });

    final uri = Uri.parse(
      '$_baseUrl/subscription/api/subscription/vendor/subscription/renew',
    ).replace(queryParameters: {'vendorId': vendorId.toString()});

    final response = await http.post(uri, headers: _publicHeaders, body: body);

    // debugPrint('renewSubscription [${response.statusCode}]: ${response.body}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    }
    throw Exception(
      'Renewal failed [${response.statusCode}]: ${response.body}',
    );
  }

  // ── Free Trial (public) ────────────────────────────────────────────────────
  /// POST /subscription/api/subscription/api/vendor/subscription  (billingCycle: FREE_TRAIL)
  Future<Map<String, dynamic>> activateFreeTrial({
    required int vendorId,
    required List<String> allModules,
    required bool termsAccepted,
  }) async {
    final body = jsonEncode({
      'vendorId': vendorId,
      'planType': _planType,
      'businessVertical': _businessVertical,
      'billingCycle': 'FREE_TRAIL',
      'selectedModules': allModules,
      'totalAmount': 0,
      'termsAccepted': termsAccepted,
    });

    final response = await http.post(
      Uri.parse(
        '$_baseUrl/subscription/api/subscription/api/vendor/subscription',
      ),
      headers: _publicHeaders,
      body: body,
    );

    // debugPrint('activateFreeTrial [${response.statusCode}]: ${response.body}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    }
    throw Exception(
      'Free trial failed [${response.statusCode}]: ${response.body}',
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  List<String> resolveSelectedModuleCodes({
    required List<PlanModule> allModules,
    required Map<String, bool> toggleState,
  }) {
    return allModules
        .where(
          (m) =>
              m.isMandatory ||
              m.isIncluded ||
              (m.isAddOn && toggleState[m.code] == true),
        )
        .map((m) => m.code)
        .toList();
  }

  double computeSubtotal({
    required List<PlanModule> allModules,
    required Map<String, bool> toggleState,
  }) {
    double total = 0;
    for (final m in allModules) {
      if (m.isMandatory) total += m.yearlyPrice;
      if (m.isAddOn && toggleState[m.code] == true) total += m.yearlyPrice;
    }
    return total;
  }

  double computeGrandTotal({
    required List<PlanModule> allModules,
    required Map<String, bool> toggleState,
  }) {
    final sub = computeSubtotal(
      allModules: allModules,
      toggleState: toggleState,
    );
    return sub + (sub * 0.18); // + 18% GST
  }
}
