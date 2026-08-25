class AboutUs {
  final int aboutUsId;
  final String aboutUs;
  final int vendorId;
  final String image;
  final String image1;
  final String image2;
  final String image3;
  final String image4;
  final String mission;
  final String vision;

  AboutUs({
    required this.aboutUsId,
    required this.aboutUs,
    required this.vendorId,
    required this.image,
    required this.image1,
    required this.image2,
    required this.image3,
    required this.image4,
    required this.mission,
    required this.vision,
  });

  factory AboutUs.fromJson(Map<String, dynamic> json) {
    return AboutUs(
      aboutUsId: json['aboutUsId'] ?? 0,
      aboutUs: json['aboutUs'] ?? '',
      vendorId: json['vendorId'] ?? 0,
      image: json['image'] ?? '',
      image1: json['image1'] ?? '',
      image2: json['image2'] ?? '',
      image3: json['image3'] ?? '',
      image4: json['image4'] ?? '',
      mission: json['mission'] ?? '',
      vision: json['vision'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'aboutUsId': aboutUsId,
      'aboutUs': aboutUs,
      'vendorId': vendorId,
      'image': image,
      'image1': image1,
      'image2': image2,
      'image3': image3,
      'image4': image4,
      'mission': mission,
      'vision': vision,
    };
  }
}
