import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../config/api_config.dart';
import '../models/lead_model.dart';
import 'lead_service.dart';

class RazorpayPaymentService {
  final Razorpay _razorpay = Razorpay();

  void Function(LeadModel lead)? onSuccess;
  void Function(String message)? onError;

  RazorpayPaymentService() {
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  LeadModel? _currentLead;
  String? _currentVendorId;

  void dispose() => _razorpay.clear();

  String get _basicAuthHeader {
    final creds = base64Encode(
      utf8.encode('${ApiConfig.razorpayKeyId}:${ApiConfig.razorpayKeySecret}'),
    );
    return 'Basic $creds';
  }

  Future<void> payForLead({
    required LeadModel lead,
    required String vendorId,
  }) async {
    final amount = lead.leadPrice;
    if (lead.id == 0 || vendorId.isEmpty || amount <= 0) {
      onError?.call('Invalid payment parameters.');
      return;
    }

    _currentLead = lead;
    _currentVendorId = vendorId;

    try {
      // ── Step 1: create the Razorpay order ──────────────────────
      final orderRes = await http.post(
        Uri.parse('${ApiConfig.subscriptionBase}/user/create-order'),
        headers: {
          'Authorization': _basicAuthHeader,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'amount': amount.round(),
          'currency': 'INR',
          'vendorId': int.tryParse(vendorId) ?? vendorId,
        }),
      );

      if (orderRes.statusCode < 200 || orderRes.statusCode >= 300) {
        throw Exception('Order creation failed: ${orderRes.statusCode}');
      }

      final orderData = jsonDecode(orderRes.body) as Map<String, dynamic>;
      final razorpayOrderId = orderData['orderId']?.toString();

      if (razorpayOrderId == null || razorpayOrderId.isEmpty) {
        throw Exception('Order ID not received from backend');
      }

      // ── Step 2: open Razorpay checkout ─────────────────────────
      final options = {
        'key': ApiConfig.razorpayKeyId,
        'amount': amount.round(),
        'currency': 'INR',
        'name': 'Maamaas Catering',
        'description': 'Lead #${lead.id}',
        'order_id': razorpayOrderId,
        'prefill': {
          'name': lead.name,
          'email': lead.email,
          'contact': lead.mobile,
        },
        'theme': {'color': '#e66d33'},
      };

      _razorpay.open(options);
    } catch (e) {
      onError?.call('Payment error: $e');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    final lead = _currentLead;
    final vendorId = _currentVendorId;
    if (lead == null || vendorId == null) return;

    final paymentId = response.paymentId ?? '';
    final razorpayOrderId = response.orderId ?? '';

    try {
      // ── Step 3: save payment against the lead ────────────────
      final saved = await LeadService.savePaymentInitiation(
        leadId: lead.id,
        vendorId: vendorId,
        amount: lead.leadPrice,
        razorpayOrderId: razorpayOrderId,
      );

      if (saved) {
        onSuccess?.call(lead);
      } else {
        onError?.call('Payment succeeded but failed to record.');
      }

      // ── Step 4: capture the payment (best-effort, matches JS) ─
      try {
        await http.post(
          Uri.parse('${ApiConfig.subscriptionBase}/user/capture'),
          headers: {
            'Authorization': _basicAuthHeader,
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'paymentId': paymentId,
            'amount': lead.leadPrice.round(),
            'currency': 'INR',
            'vendorId': int.tryParse(vendorId) ?? vendorId,
          }),
        );
      } catch (_) {
        // Capture failure is non-fatal in the original flow too.
      }
    } catch (e) {
      onError?.call('Error saving payment: $e');
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    onError?.call('Payment failed: ${response.message ?? 'Unknown error'}');
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    onError?.call('Redirected to external wallet: ${response.walletName}');
  }
}
