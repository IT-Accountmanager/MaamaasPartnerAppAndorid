import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../API/Apiclient.dart';
import 'PromotionalModel.dart';

const _baseUrl = 'http://staging.maamaas.com:8080';

class CampaignApiService {
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken') ?? prefs.getString('token');
  }

  static Future<String?> _getVendorId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('vendorId');
  }

  static Future<String?> _getCustomerId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('customerId');
  }

  static Future<List<Map<String, dynamic>>> fetchMenuItems() async {
    final vendorId = await _getVendorId();
    if (vendorId == null) return [];

    final res = await ApiClient.get(
      'api/dish/getbyvendor/$vendorId',
      service: 'food',
    );

    if (res.statusCode != 200) return [];

    final data = jsonDecode(res.body) as List;
    return data.cast<Map<String, dynamic>>();
  }

  static Future<double> applyCoupon({
    required String couponCode,
    required double amount,
  }) async {
    final res = await ApiClient.post('api/vendor/apply/coupon', {
      'customerId': 'VEN140520263',
      'couponCode': couponCode,
      'amount': amount,
      'usageType': 'CAMPAIGN',
    }, service: 'promotions');

    if (res.statusCode != 200) {
      final err = jsonDecode(res.body);
      throw Exception(err['message'] ?? 'Invalid Coupon');
    }

    final data = jsonDecode(res.body);
    return (data['discountAmount'] ?? 0).toDouble();
  }

  static Future<String> createOrder(double amount) async {
    final res = await ApiClient.post('api/payments/create-order/user', {
      'amount': amount,
      'currency': 'INR',
    }, service: 'promotions');

    if (res.statusCode != 200) {
      throw Exception('Failed to create order');
    }

    final data = jsonDecode(res.body);

    return data['orderId'] ?? data['id'] ?? '';
  }

  static Future<void> submitCampaign({
    required CampaignFormData formData,
    required double finalAmount,
    required String transactionId,
  }) async {
    final token = await _getToken();
    final customerId = await _getCustomerId();
    final vendorId = await _getVendorId();
    if (token == null || customerId == null)
      throw Exception('Missing credentials');

    final leads = formData.goalConfig.leads;
    final discount = formData.goalConfig.discount;

    final payload = {
      'campaignName': formData.name,
      'description':
          formData.mediaDescriptions['image'] ??
          formData.mediaDescriptions['video'] ??
          '',
      'goal': formData.goal.toUpperCase(),
      'subGoal': _mapSubGoal(formData.subGoal),
      'mediaType': formData.videoFile != null ? 'VIDEO' : 'IMAGE',
      'medium': formData.mediums.isNotEmpty
          ? formData.mediums.first.toUpperCase()
          : 'APP',
      'customerId': customerId,
      'totalBudget': finalAmount,
      'gst': finalAmount * 0.18 / 1.18,
      'startDate': formData.startDate.isNotEmpty
          ? '${formData.startDate}T00:00:00.000Z'
          : DateTime.now().toIso8601String(),
      'endDate': formData.endDate.isNotEmpty
          ? '${formData.endDate}T00:00:00.000Z'
          : DateTime.now().toIso8601String(),
      'transactionId': transactionId,
      'paymentMethod': 'Online_Payment',
      'interests': leads.interests.isNotEmpty ? leads.interests : ['FOOD'],
      'callToAction': _mapCTA(formData.callToAction),
      'targetAudience': formData.audience.isNotEmpty
          ? formData.audience.map(_mapAudience).toList()
          : ['Users'],
      'targeting': {
        'interests': leads.interests.isNotEmpty ? leads.interests : ['FOOD'],
        'gender': leads.gender.isNotEmpty ? leads.gender.toUpperCase() : null,
        'minAge': leads.ageRange[0],
        'maxAge': leads.ageRange[1],
        'radiusKm': 1000,
      },
      'status': 'DRAFT',
      'resolution': 'R_720P',
      'appType': formData.appTypes.isNotEmpty ? formData.appTypes.first : null,
      'vendorId': int.tryParse(vendorId ?? '0') ?? 0,
      'createdAt': DateTime.now().toIso8601String(),
    };

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$_baseUrl/promotions/api/user/create/campaign'),
    );
    request.headers['Authorization'] = 'Bearer $token';
    request.fields['campaign'] = jsonEncode(payload);

    final response = await request.send();
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Campaign creation failed: ${response.statusCode}');
    }
  }

  static String _mapSubGoal(String subGoal) {
    const map = {
      'whatsapp_messages': 'GET_MORE_WHATSAPP_MESSAGE',
      'more_calls': 'GET_MORE_CALLS',
      'website_visitors': 'GET_MORE_WEBSITE_VISITORS',
      'more_leads': 'GET_MORE_LEADS',
      'awareness': 'BRAND_AWARENESS',
      'recall': 'BRAND_RECALL',
      'premium': 'PREMIUM_POSTING',
      'new_customers': 'NEW_CUSTOMER',
      'existing_customers': 'EXISTING_CUSTOMER',
      'all_customers': 'ALL_CUSTOMERS',
    };
    return map[subGoal] ?? subGoal.toUpperCase();
  }

  static String? _mapCTA(String cta) {
    if (cta.isEmpty) return null;
    const map = {'enquire_now': 'ENQUIRE_NOW'};
    return map[cta] ?? cta.toUpperCase();
  }

  static String _mapAudience(String a) {
    const map = {'users': 'Users', 'vendors': 'Vendors', 'movers': 'Movers'};
    return map[a] ?? a;
  }
}

extension _StatusOK on int {
  bool ok(int code) => code >= 200 && code < 300;
}
