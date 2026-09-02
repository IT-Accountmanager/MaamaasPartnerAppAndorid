import 'dart:convert';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:maamaaspartner/Api/APIclient.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import '../Models/food&beverages/SubscriptionData.dart';
import '../Models/food&beverages/vendor_model.dart';

// Add this typedef for session expiration handler
typedef SessionExpiredHandler = Future<void> Function();

class Authservice {
  static const _secureStorage = FlutterSecureStorage();

  // Add session expired callback
  static SessionExpiredHandler? onSessionExpired;

  static const String subscription =
      "http://staging.maamaas.com:8080/subscription";
      // "https://backend.maamaas.com/subscription";

  static final Dio _dio = Dio();

  static void initialize() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) async {
          if (error.response?.statusCode == 401 &&
              !error.requestOptions.path.contains("/auth/refresh") &&
              !error.requestOptions.path.contains("/auth/login")) {
            final newToken = await refreshAccessToken();

            if (newToken != null) {
              final options = error.requestOptions;
              options.headers["Authorization"] = "Bearer $newToken";

              final retry = await _dio.fetch(options);
              return handler.resolve(retry);
            }

            if (onSessionExpired != null) {
              await onSessionExpired!();
            }

            return;
          }

          return handler.next(error);
        },
      ),
    );
  }

  static Future<void> debugTokens() async {
    final token = await _secureStorage.read(key: 'token');
    final refreshToken = await _secureStorage.read(key: 'refreshToken');
    //
    // debugPrint('🔍 Token exists: ${token != null}');
    // debugPrint('🔍 Refresh Token exists: ${refreshToken != null}');

    if (refreshToken != null && refreshToken.isNotEmpty) {
      try {
        final parts = refreshToken.split('.');
        if (parts.length > 1) {
          final payload = jsonDecode(
            utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
          );
          // debugPrint(
          //   '📝 Refresh Token expiry: ${DateTime.fromMillisecondsSinceEpoch(payload['exp'] * 1000)}',
          // );
        }
      } catch (e) {
        // debugPrint('❌ Error decoding refresh token: $e');
      }
    }
  }

  // Enhanced refresh token method matching your response format
  static Future<String?> refreshAccessToken() async {
    try {
      final refreshToken = await _secureStorage.read(key: 'refreshToken');
      // debugPrint('🔍 Attempting refresh...');

      if (refreshToken == null || refreshToken.isEmpty) {
        // debugPrint('❌ No refresh token found');
        return null;
      }
      //
      // debugPrint(
      //   '🔄 Using refresh token: ${refreshToken.substring(0, min(20, refreshToken.length))}...',
      // );

      final response = await _dio.post(
        '$subscription/api/auth/refresh',
        queryParameters: {'refreshTokenmobile': refreshToken},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      // debugPrint('📥 Refresh Response Status: ${response.statusCode}');

      if (response.statusCode == 401 || response.statusCode == 403) {
        // debugPrint('🔴 Refresh token invalid/expired');

        if (onSessionExpired != null) {
          await onSessionExpired!();
        }
        return null;
      }

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final newToken = data['token'] as String?;
        final newRefreshToken = data['refreshToken'] as String?;
        //
        // debugPrint('✅ New token received: ${newToken != null}');
        // debugPrint('✅ New refresh token received: ${newRefreshToken != null}');

        if (newToken != null && newToken.isNotEmpty) {
          await _secureStorage.write(key: 'token', value: newToken);

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', newToken);

          // debugPrint('✅ New access token stored');
        }

        if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
          await _secureStorage.write(
            key: 'refreshToken',
            value: newRefreshToken,
          );

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('refreshToken', newRefreshToken);

          // debugPrint('✅ New refresh token stored');
        }

        return newToken;
      }

      // debugPrint('🔴 Refresh failed: ${response.statusCode}');

      if (onSessionExpired != null) {
        await onSessionExpired!();
      }

      return null;
    } catch (e) {
      // debugPrint('🔴 Refresh exception: $e');

      if (onSessionExpired != null) {
        await onSessionExpired!();
      }

      return null;
    }
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

      debugPrint("📩 Response → ${response.statusCode}: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // ── Core auth fields ──────────────────────────────────────────────────
        final String token = data['token'] ?? '';
        final String refreshToken = data['refreshToken'] ?? '';
        final String role = data['role'] ?? '';

        // ── VendorId logic ────────────────────────────────────────────────────
        int vendorId = data['vendorId'] ?? 0;
        final int parentId = data['parentId'] ?? 0;
        if (role == 'ROLE_EMPLOYEE' && parentId != 0) {
          vendorId = parentId;
        }

        // ── Employee-specific fields ──────────────────────────────────────────
        final int employeeId = data['employeeId'] ?? data['id'] ?? 0;

        final String employeeRole =
            data['employeeRole'] ?? data['employeRole'] ?? '';

        final String customerId = data['customerId'] ?? '';

        final List<String> businessModules = data['businessModules'] != null
            ? List<String>.from(data['businessModules'])
            : [];

        final List<String> subModules = data['subModules'] != null
            ? List<String>.from(data['subModules'])
            : [];

        final List<String> tableModule = data['tableModule'] != null
            ? List<String>.from(data['tableModule'])
            : [];

        final List<String> appTypes = data['appTypes'] != null
            ? List<String>.from(data['appTypes'])
            : [];



        // ── Secure storage (sensitive tokens) ────────────────────────────────
        await _secureStorage.write(key: 'token', value: token);
        await _secureStorage.write(key: 'refreshToken', value: refreshToken);
        await _secureStorage.write(key: 'vendorId', value: vendorId.toString());
        await _secureStorage.write(
          key: 'employeeId',
          value: employeeId.toString(),
        );
        await _secureStorage.write(key: 'role', value: role);
        await _secureStorage.write(key: 'employeeRole', value: employeeRole);
        await _secureStorage.write(key: 'customerId', value: customerId);
        await _secureStorage.write(key: 'parentId', value: parentId.toString());

        // debugPrint("✅ SecureStorage save complete");

        // ── SharedPreferences (app-wide access) ───────────────────────────────
        final prefs = await SharedPreferences.getInstance();

        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('userEmail', identifier);
        await prefs.setString('token', token);
        await prefs.setString('refreshToken', refreshToken);

        await prefs.setInt('vendorId', vendorId);
        await prefs.setInt('employeeId', employeeId);
        await prefs.setInt('parentId', parentId);

        await prefs.setString('role', role);
        await prefs.setString('employeeRole', employeeRole);
        await prefs.setString('employeRole', employeeRole);

        await prefs.setString('customerId', customerId);

        // ── List fields ───────────────────────────────────────────────────────

        if (data['planTypes'] != null) {
          await prefs.setStringList(
            'planTypes',
            List<String>.from(data['planTypes']),
          );
        } else if (data['subscriptions'] != null) {
          final subs = data['subscriptions'] as List;
          final types = subs
              .map((s) => (s['planType'] ?? '').toString())
              .where((t) => t.isNotEmpty)
              .toList();
          if (types.isNotEmpty) {
            await prefs.setStringList('planTypes', types);
          }
        }

        if (data['modules'] != null) {
          await prefs.setStringList(
            'modules',
            List<String>.from(data['modules']),
          );
        }

        if (data['businessVerticals'] != null) {
          await prefs.setStringList(
            'businessVerticals',
            List<String>.from(data['businessVerticals']),
          );
        }

        await prefs.setStringList('businessModules', businessModules);

        await prefs.setStringList('subModules', subModules);

        await prefs.setStringList('tableModule', tableModule);

        if (appTypes.isNotEmpty) {
          await prefs.setStringList('appTypes', appTypes);
        }

        if (data['subscriptions'] != null) {
          final subs = data['subscriptions'] as List;
          if (subs.isNotEmpty && subs[0]['selectedModules'] != null) {
            await prefs.setStringList(
              'selectedModules',
              List<String>.from(subs[0]['selectedModules']),
            );
          }
        }

        // ── Capture device location at login time ─────────────────────────────
        try {
          final position = await _getDeviceLocation();
          if (position != null) {
            await prefs.setDouble('login_latitude', position.latitude);
            await prefs.setDouble('login_longitude', position.longitude);
            // debugPrint(
            //   "📍 Login location: ${position.latitude}, ${position.longitude}",
            // );
          } else {
            // debugPrint("📍 Location not available at login");
          }
        } catch (e) {
          // debugPrint("⚠️ Could not capture location at login: $e");
        }
        // ─────────────────────────────────────────────────────────────────────
        //
        // debugPrint("✅ Login success → VendorId: $vendorId | Role: $role");
        // debugPrint("✅ BusinessModules saved: ${businessModules.length} items");

        return {'success': true, 'data': data};
      } else {
        // debugPrint("❌ Login failed → ${response.statusCode}: ${response.body}");
        return {
          'success': false,
          'message':
              'Login failed: ${response.statusCode} ${response.reasonPhrase}',
        };
      }
    } catch (e) {
      // debugPrint("💥 Login error: $e");
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // ── Device location helper ────────────────────────────────────────────────────
  static Future<Position?> _getDeviceLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // debugPrint("📍 Location services are disabled");
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        // debugPrint("📍 Location permission denied");
        return null;
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      // debugPrint("📍 Location fetch error: $e");
      return null;
    }
  }

  static Future<void> logout() async {
    // debugPrint("🚪 Logout started");

    try {
      final token = await getAccessToken();
      if (token != null) {
        try {
          await ApiClient.post("api/auth/logout", {}, service: "subscription");
        } catch (e) {
          // debugPrint("⚠️ Logout API error: $e");
        }
      }
    } catch (e) {
      // debugPrint("❌ Logout API error: $e");
    } finally {
      // debugPrint("🧹 Clearing local storage...");

      await _secureStorage.delete(key: 'token');
      await _secureStorage.delete(key: 'refreshToken');
      await _secureStorage.delete(key: 'vendorId');
      await _secureStorage.delete(key: 'employeeId');
      await _secureStorage.delete(key: 'role');
      await _secureStorage.delete(key: 'employeRole');
      await _secureStorage.delete(key: 'customerId');

      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      //
      // debugPrint("✅ Local data cleared");
      // debugPrint("🚪 Logout completed");
    }
  }

  static Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  static Future<String?> getAccessToken() async {
    String? token = await _secureStorage.read(key: 'token');

    if (token == null || token.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      token = prefs.getString('token');
    }

    return token;
  }

  static Future<String?> getRefreshToken() async {
    return _secureStorage.read(key: 'refreshToken');
  }

  static Future<int?> getVendorId() async {
    final vendorIdStr = await _secureStorage.read(key: 'vendorId');
    if (vendorIdStr != null) {
      return int.tryParse(vendorIdStr);
    }

    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('vendorId');
  }

  Future<VendorModel?> fetchVendorData() async {
    final prefs = await SharedPreferences.getInstance();
    final vendorId = prefs.getInt('vendorId');
    print('Saved Vendor ID in SharedPreferences: $vendorId');
    // final url = Uri.parse(
    //   "http://10.10.20.9:6300/Mamaswebsite-0.0.1-SNAPSHOT/api/vendors/$vendorId",
    // );
    // final url = Uri.parse("https://backend.maamaas.com/api/vendors/$vendorId");
    //
    final url = Uri.parse(
      "http://staging.maamaas.com:8080/api/vendors/$vendorId",
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return VendorModel.fromJson(data);
      } else {
        print("Failed to fetch vendor data: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error fetching vendor data: $e");
      return null;
    }
  }

  static Future<SubscriptionData?> fetchSubscriptionData() async {
    final prefs = await SharedPreferences.getInstance();
    final vendorId = prefs.getInt('vendorId');

    Future<dynamic> fetchAdvertisements() async {}
    if (vendorId == null) {
      throw Exception("Vendor ID not found in SharedPreferences");
    }

    final endpoint = "api/get/vendor_subscription/$vendorId/FOOD_AND_BEVERAGES";

    final response = await ApiClient.get(endpoint, service: 'subscription');

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      if (data.isNotEmpty) {
        return SubscriptionData.fromJson(
          data.first,
        ); // take the first subscription
      }
    }
    return null;
  }
}
