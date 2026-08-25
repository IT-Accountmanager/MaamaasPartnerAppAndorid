
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

class WebSocketManager {
  static final WebSocketManager _instance = WebSocketManager._internal();

  factory WebSocketManager() => _instance;

  WebSocketManager._internal();

  StompClient? _foodClient;
  StompClient? _deliveryClient;

  bool _foodConnecting = false;

  final List<Function()> _pendingFoodSubscriptions = [];

  // =========================================================
  // FOOD ORDER STATUS
  // =========================================================

  final Map<int, StompUnsubscribe> _foodSubscriptions = {};

  final Map<int, Map<String, Function(Map<String, dynamic>)>> _orderListeners =
      {};

  void connectFoodSocket() {
    if (_foodClient != null && _foodClient!.connected) return;

    if (_foodConnecting) return;

    _foodConnecting = true;

    _foodClient = StompClient(
      config: StompConfig(
        // url: 'ws://staging.maamaas.com:8080/food/ws',
        url: 'ws://backend.maamaas.com/food/ws',
        onConnect: (frame) {
          debugPrint('✅ Food WebSocket Connected');

          _foodConnecting = false;

          for (var callback in _pendingFoodSubscriptions) {
            callback();
          }

          _pendingFoodSubscriptions.clear();
        },

        onWebSocketError: (error) {
          _foodConnecting = false;

          debugPrint('❌ Food WS Error: $error');
        },

        onDisconnect: (_) {
          debugPrint('⚠️ Food WS Disconnected');
        },
      ),
    );

    _foodClient!.activate();
  }

  void subscribeOrderStatus(
    int orderId,
    Function(Map<String, dynamic>) onMessage, {
    String listenerId = 'default',
  }) {
    _orderListeners.putIfAbsent(orderId, () => {});

    _orderListeners[orderId]![listenerId] = onMessage;

    debugPrint('🔔 Listener "$listenerId" added for order $orderId');

    if (_foodSubscriptions.containsKey(orderId)) {
      debugPrint('✅ STOMP channel already exists for order $orderId');

      return;
    }

    void subscribe() {
      final subscription = _foodClient?.subscribe(
        destination: '/topic/order-updates/$orderId',

        callback: (frame) {
          if (frame.body == null) return;

          final data = json.decode(frame.body!) as Map<String, dynamic>;

          debugPrint('📩 Order update for $orderId : $data');

          final listeners = Map.of(_orderListeners[orderId] ?? {});

          for (final callback in listeners.values) {
            callback(data);
          }
        },
      );

      if (subscription != null) {
        _foodSubscriptions[orderId] = subscription;

        debugPrint('📡 STOMP subscribed for order $orderId');
      }
    }

    if (_foodClient != null && _foodClient!.connected) {
      subscribe();
    } else {
      _pendingFoodSubscriptions.add(subscribe);

      connectFoodSocket();
    }
  }

  void unsubscribeOrderStatus(int orderId, {String listenerId = 'default'}) {
    _orderListeners[orderId]?.remove(listenerId);

    debugPrint('🗑 Listener "$listenerId" removed for order $orderId');

    final remaining = _orderListeners[orderId]?.length ?? 0;

    if (remaining == 0) {
      _orderListeners.remove(orderId);

      if (_foodSubscriptions.containsKey(orderId)) {
        _foodSubscriptions[orderId]?.call();

        _foodSubscriptions.remove(orderId);

        debugPrint('❌ STOMP unsubscribed for order $orderId');
      }
    } else {
      debugPrint('ℹ️ $remaining listener(s) still active for order $orderId');
    }
  }

  // =========================================================
  // VENDOR ORDERS
  // =========================================================

  final Map<int, StompUnsubscribe> _vendorOrdersSubscriptions = {};

  final Map<int, Function(Map<String, dynamic>)> _vendorOrdersCallbacks = {};

  void subscribeVendorOrders(
    int vendorId,
    Function(Map<String, dynamic>) onMessage,
  ) {
    _vendorOrdersCallbacks[vendorId] = onMessage;

    if (_vendorOrdersSubscriptions.containsKey(vendorId)) {
      debugPrint('ℹ️ Vendor orders already subscribed');

      return;
    }

    void subscribe() {
      final subscription = _foodClient?.subscribe(
        destination: '/topic/chef-orders/$vendorId',
        callback: (frame) {
          if (frame.body == null) return;

          final data = json.decode(frame.body!);

          debugPrint('📩 Chef Orders Update : $data');

          _vendorOrdersCallbacks[vendorId]?.call(data);
        },
      );

      if (subscription != null) {
        _vendorOrdersSubscriptions[vendorId] = subscription;

        debugPrint('✅ Subscribed Vendor Orders $vendorId');
      }
    }

    if (_foodClient != null && _foodClient!.connected) {
      subscribe();
    } else {
      _pendingFoodSubscriptions.add(subscribe);

      connectFoodSocket();
    }
  }

  void unsubscribeVendorOrders(int vendorId) {
    if (_vendorOrdersSubscriptions.containsKey(vendorId)) {
      _vendorOrdersSubscriptions[vendorId]?.call();

      _vendorOrdersSubscriptions.remove(vendorId);

      _vendorOrdersCallbacks.remove(vendorId);

      debugPrint('❌ Unsubscribed Vendor Orders $vendorId');
    }
  }

  // =========================================================
  // ONLINE ORDERS
  // =========================================================

  final Map<int, StompUnsubscribe> _onlineOrdersSubscriptions = {};

  final Map<int, Function(Map<String, dynamic>)> _onlineOrdersCallbacks = {};

  void subscribeOnlineOrders(
    int vendorId,
    Function(Map<String, dynamic>) onMessage,
  ) {
    _onlineOrdersCallbacks[vendorId] = onMessage;

    if (_onlineOrdersSubscriptions.containsKey(vendorId)) {
      debugPrint('ℹ️ Online orders already subscribed');

      return;
    }

    void subscribe() {
      final subscription = _foodClient?.subscribe(
        destination: '/topic/online-orders/$vendorId',

        callback: (frame) {
          if (frame.body == null) return;

          final data = json.decode(frame.body!);

          debugPrint('📩 Online Orders Update : $data');

          _onlineOrdersCallbacks[vendorId]?.call(data);
        },
      );

      if (subscription != null) {
        _onlineOrdersSubscriptions[vendorId] = subscription;

        debugPrint('✅ Subscribed Online Orders $vendorId');
      }
    }

    if (_foodClient != null && _foodClient!.connected) {
      subscribe();
    } else {
      _pendingFoodSubscriptions.add(subscribe);

      connectFoodSocket();
    }
  }

  void unsubscribeOnlineOrders(int vendorId) {
    if (_onlineOrdersSubscriptions.containsKey(vendorId)) {
      _onlineOrdersSubscriptions[vendorId]?.call();

      _onlineOrdersSubscriptions.remove(vendorId);

      _onlineOrdersCallbacks.remove(vendorId);

      debugPrint('❌ Unsubscribed Online Orders $vendorId');
    }
  }

  // =========================================================
  // OFFLINE ORDERS
  // =========================================================

  final Map<int, StompUnsubscribe> _offlineOrdersSubscriptions = {};

  final Map<int, Function(Map<String, dynamic>)> _offlineOrdersCallbacks = {};

  void subscribeOfflineOrders(
    int vendorId,
    Function(Map<String, dynamic>) onMessage,
  ) {
    _offlineOrdersCallbacks[vendorId] = onMessage;

    if (_offlineOrdersSubscriptions.containsKey(vendorId)) {
      debugPrint('ℹ️ Offline orders already subscribed');

      return;
    }

    void subscribe() {
      final subscription = _foodClient?.subscribe(
        destination: '/topic/offline-orders/$vendorId',

        callback: (frame) {
          if (frame.body == null) return;

          final data = json.decode(frame.body!);

          debugPrint('📩 Offline Orders Update : $data');

          _offlineOrdersCallbacks[vendorId]?.call(data);
        },
      );

      if (subscription != null) {
        _offlineOrdersSubscriptions[vendorId] = subscription;

        debugPrint('✅ Subscribed Offline Orders $vendorId');
      }
    }

    if (_foodClient != null && _foodClient!.connected) {
      subscribe();
    } else {
      _pendingFoodSubscriptions.add(subscribe);

      connectFoodSocket();
    }
  }

  void unsubscribeOfflineOrders(int vendorId) {
    if (_offlineOrdersSubscriptions.containsKey(vendorId)) {
      _offlineOrdersSubscriptions[vendorId]?.call();

      _offlineOrdersSubscriptions.remove(vendorId);

      _offlineOrdersCallbacks.remove(vendorId);

      debugPrint('❌ Unsubscribed Offline Orders $vendorId');
    }
  }

  // =========================================================
  // VENDOR CART UPDATES
  // =========================================================

  final Map<int, StompUnsubscribe> _vendorCartSubscriptions = {};

  final Map<int, Function(Map<String, dynamic>)> _vendorCartCallbacks = {};

  void subscribeVendorCartUpdates(
    int vendorId,
    Function(Map<String, dynamic>) onMessage,
  ) {
    _vendorCartCallbacks[vendorId] = onMessage;

    if (_vendorCartSubscriptions.containsKey(vendorId)) {
      debugPrint('ℹ️ Vendor cart already subscribed');

      return;
    }

    void subscribe() {
      final subscription = _foodClient?.subscribe(
        destination: '/topic/vendor-cart-updates/$vendorId',

        callback: (frame) {
          if (frame.body == null) return;

          final data = json.decode(frame.body!);

          debugPrint('📩 Vendor Cart Update : $data');

          _vendorCartCallbacks[vendorId]?.call(data);
        },
      );

      if (subscription != null) {
        _vendorCartSubscriptions[vendorId] = subscription;

        debugPrint('✅ Subscribed Vendor Cart $vendorId');
      }
    }

    if (_foodClient != null && _foodClient!.connected) {
      subscribe();
    } else {
      _pendingFoodSubscriptions.add(subscribe);

      connectFoodSocket();
    }
  }

  void unsubscribeVendorCartUpdates(int vendorId) {
    if (_vendorCartSubscriptions.containsKey(vendorId)) {
      _vendorCartSubscriptions[vendorId]?.call();

      _vendorCartSubscriptions.remove(vendorId);

      _vendorCartCallbacks.remove(vendorId);

      debugPrint('❌ Unsubscribed Vendor Cart $vendorId');
    }
  }

  void disconnectAll() {
    _foodClient?.deactivate();

    _deliveryClient?.deactivate();

    _foodSubscriptions.clear();

    _orderListeners.clear();

    _vendorOrdersSubscriptions.clear();

    _vendorOrdersCallbacks.clear();

    _onlineOrdersSubscriptions.clear();

    _onlineOrdersCallbacks.clear();

    _offlineOrdersSubscriptions.clear();

    _offlineOrdersCallbacks.clear();

    _vendorCartSubscriptions.clear();

    _vendorCartCallbacks.clear();

    debugPrint('🛑 All WebSocket connections deactivated and cleared');
  }
}
