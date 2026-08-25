// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import '../models/report_models.dart';
// import '../widgets/theme.dart';
//
// class OrdersTab extends StatelessWidget {
//   final ReportData? data;
//   final bool isLoading;
//   const OrdersTab({super.key, this.data, this.isLoading = false});
//
//   String _fmtN(int v) => NumberFormat('#,##,###').format(v);
//
//   @override
//   Widget build(BuildContext context) {
//     if (isLoading) return _shimmer();
//     if (data == null)
//       return const RpEmpty(
//         message: 'No orders data.',
//         icon: Icons.receipt_long_outlined,
//       );
//
//     final completionPct = data!.totalOrders > 0
//         ? data!.completedOrders / data!.totalOrders
//         : 0.0;
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // ── Stats Card (Total Orders, Completed, Cancelled, Avg Value) ──────────
//         Container(
//           margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
//           decoration: _rpCardDecoWithShadow(),
//           child: Padding(
//             padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
//             child: Column(
//               children: [
//                 // First row: Total Orders & Completed
//                 Row(
//                   children: [
//                     Expanded(
//                       child: _statCell(
//                         _fmtN(data!.totalOrders),
//                         'Total Orders',
//                         rpBlue,
//                         Icons.receipt_long_outlined,
//                       ),
//                     ),
//                     _vertDivider(),
//                     Expanded(
//                       child: _statCell(
//                         _fmtN(data!.completedOrders),
//                         'Completed',
//                         rpGreen,
//                         Icons.check_circle_outline,
//                         sub: '${(completionPct * 100).toStringAsFixed(0)}%',
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 12),
//                 // Second row: Cancelled & Avg Value
//                 Row(
//                   children: [
//                     Expanded(
//                       child: _statCell(
//                         _fmtN(data!.cancelledOrders),
//                         'Cancelled',
//                         rpRed,
//                         Icons.cancel_outlined,
//                       ),
//                     ),
//                     _vertDivider(),
//                     Expanded(
//                       child: _statCell(
//                         data!.avgOrderValue.toStringAsFixed(2),
//                         'Avg Value',
//                         rpAccent,
//                         Icons.price_change_outlined,
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
//         const RpSectionHeader(title: 'Live Status'),
//         Container(
//           decoration: _rpCardDecoWithShadow(),
//           child: Padding(
//             padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: _statCell(
//                     _fmtN(data!.preparingOrders),
//                     'Preparing',
//                     rpAmber,
//                     Icons.restaurant_outlined,
//                   ),
//                 ),
//                 _vertDivider(),
//                 Expanded(
//                   child: _statCell(
//                     _fmtN(data!.onTheWayOrders),
//                     'On The Way',
//                     rpBlue,
//                     Icons.delivery_dining_outlined,
//                   ),
//                 ),
//                 _vertDivider(),
//                 Expanded(
//                   child: _statCell(
//                     _fmtN(data!.pendingOrders),
//                     'Pending',
//                     rpRed,
//                     Icons.pending_outlined,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//         const SizedBox(height: 16),
//
//         // ── Order types ─────────────────────────────────────────────────────────
//         const RpSectionHeader(title: 'Order Types'),
//         Container(
//           decoration: rpCardDeco(),
//           padding: const EdgeInsets.all(14),
//           child: Column(
//             children: [
//               _typeRow(
//                 'Dine In',
//                 data!.dineInOrders,
//                 data!.totalOrders,
//                 rpAccent,
//                 Icons.table_restaurant_outlined,
//               ),
//               const Divider(color: rpBorder, height: 16),
//               _typeRow(
//                 'Takeaway',
//                 data!.takeawayOrders,
//                 data!.totalOrders,
//                 rpBlue,
//                 Icons.shopping_bag_outlined,
//               ),
//               const Divider(color: rpBorder, height: 16),
//               _typeRow(
//                 'Delivery',
//                 data!.deliveryOrders,
//                 data!.totalOrders,
//                 rpGreen,
//                 Icons.delivery_dining_outlined,
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(height: 16),
//
//         // ── Items by category ───────────────────────────────────────────────────
//         if (data!.allItemsByCategory.isNotEmpty) ...[
//           const RpSectionHeader(title: 'Items Sold by Category'),
//           _ItemsByCategory(data: data!.allItemsByCategory),
//         ],
//       ],
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
//           style: TextStyle(
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
//       height: 60,
//       color: rpBorder,
//       margin: const EdgeInsets.symmetric(horizontal: 8),
//     );
//   }
//
//   Widget _typeRow(
//     String label,
//     int count,
//     int total,
//     Color color,
//     IconData icon,
//   ) {
//     final pct = total > 0 ? count / total : 0.0;
//     return Row(
//       children: [
//         Container(
//           width: 32,
//           height: 32,
//           decoration: BoxDecoration(
//             color: color.withOpacity(0.12),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Icon(icon, color: color, size: 16),
//         ),
//         const SizedBox(width: 10),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Text(
//                     label,
//                     style: const TextStyle(
//                       fontSize: 13,
//                       color: rpText1,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   const Spacer(),
//                   Text(
//                     '$count orders',
//                     style: TextStyle(
//                       fontSize: 12,
//                       color: color,
//                       fontWeight: FontWeight.w700,
//                     ),
//                   ),
//                   const SizedBox(width: 6),
//                   Text(
//                     '${(pct * 100).toStringAsFixed(0)}%',
//                     style: const TextStyle(fontSize: 10, color: rpText3),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 5),
//               ClipRRect(
//                 borderRadius: BorderRadius.circular(4),
//                 child: LinearProgressIndicator(
//                   value: pct,
//                   backgroundColor: rpBorder,
//                   color: color,
//                   minHeight: 6,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _shimmer() => Column(
//     children: [
//       Container(
//         margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
//         height: 140,
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
//       Container(
//         height: 100,
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
//       const RpShimmerCard(height: 120),
//       const SizedBox(height: 16),
//       const RpShimmerCard(height: 200),
//     ],
//   );
// }
//
// // ─── Items by category expandable list ───────────────────────────────────────
//
// class _ItemsByCategory extends StatefulWidget {
//   final Map<String, List<CategoryItem>> data;
//   const _ItemsByCategory({required this.data});
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
//         final qtyA = a.value.fold(0, (s, i) => s + i.quantity);
//         final qtyB = b.value.fold(0, (s, i) => s + i.quantity);
//         return qtyB.compareTo(qtyA);
//       });
//     return Column(
//       children: entries.asMap().entries.map((e) {
//         final idx = e.key;
//         final cat = e.value.key.trim();
//         final items = e.value.value;
//         final color = _colors[idx % _colors.length];
//         final isExp = _expanded.contains(cat);
//         final catTotal = items.fold(0.0, (s, i) => s + i.revenue);
//         final catTotalQty = items.fold(0, (s, i) => s + i.quantity); // Calculate total quantity
//
//         return Container(
//           margin: const EdgeInsets.only(bottom: 10),
//           decoration: rpCardDeco(),
//           child: Column(
//             children: [
//               GestureDetector(
//                 onTap: () => setState(
//                       () => isExp ? _expanded.remove(cat) : _expanded.add(cat),
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
//                       Text(
//                         'Qty: ${fmt.format(catTotalQty)}',
//                         style: const TextStyle(
//                           fontSize: 11,
//                           color: rpText3,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       Text(
//                         '${items.length} items',
//                         style: const TextStyle(fontSize: 11, color: rpText3),
//                       ),
//                       const SizedBox(width: 8),
//                       // Text(
//                       //   '₹${fmt.format(catTotal.round())}',
//                       //   style: TextStyle(
//                       //     fontSize: 13,
//                       //     fontWeight: FontWeight.w700,
//                       //     color: color,
//                       //   ),
//                       // ),
//                       // const SizedBox(width: 8),
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
//                                   // Text(
//                                   //   '₹${fmt.format(item.revenue.round())}',
//                                   //   style: TextStyle(
//                                   //     fontSize: 12,
//                                   //     fontWeight: FontWeight.w700,
//                                   //     color: color,
//                                   //   ),
//                                   // ),
//                                   Text(
//                                     'Qty: ${item.quantity}',
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

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/report_models.dart';
import '../widgets/theme.dart';

class OrdersTab extends StatelessWidget {
  final ReportData? data;
  final bool isLoading;
  const OrdersTab({super.key, this.data, this.isLoading = false});

  String _fmtN(int v) => NumberFormat('#,##,###').format(v);

  @override
  Widget build(BuildContext context) {
    if (isLoading) return _shimmer();
    if (data == null)
      return const RpEmpty(
        message: 'No orders data.',
        icon: Icons.receipt_long_outlined,
      );

    final completionPct = data!.totalOrders > 0
        ? data!.completedOrders / data!.totalOrders
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Stats Card (Total Orders, Completed, Cancelled, Avg Value) ──────────
        Container(
          margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
          decoration: _rpCardDecoWithShadow(),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
            child: Column(
              children: [
                // First row: Total Orders & Completed
                Row(
                  children: [
                    Expanded(
                      child: _statCell(
                        _fmtN(data!.totalOrders),
                        'Total Orders',
                        rpBlue,
                        Icons.receipt_long_outlined,
                      ),
                    ),
                    _vertDivider(),
                    Expanded(
                      child: _statCell(
                        _fmtN(data!.completedOrders),
                        'Completed',
                        rpGreen,
                        Icons.check_circle_outline,
                        sub: '${(completionPct * 100).toStringAsFixed(0)}%',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Second row: Cancelled & Avg Value
                Row(
                  children: [
                    Expanded(
                      child: _statCell(
                        _fmtN(data!.cancelledOrders),
                        'Cancelled',
                        rpRed,
                        Icons.cancel_outlined,
                      ),
                    ),
                    _vertDivider(),
                    Expanded(
                      child: _statCell(
                        data!.avgOrderValue.toStringAsFixed(2),
                        'Avg Value',
                        rpAccent,
                        Icons.price_change_outlined,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        const RpSectionHeader(title: 'Live Status'),
        Container(
          decoration: _rpCardDecoWithShadow(),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
            child: Row(
              children: [
                Expanded(
                  child: _statCell(
                    _fmtN(data!.preparingOrders),
                    'Preparing',
                    rpAmber,
                    Icons.restaurant_outlined,
                  ),
                ),
                _vertDivider(),
                Expanded(
                  child: _statCell(
                    _fmtN(data!.onTheWayOrders),
                    'On The Way',
                    rpBlue,
                    Icons.delivery_dining_outlined,
                  ),
                ),
                _vertDivider(),
                Expanded(
                  child: _statCell(
                    _fmtN(data!.pendingOrders),
                    'Pending',
                    rpRed,
                    Icons.pending_outlined,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // ── Order types ─────────────────────────────────────────────────────────
        const RpSectionHeader(title: 'Order Types'),
        Container(
          decoration: rpCardDeco(),
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              _typeRow(
                'Dine In',
                data!.dineInOrders,
                data!.totalOrders,
                rpAccent,
                Icons.table_restaurant_outlined,
              ),
              const Divider(color: rpBorder, height: 16),
              _typeRow(
                'Takeaway',
                data!.takeawayOrders,
                data!.totalOrders,
                rpBlue,
                Icons.shopping_bag_outlined,
              ),
              const Divider(color: rpBorder, height: 16),
              _typeRow(
                'Delivery',
                data!.deliveryOrders,
                data!.totalOrders,
                rpGreen,
                Icons.delivery_dining_outlined,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ── Items by category ───────────────────────────────────────────────────
        if (data!.allItemsByCategory.isNotEmpty) ...[
          const RpSectionHeader(title: 'Items Sold by Category'),
          _ItemsByCategory(data: data!.allItemsByCategory),
        ],
      ],
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
          style: TextStyle(
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
      height: 60,
      color: rpBorder,
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  Widget _typeRow(
    String label,
    int count,
    int total,
    Color color,
    IconData icon,
  ) {
    final pct = total > 0 ? count / total : 0.0;
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 13,
                      color: rpText1,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '$count orders',
                    style: TextStyle(
                      fontSize: 12,
                      color: color,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${(pct * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(fontSize: 10, color: rpText3),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: pct,
                  backgroundColor: rpBorder,
                  color: color,
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _shimmer() => Column(
    children: [
      Container(
        margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        height: 140,
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
      Container(
        height: 100,
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
      const RpShimmerCard(height: 120),
      const SizedBox(height: 16),
      const RpShimmerCard(height: 200),
    ],
  );
}

// ─── Items by category expandable list (Category -> SubCategory -> Dishes) ───

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

  int _catTotalQty(Map<String, List<CategoryItem>> subMap) {
    var total = 0;
    for (final items in subMap.values) {
      total += items.fold(0, (s, i) => s + i.quantity);
    }
    return total;
  }

  int _catItemCount(Map<String, List<CategoryItem>> subMap) {
    var count = 0;
    for (final items in subMap.values) {
      count += items.length;
    }
    return count;
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
      ..sort((a, b) => _catTotalQty(b.value).compareTo(_catTotalQty(a.value)));

    return Column(
      children: entries.asMap().entries.map((e) {
        final idx = e.key;
        final cat = e.value.key.trim();
        final subMap = e.value.value;
        final color = _colors[idx % _colors.length];
        final isExp = _expanded.contains(cat);
        final catTotalQty = _catTotalQty(subMap);
        final catItemCount = _catItemCount(subMap);

        // Sort subcategories by their own quantity, descending
        final subEntries = subMap.entries.toList()
          ..sort((a, b) {
            final qa = a.value.fold(0, (s, i) => s + i.quantity);
            final qb = b.value.fold(0, (s, i) => s + i.quantity);
            return qb.compareTo(qa);
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
                        'Qty: ${fmt.format(catTotalQty)}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: rpText3,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$catItemCount items',
                        style: const TextStyle(fontSize: 11, color: rpText3),
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
                                      width: 24,
                                      height: 24,
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
                                    Text(
                                      'Qty: ${item.quantity}',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: rpText3,
                                      ),
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
