class VendorModel {
  int? vendorId;
  String? ownerName;
  String? email;
  String? mobileNumber;
  String? registeredName;
  String? websiteName;
  String? aadharNumber;
  String? panCardNumber;
  String? gstNumber;
  String? doorNumber;
  String? addressLine;
  String? landMark;
  String? city;
  String? state;
  String? country;
  int? pincode;
  double? latitude;
  double? longitude;
  double? deliveryRadius;
  double? averageDeliveryTime;
  String? businessVertical;
  String? remarks;
  String? registeredDocumentsFront;
  String? registeredDocumentsBack;
  String? tradeLicense;
  String? tradeLicenseStartDate;
  String? tradeLicenseEndDate;
  String? fssaiLicense;
  String? fssaiStartDate;
  String? fssaiEndDate;
  String? labourLicense;
  String? labourStartDate;
  String? labourEndDate;
  String? holderName;
  String? accountNumber;
  String? branchName;
  String? ifscCode;
  String? passbook;
  bool? commisition;
  bool? leads;

  VendorModel({
    this.vendorId,
    this.ownerName,
    this.email,
    this.mobileNumber,
    this.registeredName,
    this.websiteName,
    this.aadharNumber,
    this.panCardNumber,
    this.gstNumber,
    this.doorNumber,
    this.addressLine,
    this.landMark,
    this.city,
    this.state,
    this.country,
    this.pincode,
    this.latitude,
    this.longitude,
    this.deliveryRadius,
    this.averageDeliveryTime,
    this.businessVertical,
    this.remarks,
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
    this.holderName,
    this.accountNumber,
    this.branchName,
    this.ifscCode,
    this.passbook,
    this.commisition,
    this.leads,
  });

  factory VendorModel.fromJson(Map<String, dynamic> json) {
    return VendorModel(
      vendorId: json['vendorId'],
      ownerName: json['ownerName'],
      email: json['email'],
      mobileNumber: json['mobileNumber'],
      registeredName: json['registeredName'],
      websiteName: json['websiteName'],
      aadharNumber: json['aadharNumber'],
      panCardNumber: json['panCardNumber'],
      gstNumber: json['gstNumber'],
      doorNumber: json['doorNumber'],
      addressLine: json['addressLine'],
      landMark: json['landMark'],
      city: json['city'],
      state: json['state'],
      country: json['country'],
      pincode: json['pincode'],
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      deliveryRadius: (json['deliveryRadius'] as num?)?.toDouble(),
      averageDeliveryTime: (json['averageDeliveryTime'] as num?)?.toDouble(),
      businessVertical: json['businessVertical'],
      remarks: json['remarks'],
      registeredDocumentsFront: json['registeredDocumentsFront'],
      registeredDocumentsBack: json['registeredDocumentsBack'],
      tradeLicense: json['tradeLicense'],
      tradeLicenseStartDate: json['tradeLicenseStartDate'],
      tradeLicenseEndDate: json['tradeLicenseEndDate'],
      fssaiLicense: json['fssaiLicense'],
      fssaiStartDate: json['fssaiStartDate'],
      fssaiEndDate: json['fssaiEndDate'],
      labourLicense: json['labourLicense'],
      labourStartDate: json['labourStartDate'],
      labourEndDate: json['labourEndDate'],
      holderName: json['holderName'],
      accountNumber: json['accountNumber'],
      branchName: json['branchName'],
      ifscCode: json['ifscCode'],
      passbook: json['passbook'],
      commisition: json['commisition'],
      leads: json['leads'],
    );
  }
}
