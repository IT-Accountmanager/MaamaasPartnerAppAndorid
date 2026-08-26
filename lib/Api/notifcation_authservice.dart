// import 'dart:convert';
// import 'dart:io';
//
// import 'package:flutter/foundation.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import 'APIclient.dart';
//
// class Notification_authService {
//   static Future<void> registerFcmToken(String token) async {
//     // if (kDebugMode) {
//     //   print("🔔 ===== FCM TOKEN REGISTRATION START =====");
//     // }
//
//     final prefs = await SharedPreferences.getInstance();
//     final vendorId = prefs.getInt('vendorId');
//     final customerId = prefs.getString("customerId");
//
//     // if (kDebugMode) {
//     //   print("👤 Retrieved userId from SharedPreferences: $vendorId");
//     //   print("📱 FCM Token: $token");
//     // }
//
//     if (vendorId == null) {
//       // if (kDebugMode) {
//       //   print("⚠️ userId is NULL. Skipping FCM token registration.");
//       //   print("🔔 ===== FCM TOKEN REGISTRATION END =====");
//       // }
//       return;
//     }
//
//     String deviceType;
//
//     if (Platform.isAndroid) {
//       deviceType = "ANDROID";
//     } else if (Platform.isIOS) {
//       deviceType = "IOS";
//     } else {
//       deviceType = "UNKNOWN";
//     }
//
//     final body = {
//       "vendorId": vendorId,
//       "customerId": customerId,
//       "fcmToken": token,
//       "deviceType": deviceType,
//     };
//
//     if (kDebugMode)
//
//     // {
//     //   print("🌍 Endpoint: api/user/register-token");
//     //   print("🛎 Service: notification");
//     //   print("📦 Request Body: ${jsonEncode(body)}");
//     // }
//
//     try {
//       final response = await ApiClient.post(
//         "api/vendor/fcm/register-token",
//         body,
//         service: "notification",
//       );
//
//       // if (kDebugMode)
//       // {
//         print("📡 Response Status Code: ${response.statusCode}");
//         print("📡 Response Body: ${response.body}");
//       // }
//
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         // if (kDebugMode) {
//           print("✅ FCM Token Registered Successfully");
//         // }
//       }
//       else {
//         // if (kDebugMode) {
//         //   print("❌ Failed to register FCM token");
//         // }
//       }
//     }
//     catch (e, stackTrace) {
//       // if (kDebugMode) {
//       //   print("🚨 FCM Token Registration ERROR: $e");
//       //   print("🧵 StackTrace: $stackTrace");
//       // }
//     }
//
//     // if (kDebugMode)
//     // {
//     //   print("🔔 ===== FCM TOKEN REGISTRATION END =====");
//     // }
//   }
// }



import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'APIclient.dart';

class Notification_authService {
  static Future<void> registerFcmToken(String token) async {
    debugPrint('');
    debugPrint('========================================');
    debugPrint('🔥 FCM TOKEN REGISTRATION');
    debugPrint('========================================');

    debugPrint('📱 FCM Token length: ${token.length}');
    debugPrint('📱 FCM Token: $token');

    try {
      final prefs = await SharedPreferences.getInstance();

      final vendorId = prefs.getInt('vendorId');
      final customerId = prefs.getString('customerId');

      debugPrint('👤 vendorId: $vendorId');
      debugPrint('👤 customerId: $customerId');

      if (vendorId == null) {
        debugPrint('❌ vendorId is NULL');
        debugPrint('❌ FCM TOKEN WILL NOT BE SENT TO BACKEND');
        debugPrint('========================================');
        return;
      }

      String deviceType;

      if (Platform.isAndroid) {
        deviceType = "ANDROID";
      } else if (Platform.isIOS) {
        deviceType = "IOS";
      } else {
        deviceType = "UNKNOWN";
      }

      final body = {
        "vendorId": vendorId,
        "customerId": customerId,
        "fcmToken": token,
        "deviceType": deviceType,
      };

      debugPrint('📦 Request body:');
      debugPrint(jsonEncode(body));

      debugPrint('🌍 Calling: api/vendor/fcm/register-token');

      final response = await ApiClient.post(
        "api/vendor/fcm/register-token",
        body,
        service: "notification",
      );

      print('📡 Response status: ${response.statusCode}');
      print('📡 Response body: ${response.body}');

      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        print('✅ FCM TOKEN REGISTERED SUCCESSFULLY');
      } else {
        print('❌ FCM TOKEN REGISTRATION FAILED');
      }
    } catch (e, stackTrace) {
      print('🚨 FCM TOKEN REGISTRATION ERROR');
      print('Error: $e');
      print('StackTrace: $stackTrace');
    }

    print('========================================');
    print('🔥 FCM TOKEN REGISTRATION END');
    print('========================================');
  }
}