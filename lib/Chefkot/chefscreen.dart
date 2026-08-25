import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

const String _foodApi = "http://staging.maamaas.com:8080/food";

const List<String> _declineReasons = [
  'Kitchen overload',
  'Ingredient unavailable',
  'Item not available',
  'Equipment issue',
  'Other',
];

class KotItem {
  final int itemId;
  final String name;
  int quantity;
  int updateQuantity;
  String status;
  final double price;
  final String note;
  final String? chefType;
  String orderStatus;

  KotItem({
    required this.itemId,
    required this.name,
    required this.quantity,
    this.updateQuantity = 0,
    required this.status,
    required this.price,
    this.note = '',
    this.chefType,
    required this.orderStatus,
  });

  KotItem copyWith({String? status, String? orderStatus, int? quantity}) =>
      KotItem(
        itemId: itemId,
        name: name,
        quantity: quantity ?? this.quantity,
        updateQuantity: updateQuantity,
        status: status ?? this.status,
        price: price,
        note: note,
        chefType: chefType,
        orderStatus: orderStatus ?? this.orderStatus,
      );
}

class KotOrder {
  final String id;
  final String kotNumber;
  final String orderType;
  final String? tableNumber;
  String status;
  List<KotItem> items;
  final DateTime createdAt;
  final Map<String, dynamic> originalOrder;
  final int? cartId;
  final int? userId;

  KotOrder({
    required this.id,
    required this.kotNumber,
    required this.orderType,
    this.tableNumber,
    required this.status,
    required this.items,
    required this.createdAt,
    required this.originalOrder,
    this.cartId,
    this.userId,
  });

  KotOrder copyWith({String? status, List<KotItem>? items}) => KotOrder(
    id: id,
    kotNumber: kotNumber,
    orderType: orderType,
    tableNumber: tableNumber,
    status: status ?? this.status,
    items: items ?? this.items,
    createdAt: createdAt,
    originalOrder: originalOrder,
    cartId: cartId,
    userId: userId,
  );

  bool get isTableOrder => orderType == 'TABLE_DINE_IN';
  bool get isOnline => userId != null;
}

class KotTransformService {
  static KotOrder? transformToKOTFormat(Map<String, dynamic> data) {
    try {
      final orderType = data['orderType'] as String? ?? 'DINE_IN';
      final isTableOrder = orderType == 'TABLE_DINE_IN';

      final String id = isTableOrder
          ? (data['cartId'] ?? data['id'] ?? '').toString()
          : (data['orderId'] ?? data['id'] ?? '').toString();

      if (id.isEmpty) return null;

      final List<dynamic> rawItems = isTableOrder
          ? (data['cartItems'] ?? [])
          : (data['orderItems'] ?? data['cartItems'] ?? []);

      final items = rawItems
          .where((i) => (i['orderStatus'] ?? '') != 'PENDING')
          .map(
            (i) => KotItem(
              itemId: i['itemId'] as int? ?? 0,
              name: i['dishName'] as String? ?? '',
              quantity: i['quantity'] as int? ?? 1,
              updateQuantity: i['updateQuantity'] as int? ?? 0,
              status: _mapStatus(i['orderStatus'] as String? ?? 'PENDING'),
              price: (i['price'] as num?)?.toDouble() ?? 0.0,
              note: i['note'] as String? ?? '',
              chefType: i['chefType'] as String?,
              orderStatus: i['orderStatus'] as String? ?? 'PENDING',
            ),
          )
          .toList();

      if (items.isEmpty) return null;

      final overallStatus = _computeOrderStatus(items);

      DateTime createdAt = DateTime.now();
      try {
        final raw = data['orderDateAndTime'] ?? data['createdAt'];
        if (raw != null) createdAt = DateTime.parse(raw);
      } catch (_) {}

      return KotOrder(
        id: id,
        kotNumber: (data['kotNumber'] ?? data['orderId'] ?? id).toString(),
        orderType: orderType,
        tableNumber:
            data['tableCode'] as String? ?? data['tableNumber'] as String?,
        status: overallStatus,
        items: items,
        createdAt: createdAt,
        originalOrder: data,
        cartId: (data['cartId'] as int?) ?? (int.tryParse(id) ?? 0),
        userId: data['userId'] as int?,
      );
    } catch (_) {
      return null;
    }
  }

  static String _mapStatus(String raw) {
    switch (raw) {
      case 'BEING_PREPARED':
        return 'preparing';
      case 'ORDER_IS_READY':
        return 'ready';
      case 'WAITING_FOR_PICKUP':
        return 'waiting_for_pickup';
      case 'DELIVERED':
        return 'delivered';
      default:
        return 'pending';
    }
  }

  static String _computeOrderStatus(List<KotItem> items) {
    final statuses = items.map((i) => i.status).toSet();
    if (statuses.every((s) => s == 'waiting_for_pickup'))
      return 'waiting_for_pickup';
    if (statuses.every((s) => s == 'ready')) return 'ready';
    if (statuses.every((s) => s == 'preparing')) return 'preparing';
    return items.first.status;
  }
}

class ChefKotScreen extends StatefulWidget {
  const ChefKotScreen({super.key});

  @override
  State<ChefKotScreen> createState() => _ChefKotScreenState();
}

class _ChefKotScreenState extends State<ChefKotScreen> {
  static const _secureStorage = FlutterSecureStorage();

  List<KotOrder> _orders = [];
  bool _loading = false;
  String? _apiError;

  Map<String, Map<int, bool>> _selectedItems = {};

  Map<int, bool> _processingItems = {};

  String? _declineDialogOrderId;
  String _selectedReason = '';
  String _declineNote = '';

  _ToastInfo? _toast;
  Timer? _toastTimer;

  StompClient? _stompClient;

  int? _vendorId;
  String? _role;
  String? _employeeRole;
  String? _token;

  // ── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _stompClient?.deactivate();
    _toastTimer?.cancel();
    super.dispose();
  }

  Future<void> _init() async {
    await _loadPrefs();
    await _fetchOrders();
    _connectWebSocket();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _vendorId = prefs.getInt('vendorId');
    _role = prefs.getString('role');
    _employeeRole = prefs.getString('employeeRole');
    _token = await _secureStorage.read(key: 'token');
  }

  // ── Chef type filtering ──────────────────────────────────────────────────

  String? get _chefType => (_role == 'ROLE_VENDOR') ? null : _employeeRole;

  List<KotItem> _filterByChefType(List<KotItem> items) {
    final ct = _chefType;
    if (ct == null) return items;
    if (ct == 'Chef_All') return items;
    return items.where((i) {
      if (i.chefType == null) return true;
      if (i.chefType == 'Chef_All') return true;
      return i.chefType == ct;
    }).toList();
  }

  // ── Fetch orders ─────────────────────────────────────────────────────────

  Future<void> _fetchOrders() async {
    if (_vendorId == null) {
      setState(() => _apiError = 'Vendor ID not found');
      return;
    }
    setState(() {
      _loading = true;
      _apiError = null;
    });

    try {
      final response = await http.get(
        Uri.parse('$_foodApi/api/chef/orders/$_vendorId'),
        headers: {
          'Content-Type': 'application/json',
          if (_token != null) 'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> raw = jsonDecode(response.body);
        final List<KotOrder> orders = [];

        for (final data in raw) {
          final order = KotTransformService.transformToKOTFormat(
            data as Map<String, dynamic>,
          );
          if (order == null) continue;
          final filtered = _filterByChefType(order.items);
          if (filtered.isEmpty) continue;
          orders.add(order.copyWith(items: filtered));
        }

        orders.sort((a, b) => int.parse(a.id).compareTo(int.parse(b.id)));
        setState(() => _orders = orders);
      } else {
        setState(() => _apiError = 'Failed: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => _apiError = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  // ── WebSocket ────────────────────────────────────────────────────────────

  void _connectWebSocket() {
    if (_vendorId == null) return;

    _stompClient = StompClient(
      config: StompConfig.sockJS(
        url: 'http://staging.maamaas.com:8080/subscription/ws',
        onConnect: _onWsConnected,
        onDisconnect: (_) => debugPrint('WS disconnected'),
        onWebSocketError: (e) => debugPrint('WS error: $e'),
      ),
    );
    _stompClient!.activate();
  }

  void _onWsConnected(StompFrame frame) {
    _stompClient?.subscribe(
      destination: '/topic/vendor-$_vendorId',
      callback: _handleWsMessage,
    );
    _stompClient?.subscribe(
      destination: '/topic/vendor-table-cart-updates-$_vendorId',
      callback: _handleWsMessage,
    );
  }

  void _handleWsMessage(StompFrame frame) {
    if (frame.body == null) return;
    try {
      final data = jsonDecode(frame.body!) as Map<String, dynamic>;
      final topic = data['topic'] as String? ?? '';

      if (topic == 'online-orders' || topic == 'vendor-cart-updates') {
        _fetchOrders();
      } else if (topic == 'vendor-table-cart-updates') {
        _mergeTableCartUpdate(data);
      }
    } catch (_) {}
  }

  void _mergeTableCartUpdate(Map<String, dynamic> data) {
    final cartId = data['cartId']?.toString() ?? '';
    if (cartId.isEmpty) return;

    final List<dynamic> rawItems = data['cartItems'] ?? [];
    final chefType = _chefType;

    final filtered = rawItems.where((i) {
      if (i['orderStatus'] == 'PENDING') return false;
      if (chefType == null) return true;
      if (chefType == 'Chef_All') return true;
      final ct = i['chefType'] as String?;
      if (ct == null) return true;
      if (ct == 'Chef_All') return true;
      return ct == chefType;
    }).toList();

    setState(() {
      final idx = _orders.indexWhere((o) => o.id == cartId);
      if (idx < 0) {
        // New order
        final order = KotTransformService.transformToKOTFormat(data);
        if (order != null && order.items.isNotEmpty) {
          _orders = [..._orders, order]
            ..sort((a, b) => int.parse(a.id).compareTo(int.parse(b.id)));
        }
        return;
      }

      final existing = _orders[idx];
      final updatedItems = List<KotItem>.from(existing.items);

      for (final raw in filtered) {
        final itemId = raw['itemId'] as int;
        final newStatus = KotTransformService._mapStatus(
          raw['orderStatus'] as String? ?? '',
        );
        final eIdx = updatedItems.indexWhere((i) => i.itemId == itemId);
        if (eIdx >= 0) {
          updatedItems[eIdx] = updatedItems[eIdx].copyWith(
            status: newStatus,
            quantity: raw['quantity'] as int? ?? updatedItems[eIdx].quantity,
          );
        } else if (newStatus != 'delivered') {
          updatedItems.add(
            KotItem(
              itemId: itemId,
              name: raw['dishName'] as String? ?? '',
              quantity: raw['quantity'] as int? ?? 1,
              status: newStatus,
              price: (raw['price'] as num?)?.toDouble() ?? 0.0,
              note: raw['note'] as String? ?? '',
              chefType: raw['chefType'] as String?,
              orderStatus: raw['orderStatus'] as String? ?? '',
            ),
          );
        }
      }

      final finalItems = updatedItems
          .where((i) => i.status != 'delivered')
          .toList();
      if (finalItems.isEmpty) {
        _orders = _orders.where((o) => o.id != cartId).toList();
        return;
      }

      _orders[idx] = existing.copyWith(
        items: finalItems,
        status: KotTransformService._computeOrderStatus(finalItems),
      );
    });
  }

  // ── Order actions ─────────────────────────────────────────────────────────

  Future<void> _acceptNormalOrder(KotOrder order) async {
    final orderId = order.originalOrder['orderId'];
    if (orderId == null) {
      _showToast('Order ID missing', type: _ToastType.error);
      return;
    }

    try {
      setState(() => _loading = true);
      // POST to edit-orders/{orderId}/CONFIRMED with cashStatus=ACCEPT
      await http.post(
        Uri.parse(
          '$_foodApi/api/orders/edit-orders/$orderId/CONFIRMED'
          '?status=CONFIRMED&cashStatus=ACCEPT',
        ),
        headers: {
          'Content-Type': 'application/json',
          if (_token != null) 'Authorization': 'Bearer $_token',
        },
      );

      setState(() {
        _orders = _orders.map((o) {
          if (o.id != order.id) return o;
          return o.copyWith(
            status: 'preparing',
            items: o.items.map((i) => i.copyWith(status: 'preparing')).toList(),
          );
        }).toList()..sort((a, b) => int.parse(a.id).compareTo(int.parse(b.id)));
      });
      _showToast('Order #${order.kotNumber} is being prepared');
    } catch (e) {
      _showToast('Failed to accept order', type: _ToastType.error);
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _updateNormalOrderStatus(KotOrder order) async {
    final nextStatus = _getNextStatus(order.status, order.orderType);
    if (nextStatus == null) {
      _showToast('Order already completed', type: _ToastType.info);
      return;
    }

    try {
      setState(() => _loading = true);
      final orderId = order.originalOrder['orderId'] ?? order.id;

      // Map internal next status to the API status value
      final apiStatus = _nextStatusToApiParam(nextStatus);
      final cashStatus = nextStatus == 'BEING_PREPARED' ? 'ACCEPT' : 'ACCEPT';

      await http.post(
        Uri.parse(
          '$_foodApi/api/orders/edit-orders/$orderId/$apiStatus'
          '?status=$apiStatus&cashStatus=$cashStatus',
        ),
        headers: {
          'Content-Type': 'application/json',
          if (_token != null) 'Authorization': 'Bearer $_token',
        },
      );

      final mappedStatus = _mapApiStatusToLocal(nextStatus);
      setState(() {
        _orders =
            _orders
                .map((o) {
                  if (o.id != order.id) return o;
                  return o.copyWith(
                    status: mappedStatus,
                    items: o.items
                        .map((i) => i.copyWith(status: mappedStatus))
                        .toList(),
                  );
                })
                .where((o) => o.status != 'delivered')
                .toList()
              ..sort((a, b) => int.parse(a.id).compareTo(int.parse(b.id)));
      });

      final msg = {
        'BEING_PREPARED': 'Order is being prepared',
        'ORDER_IS_READY': 'Order is ready',
        'DELIVERED': 'Order delivered!',
      }[nextStatus];
      if (msg != null) _showToast(msg);
    } catch (_) {
      _showToast('Failed to update order', type: _ToastType.error);
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _handleSelectedItemsUpdate(
    KotOrder order,
    String nextStatus,
    List<KotItem> selectedList,
  ) async {
    if (selectedList.isEmpty) {
      _showToast('No items selected', type: _ToastType.warning);
      return;
    }

    final mappedStatus = _mapApiStatusToLocal(nextStatus);

    // Optimistic update
    setState(() {
      _orders =
          _orders
              .map((o) {
                if (o.id != order.id) return o;
                final updated = o.items
                    .map((item) {
                      if (selectedList.any((s) => s.itemId == item.itemId)) {
                        return item.copyWith(status: mappedStatus);
                      }
                      return item;
                    })
                    .where((i) => i.status != 'delivered')
                    .toList();

                if (updated.isEmpty) return null;
                return o.copyWith(
                  items: updated,
                  status: KotTransformService._computeOrderStatus(updated),
                );
              })
              .whereType<KotOrder>()
              .toList()
            ..sort((a, b) => int.parse(a.id).compareTo(int.parse(b.id)));

      _selectedItems[order.id] = {};
    });

    try {
      for (final item in selectedList) {
        await http.put(
          Uri.parse(
            '$_foodApi/cart/update/table/quantity/status/${order.cartId}'
            '?itemId=${item.itemId}&quantity=${item.quantity}&status=$nextStatus',
          ),
          headers: {
            'Content-Type': 'application/json',
            if (_token != null) 'Authorization': 'Bearer $_token',
          },
        );
        await Future.delayed(const Duration(milliseconds: 100));
      }
    } catch (_) {
      _showToast('Some items may not have updated', type: _ToastType.warning);
    }

    Future.delayed(const Duration(seconds: 1), _fetchOrders);
  }

  Future<void> _handleIndividualItemUpdate(KotOrder order, KotItem item) async {
    final nextStatus = _getNextItemStatus(item.status);
    if (nextStatus == null) {
      _showToast('Item already completed', type: _ToastType.info);
      return;
    }

    setState(() => _processingItems[item.itemId] = true);

    try {
      await http.put(
        Uri.parse(
          '$_foodApi/cart/update/table/quantity/status/${order.cartId}'
          '?itemId=${item.itemId}&quantity=${item.quantity}&status=$nextStatus',
        ),
        headers: {
          'Content-Type': 'application/json',
          if (_token != null) 'Authorization': 'Bearer $_token',
        },
      );

      final mappedStatus = _mapApiStatusToLocal(nextStatus);
      setState(() {
        _orders = _orders
            .map((o) {
              if (o.id != order.id) return o;
              final updated = o.items
                  .map((i) {
                    if (i.itemId != item.itemId) return i;
                    return i.copyWith(status: mappedStatus);
                  })
                  .where((i) => i.status != 'delivered')
                  .toList();

              if (updated.isEmpty) return null;
              return o.copyWith(
                items: updated,
                status: KotTransformService._computeOrderStatus(updated),
              );
            })
            .whereType<KotOrder>()
            .toList();
      });
      _showToast('${item.name} updated');
    } catch (_) {
      _showToast('Failed to update item', type: _ToastType.error);
    } finally {
      setState(() => _processingItems[item.itemId] = false);
    }
  }

  Future<void> _handleDecline() async {
    final orderId = _declineDialogOrderId;
    if (orderId == null) return;
    final order = _orders.firstWhere(
      (o) => o.id == orderId,
      orElse: () => throw Exception('not found'),
    );

    try {
      setState(() => _loading = true);
      await http.post(
        Uri.parse(
          '$_foodApi/api/chef/decline/${order.originalOrder['orderId'] ?? orderId}',
        ),
        headers: {
          'Content-Type': 'application/json',
          if (_token != null) 'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({
          'reason': _selectedReason.isNotEmpty ? _selectedReason : _declineNote,
          'note': _declineNote,
        }),
      );

      setState(() {
        _orders = _orders.where((o) => o.id != orderId).toList();
        _declineDialogOrderId = null;
        _selectedReason = '';
        _declineNote = '';
      });
      _showToast('Order declined', type: _ToastType.error);
    } catch (_) {
      _showToast('Failed to decline order', type: _ToastType.error);
    } finally {
      setState(() => _loading = false);
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String? _getNextStatus(String current, String orderType) {
    final isDineOrTakeaway = orderType == 'DINE_IN' || orderType == 'TAKEAWAY';
    if (isDineOrTakeaway) {
      return {
        'pending': 'BEING_PREPARED',
        'preparing': 'ORDER_IS_READY',
        'ready': 'DELIVERED',
      }[current];
    }
    return {
      'pending': 'BEING_PREPARED',
      'preparing': 'ORDER_IS_READY',
      'ready': 'WAITING_FOR_PICKUP',
      'waiting_for_pickup': 'DELIVERED',
    }[current];
  }

  String? _getNextItemStatus(String current) => {
    'pending': 'BEING_PREPARED',
    'preparing': 'ORDER_IS_READY',
    'ready': 'WAITING_FOR_PICKUP',
    'waiting_for_pickup': 'DELIVERED',
  }[current];

  String _mapApiStatusToLocal(String api) {
    switch (api) {
      case 'BEING_PREPARED':
        return 'preparing';
      case 'ORDER_IS_READY':
        return 'ready';
      case 'WAITING_FOR_PICKUP':
        return 'waiting_for_pickup';
      case 'DELIVERED':
        return 'delivered';
      default:
        return api.toLowerCase();
    }
  }

  String _nextStatusToApiParam(String nextStatus) {
    switch (nextStatus) {
      case 'BEING_PREPARED':
        return 'CONFIRMED';
      case 'ORDER_IS_READY':
        return 'READY';
      case 'WAITING_FOR_PICKUP':
        return 'DISPATCHED';
      case 'DELIVERED':
        return 'DELIVERED';
      default:
        return nextStatus;
    }
  }

  String? _getButtonText(String status, String orderType) {
    final isDineOrTakeaway = orderType == 'DINE_IN' || orderType == 'TAKEAWAY';
    if (isDineOrTakeaway) {
      return {
        'pending': 'Accept',
        'preparing': 'Preparing',
        'ready': 'Delivered',
      }[status];
    }
    return {
      'pending': 'Accept Order',
      'preparing': 'Mark Ready',
      'ready': 'Dispatched',
      'waiting_for_pickup': 'Delivered',
    }[status];
  }

  String _formatTime(DateTime dt) {
    final ist = dt.add(const Duration(hours: 5, minutes: 30));
    final h = ist.hour % 12 == 0 ? 12 : ist.hour % 12;
    final m = ist.minute.toString().padLeft(2, '0');
    final ampm = ist.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $ampm';
  }

  Color _cardColor(String orderType) {
    switch (orderType) {
      case 'DINE_IN':
        return const Color(0xFF1E90FF);
      case 'TAKEAWAY':
        return const Color(0xFFFF6347);
      case 'DELIVERY':
        return const Color(0xFF2051B2);
      case 'TABLE_DINE_IN':
        return const Color(0xFF20B2AA);
      default:
        return const Color(0xFFE66D33);
    }
  }

  String _orderTypeLabel(KotOrder order) {
    if (order.orderType == 'TABLE_DINE_IN') {
      return order.tableNumber != null
          ? 'Table - ${order.tableNumber}'
          : 'Dine In';
    }
    if (order.orderType == 'DINE_IN') return 'Dine In';
    if (order.orderType == 'TAKEAWAY') return 'Takeaway';
    if (order.orderType == 'DELIVERY') return 'Delivery';
    return order.orderType;
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':
        return const Color(0xFFFF9800);
      case 'preparing':
        return const Color(0xFF2196F3);
      case 'ready':
        return const Color(0xFF4CAF50);
      case 'waiting_for_pickup':
        return const Color(0xFF9C27B0);
      default:
        return Colors.grey;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'preparing':
        return 'Preparing';
      case 'ready':
        return 'Ready';
      case 'waiting_for_pickup':
        return 'Dispatched';
      default:
        return status;
    }
  }

  void _showToast(
    String title, {
    String desc = '',
    _ToastType type = _ToastType.success,
  }) {
    _toastTimer?.cancel();
    setState(() => _toast = _ToastInfo(title: title, desc: desc, type: type));
    _toastTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _toast = null);
    });
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Chef KOT',
          style: TextStyle(
            color: Color(0xFF1A1A2E),
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _fetchOrders,
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF1A1A2E)),
          ),
        ],
      ),
      body: Stack(
        children: [
          _buildBody(),
          if (_toast != null) _buildToast(_toast!),
          if (_declineDialogOrderId != null) _buildDeclineOverlay(),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading && _orders.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFE66D33)),
      );
    }

    if (_orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: Color(0xFFBBBBBB),
            ),
            const SizedBox(height: 16),
            Text(
              _apiError != null ? 'Error: $_apiError' : 'No active orders',
              style: const TextStyle(color: Color(0xFF888888), fontSize: 16),
            ),
            if (_apiError != null) ...[
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _fetchOrders,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE66D33),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchOrders,
      color: const Color(0xFFE66D33),
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _orders.length,
        itemBuilder: (_, i) => _buildOrderCard(_orders[i]),
      ),
    );
  }

  Widget _buildOrderCard(KotOrder order) {
    final selected = _selectedItems[order.id] ?? {};
    final selectedList = order.items
        .where((i) => selected[i.itemId] == true)
        .toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border(
          left: BorderSide(color: _cardColor(order.orderType), width: 5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardHeader(order),
          _buildItemsList(order, selected),
          _buildTimeRow(order),
          _buildActionButtons(order, selectedList),
        ],
      ),
    );
  }

  Widget _buildCardHeader(KotOrder order) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _cardColor(order.orderType).withOpacity(0.06),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(9),
          topRight: Radius.circular(14),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order #${order.kotNumber}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _TypeBadge(
                      label: _orderTypeLabel(order),
                      color: _cardColor(order.orderType),
                    ),
                    const SizedBox(width: 8),
                    _SourceBadge(isOnline: order.isOnline),
                  ],
                ),
              ],
            ),
          ),
          _StatusBadge(status: order.status),
          if (order.isTableOrder) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _selectAllItems(order),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A2E).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'All',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF444466),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _selectAllItems(KotOrder order) {
    final map = <int, bool>{};
    for (final item in order.items) {
      if (item.status != 'delivered') map[item.itemId] = true;
    }
    setState(() => _selectedItems[order.id] = map);
    _showToast('${map.length} item(s) selected', type: _ToastType.info);
  }

  Widget _buildItemsList(KotOrder order, Map<int, bool> selected) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Column(
        children: order.items
            .map((item) => _buildItemRow(order, item, selected))
            .toList(),
      ),
    );
  }

  Widget _buildItemRow(KotOrder order, KotItem item, Map<int, bool> selected) {
    final isProcessing = _processingItems[item.itemId] == true;
    final isSelected = selected[item.itemId] == true;
    final itemBtnText = _getButtonText(item.status, order.orderType);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFE8F0FE) : const Color(0xFFF9F9FC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? const Color(0xFF1E90FF) : const Color(0xFFE8E8EE),
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          if (order.isTableOrder)
            GestureDetector(
              onTap: () => _toggleItemSelection(order.id, item.itemId),
              child: Container(
                width: 22,
                height: 22,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? const Color(0xFF1E90FF)
                      : Colors.transparent,
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF1E90FF)
                        : const Color(0xFFBBBBCC),
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check, size: 13, color: Colors.white)
                    : null,
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                if (item.note.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Note: ${item.note}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF888888),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E).withOpacity(0.08),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'x${item.updateQuantity > 0 ? item.updateQuantity : item.quantity}',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
          ),
          const SizedBox(width: 8),
          _StatusPip(status: item.status),
          if (order.isTableOrder && itemBtnText != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: isProcessing
                  ? null
                  : () => _handleIndividualItemUpdate(order, item),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: isProcessing
                      ? Colors.grey.shade300
                      : _cardColor(order.orderType).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isProcessing
                        ? Colors.grey
                        : _cardColor(order.orderType),
                    width: 1,
                  ),
                ),
                child: isProcessing
                    ? const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.grey,
                        ),
                      )
                    : Text(
                        itemBtnText,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _cardColor(order.orderType),
                        ),
                      ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _toggleItemSelection(String orderId, int itemId) {
    final map = Map<int, bool>.from(_selectedItems[orderId] ?? {});
    map[itemId] = !(map[itemId] ?? false);
    setState(() => _selectedItems[orderId] = map);
  }

  Widget _buildTimeRow(KotOrder order) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          const Icon(
            Icons.access_time_rounded,
            size: 14,
            color: Color(0xFF888888),
          ),
          const SizedBox(width: 4),
          Text(
            _formatTime(order.createdAt),
            style: const TextStyle(fontSize: 12, color: Color(0xFF888888)),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(KotOrder order, List<KotItem> selectedList) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: order.isTableOrder
          ? _buildTableOrderButtons(order, selectedList)
          : _buildNormalOrderButtons(order),
    );
  }

  Widget _buildTableOrderButtons(KotOrder order, List<KotItem> selectedList) {
    String? bulkText;
    String? bulkStatus;

    if (selectedList.isNotEmpty) {
      final hasPending = selectedList.any((i) => i.status == 'pending');
      final hasPreparing = selectedList.any((i) => i.status == 'preparing');
      final hasReady = selectedList.any((i) => i.status == 'ready');
      final hasWaiting = selectedList.any(
        (i) => i.status == 'waiting_for_pickup',
      );

      if (hasPending) {
        bulkText = 'Accept Selected';
        bulkStatus = 'BEING_PREPARED';
      } else if (hasPreparing) {
        bulkText = 'Mark Ready';
        bulkStatus = 'ORDER_IS_READY';
      } else if (hasReady) {
        bulkText = 'Mark Dispatched';
        bulkStatus = 'WAITING_FOR_PICKUP';
      } else if (hasWaiting) {
        bulkText = 'Mark Delivered';
        bulkStatus = 'DELIVERED';
      }
    }

    return Column(
      children: [
        if (bulkText != null && bulkStatus != null)
          _ActionButton(
            label: '$bulkText (${selectedList.length})',
            color: _cardColor(order.orderType),
            onTap: () =>
                _handleSelectedItemsUpdate(order, bulkStatus!, selectedList),
          ),
        if (order.status == 'pending') ...[
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  label: 'Accept Selected',
                  color: _cardColor(order.orderType),
                  onTap: () {
                    if (selectedList.isEmpty) {
                      _showToast(
                        'Select items to accept',
                        type: _ToastType.warning,
                      );
                      return;
                    }
                    _handleSelectedItemsUpdate(
                      order,
                      'BEING_PREPARED',
                      selectedList,
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ActionButton(
                  label: 'Decline',
                  color: const Color(0xFFE53935),
                  onTap: () => setState(() => _declineDialogOrderId = order.id),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildNormalOrderButtons(KotOrder order) {
    final isDineOrTakeaway =
        order.orderType == 'DINE_IN' || order.orderType == 'TAKEAWAY';

    if (order.status == 'pending') {
      return Row(
        children: [
          Expanded(
            child: _ActionButton(
              label: 'Accept',
              color: _cardColor(order.orderType),
              onTap: () => _acceptNormalOrder(order),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _ActionButton(
              label: 'Decline',
              color: const Color(0xFFE53935),
              onTap: () => setState(() => _declineDialogOrderId = order.id),
            ),
          ),
        ],
      );
    }

    final btnText = _getButtonText(order.status, order.orderType);
    if (btnText == null) return const SizedBox.shrink();

    return _ActionButton(
      label: btnText,
      color: _cardColor(order.orderType),
      onTap: () {
        if (isDineOrTakeaway) {
          _updateNormalOrderStatus(order);
        } else {
          _updateNormalOrderStatus(order);
        }
      },
      fullWidth: true,
    );
  }

  Widget _buildDeclineOverlay() {
    return GestureDetector(
      onTap: () => setState(() {
        _declineDialogOrderId = null;
        _selectedReason = '';
        _declineNote = '';
      }),
      child: Container(
        color: Colors.black54,
        child: Center(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDeclineHeader(),
                  _buildDeclineBody(),
                  _buildDeclineFooter(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeclineHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Reason for Decline',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: Color(0xFF1A1A2E),
            ),
          ),
          GestureDetector(
            onTap: () => setState(() {
              _declineDialogOrderId = null;
              _selectedReason = '';
              _declineNote = '';
            }),
            child: const Icon(Icons.close_rounded, color: Color(0xFF888888)),
          ),
        ],
      ),
    );
  }

  Widget _buildDeclineBody() {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _declineReasons.map((r) {
              final isActive = _selectedReason == r;
              return GestureDetector(
                onTap: () => setState(() => _selectedReason = r),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isActive ? const Color(0xFFE53935) : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isActive
                          ? const Color(0xFFE53935)
                          : const Color(0xFFDDDDDD),
                    ),
                  ),
                  child: Text(
                    r,
                    style: TextStyle(
                      color: isActive ? Colors.white : const Color(0xFF444444),
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          const Text(
            'Additional notes',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: Color(0xFF555555),
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            maxLines: 3,
            onChanged: (v) => _declineNote = v,
            decoration: InputDecoration(
              hintText: 'Optional notes...',
              hintStyle: const TextStyle(color: Color(0xFFAAAAAA)),
              filled: true,
              fillColor: const Color(0xFFF5F5F5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeclineFooter() {
    final canConfirm = _selectedReason.isNotEmpty || _declineNote.isNotEmpty;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => setState(() {
                _declineDialogOrderId = null;
                _selectedReason = '';
                _declineNote = '';
              }),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF444444),
                side: const BorderSide(color: Color(0xFFCCCCCC)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Cancel'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: canConfirm ? _handleDecline : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE53935),
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade300,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Confirm Decline',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Toast ─────────────────────────────────────────────────────────────────

  Widget _buildToast(_ToastInfo toast) {
    final colors = {
      _ToastType.success: (const Color(0xFF2E7D32), const Color(0xFFE8F5E9)),
      _ToastType.error: (const Color(0xFFC62828), const Color(0xFFFFEBEE)),
      _ToastType.info: (const Color(0xFF1565C0), const Color(0xFFE3F2FD)),
      _ToastType.warning: (const Color(0xFFE65100), const Color(0xFFFFF3E0)),
    };
    final (fg, bg) = colors[toast.type]!;

    return Positioned(
      top: 16,
      left: 16,
      right: 16,
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: fg.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(_toastIcon(toast.type), color: fg, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      toast.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: fg,
                        fontSize: 14,
                      ),
                    ),
                    if (toast.desc.isNotEmpty)
                      Text(
                        toast.desc,
                        style: TextStyle(
                          color: fg.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _toastIcon(_ToastType type) {
    switch (type) {
      case _ToastType.success:
        return Icons.check_circle_rounded;
      case _ToastType.error:
        return Icons.error_rounded;
      case _ToastType.info:
        return Icons.info_rounded;
      case _ToastType.warning:
        return Icons.warning_rounded;
    }
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.color,
    required this.onTap,
    this.fullWidth = false,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _SourceBadge extends StatelessWidget {
  const _SourceBadge({required this.isOnline});

  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    final color = isOnline ? const Color(0xFF28A745) : const Color(0xFFE66D33);
    final label = isOnline ? '🟢 Online' : '🟡 Walk-in';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  Color get _color {
    switch (status) {
      case 'pending':
        return const Color(0xFFFF9800);
      case 'preparing':
        return const Color(0xFF2196F3);
      case 'ready':
        return const Color(0xFF4CAF50);
      case 'waiting_for_pickup':
        return const Color(0xFF9C27B0);
      default:
        return Colors.grey;
    }
  }

  String get _label {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'preparing':
        return 'Preparing';
      case 'ready':
        return 'Ready';
      case 'waiting_for_pickup':
        return 'Dispatched';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _color.withOpacity(0.3)),
      ),
      child: Text(
        _label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: _color,
        ),
      ),
    );
  }
}

class _StatusPip extends StatelessWidget {
  const _StatusPip({required this.status});

  final String status;

  Color get _color {
    switch (status) {
      case 'pending':
        return const Color(0xFFFF9800);
      case 'preparing':
        return const Color(0xFF2196F3);
      case 'ready':
        return const Color(0xFF4CAF50);
      case 'waiting_for_pickup':
        return const Color(0xFF9C27B0);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: _color, shape: BoxShape.circle),
    );
  }
}

enum _ToastType { success, error, info, warning }

class _ToastInfo {
  final String title;
  final String desc;
  final _ToastType type;
  _ToastInfo({required this.title, this.desc = '', required this.type});
}
