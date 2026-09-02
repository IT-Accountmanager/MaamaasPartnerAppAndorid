import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class subscription_authservice {
  static const _secureStorage = FlutterSecureStorage();

  static const String subscription =
      "http://staging.maamaas.com:8080/subscription";
  // "https://backend.maamaas.com/subscription";

  static Future<bool> refreshToken() async {
    try {
      final refreshToken = await _secureStorage.read(key: 'refreshToken');
      if (refreshToken == null || refreshToken.isEmpty) {
        // debugPrint("⚠️ No refresh token found in secure storage");
        return false;
      }

      final url = Uri.parse('$subscription/api/auth/refresh');
      // debugPrint("🔁 Refresh token request → $url");

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Cookie': 'refreshToken=$refreshToken',
        },
      );
      //
      // debugPrint(
      //   "🔁 Refresh response: ${response.statusCode} → ${response.body}",
      // );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Save the new access token
        if (data.containsKey('token')) {
          await _secureStorage.write(key: 'token', value: data['token']);
          // debugPrint("✅ Access token refreshed and saved");
        } else {
          // debugPrint("⚠️ Refresh response missing token");
          return false;
        }

        // Backend does NOT return a new refresh token in your current API
        return true;
      } else {
        // debugPrint("❌ Refresh failed: ${response.statusCode}");
        await logout(); // clear tokens if refresh fails
        return false;
      }
    } catch (e, st) {
      // debugPrint("❌ Exception in refreshToken: $e");
      // debugPrint(st.toString());
      return false;
    }
  }

  /// Get current access token (nullable)
  static Future<String?> getAccessToken() async {
    return _secureStorage.read(key: 'token');
  }

  /// Get current refresh token (nullable)
  static Future<String?> getRefreshToken() async {
    return _secureStorage.read(key: 'refreshToken');
  }

  /// Logout / clear stored tokens & prefs (customize as needed)
  static Future<void> logout() async {
    await _secureStorage.delete(key: 'token');
    await _secureStorage.delete(key: 'refreshToken');

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    await prefs.remove('role');
    await prefs.remove('userType');

    // debugPrint("🔒 Logged out — tokens & prefs cleared");
  }

  static Future<Map<String, dynamic>> login({
    required String identifier,
    required String password,
  }) async {
    final url =
        "$subscription/api/auth/login/vendor?identifier=$identifier&password=$password";

    // debugPrint("📡 Login URL → $url");

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      // debugPrint("📩 Response → ${response.statusCode}: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final String token = data['token'] ?? "";
        final String refreshToken = data['refreshToken'] ?? "";
        final int vendorId = data['vendorId'] ?? 0;
        final int employeeId = data['employeeId'] ?? 0;
        final String role = data['role'] ?? '';
        final String employeeRole = data['employeeRole'] ?? '';

        // 🧠 Log all key response fields
        // debugPrint("🔑 Token: $token");
        // debugPrint("♻️ RefreshToken: $refreshToken");
        // debugPrint("🏪 VendorId: $vendorId");
        // debugPrint("👨‍💼 EmployeeId: $employeeId");
        // debugPrint("🎭 Role: $role");
        // debugPrint("🧩 EmployeeRole: $employeeRole");

        // 🔐 Save sensitive tokens securely
        await _secureStorage.write(key: 'token', value: token);
        await _secureStorage.write(key: 'refreshToken', value: refreshToken);
        await _secureStorage.write(key: 'vendorId', value: vendorId.toString());
        await _secureStorage.write(
          key: 'employeeId',
          value: employeeId.toString(),
        );
        await _secureStorage.write(key: 'role', value: role);
        await _secureStorage.write(key: 'employeeRole', value: employeeRole);

        // debugPrint(
        //   "✅ SecureStorage save complete → token & vendor info stored",
        // );

        // 🗂 Save data in SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('refreshToken', refreshToken);
        await prefs.setInt('vendorId', vendorId);
        await prefs.setInt('employeeId', employeeId);
        await prefs.setString('role', role);
        await prefs.setString('employeeRole', employeeRole);

        // // ✅ Confirm written SharedPrefs values
        // debugPrint(
        //   "📦 SharedPrefs stored → "
        //   "vendorId: ${prefs.getInt('vendorId')}, "
        //   "employeeId: ${prefs.getInt('employeeId')}, "
        //   "role: ${prefs.getString('role')}, "
        //   "employeeRole: ${prefs.getString('employeeRole')}",
        // );

        // Save list data safely
        if (data['planTypes'] != null) {
          await prefs.setStringList(
            'planTypes',
            List<String>.from(data['planTypes']),
          );
          // debugPrint("🗂 planTypes stored → ${data['planTypes']}");
        }

        if (data['modules'] != null) {
          await prefs.setStringList(
            'modules',
            List<String>.from(data['modules']),
          );
          // debugPrint("🧱 modules stored → ${data['modules']}");
        }

        if (data['businessVerticals'] != null) {
          await prefs.setStringList(
            'businessVerticals',
            List<String>.from(data['businessVerticals']),
          );
          // debugPrint(
          //   "🏢 businessVerticals stored → ${data['businessVerticals']}",
          // );
        }

        // debugPrint("✅ Login success → VendorId: $vendorId | Role: $role");

        return {"success": true, "data": data};
      } else {
        // debugPrint("❌ Login failed → ${response.statusCode}: ${response.body}");
        return {
          "success": false,
          "message":
              "Login failed: ${response.statusCode} ${response.reasonPhrase}",
        };
      }
    } catch (e) {
      // debugPrint("💥 Login error: $e");
      return {"success": false, "message": "Error: $e"};
    }
  }
}
