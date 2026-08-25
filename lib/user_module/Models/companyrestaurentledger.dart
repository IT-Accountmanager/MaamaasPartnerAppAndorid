class CompanyRestaurantLedger {
  final String companyName;
  final String restaurantName;
  final double totalAmount;

  CompanyRestaurantLedger({
    required this.companyName,
    required this.restaurantName,
    required this.totalAmount,
  });

  factory CompanyRestaurantLedger.fromJson(Map<String, dynamic> json) {
    return CompanyRestaurantLedger(
      companyName: json['companyName'],
      restaurantName: json['restaurantName'],
      totalAmount: (json['totalAmount'] as num).toDouble(),
    );
  }
}