class Restaurent_Banner {
  final int bannerId;
  final String companyName;
  final String establishedYear;
  final String whatsappLink;
  final String instagramLink;
  final String facebookLink;
  final String twitterLink;
  final String companyBanner;
  final String companyLogo;
  final int vendorId;
  final String city;
  final String appType;
  final String Type;
  final List<String> orderTypes;
  final String addressLine;
  final num distance;


  Restaurent_Banner({
    required this.bannerId,
    required this.companyName,
    required this.establishedYear,
    required this.whatsappLink,
    required this.instagramLink,
    required this.facebookLink,
    required this.twitterLink,
    required this.companyBanner,
    required this.companyLogo,
    required this.vendorId,
    required this.city,
    required this.orderTypes,
    required this.addressLine,
    required this.appType,
    required this.Type,
    required this.distance,
  });
  factory Restaurent_Banner.fromJson(Map<String, dynamic> json) {
    return Restaurent_Banner(
      bannerId: json['bannerId'] ?? 0,
      companyName: json['companyName'] ?? "",
      establishedYear: json['establishedYear'] ?? "",
      whatsappLink: json['whatsappLink'] ?? "",
      instagramLink: json['instagramLink'] ?? "",
      facebookLink: json['facebookLink'] ?? "",
      twitterLink: json['twitterLink'] ?? "",
      companyBanner: json['companyBanner'] ?? "",
      companyLogo: json['companyLogo'] ?? "",
      vendorId: json['vendorId'] ?? 0,
      city: json['city'] ?? "",
      orderTypes: List<String>.from(json['orderTypes'] ?? []),
      addressLine: json['addressLine'] ?? "",
      appType: json['appType'] ?? "",
      Type: json['Type']?.toString() ?? "",
      distance: json['distance'] ?? 0,
    );
  }

}

