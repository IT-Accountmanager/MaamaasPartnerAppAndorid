import 'dart:convert';
import '../../API/Apiclient.dart';
import '../models/models.dart';

/// ABOUT US
class AboutUsApi {
  static Future<AboutUsModel?> get() async {
    final vid = await _vendorId();

    final res = await ApiClient.get('food/api/aboutus/$vid', service: 'food');

    if (res.statusCode == 200) {
      return AboutUsModel.fromJson(jsonDecode(res.body));
    }
    return null;
  }

  static Future<void> create(String text, List<int>? imageBytes) async {
    final vid = await _vendorId();

    final payload = {'aboutUs': text, 'vendorId': int.tryParse(vid)};

    final res = await ApiClient.post('food/api/aboutus/add/$vid', {
      'aboutUsData': jsonEncode(payload),
      if (imageBytes != null) 'image': imageBytes,
    }, service: 'food');

    if (res.statusCode >= 300) {
      throw Exception('Failed to create about us');
    }
  }

  static Future<void> update(
    int id,
    String text,
    List<int>? imageBytes,
    String? existingImg,
  ) async {
    final payload = {'aboutUsId': id, 'aboutUs': text};

    final res = await ApiClient.put(
      'food/api/aboutus/edit/$id',
      payload,
      service: 'food',
    );

    if (res.statusCode >= 300) {
      throw Exception('Failed to update about us');
    }
  }
}

/// BANNER

class BannerApi {
  static Future<BannerModel?> get() async {
    final vid = await _vendorId();

    final res = await ApiClient.get('food/api/banner/$vid', service: 'food');

    if (res.statusCode == 200) {
      return BannerModel.fromJson(jsonDecode(res.body));
    }
    return null;
  }

  static Future<void> save(
    BannerModel data, {
    List<int>? bannerBytes,
    List<int>? logoBytes,
  }) async {
    final vid = await _vendorId();
    final isEdit = data.bannerId != null;

    final endpoint = isEdit
        ? 'food/api/vendor/banner/edit/${data.bannerId}'
        : 'food/api/vendor/banner/add/$vid';

    final payload = {
      'bannerId': data.bannerId ?? 0,
      'companyName': data.companyName,
      'establishedYear': data.establishedYear,
      'instagramLink': data.instagramLink ?? '',
      'youtubeLink': data.youtubeLink ?? '',
      'linkedinLink': data.linkedinLink ?? '',
      'facebookLink': data.facebookLink ?? '',
      'twitterLink': data.twitterLink ?? '',
      'whatsappLink': data.whatsappLink ?? '',
    };

    final res = await ApiClient.post(endpoint, {
      'bannerData': jsonEncode(payload),
      if (bannerBytes != null) 'companyBanner': bannerBytes,
      if (logoBytes != null) 'companyLogo': logoBytes,
    }, service: 'food');

    if (res.statusCode >= 300) {
      throw Exception('Failed to save banner');
    }
  }
}

/// MISSION / VISION
class MissionVisionApi {
  static Future<MissionVisionModel?> get() async {
    final vid = await _vendorId();

    final res = await ApiClient.get(
      'food/api/missionvision/$vid',
      service: 'food',
    );

    if (res.statusCode == 200) {
      return MissionVisionModel.fromJson(jsonDecode(res.body));
    }
    return null;
  }

  static Future<void> update({
    required int id,
    required String mission,
    required String vision,
    List<int>? missionImgBytes,
    List<int>? visionImgBytes,
  }) async {
    final payload = {'aboutUsId': id, 'mission': mission, 'vision': vision};

    final res = await ApiClient.put(
      'food/api/missionvision/edit/$id',
      payload,
      service: 'food',
    );

    if (res.statusCode >= 300) {
      throw Exception('Failed to update mission/vision');
    }
  }
}

/// GALLERY

class GalleryApi {
  static Future<GalleryModel?> get() async {
    final vid = await _vendorId();

    final res = await ApiClient.get('food/api/aboutus/$vid', service: 'food');

    if (res.statusCode == 200) {
      return GalleryModel.fromJson(jsonDecode(res.body));
    }
    return null;
  }

  static Future<void> updateImage(
    int aboutUsId,
    String field,
    List<int> imageBytes,
  ) async {
    final res = await ApiClient.put('food/api/gallery/edit/$aboutUsId', {
      'aboutUsId': aboutUsId,
      field: imageBytes,
    }, service: 'food');

    if (res.statusCode >= 300) {
      throw Exception('Failed to update gallery image');
    }
  }
}

/// TEAM

class TeamApi {
  static Future<List<TeamMember>> getAll() async {
    final vid = await _vendorId();

    final res = await ApiClient.get('food/api/team/$vid', service: 'food');

    if (res.statusCode == 200) {
      final list = jsonDecode(res.body) as List;
      return list.map((e) => TeamMember.fromJson(e)).toList();
    }

    return [];
  }

  static Future<void> add({
    required String name,
    required String designation,
    required String description,
    List<int>? imageBytes,
  }) async {
    final vid = await _vendorId();

    final res = await ApiClient.post('food/api/team/add/$vid', {
      'teamData': jsonEncode({
        'name': name,
        'designation': designation,
        'description': description,
        'vendorId': int.tryParse(vid),
      }),
      if (imageBytes != null) 'image': imageBytes,
    }, service: 'food');

    if (res.statusCode >= 300) {
      throw Exception('Failed to add member');
    }
  }

  static Future<void> update({
    required int teamId,
    required String name,
    required String designation,
    required String description,
    List<int>? imageBytes,
  }) async {
    final res = await ApiClient.put('food/api/team/edit/$teamId', {
      'teamId': teamId,
      'name': name,
      'designation': designation,
      'description': description,
    }, service: 'food');

    if (res.statusCode >= 300) {
      throw Exception('Failed to update member');
    }
  }

  static Future<void> delete(int teamId) async {
    final res = await ApiClient.delete(
      'food/api/team/delete/$teamId',
      service: 'food',
    );

    if (res.statusCode >= 300) {
      throw Exception('Failed to delete member');
    }
  }
}

/// REGISTRATION

class RegistrationApi {
  static Future<Map<String, dynamic>?> getVendorDetails() async {
    final vid = await _vendorId();

    final res = await ApiClient.get(
      'subscription/api/vendor/get/$vid',
      service: 'subscription',
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }

    return null;
  }

  static Future<void> submit(
    Map<String, dynamic> payload, {
    Map<String, List<int>> docs = const {},
  }) async {
    final vid = await _vendorId();

    final res = await ApiClient.post('subscription/api/vendor/register/$vid', {
      'vendorData': jsonEncode(payload),
      ...docs,
    }, service: 'subscription');

    if (res.statusCode >= 300) {
      throw Exception('Registration failed');
    }
  }

  static Future<void> updateAddress(Map<String, dynamic> addressData) async {
    final vid = await _vendorId();

    final res = await ApiClient.put(
      'subscription/api/vendor/address/$vid',
      addressData,
      service: 'subscription',
    );

    if (res.statusCode >= 300) {
      throw Exception('Address update failed');
    }
  }

  static Future<void> updateBankDetails(
    Map<String, dynamic> bankData, {
    List<int>? passbookBytes,
  }) async {
    final vid = await _vendorId();

    final res = await ApiClient.put(
      'subscription/api/vendor/bank/$vid',
      bankData,
      service: 'subscription',
    );

    if (res.statusCode >= 300) {
      throw Exception('Bank update failed');
    }
  }
}

Future<String> _vendorId() async {
  return '';
}
