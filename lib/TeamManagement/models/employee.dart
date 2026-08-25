// // ─── Employee roles — exact values from EMPLOYEE_ROLES in React ────────────────
// class EmployeeRole {
//   final String value;
//   final String label;
//   const EmployeeRole({required this.value, required this.label});
// }
//
// const kEmployeeRoles = [
//   EmployeeRole(value: 'Manager',          label: 'Manager'),
//   EmployeeRole(value: 'Waiter',           label: 'Waiter'),
//   EmployeeRole(value: 'Chef_North',       label: 'Chef - North Indian'),
//   EmployeeRole(value: 'Chef_South',       label: 'Chef - South Indian'),
//   EmployeeRole(value: 'Chef_Continental', label: 'Chef - Continental'),
//   EmployeeRole(value: 'Chef_Chinese',     label: 'Chef - Chinese'),
//   EmployeeRole(value: 'Chef_All',         label: 'Chef - All Cuisines'),
//   EmployeeRole(value: 'Tea_stall',        label: 'Tea Stall'),
//   EmployeeRole(value: 'Snacks',           label: 'Snacks'),
//   EmployeeRole(value: 'Bakery',           label: 'Bakery'),
// ];
//
// String roleLabel(String value) =>
//     kEmployeeRoles.firstWhere((r) => r.value == value,
//         orElse: () => EmployeeRole(value: value, label: value)).label;
//
// // ─── Employee ──────────────────────────────────────────────────────────────────
// // Mirrors formatEmployeeForDisplay from employeeService.js exactly
// class Employee {
//   final String id;        // "EMP-098"
//   final int    vendorId;
//   final String name;
//   final String role;      // employeRole from API
//   final String department;
//   final String phone;
//   final String location;
//   final String supervisor;
//   final String joined;    // ISO date string (createdAt trimmed to date)
//   bool         isActive;  // enabled
//   final String email;
//   String       exitDate;
//   String       remarks;
//   final List<String> businessModules;
//   final List<String> subModules;
//   final Map<String, dynamic> raw;
//
//   Employee({
//     required this.id,
//     required this.vendorId,
//     required this.name,
//     required this.role,
//     required this.department,
//     required this.phone,
//     required this.location,
//     required this.supervisor,
//     required this.joined,
//     required this.isActive,
//     required this.email,
//     required this.exitDate,
//     required this.remarks,
//     required this.businessModules,
//     required this.subModules,
//     required this.raw,
//   });
//
//   // Mirrors formatEmployeeForDisplay(employee)
//   factory Employee.fromJson(Map<String, dynamic> j) {
//     final vid    = j['vendorId'] ?? 0;
//     final joinedRaw = j['createdAt'] ?? j['registerTime'] ?? '';
//     String joined = '';
//     try {
//       joined = DateTime.parse(joinedRaw).toIso8601String().split('T')[0];
//     } catch (_) {
//       joined = joinedRaw.toString().split('T')[0];
//     }
//     final mods = j['businessModules'];
//     final subs = j['subModules'];
//     return Employee(
//       id:              'EMP-${vid.toString().padLeft(3, '0')}',
//       vendorId:        vid,
//       name:            j['name']         ?? 'Unknown',
//       role:            j['employeRole']  ?? j['role'] ?? '',
//       department:      j['department']   ?? 'General',
//       phone:           j['mobileNumber'] ?? 'N/A',
//       location:        j['city']         ?? 'Unknown',
//       supervisor:      'Admin',
//       joined:          joined,
//       isActive:        j['enabled'] == true,
//       email:           j['email']        ?? '',
//       exitDate:        j['exitDate']     ?? '',
//       remarks:         j['remarks']      ?? '',
//       businessModules: mods is List ? mods.map((e) => e.toString()).toList() : [],
//       subModules:      subs is List ? subs.map((e) => e.toString()).toList() : [],
//       raw:             j,
//     );
//   }
//
//   // Human-readable joined date  e.g. "12 Jan 2024"
//   String get joinedDisplay {
//     try {
//       final d = DateTime.parse(joined);
//       const months = ['','Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
//       return '${d.day} ${months[d.month]} ${d.year}';
//     } catch (_) { return joined; }
//   }
// }
class EmployeeRole {
  final String value;
  final String label;
  const EmployeeRole({required this.value, required this.label});
}

const kEmployeeRoles = [
  EmployeeRole(value: 'Manager', label: 'Manager'),
  EmployeeRole(value: 'Waiter', label: 'Waiter'),
  EmployeeRole(value: 'Chef_North', label: 'Chef - North Indian'),
  EmployeeRole(value: 'Chef_South', label: 'Chef - South Indian'),
  EmployeeRole(value: 'Chef_Continental', label: 'Chef - Continental'),
  EmployeeRole(value: 'Chef_Chinese', label: 'Chef - Chinese'),
  EmployeeRole(value: 'Chef_All', label: 'Chef - All Cuisines'),
  EmployeeRole(value: 'Tea_stall', label: 'Tea Stall'),
  EmployeeRole(value: 'Snacks', label: 'Snacks'),
  EmployeeRole(value: 'Bakery', label: 'Bakery'),
];

String roleLabel(String value) => kEmployeeRoles
    .firstWhere(
      (r) => r.value == value,
      orElse: () => EmployeeRole(value: value, label: value),
    )
    .label;

// ─── Employee ──────────────────────────────────────────────────────────────────
class Employee {
  final String id;
  final int vendorId;
  final String name;
  final String role;
  final String department;
  final String phone;
  final String location;
  final String supervisor;
  final String joined;
  bool isActive;
  final String email;
  String exitDate;
  String remarks;
  final List<String> businessModules;
  final List<String> subModules;
  final String username;
  final String password;
  final Map<String, dynamic> raw;

  Employee({
    required this.id,
    required this.vendorId,
    required this.name,
    required this.role,
    required this.department,
    required this.phone,
    required this.location,
    required this.supervisor,
    required this.joined,
    required this.isActive,
    required this.email,
    required this.exitDate,
    required this.remarks,
    required this.businessModules,
    required this.subModules,
    required this.username,
    required this.password,
    required this.raw,
  });

  factory Employee.fromJson(Map<String, dynamic> j) {
    final vid = j['vendorId'] ?? 0;
    final joinedRaw = j['createdAt'] ?? j['registerTime'] ?? '';
    String joined = '';
    try {
      joined = DateTime.parse(joinedRaw).toIso8601String().split('T')[0];
    } catch (_) {
      joined = joinedRaw.toString().split('T')[0];
    }
    final mods = j['businessModules'];
    final subs = j['subModules'];
    return Employee(
      id: 'EMP-${vid.toString().padLeft(3, '0')}',
      vendorId: vid,
      name: j['name'] ?? 'Unknown',
      role: j['employeRole'] ?? j['role'] ?? '',
      department: j['department'] ?? 'General',
      phone: j['mobileNumber'] ?? 'N/A',
      location: j['city'] ?? 'Unknown',
      supervisor: 'Admin',
      joined: joined,
      isActive: j['enabled'] == true,
      email: j['email'] ?? '',
      exitDate: j['exitDate'] ?? '',
      remarks: j['remarks'] ?? '',
      businessModules: mods is List
          ? mods.map((e) => e.toString()).toList()
          : [],
      subModules: subs is List ? subs.map((e) => e.toString()).toList() : [],
      username: j['username'] ?? '',
      password: j['password'] ?? '',
      // ────────────────────────────────────────────────────────────────────────
      raw: j,
    );
  }

  String get joinedDisplay {
    try {
      final d = DateTime.parse(joined);
      const months = [
        '',
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${d.day} ${months[d.month]} ${d.year}';
    } catch (_) {
      return joined;
    }
  }
}

// ─── Employee Slot Plan ──────────────────────────────────────────────────────
class EmployeeSlotPlan {
  final double slotPrice;
  final int freeEmployeeLimit;
  final int? purchasedEmployeeSlots;
  final bool active;

  EmployeeSlotPlan({
    required this.slotPrice,
    required this.freeEmployeeLimit,
    required this.purchasedEmployeeSlots,
    required this.active,
  });

  factory EmployeeSlotPlan.fromJson(Map<String, dynamic> j) {
    return EmployeeSlotPlan(
      slotPrice: (j['slotPrice'] as num?)?.toDouble() ?? 50.0,
      freeEmployeeLimit: (j['freeEmployeeLimit'] as num?)?.toInt() ?? 3,
      purchasedEmployeeSlots: (j['purchasedEmployeeSlots'] as num?)?.toInt(),
      active: j['active'] == true,
    );
  }

  factory EmployeeSlotPlan.empty() => EmployeeSlotPlan(
    slotPrice: 50.0,
    freeEmployeeLimit: 3,
    purchasedEmployeeSlots: null,
    active: true,
  );
}

// ─── Slot Purchase record ────────────────────────────────────────────────────
class SlotPurchase {
  final int? id;
  final int vendorId;
  final int slotsPurchased;
  final double pricePerSlot;
  final double totalAmount;
  final String paymentId;
  final String orderId;
  final String paymentStatus;
  final String purchaseDate;

  SlotPurchase({
    this.id,
    required this.vendorId,
    required this.slotsPurchased,
    required this.pricePerSlot,
    required this.totalAmount,
    required this.paymentId,
    required this.orderId,
    required this.paymentStatus,
    required this.purchaseDate,
  });

  factory SlotPurchase.fromJson(Map<String, dynamic> j) {
    return SlotPurchase(
      id: (j['id'] as num?)?.toInt(),
      vendorId: (j['vendorId'] as num?)?.toInt() ?? 0,
      slotsPurchased: (j['slotsPurchased'] as num?)?.toInt() ?? 0,
      pricePerSlot: (j['pricePerSlot'] as num?)?.toDouble() ?? 0,
      totalAmount: (j['totalAmount'] as num?)?.toDouble() ?? 0,
      paymentId: j['paymentId']?.toString() ?? '',
      orderId: j['orderId']?.toString() ?? '',
      paymentStatus: j['paymentStatus']?.toString() ?? '',
      purchaseDate: j['purchaseDate']?.toString() ?? '',
    );
  }
}

// ─── Derived summary the UI actually renders ─────────────────────────────────

class EmployeeSlotSummary {
  final int freeLimit;
  final int purchasedSlots;
  final double slotPrice;
  final int currentEmployees;

  EmployeeSlotSummary({
    required this.freeLimit,
    required this.purchasedSlots,
    required this.slotPrice,
    required this.currentEmployees,
  });

  int get totalAvailable => freeLimit + purchasedSlots;
  int get remainingSlots => (totalAvailable - currentEmployees) < 0
      ? 0
      : totalAvailable - currentEmployees;
  bool get limitReached => currentEmployees >= totalAvailable;
  double get progress =>
      totalAvailable == 0 ? 0 : (currentEmployees / totalAvailable).clamp(0, 1);
}
