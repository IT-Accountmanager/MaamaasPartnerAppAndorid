//
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import '../models/report_models.dart';
// import '../widgets/theme.dart';
//
// // ─── Order Feedback Model ─────────────────────────────────────────────────────
// class OrderFeedback {
//   final int orderId;
//   final String feedback;
//   final int ratings;
//   final String status;
//   final String orderType;
//   final double grandTotal;
//   final String date;
//   final String? userName;
//   final String? phoneNumber;
//   final List<_OrderItem> items;
//
//   const OrderFeedback({
//     required this.orderId,
//     required this.feedback,
//     required this.ratings,
//     required this.status,
//     required this.orderType,
//     required this.grandTotal,
//     required this.date,
//     this.userName,
//     this.phoneNumber,
//     required this.items,
//   });
//
//   factory OrderFeedback.fromJson(Map<String, dynamic> j) {
//     final rawItems = j['order'];
//     final items = (rawItems is List)
//         ? rawItems
//         .whereType<Map<String, dynamic>>()
//         .map(_OrderItem.fromJson)
//         .toList()
//         : <_OrderItem>[];
//     return OrderFeedback(
//       orderId: _i(j['orderId']),
//       feedback: j['feedback']?.toString() ?? '',
//       ratings: _i(j['ratings']),
//       status: j['status']?.toString() ?? '',
//       orderType: j['orderType']?.toString() ?? '',
//       grandTotal: _d(j['grandTotal']),
//       date: j['date']?.toString() ?? '',
//       userName: j['userName']?.toString(),
//       phoneNumber: j['phoneNumber']?.toString() ?? j['mobileNo']?.toString(),
//       items: items,
//     );
//   }
// }
//
// class _OrderItem {
//   final String dishName;
//   final int quantity;
//   final double totalPrice;
//   final String category;
//
//   const _OrderItem({
//     required this.dishName,
//     required this.quantity,
//     required this.totalPrice,
//     required this.category,
//   });
//
//   factory _OrderItem.fromJson(Map<String, dynamic> j) => _OrderItem(
//     dishName: j['dishName']?.toString() ?? '',
//     quantity: _i(j['quantity']),
//     totalPrice: _d(j['totalPrice']),
//     category: j['category']?.toString() ?? '',
//   );
// }
//
// double _d(dynamic v) =>
//     (v is num) ? v.toDouble() : double.tryParse(v?.toString() ?? '') ?? 0.0;
// int _i(dynamic v) => (v is int) ? v : int.tryParse(v?.toString() ?? '') ?? 0;
//
// // ─── RatingTab ────────────────────────────────────────────────────────────────
// class RatingTab extends StatefulWidget {
//   final ReportData? data;
//   final bool isLoading;
//   const RatingTab({super.key, this.data, this.isLoading = false});
//
//   @override
//   State<RatingTab> createState() => _RatingTabState();
// }
//
// class _RatingTabState extends State<RatingTab> {
//   List<OrderFeedback> _feedbackList = [];
//   bool _feedbackLoading = true;
//   String? _feedbackError;
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchOrderFeedbacks();
//   }
//
//   Future<void> _fetchOrderFeedbacks() async {
//     setState(() {
//       _feedbackLoading = true;
//       _feedbackError = null;
//     });
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('token') ??
//           prefs.getString('authToken') ??
//           prefs.getString('auth_token') ??
//           '';
//       final vid = prefs.getInt('vendorId') ??
//           int.tryParse(prefs.getString('vendorId') ?? '') ??
//           0;
//
//       final uri = Uri.parse(
//         'http://staging.maamaas.com:8080/food/api/orders/vendor/$vid',
//       );
//       final res = await http.get(
//         uri,
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//       );
//
//       if (res.statusCode == 200) {
//         final body = jsonDecode(res.body);
//         final List<dynamic> raw = body is List
//             ? body
//             : (body['content'] ?? body['data'] ?? body['orders'] ?? []);
//
//         final withFeedback = raw
//             .whereType<Map<String, dynamic>>()
//             .map(OrderFeedback.fromJson)
//             .where((o) => o.feedback.trim().isNotEmpty)
//             .toList();
//
//         // Sort by orderId descending (newest first)
//         withFeedback.sort((a, b) => b.orderId.compareTo(a.orderId));
//
//         setState(() {
//           _feedbackList = withFeedback;
//           _feedbackLoading = false;
//         });
//       } else {
//         setState(() {
//           _feedbackError = 'Failed to load feedback (${res.statusCode})';
//           _feedbackLoading = false;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _feedbackError = 'Error: $e';
//         _feedbackLoading = false;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (widget.isLoading) return _shimmer();
//     if (widget.data == null)
//       return const RpEmpty(
//         message: 'No rating data.',
//         icon: Icons.star_outline_rounded,
//       );
//
//     final avgRating = double.tryParse(widget.data!.averageRating) ?? 0.0;
//     final totalRatings = widget.data!.totalRatings;
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // ── Unified Stats Card ─────────────────────────────────────────────
//         Container(
//           decoration: _rpCardDecoWithShadow(),
//           child: Padding(
//             padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
//             child: Column(
//               children: [
//                 Row(
//                   children: [
//                     Expanded(
//                       child: _statCell(
//                         avgRating == 0 ? 'N/A' : avgRating.toStringAsFixed(2),
//                         'Avg Rating',
//                         rpAmber,
//                         Icons.star_rounded,
//                       ),
//                     ),
//                     _vertDivider(),
//                     Expanded(
//                       child: _statCell(
//                         '$totalRatings',
//                         'Total Ratings',
//                         rpBlue,
//                         Icons.rate_review_outlined,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 12),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: _statCell(
//                         '$totalRatings',
//                         'Total Reviews',
//                         rpPurple,
//                         Icons.comment_outlined,
//                       ),
//                     ),
//                     _vertDivider(),
//                     Expanded(
//                       child: _statCell(
//                         widget.data!.ratingGrowthPercent == '0' ||
//                             widget.data!.ratingGrowthPercent == '0.00'
//                             ? '0%'
//                             : '${widget.data!.ratingGrowthPercent}%',
//                         'Rating Growth',
//                         rpGreen,
//                         Icons.trending_up_rounded,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//         const SizedBox(height: 20),
//
//         // ── Customer Feedback Section ──────────────────────────────────────
//         Row(
//           children: [
//             const Icon(Icons.feedback_outlined, color: rpBlue, size: 18),
//             const SizedBox(width: 6),
//             const Text(
//               'Customer Feedback',
//               style: TextStyle(
//                 fontSize: 15,
//                 fontWeight: FontWeight.w700,
//                 color: rpText1,
//               ),
//             ),
//             const Spacer(),
//             if (!_feedbackLoading)
//               Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 8,
//                   vertical: 3,
//                 ),
//                 decoration: BoxDecoration(
//                   color: rpBlue.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Text(
//                   '${_feedbackList.length} reviews',
//                   style: const TextStyle(
//                     fontSize: 11,
//                     color: rpBlue,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//           ],
//         ),
//         const SizedBox(height: 10),
//
//         if (_feedbackLoading)
//           _feedbackShimmer()
//         else if (_feedbackError != null)
//           _errorWidget(_feedbackError!)
//         else if (_feedbackList.isEmpty)
//             _noFeedbackWidget()
//           else
//             ..._feedbackList.map((order) => _feedbackCard(order)),
//       ],
//     );
//   }
//
//   // ─── Feedback Card ──────────────────────────────────────────────────────────
//   Widget _feedbackCard(OrderFeedback order) {
//     final starColor = order.ratings >= 4
//         ? rpGreen
//         : order.ratings == 3
//         ? rpAmber
//         : rpRed;
//
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       decoration: _rpCardDecoWithShadow(),
//       padding: const EdgeInsets.all(14),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // ── Header row: Order ID + Rating stars ─────────────────────────
//           Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 8,
//                   vertical: 4,
//                 ),
//                 decoration: BoxDecoration(
//                   color: rpBlue.withOpacity(0.08),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//
//                     const SizedBox(width: 4),
//                     Text(
//                       'OrderId : ${order.orderId}',
//                       style: const TextStyle(
//                         fontSize: 12,
//                         fontWeight: FontWeight.w700,
//                         color: rpBlue,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const Spacer(),
//               // Stars
//               Row(
//                 children: List.generate(5, (i) {
//                   return Icon(
//                     i < order.ratings
//                         ? Icons.star_rounded
//                         : Icons.star_outline_rounded,
//                     color: rpAmber,
//                     size: 16,
//                   );
//                 }),
//               ),
//               const SizedBox(width: 6),
//               Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 6,
//                   vertical: 2,
//                 ),
//                 decoration: BoxDecoration(
//                   color: starColor.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(6),
//                 ),
//                 child: Text(
//                   '${order.ratings}.0',
//                   style: TextStyle(
//                     fontSize: 11,
//                     fontWeight: FontWeight.w800,
//                     color: starColor,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 10),
//
//           // ── Feedback text ────────────────────────────────────────────────
//           Container(
//             width: double.infinity,
//             padding: const EdgeInsets.all(10),
//             decoration: BoxDecoration(
//               color: const Color(0xFFF8F9FB),
//               borderRadius: BorderRadius.circular(10),
//               border: Border.all(color: rpBorder),
//             ),
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const SizedBox(width: 6),
//                 Expanded(
//                   child: Text(
//                     order.feedback,
//                     style: const TextStyle(
//                       fontSize: 13,
//                       color: rpText1,
//                       fontWeight: FontWeight.w500,
//                       height: 1.4,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 10),
//
//           // ── Order items ──────────────────────────────────────────────────
//           if (order.items.isNotEmpty) ...[
//             Row(
//               children: [
//                 const Icon(Icons.fastfood_outlined, size: 13, color: rpText3),
//                 const SizedBox(width: 4),
//                 Text(
//                   order.items
//                       .map((i) => '${i.dishName} ×${i.quantity}')
//                       .join(', '),
//                   style: const TextStyle(fontSize: 12, color: rpText3),
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ],
//             ),
//             const SizedBox(height: 8),
//           ],
//
//           // ── Footer row: date, order type, amount ─────────────────────────
//           Row(
//             children: [
//               if (order.date.isNotEmpty) ...[
//                 const Icon(Icons.calendar_today_outlined,
//                     size: 12, color: rpText3),
//                 const SizedBox(width: 3),
//                 Text(
//                   order.date,
//                   style: const TextStyle(fontSize: 11, color: rpText3),
//                 ),
//                 const SizedBox(width: 10),
//               ],
//               _pill(_orderTypeIcon(order.orderType), order.orderType, rpPurple),
//               const Spacer(),
//               Text(
//                 '₹${order.grandTotal.toStringAsFixed(2)}',
//                 style: const TextStyle(
//                   fontSize: 13,
//                   fontWeight: FontWeight.w700,
//                   color: rpText1,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   IconData _orderTypeIcon(String type) {
//     switch (type.toUpperCase()) {
//       case 'DINE_IN':
//         return Icons.restaurant_outlined;
//       case 'TAKEAWAY':
//         return Icons.shopping_bag_outlined;
//       case 'DELIVERY':
//         return Icons.delivery_dining_outlined;
//       default:
//         return Icons.receipt_outlined;
//     }
//   }
//
//   Widget _pill(IconData icon, String label, Color color) => Container(
//     padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
//     decoration: BoxDecoration(
//       color: color.withOpacity(0.08),
//       borderRadius: BorderRadius.circular(6),
//     ),
//     child: Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Icon(icon, size: 11, color: color),
//         const SizedBox(width: 3),
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 10,
//             color: color,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ],
//     ),
//   );
//
//   Widget _errorWidget(String msg) => Container(
//     decoration: _rpCardDecoWithShadow(),
//     padding: const EdgeInsets.all(16),
//     child: Row(
//       children: [
//         const Icon(Icons.error_outline, color: rpRed, size: 18),
//         const SizedBox(width: 8),
//         Expanded(
//           child: Text(msg, style: const TextStyle(color: rpRed, fontSize: 13)),
//         ),
//         TextButton(
//           onPressed: _fetchOrderFeedbacks,
//           child: const Text('Retry'),
//         ),
//       ],
//     ),
//   );
//
//   Widget _noFeedbackWidget() => Container(
//     decoration: _rpCardDecoWithShadow(),
//     padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
//     child: const Center(
//       child: Column(
//         children: [
//           Icon(Icons.feedback_outlined, color: rpText3, size: 36),
//           SizedBox(height: 8),
//           Text(
//             'No customer feedback yet.',
//             style: TextStyle(color: rpText3, fontSize: 13),
//           ),
//         ],
//       ),
//     ),
//   );
//
//   Widget _feedbackShimmer() => Column(
//     children: List.generate(
//       3,
//           (_) => Container(
//         margin: const EdgeInsets.only(bottom: 12),
//         height: 120,
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(color: rpBorder),
//         ),
//         child: const Center(
//           child: CircularProgressIndicator(color: rpAccent, strokeWidth: 2),
//         ),
//       ),
//     ),
//   );
//
//   // ─── Existing helpers (unchanged) ──────────────────────────────────────────
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
//       String value,
//       String label,
//       Color color,
//       IconData icon, {
//         String? sub,
//       }) {
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
//       const RpShimmerCard(height: 200),
//       const SizedBox(height: 16),
//       const RpShimmerCard(height: 100),
//     ],
//   );
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../API/Apiclient.dart';
import '../models/report_models.dart';
import '../widgets/theme.dart';

class _LocalOrderFeedback {
  final int orderId;
  final String feedback;
  final int ratings;
  final String status;
  final String orderType;
  final double grandTotal;
  final String date;
  final String? userName;
  final String? phoneNumber;
  final List<_OrderItem> items;

  const _LocalOrderFeedback({
    required this.orderId,
    required this.feedback,
    required this.ratings,
    required this.status,
    required this.orderType,
    required this.grandTotal,
    required this.date,
    this.userName,
    this.phoneNumber,
    required this.items,
  });

  factory _LocalOrderFeedback.fromJson(Map<String, dynamic> j) {
    final rawItems = j['order'];
    final items = (rawItems is List)
        ? rawItems
              .whereType<Map<String, dynamic>>()
              .map(_OrderItem.fromJson)
              .toList()
        : <_OrderItem>[];
    return _LocalOrderFeedback(
      orderId: _i(j['orderId']),
      feedback: j['feedback']?.toString() ?? '',
      ratings: _i(j['ratings']),
      status: j['status']?.toString() ?? '',
      orderType: j['orderType']?.toString() ?? '',
      grandTotal: _d(j['grandTotal']),
      date: j['date']?.toString() ?? '',
      userName: j['userName']?.toString(),
      phoneNumber: j['phoneNumber']?.toString() ?? j['mobileNo']?.toString(),
      items: items,
    );
  }
}

class _OrderItem {
  final String dishName;
  final int quantity;
  final double totalPrice;
  final String category;

  const _OrderItem({
    required this.dishName,
    required this.quantity,
    required this.totalPrice,
    required this.category,
  });

  factory _OrderItem.fromJson(Map<String, dynamic> j) => _OrderItem(
    dishName: j['dishName']?.toString() ?? '',
    quantity: _i(j['quantity']),
    totalPrice: _d(j['totalPrice']),
    category: j['category']?.toString() ?? '',
  );
}

double _d(dynamic v) =>
    (v is num) ? v.toDouble() : double.tryParse(v?.toString() ?? '') ?? 0.0;
int _i(dynamic v) => (v is int) ? v : int.tryParse(v?.toString() ?? '') ?? 0;

class RatingTab extends StatefulWidget {
  final ReportData? data;
  final bool isLoading;
  const RatingTab({super.key, this.data, this.isLoading = false});

  @override
  State<RatingTab> createState() => _RatingTabState();
}

class _RatingTabState extends State<RatingTab> {
  List<_LocalOrderFeedback> _feedbackList = [];
  bool _feedbackLoading = true;
  String? _feedbackError;

  @override
  void initState() {
    super.initState();
    _fetchOrderFeedbacks();
  }

  Future<void> _fetchOrderFeedbacks() async {
    setState(() {
      _feedbackLoading = true;
      _feedbackError = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final vid =
          prefs.getInt('vendorId') ??
          int.tryParse(prefs.getString('vendorId') ?? '') ??
          0;

      final response = await ApiClient.get(
        'api/orders/vendor/$vid',
        service: 'food',
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);

        final List<dynamic> raw = body is List
            ? body
            : (body['content'] ?? body['data'] ?? body['orders'] ?? []);

        final withFeedback = raw
            .whereType<Map<String, dynamic>>()
            .map((e) => _LocalOrderFeedback.fromJson(e))
            .where((o) => o.feedback.trim().isNotEmpty)
            .toList();

        withFeedback.sort((a, b) => b.orderId.compareTo(a.orderId));

        setState(() {
          _feedbackList = withFeedback;
          _feedbackLoading = false;
        });
      } else {
        setState(() {
          _feedbackError = 'Failed to load feedback (${response.statusCode})';
          _feedbackLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _feedbackError = 'Error: $e';
        _feedbackLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) return _shimmer();
    if (widget.data == null)
      return const RpEmpty(
        message: 'No rating data.',
        icon: Icons.star_outline_rounded,
      );

    final avgRating = double.tryParse(widget.data!.averageRating) ?? 0.0;
    final totalRatings = widget.data!.totalRatings;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Unified Stats Card ─────────────────────────────────────────────
        Container(
          decoration: _rpCardDecoWithShadow(),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _statCell(
                        avgRating == 0 ? 'N/A' : avgRating.toStringAsFixed(2),
                        'Avg Rating',
                        rpAmber,
                        Icons.star_rounded,
                      ),
                    ),
                    _vertDivider(),
                    Expanded(
                      child: _statCell(
                        '$totalRatings',
                        'Total Ratings',
                        rpBlue,
                        Icons.rate_review_outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _statCell(
                        '$totalRatings',
                        'Total Reviews',
                        rpPurple,
                        Icons.comment_outlined,
                      ),
                    ),
                    _vertDivider(),
                    Expanded(
                      child: _statCell(
                        widget.data!.ratingGrowthPercent == '0' ||
                                widget.data!.ratingGrowthPercent == '0.00'
                            ? '0%'
                            : '${widget.data!.ratingGrowthPercent}%',
                        'Rating Growth',
                        rpGreen,
                        Icons.trending_up_rounded,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // ── Rating Distribution ────────────────────────────────────────────
        _ratingDistributionCard(
          widget.data!.ratingDistribution,
          avgRating,
          totalRatings,
        ),
        const SizedBox(height: 16),

        // ── Category Ratings ───────────────────────────────────────────────
        if (widget.data!.categoryRatings.isNotEmpty) ...[
          _categoryRatingsSection(widget.data!.categoryRatings),
          const SizedBox(height: 16),
        ],

        // ── Customer Feedback Section ──────────────────────────────────────
        Row(
          children: [
            const Icon(Icons.feedback_outlined, color: rpBlue, size: 18),
            const SizedBox(width: 6),
            const Text(
              'Customer Feedback',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: rpText1,
              ),
            ),
            const Spacer(),
            if (!_feedbackLoading)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),

                child: Text(
                  '${_feedbackList.length} reviews',
                  style: const TextStyle(
                    fontSize: 11,
                    color: rpBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),

        if (_feedbackLoading)
          _feedbackShimmer()
        else if (_feedbackError != null)
          _errorWidget(_feedbackError!)
        else if (_feedbackList.isEmpty)
          _noFeedbackWidget()
        else
          ..._feedbackList.map((order) => _feedbackCard(order)),
      ],
    );
  }

  // ─── Rating Distribution Card ──────────────────────────────────────────────
  Widget _ratingDistributionCard(
    RatingDistribution dist,
    double avg,
    int total,
  ) {
    final labels = ['5★', '4★', '3★', '2★', '1★'];
    final colors = [rpGreen, rpBlue, rpAmber, rpOrange, rpRed];
    final counts = dist.counts;
    final maxCount = counts.reduce((a, b) => a > b ? a : b).clamp(1, 99999);

    return Container(
      decoration: _rpCardDecoWithShadow(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(Icons.bar_chart_rounded, color: rpAmber, size: 18),
              const SizedBox(width: 6),
              const Text(
                'Rating Distribution',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: rpText1,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: rpAmber.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star_rounded, size: 13, color: rpAmber),
                    const SizedBox(width: 3),
                    Text(
                      avg == 0 ? 'N/A' : avg.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: rpAmber,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Bar rows
          ...List.generate(5, (i) {
            final count = counts[i];
            final pct = count / maxCount;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  // Label
                  SizedBox(
                    width: 28,
                    child: Text(
                      labels[i],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: colors[i],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Bar
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Stack(
                        children: [
                          // Track
                          Container(
                            height: 10,
                            color: colors[i].withOpacity(0.1),
                          ),
                          // Fill
                          FractionallySizedBox(
                            widthFactor: pct.clamp(0.0, 1.0),
                            child: Container(
                              height: 10,
                              decoration: BoxDecoration(
                                color: colors[i],
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Count
                  SizedBox(
                    width: 24,
                    child: Text(
                      '$count',
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: count > 0 ? rpText1 : rpText3,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),

          const Divider(color: rpBorder, height: 1),
          const SizedBox(height: 10),

          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Icon(Icons.people_outline, size: 13, color: rpText3),
              const SizedBox(width: 4),
              Text(
                '$total total rating${total == 1 ? '' : 's'}',
                style: const TextStyle(fontSize: 12, color: rpText3),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Category Ratings Section ──────────────────────────────────────────────
  Widget _categoryRatingsSection(List<CategoryRating> categories) {
    return Container(
      decoration: _rpCardDecoWithShadow(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(Icons.category_outlined, color: rpPurple, size: 18),
              const SizedBox(width: 6),
              const Text(
                'Category Ratings',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: rpText1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          ...categories.map(
            (cat) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Icon(_categoryIcon(cat.category), size: 16, color: rpPurple),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      cat.displayName,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: rpText1,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: rpPurple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${cat.totalRatings}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: rpPurple,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget _categoryRatingCard(CategoryRating cat) {
  //   final avg = double.tryParse(cat.averageRating) ?? 0.0;
  //   final hasData = cat.totalRatings > 0;
  //
  //   // Pick color based on avg
  //   final color = avg >= 4
  //       ? rpGreen
  //       : avg >= 3
  //       ? rpAmber
  //       : avg > 0
  //       ? rpRed
  //       : rpText3;
  //
  //   // Icon per category
  //   final icon = _categoryIcon(cat.category);
  //
  //   return Container(
  //     decoration: _rpCardDecoWithShadow(),
  //     padding: const EdgeInsets.all(12),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         // Header row: icon + name
  //         Row(
  //           children: [
  //             Container(
  //               padding: const EdgeInsets.all(7),
  //               decoration: BoxDecoration(
  //                 color: rpPurple.withOpacity(0.1),
  //                 borderRadius: BorderRadius.circular(8),
  //               ),
  //               child: Icon(icon, size: 16, color: rpPurple),
  //             ),
  //             const SizedBox(width: 8),
  //             Expanded(
  //               child: Text(
  //                 cat.displayName,
  //                 style: const TextStyle(
  //                   fontSize: 12,
  //                   fontWeight: FontWeight.w700,
  //                   color: rpText1,
  //                 ),
  //                 maxLines: 1,
  //                 overflow: TextOverflow.ellipsis,
  //               ),
  //             ),
  //           ],
  //         ),
  //         const SizedBox(height: 10),
  //
  //         // Average rating + stars
  //         Row(
  //           crossAxisAlignment: CrossAxisAlignment.end,
  //           children: [
  //             Text(
  //               hasData ? avg.toStringAsFixed(1) : '—',
  //               style: TextStyle(
  //                 fontSize: 22,
  //                 fontWeight: FontWeight.w800,
  //                 color: hasData ? color : rpText3,
  //               ),
  //             ),
  //             const SizedBox(width: 6),
  //             Padding(
  //               padding: const EdgeInsets.only(bottom: 3),
  //               child: Row(
  //                 children: List.generate(5, (i) {
  //                   return Icon(
  //                     i < avg.round()
  //                         ? Icons.star_rounded
  //                         : Icons.star_outline_rounded,
  //                     size: 13,
  //                     color: hasData ? rpAmber : rpText3,
  //                   );
  //                 }),
  //               ),
  //             ),
  //           ],
  //         ),
  //         const SizedBox(height: 4),
  //
  //         // Total ratings badge
  //         Container(
  //           padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
  //           decoration: BoxDecoration(
  //             color: hasData
  //                 ? rpPurple.withOpacity(0.08)
  //                 : rpText3.withOpacity(0.08),
  //             borderRadius: BorderRadius.circular(6),
  //           ),
  //           child: Text(
  //             '${cat.totalRatings} review${cat.totalRatings == 1 ? '' : 's'}',
  //             style: TextStyle(
  //               fontSize: 10,
  //               fontWeight: FontWeight.w600,
  //               color: hasData ? rpPurple : rpText3,
  //             ),
  //           ),
  //         ),
  //
  //         // Mini star breakdown bars (only if there's data)
  //         if (hasData) ...[
  //           const SizedBox(height: 10),
  //           const Divider(color: rpBorder, height: 1),
  //           const SizedBox(height: 8),
  //           ...() {
  //             final counts = cat.starBreakdown.counts;
  //             final maxC =
  //             counts.reduce((a, b) => a > b ? a : b).clamp(1, 99999);
  //             final barColors = [rpGreen, rpBlue, rpAmber, rpOrange, rpRed];
  //             return List.generate(5, (i) {
  //               final pct = counts[i] / maxC;
  //               return Padding(
  //                 padding: const EdgeInsets.only(bottom: 4),
  //                 child: Row(
  //                   children: [
  //                     Text(
  //                       '${5 - i}★',
  //                       style: TextStyle(
  //                         fontSize: 9,
  //                         color: barColors[i],
  //                         fontWeight: FontWeight.w600,
  //                       ),
  //                     ),
  //                     const SizedBox(width: 4),
  //                     Expanded(
  //                       child: ClipRRect(
  //                         borderRadius: BorderRadius.circular(4),
  //                         child: Stack(
  //                           children: [
  //                             Container(
  //                               height: 6,
  //                               color: barColors[i].withOpacity(0.1),
  //                             ),
  //                             FractionallySizedBox(
  //                               widthFactor: pct.clamp(0.0, 1.0),
  //                               child: Container(
  //                                 height: 6,
  //                                 color: barColors[i],
  //                               ),
  //                             ),
  //                           ],
  //                         ),
  //                       ),
  //                     ),
  //                     const SizedBox(width: 4),
  //                     SizedBox(
  //                       width: 16,
  //                       child: Text(
  //                         '${counts[i]}',
  //                         textAlign: TextAlign.end,
  //                         style: const TextStyle(
  //                           fontSize: 9,
  //                           color: rpText3,
  //                         ),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               );
  //             });
  //           }(),
  //         ],
  //       ],
  //     ),
  //   );
  // }

  IconData _categoryIcon(String cat) {
    switch (cat) {
      case 'FOOD_QUALITY':
        return Icons.restaurant_menu_outlined;
      case 'PACKAGING':
        return Icons.inventory_2_outlined;
      case 'DELIVERY':
        return Icons.delivery_dining_outlined;
      case 'SERVICE':
        return Icons.support_agent_outlined;
      case 'OTHERS':
        return Icons.more_horiz_rounded;
      default:
        return Icons.star_outline_rounded;
    }
  }

  // ─── Feedback Card ──────────────────────────────────────────────────────────
  Widget _feedbackCard(_LocalOrderFeedback order) {
    final starColor = order.ratings >= 4
        ? rpGreen
        : order.ratings == 3
        ? rpAmber
        : rpRed;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: _rpCardDecoWithShadow(),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row: Order ID + Rating stars ─────────────────────────
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: rpBlue.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(width: 4),
                    Text(
                      'OrderId : ${order.orderId}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: rpBlue,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Row(
                children: List.generate(5, (i) {
                  return Icon(
                    i < order.ratings
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: rpAmber,
                    size: 16,
                  );
                }),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: starColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${order.ratings}.0',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: starColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // ── Feedback text ────────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    order.feedback,
                    style: const TextStyle(
                      fontSize: 13,
                      color: rpText1,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // ── Order items ──────────────────────────────────────────────────
          if (order.items.isNotEmpty) ...[
            Row(
              children: [
                const Icon(Icons.fastfood_outlined, size: 13, color: rpText3),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    order.items
                        .map((i) => '${i.dishName} ×${i.quantity}')
                        .join(', '),
                    style: const TextStyle(fontSize: 12, color: rpText3),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],

          // ── Footer row: date, order type, amount ─────────────────────────
          Row(
            children: [
              if (order.date.isNotEmpty) ...[
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 12,
                  color: rpText3,
                ),
                const SizedBox(width: 3),
                Text(
                  order.date,
                  style: const TextStyle(fontSize: 11, color: rpText3),
                ),
                const SizedBox(width: 10),
              ],
              _pill(_orderTypeIcon(order.orderType), order.orderType, rpPurple),
              const Spacer(),
              Text(
                '₹${order.grandTotal.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: rpText1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _orderTypeIcon(String type) {
    switch (type.toUpperCase()) {
      case 'DINE_IN':
        return Icons.restaurant_outlined;
      case 'TAKEAWAY':
        return Icons.shopping_bag_outlined;
      case 'DELIVERY':
        return Icons.delivery_dining_outlined;
      default:
        return Icons.receipt_outlined;
    }
  }

  Widget _pill(IconData icon, String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: BoxDecoration(
      color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: color),
        const SizedBox(width: 3),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );

  Widget _errorWidget(String msg) => Container(
    decoration: _rpCardDecoWithShadow(),
    padding: const EdgeInsets.all(16),
    child: Row(
      children: [
        const Icon(Icons.error_outline, color: rpRed, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(msg, style: const TextStyle(color: rpRed, fontSize: 13)),
        ),
        TextButton(onPressed: _fetchOrderFeedbacks, child: const Text('Retry')),
      ],
    ),
  );

  Widget _noFeedbackWidget() => Container(
    decoration: _rpCardDecoWithShadow(),
    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
    child: const Center(
      child: Column(
        children: [
          Icon(Icons.feedback_outlined, color: rpText3, size: 36),
          SizedBox(height: 8),
          Text(
            'No customer feedback yet.',
            style: TextStyle(color: rpText3, fontSize: 13),
          ),
        ],
      ),
    ),
  );

  Widget _feedbackShimmer() => Column(
    children: List.generate(
      3,
      (_) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: rpBorder),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: rpAccent, strokeWidth: 2),
        ),
      ),
    ),
  );

  // ─── Shared helpers ────────────────────────────────────────────────────────
  BoxDecoration _rpCardDecoWithShadow() => BoxDecoration(
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

  Widget _vertDivider() => Container(
    width: 1,
    height: 60,
    color: rpBorder,
    margin: const EdgeInsets.symmetric(horizontal: 8),
  );

  Widget _shimmer() => Column(
    children: [
      Container(
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
      const RpShimmerCard(height: 200),
      const SizedBox(height: 16),
      const RpShimmerCard(height: 100),
    ],
  );
}

const Color rpOrange = Color(0xFFFF6B35);
