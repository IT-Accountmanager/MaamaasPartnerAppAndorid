import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'loginresponsemodel.dart';

class SessionService {
  static final SessionService _instance = SessionService._internal();
  factory SessionService() => _instance;
  static const _secureStorage = FlutterSecureStorage();

  SessionService._internal();

  LoginResponse? _user;

  LoginResponse? get user => _user;

  // Set<String> get modules => _user?.modules.toSet() ?? {};

  Set<String> get modules {
    if (_user == null) return {};

    // If employee → show only assigned modules (from API)
    if (_user!.role == 'ROLE_EMPLOYEE') {
      return _user!.modules.toSet();
    }

    // If vendor → show all modules (no filtering)
    if (_user!.role == 'ROLE_VENDOR') {
      return _user!.modules.toSet();
    }

    return {};
  }


  bool hasModule(String module) {
    return modules.contains(module);
  }

  Future<void> saveSession(LoginResponse data) async {
    _user = data;

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('token', data.token);
    await prefs.setString('refreshToken', data.refreshToken);
    await prefs.setInt('vendorId', data.vendorId);
    await prefs.setInt('employeeId', data.employeeId);
    await prefs.setString('role', data.role);
    await prefs.setString('employeeRole', data.employeeRole);
    await prefs.setString('customerId', data.customerId);
    await prefs.setStringList('modules', data.modules);

    // Secure storage
    await _secureStorage.write(key: 'token', value: data.token);
    await _secureStorage.write(key: 'refreshToken', value: data.refreshToken);
    await _secureStorage.write(
      key: 'vendorId',
      value: data.vendorId.toString(),
    );
  }

  Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();

    _user = LoginResponse(
      token: prefs.getString('token') ?? '',
      refreshToken: prefs.getString('refreshToken') ?? '',
      vendorId: prefs.getInt('vendorId') ?? 0,
      employeeId: prefs.getInt('employeeId') ?? 0,
      role: prefs.getString('role') ?? '',
      employeeRole: prefs.getString('employeeRole') ?? '',
      customerId: prefs.getString('customerId') ?? '',
      modules: prefs.getStringList('modules') ?? [],
    );
    debugPrint("modules after login.... : $modules");
  }

  Future<void> logout() async {
    _user = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await _secureStorage.deleteAll();
  }
}
