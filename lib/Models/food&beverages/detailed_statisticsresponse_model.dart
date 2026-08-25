// // Add these classes to your existing model file
//
// class DetailedStatisticsResponse {
//   final String period;
//   final double netRevenue;
//   final double grossRevenue;
//   final double totalRevenue;
//   final int totalOrders;
//   final int totalRatings;
//   final String averageRating;
//   final String profitMargin;
//   final OrderTypeRevenueStats orderTypeRevenueStats;
//   final List<CategoryPerformance> categoryPerformance;
//   final List<TopSellingItemByCategory> topSellingByCategory;
//   final PaymentBreakdown paymentBreakdown;
//   final List<DailyStat> dailyStats;
//
//   DetailedStatisticsResponse({
//     required this.period,
//     required this.netRevenue,
//     required this.grossRevenue,
//     required this.totalRevenue,
//     required this.totalOrders,
//     required this.totalRatings,
//     required this.averageRating,
//     required this.profitMargin,
//     required this.orderTypeRevenueStats,
//     required this.categoryPerformance,
//     required this.topSellingByCategory,
//     required this.paymentBreakdown,
//     required this.dailyStats,
//   });
//
//   factory DetailedStatisticsResponse.fromJson(Map<String, dynamic> json) {
//     return DetailedStatisticsResponse(
//       period: json['period'] ?? '',
//       netRevenue: (json['netRevenue'] ?? 0).toDouble(),
//       grossRevenue: (json['grossRevenue'] ?? 0).toDouble(),
//       totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
//       totalOrders: json['totalOrders'] ?? 0,
//       totalRatings: json['totalRatings'] ?? 0,
//       averageRating: json['averageRating'] ?? '0.00',
//       profitMargin: json['profitMargin'] ?? '0%',
//       orderTypeRevenueStats: OrderTypeRevenueStats.fromJson(json['orderTypeRevenueStats'] ?? {}),
//       categoryPerformance: List<CategoryPerformance>.from(
//         (json['categoryPerformance'] ?? []).map((x) => CategoryPerformance.fromJson(x)),
//       ),
//       topSellingByCategory: List<TopSellingItemByCategory>.from(
//         (json['topSellingByCategory'] ?? []).map((x) => TopSellingItemByCategory.fromJson(x)),
//       ),
//       paymentBreakdown: PaymentBreakdown.fromJson(json['paymentBreakdown'] ?? {}),
//       dailyStats: List<DailyStat>.from(
//         (json['dailyStats'] ?? []).map((x) => DailyStat.fromJson(x)),
//       ),
//     );
//   }
// }
//
// class OrderTypeRevenueStats {
//   final OrderTypeStats total;
//   final OrderTypeStats takeaway;
//   final OrderTypeStats dineIn;
//   final OrderTypeStats delivery;
//
//   OrderTypeRevenueStats({
//     required this.total,
//     required this.takeaway,
//     required this.dineIn,
//     required this.delivery,
//   });
//   factory OrderTypeRevenueStats.fromJson(Map<String, dynamic> json) {
//     return OrderTypeRevenueStats(
//       total: OrderTypeStats.fromJson(json['TOTAL'] ?? {}),
//       takeaway: OrderTypeStats.fromJson(json['TAKEAWAY'] ?? {}),
//       dineIn: OrderTypeStats.fromJson(json['DINE_IN'] ?? {}),
//       delivery: OrderTypeStats.fromJson(json['DELIVERY'] ?? {}),
//     );
//   }
//
// }
//
// class OrderTypeStats {
//   final double revenue;
//   final String percentage;
//   final int count;
//
//   OrderTypeStats({
//     required this.revenue,
//     required this.percentage,
//     required this.count,
//   });
//
//   factory OrderTypeStats.fromJson(Map<String, dynamic> json) {
//     return OrderTypeStats(
//       revenue: (json['revenue'] ?? 0).toDouble(),
//       percentage: json['percentage'] ?? '0%',
//       count: json['count'] ?? 0,
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'revenue': revenue,
//       'percentage': percentage,
//       'count': count,
//     };
//   }
// }
//
// class CategoryPerformance {
//   final double revenue;
//   final String percentage;
//   final String category;
//
//   CategoryPerformance({
//     required this.revenue,
//     required this.percentage,
//     required this.category,
//   });
//
//   factory CategoryPerformance.fromJson(Map<String, dynamic> json) {
//     return CategoryPerformance(
//       revenue: (json['revenue'] ?? 0).toDouble(),
//       percentage: json['percentage'] ?? '0%',
//       category: json['category'] ?? '',
//     );
//   }
// }
//
// class TopSellingItemByCategory {
//   final String item;
//   final int quantity;
//   final String category;
//
//   TopSellingItemByCategory({
//     required this.item,
//     required this.quantity,
//     required this.category,
//   });
//
//   factory TopSellingItemByCategory.fromJson(Map<String, dynamic> json) {
//     return TopSellingItemByCategory(
//       item: json['item'] ?? '',
//       quantity: json['quantity'] ?? 0,
//       category: json['category'] ?? '',
//     );
//   }
// }
//
// class PaymentBreakdown {
//   final double onlinePayment;
//   final double cash;
//   final double maamaasWallet;
//
//   PaymentBreakdown({
//     required this.onlinePayment,
//     required this.cash,
//     required this.maamaasWallet,
//   });
//
//   factory PaymentBreakdown.fromJson(Map<String, dynamic> json) {
//     return PaymentBreakdown(
//       onlinePayment: (json['Online_Payment'] ?? 0).toDouble(),
//       cash: (json['Cash'] ?? 0).toDouble(),
//       maamaasWallet: (json['Maamaas_Wallet'] ?? 0).toDouble(),
//     );
//   }
// }
//
// class DailyStat {
//   final String date;
//   final double revenue;
//   final int orders;
//
//   DailyStat({
//     required this.date,
//     required this.revenue,
//     required this.orders,
//   });
//
//   factory DailyStat.fromJson(Map<String, dynamic> json) {
//     return DailyStat(
//       date: json['date'] ?? '',
//       revenue: (json['revenue'] ?? 0).toDouble(),
//       orders: json['orders'] ?? 0,
//     );
//   }
// }
// class DetailedStatisticsResponse {
//   final String period;
//   final double netRevenue;
//   final double grossRevenue;
//   final double totalRevenue;
//   final int totalOrders;
//   final int totalRatings;
//   final String averageRating;
//   final String profitMargin;
//   final double discountAmount;
//   final OrderTypeRevenueStats orderTypeRevenueStats;
//   final List<CategoryPerformance> categoryPerformance;
//   final List<TopSellingItemByCategory> topSellingByCategory;
//   final PaymentBreakdown paymentBreakdown;
//   final List<DailyStat> dailyStats;
//
//   DetailedStatisticsResponse({
//     required this.period,
//     required this.netRevenue,
//     required this.grossRevenue,
//     required this.totalRevenue,
//     required this.totalOrders,
//     required this.totalRatings,
//     required this.averageRating,
//     required this.profitMargin,
//     required this.discountAmount,
//     required this.orderTypeRevenueStats,
//     required this.categoryPerformance,
//     required this.topSellingByCategory,
//     required this.paymentBreakdown,
//     required this.dailyStats,
//   });
//
//   factory DetailedStatisticsResponse.fromJson(Map<String, dynamic> json) {
//     // Parse topSellingByCategory from allItemsByCategory
//     List<TopSellingItemByCategory> topSellingList = [];
//
//     if (json['allItemsByCategory'] != null) {
//       final Map<String, dynamic> categories = json['allItemsByCategory'];
//
//       categories.forEach((category, items) {
//         for (var item in items) {
//           topSellingList.add(
//             TopSellingItemByCategory(
//               item: item['item'] ?? '',
//               quantity: item['quantity'] ?? 0,
//               category: category.toString().trim(),
//             ),
//           );
//         }
//       });
//
//       // Sort by quantity descending and take top 8
//       topSellingList.sort((a, b) => b.quantity.compareTo(a.quantity));
//       topSellingList = topSellingList.take(8).toList();
//     }
//
//     return DetailedStatisticsResponse(
//       period: json['period'] ?? '',
//       netRevenue: (json['netRevenue'] ?? 0).toDouble(),
//       grossRevenue: (json['grossRevenue'] ?? 0).toDouble(),
//       totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
//       totalOrders: json['totalOrders'] ?? 0,
//       totalRatings: json['totalRatings'] ?? 0,
//       averageRating: json['averageRating']?.toString() ?? '0.00',
//       profitMargin: json['profitMargin'] ?? '0%',
//       discountAmount: (json['discountAmount'] ?? 0).toDouble(),
//       orderTypeRevenueStats: OrderTypeRevenueStats.fromJson(
//         json['orderTypeRevenueStats'] ?? {},
//       ),
//       categoryPerformance: List<CategoryPerformance>.from(
//         (json['categoryPerformance'] ?? []).map(
//           (x) => CategoryPerformance.fromJson(x),
//         ),
//       ),
//       topSellingByCategory: topSellingList, // Use the parsed list
//       paymentBreakdown: PaymentBreakdown.fromJson(
//         json['paymentBreakdown'] ?? {},
//       ),
//       dailyStats: List<DailyStat>.from(
//         (json['dailyStats'] ?? []).map((x) => DailyStat.fromJson(x)),
//       ),
//     );
//   }
// }
//
// class OrderTypeRevenueStats {
//   final OrderTypeStats total;
//   final OrderTypeStats takeaway;
//   final OrderTypeStats dineIn;
//   final OrderTypeStats delivery;
//
//   OrderTypeRevenueStats({
//     required this.total,
//     required this.takeaway,
//     required this.dineIn,
//     required this.delivery,
//   });
//
//   factory OrderTypeRevenueStats.fromJson(Map<String, dynamic> json) {
//     return OrderTypeRevenueStats(
//       total: OrderTypeStats.fromJson(json['TOTAL'] ?? {}),
//       takeaway: OrderTypeStats.fromJson(json['TAKEAWAY'] ?? {}),
//       dineIn: OrderTypeStats.fromJson(json['DINE_IN'] ?? {}),
//       delivery: OrderTypeStats.fromJson(json['DELIVERY'] ?? {}),
//     );
//   }
// }
//
// class OrderTypeStats {
//   final double revenue;
//   final String percentage;
//   final int count;
//
//   OrderTypeStats({
//     required this.revenue,
//     required this.percentage,
//     required this.count,
//   });
//
//   factory OrderTypeStats.fromJson(Map<String, dynamic> json) {
//     return OrderTypeStats(
//       revenue: (json['revenue'] ?? 0).toDouble(),
//       percentage: json['percentage']?.toString() ?? '0%',
//       count: json['count'] ?? 0,
//     );
//   }
// }
//
// class CategoryPerformance {
//   final double revenue;
//   final String percentage;
//   final String category;
//
//   CategoryPerformance({
//     required this.revenue,
//     required this.percentage,
//     required this.category,
//   });
//
//   factory CategoryPerformance.fromJson(Map<String, dynamic> json) {
//     return CategoryPerformance(
//       revenue: (json['revenue'] ?? 0).toDouble(),
//       percentage: json['percentage']?.toString() ?? '0%',
//       category: json['category'] ?? '',
//     );
//   }
// }
//
// class TopSellingItemByCategory {
//   final String item;
//   final int quantity;
//   final String category;
//
//   TopSellingItemByCategory({
//     required this.item,
//     required this.quantity,
//     required this.category,
//   });
//
//   factory TopSellingItemByCategory.fromJson(Map<String, dynamic> json) {
//     return TopSellingItemByCategory(
//       item: json['item'] ?? '',
//       quantity: json['quantity'] ?? 0,
//       category: json['category'] ?? '',
//     );
//   }
// }
//
// class PaymentBreakdown {
//   final double onlinePayment;
//   final double cash;
//   final double maamaasWallet;
//
//   PaymentBreakdown({
//     required this.onlinePayment,
//     required this.cash,
//     required this.maamaasWallet,
//   });
//
//   factory PaymentBreakdown.fromJson(Map<String, dynamic> json) {
//     return PaymentBreakdown(
//       onlinePayment: (json['Online_Payment'] ?? 0).toDouble(),
//       cash: (json['Cash'] ?? 0).toDouble(),
//       maamaasWallet: (json['Maamaas_Wallet'] ?? 0).toDouble(),
//     );
//   }
// }
//
// class DailyStat {
//   final String date;
//   final double revenue;
//   final int orders;
//
//   DailyStat({required this.date, required this.revenue, required this.orders});
//
//   factory DailyStat.fromJson(Map<String, dynamic> json) {
//     return DailyStat(
//       date: json['date'] ?? '',
//       revenue: (json['revenue'] ?? 0).toDouble(),
//       orders: json['orders'] ?? 0,
//     );
//   }
// }

// class DetailedStatisticsResponse {
//   final String period;
//   final double netRevenue;
//   final double grossRevenue;
//   final double totalRevenue;
//   final int totalOrders;
//   final int totalRatings;
//   final String averageRating;
//   final String profitMargin;
//   final double discountAmount;
//
//   // ✅ NEW FIELDS
//   final int dineInOrders;
//   final int takeawayOrders;
//   final int deliveryOrders;
//
//   final OrderTypeRevenueStats orderTypeRevenueStats;
//   final List<CategoryPerformance> categoryPerformance;
//   final List<TopSellingItemByCategory> topSellingByCategory;
//   final PaymentBreakdown paymentBreakdown;
//   final List<DailyStat> dailyStats;
//
//   DetailedStatisticsResponse({
//     required this.period,
//     required this.netRevenue,
//     required this.grossRevenue,
//     required this.totalRevenue,
//     required this.totalOrders,
//     required this.totalRatings,
//     required this.averageRating,
//     required this.profitMargin,
//     required this.discountAmount,
//
//     // ✅ NEW
//     required this.dineInOrders,
//     required this.takeawayOrders,
//     required this.deliveryOrders,
//
//     required this.orderTypeRevenueStats,
//     required this.categoryPerformance,
//     required this.topSellingByCategory,
//     required this.paymentBreakdown,
//     required this.dailyStats,
//   });
//
//   factory DetailedStatisticsResponse.fromJson(Map<String, dynamic> json) {
//     List<TopSellingItemByCategory> topSellingList = [];
//
//     if (json['allItemsByCategory'] != null) {
//       final Map<String, dynamic> categories = json['allItemsByCategory'];
//
//       categories.forEach((category, items) {
//         for (var item in items) {
//           topSellingList.add(
//             TopSellingItemByCategory(
//               item: item['item'] ?? '',
//               quantity: item['quantity'] ?? 0,
//               category: category.toString().trim(),
//             ),
//           );
//         }
//       });
//
//       // Sort by quantity descending and take top 8
//       topSellingList.sort((a, b) => b.quantity.compareTo(a.quantity));
//       topSellingList = topSellingList.take(8).toList();
//     }
//
//     return DetailedStatisticsResponse(
//       period: json['period'] ?? '',
//       netRevenue: (json['netRevenue'] ?? 0).toDouble(),
//       grossRevenue: (json['grossRevenue'] ?? 0).toDouble(),
//       totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
//       totalOrders: json['totalOrders'] ?? 0,
//       totalRatings: json['totalRatings'] ?? 0,
//       averageRating: json['averageRating']?.toString() ?? '0.00',
//       profitMargin: json['profitMargin'] ?? '0%',
//       discountAmount: (json['discountAmount'] ?? 0).toDouble(),
//
//       // ✅ NEW FIELDS PARSING
//       dineInOrders: (json['dineInOrders'] ?? 0).toInt(),
//       takeawayOrders: (json['takeawayOrders'] ?? 0).toInt(),
//       deliveryOrders: (json['deliveryOrders'] ?? 0).toInt(),
//
//       orderTypeRevenueStats: OrderTypeRevenueStats.fromJson(
//         json['orderTypeRevenueStats'] ?? {},
//       ),
//       categoryPerformance: List<CategoryPerformance>.from(
//         (json['categoryPerformance'] ?? []).map(
//               (x) => CategoryPerformance.fromJson(x),
//         ),
//       ),
//       topSellingByCategory: topSellingList,
//       paymentBreakdown: PaymentBreakdown.fromJson(
//         json['paymentBreakdown'] ?? {},
//       ),
//       dailyStats: List<DailyStat>.from(
//         (json['dailyStats'] ?? []).map((x) => DailyStat.fromJson(x)),
//       ),
//     );
//   }
// }
//
// class OrderTypeRevenueStats {
//   final OrderTypeStats total;
//   final OrderTypeStats takeaway;
//   final OrderTypeStats dineIn;
//   final OrderTypeStats delivery;
//
//   OrderTypeRevenueStats({
//     required this.total,
//     required this.takeaway,
//     required this.dineIn,
//     required this.delivery,
//   });
//
//   factory OrderTypeRevenueStats.fromJson(Map<String, dynamic> json) {
//     return OrderTypeRevenueStats(
//       total: OrderTypeStats.fromJson(json['TOTAL'] ?? {}),
//       takeaway: OrderTypeStats.fromJson(json['TAKEAWAY'] ?? {}),
//       dineIn: OrderTypeStats.fromJson(json['DINE_IN'] ?? {}),
//       delivery: OrderTypeStats.fromJson(json['DELIVERY'] ?? {}),
//     );
//   }
// }
//
// class OrderTypeStats {
//   final double revenue;
//   final String percentage;
//   final int count;
//
//   OrderTypeStats({
//     required this.revenue,
//     required this.percentage,
//     required this.count,
//   });
//
//   factory OrderTypeStats.fromJson(Map<String, dynamic> json) {
//     return OrderTypeStats(
//       revenue: (json['revenue'] ?? 0).toDouble(),
//       percentage: json['percentage']?.toString() ?? '0%',
//       count: json['count'] ?? 0,
//     );
//   }
// }
//
// class CategoryPerformance {
//   final double revenue;
//   final String percentage;
//   final String category;
//
//   CategoryPerformance({
//     required this.revenue,
//     required this.percentage,
//     required this.category,
//   });
//
//   factory CategoryPerformance.fromJson(Map<String, dynamic> json) {
//     return CategoryPerformance(
//       revenue: (json['revenue'] ?? 0).toDouble(),
//       percentage: json['percentage']?.toString() ?? '0%',
//       category: json['category'] ?? '',
//     );
//   }
// }
//
// class TopSellingItemByCategory {
//   final String item;
//   final int quantity;
//   final String category;
//
//   TopSellingItemByCategory({
//     required this.item,
//     required this.quantity,
//     required this.category,
//   });
//
//   factory TopSellingItemByCategory.fromJson(Map<String, dynamic> json) {
//     return TopSellingItemByCategory(
//       item: json['item'] ?? '',
//       quantity: json['quantity'] ?? 0,
//       category: json['category'] ?? '',
//     );
//   }
// }
//
// class PaymentBreakdown {
//   final double onlinePayment;
//   final double cash;
//   final double maamaasWallet;
//
//   PaymentBreakdown({
//     required this.onlinePayment,
//     required this.cash,
//     required this.maamaasWallet,
//   });
//
//   factory PaymentBreakdown.fromJson(Map<String, dynamic> json) {
//     return PaymentBreakdown(
//       onlinePayment: (json['Online_Payment'] ?? 0).toDouble(),
//       cash: (json['Cash'] ?? 0).toDouble(),
//       maamaasWallet: (json['Maamaas_Wallet'] ?? 0).toDouble(),
//     );
//   }
// }
//
// class DailyStat {
//   final String date;
//   final double revenue;
//   final int orders;
//
//   DailyStat({
//     required this.date,
//     required this.revenue,
//     required this.orders,
//   });
//
//   factory DailyStat.fromJson(Map<String, dynamic> json) {
//     return DailyStat(
//       date: json['date'] ?? '',
//       revenue: (json['revenue'] ?? 0).toDouble(),
//       orders: json['orders'] ?? 0,
//     );
//   }
// }

class DetailedStatisticsResponse {
  final String period;
  final double netRevenue;
  final double grossRevenue;
  final double totalRevenue;
  final int totalOrders;
  final int totalRatings;
  final String averageRating;
  final String profitMargin;
  final double discountAmount;

  final int dineInOrders;
  final int takeawayOrders;
  final int deliveryOrders;

  // ✅ Add these four as proper final fields
  final int completedOrders;
  final int cancelledOrders;
  final int pendingOrders;
  final int preparingOrders;

  final OrderTypeRevenueStats orderTypeRevenueStats;
  final List<CategoryPerformance> categoryPerformance;
  final List<TopSellingItemByCategory> topSellingByCategory;
  final Map<String, double> paymentBreakdown;
  final List<DailyStat> dailyStats;

  DetailedStatisticsResponse({
    required this.period,
    required this.netRevenue,
    required this.grossRevenue,
    required this.totalRevenue,
    required this.totalOrders,
    required this.totalRatings,
    required this.averageRating,
    required this.profitMargin,
    required this.discountAmount,
    required this.dineInOrders,
    required this.takeawayOrders,
    required this.deliveryOrders,
    required this.completedOrders,   // ✅
    required this.cancelledOrders,   // ✅
    required this.pendingOrders,     // ✅
    required this.preparingOrders,   // ✅
    required this.orderTypeRevenueStats,
    required this.categoryPerformance,
    required this.topSellingByCategory,
    required this.paymentBreakdown,
    required this.dailyStats,
  });

  factory DetailedStatisticsResponse.fromJson(Map<String, dynamic> json) {
    List<TopSellingItemByCategory> topSellingList = [];
    if (json['allItemsByCategory'] != null) {
      final Map<String, dynamic> categories = json['allItemsByCategory'];
      categories.forEach((category, items) {
        for (var item in items) {
          topSellingList.add(
            TopSellingItemByCategory(
              item: item['item'] ?? '',
              quantity: item['quantity'] ?? 0,
              category: category.toString().trim(),
            ),
          );
        }
      });
      topSellingList.sort((a, b) => b.quantity.compareTo(a.quantity));
      topSellingList = topSellingList.take(8).toList();
    }

    final pb = <String, double>{};
    if (json['paymentBreakdown'] is Map) {
      (json['paymentBreakdown'] as Map).forEach(
            (k, v) => pb[k.toString()] = (v is num) ? v.toDouble() : 0.0,
      );
    }

    return DetailedStatisticsResponse(
      period: json['period'] ?? '',
      netRevenue: (json['netRevenue'] ?? 0).toDouble(),
      grossRevenue: (json['grossRevenue'] ?? 0).toDouble(),
      totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
      totalOrders: (json['totalOrders'] ?? 0).toInt(),
      totalRatings: (json['totalRatings'] ?? 0).toInt(),
      averageRating: json['averageRating']?.toString() ?? '0.00',
      profitMargin: json['profitMargin'] ?? '0%',
      discountAmount: (json['discountAmount'] ?? 0).toDouble(),
      dineInOrders: (json['dineInOrders'] ?? 0).toInt(),
      takeawayOrders: (json['takeawayOrders'] ?? 0).toInt(),
      deliveryOrders: (json['deliveryOrders'] ?? 0).toInt(),
      completedOrders: (json['completedOrders'] ?? 0).toInt(),   // ✅
      cancelledOrders: (json['cancelledOrders'] ?? 0).toInt(),   // ✅
      pendingOrders: (json['pendingOrders'] ?? 0).toInt(),       // ✅
      preparingOrders: (json['preparingOrders'] ?? 0).toInt(),   // ✅
      orderTypeRevenueStats: OrderTypeRevenueStats.fromJson(
        json['orderTypeRevenueStats'] ?? {},
      ),
      categoryPerformance: List<CategoryPerformance>.from(
        (json['categoryPerformance'] ?? []).map(
              (x) => CategoryPerformance.fromJson(x),
        ),
      ),
      topSellingByCategory: topSellingList,
      paymentBreakdown: pb,
      dailyStats: List<DailyStat>.from(
        (json['dailyStats'] ?? []).map((x) => DailyStat.fromJson(x)),
      ),
    );
  }
}

// ─── OrderTypeRevenueStats ────────────────────────────────────────────────────
class OrderTypeRevenueStats {
  final OrderTypeStats total;
  final OrderTypeStats takeaway;
  final OrderTypeStats dineIn;
  final OrderTypeStats delivery;

  OrderTypeRevenueStats({
    required this.total,
    required this.takeaway,
    required this.dineIn,
    required this.delivery,
  });

  factory OrderTypeRevenueStats.fromJson(Map<String, dynamic> json) {
    return OrderTypeRevenueStats(
      total: OrderTypeStats.fromJson(json['TOTAL'] ?? {}),
      takeaway: OrderTypeStats.fromJson(json['TAKEAWAY'] ?? {}),
      dineIn: OrderTypeStats.fromJson(json['DINE_IN'] ?? {}),
      delivery: OrderTypeStats.fromJson(json['DELIVERY'] ?? {}),
    );
  }
}

// ─── OrderTypeStats ───────────────────────────────────────────────────────────
class OrderTypeStats {
  final double revenue;
  final String percentage;
  final int count;

  OrderTypeStats({
    required this.revenue,
    required this.percentage,
    required this.count,
  });

  factory OrderTypeStats.fromJson(Map<String, dynamic> json) {
    return OrderTypeStats(
      revenue: (json['revenue'] ?? 0).toDouble(),
      percentage: json['percentage']?.toString() ?? '0%',
      count: json['count'] ?? 0,
    );
  }
}

// ─── CategoryPerformance ──────────────────────────────────────────────────────
class CategoryPerformance {
  final double revenue;
  final String percentage;
  final String category;

  CategoryPerformance({
    required this.revenue,
    required this.percentage,
    required this.category,
  });

  factory CategoryPerformance.fromJson(Map<String, dynamic> json) {
    return CategoryPerformance(
      revenue: (json['revenue'] ?? 0).toDouble(),
      percentage: json['percentage']?.toString() ?? '0%',
      category: json['category'] ?? '',
    );
  }
}

// ─── TopSellingItemByCategory ─────────────────────────────────────────────────
class TopSellingItemByCategory {
  final String item;
  final int quantity;
  final String category;

  TopSellingItemByCategory({
    required this.item,
    required this.quantity,
    required this.category,
  });

  factory TopSellingItemByCategory.fromJson(Map<String, dynamic> json) {
    return TopSellingItemByCategory(
      item: json['item'] ?? '',
      quantity: json['quantity'] ?? 0,
      category: json['category'] ?? '',
    );
  }
}

// ─── DailyStat ────────────────────────────────────────────────────────────────
class DailyStat {
  final String date;
  final double revenue;
  final int orders;

  DailyStat({required this.date, required this.revenue, required this.orders});

  factory DailyStat.fromJson(Map<String, dynamic> json) {
    return DailyStat(
      date: json['date'] ?? '',
      revenue: (json['revenue'] ?? 0).toDouble(),
      orders: json['orders'] ?? 0,
    );
  }
}
