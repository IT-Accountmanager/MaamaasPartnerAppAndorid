import 'dart:io';

class VendorFormData {
  // Company Details
  String companyName;
  String brandName;
  String position;
  String verticalType;

  // Address
  String doorNumber;
  String addressLine;
  String landMark;
  String city;
  String state;
  String pincode;
  double? latitude;
  double? longitude;
  String address;

  // Contact
  String contactName;
  String phone;
  String email;
  String aadhar;
  File? aadharFile;

  // Documents
  String gst;
  File? gstFile;
  String pan;
  File? panFile;
  String fssaiNo;
  String fssaiStart;
  String fssaiEnd;
  File? fssaiFile;
  String tradeLicenseNo;
  String tradeStart;
  String tradeEnd;
  File? tradeLicenseFile;
  String labourLicenseNo;
  String labourStart;
  String labourEnd;
  File? labourFile;

  // Bank
  String bankName;
  String ifsc;
  String accountNumber;
  File? passbookFile;

  VendorFormData({
    this.companyName = '',
    this.brandName = '',
    this.position = '',
    this.verticalType = '',
    this.doorNumber = '',
    this.addressLine = '',
    this.landMark = '',
    this.city = '',
    this.state = '',
    this.pincode = '',
    this.latitude,
    this.longitude,
    this.address = '',
    this.contactName = '',
    this.phone = '',
    this.email = '',
    this.aadhar = '',
    this.aadharFile,
    this.gst = '',
    this.gstFile,
    this.pan = '',
    this.panFile,
    this.fssaiNo = '',
    this.fssaiStart = '',
    this.fssaiEnd = '',
    this.fssaiFile,
    this.tradeLicenseNo = '',
    this.tradeStart = '',
    this.tradeEnd = '',
    this.tradeLicenseFile,
    this.labourLicenseNo = '',
    this.labourStart = '',
    this.labourEnd = '',
    this.labourFile,
    this.bankName = '',
    this.ifsc = '',
    this.accountNumber = '',
    this.passbookFile,
  });

  VendorFormData copyWith({
    String? companyName,
    String? brandName,
    String? position,
    String? verticalType,
    String? doorNumber,
    String? addressLine,
    String? landMark,
    String? city,
    String? state,
    String? pincode,
    double? latitude,
    double? longitude,
    String? address,
    String? contactName,
    String? phone,
    String? email,
    String? aadhar,
    File? aadharFile,
    String? gst,
    File? gstFile,
    String? pan,
    File? panFile,
    String? fssaiNo,
    String? fssaiStart,
    String? fssaiEnd,
    File? fssaiFile,
    String? tradeLicenseNo,
    String? tradeStart,
    String? tradeEnd,
    File? tradeLicenseFile,
    String? labourLicenseNo,
    String? labourStart,
    String? labourEnd,
    File? labourFile,
    String? bankName,
    String? ifsc,
    String? accountNumber,
    File? passbookFile,
  }) {
    return VendorFormData(
      companyName: companyName ?? this.companyName,
      brandName: brandName ?? this.brandName,
      position: position ?? this.position,
      verticalType: verticalType ?? this.verticalType,
      doorNumber: doorNumber ?? this.doorNumber,
      addressLine: addressLine ?? this.addressLine,
      landMark: landMark ?? this.landMark,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      contactName: contactName ?? this.contactName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      aadhar: aadhar ?? this.aadhar,
      aadharFile: aadharFile ?? this.aadharFile,
      gst: gst ?? this.gst,
      gstFile: gstFile ?? this.gstFile,
      pan: pan ?? this.pan,
      panFile: panFile ?? this.panFile,
      fssaiNo: fssaiNo ?? this.fssaiNo,
      fssaiStart: fssaiStart ?? this.fssaiStart,
      fssaiEnd: fssaiEnd ?? this.fssaiEnd,
      fssaiFile: fssaiFile ?? this.fssaiFile,
      tradeLicenseNo: tradeLicenseNo ?? this.tradeLicenseNo,
      tradeStart: tradeStart ?? this.tradeStart,
      tradeEnd: tradeEnd ?? this.tradeEnd,
      tradeLicenseFile: tradeLicenseFile ?? this.tradeLicenseFile,
      labourLicenseNo: labourLicenseNo ?? this.labourLicenseNo,
      labourStart: labourStart ?? this.labourStart,
      labourEnd: labourEnd ?? this.labourEnd,
      labourFile: labourFile ?? this.labourFile,
      bankName: bankName ?? this.bankName,
      ifsc: ifsc ?? this.ifsc,
      accountNumber: accountNumber ?? this.accountNumber,
      passbookFile: passbookFile ?? this.passbookFile,
    );
  }
}

