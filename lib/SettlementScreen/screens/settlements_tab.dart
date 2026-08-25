// //
// // import 'package:flutter/material.dart';
// // import 'package:intl/intl.dart';
// // import '../models/finance_models.dart';
// // import '../services/finance_service.dart';
// // import '../widgets/theme.dart';
// //
// // class SettlementsTab extends StatefulWidget {
// //   const SettlementsTab({super.key});
// //   @override
// //   State<SettlementsTab> createState() => _SettlementsTabState();
// // }
// //
// // class _SettlementsTabState extends State<SettlementsTab> {
// //   SettlementSummary? _summary;
// //   bool _loading = false;
// //   String? _error;
// //   String _search = '';
// //   String _period = 'This Month';
// //   DateTimeRange? _custom;
// //
// //   static const _periods = [
// //     'Today',
// //     'Yesterday',
// //     'This Week',
// //     'This Month',
// //     'Last Month',
// //     'This Year',
// //     'Custom Range',
// //   ];
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _load();
// //   }
// //
// //   Future<void> _load() async {
// //     setState(() {
// //       _loading = true;
// //       _error = null;
// //     });
// //     try {
// //       final s = await FinanceService.fetchSettlements();
// //       if (mounted)
// //         setState(() {
// //           _summary = s;
// //           _loading = false;
// //         });
// //     } catch (e) {
// //       if (mounted)
// //         setState(() {
// //           _error = e.toString();
// //           _loading = false;
// //         });
// //     }
// //   }
// //
// //   // ── Date filtering (client-side) ──────────────────────────────────────────
// //   List<Settlement> get _filtered {
// //     final all = _summary?.settlements ?? [];
// //     final range = _dateRange;
// //     List<Settlement> result;
// //
// //     if (range == null) {
// //       result = all;
// //     } else {
// //       final from = DateTime(
// //         range.start.year,
// //         range.start.month,
// //         range.start.day,
// //       );
// //       final to = DateTime(
// //         range.end.year,
// //         range.end.month,
// //         range.end.day,
// //         23,
// //         59,
// //         59,
// //       );
// //       result = all.where((s) {
// //         final ref = _parseDate(s.toDate ?? s.settlementDate);
// //         if (ref == null) return false;
// //         return !ref.isBefore(from) && !ref.isAfter(to);
// //       }).toList();
// //     }
// //
// //     // ── Show only PAID / COMPLETED settlements ──────────────────────────────
// //     result = result.where((s) => s.isPaid).toList();
// //
// //     // Sort newest first
// //     result.sort((a, b) {
// //       final da = _parseDate(a.toDate ?? a.settlementDate);
// //       final db = _parseDate(b.toDate ?? b.settlementDate);
// //       if (da == null && db == null) return 0;
// //       if (da == null) return 1;
// //       if (db == null) return -1;
// //       return db.compareTo(da);
// //     });
// //
// //     if (_search.isEmpty) return result;
// //     final q = _search.toLowerCase();
// //     return result
// //         .where(
// //           (s) =>
// //               s.settlementId.toString().contains(q) ||
// //               (s.pytMode.toLowerCase().contains(q)) ||
// //               (s.description?.toLowerCase().contains(q) ?? false),
// //         )
// //         .toList();
// //   }
// //
// //   DateTimeRange? get _dateRange {
// //     final now = DateTime.now();
// //     final today = DateTime(now.year, now.month, now.day);
// //     switch (_period) {
// //       case 'Today':
// //         return DateTimeRange(start: today, end: today);
// //       case 'Yesterday':
// //         final y = today.subtract(const Duration(days: 1));
// //         return DateTimeRange(start: y, end: y);
// //       case 'This Week':
// //         final wd = today.weekday; // Mon=1
// //         final mon = today.subtract(Duration(days: wd - 1));
// //         return DateTimeRange(start: mon, end: mon.add(const Duration(days: 6)));
// //       case 'This Month':
// //         return DateTimeRange(
// //           start: DateTime(now.year, now.month, 1),
// //           end: DateTime(now.year, now.month + 1, 0),
// //         );
// //       case 'Last Month':
// //         return DateTimeRange(
// //           start: DateTime(now.year, now.month - 1, 1),
// //           end: DateTime(now.year, now.month, 0),
// //         );
// //       case 'This Year':
// //         return DateTimeRange(
// //           start: DateTime(now.year, 1, 1),
// //           end: DateTime(now.year, 12, 31),
// //         );
// //       case 'Custom Range':
// //         return _custom;
// //       default:
// //         return null;
// //     }
// //   }
// //
// //   DateTime? _parseDate(String? s) {
// //     if (s == null || s.isEmpty) return null;
// //     try {
// //       return DateTime.parse(s);
// //     } catch (_) {
// //       return null;
// //     }
// //   }
// //
// //   // ── Only count paid settlements for the net amount banner ─────────────────
// //   double get _totalNetAmount => _filtered.fold(0.0, (s, e) => s + e.finalAmount);
// //   int get _paidCount =>
// //       (_summary?.settlements ?? []).where((s) => s.isPaid).length;
// //
// //   // ─── BUILD ─────────────────────────────────────────────────────────────────
// //   @override
// //   Widget build(BuildContext context) => RefreshIndicator(
// //     color: fnAccent,
// //     onRefresh: _load,
// //     child: SingleChildScrollView(
// //       physics: const AlwaysScrollableScrollPhysics(),
// //       padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //
// //           // ── Search bar ───────────────────────────────────────────────────────
// //           Row(
// //             children: [
// //               // 🔍 Search bar
// //               Expanded(
// //                 flex: 4,
// //                 child: _SearchBar(
// //                   hint: 'Search...',
// //                   value: _search,
// //                   onChanged: (v) => setState(() => _search = v),
// //                 ),
// //               ),
// //
// //               const SizedBox(width: 8),
// //
// //               // 📅 Dropdown
// //               Container(
// //                 height: 44,
// //                 padding: const EdgeInsets.symmetric(horizontal: 8),
// //                 decoration: BoxDecoration(
// //                   color: Colors.white,
// //                   borderRadius: BorderRadius.circular(10),
// //                   border: Border.all(color: fnBorder),
// //                 ),
// //                 child: DropdownButtonHideUnderline(
// //                   child: DropdownButton<String>(
// //                     value: _period,
// //                     icon: const Icon(Icons.keyboard_arrow_down_rounded),
// //                     style: const TextStyle(fontSize: 12, color: fnText1),
// //                     onChanged: (v) async {
// //                       if (v == null) return;
// //
// //                       if (v == 'Custom Range') {
// //                         final range = await showDateRangePicker(
// //                           context: context,
// //                           firstDate: DateTime(2023),
// //                           lastDate: DateTime.now(),
// //                         );
// //
// //                         if (range != null) {
// //                           setState(() {
// //                             _period = v;
// //                             _custom = range;
// //                           });
// //                         }
// //                       } else {
// //                         setState(() => _period = v);
// //                       }
// //                     },
// //                     items: _periods
// //                         .map(
// //                           (e) => DropdownMenuItem(
// //                         value: e,
// //                         child: Text(e),
// //                       ),
// //                     )
// //                         .toList(),
// //                   ),
// //                 ),
// //               ),
// //             ],
// //           ),
// //
// //           const SizedBox(height: 10),
// //           if (_period == 'Custom Range' && _custom != null)
// //             Padding(
// //               padding: const EdgeInsets.only(top: 8),
// //               child: Text(
// //                 '${DateFormat('dd MMM').format(_custom!.start)} – ${DateFormat('dd MMM yyyy').format(_custom!.end)}',
// //                 style: const TextStyle(
// //                   color: fnAccent,
// //                   fontSize: 12,
// //                   fontWeight: FontWeight.w600,
// //                 ),
// //               ),
// //             ),
// //           const SizedBox(height: 14),
// //
// //           // ── Net amount banner ─────────────────────────────────────────────────
// //           FnNetBanner(
// //             label: 'Net Amount ',
// //             amount: _fmtCur(_totalNetAmount),
// //             isLoading: _loading,
// //           ),
// //           const SizedBox(height: 14),
// //
// //           // ── Content ───────────────────────────────────────────────────────────
// //           if (_loading && _summary == null)
// //             const Center(
// //               child: Padding(
// //                 padding: EdgeInsets.all(40),
// //                 child: CircularProgressIndicator(color: fnAccent),
// //               ),
// //             )
// //           else if (_error != null)
// //             FnEmpty(message: 'Error: $_error\n\nPull to retry.')
// //           else if (_filtered.isEmpty)
// //             FnEmpty(
// //               message: _search.isNotEmpty
// //                   ? 'No paid settlements match your search.'
// //                   : 'No paid settlements for $_period.',
// //             )
// //           else
// //             Column(children: _filtered.map(_buildCard).toList()),
// //         ],
// //       ),
// //     ),
// //   );
// //
// //   Widget _summaryChip(String label, int count, Color color) => Expanded(
// //     child: Container(
// //       padding: const EdgeInsets.symmetric(vertical: 10),
// //       decoration: BoxDecoration(
// //         color: color.withOpacity(0.1),
// //         borderRadius: BorderRadius.circular(10),
// //         border: Border.all(color: color.withOpacity(0.25)),
// //       ),
// //       child: Column(
// //         children: [
// //           Text(
// //             '$count',
// //             style: TextStyle(
// //               fontSize: 18,
// //               fontWeight: FontWeight.w900,
// //               color: color,
// //             ),
// //           ),
// //           Text(
// //             label,
// //             style: TextStyle(
// //               fontSize: 10,
// //               color: color,
// //               fontWeight: FontWeight.w600,
// //             ),
// //           ),
// //         ],
// //       ),
// //     ),
// //   );
// //
// //   Widget _buildCard(Settlement s) {
// //     // All cards here are guaranteed paid, so always use green/accent styling
// //     return Container(
// //       margin: const EdgeInsets.only(bottom: 10),
// //       decoration: fnCardDeco(borderColor: fnGreen.withOpacity(0.25)),
// //       child: Padding(
// //         padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             // ── Top row ──────────────────────────────────────────────────────
// //             Row(
// //               children: [
// //                 Expanded(
// //                   child: Column(
// //                     crossAxisAlignment: CrossAxisAlignment.start,
// //                     children: [
// //                       Text(
// //                         _businessDateRange(s.fromDate, s.toDate),
// //                         style: const TextStyle(
// //                           fontSize: 14,
// //                           fontWeight: FontWeight.w700,
// //                           color: fnText1,
// //                         ),
// //                       ),
// //                       const SizedBox(height: 4),
// //                       Text(
// //                         'Settled on ${_fmtDate(s.updatedAt)}',
// //                         style: const TextStyle(
// //                           fontSize: 12,
// //                           color: fnGreen,
// //                           fontWeight: FontWeight.w500,
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //                 Column(
// //                   crossAxisAlignment: CrossAxisAlignment.end,
// //                   children: [
// //                     Text(
// //                       _fmtCur(s.finalAmount),
// //                       style: TextStyle(
// //                         fontSize: 18,
// //                         fontWeight: FontWeight.w900,
// //                         color: s.finalAmount < 0 ? Colors.red : fnAccent,
// //                       ),
// //                     ),
// //                     const SizedBox(height: 4),
// //                     _statusBadge(s.paymentStatus),
// //                   ],
// //                 ),
// //               ],
// //             ),
// //
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _detail(String label, String value, {Color? valueColor}) => Expanded(
// //     child: Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         Text(
// //           label,
// //           style: const TextStyle(
// //             fontSize: 10,
// //             color: fnText3,
// //             fontWeight: FontWeight.w500,
// //           ),
// //         ),
// //         const SizedBox(height: 2),
// //         Text(
// //           value,
// //           style: TextStyle(
// //             fontSize: 12,
// //             fontWeight: FontWeight.w700,
// //             color: valueColor ?? fnText1,
// //           ),
// //         ),
// //       ],
// //     ),
// //   );
// //
// //   Widget _statusBadge(String status) {
// //     // Since only paid settlements are shown, badge is always green "Paid"
// //     return Container(
// //       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
// //       decoration: BoxDecoration(
// //         color: fnGreen.withOpacity(0.12),
// //         borderRadius: BorderRadius.circular(6),
// //       ),
// //       child: Text(
// //         status[0] + status.substring(1).toLowerCase(),
// //         style: TextStyle(
// //           fontSize: 10,
// //           color: fnGreen,
// //           fontWeight: FontWeight.w700,
// //         ),
// //       ),
// //     );
// //   }
// //
// //   String _fmtCur(double v) {
// //     final fmt = NumberFormat('#,##,###.##');
// //     if (v < 0) {
// //       return '₹-${fmt.format(v.abs())}';
// //     } else {
// //       return '₹${fmt.format(v)}';
// //     }
// //   }
// //
// //   String _fmtDate(String? s) {
// //     if (s == null || s.isEmpty) return '-';
// //     try {
// //       return DateFormat('dd MMM yyyy').format(DateTime.parse(s));
// //     } catch (_) {
// //       return s;
// //     }
// //   }
// //
// //   String _businessDateRange(String? from, String? to) {
// //     if (from == null || to == null) return '-';
// //
// //     try {
// //       final f = DateTime.parse(from);
// //       final t = DateTime.parse(to);
// //
// //       // Subtract 1 day so "26 Mar 00:00" becomes "25 Mar 23:59"
// //       final adjustedTo = t.subtract(const Duration(days: 1));
// //       final endOfDay = DateTime(adjustedTo.year, adjustedTo.month, adjustedTo.day, 23, 59);
// //
// //       final dateFormat = DateFormat('dd MMM yyyy HH:mm');
// //
// //       final fromStr = dateFormat.format(f);
// //       final toStr = dateFormat.format(endOfDay);
// //
// //       return '$fromStr to\n$toStr';
// //     } catch (_) {
// //       return from;
// //     }
// //   }
// // }
// //
// // // ─── Reusable search bar ──────────────────────────────────────────────────────
// // class _SearchBar extends StatelessWidget {
// //   final String hint, value;
// //   final ValueChanged<String> onChanged;
// //   const _SearchBar({
// //     required this.hint,
// //     required this.value,
// //     required this.onChanged,
// //   });
// //
// //   @override
// //   Widget build(BuildContext context) => Container(
// //     decoration: fnCardDeco(radius: 12),
// //     child: Row(
// //       children: [
// //         const SizedBox(width: 14),
// //         const Icon(Icons.search_rounded, color: fnText3, size: 18),
// //         const SizedBox(width: 8),
// //         Expanded(
// //           child: TextField(
// //             onChanged: onChanged,
// //             decoration: InputDecoration(
// //               hintText: hint,
// //               hintStyle: const TextStyle(color: fnText3, fontSize: 13),
// //               border: InputBorder.none,
// //               contentPadding: const EdgeInsets.symmetric(vertical: 12),
// //             ),
// //             style: const TextStyle(fontSize: 13, color: fnText1),
// //           ),
// //         ),
// //         if (value.isNotEmpty)
// //           GestureDetector(
// //             onTap: () => onChanged(''),
// //             child: const Padding(
// //               padding: EdgeInsets.all(10),
// //               child: Icon(Icons.close_rounded, color: fnText3, size: 16),
// //             ),
// //           ),
// //       ],
// //     ),
// //   );
// // }
//
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import '../models/finance_models.dart';
// import '../services/finance_service.dart';
// import '../widgets/theme.dart';
//
// class SettlementsTab extends StatefulWidget {
//   const SettlementsTab({super.key});
//   @override
//   State<SettlementsTab> createState() => _SettlementsTabState();
// }
//
// class _SettlementsTabState extends State<SettlementsTab> {
//   SettlementSummary? _summary;
//   bool _loading = false;
//   String? _error;
//   String _search = '';
//   String _period = 'This Month';
//   DateTimeRange? _custom;
//
//   static const _periods = [
//     'Today',
//     'Yesterday',
//     'This Week',
//     'This Month',
//     'Last Month',
//     'This Year',
//     'Custom Range',
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     _load();
//   }
//
//   Future<void> _load() async {
//     setState(() {
//       _loading = true;
//       _error = null;
//     });
//     try {
//       final s = await FinanceService.fetchSettlements();
//       if (mounted)
//         setState(() {
//           _summary = s;
//           _loading = false;
//         });
//     } catch (e) {
//       if (mounted)
//         setState(() {
//           _error = e.toString();
//           _loading = false;
//         });
//     }
//   }
//
//   // ── Date filtering (client-side) ──────────────────────────────────────────
//   List<Settlement> get _filtered {
//     final all = _summary?.settlements ?? [];
//     final range = _dateRange;
//     List<Settlement> result;
//
//     if (range == null) {
//       result = all;
//     } else {
//       final from = DateTime(
//         range.start.year,
//         range.start.month,
//         range.start.day,
//       );
//       final to = DateTime(
//         range.end.year,
//         range.end.month,
//         range.end.day,
//         23,
//         59,
//         59,
//       );
//       result = all.where((s) {
//         final ref = _parseDate(s.toDate ?? s.settlementDate);
//         if (ref == null) return false;
//         return !ref.isBefore(from) && !ref.isAfter(to);
//       }).toList();
//     }
//
//     // ── Show only PAID / COMPLETED settlements ──────────────────────────────
//     result = result.where((s) => s.isPaid).toList();
//
//     // Sort newest first
//     result.sort((a, b) {
//       final da = _parseDate(a.toDate ?? a.settlementDate);
//       final db = _parseDate(b.toDate ?? b.settlementDate);
//       if (da == null && db == null) return 0;
//       if (da == null) return 1;
//       if (db == null) return -1;
//       return db.compareTo(da);
//     });
//
//     if (_search.isEmpty) return result;
//     final q = _search.toLowerCase();
//     return result
//         .where(
//           (s) =>
//               s.settlementId.toString().contains(q) ||
//               (s.pytMode.toLowerCase().contains(q)) ||
//               (s.description?.toLowerCase().contains(q) ?? false),
//         )
//         .toList();
//   }
//
//   DateTimeRange? get _dateRange {
//     final now = DateTime.now();
//     final today = DateTime(now.year, now.month, now.day);
//     switch (_period) {
//       case 'Today':
//         return DateTimeRange(start: today, end: today);
//       case 'Yesterday':
//         final y = today.subtract(const Duration(days: 1));
//         return DateTimeRange(start: y, end: y);
//       case 'This Week':
//         final wd = today.weekday; // Mon=1
//         final mon = today.subtract(Duration(days: wd - 1));
//         return DateTimeRange(start: mon, end: mon.add(const Duration(days: 6)));
//       case 'This Month':
//         return DateTimeRange(
//           start: DateTime(now.year, now.month, 1),
//           end: DateTime(now.year, now.month + 1, 0),
//         );
//       case 'Last Month':
//         return DateTimeRange(
//           start: DateTime(now.year, now.month - 1, 1),
//           end: DateTime(now.year, now.month, 0),
//         );
//       case 'This Year':
//         return DateTimeRange(
//           start: DateTime(now.year, 1, 1),
//           end: DateTime(now.year, 12, 31),
//         );
//       case 'Custom Range':
//         return _custom;
//       default:
//         return null;
//     }
//   }
//
//   DateTime? _parseDate(String? s) {
//     if (s == null || s.isEmpty) return null;
//     try {
//       return DateTime.parse(s);
//     } catch (_) {
//       return null;
//     }
//   }
//
//   // ── Only count paid settlements for the net amount banner ─────────────────
//   double get _totalNetAmount =>
//       _filtered.fold(0.0, (s, e) => s + e.finalAmount);
//   int get _paidCount =>
//       (_summary?.settlements ?? []).where((s) => s.isPaid).length;
//
//   // ─── BUILD ─────────────────────────────────────────────────────────────────
//   @override
//   Widget build(BuildContext context) => RefreshIndicator(
//     color: fnAccent,
//     onRefresh: _load,
//     child: SingleChildScrollView(
//       physics: const AlwaysScrollableScrollPhysics(),
//       padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // ── Search bar ───────────────────────────────────────────────────────
//           Row(
//             children: [
//               // 🔍 Search bar
//               Expanded(
//                 flex: 4,
//                 child: _SearchBar(
//                   hint: 'Search...',
//                   value: _search,
//                   onChanged: (v) => setState(() => _search = v),
//                 ),
//               ),
//
//               const SizedBox(width: 8),
//
//               // 📅 Dropdown
//               Container(
//                 height: 44,
//                 padding: const EdgeInsets.symmetric(horizontal: 8),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(10),
//                   border: Border.all(color: fnBorder),
//                 ),
//                 child: DropdownButtonHideUnderline(
//                   child: DropdownButton<String>(
//                     value: _period,
//                     icon: const Icon(Icons.keyboard_arrow_down_rounded),
//                     style: const TextStyle(fontSize: 12, color: fnText1),
//                     onChanged: (v) async {
//                       if (v == null) return;
//
//                       if (v == 'Custom Range') {
//                         final range = await showDateRangePicker(
//                           context: context,
//                           firstDate: DateTime(2023),
//                           lastDate: DateTime.now(),
//                         );
//
//                         if (range != null) {
//                           setState(() {
//                             _period = v;
//                             _custom = range;
//                           });
//                         }
//                       } else {
//                         setState(() => _period = v);
//                       }
//                     },
//                     items: _periods
//                         .map((e) => DropdownMenuItem(value: e, child: Text(e)))
//                         .toList(),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//
//           const SizedBox(height: 10),
//           if (_period == 'Custom Range' && _custom != null)
//             Padding(
//               padding: const EdgeInsets.only(top: 8),
//               child: Text(
//                 '${DateFormat('dd MMM').format(_custom!.start)} – ${DateFormat('dd MMM yyyy').format(_custom!.end)}',
//                 style: const TextStyle(
//                   color: fnAccent,
//                   fontSize: 12,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//           const SizedBox(height: 14),
//
//           // ── Net amount banner ─────────────────────────────────────────────────
//           FnNetBanner(
//             label: 'Net Amount ',
//             amount: _fmtCur(_totalNetAmount),
//             isLoading: _loading,
//           ),
//           const SizedBox(height: 14),
//
//           // ── Content ───────────────────────────────────────────────────────────
//           if (_loading && _summary == null)
//             const Center(
//               child: Padding(
//                 padding: EdgeInsets.all(40),
//                 child: CircularProgressIndicator(color: fnAccent),
//               ),
//             )
//           else if (_error != null)
//             FnEmpty(message: 'Error: $_error\n\nPull to retry.')
//           else if (_filtered.isEmpty)
//             FnEmpty(
//               message: _search.isNotEmpty
//                   ? 'No paid settlements match your search.'
//                   : 'No paid settlements for $_period.',
//             )
//           else
//             Column(
//               children: _filtered
//                   .map(
//                     (s) => _SettlementCard(
//                       settlement: s,
//                       fmtCur: _fmtCur,
//                       businessDateRange: _businessDateRange,
//                     ),
//                   )
//                   .toList(),
//             ),
//         ],
//       ),
//     ),
//   );
//
//   String _fmtCur(double v) {
//     final fmt = NumberFormat('#,##,###.##');
//     if (v < 0) {
//       return '₹-${fmt.format(v.abs())}';
//     } else {
//       return '₹${fmt.format(v)}';
//     }
//   }
//
//   String _businessDateRange(String? from, String? to) {
//     if (from == null || to == null) return '-';
//     try {
//       final f = DateTime.parse(from);
//       final t = DateTime.parse(to);
//       final adjustedTo = t.subtract(const Duration(days: 1));
//       return '${DateFormat('MMMM d, yyyy').format(f)} - ${DateFormat('MMMM d, yyyy').format(adjustedTo)}';
//     } catch (_) {
//       return from;
//     }
//   }
// }
//
// // ─── Status colors ─────────────────────────────────────────────────────────
// Color _statusColor(String status) {
//   switch (status.toUpperCase()) {
//     case 'PAID':
//     case 'COMPLETED':
//       return fnGreen;
//     case 'PENDING':
//       return const Color(0xFFF59E0B); // amber
//     case 'FAILED':
//     case 'REJECTED':
//       return const Color(0xFFEF4444); // red
//     default:
//       return fnText3;
//   }
// }
//
// String _titleCase(String s) =>
//     s.isEmpty ? s : s[0] + s.substring(1).toLowerCase();
//
// // ─── Expandable settlement card ─────────────────────────────────────────────
// class _SettlementCard extends StatefulWidget {
//   final Settlement settlement;
//   final String Function(double) fmtCur;
//   final String Function(String?, String?) businessDateRange;
//
//   const _SettlementCard({
//     required this.settlement,
//     required this.fmtCur,
//     required this.businessDateRange,
//   });
//
//   @override
//   State<_SettlementCard> createState() => _SettlementCardState();
// }
//
// class _SettlementCardState extends State<_SettlementCard> {
//   bool _expanded = false;
//
//   @override
//   Widget build(BuildContext context) {
//     final s = widget.settlement;
//     final color = _statusColor(s.paymentStatus);
//
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(color: color.withOpacity(0.35)),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.03),
//             blurRadius: 6,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       clipBehavior: Clip.antiAlias,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // ── Header row (always visible) ──────────────────────────────────
//           Padding(
//             padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Left: status badge + expand toggle
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 10,
//                           vertical: 4,
//                         ),
//                         decoration: BoxDecoration(
//                           color: color.withOpacity(0.12),
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                         child: Text(
//                           _titleCase(s.paymentStatus),
//                           style: TextStyle(
//                             fontSize: 11,
//                             fontWeight: FontWeight.w700,
//                             color: color,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       GestureDetector(
//                         onTap: () => setState(() => _expanded = !_expanded),
//                         behavior: HitTestBehavior.opaque,
//                         child: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Text(
//                               _expanded ? 'See Less' : 'See More',
//                               style: const TextStyle(
//                                 fontSize: 12,
//                                 fontWeight: FontWeight.w700,
//                                 color: fnAccent,
//                               ),
//                             ),
//                             Icon(
//                               _expanded
//                                   ? Icons.keyboard_arrow_up_rounded
//                                   : Icons.keyboard_arrow_right_rounded,
//                               size: 16,
//                               color: fnAccent,
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//
//                 // Right: final payout + payout period + download
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.end,
//                   children: [
//                     Text(
//                       'FINAL PAYOUT',
//                       style: TextStyle(
//                         fontSize: 9,
//                         fontWeight: FontWeight.w700,
//                         letterSpacing: 0.4,
//                         color: fnText3,
//                       ),
//                     ),
//                     const SizedBox(height: 2),
//                     Text(
//                       widget.fmtCur(s.finalAmount),
//                       style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.w900,
//                         color: s.finalAmount < 0 ? Colors.red : fnText1,
//                       ),
//                     ),
//                     const SizedBox(height: 6),
//                     Text(
//                       'Payout period',
//                       style: TextStyle(fontSize: 9, color: fnText3),
//                     ),
//                     Text(
//                       widget.businessDateRange(s.fromDate, s.toDate),
//                       textAlign: TextAlign.right,
//                       style: const TextStyle(
//                         fontSize: 11,
//                         fontWeight: FontWeight.w600,
//                         color: fnText1,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//
//                   ],
//                 ),
//               ],
//             ),
//           ),
//
//           // ── Expanded details ────────────────────────────────────────────
//           AnimatedCrossFade(
//             duration: const Duration(milliseconds: 200),
//             crossFadeState: _expanded
//                 ? CrossFadeState.showFirst
//                 : CrossFadeState.showSecond,
//             firstChild: _expandedContent(s),
//             secondChild: const SizedBox(width: double.infinity),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _expandedContent(Settlement s) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Divider(height: 1, color: fnBorder),
//
//         // Settlement ID / Payment mode
//         Padding(
//           padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               _labelValue('Settlement ID', '${s.settlementId}'),
//               _labelValue('Payment Mode', s.paymentModeLabel, alignEnd: true),
//             ],
//           ),
//         ),
//
//         // Payout details breakdown
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16),
//           child: Container(
//             width: double.infinity,
//             padding: const EdgeInsets.all(14),
//             decoration: BoxDecoration(
//               color: const Color(
//                 0xFFF7F7F8,
//               ), // swap for your theme's surface color, e.g. fnBg, if defined
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   'Payout details',
//                   style: TextStyle(
//                     fontSize: 12,
//                     fontWeight: FontWeight.w800,
//                     color: fnText1,
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 _breakdownRow('(A) Total Customer Paid', s.totalGrandTotal),
//                 _breakdownRow('(B) Total Fees', -s.totalFees, negative: true),
//                 _breakdownRow(
//                   'Commission',
//                   s.commission,
//                   negative: true,
//                   indent: true,
//                   muted: true,
//                 ),
//                 _breakdownRow(
//                   'TDS',
//                   s.tdsAmount,
//                   negative: true,
//                   indent: true,
//                   muted: true,
//                 ),
//                 _breakdownRow(
//                   '(C) Complaint & Cancellation Charges',
//                   s.complaintCancellationCharges,
//                 ),
//                 _breakdownRow('(D) Total Taxes', s.totalTaxes, negative: true),
//                 _breakdownRow(
//                   '(E) Other Charges & Refunds',
//                   s.otherChargesRefunds,
//                 ),
//                 const Padding(
//                   padding: EdgeInsets.symmetric(vertical: 8),
//                   child: Divider(height: 1, color: fnBorder),
//                 ),
//                 _breakdownRow(
//                   'Net Payout (A+B+C+D+E)',
//                   s.finalAmount,
//                   bold: true,
//                 ),
//               ],
//             ),
//           ),
//         ),
//
//         const SizedBox(height: 12),
//
//         // Bank details
//         if ((s.holderName?.isNotEmpty ?? false) ||
//             (s.accountNumber?.isNotEmpty ?? false) ||
//             (s.ifscCode?.isNotEmpty ?? false) ||
//             s.displayRefId.isNotEmpty)
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             child: Row(
//               children: [
//                 _detail('Holder Name', s.holderName ?? '-'),
//                 _detail('Account Number', s.accountNumber ?? '-'),
//                 _detail('IFSC Code', s.ifscCode ?? '-'),
//                 _detail(
//                   'Ref. ID',
//                   s.displayRefId.isNotEmpty ? s.displayRefId : '-',
//                 ),
//               ],
//             ),
//           ),
//
//         if (s.description != null && s.description!.isNotEmpty)
//           Padding(
//             padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
//             child: RichText(
//               text: TextSpan(
//                 style: const TextStyle(fontSize: 11, color: fnText3),
//                 children: [
//                   const TextSpan(
//                     text: 'Description: ',
//                     style: TextStyle(fontWeight: FontWeight.w600),
//                   ),
//                   TextSpan(text: s.description),
//                 ],
//               ),
//             ),
//           )
//         else
//           const SizedBox(height: 6),
//       ],
//     );
//   }
//
//   Widget _labelValue(String label, String value, {bool alignEnd = false}) =>
//       Column(
//         crossAxisAlignment: alignEnd
//             ? CrossAxisAlignment.end
//             : CrossAxisAlignment.start,
//         children: [
//           Text(label, style: const TextStyle(fontSize: 10, color: fnText3)),
//           const SizedBox(height: 2),
//           Text(
//             value,
//             style: const TextStyle(
//               fontSize: 13,
//               fontWeight: FontWeight.w700,
//               color: fnText1,
//             ),
//           ),
//         ],
//       );
//
//   Widget _breakdownRow(
//     String label,
//     double value, {
//     bool negative = false,
//     bool indent = false,
//     bool muted = false,
//     bool bold = false,
//   }) {
//     final display = negative
//         ? '-₹${NumberFormat('#,##,###.##').format(value.abs())}'
//         : '₹${NumberFormat('#,##,###.##').format(value)}';
//     return Padding(
//       padding: EdgeInsets.only(left: indent ? 12 : 0, bottom: 6),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             label,
//             style: TextStyle(
//               fontSize: muted ? 10.5 : 12,
//               fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
//               color: muted ? fnText3 : fnText1,
//             ),
//           ),
//           Text(
//             display,
//             style: TextStyle(
//               fontSize: muted ? 10.5 : 12,
//               fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
//               color: bold
//                   ? fnAccent
//                   : (negative ? const Color(0xFFEF4444) : fnText1),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _detail(String label, String value) => Expanded(
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: const TextStyle(
//             fontSize: 9,
//             color: fnText3,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//         const SizedBox(height: 2),
//         Text(
//           value,
//           style: const TextStyle(
//             fontSize: 11,
//             fontWeight: FontWeight.w700,
//             color: fnText1,
//           ),
//           overflow: TextOverflow.ellipsis,
//         ),
//       ],
//     ),
//   );
// }
//
// // ─── Reusable search bar ──────────────────────────────────────────────────────
// class _SearchBar extends StatelessWidget {
//   final String hint, value;
//   final ValueChanged<String> onChanged;
//   const _SearchBar({
//     required this.hint,
//     required this.value,
//     required this.onChanged,
//   });
//
//   @override
//   Widget build(BuildContext context) => Container(
//     decoration: fnCardDeco(radius: 12),
//     child: Row(
//       children: [
//         const SizedBox(width: 14),
//         const Icon(Icons.search_rounded, color: fnText3, size: 18),
//         const SizedBox(width: 8),
//         Expanded(
//           child: TextField(
//             onChanged: onChanged,
//             decoration: InputDecoration(
//               hintText: hint,
//               hintStyle: const TextStyle(color: fnText3, fontSize: 13),
//               border: InputBorder.none,
//               contentPadding: const EdgeInsets.symmetric(vertical: 12),
//             ),
//             style: const TextStyle(fontSize: 13, color: fnText1),
//           ),
//         ),
//         if (value.isNotEmpty)
//           GestureDetector(
//             onTap: () => onChanged(''),
//             child: const Padding(
//               padding: EdgeInsets.all(10),
//               child: Icon(Icons.close_rounded, color: fnText3, size: 16),
//             ),
//           ),
//       ],
//     ),
//   );
// }

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/finance_models.dart';
import '../services/finance_service.dart';
import '../widgets/theme.dart';

class SettlementsTab extends StatefulWidget {
  const SettlementsTab({super.key});
  @override
  State<SettlementsTab> createState() => _SettlementsTabState();
}

class _SettlementsTabState extends State<SettlementsTab> {
  SettlementSummary? _summary;
  bool _loading = false;
  String? _error;
  String _search = '';
  String _period = 'This Month';
  DateTimeRange? _custom;

  static const _periods = [
    'Today',
    'Yesterday',
    'This Week',
    'This Month',
    'Last Month',
    'This Year',
    'Custom Range',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final s = await FinanceService.fetchSettlements();
      if (mounted)
        setState(() {
          _summary = s;
          _loading = false;
        });
    } catch (e) {
      if (mounted)
        setState(() {
          _error = e.toString();
          _loading = false;
        });
    }
  }

  // ── Date filtering (client-side) ──────────────────────────────────────────
  List<Settlement> get _filtered {
    final all = _summary?.settlements ?? [];
    final range = _dateRange;
    List<Settlement> result;

    if (range == null) {
      result = all;
    } else {
      final from = DateTime(
        range.start.year,
        range.start.month,
        range.start.day,
      );
      final to = DateTime(
        range.end.year,
        range.end.month,
        range.end.day,
        23,
        59,
        59,
      );
      result = all.where((s) {
        final ref = _parseDate(s.toDate ?? s.settlementDate);
        if (ref == null) return false;
        return !ref.isBefore(from) && !ref.isAfter(to);
      }).toList();
    }

    // ── Show only PAID / COMPLETED settlements ──────────────────────────────
    result = result.where((s) => s.isPaid).toList();

    // Sort newest first
    result.sort((a, b) {
      final da = _parseDate(a.toDate ?? a.settlementDate);
      final db = _parseDate(b.toDate ?? b.settlementDate);
      if (da == null && db == null) return 0;
      if (da == null) return 1;
      if (db == null) return -1;
      return db.compareTo(da);
    });

    if (_search.isEmpty) return result;
    final q = _search.toLowerCase();
    return result
        .where(
          (s) =>
              s.settlementId.toString().contains(q) ||
              (s.pytMode.toLowerCase().contains(q)) ||
              (s.description?.toLowerCase().contains(q) ?? false),
        )
        .toList();
  }

  DateTimeRange? get _dateRange {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    switch (_period) {
      case 'Today':
        return DateTimeRange(start: today, end: today);
      case 'Yesterday':
        final y = today.subtract(const Duration(days: 1));
        return DateTimeRange(start: y, end: y);
      case 'This Week':
        final wd = today.weekday; // Mon=1
        final mon = today.subtract(Duration(days: wd - 1));
        return DateTimeRange(start: mon, end: mon.add(const Duration(days: 6)));
      case 'This Month':
        return DateTimeRange(
          start: DateTime(now.year, now.month, 1),
          end: DateTime(now.year, now.month + 1, 0),
        );
      case 'Last Month':
        return DateTimeRange(
          start: DateTime(now.year, now.month - 1, 1),
          end: DateTime(now.year, now.month, 0),
        );
      case 'This Year':
        return DateTimeRange(
          start: DateTime(now.year, 1, 1),
          end: DateTime(now.year, 12, 31),
        );
      case 'Custom Range':
        return _custom;
      default:
        return null;
    }
  }

  DateTime? _parseDate(String? s) {
    if (s == null || s.isEmpty) return null;
    try {
      return DateTime.parse(s);
    } catch (_) {
      return null;
    }
  }

  // ── Only count paid settlements for the net amount banner ─────────────────
  double get _totalNetAmount =>
      _filtered.fold(0.0, (s, e) => s + e.finalAmount);
  int get _paidCount =>
      (_summary?.settlements ?? []).where((s) => s.isPaid).length;

  // ─── BUILD ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) => RefreshIndicator(
    color: fnAccent,
    onRefresh: _load,
    child: SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Search bar ───────────────────────────────────────────────────────
          Row(
            children: [
              // 🔍 Search bar
              Expanded(
                flex: 4,
                child: _SearchBar(
                  hint: 'Search...',
                  value: _search,
                  onChanged: (v) => setState(() => _search = v),
                ),
              ),

              const SizedBox(width: 8),

              // 📅 Dropdown
              Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: fnBorder),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _period,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded),
                    style: const TextStyle(fontSize: 12, color: fnText1),
                    onChanged: (v) async {
                      if (v == null) return;

                      if (v == 'Custom Range') {
                        final range = await showDateRangePicker(
                          context: context,
                          firstDate: DateTime(2023),
                          lastDate: DateTime.now(),
                        );

                        if (range != null) {
                          setState(() {
                            _period = v;
                            _custom = range;
                          });
                        }
                      } else {
                        setState(() => _period = v);
                      }
                    },
                    items: _periods
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),
          if (_period == 'Custom Range' && _custom != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '${DateFormat('dd MMM').format(_custom!.start)} – ${DateFormat('dd MMM yyyy').format(_custom!.end)}',
                style: const TextStyle(
                  color: fnAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          const SizedBox(height: 14),

          // ── Net amount banner ─────────────────────────────────────────────────
          FnNetBanner(
            label: 'Net Amount ',
            amount: _fmtCur(_totalNetAmount),
            isLoading: _loading,
          ),
          const SizedBox(height: 14),

          // ── Content ───────────────────────────────────────────────────────────
          if (_loading && _summary == null)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(color: fnAccent),
              ),
            )
          else if (_error != null)
            FnEmpty(message: 'Error: $_error\n\nPull to retry.')
          else if (_filtered.isEmpty)
            FnEmpty(
              message: _search.isNotEmpty
                  ? 'No paid settlements match your search.'
                  : 'No paid settlements for $_period.',
            )
          else
            Column(
              children: _filtered
                  .map(
                    (s) => _SettlementCard(
                      settlement: s,
                      fmtCur: _fmtCur,
                      businessDateRange: _businessDateRange,
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    ),
  );

  String _fmtCur(double v) {
    final fmt = NumberFormat('#,##,###.##');
    if (v < 0) {
      return '₹-${fmt.format(v.abs())}';
    } else {
      return '₹${fmt.format(v)}';
    }
  }

  String _businessDateRange(String? from, String? to) {
    if (from == null || to == null) return '-';
    try {
      final f = DateTime.parse(from);
      final t = DateTime.parse(to);
      final adjustedTo = t.subtract(const Duration(days: 1));
      return '${DateFormat('MMMM d, yyyy').format(f)} - ${DateFormat('MMMM d, yyyy').format(adjustedTo)}';
    } catch (_) {
      return from;
    }
  }
}

// ─── Status colors ─────────────────────────────────────────────────────────
Color _statusColor(String status) {
  switch (status.toUpperCase()) {
    case 'PAID':
    case 'COMPLETED':
      return fnGreen;
    case 'PENDING':
      return const Color(0xFFF59E0B); // amber
    case 'FAILED':
    case 'REJECTED':
      return const Color(0xFFEF4444); // red
    default:
      return fnText3;
  }
}

String _titleCase(String s) =>
    s.isEmpty ? s : s[0] + s.substring(1).toLowerCase();

// ─── Expandable settlement card ─────────────────────────────────────────────
class _SettlementCard extends StatefulWidget {
  final Settlement settlement;
  final String Function(double) fmtCur;
  final String Function(String?, String?) businessDateRange;

  const _SettlementCard({
    required this.settlement,
    required this.fmtCur,
    required this.businessDateRange,
  });

  @override
  State<_SettlementCard> createState() => _SettlementCardState();
}

class _SettlementCardState extends State<_SettlementCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final s = widget.settlement;
    final color = _statusColor(s.paymentStatus);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.35)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _titleCase(s.paymentStatus),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: color,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      Text(
                        'Settlement ID: ${s.settlementId}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: fnText1,
                        ),
                      ),
                      const SizedBox(height: 6),

                      GestureDetector(
                        onTap: () => setState(() => _expanded = !_expanded),
                        behavior: HitTestBehavior.opaque,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _expanded ? 'See Less' : 'See More',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: fnAccent,
                              ),
                            ),
                            Icon(
                              _expanded
                                  ? Icons.keyboard_arrow_up_rounded
                                  : Icons.keyboard_arrow_right_rounded,
                              size: 16,
                              color: fnAccent,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Right: final payout + payout period + download
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'FINAL PAYOUT',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                        color: fnText3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.fmtCur(s.finalAmount),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: s.finalAmount < 0 ? Colors.red : fnText1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Payout period',
                      style: TextStyle(fontSize: 9, color: fnText3),
                    ),
                    Text(
                      widget.businessDateRange(s.fromDate, s.toDate),
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: fnText1,
                      ),
                    ),
                    const SizedBox(height: 8),

                  ],
                ),
              ],
            ),
          ),

          // ── Expanded details ────────────────────────────────────────────
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            crossFadeState: _expanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: _expandedContent(s),
            secondChild: const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }

  Widget _expandedContent(Settlement s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 1, color: fnBorder),
        const Divider(height: 1, color: fnBorder),

        // Settlement ID / Payment mode
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // _labelValue('Settlement ID', '${s.settlementId}'),
              _labelValue('Payment Mode', s.paymentModeLabel, alignEnd: true),
            ],
          ),
        ),

        // Payout details breakdown
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(
                0xFFF7F7F8,
              ), // swap for your theme's surface color, e.g. fnBg, if defined
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Payout details',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: fnText1,
                  ),
                ),
                const SizedBox(height: 10),
                _breakdownRow('(A) Total Customer Paid', s.totalGrandTotal),
                _breakdownRow('(B) Total Fees', -s.totalFees, negative: true),
                _breakdownRow(
                  'Commission',
                  s.commission,
                  negative: true,
                  indent: true,
                  muted: true,
                ),
                _breakdownRow(
                  'TDS',
                  s.tdsAmount,
                  negative: true,
                  indent: true,
                  muted: true,
                ),
                _breakdownRow(
                  '(C) Complaint & Cancellation Charges',
                  s.complaintCancellationCharges,
                ),
                _breakdownRow('(D) Total Taxes', s.totalTaxes, negative: true),
                _breakdownRow(
                  '(E) Other Charges & Refunds',
                  s.otherChargesRefunds,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Divider(height: 1, color: fnBorder),
                ),
                _breakdownRow(
                  'Net Payout (A+B+C+D+E)',
                  s.finalAmount,
                  bold: true,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Bank details
        if ((s.holderName?.isNotEmpty ?? false) ||
            (s.accountNumber?.isNotEmpty ?? false) ||
            (s.ifscCode?.isNotEmpty ?? false) ||
            s.displayRefId.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _detail('Holder Name', s.holderName ?? '-'),
                _detail('Account Number', s.accountNumber ?? '-'),
                _detail('IFSC Code', s.ifscCode ?? '-'),
                _detail(
                  'Ref. ID',
                  s.displayRefId.isNotEmpty ? s.displayRefId : '-',
                ),
              ],
            ),
          ),

        if (s.description != null && s.description!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 11, color: fnText3),
                children: [
                  const TextSpan(
                    text: 'Description: ',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: s.description),
                ],
              ),
            ),
          )
        else
          const SizedBox(height: 6),
      ],
    );
  }

  Widget _labelValue(String label, String value, {bool alignEnd = false}) =>
      Column(
        crossAxisAlignment: alignEnd
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: fnText3)),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: fnText1,
            ),
          ),
        ],
      );

  Widget _breakdownRow(
    String label,
    double value, {
    bool negative = false,
    bool indent = false,
    bool muted = false,
    bool bold = false,
  }) {
    final display = negative
        ? '-₹${NumberFormat('#,##,###.##').format(value.abs())}'
        : '₹${NumberFormat('#,##,###.##').format(value)}';
    return Padding(
      padding: EdgeInsets.only(left: indent ? 12 : 0, bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: muted ? 10.5 : 12,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
              color: muted ? fnText3 : fnText1,
            ),
          ),
          Text(
            display,
            style: TextStyle(
              fontSize: muted ? 10.5 : 12,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
              color: bold
                  ? fnAccent
                  : (negative ? const Color(0xFFEF4444) : fnText1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detail(String label, String value) => Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            color: fnText3,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: fnText1,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    ),
  );
}

// ─── Reusable search bar ──────────────────────────────────────────────────────
class _SearchBar extends StatelessWidget {
  final String hint, value;
  final ValueChanged<String> onChanged;
  const _SearchBar({
    required this.hint,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Container(
    decoration: fnCardDeco(radius: 12),
    child: Row(
      children: [
        const SizedBox(width: 14),
        const Icon(Icons.search_rounded, color: fnText3, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: fnText3, fontSize: 13),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
            style: const TextStyle(fontSize: 13, color: fnText1),
          ),
        ),
        if (value.isNotEmpty)
          GestureDetector(
            onTap: () => onChanged(''),
            child: const Padding(
              padding: EdgeInsets.all(10),
              child: Icon(Icons.close_rounded, color: fnText3, size: 16),
            ),
          ),
      ],
    ),
  );
}
