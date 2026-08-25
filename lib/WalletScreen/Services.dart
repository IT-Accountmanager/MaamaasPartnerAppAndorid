import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:maamaaspartner/Api/APIclient.dart';

import 'Model.dart';

class WalletService {
  // ── Fetch wallet balance ────────────────────────────────────────────────────
  static Future<WalletBalance?> fetchWalletBalance() async {
    try {
      final vendorId = await _getVendorId();
      if (vendorId == null) throw Exception('Vendor ID not found');

      final response = await ApiClient.get(
        'api/vendor/wallet',
        service: 'subscription',
        queryParams: {'vendorId': vendorId.toString()},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return WalletBalance.fromJson(data);
      } else {
        throw Exception(
          'Failed to fetch wallet balance: ${response.statusCode}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<WalletTransaction>> fetchTransactions() async {
    try {
      final vendorId = await _getVendorId();
      if (vendorId == null) throw Exception('Vendor ID not found');

      final response = await ApiClient.get(
        'api/vendor/transactions',
        service: 'subscription',
        queryParams: {'vendorId': vendorId.toString()},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data
            .map((e) => WalletTransaction.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to fetch transactions: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // ── Create Razorpay order ───────────────────────────────────────────────────

  static Future<Map<String, dynamic>> createOrder({
    required double amount,
    required String phoneNumber,
    String currency = 'INR',
    String? description,
  }) async {
    try {
      final vendorId = await _getVendorId();

      final body = {
        'amount': amount,
        'currency': currency,
        'phoneNumber': phoneNumber,
        'description': description ?? 'Wallet top-up for vendor $vendorId',
        'notes': {
          'vendor_id': vendorId?.toString() ?? '',
          'order_reference': 'WALLET_${DateTime.now().millisecondsSinceEpoch}',
        },
      };

      final response = await ApiClient.post(
        'api/user/create-order',
        body,
        service: 'subscription',
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to create order: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // ── Capture payment (optional server-side capture) ──────────────────────────

  static Future<bool> capturePayment({
    required String paymentId,
    required double amount,
    String currency = 'INR',
    String receipt = '',
  }) async {
    try {
      final body = {
        'paymentId': paymentId,
        'amount': amount,
        'currency': currency,
        'receipt': receipt,
      };

      final response = await ApiClient.post(
        'api/user/capture',
        body,
        service: 'subscription',
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  // ── Add cash to wallet after successful payment ─────────────────────────────

  static Future<AddCashResponse?> addCashAfterPayment({
    required double amount,
    required String paymentId,
    required String orderId,
  }) async {
    try {
      final vendorId = await _getVendorId();
      if (vendorId == null) throw Exception('Vendor ID not found');

      final response = await ApiClient.post(
        'api/vendor/addCash/self-loaded'
        '?vendorId=$vendorId'
        '&amount=$amount'
        '&paymentId=$paymentId'
        '&orderId=$orderId',
        null,
        service: 'subscription',
        sendJson: false,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return AddCashResponse.fromJson(data);
      } else {
        throw Exception('Failed to add cash: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // ── Helper ──────────────────────────────────────────────────────────────────

  static Future<int?> _getVendorId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('vendorId');
  }
}
