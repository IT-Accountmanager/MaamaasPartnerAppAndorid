// import 'dart:convert';
// import 'package:flutter/foundation.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import '../models/models.dart';
//
// // const String _base = 'http://staging.maamaas.com:8080';
// const String _subscBase = 'http://staging.maamaas.com:8080/subscription';
// const _ss = FlutterSecureStorage();
//
// // ─── Auth helpers ─────────────────────────────────────────────────────────────
// Future<String> _getToken() async {
//   String? t = await _ss.read(key: 'token');
//   if (t == null || t.isEmpty) {
//     final p = await SharedPreferences.getInstance();
//     t = p.getString('token');
//   }
//   return t ?? '';
// }
//
// Future<String> _getVendorId() async {
//   String? id = await _ss.read(key: 'vendorId');
//   if (id == null || id.isEmpty) {
//     final p = await SharedPreferences.getInstance();
//     id = p.getInt('vendorId')?.toString();
//   }
//   return id ?? '';
// }
//
// Future<Map<String, String>> _headers() async {
//   final t = await _getToken();
//   return {
//     'Content-Type': 'application/json',
//     'Accept': 'application/json',
//     'Authorization': 'Bearer $t',
//   };
// }
//
// Future<Map<String, String>> _authHeader() async {
//   final t = await _getToken();
//   return {'Authorization': 'Bearer $t', 'Accept': 'application/json'};
// }
//
// Future<String?> _refreshToken() async {
//   try {
//     final rt = await _ss.read(key: 'refreshToken');
//     if (rt == null || rt.isEmpty) return null;
//     final res = await http.post(
//       Uri.parse('$_subscBase/api/auth/refresh?refreshTokenmobile=$rt'),
//       headers: {'Content-Type': 'application/json'},
//     );
//     if (res.statusCode == 200) {
//       final d = jsonDecode(res.body);
//       final nt = d['token'] as String?;
//       if (nt != null) {
//         await _ss.write(key: 'token', value: nt);
//         final p = await SharedPreferences.getInstance();
//         await p.setString('token', nt);
//       }
//       return nt;
//     }
//   } catch (e) {
//     debugPrint('Refresh error: $e');
//   }
//   return null;
// }
//
// Future<http.Response> _get(String url) async {
//   final h = await _headers();
//   var r = await http.get(Uri.parse(url), headers: h);
//   if (r.statusCode == 401 || r.statusCode == 403) {
//     final nt = await _refreshToken();
//     if (nt != null) {
//       r = await http.get(
//         Uri.parse(url),
//         headers: {...h, 'Authorization': 'Bearer $nt'},
//       );
//     }
//   }
//   return r;
// }
//
// Future<http.Response> _put(String url, Map<String, dynamic> body) async {
//   final h = await _headers();
//   var r = await http.put(Uri.parse(url), headers: h, body: jsonEncode(body));
//   if (r.statusCode == 401 || r.statusCode == 403) {
//     final nt = await _refreshToken();
//     if (nt != null) {
//       r = await http.put(
//         Uri.parse(url),
//         headers: {...h, 'Authorization': 'Bearer $nt'},
//         body: jsonEncode(body),
//       );
//     }
//   }
//   return r;
// }
//
// Future<http.StreamedResponse> _multipartPost(
//   String url,
//   String fieldName,
//   String jsonBody, {
//   Map<String, dynamic>? files,
// }) async {
//   final tok = await _getToken();
//   final req = http.MultipartRequest('POST', Uri.parse(url))
//     ..headers['Authorization'] = 'Bearer $tok'
//     ..files.add(
//       http.MultipartFile.fromString(
//         fieldName,
//         jsonBody,
//         contentType: http.MediaType('application', 'json'),
//       ),
//     );
//   if (files != null) {
//     for (final e in files.entries) {
//       if (e.value is List<int>) {
//         req.files.add(
//           http.MultipartFile.fromBytes(
//             e.key,
//             e.value as List<int>,
//             filename: e.key,
//           ),
//         );
//       }
//     }
//   }
//   return req.send();
// }
//
// Future<http.StreamedResponse> _multipartPut(
//   String url,
//   String fieldName,
//   String jsonBody, {
//   Map<String, dynamic>? files,
// }) async {
//   final tok = await _getToken();
//   final req = http.MultipartRequest('PUT', Uri.parse(url))
//     ..headers['Authorization'] = 'Bearer $tok'
//     ..files.add(
//       http.MultipartFile.fromString(
//         fieldName,
//         jsonBody,
//         contentType: http.MediaType('application', 'json'),
//       ),
//     );
//   if (files != null) {
//     for (final e in files.entries) {
//       if (e.value is List<int>) {
//         req.files.add(
//           http.MultipartFile.fromBytes(
//             e.key,
//             e.value as List<int>,
//             filename: e.key,
//           ),
//         );
//       }
//     }
//   }
//   return req.send();
// }
//
// // ─── About Us Service ──────────────────────────────────────────────────────────
// class AboutUsApi {
//   static Future<AboutUsModel?> get() async {
//     final vid = await _getVendorId();
//     final r = await _get('$_subscBase/food/api/aboutus/$vid');
//     if (r.statusCode == 200) {
//       return AboutUsModel.fromJson(jsonDecode(r.body));
//     }
//     return null;
//   }
//
//   static Future<void> create(String text, List<int>? imageBytes) async {
//     final vid = await _getVendorId();
//     final body = jsonEncode({'aboutUs': text, 'vendorId': int.tryParse(vid)});
//     final files = imageBytes != null ? {'image': imageBytes} : null;
//     final r = await _multipartPost(
//       '$_subscBase/food/api/aboutus/add/$vid',
//       'aboutUsData',
//       body,
//       files: files,
//     );
//     if (r.statusCode >= 300) throw Exception('Failed to create about us');
//   }
//
//   static Future<void> update(
//     int id,
//     String text,
//     List<int>? imageBytes,
//     String? existingImg,
//   ) async {
//     final body = jsonEncode({'aboutUsId': id, 'aboutUs': text});
//     final files = imageBytes != null ? {'image': imageBytes} : null;
//     final r = await _multipartPut(
//       '$_subscBase/food/api/aboutus/edit/$id',
//       'aboutUsData',
//       body,
//       files: files,
//     );
//     if (r.statusCode >= 300) throw Exception('Failed to update about us');
//   }
// }
//
// // ─── Banner Service ────────────────────────────────────────────────────────────
// class BannerApi {
//   static Future<BannerModel?> get() async {
//     final vid = await _getVendorId();
//     final r = await _get('$_subscBase/food/api/banner/$vid');
//     if (r.statusCode == 200) return BannerModel.fromJson(jsonDecode(r.body));
//     return null;
//   }
//
//   static Future<void> save(
//     BannerModel data, {
//     List<int>? bannerBytes,
//     List<int>? logoBytes,
//   }) async {
//     final vid = await _getVendorId();
//     final isEdit = data.bannerId != null;
//     final url = isEdit
//         ? '$_subscBase/food/api/vendor/banner/edit/${data.bannerId}'
//         : '$_subscBase/food/api/vendor/banner/add/$vid';
//
//     final body = jsonEncode({
//       'bannerId': data.bannerId ?? 0,
//       'companyName': data.companyName,
//       'establishedYear': data.establishedYear,
//       'instagramLink': data.instagramLink ?? '',
//       'youtubeLink': data.youtubeLink ?? '',
//       'linkedinLink': data.linkedinLink ?? '',
//       'facebookLink': data.facebookLink ?? '',
//       'twitterLink': data.twitterLink ?? '',
//       'whatsappLink': data.whatsappLink ?? '',
//     });
//
//     final files = <String, dynamic>{};
//     if (bannerBytes != null) files['companyBanner'] = bannerBytes;
//     if (logoBytes != null) files['companyLogo'] = logoBytes;
//
//     final r = isEdit
//         ? await _multipartPut(url, 'bannerData', body, files: files)
//         : await _multipartPost(url, 'bannerData', body, files: files);
//
//     if (r.statusCode >= 300) throw Exception('Failed to save banner');
//   }
// }
//
// // ─── Mission Vision Service ────────────────────────────────────────────────────
// class MissionVisionApi {
//   static Future<MissionVisionModel?> get() async {
//     final vid = await _getVendorId();
//     final r = await _get('$_subscBase/food/api/missionvision/$vid');
//     if (r.statusCode == 200) {
//       return MissionVisionModel.fromJson(jsonDecode(r.body));
//     }
//     return null;
//   }
//
//   static Future<void> update({
//     required int id,
//     required String mission,
//     required String vision,
//     List<int>? missionImgBytes,
//     List<int>? visionImgBytes,
//   }) async {
//     final body = jsonEncode({
//       'aboutUsId': id,
//       'mission': mission,
//       'vision': vision,
//     });
//     final files = <String, dynamic>{};
//     if (missionImgBytes != null) files['missionImage'] = missionImgBytes;
//     if (visionImgBytes != null) files['visionImage'] = visionImgBytes;
//
//     final r = await _multipartPut(
//       '$_subscBase/food/api/missionvision/edit/$id',
//       'aboutUsData',
//       body,
//       files: files,
//     );
//     if (r.statusCode >= 300) throw Exception('Failed to update mission/vision');
//   }
// }
//
// // ─── Gallery Service ───────────────────────────────────────────────────────────
// class GalleryApi {
//   static Future<GalleryModel?> get() async {
//     final vid = await _getVendorId();
//     final r = await _get('$_subscBase/food/api/aboutus/$vid');
//     if (r.statusCode == 200) return GalleryModel.fromJson(jsonDecode(r.body));
//     return null;
//   }
//
//   static Future<void> updateImage(
//     int aboutUsId,
//     String field,
//     List<int> imageBytes,
//   ) async {
//     final body = jsonEncode({'aboutUsId': aboutUsId});
//     final files = {field: imageBytes};
//     final r = await _multipartPut(
//       '$_subscBase/food/api/gallery/edit/$aboutUsId',
//       'aboutUsData',
//       body,
//       files: files,
//     );
//     if (r.statusCode >= 300) throw Exception('Failed to update gallery image');
//   }
// }
//
// // ─── Team Service ──────────────────────────────────────────────────────────────
// class TeamApi {
//   static Future<List<TeamMember>> getAll() async {
//     final vid = await _getVendorId();
//     final r = await _get('$_subscBase/food/api/team/$vid');
//     if (r.statusCode == 200) {
//       final List<dynamic> list = jsonDecode(r.body);
//       return list.map((e) => TeamMember.fromJson(e)).toList();
//     }
//     return [];
//   }
//
//   static Future<void> add({
//     required String name,
//     required String designation,
//     required String description,
//     List<int>? imageBytes,
//   }) async {
//     final vid = await _getVendorId();
//     final body = jsonEncode({
//       'name': name,
//       'designation': designation,
//       'description': description,
//       'vendorId': int.tryParse(vid),
//     });
//     final files = imageBytes != null ? {'image': imageBytes} : null;
//     final r = await _multipartPost(
//       '$_subscBase/food/api/team/add/$vid',
//       'teamData',
//       body,
//       files: files,
//     );
//     if (r.statusCode >= 300) throw Exception('Failed to add member');
//   }
//
//   static Future<void> update({
//     required int teamId,
//     required String name,
//     required String designation,
//     required String description,
//     List<int>? imageBytes,
//   }) async {
//     final body = jsonEncode({
//       'teamId': teamId,
//       'name': name,
//       'designation': designation,
//       'description': description,
//     });
//     final files = imageBytes != null ? {'image': imageBytes} : null;
//     final r = await _multipartPut(
//       '$_subscBase/food/api/team/edit/$teamId',
//       'teamData',
//       body,
//       files: files,
//     );
//     if (r.statusCode >= 300) throw Exception('Failed to update member');
//   }
//
//   static Future<void> delete(int teamId) async {
//     final h = await _authHeader();
//     final r = await http.delete(
//       Uri.parse('$_subscBase/food/api/team/delete/$teamId'),
//       headers: h,
//     );
//     if (r.statusCode >= 300) throw Exception('Failed to delete member');
//   }
// }
//
// // ─── Registration Service ──────────────────────────────────────────────────────
// class RegistrationApi {
//   static Future<Map<String, dynamic>?> getVendorDetails() async {
//     final vid = await _getVendorId();
//     final r = await _get('$_subscBase/subscription/api/vendor/get/$vid');
//     if (r.statusCode == 200) return jsonDecode(r.body);
//     return null;
//   }
//
//   static Future<void> submit(
//     Map<String, dynamic> payload, {
//     Map<String, List<int>> docs = const {},
//   }) async {
//     final vid = await _getVendorId();
//     final tok = await _getToken();
//     final uri = Uri.parse('$_subscBase/subscription/api/vendor/register/$vid');
//     final req = http.MultipartRequest('POST', uri)
//       ..headers['Authorization'] = 'Bearer $tok'
//       ..files.add(
//         http.MultipartFile.fromString(
//           'vendorData',
//           jsonEncode(payload),
//           contentType: http.MediaType('application', 'json'),
//         ),
//       );
//     for (final e in docs.entries) {
//       req.files.add(
//         http.MultipartFile.fromBytes(e.key, e.value, filename: e.key),
//       );
//     }
//     final r = await req.send();
//     if (r.statusCode >= 300) throw Exception('Registration failed');
//   }
//
//   static Future<void> updateAddress(Map<String, dynamic> addressData) async {
//     final vid = await _getVendorId();
//     final r = await _put(
//       '$_subscBase/subscription/api/vendor/address/$vid',
//       addressData,
//     );
//     if (r.statusCode >= 300) throw Exception('Address update failed');
//   }
//
//   static Future<void> updateBankDetails(
//     Map<String, dynamic> bankData, {
//     List<int>? passbookBytes,
//   }) async {
//     final vid = await _getVendorId();
//     final body = jsonEncode(bankData);
//     final files = passbookBytes != null ? {'passbook': passbookBytes} : null;
//     final r = await _multipartPut(
//       '$_subscBase/subscription/api/vendor/bank/$vid',
//       'bankData',
//       body,
//       files: files,
//     );
//     if (r.statusCode >= 300) throw Exception('Bank update failed');
//   }
// }
// import 'dart:convert';
// import 'dart:io';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../../API/Apiclient.dart';
// import '../models/models.dart';
//
// const String _subscBase = 'subscription';
//
// class AboutUsApi {
//   static Future<AboutUsModel?> get() async {
//     final prefs = await SharedPreferences.getInstance();
//     final vendorId = prefs.getInt('vendorId');
//     final res = await ApiClient.get(
//       'food/api/aboutus/$vendorId',
//       service: _subscBase,
//     );
//
//     if (res.statusCode == 200) {
//       return AboutUsModel.fromJson(jsonDecode(res.body));
//     }
//     return null;
//   }
//
//   static Future<void> create(String text, File? imageFile) async {
//     final prefs = await SharedPreferences.getInstance();
//     final vendorId = prefs.getInt('vendorId');
//
//     final res = await ApiClient.sendMultipartRequest(
//       endpoint: 'food/api/aboutus/add/$vendorId',
//       service: _subscBase,
//       method: 'POST',
//       data: {
//         'aboutUsData': jsonEncode({
//           'aboutUs': text,
//           'vendorId': vendorId,
//         }),
//       },
//       files: imageFile != null ? {'image': imageFile} : null,
//     );
//
//     if (res.statusCode >= 300) {
//       throw Exception('Failed to create about us');
//     }
//   }
//
//   static Future<void> update(int id,
//       String text,
//       File? imageFile,
//       String? existingImg,) async {
//     final res = await ApiClient.sendMultipartRequest(
//       endpoint: 'food/api/aboutus/edit/$id',
//       service: _subscBase,
//       method: 'PUT',
//       data: {
//         'aboutUsData': jsonEncode({
//           'aboutUsId': id,
//           'aboutUs': text,
//         }),
//       },
//       files: imageFile != null ? {'image': imageFile} : null,
//     );
//
//     if (res.statusCode >= 300) {
//       throw Exception('Failed to update about us');
//     }
//   }
// }
//
// // ═════════════════════════════════════════════════════════════
//
// class BannerApi {
//   static Future<BannerModel?> get() async {
//     final prefs = await SharedPreferences.getInstance();
//     final vendorId = prefs.getInt('vendorId');
//     final res = await ApiClient.get(
//       'food/api/banner/$vendorId',
//       service: _subscBase,
//     );
//
//     if (res.statusCode == 200) {
//       return BannerModel.fromJson(jsonDecode(res.body));
//     }
//     return null;
//   }
// }
//
// // ═════════════════════════════════════════════════════════════
//
// class MissionVisionApi {
//   static Future<MissionVisionModel?> get() async {
//     final prefs = await SharedPreferences.getInstance();
//     final vendorId = prefs.getInt('vendorId');
//
//     final res = await ApiClient.get(
//       'food/api/missionvision/$vendorId',
//       service: _subscBase,
//     );
//
//     if (res.statusCode == 200) {
//       return MissionVisionModel.fromJson(jsonDecode(res.body));
//     }
//     return null;
//   }
// }
//
// // ═════════════════════════════════════════════════════════════
//
// class GalleryApi {
//   static Future<GalleryModel?> get() async {
//     final prefs = await SharedPreferences.getInstance();
//     final vendorId = prefs.getInt('vendorId');
//
//     final res = await ApiClient.get(
//       'food/api/aboutus/$vendorId',
//       service: _subscBase,
//     );
//
//     if (res.statusCode == 200) {
//       return GalleryModel.fromJson(jsonDecode(res.body));
//     }
//     return null;
//   }
// }
//
// // ═════════════════════════════════════════════════════════════
//
// class TeamApi {
//   static Future<List<TeamMember>> getAll() async {
//     final prefs = await SharedPreferences.getInstance();
//     final vendorId = prefs.getInt('vendorId');
//
//     final res = await ApiClient.get(
//       'food/api/team/$vendorId',
//       service: _subscBase,
//     );
//
//     if (res.statusCode == 200) {
//       final list = jsonDecode(res.body) as List;
//       return list.map((e) => TeamMember.fromJson(e)).toList();
//     }
//     return [];
//   }
// }
//
// // ═════════════════════════════════════════════════════════════
//
// class RegistrationApi {
//   static Future<Map<String, dynamic>?> getVendorDetails() async {
//     final prefs = await SharedPreferences.getInstance();
//     final vendorId = prefs.getInt('vendorId');
//
//     final res = await ApiClient.get(
//       'subscription/api/vendor/get/$vendorId',
//       service: _subscBase,
//     );
//
//     if (res.statusCode == 200) {
//       return jsonDecode(res.body);
//     }
//     return null;
//   }
// }


import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../../API/Apiclient.dart';
import '../models/models.dart';

/// ─────────────────────────────────────────
/// COMMON
/// ─────────────────────────────────────────
Future<String> _getVendorId() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getInt('vendorId')?.toString() ?? '';
}

/// ─────────────────────────────────────────
/// ABOUT US
/// ─────────────────────────────────────────
class AboutUsApi {
  static Future<AboutUsModel?> get() async {
    final vid = await _getVendorId();
    final res = await ApiClient.get("food/api/aboutus/$vid");

    if (res.statusCode == 200) {
      return AboutUsModel.fromJson(jsonDecode(res.body));
    }
    return null;
  }

  static Future<void> save({
    int? id,
    required String text,
    File? image,
  }) async {
    final vid = await _getVendorId();

    final endpoint = id == null
        ? "food/api/aboutus/add/$vid"
        : "food/api/aboutus/edit/$id";

    final res = await ApiClient.sendMultipartRequest(
      endpoint: endpoint,
      method: id == null ? "POST" : "PUT",
      service: "subscription",
      data: {
        "aboutUsData": jsonEncode({
          if (id != null) "aboutUsId": id,
          "aboutUs": text,
          "vendorId": int.tryParse(vid),
        }),
      },
      files: image != null ? {"image": image} : null,
    );

    if (res.statusCode >= 300) {
      throw Exception("About Us save failed");
    }
  }
}

/// ─────────────────────────────────────────
/// BANNER
/// ─────────────────────────────────────────
class BannerApi {
  static Future<BannerModel?> get() async {
    final vid = await _getVendorId();
    final res = await ApiClient.get("food/api/banner/$vid");

    if (res.statusCode == 200) {
      return BannerModel.fromJson(jsonDecode(res.body));
    }
    return null;
  }

  static Future<void> save(
      BannerModel data, {
        File? banner,
        File? logo,
      }) async {
    final vid = await _getVendorId();

    final endpoint = data.bannerId == null
        ? "food/api/vendor/banner/add/$vid"
        : "food/api/vendor/banner/edit/${data.bannerId}";

    final res = await ApiClient.sendMultipartRequest(
      endpoint: endpoint,
      method: data.bannerId == null ? "POST" : "PUT",
      service: "subscription",
      data: {
        "bannerData": jsonEncode({
          "bannerId": data.bannerId ?? 0,
          "companyName": data.companyName,
          "establishedYear": data.establishedYear,
          "instagramLink": data.instagramLink ?? "",
          "youtubeLink": data.youtubeLink ?? "",
          "linkedinLink": data.linkedinLink ?? "",
          "facebookLink": data.facebookLink ?? "",
          "twitterLink": data.twitterLink ?? "",
          "whatsappLink": data.whatsappLink ?? "",
        }),
      },
      files: {
        if (banner != null) "companyBanner": banner,
        if (logo != null) "companyLogo": logo,
      },
    );

    if (res.statusCode >= 300) {
      throw Exception("Banner save failed");
    }
  }
}

/// ─────────────────────────────────────────
/// MISSION & VISION
/// ─────────────────────────────────────────
class MissionVisionApi {
  static Future<MissionVisionModel?> get() async {
    final vid = await _getVendorId();
    final res = await ApiClient.get("food/api/missionvision/$vid");

    if (res.statusCode == 200) {
      return MissionVisionModel.fromJson(jsonDecode(res.body));
    }
    return null;
  }

  static Future<void> update({
    required int id,
    required String mission,
    required String vision,
    File? missionImg,
    File? visionImg,
  }) async {
    final res = await ApiClient.sendMultipartRequest(
      endpoint: "food/api/missionvision/edit/$id",
      method: "PUT",
      service: "subscription",
      data: {
        "aboutUsData": jsonEncode({
          "aboutUsId": id,
          "mission": mission,
          "vision": vision,
        }),
      },
      files: {
        if (missionImg != null) "missionImage": missionImg,
        if (visionImg != null) "visionImage": visionImg,
      },
    );

    if (res.statusCode >= 300) {
      throw Exception("Mission/Vision update failed");
    }
  }
}

/// ─────────────────────────────────────────
/// TEAM
/// ─────────────────────────────────────────
class TeamApi {
  static Future<List<TeamMember>> getAll() async {
    final vid = await _getVendorId();
    final res = await ApiClient.get("food/api/team/$vid");

    if (res.statusCode == 200) {
      final list = jsonDecode(res.body) as List;
      return list.map((e) => TeamMember.fromJson(e)).toList();
    }
    return [];
  }

  static Future<void> save({
    int? teamId,
    required String name,
    required String designation,
    required String description,
    File? image,
  }) async {
    final vid = await _getVendorId();

    final endpoint = teamId == null
        ? "food/api/team/add/$vid"
        : "food/api/team/edit/$teamId";

    final res = await ApiClient.sendMultipartRequest(
      endpoint: endpoint,
      method: teamId == null ? "POST" : "PUT",
      service: "subscription",
      data: {
        "teamData": jsonEncode({
          if (teamId != null) "teamId": teamId,
          "name": name,
          "designation": designation,
          "description": description,
          "vendorId": int.tryParse(vid),
        }),
      },
      files: image != null ? {"image": image} : null,
    );

    if (res.statusCode >= 300) {
      throw Exception("Team save failed");
    }
  }

  static Future<void> delete(int teamId) async {
    final res = await ApiClient.delete(
      "food/api/team/delete/$teamId",
    );

    if (res.statusCode >= 300) {
      throw Exception("Delete failed");
    }
  }
}

/// ─────────────────────────────────────────
/// REGISTRATION
/// ─────────────────────────────────────────
class RegistrationApi {
  static Future<Map<String, dynamic>?> getVendorDetails() async {
    final vid = await _getVendorId();
    final res =
    await ApiClient.get("subscription/api/vendor/get/$vid");

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    return null;
  }

  static Future<void> submit(
      Map<String, dynamic> payload, {
        Map<String, File> docs = const {},
      }) async {
    final vid = await _getVendorId();

    final res = await ApiClient.sendMultipartRequest(
      endpoint: "subscription/api/vendor/register/$vid",
      method: "POST",
      service: "subscription",
      data: {
        "vendorData": jsonEncode(payload),
      },
      files: docs,
    );

    if (res.statusCode >= 300) {
      throw Exception("Registration failed");
    }
  }

  static Future<void> updateAddress(
      Map<String, dynamic> data) async {
    final vid = await _getVendorId();

    final res = await ApiClient.put(
      "subscription/api/vendor/address/$vid",
      data,
      service: "subscription",
    );

    if (res.statusCode >= 300) {
      throw Exception("Address update failed");
    }
  }

  static Future<void> updateBank(
      Map<String, dynamic> data, {
        File? passbook,
      }) async {
    final vid = await _getVendorId();

    final res = await ApiClient.sendMultipartRequest(
      endpoint: "subscription/api/vendor/bank/$vid",
      method: "PUT",
      service: "subscription",
      data: {
        "bankData": jsonEncode(data),
      },
      files: passbook != null ? {"passbook": passbook} : null,
    );

    if (res.statusCode >= 300) {
      throw Exception("Bank update failed");
    }
  }
}