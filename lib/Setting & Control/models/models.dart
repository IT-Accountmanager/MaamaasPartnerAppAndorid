//
// class DayTiming {
//   int? id;
//   String day;
//   String open;
//   String close;
//
//   DayTiming({
//     required this.day,
//     this.open = '09:00',
//     this.close = '22:00',
//     this.id,
//   });
//
//   factory DayTiming.fromJson(Map<String, dynamic> j) => DayTiming(
//     id: j['id'],
//     day: j['day'] ?? '',
//     open: _trim(j['startTime']) ?? '09:00',
//     close: _trim(j['lastTime']) ?? '22:00',
//   );
//
//   static String? _trim(dynamic v) {
//     if (v == null) return null;
//     final s = v.toString();
//     return s.length >= 5 ? s.substring(0, 5) : null;
//   }
//
//   String get startTimeApi => '$open:00';
//   String get lastTimeApi => '$close:00';
//
//   String get openDisplay => _ampm(open);
//   String get closeDisplay => _ampm(close);
//
//   static String _ampm(String t) {
//     final p = t.split(':');
//     if (p.length < 2) return t;
//     final h = int.tryParse(p[0]) ?? 0;
//     final m = p[1];
//     final ap = h >= 12 ? 'PM' : 'AM';
//     final h12 = h > 12 ? h - 12 : (h == 0 ? 12 : h);
//     return '$h12:$m $ap';
//   }
// }
//
// // ─── BillingConfig ─────────────────────────────────────────────────────────────
// class BillingConfig {
//   int? id;
//   int? vendorId;
//
//   bool serviceChargeEnabled;
//   double serviceCharges;
//   String serviceChargesType;
//   String serviceChargesApply;
//   String platformChargeType;
//   String initialOrderStatus;
//   String userInitialOrderStatus;
//
//   // ── NEW fields ──────────────────────────────────────────────────────────────
//   bool cashierKot;
//   bool chefKot;
//   bool kotbilling;
//   List<String> orderTypes;
//
//   // Derived UI fields
//   String get regularOrders =>
//       initialOrderStatus == 'CONFIRMED' ? 'chef' : 'delivery';
//   String get onlineOrders =>
//       userInitialOrderStatus == 'CONFIRMED' ? 'chef' : 'vendor';
//
//   set regularOrders(String v) =>
//       initialOrderStatus = v == 'chef' ? 'CONFIRMED' : 'DELIVERED';
//   set onlineOrders(String v) =>
//       userInitialOrderStatus = v == 'chef' ? 'CONFIRMED' : 'PENDING';
//
//   BillingConfig({
//     this.id,
//     this.vendorId,
//     this.serviceChargeEnabled = false,
//     this.serviceCharges = 0,
//     this.serviceChargesType = 'BUSINESS_BORNE',
//     this.serviceChargesApply = 'Not_Applicable',
//     this.platformChargeType = 'BUSINESS_BORNE',
//     this.initialOrderStatus = 'DELIVERED',
//     this.userInitialOrderStatus = 'PENDING',
//     this.cashierKot = false,
//     this.chefKot = false,
//     this.kotbilling = false,
//     List<String>? orderTypes,
//   }) : orderTypes = orderTypes ?? [];
//
//   factory BillingConfig.fromJson(Map<String, dynamic> j) {
//     final sc = (j['serviceCharges'] as num?)?.toDouble() ?? 0.0;
//     final sca = j['serviceChargesApply']?.toString() ?? 'Not_Applicable';
//
//     // Parse orderTypes
//     final rawTypes = j['orderTypes'];
//     final List<String> types = rawTypes is List
//         ? rawTypes.map((e) => e.toString()).toList()
//         : [];
//
//     return BillingConfig(
//       id: j['id'],
//       vendorId: j['vendorId'],
//       serviceChargeEnabled: sc > 0 && sca == 'Applicable',
//       serviceCharges: sc,
//       serviceChargesType: j['serviceChargesType'] ?? 'BUSINESS_BORNE',
//       serviceChargesApply: sca,
//       platformChargeType: j['platformChargeType'] ?? 'BUSINESS_BORNE',
//       initialOrderStatus: j['initialOrderStatus'] ?? 'DELIVERED',
//       userInitialOrderStatus: j['userInitialOrderStatus'] ?? 'PENDING',
//       cashierKot: j['cashierKot'] == true,
//       chefKot: j['chefKot'] == true,
//       kotbilling: j['kotbilling'] == true,
//       orderTypes: types,
//     );
//   }
//
//   // orderTypes is intentionally excluded — it is saved via the dedicated
//   // PUT /billing/vendor/{vendorId}/order-types endpoint in BillingApi.
//   Map<String, dynamic> toApiPayload(int vendorIdVal) {
//     final charges = serviceChargeEnabled ? serviceCharges : 0.0;
//     return {
//       if (id != null) 'id': id,
//       'vendorId': vendorId ?? vendorIdVal,
//       'serviceCharges': charges,
//       'serviceChargesType': serviceChargesType,
//       'serviceChargesApply': serviceChargesApply,
//       'platformChargeType': 'BUSINESS_BORNE',
//       'initialOrderStatus': initialOrderStatus,
//       'userInitialOrderStatus': userInitialOrderStatus,
//       'cashierKot': cashierKot,
//       'chefKot': chefKot,
//       'kotbilling': kotbilling,
//     };
//   }
// }
//
// // ─── Module defs ───────────────────────────────────────────────────────────────
// class SubModuleDef {
//   final String backendName;
//   final String displayName;
//   const SubModuleDef({required this.backendName, required this.displayName});
// }
//
// class ModuleDef {
//   final String backendName;
//   final String displayName;
//   final int order;
//   final bool showInUI;
//   final List<SubModuleDef> subModules;
//   const ModuleDef({
//     required this.backendName,
//     required this.displayName,
//     required this.order,
//     this.showInUI = true,
//     this.subModules = const [],
//   });
// }
//
// // ─── EmployeeModule ────────────────────────────────────────────────────────────
// class EmployeeModule {
//   final int vendorId;
//   final String name;
//   final String role;
//   final String createdAt;
//   bool isActive;
//   List<String> businessModules;
//   List<String> subModules;
//
//   EmployeeModule({
//     required this.vendorId,
//     required this.name,
//     required this.role,
//     required this.createdAt,
//     this.isActive = true,
//     this.businessModules = const [],
//     this.subModules = const [],
//   });
//
//   factory EmployeeModule.fromJson(Map<String, dynamic> j) {
//     final mods = j['businessModules'];
//     final subs = j['subModules'];
//     return EmployeeModule(
//       vendorId: j['vendorId'] ?? 0,
//       name: j['name'] ?? 'Unknown',
//       role: j['employeRole'] ?? j['role'] ?? '',
//       createdAt: j['createdAt'] ?? DateTime.now().toIso8601String(),
//       isActive: j['enabled'] == true,
//       businessModules: mods is List
//           ? mods.map((e) => e.toString()).toList()
//           : [],
//       subModules: subs is List ? subs.map((e) => e.toString()).toList() : [],
//     );
//   }
// }

class DayTiming {
  int? id;
  String day;
  String open;
  String close;

  DayTiming({
    required this.day,
    this.open = '09:00',
    this.close = '22:00',
    this.id,
  });

  factory DayTiming.fromJson(Map<String, dynamic> j) => DayTiming(
    id: j['id'],
    day: j['day'] ?? '',
    open: _trim(j['startTime']) ?? '09:00',
    close: _trim(j['lastTime']) ?? '22:00',
  );

  static String? _trim(dynamic v) {
    if (v == null) return null;
    final s = v.toString();
    return s.length >= 5 ? s.substring(0, 5) : null;
  }

  String get startTimeApi => '$open:00';
  String get lastTimeApi => '$close:00';

  String get openDisplay => _ampm(open);
  String get closeDisplay => _ampm(close);

  static String _ampm(String t) {
    final p = t.split(':');
    if (p.length < 2) return t;
    final h = int.tryParse(p[0]) ?? 0;
    final m = p[1];
    final ap = h >= 12 ? 'PM' : 'AM';
    final h12 = h > 12 ? h - 12 : (h == 0 ? 12 : h);
    return '$h12:$m $ap';
  }
}

// ─── BillingConfig ─────────────────────────────────────────────────────────────
class BillingConfig {
  int? id;
  int? vendorId;

  bool serviceChargeEnabled;
  double serviceCharges;
  String serviceChargesType;
  String serviceChargesApply;
  String platformChargeType;
  String initialOrderStatus;
  String userInitialOrderStatus;

  // ── KOT fields ──────────────────────────────────────────────────────────────
  bool cashierKot;
  bool chefKot;
  bool kotbilling;
  bool autoPrint;

  // ── Order types ─────────────────────────────────────────────────────────────
  List<String> orderTypes;

  // ── Payment modes ────────────────────────────────────────────────────────────
  bool cash;
  bool qrCode;
  bool upi;
  bool splitBilling;
  bool zoom;

  // Derived UI fields
  String get regularOrders =>
      initialOrderStatus == 'CONFIRMED' ? 'chef' : 'delivery';
  String get onlineOrders =>
      userInitialOrderStatus == 'CONFIRMED' ? 'chef' : 'vendor';

  set regularOrders(String v) =>
      initialOrderStatus = v == 'chef' ? 'CONFIRMED' : 'DELIVERED';
  set onlineOrders(String v) =>
      userInitialOrderStatus = v == 'chef' ? 'CONFIRMED' : 'PENDING';

  BillingConfig({
    this.id,
    this.vendorId,
    this.serviceChargeEnabled = false,
    this.serviceCharges = 0,
    this.serviceChargesType = 'BUSINESS_BORNE',
    this.serviceChargesApply = 'Not_Applicable',
    this.platformChargeType = 'BUSINESS_BORNE',
    this.initialOrderStatus = 'DELIVERED',
    this.userInitialOrderStatus = 'PENDING',
    this.cashierKot = false,
    this.chefKot = false,
    this.kotbilling = false,
    this.autoPrint = false,
    List<String>? orderTypes,
    this.cash = false,
    this.qrCode = false,
    this.upi = false,
    this.splitBilling = false,
    this.zoom = false,
  }) : orderTypes = orderTypes ?? [];

  factory BillingConfig.fromJson(Map<String, dynamic> j) {
    final sc = (j['serviceCharges'] as num?)?.toDouble() ?? 0.0;
    final sca = j['serviceChargesApply']?.toString() ?? 'Not_Applicable';

    // Parse orderTypes
    final rawTypes = j['orderTypes'];
    final List<String> types = rawTypes is List
        ? rawTypes.map((e) => e.toString()).toList()
        : [];

    return BillingConfig(
      id: j['id'],
      vendorId: j['vendorId'],
      serviceChargeEnabled: sc > 0 && sca == 'Applicable',
      serviceCharges: sc,
      serviceChargesType: j['serviceChargesType'] ?? 'BUSINESS_BORNE',
      serviceChargesApply: sca,
      platformChargeType: j['platformChargeType'] ?? 'BUSINESS_BORNE',
      initialOrderStatus: j['initialOrderStatus'] ?? 'DELIVERED',
      userInitialOrderStatus: j['userInitialOrderStatus'] ?? 'PENDING',
      cashierKot: j['cashierKot'] == true,
      chefKot: j['chefKot'] == true,
      kotbilling: j['kotbilling'] == true,
      autoPrint: j['autoPrint'] == true,
      orderTypes: types,
      cash: j['cash'] == true,
      qrCode: j['qrCode'] == true,
      upi: j['upi'] == true,
      splitBilling: j['splitBilling'] == true,
      zoom: j['zoom'] == true,
    );
  }

  Map<String, dynamic> toApiPayload(int vendorIdVal) {
    final charges = serviceChargeEnabled ? serviceCharges : 0.0;
    return {
      if (id != null) 'id': id,
      'vendorId': vendorId ?? vendorIdVal,
      'serviceCharges': charges,
      'serviceChargesType': serviceChargesType,
      'serviceChargesApply': serviceChargesApply,
      'platformChargeType': 'BUSINESS_BORNE',
      'initialOrderStatus': initialOrderStatus,
      'userInitialOrderStatus': userInitialOrderStatus,
      'cashierKot': cashierKot,
      'chefKot': chefKot,
      'kotbilling': kotbilling,
      'autoPrint': autoPrint,
      'cash': cash,
      'qrCode': qrCode,
      'upi': upi,
      'splitBilling': splitBilling,
      'zoom': zoom,
    };
  }
}

// ─── Module defs ───────────────────────────────────────────────────────────────
class SubModuleDef {
  final String backendName;
  final String displayName;
  const SubModuleDef({required this.backendName, required this.displayName});
}

class ModuleDef {
  final String backendName;
  final String displayName;
  final int order;
  final bool showInUI;
  final List<SubModuleDef> subModules;
  const ModuleDef({
    required this.backendName,
    required this.displayName,
    required this.order,
    this.showInUI = true,
    this.subModules = const [],
  });
}

// ─── EmployeeModule ────────────────────────────────────────────────────────────
class EmployeeModule {
  final int vendorId;
  final String name;
  final String role;
  final String createdAt;
  bool isActive;
  List<String> businessModules;
  List<String> subModules;

  EmployeeModule({
    required this.vendorId,
    required this.name,
    required this.role,
    required this.createdAt,
    this.isActive = true,
    this.businessModules = const [],
    this.subModules = const [],
  });

  factory EmployeeModule.fromJson(Map<String, dynamic> j) {
    final mods = j['businessModules'];
    final subs = j['subModules'];
    return EmployeeModule(
      vendorId: j['vendorId'] ?? 0,
      name: j['name'] ?? 'Unknown',
      role: j['employeRole'] ?? j['role'] ?? '',
      createdAt: j['createdAt'] ?? DateTime.now().toIso8601String(),
      isActive: j['enabled'] == true,
      businessModules: mods is List
          ? mods.map((e) => e.toString()).toList()
          : [],
      subModules: subs is List ? subs.map((e) => e.toString()).toList() : [],
    );
  }
}
