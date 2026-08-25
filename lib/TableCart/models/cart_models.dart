class CartItem {
  final int? itemId;
  final int dishId;
  final String dishName;
  final double price;
  int quantity;
  final String? orderStatus;
  String? note;
  final bool isLocal;

  CartItem({
    this.itemId,
    required this.dishId,
    required this.dishName,
    required this.price,
    required this.quantity,
    this.orderStatus,
    this.note,
    this.isLocal = false,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
        itemId: json['itemId'],
        dishId: json['dishId'] ?? 0,
        dishName: json['dishName'] ?? '',
        price: (json['price'] ?? 0).toDouble(),
        quantity: json['quantity'] ?? 1,
        orderStatus: json['orderStatus'],
        isLocal: false,
      );

  factory CartItem.fromLocal(Map<String, dynamic> json) => CartItem(
        dishId: json['dishId'] ?? 0,
        dishName: json['dishName'] ?? '',
        price: (json['price'] ?? 0).toDouble(),
        quantity: json['quantity'] ?? 1,
        isLocal: true,
      );

  Map<String, dynamic> toJson() => {
        'itemId': itemId,
        'dishId': dishId,
        'dishName': dishName,
        'price': price,
        'quantity': quantity,
        'orderStatus': orderStatus,
      };

  Map<String, dynamic> toLocalJson() => {
        'dishId': dishId,
        'dishName': dishName,
        'price': price,
        'quantity': quantity,
      };

  CartItem copyWith({int? quantity, String? note}) => CartItem(
        itemId: itemId,
        dishId: dishId,
        dishName: dishName,
        price: price,
        quantity: quantity ?? this.quantity,
        orderStatus: orderStatus,
        note: note ?? this.note,
        isLocal: isLocal,
      );
}

class CartData {
  final int? cartId;
  final int? userId;
  final double subtotal;
  final double gstTotal;
  final double cgst;
  final double sgst;
  final double grandTotal;
  final double total;
  final double tipAmount;
  final double discountAmount;
  final double serviceCharges;
  final double packingTotal;
  final double platformCharges;
  final double deliveryCharges;
  final int? seatingDetailsId;
  final List<CartItem> cartItems;

  CartData({
    this.cartId,
    this.userId,
    this.subtotal = 0,
    this.gstTotal = 0,
    this.cgst = 0,
    this.sgst = 0,
    this.grandTotal = 0,
    this.total = 0,
    this.tipAmount = 0,
    this.discountAmount = 0,
    this.serviceCharges = 0,
    this.packingTotal = 0,
    this.platformCharges = 0,
    this.deliveryCharges = 0,
    this.seatingDetailsId,
    this.cartItems = const [],
  });

  factory CartData.fromJson(Map<String, dynamic> json) => CartData(
        cartId: json['cartId'],
        userId: json['userId'],
        subtotal: (json['subtotal'] ?? 0).toDouble(),
        gstTotal: (json['gstTotal'] ?? 0).toDouble(),
        cgst: (json['cgst'] ?? 0).toDouble(),
        sgst: (json['sgst'] ?? 0).toDouble(),
        grandTotal: (json['grandTotal'] ?? 0).toDouble(),
        total: (json['total'] ?? 0).toDouble(),
        tipAmount: (json['tipAmount'] ?? 0).toDouble(),
        discountAmount: (json['discountAmount'] ?? 0).toDouble(),
        serviceCharges: (json['serviceCharges'] ?? 0).toDouble(),
        packingTotal: (json['packingTotal'] ?? 0).toDouble(),
        platformCharges: (json['platformCharges'] ?? 0).toDouble(),
        deliveryCharges: (json['deliveryCharges'] ?? 0).toDouble(),
        seatingDetailsId: json['seatingDetailsId'],
        cartItems: (json['cartItems'] as List<dynamic>? ?? [])
            .map((e) => CartItem.fromJson(e))
            .toList(),
      );
}

class TableInfo {
  final int id;
  final String name;
  final String code;
  final int capacity;
  final String seatingStatus;

  TableInfo({
    required this.id,
    required this.name,
    required this.code,
    required this.capacity,
    required this.seatingStatus,
  });

  factory TableInfo.fromJson(Map<String, dynamic> json) => TableInfo(
        id: json['id'] ?? 0,
        name: json['name'] ?? '',
        code: json['code'] ?? '',
        capacity: json['capacity'] ?? 0,
        seatingStatus: json['seatingStatus'] ?? '',
      );

  bool get isAvailable =>
      seatingStatus.toLowerCase() == 'available';
}

class RemovalRequest {
  final int id;
  final String itemName;
  final int quantity;
  final String requestType;
  final int? removalQuantity;
  final String status;

  RemovalRequest({
    required this.id,
    required this.itemName,
    required this.quantity,
    required this.requestType,
    this.removalQuantity,
    required this.status,
  });

  factory RemovalRequest.fromJson(Map<String, dynamic> json) => RemovalRequest(
        id: json['id'] ?? 0,
        itemName: json['itemName'] ?? '',
        quantity: json['quantity'] ?? 0,
        requestType: json['requestType'] ?? '',
        removalQuantity: json['removalQuantity'],
        status: json['status'] ?? '',
      );
}

class PaymentMethodsConfig {
  final bool cash;
  final bool qrCode;
  final bool upi;
  final bool splitBilling;

  PaymentMethodsConfig({
    this.cash = true,
    this.qrCode = true,
    this.upi = true,
    this.splitBilling = true,
  });

  factory PaymentMethodsConfig.fromJson(Map<String, dynamic> json) =>
      PaymentMethodsConfig(
        cash: json['cash'] ?? false,
        qrCode: json['qrCode'] ?? false,
        upi: json['upi'] ?? false,
        splitBilling: json['splitBilling'] ?? false,
      );
}
