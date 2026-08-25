import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import '../../../../API/Apiclient.dart';
import '../../../../food&beverages/Invoice.dart';
import '../models/cart_models.dart';
import '../services/cart_service.dart';
import '../widgets/cart_item_tile.dart';
import '../widgets/bill_summary_sheet.dart';
import '../widgets/change_table_modal.dart';
import '../widgets/payment_section.dart';
import '../widgets/removal_requests_modal.dart';
import '../widgets/tip_section.dart';

// TABLE REQUEST MODELS

class TableRequestModel {
  final int vendorId;
  final int userId;
  final int itemId;
  final int removalQuantity;
  final int cartId;
  final int tableBookingId;
  final String tableCode;
  final String requestType;
  final int employeeId;
  final String customerId;
  final String reason;

  const TableRequestModel({
    required this.vendorId,
    required this.userId,
    required this.itemId,
    required this.removalQuantity,
    required this.cartId,
    required this.tableBookingId,
    required this.tableCode,
    required this.requestType,
    required this.employeeId,
    required this.customerId,
    required this.reason,
  });

  Map<String, dynamic> toJson() => {
    'vendorId': vendorId,
    if (userId != 0) 'userId': userId,
    'itemId': itemId,
    'removalQuantity': removalQuantity,
    'cartId': cartId,
    'tableBookingId': tableBookingId,
    'tableCode': tableCode,
    'requestType': requestType,
    if (employeeId != 0) 'employeeId': employeeId,
    if (customerId != '0') 'customerId': customerId,
    'reason': reason,
  };
}

class TableRequestEntry {
  final int id;
  final int vendorId;
  final int userId;
  final String name;
  final int itemId;
  final int cartId;
  final int tableBookingId;
  final String tableCode;
  final String status;
  final String requestType;
  final String? reason;
  final String? itemName;
  final int? quantity;
  final int? removalQuantity;

  const TableRequestEntry({
    required this.id,
    required this.vendorId,
    required this.userId,
    required this.name,
    required this.itemId,
    required this.cartId,
    required this.tableBookingId,
    required this.tableCode,
    required this.status,
    required this.requestType,
    this.reason,
    this.itemName,
    this.quantity,
    this.removalQuantity,
  });

  factory TableRequestEntry.fromJson(Map<String, dynamic> json) {
    return TableRequestEntry(
      id: json['id'] ?? 0,
      vendorId: json['vendorId'] ?? 0,
      userId: json['userId'] ?? 0,
      name: json['name'] ?? '',
      itemId: json['itemId'] ?? 0,
      cartId: json['cartId'] ?? 0,
      tableBookingId: json['tableBookingId'] ?? 0,
      tableCode: json['tableCode'] ?? '',
      status: json['status'] ?? 'PENDING',
      requestType: json['requestType'] ?? '',
      reason: json['reason'],
      itemName: json['itemName'],
      quantity: json['quantity'],
      removalQuantity: json['removalQuantity'],
    );
  }

  bool get isPending => status == 'PENDING';
  bool get isAccepted => status == 'ACCEPT';
  bool get isDeclined => status == 'DECLINE';
}

// ─────────────────────────────────────────────────────────────────────────────
// CASH DENOMINATION BOTTOM SHEET
// ─────────────────────────────────────────────────────────────────────────────

class _CashDenominationSheet extends StatefulWidget {
  final double expectedAmount;
  final void Function(Map<String, dynamic> denominationData) onConfirm;

  const _CashDenominationSheet({
    required this.expectedAmount,
    required this.onConfirm,
  });

  @override
  State<_CashDenominationSheet> createState() => _CashDenominationSheetState();
}

class _CashDenominationSheetState extends State<_CashDenominationSheet> {
  final Map<String, int> _counts = {
    'oneRupee': 0,
    'twoRupee': 0,
    'fiveRupee': 0,
    'tenRupee': 0,
    'twentyRupee': 0,
    'fiftyRupee': 0,
    'hundredRupee': 0,
    'twoHundredRupee': 0,
    'fiveHundredRupee': 0,
    'twoThousandRupee': 0,
  };

  static const Map<String, int> _values = {
    'oneRupee': 1,
    'twoRupee': 2,
    'fiveRupee': 5,
    'tenRupee': 10,
    'twentyRupee': 20,
    'fiftyRupee': 50,
    'hundredRupee': 100,
    'twoHundredRupee': 200,
    'fiveHundredRupee': 500,
    'twoThousandRupee': 2000,
  };

  static const Map<String, String> _labels = {
    'oneRupee': '₹1',
    'twoRupee': '₹2',
    'fiveRupee': '₹5',
    'tenRupee': '₹10',
    'twentyRupee': '₹20',
    'fiftyRupee': '₹50',
    'hundredRupee': '₹100',
    'twoHundredRupee': '₹200',
    'fiveHundredRupee': '₹500',
    'twoThousandRupee': '₹2000',
  };

  final Map<String, TextEditingController> _controllers = {};
  bool _isSubmitting = false;

  double get _totalReceived => _counts.entries.fold(
    0.0,
    (s, e) => s + (e.value * (_values[e.key] ?? 0)),
  );

  double get _returnAmount =>
      (_totalReceived - widget.expectedAmount).clamp(0.0, double.infinity);

  bool get _canConfirm => _totalReceived >= widget.expectedAmount;

  @override
  void initState() {
    super.initState();
    for (final key in _counts.keys) {
      _controllers[key] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _onChanged(String key, String val) {
    setState(() => _counts[key] = int.tryParse(val) ?? 0);
  }

  Widget _denomItem(String key) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _labels[key]!,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade600,
          ),
        ),
        SizedBox(height: 4),
        Container(
          height: 38,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: (_counts[key] ?? 0) > 0
                  ? const Color(0xFFe66d33)
                  : Colors.grey.shade300,
              width: (_counts[key] ?? 0) > 0 ? 1.5 : 1,
            ),
          ),
          child: TextField(
            controller: _controllers[key],
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: '0',
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 12),
              contentPadding: EdgeInsets.zero,
              isDense: true,
            ),
            onChanged: (v) => _onChanged(key, v),
          ),
        ),
        if ((_counts[key] ?? 0) > 0)
          Padding(
            padding: EdgeInsets.only(top: 2),
            child: Text(
              '₹${_counts[key]! * _values[key]!}',
              style: TextStyle(
                fontSize: 9,
                color: const Color(0xFFe66d33),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }

  Widget _summaryLine(String label, double value, {required Color color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          '₹${value.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final keys = _counts.keys.toList();
    final firstRow = keys.sublist(0, 5);
    final secondRow = keys.sublist(5);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              margin: EdgeInsets.only(top: 10),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFe66d33),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Row(
              children: [
                Icon(Icons.payments_outlined, color: Colors.white, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Cash Breakdown',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.close, color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFe66d33).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Expected Amount',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '₹${widget.expectedAmount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFFe66d33),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: firstRow
                        .map(
                          (k) => Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 3),
                              child: _denomItem(k),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: secondRow
                        .map(
                          (k) => Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 3),
                              child: _denomItem(k),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6F7FB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      children: [
                        _summaryLine(
                          'Total Received',
                          _totalReceived,
                          color: const Color(0xFF28a745),
                        ),
                        if (_returnAmount > 0) ...[
                          SizedBox(height: 8),
                          Divider(color: Colors.grey.shade300, height: 1),
                          SizedBox(height: 8),
                          _summaryLine(
                            'Change to Return',
                            _returnAmount,
                            color: const Color(0xFFfd7e14),
                          ),
                        ],
                        if (!_canConfirm && _totalReceived > 0) ...[
                          SizedBox(height: 8),
                          Divider(color: Colors.grey.shade300, height: 1),
                          SizedBox(height: 8),
                          _summaryLine(
                            'Still Needed',
                            widget.expectedAmount - _totalReceived,
                            color: const Color(0xFFdc3545),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 24),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 13),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF6F7FB),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Center(
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: (_canConfirm && !_isSubmitting)
                        ? () {
                            setState(() => _isSubmitting = true);
                            widget.onConfirm({
                              'amount': widget.expectedAmount,
                              'received': _totalReceived,
                              'change': _returnAmount,
                              'denominations': Map<String, int>.from(_counts),
                            });
                            Navigator.pop(context);
                          }
                        : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.symmetric(vertical: 13),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _canConfirm
                              ? [
                                  const Color(0xFF28a745),
                                  const Color(0xFF1e7e34),
                                ]
                              : [Colors.grey.shade400, Colors.grey.shade400],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: _canConfirm
                            ? [
                                BoxShadow(
                                  color: const Color(
                                    0xFF28a745,
                                  ).withOpacity(0.35),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : [],
                      ),
                      child: Center(
                        child: _isSubmitting
                            ? SizedBox(
                                width: 18,
                                height: 18,
                                child: const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                _canConfirm
                                    ? 'Confirm ₹${_totalReceived.toStringAsFixed(2)}'
                                    : 'Insufficient Amount',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SPLIT PAYMENT BOTTOM SHEET
// ─────────────────────────────────────────────────────────────────────────────

class _SplitPaymentSheet extends StatefulWidget {
  final double grandTotal;
  final void Function(List<Map<String, dynamic>> payments, bool hasQrPayment)
  onSubmit;

  const _SplitPaymentSheet({required this.grandTotal, required this.onSubmit});

  @override
  State<_SplitPaymentSheet> createState() => _SplitPaymentSheetState();
}

class _SplitPaymentSheetState extends State<_SplitPaymentSheet> {
  final List<Map<String, dynamic>> _payments = [];
  String _selectedMethod = 'Cash';
  final TextEditingController _amountCtrl = TextEditingController();

  bool _upiDisabled = false;
  bool _qrDisabled = false;

  static const List<Map<String, dynamic>> _methods = [
    {'id': 'Cash', 'label': 'Cash', 'icon': Icons.payments_outlined},
    {'id': 'UPI', 'label': 'UPI', 'icon': Icons.phone_android_outlined},
    {
      'id': 'Online_Payment',
      'label': 'QR Code',
      'icon': Icons.qr_code_2_outlined,
    },
  ];

  double get _allocated => _payments.fold(
    0.0,
    (s, p) => s + ((p['amount'] as num?)?.toDouble() ?? 0),
  );
  double get _remaining => widget.grandTotal - _allocated;
  bool get _isBalanced => _remaining.abs() < 0.01;

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: const Color(0xFFfd7e14),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _addPayment() {
    final amt = double.tryParse(_amountCtrl.text.trim()) ?? 0;
    if (amt <= 0) {
      _snack('Please enter a valid amount');
      return;
    }
    if (amt > _remaining + 0.01) {
      _snack('Amount exceeds remaining ₹${_remaining.toStringAsFixed(2)}');
      return;
    }

    if (_selectedMethod == 'Cash') {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: _CashDenominationSheet(
            expectedAmount: amt,
            onConfirm: (denomData) {
              setState(() {
                _payments.add({
                  'id': DateTime.now().millisecondsSinceEpoch,
                  'method': 'Cash',
                  'amount': amt,
                  'label': 'Cash',
                  'denominationData': denomData,
                });
                _amountCtrl.clear();
              });
            },
          ),
        ),
      );
      return;
    }

    setState(() {
      _payments.add({
        'id': DateTime.now().millisecondsSinceEpoch,
        'method': _selectedMethod,
        'amount': amt,
        'label': _methods.firstWhere(
          (m) => m['id'] == _selectedMethod,
        )['label'],
      });
      if (_selectedMethod == 'UPI') _qrDisabled = true;
      if (_selectedMethod == 'Online_Payment') _upiDisabled = true;
      _amountCtrl.clear();
    });
  }

  void _removePayment(int id) {
    final p = _payments.firstWhere((x) => x['id'] == id, orElse: () => {});
    setState(() {
      _payments.removeWhere((x) => x['id'] == id);
      if (p['method'] == 'UPI' || p['method'] == 'Online_Payment') {
        _upiDisabled = false;
        _qrDisabled = false;
      }
    });
  }

  void _submit() {
    if (_payments.isEmpty) {
      _snack('Add at least one payment method');
      return;
    }
    if (!_isBalanced) {
      _snack('Balance pending: ₹${_remaining.toStringAsFixed(2)}');
      return;
    }
    final hasQr = _payments.any((p) => p['method'] == 'Online_Payment');
    widget.onSubmit(List<Map<String, dynamic>>.from(_payments), hasQr);
    Navigator.pop(context);
  }

  Widget _methodChip(Map<String, dynamic> m) {
    final id = m['id'] as String;
    final isSelected = _selectedMethod == id;
    final isDisabled =
        (id == 'UPI' && _upiDisabled) ||
        (id == 'Online_Payment' && _qrDisabled);

    return Expanded(
      child: GestureDetector(
        onTap: isDisabled ? null : () => setState(() => _selectedMethod = id),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: EdgeInsets.only(right: id != 'Online_Payment' ? 8 : 0),
          padding: EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isDisabled
                ? const Color(0xFFF6F7FB)
                : isSelected
                ? const Color(0xFFe66d33).withOpacity(0.08)
                : const Color(0xFFF6F7FB),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDisabled
                  ? Colors.grey.shade300
                  : isSelected
                  ? const Color(0xFFe66d33)
                  : Colors.grey.shade300,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                m['icon'] as IconData,
                size: 16,
                color: isDisabled
                    ? Colors.grey.shade400
                    : isSelected
                    ? const Color(0xFFe66d33)
                    : Colors.grey.shade600,
              ),
              SizedBox(height: 3),
              Text(
                m['label'] as String,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isDisabled
                      ? Colors.grey.shade400
                      : isSelected
                      ? const Color(0xFFe66d33)
                      : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _paymentListItem(Map<String, dynamic> p) {
    final method = p['method'] as String;
    final amount = (p['amount'] as num).toDouble();
    final hasDenom = p['denominationData'] != null;

    IconData icon;
    switch (method) {
      case 'Cash':
        icon = Icons.payments_outlined;
        break;
      case 'UPI':
        icon = Icons.phone_android_outlined;
        break;
      case 'Online_Payment':
        icon = Icons.qr_code_2_outlined;
        break;
      default:
        icon = Icons.credit_card_outlined;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F7FB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: const Color(0xFFe66d33).withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 14, color: const Color(0xFFe66d33)),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Row(
              children: [
                Text(
                  p['label'] as String,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                if (hasDenom) ...[
                  SizedBox(width: 6),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF28a745).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Breakdown',
                      style: TextStyle(
                        fontSize: 9,
                        color: const Color(0xFF28a745),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: const Color(0xFFe66d33),
            ),
          ),
          SizedBox(width: 8),
          GestureDetector(
            onTap: () => _removePayment(p['id'] as int),
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: const Color(0xFFdc3545).withOpacity(0.08),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                Icons.close_rounded,
                size: 12,
                color: const Color(0xFFdc3545),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.grandTotal > 0
        ? (_allocated / widget.grandTotal).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              margin: EdgeInsets.only(top: 10),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFe66d33),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Row(
              children: [
                Icon(Icons.call_split_rounded, color: Colors.white, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Split Payment',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.close, color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _amountCard('Total', widget.grandTotal, Colors.black87),
                      SizedBox(width: 10),
                      _amountCard(
                        'Remaining',
                        _remaining,
                        _isBalanced
                            ? const Color(0xFF28a745)
                            : const Color(0xFFdc3545),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: FractionallySizedBox(
                      widthFactor: progress,
                      alignment: Alignment.centerLeft,
                      child: Container(
                        decoration: BoxDecoration(
                          color: _isBalanced
                              ? const Color(0xFF28a745)
                              : const Color(0xFFe66d33),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₹${_allocated.toStringAsFixed(2)} allocated',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        _isBalanced
                            ? '✓ Balanced'
                            : '₹${_remaining.toStringAsFixed(2)} left',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _isBalanced
                              ? const Color(0xFF28a745)
                              : const Color(0xFFdc3545),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Select Payment Method',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(children: _methods.map(_methodChip).toList()),
                  SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6F7FB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 14),
                          child: Text(
                            '₹',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _amountCtrl,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: _remaining > 0
                                  ? _remaining.toStringAsFixed(2)
                                  : '0.00',
                              hintStyle: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 14,
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 14,
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            if (_remaining > 0) {
                              _amountCtrl.text = _remaining.toStringAsFixed(2);
                            }
                          },
                          child: Container(
                            margin: EdgeInsets.only(right: 6),
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFe66d33).withOpacity(0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Max',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFFe66d33),
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: _addPayment,
                          child: Container(
                            margin: EdgeInsets.only(right: 8),
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFe66d33),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'Add',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  if (_payments.isEmpty)
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 36,
                            color: Colors.grey.shade400,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'No payments added yet',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade400,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Select a method and enter an amount above',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
                    )
                  else ...[
                    Padding(
                      padding: EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 4,
                            child: Text(
                              'Method',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                          Text(
                            'Amount',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          SizedBox(width: 32),
                        ],
                      ),
                    ),
                    ..._payments.map(_paymentListItem),
                  ],
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 24),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 13),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF6F7FB),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Center(
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: _isBalanced ? _submit : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.symmetric(vertical: 13),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _isBalanced
                              ? [
                                  const Color(0xFFe66d33),
                                  const Color(0xFFb85e2e),
                                ]
                              : [Colors.grey.shade400, Colors.grey.shade400],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: _isBalanced
                            ? [
                                BoxShadow(
                                  color: const Color(
                                    0xFFe66d33,
                                  ).withOpacity(0.35),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : [],
                      ),
                      child: Center(
                        child: Text(
                          _isBalanced
                              ? 'Complete Payment'
                              : 'Pay ₹${_remaining.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _amountCard(String label, double amount, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 2),
            Text(
              '₹${amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TABLE REQUEST SERVICE
// ─────────────────────────────────────────────────────────────────────────────

// class TableRequestService {
//   static const _storage = FlutterSecureStorage();
//   static final Dio _dio = Dio();
//   static const String _baseUrl = 'http://staging.maamaas.com:8080/food';
//
//   static Future<Map<String, String>> _headers() async {
//     final token = await _storage.read(key: 'token');
//     return {
//       'Content-Type': 'application/json',
//       if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
//     };
//   }
//
//   static Future<List<TableRequestEntry>> fetchRequestsByCart(int cartId) async {
//     try {
//       debugPrint('📥 GET api/table-requests/cart/$cartId');
//       final headers = await _headers();
//       final response = await _dio.get(
//         '$_baseUrl/api/table-requests/cart/$cartId',
//         options: Options(headers: headers),
//       );
//       debugPrint('📡 Status: ${response.statusCode}');
//       if (response.statusCode == 200) {
//         final List<dynamic> list = response.data as List<dynamic>;
//         return list
//             .map((e) => TableRequestEntry.fromJson(e as Map<String, dynamic>))
//             .toList();
//       }
//       return [];
//     } catch (e) {
//       debugPrint('❌ fetchRequestsByCart error: $e');
//       return [];
//     }
//   }
//
//   static Future<bool> createRemovalRequest({
//     required TableRequestModel request,
//   }) async {
//     try {
//       final payload = request.toJson();
//       final headers = await _headers();
//       debugPrint('📤 POST api/table-requests/create');
//       debugPrint('📦 Payload: ${jsonEncode(payload)}');
//
//       final response = await _dio.post(
//         '$_baseUrl/api/table-requests/create',
//         data: payload,
//         options: Options(headers: headers),
//       );
//
//       debugPrint('📡 Status: ${response.statusCode}');
//       return response.statusCode == 200 || response.statusCode == 201;
//     } catch (e) {
//       debugPrint('❌ createRemovalRequest error: $e');
//       return false;
//     }
//   }
//
//   static Future<bool> updateRequestStatus({
//     required int requestId,
//     required String status,
//   }) async {
//     try {
//       debugPrint('📤 PUT api/table-requests/update/$requestId?status=$status');
//       final headers = await _headers();
//       final response = await _dio.put(
//         '$_baseUrl/api/table-requests/update/$requestId?status=$status',
//         options: Options(headers: headers),
//       );
//       debugPrint('📡 Status: ${response.statusCode}');
//       return response.statusCode == 200 || response.statusCode == 204;
//     } catch (e) {
//       debugPrint('❌ updateRequestStatus error: $e');
//       return false;
//     }
//   }
// }

class TableRequestService {
  static Future<List<TableRequestEntry>> fetchRequestsByCart(int cartId) async {
    try {
      // debugPrint('📥 GET api/table-requests/cart/$cartId');

      final response = await ApiClient.get(
        'api/table-requests/cart/$cartId',
        service: 'food',
      );

      // debugPrint('📡 Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body);

        return list
            .map((e) => TableRequestEntry.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      // debugPrint('❌ fetchRequestsByCart error: $e');
      return [];
    }
  }

  static Future<bool> createRemovalRequest({
    required TableRequestModel request,
  }) async {
    try {
      final payload = request.toJson();

      final response = await ApiClient.post(
        'api/table-requests/create',
        payload,
        service: 'food',
      );

      // debugPrint('📡 Status: ${response.statusCode}');
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      // debugPrint('❌ createRemovalRequest error: $e');
      return false;
    }
  }

  static Future<bool> updateRequestStatus({
    required int requestId,
    required String status,
  }) async {
    try {
      // debugPrint('📤 PUT api/table-requests/update/$requestId?status=$status');

      final response = await ApiClient.put(
        'api/table-requests/update/$requestId?status=$status',
        {}, // empty body
        service: 'food',
      );

      // debugPrint('📡 Status: ${response.statusCode}');

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      // debugPrint('❌ updateRequestStatus error: $e');
      return false;
    }
  }
}

enum RemovalRequestType { removalQuantity, removeItem }

class TableCartScreen extends StatefulWidget {
  final int vendorId;
  final int? bookingId;
  final String tableCode;
  final int? seatingId;
  final String authToken;
  final VoidCallback? onPaymentSuccess;
  final VoidCallback? onBack;

  const TableCartScreen({
    Key? key,
    required this.vendorId,
    this.bookingId,
    required this.tableCode,
    this.seatingId,
    required this.authToken,
    this.onPaymentSuccess,
    this.onBack,
  }) : super(key: key);

  @override
  State<TableCartScreen> createState() => _TableCartScreenState();
}

class _TableCartScreenState extends State<TableCartScreen>
    with SingleTickerProviderStateMixin {
  // ── Role State ────────────────────────────────────────────────────────────
  bool _isVendorRole = false;
  int? _employeeId;
  String? _customerId;

  // ── Cart State ────────────────────────────────────────────────────────────
  CartData? _cartData;
  List<CartItem> _apiItems = [];
  List<CartItem> _localItems = [];
  bool _isBillMode = false;
  bool _isLoading = false;
  bool _isSaving = false;
  bool _isSending = false;
  bool _isKotPrinting = false;
  bool _isAddingTip = false;
  int? _existingBookingId;
  bool _isUsingLocalStorage = true;
  Map<int, bool> _itemLoadingMap = {};

  // ── Printer State ─────────────────────────────────────────────────────────
  List<BluetoothInfo> _pairedDevices = [];
  bool _isLoadingPrinter = false;
  bool _isPrinting = false;
  bool _isCashierKOTPrinting = false;

  // ── Billing State ─────────────────────────────────────────────────────────
  double _subtotal = 0;
  double _gst = 0;
  double _grandTotal = 0;
  double _total = 0;
  double _tipAmount = 0;
  double _discountAmount = 0;
  bool _isDiscountApplied = false;
  final TextEditingController _discountCtrl = TextEditingController();
  double? _selectedTip;
  final TextEditingController _customTipCtrl = TextEditingController();
  String _paymentMethod = '';
  PaymentMethodsConfig _paymentConfig = PaymentMethodsConfig();
  List<RemovalRequest> _removalRequests = [];
  double _serviceCharge = 0;
  double _packingCharges = 0;
  double _platformFee = 0;
  double _deliveryCharge = 0;

  // ── Payment Integration State ────────────────────────────────────────────
  bool _isGeneratingQr = false;
  String? _qrImageUrl;
  String? _qrOrderId;
  String? _qrPaymentId;
  bool _qrPaymentVerified = false;
  Timer? _qrPollingTimer;
  bool _isPlacingOrder = false;

  // ── Table Requests State ──────────────────────────────────────────────────
  List<TableRequestEntry> _tableRequests = [];
  bool _isLoadingRequests = false;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _existingBookingId = widget.bookingId;
    _isUsingLocalStorage = widget.bookingId == null;
    _loadUserRole();
    _init();
  }

  Future<void> _loadUserRole() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final role = prefs.getString('role') ?? '';
      // debugPrint('👤 Loaded role: $role');
      _employeeId = prefs.getInt('employeeId');
      _customerId = prefs.getString('customerId') ?? '0';
      if (mounted) {
        setState(() {
          _isVendorRole = role == 'ROLE_VENDOR';
        });
      }
    } catch (e) {
      // debugPrint('❌ _loadUserRole error: $e');
    }
  }

  Future<void> _init() async {
    await _loadFromLocal();
    if (_localItems.isEmpty) {
      if (widget.bookingId != null) {
        _isUsingLocalStorage = false;
        await _fetchCartFromBackend();
      }
    }
    await _fetchBillingConfig();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _discountCtrl.dispose();
    _customTipCtrl.dispose();
    _qrPollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('pendingCartItems');
    if (raw != null && raw.isNotEmpty) {
      final list = jsonDecode(raw) as List<dynamic>;
      setState(() {
        _localItems = list
            .map((e) => CartItem.fromLocal(e as Map<String, dynamic>))
            .toList();
        _recalcSubtotal();
      });
    }
  }

  Future<void> _saveToLocal(List<CartItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    if (items.isEmpty) {
      await prefs.remove('pendingCartItems');
    } else {
      await prefs.setString(
        'pendingCartItems',
        jsonEncode(items.map((e) => e.toLocalJson()).toList()),
      );
    }
    _recalcSubtotal();
  }

  void _recalcSubtotal() {
    final apiTotal = _apiItems.fold<double>(
      0,
      (s, i) => s + i.price * i.quantity,
    );
    final localTotal = _localItems.fold<double>(
      0,
      (s, i) => s + i.price * i.quantity,
    );
    setState(() {
      _subtotal = apiTotal + localTotal;
      if (_cartData == null) {
        _grandTotal = _subtotal;
        _total = _subtotal;
      }
    });
  }

  Future<void> _fetchCartFromBackend() async {
    final id = _existingBookingId;
    if (id == null) return;
    setState(() => _isLoading = true);
    try {
      final data = await CartService.fetchCart(widget.vendorId, id);
      if (data != null) {
        final cd = CartData.fromJson(data);
        final active = cd.cartItems
            .where(
              (i) =>
                  i.orderStatus == null ||
                  [
                    'PENDING',
                    'CONFIRMED',
                    'ORDER_IS_READY',
                    'WAITING_FOR_PICKUP',
                    'ON_THE_WAY',
                    'DELIVERED',
                  ].contains(i.orderStatus),
            )
            .toList();
        setState(() {
          _cartData = cd;
          _apiItems = active;
          _subtotal = cd.subtotal;
          _gst = cd.gstTotal;
          _grandTotal = cd.grandTotal;
          _total = cd.total;
          _tipAmount = cd.tipAmount;
          _discountAmount = cd.discountAmount;
          _isDiscountApplied = cd.discountAmount > 0;
          _serviceCharge = cd.serviceCharges;
          _packingCharges = cd.packingTotal;
          _platformFee = cd.platformCharges;
          _deliveryCharge = cd.deliveryCharges;
        });

        if (cd.cartId != null) {
          await _fetchRemovalRequests(cd.cartId!);
          await _fetchTableRequests(cd.cartId!);
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchRemovalRequests(int cartId) async {
    final list = await CartService.fetchRemovalRequests(cartId);
    if (mounted) {
      setState(() {
        _removalRequests = list
            .map((e) => RemovalRequest.fromJson(e as Map<String, dynamic>))
            .toList();
      });
    }
  }

  Future<void> _fetchTableRequests(int cartId) async {
    if (mounted) setState(() => _isLoadingRequests = true);
    try {
      final requests = await TableRequestService.fetchRequestsByCart(cartId);
      if (mounted) {
        setState(() => _tableRequests = requests);
      }
    } catch (e) {
      // debugPrint('❌ _fetchTableRequests error: $e');
    } finally {
      if (mounted) setState(() => _isLoadingRequests = false);
    }
  }

  List<TableRequestEntry> _pendingTableRequestsFor(int itemId) {
    return _tableRequests
        .where((r) => r.itemId == itemId && r.isPending)
        .toList();
  }

  Future<void> _acceptTableRequest(TableRequestEntry request) async {
    if (!_isVendorRole) {
      _showSnack('Only vendor accounts can accept requests');
      return;
    }

    final success = await TableRequestService.updateRequestStatus(
      requestId: request.id,
      status: 'ACCEPT',
    );

    if (success) {
      final cartItem = _apiItems
          .where((i) => i.itemId == request.itemId)
          .firstOrNull;
      if (cartItem != null && _cartData != null) {
        final removeQty = request.removalQuantity ?? request.quantity ?? 1;
        final newQty = (cartItem.quantity - removeQty).clamp(0, 999);

        setState(() => _itemLoadingMap[cartItem.itemId!] = true);
        try {
          await CartService.updateItemStatus(
            cartId: _cartData!.cartId!,
            itemId: cartItem.itemId!,
            quantity: newQty,
            status: cartItem.orderStatus ?? 'CONFIRMED',
          );
          _showSnack('Request accepted — ${cartItem.dishName} qty updated');
        } catch (e) {
          _showSnack('Request accepted but qty update failed');
        } finally {
          setState(() => _itemLoadingMap[cartItem.itemId!] = false);
        }
      } else {
        _showSnack('Request accepted');
      }
      await _fetchCartFromBackend();
    } else {
      _showSnack('Failed to accept request');
    }
  }

  Future<void> _declineTableRequest(TableRequestEntry request) async {
    if (!_isVendorRole) {
      _showSnack('Only vendor accounts can decline requests');
      return;
    }

    final success = await TableRequestService.updateRequestStatus(
      requestId: request.id,
      status: 'DECLINE',
    );
    if (success) {
      _showSnack('Request declined');
      if (_cartData != null) {
        await _fetchTableRequests(_cartData!.cartId!);
      }
    } else {
      _showSnack('Failed to decline request');
    }
  }

  Future<void> _fetchBillingConfig() async {
    final data = await CartService.fetchBillingConfig(widget.vendorId);
    if (data != null) {
      setState(() => _paymentConfig = PaymentMethodsConfig.fromJson(data));
    }
  }

  // ─── Printer Methods ───────────────────────────────────────────────────────

  Future<void> _loadPairedDevices() async {
    if (!mounted) return;
    setState(() => _isLoadingPrinter = true);
    try {
      final paired = await PrintBluetoothThermal.pairedBluetooths;
      if (mounted) {
        setState(() {
          _pairedDevices = paired;
          _isLoadingPrinter = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingPrinter = false);
      _showSnack('Could not load printers.', Colors.orange);
    }
  }

  Future<void> _printKOTReceipt(
    String macAddress,
    List<CartItem> items, {
    required bool isKOT,
  }) async {
    if (!mounted) return;
    setState(() => _isPrinting = true);
    try {
      await PrintBluetoothThermal.disconnect;
      final connected = await PrintBluetoothThermal.connect(
        macPrinterAddress: macAddress,
      );
      if (connected) {
        await _sendToPrinter(items, isKOT: isKOT);
        if (mounted) {
          _showSnack(
            isKOT ? 'KOT printed successfully!' : 'Receipt printed!',
            Colors.green,
          );
        }
      } else {
        throw Exception('Failed to connect to printer');
      }
    } catch (e) {
      if (mounted) _showSnack('Failed to print: $e', Colors.red);
    } finally {
      if (mounted) setState(() => _isPrinting = false);
    }
  }

  Future<void> _sendToPrinter(
    List<CartItem> items, {
    required bool isKOT,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final companyName = prefs.getString('companyName') ?? 'MAAMAAS HOUSE';
    final now = DateTime.now();
    final dateStr = DateFormat('dd/MM/yyyy').format(now);
    final timeStr = DateFormat('hh:mm a').format(now);

    // ── ESC/POS commands ──────────────────────────────────────────────────────
    const int W = 60;
    const int cItem = 30;
    const int cQty = 7;
    const int cAmt = 20;

    List<int> initialize = [27, 64, 27, 50];
    List<int> centerAlign = [27, 97, 1];
    List<int> leftAlign = [27, 97, 0];
    List<int> boldOn = [27, 69, 1];
    List<int> boldOff = [27, 69, 0];
    List<int> cutPaper = [29, 86, 66, 0];

    // ── Helpers ───────────────────────────────────────────────────────────────
    String sep([String c = '-']) => c * W;

    String row(String left, String right) {
      final space = W - left.length - right.length;
      if (space < 1) {
        final maxLeft = W - right.length - 1;
        if (maxLeft > 0) left = left.substring(0, maxLeft);
        return '$left $right';
      }
      return left + (' ' * space) + right;
    }

    String rs(double v) => 'Rs.${v.toStringAsFixed(2)}';
    String rs0(double v) => 'Rs.${v.toStringAsFixed(0)}';

    Future<void> w(String text) async {
      await PrintBluetoothThermal.writeString(
        printText: PrintTextSize(size: 1, text: text),
      );
    }

    Future<void> wb(List<int> bytes) async {
      await PrintBluetoothThermal.writeBytes(bytes);
    }

    await wb(initialize);

    // ── Header ────────────────────────────────────────────────────────────────
    await wb([...centerAlign, ...boldOn]);
    await w('$companyName\n');
    await wb(boldOff);
    await w(
      isKOT ? '** KITCHEN ORDER TICKET **\n' : '*** CASHIER RECEIPT ***\n',
    );

    // ── Meta ─────────────────────────────────────────────────────────────────
    await wb(leftAlign);
    await w('${sep()}\n');
    await w('${row('Table : ${widget.tableCode}', 'Date: $dateStr')}\n');
    await w(
      '${row('Booking #${_existingBookingId ?? ''}', 'Time: $timeStr')}\n',
    );
    await w('${sep()}\n');

    // ── Column headers ────────────────────────────────────────────────────────

    await w(
      '${'ITEM'.padRight(cItem)}'
      '${'QTY'.padRight(cQty)}'
      '${'AMOUNT'.padLeft(cAmt)}\n',
    );

    await w('${sep()}\n');

    // ── Items ─────────────────────────────────────────────────────────────────
    for (final item in items) {
      String name = item.dishName;
      final qty = '${item.quantity}';
      final amt = rs0(item.price * item.quantity);

      final qtyAmt = qty.padRight(cQty) + amt.padLeft(cAmt);

      if (name.length <= cItem) {
        await w('${name.padRight(cItem)}$qtyAmt\n');
      } else {
        if (name.length > W) name = name.substring(0, W);
        await w('$name\n');
        await w('${''.padRight(cItem)}$qtyAmt\n');
      }

      if (item.note != null && item.note!.isNotEmpty) {
        await w('  Note: ${item.note}\n');
      }
    }

    await w('${sep()}\n');

    // ── Totals ────────────────────────────────────────────────────────────────
    if (!isKOT) {
      await w('${row('Subtotal', rs(_subtotal))}\n');

      final double gstAmt = (_gst > 0 && _gst < _subtotal)
          ? _gst
          : _subtotal * (_gst / 100);
      await w('${row('GST', rs(gstAmt))}\n');

      if (_serviceCharge > 0) {
        await w('${row('Service Charge', rs(_serviceCharge))}\n');
      }
      if (_packingCharges > 0) {
        await w('${row('Packing', rs(_packingCharges))}\n');
      }
      if (_discountAmount > 0) {
        await w('${row('Discount', '-${rs(_discountAmount)}')}\n');
      }
      if (_tipAmount > 0) {
        await w('${row('Tip', rs(_tipAmount))}\n');
      }

      await w('${sep('=')}\n');

      await w('${row('TOTAL', rs(_grandTotal + _tipAmount))}\n');

      await w('${sep('=')}\n');

      if (_paymentMethod.isNotEmpty) {
        await w('${row('Payment', _paymentMethod)}\n');
      }

      await wb(centerAlign);
      await w('Thank you for dining with us!\n');
      await w('Visit us again :)\n');
    } else {
      await wb(centerAlign);
      await w('** Kitchen Copy **\n');
      await w(
        'Items: ${items.length}  '
        'Qty: ${items.fold(0, (s, i) => s + i.quantity)}\n',
      );
    }

    await wb([10, 10]);
    await wb(cutPaper);
  }

  void _showPrinterSelectionDialog(
    List<CartItem> items, {
    required bool isKOT,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PrinterBottomSheet(
        items: items,
        isKOT: isKOT,
        onPrint: (mac) => _printKOTReceipt(mac, items, isKOT: isKOT),
        onSkipPrint: () {
          _showSnack(
            isKOT ? 'KOT sent without print' : 'Items saved without print',
            Colors.orange,
          );
        },
        onLoadDevices: _loadPairedDevices,
        pairedDevices: _pairedDevices,
        isLoading: _isLoadingPrinter,
      ),
    );
  }

  // ─── Payment Integration Methods ─────────────────────────────────────────

  Future<void> _generateDynamicQr() async {
    if (_cartData?.cartId == null) return;

    setState(() {
      _isGeneratingQr = true;
      _qrImageUrl = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final vendorId = prefs.getInt('vendorId') ?? widget.vendorId;
      final phone = prefs.getString('phone') ?? '9876543210';
      final uniqueOrderId =
          'ORD${DateTime.now().millisecondsSinceEpoch}${_cartData!.cartId}';

      final response = await CartService.createDynamicQr(
        amount: _grandTotal + _tipAmount,
        cartId: _cartData!.cartId!,
        vendorId: vendorId,
        phone: phone,
        orderId: uniqueOrderId,
      );

      if (response != null) {
        setState(() {
          _qrImageUrl = response['image_url']?.toString();
          _qrOrderId = uniqueOrderId;
          _qrPaymentId = response['id']?.toString();
          _paymentMethod = 'QR_Payment';
        });
        _startQrPolling();
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) _showQrDialog();
        });
      } else {
        _showSnack('QR generation failed');
      }
    } catch (e) {
      _showSnack('Failed to generate QR: $e');
    } finally {
      setState(() => _isGeneratingQr = false);
    }
  }

  void _showQrDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFe66d33),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Scan & Pay',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        _qrPollingTimer?.cancel();
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.close, color: Colors.white, size: 18),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.currency_rupee,
                          color: const Color(0xFF28a745),
                          size: 22,
                        ),
                        Text(
                          '${(_grandTotal + _tipAmount).toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF28a745),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Builder(
                      builder: (context) {
                        final qrSize = MediaQuery.of(context).size.width * 0.75;
                        return Container(
                          width: qrSize,
                          height: qrSize,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: _qrImageUrl != null
                                ? Image.network(_qrImageUrl!, fit: BoxFit.cover)
                                : Center(
                                    child: CircularProgressIndicator(
                                      color: const Color(0xFFe66d33),
                                      strokeWidth: 3,
                                    ),
                                  ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Scan using any UPI app',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ).then((_) => _qrPollingTimer?.cancel());
  }

  void _startQrPolling() {
    _qrPollingTimer?.cancel();
    Future.delayed(const Duration(seconds: 3), () {
      _qrPollingTimer = Timer.periodic(
        const Duration(seconds: 3),
        _checkQrPayment,
      );
    });
  }

  Future<void> _checkQrPayment(Timer timer) async {
    if (_cartData?.cartId == null || _qrPaymentId == null) return;

    try {
      final status = await CartService.checkPaymentStatus(_cartData!.cartId!);

      if (status != null &&
          (status.contains('success') ||
              status.contains('paid') ||
              status.contains('completed'))) {
        timer.cancel();
        setState(() => _qrPaymentVerified = true);
        if (mounted && Navigator.of(context).canPop()) {
          Navigator.pop(context);
        }
        await _completeQrOrder();
      }
    } catch (e) {
      // debugPrint('❌ QR poll error: $e');
    }
  }

  Future<void> _completeQrOrder() async {
    setState(() => _isPlacingOrder = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final phone = prefs.getString('phone') ?? '9999999999';

      final result = await CartService.createVendorOrder(
        cartId: _cartData!.cartId!,
        vendorId: widget.vendorId,
        paymentMethod: 'Online_Payment',
        phoneNumber: phone,
      );

      if (result != null && mounted) {
        final orderId = result['orderId'] ?? result['id'];
        if (orderId != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt('orderId', orderId);

          _showSnack('✅ Payment successful!');

          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => food_Invoice(orderId: orderId)),
            );
          }
        } else {
          widget.onPaymentSuccess?.call();
        }
      }
    } catch (e) {
      _showSnack('Payment failed: $e');
    } finally {
      if (mounted) setState(() => _isPlacingOrder = false);
    }
  }

  void _openSplitPaymentSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: _SplitPaymentSheet(
          grandTotal: _grandTotal + _tipAmount,
          onSubmit: (payments, hasQrPayment) async {
            setState(() {
              _paymentMethod = 'MULTIPLE';
              _isPlacingOrder = true;
            });

            try {
              final prefs = await SharedPreferences.getInstance();
              final phone = prefs.getString('phone') ?? '9999999999';

              final result = await CartService.createVendorOrder(
                cartId: _cartData!.cartId!,
                vendorId: widget.vendorId,
                paymentMethod: 'MULTIPLE',
                phoneNumber: phone,
              );

              if (result != null && mounted) {
                final orderId = result['orderId'] ?? result['id'];

                final cashPayments = payments
                    .where((p) => p['method'] == 'Cash')
                    .toList();
                for (final cashPayment in cashPayments) {
                  if (cashPayment['denominationData'] != null) {
                    await _addCashBillingEntry(
                      orderId: orderId,
                      cashEntry: cashPayment,
                    );
                  }
                }

                if (orderId != null) {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setInt('orderId', orderId);

                  _showSnack('✅ Split payment completed!');

                  if (mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => food_Invoice(orderId: orderId),
                      ),
                    );
                  }
                } else {
                  widget.onPaymentSuccess?.call();
                }
              }
            } catch (e) {
              _showSnack('Split payment failed: $e');
            } finally {
              if (mounted) setState(() => _isPlacingOrder = false);
            }
          },
        ),
      ),
    );
  }

  Future<void> _addCashBillingEntry({
    required int orderId,
    required Map<String, dynamic> cashEntry,
  }) async {
    try {
      final denomData = cashEntry['denominationData'] as Map<String, dynamic>?;
      if (denomData == null) return;

      final prefs = await SharedPreferences.getInstance();
      final vendorId = prefs.getInt('vendorId') ?? widget.vendorId;
      final today = DateTime.now();
      final dateStr =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      final counts = denomData['denominations'] as Map<String, dynamic>? ?? {};

      final payload = {
        'oneRupee': counts['oneRupee'] ?? 0,
        'twoRupee': counts['twoRupee'] ?? 0,
        'fiveRupee': counts['fiveRupee'] ?? 0,
        'tenRupee': counts['tenRupee'] ?? 0,
        'twentyRupee': counts['twentyRupee'] ?? 0,
        'fiftyRupee': counts['fiftyRupee'] ?? 0,
        'hundredRupee': counts['hundredRupee'] ?? 0,
        'twoHundredRupee': counts['twoHundredRupee'] ?? 0,
        'fiveHundredRupee': counts['fiveHundredRupee'] ?? 0,
        'twoThousandRupee': counts['twoThousandRupee'] ?? 0,
        'grandTotal': denomData['amount'] ?? 0,
        'paid': denomData['received'] ?? 0,
        'returnMoney': denomData['change'] ?? 0,
        'paymentStatus': 'PAID',
        'vendorId': vendorId,
        'date': dateStr,
      };

      await CartService.addCashBilling(orderId, payload);
    } catch (e) {
      // debugPrint('❌ _addCashBillingEntry error: $e');
    }
  }

  void _openCashDenomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: _CashDenominationSheet(
          expectedAmount: _grandTotal + _tipAmount,
          onConfirm: (denomData) async {
            setState(() => _isPlacingOrder = true);
            try {
              final prefs = await SharedPreferences.getInstance();
              final phone = prefs.getString('phone') ?? '9999999999';

              final result = await CartService.createVendorOrder(
                cartId: _cartData!.cartId!,
                vendorId: widget.vendorId,
                paymentMethod: 'Cash',
                phoneNumber: phone,
              );

              if (result != null && mounted) {
                final orderId = result['orderId'] ?? result['id'];

                await _addCashBillingEntry(
                  orderId: orderId,
                  cashEntry: {
                    'method': 'Cash',
                    'amount': _grandTotal + _tipAmount,
                    'denominationData': denomData,
                  },
                );

                if (orderId != null) {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setInt('orderId', orderId);

                  _showSnack('✅ Cash payment recorded!');

                  if (mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => food_Invoice(orderId: orderId),
                      ),
                    );
                  }
                } else {
                  widget.onPaymentSuccess?.call();
                }
              }
            } catch (e) {
              _showSnack('Cash payment failed: $e');
            } finally {
              if (mounted) setState(() => _isPlacingOrder = false);
            }
          },
        ),
      ),
    );
  }

  // ─── Item Operations ─────────────────────────────────────────────────────

  Future<void> _increaseApi(CartItem item) async {
    final cartId = _cartData?.cartId;
    if (cartId == null) return;
    setState(() => _itemLoadingMap[item.itemId!] = true);
    try {
      await CartService.updateItemStatus(
        cartId: cartId,
        itemId: item.itemId!,
        quantity: item.quantity + 1,
        status: 'PENDING',
      );
      await _fetchCartFromBackend();
    } catch (e) {
      _showSnack('Failed to update quantity');
    } finally {
      if (mounted) setState(() => _itemLoadingMap[item.itemId!] = false);
    }
  }

  Future<void> _decreaseApi(CartItem item) async {
    final cartId = _cartData?.cartId;
    if (cartId == null) return;

    if (!_isVendorRole) {
      await _showRemovalRequestPopup(item);
      return;
    }

    setState(() => _itemLoadingMap[item.itemId!] = true);
    try {
      if (item.quantity <= 1) {
        await CartService.removeItem(widget.vendorId, cartId, item.itemId!);
      } else {
        await CartService.updateItemStatus(
          cartId: cartId,
          itemId: item.itemId!,
          quantity: item.quantity - 1,
          status: item.orderStatus ?? 'PENDING',
        );
      }
      await _fetchCartFromBackend();
    } catch (e) {
      _showSnack('Failed to update quantity');
    } finally {
      if (mounted) setState(() => _itemLoadingMap[item.itemId!] = false);
    }
  }

  Future<void> _removeApi(int itemId) async {
    final cartId = _cartData?.cartId;
    if (cartId == null) return;

    if (!_isVendorRole) {
      final item = _apiItems.firstWhere(
        (i) => i.itemId == itemId,
        orElse: () => _apiItems.first,
      );
      await _showRemovalRequestPopup(item);
      return;
    }

    setState(() => _itemLoadingMap[itemId] = true);
    try {
      await CartService.removeItem(widget.vendorId, cartId, itemId);
      await _fetchCartFromBackend();
    } catch (e) {
      _showSnack('Failed to remove item');
    } finally {
      if (mounted) setState(() => _itemLoadingMap[itemId] = false);
    }
  }

  void _increaseLocal(CartItem item) {
    setState(() {
      final idx = _localItems.indexWhere((i) => i.dishId == item.dishId);
      if (idx != -1) {
        _localItems[idx] = item.copyWith(quantity: item.quantity + 1);
      }
    });
    _saveToLocal(_localItems);
  }

  Future<void> _decreaseLocal(CartItem item) async {
    if (!_isVendorRole) {
      await _showRemovalRequestPopup(item);
      return;
    }

    setState(() {
      final idx = _localItems.indexWhere((i) => i.dishId == item.dishId);
      if (idx != -1) {
        if (_localItems[idx].quantity <= 1) {
          _localItems.removeAt(idx);
        } else {
          _localItems[idx] = item.copyWith(quantity: item.quantity - 1);
        }
      }
    });
    _saveToLocal(_localItems);
  }

  Future<void> _removeLocal(int dishId) async {
    if (!_isVendorRole) {
      final item = _localItems.firstWhere(
        (i) => i.dishId == dishId,
        orElse: () => _localItems.first,
      );
      await _showRemovalRequestPopup(item);
      return;
    }

    setState(() => _localItems.removeWhere((i) => i.dishId == dishId));
    _saveToLocal(_localItems);
  }

  Future<void> _showRemovalRequestPopup(CartItem item) async {
    if (_cartData == null && !item.isLocal) {
      _showSnack('Cart not loaded');
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final vendorId = prefs.getInt('vendorId') ?? widget.vendorId;
    final userId = prefs.getInt('userId') ?? 0;
    final employeeId = _employeeId ?? 0;
    final customerId = _customerId ?? '0';

    if (!mounted) return;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _RemovalRequestDialog(
        item: item,
        cartId: _cartData?.cartId ?? 0,
        vendorId: vendorId,
        userId: userId,
        employeeId: employeeId,
        customerId: customerId,
        bookingId: _existingBookingId ?? 0,
        tableCode: widget.tableCode,
        onSuccess: () {
          _showSnack('Removal request submitted!');
          _fetchCartFromBackend();
        },
        onError: (msg) => _showSnack(msg),
      ),
    );
  }

  // ─── Save & KOT Operations ─────────────────────────────────────────────────

  Future<void> _handleSave() async {
    if (_isSaving) return;
    final itemsToSave = _localItems.isNotEmpty ? _localItems : <CartItem>[];
    if (itemsToSave.isEmpty) return;
    setState(() => _isSaving = true);
    try {
      int bookingId = _existingBookingId ?? await _createBooking();
      setState(() => _existingBookingId = bookingId);
      await CartService.addItemsToCart(
        vendorId: widget.vendorId,
        bookingId: bookingId,
        tableCode: widget.tableCode,
        items: itemsToSave
            .map((i) => {'dishId': i.dishId, 'quantity': i.quantity})
            .toList(),
        userId: _cartData?.userId,
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('pendingCartItems');
      setState(() {
        _localItems = [];
        _isUsingLocalStorage = false;
      });
      await Future.delayed(const Duration(milliseconds: 800));
      await _fetchCartFromBackend();
      _showSnack('✅ Items saved successfully!');
    } catch (e) {
      _showSnack('Failed to save: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _handleKOT() async {
    final itemsToProcess = _localItems.isNotEmpty ? _localItems : _apiItems;
    if (itemsToProcess.isEmpty) {
      _showSnack('No items to send to kitchen');
      return;
    }
    setState(() => _isSending = true);
    try {
      int bookingId = _existingBookingId ?? await _createBooking();
      setState(() {
        _existingBookingId = bookingId;
        _isUsingLocalStorage = false;
      });
      if (_localItems.isNotEmpty) {
        await CartService.addItemsToCart(
          vendorId: widget.vendorId,
          bookingId: bookingId,
          tableCode: widget.tableCode,
          items: _localItems
              .map((i) => {'dishId': i.dishId, 'quantity': i.quantity})
              .toList(),
          userId: _cartData?.userId,
        );
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('pendingCartItems');
        setState(() => _localItems = []);
        await Future.delayed(const Duration(milliseconds: 1500));
      }
      await _fetchCartFromBackend();
      final cartId = _cartData?.cartId;
      if (cartId == null) throw Exception('Cart ID not found');
      final itemsToUpdate = _apiItems
          .where(
            (item) => item.orderStatus == null || item.orderStatus == 'PENDING',
          )
          .toList();
      int updatedCount = 0;
      for (final item in itemsToUpdate) {
        if (item.itemId != null) {
          try {
            await CartService.updateItemStatus(
              cartId: cartId,
              itemId: item.itemId!,
              quantity: item.quantity,
              status: 'CONFIRMED',
              note: item.note ?? '',
            );
            updatedCount++;
          } catch (e) {
            // debugPrint('Failed to update item ${item.itemId}: $e');
          }
        }
      }
      await _fetchCartFromBackend();
      _showSnack('✅ KOT sent! ($updatedCount items)');
    } catch (err) {
      _showSnack('Failed to send KOT: $err');
    } finally {
      setState(() => _isSending = false);
    }
  }

  // UPDATED: Cashier KOT with Print functionality
  Future<void> _handleSaveAndPrint() async {
    if (_isSaving) return;

    final itemsToProcess = _localItems.isNotEmpty ? _localItems : _apiItems;
    if (itemsToProcess.isEmpty) {
      _showSnack('No items to process');
      return;
    }

    setState(() => _isSaving = true);

    try {
      int bookingId = _existingBookingId ?? await _createBooking();
      setState(
        () => {_existingBookingId = bookingId, _isUsingLocalStorage = false},
      );

      if (_localItems.isNotEmpty) {
        await CartService.addItemsToCart(
          vendorId: widget.vendorId,
          bookingId: bookingId,
          tableCode: widget.tableCode,
          items: _localItems
              .map((i) => {'dishId': i.dishId, 'quantity': i.quantity})
              .toList(),
          userId: _cartData?.userId,
        );
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('pendingCartItems');
        setState(() => _localItems = []);
        await Future.delayed(const Duration(milliseconds: 1500));
      }

      await _fetchCartFromBackend();
      final cartId = _cartData?.cartId;
      if (cartId == null) throw Exception('Cart ID not found');

      final itemsToUpdate = _apiItems
          .where(
            (item) =>
                item.orderStatus == null ||
                item.orderStatus == 'PENDING' ||
                item.orderStatus == 'CONFIRMED',
          )
          .toList();

      int updatedCount = 0;
      for (final item in itemsToUpdate) {
        if (item.itemId != null) {
          try {
            await CartService.updateItemStatus(
              cartId: cartId,
              itemId: item.itemId!,
              quantity: item.quantity,
              status: 'DELIVERED',
              note: item.note ?? '',
            );
            updatedCount++;
          } catch (e) {
            // debugPrint('Failed to update item ${item.itemId}: $e');
          }
        }
      }

      await _loadPairedDevices();
      if (mounted && _pairedDevices.isNotEmpty) {
        _showPrinterSelectionDialog(itemsToUpdate, isKOT: false);
      } else {
        _showSnack('✅ $updatedCount items delivered! (No printer found)');
      }

      await _fetchCartFromBackend();
    } catch (err) {
      _showSnack('Failed: $err');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _handleKOTAndPrint() async {
    if (_isCashierKOTPrinting) return;

    final itemsToProcess = _localItems.isNotEmpty ? _localItems : _apiItems;
    if (itemsToProcess.isEmpty) {
      _showSnack('No items to send to kitchen');
      return;
    }

    setState(() => _isCashierKOTPrinting = true);

    try {
      int bookingId = _existingBookingId ?? await _createBooking();

      if (_localItems.isNotEmpty) {
        await CartService.addItemsToCart(
          vendorId: widget.vendorId,
          bookingId: bookingId,
          tableCode: widget.tableCode,
          items: _localItems
              .map((i) => {'dishId': i.dishId, 'quantity': i.quantity})
              .toList(),
          userId: _cartData?.userId,
        );
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('pendingCartItems');
        setState(() => _localItems = []);
        await Future.delayed(const Duration(milliseconds: 1500));
      }

      await _fetchCartFromBackend();
      final cartId = _cartData?.cartId;
      if (cartId == null) throw Exception('Cart ID not found');

      final itemsToUpdate = _apiItems
          .where(
            (item) =>
                item.orderStatus == null ||
                item.orderStatus == 'PENDING' ||
                item.orderStatus == 'CONFIRMED',
          )
          .toList();

      int updatedCount = 0;
      for (final item in itemsToUpdate) {
        if (item.itemId != null) {
          try {
            await CartService.updateItemStatus(
              cartId: cartId,
              itemId: item.itemId!,
              quantity: item.quantity,
              status: 'DELIVERED',
              note: item.note ?? '',
            );
            updatedCount++;
          } catch (e) {
            // debugPrint('Failed to update item ${item.itemId}: $e');
          }
        }
      }

      await _loadPairedDevices();
      if (mounted && _pairedDevices.isNotEmpty) {
        _showPrinterSelectionDialog(itemsToUpdate, isKOT: true);
      } else {
        _showSnack(
          '✅ $updatedCount items sent to kitchen! (No printer found)',
          Colors.orange,
        );
      }

      await _fetchCartFromBackend();
    } catch (err) {
      _showSnack('Failed: $err');
    } finally {
      setState(() => _isCashierKOTPrinting = false);
    }
  }

  Future<int> _createBooking() async {
    final id = await CartService.createBooking(
      vendorId: widget.vendorId,
      seatingId: widget.seatingId ?? 0,
      tableCode: widget.tableCode,
      capacity: 4,
      tableName: widget.tableCode,
    );
    if (id == null) throw Exception('Failed to create booking');
    return id;
  }

  // ─── Tip ───────────────────────────────────────────────────────────────────
  Future<void> _addTip({bool apply = true}) async {
    final cartId = _cartData?.cartId;
    if (cartId == null) {
      _showSnack('Cart not found');
      return;
    }
    double amount = 0;
    if (apply) {
      if (_selectedTip != null) {
        amount = _selectedTip!;
      } else {
        amount = double.tryParse(_customTipCtrl.text) ?? 0;
      }
      if (amount <= 0) {
        _showSnack('Please select or enter a tip amount');
        return;
      }
    }
    setState(() => _isAddingTip = true);
    try {
      await CartService.addTip(cartId: cartId, amount: amount, apply: apply);
      setState(() {
        _selectedTip = null;
        _customTipCtrl.clear();
      });
      await _fetchCartFromBackend();
      _showSnack(apply ? '✅ Tip added!' : '✅ Tip removed!');
    } catch (e) {
      _showSnack('Failed to process tip');
    } finally {
      if (mounted) setState(() => _isAddingTip = false);
    }
  }

  // ─── Discount ──────────────────────────────────────────────────────────────
  Future<void> _applyDiscount({bool apply = true}) async {
    final cartId = _cartData?.cartId;
    if (cartId == null) return;
    final val = double.tryParse(_discountCtrl.text) ?? 0;
    try {
      await CartService.applyDiscount(
        cartId: cartId,
        discountAmount: val,
        apply: apply,
      );
      if (!apply) _discountCtrl.clear();
      await _fetchCartFromBackend();
    } catch (e) {
      _showSnack('Failed to apply discount');
    }
  }

  Future<void> _updateRequest(int id, String status) async {
    try {
      await CartService.updateRequestStatus(id, status);
      await _fetchRemovalRequests(_cartData!.cartId!);
      if (status == 'ACCEPT') await _fetchCartFromBackend();
      _showSnack('Request ${status == "ACCEPT" ? "accepted" : "declined"}');
    } catch (e) {
      _showSnack('Failed to update request');
    }
  }

  // ─── Helpers ────────────────────────────────────────────────────────────────
  void _showSnack(String msg, [Color? color]) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: color ?? const Color(0xFF28a745),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(12),
      ),
    );
  }

  List<CartItem> get _displayItems => [..._apiItems, ..._localItems];
  int get _pendingRequestsCount =>
      _removalRequests.where((r) => r.status == 'PENDING').length;
  int get _pendingTableRequestsCount =>
      _tableRequests.where((r) => r.isPending).length;

  void _showTableRequestsSheet() {
    if (!_isVendorRole) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _TableRequestsSheet(
        requests: _tableRequests,
        isVendorRole: _isVendorRole,
        onAccept: (req) async {
          Navigator.pop(context);
          await _acceptTableRequest(req);
        },
        onDecline: (req) async {
          Navigator.pop(context);
          await _declineTableRequest(req);
        },
        onRefresh: () async {
          if (_cartData?.cartId != null) {
            await _fetchTableRequests(_cartData!.cartId!);
          }
        },
      ),
    );
  }

  // ─── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: _buildAppBar(),
      body: SafeArea(
        top: false,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFFe66d33)),
              )
            : _displayItems.isEmpty
            ? _buildEmptyCart()
            : _buildCartContent(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Color(0xFFe66d33)),
        onPressed: widget.onBack,
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Table ${widget.tableCode}',
            style: const TextStyle(
              color: Color(0xFF333333),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (_isVendorRole)
            Text(
              '',
              style: TextStyle(fontSize: 11, color: Colors.green.shade600),
            )
          else
            Text(
              'Employee Mode',
              style: TextStyle(fontSize: 11, color: Colors.orange.shade700),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'Cart is empty',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add items from the menu',
            style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildCartContent() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_isVendorRole && _pendingTableRequestsCount > 0) ...[
                  _buildPendingRequestsBanner(),
                  const SizedBox(height: 8),
                ],
                _isBillMode ? _buildBillTable() : _buildCartTable(),
                const SizedBox(height: 12),
                if (_isBillMode && _apiItems.isNotEmpty) ...[
                  BillSummarySheet(
                    subtotal: _subtotal,
                    gst: _gst,
                    serviceCharge: _serviceCharge,
                    packingCharges: _packingCharges,
                    platformFee: _platformFee,
                    deliveryCharge: _deliveryCharge,
                    discountAmount: _discountAmount,
                    isDiscountApplied: _isDiscountApplied,
                    discountCtrl: _discountCtrl,
                    total: _total,
                    grandTotal: _grandTotal,
                    onApplyDiscount: () => _applyDiscount(apply: true),
                    onRemoveDiscount: () => _applyDiscount(apply: false),
                  ),
                  const SizedBox(height: 12),
                  TipSection(
                    tipAmount: _tipAmount,
                    selectedTip: _selectedTip,
                    customTipCtrl: _customTipCtrl,
                    isAddingTip: _isAddingTip,
                    onSelectTip: (v) => setState(() => _selectedTip = v),
                    onAddTip: () => _addTip(apply: true),
                    onRemoveTip: () => _addTip(apply: false),
                  ),
                  const SizedBox(height: 12),
                  PaymentSection(
                    paymentConfig: _paymentConfig,
                    selectedMethod: _paymentMethod,
                    grandTotal: _grandTotal,
                    tipAmount: _tipAmount,
                    cartId: _cartData?.cartId,
                    vendorId: widget.vendorId,
                    authToken: widget.authToken,
                    onMethodChanged: (m) => setState(() => _paymentMethod = m),
                    onPaymentSuccess: widget.onPaymentSuccess,
                    onBack: widget.onBack,
                    onSplitByGuests: _showSplitByGuestsModal,
                    onQRPaymentRequested: _generateDynamicQr,
                    onSplitPaymentRequested: _openSplitPaymentSheet,
                    onCashPaymentRequested: _openCashDenomSheet,
                    onOrderPlaced: (orderId) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => food_Invoice(orderId: orderId),
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildPendingRequestsBanner() {
    final pendingList = _tableRequests.where((r) => r.isPending).toList();
    return GestureDetector(
      onTap: _showTableRequestsSheet,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.orange.shade200),
        ),
        child: Row(
          children: [
            Icon(
              Icons.pending_actions,
              color: Colors.orange.shade700,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '$pendingList pending removal request${pendingList.length > 1 ? 's' : ''}',
                style: TextStyle(
                  color: Colors.orange.shade800,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.orange.shade700,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartTable() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFe66d33).withOpacity(0.08),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                const SizedBox(width: 32),
                const Expanded(
                  child: Text(
                    'Item',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
                const SizedBox(
                  width: 90,
                  child: Center(
                    child: Text(
                      'Qty',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 70,
                  child: Text(
                    'Price',
                    textAlign: TextAlign.right,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  child: Text(
                    _isVendorRole ? '' : '',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: _isVendorRole
                          ? Colors.green.shade700
                          : Colors.orange.shade800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ..._apiItems.map((item) {
            final isLoading = _itemLoadingMap[item.itemId] == true;
            final pendingReqs = _isVendorRole
                ? _pendingTableRequestsFor(item.itemId ?? 0)
                : <TableRequestEntry>[];
            return Column(
              key: ValueKey(item.itemId),
              children: [
                Stack(
                  children: [
                    CartItemTile(
                      item: item,
                      onIncrease: isLoading ? () {} : () => _increaseApi(item),
                      onDecrease: isLoading ? () {} : () => _decreaseApi(item),
                      onRemove: isLoading
                          ? () {}
                          : () => _removeApi(item.itemId!),
                      onNote: () => _showNoteModal(item),
                      isSaved: true,
                    ),
                    if (isLoading)
                      Positioned.fill(
                        child: Container(
                          color: Colors.white.withOpacity(0.6),
                          child: const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFFe66d33),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                if (pendingReqs.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
                    child: Column(
                      children: pendingReqs
                          .map((req) => _buildRequestChip(req))
                          .toList(),
                    ),
                  ),
              ],
            );
          }),
          ..._localItems.map(
            (item) => CartItemTile(
              item: item,
              onIncrease: () => _increaseLocal(item),
              onDecrease: () => _decreaseLocal(item),
              onRemove: () => _removeLocal(item.dishId),
              onNote: () => _showNoteModal(item),
              isSaved: false,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text(
                  'Subtotal: ',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                Text(
                  '₹${_subtotal.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFFe66d33),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestChip(TableRequestEntry req) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.pending, size: 12, color: Colors.orange.shade700),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              'Remove ${req.removalQuantity ?? req.quantity ?? 1} item(s)',
              style: TextStyle(fontSize: 11, color: Colors.orange.shade800),
            ),
          ),
          GestureDetector(
            onTap: () => _acceptTableRequest(req),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'Accept',
                style: TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () => _declineTableRequest(req),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'Decline',
                style: TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillTable() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Row(
              children: [
                Icon(Icons.receipt_long, color: Color(0xFFe66d33), size: 18),
                SizedBox(width: 6),
                Text(
                  'Bill',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ],
            ),
            const Divider(height: 20),
            Table(
              columnWidths: const {
                0: FlexColumnWidth(3),
                1: FlexColumnWidth(1),
                2: FlexColumnWidth(1.5),
                3: FlexColumnWidth(1.5),
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  children: ['Item', 'Qty', 'Price', 'Total']
                      .map(
                        (h) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Text(
                            h,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                ..._displayItems.map(
                  (item) => TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Text(
                          item.dishName,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Text(
                          '${item.quantity}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Text(
                          '₹${item.price.toStringAsFixed(0)}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Text(
                          '₹${(item.price * item.quantity).toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                _actionBtn(
                  'Save',
                  const Color(0xFF28a745),
                  Icons.save_outlined,
                  _isSaving ? null : _handleSave,
                  loading: _isSaving,
                ),
                const SizedBox(width: 6),
                _actionBtn(
                  'Cashier KOT',
                  const Color(0xFF17a2b8),
                  Icons.receipt_long,
                  _isSaving ? null : _handleSaveAndPrint,
                  loading: _isSaving,
                ),
                const SizedBox(width: 6),
                _actionBtn(
                  'KOT',
                  const Color(0xFFffc107),
                  Icons.restaurant,
                  _isSending ? null : _handleKOT,
                  textColor: Colors.black,
                  loading: _isSending,
                ),
                const SizedBox(width: 6),
                _actionBtn(
                  'Kitchen KOT',
                  const Color(0xFFdc3545),
                  Icons.local_fire_department,
                  _isCashierKOTPrinting ? null : _handleKOTAndPrint,
                  loading: _isCashierKOTPrinting,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 40,
                        child: OutlinedButton(
                          onPressed: _showRemovalRequestsModal,
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: _pendingRequestsCount > 0
                                  ? const Color(0xFFe66d33)
                                  : Colors.grey.shade300,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.assignment_outlined,
                                size: 14,
                                color: Color(0xFFe66d33),
                              ),
                              const SizedBox(height: 1),
                              const Text(
                                'Requests',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: Color(0xFFe66d33),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (_pendingRequestsCount > 0)
                        Positioned(
                          top: -5,
                          right: -5,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: const BoxDecoration(
                              color: Color(0xFFff4444),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '$_pendingRequestsCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            if (_apiItems.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  _actionBtn(
                    _isBillMode ? 'Regenerate' : 'Generate Bill',
                    const Color(0xFFe66d33),
                    _isBillMode ? Icons.refresh : Icons.receipt_long_outlined,
                    () => setState(() => _isBillMode = !_isBillMode),
                  ),
                  const SizedBox(width: 6),
                  _actionBtn(
                    'Print Bill',
                    const Color(0xFF6c757d),
                    Icons.print_outlined,
                    _printBill,
                  ),
                  const SizedBox(width: 6),
                  _actionBtn(
                    'E-Bill',
                    const Color(0xFF17a2b8),
                    Icons.email_outlined,
                    _showEBillModal,
                  ),
                  const SizedBox(width: 6),
                  _actionBtn(
                    'Change Table',
                    const Color(0xFF6610f2),
                    Icons.table_restaurant_outlined,
                    _showChangeTableModal,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _actionBtn(
    String label,
    Color color,
    IconData icon,
    VoidCallback? onTap, {
    Color textColor = Colors.white,
    bool loading = false,
  }) {
    return Expanded(
      child: SizedBox(
        height: 40,
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: onTap == null ? color.withOpacity(0.5) : color,
            foregroundColor: textColor,
            elevation: 0,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: loading
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: textColor,
                  ),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 14, color: textColor),
                    const SizedBox(height: 1),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 9,
                        color: textColor,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  void _showNoteModal(CartItem item) {
    final ctrl = TextEditingController(text: item.note ?? '');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.note_alt_outlined, color: Color(0xFFe66d33)),
                const SizedBox(width: 8),
                Text(
                  'Note for ${item.dishName}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              maxLines: 3,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'e.g. less spicy, no onions…',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFe66d33)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFe66d33),
                    ),
                    onPressed: () {
                      setState(() {
                        if (item.isLocal) {
                          final idx = _localItems.indexWhere(
                            (i) => i.dishId == item.dishId,
                          );
                          if (idx != -1)
                            _localItems[idx] = item.copyWith(note: ctrl.text);
                        } else {
                          final idx = _apiItems.indexWhere(
                            (i) => i.dishId == item.dishId,
                          );
                          if (idx != -1)
                            _apiItems[idx] = item.copyWith(note: ctrl.text);
                        }
                      });
                      Navigator.pop(ctx);
                    },
                    child: const Text(
                      'Save',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _showRemovalRequestsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => RemovalRequestsModal(
        requests: _removalRequests,
        onUpdateStatus: _updateRequest,
      ),
    );
  }

  void _showChangeTableModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => ChangeTableModal(
        vendorId: widget.vendorId,
        cartData: _cartData,
        authToken: widget.authToken,
        currentTableCode: widget.tableCode,
        onSuccess: () async {
          Navigator.pop(ctx);
          await _fetchCartFromBackend();
          _showSnack('Table changed successfully!');
        },
      ),
    );
  }

  void _showEBillModal() {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Send E-Bill',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(
                labelText: 'Customer Name',
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: const Icon(Icons.phone_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFe66d33),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _showSnack('✅ E-Bill sent!');
                    },
                    child: const Text(
                      'Send E-Bill',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _showSplitByGuestsModal() {
    final guestCtrl = TextEditingController();
    int guests = 0;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Split Bill by Guests',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color(0xFFe66d33),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: guestCtrl,
                keyboardType: TextInputType.number,
                autofocus: true,
                onChanged: (v) => setModal(() => guests = int.tryParse(v) ?? 0),
                decoration: InputDecoration(
                  labelText: 'Number of Guests *',
                  prefixIcon: const Icon(Icons.people_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              if (guests > 0) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFe8f5e9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFc8e6c9)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Amount per guest:',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Text(
                        '₹${((_grandTotal + _tipAmount) / guests).toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFFe66d33),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: guests > 0
                            ? const Color(0xFFe66d33)
                            : Colors.grey,
                      ),
                      onPressed: guests > 0
                          ? () {
                              Navigator.pop(ctx);
                              _showSnack('✅ Bill split among $guests guests');
                            }
                          : null,
                      child: const Text(
                        'Confirm Split',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _printBill() async {
    _showSnack('Print feature requires a connected printer');
  }
}

class _TableRequestsSheet extends StatelessWidget {
  final List<TableRequestEntry> requests;
  final bool isVendorRole;
  final Future<void> Function(TableRequestEntry) onAccept;
  final Future<void> Function(TableRequestEntry) onDecline;
  final Future<void> Function() onRefresh;

  const _TableRequestsSheet({
    required this.requests,
    required this.isVendorRole,
    required this.onAccept,
    required this.onDecline,
    required this.onRefresh,
  });

  Color _statusColor(String status) {
    switch (status) {
      case 'ACCEPT':
        return const Color(0xFF28a745);
      case 'DECLINE':
        return const Color(0xFFdc3545);
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final pendingCount = requests.where((r) => r.isPending).length;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.pending_actions_rounded,
                      color: Colors.orange,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Removal Requests',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          '$pendingCount pending • ${requests.length} total',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            Flexible(
              child: requests.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Text(
                          'No requests found',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(16),
                      itemCount: requests.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (ctx, i) {
                        final req = requests[i];
                        return Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 34,
                                    height: 34,
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFFe66d33,
                                      ).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.remove_shopping_cart_outlined,
                                      color: Color(0xFFe66d33),
                                      size: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          req.itemName ?? 'Item #${req.itemId}',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        Text(
                                          'Req #${req.id} • Remove qty: ${req.removalQuantity ?? req.quantity ?? 1} • By: ${req.name}',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _statusColor(
                                        req.status,
                                      ).withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      req.status,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: _statusColor(req.status),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (req.reason != null &&
                                  req.reason!.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.grey.shade200,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.notes_rounded,
                                        size: 12,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          req.reason!,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              if (isVendorRole && req.isPending) ...[
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () => onDecline(req),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 10,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(
                                              0xFFdc3545,
                                            ).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: const Color(
                                                0xFFdc3545,
                                              ).withOpacity(0.3),
                                            ),
                                          ),
                                          child: const Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.close_rounded,
                                                color: Color(0xFFdc3545),
                                                size: 14,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                'Decline',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w700,
                                                  color: Color(0xFFdc3545),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      flex: 2,
                                      child: GestureDetector(
                                        onTap: () => onAccept(req),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 10,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF28a745),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: const Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.check_rounded,
                                                color: Colors.white,
                                                size: 14,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                'Accept & Update Cart',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w700,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RemovalRequestDialog extends StatefulWidget {
  final CartItem item;
  final int cartId;
  final int vendorId;
  final int userId;
  final int employeeId;
  final String customerId;
  final int bookingId;
  final String tableCode;
  final VoidCallback onSuccess;
  final void Function(String) onError;

  const _RemovalRequestDialog({
    required this.item,
    required this.cartId,
    required this.vendorId,
    required this.userId,
    required this.employeeId,
    required this.customerId,
    required this.bookingId,
    required this.tableCode,
    required this.onSuccess,
    required this.onError,
  });

  @override
  State<_RemovalRequestDialog> createState() => _RemovalRequestDialogState();
}

class _RemovalRequestDialogState extends State<_RemovalRequestDialog> {
  final _reasonController = TextEditingController();
  bool _isSubmitting = false;

  RemovalRequestType _selectedType = RemovalRequestType.removalQuantity;
  bool _dropdownOpen = false;
  int _removeQty = 1;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  String get _requestTypeValue =>
      _selectedType == RemovalRequestType.removalQuantity
      ? 'REMOVAL_QUANTITY'
      : 'REMOVE_ITEM';

  String get _dropdownLabel =>
      _selectedType == RemovalRequestType.removalQuantity
      ? 'Removal Quantity'
      : 'Remove Item';

  Color get _typeColor => _selectedType == RemovalRequestType.removalQuantity
      ? Colors.orange
      : const Color(0xFFdc3545);

  IconData get _typeIcon => _selectedType == RemovalRequestType.removalQuantity
      ? Icons.remove_circle_outline_rounded
      : Icons.delete_outline_rounded;

  Future<void> _submit() async {
    final reason = _reasonController.text.trim();
    if (reason.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Please enter a reason',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final payload = TableRequestModel(
        vendorId: widget.vendorId,
        userId: widget.userId,
        itemId: widget.item.itemId ?? widget.item.dishId,
        removalQuantity: _selectedType == RemovalRequestType.removalQuantity
            ? _removeQty
            : widget.item.quantity,
        cartId: widget.cartId,
        tableBookingId: widget.bookingId,
        tableCode: widget.tableCode,
        requestType: _requestTypeValue,
        employeeId: widget.employeeId,
        customerId: widget.customerId,
        reason: reason,
      );

      // debugPrint('📤 Submitting removal request:');
      // debugPrint(jsonEncode(payload.toJson()));

      final ok = await TableRequestService.createRemovalRequest(
        request: payload,
      );

      if (!ok) {
        widget.onError('Failed to submit request. Please try again.');
        if (mounted) Navigator.pop(context);
        return;
      }

      if (mounted) Navigator.pop(context);
      widget.onSuccess();
    } catch (e) {
      widget.onError('Error: $e');
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _selectType(RemovalRequestType type) {
    setState(() {
      _selectedType = type;
      _dropdownOpen = false;
      _removeQty = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFdc3545).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.remove_shopping_cart_outlined,
                          color: Color(0xFFdc3545),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Removal Request',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              'Choose request type and fill details',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFe66d33).withOpacity(0.07),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFe66d33).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFe66d33),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.restaurant_menu_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.item.dishName,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  _infoChip(
                                    '${widget.item.quantity} in cart',
                                    Icons.shopping_cart_outlined,
                                    const Color(0xFFe66d33),
                                  ),
                                  const SizedBox(width: 8),
                                  _infoChip(
                                    '₹${widget.item.price.toStringAsFixed(0)} each',
                                    Icons.currency_rupee,
                                    const Color(0xFF28a745),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.tune_rounded,
                            size: 14,
                            color: Colors.grey,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Request Type',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () =>
                            setState(() => _dropdownOpen = !_dropdownOpen),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 13,
                          ),
                          decoration: BoxDecoration(
                            color: _typeColor.withOpacity(0.07),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _typeColor.withOpacity(0.5),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: _typeColor.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  _typeIcon,
                                  color: _typeColor,
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _dropdownLabel,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: _typeColor,
                                  ),
                                ),
                              ),
                              AnimatedRotation(
                                turns: _dropdownOpen ? 0.5 : 0,
                                duration: const Duration(milliseconds: 200),
                                child: Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: _typeColor,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      AnimatedCrossFade(
                        duration: const Duration(milliseconds: 200),
                        crossFadeState: _dropdownOpen
                            ? CrossFadeState.showFirst
                            : CrossFadeState.showSecond,
                        firstChild: Container(
                          margin: const EdgeInsets.only(top: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              _buildDropdownOption(
                                type: RemovalRequestType.removalQuantity,
                                label: 'Removal Quantity',
                                sublabel: 'Reduce quantity of this item',
                                icon: Icons.remove_circle_outline_rounded,
                                color: Colors.orange,
                                isLast: false,
                              ),
                              _buildDropdownOption(
                                type: RemovalRequestType.removeItem,
                                label: 'Remove Item',
                                sublabel: 'Remove entire item from cart',
                                icon: Icons.delete_outline_rounded,
                                color: const Color(0xFFdc3545),
                                isLast: true,
                              ),
                            ],
                          ),
                        ),
                        secondChild: const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (_selectedType == RemovalRequestType.removalQuantity)
                  _buildQuantitySection(),
                if (_selectedType == RemovalRequestType.removeItem)
                  _buildRemoveItemPreview(),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(
                            Icons.edit_note_rounded,
                            size: 14,
                            color: Colors.grey,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Reason for Removal',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            ' *',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFFdc3545),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: TextField(
                          controller: _reasonController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            hintText:
                                'e.g. Customer changed mind, wrong item ordered…',
                            hintStyle: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(12),
                          ),
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: const Center(
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: GestureDetector(
                          onTap: _isSubmitting ? null : _submit,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: _isSubmitting
                                    ? [Colors.grey, Colors.grey]
                                    : _selectedType ==
                                          RemovalRequestType.removeItem
                                    ? [
                                        const Color(0xFFdc3545),
                                        const Color(0xFFB91C1C),
                                      ]
                                    : [Colors.orange, const Color(0xFFD97706)],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: _isSubmitting
                                  ? []
                                  : [
                                      BoxShadow(
                                        color: _typeColor.withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                            ),
                            child: _isSubmitting
                                ? const Center(
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  )
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.send_rounded,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Submit Request',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownOption({
    required RemovalRequestType type,
    required String label,
    required String sublabel,
    required IconData icon,
    required Color color,
    required bool isLast,
  }) {
    final isSelected = _selectedType == type;
    return GestureDetector(
      onTap: () => _selectType(type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.06) : Colors.transparent,
          borderRadius: isLast
              ? const BorderRadius.vertical(bottom: Radius.circular(12))
              : BorderRadius.zero,
          border: isLast
              ? null
              : Border(bottom: BorderSide(color: Colors.grey.shade100)),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: color.withOpacity(isSelected ? 0.15 : 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w600,
                      color: isSelected ? color : Colors.black87,
                    ),
                  ),
                  Text(
                    sublabel,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 12,
                ),
              )
            else
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade300, width: 1.5),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantitySection() {
    final presentQty = widget.item.quantity;
    final remainQty = (presentQty - _removeQty).clamp(0, presentQty);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.format_list_numbered_rounded,
                size: 14,
                color: Colors.grey,
              ),
              SizedBox(width: 6),
              Text(
                'Quantity Details',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _qtyStatBox(
                    label: 'Present',
                    value: presentQty,
                    color: const Color(0xFF17a2b8),
                    icon: Icons.inventory_2_outlined,
                  ),
                ),
                Container(width: 1, height: 48, color: Colors.grey.shade200),
                Expanded(
                  child: _qtyStatBox(
                    label: 'Removing',
                    value: _removeQty,
                    color: const Color(0xFFdc3545),
                    icon: Icons.remove_circle_outline_rounded,
                  ),
                ),
                Container(width: 1, height: 48, color: Colors.grey.shade200),
                Expanded(
                  child: _qtyStatBox(
                    label: 'Remaining',
                    value: remainQty,
                    color: const Color(0xFF28a745),
                    icon: Icons.check_circle_outline_rounded,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: _removeQty > 1
                      ? () => setState(() => _removeQty--)
                      : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 120),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _removeQty > 1
                          ? const Color(0xFFdc3545).withOpacity(0.1)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.remove_rounded,
                      size: 20,
                      color: _removeQty > 1
                          ? const Color(0xFFdc3545)
                          : const Color(0xFFAAAAAC),
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        '$_removeQty',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFdc3545),
                          height: 1.1,
                        ),
                      ),
                      const Text(
                        'to remove',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFFAAAAAC),
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: _removeQty < presentQty
                      ? () => setState(() => _removeQty++)
                      : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 120),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _removeQty < presentQty
                          ? const Color(0xFF28a745).withOpacity(0.1)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.add_rounded,
                      size: 20,
                      color: _removeQty < presentQty
                          ? const Color(0xFF28a745)
                          : const Color(0xFFAAAAAC),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _qtyStatBox({
    required String label,
    required int value,
    required Color color,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 4),
        Text(
          '$value',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  Widget _buildRemoveItemPreview() {
    final totalPrice = widget.item.price * widget.item.quantity;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFdc3545).withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFdc3545).withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Color(0xFFdc3545),
                  size: 16,
                ),
                SizedBox(width: 6),
                Text(
                  'This will remove the entire item',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFdc3545),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: const Color(0xFFdc3545).withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      color: Color(0xFFdc3545),
                      size: 14,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Text(
                              widget.item.dishName,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF6B6B8A),
                              ),
                            ),
                            Positioned.fill(
                              child: Center(
                                child: Container(
                                  height: 1.5,
                                  color: const Color(
                                    0xFFdc3545,
                                  ).withOpacity(0.7),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${widget.item.quantity} qty × ₹${widget.item.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        '₹${totalPrice.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF6B6B8A),
                        ),
                      ),
                      Positioned.fill(
                        child: Center(
                          child: Container(
                            height: 1.5,
                            color: const Color(0xFFdc3545).withOpacity(0.7),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrinterBottomSheet extends StatefulWidget {
  final List<CartItem> items;
  final bool isKOT;
  final Function(String) onPrint;
  final VoidCallback onSkipPrint;
  final Future<void> Function() onLoadDevices;
  final List<BluetoothInfo> pairedDevices;
  final bool isLoading;

  const _PrinterBottomSheet({
    required this.items,
    required this.isKOT,
    required this.onPrint,
    required this.onSkipPrint,
    required this.onLoadDevices,
    required this.pairedDevices,
    required this.isLoading,
  });

  @override
  State<_PrinterBottomSheet> createState() => _PrinterBottomSheetState();
}

class _PrinterBottomSheetState extends State<_PrinterBottomSheet> {
  bool _isConnecting = false;

  @override
  void initState() {
    super.initState();
    widget.onLoadDevices();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 10),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFF17a2b8).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.print_rounded,
                      color: const Color(0xFF17a2b8),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select Printer',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        Text(
                          '${widget.items.length} item(s)',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: Colors.grey.shade200, height: 1),
            SizedBox(
              height: 220,
              child: widget.isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: const Color(0xFFe66d33),
                        strokeWidth: 2,
                      ),
                    )
                  : widget.pairedDevices.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.bluetooth_disabled_rounded,
                            size: 40,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'No printers found',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Please pair your printer first',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: widget.pairedDevices.length,
                      itemBuilder: (_, i) {
                        final device = widget.pairedDevices[i];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF17a2b8,
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.print_rounded,
                                  color: const Color(0xFF17a2b8),
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      device.name,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey.shade800,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      device.macAdress,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: _isConnecting
                                    ? null
                                    : () async {
                                        setState(() => _isConnecting = true);
                                        await widget.onPrint(device.macAdress);
                                        if (mounted) Navigator.pop(context);
                                      },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 7,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF10B981),
                                        Color(0xFF059669),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: _isConnecting
                                      ? SizedBox(
                                          width: 14,
                                          height: 14,
                                          child:
                                              const CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2,
                                              ),
                                        )
                                      : Text(
                                          'Print',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            Divider(color: Colors.grey.shade200, height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        widget.onSkipPrint();
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: Center(
                          child: Text(
                            widget.isKOT
                                ? 'Send Without Print'
                                : 'Save Without Print',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.orange.shade700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Center(
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
