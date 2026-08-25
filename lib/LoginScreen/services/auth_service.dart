// import 'dart:convert';
// import 'package:flutter/foundation.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
//
// const String _base = 'http://staging.maamaas.com:8080';
//
// class AuthService {
//   static void _log(String tag, String msg) {
//     if (kDebugMode) debugPrint('🔐 [$tag] $msg');
//   }
//
//   static Map<String, String> _jsonHeaders() => {
//     'Content-Type': 'application/json',
//     'Accept': 'application/json',
//   };
//
//   // ════════════════════════════════════════════════════════════════════════════
//   // LOGIN
//   // POST /subscription/api/auth/login/vendor
//   //   ?identifier={username/email}&password={password}
//   // ════════════════════════════════════════════════════════════════════════════
//   static Future<Map<String, dynamic>> login({
//     required String identifier,
//     required String password,
//   }) async {
//     final url =
//         '$_base/subscription/api/auth/login/vendor'
//         '?identifier=${Uri.encodeComponent(identifier)}'
//         '&password=${Uri.encodeComponent(password)}';
//
//     _log('LOGIN', 'POST $url');
//     final res = await http.post(
//       Uri.parse(url),
//       headers: {'Accept': '*/*'},
//       body: '',
//     );
//     _log('LOGIN', 'status=${res.statusCode}');
//
//     final data = jsonDecode(res.body) as Map<String, dynamic>;
//     if (res.statusCode < 200 || res.statusCode >= 300) {
//       throw Exception(data['message']?.toString() ?? 'Login failed');
//     }
//     return data;
//   }
//
//   // Save all login data to SharedPreferences (mirrors React localStorage logic)
//   static Future<void> saveLoginData(
//     Map<String, dynamic> data,
//     String identifier,
//   ) async {
//     final p = await SharedPreferences.getInstance();
//     await p.clear();
//
//     await p.setString('authToken', data['token'] ?? '');
//     await p.setString('token', data['token'] ?? '');
//     await p.setString('refreshToken', data['refreshToken'] ?? '');
//     await p.setString('role', data['role'] ?? '');
//     await p.setString('customerId', data['customerId']?.toString() ?? '');
//     await p.setString(
//       'employeeRole',
//       data['employeeRole']?.toString() ?? 'NOT_AVAILABLE',
//     );
//     await p.setString('parentId', data['parentId']?.toString() ?? '');
//     await p.setString('username', data['username']?.toString() ?? identifier);
//     await p.setString('userType', data['userType']?.toString() ?? '');
//     await p.setString(
//       'subscriptionStatus',
//       data['subscriptionStatus']?.toString() ?? '',
//     );
//
//     // vendorId — employee uses parentId as vendorId
//     final isEmployee = data['role']?.toString() == 'ROLE_EMPLOYEE';
//     if (isEmployee) {
//       await p.setString('vendorId', data['parentId']?.toString() ?? '');
//       await p.setString('employeeId', data['vendorId']?.toString() ?? '');
//     } else {
//       final vid = data['vendorId'];
//       if (vid is int)
//         await p.setInt('vendorId', vid);
//       else if (vid != null)
//         await p.setString('vendorId', vid.toString());
//     }
//
//     // businessModules & subModules
//     final bm = data['businessModules'];
//     if (bm is List && bm.isNotEmpty) {
//       await p.setStringList(
//         'businessModules',
//         bm.map((e) => e.toString()).toList(),
//       );
//     }
//     final sm = data['subModules'];
//     if (sm is List && sm.isNotEmpty) {
//       await p.setStringList('subModules', sm.map((e) => e.toString()).toList());
//     }
//
//     // Subscriptions → selectedModules + orderTypes
//     final subs = data['subscriptions'];
//     if (subs is List && subs.isNotEmpty) {
//       final sub = subs[0] as Map<String, dynamic>;
//       await p.setString('subscription', jsonEncode(sub));
//       await p.setString('activeSubscription', jsonEncode(sub));
//       final selMods = sub['selectedModules'];
//       if (selMods is List) {
//         final mods = selMods.map((e) => e.toString()).toList();
//         await p.setStringList('selectedModules', mods);
//         const validOrderTypes = [
//           'DINE_IN',
//           'TAKEAWAY',
//           'CATERING',
//           'DELIVERY',
//           'TABLE_DINE_IN',
//         ];
//         final ot = mods.where((m) => validOrderTypes.contains(m)).toList();
//         if (ot.isNotEmpty) await p.setStringList('orderTypes', ot);
//       }
//     }
//
//     _log(
//       'SAVE',
//       'Login data saved. role=${data['role']} vendorId=${data['vendorId']}',
//     );
//   }
//
//   // ════════════════════════════════════════════════════════════════════════════
//   // FORGOT PASSWORD (send reset email)
//   // PUT /subscription/api/auth/vendor/reset-password?email={email}
//   // ════════════════════════════════════════════════════════════════════════════
//   static Future<String> resetPasswordRequest(String email) async {
//     final url =
//         '$_base/subscription/api/auth/vendor/reset-password?email=${Uri.encodeComponent(email)}';
//     _log('RESET', 'PUT $url');
//     final res = await http.put(Uri.parse(url), headers: {'Accept': '*/*'});
//     _log('RESET', 'status=${res.statusCode}  body=${res.body}');
//     if (res.statusCode >= 200 && res.statusCode < 300) return res.body;
//     throw Exception(
//       res.body.isNotEmpty
//           ? res.body
//           : 'Failed to send reset email (${res.statusCode})',
//     );
//   }
//
//   // ════════════════════════════════════════════════════════════════════════════
//   // RESET PASSWORD (set new password with token)
//   // PUT /subscription/api/auth/vendor/forget-password?token={token}&newPassword={pw}
//   // ════════════════════════════════════════════════════════════════════════════
//   static Future<void> resetPasswordWithToken({
//     required String token,
//     required String newPassword,
//   }) async {
//     final url =
//         '$_base/subscription/api/auth/vendor/forget-password'
//         '?token=${Uri.encodeComponent(token)}'
//         '&newPassword=${Uri.encodeComponent(newPassword)}';
//     _log('RESET_TOKEN', 'PUT $url');
//     final res = await http.put(
//       Uri.parse(url),
//       headers: {'Content-Type': 'application/json', 'Accept': '*/*'},
//     );
//     _log('RESET_TOKEN', 'status=${res.statusCode}  body=${res.body}');
//     if (res.statusCode < 200 || res.statusCode >= 300) {
//       throw Exception(
//         res.body.isNotEmpty ? res.body : 'Failed to reset password',
//       );
//     }
//   }
//
//   // ════════════════════════════════════════════════════════════════════════════
//   // ENQUIRY (Book Demo)
//   // POST /subscription/api/vendor/enquiry
//   // ════════════════════════════════════════════════════════════════════════════
//   static Future<Map<String, dynamic>> submitEnquiry({
//     required String name,
//     required String email,
//     required String phone,
//     required String city,
//     String companyName = '',
//   }) async {
//     const url = '$_base/subscription/api/vendor/enquiry';
//     final payload = {
//       'vendorId': 0,
//       'parentId': null,
//       'name': name.trim(),
//       'email': email.trim(),
//       'city': city.trim(),
//       'mobileNumber': phone.replaceAll(RegExp(r'\D'), ''),
//       'companyName': companyName.trim(),
//       'role': 'ROLE_VENDOR',
//       'registerTime': DateTime.now().toIso8601String(),
//     };
//     _log('ENQUIRY', 'POST $url  payload=$payload');
//     final res = await http.post(
//       Uri.parse(url),
//       headers: _jsonHeaders(),
//       body: jsonEncode(payload),
//     );
//     _log(
//       'ENQUIRY',
//       'status=${res.statusCode}  body=${res.body.substring(0, res.body.length.clamp(0, 200))}',
//     );
//
//     if (res.statusCode < 200 || res.statusCode >= 300) {
//       final msg = (res.body).toLowerCase();
//       if (msg.contains('email') && msg.contains('exist'))
//         throw Exception('Email already exists');
//       if (msg.contains('mobile') || msg.contains('phone'))
//         throw Exception('Phone number already exists');
//       if (msg.contains('duplicate'))
//         throw Exception('Duplicate entry detected');
//       throw Exception('Something went wrong');
//     }
//
//     final data = res.body.isNotEmpty
//         ? jsonDecode(res.body) as Map<String, dynamic>
//         : <String, dynamic>{};
//     // Save basic details
//     final p = await SharedPreferences.getInstance();
//     if (data['vendorId'] != null) {
//       final vid = data['vendorId'];
//       if (vid is int)
//         await p.setInt('vendorId', vid);
//       else
//         await p.setString('vendorId', vid.toString());
//     }
//     await p.setString('userName', name.trim());
//     await p.setString('userEmail', email.trim());
//     await p.setString('userPhone', phone);
//     await p.setString('userCity', city.trim());
//     return data;
//   }
//
//   // ════════════════════════════════════════════════════════════════════════════
//   // EMAIL CHECK (existing vendor login via email)
//   // GET /subscription/api/vendor/enquiry/get-email?emailId={email}
//   // ════════════════════════════════════════════════════════════════════════════
//   static Future<Map<String, dynamic>> checkEmail(String email) async {
//     final url =
//         '$_base/subscription/api/vendor/enquiry/get-email?emailId=${Uri.encodeComponent(email)}';
//     _log('EMAIL_CHECK', 'GET $url');
//     final res = await http.get(Uri.parse(url), headers: _jsonHeaders());
//     _log('EMAIL_CHECK', 'status=${res.statusCode}');
//
//     if (res.statusCode != 200) throw Exception('Error checking email');
//
//     final data = jsonDecode(res.body) as Map<String, dynamic>;
//     if (data['vendorId'] == null) throw Exception('Vendor not found');
//
//     final p = await SharedPreferences.getInstance();
//     final vid = data['vendorId'];
//     if (vid is int)
//       await p.setInt('vendorId', vid);
//     else
//       await p.setString('vendorId', vid.toString());
//     return data;
//   }
//
//   // FETCH BANNERS
//
//   static Future<List<BannerItem>> fetchBanners() async {
//     try {
//       final res = await http.get(Uri.parse('$_base/food/api/admin-banner/all'));
//       if (res.statusCode == 200) {
//         final list = jsonDecode(res.body) as List;
//         final items = <BannerItem>[];
//         for (final item in list) {
//           if (item is! Map<String, dynamic>) continue;
//           for (final key in [
//             'banner',
//             'image1',
//             'image2',
//             'image3',
//             'image4',
//           ]) {
//             final img = item[key]?.toString() ?? '';
//             if (img.isNotEmpty) {
//               items.add(
//                 BannerItem(
//                   imageUrl: img,
//                   companyName: item['companyName']?.toString() ?? '',
//                   description: item['description']?.toString() ?? '',
//                 ),
//               );
//             }
//           }
//         }
//         return items;
//       }
//     } catch (e) {
//       _log('BANNERS', 'error: $e');
//     }
//     return [];
//   }
// }
//
// class BannerItem {
//   final String imageUrl;
//   final String companyName;
//   final String description;
//   const BannerItem({
//     required this.imageUrl,
//     required this.companyName,
//     required this.description,
//   });
// }
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../API/Apiclient.dart';

class AuthService {
  static void _log(String tag, String msg) {
    if (kDebugMode) debugPrint('🔐 [$tag] $msg');
  }

  // ═══════════════════════════════════════════════════════════════
  // LOGIN
  // ═══════════════════════════════════════════════════════════════
  static Future<Map<String, dynamic>> login({
    required String identifier,
    required String password,
  }) async {
    final endpoint =
        'api/auth/login/vendor'
        '?identifier=${Uri.encodeComponent(identifier)}'
        '&password=${Uri.encodeComponent(password)}';

    _log('LOGIN', 'POST $endpoint');

    final res = await ApiClient.post(
      endpoint,
      null,
      service: 'subscription',
      sendJson: false,
    );

    _log('LOGIN', 'status=${res.statusCode}');

    final data = jsonDecode(res.body) as Map<String, dynamic>;

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception(data['message']?.toString() ?? 'Login failed');
    }

    return data;
  }

  // ═══════════════════════════════════════════════════════════════
  // SAVE LOGIN DATA (SharedPreferences)
  // ═══════════════════════════════════════════════════════════════
  static Future<void> saveLoginData(
    Map<String, dynamic> data,
    String identifier,
  ) async {
    final p = await SharedPreferences.getInstance();
    await p.clear();

    await p.setString('authToken', data['token'] ?? '');
    await p.setString('token', data['token'] ?? '');
    await p.setString('refreshToken', data['refreshToken'] ?? '');
    await p.setString('role', data['role'] ?? '');
    await p.setString('customerId', data['customerId']?.toString() ?? '');
    await p.setString(
      'employeeRole',
      data['employeeRole']?.toString() ?? 'NOT_AVAILABLE',
    );
    await p.setString('parentId', data['parentId']?.toString() ?? '');
    await p.setString('username', data['username']?.toString() ?? identifier);
    await p.setString('userType', data['userType']?.toString() ?? '');
    await p.setString(
      'subscriptionStatus',
      data['subscriptionStatus']?.toString() ?? '',
    );

    final isEmployee = data['role']?.toString() == 'ROLE_EMPLOYEE';

    if (isEmployee) {
      await p.setString('vendorId', data['parentId']?.toString() ?? '');
      await p.setString('employeeId', data['vendorId']?.toString() ?? '');
    } else {
      await p.setString('vendorId', data['vendorId']?.toString() ?? '');
    }

    final bm = data['businessModules'];
    if (bm is List) {
      await p.setStringList(
        'businessModules',
        bm.map((e) => e.toString()).toList(),
      );
    }

    final sm = data['subModules'];
    if (sm is List) {
      await p.setStringList('subModules', sm.map((e) => e.toString()).toList());
    }

    final subs = data['subscriptions'];
    if (subs is List && subs.isNotEmpty) {
      final sub = subs[0];

      await p.setString('subscription', jsonEncode(sub));
      await p.setString('activeSubscription', jsonEncode(sub));

      final mods =
          (sub['selectedModules'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [];

      await p.setStringList('selectedModules', mods);

      const validOrderTypes = [
        'DINE_IN',
        'TAKEAWAY',
        'CATERING',
        'DELIVERY',
        'TABLE_DINE_IN',
      ];

      final ot = mods.where(validOrderTypes.contains).toList();
      if (ot.isNotEmpty) {
        await p.setStringList('orderTypes', ot);
      }
    }

    _log('SAVE', 'Login data stored successfully');
  }

  // ═══════════════════════════════════════════════════════════════
  // RESET PASSWORD REQUEST
  // ═══════════════════════════════════════════════════════════════
  static Future<String> resetPasswordRequest(String email) async {
    final endpoint =
        'api/auth/vendor/reset-password?email=${Uri.encodeComponent(email)}';

    final res = await ApiClient.put(endpoint, null, service: 'subscription');

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return res.body;
    }

    throw Exception(
      res.body.isNotEmpty
          ? res.body
          : 'Failed to send reset email (${res.statusCode})',
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // RESET PASSWORD WITH TOKEN
  // ═══════════════════════════════════════════════════════════════
  static Future<void> resetPasswordWithToken({
    required String token,
    required String newPassword,
  }) async {
    final endpoint =
        'api/auth/vendor/forget-password'
        '?token=${Uri.encodeComponent(token)}'
        '&newPassword=${Uri.encodeComponent(newPassword)}';

    final res = await ApiClient.put(endpoint, null, service: 'subscription');

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception(
        res.body.isNotEmpty ? res.body : 'Failed to reset password',
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // ENQUIRY (BOOK DEMO)
  // ═══════════════════════════════════════════════════════════════
  static Future<Map<String, dynamic>> submitEnquiry({
    required String name,
    required String email,
    required String phone,
    required String city,
    String companyName = '',
  }) async {
    const endpoint = 'api/vendor/enquiry';

    final payload = {
      'vendorId': 0,
      'parentId': null,
      'name': name.trim(),
      'email': email.trim(),
      'city': city.trim(),
      'mobileNumber': phone.replaceAll(RegExp(r'\D'), ''),
      'companyName': companyName.trim(),
      'role': 'ROLE_VENDOR',
      'registerTime': DateTime.now().toIso8601String(),
    };

    final res = await ApiClient.post(
      endpoint,
      payload,
      service: 'subscription',
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      final msg = res.body.toLowerCase();

      if (msg.contains('email') && msg.contains('exist')) {
        throw Exception('Email already exists');
      }
      if (msg.contains('mobile') || msg.contains('phone')) {
        throw Exception('Phone number already exists');
      }
      if (msg.contains('duplicate')) {
        throw Exception('Duplicate entry detected');
      }

      throw Exception('Something went wrong');
    }

    final data = res.body.isNotEmpty
        ? jsonDecode(res.body)
        : <String, dynamic>{};

    final p = await SharedPreferences.getInstance();

    if (data['vendorId'] != null) {
      p.setString('vendorId', data['vendorId'].toString());
    }

    await p.setString('userName', name.trim());
    await p.setString('userEmail', email.trim());
    await p.setString('userPhone', phone);
    await p.setString('userCity', city.trim());

    return data;
  }

  // ═══════════════════════════════════════════════════════════════
  // CHECK EMAIL
  // ═══════════════════════════════════════════════════════════════
  static Future<Map<String, dynamic>> checkEmail(String email) async {
    final endpoint =
        'api/vendor/enquiry/get-email?emailId=${Uri.encodeComponent(email)}';

    final res = await ApiClient.get(endpoint, service: 'subscription');

    if (res.statusCode != 200) {
      throw Exception('Error checking email');
    }

    final data = jsonDecode(res.body);

    if (data['vendorId'] == null) {
      throw Exception('Vendor not found');
    }

    final p = await SharedPreferences.getInstance();
    p.setString('vendorId', data['vendorId'].toString());

    return data;
  }

  // ═══════════════════════════════════════════════════════════════
  // BANNERS
  // ═══════════════════════════════════════════════════════════════
  static Future<List<BannerItem>> fetchBanners() async {
    try {
      final res = await ApiClient.get(
        'api/admin-banner/all',
        service: 'food',
        requiresAuth: false,
      );

      if (res.statusCode == 200) {
        final list = jsonDecode(res.body) as List;

        final items = <BannerItem>[];

        for (final item in list) {
          if (item is! Map<String, dynamic>) continue;

          for (final key in [
            'banner',
            'image1',
            'image2',
            'image3',
            'image4',
          ]) {
            final img = item[key]?.toString() ?? '';
            if (img.isNotEmpty) {
              items.add(
                BannerItem(
                  imageUrl: img,
                  companyName: item['companyName']?.toString() ?? '',
                  description: item['description']?.toString() ?? '',
                ),
              );
            }
          }
        }

        return items;
      }
    } catch (e) {
      _log('BANNERS', 'error: $e');
    }

    return [];
  }
}

// ═══════════════════════════════════════════════════════════════
// MODEL
// ═══════════════════════════════════════════════════════════════
class BannerItem {
  final String imageUrl;
  final String companyName;
  final String description;

  const BannerItem({
    required this.imageUrl,
    required this.companyName,
    required this.description,
  });
}
