// // models/order_model.dart
// class Order {
//   final int orderId;
//   final int? userId;
//   final int vendorId;
//   final String? location;
//   final String? service;
//   final String? pincode;
//   final String date;
//   final String time;
//   final DateTime? scheduledAt;
//   final DateTime orderDateAndTime;
//   final double grandTotal;
//   final String status;
//   final String? appType;
//   final String? cashStatus;
//   final String? phoneNumber;
//   final String paymentMethod;
//   final int? couponId;
//   final String? paymentStatus;
//   final int? seatingId;
//   final String? tableCode;
//   final double discountAmount;
//   final double sgst;
//   final double cgst;
//   final double subTotal;
//   final double totalAmount;
//   final double serviceCharge;
//   final String? remainingPaymentMethod;
//   final double? walletUsed;
//   final String? walletTypes;
//   final double packingCharges;
//   final double deliveryCharges;
//   final double platformCharges;
//   final double? vendorPlatformCharge;
//   final double? vendorPlatformChargeGst;
//   final int? people;
//   final String? userName;
//   final String? userCompany;
//   final double? userLatitude;
//   final double? userLongitude;
//   final double? deliveryDistanceKm;
//   final String? mobileNo;
//   final String? deliveryUserName;
//   final String orderType;
//   final String? feedback;
//   final double? ratings;
//   final DateTime? ratedAt;
//   final bool sheduled;
//   final String? transactionId;
//   final int? cartId;
//   final List<OrderItem> orderItems;
//   final String vendorRegisteredName;
//   final String vendorFssai;
//   final String? vendorFullAddress;
//   final String vendorCity;
//   final String vendorState;
//   final double? vendorLatitude;
//   final double? vendorLongitude;
//   final String vendorGstIn;
//   final String? deliveryAddress;
//
//   Order({
//     required this.orderId,
//     required this.userId,
//     required this.vendorId,
//     required this.location,
//     required this.service,
//     required this.pincode,
//     required this.date,
//     required this.time,
//     required this.scheduledAt,
//     required this.orderDateAndTime,
//     required this.grandTotal,
//     required this.status,
//     required this.appType,
//     required this.cashStatus,
//     required this.phoneNumber,
//     required this.paymentMethod,
//     required this.couponId,
//     required this.paymentStatus,
//     required this.seatingId,
//     required this.tableCode,
//     required this.discountAmount,
//     required this.sgst,
//     required this.cgst,
//     required this.subTotal,
//     required this.totalAmount,
//     required this.serviceCharge,
//     required this.remainingPaymentMethod,
//     required this.walletUsed,
//     required this.walletTypes,
//     required this.packingCharges,
//     required this.deliveryCharges,
//     required this.platformCharges,
//     required this.vendorPlatformCharge,
//     required this.vendorPlatformChargeGst,
//     required this.people,
//     required this.userName,
//     required this.userCompany,
//     required this.userLatitude,
//     required this.userLongitude,
//     required this.deliveryDistanceKm,
//     required this.mobileNo,
//     required this.deliveryUserName,
//     required this.orderType,
//     required this.feedback,
//     required this.ratings,
//     required this.ratedAt,
//     required this.sheduled,
//     required this.transactionId,
//     required this.cartId,
//     required this.orderItems,
//     required this.vendorRegisteredName,
//     required this.vendorFssai,
//     required this.vendorFullAddress,
//     required this.vendorCity,
//     required this.vendorState,
//     required this.vendorLatitude,
//     required this.vendorLongitude,
//     required this.vendorGstIn,
//     required this.deliveryAddress,
//   });
//
//   factory Order.fromJson(Map<String, dynamic> json) {
//     return Order(
//       orderId: json['orderId'],
//       userId: json['userId'],
//       vendorId: json['vendorId'],
//       location: json['location'],
//       service: json['service'],
//       pincode: json['pincode'],
//       date: json['date'],
//       time: json['time'],
//       scheduledAt: json['scheduledAt'] != null ? DateTime.parse(json['scheduledAt']) : null,
//       orderDateAndTime: DateTime.parse(json['orderDateAndTime']),
//       grandTotal: (json['grandTotal'] as num).toDouble(),
//       status: json['status'],
//       appType: json['appType'],
//       cashStatus: json['cashStatus'],
//       phoneNumber: json['phoneNumber'],
//       paymentMethod: json['paymentMethod'],
//       couponId: json['couponId'],
//       paymentStatus: json['paymentStatus'],
//       seatingId: json['seatingId'],
//       tableCode: json['tableCode'],
//       discountAmount: (json['discountAmount'] as num).toDouble(),
//       sgst: (json['sgst'] as num).toDouble(),
//       cgst: (json['cgst'] as num).toDouble(),
//       subTotal: (json['subTotal'] as num).toDouble(),
//       totalAmount: (json['totalAmount'] as num).toDouble(),
//       serviceCharge: (json['serviceCharge'] as num).toDouble(),
//       remainingPaymentMethod: json['remainingPaymentMethod'],
//       walletUsed: (json['walletUsed'] as num?)?.toDouble(),
//       walletTypes: json['walletTypes'],
//       packingCharges: (json['packingCharges'] as num).toDouble(),
//       deliveryCharges: (json['deliveryCharges'] as num).toDouble(),
//       platformCharges: (json['platformCharges'] as num).toDouble(),
//       vendorPlatformCharge: (json['vendorPlatformCharge'] as num?)?.toDouble(),
//       vendorPlatformChargeGst: (json['vendorPlatformChargeGst'] as num?)?.toDouble(),
//       people: json['people'],
//       userName: json['userName'],
//       userCompany: json['userCompany'],
//       userLatitude: (json['userLatitude'] as num?)?.toDouble(),
//       userLongitude: (json['userLongitude'] as num?)?.toDouble(),
//       deliveryDistanceKm: (json['deliveryDistanceKm'] as num?)?.toDouble(),
//       mobileNo: json['mobileNo'],
//       deliveryUserName: json['deliveryUserName'],
//       orderType: json['orderType'],
//       feedback: json['feedback'],
//       ratings: (json['ratings'] as num?)?.toDouble(),
//       ratedAt: json['ratedAt'] != null ? DateTime.parse(json['ratedAt']) : null,
//       sheduled: json['sheduled'],
//       transactionId: json['transactionId'],
//       cartId: json['cartId'],
//       orderItems: List<OrderItem>.from((json['order'] as List).map((x) => OrderItem.fromJson(x))),
//       vendorRegisteredName: json['vendorRegisteredName'],
//       vendorFssai: json['vendorFssai'],
//       vendorFullAddress: json['vendorFullAddress'],
//       vendorCity: json['vendorCity'],
//       vendorState: json['vendorState'],
//       vendorLatitude: (json['vendorLatitude'] as num?)?.toDouble(),
//       vendorLongitude: (json['vendorLongitude'] as num?)?.toDouble(),
//       vendorGstIn: json['vendorGstIn'],
//       deliveryAddress: json['deliveryAddress'],
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'orderId': orderId,
//       'userId': userId,
//       'vendorId': vendorId,
//       'location': location,
//       'service': service,
//       'pincode': pincode,
//       'date': date,
//       'time': time,
//       'scheduledAt': scheduledAt?.toIso8601String(),
//       'orderDateAndTime': orderDateAndTime.toIso8601String(),
//       'grandTotal': grandTotal,
//       'status': status,
//       'appType': appType,
//       'cashStatus': cashStatus,
//       'phoneNumber': phoneNumber,
//       'paymentMethod': paymentMethod,
//       'couponId': couponId,
//       'paymentStatus': paymentStatus,
//       'seatingId': seatingId,
//       'tableCode': tableCode,
//       'discountAmount': discountAmount,
//       'sgst': sgst,
//       'cgst': cgst,
//       'subTotal': subTotal,
//       'totalAmount': totalAmount,
//       'serviceCharge': serviceCharge,
//       'remainingPaymentMethod': remainingPaymentMethod,
//       'walletUsed': walletUsed,
//       'walletTypes': walletTypes,
//       'packingCharges': packingCharges,
//       'deliveryCharges': deliveryCharges,
//       'platformCharges': platformCharges,
//       'vendorPlatformCharge': vendorPlatformCharge,
//       'vendorPlatformChargeGst': vendorPlatformChargeGst,
//       'people': people,
//       'userName': userName,
//       'userCompany': userCompany,
//       'userLatitude': userLatitude,
//       'userLongitude': userLongitude,
//       'deliveryDistanceKm': deliveryDistanceKm,
//       'mobileNo': mobileNo,
//       'deliveryUserName': deliveryUserName,
//       'orderType': orderType,
//       'feedback': feedback,
//       'ratings': ratings,
//       'ratedAt': ratedAt?.toIso8601String(),
//       'sheduled': sheduled,
//       'transactionId': transactionId,
//       'cartId': cartId,
//       'order': orderItems.map((item) => item.toJson()).toList(),
//       'vendorRegisteredName': vendorRegisteredName,
//       'vendorFssai': vendorFssai,
//       'vendorFullAddress': vendorFullAddress,
//       'vendorCity': vendorCity,
//       'vendorState': vendorState,
//       'vendorLatitude': vendorLatitude,
//       'vendorLongitude': vendorLongitude,
//       'vendorGstIn': vendorGstIn,
//       'deliveryAddress': deliveryAddress,
//     };
//   }
// }
//
// class OrderItem {
//   final int listId;
//   final double price;
//   final int quantity;
//   final double totalPrice;
//   final String dishName;
//   final int? dishId;
//   final double actualPrice;
//   final double actualDiscount;
//   final String category;
//   final String chefType;
//   final double? sgst;
//   final double? cgst;
//   final String status;
//
//   OrderItem({
//     required this.listId,
//     required this.price,
//     required this.quantity,
//     required this.totalPrice,
//     required this.dishName,
//     required this.dishId,
//     required this.actualPrice,
//     required this.actualDiscount,
//     required this.category,
//     required this.chefType,
//     required this.sgst,
//     required this.cgst,
//     required this.status,
//   });
//
//   factory OrderItem.fromJson(Map<String, dynamic> json) {
//     return OrderItem(
//       listId: json['listId'],
//       price: (json['price'] as num).toDouble(),
//       quantity: json['quantity'],
//       totalPrice: (json['totalPrice'] as num).toDouble(),
//       dishName: json['dishName'],
//       dishId: json['dishId'],
//       actualPrice: (json['actualPrice'] as num).toDouble(),
//       actualDiscount: (json['actualDiscount'] as num).toDouble(),
//       category: json['category'],
//       chefType: json['chefType'],
//       sgst: (json['sgst'] as num?)?.toDouble(),
//       cgst: (json['cgst'] as num?)?.toDouble(),
//       status: json['status'],
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'listId': listId,
//       'price': price,
//       'quantity': quantity,
//       'totalPrice': totalPrice,
//       'dishName': dishName,
//       'dishId': dishId,
//       'actualPrice': actualPrice,
//       'actualDiscount': actualDiscount,
//       'category': category,
//       'chefType': chefType,
//       'sgst': sgst,
//       'cgst': cgst,
//       'status': status,
//     };
//   }
// }