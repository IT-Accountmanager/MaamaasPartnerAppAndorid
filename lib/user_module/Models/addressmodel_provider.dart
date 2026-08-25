// import 'dart:convert';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
//
// // -----------------------------
// // Address State
// // -----------------------------
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
//         List<Placemark> placemarks =
//         await placemarkFromCoordinates(pos.latitude, pos.longitude);
//
//         if (placemarks.isNotEmpty) {
//           final place = placemarks.first;
//
//           city = place.locality ?? '';
//           stateName = place.administrativeArea ?? '';
//           pincode = place.postalCode ?? '';
//
//           final subLocality = place.subLocality ?? '';
//           final name = place.name ?? '';
//           fullAddress =
//               [name, subLocality, city, stateName, pincode].where((e) => e.isNotEmpty).join(', ');
//         }
//       } catch (_) {
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
//       print("⚠️ updateLocationFromPosition failed: $e");
//       return false;
//     }
//   }
//
//   // -----------------------------
//   // Send current location to backend
//   // -----------------------------
//   Future<bool> sendCurrentLocationToBackend() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final userId = prefs.getInt('userId') ?? 0;
//
//       final body = {
//         "userId": userId,
//         "latitude": state.latitude,
//         "longitude": state.longitude,
//         "address": state.fullAddress,
//       };
//
//       final uri = Uri.parse(
//           "http://10.10.20.9:6363/subscription-0.0.1-SNAPSHOT/api/user/curret/location/update");
//
//       print("📡 Sending location to backend...");
//       print("📄 Body: ${jsonEncode(body)}");
//
//       final resp = await http.post(
//         uri,
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode(body),
//       );
//
//       print("✅ Status code: ${resp.statusCode}");
//       print("📝 Response body: ${resp.body}");
//
//       // Return success
//       return resp.statusCode >= 200 && resp.statusCode < 300;
//     } catch (e) {
//       print("⚠️ sendCurrentLocationToBackend failed: $e");
//       return false;
//     }
//   }
//
//   // -----------------------------
//   // Send address to cart
//   // -----------------------------
//   Future<bool> sendAddressToCart({
//     required int userId,
//     required int cartId,
//     required int addressId, // 0 for create
//     bool usePut = true, // PUT or POST
//   }) async {
//     try {
//       final body = {
//         "addressId": addressId,
//         "doorNumber": "",
//         "addressLine": state.fullAddress,
//         "landMark": "",
//         "city": state.city,
//         "state": state.stateName,
//         "pincode": state.pincode,
//         "name": "",
//         "phoneNumber": "",
//         "latitude": state.latitude,
//         "longitude": state.longitude,
//         "address": state.fullAddress,
//       };
//
//       final url =
//           "http://10.10.20.9:7007/caterings-0.0.1-SNAPSHOT/api/user/$userId/cart/$cartId/address/$addressId";
//       final uri = Uri.parse(url);
//
//       final resp = usePut
//           ? await http.put(uri, headers: {"Content-Type": "application/json"}, body: jsonEncode(body))
//           : await http.post(uri, headers: {"Content-Type": "application/json"}, body: jsonEncode(body));
//
//       return resp.statusCode >= 200 && resp.statusCode < 300;
//     } catch (e) {
//       print("⚠️ sendAddressToCart failed: $e");
//       return false;
//     }
//   }
// }
//
// // -----------------------------
// // Global provider
// // -----------------------------
// final addressProvider = StateNotifierProvider<AddressNotifier, AddressState>((ref) {
//   return AddressNotifier();
// });
