// //
// // import 'package:flutter/material.dart';
// // import 'package:shared_preferences/shared_preferences.dart';
// // import '../models/models.dart';
// // import '../services/api_service.dart';
// // import '../widgets/theme.dart';
// //
// // // ── Order type display config ──────────────────────────────────────────────────
// // const _kOrderTypes = [
// //   _OrderTypeMeta(
// //     value: 'DINE_IN',
// //     label: 'Dine In',
// //     icon: Icons.restaurant_outlined,
// //   ),
// //   _OrderTypeMeta(
// //     value: 'TABLE_DINE_IN',
// //     label: 'Table Dine In',
// //     icon: Icons.table_restaurant_outlined,
// //   ),
// //   _OrderTypeMeta(
// //     value: 'TAKEAWAY',
// //     label: 'Takeaway',
// //     icon: Icons.shopping_bag_outlined,
// //   ),
// //   _OrderTypeMeta(
// //     value: 'DELIVERY',
// //     label: 'Delivery',
// //     icon: Icons.delivery_dining_outlined,
// //   ),
// //   _OrderTypeMeta(
// //     value: 'CATERING',
// //     label: 'Catering',
// //     icon: Icons.set_meal_outlined,
// //   ),
// // ];
// //
// // class _OrderTypeMeta {
// //   final String value, label;
// //   final IconData icon;
// //   const _OrderTypeMeta({
// //     required this.value,
// //     required this.label,
// //     required this.icon,
// //   });
// // }
// //
// // // ── Payment mode display config ────────────────────────────────────────────────
// // const _kPaymentModes = [
// //   _PaymentModeMeta(key: 'cash', label: 'Cash', icon: Icons.payments_outlined),
// //   _PaymentModeMeta(
// //     key: 'qrCode',
// //     label: 'QR Code',
// //     icon: Icons.qr_code_outlined,
// //   ),
// //   _PaymentModeMeta(
// //     key: 'upi',
// //     label: 'UPI',
// //     icon: Icons.account_balance_outlined,
// //   ),
// //   _PaymentModeMeta(
// //     key: 'splitBilling',
// //     label: 'Split Billing',
// //     icon: Icons.call_split_outlined,
// //   ),
// //   _PaymentModeMeta(key: 'zoom', label: 'kotPrintSize ', icon: Icons.zoom_in_outlined),
// // ];
// //
// // class _PaymentModeMeta {
// //   final String key, label;
// //   final IconData icon;
// //   const _PaymentModeMeta({
// //     required this.key,
// //     required this.label,
// //     required this.icon,
// //   });
// // }
// //
// // // ─────────────────────────────────────────────────────────────────────────────
// // class BillingSetupScreen extends StatefulWidget {
// //   const BillingSetupScreen({super.key});
// //   @override
// //   State<BillingSetupScreen> createState() => _BillingSetupScreenState();
// // }
// //
// // class _BillingSetupScreenState extends State<BillingSetupScreen> {
// //   BillingConfig? _config;
// //   bool _loading = true;
// //   String? _error;
// //   List<String> _selectedModules = [];
// //   // ── Per-card saving states ──────────────────────────────────────────────────
// //   bool _savingServiceCharge = false;
// //   bool _savingPaymentModes = false;
// //   bool _savingOrderTypes = false;
// //
// //   final _pctCtrl = TextEditingController();
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _load();
// //   }
// //
// //
// //   @override
// //   void dispose() {
// //     _pctCtrl.dispose();
// //     super.dispose();
// //   }
// //
// //   // ── Load config ─────────────────────────────────────────────────────────────
// //   Future<void> _load() async {
// //     setState(() {
// //       _loading = true;
// //       _error = null;
// //     });
// //     try {
// //       // 👇 ADD THIS: Read selected modules from SharedPreferences
// //       final prefs = await SharedPreferences.getInstance();
// //       _selectedModules = prefs.getStringList('selectedModules') ?? [];
// //
// //       // Your existing code continues...
// //       final c = await BillingApi.fetch();
// //       if (mounted) {
// //         setState(() {
// //           _config = c ?? BillingConfig();
// //           final sc = _config!.serviceCharges;
// //           _pctCtrl.text = sc > 0
// //               ? (sc == sc.truncateToDouble()
// //               ? sc.toInt().toString()
// //               : sc.toString())
// //               : '';
// //           _loading = false;
// //         });
// //       }
// //     } catch (e) {
// //       if (mounted) {
// //         setState(() {
// //           _config = BillingConfig();
// //           _error = e.toString();
// //           _loading = false;
// //         });
// //       }
// //     }
// //   }
// //
// //   // ── Shared save logic — called by each card's Save button ───────────────────
// //
// //   Future<void> _saveSection(String section) async {
// //     if (_config == null) return;
// //
// //     // ── Per-section validation ────────────────────────────────────────────────
// //     if (section == 'orderTypes' && _config!.orderTypes.isEmpty) {
// //       showWarning(context, 'Please select at least one order type');
// //       return;
// //     }
// //     if (section == 'paymentModes' &&
// //         !_config!.cash &&
// //         !_config!.qrCode &&
// //         !_config!.upi) {
// //       showWarning(context, 'Please select at least one payment mode');
// //       return;
// //     }
// //
// //     // ── Flip only the relevant loading flag ───────────────────────────────────
// //     setState(() {
// //       if (section == 'serviceCharge') _savingServiceCharge = true;
// //       if (section == 'paymentModes') _savingPaymentModes = true;
// //       if (section == 'orderTypes') _savingOrderTypes = true;
// //     });
// //
// //     try {
// //       // Always compute service-charge derived fields before saving
// //       final pct = double.tryParse(_pctCtrl.text) ?? 0;
// //       _config!.serviceCharges = _config!.serviceChargeEnabled ? pct : 0;
// //       _config!.serviceChargesType = _config!.serviceChargeEnabled
// //           ? 'CUSTOMER_PAYABLE'
// //           : 'BUSINESS_BORNE';
// //       _config!.serviceChargesApply = _config!.serviceChargeEnabled
// //           ? 'Applicable'
// //           : 'Not_Applicable';
// //       _config!.platformChargeType = 'BUSINESS_BORNE';
// //
// //       await BillingApi.save(_config!);
// //
// //       if (mounted) {
// //         showSuccess(context, 'Saved ✅');
// //         await _load();
// //       }
// //     } catch (e) {
// //       if (mounted) showError(context, 'Failed: $e');
// //     } finally {
// //       if (mounted) {
// //         setState(() {
// //           _savingServiceCharge = false;
// //           _savingPaymentModes = false;
// //           _savingOrderTypes = false;
// //         });
// //       }
// //     }
// //   }
// //
// //   // ── Payment mode helpers ────────────────────────────────────────────────────
// //   bool _pmValue(String key) {
// //     switch (key) {
// //       case 'cash':
// //         return _config!.cash;
// //       case 'qrCode':
// //         return _config!.qrCode;
// //       case 'upi':
// //         return _config!.upi;
// //       case 'splitBilling':
// //         return _config!.splitBilling;
// //       case 'zoom':
// //         return _config!.zoom;
// //       default:
// //         return false;
// //     }
// //   }
// //
// //   void _pmToggle(String key, bool v) {
// //     switch (key) {
// //       case 'cash':
// //         _config!.cash = v;
// //       case 'qrCode':
// //         _config!.qrCode = v;
// //       case 'upi':
// //         _config!.upi = v;
// //       case 'splitBilling':
// //         _config!.splitBilling = v;
// //       case 'zoom':
// //         _config!.zoom = v;
// //     }
// //   }
// //
// //   bool get _allPaymentSelected =>
// //       _config!.cash &&
// //       _config!.qrCode &&
// //       _config!.upi &&
// //       _config!.splitBilling &&
// //       _config!.zoom;
// //
// //   bool get _somePaymentSelected =>
// //       _config!.cash ||
// //       _config!.qrCode ||
// //       _config!.upi ||
// //       _config!.splitBilling ||
// //       _config!.zoom;
// //
// //   // ── Build ───────────────────────────────────────────────────────────────────
// //   @override
// //   Widget build(BuildContext context) {
// //     if (_loading) {
// //       return const Center(child: CircularProgressIndicator(color: kPrimary));
// //     }
// //
// //     final bottomPad = MediaQuery.of(context).padding.bottom;
// //
// //     return RefreshIndicator(
// //       color: kPrimary,
// //       onRefresh: _load,
// //       child: ListView(
// //         padding: EdgeInsets.fromLTRB(16, 12, 16, bottomPad + 24),
// //         children: [
// //           // ── Error banner ──────────────────────────────────────────────────
// //           if (_error != null) ...[
// //             Container(
// //               margin: const EdgeInsets.only(bottom: 12),
// //               padding: const EdgeInsets.all(12),
// //               decoration: BoxDecoration(
// //                 color: kWarning.withOpacity(0.08),
// //                 borderRadius: BorderRadius.circular(10),
// //                 border: Border.all(color: kWarning.withOpacity(0.3)),
// //               ),
// //               child: Row(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   const Icon(Icons.info_outline, color: kWarning, size: 16),
// //                   const SizedBox(width: 8),
// //                   Expanded(
// //                     child: Text(
// //                       'Could not load config — using defaults.\n$_error',
// //                       style: const TextStyle(fontSize: 11, color: kText2),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ],
// //
// //           // ── Header card (no Save button — informational only) ────────────
// //           KCard(
// //             leftBorderColor: kPrimary,
// //             child: const Row(
// //               crossAxisAlignment: CrossAxisAlignment.center,
// //               children: [
// //                 Expanded(
// //                   child: Column(
// //                     crossAxisAlignment: CrossAxisAlignment.start,
// //                     children: [
// //                       KSectionTitle('Billing Configuration'),
// //                       SizedBox(height: 4),
// //                       Text(
// //                         'Configure charges & order types',
// //                         style: TextStyle(fontSize: 12, color: kText2),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //           const SizedBox(height: 14),
// //
// //           // ── Service Charge card ───────────────────────────────────────────
// //           KCard(
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 // Header row — icon + title + switch + Save
// //                 Row(
// //                   children: [
// //                     const SizedBox(width: 12),
// //                     const Expanded(
// //                       child: Column(
// //                         crossAxisAlignment: CrossAxisAlignment.start,
// //                         children: [
// //                           Text(
// //                             'Service Charge',
// //                             style: TextStyle(
// //                               fontSize: 15,
// //                               fontWeight: FontWeight.w700,
// //                               color: kText1,
// //                             ),
// //                           ),
// //                           SizedBox(height: 2),
// //                         ],
// //                       ),
// //                     ),
// //                     // Switch
// //                     Switch(
// //                       value: _config!.serviceChargeEnabled,
// //                       onChanged: (v) =>
// //                           setState(() => _config!.serviceChargeEnabled = v),
// //                       activeColor: kPrimary,
// //                     ),
// //                     const SizedBox(width: 4),
// //                     // ── Save button — top-right of this card ──────────────
// //                     KBtn(
// //                       label: 'Save',
// //                       icon: Icons.save_outlined,
// //                       loading: _savingServiceCharge,
// //                       onPressed: () => _saveSection('serviceCharge'),
// //                     ),
// //                   ],
// //                 ),
// //
// //                 // Expandable percentage row
// //                 AnimatedSize(
// //                   duration: const Duration(milliseconds: 280),
// //                   curve: Curves.easeInOut,
// //                   child: _config!.serviceChargeEnabled
// //                       ? Column(
// //                           crossAxisAlignment: CrossAxisAlignment.start,
// //                           children: [
// //                             const SizedBox(height: 16),
// //                             const Divider(color: kBorder, height: 1),
// //                             const SizedBox(height: 14),
// //                             const Text(
// //                               'Service Charge %',
// //                               style: TextStyle(
// //                                 fontSize: 13,
// //                                 fontWeight: FontWeight.w700,
// //                                 color: kText1,
// //                               ),
// //                             ),
// //                             const SizedBox(height: 8),
// //                             Row(
// //                               children: [
// //                                 Expanded(
// //                                   child: TextField(
// //                                     controller: _pctCtrl,
// //                                     keyboardType:
// //                                         const TextInputType.numberWithOptions(
// //                                           decimal: true,
// //                                         ),
// //                                     style: const TextStyle(
// //                                       fontSize: 20,
// //                                       fontWeight: FontWeight.w800,
// //                                       color: kPrimary,
// //                                     ),
// //                                     decoration: InputDecoration(
// //                                       hintText: '0',
// //                                       suffixText: '%',
// //                                       suffixStyle: const TextStyle(
// //                                         fontSize: 16,
// //                                         fontWeight: FontWeight.w700,
// //                                         color: kPrimary,
// //                                       ),
// //                                       border: OutlineInputBorder(
// //                                         borderRadius: BorderRadius.circular(10),
// //                                       ),
// //                                       focusedBorder: OutlineInputBorder(
// //                                         borderRadius: BorderRadius.circular(10),
// //                                         borderSide: const BorderSide(
// //                                           color: kPrimary,
// //                                           width: 2,
// //                                         ),
// //                                       ),
// //                                       contentPadding:
// //                                           const EdgeInsets.symmetric(
// //                                             horizontal: 14,
// //                                             vertical: 14,
// //                                           ),
// //                                     ),
// //                                     onChanged: (_) => setState(() {}),
// //                                   ),
// //                                 ),
// //                                 const SizedBox(width: 14),
// //                                 Container(
// //                                   padding: const EdgeInsets.symmetric(
// //                                     horizontal: 14,
// //                                     vertical: 12,
// //                                   ),
// //                                   decoration: BoxDecoration(
// //                                     color: kPrimaryLight,
// //                                     borderRadius: BorderRadius.circular(10),
// //                                     border: Border.all(
// //                                       color: kPrimary.withOpacity(0.3),
// //                                     ),
// //                                   ),
// //                                   child: Column(
// //                                     children: [
// //                                       const Text(
// //                                         'On ₹1000',
// //                                         style: TextStyle(
// //                                           fontSize: 10,
// //                                           color: kText2,
// //                                         ),
// //                                       ),
// //                                       const SizedBox(height: 4),
// //                                       Text(
// //                                         '+₹${((double.tryParse(_pctCtrl.text) ?? 0) * 10).toStringAsFixed(0)}',
// //                                         style: const TextStyle(
// //                                           fontSize: 16,
// //                                           fontWeight: FontWeight.w800,
// //                                           color: kPrimary,
// //                                         ),
// //                                       ),
// //                                     ],
// //                                   ),
// //                                 ),
// //                               ],
// //                             ),
// //                           ],
// //                         )
// //                       : const SizedBox.shrink(),
// //                 ),
// //
// //                 const SizedBox(height: 14),
// //
// //                 // Status badge
// //                 AnimatedContainer(
// //                   duration: const Duration(milliseconds: 200),
// //                   padding: const EdgeInsets.symmetric(
// //                     horizontal: 12,
// //                     vertical: 6,
// //                   ),
// //                   decoration: BoxDecoration(
// //                     color: _config!.serviceChargeEnabled
// //                         ? kSuccess.withOpacity(0.1)
// //                         : kDanger.withOpacity(0.08),
// //                     borderRadius: BorderRadius.circular(20),
// //                     border: Border.all(
// //                       color: _config!.serviceChargeEnabled
// //                           ? kSuccess.withOpacity(0.3)
// //                           : kDanger.withOpacity(0.2),
// //                     ),
// //                   ),
// //                   child: Row(
// //                     mainAxisSize: MainAxisSize.min,
// //                     children: [
// //                       Icon(
// //                         _config!.serviceChargeEnabled
// //                             ? Icons.check_circle_outline
// //                             : Icons.cancel_outlined,
// //                         size: 14,
// //                         color: _config!.serviceChargeEnabled
// //                             ? kSuccess
// //                             : kDanger,
// //                       ),
// //                       const SizedBox(width: 6),
// //                       Text(
// //                         _config!.serviceChargeEnabled
// //                             ? 'Service charge enabled'
// //                             : 'Service charge disabled',
// //                         style: TextStyle(
// //                           fontSize: 12,
// //                           fontWeight: FontWeight.w600,
// //                           color: _config!.serviceChargeEnabled
// //                               ? kSuccess
// //                               : kDanger,
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //           const SizedBox(height: 14),
// //
// //           // ── Payment Modes card ────────────────────────────────────────────
// //           KCard(
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 // Header row — icon + title + Select All checkbox + Save
// //                 Row(
// //                   crossAxisAlignment: CrossAxisAlignment.center,
// //                   children: [
// //                     const SizedBox(width: 12),
// //                     const Expanded(
// //                       child: Column(
// //                         crossAxisAlignment: CrossAxisAlignment.start,
// //                         children: [
// //                           KSectionTitle('Payment Modes', dotColor: kInfo),
// //                           SizedBox(height: 3),
// //                         ],
// //                       ),
// //                     ),
// //                     // Select All checkbox
// //                     GestureDetector(
// //                       onTap: () => setState(() {
// //                         final selectAll = !_allPaymentSelected;
// //                         _config!.cash = selectAll;
// //                         _config!.qrCode = selectAll;
// //                         _config!.upi = selectAll;
// //                       }),
// //                       child: Row(
// //                         children: [
// //                           Text(
// //                             'All',
// //                             style: TextStyle(
// //                               fontSize: 12,
// //                               fontWeight: FontWeight.w600,
// //                               color: _allPaymentSelected ? kInfo : kText2,
// //                             ),
// //                           ),
// //                           Checkbox(
// //                             value: _allPaymentSelected
// //                                 ? true
// //                                 : (_somePaymentSelected ? null : false),
// //                             tristate: true,
// //                             activeColor: kInfo,
// //                             checkColor: Colors.white,
// //                             side: BorderSide(
// //                               color: _somePaymentSelected ? kInfo : kBorder,
// //                               width: 1.5,
// //                             ),
// //                             shape: RoundedRectangleBorder(
// //                               borderRadius: BorderRadius.circular(4),
// //                             ),
// //                             onChanged: (_) => setState(() {
// //                               final selectAll = !_allPaymentSelected;
// //                               _config!.cash = selectAll;
// //                               _config!.qrCode = selectAll;
// //                               _config!.upi = selectAll;
// //                             }),
// //                           ),
// //                         ],
// //                       ),
// //                     ),
// //                     // ── Save button — top-right of this card ──────────────
// //                     KBtn(
// //                       label: 'Save',
// //                       icon: Icons.save_outlined,
// //                       loading: _savingPaymentModes,
// //                       onPressed: () => _saveSection('paymentModes'),
// //                     ),
// //                   ],
// //                 ),
// //
// //                 const SizedBox(height: 12),
// //                 const Divider(color: kBorder, height: 1),
// //                 const SizedBox(height: 12),
// //
// //                 // Payment mode chips
// //                 Wrap(
// //                   spacing: 8,
// //                   runSpacing: 8,
// //                   children: _kPaymentModes.map((meta) {
// //                     final selected = _pmValue(meta.key);
// //                     return GestureDetector(
// //                       onTap: () =>
// //                           setState(() => _pmToggle(meta.key, !selected)),
// //                       child: AnimatedContainer(
// //                         duration: const Duration(milliseconds: 200),
// //                         padding: const EdgeInsets.symmetric(
// //                           horizontal: 14,
// //                           vertical: 10,
// //                         ),
// //                         decoration: BoxDecoration(
// //                           color: selected ? kInfo.withOpacity(0.08) : kBg,
// //                           borderRadius: BorderRadius.circular(10),
// //                           border: Border.all(
// //                             color: selected ? kInfo : kBorder,
// //                             width: selected ? 1.5 : 1,
// //                           ),
// //                         ),
// //                         child: Row(
// //                           mainAxisSize: MainAxisSize.min,
// //                           children: [
// //                             Icon(
// //                               meta.icon,
// //                               size: 16,
// //                               color: selected ? kInfo : kText2,
// //                             ),
// //                             const SizedBox(width: 7),
// //                             Text(
// //                               meta.label,
// //                               style: TextStyle(
// //                                 fontSize: 12,
// //                                 fontWeight: FontWeight.w700,
// //                                 color: selected ? kInfo : kText2,
// //                               ),
// //                             ),
// //                             if (selected) ...[
// //                               const SizedBox(width: 6),
// //                               const Icon(
// //                                 Icons.check_circle_rounded,
// //                                 size: 14,
// //                                 color: kInfo,
// //                               ),
// //                             ],
// //                           ],
// //                         ),
// //                       ),
// //                     );
// //                   }).toList(),
// //                 ),
// //               ],
// //             ),
// //           ),
// //           const SizedBox(height: 14),
// //
// //           // ── Order Types card ──────────────────────────────────────────────
// //           KCard(
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 // Header row — title + Save
// //                 Row(
// //                   crossAxisAlignment: CrossAxisAlignment.center,
// //                   children: [
// //                     const Expanded(
// //                       child: Column(
// //                         crossAxisAlignment: CrossAxisAlignment.start,
// //                         children: [
// //                           KSectionTitle('Order Types', dotColor: kSuccess),
// //                           SizedBox(height: 4),
// //                         ],
// //                       ),
// //                     ),
// //                     // ── Save button — top-right of this card ──────────────
// //                     KBtn(
// //                       label: 'Save',
// //                       icon: Icons.save_outlined,
// //                       loading: _savingOrderTypes,
// //                       onPressed: () => _saveSection('orderTypes'),
// //                     ),
// //                   ],
// //                 ),
// //                 const SizedBox(height: 14),
// //
// //                 // Order type chips
// //                 Wrap(
// //                   spacing: 8,
// //                   runSpacing: 8,
// //                   children: _kOrderTypes.map((meta) {
// //                     final selected = _config!.orderTypes.contains(meta.value);
// //                     return GestureDetector(
// //                       onTap: () => setState(() {
// //                         if (selected) {
// //                           _config!.orderTypes.remove(meta.value);
// //                         } else {
// //                           _config!.orderTypes.add(meta.value);
// //                         }
// //                       }),
// //                       child: AnimatedContainer(
// //                         duration: const Duration(milliseconds: 200),
// //                         padding: const EdgeInsets.symmetric(
// //                           horizontal: 14,
// //                           vertical: 10,
// //                         ),
// //                         decoration: BoxDecoration(
// //                           color: selected ? kPrimary.withOpacity(0.08) : kBg,
// //                           borderRadius: BorderRadius.circular(10),
// //                           border: Border.all(
// //                             color: selected ? kPrimary : kBorder,
// //                             width: selected ? 1.5 : 1,
// //                           ),
// //                         ),
// //                         child: Row(
// //                           mainAxisSize: MainAxisSize.min,
// //                           children: [
// //                             Icon(
// //                               meta.icon,
// //                               size: 16,
// //                               color: selected ? kPrimary : kText2,
// //                             ),
// //                             const SizedBox(width: 7),
// //                             Text(
// //                               meta.label,
// //                               style: TextStyle(
// //                                 fontSize: 12,
// //                                 fontWeight: FontWeight.w700,
// //                                 color: selected ? kPrimary : kText2,
// //                               ),
// //                             ),
// //                             if (selected) ...[
// //                               const SizedBox(width: 6),
// //                               Icon(
// //                                 Icons.check_circle_rounded,
// //                                 size: 14,
// //                                 color: kPrimary,
// //                               ),
// //                             ],
// //                           ],
// //                         ),
// //                       ),
// //                     );
// //                   }).toList(),
// //                 ),
// //               ],
// //             ),
// //           ),
// //           const SizedBox(height: 14),
// //         ],
// //       ),
// //     );
// //   }
// // }
//
// import 'package:flutter/material.dart';
// import '../models/models.dart';
// import '../services/api_service.dart';
// import '../widgets/theme.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// // ── Order type display config ──────────────────────────────────────────────────
// const _kOrderTypes = [
//   _OrderTypeMeta(
//     value: 'DINE_IN',
//     label: 'Dine In',
//     icon: Icons.restaurant_outlined,
//   ),
//   _OrderTypeMeta(
//     value: 'TABLE_ORDERS',
//     label: 'Table Dine In',
//     icon: Icons.table_restaurant_outlined,
//   ),
//   _OrderTypeMeta(
//     value: 'TAKEAWAY',
//     label: 'Takeaway',
//     icon: Icons.shopping_bag_outlined,
//   ),
//   _OrderTypeMeta(
//     value: 'DELIVERY',
//     label: 'Delivery',
//     icon: Icons.delivery_dining_outlined,
//   ),
//   _OrderTypeMeta(
//     value: 'CATERING',
//     label: 'Catering',
//     icon: Icons.set_meal_outlined,
//   ),
// ];
//
// class _OrderTypeMeta {
//   final String value, label;
//   final IconData icon;
//   const _OrderTypeMeta({
//     required this.value,
//     required this.label,
//     required this.icon,
//   });
// }
//
// // ── Payment mode display config ────────────────────────────────────────────────
// const _kPaymentModes = [
//   _PaymentModeMeta(key: 'cash', label: 'Cash', icon: Icons.payments_outlined),
//   _PaymentModeMeta(
//     key: 'qrCode',
//     label: 'QR Code',
//     icon: Icons.qr_code_outlined,
//   ),
//   _PaymentModeMeta(
//     key: 'upi',
//     label: 'UPI',
//     icon: Icons.account_balance_outlined,
//   ),
//   _PaymentModeMeta(
//     key: 'splitBilling',
//     label: 'Split Billing',
//     icon: Icons.call_split_outlined,
//   ),
//   _PaymentModeMeta(
//     key: 'zoom',
//     label: 'kotPrintSize ',
//     icon: Icons.zoom_in_outlined,
//   ),
// ];
//
// class _PaymentModeMeta {
//   final String key, label;
//   final IconData icon;
//   const _PaymentModeMeta({
//     required this.key,
//     required this.label,
//     required this.icon,
//   });
// }
//
// // ─────────────────────────────────────────────────────────────────────────────
// class BillingSetupScreen extends StatefulWidget {
//   const BillingSetupScreen({super.key});
//   @override
//   State<BillingSetupScreen> createState() => _BillingSetupScreenState();
// }
//
// class _BillingSetupScreenState extends State<BillingSetupScreen> {
//   BillingConfig? _config;
//   bool _loading = true;
//   String? _error;
//
//   // ── NEW: Store selected modules from login ──────────────────────────────────
//   List<String> _selectedModules = [];
//
//   // ── Per-card saving states ──────────────────────────────────────────────────
//   bool _savingServiceCharge = false;
//   bool _savingPaymentModes = false;
//   bool _savingOrderTypes = false;
//
//   final _pctCtrl = TextEditingController();
//
//   // ── NEW: Getter for available order types based on selected modules ─────────
//   List<_OrderTypeMeta> get _availableOrderTypes {
//     return _kOrderTypes
//         .where((item) => _selectedModules.contains(item.value))
//         .toList();
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     _load();
//   }
//
//   @override
//   void dispose() {
//     _pctCtrl.dispose();
//     super.dispose();
//   }
//
//   // ── Load config ─────────────────────────────────────────────────────────────
//   Future<void> _load() async {
//     setState(() {
//       _loading = true;
//       _error = null;
//     });
//     try {
//       // ── NEW: Read selected modules from SharedPreferences ──────────────────
//       final prefs = await SharedPreferences.getInstance();
//       _selectedModules = prefs.getStringList('selectedModules') ?? [];
//
//       // ── Existing: Fetch billing config ─────────────────────────────────────
//       final c = await BillingApi.fetch();
//       if (mounted) {
//         setState(() {
//           _config = c ?? BillingConfig();
//           final sc = _config!.serviceCharges;
//           _pctCtrl.text = sc > 0
//               ? (sc == sc.truncateToDouble()
//                     ? sc.toInt().toString()
//                     : sc.toString())
//               : '';
//           _loading = false;
//         });
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _config = BillingConfig();
//           _error = e.toString();
//           _loading = false;
//         });
//       }
//     }
//   }
//
//   // ── Shared save logic — called by each card's Save button ───────────────────
//
//   Future<void> _saveSection(String section) async {
//     if (_config == null) return;
//
//     // ── Per-section validation ────────────────────────────────────────────────
//     if (section == 'orderTypes' && _config!.orderTypes.isEmpty) {
//       showWarning(context, 'Please select at least one order type');
//       return;
//     }
//     if (section == 'paymentModes' &&
//         !_config!.cash &&
//         !_config!.qrCode &&
//         !_config!.upi) {
//       showWarning(context, 'Please select at least one payment mode');
//       return;
//     }
//
//     // ── Flip only the relevant loading flag ───────────────────────────────────
//     setState(() {
//       if (section == 'serviceCharge') _savingServiceCharge = true;
//       if (section == 'paymentModes') _savingPaymentModes = true;
//       if (section == 'orderTypes') _savingOrderTypes = true;
//     });
//
//     try {
//       // Always compute service-charge derived fields before saving
//       final pct = double.tryParse(_pctCtrl.text) ?? 0;
//       _config!.serviceCharges = _config!.serviceChargeEnabled ? pct : 0;
//       _config!.serviceChargesType = _config!.serviceChargeEnabled
//           ? 'CUSTOMER_PAYABLE'
//           : 'BUSINESS_BORNE';
//       _config!.serviceChargesApply = _config!.serviceChargeEnabled
//           ? 'Applicable'
//           : 'Not_Applicable';
//       _config!.platformChargeType = 'BUSINESS_BORNE';
//
//       await BillingApi.save(_config!);
//
//       if (mounted) {
//         showSuccess(context, 'Saved ✅');
//         await _load();
//       }
//     } catch (e) {
//       if (mounted) showError(context, 'Failed: $e');
//     } finally {
//       if (mounted) {
//         setState(() {
//           _savingServiceCharge = false;
//           _savingPaymentModes = false;
//           _savingOrderTypes = false;
//         });
//       }
//     }
//   }
//
//   // ── Payment mode helpers ────────────────────────────────────────────────────
//   bool _pmValue(String key) {
//     switch (key) {
//       case 'cash':
//         return _config!.cash;
//       case 'qrCode':
//         return _config!.qrCode;
//       case 'upi':
//         return _config!.upi;
//       case 'splitBilling':
//         return _config!.splitBilling;
//       case 'zoom':
//         return _config!.zoom;
//       default:
//         return false;
//     }
//   }
//
//   void _pmToggle(String key, bool v) {
//     switch (key) {
//       case 'cash':
//         _config!.cash = v;
//       case 'qrCode':
//         _config!.qrCode = v;
//       case 'upi':
//         _config!.upi = v;
//       case 'splitBilling':
//         _config!.splitBilling = v;
//       case 'zoom':
//         _config!.zoom = v;
//     }
//   }
//
//   bool get _allPaymentSelected =>
//       _config!.cash &&
//       _config!.qrCode &&
//       _config!.upi &&
//       _config!.splitBilling &&
//       _config!.zoom;
//
//   bool get _somePaymentSelected =>
//       _config!.cash ||
//       _config!.qrCode ||
//       _config!.upi ||
//       _config!.splitBilling ||
//       _config!.zoom;
//
//   // ── Build ───────────────────────────────────────────────────────────────────
//   @override
//   Widget build(BuildContext context) {
//     if (_loading) {
//       return const Center(child: CircularProgressIndicator(color: kPrimary));
//     }
//
//     final bottomPad = MediaQuery.of(context).padding.bottom;
//
//     return RefreshIndicator(
//       color: kPrimary,
//       onRefresh: _load,
//       child: ListView(
//         padding: EdgeInsets.fromLTRB(16, 12, 16, bottomPad + 24),
//         children: [
//           // ── Error banner ──────────────────────────────────────────────────
//           if (_error != null) ...[
//             Container(
//               margin: const EdgeInsets.only(bottom: 12),
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: kWarning.withOpacity(0.08),
//                 borderRadius: BorderRadius.circular(10),
//                 border: Border.all(color: kWarning.withOpacity(0.3)),
//               ),
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Icon(Icons.info_outline, color: kWarning, size: 16),
//                   const SizedBox(width: 8),
//                   Expanded(
//                     child: Text(
//                       'Could not load config — using defaults.\n$_error',
//                       style: const TextStyle(fontSize: 11, color: kText2),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//
//           // ── Header card (no Save button — informational only) ────────────
//           KCard(
//             leftBorderColor: kPrimary,
//             child: const Row(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       KSectionTitle('Billing Configuration'),
//                       SizedBox(height: 4),
//                       Text(
//                         'Configure charges & order types',
//                         style: TextStyle(fontSize: 12, color: kText2),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 14),
//
//           // ── Service Charge card ───────────────────────────────────────────
//           KCard(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Header row — icon + title + switch + Save
//                 Row(
//                   children: [
//                     const SizedBox(width: 12),
//                     const Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Service Charge',
//                             style: TextStyle(
//                               fontSize: 15,
//                               fontWeight: FontWeight.w700,
//                               color: kText1,
//                             ),
//                           ),
//                           SizedBox(height: 2),
//                         ],
//                       ),
//                     ),
//                     // Switch
//                     Switch(
//                       value: _config!.serviceChargeEnabled,
//                       onChanged: (v) =>
//                           setState(() => _config!.serviceChargeEnabled = v),
//                       activeColor: kPrimary,
//                     ),
//                     const SizedBox(width: 4),
//                     // ── Save button — top-right of this card ──────────────
//                     KBtn(
//                       label: 'Save',
//                       icon: Icons.save_outlined,
//                       loading: _savingServiceCharge,
//                       onPressed: () => _saveSection('serviceCharge'),
//                     ),
//                   ],
//                 ),
//
//                 // Expandable percentage row
//                 AnimatedSize(
//                   duration: const Duration(milliseconds: 280),
//                   curve: Curves.easeInOut,
//                   child: _config!.serviceChargeEnabled
//                       ? Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             const SizedBox(height: 16),
//                             const Divider(color: kBorder, height: 1),
//                             const SizedBox(height: 14),
//                             const Text(
//                               'Service Charge %',
//                               style: TextStyle(
//                                 fontSize: 13,
//                                 fontWeight: FontWeight.w700,
//                                 color: kText1,
//                               ),
//                             ),
//                             const SizedBox(height: 8),
//                             Row(
//                               children: [
//                                 Expanded(
//                                   child: TextField(
//                                     controller: _pctCtrl,
//                                     keyboardType:
//                                         const TextInputType.numberWithOptions(
//                                           decimal: true,
//                                         ),
//                                     style: const TextStyle(
//                                       fontSize: 20,
//                                       fontWeight: FontWeight.w800,
//                                       color: kPrimary,
//                                     ),
//                                     decoration: InputDecoration(
//                                       hintText: '0',
//                                       suffixText: '%',
//                                       suffixStyle: const TextStyle(
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.w700,
//                                         color: kPrimary,
//                                       ),
//                                       border: OutlineInputBorder(
//                                         borderRadius: BorderRadius.circular(10),
//                                       ),
//                                       focusedBorder: OutlineInputBorder(
//                                         borderRadius: BorderRadius.circular(10),
//                                         borderSide: const BorderSide(
//                                           color: kPrimary,
//                                           width: 2,
//                                         ),
//                                       ),
//                                       contentPadding:
//                                           const EdgeInsets.symmetric(
//                                             horizontal: 14,
//                                             vertical: 14,
//                                           ),
//                                     ),
//                                     onChanged: (_) => setState(() {}),
//                                   ),
//                                 ),
//                                 const SizedBox(width: 14),
//                                 Container(
//                                   padding: const EdgeInsets.symmetric(
//                                     horizontal: 14,
//                                     vertical: 12,
//                                   ),
//                                   decoration: BoxDecoration(
//                                     color: kPrimaryLight,
//                                     borderRadius: BorderRadius.circular(10),
//                                     border: Border.all(
//                                       color: kPrimary.withOpacity(0.3),
//                                     ),
//                                   ),
//                                   child: Column(
//                                     children: [
//                                       const Text(
//                                         'On ₹1000',
//                                         style: TextStyle(
//                                           fontSize: 10,
//                                           color: kText2,
//                                         ),
//                                       ),
//                                       const SizedBox(height: 4),
//                                       Text(
//                                         '+₹${((double.tryParse(_pctCtrl.text) ?? 0) * 10).toStringAsFixed(0)}',
//                                         style: const TextStyle(
//                                           fontSize: 16,
//                                           fontWeight: FontWeight.w800,
//                                           color: kPrimary,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         )
//                       : const SizedBox.shrink(),
//                 ),
//
//                 const SizedBox(height: 14),
//
//                 // Status badge
//                 AnimatedContainer(
//                   duration: const Duration(milliseconds: 200),
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 12,
//                     vertical: 6,
//                   ),
//                   decoration: BoxDecoration(
//                     color: _config!.serviceChargeEnabled
//                         ? kSuccess.withOpacity(0.1)
//                         : kDanger.withOpacity(0.08),
//                     borderRadius: BorderRadius.circular(20),
//                     border: Border.all(
//                       color: _config!.serviceChargeEnabled
//                           ? kSuccess.withOpacity(0.3)
//                           : kDanger.withOpacity(0.2),
//                     ),
//                   ),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Icon(
//                         _config!.serviceChargeEnabled
//                             ? Icons.check_circle_outline
//                             : Icons.cancel_outlined,
//                         size: 14,
//                         color: _config!.serviceChargeEnabled
//                             ? kSuccess
//                             : kDanger,
//                       ),
//                       const SizedBox(width: 6),
//                       Text(
//                         _config!.serviceChargeEnabled
//                             ? 'Service charge enabled'
//                             : 'Service charge disabled',
//                         style: TextStyle(
//                           fontSize: 12,
//                           fontWeight: FontWeight.w600,
//                           color: _config!.serviceChargeEnabled
//                               ? kSuccess
//                               : kDanger,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 14),
//
//           // ── Payment Modes card ────────────────────────────────────────────
//           KCard(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Header row — icon + title + Select All checkbox + Save
//                 Row(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     const SizedBox(width: 12),
//                     const Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           KSectionTitle('Payment Modes', dotColor: kInfo),
//                           SizedBox(height: 3),
//                         ],
//                       ),
//                     ),
//                     // Select All checkbox
//                     GestureDetector(
//                       onTap: () => setState(() {
//                         final selectAll = !_allPaymentSelected;
//                         _config!.cash = selectAll;
//                         _config!.qrCode = selectAll;
//                         _config!.upi = selectAll;
//                       }),
//                       child: Row(
//                         children: [
//                           Text(
//                             'All',
//                             style: TextStyle(
//                               fontSize: 12,
//                               fontWeight: FontWeight.w600,
//                               color: _allPaymentSelected ? kInfo : kText2,
//                             ),
//                           ),
//                           Checkbox(
//                             value: _allPaymentSelected
//                                 ? true
//                                 : (_somePaymentSelected ? null : false),
//                             tristate: true,
//                             activeColor: kInfo,
//                             checkColor: Colors.white,
//                             side: BorderSide(
//                               color: _somePaymentSelected ? kInfo : kBorder,
//                               width: 1.5,
//                             ),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(4),
//                             ),
//                             onChanged: (_) => setState(() {
//                               final selectAll = !_allPaymentSelected;
//                               _config!.cash = selectAll;
//                               _config!.qrCode = selectAll;
//                               _config!.upi = selectAll;
//                             }),
//                           ),
//                         ],
//                       ),
//                     ),
//                     // ── Save button — top-right of this card ──────────────
//                     KBtn(
//                       label: 'Save',
//                       icon: Icons.save_outlined,
//                       loading: _savingPaymentModes,
//                       onPressed: () => _saveSection('paymentModes'),
//                     ),
//                   ],
//                 ),
//
//                 const SizedBox(height: 12),
//                 const Divider(color: kBorder, height: 1),
//                 const SizedBox(height: 12),
//
//                 // Payment mode chips
//                 Wrap(
//                   spacing: 8,
//                   runSpacing: 8,
//                   children: _kPaymentModes.map((meta) {
//                     final selected = _pmValue(meta.key);
//                     return GestureDetector(
//                       onTap: () =>
//                           setState(() => _pmToggle(meta.key, !selected)),
//                       child: AnimatedContainer(
//                         duration: const Duration(milliseconds: 200),
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 14,
//                           vertical: 10,
//                         ),
//                         decoration: BoxDecoration(
//                           color: selected ? kInfo.withOpacity(0.08) : kBg,
//                           borderRadius: BorderRadius.circular(10),
//                           border: Border.all(
//                             color: selected ? kInfo : kBorder,
//                             width: selected ? 1.5 : 1,
//                           ),
//                         ),
//                         child: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Icon(
//                               meta.icon,
//                               size: 16,
//                               color: selected ? kInfo : kText2,
//                             ),
//                             const SizedBox(width: 7),
//                             Text(
//                               meta.label,
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 fontWeight: FontWeight.w700,
//                                 color: selected ? kInfo : kText2,
//                               ),
//                             ),
//                             if (selected) ...[
//                               const SizedBox(width: 6),
//                               const Icon(
//                                 Icons.check_circle_rounded,
//                                 size: 14,
//                                 color: kInfo,
//                               ),
//                             ],
//                           ],
//                         ),
//                       ),
//                     );
//                   }).toList(),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 14),
//
//           // ── Order Types card ──────────────────────────────────────────────
//           KCard(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Header row — title + Save
//                 Row(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     const Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           KSectionTitle('Order Types', dotColor: kSuccess),
//                           SizedBox(height: 4),
//                         ],
//                       ),
//                     ),
//                     // ── Save button — top-right of this card ──────────────
//                     KBtn(
//                       label: 'Save',
//                       icon: Icons.save_outlined,
//                       loading: _savingOrderTypes,
//                       onPressed: () => _saveSection('orderTypes'),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 14),
//
//                 // ── Order type chips ──────────────────────────────────────
//                 // ── CHANGED: Use _availableOrderTypes instead of _kOrderTypes ──
//                 if (_availableOrderTypes.isEmpty)
//                   Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 20),
//                     child: Center(
//                       child: Text(
//                         'No order types available',
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: kText2,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ),
//                   )
//                 else
//                   Wrap(
//                     spacing: 8,
//                     runSpacing: 8,
//                     children: _availableOrderTypes.map((meta) {
//                       final selected = _config!.orderTypes.contains(meta.value);
//                       return GestureDetector(
//                         onTap: () => setState(() {
//                           if (selected) {
//                             _config!.orderTypes.remove(meta.value);
//                           } else {
//                             _config!.orderTypes.add(meta.value);
//                           }
//                         }),
//                         child: AnimatedContainer(
//                           duration: const Duration(milliseconds: 200),
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 14,
//                             vertical: 10,
//                           ),
//                           decoration: BoxDecoration(
//                             color: selected ? kPrimary.withOpacity(0.08) : kBg,
//                             borderRadius: BorderRadius.circular(10),
//                             border: Border.all(
//                               color: selected ? kPrimary : kBorder,
//                               width: selected ? 1.5 : 1,
//                             ),
//                           ),
//                           child: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               Icon(
//                                 meta.icon,
//                                 size: 16,
//                                 color: selected ? kPrimary : kText2,
//                               ),
//                               const SizedBox(width: 7),
//                               Text(
//                                 meta.label,
//                                 style: TextStyle(
//                                   fontSize: 12,
//                                   fontWeight: FontWeight.w700,
//                                   color: selected ? kPrimary : kText2,
//                                 ),
//                               ),
//                               if (selected) ...[
//                                 const SizedBox(width: 6),
//                                 Icon(
//                                   Icons.check_circle_rounded,
//                                   size: 14,
//                                   color: kPrimary,
//                                 ),
//                               ],
//                             ],
//                           ),
//                         ),
//                       );
//                     }).toList(),
//                   ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 14),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../widgets/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ── Order type display config ──────────────────────────────────────────────────
const _kOrderTypes = [
  _OrderTypeMeta(
    value: 'DINE_IN',
    label: 'Dine In',
    icon: Icons.restaurant_outlined,
  ),
  _OrderTypeMeta(
    value: 'TABLE_DINE_IN',
    label: 'Table Dine In',
    icon: Icons.table_restaurant_outlined,
  ),
  _OrderTypeMeta(
    value: 'TAKEAWAY',
    label: 'Takeaway',
    icon: Icons.shopping_bag_outlined,
  ),
  _OrderTypeMeta(
    value: 'DELIVERY',
    label: 'Delivery',
    icon: Icons.delivery_dining_outlined,
  ),
  _OrderTypeMeta(
    value: 'CATERING',
    label: 'Catering',
    icon: Icons.set_meal_outlined,
  ),
];

class _OrderTypeMeta {
  final String value, label;
  final IconData icon;
  const _OrderTypeMeta({
    required this.value,
    required this.label,
    required this.icon,
  });
}

// ── Payment mode display config ────────────────────────────────────────────────
const _kPaymentModes = [
  _PaymentModeMeta(key: 'cash', label: 'Cash', icon: Icons.payments_outlined),
  _PaymentModeMeta(
    key: 'qrCode',
    label: 'QR Code',
    icon: Icons.qr_code_outlined,
  ),
  _PaymentModeMeta(
    key: 'upi',
    label: 'UPI',
    icon: Icons.account_balance_outlined,
  ),
  _PaymentModeMeta(
    key: 'splitBilling',
    label: 'Split Billing',
    icon: Icons.call_split_outlined,
  ),
  _PaymentModeMeta(
    key: 'zoom',
    label: 'kotPrintSize ',
    icon: Icons.zoom_in_outlined,
  ),
];

class _PaymentModeMeta {
  final String key, label;
  final IconData icon;
  const _PaymentModeMeta({
    required this.key,
    required this.label,
    required this.icon,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
class BillingSetupScreen extends StatefulWidget {
  const BillingSetupScreen({super.key});
  @override
  State<BillingSetupScreen> createState() => _BillingSetupScreenState();
}

class _BillingSetupScreenState extends State<BillingSetupScreen> {
  BillingConfig? _config;
  bool _loading = true;
  String? _error;
  List<String> _selectedModules = [];
  bool _savingServiceCharge = false;
  bool _savingPaymentModes = false;
  bool _savingOrderTypes = false;

  final _pctCtrl = TextEditingController();

  List<_OrderTypeMeta> get _availableOrderTypes {
    List<String> modules = List.from(_selectedModules);

    if (modules.contains('TABLE_ORDERS') &&
        !modules.contains('TABLE_DINE_IN')) {
      modules.add('TABLE_DINE_IN');
      print('🔧 Mapped TABLE_ORDERS to TABLE_DINE_IN');
    }

    print('📦 Modules after mapping: $modules');

    return _kOrderTypes.where((item) => modules.contains(item.value)).toList();
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _pctCtrl.dispose();
    super.dispose();
  }

  // ── Load config ─────────────────────────────────────────────────────────────
  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      // ── Read selected modules from SharedPreferences ──────────────────
      final prefs = await SharedPreferences.getInstance();
      _selectedModules = prefs.getStringList('selectedModules') ?? [];

      // Debug: Print what modules are loaded
      print('📦 Selected Modules from SharedPreferences: $_selectedModules');

      // Debug: Print what order types will be available
      final available = _availableOrderTypes;
      print(
        '✅ Available Order Types: ${available.map((e) => e.label).toList()}',
      );

      // ── Fetch billing config ─────────────────────────────────────
      final c = await BillingApi.fetch();
      if (mounted) {
        setState(() {
          _config = c ?? BillingConfig();
          final sc = _config!.serviceCharges;
          _pctCtrl.text = sc > 0
              ? (sc == sc.truncateToDouble()
                    ? sc.toInt().toString()
                    : sc.toString())
              : '';
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _config = BillingConfig();
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  // ── Shared save logic ───────────────────────────────────────────────────

  Future<void> _saveSection(String section) async {
    if (_config == null) return;

    // ── Per-section validation ────────────────────────────────────────────────
    if (section == 'orderTypes' && _config!.orderTypes.isEmpty) {
      showWarning(context, 'Please select at least one order type');
      return;
    }
    if (section == 'paymentModes' &&
        !_config!.cash &&
        !_config!.qrCode &&
        !_config!.upi) {
      showWarning(context, 'Please select at least one payment mode');
      return;
    }

    // ── Flip only the relevant loading flag ───────────────────────────────────
    setState(() {
      if (section == 'serviceCharge') _savingServiceCharge = true;
      if (section == 'paymentModes') _savingPaymentModes = true;
      if (section == 'orderTypes') _savingOrderTypes = true;
    });

    try {
      final pct = double.tryParse(_pctCtrl.text) ?? 0;
      _config!.serviceCharges = _config!.serviceChargeEnabled ? pct : 0;
      _config!.serviceChargesType = _config!.serviceChargeEnabled
          ? 'CUSTOMER_PAYABLE'
          : 'BUSINESS_BORNE';
      _config!.serviceChargesApply = _config!.serviceChargeEnabled
          ? 'Applicable'
          : 'Not_Applicable';
      _config!.platformChargeType = 'BUSINESS_BORNE';

      await BillingApi.save(_config!);

      if (mounted) {
        showSuccess(context, 'Saved ✅');
        await _load();
      }
    } catch (e) {
      if (mounted) showError(context, 'Failed: $e');
    } finally {
      if (mounted) {
        setState(() {
          _savingServiceCharge = false;
          _savingPaymentModes = false;
          _savingOrderTypes = false;
        });
      }
    }
  }

  // ── Payment mode helpers ────────────────────────────────────────────────────
  bool _pmValue(String key) {
    switch (key) {
      case 'cash':
        return _config!.cash;
      case 'qrCode':
        return _config!.qrCode;
      case 'upi':
        return _config!.upi;
      case 'splitBilling':
        return _config!.splitBilling;
      case 'zoom':
        return _config!.zoom;
      default:
        return false;
    }
  }

  void _pmToggle(String key, bool v) {
    switch (key) {
      case 'cash':
        _config!.cash = v;
      case 'qrCode':
        _config!.qrCode = v;
      case 'upi':
        _config!.upi = v;
      case 'splitBilling':
        _config!.splitBilling = v;
      case 'zoom':
        _config!.zoom = v;
    }
  }

  bool get _allPaymentSelected =>
      _config!.cash &&
      _config!.qrCode &&
      _config!.upi &&
      _config!.splitBilling &&
      _config!.zoom;

  bool get _somePaymentSelected =>
      _config!.cash ||
      _config!.qrCode ||
      _config!.upi ||
      _config!.splitBilling ||
      _config!.zoom;

  // ── Build ───────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: kPrimary));
    }

    final bottomPad = MediaQuery.of(context).padding.bottom;

    return RefreshIndicator(
      color: kPrimary,
      onRefresh: _load,
      child: ListView(
        padding: EdgeInsets.fromLTRB(16, 12, 16, bottomPad + 24),
        children: [
          // ── Error banner ──────────────────────────────────────────────────
          if (_error != null) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: kWarning.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: kWarning.withOpacity(0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, color: kWarning, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Could not load config — using defaults.\n$_error',
                      style: const TextStyle(fontSize: 11, color: kText2),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // ── Header card ────────────────────────────────────────────
          KCard(
            leftBorderColor: kPrimary,
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      KSectionTitle('Billing Configuration'),
                      SizedBox(height: 4),
                      Text(
                        'Configure charges & order types',
                        style: TextStyle(fontSize: 12, color: kText2),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // ── Service Charge card ───────────────────────────────────────────
          KCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  children: [
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Service Charge',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: kText1,
                            ),
                          ),
                          SizedBox(height: 2),
                        ],
                      ),
                    ),
                    Switch(
                      value: _config!.serviceChargeEnabled,
                      onChanged: (v) =>
                          setState(() => _config!.serviceChargeEnabled = v),
                      activeColor: kPrimary,
                    ),
                    const SizedBox(width: 4),
                    KBtn(
                      label: 'Save',
                      icon: Icons.save_outlined,
                      loading: _savingServiceCharge,
                      onPressed: () => _saveSection('serviceCharge'),
                    ),
                  ],
                ),

                // Expandable percentage row
                AnimatedSize(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeInOut,
                  child: _config!.serviceChargeEnabled
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),
                            const Divider(color: kBorder, height: 1),
                            const SizedBox(height: 14),
                            const Text(
                              'Service Charge %',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: kText1,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _pctCtrl,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                      color: kPrimary,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: '0',
                                      suffixText: '%',
                                      suffixStyle: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: kPrimary,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                          color: kPrimary,
                                          width: 2,
                                        ),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 14,
                                          ),
                                    ),
                                    onChanged: (_) => setState(() {}),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: kPrimaryLight,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: kPrimary.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      const Text(
                                        'On ₹1000',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: kText2,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '+₹${((double.tryParse(_pctCtrl.text) ?? 0) * 10).toStringAsFixed(0)}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                          color: kPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),

                const SizedBox(height: 14),

                // Status badge
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _config!.serviceChargeEnabled
                        ? kSuccess.withOpacity(0.1)
                        : kDanger.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _config!.serviceChargeEnabled
                          ? kSuccess.withOpacity(0.3)
                          : kDanger.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _config!.serviceChargeEnabled
                            ? Icons.check_circle_outline
                            : Icons.cancel_outlined,
                        size: 14,
                        color: _config!.serviceChargeEnabled
                            ? kSuccess
                            : kDanger,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _config!.serviceChargeEnabled
                            ? 'Service charge enabled'
                            : 'Service charge disabled',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _config!.serviceChargeEnabled
                              ? kSuccess
                              : kDanger,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // ── Payment Modes card ────────────────────────────────────────────
          KCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          KSectionTitle('Payment Modes', dotColor: kInfo),
                          SizedBox(height: 3),
                        ],
                      ),
                    ),
                    // Select All checkbox
                    GestureDetector(
                      onTap: () => setState(() {
                        final selectAll = !_allPaymentSelected;
                        _config!.cash = selectAll;
                        _config!.qrCode = selectAll;
                        _config!.upi = selectAll;
                      }),
                      child: Row(
                        children: [
                          Text(
                            'All',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _allPaymentSelected ? kInfo : kText2,
                            ),
                          ),
                          Checkbox(
                            value: _allPaymentSelected
                                ? true
                                : (_somePaymentSelected ? null : false),
                            tristate: true,
                            activeColor: kInfo,
                            checkColor: Colors.white,
                            side: BorderSide(
                              color: _somePaymentSelected ? kInfo : kBorder,
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            onChanged: (_) => setState(() {
                              final selectAll = !_allPaymentSelected;
                              _config!.cash = selectAll;
                              _config!.qrCode = selectAll;
                              _config!.upi = selectAll;
                            }),
                          ),
                        ],
                      ),
                    ),
                    KBtn(
                      label: 'Save',
                      icon: Icons.save_outlined,
                      loading: _savingPaymentModes,
                      onPressed: () => _saveSection('paymentModes'),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                const Divider(color: kBorder, height: 1),
                const SizedBox(height: 12),

                // Payment mode chips
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _kPaymentModes.map((meta) {
                    final selected = _pmValue(meta.key);
                    return GestureDetector(
                      onTap: () =>
                          setState(() => _pmToggle(meta.key, !selected)),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: selected ? kInfo.withOpacity(0.08) : kBg,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: selected ? kInfo : kBorder,
                            width: selected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              meta.icon,
                              size: 16,
                              color: selected ? kInfo : kText2,
                            ),
                            const SizedBox(width: 7),
                            Text(
                              meta.label,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: selected ? kInfo : kText2,
                              ),
                            ),
                            if (selected) ...[
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.check_circle_rounded,
                                size: 14,
                                color: kInfo,
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // ── Order Types card ──────────────────────────────────────────────
          KCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row — title + Save
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          KSectionTitle('Order Types', dotColor: kSuccess),
                          SizedBox(height: 4),
                        ],
                      ),
                    ),
                    KBtn(
                      label: 'Save',
                      icon: Icons.save_outlined,
                      loading: _savingOrderTypes,
                      onPressed: () => _saveSection('orderTypes'),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // ── Order type chips ──────────────────────────────────────
                if (_availableOrderTypes.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Text(
                        'No order types available',
                        style: TextStyle(
                          fontSize: 14,
                          color: kText2,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _availableOrderTypes.map((meta) {
                      final selected = _config!.orderTypes.contains(meta.value);
                      return GestureDetector(
                        onTap: () => setState(() {
                          if (selected) {
                            _config!.orderTypes.remove(meta.value);
                          } else {
                            _config!.orderTypes.add(meta.value);
                          }
                        }),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: selected ? kPrimary.withOpacity(0.08) : kBg,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: selected ? kPrimary : kBorder,
                              width: selected ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                meta.icon,
                                size: 16,
                                color: selected ? kPrimary : kText2,
                              ),
                              const SizedBox(width: 7),
                              Text(
                                meta.label,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: selected ? kPrimary : kText2,
                                ),
                              ),
                              if (selected) ...[
                                const SizedBox(width: 6),
                                Icon(
                                  Icons.check_circle_rounded,
                                  size: 14,
                                  color: kPrimary,
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
        ],
      ),
    );
  }
}
