import 'dart:async';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../API/food_authservice.dart';
import '../models/sub_models.dart';
import '../services/subscription_service.dart';
import '../widgets/theme.dart';

class SubscriptionScreen extends StatefulWidget {
  final VoidCallback onProceed;
  const SubscriptionScreen({super.key, required this.onProceed});
  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  // ── Data ──────────────────────────────────────────────────────────────────────
  List<SubPlan> _orderTypes = [];
  List<SubPlan> _addOns = [];
  List<String> _mandatoryModules = [];
  bool _loading = false;
  String? _error;

  // ── Terms modal ───────────────────────────────────────────────────────────────
  SubPlan? _termsTarget;

  // ── Coupon ────────────────────────────────────────────────────────────────────
  final _couponCtrl = TextEditingController();
  String _appliedCoupon = '';
  bool _couponApplied = false;

  // ── Razorpay ──────────────────────────────────────────────────────────────────
  late Razorpay _razorpay;
  bool _paying = false;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onPaySuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _onPayError);
    _razorpay.on(
      Razorpay.EVENT_EXTERNAL_WALLET,
      (_) => setState(() => _paying = false),
    );
    _loadAll();
  }

  @override
  void dispose() {
    _razorpay.clear();
    _couponCtrl.dispose();
    super.dispose();
  }

  // ─── fetchPlans + fetchActiveModules (mirrors SubscriptionData.jsx exactly) ──
  Future<void> _loadAll() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await SubscriptionService.getSubscriptionPlans();
      if (res == null) throw Exception('Failed to load plans');

      final rawModules = res['modules'] as List? ?? [];
      const nameMap = {'TABLE_ORDERS': 'Dine Out'};

      // Order Types — filtered, sorted by id
      final orderTypes =
          rawModules
              .whereType<Map<String, dynamic>>()
              .where((m) => m['catageory'] == 'ORDER_TYPE')
              .toList()
            ..sort((a, b) => _i(a['id']).compareTo(_i(b['id'])));

      // Feature Add-Ons — filtered, sorted by id
      final addOns =
          rawModules
              .whereType<Map<String, dynamic>>()
              .where((m) => m['catageory'] == 'FEATURE_ADD_ON')
              .toList()
            ..sort((a, b) => _i(a['id']).compareTo(_i(b['id'])));

      // Base Plan mandatory modules
      final mandatory = rawModules
          .whereType<Map<String, dynamic>>()
          .where((m) => m['catageory'] == 'BASE_PLAN')
          .map((m) => m['code']?.toString() ?? '')
          .where((c) => c.isNotEmpty)
          .toList();

      final otPlans = orderTypes
          .asMap()
          .entries
          .map((e) => SubPlan.fromJson(e.value, e.key + 1))
          .toList();
      final aoPlans = addOns
          .asMap()
          .entries
          .map((e) => SubPlan.fromJson(e.value, e.key + 1))
          .toList();

      if (mounted)
        setState(() {
          _orderTypes = otPlans;
          _addOns = aoPlans;
          _mandatoryModules = mandatory;
          _loading = false;
        });

      // Fetch active modules (auto-select + accept terms)
      _loadActiveModules(otPlans, aoPlans);
    } catch (e) {
      if (mounted)
        setState(() {
          _loading = false;
          _error = e.toString();
        });
    }
  }

  Future<void> _loadActiveModules(
    List<SubPlan> otPlans,
    List<SubPlan> aoPlans,
  ) async {
    try {
      final active = await SubscriptionService.getVendorActiveSubscription();
      if (active == null) return;

      // Extract active codes by category
      final activeOrderCodes = active.selectedModules
          .where((m) => m.isOrderType)
          .map((m) => m.moduleCode)
          .toSet();
      final activeFeatureCodes = active.selectedModules
          .where((m) => m.isFeatureAddOn)
          .map((m) => m.moduleCode)
          .toSet();

      final existing = {...activeOrderCodes, ...activeFeatureCodes};
      _mandatoryModules = {..._mandatoryModules, ...existing}.toList();

      if (!mounted) return;
      setState(() {
        for (var p in _orderTypes) {
          final code = p.name.replaceAll(' ', '_').toUpperCase();
          if (activeOrderCodes.contains(code)) {
            p.selected = true;
            p.termsAccepted = true;
          }
        }
        for (var a in _addOns) {
          final code = a.name.replaceAll(' ', '_').toUpperCase();
          if (activeFeatureCodes.contains(code)) {
            a.selected = true;
            a.termsAccepted = true;
          }
        }
      });
    } catch (_) {}
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────────
  List<SubPlan> get _selectedOrderTypes =>
      _orderTypes.where((p) => p.selected && p.termsAccepted).toList();
  List<SubPlan> get _selectedAddOns =>
      _addOns.where((a) => a.selected && a.termsAccepted).toList();
  List<SubPlan> get _allSelected => [
    ..._selectedOrderTypes,
    ..._selectedAddOns,
  ];

  double get _subtotal => _allSelected.fold(0.0, (s, p) => s + p.price);
  double get _gst => _subtotal * 0.18;
  double get _discount => _appliedCoupon == 'MAAMAAS10' ? _subtotal * 0.10 : 0;
  double get _total => _subtotal + _gst - _discount;

  List<String> get _selectedModuleCodes {
    // reverseNameMap: Dine Out → TABLE_ORDERS
    const reverseMap = {'Dine Out': 'TABLE_ORDERS'};
    final userSelected = _allSelected.map((p) {
      return reverseMap[p.name] ?? p.name.replaceAll(' ', '_').toUpperCase();
    }).toSet();
    return {...userSelected, ..._mandatoryModules}.toList();
  }

  int _i(dynamic v) => (v is int) ? v : int.tryParse(v?.toString() ?? '') ?? 0;

  void _togglePlan(SubPlan plan) {
    setState(() {
      final idx = _orderTypes.indexWhere((p) => p.id == plan.id);
      if (idx >= 0) {
        _orderTypes[idx].selected = !_orderTypes[idx].selected;
        if (!_orderTypes[idx].selected) _orderTypes[idx].termsAccepted = false;
      }
    });
  }

  void _toggleAddOn(SubPlan addon) {
    setState(() {
      final idx = _addOns.indexWhere((a) => a.id == addon.id);
      if (idx >= 0) {
        _addOns[idx].selected = !_addOns[idx].selected;
        if (!_addOns[idx].selected) _addOns[idx].termsAccepted = false;
      }
    });
  }

  void _acceptTerms(int id) {
    setState(() {
      for (var p in _orderTypes) {
        if (p.id == id) p.termsAccepted = true;
      }
      for (var a in _addOns) {
        if (a.id == id) a.termsAccepted = true;
      }
    });
    setState(() => _termsTarget = null);
  }

  void _applyCoupon() {
    final code = _couponCtrl.text.trim().toUpperCase();
    setState(() {
      _appliedCoupon = code;
      _couponApplied = code == 'MAAMAAS10';
    });
    if (_couponApplied) {
      sdSnack(context, '✅ Coupon applied! 10% discount', success: true);
    } else if (code.isNotEmpty) {
      sdSnack(context, '❌ Invalid coupon code', error: true);
    }
  }

  // ─── Payment ──────────────────────────────────────────────────────────────────
  Future<void> _startPayment() async {
    if (_allSelected.isEmpty) {
      sdSnack(context, 'Please select at least one module', error: true);
      return;
    }
    setState(() => _paying = true);
    try {
      final orderId = await SubscriptionService.createOrder(_total);
      if (orderId == null) throw Exception('Order creation failed');

      final vendorDetails = await food_authservice
          .fetchVendorRegistrationDetails();
      if (vendorDetails == null) {
        throw Exception('Unable to fetch vendor details');
      }

      final String userMobile = vendorDetails['mobileNumber'] ?? '';
      final String userEmail = vendorDetails['email'] ?? '';

      if (userMobile.isEmpty || userEmail.isEmpty) {
        setState(() => _paying = false);
        if (mounted) {
          sdSnack(
            context,
            'Please complete your profile before paying',
            error: true,
          );
        }
        return;
      }

      _razorpay.open({
        'key': 'rzp_test_TJECsclCivENpY',
        'amount': _total.toInt(),
        'currency': 'INR',
        'order_id': orderId,
        'name': 'Maamaas',
        'description': 'Subscription Payment',
        'prefill': {
          'name': vendorDetails['ownerName'] ?? 'user',
          'email': userEmail,
          'contact': userMobile,
        },
        'notes': {'modules': _selectedModuleCodes.join(', ')},
        'theme': {'color': '#f97316'},
      });
    } catch (e) {
      setState(() => _paying = false);
      if (mounted) sdSnack(context, 'Payment failed: $e', error: true);
    }
  }

  void _onPaySuccess(PaymentSuccessResponse r) async {
    try {
      // 1. Capture payment
      await SubscriptionService.capturePayment(
        paymentId: r.paymentId!,
        amount: _total,
      );

      // 2. Create or renew subscription
      final result = await SubscriptionService.createSubscription(
        selectedModules: _selectedModuleCodes,
        transactionId: r.paymentId!,
        totalAmount: _total,
      );

      if (result?['needsRenew'] == true) {
        // Already has active subscription — renew
        await SubscriptionService.renewSubscription(
          payload: result!['payload'] as Map<String, dynamic>,
        );
      }

      if (mounted) {
        setState(() => _paying = false);
        sdSnack(
          context,
          '✅ Payment Successful & Subscription Updated!',
          success: true,
        );
        widget.onProceed();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _paying = false);
        sdSnack(
          context,
          'Payment done but subscription update failed',
          error: true,
        );
      }
    }
  }

  void _onPayError(PaymentFailureResponse r) {
    if (mounted) {
      setState(() => _paying = false);
      sdSnack(
        context,
        'Payment failed: ${r.message ?? "Please try again"}',
        error: true,
      );
    }
  }

  // ─── BUILD ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (_loading)
      return const Center(
        child: CircularProgressIndicator(color: sdAccent, strokeWidth: 2),
      );
    if (_error != null) return _buildError();

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── ORDER TYPES ─────────────────────────────────────────────────────
              const Text(
                'Order Types',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: sdText1,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Choose how your restaurant takes orders',
                style: TextStyle(fontSize: 13, color: sdGray),
              ),
              const SizedBox(height: 12),
              _orderTypes.isEmpty
                  ? _emptyPlans('No order types available')
                  : Column(
                      children: _orderTypes
                          .map(
                            (p) => _PlanCard(
                              plan: p,
                              onToggle: _togglePlan,
                              onTermsTap: () =>
                                  setState(() => _termsTarget = p),
                            ),
                          )
                          .toList(),
                    ),

              const SizedBox(height: 20),

              // ── ADD-ON FEATURES ─────────────────────────────────────────────────
              const Text(
                'Add-On Features',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: sdText1,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Optional power-ups for your operations',
                style: TextStyle(fontSize: 13, color: sdGray),
              ),
              const SizedBox(height: 12),
              _addOns.isEmpty
                  ? _emptyPlans('No add-ons available')
                  : Column(
                      children: _addOns
                          .map(
                            (a) => _PlanCard(
                              plan: a,
                              onToggle: _toggleAddOn,
                              onTermsTap: () =>
                                  setState(() => _termsTarget = a),
                            ),
                          )
                          .toList(),
                    ),

              const SizedBox(height: 20),

              // ── BILLING SUMMARY ─────────────────────────────────────────────────
              _buildBillingSummary(),

              const SizedBox(height: 24),
            ],
          ),
        ),

        // Terms Modal
        if (_termsTarget != null)
          _TermsModal(
            plan: _termsTarget!,
            onClose: () => setState(() => _termsTarget = null),
            onAccept: _acceptTerms,
          ),

        // Loading overlay
        if (_paying)
          Positioned.fill(
            child: Container(
              color: Colors.black26,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: sdAccent, strokeWidth: 3),
                    SizedBox(height: 14),
                    Text(
                      'Processing payment...',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _emptyPlans(String msg) => Container(
    padding: const EdgeInsets.all(20),
    decoration: sdCardDeco(radius: 12),
    child: Center(
      child: Text(msg, style: const TextStyle(color: sdGray, fontSize: 13)),
    ),
  );

  Widget _buildError() => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded, size: 48, color: sdRed),
          const SizedBox(height: 12),
          const Text(
            'Failed to load plans',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: sdText1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _error ?? '',
            style: const TextStyle(fontSize: 12, color: sdGray),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          ElevatedButton.icon(
            onPressed: _loadAll,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: sdAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildBillingSummary() => Container(
    decoration: sdCardDeco(radius: 18),
    padding: const EdgeInsets.all(18),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Billing Summary',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: sdText1,
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          'Yearly subscription',
          style: TextStyle(fontSize: 12, color: sdGray),
        ),
        const Divider(color: sdBorder, height: 20),

        if (_selectedOrderTypes.isEmpty)
          const Text(
            '+ No order types selected',
            style: TextStyle(fontSize: 13, color: sdText3),
          )
        else
          ..._selectedOrderTypes.map(
            (p) => _billingRow('Order Type', sdTitleCase(p.name), p.price),
          ),

        const SizedBox(height: 8),

        if (_selectedAddOns.isEmpty)
          const Text(
            '+ No add-ons selected',
            style: TextStyle(fontSize: 13, color: sdText3),
          )
        else
          ..._selectedAddOns.map(
            (a) => _billingRow('Add On', sdTitleCase(a.name), a.price),
          ),

        const Divider(color: sdBorder, height: 20),

        const Text(
          'Coupon code',
          style: TextStyle(fontSize: 12, color: sdGray),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _couponApplied ? sdGreen : sdAccent,
                    width: 1.5,
                  ),
                ),
                child: TextField(
                  controller: _couponCtrl,
                  style: const TextStyle(fontSize: 14, color: sdText1),
                  decoration: InputDecoration(
                    hintText: 'Enter code',
                    hintStyle: const TextStyle(color: sdText3, fontSize: 13),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    suffixIcon: _couponApplied
                        ? const Icon(
                            Icons.check_circle_rounded,
                            color: sdGreen,
                            size: 18,
                          )
                        : null,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: _applyCoupon,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: sdBorder,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Apply',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: sdText1,
                  ),
                ),
              ),
            ),
          ],
        ),

        const Divider(color: sdBorder, height: 20),

        _summaryRow('Subtotal', '₹${_subtotal.toStringAsFixed(0)}'),
        const SizedBox(height: 6),
        _summaryRow('GST (18%)', '₹${_gst.toStringAsFixed(0)}', muted: true),
        if (_discount > 0) ...[
          const SizedBox(height: 6),
          _summaryRow(
            'Discount (MAAMAAS10)',
            '-₹${_discount.toStringAsFixed(0)}',
            green: true,
          ),
        ],
        const Divider(color: sdBorder, height: 14),
        Row(
          children: [
            const Text(
              'Total',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: sdText1,
              ),
            ),
            const Spacer(),
            Text(
              '₹${_total.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: sdAccent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        GestureDetector(
          onTap: _paying ? null : _startPayment,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFF97316), Color(0xFFEA6B0E)],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: sdAccent.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: _paying
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
                : const Center(
                    child: Text(
                      '🔒 Proceed to Payment',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
          ),
        ),
      ],
    ),
  );

  Widget _billingRow(String type, String name, double price) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(
            type,
            style: const TextStyle(
              fontSize: 12,
              color: sdText1,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            name,
            style: const TextStyle(
              fontSize: 12,
              color: sdText1,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          '₹${price.toStringAsFixed(0)}',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: sdText1,
          ),
        ),
      ],
    ),
  );

  Widget _summaryRow(
    String label,
    String value, {
    bool muted = false,
    bool green = false,
  }) => Row(
    children: [
      Text(label, style: const TextStyle(fontSize: 14, color: sdText2)),
      const Spacer(),
      Text(
        value,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: green
              ? sdGreenD
              : muted
              ? sdGray
              : sdText1,
        ),
      ),
    ],
  );
}

class _PlanCard extends StatelessWidget {
  final SubPlan plan;
  final void Function(SubPlan) onToggle;
  final VoidCallback onTermsTap;

  const _PlanCard({
    required this.plan,
    required this.onToggle,
    required this.onTermsTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = plan.selected;
    final isAccepted = plan.termsAccepted;

    Color borderColor = const Color(0xFFEBAA8B); // default
    Color bgColor = sdCard;
    if (isAccepted) {
      borderColor = sdGreen;
      bgColor = const Color(0xFFF0FDF4);
    } else if (isSelected) {
      borderColor = sdAccent;
      bgColor = sdAccentL;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
          width: isSelected || isAccepted ? 2 : 1,
        ),
        boxShadow: const [
          BoxShadow(color: sdShadow, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Stack(
        children: [
          // Recommended badge
          if (plan.recommended)
            Positioned(
              top: -1,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: sdAccent,
                  borderRadius: BorderRadius.circular(0).copyWith(
                    bottomLeft: const Radius.circular(8),
                    bottomRight: const Radius.circular(8),
                  ),
                ),
                child: const Text(
                  'Recommended',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (plan.recommended) const SizedBox(height: 10),
                // Header row
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Text(
                            sdTitleCase(plan.name),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: sdText1,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (isAccepted)
                            Container(
                              width: 18,
                              height: 18,
                              decoration: const BoxDecoration(
                                color: sdGreen,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 12,
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Toggle switch
                    GestureDetector(
                      onTap: () => onToggle(plan),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 42,
                        height: 22,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? sdAccent
                              : const Color(0xFFD1D5DB),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: AnimatedAlign(
                          duration: const Duration(milliseconds: 200),
                          alignment: isSelected
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            width: 18,
                            height: 18,
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // Description
                Text(
                  plan.description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: sdGray,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 10),
                // Price row
                Row(
                  children: [
                    Text(
                      '₹${plan.price.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: sdText1,
                      ),
                    ),
                    const Text(
                      ' / year',
                      style: TextStyle(fontSize: 13, color: sdGray),
                    ),
                  ],
                ),
                const Divider(color: sdBorder, height: 20),
                // Terms checkbox row
                GestureDetector(
                  onTap: isSelected ? onTermsTap : null,
                  child: Row(
                    children: [
                      // Round checkbox
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: isAccepted ? sdAccent : Colors.transparent,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? sdAccent : sdBorder,
                            width: 2,
                          ),
                        ),
                        child: isAccepted
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 11,
                              )
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'I agree to the ',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isSelected ? sdGray : sdText3,
                                ),
                              ),
                              TextSpan(
                                text: 'Terms & Conditions',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isSelected ? sdAccent : sdText3,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
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

class _TermsModal extends StatelessWidget {
  final SubPlan plan;
  final VoidCallback onClose;
  final void Function(int) onAccept;

  const _TermsModal({
    required this.plan,
    required this.onClose,
    required this.onAccept,
  });

  @override
  Widget build(BuildContext context) => Positioned.fill(
    child: GestureDetector(
      onTap: onClose,
      child: Container(
        color: Colors.black54,
        child: Center(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: sdCard,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '📄 ${plan.name} — Terms & Conditions',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: sdText1,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: onClose,
                        child: const Icon(
                          Icons.close_rounded,
                          color: sdGray,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: sdBorder, height: 20),

                  // Content paragraphs (exact match to TermsModal.jsx)
                  const Text(
                    'Please review the terms before enabling this module.',
                    style: TextStyle(fontSize: 13, color: sdText2, height: 1.5),
                  ),
                  const SizedBox(height: 10),
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 13,
                        color: sdText2,
                        height: 1.5,
                      ),
                      children: [
                        const TextSpan(text: 'By enabling '),
                        TextSpan(
                          text: plan.name,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const TextSpan(
                          text: ', you agree to a yearly subscription of ',
                        ),
                        TextSpan(
                          text: '₹${plan.price.toStringAsFixed(0)}',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const TextSpan(
                          text:
                              ', auto-renewing unless cancelled 7 days before the renewal date.',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Usage data may be processed to improve the service. Refunds are governed by the MAAMAAS refund policy and are pro-rated within the first 14 days.',
                    style: TextStyle(fontSize: 13, color: sdText2, height: 1.5),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'You are responsible for ensuring compliance with local food, tax, and labour regulations.',
                    style: TextStyle(fontSize: 13, color: sdText2, height: 1.5),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Service uptime target is 99.9%. Scheduled maintenance will be communicated 48 hours in advance.',
                    style: TextStyle(fontSize: 13, color: sdText2, height: 1.5),
                  ),
                  const SizedBox(height: 14),

                  // Footer box (light orange background matching modal-footer-box)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3E9DF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 13,
                              color: sdText2,
                            ),
                            children: [
                              const TextSpan(
                                text: 'Confirm your acceptance for ',
                              ),
                              TextSpan(
                                text: plan.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const TextSpan(text: '.'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: onClose,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE5E7EB),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'Cancel',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: sdText1,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => onAccept(plan.id),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFF97316),
                                        Color(0xFFEA6B0E),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      '✔ I Accept Terms',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                      ),
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
          ),
        ),
      ),
    ),
  );
}
