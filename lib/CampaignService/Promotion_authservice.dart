
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../API/Apiclient.dart';
import '../CampaignModel/CampaignAnalytics.dart';
import '../CampaignModel/CampaignRequest.dart';
import '../CampaignModel/CouponStats.dart';



class PromotionAuthService {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  // Store credentials (loaded once)
  static int? _userId;
  static String? _customerId;

  /// Load user credentials from SharedPreferences
  static Future<bool> loadUserCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getInt('userId');
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
    debugPrint('🚀 PromotionAuthService.fetchActiveCampaigns STARTED');

    if (_userId == null) throw Exception('User not logged in');
    final endpoint = 'api/user/active/campaigns?userId=$_userId';
    debugPrint('🌐 Endpoint: $endpoint');

    final response = await ApiClient.get(
      endpoint,
      service: 'promotions',
    );

    debugPrint('📥 Response status: ${response.statusCode}');
    if (response.statusCode != 200) {
      throw Exception('Failed to load campaigns: ${response.statusCode}');
    }

    final List<dynamic> data = jsonDecode(response.body);
    debugPrint('✅ Total campaigns received: ${data.length}');

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

    debugPrint('📤 Sending view request: $payload');

    final response = await ApiClient.post(
      'api/user/campaign/view',
      payload,
      service: 'promotions',
    );

    debugPrint('📥 View response status: ${response.statusCode}');
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

    debugPrint('📤 Sending like request: $payload');

    final response = await ApiClient.post(
      'api/user/campaign/like',
      payload,
      service: 'promotions',
    );

    debugPrint('📥 Like response status: ${response.statusCode}');
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

    debugPrint('📤 Sending share request: $payload');

    final response = await ApiClient.post(
      'api/user/campaign/share',
      payload,
      service: 'promotions',
    );

    debugPrint('📥 Share response status: ${response.statusCode}');
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Share tracking failed: ${response.body}');
    }
  }


  static Future<List<CampaignRequest>> fetchUserCampaigns() async {
    debugPrint('🚀 PromotionAuthService.fetchUserCampaigns STARTED');

    final prefs = await SharedPreferences.getInstance();
    final String? customerId = prefs.getString('customerId');

    if (customerId == null || customerId.isEmpty) {
      throw Exception('Customer ID not found');
    }

    final endpoint = 'api/user/$customerId';
    debugPrint('🌐 Endpoint: $endpoint');

    final response = await ApiClient.get(
      endpoint,
      service: 'promotions',
    );

    if (response.statusCode == 200) {
      if (response.body.isEmpty) return [];
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => CampaignRequest.fromJson(json)).toList();
    }

    if (response.statusCode == 404) {
      debugPrint('⚠️ No campaigns found for this user');
      return [];
    }

    throw Exception('Failed to load campaigns (${response.statusCode})');
  }

  // static Future<Map<String, dynamic>?> createCampaignWithPayment({
  //   required Map<String, dynamic> campaignData,
  //   File? imageFile,
  //   File? videoFile,
  // }) async {
  //   try {
  //     debugPrint('📤 Starting API call to create campaign');
  //
  //     // =========================
  //     // ✅ STEP 1: CLEAN DATA
  //     // =========================
  //
  //     // ❌ Remove invalid enums
  //     campaignData.remove('status');
  //     campaignData.remove('paymentStatus');
  //
  //     // =========================
  //     // ✅ STEP 2: REQUIRED FIELDS
  //     // =========================
  //
  //     campaignData['createdAt'] = DateTime.now().toIso8601String();
  //
  //     // =========================
  //     // ✅ STEP 3: WRAP JSON
  //     // =========================
  //
  //     final requestData = {
  //       "campaign": jsonEncode(campaignData),
  //     };
  //
  //     debugPrint('📦 FINAL REQUEST: ${jsonEncode(requestData)}');
  //
  //     // =========================
  //     // ✅ STEP 4: FILE HANDLING
  //     // =========================
  //
  //     Map<String, File>? files;
  //
  //     if (imageFile != null) {
  //       files = {'creative': imageFile};
  //     } else if (videoFile != null) {
  //       files = {'creative': videoFile};
  //     }
  //
  //     // =========================
  //     // ✅ STEP 5: API CALL
  //     // =========================
  //
  //     final response = await ApiClient.sendMultipartRequest(
  //       endpoint: 'api/user/create/campaign',
  //       method: 'POST',
  //       service: 'promotion',
  //       data: requestData,
  //       files: files,
  //     );
  //
  //     debugPrint('📤 Status: ${response.statusCode}');
  //     debugPrint('📤 Body: ${response.body}');
  //
  //     // =========================
  //     // ✅ STEP 6: SUCCESS RESPONSE
  //     // =========================
  //
  //     if (response.statusCode == 200 || response.statusCode == 201) {
  //       String responseBody = response.body.trim();
  //
  //       // If response is a simple success message
  //       if (responseBody == "Campaign created successfully" ||
  //           responseBody.startsWith("Campaign created")) {
  //
  //         // For now, return success without payment
  //         // If your backend returns orderId in headers or response, add it here
  //         return {
  //           'success': true,
  //           'campaignId': null,
  //           'orderId': null, // If backend returns orderId, add it here
  //           'razorpayKey': 'rzp_test_TJECsclCivENpY',
  //           'amount': campaignData['totalBudget']?.toDouble() ?? 0,
  //           'message': responseBody,
  //         };
  //       }
  //
  //       // Try to parse as JSON
  //       try {
  //         final data = jsonDecode(responseBody);
  //         return {
  //           'success': true,
  //           'campaignId': data['id'],
  //           'orderId': data['orderId'],
  //           'razorpayKey': data['razorpayKey'] ?? 'rzp_test_TJECsclCivENpY',
  //           'amount': data['amount'] ?? campaignData['totalBudget']?.toDouble() ?? 0,
  //         };
  //       } catch (e) {
  //         return {
  //           'success': true,
  //           'campaignId': null,
  //           'orderId': null,
  //           'razorpayKey': 'rzp_test_TJECsclCivENpY',
  //           'amount': campaignData['totalBudget']?.toDouble() ?? 0,
  //           'message': responseBody,
  //         };
  //       }
  //     }
  //
  //     return {
  //       'success': false,
  //       'statusCode': response.statusCode,
  //       'message': response.body,
  //     };
  //
  //   } catch (e, stackTrace) {
  //     debugPrint('❌ Error creating campaign: $e');
  //     debugPrint('📍 Stack trace: $stackTrace');
  //
  //     return {
  //       'success': false,
  //       'message': e.toString(),
  //     };
  //   }
  // }
  // static Future<Map<String, dynamic>?> createCampaignWithPayment({
  //   required Map<String, dynamic> campaignData,
  //   File? imageFile,
  //   File? videoFile,
  // }) async {
  //   try {
  //     debugPrint('📤 Starting API call to create campaign');
  //
  //     // =========================
  //     // ✅ STEP 1: CLEAN DATA
  //     // =========================
  //
  //     // Remove unwanted fields (backend should manage these)
  //     campaignData.remove('status');
  //     campaignData.remove('paymentStatus');
  //
  //     // =========================
  //     // ✅ STEP 2: ADD REQUIRED FIELDS
  //     // =========================
  //
  //     campaignData['createdAt'] = DateTime.now().toIso8601String();
  //
  //     // =========================
  //     // ✅ STEP 3: WRAP JSON
  //     // =========================
  //
  //     final requestData = {
  //       "campaign": jsonEncode(campaignData),
  //     };
  //
  //     debugPrint('📦 FINAL REQUEST: ${jsonEncode(requestData)}');
  //
  //     // =========================
  //     // ✅ STEP 4: FILE HANDLING
  //     // =========================
  //
  //     Map<String, File>? files;
  //
  //     if (imageFile != null) {
  //       files = {'creative': imageFile};
  //     } else if (videoFile != null) {
  //       files = {'creative': videoFile};
  //     }
  //
  //     // =========================
  //     // ✅ STEP 5: API CALL
  //     // =========================
  //
  //     final response = await ApiClient.sendMultipartRequest(
  //       endpoint: 'api/user/create/campaign',
  //       method: 'POST',
  //       service: 'promotions',
  //       data: requestData,
  //       files: files,
  //     );
  //
  //     debugPrint('📤 Status: ${response.statusCode}');
  //     debugPrint('📤 Body: ${response.body}');
  //
  //     // =========================
  //     // ✅ STEP 6: HANDLE RESPONSE
  //     // =========================
  //
  //     if (response.statusCode == 200 || response.statusCode == 201) {
  //       String responseBody = response.body.trim();
  //
  //       // Case 1: Plain text response
  //       if (responseBody == "Campaign created successfully" ||
  //           responseBody.startsWith("Campaign created")) {
  //         return {
  //           'success': true,
  //           'campaignId': null,
  //           'message': responseBody,
  //         };
  //       }
  //
  //       // Case 2: JSON response
  //       try {
  //         final data = jsonDecode(responseBody);
  //         return {
  //           'success': true,
  //           'campaignId': data['id'],
  //           'message': data['message'] ?? 'Campaign created successfully',
  //         };
  //       } catch (e) {
  //         // If response is not JSON but still success
  //         return {
  //           'success': true,
  //           'campaignId': null,
  //           'message': responseBody,
  //         };
  //       }
  //     }
  //
  //     // =========================
  //     // ❌ ERROR RESPONSE
  //     // =========================
  //
  //     return {
  //       'success': false,
  //       'statusCode': response.statusCode,
  //       'message': response.body,
  //     };
  //
  //   } catch (e, stackTrace) {
  //     debugPrint('❌ Error creating campaign: $e');
  //     debugPrint('📍 Stack trace: $stackTrace');
  //
  //     return {
  //       'success': false,
  //       'message': e.toString(),
  //     };
  //   }
  // }
  static Future<Map<String, dynamic>?> createCampaignWithPayment({
    required Map<String, dynamic> campaignData,
    File? imageFile,
    File? videoFile,
  }) async {
    try {
      debugPrint('📤 Starting API call to create campaign');

      // =========================
      // ✅ STEP 1: ENSURE REQUIRED FIELDS
      // =========================

      if (!campaignData.containsKey('created_at') && !campaignData.containsKey('createdAt')) {
        campaignData['created_at'] = DateTime.now().toIso8601String();
      }

      if (!campaignData.containsKey('status')) {
        campaignData['status'] = 'ACTIVE';
      }

      if (!campaignData.containsKey('approval_status')) {
        campaignData['approval_status'] = 'PENDING';
      }

      // =========================
      // ✅ STEP 2: CLEAN DATA - Remove unwanted fields
      // =========================

      campaignData.remove('isBudgetIncreased');
      campaignData.remove('budgetMultiplier');
      campaignData.remove('investmentAmount');
      campaignData.remove('reach');
      campaignData.remove('paymentStatus');

      // =========================
      // ✅ STEP 3: CREATE A COPY WITH ONLY ENCODABLE TYPES
      // =========================

      // Helper function to recursively clean values
      dynamic cleanValue(dynamic val) {
        if (val == null) return null;
        if (val is String || val is int || val is double || val is bool) {
          return val;
        }
        if (val is List) {
          return val.map((item) => cleanValue(item)).toList();
        }
        if (val is Map) {
          final Map<String, dynamic> result = {};
          val.forEach((k, v) {
            if (v != null) {
              result[k.toString()] = cleanValue(v);
            }
          });
          return result;
        }
        return val.toString();
      }

      final Map<String, dynamic> cleanData = {};

      for (var entry in campaignData.entries) {
        final key = entry.key;
        final value = entry.value;

        if (value == null) continue;

        if (value is String || value is int || value is double || value is bool) {
          cleanData[key] = value;
        } else if (value is List) {
          if (value.isNotEmpty) {
            if (value.first is Map || value.first is String || value.first is int || value.first is double) {
              cleanData[key] = value.map((item) => cleanValue(item)).toList();
            } else {
              cleanData[key] = value.toString();
            }
          } else {
            cleanData[key] = [];
          }
        } else if (value is Map) {
          // Recursively clean nested maps
          cleanData[key] = cleanValue(value);
        } else {
          cleanData[key] = value.toString();
        }
      }

      // =========================
      // ✅ STEP 4: WRAP JSON
      // =========================

      final requestData = {
        "campaign": jsonEncode(cleanData),
      };

      debugPrint('📦 FINAL REQUEST: ${jsonEncode(requestData)}');

      // =========================
      // ✅ STEP 5: FILE HANDLING
      // =========================

      Map<String, File>? files;

      if (imageFile != null) {
        files = {'creative': imageFile};
      } else if (videoFile != null) {
        files = {'creative': videoFile};
      }

      // =========================
      // ✅ STEP 6: API CALL
      // =========================

      final response = await ApiClient.sendMultipartRequest(
        endpoint: 'api/user/create/campaign',
        method: 'POST',
        service: 'promotions',
        data: requestData,
        files: files,
      );

      debugPrint('📤 Status: ${response.statusCode}');
      debugPrint('📤 Body: ${response.body}');

      // =========================
      // ✅ STEP 7: HANDLE RESPONSE
      // =========================

      if (response.statusCode == 200 || response.statusCode == 201) {
        String responseBody = response.body.trim();

        if (responseBody == "Campaign created successfully" ||
            responseBody.startsWith("Campaign created")) {
          return {
            'success': true,
            'campaignId': null,
            'message': responseBody,
          };
        }

        try {
          final data = jsonDecode(responseBody);
          return {
            'success': true,
            'campaignId': data['id'],
            'message': data['message'] ?? 'Campaign created successfully',
          };
        } catch (e) {
          return {
            'success': true,
            'campaignId': null,
            'message': responseBody,
          };
        }
      }

      return {
        'success': false,
        'statusCode': response.statusCode,
        'message': response.body,
      };

    } catch (e, stackTrace) {
      debugPrint('❌ Error creating campaign: $e');
      debugPrint('📍 Stack trace: $stackTrace');
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }
  // Fetch user campaigns

  // static Future<bool> createPromotion({
  //   required Map<String, dynamic> campaignData,
  //   required File? imageFile,
  //   required File? videoFile,
  // }) async {
  //   debugPrint('🚀 createPromotion STARTED');
  //
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     final String? customerId = prefs.getString('customerId');
  //     final String? mobileNumber = prefs.getString('mobileNumber');
  //
  //     debugPrint('👤 customerId: $customerId');
  //     debugPrint('📱 mobileNumber: $mobileNumber');
  //
  //     if (customerId == null || customerId.isEmpty) {
  //       throw Exception('User not logged in');
  //     }
  //
  //     // ✅ Add customerId and createdAt to campaignData
  //     campaignData['customerId'] = customerId;
  //     campaignData['createdAt'] = DateTime.now().toIso8601String();
  //     if (mobileNumber != null && mobileNumber.isNotEmpty) {
  //       campaignData['mobileNumber'] = mobileNumber;
  //     }
  //
  //     debugPrint('📦 Final Campaign Data: ${jsonEncode(campaignData)}');
  //
  //     // Prepare request data
  //     final Map<String, dynamic> requestData = {
  //       'campaign': jsonEncode(campaignData),
  //     };
  //
  //     // Prepare files
  //     final Map<String, File> files = {};
  //     if (imageFile != null) {
  //       debugPrint('🖼️ Image File: ${imageFile.path}');
  //       files['creative'] = imageFile;
  //     }
  //     if (videoFile != null) {
  //       debugPrint('🎥 Video File: ${videoFile.path}');
  //       files['creative'] = videoFile;
  //     }
  //
  //     debugPrint('📁 Files Map Keys: ${files.keys.toList()}');
  //
  //     // ✅ API call - use 'promotion' (singular) to match other working endpoints
  //     final response = await ApiClient.sendMultipartRequest(
  //       endpoint: 'api/user/create/campaign',
  //       method: 'POST',
  //       service: 'promotion',  // ✅ Changed from 'promotions' to 'promotion'
  //       data: requestData,
  //       files: files,
  //     );
  //
  //     debugPrint('📥 Response Status Code: ${response.statusCode}');
  //     debugPrint('📥 Response Body: ${response.body}');
  //
  //     if (response.statusCode == 200 || response.statusCode == 201) {
  //       debugPrint('✅ Promotion created successfully');
  //       return true;
  //     } else {
  //       debugPrint('❌ API Error Occurred');
  //       try {
  //         final json = jsonDecode(response.body);
  //         throw Exception(json['message'] ?? json['error'] ?? 'Failed to create promotion');
  //       } catch (e) {
  //         throw Exception('Failed to create promotion (Status: ${response.statusCode})');
  //       }
  //     }
  //   } catch (e, stack) {
  //     debugPrint('🔥 Exception: $e');
  //     debugPrint('🧵 StackTrace: $stack');
  //     rethrow;
  //   }
  // }

  static Future<CouponStats> fetchCouponStats(int campaignId) async {
    try {
      print("📡 Fetching Coupon Stats for Campaign: $campaignId");

      final response = await ApiClient.get(
        '/api/user/coupon/$campaignId/stats',
        service: 'promotions',
      );

      print("📥 Status: ${response.statusCode}");
      print("📥 Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return CouponStats.fromJson(data);
      } else {
        throw Exception('Failed: ${response.statusCode}');
      }
    } catch (e) {
      print("🚨 Error: $e");
      throw Exception('Error fetching coupon stats: $e');
    }
  }
  static Future<CampaignAnalytics> fetchCampaignAnalytics(int campaignId) async {
    debugPrint('🚀 PromotionAuthService.fetchCampaignAnalytics STARTED');
    final endpoint = 'api/user/campaigns/$campaignId/stats';
    final response = await ApiClient.get(
      endpoint,
      service: 'promotions',
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return CampaignAnalytics.fromJson(json);
    } else {
      throw Exception('Failed to load analytics: ${response.statusCode}');
    }
  }
  // static Future<Map<String, dynamic>?> fetchBillingRates() async {
  //   debugPrint('================ API CALL START =================');
  //
  //   try {
  //     debugPrint('🌐 Hitting API: api/user/get/billing');
  //
  //     final response = await ApiClient.get(
  //       'api/user/get/billing',
  //       service: 'promotions',
  //     );
  //
  //     debugPrint('📡 Response Status Code: ${response.statusCode}');
  //     debugPrint('📦 Raw Response Body: ${response.body}');
  //
  //     if (response.statusCode == 200) {
  //       debugPrint('✅ API SUCCESS');
  //
  //       final data = jsonDecode(response.body);
  //
  //       debugPrint('🧾 Decoded JSON: $data');
  //
  //       final result = {
  //         "targetAudiencesCharge":
  //         (data['targetAudiencesCharge'] ?? 0.0).toDouble(),
  //         "mediaTypeCharge":
  //         (data['mediaTypeCharge'] ?? 0.0).toDouble(),
  //         "displaypPositionCharge":
  //         (data['displaypPositionCharge'] ?? 0.0).toDouble(),
  //         "promotionCharge":
  //         (data['promotionCharge'] ?? 0.0).toDouble(),
  //         "reach":
  //         (data['reach'] ?? 0.0).toDouble(),
  //       };
  //
  //       debugPrint('🎯 Parsed Billing Data: $result');
  //
  //       return result;
  //     } else {
  //       debugPrint('❌ API FAILED with status: ${response.statusCode}');
  //     }
  //   } catch (e, stack) {
  //     debugPrint('💥 ERROR in fetchBillingRates');
  //     debugPrint('Error: $e');
  //     debugPrint('StackTrace: $stack');
  //   }
  //
  //   debugPrint('================ API CALL END =================');
  //
  //   return null;
  // }
  static Future<Map<String, dynamic>?> fetchBillingRates() async {
    debugPrint('================ API CALL START =================');

    try {
      debugPrint('🌐 Hitting API: api/user/get/billing');

      final response = await ApiClient.get(
        'api/user/get/billing',
        service: 'promotions',
      );

      debugPrint('📡 Response Status Code: ${response.statusCode}');
      debugPrint('📦 Raw Response Body: ${response.body}');

      if (response.statusCode == 200) {
        debugPrint('✅ API SUCCESS');

        final data = jsonDecode(response.body);

        debugPrint('🧾 Decoded JSON: $data');

        // CHECK IF menuChargePerItem EXISTS IN RESPONSE
        if (!data.containsKey('menuChargePerItem')) {
          debugPrint('❌ ERROR: menuChargePerItem not found in backend response');
          throw Exception('menuChargePerItem field missing from billing rates API');
        }

        final result = {
          "targetAudiencesCharge": (data['targetAudiencesCharge'] ?? 0.0).toDouble(),
          "mediaTypeCharge": (data['mediaTypeCharge'] ?? 0.0).toDouble(),
          "displaypPositionCharge": (data['displaypPositionCharge'] ?? 0.0).toDouble(),
          "promotionCharge": (data['promotionCharge'] ?? 0.0).toDouble(),
          "reach": (data['reach'] ?? 0.0).toDouble(),
          "menuChargePerItem": (data['menuChargePerItem']).toDouble(), // NO DEFAULT - MUST EXIST
          "couponCharge": (data['couponCharge'] ?? 0.0).toDouble(),   // <-- ADD THIS

          // 👇 new fields for digital campaigns
          "digitalScreenChargeImage": (data['digitalScreenChargeimage'] ?? 0.0).toDouble(),
          "digitalScreenChargeVideo": (data['digitalScreenChargevideo'] ?? 0.0).toDouble(),
          "digitalScreenSecondsCharge": (data['digitalScreenSecondsCharge'] ?? 0.0).toDouble(),

        };

        debugPrint('🎯 Parsed Billing Data: $result');

        return result;
      } else {
        debugPrint('❌ API FAILED with status: ${response.statusCode}');
        return null;
      }
    } catch (e, stack) {
      debugPrint('💥 ERROR in fetchBillingRates');
      debugPrint('Error: $e');
      debugPrint('StackTrace: $stack');
      return null;
    }
  }
// Add this method to PromotionAuthService class
  // Add this method to PromotionAuthService class - MAKE IT STATIC
  static Future<Map<String, dynamic>> fetchCustomerCampaignAnalytics() async {
    try {
      debugPrint('🚀 Fetching Customer Campaign Analytics');

      // Get customerId from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final String? customerId = prefs.getString('customerId');

      if (customerId == null || customerId.isEmpty) {
        throw Exception('Customer ID not found in SharedPreferences');
      }

      debugPrint('📱 Customer ID: $customerId');

      final endpoint = 'api/customer/campaign/analytics/$customerId';
      debugPrint('🌐 Endpoint: $endpoint');

      final response = await ApiClient.get(
        endpoint,
        service: 'promotions',
      );

      debugPrint('📥 Response Status: ${response.statusCode}');
      debugPrint('📥 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        debugPrint('✅ Analytics fetched successfully');
        return data;
      } else {
        throw Exception('Failed to fetch analytics: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error fetching customer analytics: $e');
      throw Exception('Failed to fetch customer campaign analytics: $e');
    }
  }
  static Future<List<Map<String, dynamic>>> fetchScreens() async {
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('📺 [SCREENS] Starting API call to fetch screens');
    debugPrint('📺 [SCREENS] Endpoint: api/user/screens');

    try {
      final response = await ApiClient.get(
        'api/user/screens',
        service: 'promotions',
      );

      debugPrint('📺 [SCREENS] Response Status Code: ${response.statusCode}');
      debugPrint('📺 [SCREENS] Raw Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        debugPrint('📺 [SCREENS] Successfully parsed ${data.length} screen(s)');

        final screens = data.map((screen) {
          return {
            'id': screen['id'] ?? 0,                 // ✅ use 'id' field
            'name': screen['name'] ?? 'Unnamed',
            'location': screen['location'] ?? '',
            'resolution': screen['resolution'] ?? '',
            'screenSize': screen['screenSize'] ?? '',
            'deviceId': screen['deviceId'] ?? '',    // keep for reference
          };
        }).toList();

        debugPrint('✅ [SCREENS] Screens fetched successfully. Total: ${screens.length}');
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        return screens;
      } else {
        debugPrint('❌ [SCREENS] Failed with status ${response.statusCode}');
        debugPrint('❌ [SCREENS] Error body: ${response.body}');
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        throw Exception('Failed to load screens: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ [SCREENS] Exception caught: $e');
      debugPrint('❌ [SCREENS] Stack trace: $stackTrace');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      throw Exception('Error fetching screens: $e');
    }
  }
}
