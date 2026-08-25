class CartModel {
  final int cartId;
  final int userId;
  final int vendorId;
  final String orderType;
  final List<CartItem> cartItems;
  final num subtotal;
  final num gstTotal;
  final num platformCharges;
  final num grandTotal;
  final num packingTotal;
  final num serviceCharges;
  final num deliveryCharges;
  final num cgst;
  final num sgst;
  final int seatingId;
  final String tableCode;
  final String orderStatus;
  String? couponCode;
  final int couponId;
  final num discountAmount;
  final String userCompany;
  final num savedAmount;
  final String deliveryAddress;
  final String mobileNo;
  final String name;
  final List<String>? vendorOrderType;

  CartModel({
    required this.cartId,
    required this.userId,
    required this.vendorId,
    required this.orderType,
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
    required this.seatingId,
    required this.tableCode,
    required this.orderStatus,
    this.couponCode,
    required this.couponId,
    required this.discountAmount,
    required this.userCompany,
    required this.savedAmount,
    required this.deliveryAddress,
    required this.mobileNo,
    required this.name,
    required this.vendorOrderType,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      cartId: json['cartId'] ?? 0,
      userId: json['userId'] ?? 0,
      vendorId: json['vendorId'] ?? 0,
      orderType: json['orderType'] ?? '',
      cartItems:
          (json['cartItems'] as List<dynamic>?)
              ?.map((item) => CartItem.fromJson(item))
              .toList() ??
          [],
      subtotal: json['subtotal'] ?? 0,
      gstTotal: json['gstTotal'] ?? 0,
      platformCharges: json['platformCharges'] ?? 0,
      grandTotal: json['grandTotal'] ?? 0,
      packingTotal: json['packingTotal'] ?? 0,
      serviceCharges: json['serviceCharges'] ?? 0,
      deliveryCharges: json['deliveryCharges'] ?? 0,
      cgst: json['cgst'] ?? 0,
      sgst: json['sgst'] ?? 0,
      seatingId: json['seatingId'] ?? 0,
      couponId: json['couponId'] ?? 0,
      tableCode: json['tableCode'] ?? '',
      orderStatus: json['orderStatus'] ?? '',
      couponCode: json['couponCode'] ?? '',
      discountAmount: json['discountAmount'] ?? 0,
      userCompany: json['userCompany'] ?? '',
      savedAmount: json['savedAmount'] ?? 0,
      deliveryAddress: json['deliveryAddress'] ?? " ",
      mobileNo: json["mobileNo"] ?? "",
      name: json["name"] ?? "",
      vendorOrderType: (json['vendorOrderType'] as List?)
          ?.map((e) => e.toString())
          .toList(),
    );
  }
}

class CartItem {
  final int itemId;
  final num price;
  final String dishName;
  final int dishId;
  final num gst;
  final num packingCharges;
  int quantity;
  final String chefType;
  num totalPrice;
  final String? dishImage;
  final num actualPrice;
  final int balanceQuantity;
  final bool available;
  final bool shedule;

  CartItem({
    required this.itemId,
    required this.price,
    required this.dishName,
    required this.dishId,
    required this.gst,
    required this.packingCharges,
    required this.quantity,
    required this.chefType,
    required this.totalPrice,
    this.dishImage,
    required this.actualPrice,
    required this.balanceQuantity,
    required this.available,
    required this.shedule,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      itemId: json['itemId'] ?? 0,
      price: json['price'] ?? 0,
      dishName: json['dishName'] ?? '',
      dishId: json['dishId'] ?? 0,
      gst: json['gst'] ?? 0,
      packingCharges: json['packingCharges'] ?? 0,
      quantity: json['quantity'] ?? 0,
      chefType: json['chefType'] ?? '',
      totalPrice: json['totalPrice'] ?? 0,
      dishImage: json['dishImage'],
      actualPrice: json['actualPrice'] ?? 0,
      balanceQuantity: json['balanceQuantity'] ?? 0,
      available: json['available'] == true,
      shedule: json['shedule'] ?? false,
    );
  }
}
