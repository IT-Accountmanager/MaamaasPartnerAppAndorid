import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../food&beverages/Invoice.dart';
import '../models/cart_models.dart';
import '../services/cart_service.dart';

class PaymentSection extends StatefulWidget {
  final PaymentMethodsConfig paymentConfig;
  final String selectedMethod;
  final double grandTotal;
  final double tipAmount;
  final int? cartId;
  final int vendorId;
  final String authToken;
  final ValueChanged<String> onMethodChanged;
  final VoidCallback? onPaymentSuccess;
  final VoidCallback? onBack;
  final VoidCallback onSplitByGuests;
  final VoidCallback? onQRPaymentRequested;
  final VoidCallback? onSplitPaymentRequested;
  final VoidCallback? onCashPaymentRequested;
  final Function(int orderId)?
  onOrderPlaced;

  const PaymentSection({
    Key? key,
    required this.paymentConfig,
    required this.selectedMethod,
    required this.grandTotal,
    required this.tipAmount,
    required this.cartId,
    required this.vendorId,
    required this.authToken,
    required this.onMethodChanged,
    this.onPaymentSuccess,
    this.onBack,
    required this.onSplitByGuests,
    this.onQRPaymentRequested,
    this.onSplitPaymentRequested,
    this.onCashPaymentRequested,
    this.onOrderPlaced,
  }) : super(key: key);

  @override
  State<PaymentSection> createState() => _PaymentSectionState();
}

class _PaymentSectionState extends State<PaymentSection>
    with SingleTickerProviderStateMixin {
  bool _isProcessing = false;
  final TextEditingController _cashCtrl = TextEditingController();
  double _change = 0;
  final TextEditingController _guestNameCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();

  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  // Cash denomination state
  final Map<String, int> _denominationCounts = {
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

  static const Map<String, int> _denominationValues = {
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

  static const Map<String, String> _denominationLabels = {
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

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(
      begin: 1.0,
      end: 1.04,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _cashCtrl.dispose();
    _guestNameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  List<_PayMethod> get _methods {
    final list = <_PayMethod>[];
    if (widget.paymentConfig.cash) {
      list.add(
        const _PayMethod(
          value: 'Cash',
          label: 'Cash',
          icon: Icons.payments_outlined,
          color: Color(0xFF28a745),
        ),
      );
    }
    if (widget.paymentConfig.upi) {
      list.add(
        const _PayMethod(
          value: 'UPI',
          label: 'UPI',
          icon: Icons.phone_android_outlined,
          color: Color(0xFF6610f2),
        ),
      );
    }
    if (widget.paymentConfig.qrCode) {
      list.add(
        const _PayMethod(
          value: 'QR',
          label: 'QR',
          icon: Icons.qr_code_2_rounded,
          color: Color(0xFF17a2b8),
        ),
      );
    }
    list.add(
      const _PayMethod(
        value: 'Card',
        label: 'Card',
        icon: Icons.credit_card_outlined,
        color: Color(0xFF343a40),
      ),
    );
    list.add(
      const _PayMethod(
        value: 'Hold',
        label: 'Hold',
        icon: Icons.pause_circle_outline_rounded,
        color: Color(0xFFfd7e14),
      ),
    );
    list.add(
      const _PayMethod(
        value: 'Due',
        label: 'Due',
        icon: Icons.pending_actions_outlined,
        color: Color(0xFFdc3545),
      ),
    );
    if (widget.paymentConfig.splitBilling) {
      list.add(
        const _PayMethod(
          value: 'Split',
          label: 'Split',
          icon: Icons.call_split_rounded,
          color: Color(0xFFe66d33),
        ),
      );
    }
    list.add(
      const _PayMethod(
        value: 'ByGuests',
        label: 'By Guests',
        icon: Icons.group_outlined,
        color: Color(0xFF20c997),
      ),
    );
    return list;
  }

  String _toApiMethod(String value) {
    switch (value) {
      case 'Cash':
        return 'Cash';
      case 'UPI':
        return 'UPI';
      case 'QR':
        return 'Online_Payment';
      case 'Card':
        return 'Card';
      case 'Hold':
        return 'Hold';
      case 'Due':
        return 'Due';
      case 'Split':
        return 'MULTIPLE';
      default:
        return value;
    }
  }

  Future<void> _handleCheckout() async {
    if (widget.cartId == null) {
      _snack('Cart not saved. Please save items first.', isError: true);
      return;
    }
    if (widget.selectedMethod.isEmpty) {
      _snack('Please select a payment method.', isError: true);
      return;
    }

    final method = widget.selectedMethod;

    // Handle By Guests split
    if (method == 'ByGuests') {
      widget.onSplitByGuests();
      return;
    }

    // Handle Split Payment
    if (method == 'Split') {
      if (widget.onSplitPaymentRequested != null) {
        widget.onSplitPaymentRequested!();
      } else {
        _snack('Split payment not configured', isError: true);
      }
      return;
    }

    // Handle QR Payment
    if (method == 'QR') {
      if (widget.onQRPaymentRequested != null) {
        widget.onQRPaymentRequested!();
      } else {
        _snack('QR payment not configured', isError: true);
      }
      return;
    }

    // Handle Cash Payment with denomination
    if (method == 'Cash') {
      if (widget.onCashPaymentRequested != null) {
        widget.onCashPaymentRequested!();
      } else {
        await _showCashDenominationSheet();
      }
      return;
    }

    if (method == 'Due') {
      await _showDueModal();
      return;
    }

    await _placeOrder(method);
  }
  Future<void> _showCashDenominationSheet() async {
    final Map<String, int> counts = Map.from(_denominationCounts);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          double getTotalReceived() {
            return counts.entries.fold(
              0.0,
              (s, e) => s + (e.value * (_denominationValues[e.key] ?? 0)),
            );
          }

          double getReturnAmount() {
            final received = getTotalReceived();
            final expected = widget.grandTotal + widget.tipAmount;
            return (received - expected).clamp(0.0, double.infinity);
          }

          bool canConfirm() {
            return getTotalReceived() >= (widget.grandTotal + widget.tipAmount);
          }

          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(top: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  decoration: const BoxDecoration(
                    color: Color(0xFFe66d33),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.payments_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
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
                        onTap: () => Navigator.pop(ctx),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Content
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Column(
                      children: [
                        // Expected amount
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFe66d33).withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Expected Amount',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '₹${(widget.grandTotal + widget.tipAmount).toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFFe66d33),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Denomination grid - Row 1
                        Row(
                          children: _denominationCounts.keys.take(5).map((key) {
                            return Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 3,
                                ),
                                child: _buildDenominationItem(
                                  key: key,
                                  label: _denominationLabels[key]!,
                                  value: _denominationValues[key]!,
                                  count: counts[key] ?? 0,
                                  onChanged: (val) {
                                    setModalState(() {
                                      counts[key] = int.tryParse(val) ?? 0;
                                    });
                                  },
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 10),
                        // Denomination grid - Row 2
                        Row(
                          children: _denominationCounts.keys.skip(5).map((key) {
                            return Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 3,
                                ),
                                child: _buildDenominationItem(
                                  key: key,
                                  label: _denominationLabels[key]!,
                                  value: _denominationValues[key]!,
                                  count: counts[key] ?? 0,
                                  onChanged: (val) {
                                    setModalState(() {
                                      counts[key] = int.tryParse(val) ?? 0;
                                    });
                                  },
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),
                        // Summary
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF6F7FB),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Column(
                            children: [
                              _buildSummaryLine(
                                'Total Received',
                                getTotalReceived(),
                                color: const Color(0xFF28a745),
                              ),
                              if (getReturnAmount() > 0) ...[
                                const SizedBox(height: 8),
                                const Divider(height: 1),
                                const SizedBox(height: 8),
                                _buildSummaryLine(
                                  'Change to Return',
                                  getReturnAmount(),
                                  color: const Color(0xFFfd7e14),
                                ),
                              ],
                              if (!canConfirm() && getTotalReceived() > 0) ...[
                                const SizedBox(height: 8),
                                const Divider(height: 1),
                                const SizedBox(height: 8),
                                _buildSummaryLine(
                                  'Still Needed',
                                  (widget.grandTotal + widget.tipAmount) -
                                      getTotalReceived(),
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
                // Action buttons
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(ctx),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF6F7FB),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
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
                          onTap: canConfirm()
                              ? () async {
                                  Navigator.pop(ctx);
                                  await _placeOrderWithDenominations('Cash', {
                                    'amount':
                                        widget.grandTotal + widget.tipAmount,
                                    'received': getTotalReceived(),
                                    'change': getReturnAmount(),
                                    'denominations': Map<String, int>.from(
                                      counts,
                                    ),
                                  });
                                }
                              : null,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: canConfirm()
                                    ? [
                                        const Color(0xFF28a745),
                                        const Color(0xFF1e7e34),
                                      ]
                                    : [
                                        Colors.grey.shade400,
                                        Colors.grey.shade400,
                                      ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: canConfirm()
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
                              child: Text(
                                canConfirm()
                                    ? 'Confirm ₹${getTotalReceived().toStringAsFixed(2)}'
                                    : 'Insufficient Amount',
                                style: const TextStyle(
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
        },
      ),
    );
  }

  Widget _buildDenominationItem({
    required String key,
    required String label,
    required int value,
    required int count,
    required Function(String) onChanged,
  }) {
    final controller = TextEditingController(
      text: count > 0 ? count.toString() : '',
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: 38,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: count > 0 ? const Color(0xFFe66d33) : Colors.grey.shade300,
              width: count > 0 ? 1.5 : 1,
            ),
          ),
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: '0',
              contentPadding: EdgeInsets.zero,
              isDense: true,
            ),
            onChanged: onChanged,
          ),
        ),
        if (count > 0)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              '₹${count * value}',
              style: const TextStyle(
                fontSize: 9,
                color: Color(0xFFe66d33),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSummaryLine(String label, double value, {required Color color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.grey,
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

  Future<void> _placeOrderWithDenominations(
    String method,
    Map<String, dynamic> denomData,
  ) async {
    setState(() => _isProcessing = true);

    try {
      final apiMethod = _toApiMethod(method);
      final prefs = await SharedPreferences.getInstance();
      final phone = prefs.getString('phone') ?? '9999999999';

      final result = await CartService.createVendorOrder(
        cartId: widget.cartId!,
        vendorId: widget.vendorId,
        paymentMethod: apiMethod,
        phoneNumber: phone,
      );

      if (!mounted) return;

      if (result != null) {
        final orderId = result['orderId'] ?? result['id'];
        if (orderId != null) {
          // Add cash billing entry
          await _addCashBillingEntry(
            orderId: orderId,
            cashEntry: {
              'method': 'Cash',
              'amount': widget.grandTotal + widget.tipAmount,
              'denominationData': denomData,
            },
          );

          // Store orderId
          await prefs.setInt('orderId', orderId);

          _snack('✅ Order #$orderId placed via $method!', isError: false);

          // Navigate to invoice
          if (widget.onOrderPlaced != null) {
            widget.onOrderPlaced!(orderId);
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => food_Invoice(orderId: orderId)),
            );
          }
        } else {
          _snack('✅ Payment processed via $method!', isError: false);
          widget.onPaymentSuccess?.call();
        }
      } else {
        _snack('Payment failed. Please try again.', isError: true);
      }
    } catch (e) {
      _snack('Payment error: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
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
      debugPrint('❌ _addCashBillingEntry error: $e');
    }
  }

  Future<void> _placeOrder(String uiMethod, {String? phoneOverride}) async {
    if (mounted) setState(() => _isProcessing = true);

    try {
      final apiMethod = _toApiMethod(uiMethod);
      final prefs = await SharedPreferences.getInstance();
      final phone = phoneOverride?.isNotEmpty == true
          ? phoneOverride!
          : prefs.getString('phone') ?? '9999999999';

      debugPrint('💳 [PaymentSection] Creating vendor order:');
      debugPrint('   cartId   : ${widget.cartId}');
      debugPrint('   vendorId : ${widget.vendorId}');
      debugPrint('   method   : $apiMethod');
      debugPrint('   phone    : $phone');

      final result = await CartService.createVendorOrder(
        cartId: widget.cartId!,
        vendorId: widget.vendorId,
        paymentMethod: apiMethod,
        phoneNumber: phone,
      );

      if (!mounted) return;

      if (result != null) {
        final orderId = result['orderId'] ?? result['id'];
        if (orderId != null) {
          // Store orderId in SharedPreferences
          await prefs.setInt('orderId', orderId);

          _snack('✅ Order #$orderId placed via $uiMethod!', isError: false);

          // Navigate to invoice screen
          if (widget.onOrderPlaced != null) {
            widget.onOrderPlaced!(orderId);
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => food_Invoice(orderId: orderId)),
            );
          }
        } else {
          _snack('✅ Payment processed via $uiMethod!', isError: false);
          widget.onPaymentSuccess?.call();
        }
      } else {
        _snack('Payment failed. Please try again.', isError: true);
      }
    } catch (e) {
      debugPrint('❌ [PaymentSection] createVendorOrder error: $e');
      if (!mounted) return;
      _snack('Payment error: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }


  Future<void> _showCashPaymentModal() async {
    _cashCtrl.clear();
    _change = 0;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
              left: 20,
              right: 20,
              top: 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFF28a745).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.payments_outlined,
                        color: Color(0xFF28a745),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cash Payment',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            'Enter amount tendered by customer',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFe66d33).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFe66d33).withOpacity(0.25),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Bill Amount',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '₹${(widget.grandTotal + widget.tipAmount).toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 20,
                          color: Color(0xFFe66d33),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _quickAmounts().map((amt) {
                    return GestureDetector(
                      onTap: () {
                        _cashCtrl.text = amt.toStringAsFixed(0);
                        final tendered = double.tryParse(_cashCtrl.text) ?? 0;
                        setModal(() {
                          _change =
                              (tendered -
                                      (widget.grandTotal + widget.tipAmount))
                                  .clamp(0, 9999);
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Text(
                          '₹${amt.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _cashCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d+\.?\d{0,2}'),
                    ),
                  ],
                  autofocus: true,
                  onChanged: (v) {
                    final tendered = double.tryParse(v) ?? 0;
                    setModal(() {
                      _change =
                          (tendered - (widget.grandTotal + widget.tipAmount))
                              .clamp(0, 9999);
                    });
                  },
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Amount Tendered (₹)',
                    prefixIcon: const Icon(Icons.currency_rupee, size: 18),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF28a745),
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: _change >= 0
                        ? const Color(0xFF28a745).withOpacity(0.08)
                        : const Color(0xFFdc3545).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _change >= 0
                          ? const Color(0xFF28a745).withOpacity(0.3)
                          : const Color(0xFFdc3545).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _change >= 0 ? 'Change to Return' : 'Remaining',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: _change >= 0
                              ? const Color(0xFF28a745)
                              : const Color(0xFFdc3545),
                        ),
                      ),
                      Text(
                        '₹${_change.abs().toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 20,
                          color: _change >= 0
                              ? const Color(0xFF28a745)
                              : const Color(0xFFdc3545),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _change >= 0
                          ? const Color(0xFF28a745)
                          : Colors.grey.shade400,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _change >= 0
                        ? () async {
                            Navigator.pop(ctx);
                            await _placeOrder('Cash');
                          }
                        : null,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle_outline_rounded,
                          color: Colors.white,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Confirm Cash Payment',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          );
        },
      ),
    );
  }

  List<double> _quickAmounts() {
    final g = widget.grandTotal + widget.tipAmount;
    final rounded = (g / 10).ceil() * 10.0;
    return [
      g,
      rounded,
      rounded + 10,
      rounded + 50,
      rounded + 100,
    ].toSet().toList()..sort();
  }

  Future<void> _showDueModal() async {
    _guestNameCtrl.clear();
    _phoneCtrl.clear();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Save Due',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'Enter customer details to record this due',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFdc3545).withOpacity(0.07),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFFdc3545).withOpacity(0.2),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Due Amount',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '₹${(widget.grandTotal + widget.tipAmount).toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      color: Color(0xFFdc3545),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _guestNameCtrl,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Customer Name *',
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              decoration: InputDecoration(
                labelText: 'Phone Number *',
                prefixIcon: const Icon(Icons.phone_outlined),
                hintText: '10-digit mobile number',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFdc3545),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  if (_guestNameCtrl.text.trim().isEmpty ||
                      _phoneCtrl.text.trim().length < 10) {
                    _snack(
                      'Please enter a valid name and 10-digit phone number',
                      isError: true,
                    );
                    return;
                  }
                  Navigator.pop(ctx);
                  await _placeOrder(
                    'Due',
                    phoneOverride: _phoneCtrl.text.trim(),
                  );
                },
                child: const Text(
                  'Confirm Due',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _snack(String msg, {bool isError = false}) {
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
        backgroundColor: isError
            ? const Color(0xFFdc3545)
            : const Color(0xFF28a745),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasCart = widget.cartId != null;
    final hasMethod = widget.selectedMethod.isNotEmpty;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Section header
            const Row(
              children: [
                Icon(
                  Icons.payment_outlined,
                  color: Color(0xFFe66d33),
                  size: 18,
                ),
                SizedBox(width: 6),
                Text(
                  'Payment Method',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Payment method chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _methods
                  .map(
                    (m) => _MethodChip(
                      method: m,
                      isSelected: widget.selectedMethod == m.value,
                      onTap: () {
                        if (m.value == 'ByGuests') {
                          widget.onSplitByGuests();
                          return;
                        }
                        widget.onMethodChanged(m.value);
                      },
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 14),

            // Summary rows
            _SummaryRow(label: 'Grand Total', value: widget.grandTotal),
            if (widget.tipAmount > 0)
              _SummaryRow(
                label: 'Tip',
                value: widget.tipAmount,
                valueColor: const Color(0xFF28a745),
              ),

            // Selected method highlight
            if (hasMethod) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFe66d33).withOpacity(0.07),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFe66d33).withOpacity(0.25),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          color: Color(0xFFe66d33),
                          size: 15,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          widget.selectedMethod,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: Color(0xFFe66d33),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '₹${(widget.grandTotal + widget.tipAmount).toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                        color: Color(0xFFe66d33),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 14),

            // Checkout button
            AnimatedBuilder(
              animation: _pulseAnim,
              builder: (_, child) => Transform.scale(
                scale: (hasCart && hasMethod && !_isProcessing)
                    ? _pulseAnim.value
                    : 1.0,
                child: child,
              ),
              child: SizedBox(
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: (hasCart && hasMethod)
                        ? const Color(0xFF28a745)
                        : Colors.grey.shade300,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: (hasCart && hasMethod && !_isProcessing)
                      ? _handleCheckout
                      : null,
                  child: _isProcessing
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.check_circle_outline_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              !hasCart
                                  ? 'Save items before checkout'
                                  : !hasMethod
                                  ? 'Select a payment method'
                                  : 'Check Out  ₹${(widget.grandTotal + widget.tipAmount).toStringAsFixed(2)}',
                              style: TextStyle(
                                color: (hasCart && hasMethod)
                                    ? Colors.white
                                    : Colors.grey.shade600,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),

            // Guard message
            if (!hasCart) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 13,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Save your items first to enable checkout',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}


class _PayMethod {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _PayMethod({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });
}

class _MethodChip extends StatelessWidget {
  final _PayMethod method;
  final bool isSelected;
  final VoidCallback onTap;

  const _MethodChip({
    required this.method,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? method.color : method.color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? method.color : method.color.withOpacity(0.3),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: method.color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              method.icon,
              size: 14,
              color: isSelected ? Colors.white : method.color,
            ),
            const SizedBox(width: 5),
            Text(
              method.label,
              style: TextStyle(
                color: isSelected ? Colors.white : method.color,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final double value;
  final Color? valueColor;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          Text(
            '₹${value.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: valueColor ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
