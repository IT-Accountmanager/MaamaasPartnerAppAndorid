import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../API/Apiclient.dart';
import '../Models/food&beverages/CampaignAnalytics.dart';
import '../Models/food&beverages/CampaignRequest.dart';

class PromotionAuthService {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  // Store credentials (loaded once)
  static int? _userId;
  static String? _customerId;

  /// Load user credentials from SharedPreferences
  static Future<bool> loadUserCredentials() async {
    final prefs = await SharedPreferences.getInstance();

    _customerId = prefs.getString('customerId');
    return _userId != null && _customerId != null && _customerId!.isNotEmpty;
  }

  static int? get userId => _userId;
  static String? get customerId => _customerId;

  /// Helper to get device type
  static String _getDeviceType() {
    if (Platform.isAndroid) return "ANDROID";
    if (Platform.isIOS) return "IOS";
    return "UNKNOWN";
  }

  static Future<List<CampaignRequest>> fetchActiveCampaigns() async {
    // debugPrint('🚀 PromotionAuthService.fetchActiveCampaigns STARTED');

    if (_userId == null) throw Exception('User not logged in');
    final endpoint = 'api/user/active/campaigns?customerId=$customerId';
    // debugPrint('🌐 Endpoint: $endpoint');

    final response = await ApiClient.get(endpoint, service: 'promotion');

    // debugPrint('📥 Response status: ${response.statusCode}');
    if (response.statusCode != 200) {
      throw Exception('Failed to load campaigns: ${response.statusCode}');
    }

    final List<dynamic> data = jsonDecode(response.body);
    // debugPrint('✅ Total campaigns received: ${data.length}');

    return data.map((json) => CampaignRequest.fromJson(json)).toList();
  }

  static Future<void> trackView(int campaignId) async {
    if (_customerId == null) throw Exception('Customer ID missing');
    final payload = {
      "campaignId": campaignId,
      "customerId": _customerId,
      "distanceKm": 0,
      "durationSeconds": 0,
      "scrollDepthPercent": 0,
      "deviceType": _getDeviceType(),
    };

    // debugPrint('📤 Sending view request: $payload');

    final response = await ApiClient.post(
      'api/user/campaign/view',
      payload,
      service: 'promotion',
    );

    // debugPrint('📥 View response status: ${response.statusCode}');
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('View tracking failed: ${response.body}');
    }
  }

  static Future<void> likeCampaign(int campaignId) async {
    if (_customerId == null) throw Exception('Customer ID missing');
    final payload = {
      "deliveryId": 0,
      "campaignId": campaignId,
      "customerId": _customerId,
      "interactionType": "LIKE",
      "deviceType": _getDeviceType(),
      "durationSeconds": 0,
      "scrollDepthPercent": 0,
    };

    // debugPrint('📤 Sending like request: $payload');

    final response = await ApiClient.post(
      'api/user/campaign/like',
      payload,
      service: 'promotion',
    );

    // debugPrint('📥 Like response status: ${response.statusCode}');
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Like failed: ${response.body}');
    }
  }

  static Future<void> trackShare(int campaignId) async {
    if (_customerId == null) throw Exception('Customer ID missing');
    final payload = {
      "deliveryId": 0,
      "campaignId": campaignId,
      "customerId": _customerId,
      "interactionType": "SHARE",
      "deviceType": _getDeviceType(),
      "durationSeconds": 0,
      "scrollDepthPercent": 0,
    };

    // debugPrint('📤 Sending share request: $payload');

    final response = await ApiClient.post(
      'api/user/campaign/share',
      payload,
      service: 'promotion',
    );

    // debugPrint('📥 Share response status: ${response.statusCode}');
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Share tracking failed: ${response.body}');
    }
  }

  static Future<List<CampaignRequest>> fetchUserCampaigns() async {
    // debugPrint('🚀 PromotionAuthService.fetchUserCampaigns STARTED');

    final prefs = await SharedPreferences.getInstance();
    final String? customerId = prefs.getString('customerId');

    if (customerId == null || customerId.isEmpty) {
      throw Exception('Customer ID not found');
    }

    final endpoint = 'api/user/$customerId';
    // debugPrint('🌐 Endpoint: $endpoint');

    final response = await ApiClient.get(endpoint, service: 'promotion');

    if (response.statusCode == 200) {
      if (response.body.isEmpty) return [];
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => CampaignRequest.fromJson(json)).toList();
    }

    if (response.statusCode == 404) {
      // debugPrint('⚠️ No campaigns found for this user');
      return [];
    }

    throw Exception('Failed to load campaigns (${response.statusCode})');
  }

  static Future<bool> createPromotion({
    required Map<String, dynamic> campaignData,
    required File? imageFile,
    required File? videoFile,
  }) async {
    // debugPrint('🚀 PromotionAuthService.createPromotion STARTED');

    final prefs = await SharedPreferences.getInstance();
    final String? customerId = prefs.getString('customerId');
    if (customerId == null || customerId.isEmpty) {
      throw Exception('User not logged in');
    }

    campaignData['customerId'] = customerId;
    campaignData['createdAt'] = DateTime.now().toIso8601String();

    final Map<String, dynamic> requestData = {
      'campaign': jsonEncode(campaignData),
    };

    final Map<String, File> files = {};
    if (imageFile != null) files['creative'] = imageFile;
    if (videoFile != null) files['creative'] = videoFile;

    final response = await ApiClient.sendMultipartRequest(
      endpoint: 'api/user/create/campaign',
      method: 'POST',
      service: 'promotion',
      data: requestData,
      files: files,
    );

    // debugPrint('📦 Status Code: ${response.statusCode}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      try {
        final json = jsonDecode(response.body);
        throw Exception(
          json['message'] ?? json['error'] ?? 'Failed to create promotion',
        );
      } catch (_) {
        throw Exception('Failed to create promotion');
      }
    }
  }

  static Future<CampaignAnalytics> fetchCampaignAnalytics(
    int campaignId,
  ) async {
    // debugPrint('🚀 PromotionAuthService.fetchCampaignAnalytics STARTED');
    final endpoint = 'api/user/campaigns/$campaignId/stats';
    final response = await ApiClient.get(endpoint, service: 'promotion');

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return CampaignAnalytics.fromJson(json);
    } else {
      throw Exception('Failed to load analytics: ${response.statusCode}');
    }
  }
}
