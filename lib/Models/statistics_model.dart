class DashboardStatsModel {
  final double dailyRevenue;
  final int dailyOrders;
  final List<PaymentDistribution> paymentDistribution;

  DashboardStatsModel({
    required this.dailyRevenue,
    required this.dailyOrders,
    required this.paymentDistribution,
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    return DashboardStatsModel(
      dailyRevenue: (json['dailyRevenue'] ?? 0.0) as double,
      dailyOrders: (json['dailyOrders'] ?? 0) as int,
      paymentDistribution: json['paymentDistribution'] != null
          ? (json['paymentDistribution'] as List)
          .map((item) => PaymentDistribution.fromJson(item))
          .toList()
          : [],
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
      method: json['method'] ?? 'Unknown',
      percentage: json['percentage'] ?? '0%',
      count: json['count'] ?? 0,
    );
  }
}