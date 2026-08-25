// Add this model class for Catering Orders
class CateringOrder {
  final int orderId;
  final int quotationId;
  final int leadId;
  final int userId;
  final int? customerId;
  final int vendorId;
  final String location;
  final DateTime orderDateTime;
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
  final String razorpayPaymentId;
  final String? razorpayOrderId;
  final String? companyName;
  final double amountPaid;
  final double discountAmount;
  final double amountRemaining;
  final List<CateringOrderItem> orderItems;
  final String? cancelReason;
  final String? feedback;
  final int? rating;
  final String event;
  final String eventType;
  final double userLatitude;
  final double userLongitude;
  final double? deliveryDistanceKm;
  final String? mobileNo;
  final String? deliveryUserName;
  final double deliveryFee;
  final double distanceInKm;
  final String? appType;
  final String? vendorRegisteredName;
  final String vendorFssai;
  final String vendorFullAddress;
  final String vendorCity;
  final String vendorState;
  final double vendorLatitude;
  final double vendorLongitude;
  final String vendorGstIn;
  final String? deliveryAddress;

  CateringOrder({
    required this.orderId,
    required this.quotationId,
    required this.leadId,
    required this.userId,
    this.customerId,
    required this.vendorId,
    required this.location,
    required this.orderDateTime,
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
    required this.razorpayPaymentId,
    this.razorpayOrderId,
    this.companyName,
    required this.amountPaid,
    required this.discountAmount,
    required this.amountRemaining,
    required this.orderItems,
    this.cancelReason,
    this.feedback,
    this.rating,
    required this.event,
    required this.eventType,
    required this.userLatitude,
    required this.userLongitude,
    this.deliveryDistanceKm,
    this.mobileNo,
    this.deliveryUserName,
    required this.deliveryFee,
    required this.distanceInKm,
    this.appType,
    this.vendorRegisteredName,
    required this.vendorFssai,
    required this.vendorFullAddress,
    required this.vendorCity,
    required this.vendorState,
    required this.vendorLatitude,
    required this.vendorLongitude,
    required this.vendorGstIn,
    this.deliveryAddress,
  });

  factory CateringOrder.fromJson(Map<String, dynamic> json) {
    return CateringOrder(
      orderId: json['orderId'] ?? 0,
      quotationId: json['quotationId'] ?? 0,
      leadId: json['leadId'] ?? 0,
      userId: json['userId'] ?? 0,
      customerId: json['customerId'],
      vendorId: json['vendorId'] ?? 0,
      location: json['location'] ?? 'Default Location',
      orderDateTime: DateTime.parse(
        json['orderDateTime'] ?? DateTime.now().toIso8601String(),
      ),
      paymentMethod: json['paymentMethod'] ?? '',
      paymentMethodSecondary: json['paymentMethodSecondary'],
      paymentStatus: json['paymentStatus'] ?? '',
      orderStatus: json['orderStatus'] ?? '',
      sgst: (json['sgst'] as num?)?.toDouble() ?? 0.0,
      cgst: (json['cgst'] as num?)?.toDouble() ?? 0.0,
      cateringDate: json['cateringDate'] ?? '',
      cateringTime: json['cateringTime'] ?? '',
      fromDate: json['fromDate'],
      toDate: json['toDate'],
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      platformFeeAmount: (json['platformFeeAmount'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      transactionId: json['transactionId'],
      transactionId2: json['transactionId2'],
      walletTypes: json['walletTypes'],
      walletUsed: json['walletUsed'],
      razorpayPaymentId: json['razorpayPaymentId'] ?? '',
      razorpayOrderId: json['razorpayOrderId'],
      companyName: json['companyName'],
      amountPaid: (json['amountPaid'] as num?)?.toDouble() ?? 0.0,
      discountAmount: (json['discountAmount'] as num?)?.toDouble() ?? 0.0,
      amountRemaining: (json['amountRemaining'] as num?)?.toDouble() ?? 0.0,
      orderItems: (json['orderItems'] as List? ?? [])
          .map(
            (item) => CateringOrderItem.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      cancelReason: json['cancelReason'],
      feedback: json['feedback'],
      rating: json['rating'],
      event: json['event'] ?? '',
      eventType: json['eventType'] ?? '',
      userLatitude: (json['userLatitude'] as num?)?.toDouble() ?? 0.0,
      userLongitude: (json['userLongitude'] as num?)?.toDouble() ?? 0.0,
      deliveryDistanceKm: (json['deliveryDistanceKm'] as num?)?.toDouble(),
      mobileNo: json['mobileNo'],
      deliveryUserName: json['deliveryUserName'],
      deliveryFee: (json['deliveryFee'] as num?)?.toDouble() ?? 0.0,
      distanceInKm: (json['distanceInKm'] as num?)?.toDouble() ?? 0.0,
      appType: json['appType'],
      vendorRegisteredName: json['vendorRegisteredName'],
      vendorFssai: json['vendorFssai'] ?? '',
      vendorFullAddress: json['vendorFullAddress'] ?? '',
      vendorCity: json['vendorCity'] ?? '',
      vendorState: json['vendorState'] ?? '',
      vendorLatitude: (json['vendorLatitude'] as num?)?.toDouble() ?? 0.0,
      vendorLongitude: (json['vendorLongitude'] as num?)?.toDouble() ?? 0.0,
      vendorGstIn: json['vendorGstIn'] ?? '',
      deliveryAddress: json['deliveryAddress'],
    );
  }
}

class CateringOrderItem {
  final int id;
  final int? packageId;
  final String packageName;
  final String? packageType;
  final double? packagePrice;
  final int quantity;
  final String? itemsName;
  final List<dynamic> packageItems;

  CateringOrderItem({
    required this.id,
    this.packageId,
    required this.packageName,
    this.packageType,
    this.packagePrice,
    required this.quantity,
    this.itemsName,
    required this.packageItems,
  });

  factory CateringOrderItem.fromJson(Map<String, dynamic> json) {
    return CateringOrderItem(
      id: json['id'] ?? 0,
      packageId: json['packageId'],
      packageName: json['packageName'] ?? '',
      packageType: json['packageType'],
      packagePrice: (json['packagePrice'] as num?)?.toDouble(),
      quantity: json['quantity'] ?? 1,
      itemsName: json['itemsName'],
      packageItems: json['packageItems'] as List? ?? [],
    );
  }
}
