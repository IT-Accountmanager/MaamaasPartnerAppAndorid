// ─── Module from GET /subscription/api/subscription/plans ─────────────────────
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SubModule {
  final int    id;
  final String code;
  final String category;     // BASE_PLAN | FEATURE_ADD_ON | ORDER_TYPE | ORDERTYPE_ADD_ON
  final String displayCategory;
  final String name;         // display name (mapped from code)
  final String description;
  final String defaultIncluded; // MANDATORY | INCLUDE | EXCLUDE
  final double monthlyPrice;
  final double yearlyPrice;
  final int    categoryOrder;

  // Derived
  String get type {
    if (defaultIncluded == 'INCLUDE' || defaultIncluded == 'MANDATORY') return 'included';
    return 'toggle';
  }

  const SubModule({
    this.id = 0, this.code = '', this.category = '', this.displayCategory = '',
    this.name = '', this.description = '', this.defaultIncluded = 'INCLUDE',
    this.monthlyPrice = 0, this.yearlyPrice = 0, this.categoryOrder = 999,
  });

  factory SubModule.fromJson(Map<String, dynamic> j) {
    final cat = j['catageory']?.toString() ?? '';
    final code = j['code']?.toString() ?? '';

    // Category order
    final catOrder = const {
      'BASE_PLAN': 1, 'FEATURE_ADD_ON': 2, 'ORDER_TYPE': 3, 'ORDERTYPE_ADD_ON': 4,
    }[cat] ?? 999;

    // Display category
    final displayCat = cat.split('_').map((w) => w.isEmpty ? '' : w[0].toUpperCase() + w.substring(1).toLowerCase()).join(' ');

    // Display name
    final displayName = _moduleDisplayNames[code] ??
        code.split('_').map((w) => w.isEmpty ? '' : w[0].toUpperCase() + w.substring(1).toLowerCase()).join(' ');

    return SubModule(
      id:              _i(j['id']),
      code:            code,
      category:        cat,
      displayCategory: displayCat,
      name:            displayName,
      description:     j['description']?.toString() ?? 'No description available',
      defaultIncluded: j['defaultIncluded']?.toString() ?? 'INCLUDE',
      monthlyPrice:    _d(j['monthlyPrice']),
      yearlyPrice:     _d(j['yearlyPrice']),
      categoryOrder:   catOrder,
    );
  }
}

// ─── Active Subscription from GET /subscription/api/subscription/vendor/vendor_subscription/{vendorId}/active ─
class ActiveSubscription {
  final int    subscriptionId;
  final String status;       // ACTIVE | TRIAL | EXPIRED
  final String billingCycle;
  final int    remainingDays;
  final String? endDate;
  final String? startDate;
  final double totalAmount;
  final List<String> selectedModules;
  final String? customerName;
  final String? email;
  final String? customerMobile;

  const ActiveSubscription({
    this.subscriptionId = 0,
    this.status = 'ACTIVE',
    this.billingCycle = 'YEARLY',
    this.remainingDays = 0,
    this.endDate,
    this.startDate,
    this.totalAmount = 0,
    this.selectedModules = const [],
    this.customerName,
    this.email,
    this.customerMobile,
  });

  factory ActiveSubscription.fromJson(Map<String, dynamic> j) => ActiveSubscription(
    subscriptionId: _i(j['subscriptionId']),
    status:         j['status']?.toString() ?? 'ACTIVE',
    billingCycle:   j['billingCycle']?.toString() ?? 'YEARLY',
    remainingDays:  _i(j['remainingDays']),
    endDate:        j['endDate']?.toString(),
    startDate:      j['startDate']?.toString(),
    totalAmount:    _d(j['totalAmount']),
    selectedModules: (j['selectedModules'] as List? ?? []).map((e) => e.toString()).toList(),
    customerName:   j['customerName']?.toString(),
    email:          j['email']?.toString(),
    customerMobile: j['customerMobile']?.toString(),
  );
}

// ─── Pro-rated details ────────────────────────────────────────────────────────
class ProRatedDetails {
  final List<String> addedModules;
  final List<String> removedModules;
  final double originalAmount;
  final double proRatedAmount;
  final double gstAmount;
  final double totalAmount;
  final int remainingDays;

  const ProRatedDetails({
    this.addedModules = const [], this.removedModules = const [],
    this.originalAmount = 0, this.proRatedAmount = 0,
    this.gstAmount = 0, this.totalAmount = 0, this.remainingDays = 0,
  });
}

// ─── Button config ─────────────────────────────────────────────────────────────
class ButtonConfig {
  final String text;
  final bool disabled;
  final String? action; // new | trial | renew | modify | null
  final Color buttonColor;
  final String? message;

  const ButtonConfig({
    required this.text, required this.disabled,
    this.action, required this.buttonColor, this.message,
  });
}

// ─── Module display names mapping ─────────────────────────────────────────────
const Map<String, String> _moduleDisplayNames = {
  'DASHBOARD':            'Dashboard',
  'BUSINESS_PROFILE':     'Profile Management',
  'SETTINGS_CONTROLS':    'Settings Management',
  'PRODUCTS_PRICES':      'Products & Prices',
  'ORDER_MANAGEMENT':     'Order Management',
  'CHEF_MANAGEMENT':      'Chef Management',
  'SERVICE_MANAGEMENT':   'Service Management',
  'INVENTORY':            'Inventory',
  'TEAM_MANAGEMENT':      'Team Management',
  'SALES_MANAGEMENT':     'Sales Management',
  'FINANCE_ACCOUNTING':   'Finance & Accounting',
  'PROMOTIONS_MARKETING': 'Promotions & Marketing',
  'REFER_EARN':           'Refer & Earn',
  'REWARDS_COUPONS':      'Rewards & Coupons',
  'RATINGS_REVIEWS':      'Ratings & Reviews',
  'HELP_DESK':            'Support Management',
  'LEGAL_COMPLIANCE':     'Legal Compliance',
  'NOTIFICATIONS':        'Notifications',
  'REPORTS_ANALYSIS':     'Reports & Analysis',
  'ACCOUNT_HISTORY':      'Finance & Accounting',
  'MENU_MANAGEMENT':      'Products & Prices',
  'VENDOR_PROFILE':       'Profile Management',
  'REPORTS':              'Reports & Analysis',
  'PLATFORM_ACCESS':      'Platform Access',
  'CATERING':             'Catering TableServices',
  'TAKEAWAY':             'Takeaway Orders',
  'DINE_IN':              'Dine-In Orders',
  'DELIVERY':             'Delivery TableServices',
};

// ─── Icon mapping ──────────────────────────────────────────────────────────────
IconData subModuleIcon(String code) {
  switch (code.toUpperCase()) {
    case 'DASHBOARD':             return Icons.dashboard_outlined;
    case 'BUSINESS_PROFILE':
    case 'VENDOR_PROFILE':        return Icons.business_outlined;
    case 'SETTINGS_CONTROLS':     return Icons.settings_outlined;
    case 'PRODUCTS_PRICES':
    case 'MENU_MANAGEMENT':       return Icons.inventory_2_outlined;
    case 'PLATFORM_ACCESS':       return Icons.store_outlined;
    case 'ORDER_MANAGEMENT':      return Icons.shopping_bag_outlined;
    case 'CHEF_MANAGEMENT':       return Icons.restaurant_outlined;
    case 'SERVICE_MANAGEMENT':
    case 'TEAM_MANAGEMENT':       return Icons.groups_outlined;
    case 'INVENTORY':             return Icons.inventory_outlined;
    case 'SALES_MANAGEMENT':      return Icons.trending_up_rounded;
    case 'FINANCE_ACCOUNTING':
    case 'ACCOUNT_HISTORY':       return Icons.account_balance_wallet_outlined;
    case 'PROMOTIONS_MARKETING':  return Icons.local_offer_outlined;
    case 'REFER_EARN':            return Icons.card_giftcard_outlined;
    case 'REWARDS_COUPONS':
    case 'RATINGS_REVIEWS':       return Icons.star_outline_rounded;
    case 'HELP_DESK':             return Icons.headset_mic_outlined;
    case 'NOTIFICATIONS':         return Icons.notifications_outlined;
    case 'REPORTS_ANALYSIS':
    case 'REPORTS':               return Icons.bar_chart_rounded;
    case 'DINE_IN':               return Icons.table_restaurant_outlined;
    case 'TAKEAWAY':              return Icons.shopping_bag_outlined;
    case 'DELIVERY':              return Icons.local_shipping_outlined;
    case 'CATERING':              return Icons.people_outline_rounded;
    default:
      if (code.contains('ORDER'))   return Icons.shopping_bag_outlined;
      if (code.contains('REPORT'))  return Icons.bar_chart_rounded;
      if (code.contains('PROFILE')) return Icons.business_outlined;
      return Icons.settings_outlined;
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────
double _d(dynamic v) => (v is num) ? v.toDouble() : double.tryParse(v?.toString() ?? '') ?? 0.0;
int    _i(dynamic v) => (v is int) ? v : int.tryParse(v?.toString() ?? '') ?? 0;
