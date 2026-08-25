
class DashboardModel {
  final double todayRevenue;
  final String period;
  final int totalCustomers;
  final String successRate;
  final int todayOrders;
  final int totalOrders;
  final double totalRevenue;
  final List<TopSellingItem> topSellingItems;
  final List<PaymentDistribution> paymentDistribution;

  DashboardModel({
    required this.todayRevenue,
    required this.period,
    required this.totalCustomers,
    required this.successRate,
    required this.todayOrders,
    required this.totalOrders,
    required this.totalRevenue,
    required this.topSellingItems,
    required this.paymentDistribution,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      todayRevenue: (json['todayRevenue'] ?? 0).toDouble(),
      period: json['period'] ?? '',
      totalCustomers: json['totalCustomers'] ?? 0,
      successRate: json['successRate'] ?? '0%',
      todayOrders: json['todayOrders'] ?? 0,
      totalOrders: json['totalOrders'] ?? 0,
      totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
      topSellingItems: (json['topSellingItems'] as List? ?? [])
          .map((item) => TopSellingItem.fromJson(item))
          .toList(),
      paymentDistribution: (json['paymentDistribution'] as List? ?? [])
          .map((payment) => PaymentDistribution.fromJson(payment))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'todayRevenue': todayRevenue,
      'period': period,
      'totalCustomers': totalCustomers,
      'successRate': successRate,
      'todayOrders': todayOrders,
      'totalOrders': totalOrders,
      'totalRevenue': totalRevenue,
      'topSellingItems': topSellingItems.map((item) => item.toJson()).toList(),
      'paymentDistribution': paymentDistribution
          .map((payment) => payment.toJson())
          .toList(),
    };
  }
}

class TopSellingItem {
  final String item;
  final int quantity;

  TopSellingItem({required this.item, required this.quantity});

  factory TopSellingItem.fromJson(Map<String, dynamic> json) {
    return TopSellingItem(
      item: json['item'] ?? '',
      quantity: json['quantity'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'item': item, 'quantity': quantity};
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

  Map<String, dynamic> toJson() {
    return {'method': method, 'percentage': percentage, 'count': count};
  }
}
