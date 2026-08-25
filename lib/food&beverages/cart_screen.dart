import 'dart:convert';
import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import '../API/Apiclient.dart';
import '../API/food_authservice.dart';
import '../Models/food&beverages/cart_model.dart';
import '../Models/food&beverages/orders_model.dart';
import '../widgets_helper/food/utils.dart';
import 'Invoice.dart';
import 'Menu_managemnet.dart';

// ─── Design Tokens ─────────────────────────────────────────────────────────────
class _C {
  static const bg = Color(0xFFF6F7FB);
  static const white = Color(0xFFFFFFFF);
  static const border = Color(0xFFEAEBF2);
  static const accent = Color(0xFFE66D33);
  static const accentLight = Color(0xFFF5E8FA);
  static const accentDark = Color(0xFFE66D33);
  static const green = Color(0xFF2ECC71);
  static const greenLight = Color(0xFFE8F8F0);
  static const red = Color(0xFFE74C3C);
  static const redLight = Color(0xFFFEECEB);
  static const orange = Color(0xFFF39C12);
  static const text1 = Color(0xFF1A1A2E);
  static const text2 = Color(0xFF6B6B8A);
  static const text3 = Color(0xFFAAAAAC);
  static const shadow = Color(0x0F000000);
  static const shadowMd = Color(0x18000000);
}

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
            fontSize: 11.sp,
            fontWeight: FontWeight.w700,
            color: _C.text2,
          ),
        ),
        SizedBox(height: 4.h),
        Container(
          height: 38.h,
          decoration: BoxDecoration(
            color: _C.white,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(
              color: (_counts[key] ?? 0) > 0 ? _C.accent : _C.border,
              width: (_counts[key] ?? 0) > 0 ? 1.5 : 1,
            ),
          ),
          child: TextField(
            controller: _controllers[key],
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: _C.text1,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: '0',
              hintStyle: TextStyle(color: _C.text3, fontSize: 12.sp),
              contentPadding: EdgeInsets.zero,
              isDense: true,
            ),
            onChanged: (v) => _onChanged(key, v),
          ),
        ),
        if ((_counts[key] ?? 0) > 0)
          Padding(
            padding: EdgeInsets.only(top: 2.h),
            child: Text(
              '₹${_counts[key]! * _values[key]!}',
              style: TextStyle(
                fontSize: 9.sp,
                color: _C.accent,
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
            fontSize: 13.sp,
            color: _C.text2,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          '₹${value.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 15.sp,
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
        color: _C.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              margin: EdgeInsets.only(top: 10.h),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: _C.border,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: _C.accent,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            ),
            child: Row(
              children: [
                Icon(Icons.payments_outlined, color: Colors.white, size: 20.sp),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    'Cash Breakdown',
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: EdgeInsets.all(6.r),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.close, color: Colors.white, size: 18.sp),
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                    decoration: BoxDecoration(
                      color: _C.accentLight,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Expected Amount',
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: _C.text2,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '₹${widget.expectedAmount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w900,
                            color: _C.accent,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    children: firstRow
                        .map(
                          (k) => Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 3.w),
                              child: _denomItem(k),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    children: secondRow
                        .map(
                          (k) => Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 3.w),
                              child: _denomItem(k),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  SizedBox(height: 16.h),
                  Container(
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: _C.bg,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: _C.border),
                    ),
                    child: Column(
                      children: [
                        _summaryLine(
                          'Total Received',
                          _totalReceived,
                          color: _C.green,
                        ),
                        if (_returnAmount > 0) ...[
                          SizedBox(height: 8.h),
                          Divider(color: _C.border, height: 1),
                          SizedBox(height: 8.h),
                          _summaryLine(
                            'Change to Return',
                            _returnAmount,
                            color: _C.orange,
                          ),
                        ],
                        if (!_canConfirm && _totalReceived > 0) ...[
                          SizedBox(height: 8.h),
                          Divider(color: _C.border, height: 1),
                          SizedBox(height: 8.h),
                          _summaryLine(
                            'Still Needed',
                            widget.expectedAmount - _totalReceived,
                            color: _C.red,
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
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
            decoration: BoxDecoration(
              color: _C.white,
              border: Border(top: BorderSide(color: _C.border)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 13.h),
                      decoration: BoxDecoration(
                        color: _C.bg,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: _C.border),
                      ),
                      child: Center(
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: _C.text2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
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
                      padding: EdgeInsets.symmetric(vertical: 13.h),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _canConfirm
                              ? [_C.green, const Color(0xFF27AE60)]
                              : [_C.text3, _C.text3],
                        ),
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: _canConfirm
                            ? [
                                BoxShadow(
                                  color: _C.green.withOpacity(0.35),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : [],
                      ),
                      child: Center(
                        child: _isSubmitting
                            ? SizedBox(
                                width: 18.w,
                                height: 18.w,
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
                                  fontSize: 13.sp,
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

// SPLIT PAYMENT BOTTOM SHEET

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
        backgroundColor: _C.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
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
          margin: EdgeInsets.only(right: id != 'Online_Payment' ? 8.w : 0),
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: isDisabled
                ? _C.bg
                : isSelected
                ? _C.accentLight
                : _C.bg,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(
              color: isDisabled
                  ? _C.border
                  : isSelected
                  ? _C.accent
                  : _C.border,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                m['icon'] as IconData,
                size: 16.sp,
                color: isDisabled
                    ? _C.text3
                    : isSelected
                    ? _C.accent
                    : _C.text2,
              ),
              SizedBox(height: 3.h),
              Text(
                m['label'] as String,
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                  color: isDisabled
                      ? _C.text3
                      : isSelected
                      ? _C.accent
                      : _C.text2,
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
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: _C.bg,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: _C.border),
      ),
      child: Row(
        children: [
          Container(
            width: 28.r,
            height: 28.r,
            decoration: BoxDecoration(
              color: _C.accentLight,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, size: 14.sp, color: _C.accent),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Row(
              children: [
                Text(
                  p['label'] as String,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: _C.text1,
                  ),
                ),
                if (hasDenom) ...[
                  SizedBox(width: 6.w),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 6.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: _C.greenLight,
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      'Breakdown',
                      style: TextStyle(
                        fontSize: 9.sp,
                        color: _C.green,
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
              fontSize: 14.sp,
              fontWeight: FontWeight.w800,
              color: _C.accent,
            ),
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: () => _removePayment(p['id'] as int),
            child: Container(
              width: 24.r,
              height: 24.r,
              decoration: BoxDecoration(
                color: _C.redLight,
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Icon(Icons.close_rounded, size: 12.sp, color: _C.red),
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
        color: _C.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              margin: EdgeInsets.only(top: 10.h),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: _C.border,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: _C.accent,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.call_split_rounded,
                  color: Colors.white,
                  size: 20.sp,
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    'Split Payment',
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: EdgeInsets.all(6.r),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.close, color: Colors.white, size: 18.sp),
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _amountCard('Total', widget.grandTotal, _C.text1),
                      SizedBox(width: 10.w),
                      _amountCard(
                        'Remaining',
                        _remaining,
                        _isBalanced ? _C.green : _C.red,
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Container(
                    height: 8.h,
                    decoration: BoxDecoration(
                      color: _C.border,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: FractionallySizedBox(
                      widthFactor: progress,
                      alignment: Alignment.centerLeft,
                      child: Container(
                        decoration: BoxDecoration(
                          color: _isBalanced ? _C.green : _C.accent,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₹${_allocated.toStringAsFixed(2)} allocated',
                        style: TextStyle(fontSize: 11.sp, color: _C.text2),
                      ),
                      Text(
                        _isBalanced
                            ? '✓ Balanced'
                            : '₹${_remaining.toStringAsFixed(2)} left',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          color: _isBalanced ? _C.green : _C.red,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Select Payment Method',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: _C.text1,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(children: _methods.map(_methodChip).toList()),
                  SizedBox(height: 12.h),
                  Container(
                    decoration: BoxDecoration(
                      color: _C.bg,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: _C.border),
                    ),
                    child: Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 14.w),
                          child: Text(
                            '₹',
                            style: TextStyle(fontSize: 16.sp, color: _C.text2),
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _amountCtrl,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700,
                              color: _C.text1,
                            ),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: _remaining > 0
                                  ? _remaining.toStringAsFixed(2)
                                  : '0.00',
                              hintStyle: TextStyle(
                                color: _C.text3,
                                fontSize: 14.sp,
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 14.h,
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
                            margin: EdgeInsets.only(right: 6.w),
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 5.h,
                            ),
                            decoration: BoxDecoration(
                              color: _C.accentLight,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text(
                              'Max',
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w700,
                                color: _C.accent,
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: _addPayment,
                          child: Container(
                            margin: EdgeInsets.only(right: 8.w),
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 12.h,
                            ),
                            decoration: BoxDecoration(
                              color: _C.accent,
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Text(
                              'Add',
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),
                  if (_payments.isEmpty)
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 24.h),
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 36.sp,
                            color: _C.text3,
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'No payments added yet',
                            style: TextStyle(fontSize: 13.sp, color: _C.text3),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Select a method and enter an amount above',
                            style: TextStyle(fontSize: 11.sp, color: _C.text3),
                          ),
                        ],
                      ),
                    )
                  else ...[
                    Padding(
                      padding: EdgeInsets.only(bottom: 6.h),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 4,
                            child: Text(
                              'Method',
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w700,
                                color: _C.text2,
                              ),
                            ),
                          ),
                          Text(
                            'Amount',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                              color: _C.text2,
                            ),
                          ),
                          SizedBox(width: 32.w),
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
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
            decoration: BoxDecoration(
              color: _C.white,
              border: Border(top: BorderSide(color: _C.border)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 13.h),
                      decoration: BoxDecoration(
                        color: _C.bg,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: _C.border),
                      ),
                      child: Center(
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: _C.text2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: _isBalanced ? _submit : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.symmetric(vertical: 13.h),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _isBalanced
                              ? [_C.accent, _C.accentDark]
                              : [_C.text3, _C.text3],
                        ),
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: _isBalanced
                            ? [
                                BoxShadow(
                                  color: _C.accent.withOpacity(0.35),
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
                            fontSize: 14.sp,
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
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                color: _C.text2,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              '₹${amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 16.sp,
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

// MAIN CART SCREEN

class food_CartScreen extends StatefulWidget {
  final int? cartId;

  const food_CartScreen({
    super.key,
    this.cartId,
    required double savedAmount,
    required bool showSavedPopup,
  });

  @override
  State<food_CartScreen> createState() => _food_cartScreenState();
}

class _food_cartScreenState extends State<food_CartScreen>
    with WidgetsBindingObserver {
  // ── State ───────────────────────────────────────────────────────────────────
  CartModel? cartData;
  bool isLoading = true;
  bool isPlacingOrder = false;
  String selectedPaymentMethod = '';
  bool isServiceChargeApplied = true;
  bool isExpanded = false;
  late Razorpay _razorpay;
  int? appliedCouponId;
  String? appliedCouponCode;
  String? _email;
  String? _mobile;
  OrderType selectedOrderType = OrderType.DINE_IN;
  bool _billingCash = true;
  bool _billingQrCode = true;
  bool _billingUpi = true;
  bool _billingSplitBilling = true;

  // ── Credit Points ──────────────────────────────────────────────────────────

  int? _availableCreditPoints;

  // Quantity update flags
  bool _isUpdating = false;
  final Map<int, bool> _itemLoadingMap = {};

  // QR
  bool _isGeneratingQr = false;
  String? _qrImageUrl;
  String? _qrOrderId;
  String? _qrPaymentId;
  bool _qrPaymentVerified = false;
  Timer? _qrPollingTimer;

  Map<int, int> _availableQuantities = {};

  // ── Helper getter ────────────────────────────────────────────────────────
  bool get _isCreditExhausted =>
      _availableCreditPoints != null && _availableCreditPoints == 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    _loadCart();
    _loadAvailableQuantities();
    Utils.itemCount.addListener(_onCartCountChanged);
    _loadBillingSettings();
    _loadCreditPoints();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadCart();
      _loadAvailableQuantities();
    }
  }

  void _onCartCountChanged() {
    if (!_isUpdating) {
      _loadCart();
      _loadAvailableQuantities();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    Utils.itemCount.removeListener(_onCartCountChanged);
    _razorpay.clear();
    _qrPollingTimer?.cancel();
    super.dispose();
  }

  // ── Load billing settings ────────────────────────────────────────────────
  Future<void> _loadBillingSettings() async {
    try {
      final vendorId = await _getVendorId();
      final response = await ApiClient.get(
        "api/billing/get/$vendorId",
        service: "food",
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _billingCash = data['cash'] ?? true;
            _billingQrCode = data['qrCode'] ?? true;
            _billingUpi = data['upi'] ?? true;
            _billingSplitBilling = data['splitBilling'] ?? true;
          });
        }
      }
    } catch (e) {
      debugPrint("❌ Error loading billing settings: $e");
    }
  }

  // ── Load credit points ────────────────────────────────────────────────────

  Future<void> _loadCreditPoints() async {
    try {
      final vendorId = await _getVendorId();
      final response = await ApiClient.get(
        "api/vendor/credit/$vendorId",
        service: "food",
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _availableCreditPoints = data['availableCreditPoints'] as int?;
          });
        }
      }
    } catch (e) {
      debugPrint("❌ Error loading credit points: $e");
    }
  }

  // ── Auth helpers ────────────────────────────────────────────────────────────
  Future<int> _getVendorId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('vendorId') ?? 0;
  }

  Future<Map<String, String>> _authHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionCookie =
        prefs.getString('sessionCookie') ?? prefs.getString('JSESSIONID') ?? '';
    final authToken =
        prefs.getString('authToken') ?? prefs.getString('token') ?? '';
    final vendorId = prefs.getInt('vendorId') ?? 0;
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': '*/*',
    };
    if (vendorId > 0) {
      headers['vendorId'] = vendorId.toString();
      headers['vendor-id'] = vendorId.toString();
    }
    if (sessionCookie.isNotEmpty) {
      headers['Cookie'] = sessionCookie;
    } else if (authToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $authToken';
    }
    return headers;
  }

  // ── Data loading ────────────────────────────────────────────────────────────
  Future<void> _loadAvailableQuantities() async {
    try {
      final dishes = await food_authservice.fetchDishes();
      if (mounted) {
        setState(() {
          for (var dish in dishes) {
            _availableQuantities[dish.dishId] = dish.balanceQuantity;
          }
        });
      }
    } catch (e) {
      debugPrint("❌ Error loading quantities: $e");
    }
  }

  Future<void> _loadCart() async {
    if (!_isUpdating && mounted) setState(() => isLoading = true);
    try {
      final fetched = await food_authservice.fetchCart();
      if (mounted) {
        setState(() {
          if (fetched != null) {
            cartData = CartModel(
              cartId: fetched.cartId,
              vendorId: fetched.vendorId,
              orderType: fetched.orderType,
              cartItems: fetched.cartItems
                  .map(
                    (item) => CartItem(
                      itemId: item.itemId,
                      price: item.price,
                      dishName: item.dishName,
                      dishId: item.dishId,
                      gst: item.gst,
                      packingCharges: item.packingCharges,
                      quantity: item.quantity,
                      chefType: item.chefType,
                      totalPrice: item.price * item.quantity,
                      orderType: item.orderType,
                      dishImage: item.dishImage,
                    ),
                  )
                  .toList(),
              subtotal: fetched.subtotal,
              gstTotal: fetched.gstTotal,
              platformCharges: fetched.platformCharges,
              grandTotal: fetched.grandTotal,
              packingTotal: fetched.packingTotal,
              serviceCharges: fetched.serviceCharges,
              deliveryCharges: fetched.deliveryCharges,
              cgst: fetched.cgst,
              sgst: fetched.sgst,
              seatingId: fetched.seatingId,
              tableCode: fetched.tableCode,
              orderStatus: fetched.orderStatus,
            );
          } else {
            cartData = null;
          }
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("❌ Error loading cart: $e");
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<bool> _callUpdateCartApi({
    required int cartId,
    required int dishId,
    required int quantity,
  }) async {
    try {
      final vendorId = await _getVendorId();
      final response = await ApiClient.put(
        "api/cart/update/cart/$vendorId/$cartId?dishId=$dishId&quantity=$quantity",
        {},
        service: "food",
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      debugPrint("❌ PUT cart update error: $e");
      return false;
    }
  }

  // ── Update quantity ──────────────────────────────────────────────────────────
  Future<void> _updateQuantity(CartItem item, int newQuantity) async {
    if (_isUpdating) return;
    final available = _availableQuantities[item.dishId] ?? 0;
    if (newQuantity > available && available > 0) {
      _snack('Only $available items available', _C.red);
      return;
    }
    final oldQuantity = item.quantity;
    _isUpdating = true;
    _itemLoadingMap[item.itemId] = true;
    setState(() {});
    try {
      if (newQuantity < 1) {
        final removed = await food_authservice.removeCartItem(item.itemId);
        if (removed) {
          Utils.itemCount.value = (Utils.itemCount.value - 1).clamp(0, 999);
          await _loadCart();
          await _loadAvailableQuantities();
        } else {
          _snack('Failed to remove item', _C.red);
        }
      } else {
        final success = await _callUpdateCartApi(
          cartId: cartData!.cartId,
          dishId: item.dishId,
          quantity: newQuantity,
        );
        if (success) {
          setState(() {
            item.quantity = newQuantity;
            item.totalPrice = item.price * newQuantity;
          });
          final diff = newQuantity - oldQuantity;
          if (diff != 0) {
            Utils.itemCount.value = (Utils.itemCount.value + diff).clamp(
              0,
              999,
            );
          }
          await _loadCart();
          await _loadAvailableQuantities();
        } else {
          _snack('Failed to update quantity', _C.red);
          setState(() {
            item.quantity = oldQuantity;
            item.totalPrice = item.price * oldQuantity;
          });
        }
      }
    } catch (e) {
      debugPrint('❌ _updateQuantity error: $e');
      _snack('Error updating item', _C.red);
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
          _itemLoadingMap[item.itemId] = false;
        });
      }
    }
  }

  // ── Razorpay payment handlers ────────────────────────────────────────────────
  void _handlePaymentSuccess(PaymentSuccessResponse res) async {
    final prefs = await SharedPreferences.getInstance();
    final vendorId = prefs.getInt('vendorId') ?? 0;
    final captured = await food_authservice.capturePayment(
      paymentId: res.paymentId!,
      amount: (cartData?.grandTotal ?? 0).toDouble(),
    );
    if (!captured) {
      _snack('Payment capture failed', _C.red);
      return;
    }
    final orderId = await _callOrderApi(
      vendorId: vendorId,
      paymentMethod: 'Online_Payment',
      razorpayPaymentId: res.paymentId!,
      razorpayOrderId: res.orderId!,
    );
    if (orderId != null && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => food_Invoice(orderId: orderId)),
      );
    }
  }

  void _handlePaymentError(PaymentFailureResponse res) =>
      _snack('Payment failed: ${res.message}', _C.red);

  void _handleExternalWallet(ExternalWalletResponse res) {}

  // ── QR helpers ──────────────────────────────────────────────────────────────
  Future<void> _generateDynamicQr() async {
    if (cartData == null) return;
    setState(() {
      _isGeneratingQr = true;
      _qrImageUrl = null;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final vendorId = prefs.getInt('vendorId') ?? 0;
      final phone = prefs.getString('phone') ?? '9876543210';
      final uniqueOrderId =
          'ORD${DateTime.now().millisecondsSinceEpoch}${cartData!.cartId}';
      final response = await ApiClient.post("api/payments/create/qr", {
        'amount': cartData!.grandTotal,
        'cartId': cartData!.cartId,
        'vendorId': vendorId,
        'phone': phone,
        'orderId': uniqueOrderId,
      }, service: "food");
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _qrImageUrl = data['image_url']?.toString();
          _qrOrderId = uniqueOrderId;
          _qrPaymentId = data['id']?.toString();
          selectedPaymentMethod = 'QR_Payment';
        });
        _startQrPolling();
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) _showQrDialog();
        });
      } else {
        _snack("QR generation failed: ${response.statusCode}", _C.red);
      }
    } catch (e) {
      _snack('Failed to generate QR: $e', _C.red);
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
        insetPadding: EdgeInsets.all(16.w),
        child: Container(
          decoration: BoxDecoration(
            color: _C.white,
            borderRadius: BorderRadius.circular(24.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: _C.accentDark,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(24.r),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Scan & Pay',
                      style: TextStyle(
                        fontSize: 18.sp,
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
                        padding: EdgeInsets.all(6.r),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 18.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.currency_rupee,
                          color: _C.green,
                          size: 22.sp,
                        ),
                        Text(
                          '${cartData?.grandTotal ?? 0}',
                          style: TextStyle(
                            fontSize: 28.sp,
                            fontWeight: FontWeight.w900,
                            color: _C.green,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    Builder(
                      builder: (context) {
                        final qrSize = MediaQuery.of(context).size.width * 0.75;
                        return Container(
                          width: qrSize,
                          height: qrSize,
                          decoration: BoxDecoration(
                            border: Border.all(color: _C.border, width: 2),
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14.r),
                            child: _qrImageUrl != null
                                ? Image.network(_qrImageUrl!, fit: BoxFit.cover)
                                : Center(
                                    child: CircularProgressIndicator(
                                      color: _C.accent,
                                      strokeWidth: 3,
                                    ),
                                  ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'Scan using any UPI app',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: _C.text2,
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
    if (cartData == null || _qrPaymentId == null) return;
    try {
      final response = await ApiClient.get(
        "api/orders/order/check/status",
        service: "food",
        queryParams: {"cartId": cartData!.cartId.toString()},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final status = (data['status'] ?? data['paymentStatus'] ?? 'pending')
            .toString()
            .toLowerCase();
        if (status.contains('success') ||
            status.contains('paid') ||
            status.contains('completed')) {
          timer.cancel();
          setState(() => _qrPaymentVerified = true);
          if (mounted && Navigator.of(context).canPop()) {
            Navigator.pop(context);
          }
          await _completeQrOrder();
        }
      }
    } catch (e) {
      debugPrint('❌ QR poll error: $e');
    }
  }

  Future<void> _completeQrOrder() async {
    setState(() => isPlacingOrder = true);
    try {
      final vendorId = await _getVendorId();
      final orderId = await _callOrderApi(
        vendorId: vendorId,
        paymentMethod: 'QR_Payment',
        razorpayPaymentId: _qrPaymentId ?? _qrOrderId!,
        razorpayOrderId: _qrOrderId!,
      );
      _clearCart();
      if (orderId != null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => food_Invoice(orderId: orderId)),
        );
      }
    } finally {
      if (mounted) setState(() => isPlacingOrder = false);
    }
  }

  // ── Cash billing API ──────────────────────────────────────────────────────────
  Future<void> _callAddCashBillingApi({
    required int orderId,
    required Map<String, dynamic> cashEntry,
  }) async {
    try {
      final denomData = cashEntry['denominationData'] as Map<String, dynamic>?;
      if (denomData == null) return;

      final vendorId = await _getVendorId();
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

      final response = await ApiClient.post(
        'api/cash-billing/addCash/$orderId',
        payload,
        service: 'food',
      );
      debugPrint('💰 Cash billing: ${response.statusCode} ${response.body}');
    } catch (e) {
      debugPrint('❌ _callAddCashBillingApi error: $e');
    }
  }

  // ── Main payment handler ─────────────────────────────────────────────────────
  Future<void> _handlePaymentSelected(
    String paymentMethod,
    List<Map<String, dynamic>>? splitPaymentsArg,
  ) async {
    if (cartData == null || cartData!.cartId == 0) {
      await _loadCart();
      if (cartData == null) {
        _snack('Cart is empty', _C.red);
        return;
      }
    }

    setState(() => isPlacingOrder = true);

    try {
      if (paymentMethod == 'QR_Payment') {
        await _generateDynamicQr();
        setState(() => isPlacingOrder = false);
        return;
      }

      if (paymentMethod == 'Online_Payment') {
        final amount = (cartData?.grandTotal ?? 0).toDouble();
        final orderId = await food_authservice.createOrder(amount);
        if (orderId == null) {
          _snack('Failed to create Razorpay order', _C.red);
          return;
        }
        _openRazorpay(amount, orderId);
        return;
      }

      final vendorId = await _getVendorId();

      if (paymentMethod == 'MULTIPLE') {
        final cashPaymentData = (splitPaymentsArg ?? [])
            .map(
              (p) => {
                'method': p['method'],
                'amount': (p['amount'] as num).toDouble(),
              },
            )
            .toList();

        final orderId = await _callOrderApi(
          vendorId: vendorId,
          paymentMethod: 'MULTIPLE',
          razorpayPaymentId: '',
          razorpayOrderId: '',
          cashPaymentData: cashPaymentData,
        );

        if (orderId != null) {
          final cashEntries = (splitPaymentsArg ?? [])
              .where((p) => p['method'] == 'Cash')
              .toList();
          for (final entry in cashEntries) {
            await _callAddCashBillingApi(orderId: orderId, cashEntry: entry);
          }
        }

        if (orderId != null && mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => food_Invoice(orderId: orderId)),
          );
        }
        return;
      }

      if (paymentMethod == 'Cash') {
        final orderId = await _callOrderApi(
          vendorId: vendorId,
          paymentMethod: 'Cash',
          razorpayPaymentId: '',
          razorpayOrderId: '',
        );
        if (orderId != null) {
          final cashEntry = splitPaymentsArg?.firstOrNull;
          if (cashEntry != null) {
            await _callAddCashBillingApi(
              orderId: orderId,
              cashEntry: cashEntry,
            );
          }
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => food_Invoice(orderId: orderId)),
            );
          }
        }
        return;
      }

      final orderId = await _callOrderApi(
        vendorId: vendorId,
        paymentMethod: paymentMethod,
        razorpayPaymentId: '',
        razorpayOrderId: '',
      );
      if (orderId != null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => food_Invoice(orderId: orderId)),
        );
      }
    } catch (e) {
      _snack('Error placing order: $e', _C.red);
    } finally {
      if (mounted) setState(() => isPlacingOrder = false);
    }
  }

  void _openRazorpay(double amount, String orderId) {
    try {
      _razorpay.open({
        'key': 'rzp_live_TJDvykibQEsCuN',
        'order_id': orderId,
        'amount': (amount * 100).toInt(),
        'name': 'Order Payment',
        'description': 'Online Payment via Razorpay',
        'prefill': {
          'contact': _mobile ?? '9999999999',
          'email': _email ?? 'customer@email.com',
        },
        'theme': {'color': '#E66D33'},
      });
    } catch (e) {
      debugPrint('Razorpay error: $e');
    }
  }

  Future<int?> _callOrderApi({
    required int vendorId,
    required String paymentMethod,
    required String razorpayPaymentId,
    required String razorpayOrderId,
    List<Map<String, dynamic>>? cashPaymentData,
  }) async {
    try {
      await _loadCart();
      if (cartData == null || cartData!.cartId == 0) {
        _snack('Cart is empty', _C.red);
        return null;
      }
      final result = await food_authservice.placeDirectOrder(
        vendorId: vendorId,
        cartId: cartData!.cartId,
        paymentMethod: paymentMethod,
        razorpayPaymentId: razorpayPaymentId,
        razorpayOrderId: razorpayOrderId,
        cashPaymentData: cashPaymentData,
      );
      if (result != null && result.containsKey('orderId')) {
        final orderId = result['orderId'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('orderId', orderId);
        _clearCart();
        return orderId;
      }
      _snack('Failed to place order', _C.red);
      return null;
    } catch (e) {
      _snack('Error: $e', _C.red);
      return null;
    }
  }

  void _clearCart() {
    setState(() => cartData = null);
    Utils.itemCount.value = 0;
  }

  void _snack(String msg, Color color) {
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
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // BUILD
  // ════════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    return Scaffold(
      backgroundColor: _C.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: _C.accent,
                        strokeWidth: 2,
                      ),
                    )
                  : (cartData == null || cartData!.cartItems.isEmpty)
                  ? _buildEmptyCart()
                  : _buildBody(),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 8.w, 12.h),
      decoration: BoxDecoration(
        color: _C.white,
        border: Border(bottom: BorderSide(color: _C.border)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36.r,
              height: 36.r,
              decoration: BoxDecoration(
                color: _C.bg,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: _C.border),
              ),
              child: Icon(
                Icons.arrow_back_ios_rounded,
                color: _C.text1,
                size: 15.sp,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Cart',
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w800,
                    color: _C.text1,
                    letterSpacing: -0.3,
                  ),
                ),
                if (cartData != null)
                  Text(
                    '${cartData!.cartItems.fold(0, (s, i) => s + i.quantity)} items',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: _C.text2,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
          if (cartData != null)
            GestureDetector(
              onTap: _confirmClearCart,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: _C.redLight,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: _C.red.withOpacity(0.3)),
                ),
                child: Text(
                  'Clear Cart',
                  style: TextStyle(
                    color: _C.red,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _confirmClearCart() async {
    if (cartData == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: const Text('Clear Cart?'),
        content: const Text('All items will be removed from your cart.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Clear', style: TextStyle(color: _C.red)),
          ),
        ],
      ),
    );
    if (ok == true) {
      final success = await food_authservice.deleteCart(cartData!.cartId);
      if (success) {
        _clearCart();
        _snack('Cart cleared', _C.green);
      }
    }
  }

  // ── Body ────────────────────────────────────────────────────────────────────
  Widget _buildBody() {
    return RefreshIndicator(
      color: _C.accent,
      onRefresh: () async {
        await _loadCart();
        await _loadAvailableQuantities();
        await _loadCreditPoints(); // also refresh credit points on pull-to-refresh
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 32.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCartItemsCard(),
            SizedBox(height: 12.h),
            _buildAddMoreRow(),
            SizedBox(height: 12.h),
            _buildSummaryCard(),
            SizedBox(height: 12.h),
            _buildPaymentToggleBtn(),
            if (isExpanded) ...[SizedBox(height: 12.h), _buildPaymentSection()],
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  // ── Cart Items Card ──────────────────────────────────────────────────────────
  Widget _buildCartItemsCard() {
    return Container(
      decoration: BoxDecoration(
        color: _C.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: _C.border),
        boxShadow: [
          BoxShadow(
            color: _C.shadow,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          children: cartData!.cartItems.map((item) {
            final isLast = item == cartData!.cartItems.last;
            return Column(
              key: ValueKey(item.itemId),
              children: [
                _buildCartItem(item),
                if (!isLast) Divider(height: 1, color: _C.border),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCartItem(CartItem item) {
    final isItemLoading = _itemLoadingMap[item.itemId] == true;
    final available = _availableQuantities[item.dishId] ?? 0;
    final canIncrease = item.quantity < available;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              item.dishName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: _C.text1,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          _buildQtyControl(
            item: item,
            isLoading: isItemLoading,
            canIncrease: canIncrease,
            available: available,
          ),
          SizedBox(width: 12.w),
          SizedBox(
            width: 80.w,
            child: Text(
              '₹${item.totalPrice.toStringAsFixed(2)}',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: _C.accent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQtyControl({
    required CartItem item,
    required bool isLoading,
    required bool canIncrease,
    required int available,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _C.bg,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: _C.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _qtyBtn(
            icon: item.quantity == 1
                ? Icons.delete_outline_rounded
                : Icons.remove_rounded,
            color: _C.red,
            onTap: _isUpdating
                ? null
                : () => _updateQuantity(
                    item,
                    item.quantity > 1 ? item.quantity - 1 : 0,
                  ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: isLoading
                ? SizedBox(
                    width: 14.w,
                    height: 14.w,
                    child: CircularProgressIndicator(
                      color: _C.accent,
                      strokeWidth: 1.5,
                    ),
                  )
                : Text(
                    '${item.quantity}',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: _C.text1,
                    ),
                  ),
          ),
          _qtyBtn(
            icon: Icons.add_rounded,
            color: canIncrease ? _C.green : _C.text3,
            onTap: _isUpdating
                ? null
                : canIncrease
                ? () => _updateQuantity(item, item.quantity + 1)
                : () => _snack(
                    available <= 0
                        ? 'Item is out of stock'
                        : 'Only $available available',
                    _C.orange,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _qtyBtn({
    required IconData icon,
    required Color color,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(6.w),
        decoration: BoxDecoration(
          color: (onTap == null ? _C.text3 : color).withOpacity(0.10),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(icon, size: 14.sp, color: onTap == null ? _C.text3 : color),
      ),
    );
  }

  // ── Add More ────────────────────────────────────────────────────────────────
  Widget _buildAddMoreRow() {
    return Center(
      child: GestureDetector(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => Menu_Managemnet()),
          );
          _loadCart();
          _loadAvailableQuantities();
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: _C.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: _C.accent.withOpacity(0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.add_circle_outline_rounded,
                color: _C.accent,
                size: 16.sp,
              ),
              SizedBox(width: 8.w),
              RichText(
                text: TextSpan(
                  text: 'Missed something? ',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: _C.text2,
                    fontWeight: FontWeight.w500,
                  ),
                  children: [
                    TextSpan(
                      text: 'Add more items',
                      style: TextStyle(
                        color: _C.accent,
                        fontWeight: FontWeight.w700,
                        decoration: TextDecoration.underline,
                        decorationColor: _C.accent,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Summary Card ─────────────────────────────────────────────────────────────
  Widget _buildSummaryCard() {
    if (cartData == null) return const SizedBox.shrink();
    final hasDineIn = cartData!.cartItems.any((i) => i.orderType == 'DINE_IN');
    final hasTakeaway = cartData!.cartItems.any(
      (i) => i.orderType == 'TAKEAWAY',
    );

    return Container(
      decoration: BoxDecoration(
        color: _C.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: _C.border),
        boxShadow: [
          BoxShadow(
            color: _C.shadow,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 12.h),
            child: Row(
              children: [
                Container(
                  width: 28.r,
                  height: 28.r,
                  decoration: BoxDecoration(
                    color: _C.accentLight,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.receipt_long_outlined,
                    color: _C.accent,
                    size: 14.sp,
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  'Order Summary',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: _C.text1,
                  ),
                ),
              ],
            ),
          ),
          Divider(color: _C.border, height: 1),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 14.h),
            child: Column(
              children: [
                // _summaryRow('Sub Total', cartData?.subtotal ?? 0),
                // if (hasTakeaway)
                //   _summaryRow('Packing Charges', cartData?.packingTotal ?? 0),
                // if (hasDineIn) _serviceChargeRow(),
                // _summaryRow('SGST', (cartData?.gstTotal ?? 0) / 2),
                // _summaryRow('CGST', (cartData?.gstTotal ?? 0) / 2),
                _summaryRow('Sub Total', cartData?.subtotal ?? 0),

                if (hasTakeaway && (cartData?.packingTotal ?? 0) > 0)
                  _summaryRow('Packing Charges', cartData?.packingTotal ?? 0),

                if (hasDineIn && (cartData?.serviceCharges ?? 0) > 0)
                  _serviceChargeRow(),

                if (((cartData?.gstTotal ?? 0) / 2) > 0)
                  _summaryRow('SGST', (cartData?.gstTotal ?? 0) / 2),

                if (((cartData?.gstTotal ?? 0) / 2) > 0)
                  _summaryRow('CGST', (cartData?.gstTotal ?? 0) / 2),
                SizedBox(height: 8.h),
                Divider(color: _C.border),
                SizedBox(height: 6.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Grand Total',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                        color: _C.text1,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [_C.accent, _C.accentDark],
                        ),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Text(
                        '₹${cartData?.grandTotal ?? 0}',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
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
    );
  }

  Widget _summaryRow(String label, num value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              color: _C.text2,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            '₹${value.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 13.sp,
              color: _C.text1,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _serviceChargeRow() {
    final sc = cartData?.serviceCharges ?? 0.0;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Service Charges',
            style: TextStyle(
              fontSize: 13.sp,
              color: _C.text2,
              fontWeight: FontWeight.w500,
            ),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () async {
                  if (cartData?.cartId == null) return;
                  await food_authservice.updateServiceCharges(
                    cartId: cartData!.cartId,
                    serviceCharge: isServiceChargeApplied
                        ? 'NOT_APPLICABLE'
                        : 'APPLICABLE',
                  );
                  setState(
                    () => isServiceChargeApplied = !isServiceChargeApplied,
                  );
                  await _loadCart();
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: isServiceChargeApplied
                        ? _C.redLight
                        : _C.accentLight,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    isServiceChargeApplied ? 'Remove' : 'Apply',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      color: _C.accent,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                '₹${sc.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: _C.text1,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Payment Toggle Button ────────────────────────────────────────────────────
  Widget _buildPaymentToggleBtn() {
    return GestureDetector(
      onTap: () => setState(() => isExpanded = !isExpanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 14.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isExpanded
                ? [_C.text2, _C.text1]
                : [_C.accent, _C.accentDark],
          ),
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
              color: (isExpanded ? _C.text2 : _C.accent).withOpacity(0.35),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isExpanded
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.payment_rounded,
              color: Colors.white,
              size: 20.sp,
            ),
            SizedBox(width: 8.w),
            Text(
              isExpanded ? 'Hide Payment Options' : 'Proceed to Payment',
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Payment Section ─────────────────────────────────────────────────────────
  Widget _buildPaymentSection() {
    final orderType = cartData?.orderType ?? 'DINE_IN';

    return Container(
      decoration: BoxDecoration(
        color: _C.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: _C.border),
        boxShadow: [
          BoxShadow(
            color: _C.shadow,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Header ──
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 12.h),
            child: Row(
              children: [
                Container(
                  width: 28.r,
                  height: 28.r,
                  decoration: BoxDecoration(
                    color: _C.accentLight,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.payment_outlined,
                    color: _C.accent,
                    size: 14.sp,
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  'Payment Method',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: _C.text1,
                  ),
                ),
              ],
            ),
          ),
          Divider(color: _C.border, height: 1),

          Padding(
            padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 12.h),
            child: Column(
              children: [
                // ── Credit Exhausted Banner ────────────────────────────────
                // Shown only when availableCreditPoints == 0 (not null)
                if (_isCreditExhausted) ...[
                  Container(
                    margin: EdgeInsets.only(bottom: 10.h),
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 10.h,
                    ),
                    decoration: BoxDecoration(
                      color: _C.redLight,
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: _C.red.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: _C.red,
                          size: 16.sp,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            'Cash & UPI are disabled — available credit points are 0.',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: _C.red,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // ── Cash ──────────────────────────────────────────────────
                // Hidden when orderType is DELIVERY.
                if (orderType != 'DELIVERY' && _billingCash)
                  _buildPaymentOption(
                    label: 'Cash',
                    icon: Icons.payments_outlined,
                    value: 'Cash',
                    isDisabled: _isCreditExhausted,
                    onTap: _isCreditExhausted
                        ? () => _snack(
                            'Cash payment unavailable: no credit points remaining',
                            _C.orange,
                          )
                        : () => _onPaymentOptionTap('Cash'),
                  ),

                // ── UPI ───────────────────────────────────────────────────
                if (_billingUpi)
                  _buildPaymentOption(
                    label: 'UPI',
                    icon: Icons.phone_android_outlined,
                    value: 'UPI',
                    isDisabled: _isCreditExhausted,
                    onTap: _isCreditExhausted
                        ? () => _snack(
                            'UPI payment unavailable: no credit points remaining',
                            _C.orange,
                          )
                        : () => _onPaymentOptionTap('UPI'),
                  ),

                // ── QR Code Payment ───────────────────────────────────────
                if (_billingQrCode)
                  _buildPaymentOption(
                    label: 'QR Code Payment',
                    icon: Icons.qr_code_2_outlined,
                    value: 'QR_Payment',
                    onTap: () => _onPaymentOptionTap('QR_Payment'),
                    trailing:
                        (_isGeneratingQr &&
                            selectedPaymentMethod == 'QR_Payment')
                        ? SizedBox(
                            width: 18.w,
                            height: 18.w,
                            child: CircularProgressIndicator(
                              color: _C.accent,
                              strokeWidth: 2,
                            ),
                          )
                        : null,
                  ),

                // ── Split Payment ─────────────────────────────────────────
                // // Always available regardless of credit points.
                // if (_billingSplitBilling)
                //   _buildPaymentOption(
                //     label: 'Split Payment',
                //     icon: Icons.call_split_rounded,
                //     value: 'MULTIPLE',
                //     onTap: _openSplitPaymentSheet,
                //     trailing: Icon(
                //       Icons.arrow_forward_ios_rounded,
                //       size: 13.sp,
                //       color: _C.text2,
                //     ),
                //   ),
                if (_billingSplitBilling)
                  _buildPaymentOption(
                    label: 'Split Payment',
                    icon: Icons.call_split_rounded,
                    value: 'MULTIPLE',
                    isDisabled: _isCreditExhausted,
                    onTap: _isCreditExhausted
                        ? () => _snack(
                            'Split payment unavailable: no credit points remaining',
                            _C.orange,
                          )
                        : _openSplitPaymentSheet,
                    trailing: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 13.sp,
                      color: _isCreditExhausted ? _C.text3 : _C.text2,
                    ),
                  ),
                // ── No payment methods at all ──────────────────────────────
                if (!_billingCash &&
                    !_billingUpi &&
                    !_billingQrCode &&
                    !_billingSplitBilling)
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 20.h),
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        Icon(
                          Icons.payment_outlined,
                          size: 32.sp,
                          color: _C.text3,
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'No payment methods available',
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: _C.text3,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                SizedBox(height: 12.h),

                // ── Place Order Button ─────────────────────────────────────
                _buildPlaceOrderBtn(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onPaymentOptionTap(String value) {
    setState(() => selectedPaymentMethod = value);
    if (value == 'QR_Payment') _generateDynamicQr();
  }

  void _openCashDenomSheet() {
    final total = (cartData?.grandTotal ?? 0).toDouble();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: _CashDenominationSheet(
          expectedAmount: total,
          onConfirm: (denomData) {
            _handlePaymentSelected('Cash', [
              {
                'method': 'Cash',
                'amount': total,
                'denominationData': denomData,
              },
            ]);
          },
        ),
      ),
    );
  }

  void _openSplitPaymentSheet() {
    final total = (cartData?.grandTotal ?? 0).toDouble();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: _SplitPaymentSheet(
          grandTotal: total,
          onSubmit: (payments, hasQr) {
            setState(() => selectedPaymentMethod = 'MULTIPLE');
            _handlePaymentSelected('MULTIPLE', payments);
          },
        ),
      ),
    );
  }

  // ── Payment Option Tile ──────────────────────────────────────────────────────
  /// [isDisabled] greys out the tile visually and shows a block icon.
  /// The [onTap] callback is still fired (so we can show the snack message),
  /// but the tile won't be selectable.
  Widget _buildPaymentOption({
    required String label,
    required IconData icon,
    required String value,
    required VoidCallback onTap,
    Widget? trailing,
    bool isDisabled = false,
  }) {
    // A disabled tile must never appear "selected"
    final isSelected = !isDisabled && selectedPaymentMethod == value;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: isDisabled
              ? _C.bg
              : isSelected
              ? _C.accentLight
              : _C.bg,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isDisabled
                ? _C.border
                : isSelected
                ? _C.accent
                : _C.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // Icon container
            Container(
              width: 36.r,
              height: 36.r,
              decoration: BoxDecoration(
                color: isDisabled
                    ? _C.border
                    : isSelected
                    ? _C.accent
                    : _C.white,
                borderRadius: BorderRadius.circular(10.r),
                border: (isDisabled || isSelected)
                    ? null
                    : Border.all(color: _C.border),
              ),
              child: Icon(
                icon,
                color: isDisabled
                    ? _C.text3
                    : isSelected
                    ? Colors.white
                    : _C.text2,
                size: 18.sp,
              ),
            ),
            SizedBox(width: 12.w),
            // Label
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: isDisabled
                      ? _C.text3
                      : isSelected
                      ? _C.accent
                      : _C.text1,
                ),
              ),
            ),
            // Trailing widget
            if (isDisabled)
              // Block icon signals unavailability
              Icon(Icons.block_rounded, size: 16.sp, color: _C.text3)
            else if (trailing != null)
              trailing
            else if (isSelected)
              Container(
                width: 20.r,
                height: 20.r,
                decoration: BoxDecoration(
                  color: _C.accent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 13.sp,
                ),
              )
            else
              Container(
                width: 20.r,
                height: 20.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: _C.border, width: 1.5),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── Place Order Button ───────────────────────────────────────────────────────
  Widget _buildPlaceOrderBtn() {
    final canPlace =
        selectedPaymentMethod.isNotEmpty && selectedPaymentMethod != 'MULTIPLE';

    return GestureDetector(
      onTap: (isPlacingOrder || !canPlace)
          ? null
          : () {
              if (selectedPaymentMethod == 'Cash') {
                _openCashDenomSheet();
              } else {
                _handlePaymentSelected(selectedPaymentMethod, null);
              }
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 15.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: (isPlacingOrder || !canPlace)
                ? [_C.text3, _C.text3]
                : [_C.accent, _C.accentDark],
          ),
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: (isPlacingOrder || !canPlace)
              ? []
              : [
                  BoxShadow(
                    color: _C.accent.withOpacity(0.4),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: isPlacingOrder
            ? Center(
                child: SizedBox(
                  width: 22.w,
                  height: 22.w,
                  child: const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline_rounded,
                    color: Colors.white,
                    size: 18.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Place Order',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      '₹${(cartData?.grandTotal ?? 0).toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // ── Empty Cart ───────────────────────────────────────────────────────────────
  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 90.r,
            height: 90.r,
            decoration: BoxDecoration(
              color: _C.accentLight,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_cart_outlined,
              size: 40.sp,
              color: _C.accent,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: _C.text1,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Add some delicious items',
            style: TextStyle(fontSize: 13.sp, color: _C.text2),
          ),
          SizedBox(height: 24.h),
          GestureDetector(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => Menu_Managemnet()),
              );
              _loadCart();
              _loadAvailableQuantities();
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 13.h),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_C.accent, _C.accentDark],
                ),
                borderRadius: BorderRadius.circular(14.r),
                boxShadow: [
                  BoxShadow(
                    color: _C.accent.withOpacity(0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.restaurant_menu_rounded,
                    color: Colors.white,
                    size: 16.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Browse Menu',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Dish image ───────────────────────────────────────────────────────────────
  Widget _buildDishImage(String? url) {
    if (url == null || url.isEmpty) {
      return Icon(Icons.fastfood_rounded, size: 30.sp, color: _C.text3);
    }
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) =>
          Icon(Icons.broken_image_outlined, size: 30.sp, color: _C.text3),
      loadingBuilder: (_, child, prog) {
        if (prog == null) return child;
        return Center(
          child: SizedBox(
            width: 20.w,
            height: 20.w,
            child: CircularProgressIndicator(
              color: _C.accent,
              strokeWidth: 1.5,
            ),
          ),
        );
      },
    );
  }
}
