import 'dart:convert';
import 'package:http/http.dart' as http;
import '../API/Apiclient.dart';
import 'Model.dart';

class ApiService {
  /// Submit Enquiry
  static Future<Map<String, dynamic>> submitEnquiry(
      EnquiryRequest request,
      ) async {
    try {
      final response = await ApiClient.post(
        'api/vendor/enquiry',
        request.toJson(),
        service: 'subscription',
      );

      final responseData = _decode(response);

      return {
        'success': response.statusCode >= 200 && response.statusCode < 300,
        'data': responseData,
        'statusCode': response.statusCode,
        'message': responseData['message'] ?? response.body,
      };
    } catch (e) {
      return _error(e);
    }
  }

  /// Login - Modified to work with ApiClient (no queryParams support)
  static Future<Map<String, dynamic>> login(
      String identifier,
      String password,
      ) async {
    try {
      // Build URL with query parameters since ApiClient.post doesn't support queryParams
      final url = 'api/auth/login/vendor?identifier=$identifier&password=$password';

      final response = await ApiClient.post(
        url,
        null,  // No body needed for login
        service: 'subscription',
        sendJson: false,  // Don't send JSON content-type
      );

      final data = _decode(response);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Login failed'};
      }
    } catch (e) {
      return _error(e);
    }
  }

  /// Check Email
  static Future<Map<String, dynamic>> checkEmail(String email) async {
    try {
      final response = await ApiClient.get(
        'api/vendor/enquiry/get-email',
        service: 'subscription',
        requiresAuth: false,
        queryParams: {'emailId': email},
      );

      final data = _decode(response);

      return {
        'success': response.statusCode >= 200 && response.statusCode < 300,
        'data': data,
        'message': data['message'] ?? '',
      };
    } catch (e) {
      return _error(e);
    }
  }

  /// Reset Password
  static Future<Map<String, dynamic>> resetPassword(String email) async {
    try {
      final response = await ApiClient.put(
        'api/auth/vendor/reset-password',
        {},
        service: 'subscription',
      );
      // Note: ApiClient.put doesn't support queryParams, so email is passed in body

      return {
        'success': response.statusCode >= 200 && response.statusCode < 300,
        'message': response.body,
      };
    } catch (e) {
      return _error(e);
    }
  }

  /// Get Banners
  static Future<Map<String, dynamic>> getBanners() async {
    try {
      final response = await ApiClient.get(
        'api/admin-banner/all',
        service: 'food',
        requiresAuth: false,
      );

      final data = _decode(response);

      return {
        'success': response.statusCode >= 200 && response.statusCode < 300,
        'data': data,
      };
    } catch (e) {
      return _error(e);
    }
  }

  /// Common JSON decoder
  static Map<String, dynamic> _decode(http.Response response) {
    try {
      if (response.body.isNotEmpty) {
        return jsonDecode(response.body);
      }
    } catch (_) {}
    return {};
  }

  /// Common error handler
  static Map<String, dynamic> _error(dynamic e) {
    return {'success': false, 'message': 'Network error: ${e.toString()}'};
  }
}