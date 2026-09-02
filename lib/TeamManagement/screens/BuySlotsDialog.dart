import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../models/employee.dart';
import '../services/api_service.dart';
import '../widgets/theme.dart';

const _kW = Color(0xFFFFFFFF);
const _kBg = Color(0xFFF7F8FC);
const _kBrd = Color(0xFFEEEFF5);
const _kP = Color(0xFFE66D33);
const _kPDk = Color(0xFFCC5A20);
const _kT1 = Color(0xFF111827);
const _kT2 = Color(0xFF6B7280);
const _kDng = Color(0xFFEF4444);
const _kGrd = LinearGradient(
  colors: [_kP, _kPDk],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);


class BuySlotsDialog extends StatefulWidget {
  final EmployeeSlotSummary summary;
  final VoidCallback onPurchased;
  const BuySlotsDialog({
    super.key,
    required this.summary,
    required this.onPurchased,
  });

  @override
  State<BuySlotsDialog> createState() => _BuySlotsDialogState();
}

class _BuySlotsDialogState extends State<BuySlotsDialog> {
  late Razorpay _razorpay;
  int _slots = 1;
  bool _processing = false;
  String? _pendingOrderId;

  double get _pricePerSlot => widget.summary.slotPrice;
  double get _total => _slots * _pricePerSlot;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onPaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _onPaymentError);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  Future<void> _pay() async {
    setState(() => _processing = true);
    try {
      final orderId = await PaymentApi.createRazorpayOrder(_total);
      if (orderId == null) {
        throw Exception('Could not create payment order. Please try again.');
      }
      _pendingOrderId = orderId;

      _razorpay.open({
        'key': 'rzp_test_TJECsclCivENpY',
        'amount': (_total * 100).toInt(), // Razorpay expects paise
        'currency': 'INR',
        'order_id': orderId,
        'name': 'Maamaas',
        'description': 'Purchase $_slots Employee Slot(s)',
        'theme': {'color': '#E66D33'},
      });
    } catch (e) {
      if (mounted) {
        setState(() => _processing = false);
        showError(context, e.toString().replaceAll('Exception: ', ''));
      }
    }
  }

  Future<void> _onPaymentSuccess(PaymentSuccessResponse response) async {
    try {
      await EmployeeSlotApi.purchaseSlots(
        slotsPurchased: _slots,
        pricePerSlot: _pricePerSlot,
        paymentId: response.paymentId ?? '',
        orderId: response.orderId ?? _pendingOrderId ?? '',
        paymentStatus: 'success',
      );
      if (mounted) {
        showSuccess(context, '$_slots slot(s) purchased successfully!');
        widget.onPurchased();
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted)
        showError(context, e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  void _onPaymentError(PaymentFailureResponse response) {
    if (mounted) {
      setState(() => _processing = false);
      showError(context, response.message ?? 'Payment failed. Please retry.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.summary;
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: _kW,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header ─────────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              decoration: const BoxDecoration(
                gradient: _kGrd,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.shopping_cart_rounded, color: _kW, size: 20),
                  SizedBox(width: 10),
                  Text(
                    'Purchase Employee Slots',
                    style: TextStyle(
                      color: _kW,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Row('Free Employee Limit:', '${s.freeLimit}'),
                  const SizedBox(height: 8),
                  _Row('Already Purchased:', '${s.purchasedSlots}'),
                  const SizedBox(height: 8),
                  _Row('Total Available:', '${s.totalAvailable}'),
                  const SizedBox(height: 8),
                  _Row('Current Employees:', '${s.currentEmployees}'),
                  const SizedBox(height: 8),
                  _Row(
                    'Remaining Slots:',
                    '${s.remainingSlots}',
                    valueColor: s.remainingSlots == 0 ? _kDng : _kT1,
                  ),
                  const SizedBox(height: 8),
                  _Row(
                    'Price per Slot:',
                    '₹${_pricePerSlot.toStringAsFixed(0)}',
                    valueColor: _kP,
                  ),
                  const SizedBox(height: 18),

                  const Text(
                    'Select Number of Slots:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _kT2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _StepBtn(
                        icon: Icons.remove_rounded,
                        onTap: _slots > 1
                            ? () => setState(() => _slots--)
                            : null,
                      ),
                      Expanded(
                        child: Container(
                          alignment: Alignment.center,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            border: Border.all(color: _kBrd),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$_slots',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: _kT1,
                            ),
                          ),
                        ),
                      ),
                      _StepBtn(
                        icon: Icons.add_rounded,
                        onTap: () => setState(() => _slots++),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _kBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Order Summary:',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _kT2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _Row(
                          '$_slots Slot(s) × ₹${_pricePerSlot.toStringAsFixed(0)}',
                          '₹${_total.toStringAsFixed(2)}',
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Divider(height: 1, color: _kBrd),
                        ),
                        _Row(
                          'Total Payable:',
                          '₹${_total.toStringAsFixed(2)}',
                          bold: true,
                          valueColor: _kP,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: _processing
                              ? null
                              : () => Navigator.pop(context),
                          child: Container(
                            height: 44,
                            decoration: BoxDecoration(
                              color: _kBg,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: _kBrd),
                            ),
                            child: const Center(
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: _kT2,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: GestureDetector(
                          onTap: _processing ? null : _pay,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            height: 44,
                            decoration: BoxDecoration(
                              gradient: _processing ? null : _kGrd,
                              color: _processing ? _kBrd : null,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: _processing
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        color: _kW,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.shopping_cart_rounded,
                                          color: _kW,
                                          size: 15,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Pay ₹${_total.toStringAsFixed(0)}',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: _kW,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
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
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  final Color valueColor;
  const _Row(
    this.label,
    this.value, {
    this.bold = false,
    this.valueColor = _kT1,
  });
  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: bold ? 13 : 12,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
          color: bold ? _kT1 : _kT2,
        ),
      ),
      Text(
        value,
        style: TextStyle(
          fontSize: bold ? 15 : 12,
          fontWeight: FontWeight.w800,
          color: valueColor,
        ),
      ),
    ],
  );
}

class _StepBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _StepBtn({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        border: Border.all(color: onTap == null ? _kBrd : _kP),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, size: 18, color: onTap == null ? _kBrd : _kP),
    ),
  );
}
