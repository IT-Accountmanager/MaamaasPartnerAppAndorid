// // // import 'package:flutter/material.dart';
// // // import 'package:intl/intl.dart';
// // // import 'package:razorpay_flutter/razorpay_flutter.dart';
// // // import '../models/finance_models.dart';
// // // import '../services/finance_service.dart';
// // // import '../widgets/theme.dart';
// // // import 'FnSearchBarScreen.dart';
// // // import 'settlements_tab.dart' show _SearchBar;
// // //
// // // class CreditsTab extends StatefulWidget {
// // //   const CreditsTab({super.key});
// // //   @override
// // //   State<CreditsTab> createState() => _CreditsTabState();
// // // }
// // //
// // // class _CreditsTabState extends State<CreditsTab> {
// // //   CreditStats? _stats;
// // //   bool _loading = false;
// // //   bool _paying = false;
// // //   String? _error;
// // //
// // //   final _amountCtrl = TextEditingController();
// // //   late final Razorpay _razorpay;
// // //
// // //   String _search = '';
// // //   String _period = 'This Month';
// // //   DateTimeRange? _custom;
// // //
// // //   // Credit history from settlements endpoint
// // //   List<_CreditHistoryItem> _history = [];
// // //   bool _histLoading = false;
// // //
// // //   static const _periods = [
// // //     'Today',
// // //     'Yesterday',
// // //     'This Week',
// // //     'This Month',
// // //     'Last Month',
// // //     'This Year',
// // //     'Custom Range',
// // //   ];
// // //
// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     _razorpay = Razorpay();
// // //     _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onPaySuccess);
// // //     _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _onPayError);
// // //     _razorpay.on(
// // //       Razorpay.EVENT_EXTERNAL_WALLET,
// // //       (_) => setState(() => _paying = false),
// // //     );
// // //     _load();
// // //   }
// // //
// // //   @override
// // //   void dispose() {
// // //     _razorpay.clear();
// // //     _amountCtrl.dispose();
// // //     super.dispose();
// // //   }
// // //
// // //   Future<void> _load() async {
// // //     setState(() {
// // //       _loading = true;
// // //       _error = null;
// // //     });
// // //     try {
// // //       final results = await Future.wait([
// // //         FinanceService.fetchCreditStats(),
// // //         FinanceService.fetchSettlements(),
// // //       ]);
// // //       final stats = results[0] as CreditStats?;
// // //       final summary = results[1] as dynamic;
// // //
// // //       final history = <_CreditHistoryItem>[];
// // //       if (summary != null) {
// // //         for (final s in (summary.settlements as List<Settlement>)) {
// // //           if ((s.settlementDate ?? '').isNotEmpty) {
// // //             history.add(
// // //               _CreditHistoryItem(
// // //                 id: s.settlementId,
// // //                 date: s.settlementDate!.split('T')[0],
// // //                 adjustment: s.isPaid ? -s.netAmount : s.netAmount,
// // //                 paymentMode: s.pytMode,
// // //                 status: s.paymentStatus,
// // //                 fromDate: s.fromDate ?? '',
// // //                 toDate: s.toDate ?? '',
// // //               ),
// // //             );
// // //           }
// // //         }
// // //         history.sort((a, b) => b.date.compareTo(a.date));
// // //       }
// // //
// // //       if (mounted)
// // //         setState(() {
// // //           _stats = stats;
// // //           _history = history;
// // //           _loading = false;
// // //         });
// // //     } catch (e) {
// // //       if (mounted)
// // //         setState(() {
// // //           _error = e.toString();
// // //           _loading = false;
// // //         });
// // //     }
// // //   }
// // //
// // //   Future<void> _startPayment() async {
// // //     final amt = double.tryParse(_amountCtrl.text.trim()) ?? 0;
// // //     if (amt <= 0) {
// // //       fnSnack(context, 'Enter a valid amount', error: true);
// // //       return;
// // //     }
// // //
// // //     setState(() => _paying = true);
// // //     try {
// // //       final orderId = await FinanceService.createRazorpayOrder(amt);
// // //       if (orderId == null) throw Exception('Order ID not received');
// // //       _razorpay.open({
// // //         'key': 'rzp_test_TJECsclCivENpY',
// // //         'amount': (amt * 100).toInt(),
// // //         'currency': 'INR',
// // //         'order_id': orderId,
// // //         'name': 'MAAMAAS',
// // //         'description': 'Add Credits to Wallet',
// // //         'prefill': {'contact': '', 'email': ''},
// // //         'theme': {'color': '#E66D33'},
// // //       });
// // //     } catch (e) {
// // //       setState(() => _paying = false);
// // //       if (mounted) fnSnack(context, 'Payment failed: $e', error: true);
// // //     }
// // //   }
// // //
// // //   void _onPaySuccess(PaymentSuccessResponse r) async {
// // //     try {
// // //       final amt = double.tryParse(_amountCtrl.text.trim()) ?? 0;
// // //       await FinanceService.captureRazorpayPayment(r.paymentId!, amt);
// // //       await FinanceService.payCredits(amount: amt, transactionId: r.paymentId!);
// // //       _amountCtrl.clear();
// // //       if (mounted) {
// // //         fnSnack(context, '✅ ₹${amt.toInt()} added to your credits');
// // //         _load();
// // //       }
// // //     } catch (e) {
// // //       if (mounted)
// // //         fnSnack(
// // //           context,
// // //           'Payment succeeded but update failed: $e',
// // //           error: true,
// // //         );
// // //     } finally {
// // //       if (mounted) setState(() => _paying = false);
// // //     }
// // //   }
// // //
// // //   void _onPayError(PaymentFailureResponse r) {
// // //     if (mounted) {
// // //       setState(() => _paying = false);
// // //       fnSnack(
// // //         context,
// // //         'Payment failed: ${r.message ?? 'Unknown error'}',
// // //         error: true,
// // //       );
// // //     }
// // //   }
// // //
// // //   // ── Filtered history ──────────────────────────────────────────────────────
// // //   List<_CreditHistoryItem> get _filteredHistory {
// // //     final range = _dateRange;
// // //     List<_CreditHistoryItem> result = _history;
// // //     if (range != null) {
// // //       final from = DateTime(
// // //         range.start.year,
// // //         range.start.month,
// // //         range.start.day,
// // //       );
// // //       final to = DateTime(
// // //         range.end.year,
// // //         range.end.month,
// // //         range.end.day,
// // //         23,
// // //         59,
// // //         59,
// // //       );
// // //       result = result.where((h) {
// // //         try {
// // //           final d = DateTime.parse(h.date);
// // //           return !d.isBefore(from) && !d.isAfter(to);
// // //         } catch (_) {
// // //           return false;
// // //         }
// // //       }).toList();
// // //     }
// // //     if (_search.isNotEmpty) {
// // //       final q = _search.toLowerCase();
// // //       result = result
// // //           .where(
// // //             (h) =>
// // //                 h.date.contains(q) ||
// // //                 h.paymentMode.toLowerCase().contains(q) ||
// // //                 h.id.toString().contains(q),
// // //           )
// // //           .toList();
// // //     }
// // //     return result;
// // //   }
// // //
// // //   DateTimeRange? get _dateRange {
// // //     final now = DateTime.now();
// // //     final today = DateTime(now.year, now.month, now.day);
// // //     switch (_period) {
// // //       case 'Today':
// // //         return DateTimeRange(start: today, end: today);
// // //       case 'Yesterday':
// // //         final y = today.subtract(const Duration(days: 1));
// // //         return DateTimeRange(start: y, end: y);
// // //       case 'This Week':
// // //         final wd = today.weekday;
// // //         final m = today.subtract(Duration(days: wd - 1));
// // //         return DateTimeRange(start: m, end: m.add(const Duration(days: 6)));
// // //       case 'This Month':
// // //         return DateTimeRange(
// // //           start: DateTime(now.year, now.month, 1),
// // //           end: DateTime(now.year, now.month + 1, 0),
// // //         );
// // //       case 'Last Month':
// // //         return DateTimeRange(
// // //           start: DateTime(now.year, now.month - 1, 1),
// // //           end: DateTime(now.year, now.month, 0),
// // //         );
// // //       case 'This Year':
// // //         return DateTimeRange(
// // //           start: DateTime(now.year, 1, 1),
// // //           end: DateTime(now.year, 12, 31),
// // //         );
// // //       case 'Custom Range':
// // //         return _custom;
// // //       default:
// // //         return null;
// // //     }
// // //   }
// // //
// // //   String _fmtCur(double v) =>
// // //       '₹${NumberFormat('#,##,###').format(v.abs().round())}';
// // //
// // //   @override
// // //   Widget build(BuildContext context) => RefreshIndicator(
// // //     color: fnAccent,
// // //     onRefresh: _load,
// // //     child: SingleChildScrollView(
// // //       physics: const AlwaysScrollableScrollPhysics(),
// // //       padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
// // //       child: Column(
// // //         crossAxisAlignment: CrossAxisAlignment.start,
// // //         children: [
// // //           // ── Search + filter ─────────────────────────────────────────────────
// // //           Row(
// // //             children: [
// // //               // 🔍 Search bar
// // //               Expanded(
// // //                 child: FnSearchBar(
// // //                   hint: 'Search credit history...',
// // //                   value: _search,
// // //                   onChanged: (v) => setState(() => _search = v),
// // //                 ),
// // //               ),
// // //
// // //               const SizedBox(width: 8),
// // //
// // //               // ⬇️ Dropdown
// // //               Container(
// // //                 height: 44,
// // //                 padding: const EdgeInsets.symmetric(horizontal: 8),
// // //                 decoration: BoxDecoration(
// // //                   color: Colors.white,
// // //                   borderRadius: BorderRadius.circular(10),
// // //                   border: Border.all(color: fnBorder),
// // //                 ),
// // //                 child: DropdownButtonHideUnderline(
// // //                   child: DropdownButton<String>(
// // //                     value: _period,
// // //                     icon: const Icon(Icons.keyboard_arrow_down_rounded),
// // //                     style: const TextStyle(fontSize: 12, color: fnText1),
// // //                     onChanged: (v) async {
// // //                       if (v == null) return;
// // //
// // //                       if (v == 'Custom Range') {
// // //                         final range = await showDateRangePicker(
// // //                           context: context,
// // //                           firstDate: DateTime(2023),
// // //                           lastDate: DateTime.now(),
// // //                         );
// // //
// // //                         if (range != null) {
// // //                           setState(() {
// // //                             _period = v;
// // //                             _custom = range;
// // //                           });
// // //                         }
// // //                       } else {
// // //                         setState(() => _period = v);
// // //                       }
// // //                     },
// // //                     items: _periods
// // //                         .map((e) => DropdownMenuItem(value: e, child: Text(e)))
// // //                         .toList(),
// // //                   ),
// // //                 ),
// // //               ),
// // //             ],
// // //           ),
// // //           const SizedBox(height: 10),
// // //
// // //           // ── Credit summary card ─────────────────────────────────────────────
// // //           if (_loading && _stats == null)
// // //             const Center(
// // //               child: Padding(
// // //                 padding: EdgeInsets.all(40),
// // //                 child: CircularProgressIndicator(color: fnAccent),
// // //               ),
// // //             )
// // //           else if (_stats != null)
// // //             _buildCreditSummary(),
// // //
// // //           // ── Alert banner ────────────────────────────────────────────────────
// // //           if (_stats != null && _stats!.status != 'active') ...[
// // //             const SizedBox(height: 12),
// // //             _buildAlert(),
// // //           ],
// // //           const SizedBox(height: 14),
// // //
// // //           // // ── Credit history ──────────────────────────────────────────────────
// // //           // if (_filteredHistory.isNotEmpty) ...[
// // //           //   const FnSectionHeader(title: 'Credit History'),
// // //           //   Column(children: _filteredHistory.map(_buildHistoryCard).toList()),
// // //           // ] else if (!_loading)
// // //           //   FnEmpty(
// // //           //     message: _search.isNotEmpty
// // //           //         ? 'No records match your search.'
// // //           //         : 'No credit history for $_period.',
// // //           //   ),
// // //         ],
// // //       ),
// // //     ),
// // //   );
// // //
// // //   Widget _buildCreditSummary() {
// // //     final s = _stats!;
// // //
// // //     // 🌸 Pink theme colors
// // //     const Color pinkMain = Color(0xFFE66D33);
// // //     const Color pinkLight = Color(0xFFF7F8FC);
// // //     const Color pinkBorder = Color(0xFFFFF0E8);
// // //
// // //     return Container(
// // //       decoration: BoxDecoration(
// // //         color: pinkLight,
// // //         borderRadius: BorderRadius.circular(16),
// // //         border: Border.all(color: pinkBorder),
// // //       ),
// // //       padding: const EdgeInsets.all(14),
// // //       child: Column(
// // //         children: [
// // //           // ── 3 stat boxes ─────────────────────────────────────────────
// // //           Row(
// // //             children: [
// // //               _creditBox('Credit Limit', _fmtCur(s.totalCreditPoints), fnText1),
// // //               const SizedBox(width: 8),
// // //               _creditBox(
// // //                 'Used Credit',
// // //                 _fmtCur(s.usedCreditPoints),
// // //                 Colors.red,
// // //               ),
// // //               const SizedBox(width: 8),
// // //               _creditBox(
// // //                 'Remaining',
// // //                 _fmtCur(s.availableCreditPoints),
// // //                 Colors.green,
// // //               ),
// // //             ],
// // //           ),
// // //           const SizedBox(height: 12),
// // //
// // //           // ── Add credits row ─────────────────────────────────────────
// // //           Container(
// // //             padding: const EdgeInsets.all(12),
// // //             decoration: BoxDecoration(
// // //               color: Colors.white,
// // //               borderRadius: BorderRadius.circular(12),
// // //               border: Border.all(color: pinkBorder),
// // //             ),
// // //             child: Column(
// // //               crossAxisAlignment: CrossAxisAlignment.start,
// // //               children: [
// // //                 const Text(
// // //                   'Add Credits',
// // //                   style: TextStyle(
// // //                     fontSize: 12,
// // //                     color: fnText2,
// // //                     fontWeight: FontWeight.w600,
// // //                   ),
// // //                 ),
// // //                 const SizedBox(height: 8),
// // //                 Row(
// // //                   children: [
// // //                     Container(
// // //                       width: 36,
// // //                       height: 36,
// // //                       decoration: BoxDecoration(
// // //                         color: pinkLight,
// // //                         borderRadius: const BorderRadius.only(
// // //                           topLeft: Radius.circular(8),
// // //                           bottomLeft: Radius.circular(8),
// // //                         ),
// // //                         border: Border.all(color: pinkBorder),
// // //                       ),
// // //                       child: const Center(
// // //                         child: Text(
// // //                           '₹',
// // //                           style: TextStyle(
// // //                             fontSize: 14,
// // //                             fontWeight: FontWeight.w700,
// // //                             color: fnText2,
// // //                           ),
// // //                         ),
// // //                       ),
// // //                     ),
// // //                     Expanded(
// // //                       child: Container(
// // //                         height: 36,
// // //                         decoration: BoxDecoration(
// // //                           border: Border(
// // //                             top: BorderSide(color: pinkBorder),
// // //                             bottom: BorderSide(color: pinkBorder),
// // //                           ),
// // //                         ),
// // //                         child: TextField(
// // //                           controller: _amountCtrl,
// // //                           keyboardType: TextInputType.number,
// // //                           decoration: const InputDecoration(
// // //                             hintText: 'Enter amount',
// // //                             hintStyle: TextStyle(color: fnText3, fontSize: 13),
// // //                             border: InputBorder.none,
// // //                             contentPadding: EdgeInsets.symmetric(
// // //                               horizontal: 10,
// // //                             ),
// // //                           ),
// // //                           style: const TextStyle(fontSize: 13, color: fnText1),
// // //                         ),
// // //                       ),
// // //                     ),
// // //                     GestureDetector(
// // //                       onTap: _paying ? null : _startPayment,
// // //                       child: AnimatedContainer(
// // //                         duration: const Duration(milliseconds: 180),
// // //                         height: 36,
// // //                         width: 64,
// // //                         decoration: BoxDecoration(
// // //                           color: _paying ? Colors.grey : pinkMain,
// // //                           borderRadius: const BorderRadius.only(
// // //                             topRight: Radius.circular(8),
// // //                             bottomRight: Radius.circular(8),
// // //                           ),
// // //                         ),
// // //                         child: _paying
// // //                             ? const Center(
// // //                                 child: SizedBox(
// // //                                   width: 16,
// // //                                   height: 16,
// // //                                   child: CircularProgressIndicator(
// // //                                     color: Colors.white,
// // //                                     strokeWidth: 2,
// // //                                   ),
// // //                                 ),
// // //                               )
// // //                             : const Center(
// // //                                 child: Text(
// // //                                   'Pay',
// // //                                   style: TextStyle(
// // //                                     color: Colors.white,
// // //                                     fontWeight: FontWeight.w700,
// // //                                     fontSize: 13,
// // //                                   ),
// // //                                 ),
// // //                               ),
// // //                       ),
// // //                     ),
// // //                   ],
// // //                 ),
// // //               ],
// // //             ),
// // //           ),
// // //           const SizedBox(height: 10),
// // //
// // //           // ── Usage bar ───────────────────────────────────────────────
// // //           ClipRRect(
// // //             borderRadius: BorderRadius.circular(8),
// // //             child: LinearProgressIndicator(
// // //               value: s.usagePercent,
// // //               backgroundColor: Colors.white.withOpacity(0.6),
// // //               color: pinkMain,
// // //               minHeight: 10,
// // //             ),
// // //           ),
// // //           const SizedBox(height: 6),
// // //
// // //           // ── Labels ──────────────────────────────────────────────────
// // //           Row(
// // //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // //             children: [
// // //               Text(
// // //                 '${(s.usagePercent * 100).toStringAsFixed(0)}% used',
// // //                 style: TextStyle(
// // //                   fontSize: 10,
// // //                   color: pinkMain,
// // //                   fontWeight: FontWeight.w600,
// // //                 ),
// // //               ),
// // //               Text(
// // //                 _fmtCur(s.availableCreditPoints) + ' available',
// // //                 style: const TextStyle(fontSize: 10, color: fnText2),
// // //               ),
// // //             ],
// // //           ),
// // //         ],
// // //       ),
// // //     );
// // //   }
// // //
// // //   Widget _creditBox(String label, String value, Color color) => Expanded(
// // //     child: Container(
// // //       padding: const EdgeInsets.all(10),
// // //       decoration: BoxDecoration(
// // //         color: Colors.white.withOpacity(0.7),
// // //         borderRadius: BorderRadius.circular(10),
// // //       ),
// // //       child: Column(
// // //         children: [
// // //           Text(
// // //             label,
// // //             style: const TextStyle(fontSize: 10, color: fnText2),
// // //             textAlign: TextAlign.center,
// // //           ),
// // //           const SizedBox(height: 4),
// // //           Text(
// // //             value,
// // //             style: TextStyle(
// // //               fontSize: 14,
// // //               fontWeight: FontWeight.w800,
// // //               color: color,
// // //             ),
// // //             textAlign: TextAlign.center,
// // //           ),
// // //         ],
// // //       ),
// // //     ),
// // //   );
// // //
// // //   Widget _buildAlert() {
// // //     final s = _stats!;
// // //     final msg = s.status == 'payment_required'
// // //         ? 'Pay ${_fmtCur(s.usedCreditPoints)} to enable all payment modes'
// // //         : 'Credit limit reached soon – recharge recommended';
// // //     return Container(
// // //       padding: const EdgeInsets.all(12),
// // //       decoration: BoxDecoration(
// // //         color: fnAmberL,
// // //         borderRadius: BorderRadius.circular(12),
// // //         border: Border.all(color: fnAmber.withOpacity(0.4)),
// // //       ),
// // //       child: Row(
// // //         children: [
// // //           const Icon(Icons.warning_amber_rounded, color: fnAmber, size: 18),
// // //           const SizedBox(width: 10),
// // //           Expanded(
// // //             child: Text(
// // //               msg,
// // //               style: const TextStyle(
// // //                 fontSize: 12,
// // //                 color: fnText1,
// // //                 fontWeight: FontWeight.w500,
// // //               ),
// // //             ),
// // //           ),
// // //         ],
// // //       ),
// // //     );
// // //   }
// // //
// // //   Widget _buildHistoryCard(_CreditHistoryItem h) {
// // //     final isDebit = h.adjustment < 0;
// // //     return Container(
// // //       margin: const EdgeInsets.only(bottom: 8),
// // //       decoration: fnCardDeco(),
// // //       child: Padding(
// // //         padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
// // //         child: Row(
// // //           children: [
// // //             Container(
// // //               width: 40,
// // //               height: 40,
// // //               decoration: BoxDecoration(
// // //                 color: isDebit ? fnRedL : fnGreenL,
// // //                 borderRadius: BorderRadius.circular(12),
// // //               ),
// // //               child: Icon(
// // //                 isDebit
// // //                     ? Icons.arrow_upward_rounded
// // //                     : Icons.arrow_downward_rounded,
// // //                 color: isDebit ? fnRed : fnGreen,
// // //                 size: 20,
// // //               ),
// // //             ),
// // //             const SizedBox(width: 12),
// // //             Expanded(
// // //               child: Column(
// // //                 crossAxisAlignment: CrossAxisAlignment.start,
// // //                 children: [
// // //                   Text(
// // //                     _dateLabel(h.date),
// // //                     style: const TextStyle(
// // //                       fontSize: 13,
// // //                       fontWeight: FontWeight.w700,
// // //                       color: fnText1,
// // //                     ),
// // //                   ),
// // //                   const SizedBox(height: 2),
// // //                   Row(
// // //                     children: [
// // //                       _modeBadge(h.paymentMode),
// // //                       const SizedBox(width: 6),
// // //                       _statusBadge(h.status),
// // //                     ],
// // //                   ),
// // //                 ],
// // //               ),
// // //             ),
// // //             Text(
// // //               '${isDebit ? '−' : '+'}${_fmtCur(h.adjustment.abs())}',
// // //               style: TextStyle(
// // //                 fontSize: 16,
// // //                 fontWeight: FontWeight.w800,
// // //                 color: isDebit ? fnRed : fnGreen,
// // //               ),
// // //             ),
// // //           ],
// // //         ),
// // //       ),
// // //     );
// // //   }
// // //
// // //   Widget _modeBadge(String mode) => Container(
// // //     padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
// // //     decoration: BoxDecoration(
// // //       color: fnBlueL,
// // //       borderRadius: BorderRadius.circular(5),
// // //     ),
// // //     child: Text(
// // //       mode.isNotEmpty ? mode : 'N/A',
// // //       style: const TextStyle(
// // //         fontSize: 9,
// // //         color: fnBlue,
// // //         fontWeight: FontWeight.w700,
// // //       ),
// // //     ),
// // //   );
// // //
// // //   Widget _statusBadge(String status) {
// // //     final color =
// // //         status.toUpperCase() == 'PAID' || status.toUpperCase() == 'COMPLETED'
// // //         ? fnGreen
// // //         : fnAmber;
// // //     return Container(
// // //       padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
// // //       decoration: BoxDecoration(
// // //         color: color.withOpacity(0.12),
// // //         borderRadius: BorderRadius.circular(5),
// // //       ),
// // //       child: Text(
// // //         status,
// // //         style: TextStyle(
// // //           fontSize: 9,
// // //           color: color,
// // //           fontWeight: FontWeight.w700,
// // //         ),
// // //       ),
// // //     );
// // //   }
// // //
// // //   String _dateLabel(String d) {
// // //     try {
// // //       final dt = DateTime.parse(d);
// // //       final now = DateTime.now();
// // //       final today = DateTime(now.year, now.month, now.day);
// // //       final yest = today.subtract(const Duration(days: 1));
// // //       final day = DateTime(dt.year, dt.month, dt.day);
// // //       final months = [
// // //         'January',
// // //         'February',
// // //         'March',
// // //         'April',
// // //         'May',
// // //         'June',
// // //         'July',
// // //         'August',
// // //         'September',
// // //         'October',
// // //         'November',
// // //         'December',
// // //       ];
// // //       if (day == today) return 'Today, ${months[dt.month - 1]} ${dt.day}';
// // //       if (day == yest) return 'Yesterday, ${months[dt.month - 1]} ${dt.day}';
// // //       return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
// // //     } catch (_) {
// // //       return d;
// // //     }
// // //   }
// // // }
// // //
// // // class _CreditHistoryItem {
// // //   final int id;
// // //   final String date;
// // //   final double adjustment;
// // //   final String paymentMode;
// // //   final String status;
// // //   final String fromDate;
// // //   final String toDate;
// // //   const _CreditHistoryItem({
// // //     required this.id,
// // //     required this.date,
// // //     required this.adjustment,
// // //     required this.paymentMode,
// // //     required this.status,
// // //     required this.fromDate,
// // //     required this.toDate,
// // //   });
// // // }
// // import 'package:flutter/material.dart';
// // import 'package:intl/intl.dart';
// // import 'package:razorpay_flutter/razorpay_flutter.dart';
// // import '../models/finance_models.dart';
// // import '../services/finance_service.dart';
// // import '../widgets/theme.dart';
// // import 'FnSearchBarScreen.dart';
// //
// // // ── Data model ────────────────────────────────────────────────────────────────
// // class _CreditTransaction {
// //   final int id;
// //   final int vendorId;
// //   final double creditAmount;
// //   final String transactionType;
// //   final String description;
// //   final String transactionId;
// //   final String transactionDate;
// //
// //   const _CreditTransaction({
// //     required this.id,
// //     required this.vendorId,
// //     required this.creditAmount,
// //     required this.transactionType,
// //     required this.description,
// //     required this.transactionId,
// //     required this.transactionDate,
// //   });
// //
// //   factory _CreditTransaction.fromJson(Map<String, dynamic> j) =>
// //       _CreditTransaction(
// //         id: (j['id'] ?? 0) as int,
// //         vendorId: (j['vendorId'] ?? 0) as int,
// //         creditAmount: (j['creditAmount'] ?? 0).toDouble(),
// //         transactionType: j['transactionType']?.toString() ?? '',
// //         description: j['description']?.toString() ?? '',
// //         transactionId: j['transactionId']?.toString() ?? '',
// //         transactionDate: j['transactionDate']?.toString() ?? '',
// //       );
// // }
// //
// // // ── Widget ────────────────────────────────────────────────────────────────────
// // class CreditsTab extends StatefulWidget {
// //   const CreditsTab({super.key});
// //
// //   @override
// //   State<CreditsTab> createState() => _CreditsTabState();
// // }
// //
// // class _CreditsTabState extends State<CreditsTab> {
// //   // ── State ──────────────────────────────────────────────────────────────────
// //   CreditStats? _stats;
// //   List<_CreditTransaction> _transactions = [];
// //   bool _loading = false;
// //   bool _paying = false;
// //   String? _error;
// //
// //   final _amountCtrl = TextEditingController();
// //   late final Razorpay _razorpay;
// //
// //   String _search = '';
// //   String _period = 'This Month';
// //   DateTimeRange? _custom;
// //
// //   // ── Constants ──────────────────────────────────────────────────────────────
// //   static const double _gstRate = 0.18; // 18% GST — hardcoded
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
// //   static const Color _orange = Color(0xFFE66D33);
// //   static const Color _orangeLight = Color(0xFFF7F8FC);
// //   static const Color _orangeBorder = Color(0xFFFFF0E8);
// //
// //   // ── Lifecycle ──────────────────────────────────────────────────────────────
// //   @override
// //   void initState() {
// //     super.initState();
// //     _razorpay = Razorpay();
// //     _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onPaySuccess);
// //     _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _onPayError);
// //     _razorpay.on(
// //       Razorpay.EVENT_EXTERNAL_WALLET,
// //       (_) => setState(() => _paying = false),
// //     );
// //     _load();
// //   }
// //
// //   @override
// //   void dispose() {
// //     _razorpay.clear();
// //     _amountCtrl.dispose();
// //     super.dispose();
// //   }
// //
// //   // ── Data loading ───────────────────────────────────────────────────────────
// //   Future<void> _load() async {
// //     setState(() {
// //       _loading = true;
// //       _error = null;
// //     });
// //     try {
// //       final results = await Future.wait([
// //         FinanceService.fetchCreditStats(),
// //         FinanceService.fetchCreditTransactions(),
// //       ]);
// //
// //       final stats = results[0] as CreditStats?;
// //       final rawList = results[1] as List<dynamic>;
// //
// //       final txList = rawList
// //           .whereType<Map<String, dynamic>>()
// //           .map(_CreditTransaction.fromJson)
// //           .toList();
// //
// //       // newest first
// //       txList.sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
// //
// //       if (mounted) {
// //         setState(() {
// //           _stats = stats;
// //           _transactions = txList;
// //           _loading = false;
// //         });
// //       }
// //     } catch (e) {
// //       if (mounted) {
// //         setState(() {
// //           _error = e.toString();
// //           _loading = false;
// //         });
// //       }
// //     }
// //   }
// //
// //   // ── GST helpers ────────────────────────────────────────────────────────────
// //   double get _enteredAmount => double.tryParse(_amountCtrl.text.trim()) ?? 0;
// //   double get _gstAmount =>
// //       double.parse((_enteredAmount * _gstRate).toStringAsFixed(2));
// //   double get _totalWithGst =>
// //       double.parse((_enteredAmount + _gstAmount).toStringAsFixed(2));
// //
// //   // ── Payment ────────────────────────────────────────────────────────────────
// //   Future<void> _startPayment() async {
// //     if (_enteredAmount <= 0) {
// //       fnSnack(context, 'Enter a valid amount', error: true);
// //       return;
// //     }
// //     setState(() => _paying = true);
// //     try {
// //       final orderId = await FinanceService.createRazorpayOrder(_totalWithGst);
// //       if (orderId == null) throw Exception('Order ID not received');
// //
// //       _razorpay.open({
// //         'key': 'rzp_test_TJECsclCivENpY',
// //         'amount': (_totalWithGst * 100).toInt(),
// //         'currency': 'INR',
// //         'order_id': orderId,
// //         'name': 'MAAMAAS',
// //         'description': 'Add Credits to Wallet',
// //         'prefill': {'contact': '', 'email': ''},
// //         'theme': {'color': '#E66D33'},
// //       });
// //     } catch (e) {
// //       setState(() => _paying = false);
// //       if (mounted) fnSnack(context, 'Payment failed: $e', error: true);
// //     }
// //   }
// //
// //   void _onPaySuccess(PaymentSuccessResponse r) async {
// //     // Snapshot before clearing
// //     final base = _enteredAmount;
// //     final gst = _gstAmount;
// //     final total = _totalWithGst;
// //     try {
// //       await FinanceService.captureRazorpayPayment(r.paymentId!, total);
// //       await FinanceService.payCredits(
// //         amount: total,
// //         transactionId: r.paymentId!,
// //       );
// //       _amountCtrl.clear();
// //       if (mounted) {
// //         fnSnack(
// //           context,
// //           '✅ ₹${base.toInt()} + ₹${gst.toStringAsFixed(0)} GST credited successfully',
// //         );
// //         _load();
// //       }
// //     } catch (e) {
// //       if (mounted) {
// //         fnSnack(
// //           context,
// //           'Payment succeeded but update failed: $e',
// //           error: true,
// //         );
// //       }
// //     } finally {
// //       if (mounted) setState(() => _paying = false);
// //     }
// //   }
// //
// //   void _onPayError(PaymentFailureResponse r) {
// //     if (mounted) {
// //       setState(() => _paying = false);
// //       fnSnack(
// //         context,
// //         'Payment failed: ${r.message ?? 'Unknown error'}',
// //         error: true,
// //       );
// //     }
// //   }
// //
// //   // ── Filtering ──────────────────────────────────────────────────────────────
// //   List<_CreditTransaction> get _filtered {
// //     final range = _dateRange;
// //     List<_CreditTransaction> result = _transactions;
// //
// //     if (range != null) {
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
// //       result = result.where((t) {
// //         try {
// //           final d = DateTime.parse(t.transactionDate);
// //           return !d.isBefore(from) && !d.isAfter(to);
// //         } catch (_) {
// //           return false;
// //         }
// //       }).toList();
// //     }
// //
// //     if (_search.isNotEmpty) {
// //       final q = _search.toLowerCase();
// //       result = result
// //           .where(
// //             (t) =>
// //                 t.transactionId.toLowerCase().contains(q) ||
// //                 t.description.toLowerCase().contains(q) ||
// //                 t.transactionDate.contains(q) ||
// //                 t.creditAmount.toString().contains(q) ||
// //                 t.id.toString().contains(q),
// //           )
// //           .toList();
// //     }
// //
// //     return result;
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
// //         final mon = today.subtract(Duration(days: today.weekday - 1));
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
// //   // ── Formatters ─────────────────────────────────────────────────────────────
// //   String _fmtCur(double v) =>
// //       '₹${NumberFormat('#,##,###').format(v.abs().round())}';
// //
// //   String _fmtDate(String raw) {
// //     try {
// //       final dt = DateTime.parse(raw).toLocal();
// //       return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
// //     } catch (_) {
// //       return raw;
// //     }
// //   }
// //
// //   String _cleanDesc(String s) => s.replaceAll('â‚¹', '₹');
// //
// //   // ══════════════════════════════════════════════════════════════════════════
// //   // BUILD
// //   // ══════════════════════════════════════════════════════════════════════════
// //   @override
// //   Widget build(BuildContext context) {
// //     return RefreshIndicator(
// //       color: fnAccent,
// //       onRefresh: _load,
// //       child: SingleChildScrollView(
// //         physics: const AlwaysScrollableScrollPhysics(),
// //         padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             // ── Search + period filter ───────────────────────────────────
// //             _buildSearchRow(),
// //             const SizedBox(height: 10),
// //
// //             // ── Credit summary + Add credits card ────────────────────────
// //             if (_loading && _stats == null)
// //               const Center(
// //                 child: Padding(
// //                   padding: EdgeInsets.all(40),
// //                   child: CircularProgressIndicator(color: fnAccent),
// //                 ),
// //               )
// //             else if (_stats != null)
// //               _buildCreditSummaryCard(),
// //
// //             // ── Alert ────────────────────────────────────────────────────
// //             if (_stats != null && _stats!.status != 'active') ...[
// //               const SizedBox(height: 12),
// //               _buildAlert(),
// //             ],
// //
// //             const SizedBox(height: 20),
// //
// //             // ── Transaction history ──────────────────────────────────────
// //             _buildHistorySection(),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// //
// //   // ── Search row ─────────────────────────────────────────────────────────────
// //   Widget _buildSearchRow() {
// //     return Row(
// //       children: [
// //         Expanded(
// //           child: FnSearchBar(
// //             hint: 'Search credit history...',
// //             value: _search,
// //             onChanged: (v) => setState(() => _search = v),
// //           ),
// //         ),
// //         const SizedBox(width: 8),
// //         Container(
// //           height: 44,
// //           padding: const EdgeInsets.symmetric(horizontal: 8),
// //           decoration: BoxDecoration(
// //             color: Colors.white,
// //             borderRadius: BorderRadius.circular(10),
// //             border: Border.all(color: fnBorder),
// //           ),
// //           child: DropdownButtonHideUnderline(
// //             child: DropdownButton<String>(
// //               value: _period,
// //               icon: const Icon(Icons.keyboard_arrow_down_rounded),
// //               style: const TextStyle(fontSize: 12, color: fnText1),
// //               onChanged: (v) async {
// //                 if (v == null) return;
// //                 if (v == 'Custom Range') {
// //                   final range = await showDateRangePicker(
// //                     context: context,
// //                     firstDate: DateTime(2023),
// //                     lastDate: DateTime.now(),
// //                   );
// //                   if (range != null) {
// //                     setState(() {
// //                       _period = v;
// //                       _custom = range;
// //                     });
// //                   }
// //                 } else {
// //                   setState(() => _period = v);
// //                 }
// //               },
// //               items: _periods
// //                   .map((e) => DropdownMenuItem(value: e, child: Text(e)))
// //                   .toList(),
// //             ),
// //           ),
// //         ),
// //       ],
// //     );
// //   }
// //
// //   // ── Credit summary card ────────────────────────────────────────────────────
// //   Widget _buildCreditSummaryCard() {
// //     final s = _stats!;
// //     final base = _enteredAmount;
// //     final gst = _gstAmount;
// //     final total = _totalWithGst;
// //     final showPreview = base > 0;
// //
// //     return Container(
// //       decoration: BoxDecoration(
// //         color: _orangeLight,
// //         borderRadius: BorderRadius.circular(16),
// //         border: Border.all(color: _orangeBorder),
// //       ),
// //       padding: const EdgeInsets.all(14),
// //       child: Column(
// //         children: [
// //           // ── 3 stat boxes ────────────────────────────────────────────
// //           Row(
// //             children: [
// //               _creditBox('Credit Limit', _fmtCur(s.totalCreditPoints), fnText1),
// //               const SizedBox(width: 8),
// //               _creditBox(
// //                 'Used Credit',
// //                 _fmtCur(s.usedCreditPoints),
// //                 Colors.red,
// //               ),
// //               const SizedBox(width: 8),
// //               _creditBox(
// //                 'Remaining',
// //                 _fmtCur(s.availableCreditPoints),
// //                 Colors.green,
// //               ),
// //             ],
// //           ),
// //           const SizedBox(height: 12),
// //
// //           // ── Add credits panel ────────────────────────────────────────
// //           Container(
// //             padding: const EdgeInsets.all(12),
// //             decoration: BoxDecoration(
// //               color: Colors.white,
// //               borderRadius: BorderRadius.circular(12),
// //               border: Border.all(color: _orangeBorder),
// //             ),
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 // Label
// //                 const Text(
// //                   'Add Credits',
// //                   style: TextStyle(
// //                     fontSize: 12,
// //                     color: fnText2,
// //                     fontWeight: FontWeight.w600,
// //                   ),
// //                 ),
// //                 const SizedBox(height: 8),
// //
// //                 // ₹ input + Pay button
// //                 Row(
// //                   children: [
// //                     // ₹ prefix
// //                     Container(
// //                       width: 36,
// //                       height: 40,
// //                       decoration: BoxDecoration(
// //                         color: _orangeLight,
// //                         borderRadius: const BorderRadius.only(
// //                           topLeft: Radius.circular(8),
// //                           bottomLeft: Radius.circular(8),
// //                         ),
// //                         border: Border.all(color: _orangeBorder),
// //                       ),
// //                       child: const Center(
// //                         child: Text(
// //                           '₹',
// //                           style: TextStyle(
// //                             fontSize: 15,
// //                             fontWeight: FontWeight.w700,
// //                             color: fnText2,
// //                           ),
// //                         ),
// //                       ),
// //                     ),
// //                     // Amount field
// //                     Expanded(
// //                       child: Container(
// //                         height: 40,
// //                         decoration: BoxDecoration(
// //                           border: Border(
// //                             top: BorderSide(color: _orangeBorder),
// //                             bottom: BorderSide(color: _orangeBorder),
// //                           ),
// //                         ),
// //                         child: TextField(
// //                           controller: _amountCtrl,
// //                           keyboardType: TextInputType.number,
// //                           onChanged: (_) => setState(() {}),
// //                           decoration: const InputDecoration(
// //                             hintText: 'Enter amount',
// //                             hintStyle: TextStyle(color: fnText3, fontSize: 13),
// //                             border: InputBorder.none,
// //                             contentPadding: EdgeInsets.symmetric(
// //                               horizontal: 10,
// //                             ),
// //                           ),
// //                           style: const TextStyle(fontSize: 13, color: fnText1),
// //                         ),
// //                       ),
// //                     ),
// //                     // Pay button
// //                     GestureDetector(
// //                       onTap: _paying ? null : _startPayment,
// //                       child: AnimatedContainer(
// //                         duration: const Duration(milliseconds: 180),
// //                         height: 40,
// //                         width: 70,
// //                         decoration: BoxDecoration(
// //                           color: _paying ? Colors.grey.shade400 : _orange,
// //                           borderRadius: const BorderRadius.only(
// //                             topRight: Radius.circular(8),
// //                             bottomRight: Radius.circular(8),
// //                           ),
// //                         ),
// //                         child: _paying
// //                             ? const Center(
// //                                 child: SizedBox(
// //                                   width: 16,
// //                                   height: 16,
// //                                   child: CircularProgressIndicator(
// //                                     color: Colors.white,
// //                                     strokeWidth: 2,
// //                                   ),
// //                                 ),
// //                               )
// //                             : const Center(
// //                                 child: Text(
// //                                   'Pay',
// //                                   style: TextStyle(
// //                                     color: Colors.white,
// //                                     fontWeight: FontWeight.w700,
// //                                     fontSize: 13,
// //                                   ),
// //                                 ),
// //                               ),
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //
// //                 // ── GST breakdown (shows when amount is typed) ───────────
// //                 if (showPreview) ...[
// //                   const SizedBox(height: 10),
// //                   Container(
// //                     width: double.infinity,
// //                     padding: const EdgeInsets.symmetric(
// //                       horizontal: 12,
// //                       vertical: 8,
// //                     ),
// //                     decoration: BoxDecoration(
// //                       color: const Color(0xFFFFF8F3),
// //                       borderRadius: BorderRadius.circular(8),
// //                       border: Border.all(color: _orangeBorder),
// //                     ),
// //                     child: Column(
// //                       children: [
// //                         // Row: base amount
// //                         _gstRow(
// //                           label: 'Base Amount',
// //                           value: '₹${base.toStringAsFixed(2)}',
// //                           bold: false,
// //                           color: fnText1,
// //                         ),
// //                         const SizedBox(height: 4),
// //                         // Row: GST 18%
// //                         _gstRow(
// //                           label: 'GST (18%)',
// //                           value: '+ ₹${gst.toStringAsFixed(2)}',
// //                           bold: false,
// //                           color: Colors.red.shade400,
// //                         ),
// //                         Padding(
// //                           padding: const EdgeInsets.symmetric(vertical: 5),
// //                           child: Divider(
// //                             height: 1,
// //                             color: _orangeBorder,
// //                             thickness: 1,
// //                           ),
// //                         ),
// //                         // Row: total
// //                         _gstRow(
// //                           label: 'Total Payable',
// //                           value: '₹${total.toStringAsFixed(2)}',
// //                           bold: true,
// //                           color: _orange,
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                 ],
// //               ],
// //             ),
// //           ),
// //
// //           const SizedBox(height: 12),
// //
// //           // ── Usage bar ────────────────────────────────────────────────
// //           ClipRRect(
// //             borderRadius: BorderRadius.circular(8),
// //             child: LinearProgressIndicator(
// //               value: s.usagePercent,
// //               backgroundColor: Colors.white.withOpacity(0.6),
// //               color: _orange,
// //               minHeight: 10,
// //             ),
// //           ),
// //           const SizedBox(height: 6),
// //           Row(
// //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //             children: [
// //               Text(
// //                 '${(s.usagePercent * 100).toStringAsFixed(0)}% used',
// //                 style: const TextStyle(
// //                   fontSize: 10,
// //                   color: _orange,
// //                   fontWeight: FontWeight.w600,
// //                 ),
// //               ),
// //               Text(
// //                 '${_fmtCur(s.availableCreditPoints)} available',
// //                 style: const TextStyle(fontSize: 10, color: fnText2),
// //               ),
// //             ],
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   // ── GST breakdown row helper ───────────────────────────────────────────────
// //   Widget _gstRow({
// //     required String label,
// //     required String value,
// //     required bool bold,
// //     required Color color,
// //   }) {
// //     final style = TextStyle(
// //       fontSize: 11,
// //       fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
// //       color: color,
// //     );
// //     return Row(
// //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //       children: [
// //         Text(label, style: style),
// //         Text(value, style: style),
// //       ],
// //     );
// //   }
// //
// //   // ── Credit stat box ────────────────────────────────────────────────────────
// //   Widget _creditBox(String label, String value, Color color) => Expanded(
// //     child: Container(
// //       padding: const EdgeInsets.all(10),
// //       decoration: BoxDecoration(
// //         color: Colors.white.withOpacity(0.7),
// //         borderRadius: BorderRadius.circular(10),
// //       ),
// //       child: Column(
// //         children: [
// //           Text(
// //             label,
// //             style: const TextStyle(fontSize: 10, color: fnText2),
// //             textAlign: TextAlign.center,
// //           ),
// //           const SizedBox(height: 4),
// //           Text(
// //             value,
// //             style: TextStyle(
// //               fontSize: 14,
// //               fontWeight: FontWeight.w800,
// //               color: color,
// //             ),
// //             textAlign: TextAlign.center,
// //           ),
// //         ],
// //       ),
// //     ),
// //   );
// //
// //   // ── Alert banner ───────────────────────────────────────────────────────────
// //   Widget _buildAlert() {
// //     final s = _stats!;
// //     final msg = s.status == 'payment_required'
// //         ? 'Pay ${_fmtCur(s.usedCreditPoints)} to enable all payment modes'
// //         : 'Credit limit reached soon – recharge recommended';
// //     return Container(
// //       padding: const EdgeInsets.all(12),
// //       decoration: BoxDecoration(
// //         color: fnAmberL,
// //         borderRadius: BorderRadius.circular(12),
// //         border: Border.all(color: fnAmber.withOpacity(0.4)),
// //       ),
// //       child: Row(
// //         children: [
// //           const Icon(Icons.warning_amber_rounded, color: fnAmber, size: 18),
// //           const SizedBox(width: 10),
// //           Expanded(
// //             child: Text(
// //               msg,
// //               style: const TextStyle(
// //                 fontSize: 12,
// //                 color: fnText1,
// //                 fontWeight: FontWeight.w500,
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   // ── History section ────────────────────────────────────────────────────────
// //   Widget _buildHistorySection() {
// //     if (_loading && _transactions.isEmpty) {
// //       return const Center(
// //         child: Padding(
// //           padding: EdgeInsets.symmetric(vertical: 32),
// //           child: CircularProgressIndicator(color: fnAccent),
// //         ),
// //       );
// //     }
// //
// //     final list = _filtered;
// //
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         // ── Section header ─────────────────────────────────────────────
// //         Row(
// //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //           children: [
// //             const Text(
// //               'Credit History',
// //               style: TextStyle(
// //                 fontSize: 14,
// //                 fontWeight: FontWeight.w700,
// //                 color: fnText1,
// //               ),
// //             ),
// //             if (list.isNotEmpty)
// //               Container(
// //                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
// //                 decoration: BoxDecoration(
// //                   color: const Color(0xFFFFF0E8),
// //                   borderRadius: BorderRadius.circular(20),
// //                 ),
// //                 child: Text(
// //                   '${list.length} record${list.length == 1 ? '' : 's'}',
// //                   style: const TextStyle(
// //                     fontSize: 10,
// //                     color: _orange,
// //                     fontWeight: FontWeight.w600,
// //                   ),
// //                 ),
// //               ),
// //           ],
// //         ),
// //         const SizedBox(height: 10),
// //
// //         // ── Cards or empty ─────────────────────────────────────────────
// //         if (list.isNotEmpty)
// //           Column(children: list.map(_buildTxCard).toList())
// //         else
// //           Center(
// //             child: Padding(
// //               padding: const EdgeInsets.symmetric(vertical: 32),
// //               child: Column(
// //                 children: [
// //                   Icon(Icons.receipt_long_outlined, size: 44, color: fnText3),
// //                   const SizedBox(height: 8),
// //                   Text(
// //                     _search.isNotEmpty
// //                         ? 'No records match your search.'
// //                         : 'No credit history for $_period.',
// //                     style: const TextStyle(fontSize: 13, color: fnText2),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ),
// //       ],
// //     );
// //   }
// //
// //   // ── Transaction card ───────────────────────────────────────────────────────
// //   Widget _buildTxCard(_CreditTransaction t) {
// //     return Container(
// //       margin: const EdgeInsets.only(bottom: 8),
// //       decoration: fnCardDeco(),
// //       child: Padding(
// //         padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
// //         child: Row(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             // ── Left icon ──────────────────────────────────────────────
// //             Container(
// //               width: 42,
// //               height: 42,
// //               decoration: BoxDecoration(
// //                 color: fnGreenL,
// //                 borderRadius: BorderRadius.circular(12),
// //               ),
// //               child: const Icon(
// //                 Icons.account_balance_wallet_rounded,
// //                 color: fnGreen,
// //                 size: 20,
// //               ),
// //             ),
// //             const SizedBox(width: 12),
// //
// //             // ── Middle: date, description, tx-id ──────────────────────
// //             Expanded(
// //               child: Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   // Date
// //                   Text(
// //                     _fmtDate(t.transactionDate),
// //                     style: const TextStyle(
// //                       fontSize: 12,
// //                       fontWeight: FontWeight.w700,
// //                       color: fnText1,
// //                     ),
// //                   ),
// //                   const SizedBox(height: 3),
// //                   // Description
// //                   Text(
// //                     _cleanDesc(t.description),
// //                     style: const TextStyle(fontSize: 11, color: fnText2),
// //                   ),
// //                   const SizedBox(height: 5),
// //                   // Transaction ID chip
// //                   Container(
// //                     padding: const EdgeInsets.symmetric(
// //                       horizontal: 6,
// //                       vertical: 2,
// //                     ),
// //                     decoration: BoxDecoration(
// //                       color: fnBlueL,
// //                       borderRadius: BorderRadius.circular(5),
// //                     ),
// //                     child: Text(
// //                       t.transactionId,
// //                       style: const TextStyle(
// //                         fontSize: 9,
// //                         color: fnBlue,
// //                         fontWeight: FontWeight.w600,
// //                         letterSpacing: 0.2,
// //                       ),
// //                       overflow: TextOverflow.ellipsis,
// //                       maxLines: 1,
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //             const SizedBox(width: 10),
// //
// //             // ── Right: amount ──────────────────────────────────────────
// //             Column(
// //               crossAxisAlignment: CrossAxisAlignment.end,
// //               children: [
// //                 Text(
// //                   '+${_fmtCur(t.creditAmount)}',
// //                   style: const TextStyle(
// //                     fontSize: 15,
// //                     fontWeight: FontWeight.w800,
// //                     color: fnGreen,
// //                   ),
// //                 ),
// //                 const SizedBox(height: 4),
// //                 Container(
// //                   padding: const EdgeInsets.symmetric(
// //                     horizontal: 6,
// //                     vertical: 2,
// //                   ),
// //                   decoration: BoxDecoration(
// //                     color: fnGreenL,
// //                     borderRadius: BorderRadius.circular(5),
// //                   ),
// //                   child: Text(
// //                     t.transactionType,
// //                     style: const TextStyle(
// //                       fontSize: 9,
// //                       color: fnGreen,
// //                       fontWeight: FontWeight.w700,
// //                     ),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }
//
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:razorpay_flutter/razorpay_flutter.dart';
// import '../models/finance_models.dart';
// import '../services/finance_service.dart';
// import '../widgets/theme.dart';
// import 'FnSearchBarScreen.dart';
//
// // ── Data model ────────────────────────────────────────────────────────────────
// class _CreditTransaction {
//   final int id;
//   final int vendorId;
//   final double creditAmount;
//   final String transactionType;
//   final String description;
//   final String transactionId;
//   final String transactionDate;
//
//   const _CreditTransaction({
//     required this.id,
//     required this.vendorId,
//     required this.creditAmount,
//     required this.transactionType,
//     required this.description,
//     required this.transactionId,
//     required this.transactionDate,
//   });
//
//   factory _CreditTransaction.fromJson(Map<String, dynamic> j) =>
//       _CreditTransaction(
//         id: (j['id'] ?? 0) as int,
//         vendorId: (j['vendorId'] ?? 0) as int,
//         creditAmount: (j['creditAmount'] ?? 0).toDouble(),
//         transactionType: j['transactionType']?.toString() ?? '',
//         description: j['description']?.toString() ?? '',
//         transactionId: j['transactionId']?.toString() ?? '',
//         transactionDate: j['transactionDate']?.toString() ?? '',
//       );
// }
//
// // ── Widget ────────────────────────────────────────────────────────────────────
// class CreditsTab extends StatefulWidget {
//   const CreditsTab({super.key});
//
//   @override
//   State<CreditsTab> createState() => _CreditsTabState();
// }
//
// class _CreditsTabState extends State<CreditsTab> {
//   // ── State ──────────────────────────────────────────────────────────────────
//   CreditStats? _stats;
//   List<_CreditTransaction> _transactions = [];
//   bool _loading = false;
//   bool _paying = false;
//   String? _error;
//
//   final _amountCtrl = TextEditingController();
//   late final Razorpay _razorpay;
//
//   String _search = '';
//   String _period = 'This Month';
//   DateTimeRange? _custom;
//
//   // ── Constants ──────────────────────────────────────────────────────────────
//   static const double _gstRate = 0.18; // 18% GST — hardcoded
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
//   static const Color _orange = Color(0xFFE66D33);
//   static const Color _orangeLight = Color(0xFFF7F8FC);
//   static const Color _orangeBorder = Color(0xFFFFF0E8);
//
//   // ── Lifecycle ──────────────────────────────────────────────────────────────
//   @override
//   void initState() {
//     super.initState();
//     _razorpay = Razorpay();
//     _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onPaySuccess);
//     _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _onPayError);
//     _razorpay.on(
//       Razorpay.EVENT_EXTERNAL_WALLET,
//       (_) => setState(() => _paying = false),
//     );
//     _load();
//   }
//
//   @override
//   void dispose() {
//     _razorpay.clear();
//     _amountCtrl.dispose();
//     super.dispose();
//   }
//
//   // ── Data loading ───────────────────────────────────────────────────────────
//   Future<void> _load() async {
//     setState(() {
//       _loading = true;
//       _error = null;
//     });
//     try {
//       final results = await Future.wait([
//         FinanceService.fetchCreditStats(),
//         FinanceService.fetchCreditTransactions(),
//       ]);
//
//       final stats = results[0] as CreditStats?;
//       final rawList = results[1] as List<dynamic>;
//
//       final txList = rawList
//           .whereType<Map<String, dynamic>>()
//           .map(_CreditTransaction.fromJson)
//           .toList();
//
//       // newest first
//       txList.sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
//
//       if (mounted) {
//         setState(() {
//           _stats = stats;
//           _transactions = txList;
//           _loading = false;
//         });
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _error = e.toString();
//           _loading = false;
//         });
//       }
//     }
//   }
//
//   // ── GST helpers ────────────────────────────────────────────────────────────
//   double get _enteredAmount => double.tryParse(_amountCtrl.text.trim()) ?? 0;
//   double get _gstAmount =>
//       double.parse((_enteredAmount * _gstRate).toStringAsFixed(2));
//   double get _totalWithGst =>
//       double.parse((_enteredAmount + _gstAmount).toStringAsFixed(2));
//
//   // ── Payment ────────────────────────────────────────────────────────────────
//   Future<void> _startPayment() async {
//     if (_enteredAmount <= 0) {
//       fnSnack(context, 'Enter a valid amount', error: true);
//       return;
//     }
//     setState(() => _paying = true);
//     try {
//       final orderId = await FinanceService.createRazorpayOrder(_totalWithGst);
//       if (orderId == null) throw Exception('Order ID not received');
//
//       _razorpay.open({
//         'key': 'rzp_test_TJECsclCivENpY',
//         'amount': (_totalWithGst * 100).toInt(),
//         'currency': 'INR',
//         'order_id': orderId,
//         'name': 'MAAMAAS',
//         'description': 'Add Credits to Wallet',
//         'prefill': {'contact': '', 'email': ''},
//         'theme': {'color': '#E66D33'},
//       });
//     } catch (e) {
//       setState(() => _paying = false);
//       if (mounted) fnSnack(context, 'Payment failed: $e', error: true);
//     }
//   }
//
//   void _onPaySuccess(PaymentSuccessResponse r) async {
//     // Snapshot before clearing
//     final base = _enteredAmount;
//     final gst = _gstAmount;
//     final total = _totalWithGst;
//     try {
//       await FinanceService.captureRazorpayPayment(r.paymentId!, total);
//       await FinanceService.payCredits(
//         amount: total,
//         transactionId: r.paymentId!,
//       );
//       _amountCtrl.clear();
//       if (mounted) {
//         fnSnack(
//           context,
//           '✅ ₹${base.toInt()} + ₹${gst.toStringAsFixed(0)} GST credited successfully',
//         );
//         _load();
//       }
//     } catch (e) {
//       if (mounted) {
//         fnSnack(
//           context,
//           'Payment succeeded but update failed: $e',
//           error: true,
//         );
//       }
//     } finally {
//       if (mounted) setState(() => _paying = false);
//     }
//   }
//
//   void _onPayError(PaymentFailureResponse r) {
//     if (mounted) {
//       setState(() => _paying = false);
//       fnSnack(
//         context,
//         'Payment failed: ${r.message ?? 'Unknown error'}',
//         error: true,
//       );
//     }
//   }
//
//   // ── Filtering ──────────────────────────────────────────────────────────────
//   List<_CreditTransaction> get _filtered {
//     final range = _dateRange;
//     List<_CreditTransaction> result = _transactions;
//
//     if (range != null) {
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
//       result = result.where((t) {
//         try {
//           final d = DateTime.parse(t.transactionDate).toLocal();
//           return !d.isBefore(from) && !d.isAfter(to);
//         } catch (_) {
//           return false;
//         }
//       }).toList();
//     }
//
//     if (_search.isNotEmpty) {
//       final q = _search.toLowerCase();
//       result = result
//           .where(
//             (t) =>
//                 t.transactionId.toLowerCase().contains(q) ||
//                 t.description.toLowerCase().contains(q) ||
//                 t.transactionDate.contains(q) ||
//                 t.creditAmount.toString().contains(q) ||
//                 t.id.toString().contains(q),
//           )
//           .toList();
//     }
//
//     return result;
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
//         final mon = today.subtract(Duration(days: today.weekday - 1));
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
//   // ── Formatters ─────────────────────────────────────────────────────────────
//   String _fmtCur(double v) =>
//       '₹${NumberFormat('#,##,###').format(v.abs().round())}';
//
//   String _fmtDate(String raw) {
//     try {
//       final utc = DateTime.parse(raw);
//       final ist = utc.add(const Duration(hours: 5, minutes: 30));
//
//       return DateFormat('dd MMM yyyy, hh:mm a').format(ist);
//     } catch (_) {
//       return raw;
//     }
//   }
//
//   String _cleanDesc(String s) => s.replaceAll('â‚¹', '₹');
//
//   @override
//   Widget build(BuildContext context) {
//     return RefreshIndicator(
//       color: fnAccent,
//       onRefresh: _load,
//       child: SingleChildScrollView(
//         physics: const AlwaysScrollableScrollPhysics(),
//         padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // ── Search + period filter ───────────────────────────────────
//             _buildSearchRow(),
//             const SizedBox(height: 10),
//
//             // ── Credit summary + Add credits card ────────────────────────
//             if (_loading && _stats == null)
//               const Center(
//                 child: Padding(
//                   padding: EdgeInsets.all(40),
//                   child: CircularProgressIndicator(color: fnAccent),
//                 ),
//               )
//             else if (_stats != null)
//               _buildCreditSummaryCard(),
//
//             // ── Alert ────────────────────────────────────────────────────
//             if (_stats != null && _stats!.status != 'active') ...[
//               const SizedBox(height: 12),
//               _buildAlert(),
//             ],
//
//             const SizedBox(height: 20),
//
//             // ── Transaction history ──────────────────────────────────────
//             _buildHistorySection(),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // ── Search row ─────────────────────────────────────────────────────────────
//   Widget _buildSearchRow() {
//     return Row(
//       children: [
//         Expanded(
//           child: FnSearchBar(
//             hint: 'Search credit history...',
//             value: _search,
//             onChanged: (v) => setState(() => _search = v),
//           ),
//         ),
//         const SizedBox(width: 8),
//         Container(
//           height: 44,
//           padding: const EdgeInsets.symmetric(horizontal: 8),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(10),
//             border: Border.all(color: fnBorder),
//           ),
//           child: DropdownButtonHideUnderline(
//             child: DropdownButton<String>(
//               value: _period,
//               icon: const Icon(Icons.keyboard_arrow_down_rounded),
//               style: const TextStyle(fontSize: 12, color: fnText1),
//               onChanged: (v) async {
//                 if (v == null) return;
//                 if (v == 'Custom Range') {
//                   final range = await showDateRangePicker(
//                     context: context,
//                     firstDate: DateTime(2023),
//                     lastDate: DateTime.now(),
//                   );
//                   if (range != null) {
//                     setState(() {
//                       _period = v;
//                       _custom = range;
//                     });
//                   }
//                 } else {
//                   setState(() => _period = v);
//                 }
//               },
//               items: _periods
//                   .map((e) => DropdownMenuItem(value: e, child: Text(e)))
//                   .toList(),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   // ── Credit summary card ────────────────────────────────────────────────────
//   Widget _buildCreditSummaryCard() {
//     final s = _stats!;
//     final base = _enteredAmount;
//     final gst = _gstAmount;
//     final total = _totalWithGst;
//     final showPreview = base > 0;
//
//     return Container(
//       decoration: BoxDecoration(
//         color: _orangeLight,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: _orangeBorder),
//       ),
//       padding: const EdgeInsets.all(14),
//       child: Column(
//         children: [
//           // ── 3 stat boxes ────────────────────────────────────────────
//           Row(
//             children: [
//               _creditBox('Credit Limit', _fmtCur(s.totalCreditPoints), fnText1),
//               const SizedBox(width: 8),
//               _creditBox(
//                 'Used Credit',
//                 _fmtCur(s.usedCreditPoints),
//                 Colors.red,
//               ),
//               const SizedBox(width: 8),
//               _creditBox(
//                 'Remaining',
//                 _fmtCur(s.availableCreditPoints),
//                 Colors.green,
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//
//           // ── Add credits panel ────────────────────────────────────────
//           Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(color: _orangeBorder),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Label
//                 const Text(
//                   'Add Credits',
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: fnText2,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//
//                 // ₹ input + Pay button
//                 Row(
//                   children: [
//                     // ₹ prefix
//                     Container(
//                       width: 36,
//                       height: 40,
//                       decoration: BoxDecoration(
//                         color: _orangeLight,
//                         borderRadius: const BorderRadius.only(
//                           topLeft: Radius.circular(8),
//                           bottomLeft: Radius.circular(8),
//                         ),
//                         border: Border.all(color: _orangeBorder),
//                       ),
//                       child: const Center(
//                         child: Text(
//                           '₹',
//                           style: TextStyle(
//                             fontSize: 15,
//                             fontWeight: FontWeight.w700,
//                             color: fnText2,
//                           ),
//                         ),
//                       ),
//                     ),
//                     // Amount field
//                     Expanded(
//                       child: Container(
//                         height: 40,
//                         decoration: BoxDecoration(
//                           border: Border(
//                             top: BorderSide(color: _orangeBorder),
//                             bottom: BorderSide(color: _orangeBorder),
//                           ),
//                         ),
//                         child: TextField(
//                           controller: _amountCtrl,
//                           keyboardType: TextInputType.number,
//                           onChanged: (_) => setState(() {}),
//                           decoration: const InputDecoration(
//                             hintText: 'Enter amount',
//                             hintStyle: TextStyle(color: fnText3, fontSize: 13),
//                             border: InputBorder.none,
//                             contentPadding: EdgeInsets.symmetric(
//                               horizontal: 10,
//                             ),
//                           ),
//                           style: const TextStyle(fontSize: 13, color: fnText1),
//                         ),
//                       ),
//                     ),
//                     // Pay button
//                     GestureDetector(
//                       onTap: _paying ? null : _startPayment,
//                       child: AnimatedContainer(
//                         duration: const Duration(milliseconds: 180),
//                         height: 40,
//                         width: 70,
//                         decoration: BoxDecoration(
//                           color: _paying ? Colors.grey.shade400 : _orange,
//                           borderRadius: const BorderRadius.only(
//                             topRight: Radius.circular(8),
//                             bottomRight: Radius.circular(8),
//                           ),
//                         ),
//                         child: _paying
//                             ? const Center(
//                                 child: SizedBox(
//                                   width: 16,
//                                   height: 16,
//                                   child: CircularProgressIndicator(
//                                     color: Colors.white,
//                                     strokeWidth: 2,
//                                   ),
//                                 ),
//                               )
//                             : const Center(
//                                 child: Text(
//                                   'Pay',
//                                   style: TextStyle(
//                                     color: Colors.white,
//                                     fontWeight: FontWeight.w700,
//                                     fontSize: 13,
//                                   ),
//                                 ),
//                               ),
//                       ),
//                     ),
//                   ],
//                 ),
//
//                 // ── GST breakdown (shows when amount is typed) ───────────
//                 if (showPreview) ...[
//                   const SizedBox(height: 10),
//                   Container(
//                     width: double.infinity,
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 12,
//                       vertical: 8,
//                     ),
//                     decoration: BoxDecoration(
//                       color: const Color(0xFFFFF8F3),
//                       borderRadius: BorderRadius.circular(8),
//                       border: Border.all(color: _orangeBorder),
//                     ),
//                     child: Column(
//                       children: [
//                         // Row: base amount
//                         _gstRow(
//                           label: 'Base Amount',
//                           value: '₹${base.toStringAsFixed(2)}',
//                           bold: false,
//                           color: fnText1,
//                         ),
//                         const SizedBox(height: 4),
//                         // Row: GST 18%
//                         _gstRow(
//                           label: 'GST (18%)',
//                           value: '+ ₹${gst.toStringAsFixed(2)}',
//                           bold: false,
//                           color: Colors.red.shade400,
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.symmetric(vertical: 5),
//                           child: Divider(
//                             height: 1,
//                             color: _orangeBorder,
//                             thickness: 1,
//                           ),
//                         ),
//                         // Row: total
//                         _gstRow(
//                           label: 'Total Payable',
//                           value: '₹${total.toStringAsFixed(2)}',
//                           bold: true,
//                           color: _orange,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ],
//             ),
//           ),
//
//           const SizedBox(height: 12),
//
//           // ── Usage bar ────────────────────────────────────────────────
//           ClipRRect(
//             borderRadius: BorderRadius.circular(8),
//             child: LinearProgressIndicator(
//               value: s.usagePercent,
//               backgroundColor: Colors.white.withOpacity(0.6),
//               color: _orange,
//               minHeight: 10,
//             ),
//           ),
//           const SizedBox(height: 6),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 '${(s.usagePercent * 100).toStringAsFixed(0)}% used',
//                 style: const TextStyle(
//                   fontSize: 10,
//                   color: _orange,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               Text(
//                 '${_fmtCur(s.availableCreditPoints)} available',
//                 style: const TextStyle(fontSize: 10, color: fnText2),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ── GST breakdown row helper ───────────────────────────────────────────────
//   Widget _gstRow({
//     required String label,
//     required String value,
//     required bool bold,
//     required Color color,
//   }) {
//     final style = TextStyle(
//       fontSize: 11,
//       fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
//       color: color,
//     );
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(label, style: style),
//         Text(value, style: style),
//       ],
//     );
//   }
//
//   // ── Credit stat box ────────────────────────────────────────────────────────
//   Widget _creditBox(String label, String value, Color color) => Expanded(
//     child: Container(
//       padding: const EdgeInsets.all(10),
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.7),
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: Column(
//         children: [
//           Text(
//             label,
//             style: const TextStyle(fontSize: 10, color: fnText2),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 4),
//           Text(
//             value,
//             style: TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.w800,
//               color: color,
//             ),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     ),
//   );
//
//   // ── Alert banner ───────────────────────────────────────────────────────────
//   Widget _buildAlert() {
//     final s = _stats!;
//     final msg = s.status == 'payment_required'
//         ? 'Pay ${_fmtCur(s.usedCreditPoints)} to enable all payment modes'
//         : 'Credit limit reached soon – recharge recommended';
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: fnAmberL,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: fnAmber.withOpacity(0.4)),
//       ),
//       child: Row(
//         children: [
//           const Icon(Icons.warning_amber_rounded, color: fnAmber, size: 18),
//           const SizedBox(width: 10),
//           Expanded(
//             child: Text(
//               msg,
//               style: const TextStyle(
//                 fontSize: 12,
//                 color: fnText1,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ── History section ────────────────────────────────────────────────────────
//   Widget _buildHistorySection() {
//     if (_loading && _transactions.isEmpty) {
//       return const Center(
//         child: Padding(
//           padding: EdgeInsets.symmetric(vertical: 32),
//           child: CircularProgressIndicator(color: fnAccent),
//         ),
//       );
//     }
//
//     final list = _filtered;
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // ── Section header ─────────────────────────────────────────────
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             const Text(
//               'Credit History',
//               style: TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w700,
//                 color: fnText1,
//               ),
//             ),
//             if (list.isNotEmpty)
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFFFF0E8),
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Text(
//                   '${list.length} record${list.length == 1 ? '' : 's'}',
//                   style: const TextStyle(
//                     fontSize: 10,
//                     color: _orange,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//           ],
//         ),
//         const SizedBox(height: 10),
//
//         // ── Cards or empty ─────────────────────────────────────────────
//         if (list.isNotEmpty)
//           Column(children: list.map(_buildTxCard).toList())
//         else
//           Center(
//             child: Padding(
//               padding: const EdgeInsets.symmetric(vertical: 32),
//               child: Column(
//                 children: [
//                   Icon(Icons.receipt_long_outlined, size: 44, color: fnText3),
//                   const SizedBox(height: 8),
//                   Text(
//                     _search.isNotEmpty
//                         ? 'No records match your search.'
//                         : 'No credit history for $_period.',
//                     style: const TextStyle(fontSize: 13, color: fnText2),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//       ],
//     );
//   }
//
//   // ── Transaction card ───────────────────────────────────────────────────────
//   Widget _buildTxCard(_CreditTransaction t) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 8),
//       decoration: fnCardDeco(),
//       child: Padding(
//         padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // ── Left icon ──────────────────────────────────────────────
//             Container(
//               width: 42,
//               height: 42,
//               decoration: BoxDecoration(
//                 color: fnGreenL,
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: const Icon(
//                 Icons.account_balance_wallet_rounded,
//                 color: fnGreen,
//                 size: 20,
//               ),
//             ),
//             const SizedBox(width: 12),
//
//             // ── Middle: date, description, tx-id ──────────────────────
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Date
//                   Text(
//                     _fmtDate(t.transactionDate),
//                     style: const TextStyle(
//                       fontSize: 12,
//                       fontWeight: FontWeight.w700,
//                       color: fnText1,
//                     ),
//                   ),
//                   const SizedBox(height: 3),
//                   // Description
//                   Text(
//                     _cleanDesc(t.description),
//                     style: const TextStyle(fontSize: 11, color: fnText2),
//                   ),
//                   const SizedBox(height: 5),
//                   // Transaction ID chip
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 6,
//                       vertical: 2,
//                     ),
//                     decoration: BoxDecoration(
//                       color: fnBlueL,
//                       borderRadius: BorderRadius.circular(5),
//                     ),
//                     child: Text(
//                       t.transactionId,
//                       style: const TextStyle(
//                         fontSize: 9,
//                         color: fnBlue,
//                         fontWeight: FontWeight.w600,
//                         letterSpacing: 0.2,
//                       ),
//                       overflow: TextOverflow.ellipsis,
//                       maxLines: 1,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(width: 10),
//
//             // ── Right: amount ──────────────────────────────────────────
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.end,
//               children: [
//                 Text(
//                   '+${_fmtCur(t.creditAmount)}',
//                   style: const TextStyle(
//                     fontSize: 15,
//                     fontWeight: FontWeight.w800,
//                     color: fnGreen,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 6,
//                     vertical: 2,
//                   ),
//                   decoration: BoxDecoration(
//                     color: fnGreenL,
//                     borderRadius: BorderRadius.circular(5),
//                   ),
//                   child: Text(
//                     t.transactionType,
//                     style: const TextStyle(
//                       fontSize: 9,
//                       color: fnGreen,
//                       fontWeight: FontWeight.w700,
//                     ),
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

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../models/finance_models.dart';
import '../services/finance_service.dart';
import '../widgets/theme.dart';
import 'FnSearchBarScreen.dart';

// ── Data model ────────────────────────────────────────────────────────────────
class _CreditTransaction {
  final int id;
  final int vendorId;
  final double creditAmount;
  final String transactionType;
  final String description;
  final String transactionId;
  final String transactionDate;

  const _CreditTransaction({
    required this.id,
    required this.vendorId,
    required this.creditAmount,
    required this.transactionType,
    required this.description,
    required this.transactionId,
    required this.transactionDate,
  });

  factory _CreditTransaction.fromJson(Map<String, dynamic> j) =>
      _CreditTransaction(
        id: (j['id'] ?? 0) as int,
        vendorId: (j['vendorId'] ?? 0) as int,
        creditAmount: (j['creditAmount'] ?? 0).toDouble(),
        transactionType: j['transactionType']?.toString() ?? '',
        description: j['description']?.toString() ?? '',
        transactionId: j['transactionId']?.toString() ?? '',
        transactionDate: j['transactionDate']?.toString() ?? '',
      );
}

// ── Widget ────────────────────────────────────────────────────────────────────
class CreditsTab extends StatefulWidget {
  const CreditsTab({super.key});

  @override
  State<CreditsTab> createState() => _CreditsTabState();
}

class _CreditsTabState extends State<CreditsTab> {
  // ── State ──────────────────────────────────────────────────────────────────
  CreditStats? _stats;
  List<_CreditTransaction> _transactions = [];
  bool _loading = false;
  bool _paying = false;
  String? _error;

  final _amountCtrl = TextEditingController();
  late final Razorpay _razorpay;

  String _search = '';
  String _period = 'This Month';
  DateTimeRange? _custom;

  // ── Constants ──────────────────────────────────────────────────────────────
  static const double _gstRate = 0.18;

  static const _periods = [
    'Today',
    'Yesterday',
    'This Week',
    'This Month',
    'Last Month',
    'This Year',
    'Custom Range',
  ];

  static const Color _orange = Color(0xFFE66D33);
  static const Color _orangeLight = Color(0xFFF7F8FC);
  static const Color _orangeBorder = Color(0xFFFFF0E8);

  // ── Lifecycle ──────────────────────────────────────────────────────────────
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
    _load();
  }

  @override
  void dispose() {
    _razorpay.clear();
    _amountCtrl.dispose();
    super.dispose();
  }

  // ── Data loading ───────────────────────────────────────────────────────────
  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        FinanceService.fetchCreditStats(),
        FinanceService.fetchCreditTransactions(),
      ]);

      final stats = results[0] as CreditStats?;
      final rawList = results[1] as List<dynamic>;

      final txList = rawList
          .whereType<Map<String, dynamic>>()
          .map(_CreditTransaction.fromJson)
          .toList();

      // newest first
      txList.sort((a, b) => b.transactionDate.compareTo(a.transactionDate));

      if (mounted) {
        setState(() {
          _stats = stats;
          _transactions = txList;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  // ── GST helpers ────────────────────────────────────────────────────────────
  double get _enteredAmount => double.tryParse(_amountCtrl.text.trim()) ?? 0;
  double get _gstAmount =>
      double.parse((_enteredAmount * _gstRate).toStringAsFixed(2));
  double get _totalWithGst =>
      double.parse((_enteredAmount + _gstAmount).toStringAsFixed(2));

  // ── Payment ────────────────────────────────────────────────────────────────
  Future<void> _startPayment() async {
    if (_enteredAmount <= 0) {
      fnSnack(context, 'Enter a valid amount', error: true);
      return;
    }
    setState(() => _paying = true);
    try {
      final orderId = await FinanceService.createRazorpayOrder(_totalWithGst);
      if (orderId == null) throw Exception('Order ID not received');

      _razorpay.open({
        'key': 'rzp_test_TJECsclCivENpY',
        'amount': (_totalWithGst * 100).toInt(),
        'currency': 'INR',
        'order_id': orderId,
        'name': 'MAAMAAS',
        'description': 'Add Credits to Wallet',
        'prefill': {'contact': '', 'email': ''},
        'theme': {'color': '#E66D33'},
      });
    } catch (e) {
      setState(() => _paying = false);
      if (mounted) fnSnack(context, 'Payment failed: $e', error: true);
    }
  }

  void _onPaySuccess(PaymentSuccessResponse r) async {
    final base = _enteredAmount;
    final gst = _gstAmount;
    final total = _totalWithGst;
    try {
      await FinanceService.captureRazorpayPayment(r.paymentId!, total);
      await FinanceService.payCredits(
        amount: base,
        transactionId: r.paymentId!,
      );
      _amountCtrl.clear();
      if (mounted) {
        fnSnack(
          context,
          '✅ ₹${base.toInt()} + ₹${gst.toStringAsFixed(0)} GST credited successfully',
        );
        _load();
      }
    } catch (e) {
      if (mounted) {
        fnSnack(
          context,
          'Payment succeeded but update failed: $e',
          error: true,
        );
      }
    } finally {
      if (mounted) setState(() => _paying = false);
    }
  }

  void _onPayError(PaymentFailureResponse r) {
    if (mounted) {
      setState(() => _paying = false);
      fnSnack(
        context,
        'Payment failed: ${r.message ?? 'Unknown error'}',
        error: true,
      );
    }
  }

  // ── Filtering ──────────────────────────────────────────────────────────────
  List<_CreditTransaction> get _filtered {
    final range = _dateRange;
    List<_CreditTransaction> result = _transactions;

    if (range != null) {
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
      result = result.where((t) {
        try {
          final d = DateTime.parse(t.transactionDate);
          return !d.isBefore(from) && !d.isAfter(to);
        } catch (_) {
          return false;
        }
      }).toList();
    }

    if (_search.isNotEmpty) {
      final q = _search.toLowerCase();
      result = result
          .where(
            (t) =>
                t.transactionId.toLowerCase().contains(q) ||
                t.description.toLowerCase().contains(q) ||
                t.transactionDate.contains(q) ||
                t.creditAmount.toString().contains(q) ||
                t.id.toString().contains(q),
          )
          .toList();
    }

    return result;
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
        final mon = today.subtract(Duration(days: today.weekday - 1));
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

  // ── Formatters ─────────────────────────────────────────────────────────────
  String _fmtCur(double v) =>
      '₹${NumberFormat('#,##,###').format(v.abs().round())}';

  String _fmtDate(String raw) {
    try {
      final utc = DateTime.parse(raw);
      final ist = utc.add(const Duration(hours: 5, minutes: 30));

      return DateFormat('dd MMM yyyy, hh:mm a').format(ist);
    } catch (_) {
      return raw;
    }
  }

  String _cleanDesc(String s) => s.replaceAll('â‚¹', '₹');

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: fnAccent,
      onRefresh: _load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchRow(),
            const SizedBox(height: 10),

            if (_loading && _stats == null)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(color: fnAccent),
                ),
              )
            else if (_stats != null)
              _buildCreditSummaryCard(),

            if (_stats != null && _stats!.status != 'active') ...[
              const SizedBox(height: 12),
              _buildAlert(),
            ],

            const SizedBox(height: 20),

            _buildHistorySection(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchRow() {
    return Row(
      children: [
        Expanded(
          child: FnSearchBar(
            hint: 'Search credit history...',
            value: _search,
            onChanged: (v) => setState(() => _search = v),
          ),
        ),
        const SizedBox(width: 8),
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
    );
  }

  Widget _buildCreditSummaryCard() {
    final s = _stats!;
    final base = _enteredAmount;
    final gst = _gstAmount;
    final total = _totalWithGst;
    final showPreview = base > 0;

    return Container(
      decoration: BoxDecoration(
        color: _orangeLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _orangeBorder),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          // ── 3 stat boxes ────────────────────────────────────────────
          Row(
            children: [
              _creditBox('Credit Limit', _fmtCur(s.totalCreditPoints), fnText1),
              const SizedBox(width: 8),
              _creditBox(
                'Used Credit',
                _fmtCur(s.usedCreditPoints),
                Colors.red,
              ),
              const SizedBox(width: 8),
              _creditBox(
                'Remaining',
                _fmtCur(s.availableCreditPoints),
                Colors.green,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Add credits panel ────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _orangeBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Label
                const Text(
                  'Add Credits',
                  style: TextStyle(
                    fontSize: 12,
                    color: fnText2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),

                // ₹ input + Pay button
                Row(
                  children: [
                    // ₹ prefix
                    Container(
                      width: 36,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _orangeLight,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          bottomLeft: Radius.circular(8),
                        ),
                        border: Border.all(color: _orangeBorder),
                      ),
                      child: const Center(
                        child: Text(
                          '₹',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: fnText2,
                          ),
                        ),
                      ),
                    ),
                    // Amount field
                    Expanded(
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(color: _orangeBorder),
                            bottom: BorderSide(color: _orangeBorder),
                          ),
                        ),
                        child: TextField(
                          controller: _amountCtrl,
                          keyboardType: TextInputType.number,
                          onChanged: (_) => setState(() {}),
                          decoration: const InputDecoration(
                            hintText: 'Enter amount',
                            hintStyle: TextStyle(color: fnText3, fontSize: 13),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 10,
                            ),
                          ),
                          style: const TextStyle(fontSize: 13, color: fnText1),
                        ),
                      ),
                    ),
                    // Pay button
                    GestureDetector(
                      onTap: _paying ? null : _startPayment,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        height: 40,
                        width: 70,
                        decoration: BoxDecoration(
                          color: _paying ? Colors.grey.shade400 : _orange,
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                          ),
                        ),
                        child: _paying
                            ? const Center(
                                child: SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                ),
                              )
                            : const Center(
                                child: Text(
                                  'Pay',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ],
                ),

                // ── GST breakdown (shows when amount is typed) ───────────
                if (showPreview) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8F3),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _orangeBorder),
                    ),
                    child: Column(
                      children: [
                        // Row: base amount
                        _gstRow(
                          label: 'Base Amount',
                          value: '₹${base.toStringAsFixed(2)}',
                          bold: false,
                          color: fnText1,
                        ),
                        const SizedBox(height: 4),
                        // Row: GST 18%
                        _gstRow(
                          label: 'GST (18%)',
                          value: '+ ₹${gst.toStringAsFixed(2)}',
                          bold: false,
                          color: Colors.red.shade400,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Divider(
                            height: 1,
                            color: _orangeBorder,
                            thickness: 1,
                          ),
                        ),
                        // Row: total
                        _gstRow(
                          label: 'Total Payable',
                          value: '₹${total.toStringAsFixed(2)}',
                          bold: true,
                          color: _orange,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── Usage bar ────────────────────────────────────────────────
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: s.usagePercent,
              backgroundColor: Colors.white.withOpacity(0.6),
              color: _orange,
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(s.usagePercent * 100).toStringAsFixed(0)}% used',
                style: const TextStyle(
                  fontSize: 10,
                  color: _orange,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${_fmtCur(s.availableCreditPoints)} available',
                style: const TextStyle(fontSize: 10, color: fnText2),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── GST breakdown row helper ───────────────────────────────────────────────
  Widget _gstRow({
    required String label,
    required String value,
    required bool bold,
    required Color color,
  }) {
    final style = TextStyle(
      fontSize: 11,
      fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
      color: color,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(value, style: style),
      ],
    );
  }

  // ── Credit stat box ────────────────────────────────────────────────────────
  Widget _creditBox(String label, String value, Color color) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: fnText2),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );

  // ── Alert banner ───────────────────────────────────────────────────────────
  Widget _buildAlert() {
    final s = _stats!;
    final msg = s.status == 'payment_required'
        ? 'Pay ${_fmtCur(s.usedCreditPoints)} to enable all payment modes'
        : 'Credit limit reached soon – recharge recommended';
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: fnAmberL,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: fnAmber.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: fnAmber, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              msg,
              style: const TextStyle(
                fontSize: 12,
                color: fnText1,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── History section ────────────────────────────────────────────────────────
  Widget _buildHistorySection() {
    if (_loading && _transactions.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 32),
          child: CircularProgressIndicator(color: fnAccent),
        ),
      );
    }

    final list = _filtered;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section header ─────────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Credit History',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: fnText1,
              ),
            ),
            if (list.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0E8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${list.length} record${list.length == 1 ? '' : 's'}',
                  style: const TextStyle(
                    fontSize: 10,
                    color: _orange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),

        // ── Cards or empty ─────────────────────────────────────────────
        if (list.isNotEmpty)
          Column(children: list.map(_buildTxCard).toList())
        else
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Column(
                children: [
                  Icon(Icons.receipt_long_outlined, size: 44, color: fnText3),
                  const SizedBox(height: 8),
                  Text(
                    _search.isNotEmpty
                        ? 'No records match your search.'
                        : 'No credit history for $_period.',
                    style: const TextStyle(fontSize: 13, color: fnText2),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // ── Transaction card ───────────────────────────────────────────────────────
  Widget _buildTxCard(_CreditTransaction t) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: fnCardDeco(),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Left icon ──────────────────────────────────────────────
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: fnGreenL,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.account_balance_wallet_rounded,
                color: fnGreen,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),

            // ── Middle: date, description, tx-id ──────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date
                  Text(
                    _fmtDate(t.transactionDate),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: fnText1,
                    ),
                  ),
                  const SizedBox(height: 3),
                  // Description
                  Text(
                    _cleanDesc(t.description),
                    style: const TextStyle(fontSize: 11, color: fnText2),
                  ),
                  const SizedBox(height: 5),
                  // Transaction ID chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: fnBlueL,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      t.transactionId,
                      style: const TextStyle(
                        fontSize: 9,
                        color: fnBlue,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),

            // ── Right: amount ──────────────────────────────────────────
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '+${_fmtCur(t.creditAmount)}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: fnGreen,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: fnGreenL,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    t.transactionType,
                    style: const TextStyle(
                      fontSize: 9,
                      color: fnGreen,
                      fontWeight: FontWeight.w700,
                    ),
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
