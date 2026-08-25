class KotItem {
  final dynamic itemId;
  final dynamic listId;
  final String name;
  final int quantity;
  final int updateQuantity;
  final double? price;
  final double? totalPrice;
  final String? status;
  final String? chefType;
  final String? note;

  const KotItem({
    this.itemId,
    this.listId,
    required this.name,
    required this.quantity,
    required this.updateQuantity,
    this.price,
    this.totalPrice,
    this.status,
    this.chefType,
    this.note,
  });

  factory KotItem.fromJson(Map<String, dynamic> j) => KotItem(
    itemId: j['itemId'] ?? j['id'] ?? j['listId'],
    listId: j['listId'],
    name: j['dishName']?.toString() ?? j['name']?.toString() ?? 'Item',
    quantity: (j['quantity'] as num?)?.toInt() ?? 1,
    updateQuantity:
        (j['updateQuantity'] as num?)?.toInt() ??
        (j['quantity'] as num?)?.toInt() ??
        1,
    price: (j['price'] as num?)?.toDouble(),
    totalPrice: (j['totalPrice'] as num?)?.toDouble(),
    status: j['orderStatus']?.toString() ?? j['status']?.toString(),
    chefType: j['chefType']?.toString(),
    note: j['note']?.toString(),
  );

  bool get isAlreadyAccepted => updateQuantity == 0;

  bool get isPending =>
      status == null || status == 'CONFIRMED' || status == 'PENDING';
}

enum KotStatus { pending, preparing, ready, declined }

enum KotOrderType { dineIn, takeaway, delivery, table }

class KotOrder {
  final dynamic id;
  final String kotNumber;
  KotOrderType orderType;
  final String tableNumber;
  final List<KotItem> items;
  final String orderTime;
  final DateTime? orderTimestamp;
  final int estimatedPrepTime;
  KotStatus status;
  final Map<String, dynamic>? originalOrder;

  KotOrder({
    required this.id,
    required this.kotNumber,
    required this.orderType,
    required this.tableNumber,
    required this.items,
    required this.orderTime,
    this.orderTimestamp,
    required this.estimatedPrepTime,
    required this.status,
    this.originalOrder,
  });

  factory KotOrder.fromApiOrder(Map<String, dynamic> api) {
    final isTable = api['orderType']?.toString() == 'TABLE_DINE_IN';

    final rawItems = _getItems(api);
    final items = rawItems
        .map((j) {
          try {
            return KotItem.fromJson(j as Map<String, dynamic>);
          } catch (_) {
            return null;
          }
        })
        .whereType<KotItem>()
        .toList();

    KotStatus status = KotStatus.pending;
    if (isTable) {
      final statuses = rawItems
          .map((i) => (i as Map)['orderStatus']?.toString())
          .toList();
      if (statuses.any((s) => s == 'ORDER_IS_READY')) {
        status = KotStatus.ready;
      } else if (statuses.any((s) => s == 'BEING_PREPARED')) {
        status = KotStatus.preparing;
      } else if (statuses.any((s) => s == 'CANCELLED')) {
        status = KotStatus.declined;
      }
    } else {
      switch (api['status']?.toString()) {
        case 'BEING_PREPARED':
          status = KotStatus.preparing;
          break;
        case 'ORDER_IS_READY':
          status = KotStatus.ready;
          break;
        case 'CANCELLED':
          status = KotStatus.declined;
          break;
        default:
          status = KotStatus.pending;
      }
    }

    KotOrderType orderType = KotOrderType.dineIn;
    switch (api['orderType']?.toString()) {
      case 'TABLE_DINE_IN':
        orderType = KotOrderType.table;
        break;
      case 'TAKEAWAY':
        orderType = KotOrderType.takeaway;
        break;
      case 'DELIVERY':
        orderType = KotOrderType.delivery;
        break;
      case 'DINE_IN':
        orderType = KotOrderType.dineIn;
        break;
    }

    String orderTime = '';
    DateTime? timestamp;

    String? rawTime =
        api['orderDateAndTime']?.toString() ?? api['createdAt']?.toString();

    if (rawTime == null && rawItems.isNotEmpty) {
      rawTime = (rawItems.first as Map)['createdAt']?.toString();
    }

    if (rawTime != null) {
      try {
        final parsed = DateTime.parse(
          rawTime.endsWith('Z') ? rawTime : '${rawTime}Z',
        );
        timestamp = parsed;
        final ist = parsed.add(const Duration(hours: 5, minutes: 30));
        final h24 = ist.hour;
        final m = ist.minute.toString().padLeft(2, '0');
        final amPm = h24 >= 12 ? 'PM' : 'AM';
        final h12 = h24 > 12 ? h24 - 12 : (h24 == 0 ? 12 : h24);
        orderTime = '$h12:$m $amPm';
      } catch (_) {}
    }

    // if (rawTime != null) {
    //   try {
    //     final parsed = DateTime.parse(rawTime);
    //
    //     timestamp = parsed;
    //
    //     final ist = parsed;
    //
    //     final h24 = ist.hour;
    //     final m = ist.minute.toString().padLeft(2, '0');
    //     final amPm = h24 >= 12 ? 'PM' : 'AM';
    //     final h12 = h24 > 12 ? h24 - 12 : (h24 == 0 ? 12 : h24);
    //
    //     orderTime = '$h12:$m $amPm';
    //   } catch (_) {}
    // }

    final id = api['orderId'] ?? api['cartId'];
    final kotNumber = api['kotNumber']?.toString() ?? '#KOT-$id';

    String tableNumber = '';
    if (isTable) {
      tableNumber = api['tableCode']?.toString().isNotEmpty == true
          ? api['tableCode'].toString()
          : (api['tableId'] != null ? 'Table ${api['tableId']}' : '');
    }

    return KotOrder(
      id: id,
      kotNumber: kotNumber,
      orderType: orderType,
      tableNumber: tableNumber,
      items: items,
      orderTime: orderTime,
      orderTimestamp: timestamp,
      estimatedPrepTime: 10 + (items.length * 5),
      status: status,
      originalOrder: api,
    );
  }

  List<dynamic> get allItemIds =>
      items.map((i) => i.itemId).where((id) => id != null).toList();

  List<KotItem> get pendingItems => items.where((i) => i.isPending).toList();

  List get rawCartItems => (originalOrder?['cartItems'] as List?) ?? [];

  static List _getItems(Map<String, dynamic> api) {
    if (api.containsKey('cartItems') && api['cartItems'] is List) {
      return api['cartItems'] as List;
    }
    if (api['orderItems'] is List) return api['orderItems'] as List;
    if (api['items'] is List) return api['items'] as List;
    if (api['order'] is List) return api['order'] as List;
    return [];
  }
}

const kDeclineReasons = [
  'Kitchen overload',
  'Ingredient unavailable',
  'Item not available',
  'Equipment issue',
  'Other',
];
