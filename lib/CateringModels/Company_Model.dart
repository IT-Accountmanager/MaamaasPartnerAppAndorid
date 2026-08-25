// models/order_model.dart
class Order {
  final int orderId;
  final int quotationId;
  final int leadId;
  final int userId;
  final int? customerId;
  final int vendorId;
  final String location;
  final String orderDateTime;
  final String? paymentType;
  final String paymentMethod;
  final String? paymentMethodSecondary;
  final String paymentStatus;
  final String orderStatus;
  final double sgst;
  final double cgst;
  final String cateringDate;
  final String cateringTime;
  final String? fromDate;
  final String? toDate;
  final double subtotal;
  final double platformFeeAmount;
  final double total;
  final String? transactionId;
  final String? transactionId2;
  final String? walletTypes;
  final String? walletUsed;
  final String? razorpayPaymentId;
  final String? razorpayOrderId;
  final String? companyName;
  final double amountPaid;
  final double? discountAmount;
  final double amountRemaining;
  final List<OrderItem> orderItems;
  final String? cancelReason;
  final String? feedback;
  final int? rating;
  final String? event;
  final String? eventType;
  final double? userLatitude;
  final double? userLongitude;
  final double? deliveryDistanceKm;
  final String? mobileNo;
  final String? deliveryUserName;
  final double? deliveryFee;
  final double? distanceInKm;
  final String? appType;
  final String? vendorRegisteredName;
  final String? vendorFssai;
  final String? vendorFullAddress;
  final String? vendorCity;
  final String? vendorState;
  final double? vendorLatitude;
  final double? vendorLongitude;
  final String? vendorGstIn;
  final String? deliveryAddress;

  Order({
    required this.orderId,
    required this.quotationId,
    required this.leadId,
    required this.userId,
    this.customerId,
    required this.vendorId,
    required this.location,
    required this.orderDateTime,
    this.paymentType,
    required this.paymentMethod,
    this.paymentMethodSecondary,
    required this.paymentStatus,
    required this.orderStatus,
    required this.sgst,
    required this.cgst,
    required this.cateringDate,
    required this.cateringTime,
    this.fromDate,
    this.toDate,
    required this.subtotal,
    required this.platformFeeAmount,
    required this.total,
    this.transactionId,
    this.transactionId2,
    this.walletTypes,
    this.walletUsed,
    this.razorpayPaymentId,
    this.razorpayOrderId,
    this.companyName,
    required this.amountPaid,
    this.discountAmount,
    required this.amountRemaining,
    required this.orderItems,
    this.cancelReason,
    this.feedback,
    this.rating,
    this.event,
    this.eventType,
    this.userLatitude,
    this.userLongitude,
    this.deliveryDistanceKm,
    this.mobileNo,
    this.deliveryUserName,
    this.deliveryFee,
    this.distanceInKm,
    this.appType,
    this.vendorRegisteredName,
    this.vendorFssai,
    this.vendorFullAddress,
    this.vendorCity,
    this.vendorState,
    this.vendorLatitude,
    this.vendorLongitude,
    this.vendorGstIn,
    this.deliveryAddress,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      orderId: json['orderId'] ?? 0,
      quotationId: json['quotationId'] ?? 0,
      leadId: json['leadId'] ?? 0,
      userId: json['userId'] ?? 0,
      customerId: json['customerId'],
      vendorId: json['vendorId'] ?? 0,
      location: json['location'] ?? '',
      orderDateTime: json['orderDateTime'] ?? '',
      paymentType: json['paymentType'],
      paymentMethod: json['paymentMethod'] ?? '',
      paymentMethodSecondary: json['paymentMethodSecondary'],
      paymentStatus: json['paymentStatus'] ?? '',
      orderStatus: json['orderStatus'] ?? '',
      sgst: (json['sgst'] ?? 0).toDouble(),
      cgst: (json['cgst'] ?? 0).toDouble(),
      cateringDate: json['cateringDate'] ?? '',
      cateringTime: json['cateringTime'] ?? '',
      fromDate: json['fromDate'],
      toDate: json['toDate'],
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      platformFeeAmount: (json['platformFeeAmount'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
      transactionId: json['transactionId'],
      transactionId2: json['transactionId2'],
      walletTypes: json['walletTypes'],
      walletUsed: json['walletUsed'],
      razorpayPaymentId: json['razorpayPaymentId'],
      razorpayOrderId: json['razorpayOrderId'],
      companyName: json['companyName'],
      amountPaid: (json['amountPaid'] ?? 0).toDouble(),
      discountAmount: json['discountAmount']?.toDouble(),
      amountRemaining: (json['amountRemaining'] ?? 0).toDouble(),
      orderItems: (json['orderItems'] as List? ?? [])
          .map((item) => OrderItem.fromJson(item))
          .toList(),
      cancelReason: json['cancelReason'],
      feedback: json['feedback'],
      rating: json['rating'],
      event: json['event'],
      eventType: json['eventType'],
      userLatitude: json['userLatitude']?.toDouble(),
      userLongitude: json['userLongitude']?.toDouble(),
      deliveryDistanceKm: json['deliveryDistanceKm']?.toDouble(),
      mobileNo: json['mobileNo'],
      deliveryUserName: json['deliveryUserName'],
      deliveryFee: json['deliveryFee']?.toDouble(),
      distanceInKm: json['distanceInKm']?.toDouble(),
      appType: json['appType'],
      vendorRegisteredName: json['vendorRegisteredName'],
      vendorFssai: json['vendorFssai'],
      vendorFullAddress: json['vendorFullAddress'],
      vendorCity: json['vendorCity'],
      vendorState: json['vendorState'],
      vendorLatitude: json['vendorLatitude']?.toDouble(),
      vendorLongitude: json['vendorLongitude']?.toDouble(),
      vendorGstIn: json['vendorGstIn'],
      deliveryAddress: json['deliveryAddress'],
    );
  }
}

class OrderItem {
  final int id;
  final int? packageId;
  final String? packageName;
  final String? packageType;
  final double? packagePrice;
  final int quantity;
  final String? itemsName;
  final List<dynamic> packageItems;

  OrderItem({
    required this.id,
    this.packageId,
    this.packageName,
    this.packageType,
    this.packagePrice,
    required this.quantity,
    this.itemsName,
    required this.packageItems,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] ?? 0,
      packageId: json['packageId'],
      packageName: json['packageName'],
      packageType: json['packageType'],
      packagePrice: json['packagePrice']?.toDouble(),
      quantity: json['quantity'] ?? 0,
      itemsName: json['itemsName'],
      packageItems: json['packageItems'] ?? [],
    );
  }
}
