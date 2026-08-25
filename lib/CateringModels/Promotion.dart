class Promotion {
  final String couponCode;
  final double discount;
  final String startDate;
  final String endDate;
  final String description;
  final String goal;
  final double amount;
  final String paymentStatus;
  final String? image;

  Promotion({
    required this.couponCode,
    required this.discount,
    required this.startDate,
    required this.endDate,
    required this.description,
    required this.goal,
    required this.amount,
    required this.paymentStatus,
    this.image,
  });

  factory Promotion.fromJson(Map<String, dynamic> json) {
    return Promotion(
      couponCode: json['couponCode'] ?? '',
      discount: (json['discount'] ?? 0).toDouble(),
      startDate: json['startDate'] ?? '',
      endDate: json['endDate'] ?? '',
      description: json['description'] ?? '',
      goal: json['goal'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      paymentStatus: json['paymentStatus'] ?? 'PENDING',
      image: json['image']?.toString(),
    );
  }
}
