class VendorModelLoginDialog {
  final int? vendorId;
  final String? name;
  final String? email;
  final String? mobileNumber;
  final String? city;
  final int? parentId;
  final String? companyName;
  final String? username;
  final String? password;
  final bool? enabled;
  final String? role;
  final List<String> businessVerticals;
  final String? registerTime;
  final String? referenceId;
  final List<dynamic> subModules;
  final List<dynamic> tableModule;
  final String? referralCodeUsed;
  final String? employeRole;
  final List<dynamic> businessModules;
  final bool? accountNonExpired;
  final bool? accountNonLocked;
  final bool? credentialsNonExpired;

  VendorModelLoginDialog({
    this.vendorId,
    this.name,
    this.email,
    this.mobileNumber,
    this.city,
    this.parentId,
    this.companyName,
    this.username,
    this.password,
    this.enabled,
    this.role,
    this.businessVerticals = const [],
    this.registerTime,
    this.referenceId,
    this.subModules = const [],
    this.tableModule = const [],
    this.referralCodeUsed,
    this.employeRole,
    this.businessModules = const [],
    this.accountNonExpired,
    this.accountNonLocked,
    this.credentialsNonExpired,
  });

  factory VendorModelLoginDialog.fromJson(Map<String, dynamic> json) {
    return VendorModelLoginDialog(
      vendorId: json['vendorId'] as int?,
      name: json['name'] as String?,
      email: json['email'] as String?,
      mobileNumber: json['mobileNumber']?.toString(),
      city: json['city'] as String?,
      parentId: json['parentId'] as int?,
      companyName: json['companyName'] as String?,
      username: json['username'] as String?,
      password: json['password'] as String?,
      enabled: json['enabled'] as bool?,
      role: json['role'] as String?,
      businessVerticals:
          (json['businessVerticals'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      registerTime: json['registerTime'] as String?,
      referenceId: json['referenceId'] as String?,
      subModules: (json['subModules'] as List<dynamic>?) ?? const [],
      tableModule: (json['tableModule'] as List<dynamic>?) ?? const [],
      referralCodeUsed: json['referralCodeUsed'] as String?,
      employeRole: json['employeRole'] as String?,
      businessModules: (json['businessModules'] as List<dynamic>?) ?? const [],
      accountNonExpired: json['accountNonExpired'] as bool?,
      accountNonLocked: json['accountNonLocked'] as bool?,
      credentialsNonExpired: json['credentialsNonExpired'] as bool?,
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
      'registerTime': registerTime,
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

  @override
  String toString() =>
      'VendorModel(vendorId: $vendorId, name: $name, email: $email)';
}
