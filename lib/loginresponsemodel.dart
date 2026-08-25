class LoginResponse {
  final String token;
  final String refreshToken;
  final int vendorId;
  final int employeeId;
  final String role;
  final String employeeRole;
  final String customerId;
  final List<String> modules;

  LoginResponse({
    required this.token,
    required this.refreshToken,
    required this.vendorId,
    required this.employeeId,
    required this.role,
    required this.employeeRole,
    required this.customerId,
    required this.modules,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    List<String> modules = [];

    if (json['subscriptions'] != null &&
        json['subscriptions'].isNotEmpty) {
      modules = List<String>.from(
        json['subscriptions'][0]['selectedModules'] ?? [],
      );
    }

    return LoginResponse(
      token: json['token'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
      vendorId: json['vendorId'] ?? 0,
      employeeId: json['employeeId'] ?? 0,
      role: json['role'] ?? '',
      employeeRole: json['employeRole'] ?? '',
      customerId: json['customerId'] ?? '',
      modules: modules,
    );
  }
}