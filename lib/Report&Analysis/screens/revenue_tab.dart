// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import '../models/report_models.dart';
// import '../widgets/theme.dart';
//
// class RevenueTab extends StatelessWidget {
//   final ReportData? data;
//   final bool isLoading;
//   const RevenueTab({super.key, this.data, this.isLoading = false});
//
//   static const _methodConfig = {
//     'CASH': (label: 'Cash', color: rpGreen, icon: Icons.payments_outlined),
//     'USER_ONLINE_PAYMENT': (
//       label: 'Online',
//       color: rpBlue,
//       icon: Icons.credit_card_outlined,
//     ),
//     'UPI': (label: 'UPI', color: rpPurple, icon: Icons.qr_code_2_outlined),
//     'MAAMAAS_WALLET': (
//       label: 'Wallet',
//       color: rpAmber,
//       icon: Icons.account_balance_wallet_outlined,
//     ),
//     'QR_PAYMENT': (
//       label: 'QR Payment',
//       color: rpBlue,
//       icon: Icons.qr_code_scanner_outlined,
//     ),
//   };
//
//   @override
//   Widget build(BuildContext context) {
//     if (isLoading) return const RpShimmerCard(height: 400);
//     if (data == null)
//       return const RpEmpty(
//         message: 'No revenue data.',
//         icon: Icons.trending_up_outlined,
//       );
//
//     final discount = (data!.grossRevenue - data!.totalRevenue).clamp(
//       0.0,
//       double.infinity,
//     );
//
//     final totalCollected = data!.paymentBreakdown.entries
//         .where((e) => e.key != 'Online_Payment')
//         .fold(0.0, (s, e) => s + e.value);
//
//     final totalTips = data!.totalTipAmount;
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // ── Unified Stats Card ─────────────────────────────────────────────
//         Container(
//           margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
//           decoration: _rpCardDecoWithShadow(),
//           child: Padding(
//             padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
//             child: Column(
//               children: [
//                 Row(
//                   children: [
//                     Expanded(
//                       child: _statCell(
//                         data!.grossRevenue.toStringAsFixed(2),
//                         'Total Revenue',
//                         rpBlue,
//                         Icons.account_balance_outlined,
//                       ),
//                     ),
//                     _vertDivider(),
//                     Expanded(
//                       child: _statCell(
//                         data!.refundAmount.toStringAsFixed(2),
//                         'Total Refund',
//                         rpRed,
//                         Icons.undo_rounded,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 12),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: _statCell(
//                         discount.toStringAsFixed(2),
//                         'Discount Given',
//                         rpAmber,
//                         Icons.local_offer_outlined,
//                       ),
//                     ),
//                     _vertDivider(),
//                     Expanded(
//                       child: _statCell(
//                         totalTips.toStringAsFixed(2),
//                         'Total Tips',
//                         rpPurple,
//                         Icons.volunteer_activism_outlined,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//         const SizedBox(height: 16),
//
//         // ── REVENUE BY PAYMENT MODE (including Tips) ──────────────────────
//         const RpSectionHeader(title: 'Revenue by Payment Mode'),
//         Container(
//           decoration: rpCardDeco(),
//           padding: const EdgeInsets.all(14),
//           child: Column(
//             children: [
//               // Payment methods breakdown
//               ...data!.paymentBreakdown.entries.map((e) {
//                 final normalizedKey = e.key.trim().toUpperCase();
//                 final cfg = _methodConfig[normalizedKey];
//
//                 // Hide if enum not configured
//                 if (cfg == null) {
//                   return const SizedBox.shrink();
//                 }
//
//                 final label = cfg.label;
//                 final color = cfg.color;
//
//                 final pct = totalCollected > 0
//                     ? (e.value / totalCollected) * 100
//                     : 0.0;
//
//                 return Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 6),
//                   child: Row(
//                     children: [
//                       Container(
//                         width: 10,
//                         height: 10,
//                         decoration: BoxDecoration(
//                           color: color,
//                           shape: BoxShape.circle,
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       Expanded(
//                         child: Text(
//                           label,
//                           style: const TextStyle(fontSize: 13, color: rpText2),
//                         ),
//                       ),
//                       Text(
//                         '${e.value.toStringAsFixed(2)} (${pct.toStringAsFixed(1)}%)',
//                         style: TextStyle(
//                           fontSize: 13,
//                           fontWeight: FontWeight.w700,
//                           color: color,
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               }).toList(),
//
//               // Add Tips as a separate row if totalTips > 0
//               if (totalTips > 0) ...[
//                 const SizedBox(height: 8),
//                 const Divider(color: rpBorder, height: 1),
//                 const SizedBox(height: 8),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 6),
//                   child: Row(
//                     children: [
//                       Container(
//                         width: 10,
//                         height: 10,
//                         decoration: BoxDecoration(
//                           color: rpPurple,
//                           shape: BoxShape.circle,
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       const Expanded(
//                         child: Text(
//                           'Tips',
//                           style: TextStyle(fontSize: 13, color: rpText2),
//                         ),
//                       ),
//                       Text(
//                         totalTips.toStringAsFixed(2),
//                         style: const TextStyle(
//                           fontSize: 13,
//                           fontWeight: FontWeight.w700,
//                           color: rpPurple,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//
//               if (data!.pendingPayments > 0) ...[
//                 const SizedBox(height: 10),
//                 Row(
//                   children: [
//                     const Expanded(
//                       child: Text(
//                         'Pending Payments',
//                         style: TextStyle(
//                           fontWeight: FontWeight.w600,
//                           fontSize: 13,
//                           color: rpText2,
//                         ),
//                       ),
//                     ),
//                     Text(
//                       data!.pendingPayments.toStringAsFixed(2),
//                       style: const TextStyle(
//                         fontWeight: FontWeight.w700,
//                         fontSize: 13,
//                         color: rpAmber,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ],
//           ),
//         ),
//
//         const SizedBox(height: 16),
//
//         // ── Items by Category (Detailed breakdown) ─────────────────────────
//         if (data!.allItemsByCategory.isNotEmpty) ...[
//           const RpSectionHeader(title: 'Revenue by Category'),
//           _ItemsByCategory(data: data!.allItemsByCategory),
//           const SizedBox(height: 16),
//         ],
//       ],
//     );
//   }
//
//   Widget _statCell(
//     String value,
//     String label,
//     Color color,
//     IconData icon, {
//     String? sub,
//   }) {
//     return Column(
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(icon, size: 16, color: color),
//             const SizedBox(width: 4),
//             Text(
//               label,
//               style: const TextStyle(
//                 fontSize: 12,
//                 color: rpText2,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 6),
//         Text(
//           value,
//           style: const TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//             color: rpText1,
//           ),
//         ),
//         if (sub != null) ...[
//           const SizedBox(height: 2),
//           Text(
//             sub,
//             style: TextStyle(
//               fontSize: 11,
//               color: color,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ],
//       ],
//     );
//   }
//
//   Widget _vertDivider() {
//     return Container(
//       width: 1,
//       height: 50,
//       color: rpBorder,
//       margin: const EdgeInsets.symmetric(horizontal: 8),
//     );
//   }
//
//   BoxDecoration _rpCardDecoWithShadow() {
//     return BoxDecoration(
//       color: Colors.white,
//       borderRadius: BorderRadius.circular(16),
//       border: Border.all(color: rpBorder),
//       boxShadow: [
//         BoxShadow(color: rpShadow, blurRadius: 8, offset: const Offset(0, 3)),
//       ],
//     );
//   }
// }
//
// class _CategoryBars extends StatelessWidget {
//   final Map<String, double> data;
//   final double total;
//   static const _colors = [rpAccent, rpBlue, rpGreen, rpPurple];
//   const _CategoryBars({required this.data, required this.total});
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
//           final color = _colors[e.key % _colors.length];
//           final pct = total > 0 ? e.value.value / total : 0.0;
//           return Padding(
//             padding: const EdgeInsets.only(bottom: 10),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Expanded(
//                       child: Text(
//                         e.value.key.trim(),
//                         style: const TextStyle(fontSize: 12, color: rpText2),
//                       ),
//                     ),
//                     Text(
//                       '₹${fmt.format(e.value.value.round())}',
//                       style: TextStyle(
//                         fontSize: 12,
//                         color: color,
//                         fontWeight: FontWeight.w700,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 4),
//                 ClipRRect(
//                   borderRadius: BorderRadius.circular(4),
//                   child: LinearProgressIndicator(
//                     value: pct,
//                     backgroundColor: rpBorder,
//                     color: color,
//                     minHeight: 7,
//                   ),
//                 ),
//               ],
//             ),
//           );
//         }).toList(),
//       ),
//     );
//   }
// }
//
// // ── Items by Category Widget (Collapsible categories with items) ─────────────
// class _ItemsByCategory extends StatefulWidget {
//   final Map<String, List<CategoryItem>> data;
//   const _ItemsByCategory({required this.data});
//
//   @override
//   State<_ItemsByCategory> createState() => _ItemsByCategoryState();
// }
//
// class _ItemsByCategoryState extends State<_ItemsByCategory> {
//   final Set<String> _expanded = {};
//   static const _colors = [rpAccent, rpBlue, rpGreen, rpPurple, rpAmber];
//
//   @override
//   void initState() {
//     super.initState();
//     if (widget.data.isNotEmpty) _expanded.add(widget.data.keys.first);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final fmt = NumberFormat('#,##,###');
//     final entries = widget.data.entries.toList()
//       ..sort((a, b) {
//         final totalA = a.value.fold(0.0, (s, i) => s + i.revenue);
//         final totalB = b.value.fold(0.0, (s, i) => s + i.revenue);
//         return totalB.compareTo(totalA);
//       });
//     return Column(
//       children: entries.asMap().entries.map((e) {
//         final idx = e.key;
//         final cat = e.value.key.trim();
//         final items = e.value.value;
//         final color = _colors[idx % _colors.length];
//         final isExp = _expanded.contains(cat);
//         final catTotal = items.fold(0.0, (s, i) => s + i.revenue);
//         items.fold(0, (s, i) => s + i.quantity);
//
//         return Container(
//           margin: const EdgeInsets.only(bottom: 10),
//           decoration: rpCardDeco(),
//           child: Column(
//             children: [
//               GestureDetector(
//                 onTap: () => setState(
//                   () => isExp ? _expanded.remove(cat) : _expanded.add(cat),
//                 ),
//                 child: Container(
//                   padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
//                   decoration: BoxDecoration(
//                     color: color.withOpacity(0.05),
//                     borderRadius: BorderRadius.vertical(
//                       top: const Radius.circular(14),
//                       bottom: Radius.circular(isExp ? 0 : 14),
//                     ),
//                   ),
//                   child: Row(
//                     children: [
//                       Container(
//                         width: 10,
//                         height: 10,
//                         decoration: BoxDecoration(
//                           color: color,
//                           borderRadius: BorderRadius.circular(3),
//                         ),
//                       ),
//                       const SizedBox(width: 10),
//                       Expanded(
//                         child: Text(
//                           cat,
//                           style: TextStyle(
//                             fontWeight: FontWeight.w700,
//                             fontSize: 14,
//                             color: color,
//                           ),
//                         ),
//                       ),
//
//                       Text(
//                         '₹${fmt.format(catTotal.round())}',
//                         style: TextStyle(
//                           fontSize: 13,
//                           fontWeight: FontWeight.w700,
//                           color: color,
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       Icon(
//                         isExp
//                             ? Icons.keyboard_arrow_up_rounded
//                             : Icons.keyboard_arrow_down_rounded,
//                         color: color,
//                         size: 20,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               if (isExp)
//                 Column(
//                   children: items.asMap().entries.map((ie) {
//                     final ii = ie.key;
//                     final item = ie.value;
//                     return Column(
//                       children: [
//                         Padding(
//                           padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
//                           child: Row(
//                             children: [
//                               Container(
//                                 width: 24,
//                                 height: 24,
//                                 decoration: BoxDecoration(
//                                   color: color.withOpacity(0.1),
//                                   borderRadius: BorderRadius.circular(6),
//                                 ),
//                                 child: Center(
//                                   child: Text(
//                                     '${ii + 1}',
//                                     style: TextStyle(
//                                       fontSize: 10,
//                                       fontWeight: FontWeight.w800,
//                                       color: color,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                               const SizedBox(width: 10),
//                               Expanded(
//                                 child: Text(
//                                   item.item,
//                                   style: const TextStyle(
//                                     fontSize: 13,
//                                     color: rpText1,
//                                   ),
//                                   maxLines: 2,
//                                   overflow: TextOverflow.ellipsis,
//                                 ),
//                               ),
//                               const SizedBox(width: 8),
//                               Column(
//                                 crossAxisAlignment: CrossAxisAlignment.end,
//                                 children: [
//                                   Text(
//                                     '₹${fmt.format(item.revenue.round())}',
//                                     style: TextStyle(
//                                       fontSize: 12,
//                                       fontWeight: FontWeight.w700,
//                                       color: color,
//                                     ),
//                                   ),
//                                   Text(
//                                     'qty: ${item.quantity}',
//                                     style: const TextStyle(
//                                       fontSize: 10,
//                                       color: rpText3,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ),
//                         if (ii < items.length - 1)
//                           Divider(
//                             color: rpBorder,
//                             height: 1,
//                             indent: 48,
//                             endIndent: 14,
//                           ),
//                       ],
//                     );
//                   }).toList(),
//                 ),
//             ],
//           ),
//         );
//       }).toList(),
//     );
//   }
// }
//
// class _DailyList extends StatelessWidget {
//   final List<DailyStat> items;
//   const _DailyList({required this.items});
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
//                       width: 72,
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
//                       width: 76,
//                       child: Text(
//                         '₹${fmt.format(s.revenue.round())}',
//                         style: const TextStyle(
//                           fontSize: 12,
//                           fontWeight: FontWeight.w700,
//                           color: rpText1,
//                         ),
//                         textAlign: TextAlign.right,
//                       ),
//                     ),
//                     const SizedBox(width: 6),
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

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/report_models.dart';
import '../widgets/theme.dart';

class RevenueTab extends StatelessWidget {
  final ReportData? data;
  final bool isLoading;
  const RevenueTab({super.key, this.data, this.isLoading = false});

  static const _methodConfig = {
    'CASH': (label: 'Cash', color: rpGreen, icon: Icons.payments_outlined),
    'USER_ONLINE_PAYMENT': (
      label: 'Online',
      color: rpBlue,
      icon: Icons.credit_card_outlined,
    ),
    'UPI': (label: 'UPI', color: rpPurple, icon: Icons.qr_code_2_outlined),
    'MAAMAAS_WALLET': (
      label: 'Wallet',
      color: rpAmber,
      icon: Icons.account_balance_wallet_outlined,
    ),
    'QR_PAYMENT': (
      label: 'QR Payment',
      color: rpBlue,
      icon: Icons.qr_code_scanner_outlined,
    ),
  };

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const RpShimmerCard(height: 400);
    if (data == null)
      return const RpEmpty(
        message: 'No revenue data.',
        icon: Icons.trending_up_outlined,
      );

    final discount = (data!.grossRevenue - data!.totalRevenue).clamp(
      0.0,
      double.infinity,
    );

    final totalCollected = data!.paymentBreakdown.entries
        .where((e) => e.key != 'Online_Payment')
        .fold(0.0, (s, e) => s + e.value);

    final totalTips = data!.totalTipAmount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Unified Stats Card ─────────────────────────────────────────────
        Container(
          margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          decoration: _rpCardDecoWithShadow(),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _statCell(
                        data!.grossRevenue.toStringAsFixed(2),
                        'Total Revenue',
                        rpBlue,
                        Icons.account_balance_outlined,
                      ),
                    ),
                    _vertDivider(),
                    Expanded(
                      child: _statCell(
                        data!.refundAmount.toStringAsFixed(2),
                        'Total Refund',
                        rpRed,
                        Icons.undo_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _statCell(
                        discount.toStringAsFixed(2),
                        'Discount Given',
                        rpAmber,
                        Icons.local_offer_outlined,
                      ),
                    ),
                    _vertDivider(),
                    Expanded(
                      child: _statCell(
                        totalTips.toStringAsFixed(2),
                        'Total Tips',
                        rpPurple,
                        Icons.volunteer_activism_outlined,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // ── REVENUE BY PAYMENT MODE (including Tips) ──────────────────────
        const RpSectionHeader(title: 'Revenue by Payment Mode'),
        Container(
          decoration: rpCardDeco(),
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              // Payment methods breakdown
              ...data!.paymentBreakdown.entries.map((e) {
                final normalizedKey = e.key.trim().toUpperCase();
                final cfg = _methodConfig[normalizedKey];

                // Hide if enum not configured
                if (cfg == null) {
                  return const SizedBox.shrink();
                }

                final label = cfg.label;
                final color = cfg.color;

                final pct = totalCollected > 0
                    ? (e.value / totalCollected) * 100
                    : 0.0;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          label,
                          style: const TextStyle(fontSize: 13, color: rpText2),
                        ),
                      ),
                      Text(
                        '${e.value.toStringAsFixed(2)} (${pct.toStringAsFixed(1)}%)',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),

              // Add Tips as a separate row if totalTips > 0
              if (totalTips > 0) ...[
                const SizedBox(height: 8),
                const Divider(color: rpBorder, height: 1),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: rpPurple,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Tips',
                          style: TextStyle(fontSize: 13, color: rpText2),
                        ),
                      ),
                      Text(
                        totalTips.toStringAsFixed(2),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: rpPurple,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              if (data!.pendingPayments > 0) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Pending Payments',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: rpText2,
                        ),
                      ),
                    ),
                    Text(
                      data!.pendingPayments.toStringAsFixed(2),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: rpAmber,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 16),

        // ── Items by Category (Detailed breakdown) ─────────────────────────
        if (data!.allItemsByCategory.isNotEmpty) ...[
          const RpSectionHeader(title: 'Revenue by Category'),
          _ItemsByCategory(data: data!.allItemsByCategory),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _statCell(
    String value,
    String label,
    Color color,
    IconData icon, {
    String? sub,
  }) {
    return Column(
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
  }

  Widget _vertDivider() {
    return Container(
      width: 1,
      height: 50,
      color: rpBorder,
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  BoxDecoration _rpCardDecoWithShadow() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: rpBorder),
      boxShadow: [
        BoxShadow(color: rpShadow, blurRadius: 8, offset: const Offset(0, 3)),
      ],
    );
  }
}

class _CategoryBars extends StatelessWidget {
  final Map<String, double> data;
  final double total;
  static const _colors = [rpAccent, rpBlue, rpGreen, rpPurple];
  const _CategoryBars({required this.data, required this.total});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##,###');
    final entries = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Container(
      decoration: rpCardDeco(),
      padding: const EdgeInsets.all(14),
      child: Column(
        children: entries.asMap().entries.map((e) {
          final color = _colors[e.key % _colors.length];
          final pct = total > 0 ? e.value.value / total : 0.0;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        e.value.key.trim(),
                        style: const TextStyle(fontSize: 12, color: rpText2),
                      ),
                    ),
                    Text(
                      '₹${fmt.format(e.value.value.round())}',
                      style: TextStyle(
                        fontSize: 12,
                        color: color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct,
                    backgroundColor: rpBorder,
                    color: color,
                    minHeight: 7,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Items by Category Widget (Category -> SubCategory -> Dishes) ────────────
class _ItemsByCategory extends StatefulWidget {
  final Map<String, Map<String, List<CategoryItem>>> data;
  const _ItemsByCategory({required this.data});

  @override
  State<_ItemsByCategory> createState() => _ItemsByCategoryState();
}

class _ItemsByCategoryState extends State<_ItemsByCategory> {
  final Set<String> _expanded = {};
  static const _colors = [rpAccent, rpBlue, rpGreen, rpPurple, rpAmber];

  static bool _isUnknownSub(String key) =>
      key.trim().toUpperCase() == 'UNKNOWN_SUBCATEGORY';

  double _catTotal(Map<String, List<CategoryItem>> subMap) {
    var total = 0.0;
    for (final items in subMap.values) {
      total += items.fold(0.0, (s, i) => s + i.revenue);
    }
    return total;
  }

  @override
  void initState() {
    super.initState();
    if (widget.data.isNotEmpty) _expanded.add(widget.data.keys.first);
  }

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##,###');
    final entries = widget.data.entries.toList()
      ..sort((a, b) => _catTotal(b.value).compareTo(_catTotal(a.value)));

    return Column(
      children: entries.asMap().entries.map((e) {
        final idx = e.key;
        final cat = e.value.key.trim();
        final subMap = e.value.value;
        final color = _colors[idx % _colors.length];
        final isExp = _expanded.contains(cat);
        final catTotal = _catTotal(subMap);

        // Sort subcategories by their own revenue, descending
        final subEntries = subMap.entries.toList()
          ..sort((a, b) {
            final ta = a.value.fold(0.0, (s, i) => s + i.revenue);
            final tb = b.value.fold(0.0, (s, i) => s + i.revenue);
            return tb.compareTo(ta);
          });

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: rpCardDeco(),
          child: Column(
            children: [
              GestureDetector(
                onTap: () => setState(
                  () => isExp ? _expanded.remove(cat) : _expanded.add(cat),
                ),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.05),
                    borderRadius: BorderRadius.vertical(
                      top: const Radius.circular(14),
                      bottom: Radius.circular(isExp ? 0 : 14),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          cat,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: color,
                          ),
                        ),
                      ),

                      Text(
                        '₹${fmt.format(catTotal.round())}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        isExp
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        color: color,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
              if (isExp)
                Column(
                  children: subEntries.map((subEntry) {
                    final subKey = subEntry.key.trim();
                    final items = subEntry.value;
                    final showSubHeader =
                        !_isUnknownSub(subKey) && subKey.isNotEmpty;
                    final isLastSub = subEntry == subEntries.last;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (showSubHeader)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
                            child: Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: color.withOpacity(0.6),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  subKey,
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    color: rpText3,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ...items.asMap().entries.map((ie) {
                          final ii = ie.key;
                          final item = ie.value;
                          final isLastInSub = ii == items.length - 1;
                          final isVeryLast = isLastInSub && isLastSub;

                          return Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.fromLTRB(
                                  showSubHeader ? 26 : 14,
                                  8,
                                  14,
                                  8,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 22,
                                      height: 22,
                                      decoration: BoxDecoration(
                                        color: color.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${ii + 1}',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                            color: color,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        item.dish,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: rpText1,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '₹${fmt.format(item.revenue.round())}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: color,
                                          ),
                                        ),
                                        Text(
                                          'qty: ${item.quantity}',
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: rpText3,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              if (!isVeryLast)
                                Divider(
                                  color: rpBorder,
                                  height: 1,
                                  indent: showSubHeader ? 60 : 48,
                                  endIndent: 14,
                                ),
                            ],
                          );
                        }),
                      ],
                    );
                  }).toList(),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _DailyList extends StatelessWidget {
  final List<DailyStat> items;
  const _DailyList({required this.items});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##,###');
    final maxRev = items.fold(0.0, (m, e) => e.revenue > m ? e.revenue : m);
    return Container(
      decoration: rpCardDeco(),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final i = entry.key;
          final s = entry.value;
          final ratio = maxRev > 0 ? s.revenue / maxRev : 0.0;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                child: Row(
                  children: [
                    SizedBox(
                      width: 72,
                      child: Text(
                        _fmtDate(s.date),
                        style: const TextStyle(
                          fontSize: 11,
                          color: rpText3,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Stack(
                        children: [
                          Container(
                            height: 8,
                            decoration: BoxDecoration(
                              color: rpBorder,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: ratio,
                            child: Container(
                              height: 8,
                              decoration: BoxDecoration(
                                color: rpAccent,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 76,
                      child: Text(
                        '₹${fmt.format(s.revenue.round())}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: rpText1,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                    const SizedBox(width: 6),
                    SizedBox(
                      width: 28,
                      child: Text(
                        '${s.orders}',
                        style: const TextStyle(fontSize: 11, color: rpText3),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ),
              if (i < items.length - 1)
                Divider(color: rpBorder, height: 1, indent: 14, endIndent: 14),
            ],
          );
        }).toList(),
      ),
    );
  }

  String _fmtDate(String d) {
    try {
      final parsed = DateTime.parse(
        d,
      ).add(const Duration(hours: 5, minutes: 30));
      return DateFormat('dd MMM yy').format(parsed);
    } catch (_) {
      return d;
    }
  }
}
