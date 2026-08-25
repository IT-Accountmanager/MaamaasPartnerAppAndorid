// import 'package:flutter/material.dart';
// import '../models/models.dart';
// import '../services/api_service.dart';
// import '../widgets/theme.dart';
//
// String _fmt(String t) {
//   final p = t.split(':');
//   if (p.length < 2) return t;
//   final h = int.tryParse(p[0]) ?? 0;
//   final m = p[1];
//   return '${h > 12 ? h - 12 : (h == 0 ? 12 : h)}:$m ${h >= 12 ? "PM" : "AM"}';
// }
//
// class GeneralControlsScreen extends StatefulWidget {
//   const GeneralControlsScreen({super.key});
//   @override
//   State<GeneralControlsScreen> createState() => _GeneralControlsScreenState();
// }
//
// class _GeneralControlsScreenState extends State<GeneralControlsScreen> {
//   // ── Status ────────────────────────────────────────────────────────────────
//   bool _isOnline = true;
//   bool _statusBusy = false;
//
//   // ── Timings ───────────────────────────────────────────────────────────────
//   static const _days = [
//     'Monday',
//     'Tuesday',
//     'Wednesday',
//     'Thursday',
//     'Friday',
//     'Saturday',
//     'Sunday',
//   ];
//   late List<DayTiming> _timings;
//   bool _timingsLoading = true;
//   String? _timingsError;
//   bool _savingAllTimings = false;
//   String _autoPrintStation = 'disabled';
//   bool _timingsEdited = false;
//
//   // ── Order routing + KOT ───────────────────────────────────────────────────
//   BillingConfig? _billing;
//   bool _routingLoading = true;
//   bool _routingSaving = false;
//   bool _routingEditing = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _timings = _days.map((d) => DayTiming(day: d)).toList();
//     _load();
//   }
//
//   Future<void> _load() => Future.wait([_loadTimings(), _loadRouting()]);
//
//   // ── Fetch timings ─────────────────────────────────────────────────────────
//   Future<void> _loadTimings() async {
//     setState(() {
//       _timingsLoading = true;
//       _timingsError = null;
//     });
//     try {
//       final list = await TimingsApi.fetchAll();
//       if (mounted)
//         setState(() {
//           for (final t in list) {
//             final i = _timings.indexWhere((x) => x.day == t.day);
//             if (i != -1) _timings[i] = t;
//           }
//           _timingsLoading = false;
//           _timingsEdited = false;
//         });
//     } catch (e) {
//       if (mounted)
//         setState(() {
//           _timingsError = e.toString();
//           _timingsLoading = false;
//         });
//     }
//   }
//
//   // ── Fetch billing / order routing ─────────────────────────────────────────
//   Future<void> _loadRouting() async {
//     setState(() => _routingLoading = true);
//     try {
//       final b = await BillingApi.fetch();
//       if (mounted)
//         setState(() {
//           _billing = b;
//
//           if (b != null) {
//             _autoPrintStation = b.autoPrint ? 'chef' : 'disabled';
//           }
//           _routingLoading = false;
//         });
//     } catch (_) {
//       if (mounted) setState(() => _routingLoading = false);
//     }
//   }
//
//   // ── Restaurant status ─────────────────────────────────────────────────────
//   Future<void> _toggle(bool val) async {
//     if (val) {
//       setState(() {
//         _isOnline = true;
//         _statusBusy = true;
//       });
//       try {
//         await RestaurantStatusApi.setOnline();
//         if (mounted) showSuccess(context, 'Restaurant is now Open ✅');
//       } catch (e) {
//         if (mounted) {
//           setState(() => _isOnline = false);
//           showError(context, 'Failed: $e');
//         }
//       } finally {
//         if (mounted) setState(() => _statusBusy = false);
//       }
//     } else {
//       _showOfflineSheet();
//     }
//   }
//
//   void _showOfflineSheet() => showModalBottomSheet(
//     context: context,
//     isScrollControlled: true,
//     useSafeArea: true,
//     backgroundColor: Colors.transparent,
//     shape: const RoundedRectangleBorder(
//       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//     ),
//     builder: (_) => _OfflineSheet(
//       onConfirm: (reasons) async {
//         Navigator.pop(context);
//         setState(() {
//           _isOnline = false;
//           _statusBusy = true;
//         });
//         try {
//           await RestaurantStatusApi.setOffline(reasons);
//           if (mounted) showSuccess(context, 'Restaurant is now Closed');
//         } catch (e) {
//           if (mounted) {
//             setState(() => _isOnline = true);
//             showError(context, 'Failed: $e');
//           }
//         } finally {
//           if (mounted) setState(() => _statusBusy = false);
//         }
//       },
//       onCancel: () => Navigator.pop(context),
//     ),
//   );
//
//   // ── Save ALL timings at once ───────────────────────────────────────────────
//   Future<void> _saveAllTimings() async {
//     setState(() => _savingAllTimings = true);
//     try {
//       final results = await Future.wait(
//         List.generate(_timings.length, (i) => TimingsApi.save(_timings[i])),
//       );
//       if (mounted) {
//         setState(() {
//           for (int i = 0; i < results.length; i++) _timings[i] = results[i];
//         });
//         showSuccess(context, 'All timings saved ✅');
//         setState(() => _timingsEdited = false);
//       }
//     } catch (e) {
//       if (mounted) showError(context, 'Failed: $e');
//     } finally {
//       if (mounted) setState(() => _savingAllTimings = false);
//     }
//   }
//
//   // ── Save order routing + KOT ──────────────────────────────────────────────
//   Future<void> _saveRouting() async {
//     setState(() => _routingSaving = true);
//     try {
//       _billing ??= BillingConfig();
//       _billing!.autoPrint = _autoPrintStation != 'disabled';
//
//       await BillingApi.save(_billing!);
//       if (mounted) {
//         setState(() => _routingEditing = false);
//         showSuccess(context, 'Settings saved ✅');
//         _loadRouting();
//       }
//     } catch (e) {
//       if (mounted) showError(context, 'Failed: $e');
//     } finally {
//       if (mounted) setState(() => _routingSaving = false);
//     }
//   }
//
//   String get _today {
//     const d = [
//       'Sunday',
//       'Monday',
//       'Tuesday',
//       'Wednesday',
//       'Thursday',
//       'Friday',
//       'Saturday',
//     ];
//     return d[DateTime.now().weekday % 7];
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final bottomPad = MediaQuery.of(context).padding.bottom;
//     return RefreshIndicator(
//       color: kPrimary,
//       onRefresh: _load,
//       child: ListView(
//         padding: EdgeInsets.fromLTRB(16, 12, 16, bottomPad + 24),
//         children: [
//           // ── 1. Restaurant Status ───────────────────────────────────────
//           KCard(
//             leftBorderColor: _isOnline ? kSuccess : kDanger,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           KSectionTitle(
//                             'Restaurant Status',
//                             dotColor: _isOnline ? kSuccess : kDanger,
//                           ),
//                           const SizedBox(height: 4),
//                           const Text(
//                             'Control whether your restaurant accepts orders',
//                             style: TextStyle(fontSize: 12, color: kText2),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     if (_statusBusy)
//                       const Padding(
//                         padding: EdgeInsets.symmetric(vertical: 8),
//                         child: SizedBox(
//                           width: 26,
//                           height: 26,
//                           child: CircularProgressIndicator(
//                             strokeWidth: 2,
//                             color: kPrimary,
//                           ),
//                         ),
//                       )
//                     else
//                       Column(
//                         children: [
//                           Switch(
//                             value: _isOnline,
//                             onChanged: _toggle,
//                             activeColor: kSuccess,
//                             inactiveThumbColor: kDanger,
//                             inactiveTrackColor: kDanger.withOpacity(0.3),
//                           ),
//                           Text(
//                             _isOnline ? 'Open' : 'Closed',
//                             style: TextStyle(
//                               fontSize: 10,
//                               fontWeight: FontWeight.w800,
//                               color: _isOnline ? kSuccess : kDanger,
//                             ),
//                           ),
//                         ],
//                       ),
//                   ],
//                 ),
//                 if (!_isOnline) ...[
//                   const SizedBox(height: 10),
//                   Container(
//                     padding: const EdgeInsets.all(10),
//                     decoration: BoxDecoration(
//                       color: kDanger.withOpacity(0.07),
//                       borderRadius: BorderRadius.circular(8),
//                       border: Border.all(color: kDanger.withOpacity(0.2)),
//                     ),
//                     child: const Row(
//                       children: [
//                         Icon(Icons.cancel_outlined, color: kDanger, size: 15),
//                         SizedBox(width: 8),
//                         Expanded(
//                           child: Text(
//                             "Customers see 'Restaurant is currently closed'",
//                             style: TextStyle(fontSize: 12, color: kDanger),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ],
//             ),
//           ),
//           const SizedBox(height: 14),
//
//           // ── 2. Weekly Operating Hours ──────────────────────────────────
//           KCard(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     const Expanded(
//                       child: KSectionTitle('Weekly Operating Hours'),
//                     ),
//                     if (!_timingsLoading &&
//                         _timingsError == null &&
//                         _timingsEdited)
//                       KBtn(
//                         label: 'Save',
//                         loading: _savingAllTimings,
//                         onPressed: _saveAllTimings,
//                       ),
//                   ],
//                 ),
//                 const SizedBox(height: 10),
//                 if (_timingsError != null)
//                   _RetryBanner(msg: _timingsError!, onRetry: _loadTimings)
//                 else if (_timingsLoading)
//                   const Center(
//                     child: Padding(
//                       padding: EdgeInsets.all(24),
//                       child: CircularProgressIndicator(color: kPrimary),
//                     ),
//                   )
//                 else
//                   ..._timings.asMap().entries.map(
//                     (e) => _DayRow(
//                       t: e.value,
//                       isToday: e.value.day == _today,
//                       onOpen: (v) => setState(() {
//                         _timings[e.key].open = v;
//                         _timingsEdited = true;
//                       }),
//                       onClose: (v) => setState(() {
//                         _timings[e.key].close = v;
//                         _timingsEdited = true;
//                       }),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 14),
//
//           // ── 3. Order Processing Mode ───────────────────────────────────
//           KCard(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Header row
//                 Row(
//                   children: [
//                     const Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           KSectionTitle(
//                             'Order Processing Mode',
//                             dotColor: kWarning,
//                           ),
//                           SizedBox(height: 3),
//                         ],
//                       ),
//                     ),
//                     if (!_routingEditing)
//                       GestureDetector(
//                         onTap: () => setState(() => _routingEditing = true),
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 14,
//                             vertical: 7,
//                           ),
//                           decoration: BoxDecoration(
//                             color: kBg,
//                             borderRadius: BorderRadius.circular(8),
//                             border: Border.all(color: kBorder),
//                           ),
//                           child: const Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               Icon(
//                                 Icons.edit_outlined,
//                                 size: 13,
//                                 color: kText2,
//                               ),
//                               SizedBox(width: 5),
//                               Text(
//                                 'Edit',
//                                 style: TextStyle(
//                                   fontSize: 12,
//                                   fontWeight: FontWeight.w700,
//                                   color: kText2,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       )
//                     else
//                       Flexible(
//                         child: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             GestureDetector(
//                               onTap: _routingSaving
//                                   ? null
//                                   : () {
//                                       setState(() => _routingEditing = false);
//                                       _loadRouting();
//                                     },
//                               child: Container(
//                                 padding: const EdgeInsets.symmetric(
//                                   horizontal: 8,
//                                   vertical: 7,
//                                 ),
//                                 decoration: BoxDecoration(
//                                   color: kBg,
//                                   borderRadius: BorderRadius.circular(8),
//                                   border: Border.all(color: kBorder),
//                                 ),
//                                 child: const Text(
//                                   'Cancel',
//                                   style: TextStyle(
//                                     fontSize: 12,
//                                     fontWeight: FontWeight.w700,
//                                     color: kText2,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(width: 8),
//                             KBtn(
//                               label: 'Save',
//                               loading: _routingSaving,
//                               onPressed: _saveRouting,
//                             ),
//                           ],
//                         ),
//                       ),
//                   ],
//                 ),
//                 const SizedBox(height: 16),
//
//                 if (_routingLoading)
//                   const Center(
//                     child: CircularProgressIndicator(color: kPrimary),
//                   )
//                 else ...[
//                   // ── Order Routing rows ─────────────────────────────────
//                   _RoutingRow(
//                     icon: '🍽️',
//                     title: 'Regular Orders',
//                     subtitle: 'Walk-in & dine-in',
//                     leftLabel: '👨‍🍳 Chef',
//                     rightLabel: '🚚 Delivery',
//                     isLeft: (_billing?.regularOrders ?? 'delivery') == 'chef',
//                     onToggle: _routingEditing
//                         ? () => setState(() {
//                             _billing ??= BillingConfig();
//                             _billing!.regularOrders =
//                                 _billing!.regularOrders == 'chef'
//                                 ? 'delivery'
//                                 : 'chef';
//                           })
//                         : null,
//                   ),
//                   const SizedBox(height: 10),
//                   _RoutingRow(
//                     icon: '🛵',
//                     title: 'Online Orders',
//                     subtitle: 'App & website orders',
//                     leftLabel: '👨‍🍳 Chef',
//                     rightLabel: '🏪 Cashier',
//                     isLeft: (_billing?.onlineOrders ?? 'vendor') == 'chef',
//                     onToggle: _routingEditing
//                         ? () => setState(() {
//                             _billing ??= BillingConfig();
//                             _billing!.onlineOrders =
//                                 _billing!.onlineOrders == 'chef'
//                                 ? 'vendor'
//                                 : 'chef';
//                           })
//                         : null,
//                   ),
//                   const SizedBox(height: 14),
//
//                   // ── KOT Settings ───────────────────────────────────────
//                   const Divider(color: kBorder, height: 1),
//                   const SizedBox(height: 14),
//                   const Text(
//                     'KOT Settings',
//                     style: TextStyle(
//                       fontSize: 13,
//                       fontWeight: FontWeight.w800,
//                       color: kText1,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   const Text(
//                     'Kitchen Order Ticket printing preferences',
//                     style: TextStyle(fontSize: 12, color: kText2),
//                   ),
//                   const SizedBox(height: 12),
//
//                   _KotToggleRow(
//                     icon: Icons.receipt_long_outlined,
//                     title: 'Cashier KOT',
//                     subtitle: 'Print KOT at cashier station',
//                     value: _billing?.cashierKot ?? false,
//                     enabled: _routingEditing,
//                     onChanged: _routingEditing
//                         ? (v) => setState(() {
//                             _billing ??= BillingConfig();
//                             _billing!.cashierKot = v;
//                           })
//                         : null,
//                   ),
//                   const SizedBox(height: 10),
//                   _KotToggleRow(
//                     icon: Icons.restaurant_menu_outlined,
//                     title: 'Chef KOT',
//                     subtitle: 'Print KOT at kitchen / chef station',
//                     value: _billing?.chefKot ?? false,
//                     enabled: _routingEditing,
//                     onChanged: _routingEditing
//                         ? (v) => setState(() {
//                             _billing ??= BillingConfig();
//                             _billing!.chefKot = v;
//                           })
//                         : null,
//                   ),
//                   const SizedBox(height: 10),
//
//                   const SizedBox(height: 14),
//                   const Divider(color: kBorder, height: 1),
//                   const SizedBox(height: 14),
//                   const Text(
//                     'Auto Print',
//                     style: TextStyle(
//                       fontSize: 13,
//                       fontWeight: FontWeight.w800,
//                       color: kText1,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   const Text(
//                     'Automatically print orders when received by cashier',
//                     style: TextStyle(fontSize: 12, color: kText2),
//                   ),
//                   const SizedBox(height: 12),
//
//                   _AutoPrintRow(
//                     title: 'Chef',
//                     subtitle: 'Send auto-print orders to kitchen',
//                     isSelected: _autoPrintStation == 'chef',
//                     enabled: _routingEditing,
//                     onTap: _routingEditing
//                         ? () => setState(() => _autoPrintStation = 'chef')
//                         : null,
//                   ),
//                   const SizedBox(height: 8),
//                   _AutoPrintRow(
//                     title: 'Cashier',
//                     subtitle: 'Send auto-print orders to cashier station',
//                     isSelected: _autoPrintStation == 'cashier',
//                     enabled: _routingEditing,
//                     onTap: _routingEditing
//                         ? () => setState(() => _autoPrintStation = 'cashier')
//                         : null,
//                   ),
//                   const SizedBox(height: 8),
//                   _AutoPrintRow(
//                     title: 'Disable',
//                     subtitle: 'Turn off auto-print functionality',
//                     isSelected: _autoPrintStation == 'disabled',
//                     enabled: _routingEditing,
//                     onTap: _routingEditing
//                         ? () => setState(() => _autoPrintStation = 'disabled')
//                         : null,
//                     isDanger: true,
//                   ),
//                 ],
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // ── KOT Toggle Row ─────────────────────────────────────────────────────────────
// class _KotToggleRow extends StatelessWidget {
//   final IconData icon;
//   final String title, subtitle;
//   final bool value, enabled;
//   final ValueChanged<bool>? onChanged;
//
//   const _KotToggleRow({
//     required this.icon,
//     required this.title,
//     required this.subtitle,
//     required this.value,
//     required this.enabled,
//     this.onChanged,
//   });
//
//   @override
//   Widget build(BuildContext context) => Container(
//     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//     decoration: BoxDecoration(
//       color: kBg,
//       borderRadius: BorderRadius.circular(10),
//       border: Border.all(color: kBorder),
//     ),
//     child: Row(
//       children: [
//         Container(
//           padding: const EdgeInsets.all(8),
//           decoration: BoxDecoration(
//             color: (value ? kPrimary : kText2).withOpacity(0.1),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Icon(icon, size: 18, color: value ? kPrimary : kText2),
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 title,
//                 style: const TextStyle(
//                   fontSize: 13,
//                   fontWeight: FontWeight.w700,
//                   color: kText1,
//                 ),
//               ),
//               Text(
//                 subtitle,
//                 style: const TextStyle(fontSize: 11, color: kText2),
//               ),
//             ],
//           ),
//         ),
//         Switch(
//           value: value,
//           onChanged: enabled ? onChanged : null,
//           activeColor: kPrimary,
//           inactiveThumbColor: enabled ? kText2 : kBorder,
//           inactiveTrackColor: kBorder,
//         ),
//       ],
//     ),
//   );
// }
//
// // ── Auto Print Row ─────────────────────────────────────────────────────────────
// class _AutoPrintRow extends StatelessWidget {
//   final String title, subtitle;
//   final bool isSelected, enabled;
//   final VoidCallback? onTap;
//   final bool isDanger;
//
//   const _AutoPrintRow({
//     required this.title,
//     required this.subtitle,
//     required this.isSelected,
//     required this.enabled,
//     this.onTap,
//     this.isDanger = false,
//   });
//
//   @override
//   Widget build(BuildContext context) => GestureDetector(
//     onTap: enabled ? onTap : null,
//     child: Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
//       decoration: BoxDecoration(
//         color: isSelected
//             ? (isDanger
//                   ? kDanger.withOpacity(0.08)
//                   : kPrimary.withOpacity(0.08))
//             : kBg,
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(
//           color: isSelected ? (isDanger ? kDanger : kPrimary) : kBorder,
//           width: isSelected ? 1.5 : 1,
//         ),
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: isSelected ? (isDanger ? kDanger : kPrimary) : kBorder,
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Icon(
//               title == 'Chef'
//                   ? Icons.restaurant_menu_outlined
//                   : title == 'Cashier'
//                   ? Icons.receipt_long_outlined
//                   : Icons.block_outlined,
//               size: 18,
//               color: isSelected ? Colors.white : kText2,
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: TextStyle(
//                     fontSize: 13,
//                     fontWeight: FontWeight.w700,
//                     color: isSelected
//                         ? (isDanger ? kDanger : kPrimary)
//                         : kText1,
//                   ),
//                 ),
//                 Text(
//                   subtitle,
//                   style: const TextStyle(fontSize: 11, color: kText2),
//                 ),
//               ],
//             ),
//           ),
//           if (isSelected)
//             Icon(
//               Icons.check_circle,
//               size: 20,
//               color: isDanger ? kDanger : kPrimary,
//             ),
//         ],
//       ),
//     ),
//   );
// }
//
// // ── Retry Banner ───────────────────────────────────────────────────────────────
// class _RetryBanner extends StatelessWidget {
//   final String msg;
//   final VoidCallback onRetry;
//   const _RetryBanner({required this.msg, required this.onRetry});
//   @override
//   Widget build(BuildContext context) => Container(
//     padding: const EdgeInsets.all(12),
//     decoration: BoxDecoration(
//       color: kDanger.withOpacity(0.06),
//       borderRadius: BorderRadius.circular(8),
//       border: Border.all(color: kDanger.withOpacity(0.2)),
//     ),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Row(
//           children: [
//             Icon(Icons.error_outline, color: kDanger, size: 15),
//             SizedBox(width: 6),
//             Text(
//               'Failed to load timings',
//               style: TextStyle(
//                 color: kDanger,
//                 fontWeight: FontWeight.w700,
//                 fontSize: 12,
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 4),
//         Text(msg, style: const TextStyle(fontSize: 11, color: kText2)),
//         const SizedBox(height: 8),
//         GestureDetector(
//           onTap: onRetry,
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
//             decoration: BoxDecoration(
//               color: kDanger,
//               borderRadius: BorderRadius.circular(6),
//             ),
//             child: const Text(
//               'Retry',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 11,
//                 fontWeight: FontWeight.w700,
//               ),
//             ),
//           ),
//         ),
//       ],
//     ),
//   );
// }
//
// // ── Day Row ────────────────────────────────────────────────────────────────────
// class _DayRow extends StatelessWidget {
//   final DayTiming t;
//   final bool isToday;
//   final ValueChanged<String> onOpen, onClose;
//   const _DayRow({
//     required this.t,
//     required this.isToday,
//     required this.onOpen,
//     required this.onClose,
//   });
//
//   @override
//   Widget build(BuildContext context) => Container(
//     margin: const EdgeInsets.only(bottom: 8),
//     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//     child: Column(
//       children: [
//         Row(
//           children: [
//             Text(
//               t.day,
//               style: TextStyle(
//                 fontSize: 13,
//                 fontWeight: FontWeight.w700,
//                 color: isToday ? kPrimary : kText1,
//               ),
//             ),
//             if (isToday) ...[
//               const SizedBox(width: 6),
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                 decoration: BoxDecoration(
//                   color: kPrimary,
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: const Text(
//                   'Today',
//                   style: TextStyle(
//                     fontSize: 9,
//                     color: Colors.white,
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),
//               ),
//             ],
//           ],
//         ),
//         const SizedBox(height: 8),
//         Row(
//           children: [
//             Expanded(
//               child: _TimeField(
//                 label: 'Open',
//                 value: t.open,
//                 onChanged: onOpen,
//               ),
//             ),
//             const SizedBox(width: 10),
//             Expanded(
//               child: _TimeField(
//                 label: 'Close',
//                 value: t.close,
//                 onChanged: onClose,
//               ),
//             ),
//           ],
//         ),
//       ],
//     ),
//   );
// }
//
// // ── Time Field ─────────────────────────────────────────────────────────────────
// class _TimeField extends StatelessWidget {
//   final String label, value;
//   final ValueChanged<String> onChanged;
//   const _TimeField({
//     required this.label,
//     required this.value,
//     required this.onChanged,
//   });
//
//   @override
//   Widget build(BuildContext context) => GestureDetector(
//     onTap: () async {
//       final p = value.split(':');
//       final init = TimeOfDay(
//         hour: int.tryParse(p[0]) ?? 9,
//         minute: int.tryParse(p.length > 1 ? p[1] : '0') ?? 0,
//       );
//       final picked = await showTimePicker(
//         context: context,
//         initialTime: init,
//         builder: (c, child) => Theme(
//           data: ThemeData.light().copyWith(
//             colorScheme: const ColorScheme.light(primary: kPrimary),
//           ),
//           child: child!,
//         ),
//       );
//       if (picked != null) {
//         onChanged(
//           '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}',
//         );
//       }
//     },
//     child: Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: kBorder),
//       ),
//       child: Row(
//         children: [
//           Text(
//             label,
//             style: const TextStyle(
//               fontSize: 11,
//               color: kText2,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           const Spacer(),
//           const Icon(Icons.access_time_rounded, size: 13, color: kPrimary),
//           const SizedBox(width: 4),
//           Text(
//             _fmt(value),
//             style: const TextStyle(
//               fontSize: 12,
//               fontWeight: FontWeight.w700,
//               color: kText1,
//             ),
//           ),
//         ],
//       ),
//     ),
//   );
// }
//
// // ── Routing Row ────────────────────────────────────────────────────────────────
// class _RoutingRow extends StatelessWidget {
//   final String icon, title, subtitle, leftLabel, rightLabel;
//   final bool isLeft;
//   final VoidCallback? onToggle;
//   const _RoutingRow({
//     required this.icon,
//     required this.title,
//     required this.subtitle,
//     required this.leftLabel,
//     required this.rightLabel,
//     required this.isLeft,
//     this.onToggle,
//   });
//
//   @override
//   Widget build(BuildContext context) => Container(
//     padding: const EdgeInsets.all(12),
//     decoration: BoxDecoration(
//       color: kBg,
//       borderRadius: BorderRadius.circular(10),
//       border: Border.all(color: kBorder),
//     ),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Text(icon, style: const TextStyle(fontSize: 20)),
//             const SizedBox(width: 10),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     title,
//                     style: const TextStyle(
//                       fontSize: 13,
//                       fontWeight: FontWeight.w700,
//                       color: kText1,
//                     ),
//                   ),
//                   Text(
//                     subtitle,
//                     style: const TextStyle(fontSize: 11, color: kText2),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 10),
//         Row(
//           children: [
//             _RBtn(
//               label: leftLabel,
//               active: isLeft,
//               onTap: (onToggle != null && !isLeft) ? onToggle : null,
//               disabled: onToggle == null,
//             ),
//             const SizedBox(width: 8),
//             _RBtn(
//               label: rightLabel,
//               active: !isLeft,
//               onTap: (onToggle != null && isLeft) ? onToggle : null,
//               disabled: onToggle == null,
//             ),
//           ],
//         ),
//       ],
//     ),
//   );
// }
//
// class _RBtn extends StatelessWidget {
//   final String label;
//   final bool active, disabled;
//   final VoidCallback? onTap;
//   const _RBtn({
//     required this.label,
//     required this.active,
//     this.disabled = false,
//     this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) => GestureDetector(
//     onTap: onTap,
//     child: AnimatedContainer(
//       duration: const Duration(milliseconds: 200),
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
//       decoration: BoxDecoration(
//         color: active
//             ? (disabled ? kPrimary.withOpacity(0.45) : kPrimary)
//             : Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(
//           color: active
//               ? (disabled ? kPrimary.withOpacity(0.3) : kPrimary)
//               : kBorder,
//         ),
//         boxShadow: (active && !disabled)
//             ? [BoxShadow(color: kPrimary.withOpacity(0.2), blurRadius: 6)]
//             : null,
//       ),
//       child: Text(
//         label,
//         style: TextStyle(
//           fontSize: 12,
//           fontWeight: FontWeight.w600,
//           color: active ? Colors.white : (disabled ? kBorder : kText2),
//         ),
//       ),
//     ),
//   );
// }
//
// // ── Offline Reasons Sheet ──────────────────────────────────────────────────────
// class _OfflineSheet extends StatefulWidget {
//   final Function(List<String>) onConfirm;
//   final VoidCallback onCancel;
//   const _OfflineSheet({required this.onConfirm, required this.onCancel});
//   @override
//   State<_OfflineSheet> createState() => _OfflineSheetState();
// }
//
// class _OfflineSheetState extends State<_OfflineSheet> {
//   static const _reasons = [
//     'Items out of stock',
//     'Ingredients not available',
//     'Kitchen equipment issue',
//     'Staff shortage',
//     'Power outage',
//     'Maintenance work',
//     'Weather conditions',
//   ];
//   final Set<String> _sel = {};
//   final _ctrl = TextEditingController();
//
//   @override
//   void dispose() {
//     _ctrl.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final keyboardH = MediaQuery.of(context).viewInsets.bottom;
//     return Container(
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       padding: EdgeInsets.only(
//         bottom: keyboardH + 16,
//         left: 20,
//         right: 20,
//         top: 12,
//       ),
//       child: SingleChildScrollView(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const SheetHandle(),
//             Row(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color: kWarning.withOpacity(0.12),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: const Icon(
//                     Icons.warning_amber_rounded,
//                     color: kWarning,
//                     size: 20,
//                   ),
//                 ),
//                 const SizedBox(width: 10),
//                 const Expanded(
//                   child: Text(
//                     'Reason for going offline',
//                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
//                   ),
//                 ),
//                 GestureDetector(
//                   onTap: widget.onCancel,
//                   child: const Icon(Icons.close, color: kText2, size: 20),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 6),
//             const Text(
//               'Select at least one reason:',
//               style: TextStyle(fontSize: 12, color: kText2),
//             ),
//             const SizedBox(height: 10),
//             ..._reasons.map(
//               (r) => CheckboxListTile(
//                 value: _sel.contains(r),
//                 onChanged: (v) =>
//                     setState(() => v! ? _sel.add(r) : _sel.remove(r)),
//                 title: Text(r, style: const TextStyle(fontSize: 13)),
//                 activeColor: kPrimary,
//                 contentPadding: EdgeInsets.zero,
//                 dense: true,
//                 controlAffinity: ListTileControlAffinity.leading,
//               ),
//             ),
//             const SizedBox(height: 6),
//             TextField(
//               controller: _ctrl,
//               maxLines: 2,
//               maxLength: 200,
//               decoration: InputDecoration(
//                 hintText: 'Other reason (optional)...',
//                 hintStyle: const TextStyle(fontSize: 12, color: kText2),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 contentPadding: const EdgeInsets.symmetric(
//                   horizontal: 12,
//                   vertical: 10,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 12),
//             Row(
//               children: [
//                 Expanded(
//                   child: KOutlineBtn(
//                     label: 'Cancel',
//                     onPressed: widget.onCancel,
//                   ),
//                 ),
//                 const SizedBox(width: 10),
//                 Expanded(
//                   child: KBtn(
//                     label: 'Go Offline',
//                     color: kWarning,
//                     onPressed: () {
//                       final list = [..._sel];
//                       if (_ctrl.text.trim().isNotEmpty)
//                         list.add('Other: ${_ctrl.text.trim()}');
//                       if (list.isEmpty) {
//                         showWarning(
//                           context,
//                           'Please select at least one reason',
//                         );
//                         return;
//                       }
//                       widget.onConfirm(list);
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../widgets/theme.dart';

String _fmt(String t) {
  final p = t.split(':');
  if (p.length < 2) return t;
  final h = int.tryParse(p[0]) ?? 0;
  final m = p[1];
  return '${h > 12 ? h - 12 : (h == 0 ? 12 : h)}:$m ${h >= 12 ? "PM" : "AM"}';
}

class GeneralControlsScreen extends StatefulWidget {
  const GeneralControlsScreen({super.key});
  @override
  State<GeneralControlsScreen> createState() => _GeneralControlsScreenState();
}

class _GeneralControlsScreenState extends State<GeneralControlsScreen> {
  // ── Status ────────────────────────────────────────────────────────────────
  bool _isOnline =
      false; // ✅ safe default — will be overwritten by _loadStatus()
  bool _statusBusy = false;
  bool _statusLoading = true; // shows loader until first fetch completes

  // ── Timings ───────────────────────────────────────────────────────────────
  static const _days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  late List<DayTiming> _timings;
  bool _timingsLoading = true;
  String? _timingsError;
  bool _savingAllTimings = false;
  String _autoPrintStation = 'disabled';
  bool _timingsEdited = false;

  // ── Order routing + KOT ───────────────────────────────────────────────────
  BillingConfig? _billing;
  bool _routingLoading = true;
  bool _routingSaving = false;
  bool _routingEditing = false;

  @override
  void initState() {
    super.initState();
    dev.log(
      '[GeneralControls] initState — building default timings for ${_days.length} days',
      name: 'GCS',
    );
    _timings = _days.map((d) => DayTiming(day: d)).toList();
    _load();
  }

  Future<void> _load() {
    dev.log(
      '[GeneralControls] _load — starting status + timings + routing fetch in parallel',
      name: 'GCS',
    );
    return Future.wait([_loadStatus(), _loadTimings(), _loadRouting()]);
  }

  // ── Fetch restaurant online/offline status ────────────────────────────────
  Future<void> _loadStatus() async {
    dev.log(
      '[GeneralControls] _loadStatus — fetching restaurant status from server...',
      name: 'GCS',
    );
    setState(() => _statusLoading = true);
    try {
      final online = await RestaurantStatusApi.fetchStatus();
      dev.log(
        '[GeneralControls] _loadStatus — server says: online=$online',
        name: 'GCS',
      );
      if (mounted) setState(() => _isOnline = online);
    } catch (e, stack) {
      dev.log(
        '[GeneralControls] _loadStatus — ERROR: $e',
        name: 'GCS',
        error: e,
        stackTrace: stack,
      );
      // Keep _isOnline = false on error (safe default — don't show open if unsure)
    } finally {
      if (mounted) setState(() => _statusLoading = false);
    }
  }

  // ── Fetch timings ─────────────────────────────────────────────────────────
  Future<void> _loadTimings() async {
    dev.log('[GeneralControls] _loadTimings — fetching...', name: 'GCS');
    setState(() {
      _timingsLoading = true;
      _timingsError = null;
    });
    try {
      final list = await TimingsApi.fetchAll();
      dev.log(
        '[GeneralControls] _loadTimings — received ${list.length} timing(s): ${list.map((t) => t.day).toList()}',
        name: 'GCS',
      );
      if (mounted)
        setState(() {
          for (final t in list) {
            final i = _timings.indexWhere((x) => x.day == t.day);
            if (i != -1) {
              dev.log(
                '[GeneralControls] _loadTimings — merging ${t.day}: open=${t.open}, close=${t.close}',
                name: 'GCS',
              );
              _timings[i] = t;
            } else {
              dev.log(
                '[GeneralControls] _loadTimings — WARNING: day "${t.day}" not found in local list',
                name: 'GCS',
              );
            }
          }
          _timingsLoading = false;
          _timingsEdited = false;
        });
    } catch (e, stack) {
      dev.log(
        '[GeneralControls] _loadTimings — ERROR: $e',
        name: 'GCS',
        error: e,
        stackTrace: stack,
      );
      if (mounted)
        setState(() {
          _timingsError = e.toString();
          _timingsLoading = false;
        });
    }
  }

  // ── Fetch billing / order routing ─────────────────────────────────────────
  Future<void> _loadRouting() async {
    dev.log(
      '[GeneralControls] _loadRouting — fetching billing config...',
      name: 'GCS',
    );
    setState(() => _routingLoading = true);
    try {
      final b = await BillingApi.fetch();
      dev.log(
        '[GeneralControls] _loadRouting — received: ${b != null ? 'autoPrint=${b.autoPrint}, regularOrders=${b.regularOrders}, onlineOrders=${b.onlineOrders}, cashierKot=${b.cashierKot}, chefKot=${b.chefKot}' : 'null'}',
        name: 'GCS',
      );
      if (mounted)
        setState(() {
          _billing = b;
          if (b != null) {
            _autoPrintStation = b.autoPrint ? 'chef' : 'disabled';
            dev.log(
              '[GeneralControls] _loadRouting — autoPrintStation set to "$_autoPrintStation"',
              name: 'GCS',
            );
          }
          _routingLoading = false;
        });
    } catch (e, stack) {
      dev.log(
        '[GeneralControls] _loadRouting — ERROR: $e',
        name: 'GCS',
        error: e,
        stackTrace: stack,
      );
      if (mounted) setState(() => _routingLoading = false);
    }
  }

  // ── Restaurant status ─────────────────────────────────────────────────────
  Future<void> _toggle(bool val) async {
    dev.log(
      '[GeneralControls] _toggle — user tapped toggle: val=$val (current _isOnline=$_isOnline)',
      name: 'GCS',
    );
    if (val) {
      setState(() {
        _isOnline = true;
        _statusBusy = true;
      });
      try {
        dev.log(
          '[GeneralControls] _toggle — calling RestaurantStatusApi.setOnline()...',
          name: 'GCS',
        );
        await RestaurantStatusApi.setOnline();
        dev.log('[GeneralControls] _toggle — setOnline() SUCCESS', name: 'GCS');
        if (mounted) showSuccess(context, 'Restaurant is now Open ✅');
      } catch (e, stack) {
        dev.log(
          '[GeneralControls] _toggle — setOnline() FAILED: $e',
          name: 'GCS',
          error: e,
          stackTrace: stack,
        );
        if (mounted) {
          setState(() => _isOnline = false);
          showError(context, 'Failed: $e');
        }
      } finally {
        if (mounted) setState(() => _statusBusy = false);
        dev.log(
          '[GeneralControls] _toggle — done. _isOnline=$_isOnline',
          name: 'GCS',
        );
      }
    } else {
      dev.log(
        '[GeneralControls] _toggle — going offline, showing reason sheet',
        name: 'GCS',
      );
      _showOfflineSheet();
    }
  }

  void _showOfflineSheet() => showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _OfflineSheet(
      onConfirm: (reasons) async {
        dev.log(
          '[GeneralControls] _showOfflineSheet — confirmed offline with reasons: $reasons',
          name: 'GCS',
        );
        Navigator.pop(context);
        setState(() {
          _isOnline = false;
          _statusBusy = true;
        });
        try {
          dev.log(
            '[GeneralControls] _showOfflineSheet — calling RestaurantStatusApi.setOffline()...',
            name: 'GCS',
          );
          await RestaurantStatusApi.setOffline(reasons);
          dev.log(
            '[GeneralControls] _showOfflineSheet — setOffline() SUCCESS',
            name: 'GCS',
          );
          if (mounted) showSuccess(context, 'Restaurant is now Closed');
        } catch (e, stack) {
          dev.log(
            '[GeneralControls] _showOfflineSheet — setOffline() FAILED: $e',
            name: 'GCS',
            error: e,
            stackTrace: stack,
          );
          if (mounted) {
            setState(() => _isOnline = true);
            showError(context, 'Failed: $e');
          }
        } finally {
          if (mounted) setState(() => _statusBusy = false);
          dev.log(
            '[GeneralControls] _showOfflineSheet — done. _isOnline=$_isOnline',
            name: 'GCS',
          );
        }
      },
      onCancel: () => Navigator.pop(context),
    ),
  );

  // ── Save ALL timings at once ───────────────────────────────────────────────
  Future<void> _saveAllTimings() async {
    dev.log(
      '[GeneralControls] _saveAllTimings — saving ${_timings.length} timings...',
      name: 'GCS',
    );
    for (final t in _timings) {
      dev.log(
        '[GeneralControls] _saveAllTimings — ${t.day}: open=${t.open}, close=${t.close}',
        name: 'GCS',
      );
    }
    setState(() => _savingAllTimings = true);
    try {
      final results = await Future.wait(
        List.generate(_timings.length, (i) => TimingsApi.save(_timings[i])),
      );
      dev.log(
        '[GeneralControls] _saveAllTimings — all ${results.length} timings saved successfully',
        name: 'GCS',
      );
      if (mounted) {
        setState(() {
          for (int i = 0; i < results.length; i++) _timings[i] = results[i];
        });
        showSuccess(context, 'All timings saved ✅');
        setState(() => _timingsEdited = false);
      }
    } catch (e, stack) {
      dev.log(
        '[GeneralControls] _saveAllTimings — ERROR: $e',
        name: 'GCS',
        error: e,
        stackTrace: stack,
      );
      if (mounted) showError(context, 'Failed: $e');
    } finally {
      if (mounted) setState(() => _savingAllTimings = false);
    }
  }

  // ── Save order routing + KOT ──────────────────────────────────────────────
  Future<void> _saveRouting() async {
    dev.log(
      '[GeneralControls] _saveRouting — saving billing config...',
      name: 'GCS',
    );
    setState(() => _routingSaving = true);
    try {
      _billing ??= BillingConfig();
      _billing!.autoPrint = _autoPrintStation != 'disabled';
      dev.log(
        '[GeneralControls] _saveRouting — payload: autoPrint=${_billing!.autoPrint}, regularOrders=${_billing!.regularOrders}, onlineOrders=${_billing!.onlineOrders}, cashierKot=${_billing!.cashierKot}, chefKot=${_billing!.chefKot}',
        name: 'GCS',
      );

      await BillingApi.save(_billing!);
      dev.log(
        '[GeneralControls] _saveRouting — BillingApi.save() SUCCESS',
        name: 'GCS',
      );
      if (mounted) {
        setState(() => _routingEditing = false);
        showSuccess(context, 'Settings saved ✅');
        _loadRouting();
      }
    } catch (e, stack) {
      dev.log(
        '[GeneralControls] _saveRouting — ERROR: $e',
        name: 'GCS',
        error: e,
        stackTrace: stack,
      );
      if (mounted) showError(context, 'Failed: $e');
    } finally {
      if (mounted) setState(() => _routingSaving = false);
    }
  }

  String get _today {
    const d = [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
    ];
    return d[DateTime.now().weekday % 7];
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return RefreshIndicator(
      color: kPrimary,
      onRefresh: _load,
      child: ListView(
        padding: EdgeInsets.fromLTRB(16, 12, 16, bottomPad + 24),
        children: [
          // ── 1. Restaurant Status ───────────────────────────────────────
          // KCard(
          //   leftBorderColor: _isOnline ? kSuccess : kDanger,
          //   child: Column(
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     children: [
          //       Row(
          //         crossAxisAlignment: CrossAxisAlignment.start,
          //         children: [
          //           Expanded(
          //             child: Column(
          //               crossAxisAlignment: CrossAxisAlignment.start,
          //               children: [
          //                 KSectionTitle(
          //                   'Restaurant Status',
          //                   dotColor: _isOnline ? kSuccess : kDanger,
          //                 ),
          //                 const SizedBox(height: 4),
          //                 const Text(
          //                   'Control whether your restaurant accepts orders',
          //                   style: TextStyle(fontSize: 12, color: kText2),
          //                 ),
          //               ],
          //             ),
          //           ),
          //           const SizedBox(width: 12),
          //           if (_statusBusy || _statusLoading)
          //             const Padding(
          //               padding: EdgeInsets.symmetric(vertical: 8),
          //               child: SizedBox(
          //                 width: 26,
          //                 height: 26,
          //                 child: CircularProgressIndicator(
          //                   strokeWidth: 2,
          //                   color: kPrimary,
          //                 ),
          //               ),
          //             )
          //           else
          //             Column(
          //               children: [
          //                 Switch(
          //                   value: _isOnline,
          //                   onChanged: _toggle,
          //                   activeColor: kSuccess,
          //                   inactiveThumbColor: kDanger,
          //                   inactiveTrackColor: kDanger.withOpacity(0.3),
          //                 ),
          //                 Text(
          //                   _isOnline ? 'Open' : 'Closed',
          //                   style: TextStyle(
          //                     fontSize: 10,
          //                     fontWeight: FontWeight.w800,
          //                     color: _isOnline ? kSuccess : kDanger,
          //                   ),
          //                 ),
          //               ],
          //             ),
          //         ],
          //       ),
          //       if (!_isOnline) ...[
          //         const SizedBox(height: 10),
          //         Container(
          //           padding: const EdgeInsets.all(10),
          //           decoration: BoxDecoration(
          //             color: kDanger.withOpacity(0.07),
          //             borderRadius: BorderRadius.circular(8),
          //             border: Border.all(color: kDanger.withOpacity(0.2)),
          //           ),
          //           child: const Row(
          //             children: [
          //               Icon(Icons.cancel_outlined, color: kDanger, size: 15),
          //               SizedBox(width: 8),
          //               Expanded(
          //                 child: Text(
          //                   "Customers see 'Restaurant is currently closed'",
          //                   style: TextStyle(fontSize: 12, color: kDanger),
          //                 ),
          //               ),
          //             ],
          //           ),
          //         ),
          //       ],
          //     ],
          //   ),
          // ),
          const SizedBox(height: 14),

          // ── 2. Weekly Operating Hours ──────────────────────────────────
          KCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: KSectionTitle('Weekly Operating Hours'),
                    ),
                    if (!_timingsLoading &&
                        _timingsError == null &&
                        _timingsEdited)
                      KBtn(
                        label: 'Save',
                        loading: _savingAllTimings,
                        onPressed: _saveAllTimings,
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                if (_timingsError != null)
                  _RetryBanner(msg: _timingsError!, onRetry: _loadTimings)
                else if (_timingsLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(color: kPrimary),
                    ),
                  )
                else
                  ..._timings.asMap().entries.map(
                    (e) => _DayRow(
                      t: e.value,
                      isToday: e.value.day == _today,
                      onOpen: (v) => setState(() {
                        _timings[e.key].open = v;
                        _timingsEdited = true;
                      }),
                      onClose: (v) => setState(() {
                        _timings[e.key].close = v;
                        _timingsEdited = true;
                      }),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // ── 3. Order Processing Mode ───────────────────────────────────
          KCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          KSectionTitle(
                            'Order Processing Mode',
                            dotColor: kWarning,
                          ),
                          SizedBox(height: 3),
                        ],
                      ),
                    ),
                    if (!_routingEditing)
                      GestureDetector(
                        onTap: () => setState(() => _routingEditing = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: kBg,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: kBorder),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.edit_outlined,
                                size: 13,
                                color: kText2,
                              ),
                              SizedBox(width: 5),
                              Text(
                                'Edit',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: kText2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Flexible(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: _routingSaving
                                  ? null
                                  : () {
                                      setState(() => _routingEditing = false);
                                      _loadRouting();
                                    },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 7,
                                ),
                                decoration: BoxDecoration(
                                  color: kBg,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: kBorder),
                                ),
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: kText2,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            KBtn(
                              label: 'Save',
                              loading: _routingSaving,
                              onPressed: _saveRouting,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                if (_routingLoading)
                  const Center(
                    child: CircularProgressIndicator(color: kPrimary),
                  )
                else ...[
                  // ── Order Routing rows ─────────────────────────────────
                  _RoutingRow(
                    icon: '🍽️',
                    title: 'Regular Orders',
                    subtitle: 'Walk-in & dine-in',
                    leftLabel: '👨‍🍳 Chef',
                    rightLabel: '🚚 Delivery',
                    isLeft: (_billing?.regularOrders ?? 'delivery') == 'chef',
                    onToggle: _routingEditing
                        ? () => setState(() {
                            _billing ??= BillingConfig();
                            _billing!.regularOrders =
                                _billing!.regularOrders == 'chef'
                                ? 'delivery'
                                : 'chef';
                          })
                        : null,
                  ),
                  const SizedBox(height: 10),
                  _RoutingRow(
                    icon: '🛵',
                    title: 'Online Orders',
                    subtitle: 'App & website orders',
                    leftLabel: '👨‍🍳 Chef',
                    rightLabel: '🏪 Cashier',
                    isLeft: (_billing?.onlineOrders ?? 'vendor') == 'chef',
                    onToggle: _routingEditing
                        ? () => setState(() {
                            _billing ??= BillingConfig();
                            _billing!.onlineOrders =
                                _billing!.onlineOrders == 'chef'
                                ? 'vendor'
                                : 'chef';
                          })
                        : null,
                  ),
                  const SizedBox(height: 14),

                  // ── KOT Settings ───────────────────────────────────────
                  const Divider(color: kBorder, height: 1),
                  const SizedBox(height: 14),
                  const Text(
                    'KOT Settings',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: kText1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Kitchen Order Ticket printing preferences',
                    style: TextStyle(fontSize: 12, color: kText2),
                  ),
                  const SizedBox(height: 12),

                  _KotToggleRow(
                    icon: Icons.receipt_long_outlined,
                    title: 'Cashier KOT',
                    subtitle: 'Print KOT at cashier station',
                    value: _billing?.cashierKot ?? false,
                    enabled: _routingEditing,
                    onChanged: _routingEditing
                        ? (v) => setState(() {
                            _billing ??= BillingConfig();
                            _billing!.cashierKot = v;
                          })
                        : null,
                  ),
                  const SizedBox(height: 10),
                  _KotToggleRow(
                    icon: Icons.restaurant_menu_outlined,
                    title: 'Chef KOT',
                    subtitle: 'Print KOT at kitchen / chef station',
                    value: _billing?.chefKot ?? false,
                    enabled: _routingEditing,
                    onChanged: _routingEditing
                        ? (v) => setState(() {
                            _billing ??= BillingConfig();
                            _billing!.chefKot = v;
                          })
                        : null,
                  ),
                  const SizedBox(height: 10),

                  const SizedBox(height: 14),
                  const Divider(color: kBorder, height: 1),
                  const SizedBox(height: 14),
                  const Text(
                    'Auto Print',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: kText1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Automatically print orders when received by cashier',
                    style: TextStyle(fontSize: 12, color: kText2),
                  ),
                  const SizedBox(height: 12),

                  _AutoPrintRow(
                    title: 'Chef',
                    subtitle: 'Send auto-print orders to kitchen',
                    isSelected: _autoPrintStation == 'chef',
                    enabled: _routingEditing,
                    onTap: _routingEditing
                        ? () => setState(() => _autoPrintStation = 'chef')
                        : null,
                  ),
                  const SizedBox(height: 8),
                  _AutoPrintRow(
                    title: 'Cashier',
                    subtitle: 'Send auto-print orders to cashier station',
                    isSelected: _autoPrintStation == 'cashier',
                    enabled: _routingEditing,
                    onTap: _routingEditing
                        ? () => setState(() => _autoPrintStation = 'cashier')
                        : null,
                  ),
                  const SizedBox(height: 8),
                  _AutoPrintRow(
                    title: 'Disable',
                    subtitle: 'Turn off auto-print functionality',
                    isSelected: _autoPrintStation == 'disabled',
                    enabled: _routingEditing,
                    onTap: _routingEditing
                        ? () => setState(() => _autoPrintStation = 'disabled')
                        : null,
                    isDanger: true,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── KOT Toggle Row ─────────────────────────────────────────────────────────────
class _KotToggleRow extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final bool value, enabled;
  final ValueChanged<bool>? onChanged;

  const _KotToggleRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.enabled,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: kBg,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: kBorder),
    ),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (value ? kPrimary : kText2).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: value ? kPrimary : kText2),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: kText1,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 11, color: kText2),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: enabled ? onChanged : null,
          activeColor: kPrimary,
          inactiveThumbColor: enabled ? kText2 : kBorder,
          inactiveTrackColor: kBorder,
        ),
      ],
    ),
  );
}

// ── Auto Print Row ─────────────────────────────────────────────────────────────
class _AutoPrintRow extends StatelessWidget {
  final String title, subtitle;
  final bool isSelected, enabled;
  final VoidCallback? onTap;
  final bool isDanger;

  const _AutoPrintRow({
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.enabled,
    this.onTap,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: enabled ? onTap : null,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: isSelected
            ? (isDanger
                  ? kDanger.withOpacity(0.08)
                  : kPrimary.withOpacity(0.08))
            : kBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSelected ? (isDanger ? kDanger : kPrimary) : kBorder,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected ? (isDanger ? kDanger : kPrimary) : kBorder,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              title == 'Chef'
                  ? Icons.restaurant_menu_outlined
                  : title == 'Cashier'
                  ? Icons.receipt_long_outlined
                  : Icons.block_outlined,
              size: 18,
              color: isSelected ? Colors.white : kText2,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isSelected
                        ? (isDanger ? kDanger : kPrimary)
                        : kText1,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 11, color: kText2),
                ),
              ],
            ),
          ),
          if (isSelected)
            Icon(
              Icons.check_circle,
              size: 20,
              color: isDanger ? kDanger : kPrimary,
            ),
        ],
      ),
    ),
  );
}

// ── Retry Banner ───────────────────────────────────────────────────────────────
class _RetryBanner extends StatelessWidget {
  final String msg;
  final VoidCallback onRetry;
  const _RetryBanner({required this.msg, required this.onRetry});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: kDanger.withOpacity(0.06),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: kDanger.withOpacity(0.2)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.error_outline, color: kDanger, size: 15),
            SizedBox(width: 6),
            Text(
              'Failed to load timings',
              style: TextStyle(
                color: kDanger,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(msg, style: const TextStyle(fontSize: 11, color: kText2)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onRetry,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: kDanger,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'Retry',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

// ── Day Row ────────────────────────────────────────────────────────────────────
class _DayRow extends StatelessWidget {
  final DayTiming t;
  final bool isToday;
  final ValueChanged<String> onOpen, onClose;
  const _DayRow({
    required this.t,
    required this.isToday,
    required this.onOpen,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    child: Column(
      children: [
        Row(
          children: [
            Text(
              t.day,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isToday ? kPrimary : kText1,
              ),
            ),
            if (isToday) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: kPrimary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Today',
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _TimeField(
                label: 'Open',
                value: t.open,
                onChanged: onOpen,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _TimeField(
                label: 'Close',
                value: t.close,
                onChanged: onClose,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

// ── Time Field ─────────────────────────────────────────────────────────────────
class _TimeField extends StatelessWidget {
  final String label, value;
  final ValueChanged<String> onChanged;
  const _TimeField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () async {
      final p = value.split(':');
      final init = TimeOfDay(
        hour: int.tryParse(p[0]) ?? 9,
        minute: int.tryParse(p.length > 1 ? p[1] : '0') ?? 0,
      );
      final picked = await showTimePicker(
        context: context,
        initialTime: init,
        builder: (c, child) => Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: kPrimary),
          ),
          child: child!,
        ),
      );
      if (picked != null) {
        onChanged(
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}',
        );
      }
    },
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: kBorder),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: kText2,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          const Icon(Icons.access_time_rounded, size: 13, color: kPrimary),
          const SizedBox(width: 4),
          Text(
            _fmt(value),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: kText1,
            ),
          ),
        ],
      ),
    ),
  );
}

// ── Routing Row ────────────────────────────────────────────────────────────────
class _RoutingRow extends StatelessWidget {
  final String icon, title, subtitle, leftLabel, rightLabel;
  final bool isLeft;
  final VoidCallback? onToggle;
  const _RoutingRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.leftLabel,
    required this.rightLabel,
    required this.isLeft,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: kBg,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: kBorder),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: kText1,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 11, color: kText2),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _RBtn(
              label: leftLabel,
              active: isLeft,
              onTap: (onToggle != null && !isLeft) ? onToggle : null,
              disabled: onToggle == null,
            ),
            const SizedBox(width: 8),
            _RBtn(
              label: rightLabel,
              active: !isLeft,
              onTap: (onToggle != null && isLeft) ? onToggle : null,
              disabled: onToggle == null,
            ),
          ],
        ),
      ],
    ),
  );
}

class _RBtn extends StatelessWidget {
  final String label;
  final bool active, disabled;
  final VoidCallback? onTap;
  const _RBtn({
    required this.label,
    required this.active,
    this.disabled = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: active
            ? (disabled ? kPrimary.withOpacity(0.45) : kPrimary)
            : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: active
              ? (disabled ? kPrimary.withOpacity(0.3) : kPrimary)
              : kBorder,
        ),
        boxShadow: (active && !disabled)
            ? [BoxShadow(color: kPrimary.withOpacity(0.2), blurRadius: 6)]
            : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: active ? Colors.white : (disabled ? kBorder : kText2),
        ),
      ),
    ),
  );
}

// ── Offline Reasons Sheet ──────────────────────────────────────────────────────
class _OfflineSheet extends StatefulWidget {
  final Function(List<String>) onConfirm;
  final VoidCallback onCancel;
  const _OfflineSheet({required this.onConfirm, required this.onCancel});
  @override
  State<_OfflineSheet> createState() => _OfflineSheetState();
}

class _OfflineSheetState extends State<_OfflineSheet> {
  static const _reasons = [
    'Items out of stock',
    'Ingredients not available',
    'Kitchen equipment issue',
    'Staff shortage',
    'Power outage',
    'Maintenance work',
    'Weather conditions',
  ];
  final Set<String> _sel = {};
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keyboardH = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: keyboardH + 16,
        left: 20,
        right: 20,
        top: 12,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SheetHandle(),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: kWarning.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: kWarning,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Reason for going offline',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                ),
                GestureDetector(
                  onTap: widget.onCancel,
                  child: const Icon(Icons.close, color: kText2, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Select at least one reason:',
              style: TextStyle(fontSize: 12, color: kText2),
            ),
            const SizedBox(height: 10),
            ..._reasons.map(
              (r) => CheckboxListTile(
                value: _sel.contains(r),
                onChanged: (v) =>
                    setState(() => v! ? _sel.add(r) : _sel.remove(r)),
                title: Text(r, style: const TextStyle(fontSize: 13)),
                activeColor: kPrimary,
                contentPadding: EdgeInsets.zero,
                dense: true,
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _ctrl,
              maxLines: 2,
              maxLength: 200,
              decoration: InputDecoration(
                hintText: 'Other reason (optional)...',
                hintStyle: const TextStyle(fontSize: 12, color: kText2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: KOutlineBtn(
                    label: 'Cancel',
                    onPressed: widget.onCancel,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: KBtn(
                    label: 'Go Offline',
                    color: kWarning,
                    onPressed: () {
                      final list = [..._sel];
                      if (_ctrl.text.trim().isNotEmpty)
                        list.add('Other: ${_ctrl.text.trim()}');
                      if (list.isEmpty) {
                        showWarning(
                          context,
                          'Please select at least one reason',
                        );
                        return;
                      }
                      widget.onConfirm(list);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
