// // import 'dart:convert';
// // import 'package:flutter/cupertino.dart';
// // import 'package:flutter_riverpod/flutter_riverpod.dart';
// // import 'package:geocoding/geocoding.dart';
// // import 'package:geolocator/geolocator.dart';
// // import 'package:shared_preferences/shared_preferences.dart';
// // import 'package:http/http.dart' as http;
// //
// // import '../../Api/APIclient.dart';
// // import '../API/Apiclient.dart';
// //
// // const String baseurl = "http://staging.maamaas.com:8080/subscription";
// //
// // class AddressState {
// //   final String city;
// //   final String stateName; // `state` is reserved
// //   final String pincode;
// //   final double latitude;
// //   final double longitude;
// //   final String fullAddress;
// //
// //   const AddressState({
// //     this.city = '',
// //     this.stateName = '',
// //     this.pincode = '',
// //     this.latitude = 0,
// //     this.longitude = 0,
// //     this.fullAddress = '',
// //   });
// //
// //   AddressState copyWith({
// //     String? city,
// //     String? stateName,
// //     String? pincode,
// //     double? latitude,
// //     double? longitude,
// //     String? fullAddress,
// //   }) {
// //     return AddressState(
// //       city: city ?? this.city,
// //       stateName: stateName ?? this.stateName,
// //       pincode: pincode ?? this.pincode,
// //       latitude: latitude ?? this.latitude,
// //       longitude: longitude ?? this.longitude,
// //       fullAddress: fullAddress ?? this.fullAddress,
// //     );
// //   }
// //
// //   Map<String, dynamic> toJson() => {
// //     "city": city,
// //     "state": stateName,
// //     "pincode": pincode,
// //     "latitude": latitude,
// //     "longitude": longitude,
// //     "address": fullAddress,
// //   };
// // }
// //
// // // -----------------------------
// // // Address Notifier
// // // -----------------------------
// // class AddressNotifier extends StateNotifier<AddressState> {
// //   AddressNotifier() : super(const AddressState());
// //
// //   // -----------------------------
// //   // Update local state manually
// //   // -----------------------------
// //   Future<void> updateLocalAddress({
// //     required String city,
// //     required String stateName,
// //     required String pincode,
// //     required double latitude,
// //     required double longitude,
// //     String? fullAddress,
// //   }) async {
// //     final address = fullAddress ?? "$city, $stateName - $pincode";
// //     state = AddressState(
// //       city: city,
// //       stateName: stateName,
// //       pincode: pincode,
// //       latitude: latitude,
// //       longitude: longitude,
// //       fullAddress: address,
// //     );
// //   }
// //
// //   // -----------------------------
// //   // Update state from a Position object
// //   // -----------------------------
// //   Future<bool> updateLocationFromPosition(Position pos) async {
// //     try {
// //       String city = '';
// //       String stateName = '';
// //       String pincode = '';
// //       String fullAddress = "${pos.latitude}, ${pos.longitude}";
// //
// //       try {
// //         List<Placemark> placemarks = await placemarkFromCoordinates(
// //           pos.latitude,
// //           pos.longitude,
// //         );
// //
// //         if (placemarks.isNotEmpty) {
// //           final place = placemarks.first;
// //
// //           city = place.locality ?? '';
// //           stateName = place.administrativeArea ?? '';
// //           pincode = place.postalCode ?? '';
// //
// //           final subLocality = place.subLocality ?? '';
// //           final name = place.name ?? '';
// //           fullAddress = [
// //             name,
// //             subLocality,
// //             city,
// //             stateName,
// //             pincode,
// //           ].where((e) => e.isNotEmpty).join(', ');
// //         }
// //       } catch (_) {
// //         // ignore reverse geocoding errors, fallback to coordinates
// //       }
// //
// //       // Update Riverpod state
// //       state = state.copyWith(
// //         city: city,
// //         stateName: stateName,
// //         pincode: pincode,
// //         latitude: pos.latitude,
// //         longitude: pos.longitude,
// //         fullAddress: fullAddress,
// //       );
// //
// //       // Send to backend
// //       return await sendCurrentLocationToBackend();
// //     } catch (e) {
// //       // print("⚠️ updateLocationFromPosition failed: $e");
// //       return false;
// //     }
// //   }
// //
// //   // -----------------------------
// //   // Send current location to backend
// //   // -----------------------------
// //   Future<bool> sendCurrentLocationToBackend() async {
// //     debugPrint("══════════════════════════════════════");
// //     debugPrint("🚀 START sendCurrentLocationToBackend");
// //
// //     try {
// //       // 1️⃣ Get SharedPreferences
// //       debugPrint("🔍 Getting SharedPreferences...");
// //       final prefs = await SharedPreferences.getInstance();
// //       debugPrint("✅ SharedPreferences Loaded");
// //
// //       // 2️⃣ Get customerId
// //       final customerId = prefs.getString('customerId');
// //       debugPrint("🔐 customerId from storage → $customerId");
// //
// //       if (customerId == null || customerId.isEmpty) {
// //         debugPrint("❌ ERROR: customerId is NULL or EMPTY");
// //         debugPrint("══════════════════════════════════════");
// //         return false;
// //       }
// //
// //       // 3️⃣ Check location values
// //       debugPrint("📍 Latitude → ${state.latitude}");
// //       debugPrint("📍 Longitude → ${state.longitude}");
// //       debugPrint("🏠 Address → ${state.fullAddress}");
// //
// //       if (state.latitude == null || state.longitude == null) {
// //         debugPrint("❌ ERROR: Latitude or Longitude is NULL");
// //         debugPrint("══════════════════════════════════════");
// //         return false;
// //       }
// //
// //       // 4️⃣ Prepare request body
// //       final body = {
// //         "customerId": customerId,
// //         "latitude": state.latitude,
// //         "longitude": state.longitude,
// //         "address": state.fullAddress ?? "",
// //       };
// //
// //       debugPrint("📦 Request Body JSON → ${jsonEncode(body)}");
// //
// //       // 5️⃣ Backend URL (Your Exact API)
// //       final uri = Uri.parse("$baseurl/api/user/curret/location/update");
// //
// //       debugPrint("🌐 POST URL → $uri");
// //
// //       // 6️⃣ Send POST request
// //       final response = await http.post(
// //         uri,
// //         headers: {"Content-Type": "application/json"},
// //         body: jsonEncode(body),
// //       );
// //
// //       // 7️⃣ Print full response details
// //       debugPrint("📬 RESPONSE RECEIVED");
// //       debugPrint("📬 Status Code → ${response.statusCode}");
// //       debugPrint("📬 Response Headers → ${response.headers}");
// //       debugPrint("📬 Response Body → ${response.body}");
// //
// //       // 8️⃣ Check result
// //       if (response.statusCode >= 200 && response.statusCode < 300) {
// //         debugPrint("✅ SUCCESS: Location Posted Successfully");
// //         debugPrint("══════════════════════════════════════");
// //         return true;
// //       } else {
// //         debugPrint("❌ FAILED: Server Returned Error");
// //         debugPrint("══════════════════════════════════════");
// //         return false;
// //       }
// //     } catch (e, stack) {
// //       debugPrint("🔥 EXCEPTION OCCURRED");
// //       debugPrint("❗ Error → $e");
// //       debugPrint("🧵 StackTrace → $stack");
// //       debugPrint("══════════════════════════════════════");
// //       return false;
// //     }
// //   }
// //
// //   // -----------------------------
// //   // Send address to cart
// //   // -----------------------------
// //   // Update cart delivery address API
// //   static Future<bool> updateDeliveryAddress({
// //     required int cartId,
// //     required int addressId,
// //   }) async {
// //     try {
// //       final body = {"addressId": addressId, "cartId": cartId};
// //       final endpoint = "api/cart/delivery/$cartId/address/$addressId";
// //
// //       debugPrint("🔹 [UpdateDeliveryAddress] Sending request to: $endpoint");
// //       debugPrint(
// //         "🔹 [UpdateDeliveryAddress] Request body: ${jsonEncode(body)}",
// //       );
// //
// //       final response = await ApiClient.put(endpoint, body, service: "food");
// //
// //       debugPrint(
// //         "🔹 [UpdateDeliveryAddress] Status code: ${response.statusCode}",
// //       );
// //       debugPrint("🔹 [UpdateDeliveryAddress] Response body: ${response.body}");
// //
// //       return response.statusCode == 200;
// //     } catch (e, st) {
// //       debugPrint("❌ [UpdateDeliveryAddress] Error: $e");
// //       debugPrint("❌ [UpdateDeliveryAddress] StackTrace: $st");
// //       return false;
// //     }
// //   }
// //
// //   static Future<bool> updatecateringDeliveryAddress({
// //     required int cartId,
// //     required int addressId,
// //   }) async {
// //     try {
// //       final body = {"addressId": addressId, "cartId": cartId};
// //       final endpoint = "api/user/delivery/$cartId/address/$addressId";
// //
// //       debugPrint("🔹 [UpdateDeliveryAddress] Sending request to: $endpoint");
// //       debugPrint(
// //         "🔹 [UpdateDeliveryAddress] Request body: ${jsonEncode(body)}",
// //       );
// //
// //       final response = await ApiClient.put(endpoint, body, service: "catering");
// //       debugPrint("response body : ${response.body}");
// //
// //       debugPrint(
// //         "🔹 [UpdateDeliveryAddress] Status code: ${response.statusCode}",
// //       );
// //       debugPrint("🔹 [UpdateDeliveryAddress] Response body: ${response.body}");
// //
// //       return response.statusCode == 200;
// //     } catch (e, st) {
// //       debugPrint("❌ [UpdateDeliveryAddress] Error: $e");
// //       debugPrint("❌ [UpdateDeliveryAddress] StackTrace: $st");
// //       return false;
// //     }
// //   }
// // }
// //
// // // -----------------------------
// // // Global provider
// // // -----------------------------
// // final addressProvider = StateNotifierProvider<AddressNotifier, AddressState>((
// //   ref,
// // ) {
// //   return AddressNotifier();
// // });
// import 'dart:convert';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
//
// import '../../Api/APIclient.dart';
// import '../API/Apiclient.dart';
//
// const String baseurl = "http://staging.maamaas.com:8080/subscription";
//
// class AddressState {
//   final String city;
//   final String stateName; // `state` is reserved
//   final String pincode;
//   final double latitude;
//   final double longitude;
//   final String fullAddress;
//
//   const AddressState({
//     this.city = '',
//     this.stateName = '',
//     this.pincode = '',
//     this.latitude = 0,
//     this.longitude = 0,
//     this.fullAddress = '',
//   });
//
//   AddressState copyWith({
//     String? city,
//     String? stateName,
//     String? pincode,
//     double? latitude,
//     double? longitude,
//     String? fullAddress,
//   }) {
//     return AddressState(
//       city: city ?? this.city,
//       stateName: stateName ?? this.stateName,
//       pincode: pincode ?? this.pincode,
//       latitude: latitude ?? this.latitude,
//       longitude: longitude ?? this.longitude,
//       fullAddress: fullAddress ?? this.fullAddress,
//     );
//   }
//
//   Map<String, dynamic> toJson() => {
//     "city": city,
//     "state": stateName,
//     "pincode": pincode,
//     "latitude": latitude,
//     "longitude": longitude,
//     "address": fullAddress,
//   };
// }
//
// // -----------------------------
// // Address Notifier
// // -----------------------------
// class AddressNotifier extends StateNotifier<AddressState> {
//   AddressNotifier() : super(const AddressState());
//
//   // -----------------------------
//   // Update local state manually
//   // -----------------------------
//   Future<void> updateLocalAddress({
//     required String city,
//     required String stateName,
//     required String pincode,
//     required double latitude,
//     required double longitude,
//     String? fullAddress,
//   }) async {
//     final address = fullAddress ?? "$city, $stateName - $pincode";
//     state = AddressState(
//       city: city,
//       stateName: stateName,
//       pincode: pincode,
//       latitude: latitude,
//       longitude: longitude,
//       fullAddress: address,
//     );
//
//     debugPrint("✅ Local address updated - City: $city, State: $stateName, Pincode: $pincode");
//   }
//
//   // -----------------------------
//   // Update state from a Position object
//   // -----------------------------
//   Future<bool> updateLocationFromPosition(Position pos) async {
//     try {
//       String city = '';
//       String stateName = '';
//       String pincode = '';
//       String fullAddress = "${pos.latitude}, ${pos.longitude}";
//
//       try {
//         List<Placemark> placemarks = await placemarkFromCoordinates(
//           pos.latitude,
//           pos.longitude,
//         );
//
//         if (placemarks.isNotEmpty) {
//           final place = placemarks.first;
//
//           // FIXED: Enhanced city extraction with multiple fallbacks
//           city = place.locality ??
//               place.subAdministrativeArea ??
//               place.administrativeArea ??
//               place.subLocality ??
//               '';
//
//           // If city is still empty, try to extract from thoroughfare or name
//           if (city.isEmpty) {
//             city = place.thoroughfare ?? place.name ?? '';
//           }
//
//           stateName = place.administrativeArea ?? '';
//           pincode = place.postalCode ?? '';
//
//           final subLocality = place.subLocality ?? '';
//           final name = place.name ?? '';
//           final street = place.street ?? '';
//
//           fullAddress = [
//             name,
//             street,
//             subLocality,
//             city,
//             stateName,
//             pincode,
//           ].where((e) => e.isNotEmpty).join(', ');
//
//           debugPrint("📍 Reverse geocoded - City: $city, State: $stateName, Pincode: $pincode");
//         }
//       } catch (e) {
//         debugPrint("⚠️ Reverse geocoding error: $e");
//         // ignore reverse geocoding errors, fallback to coordinates
//       }
//
//       // Update Riverpod state
//       state = state.copyWith(
//         city: city,
//         stateName: stateName,
//         pincode: pincode,
//         latitude: pos.latitude,
//         longitude: pos.longitude,
//         fullAddress: fullAddress,
//       );
//
//       // Send to backend
//       return await sendCurrentLocationToBackend();
//     } catch (e) {
//       debugPrint("⚠️ updateLocationFromPosition failed: $e");
//       return false;
//     }
//   }
//
//   // -----------------------------
//   // Send current location to backend
//   // -----------------------------
//   Future<bool> sendCurrentLocationToBackend() async {
//     debugPrint("══════════════════════════════════════");
//     debugPrint("🚀 START sendCurrentLocationToBackend");
//
//     try {
//       // 1️⃣ Get SharedPreferences
//       debugPrint("🔍 Getting SharedPreferences...");
//       final prefs = await SharedPreferences.getInstance();
//       debugPrint("✅ SharedPreferences Loaded");
//
//       // 2️⃣ Get customerId
//       final customerId = prefs.getString('customerId');
//       debugPrint("🔐 customerId from storage → $customerId");
//
//       if (customerId == null || customerId.isEmpty) {
//         debugPrint("❌ ERROR: customerId is NULL or EMPTY");
//         debugPrint("══════════════════════════════════════");
//         return false;
//       }
//
//       // 3️⃣ Check location values
//       debugPrint("📍 Latitude → ${state.latitude}");
//       debugPrint("📍 Longitude → ${state.longitude}");
//       debugPrint("🏠 Address → ${state.fullAddress}");
//       debugPrint("🏙️ City → ${state.city}");
//       debugPrint("📌 State → ${state.stateName}");
//       debugPrint("📮 Pincode → ${state.pincode}");
//
//       if (state.latitude == 0 || state.longitude == 0) {
//         debugPrint("❌ ERROR: Latitude or Longitude is 0");
//         debugPrint("══════════════════════════════════════");
//         return false;
//       }
//
//       // 4️⃣ Prepare request body - FIXED: Added city field
//       final body = {
//         "customerId": customerId,
//         "latitude": state.latitude,
//         "longitude": state.longitude,
//         "address": state.fullAddress ?? "",
//         "city": state.city.isNotEmpty ? state.city : _extractCityFromAddress(state.fullAddress),
//       };
//
//       debugPrint("📦 Request Body JSON → ${jsonEncode(body)}");
//
//       // 5️⃣ Backend URL
//       final uri = Uri.parse("$baseurl/api/user/curret/location/update");
//       debugPrint("🌐 POST URL → $uri");
//
//       // 6️⃣ Send POST request
//       final response = await http.post(
//         uri,
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode(body),
//       );
//
//       // 7️⃣ Print full response details
//       debugPrint("📬 RESPONSE RECEIVED");
//       debugPrint("📬 Status Code → ${response.statusCode}");
//       debugPrint("📬 Response Body → ${response.body}");
//
//       // 8️⃣ Check result
//       if (response.statusCode >= 200 && response.statusCode < 300) {
//         debugPrint("✅ SUCCESS: Location Posted Successfully");
//         debugPrint("══════════════════════════════════════");
//         return true;
//       } else {
//         debugPrint("❌ FAILED: Server Returned Error");
//         debugPrint("══════════════════════════════════════");
//         return false;
//       }
//     } catch (e, stack) {
//       debugPrint("🔥 EXCEPTION OCCURRED");
//       debugPrint("❗ Error → $e");
//       debugPrint("🧵 StackTrace → $stack");
//       debugPrint("══════════════════════════════════════");
//       return false;
//     }
//   }
//
//   // Helper method to extract city from address if needed
//   String _extractCityFromAddress(String? address) {
//     if (address == null || address.isEmpty) return '';
//
//     // Try to extract city from address string
//     // Common patterns: "Area, City, State - Pincode" or "Area, City"
//     final parts = address.split(',');
//     if (parts.length >= 2) {
//       // Usually the second last part might be city
//       // Clean up the string
//       String possibleCity = parts[parts.length - 2].trim();
//       // Remove any pincode or extra spaces
//       possibleCity = possibleCity.replaceAll(RegExp(r'[-]\s*\d+'), '').trim();
//       return possibleCity;
//     }
//     return '';
//   }
//
//   // -----------------------------
//   // Send address to cart
//   // -----------------------------
//   // Update cart delivery address API
//   static Future<bool> updateDeliveryAddress({
//     required int cartId,
//     required int addressId,
//   }) async {
//     try {
//       final body = {"addressId": addressId, "cartId": cartId};
//       final endpoint = "api/cart/delivery/$cartId/address/$addressId";
//
//       debugPrint("🔹 [UpdateDeliveryAddress] Sending request to: $endpoint");
//       debugPrint(
//         "🔹 [UpdateDeliveryAddress] Request body: ${jsonEncode(body)}",
//       );
//
//       final response = await ApiClient.put(endpoint, body, service: "food");
//
//       debugPrint(
//         "🔹 [UpdateDeliveryAddress] Status code: ${response.statusCode}",
//       );
//       debugPrint("🔹 [UpdateDeliveryAddress] Response body: ${response.body}");
//
//       return response.statusCode == 200;
//     } catch (e, st) {
//       debugPrint("❌ [UpdateDeliveryAddress] Error: $e");
//       debugPrint("❌ [UpdateDeliveryAddress] StackTrace: $st");
//       return false;
//     }
//   }
//
//   static Future<bool> updatecateringDeliveryAddress({
//     required int cartId,
//     required int addressId,
//   }) async {
//     try {
//       final body = {"addressId": addressId, "cartId": cartId};
//       final endpoint = "api/user/delivery/$cartId/address/$addressId";
//
//       debugPrint("🔹 [UpdateDeliveryAddress] Sending request to: $endpoint");
//       debugPrint(
//         "🔹 [UpdateDeliveryAddress] Request body: ${jsonEncode(body)}",
//       );
//
//       final response = await ApiClient.put(endpoint, body, service: "catering");
//       debugPrint("response body : ${response.body}");
//
//       debugPrint(
//         "🔹 [UpdateDeliveryAddress] Status code: ${response.statusCode}",
//       );
//       debugPrint("🔹 [UpdateDeliveryAddress] Response body: ${response.body}");
//
//       return response.statusCode == 200;
//     } catch (e, st) {
//       debugPrint("❌ [UpdateDeliveryAddress] Error: $e");
//       debugPrint("❌ [UpdateDeliveryAddress] StackTrace: $st");
//       return false;
//     }
//   }
// }
//
// // -----------------------------
// // Global provider
// // -----------------------------
// final addressProvider = StateNotifierProvider<AddressNotifier, AddressState>((
//     ref,
//     ) {
//   return AddressNotifier();
// });

import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../Api/APIclient.dart';
import '../API/Apiclient.dart';

const String baseurl = "http://staging.maamaas.com:8080/subscription";

class AddressState {
  final String city;
  final String stateName; // `state` is reserved
  final String pincode;
  final double latitude;
  final double longitude;
  final String fullAddress;

  const AddressState({
    this.city = '',
    this.stateName = '',
    this.pincode = '',
    this.latitude = 0,
    this.longitude = 0,
    this.fullAddress = '',
  });

  AddressState copyWith({
    String? city,
    String? stateName,
    String? pincode,
    double? latitude,
    double? longitude,
    String? fullAddress,
  }) {
    return AddressState(
      city: city ?? this.city,
      stateName: stateName ?? this.stateName,
      pincode: pincode ?? this.pincode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      fullAddress: fullAddress ?? this.fullAddress,
    );
  }

  Map<String, dynamic> toJson() => {
    "city": city,
    "state": stateName,
    "pincode": pincode,
    "latitude": latitude,
    "longitude": longitude,
    "address": fullAddress,
  };
}

// -----------------------------
// Address Notifier
// -----------------------------
class AddressNotifier extends StateNotifier<AddressState> {
  AddressNotifier() : super(const AddressState());

  // -----------------------------
  // Update local state manually
  // -----------------------------
  Future<void> updateLocalAddress({
    required String city,
    required String stateName,
    required String pincode,
    required double latitude,
    required double longitude,
    String? fullAddress,
  }) async {
    final address = fullAddress ?? "$city, $stateName - $pincode";
    state = AddressState(
      city: city,
      stateName: stateName,
      pincode: pincode,
      latitude: latitude,
      longitude: longitude,
      fullAddress: address,
    );

    debugPrint("✅ Local address updated - City: $city, State: $stateName, Pincode: $pincode");
  }

  // -----------------------------
  // Update state from a Position object
  // -----------------------------
  Future<bool> updateLocationFromPosition(Position pos) async {
    try {
      String city = '';
      String stateName = '';
      String pincode = '';
      String fullAddress = "${pos.latitude}, ${pos.longitude}";

      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          pos.latitude,
          pos.longitude,
        );

        if (placemarks.isNotEmpty) {
          final place = placemarks.first;

          // Enhanced city extraction with multiple fallbacks
          city = place.locality ??
              place.subAdministrativeArea ??
              place.administrativeArea ??
              place.subLocality ??
              '';

          // If city is still empty, try to extract from thoroughfare or name
          if (city.isEmpty) {
            city = place.thoroughfare ?? place.name ?? '';
          }

          stateName = place.administrativeArea ?? '';
          pincode = place.postalCode ?? '';

          final subLocality = place.subLocality ?? '';
          final name = place.name ?? '';
          final street = place.street ?? '';

          fullAddress = [
            name,
            street,
            subLocality,
            city,
            stateName,
            pincode,
          ].where((e) => e.isNotEmpty).join(', ');

          debugPrint("📍 Reverse geocoded - City: $city, State: $stateName, Pincode: $pincode");
        }
      } catch (e) {
        debugPrint("⚠️ Reverse geocoding error: $e");
        // ignore reverse geocoding errors, fallback to coordinates
      }

      // Update Riverpod state
      state = state.copyWith(
        city: city,
        stateName: stateName,
        pincode: pincode,
        latitude: pos.latitude,
        longitude: pos.longitude,
        fullAddress: fullAddress,
      );

      // Send to backend
      return await sendCurrentLocationToBackend();
    } catch (e) {
      debugPrint("⚠️ updateLocationFromPosition failed: $e");
      return false;
    }
  }

  // Helper method to extract city from address if needed
  String _extractCityFromAddress(String? address) {
    if (address == null || address.isEmpty) return '';

    // Try to extract city from address string
    // Common patterns: "Area, City, State - Pincode" or "Area, City"
    final parts = address.split(',');
    if (parts.length >= 2) {
      // Usually the second last part might be city
      // Clean up the string
      String possibleCity = parts[parts.length - 2].trim();
      // Remove any pincode or extra spaces
      possibleCity = possibleCity.replaceAll(RegExp(r'[-]\s*\d+'), '').trim();
      return possibleCity;
    }
    return '';
  }

  // Helper method to get auth token
  Future<String?> _getAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Try different possible token keys
      List<String> possibleKeys = [
        'authToken',
        'token',
        'accessToken',
        'jwt_token',
        'user_token'
      ];

      for (String key in possibleKeys) {
        String? token = prefs.getString(key);
        if (token != null && token.isNotEmpty) {
          debugPrint("✅ Found token with key: $key");
          return token;
        }
      }

      debugPrint("❌ No authentication token found in SharedPreferences");
      return null;
    } catch (e) {
      debugPrint("❌ Error getting auth token: $e");
      return null;
    }
  }

  // -----------------------------
  // Send current location to backend
  // -----------------------------
  Future<bool> sendCurrentLocationToBackend() async {
    debugPrint("══════════════════════════════════════");
    debugPrint("🚀 START sendCurrentLocationToBackend");

    try {
      // 1️⃣ Get SharedPreferences
      debugPrint("🔍 Getting SharedPreferences...");
      final prefs = await SharedPreferences.getInstance();
      debugPrint("✅ SharedPreferences Loaded");

      // 2️⃣ Get customerId
      final customerId = prefs.getString('customerId');
      debugPrint("🔐 customerId from storage → $customerId");

      if (customerId == null || customerId.isEmpty) {
        debugPrint("❌ ERROR: customerId is NULL or EMPTY");
        debugPrint("══════════════════════════════════════");
        return false;
      }

      // 3️⃣ Get authentication token - FIXED: Added this!
      final token = await _getAuthToken();
      if (token == null) {
        debugPrint("❌ ERROR: No authentication token found");
        debugPrint("⚠️ User needs to login again");
        debugPrint("══════════════════════════════════════");
        return false;
      }
      debugPrint("🔑 Auth Token found (length: ${token.length})");

      // 4️⃣ Check location values
      debugPrint("📍 Latitude → ${state.latitude}");
      debugPrint("📍 Longitude → ${state.longitude}");
      debugPrint("🏠 Address → ${state.fullAddress}");
      debugPrint("🏙️ City → ${state.city}");
      debugPrint("📌 State → ${state.stateName}");
      debugPrint("📮 Pincode → ${state.pincode}");

      if (state.latitude == 0 || state.longitude == 0) {
        debugPrint("❌ ERROR: Latitude or Longitude is 0");
        debugPrint("══════════════════════════════════════");
        return false;
      }

      // 5️⃣ Prepare request body
      final body = {
        "customerId": customerId,
        "latitude": state.latitude,
        "longitude": state.longitude,
        "address": state.fullAddress ?? "",
        "city": state.city.isNotEmpty ? state.city : _extractCityFromAddress(state.fullAddress),
      };

      debugPrint("📦 Request Body JSON → ${jsonEncode(body)}");

      // 6️⃣ Backend URL
      final uri = Uri.parse("$baseurl/api/user/curret/location/update");
      debugPrint("🌐 POST URL → $uri");

      // 7️⃣ Send POST request WITH AUTH HEADER - FIXED: Added Authorization header!
      debugPrint("🔐 Sending request with Bearer token...");
      final response = await http.post(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",  // CRITICAL FIX: Added this line!
        },
        body: jsonEncode(body),
      );

      // 8️⃣ Print full response details
      debugPrint("📬 RESPONSE RECEIVED");
      debugPrint("📬 Status Code → ${response.statusCode}");
      debugPrint("📬 Response Body → ${response.body}");

      // 9️⃣ Check result
      if (response.statusCode >= 200 && response.statusCode < 300) {
        debugPrint("✅ SUCCESS: Location Posted Successfully");
        debugPrint("══════════════════════════════════════");
        return true;
      }
      else if (response.statusCode == 401 || response.statusCode == 403) {
        debugPrint("❌ AUTHENTICATION ERROR: Token may be expired or invalid");
        debugPrint("⚠️ User needs to login again");
        debugPrint("══════════════════════════════════════");
        return false;
      }
      else {
        debugPrint("❌ FAILED: Server Returned Error");
        debugPrint("══════════════════════════════════════");
        return false;
      }
    } catch (e, stack) {
      debugPrint("🔥 EXCEPTION OCCURRED");
      debugPrint("❗ Error → $e");
      debugPrint("🧵 StackTrace → $stack");
      debugPrint("══════════════════════════════════════");
      return false;
    }
  }

  // -----------------------------
  // Send address to cart
  // -----------------------------
  // Update cart delivery address API
  static Future<bool> updateDeliveryAddress({
    required int cartId,
    required int addressId,
  }) async {
    try {
      final body = {"addressId": addressId, "cartId": cartId};
      final endpoint = "api/cart/delivery/$cartId/address/$addressId";

      debugPrint("🔹 [UpdateDeliveryAddress] Sending request to: $endpoint");
      debugPrint(
        "🔹 [UpdateDeliveryAddress] Request body: ${jsonEncode(body)}",
      );

      final response = await ApiClient.put(endpoint, body, service: "food");

      debugPrint(
        "🔹 [UpdateDeliveryAddress] Status code: ${response.statusCode}",
      );
      debugPrint("🔹 [UpdateDeliveryAddress] Response body: ${response.body}");

      return response.statusCode == 200;
    } catch (e, st) {
      debugPrint("❌ [UpdateDeliveryAddress] Error: $e");
      debugPrint("❌ [UpdateDeliveryAddress] StackTrace: $st");
      return false;
    }
  }

  static Future<bool> updatecateringDeliveryAddress({
    required int cartId,
    required int addressId,
  }) async {
    try {
      final body = {"addressId": addressId, "cartId": cartId};
      final endpoint = "api/user/delivery/$cartId/address/$addressId";

      debugPrint("🔹 [UpdateDeliveryAddress] Sending request to: $endpoint");
      debugPrint(
        "🔹 [UpdateDeliveryAddress] Request body: ${jsonEncode(body)}",
      );

      final response = await ApiClient.put(endpoint, body, service: "catering");
      debugPrint("response body : ${response.body}");

      debugPrint(
        "🔹 [UpdateDeliveryAddress] Status code: ${response.statusCode}",
      );
      debugPrint("🔹 [UpdateDeliveryAddress] Response body: ${response.body}");

      return response.statusCode == 200;
    } catch (e, st) {
      debugPrint("❌ [UpdateDeliveryAddress] Error: $e");
      debugPrint("❌ [UpdateDeliveryAddress] StackTrace: $st");
      return false;
    }
  }
}

// -----------------------------
// Global provider
// -----------------------------
final addressProvider = StateNotifierProvider<AddressNotifier, AddressState>((
    ref,
    ) {
  return AddressNotifier();
});