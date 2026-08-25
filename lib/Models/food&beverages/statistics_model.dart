class StatisticsResponse {
  final int weeklyOrders;
  final int totalCustomers;
  final String successRate;
  final double weeklyRevenue;
  final String salesGrowth;
  final int totalOrders;
  final double totalRevenue;
  final List<TopSellingItem> topSellingItems;
  final double dailyRevenue;
  final List<PaymentDistribution> paymentDistribution;
  final int dailyOrders;

  StatisticsResponse({
    required this.weeklyOrders,
    required this.totalCustomers,
    required this.successRate,
    required this.weeklyRevenue,
    required this.salesGrowth,
    required this.totalOrders,
    required this.totalRevenue,
    required this.topSellingItems,
    required this.dailyRevenue,
    required this.paymentDistribution,
    required this.dailyOrders,
  });

  factory StatisticsResponse.fromJson(Map<String, dynamic> json) {
    return StatisticsResponse(
      weeklyOrders: json['weeklyOrders'] ?? 0,
      totalCustomers: json['totalCustomers'] ?? 0,
      successRate: json['successRate'] ?? '0%',
      weeklyRevenue: (json['weeklyRevenue'] ?? 0.0).toDouble(),
      salesGrowth: json['salesGrowth'] ?? '0%',
      totalOrders: json['totalOrders'] ?? 0,
      totalRevenue: (json['totalRevenue'] ?? 0.0).toDouble(),
      topSellingItems: (json['topSellingItems'] as List<dynamic>?)
          ?.map((item) => TopSellingItem.fromJson(item))
          .toList() ??
          [],
      dailyRevenue: (json['dailyRevenue'] ?? 0.0).toDouble(),
      paymentDistribution: (json['paymentDistribution'] as List<dynamic>?)
          ?.map((item) => PaymentDistribution.fromJson(item))
          .toList() ??
          [],
      dailyOrders: json['dailyOrders'] ?? 0,
    );
  }
}

class TopSellingItem {
  final String name;
  final int count;

  TopSellingItem({
    required this.name,
    required this.count,
  });

  factory TopSellingItem.fromJson(Map<String, dynamic> json) {
    // The JSON has dynamic keys like {"idly": 90}, {"dosa": 50}
    final entry = json.entries.first;
    return TopSellingItem(
      name: entry.key,
      count: entry.value,
    );
  }
}

class PaymentDistribution {
  final String method;
  final String percentage;
  final int count;

  PaymentDistribution({
    required this.method,
    required this.percentage,
    required this.count,
  });

  factory PaymentDistribution.fromJson(Map<String, dynamic> json) {
    return PaymentDistribution(
      method: json['method'] ?? '',
      percentage: json['percentage'] ?? '0%',
      count: json['count'] ?? 0,
    );
  }
}