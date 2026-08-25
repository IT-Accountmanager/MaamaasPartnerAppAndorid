import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:maamaaspartner/user_module/Models/caterings/vendor_quotation_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Api/APIclient.dart';
import '../Models/caterings/aboutusmodel.dart';
import '../Models/caterings/banner_model.dart';
import '../Models/caterings/catering_cart_model.dart';
import '../Models/caterings/catering_enquiry_model.dart';
import '../Models/caterings/dish.dart';
import '../Models/caterings/orders_model.dart';
import '../Models/caterings/packages_model.dart';

class catering_authservice {
  static const String baseUrl =
      "http://10.10.20.9:7007/caterings-0.0.1-SNAPSHOT";

  static Future<List<catering_BannerModel>> fetchBanners() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final customerId = prefs.getString('customerId');
      final endpoint = "api/user/nearby-vendors/?customerId=$customerId";

      final response = await ApiClient.get(endpoint, service: "catering");

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final banners = data
            .map((e) => catering_BannerModel.fromJson(e))
            .toList();
        // debugPrint("✅ Banners fetched: $banners");
        return banners;
      } else {
        // debugPrint(
        //   "⚠️ Failed to fetch banners: ${response.statusCode} → ${response.body}",
        // );
        return [];
      }
    } catch (e) {
      print("❌ Error fetching banners: $e");
      return [];
    }
  }

  static Future<catering_BannerModel?> fetchBannerById(String vendorId) async {
    final endpoint = "api/banner/get/$vendorId ";
    try {
      final response = await ApiClient.get(endpoint, service: "catering");

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final banner = catering_BannerModel.fromJson(data);
        debugPrint("✅ Banner fetched: ${banner.companyName}");
        return banner;
      } else {
        debugPrint("❌ Failed to fetch banner: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      debugPrint("⚠️ Error fetching banner: $e");
      return null;
    }
  }

  static Future<List<Package>> fetchPackageById(String vendorId) async {
    final endpoint = "api/package/$vendorId";

    try {
      final response = await ApiClient.get(endpoint, service: "catering");

      debugPrint("📡 Fetching packages from: $endpoint");
      debugPrint("📥 Response: ${response.statusCode} → ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        // ✅ Parse into Package objects
        final packages = data.map((json) => Package.fromJson(json)).toList();

        debugPrint("✅ Parsed ${packages.length} packages");
        return packages;
      } else {
        throw Exception("❌ Failed to fetch package: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("⚠️ Error fetching package: $e");
      return [];
    }
  }

  static Future<List<Dish>> fetchDishes() async {
    const endpoint = "api/user/dishes/getAll";

    try {
      final response = await ApiClient.get(
        endpoint,
        service: "catering",
      ); // ✅ using service with token

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        final dishes = data.map((e) => Dish.fromJson(e)).toList();
        debugPrint("✅ Fetched ${dishes.length} dishes");
        return dishes;
      } else {
        debugPrint("❌ Failed to fetch dishes: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      debugPrint("⚠️ Error fetching dishes: $e");
      return [];
    }
  }

  // static Future<bool> createEnquiry({
  //   required String fullName,
  //   required String email,
  //   required String phoneNumber,
  //   required String eventType,
  //   required String eventDate,
  //   required String eventTime,
  //   required String people,
  //   required String budget,
  //   required String fullAddress,
  //   required String country,
  //   required String state,
  //   required String city,
  //   required String vegPlates,
  //   required String nonVegPlates,
  //   required String mixedPlates,
  //   required String specialRequests,
  //   required List<int> selectedItems,
  //   int? addressId,
  // }) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final userId = prefs.getInt('userId');
  //   final url = "api/user/enquiry/create/$userId";
  //
  //   final now = DateTime.now();
  //
  //   final body = {
  //     "fullName": fullName,
  //     "email": email,
  //     "phoneNumber": phoneNumber,
  //     "eventType": eventType,
  //     "eventDate": eventDate,
  //     "eventTime": eventTime,
  //     "people": people,
  //     "budget": budget,
  //     "fullAddress": fullAddress,
  //     "country": country,
  //     "state": state,
  //     "city": city,
  //     "vegPlates": vegPlates,
  //     "nonVegPlates": nonVegPlates,
  //     "mixedPlates": mixedPlates,
  //     "specialRequests": specialRequests,
  //     "dishId": selectedItems,
  //     if (addressId != null) "addressId": addressId,
  //     "createdAt": now.toIso8601String(),
  //     "updatedAt": now.toIso8601String(),
  //   };
  //
  //   try {
  //     debugPrint("📤 Enquiry POST → $url");
  //     debugPrint("📦 Payload → ${jsonEncode(body)}");
  //
  //     final response = await ApiClient.post(url, body, service: "catering");
  //
  //     debugPrint("📬 Response Code: ${response.statusCode}");
  //     debugPrint("📬 Response Body: ${response.body}");
  //
  //     if (response.statusCode == 200 || response.statusCode == 201) {
  //       return true;
  //     } else {
  //       debugPrint("❌ Failed Enquiry Creation → ${response.body}");
  //       return false;
  //     }
  //   } catch (e) {
  //     debugPrint("❌ Exception in createEnquiry(): $e");
  //     return false;
  //   }
  // }

  static Future<bool> createEnquiry({
    required String fullName,
    required String email,
    required String phoneNumber,
    // required String event,
    required String eventType,
    required String eventDate,
    required String eventTime,
    required String people,
    required String budget,
    required String fullAddress,
    required String country,
    required String state,
    required String city,
    required String vegPlates,
    required String nonVegPlates,
    required String mixedPlates,
    required String additionalRequests,
    required List<int> selectedItems,
    int? addressId,
    int? pincode,
    String? gstRequirement,
    List<Map<String, dynamic>>? addOns, // Add this parameter
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final customerId = prefs.getString('customerId');
    final url = "api/user/enquiry/create/?customerId=$customerId";

    // Convert string values to appropriate types
    int? parsedVegPlates = int.tryParse(vegPlates);
    int? parsedNonVegPlates = int.tryParse(nonVegPlates);
    int? parsedMixedPlates = int.tryParse(mixedPlates);
    int? parsedPeople = int.tryParse(people);
    double? parsedBudget = double.tryParse(budget);

    final body = {
      "event": "EVENT",
      "fullName": fullName,
      "email": email,
      "phoneNumber": phoneNumber,
      // "event": event,
      "eventType": eventType,
      "eventDate": eventDate,
      "eventTime": eventTime,
      "people": parsedPeople,
      "budget": parsedBudget,
      "fullAddress": fullAddress,
      "country": country,
      "state": state,
      "city": city,
      "vegPlates": parsedVegPlates,
      "nonVegPlates": parsedNonVegPlates,
      "mixedPlates": parsedMixedPlates,
      "additionalRequests": additionalRequests,
      "dishId": selectedItems,
      if (addressId != null) "addressId": addressId,
      if (pincode != null) "pincode": pincode,
      if (gstRequirement != null && gstRequirement.isNotEmpty)
        "gstRequirement": gstRequirement,
      if (addOns != null && addOns.isNotEmpty)
        "addOns": addOns, // Add this line
    };

    try {
      debugPrint("📤 Enquiry POST → $url");
      debugPrint("📦 Payload → ${jsonEncode(body)}");

      final response = await ApiClient.post(url, body, service: "catering");

      debugPrint("📬 Response Code: ${response.statusCode}");
      debugPrint("📬 Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        debugPrint("❌ Failed Enquiry Creation → ${response.body}");
        return false;
      }
    } catch (e) {
      debugPrint("❌ Exception in createEnquiry(): $e");
      return false;
    }
  }

  static Future<bool> addToCart({
    required String customerId,
    required int packageId,
    required int quantity,
  }) async {
    debugPrint("🛒 [addToCart] Started...");
    debugPrint(
      "👤 userId: $customerId | 📦 packageId: $packageId | 🔢 quantity: $quantity",
    );

    try {
      final body = {
        "customerId": customerId,
        "packageId": packageId,
        "quantity": quantity,
      };

      final endpoint = "api/user/cart/add";
      debugPrint("🌐 [addToCart] Endpoint: $endpoint");
      debugPrint("📤 [addToCart] Request Body: ${jsonEncode(body)}");

      final response = await ApiClient.post(
        endpoint,
        body,
        service: "catering",
      );

      debugPrint("📥 [addToCart] Response Status: ${response.statusCode}");
      debugPrint("📥 [addToCart] Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        final int? cartId = data["id"];

        if (cartId == null || cartId <= 0) {
          debugPrint("❌ [addToCart] Invalid cartId received: $cartId");
          return false;
        }

        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt("cartId", cartId);

        debugPrint("✅ [addToCart] Cart ID saved: $cartId");

        debugPrint("✅ [addToCart] Cart ID saved locally in SharedPreferences.");

        return true;
      } else {
        debugPrint("❌ [addToCart] Failed → ${response.statusCode}");
        return false;
      }
    } catch (e, stackTrace) {
      debugPrint("⚠️ [addToCart] Exception: $e");
      debugPrint("🧩 [addToCart] Stack Trace: $stackTrace");
      return false;
    } finally {
      debugPrint("🏁 [addToCart] Completed.");
    }
  }

  static Future<catering_Cart?> fetchUserCart() async {
    final prefs = await SharedPreferences.getInstance();
    final customerId = prefs.getString('customerId') ?? "";
    final endpoint = "api/user/get/cart?customerId=$customerId";

    try {
      final response = await ApiClient.get(endpoint, service: "catering");

      debugPrint("📡 Cart API Status: ${response.statusCode}");
      debugPrint("📦 Cart API Response: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> body =
            json.decode(response.body) as Map<String, dynamic>;

        return catering_Cart.fromJson(body);
      } else {
        debugPrint("❌ Failed to fetch cart: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      debugPrint("❌ Error fetching cart: $e");
      return null;
    }
  }

  // static Future<Map<String, dynamic>?> placeOrder({
  //   required int customerId,
  //   required int cartId,
  //   required String paymentMethod,
  //   required String razorpayPaymentId,
  //   required String razorpayOrderId,
  //   required double grandTotal,
  //   List<String>? walletTypes,
  // }) async {
  //   debugPrint("🚀 [placeOrder] Started ----------------------------");
  //   debugPrint("👤 customerId: $customerId");
  //   debugPrint("🛒 cartId: $cartId");
  //   debugPrint("💳 paymentMethod: $paymentMethod");
  //   debugPrint("🪙 razorpayPaymentId: $razorpayPaymentId");
  //   debugPrint("🧾 razorpayOrderId: $razorpayOrderId");
  //   debugPrint("💰 grandTotal: $grandTotal");
  //   debugPrint("🏦 walletType: $walletTypes");
  //
  //   try {
  //     final updateCartResponse = await ApiClient.post(
  //       "api/user/cart/update-customer?cartId=$cartId&customerId=$customerId",
  //       {},
  //       service: 'catering',
  //     );
  //
  //     if (updateCartResponse.statusCode != 200) {
  //       debugPrint("⚠️ Failed to update cart with customerId");
  //     }
  //
  //     // Build order URL - note: we're NOT including customerId in query params
  //     final buffer = StringBuffer(
  //       "api/user/orders?"
  //       "cartId=$cartId"
  //       "&paymentMethod=$paymentMethod"
  //       "&razorpayPaymentId=$razorpayPaymentId"
  //       "&razorpayOrderId=$razorpayOrderId"
  //       "&grandTotal=$grandTotal",
  //     );
  //
  //     if (walletTypes != null && walletTypes.isNotEmpty) {
  //       // Handle multiple wallet types - depends on backend format
  //       // If backend expects comma-separated values:
  //       final walletTypesString = walletTypes.join(',');
  //       buffer.write("&walletType=$walletTypesString");
  //       debugPrint("🏦 [placeOrder] walletType appended: $walletTypesString");
  //     }
  //
  //     final endpoint = buffer.toString();
  //     debugPrint("📤 [placeOrder] Final Order Endpoint: $endpoint");
  //
  //     // Send POST request
  //     final response = await ApiClient.post(endpoint, {}, service: 'catering');
  //
  //     debugPrint("📬 [placeOrder] Response Status: ${response.statusCode}");
  //     debugPrint("📬 [placeOrder] Response Body: ${response.body}");
  //
  //     if (response.statusCode == 200 || response.statusCode == 201) {
  //       try {
  //         final Map<String, dynamic> parsed = jsonDecode(response.body);
  //         debugPrint("✅ [placeOrder] Order Success → Parsed: $parsed");
  //         return parsed;
  //       } catch (e) {
  //         debugPrint("⚠️ [placeOrder] JSON Decode Error: $e");
  //         return null;
  //       }
  //     } else {
  //       debugPrint("❌ [placeOrder] Failed: ${response.statusCode}");
  //       return null;
  //     }
  //   } catch (e, stack) {
  //     debugPrint("💥 [placeOrder] Exception: $e");
  //     debugPrint("📜 [placeOrder] Stacktrace: $stack");
  //     return null;
  //   } finally {
  //     debugPrint("🏁 [placeOrder] Completed ----------------------------");
  //   }
  // }

  static Future<Map<String, dynamic>?> placeOrder({
    // required int customerId,
    required int cartId, // cartId
    required String paymentMethod,
    required String razorpayPaymentId,
    required String razorpayOrderId,
    required double grandTotal,
    // String? walletType,
    List<String>? walletTypes,
  }) async {


    final prefs = await SharedPreferences.getInstance();
    final customerId = prefs.getString('customerId') ?? "";

    debugPrint("🚀 [placeOrder] Started ----------------------------");
    debugPrint("👤 customerId: $customerId");
    debugPrint("🛒 cartId: $cartId");
    debugPrint("💳 paymentMethod: $paymentMethod");
    debugPrint("🪙 razorpayPaymentId: $razorpayPaymentId");
    debugPrint("🧾 razorpayOrderId: $razorpayOrderId");
    debugPrint("💰 grandTotal: $grandTotal");
    debugPrint("🏦 walletType: $walletTypes");

    try {
      // final prefs = await SharedPreferences.getInstance();
      // final cartId = prefs.getInt('cartId') ?? cartId;
      // debugPrint("📦 [placeOrder] Using Cart ID: $cartId");

      // ✅ Build order URL dynamically
      final buffer = StringBuffer(
        "api/user/orders?"
        "cartId=$cartId"
        "&customerId=$customerId"
        "&paymentMethod=$paymentMethod"
        "&razorpayPaymentId=$razorpayPaymentId"
        "&razorpayOrderId=$razorpayOrderId"
        "&grandTotal=$grandTotal",
      );

      if (walletTypes != null && walletTypes.isNotEmpty) {
        buffer.write("&walletType=$walletTypes");
        debugPrint("🏦 [placeOrder] walletType appended: $walletTypes");
      }

      final endpoint = buffer.toString();
      debugPrint("📤 [placeOrder] Final Order Endpoint: $endpoint");

      // ✅ Send POST request
      final response = await ApiClient.post(endpoint, {}, service: 'catering');

      debugPrint("📬 [placeOrder] Response Status: ${response.statusCode}");
      debugPrint("📬 [placeOrder] Response Body: ${response.body}");

      // ✅ Handle successful response
      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final Map<String, dynamic> parsed = jsonDecode(response.body);
          debugPrint("✅ [placeOrder] Order Success → Parsed: $parsed");
          return parsed;
        } catch (e) {
          debugPrint("⚠️ [placeOrder] JSON Decode Error: $e");
          return null;
        }
      } else {
        debugPrint("❌ [placeOrder] Failed: ${response.statusCode}");
        return null;
      }
    } catch (e, stack) {
      debugPrint("💥 [placeOrder] Exception: $e");
      debugPrint("📜 [placeOrder] Stacktrace: $stack");
      return null;
    } finally {
      debugPrint("🏁 [placeOrder] Completed ----------------------------");
    }
  }

  static Future<bool> updateDateTime(
    BuildContext context,
    DateTime dateTime,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final cartId = prefs.getInt('cartId');

    if (cartId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No cart found! Please add an item first."),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    final endpoint = "api/user/$cartId/datetime";

    final body = {
      "cateringDate": DateFormat("yyyy-MM-dd").format(dateTime),
      "cateringTime": DateFormat("HH:mm:ss").format(dateTime),
    };

    try {
      debugPrint("📤 PUT → $endpoint");
      debugPrint("📦 Body → ${json.encode(body)}");

      final response = await ApiClient.put(endpoint, body, service: "catering");

      debugPrint("📡 updateDateTime Status: ${response.statusCode}");
      debugPrint("📦 updateDateTime Response: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Date and time updated successfully!"),
            backgroundColor: Colors.green,
          ),
        );
        return true;
      } else {
        // 🧩 Try to extract message from the backend response
        // String errorMessage = "Failed to update Date & Time.";
        try {
          final Map<String, dynamic> jsonBody = jsonDecode(response.body);
          if (jsonBody.containsKey("message")) {
            // errorMessage = jsonBody["message"];
          }
        } catch (_) {}
        //
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        // );

        debugPrint("❌ Failed to update DateTime → ${response.statusCode}");
        return false;
      }
    } catch (e) {
      debugPrint("⚠️ Exception in updateDateTime: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Something went wrong: $e"),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
  }

  Future<Map<String, dynamic>?> fetchOrderById([int? orderId]) async {
    final endpoint = "api/get/$orderId";
    try {
      print("📡 Fetching order with ID: $orderId");
      final response = await ApiClient.get(endpoint, service: "catering");

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        print("📦 Order Response: ${jsonEncode(decoded)}");
        return decoded as Map<String, dynamic>;
      } else {
        print("⚠️ Failed to fetch order. Status: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("❌ Error fetching order: $e");
      return null;
    }
  }

  static Future<bool> updateCartQuantity({
    required int cartId,
    required int userId,
    required int packageId,
    required int quantity,
  }) async {
    final endpoint = "api/user/updatequantity/$cartId";

    final body = {
      "userId": userId,
      "packageId": packageId,
      "quantity": quantity,
    };

    try {
      debugPrint("📤 PUT → $endpoint");
      debugPrint("📦 Body → $body");

      final response = await ApiClient.put(endpoint, body, service: "catering");

      debugPrint("📡 updateCartQuantity Status → ${response.statusCode}");
      debugPrint("📦 updateCartQuantity Response → ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint("✅ Quantity updated successfully!");
        return true;
      } else {
        final msg =
            jsonDecode(response.body)['message'] ??
            "Failed to update quantity.";
        debugPrint("❌ Failed to update quantity: $msg");
        return false;
      }
    } catch (e, st) {
      debugPrint("⚠️ Exception in updateCartQuantity: $e");
      debugPrint("📄 Stacktrace: $st");
      return false;
    }
  }

  static Future<bool> deletePackageFromCart({
    required int cartId,
    required int packageId,
  }) async {
    final endpoint = "api/user/package/$packageId/$cartId";
    debugPrint("🗑 Deleting package: $endpoint");

    try {
      final response = await ApiClient.delete(endpoint, service: "catering");

      debugPrint("📡 Response Code: ${response.statusCode}");
      debugPrint("📦 Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 204) {
        // Try to decode JSON if available
        if (response.body.isNotEmpty) {
          final data = jsonDecode(response.body);

          if (data is Map &&
              (data['status'] == 'success' || data['code'] == 200)) {
            debugPrint("✅ Package deleted successfully");
            return true;
          }
        }

        // Even if there's no body, success status is enough
        debugPrint("✅ Package deleted successfully (no response body)");
        return true;
      } else {
        debugPrint("❌ Delete failed with ${response.statusCode}");
        return false;
      }
    } catch (e) {
      debugPrint("⚠️ Error deleting package: $e");
      return false;
    }
  }

  static Future<bool> clearCart() async {
    final prefs = await SharedPreferences.getInstance();
    final customerId = prefs.getString('customerId');
    final endpoint = "api/user/clear/cart?customerId=$customerId";
    debugPrint("🗑 Clearing cart: $endpoint");

    try {
      final response = await ApiClient.delete(endpoint, service: "catering");

      debugPrint("📡 Response Code: ${response.statusCode}");
      debugPrint("📦 Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 204) {
        debugPrint("✅ Cart cleared successfully");
        return true;
      } else {
        debugPrint("❌ Failed to clear cart: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      debugPrint("⚠️ Error clearing cart: $e");
      return false;
    }
  }

  static Future<List<CateringOrder>> getAllCateringOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final customerId = prefs.getString('customerId');
    final endpoint = "api/user/getall/orders?customerId=$customerId";
    debugPrint("🗑 Clearing cart: $endpoint");
    try {
      final response = await ApiClient.get(endpoint, service: "catering");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> orderList = data is List ? data : [data];

        return orderList.map((e) => CateringOrder.fromJson(e)).toList();
      } else {
        throw Exception("Failed to fetch orders: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error in getAllCateringOrders: $e");
      rethrow;
    }
  }

  static Future<List<CateringEnquiry>> getAllEnquiries() async {
    final prefs = await SharedPreferences.getInstance();
    final customerId = prefs.getString('customerId');

    if (customerId == null) {
      debugPrint("⚠️ No userId found in SharedPreferences");
      throw Exception("User not logged in");
    }

    final endpoint = "api/user/get/enquiry?customerId=$customerId";
    debugPrint("📡 Fetching enquiries: $endpoint");

    try {
      final response = await ApiClient.get(endpoint, service: "catering");
      debugPrint("✅ Response status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint("🧩 Response body: $data");

        // Normalize to a list
        final List<dynamic> orderList = data is List ? data : [data];

        return orderList.map((e) => CateringEnquiry.fromJson(e)).toList();
      } else {
        throw Exception("Failed to fetch orders: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("❌ Error in getEnquiries: $e");
      rethrow;
    }
  }

  static Future<bool> selectQuotation(int quotationId) async {
    final endpoint = "api/user/quotation/select/$quotationId";

    try {
      final response = await ApiClient.post(
        endpoint,
        null, // ✅ NO BODY
        service: "catering",
        sendJson: false, // ✅ VERY IMPORTANT
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to accept quotation');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<AboutUsModel?> fetchAboutUsData(String vendorId) async {
    final endpoint = 'api/aboutus/$vendorId';
    try {
      // Using ApiClient for token handling + refresh
      final response = await ApiClient.get(endpoint, service: "catering");

      print("📩 About Us Response: ${response.statusCode} → ${response.body}");
      print("🔎 Fetching About Us Data for vendorId: $vendorId");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // ✅ Assuming AboutUsModel already includes image URLs and text fields
        return AboutUsModel.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        print(
          "❌ Failed to load About Us: ${error['message'] ?? response.body}",
        );
        return null;
      }
    } catch (e) {
      print("⚠️ Exception while fetching About Us: $e");
      return null;
    }
  }

  static Future<String?> createOrder(double amount) async {
    try {
      String endpoint = "api/payments/create-order/user";

      final body = {
        "amount": amount,
        "currency": "INR",
        "receipt": "receipt#${DateTime.now().millisecondsSinceEpoch}",
        "notes": {"key1": "value3", "key2": "value2"},
      };

      final res = await ApiClient.post(endpoint, body, service: "catering");

      debugPrint("📤 CreateOrder Response: ${res.statusCode} ${res.body}");

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data["orderId"] ?? data["id"]; // ensure correct key
      }

      debugPrint("❌ Order creation failed: ${res.body}");
      return null;
    } catch (e) {
      debugPrint("⚠️ Exception in createOrder: $e");
      return null;
    }
  }

  // 2️⃣ CAPTURE PAYMENT
  static Future<bool> capturePayment({
    required String paymentId,
    required double amount,
  }) async {
    try {
      String endpoint = "api/payments/capture";

      final body = {
        "paymentId": paymentId,
        "amount": amount,
        "currency": "INR",
        "receipt":
            "order#${DateTime.now().millisecondsSinceEpoch} for wallet top-up",
      };

      final res = await ApiClient.post(endpoint, body, service: "catering");
      debugPrint("💰 Capture Payment Response: ${res.statusCode} ${res.body}");

      return res.statusCode == 200;
    } catch (e) {
      debugPrint("❌ Capture API Exception: $e");
      return false;
    }
  }

  static Future<bool> submitUserFeedback({
    required int orderId,
    required String feedback,
    required int rating,
  }) async {
    // ✅ Corrected endpoint with orderId and query params
    final encodedFeedback = Uri.encodeComponent(feedback);
    final endpoint =
        "api/user/feedback/$orderId?feedback=$encodedFeedback&rating=$rating";

    try {
      debugPrint("📤 PUT → $endpoint");

      final response = await ApiClient.put(
        endpoint,
        {}, // no body required, handled by query params
        service: "catering",
      );

      debugPrint("📡 submitUserFeedback Status → ${response.statusCode}");
      debugPrint("📦 submitUserFeedback Response → ${response.body}");

      // ✅ Handle success
      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint("✅ Feedback submitted successfully!");
        return true;
      }

      // ✅ Handle failure and non-JSON response gracefully
      try {
        final decoded = jsonDecode(response.body);
        final msg = decoded['message'] ?? "Failed to submit feedback.";
        debugPrint("❌ Failed to submit feedback: $msg");
      } catch (_) {
        debugPrint("❌ Non-JSON error: ${response.body}");
      }

      return false;
    } catch (e, st) {
      debugPrint("⚠️ Exception in submitUserFeedback: $e");
      debugPrint("📄 Stacktrace: $st");
      return false;
    }
  }

  static Future<List<Package>> fetchTopRatedPackages() async {
    const endpoint = "api/packages/toprated";
    try {
      debugPrint("📡 GET → $endpoint");

      final response = await ApiClient.get(endpoint, service: "catering");
      debugPrint("📥 Response: ${response.statusCode}");

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        // 🔹 Convert each JSON map to a Package model
        final packages = data.map((e) => Package.fromJson(e)).toList();

        debugPrint("✅ Packages fetched: ${packages.length}");
        return packages;
      } else {
        debugPrint("❌ Failed to fetch packages: ${response.body}");
        return [];
      }
    } catch (e, st) {
      debugPrint("⚠️ Exception in fetchTopRatedPackages: $e");
      debugPrint("📄 Stacktrace: $st");
      return [];
    }
  }

  static Future<bool> updateCartAddress({
    required int cartId,
    required int addressId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    final endpoint = "api/user/$userId/cart/$cartId/address/$addressId";

    try {
      debugPrint("📤 PUT → $endpoint");

      final response = await ApiClient.put(
        endpoint,
        {}, // No body needed for this request
        service: "catering",
      );

      debugPrint("📡 updateCartAddress Status → ${response.statusCode}");
      debugPrint("📦 updateCartAddress Response → ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint("✅ Address updated successfully!");
        return true;
      } else {
        final msg =
            jsonDecode(response.body)['message'] ?? "Failed to update address.";
        debugPrint("❌ Failed to update address: $msg");
        return false;
      }
    } catch (e, st) {
      debugPrint("⚠️ Exception in updateCartAddress: $e");
      debugPrint("📄 Stacktrace: $st");
      return false;
    }
  }

  static Future<int> fetchCartCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final customerId = prefs.getInt('customerId');

      if (customerId == null) return 0;

      final response = await ApiClient.get(
        "api/user/count/cartitems?customerId=$customerId",
        service: "catering", // or "Mamaswebsite" depending on your setup
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint("🛒 Cart count → $data");
        return data is int ? data : int.tryParse(data.toString()) ?? 0;
      } else {
        debugPrint("❌ Failed to fetch cart count → ${response.statusCode}");
        return 0;
      }
    } catch (e) {
      debugPrint("💥 Error fetching cart count: $e");
      return 0;
    }
  }

  static Future<List<VendorQuotation>> loadQuotations({
    required String leadId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final customerId = prefs.getString('customerId');


    if (customerId == null) {
      throw Exception("User ID not found");
    }


    final endpoint = 'api/user/lead/quotations/$leadId/?customerId=$customerId';


    final response = await ApiClient.get(endpoint, service: 'catering');


    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final result = VendorQuotationResponse.fromJson(jsonData);
      return result.data;
    } else {
      throw Exception("Server error: ${response.statusCode}");
    }
  }



}
