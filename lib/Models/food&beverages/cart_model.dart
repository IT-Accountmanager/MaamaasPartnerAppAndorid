//
// class CartModel {
//   final int cartId;
//   final int vendorId;
//   final String orderType;
//   final List<CartItem> cartItems;
//   final num subtotal;
//   final num gstTotal;
//   final num platformCharges;
//   final num grandTotal;
//   final num packingTotal;
//   final num serviceCharges;
//   final num deliveryCharges;
//   final num cgst;
//   final num sgst;
//   final int seatingId;
//   final String tableCode;
//   final String orderStatus;
//
//   CartModel({
//     required this.cartId,
//     required this.vendorId,
//     required this.orderType,
//     required this.cartItems,
//     required this.subtotal,
//     required this.gstTotal,
//     required this.platformCharges,
//     required this.grandTotal,
//     required this.packingTotal,
//     required this.serviceCharges,
//     required this.deliveryCharges,
//     required this.cgst,
//     required this.sgst,
//     required this.seatingId,
//     required this.tableCode,
//     required this.orderStatus,
//   });
//
//   factory CartModel.fromJson(Map<String, dynamic> json) {
//     return CartModel(
//       cartId: json['cartId'] ?? 0,
//       vendorId: json['vendorId'] ?? 0,
//       orderType: json['orderType'] ?? '',
//       cartItems: (json['cartItems'] as List<dynamic>?)
//           ?.map((item) => CartItem.fromJson(item))
//           .toList() ??
//           [],
//       subtotal: json['subtotal'] ?? 0,
//       gstTotal: json['gstTotal'] ?? 0,
//       platformCharges: json['platformCharges']?? 0,
//       grandTotal: json['grandTotal'] ?? 0,
//       packingTotal: json['packingTotal']?? 0,
//       serviceCharges: json['serviceCharges']?? 0,
//       deliveryCharges: json['deliveryCharges']?? 0,
//       cgst: json['cgst']?? 0,
//       sgst: json['sgst']?? 0,
//       seatingId: json['seatingId'] ?? 0,
//       tableCode: json['tableCode']?? '',
//       orderStatus: json['orderStatus']?? '',
//     );
//   }
// }
//
// class CartItem {
//   final int itemId;
//   final num price;
//   final String dishName;
//   final int dishId;
//   final num gst;
//   final num packingCharges;
//   int quantity;
//   final String chefType;
//   num totalPrice;
//   final String? dishImage;
//
//   CartItem({
//     required this.itemId,
//     required this.price,
//     required this.dishName,
//     required this.dishId,
//     required this.gst,
//     required this.packingCharges,
//     required this.quantity,
//     required this.chefType,
//     required this.totalPrice,
//     this.dishImage,
//   });
//
//   factory CartItem.fromJson(Map<String, dynamic> json) {
//     return CartItem(
//       itemId: json['itemId'] ?? 0,
//       price: json['price'] ?? 0,
//       dishName: json['dishName'] ?? '',
//       dishId: json['dishId'] ?? 0,
//       gst: json['gst'] ?? 0,
//       packingCharges: json['packingCharges'] ?? 0,
//       quantity: json['quantity'] ?? 0,
//       chefType: json['chefType'] ?? '',
//       totalPrice: json['totalPrice'] ?? 0,
//       dishImage: json['dishImage'],
//     );
//   }
// }
class CartModel {
  final int cartId;
  final int vendorId;
  final String orderType; // global cart order type (optional)
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

  CartModel({
    required this.cartId,
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
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      cartId: json['cartId'] ?? 0,
      vendorId: json['vendorId'] ?? 0,
      orderType: json['orderType'] ?? '',
      cartItems: (json['cartItems'] as List<dynamic>?)
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
      tableCode: json['tableCode'] ?? '',
      orderStatus: json['orderStatus'] ?? '',
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
  String orderType; // <-- Added field

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
    required this.orderType, // <-- include in constructor
    this.dishImage,
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
      orderType: json['orderType'] ?? 'DINE_IN', // <-- default
      dishImage: json['dishImage'],
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
      'chefType': chefType,
      'totalPrice': totalPrice,
      'orderType': orderType,
      'dishImage': dishImage,
    };
  }

}
