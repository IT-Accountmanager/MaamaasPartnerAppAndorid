import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../api/ApiClient.dart'; // ← adjust import path to your project structure
import '../CateringModels/PackageItem.dart';
import '../CateringModels/package_model.dart';

class CateringService {
  static const _secureStorage = FlutterSecureStorage();

  // ── Vendor ID ──────────────────────────────────────────────────────────────

  static Future<int?> getVendorId() async {
    // Try stored vendor_id first
    final stored = await _secureStorage.read(key: 'vendor_id');
    if (stored != null) {
      final parsed = int.tryParse(stored);
      if (parsed != null) return parsed;
    }

    // Fallback: decode from JWT payload
    final token = await _secureStorage.read(key: 'token');
    if (token == null || token.isEmpty) return null;

    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final payload = utf8.decode(
        base64Url.decode(base64Url.normalize(parts[1])),
      );
      final data = jsonDecode(payload) as Map<String, dynamic>;
      final id = data['id'];
      if (id is int) return id;
      if (id is String) return int.tryParse(id);
    } catch (_) {}

    return null;
  }

  // ── GET packages ───────────────────────────────────────────────────────────

  static Future<List<PackageModel>> getPackagesByVendor(int vendorId) async {
    final response = await ApiClient.get(
      'api/package/$vendorId',
      service: 'catering',
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body) as List;
      return data
          .map((e) => PackageModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    throw Exception(
      'Failed to load packages (${response.statusCode}): ${response.body}',
    );
  }

  // ── CREATE package ─────────────────────────────────────────────────────────


  static Future<PackageModel> createPackage({
    required int vendorId,
    required String packageName,
    required String packageType,
    required List<PackageItemModel> items,
    required double totalPrice,
    String? companyName,
    File? imageFile,
  }) async {
    final body = <String, dynamic>{
      'vendorId': vendorId,
      'packageName': packageName,
      'packageType': packageType,
      if (companyName != null && companyName.isNotEmpty)
        'companyName': companyName,
      'items': items.map((i) => i.toJson()).toList(),
      'totalPrice': totalPrice,
    };

    final response = imageFile != null
        ? await ApiClient.sendMultipartRequest(
      endpoint: 'api/package',
      method: 'POST',
      service: 'catering',
      data: {'data': jsonEncode(body)},
      files: {'image': imageFile},
    )
        : await ApiClient.post(
      'api/package',
      body,
      service: 'catering',
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return PackageModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }

    throw Exception(
      'Failed to create package (${response.statusCode}): ${response.body}',
    );
  }

  // ── UPDATE package ─────────────────────────────────────────────────────────


  static Future<PackageModel> updatePackage({
    required int vendorId,
    required int packageId,
    required String packageName,
    required String packageType,
    required List<PackageItemModel> items,
    required double totalPrice,
    String? companyName,
    String? existingImageUrl,
    File? imageFile,
  }) async {
    final body = <String, dynamic>{
      'id': packageId,
      'vendorId': vendorId,
      'packageName': packageName,
      'packageType': packageType,
      if (companyName != null && companyName.isNotEmpty)
        'companyName': companyName,
      'items': items.map((i) => i.toJson()).toList(),
      'totalPrice': totalPrice,
      // Only include image when NOT uploading a new file
      if (imageFile == null &&
          existingImageUrl != null &&
          existingImageUrl.isNotEmpty)
        'image': existingImageUrl,
    };

    final response = imageFile != null
        ? await ApiClient.sendMultipartRequest(
      endpoint: 'api/vendor/$vendorId/$packageId',
      method: 'PUT',
      service: 'catering',
      data: {'data': jsonEncode(body)},
      files: {'image': imageFile},
    )
        : await ApiClient.put(
      'api/vendor/$vendorId/$packageId',
      body,
      service: 'catering',
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      // Re-fetch to get fresh signed S3 image URLs
      try {
        final refreshed = await getPackagesByVendor(vendorId);
        return refreshed.firstWhere(
              (p) => p.id == packageId,
          orElse: () => PackageModel.fromJson(
            jsonDecode(response.body) as Map<String, dynamic>,
          ),
        );
      } catch (_) {
        return PackageModel.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
      }
    }

    throw Exception(
      'Failed to update package (${response.statusCode}): ${response.body}',
    );
  }

  // ── DELETE package ─────────────────────────────────────────────────────────

  /// DELETE /catering/api/vendor/items/{vendorId}/{packageId}
  static Future<bool> deletePackage(int packageId) async {
    try {
      final vendorId = await getVendorId();
      if (vendorId == null) return false;

      final response = await ApiClient.delete(
        'api/vendor/items/$vendorId/$packageId',
        service: 'catering',
      );

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }
}