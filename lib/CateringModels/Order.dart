import 'OrderItem.dart';

class Order {
  final int orderId;
  final int userId;
  final int vendorId;
  final String location;
  final String orderDateTime;
  final String paymentMethod;
  final String paymentStatus;
  final String orderStatus;
  final double sgst;
  final double cgst;
  final String cateringDate;
  final String cateringTime;
  final double subtotal;
  final double platformFeeAmount;
  final double total;
  final String? transactionId;
  final String? cancelReason;
  final String? feedback;
  final int? rating;
  final List<OrderItem> orderItems;

  Order({
    required this.orderId,
    required this.userId,
    required this.vendorId,
    required this.location,
    required this.orderDateTime,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.orderStatus,
    required this.sgst,
    required this.cgst,
    required this.cateringDate,
    required this.cateringTime,
    required this.subtotal,
    required this.platformFeeAmount,
    required this.total,
    this.transactionId,
    this.cancelReason,
    this.feedback,
    this.rating,
    required this.orderItems,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      orderId: json['orderId'] ?? 0,
      userId: json['userId'] ?? 0,
      vendorId: json['vendorId'] ?? 0,
      location: json['location'] ?? '',
      orderDateTime: json['orderDateTime'] ?? '',
      paymentMethod: json['paymentMethod'] ?? '',
      paymentStatus: json['paymentStatus'] ?? '',
      orderStatus: json['orderStatus'] ?? '',
      sgst: (json['sgst'] ?? 0).toDouble(),
      cgst: (json['cgst'] ?? 0).toDouble(),
      cateringDate: json['cateringDate'] ?? '',
      cateringTime: json['cateringTime'] ?? '',
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      platformFeeAmount: (json['platformFeeAmount'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
      transactionId: json['transactionId'],
      cancelReason: json['cancelReason'],
      feedback: json['feedback'],
      rating: json['rating'],
      orderItems: (json['orderItems'] as List<dynamic>? ?? [])
          .map((item) => OrderItem.fromJson(item))
          .toList(),
    );
  }

  get customerName => null;

  get mobile => null;

  get email => null;

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'userId': userId,
      'vendorId': vendorId,
      'location': location,
      'orderDateTime': orderDateTime,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'orderStatus': orderStatus,
      'sgst': sgst,
      'cgst': cgst,
      'cateringDate': cateringDate,
      'cateringTime': cateringTime,
      'subtotal': subtotal,
      'platformFeeAmount': platformFeeAmount,
      'total': total,
      'transactionId': transactionId,
      'cancelReason': cancelReason,
      'feedback': feedback,
      'rating': rating,
      'orderItems': orderItems.map((e) => e.toJson()).toList(),
    };
  }
}
