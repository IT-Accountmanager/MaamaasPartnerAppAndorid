// lib/models/referral_model.dart

class VendorReferralResponse {
  final int vendorId;
  final String name;
  final String email;
  final String mobileNumber;
  final String city;
  final int? parentId;
  final String companyName;
  final String? username;
  final String? password;
  final bool enabled;
  final String role;
  final List<String> businessVerticals;
  final DateTime registerTime;
  final String referenceId;
  final List<dynamic> subModules;
  final List<dynamic> tableModule;
  final String referralCodeUsed;
  final String? employeRole;
  final List<dynamic> businessModules;
  final bool accountNonExpired;
  final bool accountNonLocked;
  final bool credentialsNonExpired;

  VendorReferralResponse({
    required this.vendorId,
    required this.name,
    required this.email,
    required this.mobileNumber,
    required this.city,
    this.parentId,
    required this.companyName,
    this.username,
    this.password,
    required this.enabled,
    required this.role,
    required this.businessVerticals,
    required this.registerTime,
    required this.referenceId,
    required this.subModules,
    required this.tableModule,
    required this.referralCodeUsed,
    this.employeRole,
    required this.businessModules,
    required this.accountNonExpired,
    required this.accountNonLocked,
    required this.credentialsNonExpired,
  });

  factory VendorReferralResponse.fromJson(Map<String, dynamic> json) {
    return VendorReferralResponse(
      vendorId: json['vendorId'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      mobileNumber: json['mobileNumber'] ?? '',
      city: json['city'] ?? '',
      parentId: json['parentId'],
      companyName: json['companyName'] ?? '',
      username: json['username'],
      password: json['password'],
      enabled: json['enabled'] ?? false,
      role: json['role'] ?? '',
      businessVerticals: json['businessVerticals'] != null
          ? List<String>.from(json['businessVerticals'])
          : [],
      registerTime: json['registerTime'] != null
          ? DateTime.parse(json['registerTime'])
          : DateTime.now(),
      referenceId: json['referenceId'] ?? '',
      subModules: json['subModules'] ?? [],
      tableModule: json['tableModule'] ?? [],
      referralCodeUsed: json['referralCodeUsed'] ?? '',
      employeRole: json['employeRole'],
      businessModules: json['businessModules'] ?? [],
      accountNonExpired: json['accountNonExpired'] ?? false,
      accountNonLocked: json['accountNonLocked'] ?? false,
      credentialsNonExpired: json['credentialsNonExpired'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vendorId': vendorId,
      'name': name,
      'email': email,
      'mobileNumber': mobileNumber,
      'city': city,
      'parentId': parentId,
      'companyName': companyName,
      'username': username,
      'password': password,
      'enabled': enabled,
      'role': role,
      'businessVerticals': businessVerticals,
      'registerTime': registerTime.toIso8601String(),
      'referenceId': referenceId,
      'subModules': subModules,
      'tableModule': tableModule,
      'referralCodeUsed': referralCodeUsed,
      'employeRole': employeRole,
      'businessModules': businessModules,
      'accountNonExpired': accountNonExpired,
      'accountNonLocked': accountNonLocked,
      'credentialsNonExpired': credentialsNonExpired,
    };
  }
}
