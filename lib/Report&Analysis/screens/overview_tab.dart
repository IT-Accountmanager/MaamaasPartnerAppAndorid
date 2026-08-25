// // import 'package:flutter/material.dart';
// // import 'package:intl/intl.dart';
// // import '../models/report_models.dart';
// // import '../widgets/theme.dart';
// //
// // class OverviewTab extends StatelessWidget {
// //   final ReportData? data;
// //   final bool isLoading;
// //   const OverviewTab({super.key, this.data, this.isLoading = false});
// //
// //   String _fmtN(int v) => NumberFormat('#,##,###').format(v);
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     if (isLoading) return _shimmer();
// //     if (data == null)
// //       return const RpEmpty(
// //         message: 'No data. Pull down to refresh or change date range.',
// //         icon: Icons.dashboard_outlined,
// //       );
// //
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         // Period label
// //         if (data!.period.isNotEmpty)
// //           Padding(
// //             padding: const EdgeInsets.only(bottom: 12),
// //             child: Container(
// //               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
// //               decoration: BoxDecoration(
// //                 color: rpAccentL,
// //                 borderRadius: BorderRadius.circular(8),
// //               ),
// //               child: Text(
// //                 data!.period,
// //                 style: const TextStyle(
// //                   color: rpAccent,
// //                   fontSize: 12,
// //                   fontWeight: FontWeight.w600,
// //                 ),
// //               ),
// //             ),
// //           ),
// //
// //         // ── Stats Card (matching the reference UI) ──────────────────────────────
// //         Container(
// //           margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
// //           decoration: _rpCardDecoWithShadow(),
// //           child: Padding(
// //             padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
// //             child: Column(
// //               children: [
// //                 // First row: Revenue Growth & Total Orders
// //                 Row(
// //                   children: [
// //                     Expanded(
// //                       child: _statCell(
// //                         data!.grossRevenue.toStringAsFixed(2),
// //                         'Gross Revenue',
// //                         rpGreen,
// //                         Icons.account_balance_outlined,
// //                       ),
// //                     ),
// //
// //                     _vertDivider(),
// //                     Expanded(
// //                       child: _statCell(
// //                         _fmtN(data!.totalOrders),
// //                         'Total Orders',
// //                         rpBlue,
// //                         Icons.shopping_bag_rounded,
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //
// //                 const SizedBox(height: 12),
// //
// //                 // Second row: Gross Revenue & Avg Order Value
// //                 Row(
// //                   children: [
// //                     Expanded(
// //                       child: _statCell(
// //                         '${data!.revenueGrowthPercent.toStringAsFixed(2)}%',
// //                         'Revenue Growth',
// //                         data!.revenueGrowthPercent >= 0 ? rpGreen : rpRed,
// //                         data!.revenueGrowthPercent >= 0
// //                             ? Icons.trending_up_rounded
// //                             : Icons.trending_down_rounded,
// //                       ),
// //                     ),
// //                     _vertDivider(),
// //                     Expanded(
// //                       child: _statCell(
// //                         data!.avgOrderValue.toStringAsFixed(2),
// //                         'Avg Order Value',
// //                         Colors.orange,
// //                         Icons.trending_up_rounded,
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //
// //                 const SizedBox(height: 12),
// //
// //                 Row(
// //                   children: [
// //                     Expanded(
// //                       child: _statCell(
// //                         _fmtN(data!.dineInOrders),
// //                         'Offline Orders',
// //                         rpAmber,
// //                         Icons.restaurant_rounded,
// //                       ),
// //                     ),
// //                     _vertDivider(),
// //                     Expanded(
// //                       child: _statCell(
// //                         _fmtN(data!.takeawayOrders + data!.deliveryOrders),
// //                         'Online Orders',
// //                         rpRed,
// //                         Icons.shopping_cart_rounded,
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ),
// //         const SizedBox(height: 16),
// //
// //         // ── Avg Rating highlight ───────────────────────────────────────────────
// //         if (data!.averageRating != '0' && data!.averageRating != '0.00') ...[
// //           const RpSectionHeader(title: 'Customer Rating'),
// //           Container(
// //             decoration: rpCardDeco(border: rpAmber.withOpacity(0.4)),
// //             padding: const EdgeInsets.all(14),
// //             child: Row(
// //               children: [
// //                 Container(
// //                   width: 52,
// //                   height: 52,
// //                   decoration: BoxDecoration(
// //                     color: rpAmberL,
// //                     borderRadius: BorderRadius.circular(14),
// //                   ),
// //                   child: const Icon(
// //                     Icons.star_rounded,
// //                     color: rpAmber,
// //                     size: 28,
// //                   ),
// //                 ),
// //                 const SizedBox(width: 14),
// //                 Column(
// //                   crossAxisAlignment: CrossAxisAlignment.start,
// //                   children: [
// //                     Text(
// //                       data!.averageRating,
// //                       style: const TextStyle(
// //                         fontSize: 28,
// //                         fontWeight: FontWeight.w900,
// //                         color: rpAmber,
// //                       ),
// //                     ),
// //                     Text(
// //                       '${data!.totalRatings} total ratings',
// //                       style: const TextStyle(color: rpText2, fontSize: 13),
// //                     ),
// //                   ],
// //                 ),
// //                 const Spacer(),
// //                 Container(
// //                   padding: const EdgeInsets.symmetric(
// //                     horizontal: 10,
// //                     vertical: 6,
// //                   ),
// //                   decoration: BoxDecoration(
// //                     color: rpAmberL,
// //                     borderRadius: BorderRadius.circular(8),
// //                   ),
// //                   child: Text(
// //                     data!.ratingGrowthPercent == '0' ||
// //                             data!.ratingGrowthPercent == '0.00'
// //                         ? 'No change'
// //                         : '${data!.ratingGrowthPercent}%',
// //                     style: const TextStyle(
// //                       color: rpAmber,
// //                       fontWeight: FontWeight.w700,
// //                       fontSize: 12,
// //                     ),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //           const SizedBox(height: 16),
// //         ],
// //
// //         // ── Order Status Card ───────────────────────────────────────────────────
// //         _buildOrderStatusCard(),
// //         const SizedBox(height: 16),
// //
// //         // ── Order type split ───────────────────────────────────────────────────
// //         const RpSectionHeader(title: 'Order Types'),
// //         Container(
// //           decoration: rpCardDeco(),
// //           padding: const EdgeInsets.all(14),
// //           child: Column(
// //             children: [
// //               _typeBar(
// //                 'Dine In',
// //                 data!.dineInOrders,
// //                 data!.totalOrders,
// //                 rpAccent,
// //               ),
// //               const SizedBox(height: 12),
// //               _typeBar(
// //                 'Takeaway',
// //                 data!.takeawayOrders,
// //                 data!.totalOrders,
// //                 rpBlue,
// //               ),
// //               const SizedBox(height: 12),
// //               _typeBar(
// //                 'Delivery',
// //                 data!.deliveryOrders,
// //                 data!.totalOrders,
// //                 rpGreen,
// //               ),
// //             ],
// //           ),
// //         ),
// //         const SizedBox(height: 16),
// //
// //         // ── Peak hour ──────────────────────────────────────────────────────────
// //         if (data!.peakHour != null) ...[
// //           const RpSectionHeader(title: 'Peak Hour'),
// //           Container(
// //             decoration: rpCardDeco(border: rpAccent.withOpacity(0.3)),
// //             padding: const EdgeInsets.all(14),
// //             child: Row(
// //               children: [
// //                 Container(
// //                   width: 48,
// //                   height: 48,
// //                   decoration: BoxDecoration(
// //                     color: rpAccentL,
// //                     borderRadius: BorderRadius.circular(14),
// //                   ),
// //                   child: const Icon(
// //                     Icons.access_time_rounded,
// //                     color: rpAccent,
// //                     size: 24,
// //                   ),
// //                 ),
// //                 const SizedBox(width: 14),
// //                 Column(
// //                   crossAxisAlignment: CrossAxisAlignment.start,
// //                   children: [
// //                     Text(
// //                       data!.peakHour!.hour,
// //                       style: const TextStyle(
// //                         fontSize: 24,
// //                         fontWeight: FontWeight.w900,
// //                         color: rpText1,
// //                       ),
// //                     ),
// //                     Text(
// //                       '${data!.peakHour!.orders} orders at peak',
// //                       style: const TextStyle(color: rpText2, fontSize: 13),
// //                     ),
// //                   ],
// //                 ),
// //               ],
// //             ),
// //           ),
// //           const SizedBox(height: 16),
// //         ],
// //
// //         // ── Hourly chart ───────────────────────────────────────────────────────
// //         if (data!.hourlyBreakdown.isNotEmpty) ...[
// //           const RpSectionHeader(title: 'Hourly Order Pattern'),
// //           _HourlyChart(items: data!.hourlyBreakdown),
// //           const SizedBox(height: 16),
// //         ],
// //
// //         // ── Revenue by category ────────────────────────────────────────────────
// //         if (data!.revenueByCategory.isNotEmpty) ...[
// //           const RpSectionHeader(title: 'Revenue by Category'),
// //           _CategoryRevenue(
// //             data: data!.revenueByCategory,
// //             total: data!.totalRevenue,
// //           ),
// //         ],
// //       ],
// //     );
// //   }
// //
// //   Widget _buildOrderStatusCard() {
// //     return Container(
// //       margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
// //       decoration: _rpCardDecoWithShadow(),
// //       child: Padding(
// //         padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             const Row(
// //               children: [
// //                 Icon(Icons.pie_chart_outline, size: 18, color: rpText2),
// //                 SizedBox(width: 8),
// //                 Text(
// //                   'Order Status',
// //                   style: TextStyle(
// //                     fontSize: 14,
// //                     fontWeight: FontWeight.w600,
// //                     color: rpText1,
// //                   ),
// //                 ),
// //               ],
// //             ),
// //             const SizedBox(height: 12),
// //             Row(
// //               children: [
// //                 Expanded(
// //                   child: _statusCardItem(
// //                     'Completed',
// //                     data!.completedOrders,
// //                     rpGreen,
// //                     Icons.check_circle_outline,
// //                   ),
// //                 ),
// //                 const SizedBox(width: 8),
// //                 Expanded(
// //                   child: _statusCardItem(
// //                     'Cancelled',
// //                     data!.cancelledOrders,
// //                     rpRed,
// //                     Icons.cancel_outlined,
// //                   ),
// //                 ),
// //                 const SizedBox(width: 8),
// //                 Expanded(
// //                   child: _statusCardItem(
// //                     'Preparing',
// //                     data!.preparingOrders,
// //                     rpAmber,
// //                     Icons.restaurant_outlined,
// //                   ),
// //                 ),
// //                 const SizedBox(width: 8),
// //                 Expanded(
// //                   child: _statusCardItem(
// //                     'Pending',
// //                     data!.pendingOrders,
// //                     rpBlue,
// //                     Icons.pending_outlined,
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _statusCardItem(String label, int count, Color color, IconData icon) {
// //     return Column(
// //       children: [
// //         Icon(icon, color: color, size: 22),
// //         const SizedBox(height: 6),
// //         Text(
// //           '$count',
// //           style: TextStyle(
// //             fontWeight: FontWeight.w800,
// //             fontSize: 18,
// //             color: color,
// //           ),
// //         ),
// //         Text(
// //           label,
// //           style: const TextStyle(
// //             fontSize: 10,
// //             color: rpText2,
// //             fontWeight: FontWeight.w500,
// //           ),
// //           textAlign: TextAlign.center,
// //         ),
// //       ],
// //     );
// //   }
// //
// //   BoxDecoration _rpCardDecoWithShadow() {
// //     return BoxDecoration(
// //       color: Colors.white,
// //       borderRadius: BorderRadius.circular(16),
// //       border: Border.all(color: rpBorder),
// //       boxShadow: [
// //         BoxShadow(color: rpShadow, blurRadius: 8, offset: const Offset(0, 3)),
// //       ],
// //     );
// //   }
// //
// //   Widget _statCell(
// //     String value,
// //     String label,
// //     Color color,
// //     IconData icon, {
// //     String? sub,
// //   }) {
// //     return Column(
// //       children: [
// //         Row(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             Icon(icon, size: 16, color: color),
// //             const SizedBox(width: 4),
// //             Text(
// //               label,
// //               style: const TextStyle(
// //                 fontSize: 12,
// //                 color: rpText2,
// //                 fontWeight: FontWeight.w500,
// //               ),
// //             ),
// //           ],
// //         ),
// //         const SizedBox(height: 6),
// //         Text(
// //           value,
// //           style: TextStyle(
// //             fontSize: 18,
// //             fontWeight: FontWeight.bold,
// //             color: rpText1,
// //           ),
// //         ),
// //         if (sub != null) ...[
// //           const SizedBox(height: 2),
// //           Text(
// //             sub,
// //             style: TextStyle(
// //               fontSize: 11,
// //               color: color,
// //               fontWeight: FontWeight.w600,
// //             ),
// //           ),
// //         ],
// //       ],
// //     );
// //   }
// //
// //   Widget _vertDivider() {
// //     return Container(
// //       width: 1,
// //       height: 60,
// //       color: rpBorder,
// //       margin: const EdgeInsets.symmetric(horizontal: 8),
// //     );
// //   }
// //
// //   Widget _typeBar(String label, int count, int total, Color color) {
// //     final pct = total > 0 ? count / total : 0.0;
// //     return Row(
// //       children: [
// //         SizedBox(
// //           width: 58,
// //           child: Text(
// //             label,
// //             style: const TextStyle(fontSize: 12, color: rpText2),
// //           ),
// //         ),
// //         Expanded(
// //           child: ClipRRect(
// //             borderRadius: BorderRadius.circular(4),
// //             child: LinearProgressIndicator(
// //               value: pct,
// //               backgroundColor: rpBorder,
// //               color: color,
// //               minHeight: 8,
// //             ),
// //           ),
// //         ),
// //         const SizedBox(width: 8),
// //         SizedBox(
// //           width: 28,
// //           child: Text(
// //             '$count',
// //             style: TextStyle(
// //               fontSize: 12,
// //               fontWeight: FontWeight.w700,
// //               color: color,
// //             ),
// //             textAlign: TextAlign.right,
// //           ),
// //         ),
// //         const SizedBox(width: 4),
// //         SizedBox(
// //           width: 36,
// //           child: Text(
// //             '${(pct * 100).toStringAsFixed(0)}%',
// //             style: const TextStyle(fontSize: 10, color: rpText3),
// //           ),
// //         ),
// //       ],
// //     );
// //   }
// //
// //   Widget _shimmer() => Column(
// //     children: [
// //       Container(
// //         margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
// //         height: 180,
// //         decoration: BoxDecoration(
// //           color: Colors.white,
// //           borderRadius: BorderRadius.circular(16),
// //           border: Border.all(color: rpBorder),
// //         ),
// //         child: const Center(
// //           child: CircularProgressIndicator(color: rpAccent, strokeWidth: 2),
// //         ),
// //       ),
// //       const SizedBox(height: 16),
// //       const RpShimmerCard(height: 80),
// //       const SizedBox(height: 16),
// //       const RpShimmerCard(height: 160),
// //     ],
// //   );
// // }
// //
// // // ─── Hourly bar chart ─────────────────────────────────────────────────────────
// // class _HourlyChart extends StatelessWidget {
// //   final List<HourlyStat> items;
// //   const _HourlyChart({required this.items});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     final maxOrders = items.fold(0, (m, e) => e.orders > m ? e.orders : m);
// //     return Container(
// //       decoration: rpCardDeco(),
// //       padding: const EdgeInsets.fromLTRB(12, 14, 12, 10),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           SizedBox(
// //             height: 80,
// //             child: Row(
// //               crossAxisAlignment: CrossAxisAlignment.end,
// //               children: items.map((s) {
// //                 final ratio = maxOrders > 0 ? s.orders / maxOrders : 0.0;
// //                 final isActive = s.orders > 0;
// //                 return Expanded(
// //                   child: Padding(
// //                     padding: const EdgeInsets.symmetric(horizontal: 1),
// //                     child: Tooltip(
// //                       message: '${s.hour}: ${s.orders} orders',
// //                       child: Container(
// //                         height: ratio * 70 + (isActive ? 4 : 2),
// //                         decoration: BoxDecoration(
// //                           color: isActive
// //                               ? rpAccent.withOpacity(0.7 + ratio * 0.3)
// //                               : rpBorder,
// //                           borderRadius: BorderRadius.circular(3),
// //                         ),
// //                       ),
// //                     ),
// //                   ),
// //                 );
// //               }).toList(),
// //             ),
// //           ),
// //           const SizedBox(height: 6),
// //           Row(
// //             children: items.asMap().entries.map((e) {
// //               final show = e.key % 6 == 0 || e.key == 23;
// //               return Expanded(
// //                 child: Text(
// //                   show ? e.value.hour.substring(0, 2) : '',
// //                   style: const TextStyle(fontSize: 8, color: rpText3),
// //                   textAlign: TextAlign.center,
// //                 ),
// //               );
// //             }).toList(),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
// //
// // // ─── Daily revenue bars ───────────────────────────────────────────────────────
// // class _DailyChart extends StatelessWidget {
// //   final List<DailyStat> items;
// //   const _DailyChart({required this.items});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     final fmt = NumberFormat('#,##,###');
// //     final maxRev = items.fold(0.0, (m, e) => e.revenue > m ? e.revenue : m);
// //     return Container(
// //       decoration: rpCardDeco(),
// //       child: Column(
// //         children: items.asMap().entries.map((entry) {
// //           final i = entry.key;
// //           final s = entry.value;
// //           final ratio = maxRev > 0 ? s.revenue / maxRev : 0.0;
// //           return Column(
// //             children: [
// //               Padding(
// //                 padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
// //                 child: Row(
// //                   children: [
// //                     SizedBox(
// //                       width: 70,
// //                       child: Text(
// //                         _fmtDate(s.date),
// //                         style: const TextStyle(
// //                           fontSize: 11,
// //                           color: rpText3,
// //                           fontWeight: FontWeight.w600,
// //                         ),
// //                       ),
// //                     ),
// //                     Expanded(
// //                       child: Stack(
// //                         children: [
// //                           Container(
// //                             height: 8,
// //                             decoration: BoxDecoration(
// //                               color: rpBorder,
// //                               borderRadius: BorderRadius.circular(4),
// //                             ),
// //                           ),
// //                           FractionallySizedBox(
// //                             widthFactor: ratio,
// //                             child: Container(
// //                               height: 8,
// //                               decoration: BoxDecoration(
// //                                 color: rpAccent,
// //                                 borderRadius: BorderRadius.circular(4),
// //                               ),
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                     ),
// //                     const SizedBox(width: 10),
// //                     SizedBox(
// //                       width: 74,
// //                       child: Text(
// //                         '₹${fmt.format(s.revenue.round())}',
// //                         style: const TextStyle(
// //                           fontSize: 12,
// //                           fontWeight: FontWeight.w700,
// //                           color: rpText1,
// //                         ),
// //                         textAlign: TextAlign.right,
// //                       ),
// //                     ),
// //                     const SizedBox(width: 8),
// //                     SizedBox(
// //                       width: 28,
// //                       child: Text(
// //                         '${s.orders}',
// //                         style: const TextStyle(fontSize: 11, color: rpText3),
// //                         textAlign: TextAlign.right,
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //               if (i < items.length - 1)
// //                 Divider(color: rpBorder, height: 1, indent: 14, endIndent: 14),
// //             ],
// //           );
// //         }).toList(),
// //       ),
// //     );
// //   }
// //
// //   String _fmtDate(String d) {
// //     try {
// //       final parsed = DateTime.parse(d).add(const Duration(hours: 5, minutes: 30));
// //       return DateFormat('dd MMM yy').format(parsed);
// //     } catch (_) {
// //       return d;
// //     }
// //   }
// // }
// //
// // // ─── Category revenue breakdown ───────────────────────────────────────────────
// // class _CategoryRevenue extends StatelessWidget {
// //   final Map<String, double> data;
// //   final double total;
// //   const _CategoryRevenue({required this.data, required this.total});
// //
// //   static const _colors = [rpAccent, rpBlue, rpGreen, rpPurple, rpAmber, rpRed];
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     final fmt = NumberFormat('#,##,###');
// //     final entries = data.entries.toList()
// //       ..sort((a, b) => b.value.compareTo(a.value));
// //     return Container(
// //       decoration: rpCardDeco(),
// //       padding: const EdgeInsets.all(14),
// //       child: Column(
// //         children: entries.asMap().entries.map((e) {
// //           final idx = e.key;
// //           final cat = e.value.key;
// //           final rev = e.value.value;
// //           final color = _colors[idx % _colors.length];
// //           final pct = total > 0 ? rev / total : 0.0;
// //           final isLast = idx == entries.length - 1;
// //           return Column(
// //             children: [
// //               Row(
// //                 children: [
// //                   Container(
// //                     width: 10,
// //                     height: 10,
// //                     decoration: BoxDecoration(
// //                       color: color,
// //                       borderRadius: BorderRadius.circular(3),
// //                     ),
// //                   ),
// //                   const SizedBox(width: 8),
// //                   Expanded(
// //                     child: Text(
// //                       cat.trim(),
// //                       style: const TextStyle(
// //                         fontSize: 13,
// //                         color: rpText1,
// //                         fontWeight: FontWeight.w600,
// //                       ),
// //                     ),
// //                   ),
// //                   Text(
// //                     '${(pct * 100).toStringAsFixed(1)}%',
// //                     style: const TextStyle(fontSize: 11, color: rpText3),
// //                   ),
// //                   const SizedBox(width: 10),
// //                   Text(
// //                     '₹${fmt.format(rev.round())}',
// //                     style: TextStyle(
// //                       fontSize: 13,
// //                       fontWeight: FontWeight.w700,
// //                       color: color,
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //               const SizedBox(height: 6),
// //               ClipRRect(
// //                 borderRadius: BorderRadius.circular(4),
// //                 child: LinearProgressIndicator(
// //                   value: pct,
// //                   backgroundColor: rpBorder,
// //                   color: color,
// //                   minHeight: 6,
// //                 ),
// //               ),
// //               if (!isLast) const SizedBox(height: 12),
// //               if (!isLast) Divider(color: rpBorder, height: 1),
// //               if (!isLast) const SizedBox(height: 4),
// //             ],
// //           );
// //         }).toList(),
// //       ),
// //     );
// //   }
// // }
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import '../models/report_models.dart';
// import '../widgets/theme.dart';
//
// class OverviewTab extends StatelessWidget {
//   final ReportData? data;
//   final bool isLoading;
//   const OverviewTab({super.key, this.data, this.isLoading = false});
//
//   String _fmtN(int v) => NumberFormat('#,##,###').format(v);
//
//   @override
//   Widget build(BuildContext context) {
//     if (isLoading) return _shimmer();
//     if (data == null) {
//       return const RpEmpty(
//         message: 'No data. Pull down to refresh or change date range.',
//         icon: Icons.dashboard_outlined,
//       );
//     }
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // ── Period label ───────────────────────────────────────────────────────
//         if (data!.period.isNotEmpty)
//           Padding(
//             padding: const EdgeInsets.only(bottom: 12),
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//               decoration: BoxDecoration(
//                 color: rpAccentL,
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Text(
//                 data!.period,
//                 style: const TextStyle(
//                   color: rpAccent,
//                   fontSize: 12,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//           ),
//
//         // ── Stats Card ─────────────────────────────────────────────────────────
//         Container(
//           decoration: _cardDeco(),
//           child: Padding(
//             padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
//             child: Column(
//               children: [
//                 // Row 1: Gross Revenue | Total Orders
//                 Row(
//                   children: [
//                     Expanded(
//                       child: _statCell(
//                         data!.grossRevenue.toStringAsFixed(2),
//                         'Gross Revenue',
//                         rpGreen,
//                         Icons.account_balance_outlined,
//                       ),
//                     ),
//                     _vertDivider(),
//                     Expanded(
//                       child: _statCell(
//                         data!.netProfit.toStringAsFixed(2),
//                         'Net Profit',
//                         rpGreen,
//                         Icons.account_balance_wallet_rounded,
//                       ),
//                     ),
//
//                   ],
//                 ),
//
//                 const SizedBox(height: 12),
//
//                 // Row 2: Revenue Growth | Avg Order Value
//                 Row(
//                   children: [
//                     Expanded(
//                       child: _statCell(
//                         '${data!.revenueGrowthPercent.toStringAsFixed(2)}%',
//                         'Revenue Growth',
//                         data!.revenueGrowthPercent >= 0 ? rpGreen : rpRed,
//                         data!.revenueGrowthPercent >= 0
//                             ? Icons.trending_up_rounded
//                             : Icons.trending_down_rounded,
//                       ),
//                     ),
//                     _vertDivider(),
//                     Expanded(
//                       child: _statCell(
//                         _fmtN(data!.totalOrders),
//                         'Total Orders',
//                         rpBlue,
//                         Icons.shopping_bag_rounded,
//                       ),
//                     ),
//                   ],
//                 ),
//
//                 const SizedBox(height: 12),
//
//                 // ── Row 3: Vendor Orders | User Orders ─────────────────────────
//
//                 Container(
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   padding: const EdgeInsets.symmetric(
//                     vertical: 10,
//                     horizontal: 4,
//                   ),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: _statCell(
//                           _fmtN(data!.vendorOrders),
//                           'Offline Orders',
//                           rpAccent,
//                           Icons.storefront_outlined,
//                         ),
//                       ),
//                       _vertDivider(),
//                       Expanded(
//                         child: _statCell(
//                           _fmtN(data!.userOrders),
//                           'Online Orders',
//                           rpPurple,
//                           Icons.person_outline_rounded,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//         const SizedBox(height: 16),
//
//
//         // ── Avg Rating ────────────────────────────────────────────────────────
//         if (data!.averageRating != '0' && data!.averageRating != '0.00') ...[
//           const RpSectionHeader(title: 'Customer Rating'),
//           Container(
//             decoration: rpCardDeco(border: rpAmber.withOpacity(0.4)),
//             padding: const EdgeInsets.all(14),
//             child: Row(
//               children: [
//                 Container(
//                   width: 52,
//                   height: 52,
//                   decoration: BoxDecoration(
//                     color: rpAmberL,
//                     borderRadius: BorderRadius.circular(14),
//                   ),
//                   child: const Icon(
//                     Icons.star_rounded,
//                     color: rpAmber,
//                     size: 28,
//                   ),
//                 ),
//                 const SizedBox(width: 14),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       data!.averageRating,
//                       style: const TextStyle(
//                         fontSize: 28,
//                         fontWeight: FontWeight.w900,
//                         color: rpAmber,
//                       ),
//                     ),
//                     Text(
//                       '${data!.totalRatings} total ratings',
//                       style: const TextStyle(color: rpText2, fontSize: 13),
//                     ),
//                   ],
//                 ),
//                 const Spacer(),
//                 // Container(
//                 //   padding: const EdgeInsets.symmetric(
//                 //     horizontal: 10,
//                 //     vertical: 6,
//                 //   ),
//                 //   decoration: BoxDecoration(
//                 //     color: rpAmberL,
//                 //     borderRadius: BorderRadius.circular(8),
//                 //   ),
//                 //   child: Text(
//                 //     data!.ratingGrowthPercent == '0' ||
//                 //             data!.ratingGrowthPercent == '0.00'
//                 //         ? 'No change'
//                 //         : '${data!.ratingGrowthPercent}%',
//                 //     style: const TextStyle(
//                 //       color: rpAmber,
//                 //       fontWeight: FontWeight.w700,
//                 //       fontSize: 12,
//                 //     ),
//                 //   ),
//                 // ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 16),
//         ],
//
//         // ── Order Status Card ──────────────────────────────────────────────────
//         _buildOrderStatusCard(),
//         const SizedBox(height: 16),
//
//         // ── Order type bars ────────────────────────────────────────────────────
//         const RpSectionHeader(title: 'Order Types'),
//         Container(
//           decoration: rpCardDeco(),
//           padding: const EdgeInsets.all(14),
//           child: Column(
//             children: [
//               _typeBar(
//                 'Dine In',
//                 data!.dineInOrders,
//                 data!.totalOrders,
//                 rpAccent,
//               ),
//               const SizedBox(height: 12),
//               _typeBar(
//                 'Takeaway',
//                 data!.takeawayOrders,
//                 data!.totalOrders,
//                 rpBlue,
//               ),
//               const SizedBox(height: 12),
//               _typeBar(
//                 'Delivery',
//                 data!.deliveryOrders,
//                 data!.totalOrders,
//                 rpGreen,
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(height: 16),
//
//         // ── Peak hour ──────────────────────────────────────────────────────────
//         if (data!.peakHour != null) ...[
//           const RpSectionHeader(title: 'Peak Hour'),
//           Container(
//             decoration: rpCardDeco(border: rpAccent.withOpacity(0.3)),
//             padding: const EdgeInsets.all(14),
//             child: Row(
//               children: [
//                 Container(
//                   width: 48,
//                   height: 48,
//                   decoration: BoxDecoration(
//                     color: rpAccentL,
//                     borderRadius: BorderRadius.circular(14),
//                   ),
//                   child: const Icon(
//                     Icons.access_time_rounded,
//                     color: rpAccent,
//                     size: 24,
//                   ),
//                 ),
//                 const SizedBox(width: 14),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       data!.peakHour!.hour,
//                       style: const TextStyle(
//                         fontSize: 24,
//                         fontWeight: FontWeight.w900,
//                         color: rpText1,
//                       ),
//                     ),
//                     Text(
//                       '${data!.peakHour!.orders} orders at peak',
//                       style: const TextStyle(color: rpText2, fontSize: 13),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 16),
//         ],
//
//         // ── Hourly chart ───────────────────────────────────────────────────────
//         if (data!.hourlyBreakdown.isNotEmpty) ...[
//           const RpSectionHeader(title: 'Hourly Order Pattern'),
//           _HourlyChart(items: data!.hourlyBreakdown),
//           const SizedBox(height: 16),
//         ],
//
//         // ── Daily stats ────────────────────────────────────────────────────────
//         // if (data!.dailyStats.isNotEmpty) ...[
//         //   const RpSectionHeader(title: 'Daily Revenue'),
//         //   _DailyChart(items: data!.dailyStats),
//         //   const SizedBox(height: 16),
//         // ],
//
//         // ── Revenue by category ────────────────────────────────────────────────
//         // if (data!.revenueByCategory.isNotEmpty) ...[
//         //   const RpSectionHeader(title: 'Revenue by Category'),
//         //   _CategoryRevenue(
//         //     data: data!.revenueByCategory,
//         //     total: data!.totalRevenue,
//         //   ),
//         // ],
//       ],
//     );
//   }
//
//   // ── Vendor vs User Orders bar ──────────────────────────────────────────────
//
//   Widget _sourceLegend(IconData icon, String label, int count, Color color) =>
//       Expanded(
//         child: Container(
//           padding: const EdgeInsets.all(10),
//           decoration: BoxDecoration(
//             color: color.withOpacity(0.07),
//             borderRadius: BorderRadius.circular(10),
//             border: Border.all(color: color.withOpacity(0.2)),
//           ),
//           child: Row(
//             children: [
//               Container(
//                 width: 30,
//                 height: 30,
//                 decoration: BoxDecoration(
//                   color: color.withOpacity(0.15),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Icon(icon, color: color, size: 16),
//               ),
//               const SizedBox(width: 8),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       '$count',
//                       style: TextStyle(
//                         fontSize: 17,
//                         fontWeight: FontWeight.w900,
//                         color: color,
//                       ),
//                     ),
//                     Text(
//                       label,
//                       style: const TextStyle(
//                         fontSize: 10,
//                         color: rpText2,
//                         fontWeight: FontWeight.w500,
//                       ),
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );
//
//   // ── Order Status Card ──────────────────────────────────────────────────────
//   Widget _buildOrderStatusCard() => Container(
//     decoration: _cardDeco(),
//     child: Padding(
//       padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Row(
//             children: [
//               Icon(Icons.pie_chart_outline, size: 18, color: rpText2),
//               SizedBox(width: 8),
//               Text(
//                 'Order Status',
//                 style: TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.w600,
//                   color: rpText1,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           Row(
//             children: [
//               Expanded(
//                 child: _statusItem(
//                   'Completed',
//                   data!.completedOrders,
//                   rpGreen,
//                   Icons.check_circle_outline,
//                 ),
//               ),
//               const SizedBox(width: 8),
//               Expanded(
//                 child: _statusItem(
//                   'Cancelled',
//                   data!.cancelledOrders,
//                   rpRed,
//                   Icons.cancel_outlined,
//                 ),
//               ),
//               const SizedBox(width: 8),
//               Expanded(
//                 child: _statusItem(
//                   'Preparing',
//                   data!.preparingOrders,
//                   rpAmber,
//                   Icons.restaurant_outlined,
//                 ),
//               ),
//               const SizedBox(width: 8),
//               Expanded(
//                 child: _statusItem(
//                   'Pending',
//                   data!.pendingOrders,
//                   rpBlue,
//                   Icons.pending_outlined,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     ),
//   );
//
//   Widget _statusItem(String label, int count, Color color, IconData icon) =>
//       Column(
//         children: [
//           Icon(icon, color: color, size: 22),
//           const SizedBox(height: 6),
//           Text(
//             '$count',
//             style: TextStyle(
//               fontWeight: FontWeight.w800,
//               fontSize: 18,
//               color: color,
//             ),
//           ),
//           Text(
//             label,
//             style: const TextStyle(
//               fontSize: 10,
//               color: rpText2,
//               fontWeight: FontWeight.w500,
//             ),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       );
//
//   BoxDecoration _cardDeco() => BoxDecoration(
//     color: Colors.white,
//     borderRadius: BorderRadius.circular(16),
//     border: Border.all(color: rpBorder),
//     boxShadow: [
//       BoxShadow(color: rpShadow, blurRadius: 8, offset: const Offset(0, 3)),
//     ],
//   );
//
//   Widget _statCell(
//     String value,
//     String label,
//     Color color,
//     IconData icon, {
//     String? sub,
//   }) => Column(
//     children: [
//       Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(icon, size: 16, color: color),
//           const SizedBox(width: 4),
//           Text(
//             label,
//             style: const TextStyle(
//               fontSize: 12,
//               color: rpText2,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ],
//       ),
//       const SizedBox(height: 6),
//       Text(
//         value,
//         style: const TextStyle(
//           fontSize: 18,
//           fontWeight: FontWeight.bold,
//           color: rpText1,
//         ),
//       ),
//       if (sub != null) ...[
//         const SizedBox(height: 2),
//         Text(
//           sub,
//           style: TextStyle(
//             fontSize: 11,
//             color: color,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ],
//     ],
//   );
//
//   Widget _vertDivider() => Container(
//     width: 1,
//     height: 60,
//     color: rpBorder,
//     margin: const EdgeInsets.symmetric(horizontal: 8),
//   );
//
//   Widget _typeBar(String label, int count, int total, Color color) {
//     final pct = total > 0 ? count / total : 0.0;
//     return Row(
//       children: [
//         SizedBox(
//           width: 58,
//           child: Text(
//             label,
//             style: const TextStyle(fontSize: 12, color: rpText2),
//           ),
//         ),
//         Expanded(
//           child: ClipRRect(
//             borderRadius: BorderRadius.circular(4),
//             child: LinearProgressIndicator(
//               value: pct,
//               backgroundColor: rpBorder,
//               color: color,
//               minHeight: 8,
//             ),
//           ),
//         ),
//         const SizedBox(width: 8),
//         SizedBox(
//           width: 28,
//           child: Text(
//             '$count',
//             style: TextStyle(
//               fontSize: 12,
//               fontWeight: FontWeight.w700,
//               color: color,
//             ),
//             textAlign: TextAlign.right,
//           ),
//         ),
//         const SizedBox(width: 4),
//         SizedBox(
//           width: 36,
//           child: Text(
//             '${(pct * 100).toStringAsFixed(0)}%',
//             style: const TextStyle(fontSize: 10, color: rpText3),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _shimmer() => Column(
//     children: [
//       Container(
//         height: 180,
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(color: rpBorder),
//         ),
//         child: const Center(
//           child: CircularProgressIndicator(color: rpAccent, strokeWidth: 2),
//         ),
//       ),
//       const SizedBox(height: 16),
//       const RpShimmerCard(height: 80),
//       const SizedBox(height: 16),
//       const RpShimmerCard(height: 160),
//     ],
//   );
// }
//
// // ─── Hourly bar chart ─────────────────────────────────────────────────────────
// class _HourlyChart extends StatelessWidget {
//   final List<HourlyStat> items;
//   const _HourlyChart({required this.items});
//
//   @override
//   Widget build(BuildContext context) {
//     final maxOrders = items.fold(0, (m, e) => e.orders > m ? e.orders : m);
//     return Container(
//       decoration: rpCardDeco(),
//       padding: const EdgeInsets.fromLTRB(12, 14, 12, 10),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             height: 80,
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.end,
//               children: items.map((s) {
//                 final ratio = maxOrders > 0 ? s.orders / maxOrders : 0.0;
//                 final isActive = s.orders > 0;
//                 return Expanded(
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 1),
//                     child: Tooltip(
//                       message: '${s.hour}: ${s.orders} orders',
//                       child: Container(
//                         height: ratio * 70 + (isActive ? 4 : 2),
//                         decoration: BoxDecoration(
//                           color: isActive
//                               ? rpAccent.withOpacity(0.7 + ratio * 0.3)
//                               : rpBorder,
//                           borderRadius: BorderRadius.circular(3),
//                         ),
//                       ),
//                     ),
//                   ),
//                 );
//               }).toList(),
//             ),
//           ),
//           const SizedBox(height: 6),
//           Row(
//             children: items.asMap().entries.map((e) {
//               final show = e.key % 6 == 0 || e.key == 23;
//               // Show shortened label (first 2 chars of the IST-converted time)
//               final label = show
//                   ? (e.value.hour.length >= 2
//                         ? e.value.hour.substring(0, 2)
//                         : e.value.hour)
//                   : '';
//               return Expanded(
//                 child: Text(
//                   label,
//                   style: const TextStyle(fontSize: 8, color: rpText3),
//                   textAlign: TextAlign.center,
//                 ),
//               );
//             }).toList(),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // ─── Daily revenue bars ───────────────────────────────────────────────────────
// class _DailyChart extends StatelessWidget {
//   final List<DailyStat> items;
//   const _DailyChart({required this.items});
//
//   @override
//   Widget build(BuildContext context) {
//     final fmt = NumberFormat('#,##,###');
//     final maxRev = items.fold(0.0, (m, e) => e.revenue > m ? e.revenue : m);
//     return Container(
//       decoration: rpCardDeco(),
//       child: Column(
//         children: items.asMap().entries.map((entry) {
//           final i = entry.key;
//           final s = entry.value;
//           final ratio = maxRev > 0 ? s.revenue / maxRev : 0.0;
//           return Column(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
//                 child: Row(
//                   children: [
//                     SizedBox(
//                       width: 70,
//                       child: Text(
//                         _fmtDate(s.date),
//                         style: const TextStyle(
//                           fontSize: 11,
//                           color: rpText3,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                     Expanded(
//                       child: Stack(
//                         children: [
//                           Container(
//                             height: 8,
//                             decoration: BoxDecoration(
//                               color: rpBorder,
//                               borderRadius: BorderRadius.circular(4),
//                             ),
//                           ),
//                           FractionallySizedBox(
//                             widthFactor: ratio,
//                             child: Container(
//                               height: 8,
//                               decoration: BoxDecoration(
//                                 color: rpAccent,
//                                 borderRadius: BorderRadius.circular(4),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(width: 10),
//                     SizedBox(
//                       width: 74,
//                       child: Text(
//                         '₹${s.revenue.toStringAsFixed(2)}',
//                         style: const TextStyle(
//                           fontSize: 12,
//                           fontWeight: FontWeight.w700,
//                           color: rpText1,
//                         ),
//                         textAlign: TextAlign.right,
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     SizedBox(
//                       width: 28,
//                       child: Text(
//                         '${s.orders}',
//                         style: const TextStyle(fontSize: 11, color: rpText3),
//                         textAlign: TextAlign.right,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               if (i < items.length - 1)
//                 Divider(color: rpBorder, height: 1, indent: 14, endIndent: 14),
//             ],
//           );
//         }).toList(),
//       ),
//     );
//   }
//
//   String _fmtDate(String d) {
//     try {
//       final parsed = DateTime.parse(
//         d,
//       ).add(const Duration(hours: 5, minutes: 30));
//       return DateFormat('dd MMM yy').format(parsed);
//     } catch (_) {
//       return d;
//     }
//   }
// }
//
// // ─── Category revenue breakdown ───────────────────────────────────────────────
// class _CategoryRevenue extends StatelessWidget {
//   final Map<String, double> data;
//   final double total;
//   const _CategoryRevenue({required this.data, required this.total});
//
//   static const _colors = [rpAccent, rpBlue, rpGreen, rpPurple, rpAmber, rpRed];
//
//   @override
//   Widget build(BuildContext context) {
//     final fmt = NumberFormat('#,##,###');
//     final entries = data.entries.toList()
//       ..sort((a, b) => b.value.compareTo(a.value));
//     return Container(
//       decoration: rpCardDeco(),
//       padding: const EdgeInsets.all(14),
//       child: Column(
//         children: entries.asMap().entries.map((e) {
//           final idx = e.key;
//           final cat = e.value.key;
//           final rev = e.value.value;
//           final color = _colors[idx % _colors.length];
//           final pct = total > 0 ? rev / total : 0.0;
//           final isLast = idx == entries.length - 1;
//           return Column(
//             children: [
//               Row(
//                 children: [
//                   Container(
//                     width: 10,
//                     height: 10,
//                     decoration: BoxDecoration(
//                       color: color,
//                       borderRadius: BorderRadius.circular(3),
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   Expanded(
//                     child: Text(
//                       cat.trim(),
//                       style: const TextStyle(
//                         fontSize: 13,
//                         color: rpText1,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//                   Text(
//                     '${(pct * 100).toStringAsFixed(1)}%',
//                     style: const TextStyle(fontSize: 11, color: rpText3),
//                   ),
//                   const SizedBox(width: 10),
//                   Text(
//                     '₹${e.value.value.toStringAsFixed(2)}',
//                     style: TextStyle(
//                       fontSize: 12,
//                       color: color,
//                       fontWeight: FontWeight.w700,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 6),
//               ClipRRect(
//                 borderRadius: BorderRadius.circular(4),
//                 child: LinearProgressIndicator(
//                   value: pct,
//                   backgroundColor: rpBorder,
//                   color: color,
//                   minHeight: 6,
//                 ),
//               ),
//               if (!isLast) const SizedBox(height: 12),
//               if (!isLast) Divider(color: rpBorder, height: 1),
//               if (!isLast) const SizedBox(height: 4),
//             ],
//           );
//         }).toList(),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/report_models.dart';
import '../widgets/theme.dart';

class OverviewTab extends StatelessWidget {
  final ReportData? data;
  final bool isLoading;
  const OverviewTab({super.key, this.data, this.isLoading = false});

  String _fmtN(int v) => NumberFormat('#,##,###').format(v);
  String _fmtCurrency(double v) => NumberFormat('#,##,###.00').format(v);

  @override
  Widget build(BuildContext context) {
    if (isLoading) return _shimmer();
    if (data == null) {
      return const RpEmpty(
        message: 'No data. Pull down to refresh or change date range.',
        icon: Icons.dashboard_outlined,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Stats Card (FIRST) ─────────────────────────────────────────────────
        Container(
          decoration: _cardDeco(),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _statCell(
                        data!.grossRevenue.toStringAsFixed(2),
                        'Gross Income',
                        rpGreen,
                        Icons.account_balance_outlined,
                      ),
                    ),
                    _vertDivider(),
                    Expanded(
                      child: _statCell(
                        data!.netProfit.toStringAsFixed(2),
                        'Net Income',
                        rpGreen,
                        Icons.account_balance_wallet_rounded,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _statCell(
                        '${data!.revenueGrowthPercent.toStringAsFixed(2)}%',
                        'Growth',
                        data!.revenueGrowthPercent >= 0 ? rpGreen : rpRed,
                        data!.revenueGrowthPercent >= 0
                            ? Icons.trending_up_rounded
                            : Icons.trending_down_rounded,
                      ),
                    ),
                    _vertDivider(),
                    Expanded(
                      child: _statCell(
                        _fmtN(data!.totalOrders),
                        'Total Orders',
                        rpBlue,
                        Icons.shopping_bag_rounded,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Row 3: Offline Orders | Online Orders
                // Container(
                //   decoration: BoxDecoration(
                //     borderRadius: BorderRadius.circular(10),
                //   ),
                //   padding: const EdgeInsets.symmetric(
                //     vertical: 10,
                //     horizontal: 4,
                //   ),
                //   child: Row(
                //     children: [
                //       Expanded(
                //         child: _statCell(
                //           _fmtN(data!.vendorOrders),
                //           'Offline Orders',
                //           rpAccent,
                //           Icons.storefront_outlined,
                //         ),
                //       ),
                //       _vertDivider(),
                //       Expanded(
                //         child: _statCell(
                //           _fmtN(data!.userOrders),
                //           'Online Orders',
                //           rpPurple,
                //           Icons.person_outline_rounded,
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
                if (data!.averageRating != '0' &&
                    data!.averageRating != '0.00') ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _statCell(
                          data!.averageRating,
                          'Avg Rating',
                          rpAmber,
                          Icons.star_rounded,
                        ),
                      ),
                      _vertDivider(),
                      // Expanded(
                      //   child: _statCell(
                      //     _fmtN(data!.totalRatings),
                      //     'Total Ratings',
                      //     rpAmber,
                      //     Icons.reviews_outlined,
                      //   ),
                      // ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // ── Customer Rating (SECOND) ───────────────────────────────────────────
        // if (data!.averageRating != '0' && data!.averageRating != '0.00') ...[
        //   const RpSectionHeader(title: 'Customer Rating'),
        //   Container(
        //     decoration: rpCardDeco(border: rpAmber.withOpacity(0.4)),
        //     padding: const EdgeInsets.all(14),
        //     child: Row(
        //       children: [
        //         Container(
        //           width: 52,
        //           height: 52,
        //           decoration: BoxDecoration(
        //             color: rpAmberL,
        //             borderRadius: BorderRadius.circular(14),
        //           ),
        //           child: const Icon(
        //             Icons.star_rounded,
        //             color: rpAmber,
        //             size: 28,
        //           ),
        //         ),
        //         const SizedBox(width: 14),
        //         Column(
        //           crossAxisAlignment: CrossAxisAlignment.start,
        //           children: [
        //             Text(
        //               data!.averageRating,
        //               style: const TextStyle(
        //                 fontSize: 28,
        //                 fontWeight: FontWeight.w900,
        //                 color: rpAmber,
        //               ),
        //             ),
        //             Text(
        //               '${data!.totalRatings} total ratings',
        //               style: const TextStyle(color: rpText2, fontSize: 13),
        //             ),
        //           ],
        //         ),
        //         const Spacer(),
        //         // Rating growth indicator (commented as in original)
        //         // Container(
        //         //   padding: const EdgeInsets.symmetric(
        //         //     horizontal: 10,
        //         //     vertical: 6,
        //         //   ),
        //         //   decoration: BoxDecoration(
        //         //     color: rpAmberL,
        //         //     borderRadius: BorderRadius.circular(8),
        //         //   ),
        //         //   child: Text(
        //         //     data!.ratingGrowthPercent == '0' ||
        //         //             data!.ratingGrowthPercent == '0.00'
        //         //         ? 'No change'
        //         //         : '${data!.ratingGrowthPercent}%',
        //         //     style: const TextStyle(
        //         //       color: rpAmber,
        //         //       fontWeight: FontWeight.w700,
        //         //       fontSize: 12,
        //         //     ),
        //         //   ),
        //         // ),
        //       ],
        //     ),
        //   ),
        //   const SizedBox(height: 16),
        // ],

        // ── Weekly Overview Chart (THIRD) ──────────────────────────────────────
        if (data!.dailyStats.isNotEmpty) ...[
          _buildWeeklyOverviewChart(),
          const SizedBox(height: 16),
        ],

        // ── Order Status Card ──────────────────────────────────────────────────
        _buildOrderStatusCard(),
        const SizedBox(height: 16),

        // ── Order type bars ────────────────────────────────────────────────────
        const RpSectionHeader(title: 'Order Types'),
        Container(
          decoration: rpCardDeco(),
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              _typeBar(
                'Dine In',
                data!.dineInOrders,
                data!.totalOrders,
                rpAccent,
              ),
              const SizedBox(height: 12),
              _typeBar(
                'Takeaway',
                data!.takeawayOrders,
                data!.totalOrders,
                rpBlue,
              ),
              const SizedBox(height: 12),
              _typeBar(
                'Delivery',
                data!.deliveryOrders,
                data!.totalOrders,
                rpGreen,
              ),
              const SizedBox(height: 12),
              _typeBar(
                'Dine Out',
                data!.deliveryOrders,
                data!.totalOrders,
                rpGreen,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ── Peak hour ──────────────────────────────────────────────────────────
        if (data!.peakHour != null) ...[
          const RpSectionHeader(title: 'Peak Hour'),
          Container(
            decoration: rpCardDeco(border: rpAccent.withOpacity(0.3)),
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: rpAccentL,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.access_time_rounded,
                    color: rpAccent,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data!.peakHour!.hour,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: rpText1,
                      ),
                    ),
                    Text(
                      '${data!.peakHour!.orders} orders at peak',
                      style: const TextStyle(color: rpText2, fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // ── Hourly chart ───────────────────────────────────────────────────────
        if (data!.hourlyBreakdown.isNotEmpty) ...[
          const RpSectionHeader(title: 'Hourly Order Pattern'),
          _HourlyChart(items: data!.hourlyBreakdown),
          const SizedBox(height: 16),
        ],

        // ── Daily stats (commented - replaced by Weekly Overview above) ────────
        // if (data!.dailyStats.isNotEmpty) ...[
        //   const RpSectionHeader(title: 'Daily Revenue'),
        //   _DailyChart(items: data!.dailyStats),
        //   const SizedBox(height: 16),
        // ],

        // ── Revenue by category (commented) ────────────────────────────────────
        // if (data!.revenueByCategory.isNotEmpty) ...[
        //   const RpSectionHeader(title: 'Revenue by Category'),
        //   _CategoryRevenue(
        //     data: data!.revenueByCategory,
        //     total: data!.totalRevenue,
        //   ),
        // ],
      ],
    );
  }

  // ── Weekly Overview Chart Widget ─────────────────────────────────────────────
  Widget _buildWeeklyOverviewChart() {
    final dailyStats = data!.dailyStats;

    if (dailyStats.isEmpty) {
      return const SizedBox.shrink();
    }

    final List<FlSpot> orderSpots = [];
    final List<FlSpot> revenueSpots = [];

    final sortedStats = List<DailyStat>.from(dailyStats)
      ..sort((a, b) => a.date.compareTo(b.date));

    final displayStats = sortedStats.length > 7
        ? sortedStats.sublist(sortedStats.length - 7)
        : sortedStats;

    for (int i = 0; i < displayStats.length; i++) {
      orderSpots.add(FlSpot(i.toDouble(), displayStats[i].orders.toDouble()));
      revenueSpots.add(FlSpot(i.toDouble(), displayStats[i].revenue));
    }

    final maxOrders = orderSpots.isEmpty
        ? 1
        : orderSpots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    final maxRevenue = revenueSpots.isEmpty
        ? 1
        : revenueSpots.map((s) => s.y).reduce((a, b) => a > b ? a : b);

    final totalOrders = displayStats.fold(0, (sum, s) => sum + s.orders);
    final totalRevenue = displayStats.fold(0.0, (sum, s) => sum + s.revenue);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const RpSectionHeader(title: 'Weekly Overview'),
        Container(
          decoration: rpCardDeco(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _fmtN(totalOrders),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: rpText1,
                          ),
                        ),
                        const Text(
                          'Total Orders',
                          style: TextStyle(fontSize: 11, color: rpText2),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '₹${_fmtCurrency(totalRevenue)}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: rpText1,
                          ),
                        ),
                        const Text(
                          'Total Revenue',
                          style: TextStyle(fontSize: 11, color: rpText2),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Line Chart
              SizedBox(
                height: 180,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (_) =>
                          FlLine(color: rpBorder, strokeWidth: 1),
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 36,
                          interval: maxOrders > 0
                              ? (maxOrders / 4).ceilToDouble()
                              : 1,
                          getTitlesWidget: (value, meta) => Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 9, color: rpText3),
                          ),
                        ),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 46,
                          interval: maxRevenue > 0
                              ? (maxRevenue / 4).ceilToDouble()
                              : 1,
                          getTitlesWidget: (value, meta) => Text(
                            '₹${value.toInt()}',
                            style: const TextStyle(fontSize: 9, color: rpText3),
                          ),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 32,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index < 0 || index >= displayStats.length) {
                              return const Text('');
                            }
                            final date = displayStats[index].date;
                            try {
                              final parsed = DateTime.parse(date);
                              return Text(
                                DateFormat('dd/MM').format(parsed),
                                style: const TextStyle(
                                  fontSize: 9,
                                  color: rpText3,
                                ),
                              );
                            } catch (_) {
                              return const Text('');
                            }
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(color: rpBorder),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: orderSpots,
                        isCurved: true,
                        color: rpBlue,
                        barWidth: 2.5,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (_, __, ___, ____) =>
                              FlDotCirclePainter(
                                radius: 3,
                                color: rpBlue,
                                strokeWidth: 2,
                                strokeColor: Colors.white,
                              ),
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          color: rpBlue.withOpacity(0.05),
                        ),
                      ),
                      LineChartBarData(
                        spots: revenueSpots,
                        isCurved: true,
                        color: rpAmber,
                        barWidth: 2.5,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (_, __, ___, ____) =>
                              FlDotCirclePainter(
                                radius: 3,
                                color: rpAmber,
                                strokeWidth: 2,
                                strokeColor: Colors.white,
                              ),
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          color: rpAmber.withOpacity(0.05),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Legend
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _legendDot(rpBlue, 'Orders'),
                  const SizedBox(width: 20),
                  _legendDot(rpAmber, 'Revenue (₹)'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: rpText2)),
      ],
    );
  }

  // ── Vendor vs User Orders bar ──────────────────────────────────────────────
  Widget _sourceLegend(IconData icon, String label, int count, Color color) =>
      Expanded(
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.07),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$count',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: color,
                      ),
                    ),
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 10,
                        color: rpText2,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  // ── Order Status Card ──────────────────────────────────────────────────────
  Widget _buildOrderStatusCard() => Container(
    decoration: _cardDeco(),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.pie_chart_outline, size: 18, color: rpText2),
              SizedBox(width: 8),
              Text(
                'Order Status',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: rpText1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _statusItem(
                  'Completed',
                  data!.completedOrders,
                  rpGreen,
                  Icons.check_circle_outline,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _statusItem(
                  'Cancelled',
                  data!.cancelledOrders,
                  rpRed,
                  Icons.cancel_outlined,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _statusItem(
                  'Preparing',
                  data!.preparingOrders,
                  rpAmber,
                  Icons.restaurant_outlined,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _statusItem(
                  'Pending',
                  data!.pendingOrders,
                  rpBlue,
                  Icons.pending_outlined,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );

  Widget _statusItem(String label, int count, Color color, IconData icon) =>
      Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            '$count',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 18,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: rpText2,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );

  BoxDecoration _cardDeco() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: rpBorder),
    boxShadow: [
      BoxShadow(color: rpShadow, blurRadius: 8, offset: const Offset(0, 3)),
    ],
  );

  Widget _statCell(
    String value,
    String label,
    Color color,
    IconData icon, {
    String? sub,
  }) => Column(
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: rpText2,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      const SizedBox(height: 6),
      Text(
        value,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: rpText1,
        ),
      ),
      if (sub != null) ...[
        const SizedBox(height: 2),
        Text(
          sub,
          style: TextStyle(
            fontSize: 11,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ],
  );

  Widget _vertDivider() => Container(
    width: 1,
    height: 60,
    color: rpBorder,
    margin: const EdgeInsets.symmetric(horizontal: 8),
  );

  Widget _typeBar(String label, int count, int total, Color color) {
    final pct = total > 0 ? count / total : 0.0;
    return Row(
      children: [
        SizedBox(
          width: 58,
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, color: rpText2),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              backgroundColor: rpBorder,
              color: color,
              minHeight: 8,
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 28,
          child: Text(
            '$count',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
            textAlign: TextAlign.right,
          ),
        ),
        const SizedBox(width: 4),
        SizedBox(
          width: 36,
          child: Text(
            '${(pct * 100).toStringAsFixed(0)}%',
            style: const TextStyle(fontSize: 10, color: rpText3),
          ),
        ),
      ],
    );
  }

  Widget _shimmer() => Column(
    children: [
      Container(
        height: 180,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: rpBorder),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: rpAccent, strokeWidth: 2),
        ),
      ),
      const SizedBox(height: 16),
      const RpShimmerCard(height: 80),
      const SizedBox(height: 16),
      const RpShimmerCard(height: 160),
    ],
  );
}

// ─── Hourly bar chart ─────────────────────────────────────────────────────────
class _HourlyChart extends StatelessWidget {
  final List<HourlyStat> items;
  const _HourlyChart({required this.items});

  @override
  Widget build(BuildContext context) {
    final maxOrders = items.fold(0, (m, e) => e.orders > m ? e.orders : m);
    return Container(
      decoration: rpCardDeco(),
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 80,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: items.map((s) {
                final ratio = maxOrders > 0 ? s.orders / maxOrders : 0.0;
                final isActive = s.orders > 0;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1),
                    child: Tooltip(
                      message: '${s.hour}: ${s.orders} orders',
                      child: Container(
                        height: ratio * 70 + (isActive ? 4 : 2),
                        decoration: BoxDecoration(
                          color: isActive
                              ? rpAccent.withOpacity(0.7 + ratio * 0.3)
                              : rpBorder,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: items.asMap().entries.map((e) {
              final show = e.key % 6 == 0 || e.key == 23;
              // Show shortened label (first 2 chars of the IST-converted time)
              final label = show
                  ? (e.value.hour.length >= 2
                        ? e.value.hour.substring(0, 2)
                        : e.value.hour)
                  : '';
              return Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontSize: 8, color: rpText3),
                  textAlign: TextAlign.center,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ─── Daily revenue bars (commented - kept for reference) ───────────────────────
// class _DailyChart extends StatelessWidget {
//   final List<DailyStat> items;
//   const _DailyChart({required this.items});
//
//   @override
//   Widget build(BuildContext context) {
//     final fmt = NumberFormat('#,##,###');
//     final maxRev = items.fold(0.0, (m, e) => e.revenue > m ? e.revenue : m);
//     return Container(
//       decoration: rpCardDeco(),
//       child: Column(
//         children: items.asMap().entries.map((entry) {
//           final i = entry.key;
//           final s = entry.value;
//           final ratio = maxRev > 0 ? s.revenue / maxRev : 0.0;
//           return Column(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
//                 child: Row(
//                   children: [
//                     SizedBox(
//                       width: 70,
//                       child: Text(
//                         _fmtDate(s.date),
//                         style: const TextStyle(
//                           fontSize: 11,
//                           color: rpText3,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                     Expanded(
//                       child: Stack(
//                         children: [
//                           Container(
//                             height: 8,
//                             decoration: BoxDecoration(
//                               color: rpBorder,
//                               borderRadius: BorderRadius.circular(4),
//                             ),
//                           ),
//                           FractionallySizedBox(
//                             widthFactor: ratio,
//                             child: Container(
//                               height: 8,
//                               decoration: BoxDecoration(
//                                 color: rpAccent,
//                                 borderRadius: BorderRadius.circular(4),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(width: 10),
//                     SizedBox(
//                       width: 74,
//                       child: Text(
//                         '₹${s.revenue.toStringAsFixed(2)}',
//                         style: const TextStyle(
//                           fontSize: 12,
//                           fontWeight: FontWeight.w700,
//                           color: rpText1,
//                         ),
//                         textAlign: TextAlign.right,
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     SizedBox(
//                       width: 28,
//                       child: Text(
//                         '${s.orders}',
//                         style: const TextStyle(fontSize: 11, color: rpText3),
//                         textAlign: TextAlign.right,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               if (i < items.length - 1)
//                 Divider(color: rpBorder, height: 1, indent: 14, endIndent: 14),
//             ],
//           );
//         }).toList(),
//       ),
//     );
//   }
//
//   String _fmtDate(String d) {
//     try {
//       final parsed = DateTime.parse(
//         d,
//       ).add(const Duration(hours: 5, minutes: 30));
//       return DateFormat('dd MMM yy').format(parsed);
//     } catch (_) {
//       return d;
//     }
//   }
// }

// ─── Category revenue breakdown (commented) ───────────────────────────────────
// class _CategoryRevenue extends StatelessWidget {
//   final Map<String, double> data;
//   final double total;
//   const _CategoryRevenue({required this.data, required this.total});
//
//   static const _colors = [rpAccent, rpBlue, rpGreen, rpPurple, rpAmber, rpRed];
//
//   @override
//   Widget build(BuildContext context) {
//     final fmt = NumberFormat('#,##,###');
//     final entries = data.entries.toList()
//       ..sort((a, b) => b.value.compareTo(a.value));
//     return Container(
//       decoration: rpCardDeco(),
//       padding: const EdgeInsets.all(14),
//       child: Column(
//         children: entries.asMap().entries.map((e) {
//           final idx = e.key;
//           final cat = e.value.key;
//           final rev = e.value.value;
//           final color = _colors[idx % _colors.length];
//           final pct = total > 0 ? rev / total : 0.0;
//           final isLast = idx == entries.length - 1;
//           return Column(
//             children: [
//               Row(
//                 children: [
//                   Container(
//                     width: 10,
//                     height: 10,
//                     decoration: BoxDecoration(
//                       color: color,
//                       borderRadius: BorderRadius.circular(3),
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   Expanded(
//                     child: Text(
//                       cat.trim(),
//                       style: const TextStyle(
//                         fontSize: 13,
//                         color: rpText1,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//                   Text(
//                     '${(pct * 100).toStringAsFixed(1)}%',
//                     style: const TextStyle(fontSize: 11, color: rpText3),
//                   ),
//                   const SizedBox(width: 10),
//                   Text(
//                     '₹${e.value.value.toStringAsFixed(2)}',
//                     style: TextStyle(
//                       fontSize: 12,
//                       color: color,
//                       fontWeight: FontWeight.w700,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 6),
//               ClipRRect(
//                 borderRadius: BorderRadius.circular(4),
//                 child: LinearProgressIndicator(
//                   value: pct,
//                   backgroundColor: rpBorder,
//                   color: color,
//                   minHeight: 6,
//                 ),
//               ),
//               if (!isLast) const SizedBox(height: 12),
//               if (!isLast) Divider(color: rpBorder, height: 1),
//               if (!isLast) const SizedBox(height: 4),
//             ],
//           );
//         }).toList(),
//       ),
//     );
//   }
// }
