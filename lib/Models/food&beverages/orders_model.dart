
/// =========================
/// ENUM DEFINITIONS
/// =========================

enum OrderStatus {
  HOLD,
  PENDING,
  CONFIRMED,
  ORDER_IS_READY,
  WAITING_FOR_PICKUP,
  PROCESSING,
  BEING_PREPARED,
  COMPLETED,
  DELIVERED,
  CANCELLED,
}

enum AppType {
  FOOD_AND_BEVERAGES,
  CATERINGS,
  CO_WORKING_SPACE,
  LOGISTICS,
}

enum CashStatus {
  PENDING,
  ACCEPT,
  DECLINE,
}

enum PaymentMethod {
  Maamaas_Wallet,
  Cash,
  Online_Payment,
}

enum WalletType {
  SELF_LOADED,
  COMPANY_LOADED,
  CASHBACK,
  EARNED_AMOUNT,
  POST_PAID,
}

enum OrderType {
  DINE_IN,
  DELIVERY,
  TAKEAWAY,
  TABLE_DINE_IN,
}

enum ChefType {
  Chef_North,
  Chef_South,
  Chef_Continental,
  Chef_Chinese,
}

enum RefundStatus {
  Okay,
  Cancelled,
}

enum TicketType {
  DELIVERY_ISSUE,
  PAYMENT_PROBLEM,
  WRONG_ORDER,
  SERVICE_QUALITY,
  OTHER,
}

enum TicketStatus {
  OPEN,
  IN_PROGRESS,
  RESOLVED,
  REJECTED,
}

enum AdminResponse {
  PENDING_REVIEW,
  UNDER_INVESTIGATION,
  RESOLVED_REFUNDED,
  RESOLVED_REPLACED,
  RESOLVED_COMPENSATED,
  REJECTED_INVALID,
  REJECTED_POLICY,
  ESCALATED,
}

/// =========================
/// SUB ENTITIES
/// =========================

class LocalTime {
  final int? hour;
  final int? minute;
  final int? second;
  final int? nano;

  LocalTime({this.hour, this.minute, this.second, this.nano});

  factory LocalTime.fromJson(Map<String, dynamic> json) => LocalTime(
    hour: json['hour'],
    minute: json['minute'],
    second: json['second'],
    nano: json['nano'],
  );

  Map<String, dynamic> toJson() => {
    'hour': hour,
    'minute': minute,
    'second': second,
    'nano': nano,
  };
}

class OrderListEntity {
  final int? listId;
  final double? price;
  final int? quantity;
  final double? totalPrice;
  final String? dishName;
  final int? dishId;
  final ChefType? chefType;
  final double? sgst;
  final double? cgst;
  final RefundStatus? status;

  OrderListEntity({
    this.listId,
    this.price,
    this.quantity,
    this.totalPrice,
    this.dishName,
    this.dishId,
    this.chefType,
    this.sgst,
    this.cgst,
    this.status,
  });

  factory OrderListEntity.fromJson(Map<String, dynamic> json) => OrderListEntity(
    listId: json['listId'],
    price: (json['price'] as num?)?.toDouble(),
    quantity: json['quantity'],
    totalPrice: (json['totalPrice'] as num?)?.toDouble(),
    dishName: json['dishName'],
    dishId: json['dishId'],
    chefType: _enumDecodeNullable(ChefType.values, json['chefType']),
    sgst: (json['sgst'] as num?)?.toDouble(),
    cgst: (json['cgst'] as num?)?.toDouble(),
    status: _enumDecodeNullable(RefundStatus.values, json['status']),
  );

  Map<String, dynamic> toJson() => {
    'listId': listId,
    'price': price,
    'quantity': quantity,
    'totalPrice': totalPrice,
    'dishName': dishName,
    'dishId': dishId,
    'chefType': chefType?.name,
    'sgst': sgst,
    'cgst': cgst,
    'status': status?.name,
  };
}

class OrderRefundHistoryEntity {
  final int? refundId;
  final int? listId;
  final int? orderId;
  final int? userId;
  final int? vendorId;
  final String? userName;
  final double? price;
  final double? cgst;
  final double? sgst;
  final RefundStatus? status;
  final String? cancelledAt;
  final String? transactionId;
  final String? paymentMethod;

  OrderRefundHistoryEntity({
    this.refundId,
    this.listId,
    this.orderId,
    this.userId,
    this.vendorId,
    this.userName,
    this.price,
    this.cgst,
    this.sgst,
    this.status,
    this.cancelledAt,
    this.transactionId,
    this.paymentMethod,
  });

  factory OrderRefundHistoryEntity.fromJson(Map<String, dynamic> json) =>
      OrderRefundHistoryEntity(
        refundId: json['refundId'],
        listId: json['listId'],
        orderId: json['orderId'],
        userId: json['userId'],
        vendorId: json['vendorId'],
        userName: json['userName'],
        price: (json['price'] as num?)?.toDouble(),
        cgst: (json['cgst'] as num?)?.toDouble(),
        sgst: (json['sgst'] as num?)?.toDouble(),
        status: _enumDecodeNullable(RefundStatus.values, json['status']),
        cancelledAt: json['cancelledAt'],
        transactionId: json['transactionId'],
        paymentMethod: json['paymentMethod'],
      );

  Map<String, dynamic> toJson() => {
    'refundId': refundId,
    'listId': listId,
    'orderId': orderId,
    'userId': userId,
    'vendorId': vendorId,
    'userName': userName,
    'price': price,
    'cgst': cgst,
    'sgst': sgst,
    'status': status?.name,
    'cancelledAt': cancelledAt,
    'transactionId': transactionId,
    'paymentMethod': paymentMethod,
  };
}

class OrderTicket {
  final int? id;
  final int? userId;
  final TicketType? ticketType;
  final TicketStatus? status;
  final String? message;
  final String? attachmentUrl;
  final String? createdAt;
  final String? resolvedAt;
  final AdminResponse? adminResponse;
  final int? orderId;

  OrderTicket({
    this.id,
    this.userId,
    this.ticketType,
    this.status,
    this.message,
    this.attachmentUrl,
    this.createdAt,
    this.resolvedAt,
    this.adminResponse,
    this.orderId,
  });

  factory OrderTicket.fromJson(Map<String, dynamic> json) => OrderTicket(
    id: json['id'],
    userId: json['userId'],
    ticketType: _enumDecodeNullable(TicketType.values, json['ticketType']),
    status: _enumDecodeNullable(TicketStatus.values, json['status']),
    message: json['message'],
    attachmentUrl: json['attachmentUrl'],
    createdAt: json['createdAt'],
    resolvedAt: json['resolvedAt'],
    adminResponse:
    _enumDecodeNullable(AdminResponse.values, json['adminResponse']),
    orderId: json['orderId'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'ticketType': ticketType?.name,
    'status': status?.name,
    'message': message,
    'attachmentUrl': attachmentUrl,
    'createdAt': createdAt,
    'resolvedAt': resolvedAt,
    'adminResponse': adminResponse?.name,
    'orderId': orderId,
  };
}

/// =========================
/// MAIN ORDERS MODEL
/// =========================

class Orders {
  final int? orderId;
  final int? userId;
  final int? vendorId;
  final String? location;
  final String? service;
  final String? pincode;
  final String? date;
  final LocalTime? time;
  final String? orderDateAndTime;
  final double? grandTotal;
  final OrderStatus? status;
  final AppType? appType;
  final CashStatus? cashStatus;
  final String? phoneNumber;
  final PaymentMethod? paymentMethod;
  final int? couponId;
  final String? paymentStatus;
  final int? seatingId;
  final String? tableCode;
  final double? discountAmount;
  final double? sgst;
  final double? cgst;
  final double? subTotal;
  final double? totalAmount;
  final double? serviceCharge;
  final String? remainingPaymentMethod;
  final double? walletUsed;
  final WalletType? walletTypes;
  final double? packingCharges;
  final double? deliveryCharges;
  final double? platformCharges;
  final int? people;
  final String? userName;
  final String? userCompany;
  final OrderType? orderType;
  final String? feedback;
  final int? ratings;
  final String? ratedAt;
  final bool? scheduled;
  final String? transactionId;
  final List<OrderListEntity>? order;
  final List<OrderRefundHistoryEntity>? refund;
  final List<OrderTicket>? ticket;
  final String? vendorRestaurantName;
  final String? vendorFssai;
  final String? vendorFullAddress;
  final String? vendorCity;
  final String? vendorState;
  final double? vendorLatitude;
  final double? vendorLongitude;

  Orders({
    this.orderId,
    this.userId,
    this.vendorId,
    this.location,
    this.service,
    this.pincode,
    this.date,
    this.time,
    this.orderDateAndTime,
    this.grandTotal,
    this.status,
    this.appType,
    this.cashStatus,
    this.phoneNumber,
    this.paymentMethod,
    this.couponId,
    this.paymentStatus,
    this.seatingId,
    this.tableCode,
    this.discountAmount,
    this.sgst,
    this.cgst,
    this.subTotal,
    this.totalAmount,
    this.serviceCharge,
    this.remainingPaymentMethod,
    this.walletUsed,
    this.walletTypes,
    this.packingCharges,
    this.deliveryCharges,
    this.platformCharges,
    this.people,
    this.userName,
    this.userCompany,
    this.orderType,
    this.feedback,
    this.ratings,
    this.ratedAt,
    this.scheduled,
    this.transactionId,
    this.order,
    this.refund,
    this.ticket,
    this.vendorRestaurantName,
    this.vendorFssai,
    this.vendorFullAddress,
    this.vendorCity,
    this.vendorState,
    this.vendorLatitude,
    this.vendorLongitude,
  });

  factory Orders.fromJson(Map<String, dynamic> json) => Orders(
    orderId: json['orderId'],
    userId: json['userId'],
    vendorId: json['vendorId'],
    location: json['location'],
    service: json['service'],
    pincode: json['pincode'],
    date: json['date'],
    time: json['time'] != null ? LocalTime.fromJson(json['time']) : null,
    orderDateAndTime: json['orderDateAndTime'],
    grandTotal: (json['grandTotal'] as num?)?.toDouble(),
    status: _enumDecodeNullable(OrderStatus.values, json['status']),
    appType: _enumDecodeNullable(AppType.values, json['appType']),
    cashStatus: _enumDecodeNullable(CashStatus.values, json['cashStatus']),
    phoneNumber: json['phoneNumber'],
    paymentMethod:
    _enumDecodeNullable(PaymentMethod.values, json['paymentMethod']),
    couponId: json['couponId'],
    paymentStatus: json['paymentStatus'],
    seatingId: json['seatingId'],
    tableCode: json['tableCode'],
    discountAmount: (json['discountAmount'] as num?)?.toDouble(),
    sgst: (json['sgst'] as num?)?.toDouble(),
    cgst: (json['cgst'] as num?)?.toDouble(),
    subTotal: (json['subTotal'] as num?)?.toDouble(),
    totalAmount: (json['totalAmount'] as num?)?.toDouble(),
    serviceCharge: (json['serviceCharge'] as num?)?.toDouble(),
    remainingPaymentMethod: json['remainingPaymentMethod'],
    walletUsed: (json['walletUsed'] as num?)?.toDouble(),
    walletTypes: _enumDecodeNullable(WalletType.values, json['walletTypes']),
    packingCharges: (json['packingCharges'] as num?)?.toDouble(),
    deliveryCharges: (json['deliveryCharges'] as num?)?.toDouble(),
    platformCharges: (json['platformCharges'] as num?)?.toDouble(),
    people: json['people'],
    userName: json['userName'],
    userCompany: json['userCompany'],
    orderType: _enumDecodeNullable(OrderType.values, json['orderType']),
    feedback: json['feedback'],
    ratings: json['ratings'],
    ratedAt: json['ratedAt'],
    scheduled: json['sheduled'],
    transactionId: json['transactionId'],
    order: (json['order'] as List?)
        ?.map((e) => OrderListEntity.fromJson(e))
        .toList(),
    refund: (json['refund'] as List?)
        ?.map((e) => OrderRefundHistoryEntity.fromJson(e))
        .toList(),
    ticket: (json['ticket'] as List?)
        ?.map((e) => OrderTicket.fromJson(e))
        .toList(),
    vendorRestaurantName: json['vendorRestaurantName'],
    vendorFssai: json['vendorFssai'],
    vendorFullAddress: json['vendorFullAddress'],
    vendorCity: json['vendorCity'],
    vendorState: json['vendorState'],
    vendorLatitude: (json['vendorLatitude'] as num?)?.toDouble(),
    vendorLongitude: (json['vendorLongitude'] as num?)?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'orderId': orderId,
    'userId': userId,
    'vendorId': vendorId,
    'location': location,
    'service': service,
    'pincode': pincode,
    'date': date,
    'time': time?.toJson(),
    'orderDateAndTime': orderDateAndTime,
    'grandTotal': grandTotal,
    'status': status?.name,
    'appType': appType?.name,
    'cashStatus': cashStatus?.name,
    'phoneNumber': phoneNumber,
    'paymentMethod': paymentMethod?.name,
    'couponId': couponId,
    'paymentStatus': paymentStatus,
    'seatingId': seatingId,
    'tableCode': tableCode,
    'discountAmount': discountAmount,
    'sgst': sgst,
    'cgst': cgst,
    'subTotal': subTotal,
    'totalAmount': totalAmount,
    'serviceCharge': serviceCharge,
    'remainingPaymentMethod': remainingPaymentMethod,
    'walletUsed': walletUsed,
    'walletTypes': walletTypes?.name,
    'packingCharges': packingCharges,
    'deliveryCharges': deliveryCharges,
    'platformCharges': platformCharges,
    'people': people,
    'userName': userName,
    'userCompany': userCompany,
    'orderType': orderType?.name,
    'feedback': feedback,
    'ratings': ratings,
    'ratedAt': ratedAt,
    'sheduled': scheduled,
    'transactionId': transactionId,
    'order': order?.map((e) => e.toJson()).toList(),
    'refund': refund?.map((e) => e.toJson()).toList(),
    'ticket': ticket?.map((e) => e.toJson()).toList(),
    'vendorRestaurantName': vendorRestaurantName,
    'vendorFssai': vendorFssai,
    'vendorFullAddress': vendorFullAddress,
    'vendorCity': vendorCity,
    'vendorState': vendorState,
    'vendorLatitude': vendorLatitude,
    'vendorLongitude': vendorLongitude,
  };
}

/// =========================
/// ENUM DECODER HELPER
/// =========================

T? _enumDecodeNullable<T>(List<T> values, dynamic source) {
  if (source == null) return null;
  return values.firstWhere(
        (e) => e.toString().split('.').last == source,
    orElse: () => values.first,
  );
}
