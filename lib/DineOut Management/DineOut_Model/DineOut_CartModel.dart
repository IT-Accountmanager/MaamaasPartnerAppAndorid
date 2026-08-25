

class DineoutCartmodel {
  final int cartId;
  final int? userId;
  final int vendorId;
  final String orderType;
  final int seatingId;
  final String tableCode;
  final int? couponId;
  final int? customerId;
  final List<CartItem> cartItems;
  final double subtotal;
  final double gstTotal;
  final double platformCharges;
  final double grandTotal;
  final double packingTotal;
  final double serviceCharges;
  final double deliveryCharges;
  final double cgst;
  final double sgst;
  final String? couponCode;
  final double? discountAmount;
  final double total;
  final double serviceChargeGst;
  final double packingChargeGst;
  final double platformChargeGst;
  final double vendorPlatformCharge;
  final double vendorPlatformChargeGst;
  final double savedAmount;
  final double? userLatitude;
  final double? userLongitude;
  final double? deliveryDistanceKm;
  final String? mobileNo;
  final String? deliveryUserName;
  final int? campaignId;
  final String? name;
  final String? userCompany;
  final String? deliveryAddress;
  final List<int> itemId;

  DineoutCartmodel({
    required this.cartId,
    this.userId,
    required this.vendorId,
    required this.orderType,
    required this.seatingId,
    required this.tableCode,
    this.couponId,
    this.customerId,
    required this.cartItems,
    required this.subtotal,
    required this.gstTotal,
    required this.platformCharges,
    required this.grandTotal,
    required this.packingTotal,
    required this.serviceCharges,
    required this.deliveryCharges,
    required this.cgst,
    required this.sgst,
    this.couponCode,
    this.discountAmount,
    required this.total,
    required this.serviceChargeGst,
    required this.packingChargeGst,
    required this.platformChargeGst,
    required this.vendorPlatformCharge,
    required this.vendorPlatformChargeGst,
    required this.savedAmount,
    this.userLatitude,
    this.userLongitude,
    this.deliveryDistanceKm,
    this.mobileNo,
    this.deliveryUserName,
    this.campaignId,
    this.name,
    this.userCompany,
    this.deliveryAddress,
    required this.itemId,
  });

  // Safe parsers
  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static List<int> _parseIntList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((e) => _parseInt(e)).toList();
    }
    return [];
  }

  factory DineoutCartmodel.fromJson(Map<String, dynamic> json) {
    return DineoutCartmodel(
      cartId: _parseInt(json['cartId']),
      userId: json['userId'] != null ? _parseInt(json['userId']) : null,
      vendorId: _parseInt(json['vendorId']),
      orderType: json['orderType'] ?? '',
      seatingId: _parseInt(json['seatingId']),
      tableCode: json['tableCode'] ?? '',
      couponId: json['couponId'] != null ? _parseInt(json['couponId']) : null,
      customerId: json['customerId'] != null
          ? _parseInt(json['customerId'])
          : null,
      cartItems:
          (json['cartItems'] as List<dynamic>?)
              ?.map((item) => CartItem.fromJson(item))
              .toList() ??
          [],
      subtotal: _parseDouble(json['subtotal']),
      gstTotal: _parseDouble(json['gstTotal']),
      platformCharges: _parseDouble(json['platformCharges']),
      grandTotal: _parseDouble(json['grandTotal']),
      packingTotal: _parseDouble(json['packingTotal']),
      serviceCharges: _parseDouble(json['serviceCharges']),
      deliveryCharges: _parseDouble(json['deliveryCharges']),
      cgst: _parseDouble(json['cgst']),
      sgst: _parseDouble(json['sgst']),
      couponCode: json['couponCode'],
      discountAmount: json['discountAmount'] != null
          ? _parseDouble(json['discountAmount'])
          : null,
      total: _parseDouble(json['total']),
      serviceChargeGst: _parseDouble(json['serviceChargeGst']),
      packingChargeGst: _parseDouble(json['packingChargeGst']),
      platformChargeGst: _parseDouble(json['platformChargeGst']),
      vendorPlatformCharge: _parseDouble(json['vendorPlatformCharge']),
      vendorPlatformChargeGst: _parseDouble(json['vendorPlatformChargeGst']),
      savedAmount: _parseDouble(json['savedAmount']),
      userLatitude: json['userLatitude'] != null
          ? _parseDouble(json['userLatitude'])
          : null,
      userLongitude: json['userLongitude'] != null
          ? _parseDouble(json['userLongitude'])
          : null,
      deliveryDistanceKm: json['deliveryDistanceKm'] != null
          ? _parseDouble(json['deliveryDistanceKm'])
          : null,
      mobileNo: json['mobileNo'],
      deliveryUserName: json['deliveryUserName'],
      campaignId: json['campaignId'] != null
          ? _parseInt(json['campaignId'])
          : null,
      name: json['name'],
      userCompany: json['userCompany'],
      deliveryAddress: json['deliveryAddress'],
      itemId: _parseIntList(json['itemId']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cartId': cartId,
      'userId': userId,
      'vendorId': vendorId,
      'orderType': orderType,
      'seatingId': seatingId,
      'tableCode': tableCode,
      'couponId': couponId,
      'customerId': customerId,
      'cartItems': cartItems.map((e) => e.toJson()).toList(),
      'subtotal': subtotal,
      'gstTotal': gstTotal,
      'platformCharges': platformCharges,
      'grandTotal': grandTotal,
      'packingTotal': packingTotal,
      'serviceCharges': serviceCharges,
      'deliveryCharges': deliveryCharges,
      'cgst': cgst,
      'sgst': sgst,
      'couponCode': couponCode,
      'discountAmount': discountAmount,
      'total': total,
      'serviceChargeGst': serviceChargeGst,
      'packingChargeGst': packingChargeGst,
      'platformChargeGst': platformChargeGst,
      'vendorPlatformCharge': vendorPlatformCharge,
      'vendorPlatformChargeGst': vendorPlatformChargeGst,
      'savedAmount': savedAmount,
      'userLatitude': userLatitude,
      'userLongitude': userLongitude,
      'deliveryDistanceKm': deliveryDistanceKm,
      'mobileNo': mobileNo,
      'deliveryUserName': deliveryUserName,
      'campaignId': campaignId,
      'name': name,
      'userCompany': userCompany,
      'deliveryAddress': deliveryAddress,
      'itemId': itemId,
    };
  }
}

class CartItem {
  int itemId;
  double price;
  String dishName;
  int dishId;
  double gst;
  double packingCharges;
  int quantity;
  int updateQuantity;
  int previousQuantity;
  String chefType;
  double totalPrice;
  String? note;
  String? orderStatus;
  double actualPrice;
  double actualDiscount;
  String category;
  bool shedule;
  String createdAt;
  String updatedAt;
  String? dishImage;
  String orderType;

  CartItem({
    required this.itemId,
    required this.price,
    required this.dishName,
    required this.dishId,
    required this.gst,
    required this.packingCharges,
    required this.quantity,
    required this.updateQuantity,
    required this.previousQuantity,
    required this.chefType,
    required this.totalPrice,
    this.note,
    this.orderStatus,
    required this.actualPrice,
    required this.actualDiscount,
    required this.category,
    required this.shedule,
    required this.createdAt,
    required this.updatedAt,
    this.dishImage,
    required this.orderType,
  });

  // Safe parsers for CartItem
  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    return value == 1;
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      itemId: _parseInt(json['itemId']),
      price: _parseDouble(json['price']),
      dishName: json['dishName'] ?? '',
      dishId: _parseInt(json['dishId']),
      gst: _parseDouble(json['gst']),
      packingCharges: _parseDouble(json['packingCharges']),
      quantity: _parseInt(json['quantity']),
      updateQuantity: _parseInt(json['updateQuantity']),
      previousQuantity: _parseInt(json['previousQuantity']),
      chefType: json['chefType'] ?? '',
      totalPrice: _parseDouble(json['totalPrice']),
      note: json['note'],
      orderStatus: json['orderStatus'],
      actualPrice: _parseDouble(json['actualPrice']),
      actualDiscount: _parseDouble(json['actualDiscount']),
      category: json['category'] ?? '',
      shedule: _parseBool(json['shedule']),
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      dishImage: json['dishImage'],
      orderType: json['orderType'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'itemId': itemId,
      'price': price,
      'dishName': dishName,
      'dishId': dishId,
      'gst': gst,
      'packingCharges': packingCharges,
      'quantity': quantity,
      'updateQuantity': updateQuantity,
      'previousQuantity': previousQuantity,
      'chefType': chefType,
      'totalPrice': totalPrice,
      'note': note,
      'orderStatus': orderStatus,
      'actualPrice': actualPrice,
      'actualDiscount': actualDiscount,
      'category': category,
      'shedule': shedule,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'dishImage': dishImage,
      'orderType': orderType,
    };
  }
}
