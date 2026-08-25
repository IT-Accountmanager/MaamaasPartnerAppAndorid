import '../../food&beverages/AddEmployee.dart';

class Employee {
  final int vendorId;
  final int parentId;
  final String name;
  final String email;
  final String mobileNumber;
  final String city;
  final String? companyName;
  final String? username;
  final String? password;
  final bool enabled;
  final String role;
  final List<BusinessVerticals> businessVerticals;
  final String registerTime;
  final EmployeRole employeRole;
  final List<BusinessModules> businessModules;
  final bool credentialsNonExpired;
  final bool accountNonExpired;
  final bool accountNonLocked;

  Employee({
    required this.vendorId,
    required this.parentId,
    required this.name,
    required this.email,
    required this.mobileNumber,
    required this.city,
    this.companyName,
    this.username,
    this.password,
    required this.enabled,
    required this.role,
    required this.businessVerticals,
    required this.registerTime,
    required this.employeRole,
    required this.businessModules,
    required this.credentialsNonExpired,
    required this.accountNonExpired,
    required this.accountNonLocked,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      vendorId: json['vendorId'] ?? 0,
      parentId: json['parentId'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      mobileNumber: json['mobileNumber'] ?? '',
      city: json['city'] ?? '',
      companyName: json['companyName'],
      username: json['username'],
      password: json['password'],
      enabled: json['enabled'] ?? true,
      role: json['role'] ?? '',
      businessVerticals: (json['businessVerticals'] as List?)
          ?.map((e) => BusinessVerticals.values.firstWhere(
            (v) => v.name == e,
        orElse: () => BusinessVerticals.Unknown,
      ))
          .toList() ??
          [],
      registerTime: json['registerTime'] ?? '',
      employeRole: EmployeRole.values.firstWhere(
            (r) => r.name == json['employeRole'],
        orElse: () => EmployeRole.Manager,
      ),
      businessModules: (json['businessModules'] as List?)
          ?.map((e) => BusinessModules.values.firstWhere(
            (m) => m.name == e,
        orElse: () => BusinessModules.Unknown,
      ))
          .toList() ??
          [],
      credentialsNonExpired: json['credentialsNonExpired'] ?? true,
      accountNonExpired: json['accountNonExpired'] ?? true,
      accountNonLocked: json['accountNonLocked'] ?? true,
    );
  }

  static Future fetchEmployees() async {}

}
