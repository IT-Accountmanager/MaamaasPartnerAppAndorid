// import 'dart:convert';
// import 'package:flutter/foundation.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import '../models/employee.dart';
//
// const _base = 'http://staging.maamaas.com:8080/subscription/api';
//
// const _ss = FlutterSecureStorage();
//
// // ─── Auth helpers ──────────────────────────────────────────────────────────────
// Future<String> _token() async {
//   String? t = await _ss.read(key: 'token');
//   if (t == null || t.isEmpty) {
//     final p = await SharedPreferences.getInstance();
//     t = p.getString('token') ?? p.getString('authToken');
//   }
//   debugPrint(
//     '🔑 ${t != null && t.isNotEmpty ? t.substring(0, 20) : "TOKEN MISSING"}',
//   );
//   return t ?? '';
// }
//
// Future<String> _vendorId() async {
//   String? v = await _ss.read(key: 'vendorId');
//   if (v == null || v.isEmpty) {
//     final p = await SharedPreferences.getInstance();
//     v = p.getString('vendorId') ?? p.getInt('vendorId')?.toString();
//   }
//   debugPrint('🏪 vendorId=$v');
//   return v ?? '';
// }
//
// Future<Map<String, String>> _headers() async => {
//   'Content-Type': 'application/json',
//   'Accept': 'application/json',
//   'Authorization': 'Bearer ${await _token()}',
// };
//
// Future<http.Response> _get(String url) async {
//   debugPrint('GET  $url');
//   final r = await http.get(Uri.parse(url), headers: await _headers());
//   debugPrint('  → ${r.statusCode}');
//   return r;
// }
//
// Future<http.Response> _post(String url, Map<String, dynamic> body) async {
//   debugPrint('POST $url  ${jsonEncode(body)}');
//   final r = await http.post(
//     Uri.parse(url),
//     headers: await _headers(),
//     body: jsonEncode(body),
//   );
//   debugPrint(
//     '  → ${r.statusCode}  ${r.body.length > 200 ? r.body.substring(0, 200) : r.body}',
//   );
//   return r;
// }
//
// Future<http.Response> _put(String url, Map<String, dynamic> body) async {
//   debugPrint('PUT  $url  ${jsonEncode(body)}');
//   final r = await http.put(
//     Uri.parse(url),
//     headers: await _headers(),
//     body: jsonEncode(body),
//   );
//   debugPrint(
//     '  → ${r.statusCode}  ${r.body.length > 200 ? r.body.substring(0, 200) : r.body}',
//   );
//   return r;
// }
//
// Future<http.Response> _delete(String url) async {
//   debugPrint('DEL  $url');
//   final r = await http.delete(Uri.parse(url), headers: await _headers());
//   debugPrint('  → ${r.statusCode}');
//   return r;
// }
//
// // ─── Check 2xx ─────────────────────────────────────────────────────────────────
// bool _ok(int code) => code >= 200 && code < 300;
//
// // ═════════════════════════════════════════════════════════════════════════════
// // EMPLOYEE API — mirrors employeeService.js exactly
// // ═════════════════════════════════════════════════════════════════════════════
// class EmployeeApi {
//
//   static Future<List<Employee>> fetchAll() async {
//     final vid = await _vendorId();
//     final r = await _get('$_base/get-employees/enquiry/$vid');
//     if (_ok(r.statusCode)) {
//       final d = jsonDecode(r.body);
//       if (d is List)
//         return d
//             .map((j) => Employee.fromJson(j as Map<String, dynamic>))
//             .toList();
//     }
//     return [];
//   }
//
//   // POST /subscription/api/vendor/enquiry
//   // mirrors: addEmployee(employeeData)
//   // Payload includes parentId (vendorId), name, phone, email, role, city, etc.
//   static Future<void> add({
//     required String name,
//     required String phone,
//     required String email,
//     required String role,
//     String location = 'Unknown',
//     String companyName = '',
//   }) async {
//     final vid = await _vendorId();
//     final vidInt = int.tryParse(vid) ?? 0;
//     final username =
//         name.toLowerCase().replaceAll(RegExp(r'\s+'), '.') +
//         DateTime.now().millisecondsSinceEpoch.toString().substring(9);
//     final payload = {
//       'vendorId': 0,
//       'name': name,
//       'email': email.isNotEmpty
//           ? email
//           : '${name.toLowerCase().replaceAll(' ', '.')}@example.com',
//       'mobileNumber': phone,
//       'city': location.isNotEmpty ? location : 'Unknown',
//       'companyName': companyName,
//       'businessVerticals': ['FOOD_AND_BEVERAGES'],
//       'parentId': vidInt,
//       'username': username,
//       'password': 'Default@123',
//       'enabled': true,
//       'employeRole': role,
//       'role': 'ROLE_VENDOR',
//       'accountNonLocked': true,
//       'accountNonExpired': true,
//       'credentialsNonExpired': true,
//       'businessModules': [],
//       'createdAt': DateTime.now().toIso8601String(),
//     };
//     final r = await _post('$_base/vendor/enquiry', payload);
//     if (!_ok(r.statusCode)) {
//       final body = r.body;
//       if (body.toLowerCase().contains('mobile')) {
//         throw Exception('This mobile number is already registered.');
//       }
//       throw Exception('Failed to add employee (${r.statusCode}): $body');
//     }
//   }
//
//   // PUT /subscription/api/edit/enquiry/{vendorId}
//   // mirrors: updateEmployeeStatus(vendorId, status)
//   // body: { enabled: bool }
//   static Future<void> updateStatus(int empVendorId, bool enabled) async {
//     final r = await _put('$_base/edit/enquiry/$empVendorId', {
//       'enabled': enabled,
//     });
//     if (!_ok(r.statusCode))
//       throw Exception('updateStatus failed (${r.statusCode}): ${r.body}');
//   }
//
//   // PUT /subscription/api/edit/enquiry/{vendorId}
//   // mirrors: updateEmployee(vendorId, { role, status, remarks, exitDate })
//   // body: { employeRole?, enabled?, remarks?, exitDate? }
//   static Future<void> updateEmployee(
//     int empVendorId, {
//     String? role,
//     bool? enabled,
//     String? remarks,
//     String? exitDate,
//   }) async {
//     final payload = <String, dynamic>{};
//     if (role != null && role.isNotEmpty) payload['employeRole'] = role;
//     if (enabled != null) payload['enabled'] = enabled;
//     if (remarks != null && remarks.isNotEmpty) payload['remarks'] = remarks;
//     if (exitDate != null && exitDate.isNotEmpty) payload['exitDate'] = exitDate;
//     final r = await _put('$_base/edit/enquiry/$empVendorId', payload);
//     if (!_ok(r.statusCode))
//       throw Exception('updateEmployee failed (${r.statusCode}): ${r.body}');
//   }
//
//   // DELETE /subscription/api/delete/enquiry/{vendorId}
//   // mirrors: deleteEmployee(vendorId)
//   static Future<void> delete(int empVendorId) async {
//     final r = await _delete('$_base/delete/enquiry/$empVendorId');
//     if (!_ok(r.statusCode))
//       throw Exception('deleteEmployee failed (${r.statusCode}): ${r.body}');
//   }
// }
// import 'dart:convert';
// import 'package:flutter/foundation.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../API/Apiclient.dart';
// import '../models/employee.dart';
//
// const _ss = FlutterSecureStorage();
//
// // ─── Vendor ID helper ─────────────────────────────────────────────────────
// Future<String> _vendorId() async {
//   String? v = await _ss.read(key: 'vendorId');
//
//   if (v == null || v.isEmpty) {
//     final p = await SharedPreferences.getInstance();
//     v = p.getString('vendorId') ?? p.getInt('vendorId')?.toString();
//   }
//
//   debugPrint('🏪 vendorId=$v');
//   return v ?? '';
// }
// class EmployeeApi {
//   // ── GET Employees ───────────────────────────────────────────────────────
//   static Future<List<Employee>> fetchAll() async {
//     try {
//       final vid = await _vendorId();
//
//       if (vid.isEmpty) {
//         debugPrint("⚠️ No vendorId found");
//         return [];
//       }
//
//       final response = await ApiClient.get(
//         'api/get-employees/enquiry/$vid',
//         service: 'subscription',
//       );
//
//       debugPrint("👥 Fetch Employees → ${response.statusCode}");
//
//       if (response.statusCode >= 200 && response.statusCode < 300 &&
//           response.body.isNotEmpty) {
//
//         final data = jsonDecode(response.body);
//
//         if (data is List) {
//           return data
//               .map((e) => Employee.fromJson(e as Map<String, dynamic>))
//               .toList();
//         }
//       }
//
//       return [];
//     } catch (e) {
//       debugPrint("❌ fetchAll error: $e");
//       return [];
//     }
//   }
//
//   // ── ADD Employee ────────────────────────────────────────────────────────
//   static Future<void> add({
//     required String name,
//     required String phone,
//     required String email,
//     required String role,
//     String location = 'Unknown',
//     String companyName = '',
//   }) async {
//     final vid = await _vendorId();
//     final vidInt = int.tryParse(vid) ?? 0;
//
//     final username =
//         name.toLowerCase().replaceAll(RegExp(r'\s+'), '.') +
//             DateTime.now().millisecondsSinceEpoch.toString().substring(9);
//
//     final payload = {
//       'vendorId': 0,
//       'name': name,
//       'email': email.isNotEmpty
//           ? email
//           : '${name.toLowerCase().replaceAll(' ', '.')}@example.com',
//       'mobileNumber': phone,
//       'city': location.isNotEmpty ? location : 'Unknown',
//       'companyName': companyName,
//       'businessVerticals': ['FOOD_AND_BEVERAGES'],
//       'parentId': vidInt,
//       'username': username,
//       'password': 'Default@123',
//       'enabled': true,
//       'employeRole': role,
//       'role': 'ROLE_VENDOR',
//       'accountNonLocked': true,
//       'accountNonExpired': true,
//       'credentialsNonExpired': true,
//       'businessModules': [],
//       'createdAt': DateTime.now().toIso8601String(),
//     };
//
//     final response = await ApiClient.post(
//       'api/vendor/enquiry',
//       payload,
//       service: 'subscription',
//     );
//
//     debugPrint("➕ Add Employee → ${response.statusCode}");
//
//     if (response.statusCode < 200 || response.statusCode >= 300) {
//       final body = response.body.toLowerCase();
//
//       if (body.contains('mobile')) {
//         throw Exception('This mobile number is already registered.');
//       }
//
//       throw Exception('Failed to add employee: ${response.body}');
//     }
//   }
//
//   // ── UPDATE STATUS ───────────────────────────────────────────────────────
//   static Future<void> updateStatus(int empVendorId, bool enabled) async {
//     final response = await ApiClient.put(
//       'api/edit/enquiry/$empVendorId',
//       {'enabled': enabled},
//       service: 'subscription',
//     );
//
//     debugPrint("🔄 Update Status → ${response.statusCode}");
//
//     if (response.statusCode < 200 || response.statusCode >= 300) {
//       throw Exception('updateStatus failed: ${response.body}');
//     }
//   }
//
//   // ── UPDATE EMPLOYEE ─────────────────────────────────────────────────────
//   static Future<void> updateEmployee(
//       int empVendorId, {
//         String? role,
//         bool? enabled,
//         String? remarks,
//         String? exitDate,
//       }) async {
//     final payload = <String, dynamic>{};
//
//     if (role != null && role.isNotEmpty) payload['employeRole'] = role;
//     if (enabled != null) payload['enabled'] = enabled;
//     if (remarks != null && remarks.isNotEmpty) payload['remarks'] = remarks;
//     if (exitDate != null && exitDate.isNotEmpty) payload['exitDate'] = exitDate;
//
//     final response = await ApiClient.put(
//       'api/edit/enquiry/$empVendorId',
//       payload,
//       service: 'subscription',
//     );
//
//     debugPrint("✏️ Update Employee → ${response.statusCode}");
//
//     if (response.statusCode < 200 || response.statusCode >= 300) {
//       throw Exception('updateEmployee failed: ${response.body}');
//     }
//   }
//
//   // ── DELETE EMPLOYEE ─────────────────────────────────────────────────────
//   static Future<void> delete(int empVendorId) async {
//     final response = await ApiClient.delete(
//       'api/delete/enquiry/$empVendorId',
//       service: 'subscription',
//     );
//
//     debugPrint("🗑 Delete Employee → ${response.statusCode}");
//
//     if (response.statusCode < 200 || response.statusCode >= 300) {
//       throw Exception('deleteEmployee failed: ${response.body}');
//     }
//   }
// }

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../API/Apiclient.dart';
import '../models/employee.dart';

const _ss = FlutterSecureStorage();

// ─── Vendor ID helper ─────────────────────────────────────────────────────
Future<String> _vendorId() async {
  String? v = await _ss.read(key: 'vendorId');

  if (v == null || v.isEmpty) {
    final p = await SharedPreferences.getInstance();
    v = p.getString('vendorId') ?? p.getInt('vendorId')?.toString();
  }

  debugPrint('🏪 vendorId=$v');
  return v ?? '';
}

class EmployeeApi {
  // ── GET Employees ───────────────────────────────────────────────────────
  static Future<List<Employee>> fetchAll() async {
    try {
      final vid = await _vendorId();

      if (vid.isEmpty) {
        debugPrint("⚠️ No vendorId found");
        return [];
      }

      final response = await ApiClient.get(
        'api/get-employees/enquiry/$vid',
        service: 'subscription',
      );

      debugPrint("👥 Fetch Employees → ${response.statusCode}");

      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          response.body.isNotEmpty) {
        final data = jsonDecode(response.body);

        if (data is List) {
          return data
              .map((e) => Employee.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      }

      return [];
    } catch (e) {
      debugPrint("❌ fetchAll error: $e");
      return [];
    }
  }

  // ── ADD Employee ────────────────────────────────────────────────────────
  static Future<void> add({
    required String name,
    required String phone,
    required String email,
    required String role,
    String location = 'Unknown',
    String companyName = '',
  }) async {
    final vid = await _vendorId();
    final vidInt = int.tryParse(vid) ?? 0;

    final username =
        name.toLowerCase().replaceAll(RegExp(r'\s+'), '.') +
        DateTime.now().millisecondsSinceEpoch.toString().substring(9);

    final payload = {
      'vendorId': 0,
      'name': name,
      'email': email.isNotEmpty
          ? email
          : '${name.toLowerCase().replaceAll(' ', '.')}@example.com',
      'mobileNumber': phone,
      'city': location.isNotEmpty ? location : 'Unknown',
      'companyName': companyName,
      'businessVerticals': ['FOOD_AND_BEVERAGES'],
      'parentId': vidInt,
      'username': username,
      'password': 'Default@123',
      'enabled': true,
      'employeRole': role,
      'role': 'ROLE_VENDOR',
      'accountNonLocked': true,
      'accountNonExpired': true,
      'credentialsNonExpired': true,
      'businessModules': [],
      'createdAt': DateTime.now().toIso8601String(),
    };

    final response = await ApiClient.post(
      'api/vendor/enquiry',
      payload,
      service: 'subscription',
    );

    debugPrint("➕ Add Employee → ${response.statusCode}");

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final body = response.body.toLowerCase();

      if (body.contains('mobile')) {
        throw Exception('This mobile number is already registered.');
      }

      throw Exception('Failed to add employee: ${response.body}');
    }
  }

  // ── UPDATE STATUS ───────────────────────────────────────────────────────
  static Future<void> updateStatus(int empVendorId, bool enabled) async {
    final response = await ApiClient.put('api/edit/enquiry/$empVendorId', {
      'enabled': enabled,
    }, service: 'subscription');

    debugPrint("🔄 Update Status → ${response.statusCode}");

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('updateStatus failed: ${response.body}');
    }
  }

  // ── UPDATE EMPLOYEE ─────────────────────────────────────────────────────
  static Future<void> updateEmployee(
    int empVendorId, {
    String? role,
    bool? enabled,
    String? remarks,
    String? exitDate,
  }) async {
    final payload = <String, dynamic>{};

    if (role != null && role.isNotEmpty) payload['employeRole'] = role;
    if (enabled != null) payload['enabled'] = enabled;
    if (remarks != null && remarks.isNotEmpty) payload['remarks'] = remarks;
    if (exitDate != null && exitDate.isNotEmpty) payload['exitDate'] = exitDate;

    final response = await ApiClient.put(
      'api/edit/enquiry/$empVendorId',
      payload,
      service: 'subscription',
    );

    debugPrint("✏️ Update Employee → ${response.statusCode}");

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('updateEmployee failed: ${response.body}');
    }
  }

  // ── DELETE EMPLOYEE ─────────────────────────────────────────────────────
  static Future<void> delete(int empVendorId) async {
    final response = await ApiClient.delete(
      'api/delete/enquiry/$empVendorId',
      service: 'subscription',
    );

    debugPrint("🗑 Delete Employee → ${response.statusCode}");

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('deleteEmployee failed: ${response.body}');
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// EMPLOYEE SLOTS — plan config, purchase, and purchase history
// ═══════════════════════════════════════════════════════════════════════════
class EmployeeSlotApi {
  // ── GET /subscription/employee-slot-plan ────────────────────────────────
  // Returns the active plan config: free slot limit + price per extra slot.
  static Future<EmployeeSlotPlan> fetchPlan() async {
    try {
      final response = await ApiClient.get(
        'employee-slot-plan',
        service: 'subscription',
      );

      debugPrint("📋 Fetch Slot Plan → ${response.statusCode}");

      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          response.body.isNotEmpty) {
        final data = jsonDecode(response.body);

        if (data is List && data.isNotEmpty) {
          final active = data.firstWhere(
            (e) => e['active'] == true,
            orElse: () => data.first,
          );
          return EmployeeSlotPlan.fromJson(active as Map<String, dynamic>);
        }
      }

      return EmployeeSlotPlan.empty();
    } catch (e) {
      debugPrint("❌ fetchPlan error: $e");
      return EmployeeSlotPlan.empty();
    }
  }

  // ── GET /subscription/employee/slot/purchase/{vendorId} ─────────────────
  // Returns purchase history for the vendor; used to total up paid slots.
  static Future<List<SlotPurchase>> fetchPurchaseHistory() async {
    try {
      final vid = await _vendorId();
      if (vid.isEmpty) return [];

      final response = await ApiClient.get(
        'employee/slot/purchase/$vid',
        service: 'subscription',
      );

      debugPrint("🧾 Fetch Slot Purchases → ${response.statusCode}");

      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          response.body.isNotEmpty) {
        final data = jsonDecode(response.body);

        if (data is List) {
          return data
              .map((e) => SlotPurchase.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      }

      return [];
    } catch (e) {
      debugPrint("❌ fetchPurchaseHistory error: $e");
      return [];
    }
  }

  // ── Combined summary: plan + purchase history + live employee count ─────
  // This is what the UI (slot bar + buy-slots dialog) actually consumes.
  static Future<EmployeeSlotSummary> fetchSummary(int currentEmployees) async {
    final results = await Future.wait([fetchPlan(), fetchPurchaseHistory()]);
    final plan = results[0] as EmployeeSlotPlan;
    final purchases = results[1] as List<SlotPurchase>;

    final purchasedSlots = purchases
        .where((p) => p.paymentStatus.toUpperCase() == 'SUCCESS')
        .fold<int>(0, (sum, p) => sum + p.slotsPurchased);

    return EmployeeSlotSummary(
      freeLimit: plan.freeEmployeeLimit,
      purchasedSlots: purchasedSlots,
      slotPrice: plan.slotPrice,
      currentEmployees: currentEmployees,
    );
  }

  // ── POST /subscription/employee/slot/purchase ────────────────────────────
  // Called after a successful Razorpay payment to record the purchase.
  static Future<void> purchaseSlots({
    required int slotsPurchased,
    required double pricePerSlot,
    required String paymentId,
    required String orderId,
    String paymentStatus = 'success',
  }) async {
    final vid = await _vendorId();
    final vidInt = int.tryParse(vid) ?? 0;

    final payload = {
      'vendorId': vidInt,
      'slotsPurchased': slotsPurchased,
      'pricePerSlot': pricePerSlot,
      'totalAmount': slotsPurchased * pricePerSlot,
      'paymentId': paymentId,
      'orderId': orderId,
      'paymentStatus': paymentStatus,
      'purchaseDate': DateTime.now().toIso8601String(),
    };

    final response = await ApiClient.post(
      'employee/slot/purchase',
      payload,
      service: 'subscription',
    );

    debugPrint("💳 Purchase Slots → ${response.statusCode}");

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('purchaseSlots failed: ${response.body}');
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// PAYMENT — Razorpay order creation, matching the pattern already used for
// subscription/credit payments elsewhere in the app.
// ═══════════════════════════════════════════════════════════════════════════
class PaymentApi {
  static Future<String?> createRazorpayOrder(double amount) async {
    final vid = await _vendorId();

    final res = await ApiClient.post("api/user/create-order", {
      "amount": amount,
      "currency": "INR",
      "receipt": "slot_purchase_${DateTime.now().millisecondsSinceEpoch}",
      "vendorId": int.tryParse(vid) ?? 0,
    }, service: "subscription");

    if (res.statusCode >= 200 && res.statusCode < 300) {
      final data = jsonDecode(res.body);
      return data['orderId']?.toString() ?? data['id']?.toString();
    }

    return null;
  }

  static Future<bool> captureRazorpayPayment(
    String paymentId,
    double amount,
  ) async {
    final vid = await _vendorId();

    final res = await ApiClient.post("api/user/capture", {
      "paymentId": paymentId,
      "amount": amount,
      "currency": "INR",
      "vendorId": int.tryParse(vid) ?? 0,
    }, service: "subscription");

    return res.statusCode >= 200 && res.statusCode < 300;
  }
}
