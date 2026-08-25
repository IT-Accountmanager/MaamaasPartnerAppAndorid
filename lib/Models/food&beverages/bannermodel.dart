class BannerModel {
  final int bannerId;
  final String companyName;
  final String establishedYear;
  final String companyLogo;
  final String companyBanner;
  final String whatsappLink;
  final String instagramLink;
  final String facebookLink;
  final String twitterLink;
  final int vendorId;

  BannerModel({
    required this.bannerId,
    required this.companyName,
    required this.establishedYear,
    required this.companyLogo,
    required this.companyBanner,
    required this.whatsappLink,
    required this.instagramLink,
    required this.facebookLink,
    required this.twitterLink,
    required this.vendorId,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      bannerId: json['bannerId'] ?? 0,
      companyName: json['companyName'] ?? '',
      establishedYear: json['establishedYear'] ?? '',
      companyLogo: json['companyLogo'] ?? '',
      companyBanner: json['companyBanner'] ?? '',
      whatsappLink: json['whatsappLink'] ?? '',
      instagramLink: json['instagramLink'] ?? '',
      facebookLink: json['facebookLink'] ?? '',
      twitterLink: json['twitterLink'] ?? '',
      vendorId: json['vendorId'] ?? 0,
    );
  }
}
