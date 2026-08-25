import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

typedef SessionExpiredHandler = Future<void> Function();

class ApiClient {
  static const String subscription =
      // "http://staging.maamaas.com:8080/subscription";
      "https://backend.maamaas.com/subscription";

  static const String food_beverages =
      // "http://staging.maamaas.com:8080/food";
      "https://backend.maamaas.com/food";

  static const String notification =
      // "http://staging.maamaas.com:8080/notify";
      "https://backend.maamaas.com/notify";

  static const String catering =
      // "http://staging.maamaas.com:8080/catering";
      "https://backend.maamaas.com/catering";

  static const String delivery =
      // "http://staging.maamaas.com:8080/delivery";
      "https://backend.maamaas.com/delivery";

  static const String grocery =
      "https://backend.maamaas.com/groceries";
  // "http://staging.maamaas.com:8080/groceries";

  static const String promotions =
      "https://backend.maamaas.com/promotions";
  // "http://staging.maamaas.com:8080/promotions";

  static SessionExpiredHandler? onSessionExpired;

  static String _resolveBaseUrl(String service) {
    switch (service) {
      case 'subscription':
        return subscription;
      case 'catering':
        return catering;
      case 'food':
        return food_beverages;
      case 'notification':
        return notification;
      case 'delivery':
        return delivery;
      case 'grocery':
        return grocery;
      case 'promotions':
        return promotions;
      default:
        return subscription;
    }
  }

  static const _secureStorage = FlutterSecureStorage();
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
    await _secureStorage.read(key: 'token');
    final refreshToken = await _secureStorage.read(key: 'refreshToken');

    if (refreshToken != null) {
      jsonDecode(
        utf8.decode(
          base64Url.decode(base64Url.normalize(refreshToken.split('.')[1])),
        ),
      );
    }
  }

  static Future<String?> refreshAccessToken() async {
    try {
      final refreshToken = await _secureStorage.read(key: 'refreshToken');

      // debugPrint(
      //   "🔑 Refresh token read: ${refreshToken != null ? "YES" : "NO"}",
      // );

      if (refreshToken == null || refreshToken.isEmpty) {
        // debugPrint('❌ No refresh token found');
        return null;
      }

      // debugPrint("🚀 Calling refresh API: $subscription/api/auth/refresh");

      final response = await _dio.post(
        '$subscription/api/auth/refresh',
        data: {"refreshToken": refreshToken},
      );
      //
      // debugPrint("📡 Refresh response code: ${response.statusCode}");
      // debugPrint("📦 Refresh response data: ${response.data}");

      if (response.statusCode == 200) {
        // debugPrint("🟢 Refresh successful");

        final newToken = response.data['token'];
        final newRefreshToken = response.data['refreshToken'];
        //
        // debugPrint("🔐 New access token received: ${newToken != null}");
        // debugPrint("🔐 New refresh token received: ${newRefreshToken != null}");

        if (newToken != null) {
          await _secureStorage.write(key: 'token', value: newToken);
        }

        if (newRefreshToken != null) {
          await _secureStorage.write(
            key: 'refreshToken',
            value: newRefreshToken,
          );
        }

        return newToken;
      }

      // debugPrint("🔴 Refresh failed with status: ${response.statusCode}");

      return null;
    } catch (e) {
      // debugPrint('💥 Refresh exception: $e');
      return null;
    }
  }

  static Future<http.Response> _handleRequestWithRefreshRetry(
    Future<http.Response> Function() requestFunc,
  ) async {
    http.Response response = await requestFunc();

    if (response.statusCode == 401 || response.statusCode == 403) {
      final newToken = await refreshAccessToken();

      if (newToken != null) {
        response = await requestFunc();
      } else {
        if (onSessionExpired != null) {
          await onSessionExpired!();
        }
        throw Exception("Session expired. Please login again.");
      }
    }

    return response;
  }

  static Future<Map<String, String>> _headers({
    bool isMultipart = false,
  }) async {
    final token = await _secureStorage.read(key: 'token');

    final headers = <String, String>{};

    if (!isMultipart) {
      headers['Content-Type'] = 'application/json';
    }

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  static Future<http.Response> get(
    String endpoint, {
    String service = 'subscription',
    bool requiresAuth = true,
    Map<String, dynamic>? queryParams,
  }) async {
    return _handleRequestWithRefreshRetry(() async {
      final baseUrl = _resolveBaseUrl(service);

      final uri = Uri.parse(
        '$baseUrl/$endpoint',
      ).replace(queryParameters: queryParams);

      Map<String, String> headers;

      if (requiresAuth) {
        headers = await _headers();
      } else {
        headers = {"Content-Type": "application/json"};
      }

      return http.get(uri, headers: headers);
    });
  }

  static Future<http.Response> post(
    String endpoint,
    dynamic body, {
    String service = 'subscription',
    bool sendJson = true,
  }) async {
    return _handleRequestWithRefreshRetry(() async {
      final baseUrl = _resolveBaseUrl(service);
      final url = Uri.parse('$baseUrl/$endpoint');

      final headers = await _headers();

      if (body == null || sendJson == false) {
        headers.remove('Content-Type');
      }

      return http.post(
        url,
        headers: headers,
        body: body == null ? null : (sendJson ? jsonEncode(body) : body),
      );
    });
  }

  static Future<http.Response> put(
    String endpoint,
    dynamic body, {
    String service = "food",
  }) async {
    return _handleRequestWithRefreshRetry(() async {
      final baseUrl = _resolveBaseUrl(service);
      final url = Uri.parse("$baseUrl/$endpoint");
      final headers = await _headers();
      return http.put(url, headers: headers, body: jsonEncode(body));
    });
  }

  static Future<http.Response> sendMultipartRequest({
    required String endpoint,
    required String method,
    required String service,
    Map<String, dynamic>? data,
    Map<String, File>? files,
  }) async {
    return _handleRequestWithRefreshRetry(() async {
      final token = await _secureStorage.read(key: 'token');
      if (token == null || token.isEmpty) {
        throw Exception("❌ Authentication token not found.");
      }

      final baseUrl = _resolveBaseUrl(service);
      final fullUrl = "$baseUrl/$endpoint";
      final uri = Uri.parse(fullUrl);

      final request = http.MultipartRequest(method, uri);

      request.headers.addAll({
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      });

      // 🔥 Add NORMAL FIELDS (NO JSON ENCODE)
      if (data != null) {
        for (final entry in data.entries) {
          final key = entry.key;
          final value = entry.value;

          // If value is JSON → send as multipart JSON part
          if (value is String && value.trim().startsWith("{")) {
            request.files.add(
              http.MultipartFile.fromString(
                key,
                value,
                contentType: MediaType("application", "json"),
              ),
            );
          } else {
            request.fields[key] = value.toString();
          }
        }
      }

      if (files != null && files.isNotEmpty) {
        for (final entry in files.entries) {
          final file = entry.value;

          final mimeType =
              lookupMimeType(file.path) ?? "application/octet-stream";
          final parts = mimeType.split("/");

          request.files.add(
            await http.MultipartFile.fromPath(
              entry.key,
              file.path,
              filename: file.path.split('/').last,
              contentType: parts.length == 2
                  ? MediaType(parts[0], parts[1])
                  : MediaType("application", "octet-stream"),
            ),
          );
        }
      }

      final streamedResponse = await request.send();
      return http.Response.fromStream(streamedResponse);
    });
  }

  static Future<http.Response> delete(
    String endpoint, {
    String service = 'subscription',
  }) async {
    return _handleRequestWithRefreshRetry(() async {
      final baseUrl = _resolveBaseUrl(service);
      final url = Uri.parse('$baseUrl/$endpoint');
      final headers = await _headers();
      return http.delete(url, headers: headers);
    });
  }
}
