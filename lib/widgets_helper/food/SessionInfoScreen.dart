import 'package:shared_preferences/shared_preferences.dart';

/// Central helper that reads the login response fields stored in SharedPreferences
/// and exposes role / module helpers used across the app.
class SessionInfo {
  SessionInfo._();

  // ── Backend businessModules string → BusinessModules enum name ──────────────
  static const Map<String, String> backendToEnum = {
    'DASHBOARD': 'HomePage',
    'BUSINESS_PROFILE': 'Company',
    'SETTINGS_CONTROLS': 'Settings_Controls',
    'PRODUCTS_PRICES': 'Menu_Management',
    'ORDER_MANAGEMENT': 'Order_Management',
    'CHEF_MANAGEMENT': 'ChefKotScreen',
    'SERVICE_MANAGEMENT': 'Delivery_Management',
    'INVENTORY': 'Inventory_Management',
    'TEAM_MANAGEMENT': 'TeamDirectoryScreen',
    'SALES_MANAGEMENT': 'Report_Analysis',
    'FINANCE_ACCOUNTING': 'Account_History',
    'PROMOTIONS_MARKETING': 'Promotions_Discounts',
    'REFER_EARN': 'Promotions_Discounts',
    'REWARDS_COUPONS': 'CampaignListScreen',
    'RATINGS_REVIEWS': 'Report_Analysis',
    'HELP_DESK': 'Supportteam',
    'LEGAL_COMPLIANCE': 'SettingsScreen',
    'NOTIFICATIONS': 'HomePage',
    'REPORTS_ANALYSIS': 'Report_Analysis',
    'SUBSCRIPTION_MANAGEMENT': 'subscription',
  };

  // ── Role checks ─────────────────────────────────────────────────────────────
  static Future<String> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('role') ?? 'ROLE_VENDOR';
  }

  static Future<bool> isVendor() async => (await getRole()) == 'ROLE_VENDOR';
  static Future<bool> isEmployee() async =>
      (await getRole()) == 'ROLE_EMPLOYEE';

  // ── Employee-specific fields ────────────────────────────────────────────────
  static Future<String> getEmployeeRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('employeeRole') ??
        prefs.getString('employeRole') ??
        '';
  }

  static Future<int> getParentId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('parentId') ?? 0;
  }

  /// Raw businessModules strings from login response  e.g. ["ORDER_MANAGEMENT"]
  static Future<List<String>> getBusinessModules() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('businessModules') ?? [];
  }

  /// Raw subModules strings from login response
  static Future<List<String>> getSubModules() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('subModules') ?? [];
  }

  /// Converts backend businessModules → allowed BusinessModules enum names.
  /// Returns empty list for ROLE_VENDOR (means "show all").
  static Future<List<String>> getAllowedEnumNames() async {
    final role = await getRole();
    if (role != 'ROLE_EMPLOYEE') return [];
    final modules = await getBusinessModules();
    return modules.map((m) => backendToEnum[m]).whereType<String>().toList();
  }

  // ── Vendor / plan ────────────────────────────────────────────────────────────
  static Future<String> getPlanType() async {
    final prefs = await SharedPreferences.getInstance();
    final plans = prefs.getStringList('planTypes') ?? ['BASIC'];
    return plans.contains('PREMIUM') ? 'PREMIUM' : 'BASIC';
  }

  static Future<int> getVendorId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('vendorId') ??
        prefs.getInt('vendor_id') ??
        prefs.getInt('id') ??
        0;
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken') ??
        prefs.getString('token') ??
        prefs.getString('accessToken');
  }
}
