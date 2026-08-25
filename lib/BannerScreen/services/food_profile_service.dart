import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../API/Apiclient.dart';
import '../models/food_profile_models.dart';

class FoodProfileService {
  static const String _service = "food";
  static const String _base = "https://backend.maamaas.com";
  // static const String _base = "http://staging.maamaas.com:8080";

  static Future<int> _vid() async {
    final p = await SharedPreferences.getInstance();
    return p.getInt('vendorId') ??
        int.tryParse(p.getString('vendorId') ?? '') ??
        0;
  }

  static void _log(String tag, String msg) {
    // if (kDebugMode) debugPrint("🔵 [$tag] $msg");
  }

  static String fullImageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    if (path.startsWith('food/')) return '$_base/$path';
    return '$_base/food/$path';
  }

  static Future<BannerData?> getBanner() async {
    final vid = await _vid();

    final res = await ApiClient.get('api/banner/$vid', service: _service);

    if (res.statusCode != 200) return null;

    try {
      return BannerData.fromJson(jsonDecode(res.body));
    } catch (e) {
      _log("getBanner", "parse error: $e");
      return null;
    }
  }

  static Future<bool> saveBanner({
    required BannerData data,
    File? bannerFile,
    File? logoFile,
    required bool isEdit,
  }) async {
    final vid = await _vid();

    final endpoint = isEdit
        ? 'api/vendor/banner/edit/${data.bannerId}'
        : 'api/vendor/banner/add/$vid';

    final res = await ApiClient.sendMultipartRequest(
      endpoint: endpoint,
      method: isEdit ? 'PUT' : 'POST',
      service: _service,
      data: {
        "bannerData": jsonEncode({
          'bannerId': data.bannerId ?? 0,
          'companyName': data.companyName,
          'establishedYear': data.establishedYear,
          'instagramLink': data.instagramLink,
          'youtubeLink': data.youtubeLink,
          'linkedinLink': data.linkedinLink,
          'facebookLink': data.facebookLink,
          'twitterLink': data.twitterLink,
          'whatsappLink': data.whatsappLink,
        }),
      },
      files: {
        if (bannerFile != null) "companyBanner": bannerFile,
        if (logoFile != null) "companyLogo": logoFile,
      },
    );

    return res.statusCode >= 200 && res.statusCode < 300;
  }

  static Future<AboutUsData?> getAboutUs() async {
    final vid = await _vid();

    final res = await ApiClient.get(
      'api/vendor/aboutus/get/$vid',
      service: _service,
    );

    if (res.statusCode != 200) return null;

    try {
      return AboutUsData.fromJson(jsonDecode(res.body));
    } catch (e) {
      _log("getAboutUs", "parse error: $e");
      return null;
    }
  }

  static Future<bool> createAboutUs(String text, File? imageFile) async {
    final vid = await _vid();

    final res = await ApiClient.sendMultipartRequest(
      endpoint: 'api/vendor/aboutus/add/$vid',
      method: 'POST',
      service: _service,
      data: {
        "aboutUsData": jsonEncode({
          "aboutUsId": 0,
          "aboutUs": text,
          "vendorId": vid,
        }),
      },
      files: {if (imageFile != null) "image": imageFile},
    );

    return res.statusCode >= 200 && res.statusCode < 300;
  }

  static Future<bool> updateAboutUs(
    int aboutUsId,
    String text,
    File? imageFile,
  ) async {
    final res = await ApiClient.sendMultipartRequest(
      endpoint: 'api/vendor/aboutus/update/$aboutUsId',
      method: 'PUT',
      service: _service,
      data: {
        "aboutUsData": jsonEncode({"aboutUsId": aboutUsId, "aboutUs": text}),
      },
      files: {if (imageFile != null) "image": imageFile},
    );

    return res.statusCode >= 200 && res.statusCode < 300;
  }

  static Future<bool> updateMissionVision({
    required int aboutUsId,
    String? mission,
    String? vision,
    File? missionImage,
    File? visionImage,
  }) async {
    final res = await ApiClient.sendMultipartRequest(
      endpoint: 'api/vendor/aboutus/update/$aboutUsId',
      method: 'PUT',
      service: _service,
      data: {
        "aboutUsData": jsonEncode({
          "aboutUsId": aboutUsId,
          if (mission != null) "mission": mission,
          if (vision != null) "vision": vision,
        }),
      },
      files: {
        if (missionImage != null) "missionImage": missionImage,
        if (visionImage != null) "visionImage": visionImage,
      },
    );

    return res.statusCode >= 200 && res.statusCode < 300;
  }

  static Future<bool> addGalleryImage(int aboutUsId, File imageFile) async {
    final res = await ApiClient.sendMultipartRequest(
      endpoint: 'api/vendor/aboutus/update/$aboutUsId',
      method: 'PUT',
      service: _service,
      data: {
        "aboutUsData": jsonEncode({"aboutUsId": aboutUsId}),
      },
      files: {"images": imageFile},
    );

    return res.statusCode >= 200 && res.statusCode < 300;
  }

  static Future<bool> deleteGalleryImage(int imageId) async {
    final res = await ApiClient.delete(
      'api/aboutus/image/delete/$imageId',
      service: _service,
    );

    return res.statusCode >= 200 && res.statusCode < 300;
  }

  static Future<List<TeamMember>> getTeamMembers() async {
    final vid = await _vid();

    final res = await ApiClient.get(
      'api/adminteam/getall/$vid',
      service: _service,
    );

    if (res.statusCode != 200) return [];

    try {
      final list = jsonDecode(res.body) as List;
      return list.map((e) => TeamMember.fromJson(e)).toList();
    } catch (e) {
      _log("getTeamMembers", "parse error: $e");
      return [];
    }
  }

  static Future<bool> addTeamMember({
    required String name,
    required String designation,
    required String description,
    File? image,
  }) async {
    final vid = await _vid();

    final res = await ApiClient.sendMultipartRequest(
      endpoint: 'api/adminteam/addteam/$vid',
      method: 'POST',
      service: _service,
      data: {
        "teamData": jsonEncode({
          'teamId': 0,
          'vendorId': vid,
          'name': name,
          'designation': designation,
          'description': description,
          'image': '',
        }),
      },
      files: {if (image != null) "image": image},
    );

    return res.statusCode >= 200 && res.statusCode < 300;
  }

  static Future<bool> updateTeamMember({
    required int teamId,
    required int vendorId,
    required String name,
    required String designation,
    required String description,
    required String existingImage,
    File? image,
  }) async {
    final res = await ApiClient.sendMultipartRequest(
      endpoint: 'api/adminteam/editbyid/$teamId',
      method: 'PUT',
      service: _service,
      data: {
        "teamData": jsonEncode({
          'teamId': teamId,
          'vendorId': vendorId,
          'name': name,
          'designation': designation,
          'description': description,
          'image': existingImage,
        }),
      },
      files: {if (image != null) "image": image},
    );

    return res.statusCode >= 200 && res.statusCode < 300;
  }

  static Future<bool> deleteTeamMember(int teamId) async {
    final res = await ApiClient.delete(
      'api/adminteam/delete/$teamId',
      service: _service,
    );

    return res.statusCode >= 200 && res.statusCode < 300;
  }
}
