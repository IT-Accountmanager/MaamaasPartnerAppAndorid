// class StatisticsResponse {
//   final int weeklyOrders;
//   final double weeklyRevenue;
//   final List<TopSellingItem> topSellingItems;
//   final List<PaymentMethod> paymentDistribution;
//
//   StatisticsResponse({
//     required this.weeklyOrders,
//     required this.weeklyRevenue,
//     required this.topSellingItems,
//     required this.paymentDistribution,
//   });
//
//   factory StatisticsResponse.fromJson(Map<String, dynamic> json) {
//     return StatisticsResponse(
//       weeklyOrders: json['weeklyOrders'] ?? 0,
//       weeklyRevenue: (json['weeklyRevenue'] ?? 0).toDouble(),
//       topSellingItems: List<TopSellingItem>.from(
//         (json['topSellingItems'] ?? []).map((x) => TopSellingItem.fromJson(x)),
//       ),
//       paymentDistribution: List<PaymentMethod>.from(
//         (json['paymentDistribution'] ?? []).map((x) => PaymentMethod.fromJson(x)),
//       ),
//     );
//   }
// }
//
// class TopSellingItem {
//   final String name;
//   final int count;
//
//   TopSellingItem({
//     required this.name,
//     required this.count,
//   });
//
//   factory TopSellingItem.fromJson(Map<String, dynamic> json) {
//     return TopSellingItem(
//       name: json['name'] ?? '',
//       count: json['count'] ?? 0,
//     );
//   }
// }
//
// class PaymentMethod {
//   final String method;
//   final String percentage;
//
//   PaymentMethod({
//     required this.method,
//     required this.percentage,
//   });
//
//   factory PaymentMethod.fromJson(Map<String, dynamic> json) {
//     return PaymentMethod(
//       method: json['method'] ?? '',
//       percentage: json['percentage'] ?? '0%',
//     );
//   }
// }
//
// // Add this class for custom statistics
// class CustomStatisticsResponse {
//   final int totalOrders;
//   final double totalRevenue;
//   final String averageRating;
//
//   CustomStatisticsResponse({
//     required this.totalOrders,
//     required this.totalRevenue,
//     required this.averageRating,
//   });
//
//   factory CustomStatisticsResponse.fromJson(Map<String, dynamic> json) {
//     return CustomStatisticsResponse(
//       totalOrders: json['totalOrders'] ?? 0,
//       totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
//       averageRating: json['averageRating'] ?? '0.00',
//     );
//   }
// }

class CustomStatisticsResponse {
  final int totalOrders;
  final double totalRevenue;
  final String averageRating;
  final double netRevenue;
  final double grossRevenue;
  final String profitMargin;
  final int totalRatings;
  final double discountAmount;
  final Map<String, dynamic>? orderTypeRevenueStats;
  final List<dynamic>? categoryPerformance;
  final List<TopSellingCategoryItem> topSellingByCategory;
  final Map<String, dynamic>? paymentBreakdown;
  final List<dynamic>? dailyStats;

  CustomStatisticsResponse({
    required this.totalOrders,
    required this.totalRevenue,
    required this.averageRating,
    this.netRevenue = 0,
    this.grossRevenue = 0,
    this.profitMargin = '0%',
    this.totalRatings = 0,
    this.discountAmount = 0,
    this.orderTypeRevenueStats,
    this.categoryPerformance,
    required this.topSellingByCategory,
    this.paymentBreakdown,
    this.dailyStats,
  });


  factory CustomStatisticsResponse.fromJson(Map<String, dynamic> json) {
    List<TopSellingCategoryItem> topSellingList = [];

    if (json['allItemsByCategory'] != null) {
      final Map<String, dynamic> categories = json['allItemsByCategory'];

      categories.forEach((category, items) {
        for (var item in items) {
          topSellingList.add(
            TopSellingCategoryItem(
              item: item['item'] ?? '',
              quantity: item['quantity'] ?? 0,
              category: category.toString().trim(),
            ),
          );
        }
      });
    }


    topSellingList.sort((a, b) => b.quantity.compareTo(a.quantity));


    topSellingList = topSellingList.take(8).toList();
    return CustomStatisticsResponse(
      totalOrders: json['totalOrders'] ?? 0,
      totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
      averageRating: json['averageRating']?.toString() ?? '0.00',
      netRevenue: (json['netRevenue'] ?? 0).toDouble(),
      grossRevenue: (json['grossRevenue'] ?? 0).toDouble(),
      profitMargin: json['profitMargin'] ?? '0%',
      totalRatings: json['totalRatings'] ?? 0,
      discountAmount: (json['discountAmount'] ?? 0).toDouble(),
      orderTypeRevenueStats: json['orderTypeRevenueStats'],
      categoryPerformance: json['categoryPerformance'],
      topSellingByCategory: topSellingList, // ✅ THIS LINE IS KEY
      paymentBreakdown: json['paymentBreakdown'],
      dailyStats: json['dailyStats'],
    );
  }
}

class StatisticsResponse {
  final int weeklyOrders;
  final double weeklyRevenue;
  final List<TopSellingItem> topSellingItems;
  final List<PaymentMethod> paymentDistribution;

  StatisticsResponse({
    required this.weeklyOrders,
    required this.weeklyRevenue,
    required this.topSellingItems,
    required this.paymentDistribution,
  });

  factory StatisticsResponse.fromJson(Map<String, dynamic> json) {
    return StatisticsResponse(
      weeklyOrders: json['weeklyOrders'] ?? 0,
      weeklyRevenue: (json['weeklyRevenue'] ?? 0).toDouble(),
      topSellingItems: List<TopSellingItem>.from(
        (json['topSellingItems'] ?? []).map((x) => TopSellingItem.fromJson(x)),
      ),
      paymentDistribution: List<PaymentMethod>.from(
        (json['paymentDistribution'] ?? []).map((x) => PaymentMethod.fromJson(x)),
      ),
    );
  }
}

class TopSellingCategoryItem {
  final String item;
  final int quantity;
  final String category;

  TopSellingCategoryItem({
    required this.item,
    required this.quantity,
    required this.category,
  });
}
class TopSellingItem {
  final String name;
  final int count;

  TopSellingItem({
    required this.name,
    required this.count,
  });

  factory TopSellingItem.fromJson(Map<String, dynamic> json) {
    return TopSellingItem(
      name: json['dishName'] ?? json['name'] ?? '',
      count: json['quantity'] ?? json['count'] ?? 0,
    );
  }
}

class PaymentMethod {
  final String method;
  final String percentage;

  PaymentMethod({
    required this.method,
    required this.percentage,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      method: json['method'] ?? '',
      percentage: json['percentage'] ?? '0%',
    );
  }
}