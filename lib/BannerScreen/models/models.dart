// ─── models.dart ─────────────────────────────────────────────────────────────

// ==================== ABOUT US ====================
class AboutUsModel {
  final int? aboutUsId;
  final String text;
  final String? image;

  AboutUsModel({this.aboutUsId, required this.text, this.image});

  factory AboutUsModel.fromJson(Map<String, dynamic> j) => AboutUsModel(
        aboutUsId: j['aboutUsId'],
        text: j['aboutUs'] ?? '',
        image: j['image'],
      );
}

// ==================== BANNER ====================
class BannerModel {
  final int? bannerId;
  final String companyName;
  final String establishedYear;
  final String? companyBanner;
  final String? companyLogo;
  final String? instagramLink;
  final String? youtubeLink;
  final String? linkedinLink;
  final String? facebookLink;
  final String? twitterLink;
  final String? whatsappLink;
  final String? openTime;
  final String? closeTime;

  BannerModel({
    this.bannerId,
    this.companyName = '',
    this.establishedYear = '',
    this.companyBanner,
    this.companyLogo,
    this.instagramLink,
    this.youtubeLink,
    this.linkedinLink,
    this.facebookLink,
    this.twitterLink,
    this.whatsappLink,
    this.openTime,
    this.closeTime,
  });

  factory BannerModel.fromJson(Map<String, dynamic> j) => BannerModel(
        bannerId: j['bannerId'],
        companyName: j['companyName'] ?? '',
        establishedYear: j['establishedYear'] ?? '',
        companyBanner: j['companyBanner'],
        companyLogo: j['companyLogo'],
        instagramLink: j['instagramLink'],
        youtubeLink: j['youtubeLink'],
        linkedinLink: j['linkedinLink'],
        facebookLink: j['facebookLink'],
        twitterLink: j['twitterLink'],
        whatsappLink: j['whatsappLink'],
        openTime: j['openTime'],
        closeTime: j['closeTime'],
      );

  BannerModel copyWith({
    String? companyName,
    String? establishedYear,
    String? companyBanner,
    String? companyLogo,
    String? instagramLink,
    String? youtubeLink,
    String? linkedinLink,
    String? facebookLink,
    String? twitterLink,
    String? openTime,
    String? closeTime,
  }) =>
      BannerModel(
        bannerId: bannerId,
        companyName: companyName ?? this.companyName,
        establishedYear: establishedYear ?? this.establishedYear,
        companyBanner: companyBanner ?? this.companyBanner,
        companyLogo: companyLogo ?? this.companyLogo,
        instagramLink: instagramLink ?? this.instagramLink,
        youtubeLink: youtubeLink ?? this.youtubeLink,
        linkedinLink: linkedinLink ?? this.linkedinLink,
        facebookLink: facebookLink ?? this.facebookLink,
        twitterLink: twitterLink ?? this.twitterLink,
        openTime: openTime ?? this.openTime,
        closeTime: closeTime ?? this.closeTime,
      );
}

// ==================== MISSION / VISION ====================
class MissionVisionModel {
  final int? aboutUsId;
  final String mission;
  final String vision;
  final String? missionImage;
  final String? visionImage;

  MissionVisionModel({
    this.aboutUsId,
    this.mission = '',
    this.vision = '',
    this.missionImage,
    this.visionImage,
  });

  factory MissionVisionModel.fromJson(Map<String, dynamic> j) =>
      MissionVisionModel(
        aboutUsId: j['aboutUsId'],
        mission: j['mission'] ?? '',
        vision: j['vision'] ?? '',
        missionImage: j['missionImage'],
        visionImage: j['visionImage'],
      );
}

// ==================== GALLERY ====================
class GalleryModel {
  final int? aboutUsId;
  final String? image1;
  final String? image2;
  final String? image3;
  final String? image4;

  GalleryModel({
    this.aboutUsId,
    this.image1,
    this.image2,
    this.image3,
    this.image4,
  });

  factory GalleryModel.fromJson(Map<String, dynamic> j) => GalleryModel(
        aboutUsId: j['aboutUsId'],
        image1: j['image1'],
        image2: j['image2'],
        image3: j['image3'],
        image4: j['image4'],
      );

  List<String> get images =>
      [image1, image2, image3, image4].whereType<String>().toList();
}

// ==================== TEAM MEMBER ====================
class TeamMember {
  final int teamId;
  final String name;
  final String designation;
  final String description;
  final String? image;

  TeamMember({
    required this.teamId,
    required this.name,
    required this.designation,
    required this.description,
    this.image,
  });

  factory TeamMember.fromJson(Map<String, dynamic> j) => TeamMember(
        teamId: j['teamId'] ?? 0,
        name: j['name'] ?? '',
        designation: j['designation'] ?? '',
        description: j['description'] ?? '',
        image: j['image'],
      );
}

// ==================== ADDRESS ====================
class AddressModel {
  final String doorNo;
  final String street;
  final String city;
  final String state;
  final String pincode;
  final String landmark;
  final String latitude;
  final String longitude;

  const AddressModel({
    this.doorNo = '',
    this.street = '',
    this.city = '',
    this.state = '',
    this.pincode = '',
    this.landmark = '',
    this.latitude = '',
    this.longitude = '',
  });

  AddressModel copyWith({
    String? doorNo,
    String? street,
    String? city,
    String? state,
    String? pincode,
    String? landmark,
    String? latitude,
    String? longitude,
  }) =>
      AddressModel(
        doorNo: doorNo ?? this.doorNo,
        street: street ?? this.street,
        city: city ?? this.city,
        state: state ?? this.state,
        pincode: pincode ?? this.pincode,
        landmark: landmark ?? this.landmark,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
      );

  Map<String, dynamic> toJson() => {
        'doorNo': doorNo,
        'street': street,
        'city': city,
        'state': state,
        'pincode': pincode,
        'landmark': landmark,
        'latitude': latitude,
        'longitude': longitude,
      };
}

// ==================== BANK DETAILS ====================
class BankDetailsModel {
  final String holderName;
  final String accountNumber;
  final String branchName;
  final String ifscCode;
  final String? passbookServerFileName;

  const BankDetailsModel({
    this.holderName = '',
    this.accountNumber = '',
    this.branchName = '',
    this.ifscCode = '',
    this.passbookServerFileName,
  });

  factory BankDetailsModel.fromJson(Map<String, dynamic> j) => BankDetailsModel(
        holderName: j['holderName'] ?? '',
        accountNumber: j['accountNumber'] ?? '',
        branchName: j['branchName'] ?? '',
        ifscCode: j['ifscCode'] ?? '',
        passbookServerFileName: j['passbookServerFileName'],
      );

  Map<String, dynamic> toJson() => {
        'holderName': holderName,
        'accountNumber': accountNumber,
        'branchName': branchName,
        'ifscCode': ifscCode,
      };
}

// ==================== LICENSE ====================
class LicenseModel {
  final String licenseNumber;
  final String startDate;
  final String endDate;

  const LicenseModel({
    this.licenseNumber = '',
    this.startDate = '',
    this.endDate = '',
  });

  factory LicenseModel.fromJson(Map<String, dynamic> j) => LicenseModel(
        licenseNumber: j['licenseNumber'] ?? '',
        startDate: j['startDate'] ?? '',
        endDate: j['endDate'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'licenseNumber': licenseNumber,
        'startDate': startDate,
        'endDate': endDate,
      };
}

// ==================== REGISTRATION ====================
class RegistrationModel {
  final String companyName;
  final String businessVertical;
  final String position;
  final String verticalType;
  final AddressModel address;
  final String contactName;
  final String phoneNo;
  final String emailId;
  final String aadharCardNo;
  final String gstNo;
  final LicenseModel tradeLicense;
  final LicenseModel fssaiLicense;
  final LicenseModel labourLicense;
  final BankDetailsModel bankDetails;

  const RegistrationModel({
    this.companyName = '',
    this.businessVertical = 'FOOD_AND_BEVERAGES',
    this.position = '',
    this.verticalType = '',
    this.address = const AddressModel(),
    this.contactName = '',
    this.phoneNo = '',
    this.emailId = '',
    this.aadharCardNo = '',
    this.gstNo = '',
    this.tradeLicense = const LicenseModel(),
    this.fssaiLicense = const LicenseModel(),
    this.labourLicense = const LicenseModel(),
    this.bankDetails = const BankDetailsModel(),
  });
}

// ==================== STATUS ENUM ====================
enum FieldStatus { pending, verified, uploaded, provided, notUploaded, notVerified, rejected }

extension FieldStatusExt on FieldStatus {
  String get label {
    switch (this) {
      case FieldStatus.pending: return 'Pending';
      case FieldStatus.verified: return 'Verified';
      case FieldStatus.uploaded: return 'Uploaded';
      case FieldStatus.provided: return 'Provided';
      case FieldStatus.notUploaded: return 'Not Uploaded';
      case FieldStatus.notVerified: return 'Not Verified';
      case FieldStatus.rejected: return 'Rejected';
    }
  }
}
