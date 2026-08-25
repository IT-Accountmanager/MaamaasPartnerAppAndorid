import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Models/food&beverages/promotions_model.dart';
import 'Apiclient.dart';

class promotion_Authservice {
  static Future<List<Campaign>> fetchcampaign() async {
    // debugPrint("🔵 ===== FETCH CAMPAIGNS START =====");

    final prefs = await SharedPreferences.getInstance();
    final customerId = prefs.getString('customerId');


    // debugPrint("👤 Retrieved userId from SharedPreferences: $customerId");

    if (customerId == null) {
      // debugPrint("❌ userId is NULL. Cannot fetch campaigns.");
      return [];
    }

    final String endpoint = 'api/user/active/campaigns?customerId=$customerId';

    // debugPrint("🌍 Endpoint: $endpoint");

    try {
      final response = await ApiClient.get(endpoint, service: "promotions");

      // debugPrint("📡 Response Status Code: ${response.statusCode}");
      // debugPrint("📦 Raw Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final dynamic decodedData = jsonDecode(response.body);

        // debugPrint("🧩 Decoded Type: ${decodedData.runtimeType}");

        final List<dynamic> campaignList = decodedData is List
            ? decodedData
            : [decodedData];

        // debugPrint("📊 Campaign Count from API: ${campaignList.length}");

        final campaigns = campaignList
            .map((e) => Campaign.fromJson(e))
            .toList();

        // debugPrint("✅ Parsed Campaign Objects: ${campaigns.length}");
        // debugPrint("🟢 ===== FETCH CAMPAIGNS SUCCESS =====");

        return campaigns;
      } else {
        // debugPrint(
        //   "❌ Failed to fetch campaigns. Status Code: ${response.statusCode}",
        // );
        // debugPrint("🔴 ===== FETCH CAMPAIGNS FAILED =====");
        return [];
      }
    } catch (e, stackTrace) {
      // debugPrint("⚠️ Exception while fetching campaigns: $e");
      // debugPrint("📍 StackTrace: $stackTrace");
      // debugPrint("🔴 ===== FETCH CAMPAIGNS ERROR =====");
      return [];
    }
  }

  static Future<void> sendViewAnalytics(Map<String, dynamic> payload) async {
    final endpoint = "api/user/campaign/view";
    try {
      final response = await ApiClient.post(
        endpoint,
        payload,
        service: "promotions",
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("✅ View analytics sent successfully");
      } else {
        print("❌ Failed to send analytics");
        print("Status Code: ${response.statusCode}");
        print("Response: ${response.body}");
      }
    } catch (e) {
      print("❌ API Error: $e");
    }
  }
  static Future<void> sendlikeAnalytics(Map<String, dynamic> payload) async {
    final endpoint = "api/user/campaign/like";

    try {
      print("➡️ Sending Payload: $payload");

      final response = await ApiClient.post(
        endpoint,
        payload,
        service: "promotions",
      );

      print("⬅️ Status: ${response.statusCode}");
      print("⬅️ Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("✅ like analytics sent successfully");
      } else {
        print("❌ Failed to send analytics");
      }
    } catch (e, stack) {
      print("❌ API Error: $e");
      print(stack);
    }
  }

  static Future<void> sendshareAnalytics(Map<String, dynamic> payload) async {
    final endpoint = "api/user/campaign/share";
    try {
      final response = await ApiClient.post(
        endpoint,
        payload,
        service: "promotions",
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("✅ share analytics sent successfully");
      } else {
        print("❌ Failed to send analytics");
        print("Status Code: ${response.statusCode}");
        print("Response: ${response.body}");
      }
    } catch (e) {
      print("❌ API Error: $e");
    }
  }

  static Future<void> sendsaveAnalytics(Map<String, dynamic> payload) async {
    final endpoint = "api/user/campaign/save";
    try {
      final response = await ApiClient.post(
        endpoint,
        payload,
        service: "promotions",
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("✅ save analytics sent successfully");
      } else {
        print("❌ Failed to send analytics");
        print("Status Code: ${response.statusCode}");
        print("Response: ${response.body}");
      }
    } catch (e) {
      print("❌ API Error: $e");
    }
  }
}
