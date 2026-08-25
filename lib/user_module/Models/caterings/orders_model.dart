enum OrderStatus { confirmed, preparing, ready, delivered, cancelled }


class CateringOrder {
  final int id;
  final int userId;
  final String location;
  final DateTime orderDateTime;
  final String paymentMethod;
  final String? razorpayPaymentId;
  final String paymentStatus;
  final OrderStatus orderStatus;
  final double sgst;
  final double cgst;
  final String cateringDate;
  final String cateringTime;
  final double subtotal;
  final double total;
  final double platformFeeAmount;
  final double deliveryFee;
  final List<CateringOrderItem> items;
  final num rating;
  final String mobileNo;
  final String deliveryUserName;
  final  String deliveryAddress;
  // ✅ Renamed class


  CateringOrder({
    required this.id,
    required this.userId,
    required this.location,
    required this.orderDateTime,
    required this.paymentMethod,
    this.razorpayPaymentId,
    required this.paymentStatus,
    required this.orderStatus,
    required this.sgst,
    required this.cgst,
    required this.cateringDate,
    required this.cateringTime,
    required this.subtotal,
    required this.platformFeeAmount,
    required this.total,
    required this.items,
    required this.rating,
    required this.mobileNo,
    required this.deliveryUserName,
    required this.deliveryAddress,
    required this.deliveryFee,
  });


  factory CateringOrder.fromJson(Map<String, dynamic> json) {
    return CateringOrder(
      id: json['orderId'] ?? 0,
      userId: json['userId'] ?? 0,
      location: json['location']?.toString() ?? '',
      orderDateTime: json['orderDateTime'] != null
          ? DateTime.tryParse(json['orderDateTime']) ?? DateTime.now()
          : DateTime.now(),
      paymentMethod: json['paymentMethod']?.toString() ?? '',
      razorpayPaymentId: json['razorpayPaymentId']?.toString(),
      paymentStatus: json['paymentStatus']?.toString() ?? '',
      orderStatus: _parseOrderStatus(json['orderStatus']),
      sgst: (json['sgst'] as num?)?.toDouble() ?? 0.0,
      cgst: (json['cgst'] as num?)?.toDouble() ?? 0.0,
      cateringDate: json['cateringDate']?.toString() ?? '',
      cateringTime: json['cateringTime']?.toString() ?? '',
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      platformFeeAmount:
      (json['platformFeeAmount'] as num?)?.toDouble() ?? 0.0,
      deliveryFee:
      (json['deliveryFee'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      items: (json['orderItems'] as List<dynamic>?)
          ?.map((item) => CateringOrderItem.fromJson(item))
          .toList() ??
          [],
      rating: json['rating'] ?? 0,
      mobileNo: json['mobileNo']?.toString() ?? '',
      deliveryUserName: json['deliveryUserName']?.toString() ?? '',
      deliveryAddress: json['deliveryAddress']?.toString() ?? '',
    );
  }


  static OrderStatus _parseOrderStatus(String? status) {
    switch (status?.toUpperCase()) {
      case 'CONFIRMED':
        return OrderStatus.confirmed;
      case 'PREPARING':
        return OrderStatus.preparing;
      case 'READY':
        return OrderStatus.ready;
      case 'DELIVERED':
        return OrderStatus.delivered;
      case 'CANCELLED':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.confirmed; // safe fallback
    }
  }
}


class CateringOrderItem {
  final String name;
  final int quantity;
  final double price;
  final List<PackageItem> packageItems;


  CateringOrderItem({
    required this.name,
    required this.quantity,
    required this.price,
    required this.packageItems,
  });
  factory CateringOrderItem.fromJson(Map<String, dynamic> json) {
    return CateringOrderItem(
      name: json['packageName'] ?? 'Unknown Item',
      quantity: json['quantity'] ?? 0,
      price: (json['packagePrice'] as num?)?.toDouble() ?? 0.0,
      packageItems:
      (json['packageItems'] as List<dynamic>?)
          ?.map((item) => PackageItem.fromJson(item))
          .toList() ??
          [],
    );
  }
}


class PackageItem {
  final int itemId;
  final String itemName;
  final double price;


  PackageItem({
    required this.itemId,
    required this.itemName,
    required this.price,
  });


  factory PackageItem.fromJson(Map<String, dynamic> json) {
    return PackageItem(
      itemId: json['itemId'] ?? 0,
      itemName: json['itemName'] ?? 'Unknown Item',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
