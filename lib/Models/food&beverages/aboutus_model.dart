
class AboutUsModel {
  final int aboutUsId;
  final String aboutUs;
  final String image;
  final String? image1;
  final String? image2;
  final String? image3;
  final String? image4;
  final String? mission;
  final String? vision;
  final int vendorId;

  AboutUsModel({
    required this.aboutUsId,
    required this.aboutUs,
    required this.image,
    this.image1,
    this.image2,
    this.image3,
    this.image4,
    this.mission,
    this.vision,
    required this.vendorId,
  });

  factory AboutUsModel.fromJson(Map<String, dynamic> json) {
    return AboutUsModel(
      aboutUsId: json['aboutUsId'] ?? 0,
      aboutUs: json['aboutUs'] ?? '',
      image: json['image'] ?? '',
      image1: json['image1'],
      image2: json['image2'],
      image3: json['image3'],
      image4: json['image4'],
      mission: json['mission'],
      vision: json['vision'],
      vendorId: json['vendorId'] ?? 0,
    );
  }

  // ✅ ADD THIS METHOD
  AboutUsModel copyWith({
    int? aboutUsId,
    String? aboutUs,
    String? image,
    String? image1,
    String? image2,
    String? image3,
    String? image4,
    String? mission,
    String? vision,
    int? vendorId,
  }) {
    return AboutUsModel(
      aboutUsId: aboutUsId ?? this.aboutUsId,
      aboutUs: aboutUs ?? this.aboutUs,
      image: image ?? this.image,
      image1: image1 ?? this.image1,
      image2: image2 ?? this.image2,
      image3: image3 ?? this.image3,
      image4: image4 ?? this.image4,
      mission: mission ?? this.mission,
      vision: vision ?? this.vision,
      vendorId: vendorId ?? this.vendorId,
    );
  }

  // Get all gallery images
  List<String> getGalleryImages() {
    final List<String> images = [];
    if (image1 != null && image1!.isNotEmpty) images.add(image1!);
    if (image2 != null && image2!.isNotEmpty) images.add(image2!);
    if (image3 != null && image3!.isNotEmpty) images.add(image3!);
    if (image4 != null && image4!.isNotEmpty) images.add(image4!);
    return images;
  }
}
