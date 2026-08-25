import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'APIclient.dart';

// ─── Delivery Order Model ──────────────────────────────────────────────────────

class DeliveryOrder {
  final String id;
  final int orderId;
  final int? partnerId;
  final String status;
  final int? vendorOtp;
  final int? userOtp;
  final String deliveryAddress;
  final String userName;
  final String userPhone;
  final String? deliveryPartnerName;
  final String? vehicleStatus;
  final String? items;
  final double? earning;

  const DeliveryOrder({
    required this.id,
    required this.orderId,
    this.partnerId,
    required this.status,
    this.vendorOtp,
    this.userOtp,
    required this.deliveryAddress,
    required this.userName,
    required this.userPhone,
    this.deliveryPartnerName,
    this.vehicleStatus,
    this.items,
    this.earning,
  });

  factory DeliveryOrder.fromJson(Map<String, dynamic> j) => DeliveryOrder(
    id: j['id']?.toString() ?? '',
    orderId: j['orderId'] ?? 0,
    partnerId: j['partnerId'],
    status: j['status']?.toString() ?? '',
    vendorOtp: j['vendorOtp'] is int
        ? j['vendorOtp']
        : int.tryParse(j['vendorOtp']?.toString() ?? ''),
    userOtp: j['userOtp'] is int
        ? j['userOtp']
        : int.tryParse(j['userOtp']?.toString() ?? ''),
    deliveryAddress: j['deliveryAddress']?.toString() ?? '',
    userName: j['userName']?.toString() ?? '',
    userPhone: j['userPhone']?.toString() ?? '',
    deliveryPartnerName: j['deliveryPartnerName']?.toString(),
    vehicleStatus: j['vehicleStatus']?.toString(),
    items: j['items']?.toString(),
    earning: j['earning'] is num ? (j['earning'] as num).toDouble() : null,
  );

  bool get hasPartner => partnerId != null && partnerId! > 0;
  bool get hasVendorOtp => vendorOtp != null && vendorOtp! > 0;
  bool get hasUserOtp => userOtp != null && userOtp! > 0;
}

// ─── Delivery OTP API ─────────────────────────────────────────────────────────

class DeliveryApi {
  static Future<DeliveryOrder?> fetchOrder(int orderId) async {
    try {
      final response = await ApiClient.get(
        "api/get/order",
        service: "delivery",
        queryParams: {
          "orderId": orderId.toString(),
          "appType": "FOOD_AND_BEVERAGES",
        },
      );

      debugPrint("📥 ${response.statusCode} ← delivery order $orderId");

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);

        if (data is Map<String, dynamic>) {
          return DeliveryOrder.fromJson(data);
        }
      } else {
        debugPrint("❌ API Error: ${response.body}");
      }
    } catch (e) {
      debugPrint("⚠️ DeliveryApi.fetchOrder($orderId) failed: $e");
    }

    return null;
  }
}

// import 'dart:convert';
// import 'package:flutter/foundation.dart';
// import 'APIclient.dart';
//
// // ──────────────────────────────────────────────────────────────────────────────
// // DELIVERY ORDER MODEL
// // ──────────────────────────────────────────────────────────────────────────────
//
// class DeliveryOrder {
//   final String id;
//   final int orderId;
//   final int? partnerId;
//   final String status;
//   final int? vendorOtp;
//   final int? userOtp;
//   final String deliveryAddress;
//   final String userName;
//   final String userPhone;
//   final String? deliveryPartnerName;
//   final String? vehicleStatus;
//   final String? items;
//   final double? earning;
//
//   const DeliveryOrder({
//     required this.id,
//     required this.orderId,
//     this.partnerId,
//     required this.status,
//     this.vendorOtp,
//     this.userOtp,
//     required this.deliveryAddress,
//     required this.userName,
//     required this.userPhone,
//     this.deliveryPartnerName,
//     this.vehicleStatus,
//     this.items,
//     this.earning,
//   });
//
//   factory DeliveryOrder.fromJson(Map<String, dynamic> j) => DeliveryOrder(
//     id: j['id']?.toString() ?? '',
//     orderId: j['orderId'] ?? 0,
//     partnerId: j['partnerId'],
//     status: j['status']?.toString() ?? '',
//     vendorOtp: j['vendorOtp'] is int
//         ? j['vendorOtp']
//         : int.tryParse(j['vendorOtp']?.toString() ?? ''),
//     userOtp: j['userOtp'] is int
//         ? j['userOtp']
//         : int.tryParse(j['userOtp']?.toString() ?? ''),
//     deliveryAddress: j['deliveryAddress']?.toString() ?? '',
//     userName: j['userName']?.toString() ?? '',
//     userPhone: j['userPhone']?.toString() ?? '',
//     deliveryPartnerName: j['deliveryPartnerName']?.toString(),
//     vehicleStatus: j['vehicleStatus']?.toString(),
//     items: j['items']?.toString(),
//     earning: j['earning'] is num ? (j['earning'] as num).toDouble() : null,
//   );
//
//   bool get hasPartner => partnerId != null && partnerId! > 0;
//   bool get hasVendorOtp => vendorOtp != null && vendorOtp! > 0;
//   bool get hasUserOtp => userOtp != null && userOtp! > 0;
// }
//
// // ──────────────────────────────────────────────────────────────────────────────
// // DELIVERY API (REFRACTORED)
// // ──────────────────────────────────────────────────────────────────────────────
//
// class DeliveryApi {
//   static void _log(String tag, String msg) {
//     if (kDebugMode) {
//       debugPrint('🚚 [Delivery/$tag] $msg');
//     }
//   }
//
//   // ═══════════════════════════════════════════════════════════════
//   // FETCH DELIVERY ORDER
//   // ═══════════════════════════════════════════════════════════════
//
//   static Future<DeliveryOrder?> fetchOrder(int orderId) async {
//     final endpoint =
//         'delivery/get/order?orderId=$orderId&appType=FOOD_AND_BEVERAGES';
//
//     _log('FETCH_ORDER', endpoint);
//
//     final res = await ApiClient.get(
//       endpoint,
//       service: 'delivery',
//       requiresAuth: true,
//     );
//
//     if (res.statusCode >= 200 && res.statusCode < 300) {
//       final data = jsonDecode(res.body);
//
//       if (data is Map<String, dynamic>) {
//         return DeliveryOrder.fromJson(data);
//       }
//     }
//
//     _log('FETCH_ORDER', 'Failed ${res.statusCode}');
//     return null;
//   }
// }
