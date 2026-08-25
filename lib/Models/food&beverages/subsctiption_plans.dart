// // class SubscriptionModel {
// //   final String planType;
// //   final String businessVertical;
// //   final List<Module> modules;
// //
// //   SubscriptionModel({
// //     required this.planType,
// //     required this.businessVertical,
// //     required this.modules,
// //   });
// //
// //   factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
// //     return SubscriptionModel(
// //       planType: json['planType'],
// //       businessVertical: json['businessVertical'],
// //       modules: (json['modules'] as List)
// //           .map((e) => Module.fromJson(e))
// //           .toList(),
// //     );
// //   }
// // }
// //
// // class Module {
// //   final int id;
// //   final String code;
// //   final String description;
// //   final String defaultIncluded;
// //   final double monthlyPrice;
// //   final double yearlyPrice;
// //   final String category;
// //
// //   Module({
// //     required this.id,
// //     required this.code,
// //     required this.description,
// //     required this.defaultIncluded,
// //     required this.monthlyPrice,
// //     required this.yearlyPrice,
// //     required this.category,
// //   });
// //
// //   factory Module.fromJson(Map<String, dynamic> json) {
// //     return Module(
// //       id: json['id'],
// //       code: json['code'],
// //       description: json['description'],
// //       defaultIncluded: json['defaultIncluded'],
// //       monthlyPrice: (json['monthlyPrice'] as num).toDouble(),
// //       yearlyPrice: (json['yearlyPrice'] as num).toDouble(),
// //       category: json['catageory'],
// //     );
// //   }
// // }
// // ─── subscription_model.dart ──────────────────────────────────────────────────
//
// class SubscriptionModel {
//   final String planType;
//   final String businessVertical;
//   final List<Module> modules;
//
//   SubscriptionModel({
//     required this.planType,
//     required this.businessVertical,
//     required this.modules,
//   });
//
//   factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
//     return SubscriptionModel(
//       planType: json['planType'],
//       businessVertical: json['businessVertical'],
//       modules: (json['modules'] as List).map((e) => Module.fromJson(e)).toList(),
//     );
//   }
// }
//
// class Module {
//   final int id;
//   final String code;
//   final String description;
//   final String defaultIncluded;
//   final double monthlyPrice;
//   final double yearlyPrice;
//   final String category;
//
//   Module({
//     required this.id,
//     required this.code,
//     required this.description,
//     required this.defaultIncluded,
//     required this.monthlyPrice,
//     required this.yearlyPrice,
//     required this.category,
//   });
//
//   factory Module.fromJson(Map<String, dynamic> json) {
//     return Module(
//       id: json['id'],
//       code: json['code'],
//       description: json['description'] ?? '',
//       defaultIncluded: json['defaultIncluded'],
//       monthlyPrice: (json['monthlyPrice'] as num).toDouble(),
//       yearlyPrice: (json['yearlyPrice'] as num).toDouble(),
//       // Note: API returns "catageory" (typo in backend) — handled here
//       category: json['catageory'] ?? json['category'] ?? '',
//     );
//   }
// }
//
// // ─── Active Subscription Model (from /api/vendor/subscription GET) ────────────
// class ActiveSubscription {
//   final int subscriptionId;
//   final int vendorId;
//   final String customerId;
//   final String customerName;
//   final String customerMobile;
//   final String planType;
//   final String businessVertical;
//   final String billingCycle;
//   final double totalAmount;
//   final String status;
//   final List<String> selectedModules;
//   final String startDate;
//   final String endDate;
//   final String email;
//   final String city;
//   final int remainingDays;
//   final String message;
//
//   ActiveSubscription({
//     required this.subscriptionId,
//     required this.vendorId,
//     required this.customerId,
//     required this.customerName,
//     required this.customerMobile,
//     required this.planType,
//     required this.businessVertical,
//     required this.billingCycle,
//     required this.totalAmount,
//     required this.status,
//     required this.selectedModules,
//     required this.startDate,
//     required this.endDate,
//     required this.email,
//     required this.city,
//     required this.remainingDays,
//     required this.message,
//   });
//
//   factory ActiveSubscription.fromJson(Map<String, dynamic> json) {
//     return ActiveSubscription(
//       subscriptionId: json['subscriptionId'],
//       vendorId: json['vendorId'],
//       customerId: json['customerId'] ?? '',
//       customerName: json['customerName'] ?? '',
//       customerMobile: json['customerMobile'] ?? '',
//       planType: json['planType'],
//       businessVertical: json['businessVertical'],
//       billingCycle: json['billingCycle'],
//       totalAmount: (json['totalAmount'] as num).toDouble(),
//       status: json['status'],
//       selectedModules: List<String>.from(json['selectedModules'] ?? []),
//       startDate: json['startDate'] ?? '',
//       endDate: json['endDate'] ?? '',
//       email: json['email'] ?? '',
//       city: json['city'] ?? '',
//       remainingDays: json['remainingDays'] ?? 0,
//       message: json['message'] ?? '',
//     );
//   }
//
//   bool get isActive => status == 'ACTIVE';
// }

// lib/models/subscription_models.dart

class SubscriptionPlan {
  final String planType;
  final String businessVertical;
  final List<PlanModule> modules;

  SubscriptionPlan({
    required this.planType,
    required this.businessVertical,
    required this.modules,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      planType: json['planType'] ?? '',
      businessVertical: json['businessVertical'] ?? '',
      modules: (json['modules'] as List? ?? [])
          .map((e) => PlanModule.fromJson(e))
          .toList(),
    );
  }

  List<PlanModule> get basePlan =>
      modules.where((m) => m.category == 'BASE_PLAN').toList();

  List<PlanModule> get featureAddOns =>
      modules.where((m) => m.category == 'FEATURE_ADD_ON').toList();

  List<PlanModule> get orderTypes => modules
      .where(
        (m) => m.category == 'ORDER_TYPE' || m.category == 'ORDERTYPE_ADD_ON',
      )
      .toList();
}

class PlanModule {
  final int id;
  final String code;
  final String description;
  final String defaultIncluded; // MANDATORY | INCLUDE | EXCLUDE
  final double monthlyPrice;
  final double yearlyPrice;
  final String category; // BASE_PLAN | FEATURE_ADD_ON | ORDER_TYPE

  PlanModule({
    required this.id,
    required this.code,
    required this.description,
    required this.defaultIncluded,
    required this.monthlyPrice,
    required this.yearlyPrice,
    required this.category,
  });

  factory PlanModule.fromJson(Map<String, dynamic> json) {
    return PlanModule(
      id: json['id'] ?? 0,
      code: json['code'] ?? '',
      description: json['description'] ?? '',
      defaultIncluded: json['defaultIncluded'] ?? 'INCLUDE',
      monthlyPrice: (json['monthlyPrice'] as num? ?? 0).toDouble(),
      yearlyPrice: (json['yearlyPrice'] as num? ?? 0).toDouble(),
      // Backend has typo "catageory" — handle both
      category: json['catageory'] ?? json['category'] ?? '',
    );
  }

  bool get isMandatory => defaultIncluded == 'MANDATORY';
  bool get isIncluded => defaultIncluded == 'INCLUDE';
  bool get isAddOn => defaultIncluded == 'EXCLUDE';

  String get displayName {
    const names = {
      'DASHBOARD': 'Dashboard',
      'BUSINESS_PROFILE': 'Profile Management',
      'SETTINGS_CONTROLS': 'Settings Management',
      'PRODUCTS_PRICES': 'Products & Prices',
      'ORDER_MANAGEMENT': 'Order Management',
      'CHEF_MANAGEMENT': 'Chef Management',
      'SERVICE_MANAGEMENT': 'Service Management',
      'INVENTORY': 'Inventory',
      'TEAM_MANAGEMENT': 'Team Management',
      'SALES_MANAGEMENT': 'Sales Management',
      'FINANCE_ACCOUNTING': 'Finance & Accounting',
      'PROMOTIONS_MARKETING': 'Promotions & Marketing',
      'REFER_EARN': 'Refer & Earn',
      'REWARDS_COUPONS': 'Rewards & Coupons',
      'RATINGS_REVIEWS': 'Ratings & Reviews',
      'HELP_DESK': 'Support Management',
      'LEGAL_COMPLIANCE': 'Legal Compliance',
      'NOTIFICATIONS': 'Notifications',
      'REPORTS_ANALYSIS': 'Reports & Analysis',
      'ACCOUNT_HISTORY': 'Account History',
      'MENU_MANAGEMENT': 'Menu Management',
      'VENDOR_PROFILE': 'Vendor Profile',
      'REPORTS': 'Reports & Analysis',
      'PLATFORM_ACCESS': 'Platform Access',
      'DELIVERY': 'Delivery',
      'DINE_IN': 'Dine-In',
      'TAKEAWAY': 'Takeaway',
    };
    return names[code] ??
        code
            .split('_')
            .map((w) => '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
            .join(' ');
  }
}

class ActiveSubscription {
  final int subscriptionId;
  final int vendorId;
  final String customerId;
  final String customerName;
  final String customerMobile;
  final String planType;
  final String businessVertical;
  final String billingCycle;
  final double totalAmount;
  final String status;
  final List<String> selectedModules;
  final String startDate;
  final String endDate;
  final String email;
  final String city;
  final int remainingDays;
  final String message;

  ActiveSubscription({
    required this.subscriptionId,
    required this.vendorId,
    required this.customerId,
    required this.customerName,
    required this.customerMobile,
    required this.planType,
    required this.businessVertical,
    required this.billingCycle,
    required this.totalAmount,
    required this.status,
    required this.selectedModules,
    required this.startDate,
    required this.endDate,
    required this.email,
    required this.city,
    required this.remainingDays,
    required this.message,
  });

  factory ActiveSubscription.fromJson(Map<String, dynamic> json) {
    return ActiveSubscription(
      subscriptionId: json['subscriptionId'] ?? 0,
      vendorId: json['vendorId'] ?? 0,
      customerId: json['customerId'] ?? '',
      customerName: json['customerName'] ?? '',
      customerMobile: json['customerMobile'] ?? '',
      planType: json['planType'] ?? '',
      businessVertical: json['businessVertical'] ?? '',
      billingCycle: json['billingCycle'] ?? '',
      totalAmount: (json['totalAmount'] as num? ?? 0).toDouble(),
      status: json['status'] ?? '',
      selectedModules: List<String>.from(json['selectedModules'] ?? []),
      startDate: json['startDate'] ?? '',
      endDate: json['endDate'] ?? '',
      email: json['email'] ?? '',
      city: json['city'] ?? '',
      remainingDays: json['remainingDays'] ?? 0,
      message: json['message'] ?? '',
    );
  }

  bool get isActive => status == 'ACTIVE';
  bool get isTrial => status == 'TRIAL' || billingCycle == 'FREE_TRAIL';
  bool get isExpired => status == 'EXPIRED';
  bool get needsRenewal => isExpired || (isActive && remainingDays <= 7);
}

enum SubscriptionStatus { none, loading, active, trial, expired }
