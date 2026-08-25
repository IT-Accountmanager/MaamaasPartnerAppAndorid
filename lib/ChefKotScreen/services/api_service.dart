
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../API/Apiclient.dart';
import '../../API/WebSocket.dart';
import '../models/kot_model.dart';

class ChefKotApi {
  static const _ss = FlutterSecureStorage();

  static final _ws = WebSocketManager();

  static String? _subscribedVendorId;

  static final Set<int> _watchedOrderIds = {};

  static Future<String> _vendorId() async {
    String? v = await _ss.read(key: 'vendorId');

    if (v == null || v.isEmpty) {
      final p = await SharedPreferences.getInstance();
      v = p.getString('vendorId') ?? p.getInt('vendorId')?.toString();
    }

    return v ?? '';
  }

  static bool _ok(int c) => c >= 200 && c < 300;

  static List _extractList(dynamic data) {
    if (data == null) return [];
    if (data is List) return data;
    if (data is Map) {
      if (data['content'] is List) return data['content'];
      if (data['data'] is List) return data['data'];
    }
    return [];
  }

  static Future<void> startRealtimeUpdates({
    required void Function(List<KotOrder> updatedOrders) onNewOrder,
    void Function(Map<String, dynamic> rawUpdate)? onOrderUpdate,
  }) async {
    final vid = await _vendorId();
    if (vid.isEmpty) return;

    _subscribedVendorId = vid;
    final vendorIdInt = int.tryParse(vid);
    if (vendorIdInt == null) return;

    _ws.connectFoodSocket();

    _ws.subscribeVendorOrders(vendorIdInt, (update) async {
      // debugPrint('📦 [KOT] vendor-orders update: $update');
      final fresh = await fetchOrders();
      onNewOrder(fresh);
      onOrderUpdate?.call(update);
    });

    _ws.subscribeOfflineOrders(vendorIdInt, (update) async {
      // debugPrint('🍽️ [KOT] offline-orders update: $update');
      final fresh = await fetchOrders();
      onNewOrder(fresh);
      onOrderUpdate?.call(update);
    });

    // debugPrint('✅ [KOT] WebSocket subscribed for vendor $vid');
  }

  static void watchOrderStatus(
    int orderId, {
    required void Function(Map<String, dynamic> update) onUpdate,
    String listenerId = 'kot',
  }) {
    if (_watchedOrderIds.contains(orderId)) return;
    _watchedOrderIds.add(orderId);

    _ws.connectFoodSocket();
    _ws.subscribeOrderStatus(orderId, (update) {
      // debugPrint('🔄 [KOT] order $orderId status update: $update');
      onUpdate(update);
    }, listenerId: listenerId);

    // debugPrint('👁️ [KOT] Watching order $orderId');
  }

  static void unwatchOrderStatus(int orderId, {String listenerId = 'kot'}) {
    if (!_watchedOrderIds.contains(orderId)) return;
    _watchedOrderIds.remove(orderId);
    _ws.unsubscribeOrderStatus(orderId, listenerId: listenerId);
    // debugPrint('🚫 [KOT] Stopped watching order $orderId');
  }

  static void stopRealtimeUpdates() {
    final vendorIdInt = _subscribedVendorId != null
        ? int.tryParse(_subscribedVendorId!)
        : null;

    if (vendorIdInt != null) {
      _ws.unsubscribeVendorOrders(vendorIdInt);
      _ws.unsubscribeOfflineOrders(vendorIdInt);
      // debugPrint(
      //   '🛑 [KOT] Unsubscribed vendor-orders & offline-orders for vendor $_subscribedVendorId',
      // );
    }

    // Clean up any per-order watches.
    for (final orderId in List<int>.from(_watchedOrderIds)) {
      _ws.unsubscribeOrderStatus(orderId, listenerId: 'kot');
    }
    _watchedOrderIds.clear();

    _subscribedVendorId = null;
    // debugPrint('🛑 [KOT] All WebSocket subscriptions removed');
  }

  static Future<List<KotOrder>> fetchOrders() async {
    final vid = await _vendorId();
    if (vid.isEmpty) return [];

    const size = 50;

    final r1 = await _getList(
      'api/orders/vendor/order/status/$vid',
      query: {
        'status': 'CONFIRMED',
        'page': '0',
        'size': '$size',
        'sortField': 'orderDateAndTime',
        'sortDir': 'asc',
      },
    );

    final r2 = await _getList(
      'api/orders/status-range',
      query: {
        'vendorId': vid,
        'fromStatus': 'BEING_PREPARED',
        'toStatus': 'BEING_PREPARED',
        'page': '0',
        'size': '$size',
      },
    );

    final r3 = await _getList(
      'api/cart/get/ordertype=TABLE_DINE_IN/$vid/CONFIRMED',
      query: {'page': '0', 'size': '$size'},
    );

    final r4 = await _getList(
      'api/cart/get/ordertype=TABLE_DINE_IN/$vid/BEING_PREPARED',
      query: {'page': '0', 'size': '$size'},
    );

    // 🧠 Deduplicate
    final seen = <dynamic>{};
    final combined = [...r1, ...r2, ...r3, ...r4].where((o) {
      if (o is! Map) return false;
      final key = o['orderId'] ?? o['cartId'];
      if (key == null || seen.contains(key)) return false;
      seen.add(key);
      return true;
    }).toList();

    // 🔄 Convert to model
    final orders = combined
        .map((o) {
          try {
            return KotOrder.fromApiOrder(o as Map<String, dynamic>);
          } catch (_) {
            return null;
          }
        })
        .whereType<KotOrder>()
        .toList();

    // ⏱ Sort oldest first
    orders.sort((a, b) {
      final ta = a.orderTimestamp?.millisecondsSinceEpoch ?? 0;
      final tb = b.orderTimestamp?.millisecondsSinceEpoch ?? 0;
      return ta.compareTo(tb);
    });

    return orders;
  }

  static Future<List> _getList(
    String endpoint, {
    Map<String, dynamic>? query,
  }) async {
    try {
      // debugPrint("GET → $endpoint");
      final res = await ApiClient.get(
        endpoint,
        service: 'food',
        queryParams: query,
      );
      // debugPrint("STATUS → ${res.statusCode}");
      if (_ok(res.statusCode)) {
        return _extractList(jsonDecode(res.body));
      }
    } catch (e) {
      // debugPrint("❌ API ERROR: $e");
    }
    return [];
  }

  //
  //
  // static Future<void> acceptOrder(
  //   KotOrder order,
  //   List<dynamic> selectedItemIds, {
  //   void Function(Map<String, dynamic> update)? onStatusUpdate,
  // }) async {
  //   final api = order.originalOrder ?? {};
  //   final orderId = api['orderId'] ?? api['cartId'] ?? order.id;
  //
  //   if (order.orderType == KotOrderType.table) {
  //     if (selectedItemIds.isEmpty) {
  //       throw Exception('Select at least one item');
  //     }
  //
  //     final ids = selectedItemIds.join('&itemIds=');
  //     final endpoint =
  //         'api/cart/cart/status/$orderId?itemIds=$ids&status=BEING_PREPARED';
  //
  //     final res = await ApiClient.put(endpoint, {}, service: 'food');
  //
  //     if (!_ok(res.statusCode)) {
  //       throw Exception('Accept failed (${res.statusCode})');
  //     }
  //   } else {
  //     final endpoint = 'api/orders/edit-orders/$orderId/BEING_PREPARED';
  //
  //     final res = await ApiClient.put(endpoint, {
  //       'status': 'BEING_PREPARED',
  //     }, service: 'food');
  //
  //     if (!_ok(res.statusCode)) {
  //       throw Exception('Accept failed (${res.statusCode})');
  //     }
  //   }
  //
  //   // 🔌 Subscribe to real-time status updates for this accepted order.
  //   if (orderId is int && onStatusUpdate != null) {
  //     watchOrderStatus(orderId, onUpdate: onStatusUpdate);
  //   } else if (orderId != null) {
  //     final id = int.tryParse(orderId.toString());
  //     if (id != null && onStatusUpdate != null) {
  //       watchOrderStatus(id, onUpdate: onStatusUpdate);
  //     }
  //   }
  // }
  //
  //
  // static Future<void> declineOrder(KotOrder order) async {
  //   final api = order.originalOrder ?? {};
  //   final orderId = api['orderId'] ?? api['cartId'] ?? order.id;
  //
  //   if (order.orderType == KotOrderType.table) {
  //     final endpoint = 'api/cart/cart/status/$orderId?status=CANCELLED';
  //     final res = await ApiClient.put(endpoint, {}, service: 'food');
  //
  //     if (!_ok(res.statusCode)) {
  //       throw Exception('Decline failed (${res.statusCode})');
  //     }
  //   } else {
  //     final endpoint = 'api/orders/cancal/total/order/$orderId';
  //     final res = await ApiClient.put(endpoint, {}, service: 'food');
  //
  //     if (!_ok(res.statusCode)) {
  //       throw Exception('Decline failed (${res.statusCode})');
  //     }
  //   }
  //
  //   // 🔌 Order cancelled — unwatch it so we don't leak the subscription.
  //   final id = orderId is int
  //       ? orderId
  //       : int.tryParse(orderId?.toString() ?? '');
  //   if (id != null) {
  //     unwatchOrderStatus(id);
  //   }
  // }
  //
  //
  //
  // static Future<void> markReady(
  //   KotOrder order, {
  //   void Function(Map<String, dynamic> update)? onStatusUpdate,
  // }) async {
  //   final api = order.originalOrder ?? {};
  //   final orderId = api['orderId'] ?? api['cartId'] ?? order.id;
  //
  //   if (order.orderType == KotOrderType.table) {
  //     final cartItems = (api['cartItems'] as List?) ?? [];
  //
  //     await Future.wait(
  //       cartItems.map((item) async {
  //         final itemId = item['itemId'];
  //         final endpoint =
  //             'api/cart/cartitem/status/$itemId'
  //             '?status=ORDER_IS_READY'
  //             '&note=${Uri.encodeComponent('Prepared successfully')}';
  //         await ApiClient.put(endpoint, {}, service: 'food');
  //       }),
  //     );
  //   } else {
  //     final endpoint = 'api/orders/edit-orders/$orderId/ORDER_IS_READY';
  //     final res = await ApiClient.put(endpoint, {
  //       'status': 'ORDER_IS_READY',
  //     }, service: 'food');
  //
  //     if (!_ok(res.statusCode)) {
  //       throw Exception('Mark ready failed (${res.statusCode})');
  //     }
  //   }
  //
  //   final id = orderId is int
  //       ? orderId
  //       : int.tryParse(orderId?.toString() ?? '');
  //
  //   if (id != null && onStatusUpdate != null) {
  //     watchOrderStatus(id, onUpdate: onStatusUpdate);
  //   } else if (id != null) {
  //     unwatchOrderStatus(id);
  //   }
  // }

  static Future<void> acceptOrder(
    KotOrder order,
    List<dynamic> selectedItemIds, {
    void Function(Map<String, dynamic> update)? onStatusUpdate,
  }) async {
    final api = order.originalOrder ?? {};
    final orderId = api['orderId'] ?? api['cartId'] ?? order.id;

    // Guard
    if (orderId == null || orderId.toString().isEmpty) {
      throw Exception('acceptOrder: orderId is null');
    }

    if (order.orderType == KotOrderType.table) {
      if (selectedItemIds.isEmpty) {
        throw Exception('Select at least one item');
      }

      // ✅ NEW API CALL
      for (final itemId in selectedItemIds) {
        final endpoint =
            'api/cart/cartitem/status/$itemId?status=BEING_PREPARED';

        final res = await ApiClient.put(endpoint, {}, service: 'food');

        // debugPrint('acceptOrder ITEM $itemId → ${res.statusCode} ${res.body}');

        if (!_ok(res.statusCode)) {
          throw Exception(
            'Accept failed for item $itemId '
            '(${res.statusCode}): ${res.body}',
          );
        }
      }
    } else {
      // ONLINE ORDER
      final endpoint = 'api/orders/edit-orders/$orderId/BEING_PREPARED';

      final res = await ApiClient.put(endpoint, {
        'status': 'BEING_PREPARED',
      }, service: 'food');

      // debugPrint('acceptOrder ONLINE → ${res.statusCode} ${res.body}');

      if (!_ok(res.statusCode)) {
        throw Exception('Accept failed (${res.statusCode}): ${res.body}');
      }
    }

    final id = orderId is int ? orderId : int.tryParse(orderId.toString());

    if (id != null && onStatusUpdate != null) {
      watchOrderStatus(id, onUpdate: onStatusUpdate);
    }
  }

  static Future<void> markProcessing(
    KotOrder order, {
    void Function(Map<String, dynamic> update)? onStatusUpdate,
  }) async {
    final api = order.originalOrder ?? {};
    final orderId = api['orderId'] ?? api['cartId'] ?? order.id;

    if (orderId == null || orderId.toString().isEmpty) {
      throw Exception('markProcessing: orderId is null');
    }

    if (order.orderType == KotOrderType.table) {
      final endpoint = 'api/cart/cart/status/$orderId?status=PROCESSING';
      final res = await ApiClient.put(endpoint, {}, service: 'food');
      // debugPrint('markProcessing TABLE → ${res.statusCode} ${res.body}');

      if (!_ok(res.statusCode)) {
        throw Exception(
          'Mark processing failed (${res.statusCode}): ${res.body}',
        );
      }
    } else {
      final endpoint = 'api/orders/edit-orders/$orderId/PROCESSING';
      final res = await ApiClient.put(endpoint, {
        'status': 'PROCESSING',
      }, service: 'food');
      // debugPrint('markProcessing ONLINE → ${res.statusCode} ${res.body}');

      if (!_ok(res.statusCode)) {
        throw Exception(
          'Mark processing failed (${res.statusCode}): ${res.body}',
        );
      }
    }

    final id = orderId is int ? orderId : int.tryParse(orderId.toString());
    if (id != null && onStatusUpdate != null) {
      watchOrderStatus(id, onUpdate: onStatusUpdate);
    }
  }

  static Future<void> declineOrder(KotOrder order) async {
    final api = order.originalOrder ?? {};
    final orderId = api['orderId'] ?? api['cartId'] ?? order.id;

    if (orderId == null || orderId.toString().isEmpty) {
      throw Exception('declineOrder: orderId is null');
    }

    if (order.orderType == KotOrderType.table) {
      final endpoint = 'api/cart/cart/status/$orderId?status=CANCELLED';
      final res = await ApiClient.put(endpoint, {}, service: 'food');
      // debugPrint('declineOrder TABLE → ${res.statusCode} ${res.body}');

      if (!_ok(res.statusCode)) {
        throw Exception('Decline failed (${res.statusCode}): ${res.body}');
      }
    } else {
      final endpoint = 'api/orders/cancel/total/order/$orderId';
      final res = await ApiClient.put(endpoint, {}, service: 'food');
      // debugPrint('declineOrder ONLINE → ${res.statusCode} ${res.body}');

      if (!_ok(res.statusCode)) {
        throw Exception('Decline failed (${res.statusCode}): ${res.body}');
      }
    }

    final id = orderId is int ? orderId : int.tryParse(orderId.toString());
    if (id != null) unwatchOrderStatus(id);
  }

  static Future<void> markReady(
    KotOrder order, {
    void Function(Map<String, dynamic> update)? onStatusUpdate,
  }) async {
    final api = order.originalOrder ?? {};
    final orderId = api['orderId'] ?? api['cartId'] ?? order.id;

    if (orderId == null || orderId.toString().isEmpty) {
      throw Exception('markReady: orderId is null');
    }

    if (order.orderType == KotOrderType.table) {
      final cartItems = (api['cartItems'] as List?) ?? [];

      if (cartItems.isEmpty) {
        throw Exception('markReady: no cartItems found in order');
      }

      await Future.wait(
        cartItems.map((item) async {
          final itemId = item['itemId'] ?? item['id'] ?? item['listId'];

          if (itemId == null) {
            // debugPrint(
            //   '⚠️ markReady: cartItem has no itemId — keys: ${item.keys}',
            // );
            return;
          }

          final endpoint =
              'api/cart/cartitem/status/$itemId'
              '?status=ORDER_IS_READY'
              '&note=${Uri.encodeComponent('Prepared successfully')}';

          final res = await ApiClient.put(endpoint, {}, service: 'food');
          // debugPrint('markReady ITEM $itemId → ${res.statusCode} ${res.body}');

          if (!_ok(res.statusCode)) {
            throw Exception(
              'Mark ready failed for item $itemId (${res.statusCode}): ${res.body}',
            );
          }
        }),
      );
    } else {
      final endpoint =
          'api/orders/edit-orders/$orderId/ORDER_IS_READY'
          '?status=ORDER_IS_READY';

      final res = await ApiClient.put(endpoint, {
        'status': 'ORDER_IS_READY',
      }, service: 'food');
      // debugPrint('markReady ONLINE → ${res.statusCode} ${res.body}');

      if (!_ok(res.statusCode)) {
        throw Exception('Mark ready failed (${res.statusCode}): ${res.body}');
      }
    }

    final id = orderId is int ? orderId : int.tryParse(orderId.toString());

    if (id != null && onStatusUpdate != null) {
      watchOrderStatus(id, onUpdate: onStatusUpdate);
    } else if (id != null) {
      unwatchOrderStatus(id);
    }
  }
}
