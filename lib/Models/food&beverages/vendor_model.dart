class VendorModel {
  final int? vendorId;
  final String? registeredName;
  final bool registeredNameStatus;
  final String? businessPlan;
  final bool businessPlanStatus;
  final String? type;
  final bool typeStatus;
  final String? ownerName;
  final bool ownerNameStatus;
  final String? mobileNumber;
  final bool mobileNumberStatus;
  final String? email;
  final bool emailStatus;
  final String? aadharPhotoFront;
  final String? aadharPhotoBack;
  final String? aadharNumber;
  final bool aadharNumberStatus;
  final String? panCard;
  final String? panCardNumber;
  final bool panCardStatus;
  final String? websiteName;
  final bool websiteNameStatus;
  final String? gstNumber;
  final bool gstNumberStatus;
  final String? registeredDocumentsFront;
  final String? registeredDocumentsBack;
  final bool registeredDocumentsStatus;
  final String? tradeLicense;
  final bool tradeLicenseStatus;
  final String? tradeLicenseStartDate;
  final String? tradeLicenseEndDate;
  final String? fssaiLicense;
  final bool fssaiLicenseStatus;
  final String? fssaiStartDate;
  final String? fssaiEndDate;
  final String? labourLicense;
  final bool labourLicenseStatus;
  final String? labourStartDate;
  final String? labourEndDate;
  final String? remarks;
  final String? businessVertical;


  VendorModel({
    this.vendorId,
    this.registeredName,
    this.businessPlan,
    this.type,
    this.ownerName,
    this.mobileNumber,
    this.email,
    this.aadharPhotoFront,
    this.aadharPhotoBack,
    this.aadharNumber,
    this.panCard,
    this.panCardNumber,
    this.websiteName,
    this.gstNumber,
    this.registeredDocumentsFront,
    this.registeredDocumentsBack,
    this.tradeLicense,
    this.tradeLicenseStartDate,
    this.tradeLicenseEndDate,
    this.fssaiLicense,
    this.fssaiStartDate,
    this.fssaiEndDate,
    this.labourLicense,
    this.labourStartDate,
    this.labourEndDate,
    this.remarks,
    this.registeredNameStatus = false,
    this.businessPlanStatus = false,
    this.typeStatus = false,
    this.ownerNameStatus = false,
    this.mobileNumberStatus = false,
    this.emailStatus = false,
    this.aadharNumberStatus = false,
    this.panCardStatus = false,
    this.websiteNameStatus = false,
    this.gstNumberStatus = false,
    this.registeredDocumentsStatus = false,
    this.tradeLicenseStatus = false,
    this.fssaiLicenseStatus = false,
    this.labourLicenseStatus = false,
     this.businessVertical
  });

  factory VendorModel.fromJson(Map<String, dynamic> json) {
    return VendorModel(
      vendorId: json['vendorId'],
      registeredName: json['registeredName'],
      registeredNameStatus: json['registeredNameStatus'] ?? false,
      businessPlan: json['businessPlan'],
      businessVertical: json['businessVertical'],
      businessPlanStatus: json['businessPlanStatus'] ?? false,
      type: json['type'],
      typeStatus: json['typeStatus'] ?? false,
      ownerName: json['ownerName'],
      ownerNameStatus: json['ownerNameStatus'] ?? false,
      mobileNumber: json['mobileNumber'],
      mobileNumberStatus: json['mobileNumberStatus'] ?? false,
      email: json['email'],
      emailStatus: json['emailStatus'] ?? false,
      aadharPhotoFront: json['aadharPhotoFront'],
      aadharPhotoBack: json['aadharPhotoBack'],
      aadharNumber: json['aadharNumber'],
      aadharNumberStatus: json['aadharNumberStatus'] ?? false,
      panCard: json['panCard'],
      panCardNumber: json['panCardNumber'],
      panCardStatus: json['panCardStatus'] ?? false,
      websiteName: json['websiteName'],
      websiteNameStatus: json['websiteNameStatus'] ?? false,
      gstNumber: json['gstNumber'],
      gstNumberStatus: json['gstNumberStatus'] ?? false,
      registeredDocumentsFront: json['registeredDocumentsFront'],
      registeredDocumentsBack: json['registeredDocumentsBack'],
      registeredDocumentsStatus: json['registeredDocumentsStatus'] ?? false,
      tradeLicense: json['tradeLicense'],
      tradeLicenseStatus: json['tradeLicenseStatus'] ?? false,
      tradeLicenseStartDate: json['tradeLicenseStartDate'],
      tradeLicenseEndDate: json['tradeLicenseEndDate'],
      fssaiLicense: json['fssaiLicense'],
      fssaiLicenseStatus: json['fssaiLicenseStatus'] ?? false,
      fssaiStartDate: json['fssaiStartDate'],
      fssaiEndDate: json['fssaiEndDate'],
      labourLicense: json['labourLicense'],
      labourLicenseStatus: json['labourLicenseStatus'] ?? false,
      labourStartDate: json['labourStartDate'],
      labourEndDate: json['labourEndDate'],
      remarks: json['remarks'],
    );
  }

  VendorModel copyWith({
    int? vendorId,
    String? registeredName,
    bool? registeredNameStatus,
    String? businessPlan,
    bool? businessPlanStatus,
    String? type,
    bool? typeStatus,
    String? ownerName,
    bool? ownerNameStatus,
    String? mobileNumber,
    bool? mobileNumberStatus,
    String? email,
    bool? emailStatus,
    String? aadharPhotoFront,
    String? aadharPhotoBack,
    String? aadharNumber,
    bool? aadharNumberStatus,
    String? panCard,
    String? panCardNumber,
    bool? panCardStatus,
    String? websiteName,
    bool? websiteNameStatus,
    String? gstNumber,
    bool? gstNumberStatus,
    String? registeredDocumentsFront,
    String? registeredDocumentsBack,
    bool? registeredDocumentsStatus,
    String? tradeLicense,
    bool? tradeLicenseStatus,
    String? tradeLicenseStartDate,
    String? tradeLicenseEndDate,
    String? fssaiLicense,
    bool? fssaiLicenseStatus,
    String? fssaiStartDate,
    String? fssaiEndDate,
    String? labourLicense,
    bool? labourLicenseStatus,
    String? labourStartDate,
    String? labourEndDate,
    String? remarks,
    String? businessVertical
  }) {
    return VendorModel(
      vendorId: vendorId ?? this.vendorId,
      registeredName: registeredName ?? this.registeredName,
      registeredNameStatus: registeredNameStatus ?? this.registeredNameStatus,
      businessPlan: businessPlan ?? this.businessPlan,
      businessPlanStatus: businessPlanStatus ?? this.businessPlanStatus,
      type: type ?? this.type,
      typeStatus: typeStatus ?? this.typeStatus,
      ownerName: ownerName ?? this.ownerName,
      ownerNameStatus: ownerNameStatus ?? this.ownerNameStatus,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      mobileNumberStatus: mobileNumberStatus ?? this.mobileNumberStatus,
      email: email ?? this.email,
      emailStatus: emailStatus ?? this.emailStatus,
      aadharPhotoFront: aadharPhotoFront ?? this.aadharPhotoFront,
      aadharPhotoBack: aadharPhotoBack ?? this.aadharPhotoBack,
      aadharNumber: aadharNumber ?? this.aadharNumber,
      aadharNumberStatus: aadharNumberStatus ?? this.aadharNumberStatus,
      panCard: panCard ?? this.panCard,
      panCardNumber: panCardNumber ?? this.panCardNumber,
      panCardStatus: panCardStatus ?? this.panCardStatus,
      websiteName: websiteName ?? this.websiteName,
      websiteNameStatus: websiteNameStatus ?? this.websiteNameStatus,
      gstNumber: gstNumber ?? this.gstNumber,
      gstNumberStatus: gstNumberStatus ?? this.gstNumberStatus,
      registeredDocumentsFront: registeredDocumentsFront ?? this.registeredDocumentsFront,
      registeredDocumentsBack: registeredDocumentsBack ?? this.registeredDocumentsBack,
      registeredDocumentsStatus: registeredDocumentsStatus ?? this.registeredDocumentsStatus,
      tradeLicense: tradeLicense ?? this.tradeLicense,
      tradeLicenseStatus: tradeLicenseStatus ?? this.tradeLicenseStatus,
      tradeLicenseStartDate: tradeLicenseStartDate ?? this.tradeLicenseStartDate,
      tradeLicenseEndDate: tradeLicenseEndDate ?? this.tradeLicenseEndDate,
      fssaiLicense: fssaiLicense ?? this.fssaiLicense,
      fssaiLicenseStatus: fssaiLicenseStatus ?? this.fssaiLicenseStatus,
      fssaiStartDate: fssaiStartDate ?? this.fssaiStartDate,
      fssaiEndDate: fssaiEndDate ?? this.fssaiEndDate,
      labourLicense: labourLicense ?? this.labourLicense,
      labourLicenseStatus: labourLicenseStatus ?? this.labourLicenseStatus,
      labourStartDate: labourStartDate ?? this.labourStartDate,
      labourEndDate: labourEndDate ?? this.labourEndDate,
      remarks: remarks ?? this.remarks,
      businessVertical:businessVertical ?? this.businessVertical
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "vendorId": vendorId,
      "registeredName": registeredName,
      "registeredNameStatus": registeredNameStatus,
      "businessPlan": businessPlan,
      "businessPlanStatus": businessPlanStatus,
      "type": type,
      "typeStatus": typeStatus,
      "ownerName": ownerName,
      "ownerNameStatus": ownerNameStatus,
      "mobileNumber": mobileNumber,
      "mobileNumberStatus": mobileNumberStatus,
      "email": email,
      "emailStatus": emailStatus,
      "aadharPhotoFront": aadharPhotoFront,
      "aadharPhotoBack": aadharPhotoBack,
      "aadharNumber": aadharNumber,
      "aadharNumberStatus": aadharNumberStatus,
      "panCard": panCard,
      "panCardNumber": panCardNumber,
      "panCardStatus": panCardStatus,
      "websiteName": websiteName,
      "websiteNameStatus": websiteNameStatus,
      "gstNumber": gstNumber,
      "gstNumberStatus": gstNumberStatus,
      "registeredDocumentsFront": registeredDocumentsFront,
      "registeredDocumentsBack": registeredDocumentsBack,
      "registeredDocumentsStatus": registeredDocumentsStatus,
      "tradeLicense": tradeLicense,
      "tradeLicenseStatus": tradeLicenseStatus,
      "tradeLicenseStartDate": tradeLicenseStartDate,
      "tradeLicenseEndDate": tradeLicenseEndDate,
      "fssaiLicense": fssaiLicense,
      "fssaiLicenseStatus": fssaiLicenseStatus,
      "fssaiStartDate": fssaiStartDate,
      "fssaiEndDate": fssaiEndDate,
      "labourLicense": labourLicense,
      "labourLicenseStatus": labourLicenseStatus,
      "labourStartDate": labourStartDate,
      "labourEndDate": labourEndDate,
      "remarks": remarks,
      "businessVertical":businessVertical
    };

}
}
