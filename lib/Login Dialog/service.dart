import 'dart:convert';

import '../API/APIclient.dart';
import 'ModelLoginDialog.dart';


class VendorServiceException implements Exception {
  final String message;
  final int? statusCode;

  VendorServiceException(this.message, {this.statusCode});

  @override
  String toString() => 'VendorServiceException: $message';
}

class VendorService {

  static Future<VendorModelLoginDialog?> getVendorByEmail(String email) async {
    try {
      final response = await ApiClient.get(
        'api/vendor/enquiry/get-email',
        service: 'subscription',

        requiresAuth: false,
        queryParams: {'emailId': email},
      );

      switch (response.statusCode) {
        case 200:
          if (response.body.isEmpty) return null;

          final decoded = jsonDecode(response.body);

          if (decoded is Map<String, dynamic>) {
            return VendorModelLoginDialog.fromJson(decoded);
          }

          if (decoded is Map && decoded['data'] is Map<String, dynamic>) {
            return VendorModelLoginDialog.fromJson(decoded['data'] as Map<String, dynamic>);
          }

          return null;

        case 404:
          return null;

        default:
          throw VendorServiceException(
            'Failed to fetch vendor details.',
            statusCode: response.statusCode,
          );
      }
    } on VendorServiceException {
      rethrow;
    } catch (e) {
      throw VendorServiceException('Something went wrong while checking the email: $e');
    }
  }
}