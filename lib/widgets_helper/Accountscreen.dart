// import 'package:flutter/material.dart';
//
// // ─── Constants ────────────────────────────────────────────────────────────────
// const kOrange = Color(0xFFE8622A);
// const kOrangeDark = Color(0xFFD4541F);
// const kOrangeLight = Color(0xFFFFF0EB);
// const kGreen = Color(0xFF2EAF72);
// const kGreenBg = Color(0xFFF0FAF5);
// const kRed = Color(0xFFE53935);
// const kTextDark = Color(0xFF1A1A1A);
// const kTextGrey = Color(0xFF9E9E9E);
// const kBorder = Color(0xFFEEEEEE);
// const kBg = Color(0xFFF8F8F8);
//
// // ─── Data Models ──────────────────────────────────────────────────────────────
// class LedgerEntry {
//   final String date;
//   final double amount;
//   const LedgerEntry({required this.date, required this.amount});
// }
//
// class SettlementEntry {
//   final String period;
//   final double amount;
//   final String status;
//   const SettlementEntry({
//     required this.period,
//     required this.amount,
//     required this.status,
//   });
// }
//
// // ─── Main Screen ──────────────────────────────────────────────────────────────
// class AccountScreen extends StatefulWidget {
//   const AccountScreen({super.key});
//   @override
//   State<AccountScreen> createState() => _AccountScreenState();
// }
//
// class _AccountScreenState extends State<AccountScreen>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//
//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 3, vsync: this);
//   }
//
//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       // ── SafeArea: single top-level wrap — tab children are inside this ──────
//       body: SafeArea(
//         child: Column(
//           children: [
//             _TabBar(controller: _tabController),
//             Expanded(
//               child: TabBarView(
//                 controller: _tabController,
//                 children: const [LedgerTab(), SettlementTab(), CreditsTab()],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // ─── Custom Tab Bar ───────────────────────────────────────────────────────────
// // FIX: each _TabButton is wrapped in Expanded so the three buttons share the
// // available width equally and never overflow — no matter how long the label is.
// class _TabBar extends StatelessWidget {
//   final TabController controller;
//   const _TabBar({required this.controller});
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
//       child: Row(
//         children: [
//           Expanded(
//             child: _TabButton(
//               label: 'LEDGER',
//               index: 0,
//               controller: controller,
//             ),
//           ),
//           const SizedBox(width: 8),
//           Expanded(
//             child: _TabButton(
//               label: 'SETTLEMENT',
//               index: 1,
//               controller: controller,
//             ),
//           ),
//           const SizedBox(width: 8),
//           Expanded(
//             child: _TabButton(
//               label: 'CREDITS',
//               index: 2,
//               controller: controller,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _TabButton extends StatefulWidget {
//   final String label;
//   final int index;
//   final TabController controller;
//   const _TabButton({
//     required this.label,
//     required this.index,
//     required this.controller,
//   });
//   @override
//   State<_TabButton> createState() => _TabButtonState();
// }
//
// class _TabButtonState extends State<_TabButton> {
//   @override
//   void initState() {
//     super.initState();
//     widget.controller.addListener(_onTabChanged);
//   }
//
//   void _onTabChanged() {
//     if (mounted) setState(() {});
//   }
//
//   @override
//   void dispose() {
//     widget.controller.removeListener(_onTabChanged);
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final isActive = widget.controller.index == widget.index;
//     return GestureDetector(
//       onTap: () => widget.controller.animateTo(widget.index),
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 200),
//         height: 44,
//         // Width comes from Expanded in _TabBar — no fixed horizontal padding needed
//         alignment: Alignment.center,
//         decoration: BoxDecoration(
//           color: isActive ? kOrange : Colors.white,
//           borderRadius: BorderRadius.circular(8),
//           border: Border.all(color: isActive ? kOrange : kBorder, width: 1.5),
//         ),
//         child: Text(
//           widget.label,
//           style: TextStyle(
//             color: isActive ? Colors.white : kTextDark,
//             fontWeight: FontWeight.w700,
//             fontSize: 13,
//             letterSpacing: 0.5,
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // ─── Shared Widgets ───────────────────────────────────────────────────────────
//
// class _NetAmountBanner extends StatelessWidget {
//   final String amount;
//   const _NetAmountBanner({required this.amount});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.symmetric(vertical: 18),
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           colors: [kOrange, kOrangeDark],
//           begin: Alignment.centerLeft,
//           end: Alignment.centerRight,
//         ),
//         borderRadius: BorderRadius.circular(14),
//       ),
//       child: Column(
//         children: [
//           const Text(
//             'Net Amount',
//             style: TextStyle(
//               color: Colors.white70,
//               fontSize: 14,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             amount,
//             style: const TextStyle(
//               color: Colors.white,
//               fontSize: 22,
//               fontWeight: FontWeight.w700,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // _SearchAndFilter: search box + date filter + export button in a Row.
// // All three items are flex-sized so they never overflow on narrow screens.
// class _SearchAndFilter extends StatelessWidget {
//   final String hint;
//   final String filterLabel;
//   const _SearchAndFilter({required this.hint, required this.filterLabel});
//
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         // Search field — takes remaining space
//         Expanded(
//           child: Container(
//             height: 44,
//             decoration: BoxDecoration(
//               color: kBg,
//               borderRadius: BorderRadius.circular(10),
//               border: Border.all(color: kBorder),
//             ),
//             child: const Row(
//               children: [
//                 SizedBox(width: 12),
//                 Icon(Icons.search, color: kTextGrey, size: 18),
//                 SizedBox(width: 8),
//                 Flexible(
//                   child: Text(
//                     'Search…',
//                     style: TextStyle(color: kTextGrey, fontSize: 14),
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//         const SizedBox(width: 8),
//         // Date filter — fixed intrinsic width, but text wrapped safely
//         Container(
//           height: 44,
//           padding: const EdgeInsets.symmetric(horizontal: 10),
//           decoration: BoxDecoration(
//             color: kBg,
//             borderRadius: BorderRadius.circular(10),
//             border: Border.all(color: kBorder),
//           ),
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const Icon(
//                 Icons.calendar_today_outlined,
//                 size: 16,
//                 color: kTextGrey,
//               ),
//               const SizedBox(width: 6),
//               Text(
//                 filterLabel,
//                 style: const TextStyle(
//                   color: kTextDark,
//                   fontSize: 13,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//               const SizedBox(width: 4),
//               const Icon(Icons.keyboard_arrow_down, size: 18, color: kTextGrey),
//             ],
//           ),
//         ),
//         const SizedBox(width: 8),
//         // Export button — fixed intrinsic width
//         _ExportButton(),
//       ],
//     );
//   }
// }
//
// class _ExportButton extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 44,
//       padding: const EdgeInsets.symmetric(horizontal: 12),
//       decoration: BoxDecoration(
//         color: kOrange,
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: const Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(Icons.file_download_outlined, color: Colors.white, size: 18),
//           SizedBox(width: 6),
//           Text(
//             'Export',
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 13,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _EntryCard extends StatelessWidget {
//   final Widget leading;
//   final Widget trailing;
//   final Widget? subtitle;
//   const _EntryCard({
//     required this.leading,
//     required this.trailing,
//     this.subtitle,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 10),
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: kBorder),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.03),
//             blurRadius: 4,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 leading,
//                 if (subtitle != null) ...[const SizedBox(height: 4), subtitle!],
//               ],
//             ),
//           ),
//           trailing,
//         ],
//       ),
//     );
//   }
// }
//
// // ─── Ledger Tab ───────────────────────────────────────────────────────────────
// // SafeArea: NOT needed — lives inside AccountScreen's SafeArea (TabBarView).
// // Bottom padding respects home indicator via MediaQuery.
// class LedgerTab extends StatelessWidget {
//   const LedgerTab({super.key});
//
//   static const _entries = [
//     LedgerEntry(date: 'April 8', amount: 15144.36),
//     LedgerEntry(date: 'April 7', amount: 19786.37),
//     LedgerEntry(date: 'April 6', amount: 15343.96),
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     final bottomPad = MediaQuery.of(context).padding.bottom;
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
//       child: Column(
//         children: [
//           const _SearchAndFilter(
//             hint: 'Search by date...',
//             filterLabel: 'This Week',
//           ),
//           const SizedBox(height: 16),
//           const _NetAmountBanner(amount: '₹50,274.69'),
//           const SizedBox(height: 16),
//           Expanded(
//             child: ListView.builder(
//               // Bottom padding clears the home indicator
//               padding: EdgeInsets.only(bottom: 16 + bottomPad),
//               itemCount: _entries.length,
//               itemBuilder: (_, i) {
//                 final e = _entries[i];
//                 return _EntryCard(
//                   leading: Text(
//                     e.date,
//                     style: const TextStyle(
//                       fontWeight: FontWeight.w700,
//                       fontSize: 15,
//                       color: kTextDark,
//                     ),
//                   ),
//                   trailing: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Text(
//                         '₹${_fmt(e.amount)}',
//                         style: const TextStyle(
//                           color: kOrange,
//                           fontWeight: FontWeight.w700,
//                           fontSize: 15,
//                         ),
//                       ),
//                       const SizedBox(width: 10),
//                       Container(
//                         width: 36,
//                         height: 36,
//                         decoration: BoxDecoration(
//                           color: kBg,
//                           borderRadius: BorderRadius.circular(8),
//                           border: Border.all(color: kBorder),
//                         ),
//                         child: const Icon(
//                           Icons.file_download_outlined,
//                           color: kOrange,
//                           size: 18,
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   String _fmt(double v) {
//     final s = v.toStringAsFixed(2);
//     final parts = s.split('.');
//     final buf = StringBuffer();
//     for (var i = 0; i < parts[0].length; i++) {
//       if (i > 0 && (parts[0].length - i) % 3 == 0) buf.write(',');
//       buf.write(parts[0][i]);
//     }
//     return '${buf.toString()}.${parts[1]}';
//   }
// }
//
// // ─── Settlement Tab ───────────────────────────────────────────────────────────
// // SafeArea: NOT needed — inside AccountScreen's SafeArea.
// class SettlementTab extends StatelessWidget {
//   const SettlementTab({super.key});
//
//   static const _entries = [
//     SettlementEntry(
//       period: 'April 7, 12:00 AM - April 7, 11:59 PM',
//       amount: 19786.37,
//       status: 'Pending Settlement',
//     ),
//     SettlementEntry(
//       period: 'April 6, 12:00 AM - April 6, 11:59 PM',
//       amount: 15343.96,
//       status: 'Pending Settlement',
//     ),
//     SettlementEntry(
//       period: 'April 4, 12:00 AM - April 4, 11:59 PM',
//       amount: 5796.58,
//       status: 'Pending Settlement',
//     ),
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     final bottomPad = MediaQuery.of(context).padding.bottom;
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
//       child: Column(
//         children: [
//           const _SearchAndFilter(
//             hint: 'Search settlements...',
//             filterLabel: 'This Month',
//           ),
//           const SizedBox(height: 16),
//           const _NetAmountBanner(amount: '₹40,926.91'),
//           const SizedBox(height: 16),
//           Expanded(
//             child: ListView.builder(
//               padding: EdgeInsets.only(bottom: 16 + bottomPad),
//               itemCount: _entries.length,
//               itemBuilder: (_, i) {
//                 final e = _entries[i];
//                 return _EntryCard(
//                   leading: Text(
//                     e.period,
//                     style: const TextStyle(
//                       fontWeight: FontWeight.w600,
//                       fontSize: 14,
//                       color: kTextDark,
//                     ),
//                   ),
//                   subtitle: Text(
//                     'Status: ${e.status}',
//                     style: const TextStyle(
//                       color: kOrange,
//                       fontSize: 13,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                   trailing: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Text(
//                         '₹${_fmt(e.amount)}',
//                         style: const TextStyle(
//                           color: kOrange,
//                           fontWeight: FontWeight.w700,
//                           fontSize: 15,
//                         ),
//                       ),
//                       const SizedBox(width: 10),
//                       Container(
//                         width: 36,
//                         height: 36,
//                         decoration: BoxDecoration(
//                           color: kBg,
//                           borderRadius: BorderRadius.circular(8),
//                           border: Border.all(color: kBorder),
//                         ),
//                         child: const Icon(
//                           Icons.file_download_outlined,
//                           color: kOrange,
//                           size: 18,
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   String _fmt(double v) {
//     final s = v.toStringAsFixed(2);
//     final parts = s.split('.');
//     final buf = StringBuffer();
//     for (var i = 0; i < parts[0].length; i++) {
//       if (i > 0 && (parts[0].length - i) % 3 == 0) buf.write(',');
//       buf.write(parts[0][i]);
//     }
//     return '${buf.toString()}.${parts[1]}';
//   }
// }
//
// // ─── Credits Tab ──────────────────────────────────────────────────────────────
// // SafeArea: NOT needed — inside AccountScreen's SafeArea.
// // The filter Row is reconstructed with mainAxisSize: min on fixed-width items
// // so the "Export" button never overflows.
// class CreditsTab extends StatefulWidget {
//   const CreditsTab({super.key});
//   @override
//   State<CreditsTab> createState() => _CreditsTabState();
// }
//
// class _CreditsTabState extends State<CreditsTab> {
//   final _amountController = TextEditingController();
//
//   @override
//   void dispose() {
//     _amountController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       padding: EdgeInsets.fromLTRB(
//         16,
//         16,
//         16,
//         16 + MediaQuery.of(context).padding.bottom,
//       ),
//       child: Column(
//         children: [
//           // ── Search + date filter + export (same Row fix as _SearchAndFilter) ──
//           Row(
//             children: [
//               Expanded(
//                 child: Container(
//                   height: 44,
//                   decoration: BoxDecoration(
//                     color: kBg,
//                     borderRadius: BorderRadius.circular(10),
//                     border: Border.all(color: kBorder),
//                   ),
//                   child: const Row(
//                     children: [
//                       SizedBox(width: 12),
//                       Icon(Icons.search, color: kTextGrey, size: 18),
//                       SizedBox(width: 8),
//                       Flexible(
//                         child: Text(
//                           'Search credit history...',
//                           style: TextStyle(color: kTextGrey, fontSize: 14),
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 8),
//               Container(
//                 height: 44,
//                 padding: const EdgeInsets.symmetric(horizontal: 10),
//                 decoration: BoxDecoration(
//                   color: kBg,
//                   borderRadius: BorderRadius.circular(10),
//                   border: Border.all(color: kBorder),
//                 ),
//                 child: const Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Icon(
//                       Icons.calendar_today_outlined,
//                       size: 16,
//                       color: kTextGrey,
//                     ),
//                     SizedBox(width: 6),
//                     Text(
//                       'This Month',
//                       style: TextStyle(
//                         color: kTextDark,
//                         fontSize: 13,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                     SizedBox(width: 4),
//                     Icon(Icons.keyboard_arrow_down, size: 18, color: kTextGrey),
//                   ],
//                 ),
//               ),
//               const SizedBox(width: 8),
//               Container(
//                 height: 44,
//                 padding: const EdgeInsets.symmetric(horizontal: 12),
//                 decoration: BoxDecoration(
//                   color: kOrange,
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: const Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Icon(
//                       Icons.file_download_outlined,
//                       color: Colors.white,
//                       size: 18,
//                     ),
//                     SizedBox(width: 6),
//                     Text(
//                       'Export',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 13,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 20),
//
//           // ── Credit stats card ────────────────────────────────────────────────
//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: kGreenBg,
//               borderRadius: BorderRadius.circular(14),
//               border: Border.all(color: kGreen.withOpacity(0.3), width: 1.5),
//             ),
//             child: Column(
//               children: [
//                 // Stat cards row
//                 Row(
//                   children: [
//                     Expanded(
//                       child: _CreditStatCard(
//                         label: 'Credit Limit',
//                         value: '₹2,000',
//                         valueColor: kTextDark,
//                       ),
//                     ),
//                     const SizedBox(width: 10),
//                     Expanded(
//                       child: _CreditStatCard(
//                         label: 'Used Credit',
//                         value: '₹3',
//                         valueColor: kRed,
//                       ),
//                     ),
//                     const SizedBox(width: 10),
//                     Expanded(
//                       child: _CreditStatCard(
//                         label: 'Remaining',
//                         value: '₹1,997',
//                         valueColor: kGreen,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 14),
//
//                 // Add credits input
//                 Container(
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(10),
//                     border: Border.all(color: kBorder),
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         'Add Credits',
//                         style: TextStyle(
//                           color: kTextGrey,
//                           fontSize: 13,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       // Amount entry row — IntrinsicHeight so all children match vertically
//                       IntrinsicHeight(
//                         child: Row(
//                           crossAxisAlignment: CrossAxisAlignment.stretch,
//                           children: [
//                             // ₹ prefix box
//                             Container(
//                               width: 36,
//                               decoration: BoxDecoration(
//                                 color: kBg,
//                                 borderRadius: const BorderRadius.horizontal(
//                                   left: Radius.circular(8),
//                                 ),
//                                 border: const Border(
//                                   top: BorderSide(color: kBorder),
//                                   bottom: BorderSide(color: kBorder),
//                                   left: BorderSide(color: kBorder),
//                                 ),
//                               ),
//                               child: const Center(
//                                 child: Text(
//                                   '₹',
//                                   style: TextStyle(
//                                     color: kTextGrey,
//                                     fontWeight: FontWeight.w600,
//                                     fontSize: 16,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             // Amount text field — Expanded to take remaining space
//                             Expanded(
//                               child: TextField(
//                                 controller: _amountController,
//                                 keyboardType: TextInputType.number,
//                                 decoration: const InputDecoration(
//                                   hintText: 'Amount',
//                                   hintStyle: TextStyle(
//                                     color: kTextGrey,
//                                     fontSize: 14,
//                                   ),
//                                   filled: true,
//                                   fillColor: Colors.white,
//                                   contentPadding: EdgeInsets.symmetric(
//                                     horizontal: 12,
//                                     vertical: 12,
//                                   ),
//                                   border: OutlineInputBorder(
//                                     borderRadius: BorderRadius.zero,
//                                     borderSide: BorderSide(color: kBorder),
//                                   ),
//                                   enabledBorder: OutlineInputBorder(
//                                     borderRadius: BorderRadius.zero,
//                                     borderSide: BorderSide(color: kBorder),
//                                   ),
//                                   focusedBorder: OutlineInputBorder(
//                                     borderRadius: BorderRadius.zero,
//                                     borderSide: BorderSide(
//                                       color: kOrange,
//                                       width: 1.5,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             // Pay button
//                             GestureDetector(
//                               onTap: () {},
//                               child: Container(
//                                 padding: const EdgeInsets.symmetric(
//                                   horizontal: 20,
//                                 ),
//                                 decoration: const BoxDecoration(
//                                   color: kOrange,
//                                   borderRadius: BorderRadius.horizontal(
//                                     right: Radius.circular(8),
//                                   ),
//                                 ),
//                                 child: const Center(
//                                   child: Text(
//                                     'Pay',
//                                     style: TextStyle(
//                                       color: Colors.white,
//                                       fontWeight: FontWeight.w700,
//                                       fontSize: 15,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _CreditStatCard extends StatelessWidget {
//   final String label;
//   final String value;
//   final Color valueColor;
//   const _CreditStatCard({
//     required this.label,
//     required this.value,
//     required this.valueColor,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(color: kBorder),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             label,
//             style: const TextStyle(
//               color: kTextGrey,
//               fontSize: 12,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           const SizedBox(height: 6),
//           Text(
//             value,
//             style: TextStyle(
//               color: valueColor,
//               fontSize: 18,
//               fontWeight: FontWeight.w700,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
