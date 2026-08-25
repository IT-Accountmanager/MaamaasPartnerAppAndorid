class VendorModel {
  final int? vendorId;
  final int? parentId;
  final String? name;
  final String? email;
  final String? mobileNumber;
  final String? city;
  final String? companyName;
  final String? role;
  final String? token;
  final String? refreshToken;
  final String? customerId;
  final List<String>? businessVerticals;
  final String? subscriptionStatus;
  final String? employeeRole;

  VendorModel({
    this.vendorId,
    this.parentId,
    this.name,
    this.email,
    this.mobileNumber,
    this.city,
    this.companyName,
    this.role,
    this.token,
    this.refreshToken,
    this.customerId,
    this.businessVerticals,
    this.subscriptionStatus,
    this.employeeRole,
  });

  factory VendorModel.fromJson(Map<String, dynamic> json) {
    return VendorModel(
      vendorId: json['vendorId'],
      parentId: json['parentId'],
      name: json['name'],
      email: json['email'],
      mobileNumber: json['mobileNumber'],
      city: json['city'],
      companyName: json['companyName'],
      role: json['role'],
      token: json['token'],
      refreshToken: json['refreshToken'],
      customerId: json['customerId'],
      businessVerticals: json['businessVerticals'] != null
          ? List<String>.from(json['businessVerticals'])
          : null,
      subscriptionStatus: json['subscriptionStatus'],
      employeeRole: json['employeeRole'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vendorId': vendorId,
      'parentId': parentId,
      'name': name,
      'email': email,
      'mobileNumber': mobileNumber,
      'city': city,
      'companyName': companyName,
      'role': role,
      'token': token,
      'refreshToken': refreshToken,
      'customerId': customerId,
      'businessVerticals': businessVerticals,
      'subscriptionStatus': subscriptionStatus,
      'employeeRole': employeeRole,
    };
  }
}

class EnquiryRequest {
  final int vendorId;
  final int? parentId;
  final String name;
  final String email;
  final String city;
  final String mobileNumber;
  final String companyName;
  final String role;
  final List<String> businessVerticals;
  final String registerTime;

  EnquiryRequest({
    required this.vendorId,
    this.parentId,
    required this.name,
    required this.email,
    required this.city,
    required this.mobileNumber,
    required this.companyName,
    required this.role,
    required this.businessVerticals,
    required this.registerTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'vendorId': vendorId,
      'parentId': parentId,
      'name': name,
      'email': email,
      'city': city,
      'mobileNumber': mobileNumber,
      'companyName': companyName,
      'role': role,
      'businessVerticals': businessVerticals,
      'registerTime': registerTime,
    };
  }
}
