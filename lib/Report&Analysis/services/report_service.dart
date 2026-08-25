import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../API/Apiclient.dart';
import '../models/report_models.dart';

class ReportService {
  static void _log(String msg) {
    if (kDebugMode) debugPrint('📊 [ReportService] $msg');
  }

  // ── Main fetch ─────────────────────────────────────────────
  static Future<ReportData?> fetch(ReportFilter filter) async {
    final vid = await _vid();

    _log('Fetching report data...');

    try {
      final response = await ApiClient.get(
        'api/orders/vendor/statistics/custom',
        service: 'food',
        queryParams: {
          'vendorId': vid.toString(),
          'fromDate': filter.startDate,
          'toDate': filter.endDate,
        },
      );

      _log('status=${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(response.body);

        if (jsonBody is Map<String, dynamic>) {
          return ReportData.fromJson(jsonBody);
        }
      } else {
        _log('error body=${response.body.substring(0, response.body.length.clamp(0, 300))}');
      }
    } catch (e) {
      _log('ERROR: $e');
    }

    return null;
  }

  static Future<int> _vid() async {
    final p = await SharedPreferences.getInstance();
    return p.getInt('vendorId') ??
        int.tryParse(p.getString('vendorId') ?? '') ??
        0;
  }

  // ── Role / submodules unchanged ─────────────────────────────
  static Future<String> getRole() async {
    final p = await SharedPreferences.getInstance();
    return p.getString('role') ?? p.getString('userRole') ?? 'ROLE_VENDOR';
  }

  static Future<List<String>> getSubModules() async {
    final p = await SharedPreferences.getInstance();

    final list = p.getStringList('subModules');
    if (list != null) return list;

    try {
      final raw = p.getString('subModules') ?? '[]';
      return List<String>.from(jsonDecode(raw));
    } catch (_) {}

    return [];
  }
}