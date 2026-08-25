import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'model.dart';

class ReferralService {
  static const String baseUrl = "http://staging.maamaas.com:8080";

  static Future<VendorReferralResponse?> getVendorByReferralCode(
    int vendorId,
  ) async {
    try {
      final endpoint = "subscription/api/vendor/getpayments/enquiry/$vendorId";
      final url = Uri.parse("$baseUrl/$endpoint");

      if (kDebugMode) {
        print("📡 Fetching vendor data from: $url");
      }

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (kDebugMode) {
        print("📩 Response status: ${response.statusCode}");
        print("📦 Response body: ${response.body}");
      }

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return VendorReferralResponse.fromJson(data);
      } else if (response.statusCode == 404) {
        if (kDebugMode) {
          print("❌ Vendor not found with ID: $vendorId");
        }
        return null;
      } else {
        if (kDebugMode) {
          print("❌ Failed to fetch vendor: ${response.statusCode}");
          print("Error body: ${response.body}");
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print("💥 Error fetching vendor by referral code: $e");
      }
      return null;
    }
  }
}
