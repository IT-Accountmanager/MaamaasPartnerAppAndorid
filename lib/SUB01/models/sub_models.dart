// ─── Plan / Module from GET /subscription/api/subscription/plans ─────────────
class SubPlan {
  final int    id;
  final String code;
  final String name;        // display name (mapped)
  final String description;
  final String category;    // ORDER_TYPE | FEATURE_ADD_ON | BASE_PLAN
  final double yearlyPrice;
  final bool   recommended; // defaultIncluded == INCLUDE
  bool   selected;
  bool   termsAccepted;
  int    serialNo;

  SubPlan({
    this.id = 0, this.code = '', this.name = '', this.description = '',
    this.category = '', this.yearlyPrice = 0, this.recommended = false,
    this.selected = false, this.termsAccepted = false, this.serialNo = 0,
  });

  factory SubPlan.fromJson(Map<String, dynamic> j, int serial, {String? overrideName}) {
    const nameMap = {'TABLE_ORDERS': 'Dine Out'};
    final code = j['code']?.toString() ?? '';
    final cat  = j['catageory']?.toString() ?? '';
    final name = overrideName ?? nameMap[code] ?? code.replaceAll('_', ' ');
    return SubPlan(
      id:          _i(j['id']),
      code:        code,
      name:        name,
      description: j['description']?.toString() ?? '',
      category:    cat,
      yearlyPrice: _d(j['yearlyPrice']),
      recommended: j['defaultIncluded']?.toString() == 'INCLUDE',
      serialNo:    serial,
    );
  }

  double get price => yearlyPrice;
  bool   get isOrderType    => category == 'ORDER_TYPE';
  bool   get isFeatureAddOn => category == 'FEATURE_ADD_ON';
  bool   get isBasePlan     => category == 'BASE_PLAN';

  SubPlan copyWith({bool? selected, bool? termsAccepted}) => SubPlan(
    id: id, code: code, name: name, description: description, category: category,
    yearlyPrice: yearlyPrice, recommended: recommended, serialNo: serialNo,
    selected:      selected      ?? this.selected,
    termsAccepted: termsAccepted ?? this.termsAccepted,
  );
}

// ─── Active subscription from GET /vendor_subscription/{id}/active ────────────
class ActiveSubscription {
  final int    subscriptionId;
  final String status;
  final String billingCycle;
  final int    remainingDays;
  final String startDate;
  final String endDate;
  final double totalAmount;
  final List<ActiveModuleItem> selectedModules;

  const ActiveSubscription({
    this.subscriptionId = 0, this.status = '', this.billingCycle = '',
    this.remainingDays = 0, this.startDate = '', this.endDate = '',
    this.totalAmount = 0, this.selectedModules = const [],
  });

  factory ActiveSubscription.fromJson(Map<String, dynamic> j) {
    final rawModules = j['selectedModules'] as List? ?? [];
    return ActiveSubscription(
      subscriptionId: _i(j['subscriptionId']),
      status:         j['status']?.toString() ?? '',
      billingCycle:   j['billingCycle']?.toString() ?? '',
      remainingDays:  _i(j['remainingDays']),
      startDate:      j['startDate']?.toString() ?? '',
      endDate:        j['endDate']?.toString() ?? '',
      totalAmount:    _d(j['totalAmount']),
      selectedModules: rawModules.whereType<Map<String, dynamic>>().map(ActiveModuleItem.fromJson).toList(),
    );
  }
}

class ActiveModuleItem {
  final String moduleCode; // e.g. TABLE_ORDERS
  final String category;   // ORDER_TYPE | FEATURE_ADD_ON

  const ActiveModuleItem({this.moduleCode = '', this.category = ''});

  factory ActiveModuleItem.fromJson(Map<String, dynamic> j) => ActiveModuleItem(
    moduleCode: j['selectedModules']?.toString() ?? '',
    category:   j['catageory']?.toString() ?? '',
  );

  bool get isOrderType    => category == 'ORDER_TYPE';
  bool get isFeatureAddOn => category == 'FEATURE_ADD_ON';

  String get displayName {
    const nameMap = {'TABLE_ORDERS': 'Dine Out'};
    return nameMap[moduleCode] ?? moduleCode.replaceAll('_', ' ');
  }

  String get displayCategory {
    return category
        .toLowerCase()
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────
double _d(dynamic v) => (v is num) ? v.toDouble() : double.tryParse(v?.toString() ?? '') ?? 0.0;
int    _i(dynamic v) => (v is int) ? v : int.tryParse(v?.toString() ?? '') ?? 0;
