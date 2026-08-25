// // ─── Settlement entry ─────────────────────────────────────────────────────────
// class Settlement {
//   final int settlementId;
//   final String transactionId;
//   final double totalGrandTotal;
//   final double totalCgst;
//   final double totalSgst;
//   final double totalPlatformCharges;
//   final double tdsAmount;
//   final double totalVendorPlatformCharges;
//   final double totalVendorPlatformChargesGst;
//   final double totalOnlinePayment;
//   final double totalCash;
//   final double totalWalletPayment;
//   final double finalAmount;
//   final String paymentStatus;
//   final String pytMode;
//   final String? description;
//   final String? remarks;
//   final String? fromDate;
//   final String? toDate;
//   final String? settlementDate;
//   final String? updatedAt;
//
//   Settlement({
//     required this.settlementId,
//     this.transactionId = '',
//     this.totalGrandTotal = 0,
//     this.totalCgst = 0,
//     this.totalSgst = 0,
//     this.totalPlatformCharges = 0,
//     this.tdsAmount = 0,
//     this.totalVendorPlatformCharges = 0,
//     this.totalVendorPlatformChargesGst = 0,
//     this.totalOnlinePayment = 0,
//     this.totalCash = 0,
//     this.totalWalletPayment = 0,
//     this.finalAmount = 0,
//     this.paymentStatus = 'PENDING',
//     this.pytMode = '',
//     this.description,
//     this.remarks,
//     this.fromDate,
//     this.toDate,
//     this.settlementDate,
//     this.updatedAt,
//   });
//
//   factory Settlement.fromJson(Map<String, dynamic> j) => Settlement(
//     settlementId: _i(j['settlementId']),
//     transactionId: j['transactionId']?.toString() ?? '',
//     totalGrandTotal: _d(j['totalGrandTotal']),
//     totalCgst: _d(j['totalCgst']),
//     totalSgst: _d(j['totalSgst']),
//     totalPlatformCharges: _d(j['totalPlatformCharges']),
//     tdsAmount: _d(j['tdsAmount']),
//     totalVendorPlatformCharges: _d(j['totalVendorPlatformCharges']),
//     totalVendorPlatformChargesGst: _d(j['totalVendorPlatformChargesGst']),
//     totalOnlinePayment: _d(j['totalOnlinePayment']),
//     totalCash: _d(j['totalCash']),
//     totalWalletPayment: _d(j['totalWalletPayment']),
//     finalAmount: _d(j['finalAmount']),
//     paymentStatus: j['paymentStatus']?.toString() ?? 'PENDING',
//     pytMode: j['pytMode']?.toString() ?? '',
//     description: j['description']?.toString(),
//     remarks: j['remarks']?.toString(),
//     fromDate: j['fromDate']?.toString(),
//     toDate: j['toDate']?.toString(),
//     settlementDate: j['settlementDate']?.toString(),
//     updatedAt: j['updatedAt']?.toString(),
//   );
//
//   // ── Computed ──────────────────────────────────────────────────────────────
//   bool get isPaid =>
//       paymentStatus.toUpperCase() == 'PAID' ||
//       paymentStatus.toUpperCase() == 'COMPLETED';
//
//   double get netAmount {
//     if (totalOnlinePayment > 0) {
//       // Online: deduct CGST + SGST + platform + TDS
//       return totalGrandTotal -
//           totalCgst -
//           totalSgst -
//           totalPlatformCharges -
//           tdsAmount;
//     } else {
//       // Cash: deduct vendor platform charges
//       return totalGrandTotal -
//           totalCgst -
//           totalSgst -
//           totalVendorPlatformCharges -
//           totalVendorPlatformChargesGst;
//     }
//   }
//
//   double get totalCharges => totalGrandTotal - netAmount;
//
//   String get paymentModeLabel {
//     const map = {
//       'FT': 'Bank Transfer',
//       'IMPS': 'IMPS',
//       'NEFT': 'NEFT',
//       'RTGS': 'RTGS',
//       'UPI': 'UPI',
//       'CASH': 'Cash',
//       'CHEQUE': 'Cheque',
//     };
//     return map[pytMode.toUpperCase()] ??
//         (pytMode.isNotEmpty ? pytMode : 'Bank Transfer');
//   }
// }
//
// // ─── Settlement summary ───────────────────────────────────────────────────────
// class SettlementSummary {
//   final int totalSettlements;
//   final int successfulSettlements;
//   final int pendingSettlements;
//   final double pendingCredits;
//   final List<Settlement> settlements;
//
//   SettlementSummary({
//     this.totalSettlements = 0,
//     this.successfulSettlements = 0,
//     this.pendingSettlements = 0,
//     this.pendingCredits = 0,
//     this.settlements = const [],
//   });
//
//   factory SettlementSummary.fromJson(Map<String, dynamic> j) {
//     final list = j['settlements'] as List? ?? [];
//     return SettlementSummary(
//       totalSettlements: _i(j['totalSettlements']),
//       successfulSettlements: _i(j['successfulSettlements']),
//       pendingSettlements: _i(j['pendingSettlements']),
//       pendingCredits: _d(j['pendingCredits']),
//       settlements: list
//           .whereType<Map<String, dynamic>>()
//           .map(Settlement.fromJson)
//           .toList(),
//     );
//   }
// }
//
// // ─── Credit stats ─────────────────────────────────────────────────────────────
// // GET /food/api/vendor/credit/{vendorId}
// class CreditStats {
//   final double totalCreditPoints;
//   final double usedCreditPoints;
//   final double availableCreditPoints;
//   final double pendingCreditPoints;
//   final double pendingAmount;
//   final double paidAmount;
//
//   CreditStats({
//     this.totalCreditPoints = 0,
//     this.usedCreditPoints = 0,
//     this.availableCreditPoints = 0,
//     this.pendingCreditPoints = 0,
//     this.pendingAmount = 0,
//     this.paidAmount = 0,
//   });
//
//   factory CreditStats.fromJson(Map<String, dynamic> j) => CreditStats(
//     totalCreditPoints: _d(j['totalCreditPoints']),
//     usedCreditPoints: _d(j['usedCreditPoints']),
//     availableCreditPoints: _d(j['availableCreditPoints']),
//     pendingCreditPoints: _d(j['pendingCreditPoints']),
//     pendingAmount: _d(j['pendingAmount']),
//     paidAmount: _d(j['paidAmount']),
//   );
//
//   // active | warning | payment_required
//   String get status {
//     if (totalCreditPoints <= 0) return 'active';
//     if (usedCreditPoints >= totalCreditPoints) return 'payment_required';
//     if (usedCreditPoints >= totalCreditPoints * 0.7) return 'warning';
//     return 'active';
//   }
//
//   double get usagePercent => totalCreditPoints > 0
//       ? (usedCreditPoints / totalCreditPoints).clamp(0.0, 1.0)
//       : 0.0;
// }
//
// // ─── Order (for Ledger tab) ───────────────────────────────────────────────────
// // GET /food/api/orders/vendor/date-range/{vendorId}?startDate=X&endDate=Y
// class LedgerOrder {
//   final String orderId;
//   final double grandTotal;
//   final double deliveryCharges;
//   final double platformCharges;
//   final double platformChargesGst;
//   final double vendorPlatformCharge;
//   final double vendorPlatformChargeGst;
//   final String paymentMethod;
//   final String date; // YYYY-MM-DD
//   final String? orderDateAndTime;
//   final String? time;
//   final String? orderType;
//
//   LedgerOrder({
//     this.orderId = '',
//     this.grandTotal = 0,
//     this.deliveryCharges = 0,
//     this.platformCharges = 0,
//     this.platformChargesGst = 0,
//     this.vendorPlatformCharge = 0,
//     this.vendorPlatformChargeGst = 0,
//     this.paymentMethod = '',
//     this.date = '',
//     this.orderDateAndTime,
//     this.time,
//     this.orderType,
//   });
//
//   factory LedgerOrder.fromJson(Map<String, dynamic> j) => LedgerOrder(
//     orderId: j['orderId']?.toString() ?? '',
//     grandTotal: _d(j['grandTotal']),
//     deliveryCharges: _d(j['deliveryCharges']),
//     platformCharges: _d(j['platformCharges']),
//     platformChargesGst: _d(j['platformChargesGst']),
//     vendorPlatformCharge: _d(j['vendorPlatformCharge']),
//     vendorPlatformChargeGst: _d(j['vendorPlatformChargeGst']),
//     paymentMethod: j['paymentMethod']?.toString() ?? '',
//     date: j['date']?.toString() ?? '',
//     orderDateAndTime: j['orderDateAndTime']?.toString(),
//     time: j['time']?.toString(),
//     orderType: j['orderType']?.toString(),
//   );
//
//   double get netAmount {
//     final charges =
//         deliveryCharges +
//         platformCharges +
//         platformChargesGst +
//         vendorPlatformCharge +
//         vendorPlatformChargeGst;
//     return grandTotal - charges;
//   }
// }
//
// // ─── Daily ledger group ───────────────────────────────────────────────────────
// class DailyLedger {
//   final String date;
//   final double totalNetAmount;
//   final int orderCount;
//   final List<LedgerOrder> orders;
//
//   DailyLedger({
//     required this.date,
//     required this.totalNetAmount,
//     required this.orderCount,
//     required this.orders,
//   });
//
//   String get formattedDate {
//     try {
//       final dt = DateTime.parse(date);
//       final now = DateTime.now();
//       final today = DateTime(now.year, now.month, now.day);
//       final yesterday = today.subtract(const Duration(days: 1));
//       final d = DateTime(dt.year, dt.month, dt.day);
//       final months = [
//         'Jan',
//         'Feb',
//         'Mar',
//         'Apr',
//         'May',
//         'Jun',
//         'Jul',
//         'Aug',
//         'Sep',
//         'Oct',
//         'Nov',
//         'Dec',
//       ];
//       if (d == today) return 'Today, ${months[dt.month - 1]} ${dt.day}';
//       if (d == yesterday) return 'Yesterday, ${months[dt.month - 1]} ${dt.day}';
//       return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
//     } catch (_) {
//       return date;
//     }
//   }
// }
//
// // ─── Helpers ──────────────────────────────────────────────────────────────────
// double _d(dynamic v) =>
//     (v is num) ? v.toDouble() : double.tryParse(v?.toString() ?? '') ?? 0.0;
// int _i(dynamic v) => (v is int) ? v : int.tryParse(v?.toString() ?? '') ?? 0;
// // ─── Cash Billing Record ──────────────────────────────────────────────────────
//
//
// class CashBillingRecord {
//   final int    id;
//   final String orderId;
//   final String date;
//   final int    fiveHundredRupee;
//   final int    twoHundredRupee;
//   final int    hundredRupee;
//   final int    fiftyRupee;
//   final int    twentyRupee;
//   final int    tenRupee;
//   final int    fiveRupee;
//   final int    twoRupee;
//   final int    oneRupee;
//   final double grandTotal;
//   final double paid;
//   final double returnMoney;
//   final String paymentStatus; // PAID | PENDING
//
//   const CashBillingRecord({
//     this.id = 0,
//     this.orderId = '',
//     this.date = '',
//     this.fiveHundredRupee = 0,
//     this.twoHundredRupee = 0,
//     this.hundredRupee = 0,
//     this.fiftyRupee = 0,
//     this.twentyRupee = 0,
//     this.tenRupee = 0,
//     this.fiveRupee = 0,
//     this.twoRupee = 0,
//     this.oneRupee = 0,
//     this.grandTotal = 0,
//     this.paid = 0,
//     this.returnMoney = 0,
//     this.paymentStatus = 'PENDING',
//   });
//
//   factory CashBillingRecord.fromJson(Map<String, dynamic> j) =>
//       CashBillingRecord(
//         id:               _i(j['id']),
//         orderId:          j['orderId']?.toString() ?? '',
//         date:             j['date']?.toString() ?? '',
//         fiveHundredRupee: _i(j['fiveHundredRupee']),
//         twoHundredRupee:  _i(j['twoHundredRupee']),
//         hundredRupee:     _i(j['hundredRupee']),
//         fiftyRupee:       _i(j['fiftyRupee']),
//         twentyRupee:      _i(j['twentyRupee']),
//         tenRupee:         _i(j['tenRupee']),
//         fiveRupee:        _i(j['fiveRupee']),
//         twoRupee:         _i(j['twoRupee']),
//         oneRupee:         _i(j['oneRupee']),
//         grandTotal:       _d(j['grandTotal']),
//         paid:             _d(j['paid']),
//         returnMoney:      _d(j['returnMoney']),
//         paymentStatus:    j['paymentStatus']?.toString() ?? 'PENDING',
//       );
//
//   bool get isPaid => paymentStatus.toUpperCase() == 'PAID';
//
//   // All denominations as list of (label, count) — only non-zero
//   List<Map<String, dynamic>> get denomBreakdown {
//     return [
//       {'label': '₹500', 'count': fiveHundredRupee,  'value': 500},
//       {'label': '₹200', 'count': twoHundredRupee,   'value': 200},
//       {'label': '₹100', 'count': hundredRupee,       'value': 100},
//       {'label': '₹50',  'count': fiftyRupee,         'value': 50},
//       {'label': '₹20',  'count': twentyRupee,        'value': 20},
//       {'label': '₹10',  'count': tenRupee,           'value': 10},
//       {'label': '₹5',   'count': fiveRupee,          'value': 5},
//       {'label': '₹2',   'count': twoRupee,           'value': 2},
//       {'label': '₹1',   'count': oneRupee,           'value': 1},
//     ].where((d) => (d['count'] as int) > 0).toList();
//   }
// }
//
// // ─── Page response ────────────────────────────────────────────────────────────
// class CashBillingPage {
//   final List<CashBillingRecord> records;
//   final int    totalElements;
//   final int    total500;
//   final int    total200;
//   final int    total100;
//   final int    total50;
//   final int    total20;
//   final int    total10;
//   final int    total5;
//   final int    total2;
//   final int    total1;
//
//   const CashBillingPage({
//     this.records = const [],
//     this.totalElements = 0,
//     this.total500 = 0,
//     this.total200 = 0,
//     this.total100 = 0,
//     this.total50 = 0,
//     this.total20 = 0,
//     this.total10 = 0,
//     this.total5 = 0,
//     this.total2 = 0,
//     this.total1 = 0,
//   });
//
//   factory CashBillingPage.fromJson(Map<String, dynamic> j) => CashBillingPage(
//     records:       (j['records'] as List? ?? []).whereType<Map<String, dynamic>>().map(CashBillingRecord.fromJson).toList(),
//     totalElements: _i(j['totalElements']),
//     total500:      _i(j['total500']),
//     total200:      _i(j['total200']),
//     total100:      _i(j['total100']),
//     total50:       _i(j['total50']),
//     total20:       _i(j['total20']),
//     total10:       _i(j['total10']),
//     total5:        _i(j['total5']),
//     total2:        _i(j['total2']),
//     total1:        _i(j['total1']),
//   );
//
//   // Summary totals list — only non-zero
//   List<Map<String, dynamic>> get summaryDenoms => [
//     {'label': '₹500', 'count': total500},
//     {'label': '₹200', 'count': total200},
//     {'label': '₹100', 'count': total100},
//     {'label': '₹50',  'count': total50},
//     {'label': '₹20',  'count': total20},
//     {'label': '₹10',  'count': total10},
//     {'label': '₹5',   'count': total5},
//     {'label': '₹2',   'count': total2},
//     {'label': '₹1',   'count': total1},
//   ].where((d) => (d['count'] as int) > 0).toList();
//
//   bool get hasSummary => summaryDenoms.isNotEmpty;
// }
//

// ─── Settlement entry ─────────────────────────────────────────────────────────
class Settlement {
  final int settlementId;
  final String transactionId;
  final double totalGrandTotal;
  final double totalCgst;
  final double totalSgst;
  final double totalPlatformCharges;
  final double tdsAmount;
  final double totalVendorPlatformCharges;
  final double totalVendorPlatformChargesGst;
  final double totalOnlinePayment;
  final double totalCash;
  final double totalWalletPayment;
  final double finalAmount;
  final String paymentStatus;
  final String pytMode;
  final String? description;
  final String? remarks;
  final String? fromDate;
  final String? toDate;
  final String? settlementDate;
  final String? updatedAt;

  // ── New: payout-breakdown / bank-detail fields for the settlement card ─────
  final double complaintCancellationCharges;
  final double otherChargesRefunds;
  final String? holderName;
  final String? accountNumber;
  final String? ifscCode;
  final String? refId;

  Settlement({
    required this.settlementId,
    this.transactionId = '',
    this.totalGrandTotal = 0,
    this.totalCgst = 0,
    this.totalSgst = 0,
    this.totalPlatformCharges = 0,
    this.tdsAmount = 0,
    this.totalVendorPlatformCharges = 0,
    this.totalVendorPlatformChargesGst = 0,
    this.totalOnlinePayment = 0,
    this.totalCash = 0,
    this.totalWalletPayment = 0,
    this.finalAmount = 0,
    this.paymentStatus = 'PENDING',
    this.pytMode = '',
    this.description,
    this.remarks,
    this.fromDate,
    this.toDate,
    this.settlementDate,
    this.updatedAt,
    this.complaintCancellationCharges = 0,
    this.otherChargesRefunds = 0,
    this.holderName,
    this.accountNumber,
    this.ifscCode,
    this.refId,
  });

  factory Settlement.fromJson(Map<String, dynamic> j) => Settlement(
    settlementId: _i(j['settlementId']),
    transactionId: j['transactionId']?.toString() ?? '',
    totalGrandTotal: _d(j['totalGrandTotal']),
    totalCgst: _d(j['totalCgst']),
    totalSgst: _d(j['totalSgst']),
    totalPlatformCharges: _d(j['totalPlatformCharges']),
    tdsAmount: _d(j['tdsAmount']),
    totalVendorPlatformCharges: _d(j['totalVendorPlatformCharges']),
    totalVendorPlatformChargesGst: _d(j['totalVendorPlatformChargesGst']),
    totalOnlinePayment: _d(j['totalOnlinePayment']),
    totalCash: _d(j['totalCash']),
    totalWalletPayment: _d(j['totalWalletPayment']),
    finalAmount: _d(j['finalAmount']),
    paymentStatus: j['paymentStatus']?.toString() ?? 'PENDING',
    pytMode: j['pytMode']?.toString() ?? '',
    description: j['description']?.toString(),
    remarks: j['remarks']?.toString(),
    fromDate: j['fromDate']?.toString(),
    toDate: j['toDate']?.toString(),
    settlementDate: j['settlementDate']?.toString(),
    updatedAt: j['updatedAt']?.toString(),
    complaintCancellationCharges: _d(j['complaintCancellationCharges']),
    otherChargesRefunds: _d(j['otherChargesRefunds']),
    holderName:
        j['holderName']?.toString() ?? j['accountHolderName']?.toString(),
    accountNumber: j['accountNumber']?.toString(),
    ifscCode: j['ifscCode']?.toString(),
    refId: j['refId']?.toString() ?? j['referenceId']?.toString(),
  );

  // ── Computed ──────────────────────────────────────────────────────────────
  bool get isPaid =>
      paymentStatus.toUpperCase() == 'PAID' ||
      paymentStatus.toUpperCase() == 'COMPLETED';

  /// Commission + TDS, the two components that make up "Total Fees" (B)
  double get commission => totalOnlinePayment > 0
      ? totalPlatformCharges
      : totalVendorPlatformCharges + totalVendorPlatformChargesGst;

  double get totalFees => commission + tdsAmount;

  double get totalTaxes => totalCgst + totalSgst;

  double get netAmount {
    if (totalOnlinePayment > 0) {
      // Online: deduct CGST + SGST + platform + TDS
      return totalGrandTotal -
          totalCgst -
          totalSgst -
          totalPlatformCharges -
          tdsAmount;
    } else {
      // Cash: deduct vendor platform charges
      return totalGrandTotal -
          totalCgst -
          totalSgst -
          totalVendorPlatformCharges -
          totalVendorPlatformChargesGst;
    }
  }

  double get totalCharges => totalGrandTotal - netAmount;

  /// Falls back to the transaction id if a dedicated ref id isn't supplied.
  String get displayRefId =>
      (refId != null && refId!.isNotEmpty) ? refId! : transactionId;

  String get paymentModeLabel {
    const map = {
      'FT': 'Bank Transfer',
      'IMPS': 'IMPS',
      'NEFT': 'NEFT',
      'RTGS': 'RTGS',
      'UPI': 'UPI',
      'CASH': 'Cash',
      'CHEQUE': 'Cheque',
    };
    return map[pytMode.toUpperCase()] ??
        (pytMode.isNotEmpty ? pytMode : 'Bank Transfer');
  }
}

// ─── Settlement summary ───────────────────────────────────────────────────────
class SettlementSummary {
  final int totalSettlements;
  final int successfulSettlements;
  final int pendingSettlements;
  final double pendingCredits;
  final List<Settlement> settlements;

  SettlementSummary({
    this.totalSettlements = 0,
    this.successfulSettlements = 0,
    this.pendingSettlements = 0,
    this.pendingCredits = 0,
    this.settlements = const [],
  });

  factory SettlementSummary.fromJson(Map<String, dynamic> j) {
    final list = j['settlements'] as List? ?? [];
    return SettlementSummary(
      totalSettlements: _i(j['totalSettlements']),
      successfulSettlements: _i(j['successfulSettlements']),
      pendingSettlements: _i(j['pendingSettlements']),
      pendingCredits: _d(j['pendingCredits']),
      settlements: list
          .whereType<Map<String, dynamic>>()
          .map(Settlement.fromJson)
          .toList(),
    );
  }
}

// ─── Credit stats ─────────────────────────────────────────────────────────────
// GET /food/api/vendor/credit/{vendorId}
class CreditStats {
  final double totalCreditPoints;
  final double usedCreditPoints;
  final double availableCreditPoints;
  final double pendingCreditPoints;
  final double pendingAmount;
  final double paidAmount;

  CreditStats({
    this.totalCreditPoints = 0,
    this.usedCreditPoints = 0,
    this.availableCreditPoints = 0,
    this.pendingCreditPoints = 0,
    this.pendingAmount = 0,
    this.paidAmount = 0,
  });

  factory CreditStats.fromJson(Map<String, dynamic> j) => CreditStats(
    totalCreditPoints: _d(j['totalCreditPoints']),
    usedCreditPoints: _d(j['usedCreditPoints']),
    availableCreditPoints: _d(j['availableCreditPoints']),
    pendingCreditPoints: _d(j['pendingCreditPoints']),
    pendingAmount: _d(j['pendingAmount']),
    paidAmount: _d(j['paidAmount']),
  );

  // active | warning | payment_required
  String get status {
    if (totalCreditPoints <= 0) return 'active';
    if (usedCreditPoints >= totalCreditPoints) return 'payment_required';
    if (usedCreditPoints >= totalCreditPoints * 0.7) return 'warning';
    return 'active';
  }

  double get usagePercent => totalCreditPoints > 0
      ? (usedCreditPoints / totalCreditPoints).clamp(0.0, 1.0)
      : 0.0;
}

// ─── Order (for Ledger tab) ───────────────────────────────────────────────────
// GET /food/api/orders/vendor/date-range/{vendorId}?startDate=X&endDate=Y
class LedgerOrder {
  final String orderId;
  final double grandTotal;
  final double deliveryCharges;
  final double platformCharges;
  final double platformChargesGst;
  final double vendorPlatformCharge;
  final double vendorPlatformChargeGst;
  final String paymentMethod;
  final String date; // YYYY-MM-DD
  final String? orderDateAndTime;
  final String? time;
  final String? orderType;

  LedgerOrder({
    this.orderId = '',
    this.grandTotal = 0,
    this.deliveryCharges = 0,
    this.platformCharges = 0,
    this.platformChargesGst = 0,
    this.vendorPlatformCharge = 0,
    this.vendorPlatformChargeGst = 0,
    this.paymentMethod = '',
    this.date = '',
    this.orderDateAndTime,
    this.time,
    this.orderType,
  });

  factory LedgerOrder.fromJson(Map<String, dynamic> j) => LedgerOrder(
    orderId: j['orderId']?.toString() ?? '',
    grandTotal: _d(j['grandTotal']),
    deliveryCharges: _d(j['deliveryCharges']),
    platformCharges: _d(j['platformCharges']),
    platformChargesGst: _d(j['platformChargesGst']),
    vendorPlatformCharge: _d(j['vendorPlatformCharge']),
    vendorPlatformChargeGst: _d(j['vendorPlatformChargeGst']),
    paymentMethod: j['paymentMethod']?.toString() ?? '',
    date: j['date']?.toString() ?? '',
    orderDateAndTime: j['orderDateAndTime']?.toString(),
    time: j['time']?.toString(),
    orderType: j['orderType']?.toString(),
  );

  double get netAmount {
    final charges =
        deliveryCharges +
        platformCharges +
        platformChargesGst +
        vendorPlatformCharge +
        vendorPlatformChargeGst;
    return grandTotal - charges;
  }
}

// ─── Daily ledger group ───────────────────────────────────────────────────────
class DailyLedger {
  final String date;
  final double totalNetAmount;
  final int orderCount;
  final List<LedgerOrder> orders;

  DailyLedger({
    required this.date,
    required this.totalNetAmount,
    required this.orderCount,
    required this.orders,
  });

  String get formattedDate {
    try {
      final dt = DateTime.parse(date);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final d = DateTime(dt.year, dt.month, dt.day);
      final months = [
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
      if (d == today) return 'Today, ${months[dt.month - 1]} ${dt.day}';
      if (d == yesterday) return 'Yesterday, ${months[dt.month - 1]} ${dt.day}';
      return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
    } catch (_) {
      return date;
    }
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────
double _d(dynamic v) =>
    (v is num) ? v.toDouble() : double.tryParse(v?.toString() ?? '') ?? 0.0;
int _i(dynamic v) => (v is int) ? v : int.tryParse(v?.toString() ?? '') ?? 0;
// ─── Cash Billing Record ──────────────────────────────────────────────────────

class CashBillingRecord {
  final int id;
  final String orderId;
  final String date;
  final int fiveHundredRupee;
  final int twoHundredRupee;
  final int hundredRupee;
  final int fiftyRupee;
  final int twentyRupee;
  final int tenRupee;
  final int fiveRupee;
  final int twoRupee;
  final int oneRupee;
  final double grandTotal;
  final double paid;
  final double returnMoney;
  final String paymentStatus; // PAID | PENDING

  const CashBillingRecord({
    this.id = 0,
    this.orderId = '',
    this.date = '',
    this.fiveHundredRupee = 0,
    this.twoHundredRupee = 0,
    this.hundredRupee = 0,
    this.fiftyRupee = 0,
    this.twentyRupee = 0,
    this.tenRupee = 0,
    this.fiveRupee = 0,
    this.twoRupee = 0,
    this.oneRupee = 0,
    this.grandTotal = 0,
    this.paid = 0,
    this.returnMoney = 0,
    this.paymentStatus = 'PENDING',
  });

  factory CashBillingRecord.fromJson(Map<String, dynamic> j) =>
      CashBillingRecord(
        id: _i(j['id']),
        orderId: j['orderId']?.toString() ?? '',
        date: j['date']?.toString() ?? '',
        fiveHundredRupee: _i(j['fiveHundredRupee']),
        twoHundredRupee: _i(j['twoHundredRupee']),
        hundredRupee: _i(j['hundredRupee']),
        fiftyRupee: _i(j['fiftyRupee']),
        twentyRupee: _i(j['twentyRupee']),
        tenRupee: _i(j['tenRupee']),
        fiveRupee: _i(j['fiveRupee']),
        twoRupee: _i(j['twoRupee']),
        oneRupee: _i(j['oneRupee']),
        grandTotal: _d(j['grandTotal']),
        paid: _d(j['paid']),
        returnMoney: _d(j['returnMoney']),
        paymentStatus: j['paymentStatus']?.toString() ?? 'PENDING',
      );

  bool get isPaid => paymentStatus.toUpperCase() == 'PAID';

  // All denominations as list of (label, count) — only non-zero
  List<Map<String, dynamic>> get denomBreakdown {
    return [
      {'label': '₹500', 'count': fiveHundredRupee, 'value': 500},
      {'label': '₹200', 'count': twoHundredRupee, 'value': 200},
      {'label': '₹100', 'count': hundredRupee, 'value': 100},
      {'label': '₹50', 'count': fiftyRupee, 'value': 50},
      {'label': '₹20', 'count': twentyRupee, 'value': 20},
      {'label': '₹10', 'count': tenRupee, 'value': 10},
      {'label': '₹5', 'count': fiveRupee, 'value': 5},
      {'label': '₹2', 'count': twoRupee, 'value': 2},
      {'label': '₹1', 'count': oneRupee, 'value': 1},
    ].where((d) => (d['count'] as int) > 0).toList();
  }
}

// ─── Page response ────────────────────────────────────────────────────────────
class CashBillingPage {
  final List<CashBillingRecord> records;
  final int totalElements;
  final int total500;
  final int total200;
  final int total100;
  final int total50;
  final int total20;
  final int total10;
  final int total5;
  final int total2;
  final int total1;

  const CashBillingPage({
    this.records = const [],
    this.totalElements = 0,
    this.total500 = 0,
    this.total200 = 0,
    this.total100 = 0,
    this.total50 = 0,
    this.total20 = 0,
    this.total10 = 0,
    this.total5 = 0,
    this.total2 = 0,
    this.total1 = 0,
  });

  factory CashBillingPage.fromJson(Map<String, dynamic> j) => CashBillingPage(
    records: (j['records'] as List? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(CashBillingRecord.fromJson)
        .toList(),
    totalElements: _i(j['totalElements']),
    total500: _i(j['total500']),
    total200: _i(j['total200']),
    total100: _i(j['total100']),
    total50: _i(j['total50']),
    total20: _i(j['total20']),
    total10: _i(j['total10']),
    total5: _i(j['total5']),
    total2: _i(j['total2']),
    total1: _i(j['total1']),
  );

  // Summary totals list — only non-zero
  List<Map<String, dynamic>> get summaryDenoms => [
    {'label': '₹500', 'count': total500},
    {'label': '₹200', 'count': total200},
    {'label': '₹100', 'count': total100},
    {'label': '₹50', 'count': total50},
    {'label': '₹20', 'count': total20},
    {'label': '₹10', 'count': total10},
    {'label': '₹5', 'count': total5},
    {'label': '₹2', 'count': total2},
    {'label': '₹1', 'count': total1},
  ].where((d) => (d['count'] as int) > 0).toList();

  bool get hasSummary => summaryDenoms.isNotEmpty;
}
