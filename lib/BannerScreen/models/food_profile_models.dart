// ─── Models ──────────────────────────────────────────────────────────────────

class BannerData {
  final int? bannerId;
  final String companyName;
  final String establishedYear;
  final String companyBanner;
  final String companyLogo;
  final String instagramLink;
  final String youtubeLink;
  final String linkedinLink;
  final String facebookLink;
  final String twitterLink;
  final String whatsappLink;

  BannerData({
    this.bannerId,
    this.companyName = '',
    this.establishedYear = '',
    this.companyBanner = '',
    this.companyLogo = '',
    this.instagramLink = '',
    this.youtubeLink = '',
    this.linkedinLink = '',
    this.facebookLink = '',
    this.twitterLink = '',
    this.whatsappLink = '',
  });

  factory BannerData.fromJson(Map<String, dynamic> j) => BannerData(
        bannerId: j['bannerId'],
        companyName: j['companyName'] ?? '',
        establishedYear: j['establishedYear'] ?? '',
        companyBanner: j['companyBanner'] ?? '',
        companyLogo: j['companyLogo'] ?? '',
        instagramLink: j['instagramLink'] ?? '',
        youtubeLink: j['youtubeLink'] ?? '',
        linkedinLink: j['linkedinLink'] ?? '',
        facebookLink: j['facebookLink'] ?? '',
        twitterLink: j['twitterLink'] ?? '',
        whatsappLink: j['whatsappLink'] ?? '',
      );

  BannerData copyWith({
    int? bannerId,
    String? companyName,
    String? establishedYear,
    String? companyBanner,
    String? companyLogo,
    String? instagramLink,
    String? youtubeLink,
    String? linkedinLink,
    String? facebookLink,
    String? twitterLink,
    String? whatsappLink,
  }) =>
      BannerData(
        bannerId: bannerId ?? this.bannerId,
        companyName: companyName ?? this.companyName,
        establishedYear: establishedYear ?? this.establishedYear,
        companyBanner: companyBanner ?? this.companyBanner,
        companyLogo: companyLogo ?? this.companyLogo,
        instagramLink: instagramLink ?? this.instagramLink,
        youtubeLink: youtubeLink ?? this.youtubeLink,
        linkedinLink: linkedinLink ?? this.linkedinLink,
        facebookLink: facebookLink ?? this.facebookLink,
        twitterLink: twitterLink ?? this.twitterLink,
        whatsappLink: whatsappLink ?? this.whatsappLink,
      );
}

class AboutUsData {
  final int? aboutUsId;
  final String aboutUs;
  final String image;
  final String mission;
  final String vision;
  final String missionImage;
  final String visionImage;
  final List<GalleryItem> images;

  AboutUsData({
    this.aboutUsId,
    this.aboutUs = '',
    this.image = '',
    this.mission = '',
    this.vision = '',
    this.missionImage = '',
    this.visionImage = '',
    this.images = const [],
  });

  factory AboutUsData.fromJson(Map<String, dynamic> j) => AboutUsData(
        aboutUsId: j['aboutUsId'],
        aboutUs: j['aboutUs'] ?? '',
        image: j['image'] ?? '',
        mission: j['mission'] ?? '',
        vision: j['vision'] ?? '',
        missionImage: j['missionImage'] ?? '',
        visionImage: j['visionImage'] ?? '',
        images: (j['images'] as List? ?? [])
            .map((e) => GalleryItem.fromJson(e))
            .toList(),
      );
}

class GalleryItem {
  final int id;
  final String mediaUrl;

  GalleryItem({required this.id, required this.mediaUrl});

  factory GalleryItem.fromJson(Map<String, dynamic> j) =>
      GalleryItem(id: j['id'] ?? 0, mediaUrl: j['mediaUrl'] ?? '');
}

class TeamMember {
  final int teamId;
  final int vendorId;
  final String name;
  final String designation;
  final String description;
  final String image;

  TeamMember({
    required this.teamId,
    required this.vendorId,
    required this.name,
    required this.designation,
    this.description = '',
    this.image = '',
  });

  factory TeamMember.fromJson(Map<String, dynamic> j) => TeamMember(
        teamId: j['teamId'] ?? 0,
        vendorId: j['vendorId'] ?? 0,
        name: j['name'] ?? '',
        designation: j['designation'] ?? '',
        description: j['description'] ?? '',
        image: j['image'] ?? '',
      );
}
