// // // class ReportFilter {
// // //   final String startDate; // yyyy-MM-dd
// // //   final String endDate;
// // //   final String period;
// // //
// // //   const ReportFilter({
// // //     required this.startDate,
// // //     required this.endDate,
// // //     this.period = 'today',
// // //   });
// // // }
// // //
// // // // ─── Single unified response from the API ────────────────────────────────────
// // // // GET /food/api/orders/vendor/statistics/custom?vendorId=X&fromDate=Y&toDate=Z
// // // class ReportData {
// // //   // Revenue
// // //   final double totalRevenue;
// // //   final double grossRevenue;
// // //   final double netRevenue;
// // //   final double todayRevenue;
// // //   final double netProfit;
// // //   final double refundAmount;
// // //   final double platformCommission;
// // //   final double avgOrderValue;
// // //   final String profitMargin;
// // //   final double revenueGrowthPercent;
// // //   final String period;
// // //
// // //   // Orders
// // //   final int totalOrders;
// // //   final int completedOrders;
// // //   final int cancelledOrders;
// // //   final int pendingOrders;
// // //   final int preparingOrders;
// // //   final int onTheWayOrders;
// // //   final int dineInOrders;
// // //   final int takeawayOrders;
// // //   final int deliveryOrders;
// // //
// // //   // ── NEW: vendorOrders & userOrders from API ───────────────────────────────
// // //   final int vendorOrders; // orders placed by vendor (walk-in / manual)
// // //   final int userOrders; // orders placed by customers via app/online
// // //
// // //   // Payments
// // //   final int successfulPayments;
// // //   final int failedPayments;
// // //   final double pendingPayments;
// // //   final String paymentSuccessRate;
// // //   final Map<String, double> paymentBreakdown;
// // //
// // //   // Ratings
// // //   final String averageRating;
// // //   final int totalRatings;
// // //   final String ratingGrowthPercent;
// // //
// // //   // Charts
// // //   final List<DailyStat> dailyStats;
// // //   final List<HourlyStat> hourlyBreakdown;
// // //   final PeakHour? peakHour;
// // //   final Map<String, double> revenueByCategory;
// // //   final Map<String, List<CategoryItem>> allItemsByCategory;
// // //   final DineInVsOnline? dineInVsOnline;
// // //
// // //   const ReportData({
// // //     this.totalRevenue = 0,
// // //     this.grossRevenue = 0,
// // //     this.netRevenue = 0,
// // //     this.todayRevenue = 0,
// // //     this.netProfit = 0,
// // //     this.refundAmount = 0,
// // //     this.platformCommission = 0,
// // //     this.avgOrderValue = 0,
// // //     this.profitMargin = '0%',
// // //     this.revenueGrowthPercent = 0,
// // //     this.period = '',
// // //     this.totalOrders = 0,
// // //     this.completedOrders = 0,
// // //     this.cancelledOrders = 0,
// // //     this.pendingOrders = 0,
// // //     this.preparingOrders = 0,
// // //     this.onTheWayOrders = 0,
// // //     this.dineInOrders = 0,
// // //     this.takeawayOrders = 0,
// // //     this.deliveryOrders = 0,
// // //     this.vendorOrders = 0, // NEW
// // //     this.userOrders = 0, // NEW
// // //     this.successfulPayments = 0,
// // //     this.failedPayments = 0,
// // //     this.pendingPayments = 0,
// // //     this.paymentSuccessRate = '0%',
// // //     this.paymentBreakdown = const {},
// // //     this.averageRating = '0',
// // //     this.totalRatings = 0,
// // //     this.ratingGrowthPercent = '0',
// // //     this.dailyStats = const [],
// // //     this.hourlyBreakdown = const [],
// // //     this.peakHour,
// // //     this.revenueByCategory = const {},
// // //     this.allItemsByCategory = const {},
// // //     this.dineInVsOnline,
// // //   });
// // //
// // //   factory ReportData.fromJson(Map<String, dynamic> j) {
// // //     // paymentBreakdown map
// // //     final pb = <String, double>{};
// // //     if (j['paymentBreakdown'] is Map) {
// // //       (j['paymentBreakdown'] as Map).forEach(
// // //         (k, v) => pb[k.toString()] = _d(v),
// // //       );
// // //     }
// // //
// // //     // revenueByCategory map
// // //     final rbc = <String, double>{};
// // //     if (j['revenueByCategory'] is Map) {
// // //       (j['revenueByCategory'] as Map).forEach(
// // //         (k, v) => rbc[k.toString()] = _d(v),
// // //       );
// // //     }
// // //
// // //     // allItemsByCategory
// // //     final aibc = <String, List<CategoryItem>>{};
// // //     if (j['allItemsByCategory'] is Map) {
// // //       (j['allItemsByCategory'] as Map).forEach((k, v) {
// // //         if (v is List) {
// // //           aibc[k.toString()] = v
// // //               .whereType<Map<String, dynamic>>()
// // //               .map(CategoryItem.fromJson)
// // //               .toList();
// // //         }
// // //       });
// // //     }
// // //
// // //     return ReportData(
// // //       totalRevenue: _d(j['totalRevenue']),
// // //       grossRevenue: _d(j['grossRevenue']),
// // //       netRevenue: _d(j['netRevenue']),
// // //       todayRevenue: _d(j['todayRevenue']),
// // //       netProfit: _d(j['netProfit']),
// // //       refundAmount: _d(j['refundAmount']),
// // //       platformCommission: _d(j['platformCommission']),
// // //       avgOrderValue: _d(j['avgOrderValue']),
// // //       profitMargin: j['profitMargin']?.toString() ?? '0%',
// // //       revenueGrowthPercent: _d(j['revenueGrowthPercent']),
// // //       period: j['period']?.toString() ?? '',
// // //       totalOrders: _i(j['totalOrders']),
// // //       completedOrders: _i(j['completedOrders']),
// // //       cancelledOrders: _i(j['cancelledOrders']),
// // //       pendingOrders: _i(j['pendingOrders']),
// // //       preparingOrders: _i(j['preparingOrders']),
// // //       onTheWayOrders: _i(j['onTheWayOrders']),
// // //       dineInOrders: _i(j['dineInOrders']),
// // //       takeawayOrders: _i(j['takeawayOrders']),
// // //       deliveryOrders: _i(j['deliveryOrders']),
// // //       vendorOrders: _i(j['vendorOrders']), // NEW
// // //       userOrders: _i(j['userOrders']), // NEW
// // //       successfulPayments: _i(j['successfulPayments']),
// // //       failedPayments: _i(j['failedPayments']),
// // //       pendingPayments: _d(j['pendingPayments']),
// // //       paymentSuccessRate: j['paymentSuccessRate']?.toString() ?? '0%',
// // //       paymentBreakdown: pb,
// // //       averageRating: j['averageRating']?.toString() ?? '0',
// // //       totalRatings: _i(j['totalRatings']),
// // //       ratingGrowthPercent: j['ratingGrowthPercent']?.toString() ?? '0',
// // //       dailyStats: _parseList(j['dailyStats'], DailyStat.fromJson),
// // //       hourlyBreakdown: _parseList(
// // //         j['hourlyOrderBreakdown'],
// // //         HourlyStat.fromJson,
// // //       ),
// // //       peakHour: j['peakHourOrders'] is Map
// // //           ? PeakHour.fromJson(j['peakHourOrders'] as Map<String, dynamic>)
// // //           : null,
// // //       revenueByCategory: rbc,
// // //       allItemsByCategory: aibc,
// // //       dineInVsOnline: j['dineInVsOnline'] is Map
// // //           ? DineInVsOnline.fromJson(j['dineInVsOnline'] as Map<String, dynamic>)
// // //           : null,
// // //     );
// // //   }
// // // }
// // //
// // // class DailyStat {
// // //   final String date;
// // //   final double revenue;
// // //   final int orders;
// // //   DailyStat({required this.date, required this.revenue, required this.orders});
// // //   factory DailyStat.fromJson(Map<String, dynamic> j) => DailyStat(
// // //     date: j['date']?.toString() ?? '',
// // //     revenue: _d(j['revenue']),
// // //     orders: _i(j['orders']),
// // //   );
// // // }
// // //
// // // class HourlyStat {
// // //   final String hour;
// // //   final int orders;
// // //   HourlyStat({required this.hour, required this.orders});
// // //   factory HourlyStat.fromJson(Map<String, dynamic> j) => HourlyStat(
// // //     hour: _toISTHour(j['hour']?.toString()),
// // //     orders: _i(j['orders']),
// // //   );
// // // }
// // //
// // // class PeakHour {
// // //   final String hour;
// // //   final int orders;
// // //   PeakHour({required this.hour, required this.orders});
// // //   factory PeakHour.fromJson(Map<String, dynamic> j) => PeakHour(
// // //     hour: _toISTHour(j['hour']?.toString()),
// // //     orders: _i(j['orders']),
// // //   );
// // // }
// // //
// // // class CategoryItem {
// // //   final String item;
// // //   final int quantity;
// // //   final double revenue;
// // //   CategoryItem({
// // //     required this.item,
// // //     required this.quantity,
// // //     required this.revenue,
// // //   });
// // //   factory CategoryItem.fromJson(Map<String, dynamic> j) => CategoryItem(
// // //     item: j['item']?.toString() ?? '',
// // //     quantity: _i(j['quantity']),
// // //     revenue: _d(j['revenue']),
// // //   );
// // // }
// // //
// // // class DineInVsOnline {
// // //   final int dineIn;
// // //   final int online;
// // //   DineInVsOnline({required this.dineIn, required this.online});
// // //   factory DineInVsOnline.fromJson(Map<String, dynamic> j) =>
// // //       DineInVsOnline(dineIn: _i(j['dineIn']), online: _i(j['online']));
// // // }
// // //
// // // // ─── Helpers ──────────────────────────────────────────────────────────────────
// // // double _d(dynamic v) =>
// // //     (v is num) ? v.toDouble() : double.tryParse(v?.toString() ?? '') ?? 0.0;
// // // int _i(dynamic v) => (v is int) ? v : int.tryParse(v?.toString() ?? '') ?? 0;
// // //
// // // List<T> _parseList<T>(dynamic raw, T Function(Map<String, dynamic>) fn) {
// // //   if (raw is! List) return [];
// // //   return raw.whereType<Map<String, dynamic>>().map(fn).toList();
// // // }
// // //
// // // String _toISTHour(String? raw) {
// // //   if (raw == null || raw.isEmpty) return '';
// // //   try {
// // //     final parts = raw.split(':');
// // //     final h = int.parse(parts[0]);
// // //     final m = int.parse(parts.length > 1 ? parts[1] : '0');
// // //     final utc = DateTime.utc(2000, 1, 1, h, m);
// // //     final ist = utc.add(const Duration(hours: 5, minutes: 30));
// // //     final hh = ist.hour % 12 == 0 ? 12 : ist.hour % 12;
// // //     final mm = ist.minute.toString().padLeft(2, '0');
// // //     final ampm = ist.hour >= 12 ? 'PM' : 'AM';
// // //     return '$hh:$mm $ampm';
// // //   } catch (_) {
// // //     return raw;
// // //   }
// // // }
// // class ReportFilter {
// //   final String startDate; // yyyy-MM-dd
// //   final String endDate;
// //   final String period;
// //
// //   const ReportFilter({
// //     required this.startDate,
// //     required this.endDate,
// //     this.period = 'today',
// //   });
// // }
// //
// // // ─── Order-level feedback (from orders list in the API response) ─────────────
// // class OrderFeedback {
// //   final int orderId;
// //   final String feedback;
// //   final int ratings;
// //   final String orderType;
// //   final String date;
// //   final String time;
// //   final double grandTotal;
// //   final String status;
// //   final String paymentMethod;
// //
// //   const OrderFeedback({
// //     required this.orderId,
// //     required this.feedback,
// //     required this.ratings,
// //     required this.orderType,
// //     required this.date,
// //     required this.time,
// //     required this.grandTotal,
// //     required this.status,
// //     required this.paymentMethod,
// //   });
// //
// //   factory OrderFeedback.fromJson(Map<String, dynamic> j) => OrderFeedback(
// //     orderId: _i(j['orderId']),
// //     feedback: j['feedback']?.toString().trim() ?? '',
// //     ratings: _i(j['ratings']),
// //     orderType: j['orderType']?.toString() ?? '',
// //     date: j['date']?.toString() ?? '',
// //     time: j['time']?.toString() ?? '',
// //     grandTotal: _d(j['grandTotal']),
// //     status: j['status']?.toString() ?? '',
// //     paymentMethod: j['paymentMethod']?.toString() ?? '',
// //   );
// // }
// //
// // // ─── Single unified response from the API ────────────────────────────────────
// // // GET /food/api/orders/vendor/statistics/custom?vendorId=X&fromDate=Y&toDate=Z
// // class ReportData {
// //   // Revenue
// //   final double totalRevenue;
// //   final double grossRevenue;
// //   final double netRevenue;
// //   final double todayRevenue;
// //   final double netProfit;
// //   final double refundAmount;
// //   final double platformCommission;
// //   final double avgOrderValue;
// //   final String profitMargin;
// //   final double revenueGrowthPercent;
// //   final String period;
// //
// //   // Orders
// //   final int totalOrders;
// //   final int completedOrders;
// //   final int cancelledOrders;
// //   final int pendingOrders;
// //   final int preparingOrders;
// //   final int onTheWayOrders;
// //   final int dineInOrders;
// //   final int takeawayOrders;
// //   final int deliveryOrders;
// //
// //   // ── vendorOrders & userOrders from API ────────────────────────────────────
// //   final int vendorOrders; // orders placed by vendor (walk-in / manual)
// //   final int userOrders; // orders placed by customers via app/online
// //
// //   // Payments
// //   final int successfulPayments;
// //   final int failedPayments;
// //   final double pendingPayments;
// //   final String paymentSuccessRate;
// //   final Map<String, double> paymentBreakdown;
// //
// //   // Ratings
// //   final String averageRating;
// //   final int totalRatings;
// //   final String ratingGrowthPercent;
// //
// //   // ── Feedbacks (orders that have a non-empty feedback field) ──────────────
// //   final List<OrderFeedback> feedbacks;
// //
// //   // Charts
// //   final List<DailyStat> dailyStats;
// //   final List<HourlyStat> hourlyBreakdown;
// //   final PeakHour? peakHour;
// //   final Map<String, double> revenueByCategory;
// //   final Map<String, List<CategoryItem>> allItemsByCategory;
// //   final DineInVsOnline? dineInVsOnline;
// //
// //   const ReportData({
// //     this.totalRevenue = 0,
// //     this.grossRevenue = 0,
// //     this.netRevenue = 0,
// //     this.todayRevenue = 0,
// //     this.netProfit = 0,
// //     this.refundAmount = 0,
// //     this.platformCommission = 0,
// //     this.avgOrderValue = 0,
// //     this.profitMargin = '0%',
// //     this.revenueGrowthPercent = 0,
// //     this.period = '',
// //     this.totalOrders = 0,
// //     this.completedOrders = 0,
// //     this.cancelledOrders = 0,
// //     this.pendingOrders = 0,
// //     this.preparingOrders = 0,
// //     this.onTheWayOrders = 0,
// //     this.dineInOrders = 0,
// //     this.takeawayOrders = 0,
// //     this.deliveryOrders = 0,
// //     this.vendorOrders = 0,
// //     this.userOrders = 0,
// //     this.successfulPayments = 0,
// //     this.failedPayments = 0,
// //     this.pendingPayments = 0,
// //     this.paymentSuccessRate = '0%',
// //     this.paymentBreakdown = const {},
// //     this.averageRating = '0',
// //     this.totalRatings = 0,
// //     this.ratingGrowthPercent = '0',
// //     this.feedbacks = const [],
// //     this.dailyStats = const [],
// //     this.hourlyBreakdown = const [],
// //     this.peakHour,
// //     this.revenueByCategory = const {},
// //     this.allItemsByCategory = const {},
// //     this.dineInVsOnline,
// //   });
// //
// //   factory ReportData.fromJson(Map<String, dynamic> j) {
// //     // paymentBreakdown map
// //     final pb = <String, double>{};
// //     if (j['paymentBreakdown'] is Map) {
// //       (j['paymentBreakdown'] as Map).forEach(
// //         (k, v) => pb[k.toString()] = _d(v),
// //       );
// //     }
// //
// //     // revenueByCategory map
// //     final rbc = <String, double>{};
// //     if (j['revenueByCategory'] is Map) {
// //       (j['revenueByCategory'] as Map).forEach(
// //         (k, v) => rbc[k.toString()] = _d(v),
// //       );
// //     }
// //
// //     // allItemsByCategory
// //     final aibc = <String, List<CategoryItem>>{};
// //     if (j['allItemsByCategory'] is Map) {
// //       (j['allItemsByCategory'] as Map).forEach((k, v) {
// //         if (v is List) {
// //           aibc[k.toString()] = v
// //               .whereType<Map<String, dynamic>>()
// //               .map(CategoryItem.fromJson)
// //               .toList();
// //         }
// //       });
// //     }
// //
// //     // feedbacks — parse from top-level 'orders' list, keep only those
// //     // where the feedback field is non-null and non-empty.
// //     final feedbacks = <OrderFeedback>[];
// //     final rawOrders = j['orders'];
// //     if (rawOrders is List) {
// //       for (final item in rawOrders) {
// //         if (item is Map<String, dynamic>) {
// //           final fb = item['feedback']?.toString().trim() ?? '';
// //           if (fb.isNotEmpty) {
// //             feedbacks.add(OrderFeedback.fromJson(item));
// //           }
// //         }
// //       }
// //     }
// //
// //     return ReportData(
// //       totalRevenue: _d(j['totalRevenue']),
// //       grossRevenue: _d(j['grossRevenue']),
// //       netRevenue: _d(j['netRevenue']),
// //       todayRevenue: _d(j['todayRevenue']),
// //       netProfit: _d(j['netProfit']),
// //       refundAmount: _d(j['refundAmount']),
// //       platformCommission: _d(j['platformCommission']),
// //       avgOrderValue: _d(j['avgOrderValue']),
// //       profitMargin: j['profitMargin']?.toString() ?? '0%',
// //       revenueGrowthPercent: _d(j['revenueGrowthPercent']),
// //       period: j['period']?.toString() ?? '',
// //       totalOrders: _i(j['totalOrders']),
// //       completedOrders: _i(j['completedOrders']),
// //       cancelledOrders: _i(j['cancelledOrders']),
// //       pendingOrders: _i(j['pendingOrders']),
// //       preparingOrders: _i(j['preparingOrders']),
// //       onTheWayOrders: _i(j['onTheWayOrders']),
// //       dineInOrders: _i(j['dineInOrders']),
// //       takeawayOrders: _i(j['takeawayOrders']),
// //       deliveryOrders: _i(j['deliveryOrders']),
// //       vendorOrders: _i(j['vendorOrders']),
// //       userOrders: _i(j['userOrders']),
// //       successfulPayments: _i(j['successfulPayments']),
// //       failedPayments: _i(j['failedPayments']),
// //       pendingPayments: _d(j['pendingPayments']),
// //       paymentSuccessRate: j['paymentSuccessRate']?.toString() ?? '0%',
// //       paymentBreakdown: pb,
// //       averageRating: j['averageRating']?.toString() ?? '0',
// //       totalRatings: _i(j['totalRatings']),
// //       ratingGrowthPercent: j['ratingGrowthPercent']?.toString() ?? '0',
// //       feedbacks: feedbacks,
// //       dailyStats: _parseList(j['dailyStats'], DailyStat.fromJson),
// //       hourlyBreakdown: _parseList(
// //         j['hourlyOrderBreakdown'],
// //         HourlyStat.fromJson,
// //       ),
// //       peakHour: j['peakHourOrders'] is Map
// //           ? PeakHour.fromJson(j['peakHourOrders'] as Map<String, dynamic>)
// //           : null,
// //       revenueByCategory: rbc,
// //       allItemsByCategory: aibc,
// //       dineInVsOnline: j['dineInVsOnline'] is Map
// //           ? DineInVsOnline.fromJson(j['dineInVsOnline'] as Map<String, dynamic>)
// //           : null,
// //     );
// //   }
// // }
// //
// // class DailyStat {
// //   final String date;
// //   final double revenue;
// //   final int orders;
// //   DailyStat({required this.date, required this.revenue, required this.orders});
// //   factory DailyStat.fromJson(Map<String, dynamic> j) => DailyStat(
// //     date: j['date']?.toString() ?? '',
// //     revenue: _d(j['revenue']),
// //     orders: _i(j['orders']),
// //   );
// // }
// //
// // class HourlyStat {
// //   final String hour;
// //   final int orders;
// //   HourlyStat({required this.hour, required this.orders});
// //   factory HourlyStat.fromJson(Map<String, dynamic> j) => HourlyStat(
// //     hour: _toISTHour(j['hour']?.toString()),
// //     orders: _i(j['orders']),
// //   );
// // }
// //
// // class PeakHour {
// //   final String hour;
// //   final int orders;
// //   PeakHour({required this.hour, required this.orders});
// //   factory PeakHour.fromJson(Map<String, dynamic> j) => PeakHour(
// //     hour: _toISTHour(j['hour']?.toString()),
// //     orders: _i(j['orders']),
// //   );
// // }
// //
// // class CategoryItem {
// //   final String item;
// //   final int quantity;
// //   final double revenue;
// //   CategoryItem({
// //     required this.item,
// //     required this.quantity,
// //     required this.revenue,
// //   });
// //   factory CategoryItem.fromJson(Map<String, dynamic> j) => CategoryItem(
// //     item: j['item']?.toString() ?? '',
// //     quantity: _i(j['quantity']),
// //     revenue: _d(j['revenue']),
// //   );
// // }
// //
// // class DineInVsOnline {
// //   final int dineIn;
// //   final int online;
// //   DineInVsOnline({required this.dineIn, required this.online});
// //   factory DineInVsOnline.fromJson(Map<String, dynamic> j) =>
// //       DineInVsOnline(dineIn: _i(j['dineIn']), online: _i(j['online']));
// // }
// //
// // // ─── Helpers ──────────────────────────────────────────────────────────────────
// // double _d(dynamic v) =>
// //     (v is num) ? v.toDouble() : double.tryParse(v?.toString() ?? '') ?? 0.0;
// // int _i(dynamic v) => (v is int) ? v : int.tryParse(v?.toString() ?? '') ?? 0;
// //
// // List<T> _parseList<T>(dynamic raw, T Function(Map<String, dynamic>) fn) {
// //   if (raw is! List) return [];
// //   return raw.whereType<Map<String, dynamic>>().map(fn).toList();
// // }
// //
// // String _toISTHour(String? raw) {
// //   if (raw == null || raw.isEmpty) return '';
// //   try {
// //     final parts = raw.split(':');
// //     final h = int.parse(parts[0]);
// //     final m = int.parse(parts.length > 1 ? parts[1] : '0');
// //     final utc = DateTime.utc(2000, 1, 1, h, m);
// //     final ist = utc.add(const Duration(hours: 5, minutes: 30));
// //     final hh = ist.hour % 12 == 0 ? 12 : ist.hour % 12;
// //     final mm = ist.minute.toString().padLeft(2, '0');
// //     final ampm = ist.hour >= 12 ? 'PM' : 'AM';
// //     return '$hh:$mm $ampm';
// //   } catch (_) {
// //     return raw;
// //   }
// // }
// class ReportFilter {
//   final String startDate;
//   final String endDate;
//   final String period;
//
//   const ReportFilter({
//     required this.startDate,
//     required this.endDate,
//     this.period = 'today',
//   });
// }
//
// class OrderFeedback {
//   final int orderId;
//   final String feedback;
//   final int ratings;
//   final String orderType;
//   final String date;
//   final String time;
//   final double grandTotal;
//   final String status;
//   final String paymentMethod;
//
//   const OrderFeedback({
//     required this.orderId,
//     required this.feedback,
//     required this.ratings,
//     required this.orderType,
//     required this.date,
//     required this.time,
//     required this.grandTotal,
//     required this.status,
//     required this.paymentMethod,
//   });
//
//   factory OrderFeedback.fromJson(Map<String, dynamic> j) => OrderFeedback(
//     orderId: _i(j['orderId']),
//     feedback: j['feedback']?.toString().trim() ?? '',
//     ratings: _i(j['ratings']),
//     orderType: j['orderType']?.toString() ?? '',
//     date: j['date']?.toString() ?? '',
//     time: j['time']?.toString() ?? '',
//     grandTotal: _d(j['grandTotal']),
//     status: j['status']?.toString() ?? '',
//     paymentMethod: j['paymentMethod']?.toString() ?? '',
//   );
// }
//
// class RatingDistribution {
//   final int star5;
//   final int star4;
//   final int star3;
//   final int star2;
//   final int star1;
//
//   const RatingDistribution({
//     this.star5 = 0,
//     this.star4 = 0,
//     this.star3 = 0,
//     this.star2 = 0,
//     this.star1 = 0,
//   });
//
//   int get total => star5 + star4 + star3 + star2 + star1;
//
//   List<int> get counts => [star5, star4, star3, star2, star1];
//
//   factory RatingDistribution.fromJson(Map<String, dynamic> j) =>
//       RatingDistribution(
//         star5: _i(j['5Star']),
//         star4: _i(j['4Star']),
//         star3: _i(j['3Star']),
//         star2: _i(j['2Star']),
//         star1: _i(j['1Star']),
//       );
// }
//
// class CategoryRating {
//   final String category;
//   final String averageRating;
//   final int totalRatings;
//   final RatingDistribution starBreakdown;
//
//   const CategoryRating({
//     required this.category,
//     required this.averageRating,
//     required this.totalRatings,
//     required this.starBreakdown,
//   });
//
//   String get displayName {
//     switch (category) {
//       case 'FOOD_QUALITY':
//         return 'Food Quality';
//       case 'PACKAGING':
//         return 'Packaging';
//       case 'DELIVERY':
//         return 'Delivery';
//       case 'SERVICE':
//         return 'Service';
//       case 'OTHERS':
//         return 'Others';
//       default:
//         return category
//             .split('_')
//             .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
//             .join(' ');
//     }
//   }
//
//   factory CategoryRating.fromJson(String key, Map<String, dynamic> j) {
//     final sb = j['starBreakdown'];
//     return CategoryRating(
//       category: key,
//       averageRating: j['averageRating']?.toString() ?? '0.00',
//       totalRatings: _i(j['totalRatings']),
//       starBreakdown: sb is Map<String, dynamic>
//           ? RatingDistribution.fromJson(sb)
//           : const RatingDistribution(),
//     );
//   }
// }
//
// class ReportData {
//   final double totalRevenue;
//   final double grossRevenue;
//   final double netRevenue;
//   final double todayRevenue;
//   final double netProfit;
//   final double refundAmount;
//   final double platformCommission;
//   final double avgOrderValue;
//   final String profitMargin;
//   final double revenueGrowthPercent;
//   final String period;
//
//   final int totalOrders;
//   final int completedOrders;
//   final int cancelledOrders;
//   final int pendingOrders;
//   final int preparingOrders;
//   final int onTheWayOrders;
//   final int dineInOrders;
//   final int takeawayOrders;
//   final int deliveryOrders;
//
//   final int vendorOrders;
//   final int userOrders;
//
//   final int successfulPayments;
//   final int failedPayments;
//   final double pendingPayments;
//   final String paymentSuccessRate;
//   final Map<String, double> paymentBreakdown;
//
//   final double totalTipAmount;
//   final String averageRating;
//   final int totalRatings;
//   final String ratingGrowthPercent;
//   final RatingDistribution ratingDistribution;
//   final List<CategoryRating> categoryRatings;
//   final List<OrderFeedback> feedbacks;
//   final List<DailyStat> dailyStats;
//   final List<HourlyStat> hourlyBreakdown;
//   final PeakHour? peakHour;
//   final Map<String, double> revenueByCategory;
//   final Map<String, List<CategoryItem>> allItemsByCategory;
//   final DineInVsOnline? dineInVsOnline;
//
//   const ReportData({
//     this.totalRevenue = 0,
//     this.grossRevenue = 0,
//     this.netRevenue = 0,
//     this.todayRevenue = 0,
//     this.netProfit = 0,
//     this.refundAmount = 0,
//     this.platformCommission = 0,
//     this.avgOrderValue = 0,
//     this.profitMargin = '0%',
//     this.revenueGrowthPercent = 0,
//     this.period = '',
//     this.totalOrders = 0,
//     this.completedOrders = 0,
//     this.cancelledOrders = 0,
//     this.pendingOrders = 0,
//     this.preparingOrders = 0,
//     this.onTheWayOrders = 0,
//     this.dineInOrders = 0,
//     this.takeawayOrders = 0,
//     this.deliveryOrders = 0,
//     this.vendorOrders = 0,
//     this.userOrders = 0,
//     this.successfulPayments = 0,
//     this.failedPayments = 0,
//     this.pendingPayments = 0,
//     this.paymentSuccessRate = '0%',
//     this.paymentBreakdown = const {},
//     this.totalTipAmount = 0,
//     this.averageRating = '0',
//     this.totalRatings = 0,
//     this.ratingGrowthPercent = '0',
//     this.ratingDistribution = const RatingDistribution(),
//     this.categoryRatings = const [],
//     this.feedbacks = const [],
//     this.dailyStats = const [],
//     this.hourlyBreakdown = const [],
//     this.peakHour,
//     this.revenueByCategory = const {},
//     this.allItemsByCategory = const {},
//     this.dineInVsOnline,
//   });
//
//   factory ReportData.fromJson(Map<String, dynamic> j) {
//     // paymentBreakdown map
//     final pb = <String, double>{};
//     if (j['paymentBreakdown'] is Map) {
//       (j['paymentBreakdown'] as Map).forEach(
//         (k, v) => pb[k.toString()] = _d(v),
//       );
//     }
//
//     // revenueByCategory map
//     final rbc = <String, double>{};
//     if (j['revenueByCategory'] is Map) {
//       (j['revenueByCategory'] as Map).forEach(
//         (k, v) => rbc[k.toString()] = _d(v),
//       );
//     }
//
//     // allItemsByCategory
//     final aibc = <String, List<CategoryItem>>{};
//     if (j['allItemsByCategory'] is Map) {
//       (j['allItemsByCategory'] as Map).forEach((k, v) {
//         if (v is List) {
//           aibc[k.toString()] = v
//               .whereType<Map<String, dynamic>>()
//               .map(CategoryItem.fromJson)
//               .toList();
//         }
//       });
//     }
//
//
//     final feedbacks = <OrderFeedback>[];
//     final rawOrders = j['orders'];
//     if (rawOrders is List) {
//       for (final item in rawOrders) {
//         if (item is Map<String, dynamic>) {
//           final fb = item['feedback']?.toString().trim() ?? '';
//           if (fb.isNotEmpty) {
//             feedbacks.add(OrderFeedback.fromJson(item));
//           }
//         }
//       }
//     }
//
//     // ratingDistribution — NEW
//     final ratingDistribution = j['ratingDistribution'] is Map<String, dynamic>
//         ? RatingDistribution.fromJson(
//             j['ratingDistribution'] as Map<String, dynamic>,
//           )
//         : const RatingDistribution();
//
//     // categoryRatings — NEW
//     final categoryRatings = <CategoryRating>[];
//     if (j['categoryRatings'] is Map) {
//       (j['categoryRatings'] as Map).forEach((k, v) {
//         if (v is Map<String, dynamic>) {
//           categoryRatings.add(CategoryRating.fromJson(k.toString(), v));
//         }
//       });
//     }
//
//     return ReportData(
//       totalRevenue: _d(j['totalRevenue']),
//       grossRevenue: _d(j['grossRevenue']),
//       netRevenue: _d(j['netRevenue']),
//       todayRevenue: _d(j['todayRevenue']),
//       netProfit: _d(j['netProfit']),
//       refundAmount: _d(j['refundAmount']),
//       platformCommission: _d(j['platformCommission']),
//       avgOrderValue: _d(j['avgOrderValue']),
//       profitMargin: j['profitMargin']?.toString() ?? '0%',
//       revenueGrowthPercent: _d(j['revenueGrowthPercent']),
//       period: j['period']?.toString() ?? '',
//       totalOrders: _i(j['totalOrders']),
//       completedOrders: _i(j['completedOrders']),
//       cancelledOrders: _i(j['cancelledOrders']),
//       pendingOrders: _i(j['pendingOrders']),
//       preparingOrders: _i(j['preparingOrders']),
//       onTheWayOrders: _i(j['onTheWayOrders']),
//       dineInOrders: _i(j['dineInOrders']),
//       takeawayOrders: _i(j['takeawayOrders']),
//       deliveryOrders: _i(j['deliveryOrders']),
//       vendorOrders: _i(j['vendorOrders']),
//       userOrders: _i(j['userOrders']),
//       successfulPayments: _i(j['successfulPayments']),
//       failedPayments: _i(j['failedPayments']),
//       pendingPayments: _d(j['pendingPayments']),
//       paymentSuccessRate: j['paymentSuccessRate']?.toString() ?? '0%',
//       paymentBreakdown: pb,
//       totalTipAmount: _d(j['totalTipAmount']),
//       averageRating: j['averageRating']?.toString() ?? '0',
//       totalRatings: _i(j['totalRatings']),
//       ratingGrowthPercent: j['ratingGrowthPercent']?.toString() ?? '0',
//       ratingDistribution: ratingDistribution,
//       categoryRatings: categoryRatings,
//       feedbacks: feedbacks,
//       dailyStats: _parseList(j['dailyStats'], DailyStat.fromJson),
//       hourlyBreakdown: _parseList(
//         j['hourlyOrderBreakdown'],
//         HourlyStat.fromJson,
//       ),
//       peakHour: j['peakHourOrders'] is Map
//           ? PeakHour.fromJson(j['peakHourOrders'] as Map<String, dynamic>)
//           : null,
//       revenueByCategory: rbc,
//       allItemsByCategory: aibc,
//       dineInVsOnline: j['dineInVsOnline'] is Map
//           ? DineInVsOnline.fromJson(j['dineInVsOnline'] as Map<String, dynamic>)
//           : null,
//     );
//   }
// }
//
// class DailyStat {
//   final String date;
//   final double revenue;
//   final int orders;
//   DailyStat({required this.date, required this.revenue, required this.orders});
//   factory DailyStat.fromJson(Map<String, dynamic> j) => DailyStat(
//     date: j['date']?.toString() ?? '',
//     revenue: _d(j['revenue']),
//     orders: _i(j['orders']),
//   );
// }
//
// class HourlyStat {
//   final String hour;
//   final int orders;
//   HourlyStat({required this.hour, required this.orders});
//   factory HourlyStat.fromJson(Map<String, dynamic> j) => HourlyStat(
//     hour: _toISTHour(j['hour']?.toString()),
//     orders: _i(j['orders']),
//   );
// }
//
// class PeakHour {
//   final String hour;
//   final int orders;
//   PeakHour({required this.hour, required this.orders});
//   factory PeakHour.fromJson(Map<String, dynamic> j) => PeakHour(
//     hour: _toISTHour(j['hour']?.toString()),
//     orders: _i(j['orders']),
//   );
// }
//
// class CategoryItem {
//   final String dish;
//   final int quantity;
//   final double revenue;
//   CategoryItem({
//     required this.dish,
//     required this.quantity,
//     required this.revenue,
//   });
//   factory CategoryItem.fromJson(Map<String, dynamic> j) => CategoryItem(
//     dish: (j['dish'] ?? j['item'])?.toString() ?? '',
//     quantity: _i(j['quantity']),
//     revenue: _d(j['revenue']),
//   );
// }
//
// class DineInVsOnline {
//   final int dineIn;
//   final int online;
//   DineInVsOnline({required this.dineIn, required this.online});
//   factory DineInVsOnline.fromJson(Map<String, dynamic> j) =>
//       DineInVsOnline(dineIn: _i(j['dineIn']), online: _i(j['online']));
// }
//
// // ─── Helpers ──────────────────────────────────────────────────────────────────
// double _d(dynamic v) =>
//     (v is num) ? v.toDouble() : double.tryParse(v?.toString() ?? '') ?? 0.0;
// int _i(dynamic v) => (v is int) ? v : int.tryParse(v?.toString() ?? '') ?? 0;
//
// List<T> _parseList<T>(dynamic raw, T Function(Map<String, dynamic>) fn) {
//   if (raw is! List) return [];
//   return raw.whereType<Map<String, dynamic>>().map(fn).toList();
// }
//
// String _toISTHour(String? raw) {
//   if (raw == null || raw.isEmpty) return '';
//   try {
//     final parts = raw.split(':');
//     final h = int.parse(parts[0]);
//     final m = int.parse(parts.length > 1 ? parts[1] : '0');
//     final utc = DateTime.utc(2000, 1, 1, h, m);
//     final ist = utc.add(const Duration(hours: 5, minutes: 30));
//     final hh = ist.hour % 12 == 0 ? 12 : ist.hour % 12;
//     final mm = ist.minute.toString().padLeft(2, '0');
//     final ampm = ist.hour >= 12 ? 'PM' : 'AM';
//     return '$hh:$mm $ampm';
//   } catch (_) {
//     return raw;
//   }
// }

class ReportFilter {
  final String startDate;
  final String endDate;
  final String period;

  const ReportFilter({
    required this.startDate,
    required this.endDate,
    this.period = 'today',
  });
}

class OrderFeedback {
  final int orderId;
  final String feedback;
  final int ratings;
  final String orderType;
  final String date;
  final String time;
  final double grandTotal;
  final String status;
  final String paymentMethod;

  const OrderFeedback({
    required this.orderId,
    required this.feedback,
    required this.ratings,
    required this.orderType,
    required this.date,
    required this.time,
    required this.grandTotal,
    required this.status,
    required this.paymentMethod,
  });

  factory OrderFeedback.fromJson(Map<String, dynamic> j) => OrderFeedback(
    orderId: _i(j['orderId']),
    feedback: j['feedback']?.toString().trim() ?? '',
    ratings: _i(j['ratings']),
    orderType: j['orderType']?.toString() ?? '',
    date: j['date']?.toString() ?? '',
    time: j['time']?.toString() ?? '',
    grandTotal: _d(j['grandTotal']),
    status: j['status']?.toString() ?? '',
    paymentMethod: j['paymentMethod']?.toString() ?? '',
  );
}

class RatingDistribution {
  final int star5;
  final int star4;
  final int star3;
  final int star2;
  final int star1;

  const RatingDistribution({
    this.star5 = 0,
    this.star4 = 0,
    this.star3 = 0,
    this.star2 = 0,
    this.star1 = 0,
  });

  int get total => star5 + star4 + star3 + star2 + star1;

  List<int> get counts => [star5, star4, star3, star2, star1];

  factory RatingDistribution.fromJson(Map<String, dynamic> j) =>
      RatingDistribution(
        star5: _i(j['5Star']),
        star4: _i(j['4Star']),
        star3: _i(j['3Star']),
        star2: _i(j['2Star']),
        star1: _i(j['1Star']),
      );
}

class CategoryRating {
  final String category;
  final String averageRating;
  final int totalRatings;
  final RatingDistribution starBreakdown;

  const CategoryRating({
    required this.category,
    required this.averageRating,
    required this.totalRatings,
    required this.starBreakdown,
  });

  String get displayName {
    switch (category) {
      case 'FOOD_QUALITY':
        return 'Food Quality';
      case 'PACKAGING':
        return 'Packaging';
      case 'DELIVERY':
        return 'Delivery';
      case 'SERVICE':
        return 'Service';
      case 'OTHERS':
        return 'Others';
      default:
        return category
            .split('_')
            .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
            .join(' ');
    }
  }

  factory CategoryRating.fromJson(String key, Map<String, dynamic> j) {
    final sb = j['starBreakdown'];
    return CategoryRating(
      category: key,
      averageRating: j['averageRating']?.toString() ?? '0.00',
      totalRatings: _i(j['totalRatings']),
      starBreakdown: sb is Map<String, dynamic>
          ? RatingDistribution.fromJson(sb)
          : const RatingDistribution(),
    );
  }
}

class ReportData {
  final double totalRevenue;
  final double grossRevenue;
  final double netRevenue;
  final double todayRevenue;
  final double netProfit;
  final double refundAmount;
  final double platformCommission;
  final double avgOrderValue;
  final String profitMargin;
  final double revenueGrowthPercent;
  final String period;

  final int totalOrders;
  final int completedOrders;
  final int cancelledOrders;
  final int pendingOrders;
  final int preparingOrders;
  final int onTheWayOrders;
  final int dineInOrders;
  final int takeawayOrders;
  final int deliveryOrders;

  final int vendorOrders;
  final int userOrders;

  final int successfulPayments;
  final int failedPayments;
  final double pendingPayments;
  final String paymentSuccessRate;
  final Map<String, double> paymentBreakdown;

  final double totalTipAmount;
  final String averageRating;
  final int totalRatings;
  final String ratingGrowthPercent;
  final RatingDistribution ratingDistribution;
  final List<CategoryRating> categoryRatings;
  final List<OrderFeedback> feedbacks;
  final List<DailyStat> dailyStats;
  final List<HourlyStat> hourlyBreakdown;
  final PeakHour? peakHour;
  final Map<String, double> revenueByCategory;
  final Map<String, Map<String, List<CategoryItem>>> allItemsByCategory;
  final DineInVsOnline? dineInVsOnline;

  const ReportData({
    this.totalRevenue = 0,
    this.grossRevenue = 0,
    this.netRevenue = 0,
    this.todayRevenue = 0,
    this.netProfit = 0,
    this.refundAmount = 0,
    this.platformCommission = 0,
    this.avgOrderValue = 0,
    this.profitMargin = '0%',
    this.revenueGrowthPercent = 0,
    this.period = '',
    this.totalOrders = 0,
    this.completedOrders = 0,
    this.cancelledOrders = 0,
    this.pendingOrders = 0,
    this.preparingOrders = 0,
    this.onTheWayOrders = 0,
    this.dineInOrders = 0,
    this.takeawayOrders = 0,
    this.deliveryOrders = 0,
    this.vendorOrders = 0,
    this.userOrders = 0,
    this.successfulPayments = 0,
    this.failedPayments = 0,
    this.pendingPayments = 0,
    this.paymentSuccessRate = '0%',
    this.paymentBreakdown = const {},
    this.totalTipAmount = 0,
    this.averageRating = '0',
    this.totalRatings = 0,
    this.ratingGrowthPercent = '0',
    this.ratingDistribution = const RatingDistribution(),
    this.categoryRatings = const [],
    this.feedbacks = const [],
    this.dailyStats = const [],
    this.hourlyBreakdown = const [],
    this.peakHour,
    this.revenueByCategory = const {},
    this.allItemsByCategory = const {},
    this.dineInVsOnline,
  });

  factory ReportData.fromJson(Map<String, dynamic> j) {
    // paymentBreakdown map
    final pb = <String, double>{};
    if (j['paymentBreakdown'] is Map) {
      (j['paymentBreakdown'] as Map).forEach(
        (k, v) => pb[k.toString()] = _d(v),
      );
    }

    // revenueByCategory map
    final rbc = <String, double>{};
    if (j['revenueByCategory'] is Map) {
      (j['revenueByCategory'] as Map).forEach(
        (k, v) => rbc[k.toString()] = _d(v),
      );
    }

    // allItemsByCategory: Category -> SubCategory -> [dish items]
    final aibc = <String, Map<String, List<CategoryItem>>>{};
    if (j['allItemsByCategory'] is Map) {
      (j['allItemsByCategory'] as Map).forEach((catKey, subMap) {
        if (subMap is Map) {
          final subResult = <String, List<CategoryItem>>{};
          subMap.forEach((subKey, itemsList) {
            if (itemsList is List) {
              subResult[subKey.toString()] = itemsList
                  .whereType<Map<String, dynamic>>()
                  .map(CategoryItem.fromJson)
                  .toList();
            }
          });
          aibc[catKey.toString()] = subResult;
        }
      });
    }

    final feedbacks = <OrderFeedback>[];
    final rawOrders = j['orders'];
    if (rawOrders is List) {
      for (final item in rawOrders) {
        if (item is Map<String, dynamic>) {
          final fb = item['feedback']?.toString().trim() ?? '';
          if (fb.isNotEmpty) {
            feedbacks.add(OrderFeedback.fromJson(item));
          }
        }
      }
    }

    // ratingDistribution — NEW
    final ratingDistribution = j['ratingDistribution'] is Map<String, dynamic>
        ? RatingDistribution.fromJson(
            j['ratingDistribution'] as Map<String, dynamic>,
          )
        : const RatingDistribution();

    // categoryRatings — NEW
    final categoryRatings = <CategoryRating>[];
    if (j['categoryRatings'] is Map) {
      (j['categoryRatings'] as Map).forEach((k, v) {
        if (v is Map<String, dynamic>) {
          categoryRatings.add(CategoryRating.fromJson(k.toString(), v));
        }
      });
    }

    return ReportData(
      totalRevenue: _d(j['totalRevenue']),
      grossRevenue: _d(j['grossRevenue']),
      netRevenue: _d(j['netRevenue']),
      todayRevenue: _d(j['todayRevenue']),
      netProfit: _d(j['netProfit']),
      refundAmount: _d(j['refundAmount']),
      platformCommission: _d(j['platformCommission']),
      avgOrderValue: _d(j['avgOrderValue']),
      profitMargin: j['profitMargin']?.toString() ?? '0%',
      revenueGrowthPercent: _d(j['revenueGrowthPercent']),
      period: j['period']?.toString() ?? '',
      totalOrders: _i(j['totalOrders']),
      completedOrders: _i(j['completedOrders']),
      cancelledOrders: _i(j['cancelledOrders']),
      pendingOrders: _i(j['pendingOrders']),
      preparingOrders: _i(j['preparingOrders']),
      onTheWayOrders: _i(j['onTheWayOrders']),
      dineInOrders: _i(j['dineInOrders']),
      takeawayOrders: _i(j['takeawayOrders']),
      deliveryOrders: _i(j['deliveryOrders']),
      vendorOrders: _i(j['vendorOrders']),
      userOrders: _i(j['userOrders']),
      successfulPayments: _i(j['successfulPayments']),
      failedPayments: _i(j['failedPayments']),
      pendingPayments: _d(j['pendingPayments']),
      paymentSuccessRate: j['paymentSuccessRate']?.toString() ?? '0%',
      paymentBreakdown: pb,
      totalTipAmount: _d(j['totalTipAmount']),
      averageRating: j['averageRating']?.toString() ?? '0',
      totalRatings: _i(j['totalRatings']),
      ratingGrowthPercent: j['ratingGrowthPercent']?.toString() ?? '0',
      ratingDistribution: ratingDistribution,
      categoryRatings: categoryRatings,
      feedbacks: feedbacks,
      dailyStats: _parseList(j['dailyStats'], DailyStat.fromJson),
      hourlyBreakdown: _parseList(
        j['hourlyOrderBreakdown'],
        HourlyStat.fromJson,
      ),
      peakHour: j['peakHourOrders'] is Map
          ? PeakHour.fromJson(j['peakHourOrders'] as Map<String, dynamic>)
          : null,
      revenueByCategory: rbc,
      allItemsByCategory: aibc,
      dineInVsOnline: j['dineInVsOnline'] is Map
          ? DineInVsOnline.fromJson(j['dineInVsOnline'] as Map<String, dynamic>)
          : null,
    );
  }
}

class DailyStat {
  final String date;
  final double revenue;
  final int orders;
  DailyStat({required this.date, required this.revenue, required this.orders});
  factory DailyStat.fromJson(Map<String, dynamic> j) => DailyStat(
    date: j['date']?.toString() ?? '',
    revenue: _d(j['revenue']),
    orders: _i(j['orders']),
  );
}

class HourlyStat {
  final String hour;
  final int orders;
  HourlyStat({required this.hour, required this.orders});
  factory HourlyStat.fromJson(Map<String, dynamic> j) => HourlyStat(
    hour: _toISTHour(j['hour']?.toString()),
    orders: _i(j['orders']),
  );
}

class PeakHour {
  final String hour;
  final int orders;
  PeakHour({required this.hour, required this.orders});
  factory PeakHour.fromJson(Map<String, dynamic> j) => PeakHour(
    hour: _toISTHour(j['hour']?.toString()),
    orders: _i(j['orders']),
  );
}

class CategoryItem {
  final String dish;
  final int quantity;
  final double revenue;
  CategoryItem({
    required this.dish,
    required this.quantity,
    required this.revenue,
  });
  factory CategoryItem.fromJson(Map<String, dynamic> j) => CategoryItem(
    dish: (j['dish'] ?? j['item'])?.toString() ?? '',
    quantity: _i(j['quantity']),
    revenue: _d(j['revenue']),
  );
}

class DineInVsOnline {
  final int dineIn;
  final int online;
  DineInVsOnline({required this.dineIn, required this.online});
  factory DineInVsOnline.fromJson(Map<String, dynamic> j) =>
      DineInVsOnline(dineIn: _i(j['dineIn']), online: _i(j['online']));
}

// ─── Helpers ──────────────────────────────────────────────────────────────────
double _d(dynamic v) =>
    (v is num) ? v.toDouble() : double.tryParse(v?.toString() ?? '') ?? 0.0;
int _i(dynamic v) => (v is int) ? v : int.tryParse(v?.toString() ?? '') ?? 0;

List<T> _parseList<T>(dynamic raw, T Function(Map<String, dynamic>) fn) {
  if (raw is! List) return [];
  return raw.whereType<Map<String, dynamic>>().map(fn).toList();
}

String _toISTHour(String? raw) {
  if (raw == null || raw.isEmpty) return '';
  try {
    final parts = raw.split(':');
    final h = int.parse(parts[0]);
    final m = int.parse(parts.length > 1 ? parts[1] : '0');
    final utc = DateTime.utc(2000, 1, 1, h, m);
    final ist = utc.add(const Duration(hours: 5, minutes: 30));
    final hh = ist.hour % 12 == 0 ? 12 : ist.hour % 12;
    final mm = ist.minute.toString().padLeft(2, '0');
    final ampm = ist.hour >= 12 ? 'PM' : 'AM';
    return '$hh:$mm $ampm';
  } catch (_) {
    return raw;
  }
}
