// lib/CateringModels/OrderItem.dart
class OrderItem {
  final String packageName;
  final int quantity;
  final double price;
  final double totalPrice;

  OrderItem({
    required this.packageName,
    required this.quantity,
    required this.price,
    required this.totalPrice,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      packageName: json['packageName'] as String? ?? '',
      quantity: json['quantity'] as int? ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'packageName': packageName,
      'quantity': quantity,
      'price': price,
      'totalPrice': totalPrice,
    };
  }
}
