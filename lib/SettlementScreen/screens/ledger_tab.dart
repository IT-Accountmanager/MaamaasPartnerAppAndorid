// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import '../models/finance_models.dart';
// import '../services/finance_service.dart';
// import '../widgets/theme.dart';
// import 'FnSearchBarScreen.dart';
// import 'settlements_tab.dart' show _SearchBar;
//
// class LedgerTab extends StatefulWidget {
//   const LedgerTab({super.key});
//   @override
//   State<LedgerTab> createState() => _LedgerTabState();
// }
//
// class _LedgerTabState extends State<LedgerTab> {
//   List<DailyLedger> _dailyData = [];
//   double _totalNet = 0;
//   bool _loading = false;
//   String? _error;
//   String _search = '';
//   String _period = 'This Week';
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
//     final range = _buildDateRange();
//     if (range == null) return;
//
//     setState(() {
//       _loading = true;
//       _error = null;
//     });
//     try {
//       final fmt = DateFormat('yyyy-MM-dd');
//       final startDate = fmt.format(range.start);
//       final endDate = fmt.format(range.end);
//       final orders = await FinanceService.fetchOrdersByDateRange(
//         startDate,
//         endDate,
//       );
//
//       // Filter by date range (same as React — ensure orders fall within range)
//       final filtered = orders.where((o) {
//         if (o.date.isEmpty) return false;
//         return o.date.compareTo(startDate) >= 0 &&
//             o.date.compareTo(endDate) <= 0;
//       }).toList();
//
//       final daily = FinanceService.groupOrdersByDay(filtered);
//       final total = daily.fold(0.0, (s, d) => s + d.totalNetAmount);
//
//       if (mounted)
//         setState(() {
//           _dailyData = daily;
//           _totalNet = total;
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
//   DateTimeRange? _buildDateRange() {
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
//   List<DailyLedger> get _filtered {
//     if (_search.isEmpty) return _dailyData;
//     final q = _search.toLowerCase();
//     return _dailyData
//         .where(
//           (d) =>
//               d.date.contains(q) || d.formattedDate.toLowerCase().contains(q),
//         )
//         .toList();
//   }
//
//   String _fmtCur(double v) =>
//       '₹${NumberFormat('#,##,###').format(v.abs().round())}';
//
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
//           // ── Search ───────────────────────────────────────────────────────────
//           FnSearchBar(
//             hint: 'Search by date...',
//             value: _search,
//             onChanged: (v) => setState(() => _search = v),
//           ),
//           const SizedBox(height: 10),
//
//           // ── Period filter ─────────────────────────────────────────────────────
//           FnFilterBar(
//             selected: _period,
//             options: _periods,
//             onSelect: (v) async {
//               if (v == 'Custom Range') {
//                 final range = await showDateRangePicker(
//                   context: context,
//                   firstDate: DateTime(2023),
//                   lastDate: DateTime.now(),
//                   builder: (ctx, child) => Theme(
//                     data: ThemeData.light().copyWith(
//                       colorScheme: const ColorScheme.light(
//                         primary: fnAccent,
//                         onPrimary: Colors.white,
//                       ),
//                     ),
//                     child: child!,
//                   ),
//                 );
//                 if (range != null && mounted) {
//                   setState(() {
//                     _period = v;
//                     _custom = range;
//                   });
//                   _load();
//                 }
//               } else {
//                 setState(() => _period = v);
//                 _load();
//               }
//             },
//           ),
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
//             label: 'Net Amount (${_daily.length} days)',
//             amount: _fmtCur(_totalNet),
//             isLoading: _loading,
//           ),
//           const SizedBox(height: 14),
//
//           // ── Loading ───────────────────────────────────────────────────────────
//           if (_loading)
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
//                   ? 'No data matches your search.'
//                   : 'No orders for $_period.',
//             )
//           else
//             Column(children: _filtered.map(_buildDayCard).toList()),
//         ],
//       ),
//     ),
//   );
//
//   List<DailyLedger> get _daily => _filtered;
//
//   Widget _buildDayCard(DailyLedger day) => Container(
//     margin: const EdgeInsets.only(bottom: 8),
//     decoration: fnCardDeco(),
//     child: Padding(
//       padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
//       child: Column(
//         children: [
//           Row(
//             children: [
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       day.formattedDate,
//                       style: const TextStyle(
//                         fontSize: 15,
//                         fontWeight: FontWeight.w700,
//                         color: fnText1,
//                       ),
//                     ),
//                     const SizedBox(height: 3),
//                     Text(
//                       '${day.orderCount} order${day.orderCount != 1 ? 's' : ''}',
//                       style: const TextStyle(fontSize: 11, color: fnText3),
//                     ),
//                   ],
//                 ),
//               ),
//               Text(
//                 _fmtCur(day.totalNetAmount),
//                 style: const TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.w900,
//                   color: fnAccent,
//                 ),
//               ),
//             ],
//           ),
//           // Payment method mini breakdown
//           if (day.orders.isNotEmpty) ...[
//             const SizedBox(height: 10),
//             const Divider(color: fnBorder, height: 1),
//             const SizedBox(height: 10),
//             _buildPaymentBreakdown(day.orders),
//           ],
//         ],
//       ),
//     ),
//   );
//
//   Widget _buildPaymentBreakdown(List<LedgerOrder> orders) {
//     final totals = <String, double>{};
//     for (final o in orders) {
//       if (o.paymentMethod.isNotEmpty) {
//         totals[o.paymentMethod] = (totals[o.paymentMethod] ?? 0) + o.grandTotal;
//       }
//     }
//     if (totals.isEmpty) return const SizedBox.shrink();
//
//     const colors = {
//       'Online_Payment': fnBlue,
//       'Cash': fnGreen,
//       'UPI': fnPurple,
//       'Maamaas_Wallet': fnAmber,
//       'QR': fnAccent,
//     };
//     const labels = {
//       'Online_Payment': 'Online',
//       'Cash': 'Cash',
//       'UPI': 'UPI',
//       'Maamaas_Wallet': 'Wallet',
//       'QR': 'QR',
//     };
//
//     return Wrap(
//       spacing: 8,
//       runSpacing: 6,
//       children: totals.entries.map((e) {
//         final color = colors[e.key] ?? fnText2;
//         final label = labels[e.key] ?? e.key.replaceAll('_', ' ');
//         return Container(
//           padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//           decoration: BoxDecoration(
//             color: color.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(8),
//             border: Border.all(color: color.withOpacity(0.25)),
//           ),
//           child: RichText(
//             text: TextSpan(
//               children: [
//                 TextSpan(
//                   text: '$label  ',
//                   style: TextStyle(
//                     fontSize: 10,
//                     color: color.withOpacity(0.8),
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 TextSpan(
//                   text: _fmtCur(e.value),
//                   style: TextStyle(
//                     fontSize: 11,
//                     color: color,
//                     fontWeight: FontWeight.w800,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       }).toList(),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/finance_models.dart';
import '../services/finance_service.dart';
import '../widgets/theme.dart';
import 'FnSearchBarScreen.dart';

class LedgerTab extends StatefulWidget {
  const LedgerTab({super.key});
  @override
  State<LedgerTab> createState() => _LedgerTabState();
}

class _LedgerTabState extends State<LedgerTab> {
  List<DailyLedger> _dailyData = [];
  double _totalNet = 0;
  bool _loading = false;
  String? _error;
  String _search = '';
  String _period = 'This Week';
  DateTimeRange? _custom;

  static const _periods = [
    // 'Today',
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
    final range = _buildDateRange();
    if (range == null) return;

    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final fmt = DateFormat('yyyy-MM-dd');
      final now = DateTime.now();
      final todayStr = fmt.format(DateTime(now.year, now.month, now.day));

      final startDate = fmt.format(range.start);
      final endDate = fmt.format(range.end);

      final orders = await FinanceService.fetchOrdersByDateRange(
        startDate,
        endDate,
      );

      // Filter by date range and exclude today's orders
      final filtered = orders.where((o) {
        if (o.date.isEmpty) return false;
        if (o.date == todayStr) return false; // ← exclude today
        return o.date.compareTo(startDate) >= 0 &&
            o.date.compareTo(endDate) <= 0;
      }).toList();

      final daily = FinanceService.groupOrdersByDay(filtered);
      final total = daily.fold(0.0, (s, d) => s + d.totalNetAmount);

      if (mounted)
        setState(() {
          _dailyData = daily;
          _totalNet = total;
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

  DateTimeRange? _buildDateRange() {
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

  List<DailyLedger> get _filtered {
    if (_search.isEmpty) return _dailyData;
    final q = _search.toLowerCase();
    return _dailyData
        .where(
          (d) =>
              d.date.contains(q) || d.formattedDate.toLowerCase().contains(q),
        )
        .toList();
  }

  List<DailyLedger> get _daily => _filtered;

  // String _fmtCur(double v) =>
  //     '₹${NumberFormat('#,##,###').format(v.abs().round())}';

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
          // ── Search ─────────────────────────────────────────────────────────
          Row(
            children: [
              // 🔍 Search
              Expanded(
                flex: 4, // more space
                child: FnSearchBar(
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
                        .map(
                          (e) => DropdownMenuItem(
                        value: e,
                        child: Text(e),
                      ),
                    )
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

          // ── Net amount banner ───────────────────────────────────────────────
          FnNetBanner(
            label: 'Net Amount ',
            amount: (_totalNet.toStringAsFixed(2)),
            isLoading: _loading,
          ),
          const SizedBox(height: 14),

          // ── Content ─────────────────────────────────────────────────────────
          if (_loading)
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
                  ? 'No data matches your search.'
                  : _period == 'Today'
                  ? 'Today\'s data is not available yet.'
                  : 'No orders for $_period.',
            )
          else
            Column(children: _filtered.map(_buildDayCard).toList()),
        ],
      ),
    ),
  );

  Widget _buildDayCard(DailyLedger day) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    decoration: fnCardDeco(),
    child: Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      day.formattedDate,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: fnText1,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${day.orderCount} order${day.orderCount != 1 ? 's' : ''}',
                      style: const TextStyle(fontSize: 11, color: fnText3),
                    ),
                  ],
                ),
              ),
              Text(
                (day.totalNetAmount.toStringAsFixed(2)),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: fnAccent,
                ),
              ),
            ],
          ),

        ],
      ),
    ),
  );
}
