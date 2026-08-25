class DashboardModel {
  final int weeklyOrders;
  final int totalCustomers;
  final String successRate;
  final double weeklyRevenue;
  final String salesGrowth;
  final int totalOrders;
  final double totalRevenue;
  final double dailyRevenue;
  final int dailyOrders;
  final List<Map<String, dynamic>> topSellingItems;
  final List<PaymentDistribution> paymentDistribution;

  DashboardModel({
    required this.weeklyOrders,
    required this.totalCustomers,
    required this.successRate,
    required this.weeklyRevenue,
    required this.salesGrowth,
    required this.totalOrders,
    required this.totalRevenue,
    required this.dailyRevenue,
    required this.dailyOrders,
    required this.topSellingItems,
    required this.paymentDistribution,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      weeklyOrders: json['weeklyOrders'] ?? 0,
      totalCustomers: json['totalCustomers'] ?? 0,
      successRate: json['successRate'] ?? "0%",
      weeklyRevenue: (json['weeklyRevenue'] ?? 0).toDouble(),
      salesGrowth: json['salesGrowth'] ?? "0%",
      totalOrders: json['totalOrders'] ?? 0,
      totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
      dailyRevenue: (json['dailyRevenue'] ?? 0).toDouble(),
      dailyOrders: json['dailyOrders'] ?? 0,
      topSellingItems: (json['topSellingItems'] as List<dynamic>?)
          ?.map((e) => Map<String, dynamic>.from(e))
          .toList() ??
          [],
      paymentDistribution: (json['paymentDistribution'] as List<dynamic>?)
          ?.map((e) => PaymentDistribution.fromJson(e))
          .toList() ??
          [],
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
