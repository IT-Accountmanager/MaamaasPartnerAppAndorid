import 'dart:convert';
import '../../Api/APIclient.dart';
import '../Models/grocery/grocery_banner_model.dart';
import 'Apiclient.dart';

class grocery_authservice {
  Future<List<grocery_Banner>> fetchBanners() async {
    final endpoint = 'api/grocery/banners/getall';

    try {
      // Use ApiService.get to include token automatically
      final response = await ApiClient.get(endpoint, service: "grocery");

      print("📩 Banners Response: ${response.statusCode} → ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((item) => grocery_Banner.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load banners: ${response.statusCode}');
      }
    } catch (e) {
      print("⚠️ Exception while fetching banners: $e");
      throw Exception('Failed to load banners');
    }
  }

  static Future<List<grocery_Banner>> fetchBanner() async {
    final endpoint = 'banner/toprated/restaurants?userId=2&radiusKm=5';

    try {
      // Use ApiService.get to include token automatically
      final response = await ApiClient.get(endpoint, service: "grocery");

      print("📩 Banners Response: ${response.statusCode} → ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((item) => grocery_Banner.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load banners: ${response.statusCode}');
      }
    } catch (e) {
      print("⚠️ Exception while fetching banners: $e");
      throw Exception('Failed to load banners');
    }
  }

  Future<grocery_Banner> fetchVendorBanner(int vendorId) async {
    final endpoint = 'banner/vendor/$vendorId';

    try {
      // Use ApiService to automatically add token
      final response = await ApiClient.get(endpoint, service: "grocery");

      print(
        "📩 Vendor Banner Response: ${response.statusCode} → ${response.body}",
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return grocery_Banner.fromJson(jsonData);
      } else {
        throw Exception('Failed to load banner data: ${response.statusCode}');
      }
    } catch (e) {
      print("⚠️ Exception while fetching vendor banner: $e");
      throw Exception('Failed to load banner data');
    }
  }


}
