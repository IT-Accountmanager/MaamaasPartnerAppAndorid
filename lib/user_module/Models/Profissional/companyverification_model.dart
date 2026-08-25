
class CompanyVerificationModel {
  final int id;
  final String companyName;
  final String businessType;
  final String companyPan;
  final String gstin;
  final String cin;

  final String ownerFullName;
  final String ownerMobile;
  final String ownerEmail;
  final String ownerPan;
  final String ownerAadhaar;
  final String ownerAddress;
  final String? ownerDob;
  final String ownerSelfie;

  final String registeredAddress;
  final String city;
  final String state;
  final String pincode;

  final String? companyPanDocument;
  final String? gstCertificate;
  final String? ownerPanDocument;
  final String? ownerAadhaarDocument;
  final String tradeLicense;
  final String incorporationCertificate;

  final String verificationStatus;
  final String? rejectionReason;
  final String? verifiedBy;

  final DateTime? submittedAt;
  final DateTime? updatedAt;

  CompanyVerificationModel({
    required this.id,
    required this.companyName,
    required this.businessType,
    required this.companyPan,
    required this.gstin,
    required this.cin,
    required this.ownerFullName,
    required this.ownerMobile,
    required this.ownerEmail,
    required this.ownerPan,
    required this.ownerAadhaar,
    required this.ownerAddress,
    required this.registeredAddress,
    required this.city,
    required this.state,
    required this.pincode,
    required this.verificationStatus,
    required this.ownerSelfie,
    required this.tradeLicense,
    required this.incorporationCertificate,
    this.companyPanDocument,
    this.gstCertificate,
    this.ownerPanDocument,
    this.ownerAadhaarDocument,
    this.rejectionReason,
    this.verifiedBy,
    this.ownerDob,
    this.submittedAt,
    this.updatedAt,
  });

  factory CompanyVerificationModel.fromJson(Map<String, dynamic> json) {
    return CompanyVerificationModel(
      id: json['id'] ?? 0,
      companyName: json['companyName'] ?? '',
      businessType: json['businessType'] ?? '',
      companyPan: json['companyPan'] ?? '',
      gstin: json['gstin'] ?? '',
      cin: json['cin'] ?? '',
      ownerFullName: json['ownerFullName'] ?? '',
      ownerMobile: json['ownerMobile'] ?? '',
      ownerEmail: json['ownerEmail'] ?? '',
      ownerPan: json['ownerPan'] ?? '',
      ownerAadhaar: json['ownerAadhaar']?.toString() ?? '',
      ownerAddress: json['ownerAddress'] ?? '',
      ownerDob: json['ownerDob'],
      registeredAddress: json['registeredAddress'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      pincode: json['pincode']?.toString() ?? '',
      companyPanDocument: json['companyPanDocument'],
      gstCertificate: json['gstCertificate'],
      ownerPanDocument: json['ownerPanDocument'],
      ownerAadhaarDocument: json['ownerAadhaarDocument'],
      verificationStatus: json['verificationStatus'] ?? 'PENDING',
      rejectionReason: json['rejectionReason'],
      verifiedBy: json['verifiedBy'],
        incorporationCertificate:json['incorporationCertificate'],
      tradeLicense: json['tradeLicense'],
      ownerSelfie: json['ownerSelfie'],

      submittedAt: json['submittedAt'] != null
          ? DateTime.tryParse(json['submittedAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
    );
  }
}
