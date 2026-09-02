// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:razorpay_flutter/razorpay_flutter.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../models/sub_models.dart';
// import '../services/subscription_service.dart';
// import '../widgets/theme.dart';
//
// class SubscriptionScreen1 extends StatefulWidget {
//   const SubscriptionScreen1({super.key});
//   @override
//   State<SubscriptionScreen1> createState() => _SubscriptionScreenState();
// }
//
// class _SubscriptionScreenState extends State<SubscriptionScreen1> {
//   // ── Data ──────────────────────────────────────────────────────────────────
//   List<SubModule> _modules = [];
//   ActiveSubscription? _activeSub;
//   String _subStatus = 'NONE';
//   int _remainingDays = 0;
//   int? _subscriptionId;
//
//   // ── UI state ──────────────────────────────────────────────────────────────
//   bool _loading = true;
//   bool _paymentLoading = false;
//   String? _error;
//   bool _termsAccepted = false;
//   Map<String, bool> _selectedModules = {};
//
//   // Popups
//   bool _showSuccess = false;
//   bool _showFreeTrial = false;
//   bool _showRenewalWarn = false;
//   int _countdown = 5;
//   Timer? _countdownTimer;
//
//   // Razorpay
//   late Razorpay _razorpay;
//
//   // ── Computed ──────────────────────────────────────────────────────────────
//   Map<String, List<SubModule>> get _grouped {
//     final g = <String, List<SubModule>>{};
//     for (final m in _modules) {
//       (g[m.category] ??= []).add(m);
//     }
//     return g;
//   }
//
//   double get _subTotal {
//     double total = 0;
//     for (final m in _modules) {
//       if (_selectedModules[m.code] == true) total += m.yearlyPrice;
//     }
//     return total;
//   }
//
//   double get _gst => _subTotal * 0.18;
//   double get _grandTotal => _subTotal + _gst;
//
//   List<String> get _selectedArray {
//     final list = <String>[];
//     for (final m in _modules) {
//       if (m.defaultIncluded == 'INCLUDE' || m.defaultIncluded == 'MANDATORY') {
//         list.add(m.code);
//       } else if (_selectedModules[m.code] == true) {
//         list.add(m.code);
//       }
//     }
//     return list;
//   }
//
//   List<String> get _allModulesArray => _modules.map((m) => m.code).toList();
//
//   bool get _hasSelectedModules => _selectedArray.isNotEmpty;
//
//   ProRatedDetails _getProRated() {
//     if (_activeSub == null || _activeSub!.selectedModules.isEmpty) {
//       return const ProRatedDetails();
//     }
//     final current = _activeSub!.selectedModules;
//     final next = _selectedArray;
//     final added = next.where((m) => !current.contains(m)).toList();
//     final removed = current.where((m) => !next.contains(m)).toList();
//     final daysLeft = _activeSub!.remainingDays > 0
//         ? _activeSub!.remainingDays
//         : 365;
//     double origFull = 0, proRated = 0;
//     for (final code in added) {
//       final mod = _modules.firstWhere(
//         (m) => m.code == code,
//         orElse: () => const SubModule(),
//       );
//       if (mod.defaultIncluded == 'EXCLUDE') {
//         origFull += mod.yearlyPrice;
//         proRated += (mod.yearlyPrice / 365) * daysLeft;
//       }
//     }
//     final gst = proRated * 0.18;
//     final total = proRated + gst;
//     return ProRatedDetails(
//       addedModules: added,
//       removedModules: removed,
//       originalAmount: origFull,
//       proRatedAmount: proRated,
//       gstAmount: gst,
//       totalAmount: total,
//       remainingDays: daysLeft,
//     );
//   }
//
//   ButtonConfig get _buttonConfig {
//     final c = _activeSub;
//     if (_subStatus == 'ACTIVE' && c != null) {
//       final current = c.selectedModules;
//       final next = _selectedArray;
//       final changed =
//           current.length != next.length || !current.every(next.contains);
//       if (changed) {
//         final pr = _getProRated();
//         if (pr.proRatedAmount > 0) {
//           return ButtonConfig(
//             text: 'Pay ₹${pr.totalAmount.toStringAsFixed(2)} (Pro-rated)',
//             disabled: false,
//             action: 'modify',
//             buttonColor: subPurple,
//           );
//         }
//         return ButtonConfig(
//           text: 'Update Modules (No Payment)',
//           disabled: false,
//           action: 'modify',
//           buttonColor: subGreen,
//           message: 'No additional payment required',
//         );
//       }
//       if (_remainingDays > 7) {
//         return ButtonConfig(
//           text: 'Active ($_remainingDays days left)',
//           disabled: true,
//           buttonColor: subGreen,
//           message: 'Your subscription is active until ${c.endDate ?? ""}',
//         );
//       }
//       if (_remainingDays <= 7 && _remainingDays > 0) {
//         return ButtonConfig(
//           text: 'Renew Now ($_remainingDays days left)',
//           disabled: false,
//           action: 'renew',
//           buttonColor: subAmber,
//           message: 'Your subscription expires in $_remainingDays days.',
//         );
//       }
//     }
//     if (_subStatus == 'EXPIRED') {
//       return ButtonConfig(
//         text: 'Renew Subscription',
//         disabled: false,
//         action: 'renew',
//         buttonColor: subAmber,
//         message: 'Your subscription has expired. Please renew to continue.',
//       );
//     }
//     if (_subStatus == 'NONE' || _subStatus == 'TRIAL') {
//       final canTrial = _subStatus == 'NONE';
//       if (canTrial) {
//         // check hasUsedTrial from prefs — we'll read it sync via cached value
//       }
//       return ButtonConfig(
//         text: 'Pay ₹${NumberFormat('#,##,###').format(_grandTotal.round())}',
//         disabled: false,
//         action: 'new',
//         buttonColor: subGreen,
//         message: 'Start your subscription today!',
//       );
//     }
//     return ButtonConfig(
//       text: 'Pay ₹${NumberFormat('#,##,###').format(_grandTotal.round())}',
//       disabled: false,
//       action: 'new',
//       buttonColor: subGreen,
//     );
//   }
//
//   bool _shouldShowFreeTrial = false;
//
//   // ── Init ──────────────────────────────────────────────────────────────────
//   @override
//   void initState() {
//     super.initState();
//     _razorpay = Razorpay();
//     _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onPaySuccess);
//     _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _onPayError);
//     _razorpay.on(
//       Razorpay.EVENT_EXTERNAL_WALLET,
//       (_) => setState(() => _paymentLoading = false),
//     );
//     _init();
//   }
//
//   @override
//   void dispose() {
//     _razorpay.clear();
//     _countdownTimer?.cancel();
//     super.dispose();
//   }
//
//   Future<void> _init() async {
//     setState(() {
//       _loading = true;
//       _error = null;
//     });
//     // Parallel fetch
//     final results = await Future.wait([
//       SubscriptionService.fetchPlans(),
//       SubscriptionService.fetchActiveSubscription(),
//     ]);
//     final modules = results[0] as List<SubModule>;
//     final active = results[1] as ActiveSubscription?;
//
//     final p = await SharedPreferences.getInstance();
//     final hasUsedTrial = p.getBool('hasUsedTrial') ?? false;
//
//     if (!mounted) return;
//     setState(() {
//       _modules = modules;
//       _activeSub = active;
//       _subStatus = active?.status ?? 'NONE';
//       _remainingDays = active?.remainingDays ?? 0;
//       _subscriptionId = active?.subscriptionId;
//       _loading = false;
//       _shouldShowFreeTrial = active == null && !hasUsedTrial;
//
//       // Initialise toggles
//       final initial = <String, bool>{};
//       for (final m in modules) {
//         if (m.defaultIncluded == 'INCLUDE' ||
//             m.defaultIncluded == 'MANDATORY') {
//           initial[m.code] = true;
//         } else if (active != null && active.selectedModules.contains(m.code)) {
//           initial[m.code] = true;
//         } else {
//           initial[m.code] = false;
//         }
//       }
//       _selectedModules = initial;
//     });
//   }
//
//   void _toggle(String code) => setState(
//     () => _selectedModules[code] = !(_selectedModules[code] ?? false),
//   );
//
//   // ── Actions ────────────────────────────────────────────────────────────────
//   Future<void> _handleAction() async {
//     if (!_hasSelectedModules) {
//       subSnack(context, 'Please select at least one module.', warn: true);
//       return;
//     }
//     if (!_termsAccepted) {
//       subSnack(context, 'Please accept Terms & Conditions', warn: true);
//       return;
//     }
//     final cfg = _buttonConfig;
//     if (cfg.disabled) {
//       subSnack(
//         context,
//         cfg.message ?? 'Your subscription is active.',
//         warn: true,
//       );
//       return;
//     }
//     switch (cfg.action) {
//       case 'modify':
//         await _handleModify();
//         break;
//       case 'trial':
//         setState(() => _showFreeTrial = true);
//         break;
//       case 'renew':
//         if (_subStatus == 'ACTIVE' && _remainingDays <= 7) {
//           setState(() => _showRenewalWarn = true);
//         } else {
//           await _handleConfirmPayment();
//         }
//         break;
//       default:
//         await _handleConfirmPayment();
//     }
//   }
//
//   Future<void> _handleConfirmPayment() async {
//     setState(() => _paymentLoading = true);
//     try {
//       final orderId = await SubscriptionService.createRazorpayOrder(
//         _grandTotal,
//       );
//       if (orderId == null) throw Exception('Order ID not received');
//       final cfg = _buttonConfig;
//       _razorpay.open({
//         'key': 'rzp_test_TJECsclCivENpY',
//         'amount': (_grandTotal * 1).toInt(),
//         'currency': 'INR',
//         'order_id': orderId,
//         'name': 'Maamaas Subscription',
//         'description': cfg.action == 'renew'
//             ? 'Renew Subscription'
//             : 'New Subscription',
//         'prefill': {'method': 'upi'},
//         'theme': {'color': cfg.action == 'renew' ? '#F59E0B' : '#059669'},
//       });
//     } catch (e) {
//       setState(() => _paymentLoading = false);
//       if (mounted) subSnack(context, 'Payment failed: $e', error: true);
//     }
//   }
//
//   Future<void> _handleModify() async {
//     final sid = _subscriptionId;
//     if (sid == null) {
//       subSnack(context, 'No active subscription found.', error: true);
//       return;
//     }
//     setState(() => _paymentLoading = true);
//     final pr = _getProRated();
//     if (pr.proRatedAmount > 0) {
//       // Need payment for added modules
//       try {
//         final orderId = await SubscriptionService.createRazorpayOrder(
//           pr.totalAmount,
//         );
//         if (orderId == null) throw Exception('Order ID not received');
//         _razorpay.open({
//           'key': 'rzp_test_TJECsclCivENpY',
//           'amount': (pr.totalAmount * 1).toInt(),
//           'currency': 'INR',
//           'order_id': orderId,
//           'name': 'Maamaas - Module Upgrade',
//           'description': 'Adding: ${pr.addedModules.join(', ')} (incl. GST)',
//           'theme': {'color': '#8B5CF6'},
//         });
//         // Store pending context for success handler
//         _pendingAction = 'modify';
//         _pendingProRated = pr;
//       } catch (e) {
//         setState(() => _paymentLoading = false);
//         if (mounted) subSnack(context, 'Payment failed: $e', error: true);
//       }
//     } else {
//       // No extra payment
//       final ok = await SubscriptionService.updateModules(
//         subscriptionId: sid,
//         modules: _selectedArray,
//         paymentMethod: 'Maamaas_Wallet',
//         amount: 0,
//         transactionId: 'WALLET_${DateTime.now().millisecondsSinceEpoch}',
//       );
//       setState(() => _paymentLoading = false);
//       if (mounted) {
//         subSnack(
//           context,
//           ok ? '✅ Modules updated successfully!' : '❌ Update failed',
//           error: !ok,
//         );
//         if (ok) await _init();
//       }
//     }
//   }
//
//   Future<void> _handleFreeTrial() async {
//     if (!_termsAccepted) {
//       subSnack(context, 'Please accept Terms & Conditions', warn: true);
//       return;
//     }
//     setState(() {
//       _paymentLoading = true;
//       _showFreeTrial = false;
//     });
//     final result = await SubscriptionService.startFreeTrial(_allModulesArray);
//     setState(() => _paymentLoading = false);
//     if (mounted) {
//       if (result != null) {
//         _triggerSuccess();
//       } else {
//         subSnack(context, '❌ Free trial activation failed.', error: true);
//       }
//     }
//   }
//
//   // ── Razorpay callbacks ─────────────────────────────────────────────────────
//   String? _pendingAction;
//   ProRatedDetails? _pendingProRated;
//
//   void _onPaySuccess(PaymentSuccessResponse r) async {
//     final p = await SharedPreferences.getInstance();
//     final vid =
//         p.getInt('vendorId')?.toString() ?? p.getString('vendorId') ?? '';
//     // Capture
//     await SubscriptionService.capturePayment(
//       paymentId: r.paymentId!,
//       amount: _grandTotal,
//       vendorIdStr: vid,
//     );
//
//     if (_pendingAction == 'modify') {
//       final sid = _subscriptionId;
//       if (sid != null) {
//         await SubscriptionService.updateModules(
//           subscriptionId: sid,
//           modules: _selectedArray,
//           paymentMethod: 'Online_Payment',
//           amount: _pendingProRated?.proRatedAmount ?? 0,
//           transactionId: r.paymentId!,
//         );
//       }
//       _pendingAction = null;
//       _pendingProRated = null;
//     } else {
//       // New / renew
//       final isRenew = _buttonConfig.action == 'renew';
//       await SubscriptionService.createSubscription(
//         selectedModules: _selectedArray,
//         totalAmount: _grandTotal,
//         transactionId: r.paymentId!,
//         renew: isRenew,
//       );
//     }
//     if (mounted) {
//       setState(() => _paymentLoading = false);
//       _triggerSuccess();
//     }
//   }
//
//   void _onPayError(PaymentFailureResponse r) {
//     if (mounted) {
//       setState(() => _paymentLoading = false);
//       subSnack(
//         context,
//         'Payment failed: ${r.message ?? "Please try again"}',
//         error: true,
//       );
//     }
//   }
//
//   void _triggerSuccess() {
//     setState(() {
//       _showSuccess = true;
//       _countdown = 5;
//     });
//     _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
//       if (!mounted) {
//         t.cancel();
//         return;
//       }
//       setState(() => _countdown--);
//       if (_countdown <= 0) {
//         t.cancel();
//         setState(() => _showSuccess = false);
//         _init(); // reload
//       }
//     });
//   }
//
//   // ── UI helpers ─────────────────────────────────────────────────────────────
//   String _fmt(double v) => '₹${NumberFormat('#,##,###').format(v.round())}';
//
//   @override
//   Widget build(BuildContext context) => Scaffold(
//     backgroundColor: subBg,
//     appBar: AppBar(
//       backgroundColor: subCard,
//       elevation: 0,
//       centerTitle: false,
//       leading: Navigator.canPop(context)
//           ? IconButton(
//               icon: Container(
//                 width: 36,
//                 height: 36,
//                 decoration: BoxDecoration(
//                   color: subBg,
//                   borderRadius: BorderRadius.circular(10),
//                   border: Border.all(color: subBorder),
//                 ),
//                 child: const Icon(
//                   Icons.arrow_back_ios_rounded,
//                   size: 15,
//                   color: subText1,
//                 ),
//               ),
//               onPressed: () => Navigator.pop(context),
//             )
//           : null,
//       title: const Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Subscription Plans',
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.w800,
//               color: subText1,
//               letterSpacing: -0.3,
//             ),
//           ),
//
//         ],
//       ),
//     ),
//     body: Stack(
//       children: [
//         _loading
//             ? const Center(
//                 child: CircularProgressIndicator(
//                   color: subAccent,
//                   strokeWidth: 2,
//                 ),
//               )
//             : _error != null
//             ? _buildError()
//             : _buildBody(),
//         if (_showSuccess) _buildSuccessOverlay(),
//         if (_showFreeTrial) _buildFreeTrialOverlay(),
//         if (_showRenewalWarn) _buildRenewalWarnOverlay(),
//         if (_paymentLoading) _buildLoadingOverlay(),
//       ],
//     ),
//   );
//
//   Widget _buildBody() => RefreshIndicator(
//     color: subAccent,
//     onRefresh: _init,
//     child: SingleChildScrollView(
//       physics: const AlwaysScrollableScrollPhysics(),
//       padding: const EdgeInsets.fromLTRB(14, 14, 14, 32),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Active subscription banner
//           if (_activeSub != null) _buildActiveSubBanner(),
//           const SizedBox(height: 8),
//
//           // Module groups
//           ..._buildModuleGroups(),
//
//           const SizedBox(height: 16),
//
//           // Platform usage policy
//           _buildPolicyCard(),
//           const SizedBox(height: 12),
//
//           // Vendor settlement card
//           _buildSettlementCard(),
//           const SizedBox(height: 12),
//
//           // // Pro-rated info (when modifying)
//           // _buildProRatedInfo(),
//
//           // Billing summary
//           _buildBillingSummary(),
//           const SizedBox(height: 12),
//
//           // Terms & Conditions
//           _buildTermsSection(),
//           const SizedBox(height: 16),
//
//           // Action button
//           _buildActionButton(),
//           const SizedBox(height: 24),
//         ],
//       ),
//     ),
//   );
//
//   // ── Active Subscription Banner ─────────────────────────────────────────────
//   Widget _buildActiveSubBanner() {
//     final s = _activeSub!;
//     Color bg;
//     Color fg;
//     String label;
//     switch (_subStatus) {
//       case 'TRIAL':
//         bg = subAmberL;
//         fg = subAmber;
//         label = '🎁 Free Trial Active';
//         break;
//       case 'EXPIRED':
//         bg = subRedL;
//         fg = subRed;
//         label = '⚠️ Subscription Expired';
//         break;
//       default:
//         bg = subGreenL;
//         fg = subGreen;
//         label = '✅ Subscription Active';
//         break;
//     }
//     return Container(
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: bg,
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(color: fg.withOpacity(0.3)),
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   label,
//                   style: TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w800,
//                     color: fg,
//                   ),
//                 ),
//                 const SizedBox(height: 3),
//                 Text(
//                   '${_remainingDays} days remaining${s.endDate != null ? " • Ends ${s.endDate}" : ""}',
//                   style: TextStyle(fontSize: 11, color: fg.withOpacity(0.8)),
//                 ),
//               ],
//             ),
//           ),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//             decoration: BoxDecoration(
//               color: fg.withOpacity(0.15),
//               borderRadius: BorderRadius.circular(20),
//             ),
//             child: Text(
//               _subStatus,
//               style: TextStyle(
//                 fontSize: 11,
//                 fontWeight: FontWeight.w700,
//                 color: fg,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ── Module Groups ──────────────────────────────────────────────────────────
//   List<Widget> _buildModuleGroups() {
//     final orderedCats = [
//       'BASE_PLAN',
//       'FEATURE_ADD_ON',
//       'ORDER_TYPE',
//       'ORDERTYPE_ADD_ON',
//     ];
//     final widgets = <Widget>[];
//     for (final cat in orderedCats) {
//       final mods = _grouped[cat];
//       if (mods == null || mods.isEmpty) continue;
//       final sorted = List<SubModule>.from(mods)
//         ..sort((a, b) {
//           if (a.defaultIncluded == 'MANDATORY') return -1;
//           if (b.defaultIncluded == 'MANDATORY') return 1;
//           return 0;
//         });
//       String title;
//       String? subtitle;
//       switch (cat) {
//         case 'BASE_PLAN':
//           title = 'Activate Your MAAMAAS Restaurant Platform';
//           subtitle = null;
//           break;
//         case 'FEATURE_ADD_ON':
//           title = 'Optional Feature Add-Ons';
//           subtitle = null;
//           break;
//         default:
//           title = 'Order Type Integrations';
//           subtitle = 'Activate order channels your restaurant wants to use.';
//           break;
//       }
//       widgets.add(
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               title,
//               style: const TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w800,
//                 color: subText1,
//               ),
//             ),
//             if (subtitle != null)
//               Padding(
//                 padding: const EdgeInsets.only(top: 2, bottom: 8),
//                 child: Text(
//                   subtitle,
//                   style: const TextStyle(fontSize: 12, color: subText2),
//                 ),
//               ),
//             const SizedBox(height: 8),
//             Container(
//               decoration: subCardDeco(radius: 14),
//               child: Column(
//                 children: [
//                   // Table header
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 14,
//                       vertical: 10,
//                     ),
//                     decoration: const BoxDecoration(
//                       color: subOrange,
//                       borderRadius: BorderRadius.only(
//                         topLeft: Radius.circular(14),
//                         topRight: Radius.circular(14),
//                       ),
//                     ),
//                     child: Row(
//                       children: [
//                         const Expanded(
//                           flex: 3,
//                           child: Text(
//                             'Module',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontWeight: FontWeight.w700,
//                               fontSize: 12,
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 6),
//                         Text(
//                           cat == 'ORDER_TYPE' || cat == 'ORDERTYPE_ADD_ON'
//                               ? 'Status'
//                               : 'Toggle',
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.w700,
//                             fontSize: 12,
//                           ),
//                         ),
//                         const SizedBox(width: 10),
//                         const Text(
//                           'Price/yr',
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.w700,
//                             fontSize: 12,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   ...sorted.map((m) => _buildModuleRow(m)),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 16),
//           ],
//         ),
//       );
//     }
//     return widgets;
//   }
//
//   Widget _buildModuleRow(SubModule m) {
//     final isMandatory = m.defaultIncluded == 'MANDATORY';
//     final isIncluded = m.defaultIncluded == 'INCLUDE';
//     final isSelected = _selectedModules[m.code] ?? false;
//     final isNewlyAdded =
//         _activeSub != null &&
//         isSelected &&
//         !_activeSub!.selectedModules.contains(m.code) &&
//         !isIncluded &&
//         !isMandatory;
//     final isRemoved =
//         _activeSub != null &&
//         !isSelected &&
//         _activeSub!.selectedModules.contains(m.code);
//
//     Color rowBg = isMandatory
//         ? const Color(0xFFFFF7ED)
//         : (isSelected ? const Color(0xFFF9FAFB) : subCard);
//     if (isNewlyAdded) rowBg = const Color(0xFFF0FDF4);
//     if (isRemoved) rowBg = subRedL;
//
//     return Container(
//       decoration: BoxDecoration(
//         color: rowBg,
//         border: Border(bottom: BorderSide(color: subBorder, width: 0.5)),
//       ),
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Icon + name + desc
//           Expanded(
//             flex: 3,
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Container(
//                   width: 36,
//                   height: 36,
//                   decoration: BoxDecoration(
//                     color: subAccentL,
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: Icon(
//                     subModuleIcon(m.code),
//                     size: 18,
//                     color: subAccent,
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           Expanded(
//                             child: Text(
//                               m.name,
//                               style: const TextStyle(
//                                 fontSize: 13,
//                                 fontWeight: FontWeight.w700,
//                                 color: subText1,
//                               ),
//                             ),
//                           ),
//                           if (isNewlyAdded)
//                             Container(
//                               margin: const EdgeInsets.only(left: 4),
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 5,
//                                 vertical: 2,
//                               ),
//                               decoration: BoxDecoration(
//                                 color: subGreenL,
//                                 borderRadius: BorderRadius.circular(6),
//                               ),
//                               child: const Text(
//                                 'NEW',
//                                 style: TextStyle(
//                                   fontSize: 8,
//                                   fontWeight: FontWeight.w800,
//                                   color: subGreen,
//                                 ),
//                               ),
//                             ),
//                           if (isRemoved)
//                             Container(
//                               margin: const EdgeInsets.only(left: 4),
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 5,
//                                 vertical: 2,
//                               ),
//                               decoration: BoxDecoration(
//                                 color: subRedL,
//                                 borderRadius: BorderRadius.circular(6),
//                               ),
//                               child: const Text(
//                                 'DEL',
//                                 style: TextStyle(
//                                   fontSize: 8,
//                                   fontWeight: FontWeight.w800,
//                                   color: subRed,
//                                 ),
//                               ),
//                             ),
//                         ],
//                       ),
//                       const SizedBox(height: 2),
//                       Text(
//                         m.description,
//                         style: const TextStyle(fontSize: 11, color: subText2),
//                         maxLines: 2,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(width: 8),
//           // Toggle / badge
//           if (isMandatory)
//             Transform.scale(
//               scale: 0.85,
//               child: Switch(
//                 value: _selectedModules[m.code] ?? true,
//                 activeColor: subAccent,
//                 onChanged: (_) => _toggle(m.code),
//               ),
//             )
//           else if (isIncluded)
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//               decoration: BoxDecoration(
//                 color: subGreenL,
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               child: const Text(
//                 'Included',
//                 style: TextStyle(
//                   fontSize: 10,
//                   fontWeight: FontWeight.w700,
//                   color: subGreen,
//                 ),
//               ),
//             )
//           else
//             Transform.scale(
//               scale: 0.85,
//               child: Switch(
//                 value: isSelected,
//                 activeColor: subAccent,
//                 onChanged: (_) => _toggle(m.code),
//               ),
//             ),
//           const SizedBox(width: 8),
//           // Price
//           SizedBox(
//             width: 56,
//             child: Text(
//               isIncluded ? '—' : '₹${m.yearlyPrice.toInt()}',
//               style: TextStyle(
//                 fontSize: 13,
//                 fontWeight: FontWeight.w700,
//                 color: isIncluded ? subText3 : subAccent,
//               ),
//               textAlign: TextAlign.right,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ── Policy Card ────────────────────────────────────────────────────────────
//   Widget _buildPolicyCard() => Container(
//     decoration: subCardDeco(
//       border: const Color(0xFFFACC15),
//       color: const Color(0xFFFFFBEB),
//       radius: 14,
//     ),
//     padding: const EdgeInsets.all(16),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Container(
//               width: 34,
//               height: 34,
//               decoration: BoxDecoration(
//                 color: const Color(0xFFFEF3C7),
//                 shape: BoxShape.circle,
//               ),
//               child: const Center(
//                 child: Text(
//                   'i',
//                   style: TextStyle(
//                     fontWeight: FontWeight.w800,
//                     color: Color(0xFFB45309),
//                     fontSize: 16,
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(width: 10),
//             const Text(
//               'MAAMAAS Platform Usage Policy',
//               style: TextStyle(
//                 fontSize: 15,
//                 fontWeight: FontWeight.w800,
//                 color: subText1,
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 12),
//         _policySection('MAAMAAS Platform Usage Policy (Credit Model)', [
//           'MAAMAAS follows an Earn Now, Pay Later model with a predefined credit limit for each vendor.',
//           'All platform charges (commissions, service fees) are automatically added to the vendor\'s outstanding balance.',
//           'Vendors must clear dues within the billing cycle to continue smooth operations.',
//           'If the credit limit is reached, Cash and UPI payment options will be disabled until pending dues are paid.',
//         ]),
//         const SizedBox(height: 8),
//         _policySection('Order Processing Fees', [
//           'Dine-In Orders → 0.5% per order',
//           'Takeaway Orders → 0.5% per order',
//         ]),
//         const SizedBox(height: 8),
//         _policySection('Tax Policy', [
//           'All applicable platform charges are subject to GST, as per government regulations.',
//         ]),
//       ],
//     ),
//   );
//
//   Widget _policySection(String title, List<String> items) => Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       Text(
//         title,
//         style: const TextStyle(
//           fontSize: 13,
//           fontWeight: FontWeight.w700,
//           color: subText1,
//         ),
//       ),
//       const SizedBox(height: 4),
//       ...items.map(
//         (i) => Padding(
//           padding: const EdgeInsets.only(left: 12, bottom: 3),
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text('• ', style: TextStyle(color: subText2, fontSize: 12)),
//               Expanded(
//                 child: Text(
//                   i,
//                   style: const TextStyle(
//                     fontSize: 12,
//                     color: subText2,
//                     height: 1.5,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     ],
//   );
//
//   // ── Settlement Card ────────────────────────────────────────────────────────
//   Widget _buildSettlementCard() => Container(
//     decoration: subCardDeco(
//       border: const Color(0xFF93C5FD),
//       color: subBlueL,
//       radius: 14,
//     ),
//     padding: const EdgeInsets.all(16),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Container(
//               width: 38,
//               height: 38,
//               decoration: BoxDecoration(
//                 color: const Color(0xFFDBEAFE),
//                 shape: BoxShape.circle,
//               ),
//               child: const Center(
//                 child: Text(
//                   '₹',
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.w800,
//                     color: subBlue,
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(width: 12),
//             const Text(
//               'Vendor Payment Settlement',
//               style: TextStyle(
//                 fontSize: 15,
//                 fontWeight: FontWeight.w800,
//                 color: Color(0xFF1E293B),
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 10),
//         const Text(
//           'Customer payments collected through the MAAMAAS platform are processed through a secure payment gateway.\n\n'
//           'Vendor earnings will be transferred after successful payment confirmation. '
//           'Settlement Timeline: Within 48 working hours.\n\n'
//           'Vendors can track settlements and transaction reports in the Accounts & Finance Dashboard.',
//           style: TextStyle(fontSize: 13, color: Color(0xFF475569), height: 1.6),
//         ),
//       ],
//     ),
//   );
//
//   // ── Pro-rated Info ─────────────────────────────────────────────────────────
//   // Widget _buildProRatedInfo() {
//   //   if (_subStatus != 'ACTIVE' || _activeSub == null) return const SizedBox();
//   //   final pr = _getProRated();
//   //   if (pr.addedModules.isEmpty) return const SizedBox();
//   //   return Container(
//   //     margin: const EdgeInsets.only(bottom: 12),
//   //     decoration: subCardDeco(
//   //       border: subPurple.withOpacity(0.4),
//   //       color: subPurpleL,
//   //       radius: 12,
//   //     ),
//   //     padding: const EdgeInsets.all(14),
//   //     child: Column(
//   //       crossAxisAlignment: CrossAxisAlignment.start,
//   //       children: [
//   //         const Text(
//   //           'Pricing for Remaining Period',
//   //           style: TextStyle(
//   //             fontSize: 14,
//   //             fontWeight: FontWeight.w800,
//   //             color: Color(0xFF5B21B6),
//   //           ),
//   //         ),
//   //         const SizedBox(height: 6),
//   //         Text(
//   //           'You have ${pr.remainingDays} days remaining. You\'ll only pay for the remaining period.',
//   //           style: const TextStyle(fontSize: 12, color: Color(0xFF4C1D95)),
//   //         ),
//   //         const SizedBox(height: 10),
//   //         Container(
//   //           decoration: BoxDecoration(
//   //             color: subCard,
//   //             borderRadius: BorderRadius.circular(8),
//   //           ),
//   //           padding: const EdgeInsets.all(12),
//   //           child: Column(
//   //             children: [
//   //               ...pr.addedModules.map((code) {
//   //                 final mod = _modules.firstWhere(
//   //                   (m) => m.code == code,
//   //                   orElse: () => const SubModule(),
//   //                 );
//   //                 final proRated = (mod.yearlyPrice / 365) * pr.remainingDays;
//   //                 return Padding(
//   //                   padding: const EdgeInsets.only(bottom: 8),
//   //                   child: Row(
//   //                     children: [
//   //                       Expanded(
//   //                         child: Text(
//   //                           mod.name.isEmpty ? code : mod.name,
//   //                           style: const TextStyle(
//   //                             fontSize: 12,
//   //                             color: subText1,
//   //                           ),
//   //                         ),
//   //                       ),
//   //                       Text(
//   //                         '₹${mod.yearlyPrice.toInt()}/yr',
//   //                         style: const TextStyle(
//   //                           fontSize: 11,
//   //                           color: subText3,
//   //                           decoration: TextDecoration.lineThrough,
//   //                         ),
//   //                       ),
//   //                       const SizedBox(width: 8),
//   //                       Text(
//   //                         '₹${proRated.toStringAsFixed(2)}',
//   //                         style: const TextStyle(
//   //                           fontSize: 12,
//   //                           fontWeight: FontWeight.w700,
//   //                           color: subPurple,
//   //                         ),
//   //                       ),
//   //                     ],
//   //                   ),
//   //                 );
//   //               }),
//   //               const Divider(color: subBorder),
//   //               _proRow(
//   //                 'Original Full Year Price',
//   //                 '₹${pr.originalAmount.toStringAsFixed(2)}',
//   //               ),
//   //               _proRow(
//   //                 'Pro-rated (${pr.remainingDays} days)',
//   //                 '₹${pr.proRatedAmount.toStringAsFixed(2)}',
//   //               ),
//   //               _proRow('GST (18%)', '₹${pr.gstAmount.toStringAsFixed(2)}'),
//   //               const Divider(color: subBorder),
//   //               Row(
//   //                 children: [
//   //                   const Expanded(
//   //                     child: Text(
//   //                       'Total Payable Now',
//   //                       style: TextStyle(
//   //                         fontSize: 13,
//   //                         fontWeight: FontWeight.w800,
//   //                         color: Color(0xFF5B21B6),
//   //                       ),
//   //                     ),
//   //                   ),
//   //                   Text(
//   //                     '₹${pr.totalAmount.toStringAsFixed(2)}',
//   //                     style: const TextStyle(
//   //                       fontSize: 14,
//   //                       fontWeight: FontWeight.w900,
//   //                       color: subPurple,
//   //                     ),
//   //                   ),
//   //                 ],
//   //               ),
//   //               const SizedBox(height: 8),
//   //               Container(
//   //                 padding: const EdgeInsets.all(8),
//   //                 decoration: BoxDecoration(
//   //                   color: subAmberL,
//   //                   borderRadius: BorderRadius.circular(6),
//   //                 ),
//   //                 child: const Text(
//   //                   '💡 Note: When you renew next year, you\'ll pay the full yearly price for all modules.',
//   //                   style: TextStyle(fontSize: 11, color: Color(0xFF92400E)),
//   //                 ),
//   //               ),
//   //             ],
//   //           ),
//   //         ),
//   //       ],
//   //     ),
//   //   );
//   // }
//   //
//   Widget _proRow(String label, String value) => Padding(
//     padding: const EdgeInsets.symmetric(vertical: 3),
//     child: Row(
//       children: [
//         Expanded(
//           child: Text(
//             label,
//             style: const TextStyle(fontSize: 12, color: subText2),
//           ),
//         ),
//         Text(
//           value,
//           style: const TextStyle(
//             fontSize: 12,
//             fontWeight: FontWeight.w600,
//             color: subText1,
//           ),
//         ),
//       ],
//     ),
//   );
//
//   // ── Billing Summary ────────────────────────────────────────────────────────
//   Widget _buildBillingSummary() {
//     final pr = (_subStatus == 'ACTIVE' && _activeSub != null)
//         ? _getProRated()
//         : null;
//     final showProRated = pr != null && pr.addedModules.isNotEmpty;
//     final displayAmount = showProRated ? pr!.totalAmount : _grandTotal;
//
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: subGreenL,
//         borderRadius: BorderRadius.circular(14),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             _subStatus == 'ACTIVE' && _activeSub != null
//                 ? 'Total Payable for remaining days'
//                 : 'Total Payable (Yearly)',
//             style: const TextStyle(fontSize: 12, color: Color(0xFF065F46)),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             showProRated
//                 ? '₹${displayAmount.toStringAsFixed(2)}'
//                 : _fmt(displayAmount),
//             style: const TextStyle(
//               fontSize: 28,
//               fontWeight: FontWeight.w800,
//               color: Color(0xFF065F46),
//             ),
//           ),
//           if (!showProRated) ...[
//             const SizedBox(height: 8),
//             _summaryRow('Subtotal', _fmt(_subTotal)),
//             _summaryRow('GST (18%)', _fmt(_gst)),
//             const Divider(color: Color(0xFFA7F3D0), thickness: 1),
//             _summaryRow('Grand Total', _fmt(_grandTotal), bold: true),
//           ],
//         ],
//       ),
//     );
//   }
//
//   Widget _summaryRow(String label, String val, {bool bold = false}) => Padding(
//     padding: const EdgeInsets.symmetric(vertical: 2),
//     child: Row(
//       children: [
//         Expanded(
//           child: Text(
//             label,
//             style: TextStyle(
//               fontSize: 13,
//               fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
//               color: const Color(0xFF065F46),
//             ),
//           ),
//         ),
//         Text(
//           val,
//           style: TextStyle(
//             fontSize: 13,
//             fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
//             color: const Color(0xFF065F46),
//           ),
//         ),
//       ],
//     ),
//   );
//
//   // ── Terms Section ──────────────────────────────────────────────────────────
//   Widget _buildTermsSection() => Container(
//     padding: const EdgeInsets.all(14),
//     decoration: subCardDeco(radius: 12),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Transform.scale(
//               scale: 0.9,
//               child: Checkbox(
//                 value: _termsAccepted,
//                 activeColor: subAccent,
//                 onChanged: (v) => setState(() => _termsAccepted = v ?? false),
//               ),
//             ),
//             const SizedBox(width: 4),
//             const Expanded(
//               child: Text(
//                 'I confirm that I have read and agree to the MAAMAAS Terms & Conditions, '
//                 'Platform Usage Policy, Catering Lead Policy, and Vendor Settlement Terms.',
//                 style: TextStyle(fontSize: 13, color: subText1, height: 1.5),
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 8),
//         ...const [
//           'Subscription fee is for account activation only',
//           'Platform commissions or service charges may apply',
//           'Vendor payments are settled within 48 working hours',
//           'All charges are calculated with GST',
//         ].map(
//           (t) => Padding(
//             padding: const EdgeInsets.only(left: 14, bottom: 3),
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   '• ',
//                   style: TextStyle(color: subText2, fontSize: 11),
//                 ),
//                 Expanded(
//                   child: Text(
//                     t,
//                     style: const TextStyle(fontSize: 11, color: subText2),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     ),
//   );
//
//   // ── Action Button ──────────────────────────────────────────────────────────
//   Widget _buildActionButton() {
//     final cfg = _buttonConfig;
//     Color btnColor = cfg.buttonColor;
//     if (!_termsAccepted || _paymentLoading)
//       btnColor = btnColor.withOpacity(0.5);
//
//     return Column(
//       children: [
//         if (cfg.message != null && !cfg.disabled)
//           Padding(
//             padding: const EdgeInsets.only(bottom: 8),
//             child: Text(
//               cfg.message!,
//               style: TextStyle(
//                 fontSize: 13,
//                 color: cfg.buttonColor,
//                 fontWeight: FontWeight.w500,
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ),
//
//         if (_shouldShowFreeTrial && _subStatus == 'NONE') ...[
//           // Free trial button
//           SizedBox(
//             width: double.infinity,
//             child: ElevatedButton(
//               onPressed: (!_termsAccepted || _paymentLoading)
//                   ? null
//                   : () => setState(() => _showFreeTrial = true),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFFF57C00),
//                 foregroundColor: Colors.white,
//                 padding: const EdgeInsets.symmetric(vertical: 16),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(14),
//                 ),
//                 elevation: 0,
//               ),
//               child: const Text(
//                 'Start 7-Day Free Trial',
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
//               ),
//             ),
//           ),
//           const SizedBox(height: 8),
//           const Text('— OR —', style: TextStyle(color: subText3, fontSize: 12)),
//           const SizedBox(height: 8),
//         ],
//
//         SizedBox(
//           width: double.infinity,
//           child: ElevatedButton(
//             onPressed:
//                 (cfg.disabled ||
//                     _paymentLoading ||
//                     !_termsAccepted ||
//                     !_hasSelectedModules)
//                 ? null
//                 : _handleAction,
//             style: ElevatedButton.styleFrom(
//               backgroundColor: btnColor,
//               foregroundColor: Colors.white,
//               padding: const EdgeInsets.symmetric(vertical: 16),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(14),
//               ),
//               elevation: 0,
//               disabledBackgroundColor: cfg.disabled
//                   ? btnColor.withOpacity(0.6)
//                   : subBorder,
//               disabledForegroundColor: Colors.white70,
//             ),
//             child: _paymentLoading
//                 ? const SizedBox(
//                     width: 22,
//                     height: 22,
//                     child: CircularProgressIndicator(
//                       color: Colors.white,
//                       strokeWidth: 2,
//                     ),
//                   )
//                 : Text(
//                     !_hasSelectedModules
//                         ? 'Select Modules to Continue'
//                         : cfg.text,
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w700,
//                     ),
//                   ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   // ── Overlays ───────────────────────────────────────────────────────────────
//   Widget _buildSuccessOverlay() => Positioned.fill(
//     child: Container(
//       color: Colors.black54,
//       child: Center(
//         child: Container(
//           margin: const EdgeInsets.symmetric(horizontal: 24),
//           padding: const EdgeInsets.all(28),
//           decoration: BoxDecoration(
//             color: subCard,
//             borderRadius: BorderRadius.circular(20),
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const Text('🎉', style: TextStyle(fontSize: 48)),
//               const SizedBox(height: 10),
//               const Text(
//                 'Payment Successful!',
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.w800,
//                   color: subGreen,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               const Text(
//                 'Your subscription has been activated successfully.',
//                 style: TextStyle(fontSize: 14, color: subText2),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 14),
//               Text(
//                 'Refreshing in ${_countdown}s...',
//                 style: const TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.w800,
//                   color: subPurple,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     ),
//   );
//
//   Widget _buildFreeTrialOverlay() => Positioned.fill(
//     child: GestureDetector(
//       onTap: () => setState(() => _showFreeTrial = false),
//       child: Container(
//         color: Colors.black54,
//         child: Center(
//           child: GestureDetector(
//             onTap: () {},
//             child: Container(
//               margin: const EdgeInsets.symmetric(horizontal: 24),
//               padding: const EdgeInsets.all(24),
//               decoration: BoxDecoration(
//                 color: subCard,
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   const Text(
//                     '🎁 Start 7-Day Free Trial',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.w800,
//                       color: Color(0xFFF57C00),
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   const Text(
//                     'You are about to start a 7-day free trial with all modules included.\n\nNo payment required.',
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: subText2,
//                       height: 1.6,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                   const SizedBox(height: 20),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: ElevatedButton(
//                           onPressed: _paymentLoading ? null : _handleFreeTrial,
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: _termsAccepted
//                                 ? const Color(0xFFF57C00)
//                                 : subBorder,
//                             foregroundColor: Colors.white,
//                             padding: const EdgeInsets.symmetric(vertical: 14),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                           ),
//                           child: Text(
//                             _paymentLoading
//                                 ? 'Processing...'
//                                 : 'Start Free Trial',
//                             style: const TextStyle(fontWeight: FontWeight.w700),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 10),
//                       Expanded(
//                         child: ElevatedButton(
//                           onPressed: () =>
//                               setState(() => _showFreeTrial = false),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: subRed,
//                             foregroundColor: Colors.white,
//                             padding: const EdgeInsets.symmetric(vertical: 14),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                           ),
//                           child: const Text(
//                             'Cancel',
//                             style: TextStyle(fontWeight: FontWeight.w700),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     ),
//   );
//
//   Widget _buildRenewalWarnOverlay() => Positioned.fill(
//     child: GestureDetector(
//       onTap: () => setState(() => _showRenewalWarn = false),
//       child: Container(
//         color: Colors.black54,
//         child: Center(
//           child: GestureDetector(
//             onTap: () {},
//             child: Container(
//               margin: const EdgeInsets.symmetric(horizontal: 24),
//               padding: const EdgeInsets.all(24),
//               decoration: BoxDecoration(
//                 color: subCard,
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   const Text(
//                     '⚠️ Early Renewal Warning',
//                     style: TextStyle(
//                       fontSize: 17,
//                       fontWeight: FontWeight.w800,
//                       color: subAmber,
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   Text(
//                     'Your current plan is still valid for $_remainingDays more days.\n\nIf you renew now, your new subscription will start immediately.',
//                     style: const TextStyle(
//                       fontSize: 13,
//                       color: subText2,
//                       height: 1.6,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                   const SizedBox(height: 20),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: ElevatedButton(
//                           onPressed: () {
//                             setState(() => _showRenewalWarn = false);
//                             _handleConfirmPayment();
//                           },
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: subAmber,
//                             foregroundColor: Colors.white,
//                             padding: const EdgeInsets.symmetric(vertical: 14),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                           ),
//                           child: const Text(
//                             'Yes, Renew Now',
//                             style: TextStyle(fontWeight: FontWeight.w700),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 10),
//                       Expanded(
//                         child: ElevatedButton(
//                           onPressed: () =>
//                               setState(() => _showRenewalWarn = false),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: const Color(0xFF64748B),
//                             foregroundColor: Colors.white,
//                             padding: const EdgeInsets.symmetric(vertical: 14),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                           ),
//                           child: const Text(
//                             'Cancel',
//                             style: TextStyle(fontWeight: FontWeight.w700),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     ),
//   );
//
//   Widget _buildLoadingOverlay() => Positioned.fill(
//     child: Container(
//       color: Colors.black26,
//       child: const Center(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             CircularProgressIndicator(color: subAccent, strokeWidth: 3),
//             SizedBox(height: 14),
//             Text(
//               'Processing...',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.w600,
//                 fontSize: 14,
//               ),
//             ),
//           ],
//         ),
//       ),
//     ),
//   );
//
//   Widget _buildError() => Center(
//     child: Padding(
//       padding: const EdgeInsets.all(24),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const Icon(Icons.error_outline_rounded, size: 52, color: subRed),
//           const SizedBox(height: 14),
//           const Text(
//             'Error Loading Plans',
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w700,
//               color: subText1,
//             ),
//           ),
//           const SizedBox(height: 6),
//           Text(
//             _error ?? 'Please try again.',
//             style: const TextStyle(fontSize: 13, color: subText2),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 20),
//           ElevatedButton.icon(
//             onPressed: _init,
//             icon: const Icon(Icons.refresh_rounded),
//             label: const Text('Retry'),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: subBlue,
//               foregroundColor: Colors.white,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//             ),
//           ),
//         ],
//       ),
//     ),
//   );
// }
