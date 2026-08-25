import 'dart:async';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:audioplayers/audioplayers.dart';
import '../API/Apiclient.dart';
import '../Api/food_authservice.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import '../widgets_helper/Home_screen_1.dart';
import 'Delivery_management.dart';

// ─── Design Tokens ─────────────────────────────────────────────────────────────
class _O {
  static const bg = Color(0xFFF7F8FC);
  static const white = Color(0xFFFFFFFF);
  static const border = Color(0xFFEEEFF5);
  static const accent = Color(0xFFE66D33);
  static const accentDark = Color(0xFFE66D33);
  static const accentLight = Color(0xFFF5E8FA);
  static const blue = Color(0xFFE66D33);
  static const blueLight = Color(0xFFDBEAFE);
  static const green = Color(0xFF10B981);
  static const greenLight = Color(0xFFFFFFFF);
  static const amber = Color(0xFFF59E0B);
  static const amberLight = Color(0xFFFEF3C7);
  static const red = Color(0xFFEF4444);
  static const redLight = Color(0xFFFFFFFF);
  static const purple = Color(0xFF8B5CF6);
  static const purpleLight = Color(0xFFEDE9FE);
  static const teal = Color(0xFF14B8A6);
  static const tealLight = Color(0xFFCCFBF1);
  static const orange = Color(0xFFF97316);
  static const orangeLight = Color(0xFFFFEDD5);
  static const text1 = Color(0xFF111827);
  static const text2 = Color(0xFF6B7280);
  static const text3 = Color(0xFFB0B3C1);
  static const shadow = Color(0x0A000000);
  static const shadowMd = Color(0x14000000);
  static const infBlue = Color(0xFF3B82F6);
  static const infBlueLt = Color(0xFFDBEAFE);
  static const cateringColor = Color(0xFFD97706);
  static const cateringLight = Color(0xFFFEF3C7);
}

// ─── Normalise helper ─────────────────────────────────────────────────────────
Map<String, dynamic> _normaliseOrder(Map<String, dynamic> raw) {
  final type = (raw['orderType'] ?? '').toString().toUpperCase();
  if (type == 'CATERING') return raw;
  if (type != 'TABLE_DINE_IN') return raw;
  if (raw['cartItems'] == null && raw['order'] != null) return raw;
  final o = Map<String, dynamic>.from(raw);
  if (o['orderId'] == null && o['cartId'] != null) o['orderId'] = o['cartId'];
  final cartItems = (o['cartItems'] as List? ?? []);
  o['order'] ??= cartItems
      .map(
        (ci) => <String, dynamic>{
          'dishName': ci['dishName'],
          'quantity': ci['quantity'],
          'totalPrice': ci['totalPrice'],
          'dishId': ci['dishId'],
          'note': ci['note'],
          'orderStatus': ci['orderStatus'],
        },
      )
      .toList();
  if ((o['userName'] == null || o['userName'].toString().isEmpty) &&
      o['name'] != null) {
    o['userName'] = o['name'];
  }
  o['grandTotal'] ??= o['total'] ?? 0.0;
  return o;
}

// ─── Main Widget ──────────────────────────────────────────────────────────────
class Order_management extends StatefulWidget {
  const Order_management({super.key});
  @override
  State<Order_management> createState() => _OrderManagementState();
}

class _OrderManagementState extends State<Order_management> {
  final List<String> _tabTitles = ['KOT', 'History'];
  int _selectedTab = 0;
  List<dynamic> _orders = [];
  bool _isLoading = true;
  final AudioPlayer _audioPlayer = AudioPlayer();
  Set<String> _pendingOrderIds = {};
  Set<String> _ringingOrderIds = {};
  bool _isSoundEnabled = true;
  Timer? _orderPollingTimer;
  bool _isPlaying = false;
  int _vendorId = 0;
  bool _isVendorLoading = true;
  bool _printSelected = true;
  bool _cateringIsLoading = false;
  List<dynamic> _cateringOrders = [];
  String _cateringCurrentView = 'orders';
  bool _showControls = false;

  @override
  void initState() {
    super.initState();
    _initializeSound();
    _loadVendorId();
  }

  Future<void> _initializeSound() async {
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
  }

  Future<void> _loadVendorId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      int vid = prefs.getInt('vendorId') ?? prefs.getInt('VendorId') ?? 1;
      setState(() {
        _vendorId = vid;
        _isVendorLoading = false;
      });
      _fetchOrders();
      _startOrderPolling();
    } catch (e) {
      setState(() {
        _vendorId = 1;
        _isVendorLoading = false;
      });
      _fetchOrders();
      _startOrderPolling();
    }
  }

  void _startOrderPolling() {
    _orderPollingTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted && _vendorId > 0) _fetchOrdersInBackground();
    });
  }

  Future<List<Map<String, dynamic>>> fetchTableDineInOrders() async {
    try {
      if (_vendorId == 0) return [];
      final endpoint =
          'api/cart/get/ordertype=TABLE_DINE_IN/$_vendorId/PENDING';
      final response = await ApiClient.get(endpoint, service: 'food');
      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        List<dynamic> rawOrders = [];
        if (data is List) {
          rawOrders = data;
        } else if (data is Map<String, dynamic>) {
          rawOrders =
              data['data'] as List? ??
              data['content'] as List? ??
              data['orders'] as List? ??
              data['items'] as List? ??
              [];
          if (rawOrders.isEmpty && data.containsKey('cartId'))
            rawOrders = [data];
        }
        final normalizedOrders = rawOrders.map((order) {
          if (order is! Map<String, dynamic>) return <String, dynamic>{};
          final normalized = Map<String, dynamic>.from(order);
          normalized['orderType'] = 'TABLE_DINE_IN';
          normalized['status'] = 'PENDING';
          normalized['vendorId'] = _vendorId;
          if (normalized['orderId'] == null && normalized['cartId'] != null) {
            normalized['orderId'] = normalized['cartId'];
          }
          normalized['grandTotal'] =
              normalized['grandTotal'] ??
              normalized['total'] ??
              _calculateGrandTotal(normalized);
          normalized['orderDateAndTime'] =
              normalized['createdAt'] ??
              normalized['orderDateTime'] ??
              normalized['updatedAt'];
          if ((normalized['userName'] == null ||
                  normalized['userName'].toString().isEmpty) &&
              normalized['name'] != null) {
            normalized['userName'] = normalized['name'];
          }
          if (normalized['cartItems'] != null && normalized['order'] == null) {
            final cartItems = normalized['cartItems'] as List? ?? [];
            normalized['order'] = cartItems.map((item) {
              final itemMap = item as Map<String, dynamic>;
              return {
                'dishName': itemMap['dishName'] ?? 'Unknown Item',
                'quantity': itemMap['quantity'] ?? 1,
                'totalPrice': itemMap['totalPrice'] ?? itemMap['price'] ?? 0,
                'dishId': itemMap['dishId'],
                'note': itemMap['note'],
                'orderStatus': itemMap['orderStatus'],
              };
            }).toList();
          }
          return normalized;
        }).toList();
        return normalizedOrders;
      }
      return [];
    } catch (e) {
      debugPrint('[TABLE_DINE_IN] Error: $e');
      return [];
    }
  }

  double _calculateGrandTotal(Map<String, dynamic> order) {
    final cartItems = order['cartItems'] as List? ?? [];
    double subtotal = 0.0;
    for (var item in cartItems) {
      final itemMap = item as Map<String, dynamic>;
      subtotal += (itemMap['totalPrice'] ?? 0.0) as double;
    }
    return (subtotal +
            (order['gstTotal'] ?? 0.0) +
            (order['platformCharges'] ?? 0.0) +
            (order['packingTotal'] ?? 0.0) +
            (order['serviceCharges'] ?? 0.0))
        .toDouble();
  }

  Future<List<dynamic>> _fetchPendingCateringOrders() async {
    try {
      if (_vendorId == 0) return [];
      final response = await ApiClient.get(
        'api/vendor/getall/$_vendorId',
        service: 'catering',
      );
      if (response.statusCode != 200) return [];
      final dynamic resp = json.decode(response.body);
      List<dynamic> all = resp is List
          ? resp
          : resp is Map<String, dynamic>
          ? (resp['data'] as List? ?? resp['orders'] as List? ?? [])
          : [];
      return all
          .where(
            (o) =>
                o is Map &&
                (o['orderStatus'] ?? '').toString().toUpperCase() == 'PENDING',
          )
          .map((o) {
            final m = Map<String, dynamic>.from(o as Map);
            m['orderType'] = 'CATERING';
            m['status'] = 'PENDING';
            m['vendorId'] ??= _vendorId;
            m['orderDateAndTime'] ??= m['orderDateTime'];
            final orderItems = m['orderItems'] as List? ?? [];
            m['order'] = orderItems.map((item) {
              final im = Map<String, dynamic>.from(item as Map);
              final price = (im['packagePrice'] ?? 0) as num;
              final qty = (im['quantity'] ?? 1) as num;
              return <String, dynamic>{
                'dishName': im['packageName'] ?? im['itemsName'] ?? 'Item',
                'quantity': qty,
                'totalPrice': price * qty,
              };
            }).toList();
            m['grandTotal'] ??= m['total'] ?? 0.0;
            return m;
          })
          .toList();
    } catch (e) {
      debugPrint('[CATERING PENDING] fetch error: $e');
      return [];
    }
  }

  List<dynamic> _mergeOrders(List<dynamic> standard, List<dynamic> extra) {
    final seen = <String>{};
    final merged = <dynamic>[];
    for (final order in [...standard, ...extra]) {
      final id = order['orderId'] ?? order['cartId'];
      final orderType = order['orderType'] ?? '';
      final key = '${orderType}_$id';
      if (id != null && seen.add(key)) merged.add(order);
    }
    return merged;
  }

  Future<void> _fetchOrdersInBackground() async {
    if (_vendorId == 0) return;
    try {
      final standardRaw = await food_authservice.getAllOrders();
      final tableDineIn = await fetchTableDineInOrders();
      final cateringPending = await _fetchPendingCateringOrders();
      final standard = (standardRaw as List).where((o) {
        final t = (o['orderType'] ?? '').toString().toUpperCase();
        return ['DINE_IN', 'DELIVERY', 'TAKEAWAY'].contains(t);
      }).toList();
      final merged = _mergeOrders(
        _mergeOrders(standard, tableDineIn),
        cateringPending,
      );
      merged.sort((a, b) {
        final dateA = a['createdAt'] ?? a['orderDateAndTime'] ?? '';
        final dateB = b['createdAt'] ?? b['orderDateAndTime'] ?? '';
        return dateB.toString().compareTo(dateA.toString());
      });
      _checkForNewPendingOrders(merged);
      if (mounted) setState(() => _orders = merged);
    } catch (_) {}
  }

  Future<void> _fetchOrders() async {
    if (_vendorId == 0) return;
    setState(() => _isLoading = true);
    try {
      final standardRaw = await food_authservice.getAllOrders();
      final tableDineIn = await fetchTableDineInOrders();
      final cateringPending = await _fetchPendingCateringOrders();
      final standard = (standardRaw as List).where((o) {
        final t = (o['orderType'] ?? '').toString().toUpperCase();
        return ['DINE_IN', 'DELIVERY', 'TAKEAWAY'].contains(t);
      }).toList();
      final merged = _mergeOrders(
        _mergeOrders(standard, tableDineIn),
        cateringPending,
      );
      merged.sort((a, b) {
        final dateA = a['createdAt'] ?? a['orderDateAndTime'] ?? '';
        final dateB = b['createdAt'] ?? b['orderDateAndTime'] ?? '';
        return dateB.toString().compareTo(dateA.toString());
      });
      setState(() => _orders = merged);
      _checkForNewPendingOrders(merged);
    } catch (e) {
      debugPrint('Error fetching orders: $e');
      // _snack('Failed to load orders', _O.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _checkForNewPendingOrders(List<dynamic> current) {
    final pendingIds = current
        .map((o) => _normaliseOrder(o as Map<String, dynamic>))
        .where((o) => (o['status'] ?? '').toString().toUpperCase() == 'PENDING')
        .map((o) => (o['orderId'] ?? o['cartId'] ?? '').toString())
        .where((id) => id.isNotEmpty)
        .toSet();
    for (var id in pendingIds) {
      if (!_ringingOrderIds.contains(id)) {
        _pendingOrderIds.add(id);
        _ringingOrderIds.add(id);
        if (!_isPlaying) _startRinging(id);
      }
    }
    for (var id in _ringingOrderIds.difference(pendingIds)) {
      _pendingOrderIds.remove(id);
      _ringingOrderIds.remove(id);
    }
    if (_pendingOrderIds.isEmpty && _isPlaying) _stopAllRinging();
  }

  Future<void> _startRinging(String orderId) async {
    if (!_isSoundEnabled || _isPlaying) return;
    try {
      _isPlaying = true;
      await _audioPlayer.play(AssetSource('school-bel93.mp3'));
    } catch (_) {
      _isPlaying = false;
    }
  }

  Future<void> _stopAllRinging() async {
    if (_isPlaying) {
      await _audioPlayer.stop();
      _isPlaying = false;
    }
  }

  void _stopRingingForOrder(String orderId) {
    if (_pendingOrderIds.contains(orderId)) {
      _pendingOrderIds.remove(orderId);
      _ringingOrderIds.remove(orderId);
      if (_pendingOrderIds.isEmpty && _isPlaying) _stopAllRinging();
      // _snack('Order #$orderId accepted ✅', _O.green);
    }
  }

  // ─── FIX 1: Remove a single order locally — no full list re-fetch ──────────
  void _removeOrderLocally(dynamic order) {
    setState(() {
      _orders.removeWhere((o) {
        final id = o['orderId'] ?? o['cartId'];
        final targetId = order['orderId'] ?? order['cartId'];
        return id.toString() == targetId.toString();
      });
    });
  }

  Future<void> _fetchCateringOrders() async {
    setState(() => _cateringIsLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      int vendorId =
          prefs.getInt('vendorId') ?? prefs.getInt('VendorId') ?? _vendorId;
      if (vendorId == 0) {
        setState(() => _cateringIsLoading = false);
        return;
      }
      final response = await ApiClient.get(
        'api/vendor/getall/$vendorId',
        service: 'catering',
      );
      if (response.statusCode == 200) {
        final dynamic resp = json.decode(response.body);
        List<dynamic> ordersData = resp is List
            ? resp
            : resp is Map<String, dynamic>
            ? (resp['data'] as List? ?? resp['orders'] as List? ?? [resp])
            : [];
        final processed = ordersData.map((o) {
          if (o is! Map<String, dynamic>) return o;
          final m = <String, dynamic>{};
          o.forEach((k, v) {
            if ((k == 'orderId' || k == 'vendorId') && v is String)
              m[k] = int.tryParse(v) ?? 0;
            else if ([
                  'total',
                  'subtotal',
                  'deliveryFee',
                  'platformFeeAmount',
                  'sgst',
                  'cgst',
                ].contains(k) &&
                v is String)
              m[k] = double.tryParse(v) ?? 0.0;
            else
              m[k] = v;
          });
          return m;
        }).toList();
        setState(() {
          _cateringOrders = processed;
          _cateringIsLoading = false;
        });
      } else {
        setState(() => _cateringIsLoading = false);
        _snack('Failed to fetch catering orders', _O.red);
      }
    } catch (e) {
      setState(() => _cateringIsLoading = false);
      // _snack('Error loading catering orders', _O.red);
    }
  }

  Future<void> _updateCateringOrderStatus(int orderId, String newStatus) async {
    setState(() => _cateringIsLoading = true);
    try {
      if (_vendorId == 0) {
        setState(() => _cateringIsLoading = false);
        return;
      }
      final backendStatus = _mapToBackendStatus(newStatus);
      final uri = Uri.parse('api/vendor/orders/status').replace(
        queryParameters: {
          'orderId': orderId.toString(),
          'orderStatus': backendStatus,
          if (newStatus == 'DECLINED' || newStatus == 'CANCELLED')
            'cancelReason': 'Order declined by vendor',
        },
      );
      final response = await ApiClient.put(
        uri.toString().replaceFirst('catering/', ''),
        null,
        service: 'catering',
      );
      setState(() => _cateringIsLoading = false);
      if (response.statusCode == 200) {
        // _snack(
        //   newStatus == 'ACCEPTED'
        //       ? '✅ Order Accepted!'
        //       : 'Order status updated',
        //   newStatus == 'ACCEPTED' ? _O.green : _O.amber,
        // );
        await _fetchCateringOrders();
        await _fetchOrders();
      } else {
        // _snack('Failed to update order status', _O.red);
      }
    } catch (e) {
      setState(() => _cateringIsLoading = false);
      // _snack('Error updating order status', _O.red);
    }
  }

  String _mapToBackendStatus(String s) {
    switch (s) {
      case 'ACCEPTED':
        return 'CONFIRMED';
      case 'DECLINED':
        return 'CANCELLED';
      default:
        return s;
    }
  }

  String? _getTokenFromPrefs(SharedPreferences prefs) {
    for (var key in [
      'authToken',
      'token',
      'accessToken',
      'jwtToken',
      'bearerToken',
      'userToken',
    ]) {
      final v = prefs.get(key);
      if (v != null) return v.toString();
    }
    return null;
  }

  void _snack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _navigateBackToHome() {
    if (Navigator.canPop(context))
      Navigator.pop(context);
    else
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeWrapper()),
      );
  }

  @override
  Widget build(BuildContext context) {
    if (_isVendorLoading) {
      return Scaffold(
        backgroundColor: _O.bg,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: _O.accent, strokeWidth: 2),
              SizedBox(height: 16.h),
              Text(
                'Loading...',
                style: TextStyle(color: _O.text2, fontSize: 14.sp),
              ),
            ],
          ),
        ),
      );
    }
    return WillPopScope(
      onWillPop: () async {
        _navigateBackToHome();
        return false;
      },
      child: Scaffold(
        backgroundColor: _O.bg,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),

              // ── DROP-DOWN CONTROLS PANEL ──────────────────────────
              // if (_selectedTab == 0)
              //   AnimatedContainer(
              //     duration: const Duration(milliseconds: 220),
              //     curve: Curves.easeInOut,
              //     height: _showControls ? 56.h : 0,
              //     color: _O.white,
              //     child: AnimatedOpacity(
              //       duration: const Duration(milliseconds: 180),
              //       opacity: _showControls ? 1.0 : 0.0,
              //       child: Container(
              //         decoration: BoxDecoration(
              //           color: _O.white,
              //           border: Border(bottom: BorderSide(color: _O.border)),
              //         ),
              //         padding: EdgeInsets.symmetric(
              //           horizontal: 16.w,
              //           vertical: 10.h,
              //         ),
              //         child: Row(
              //           children: [
              //             // ── Print toggle ──────────────────────────
              //             GestureDetector(
              //               onTap: () {
              //                 setState(() => _printSelected = !_printSelected);
              //                 _snack(
              //                   _printSelected
              //                       ? 'Printing Enabled ✅'
              //                       : 'Printing Disabled ❌',
              //                   _printSelected ? _O.infBlue : _O.text2,
              //                 );
              //               },
              //               child: Container(
              //                 padding: EdgeInsets.symmetric(
              //                   horizontal: 12.w,
              //                   vertical: 7.h,
              //                 ),
              //                 decoration: BoxDecoration(
              //                   color: _printSelected ? _O.infBlueLt : _O.bg,
              //                   borderRadius: BorderRadius.circular(10.r),
              //                   border: Border.all(
              //                     color: _printSelected
              //                         ? _O.infBlue.withOpacity(0.3)
              //                         : _O.border,
              //                   ),
              //                 ),
              //                 child: Row(
              //                   mainAxisSize: MainAxisSize.min,
              //                   children: [
              //                     Icon(
              //                       Icons.print_rounded,
              //                       color: _printSelected
              //                           ? _O.infBlue
              //                           : _O.text3,
              //                       size: 16.sp,
              //                     ),
              //                     SizedBox(width: 6.w),
              //                     Text(
              //                       'Print',
              //                       style: TextStyle(
              //                         fontSize: 12.sp,
              //                         fontWeight: FontWeight.w600,
              //                         color: _printSelected
              //                             ? _O.infBlue
              //                             : _O.text3,
              //                       ),
              //                     ),
              //                     SizedBox(width: 6.w),
              //                     Container(
              //                       padding: EdgeInsets.symmetric(
              //                         horizontal: 6.w,
              //                         vertical: 2.h,
              //                       ),
              //                       decoration: BoxDecoration(
              //                         color: _printSelected
              //                             ? _O.infBlue
              //                             : _O.text3,
              //                         borderRadius: BorderRadius.circular(4.r),
              //                       ),
              //                       child: Text(
              //                         _printSelected ? 'ON' : 'OFF',
              //                         style: TextStyle(
              //                           fontSize: 9.sp,
              //                           fontWeight: FontWeight.w800,
              //                           color: Colors.white,
              //                         ),
              //                       ),
              //                     ),
              //                   ],
              //                 ),
              //               ),
              //             ),
              //
              //             SizedBox(width: 10.w),
              //
              //             // ── Sound toggle ──────────────────────────
              //             GestureDetector(
              //               onTap: () {
              //                 setState(
              //                   () => _isSoundEnabled = !_isSoundEnabled,
              //                 );
              //                 if (!_isSoundEnabled) _stopAllRinging();
              //               },
              //               child: Container(
              //                 padding: EdgeInsets.symmetric(
              //                   horizontal: 12.w,
              //                   vertical: 7.h,
              //                 ),
              //                 decoration: BoxDecoration(
              //                   color: _isSoundEnabled ? _O.accentLight : _O.bg,
              //                   borderRadius: BorderRadius.circular(10.r),
              //                   border: Border.all(
              //                     color: _isSoundEnabled
              //                         ? _O.accent.withOpacity(0.3)
              //                         : _O.border,
              //                   ),
              //                 ),
              //                 child: Row(
              //                   mainAxisSize: MainAxisSize.min,
              //                   children: [
              //                     Icon(
              //                       _isSoundEnabled
              //                           ? Icons.volume_up_rounded
              //                           : Icons.volume_off_rounded,
              //                       color: _isSoundEnabled
              //                           ? _O.accent
              //                           : _O.text3,
              //                       size: 16.sp,
              //                     ),
              //                     SizedBox(width: 6.w),
              //                     Text(
              //                       'Sound',
              //                       style: TextStyle(
              //                         fontSize: 12.sp,
              //                         fontWeight: FontWeight.w600,
              //                         color: _isSoundEnabled
              //                             ? _O.accent
              //                             : _O.text3,
              //                       ),
              //                     ),
              //                     SizedBox(width: 6.w),
              //                     Container(
              //                       padding: EdgeInsets.symmetric(
              //                         horizontal: 6.w,
              //                         vertical: 2.h,
              //                       ),
              //                       decoration: BoxDecoration(
              //                         color: _isSoundEnabled
              //                             ? _O.accent
              //                             : _O.text3,
              //                         borderRadius: BorderRadius.circular(4.r),
              //                       ),
              //                       child: Text(
              //                         _isSoundEnabled ? 'ON' : 'OFF',
              //                         style: TextStyle(
              //                           fontSize: 9.sp,
              //                           fontWeight: FontWeight.w800,
              //                           color: Colors.white,
              //                         ),
              //                       ),
              //                     ),
              //                   ],
              //                 ),
              //               ),
              //             ),
              //
              //             const Spacer(),
              //
              //             // ── Small hint text ───────────────────────
              //             Text(
              //               'Tap to toggle',
              //               style: TextStyle(fontSize: 10.sp, color: _O.text3),
              //             ),
              //           ],
              //         ),
              //       ),
              //     ),
              //   ),

              // ─────────────────────────────────────────────────────
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 10.h),
      decoration: const BoxDecoration(
        color: _O.white,
        border: Border(bottom: BorderSide(color: _O.border)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _navigateBackToHome,
            child: Container(
              width: 36.r,
              height: 36.r,
              decoration: BoxDecoration(
                color: _O.bg,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: _O.border),
              ),
              child: Icon(
                Icons.arrow_back_ios_rounded,
                color: _O.text1,
                size: 15.sp,
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: List.generate(_tabTitles.length, (i) {
                  final isActive = _selectedTab == i;
                  final hasBadge = i == 0 && _pendingOrderIds.isNotEmpty;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedTab = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: EdgeInsets.only(right: 8.w),
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 7.h,
                      ),
                      decoration: BoxDecoration(
                        color: isActive
                            ? Colors.green
                            : const Color(0xFFE66D33),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (hasBadge) ...[
                            Container(
                              width: 7.r,
                              height: 7.r,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 5.w),
                          ],
                          Text(
                            _tabTitles[i],
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          SizedBox(width: 10.w),
          if (_selectedTab == 0)
            GestureDetector(
              onTap: () => setState(() => _showControls = !_showControls),
              child: Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: _showControls ? _O.accentLight : _O.bg,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: _showControls
                        ? _O.accent.withOpacity(0.3)
                        : _O.border,
                  ),
                ),
                child: Icon(
                  _showControls
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.more_vert_rounded,
                  color: _showControls ? _O.accent : _O.text2,
                  size: 18.sp,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return IndexedStack(
      index: _selectedTab,
      children: [
        // AllOrdersTab(
        //   orders: _orders,
        //   isLoading: _isLoading,
        //   onRefresh: _fetchOrders,
        //   shouldPrint: _printSelected,
        //   onOrderAccepted: _stopRingingForOrder,
        //   onOrderRemoved: _removeOrderLocally,
        //   isRinging: _pendingOrderIds.isNotEmpty,
        //   vendorId: _vendorId,
        // ),
        ProcessingTab(vendorId: _vendorId),
        HistoryTab(vendorId: _vendorId),
        // const DineOut(),
      ],
    );
  }

  @override
  void dispose() {
    _orderPollingTimer?.cancel();
    _stopAllRinging();
    _audioPlayer.dispose();
    super.dispose();
  }
}

// ─── AllOrdersTab ─────────────────────────────────────────────────────────────
class AllOrdersTab extends StatefulWidget {
  final List<dynamic> orders;
  final bool isLoading;
  final VoidCallback onRefresh;
  final bool shouldPrint;
  final Function(String) onOrderAccepted;
  // ─── FIX 1: new callback — removes single order without full list rebuild ──
  final Function(dynamic) onOrderRemoved;
  final bool isRinging;
  final int vendorId;

  const AllOrdersTab({
    super.key,
    required this.orders,
    required this.isLoading,
    required this.onRefresh,
    required this.shouldPrint,
    required this.onOrderAccepted,
    required this.onOrderRemoved,
    required this.isRinging,
    required this.vendorId,
  });

  @override
  State<AllOrdersTab> createState() => _AllOrdersTabState();
}

// ─── FIX 3: AutomaticKeepAliveClientMixin preserves scroll on tab switch ──────
class _AllOrdersTabState extends State<AllOrdersTab>
    with AutomaticKeepAliveClientMixin {
  bool isConnecting = false;
  static const String kDefaultPrinterKey = 'default_printer_mac';

  @override
  bool get wantKeepAlive => true;

  Future<void> saveDefaultPrinter(String mac) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(kDefaultPrinterKey, mac);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (widget.isLoading) return _buildLoadingState();

    final normalisedOrders = widget.orders
        .map((o) => _normaliseOrder(o as Map<String, dynamic>))
        .toList();
    final pendingOrders =
        normalisedOrders
            .where(
              (o) => (o['status'] ?? '').toString().toUpperCase() == 'PENDING',
            )
            .toList()
          ..sort((a, b) {
            final idA = (a['orderId'] ?? a['cartId'] ?? 0) as num;
            final idB = (b['orderId'] ?? b['cartId'] ?? 0) as num;
            return idB.compareTo(idA);
          });

    if (pendingOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72.r,
              height: 72.r,
              decoration: BoxDecoration(
                color: _O.bg,
                shape: BoxShape.circle,
                border: Border.all(color: _O.border),
              ),
              child: Icon(
                Icons.shopping_bag_outlined,
                size: 30.sp,
                color: _O.text3,
              ),
            ),
            SizedBox(height: 14.h),
            Text(
              'No Pending Orders',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: _O.text1,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'New orders will appear here',
              style: TextStyle(fontSize: 12.sp, color: _O.text2),
            ),
            SizedBox(height: 20.h),
            GestureDetector(
              onTap: widget.onRefresh,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: _O.accentLight,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: _O.accent.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh_rounded, color: _O.accent, size: 16.sp),
                    SizedBox(width: 6.w),
                    Text(
                      'Refresh',
                      style: TextStyle(
                        color: _O.accent,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: _O.accent,
      onRefresh: () async => widget.onRefresh(),
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 24.h),
        itemCount: pendingOrders.length,
        itemBuilder: (context, index) =>
            _buildOrderCard(pendingOrders[index], index),
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> rawOrder, int index) {
    final order = _normaliseOrder(rawOrder);
    final items = order['order'] as List? ?? [];
    final dtRaw =
        order['orderDateAndTime'] ??
        order['createdAt'] ??
        order['orderDateTime'] ??
        '';
    final time = _fmtDt(dtRaw as String? ?? '');
    final isRinging = widget.isRinging;
    final orderType = (order['orderType'] as String? ?? '').toUpperCase();
    final isCatering = orderType == 'CATERING';

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: _O.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isCatering
              ? _O.cateringColor.withOpacity(0.4)
              : isRinging
              ? _O.red.withOpacity(0.4)
              : _O.border,
          width: (isCatering || isRinging) ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isCatering
                ? _O.cateringColor.withOpacity(0.08)
                : isRinging
                ? _O.red.withOpacity(0.08)
                : _O.shadow,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Card Header ─────────────────────────────────────────────────────
          Container(
            padding: EdgeInsets.all(14.r),
            decoration: BoxDecoration(
              color: isCatering
                  ? _O.cateringColor.withOpacity(0.07)
                  : isRinging
                  ? _O.red.withOpacity(0.06)
                  : _O.bg,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order #${order['orderId']}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w800,
                          color: _O.text1,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Wrap(
                        spacing: 6.w,
                        runSpacing: 4.h,
                        children: [
                          _orderTypeBadge(orderType),
                          if (orderType == 'TABLE_DINE_IN' &&
                              (order['tableCode'] ?? '').toString().isNotEmpty)
                            _badge(
                              'Table: ${order['tableCode']}',
                              _O.amber,
                              _O.amberLight,
                            ),
                          if (isCatering &&
                              (order['eventType'] ?? '').toString().isNotEmpty)
                            _badge(
                              order['eventType'].toString(),
                              _O.purple,
                              _O.purpleLight,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      time['date']!,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: _O.text2,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      time['time']!,
                      style: TextStyle(fontSize: 11.sp, color: _O.text2),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // ── Card Body ───────────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if ((order['userName'] as String?)?.isNotEmpty == true) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline_rounded,
                        size: 13.sp,
                        color: _O.text3,
                      ),
                      SizedBox(width: 5.w),
                      Text(
                        order['userName'].toString(),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: _O.text2,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                ],
                if (isCatering) ...[
                  if ((order['cateringDate'] ?? '').toString().isNotEmpty ||
                      (order['cateringTime'] ?? '').toString().isNotEmpty)
                    Container(
                      margin: EdgeInsets.only(bottom: 8.h),
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 7.h,
                      ),
                      decoration: BoxDecoration(
                        color: _O.greenLight,
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: _O.green.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.event_rounded,
                            size: 14.sp,
                            color: _O.green,
                          ),
                          SizedBox(width: 6.w),
                          if ((order['cateringDate'] ?? '')
                              .toString()
                              .isNotEmpty)
                            Text(
                              'Date: ${_fmtDate(order['cateringDate']?.toString())}',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: _O.green,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          if ((order['cateringDate'] ?? '')
                                  .toString()
                                  .isNotEmpty &&
                              (order['cateringTime'] ?? '')
                                  .toString()
                                  .isNotEmpty)
                            SizedBox(width: 12.w),
                          if ((order['cateringTime'] ?? '')
                              .toString()
                              .isNotEmpty)
                            Text(
                              'Time: ${_fmtTime(order['cateringTime']?.toString())}',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: _O.green,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                    ),
                  if ((order['deliveryAddress'] ?? '')
                      .toString()
                      .isNotEmpty) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          size: 13.sp,
                          color: _O.red,
                        ),
                        SizedBox(width: 5.w),
                        Expanded(
                          child: Text(
                            order['deliveryAddress'].toString(),
                            style: TextStyle(fontSize: 12.sp, color: _O.text2),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                  ],
                ],
                if (orderType == 'TABLE_DINE_IN') ...[
                  Row(
                    children: [
                      Icon(
                        Icons.table_restaurant_rounded,
                        size: 13.sp,
                        color: _O.text3,
                      ),
                      SizedBox(width: 5.w),
                      Text(
                        'Table: ${order['tableCode'] ?? '-'}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: _O.amber,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                ],
                Text(
                  'Items',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: _O.text1,
                  ),
                ),
                SizedBox(height: 8.h),
                ...items.map(
                  (it) => Padding(
                    padding: EdgeInsets.symmetric(vertical: 3.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Row(
                            children: [
                              Container(
                                width: 5.r,
                                height: 5.r,
                                decoration: BoxDecoration(
                                  color: isCatering
                                      ? _O.cateringColor
                                      : _O.accent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Flexible(
                                child: Text(
                                  '${it['dishName']} × ${it['quantity']}',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: _O.text2,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '₹${it['totalPrice']}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: _O.text1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 10.h,
                  ),
                  decoration: BoxDecoration(
                    color: isCatering ? _O.cateringLight : _O.orangeLight,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.local_offer_rounded,
                            color: isCatering ? _O.cateringColor : _O.orange,
                            size: 18.sp,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            'Grand Total',
                            style: TextStyle(
                              color: isCatering ? _O.cateringColor : _O.orange,
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '₹${_calcTotal(items, order)}',
                        style: TextStyle(
                          color: isCatering ? _O.cateringColor : _O.orange,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isCatering &&
                    (order['paymentStatus'] ?? '').toString().isNotEmpty) ...[
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Icon(Icons.payment, size: 13.sp, color: _O.text3),
                      SizedBox(width: 5.w),
                      Text(
                        '${order['paymentMethod'] ?? ''} · ${order['paymentStatus'] ?? ''}',
                        style: TextStyle(fontSize: 11.sp, color: _O.text2),
                      ),
                      if ((order['amountPaid'] ?? 0) > 0) ...[
                        const Spacer(),
                        Text(
                          'Paid: ₹${(order['amountPaid'] as num).toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: _O.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
                SizedBox(height: 12.h),
                // Accept / Decline buttons
                Row(
                  children: [
                    Expanded(
                      child: isConnecting
                          ? Center(
                              child: SizedBox(
                                width: 20.r,
                                height: 20.r,
                                child: CircularProgressIndicator(
                                  color: _O.accent,
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                          : GestureDetector(
                              onTap: () => _handleAccept(order, index),
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 12.h),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [_O.green, Color(0xFF059669)],
                                  ),
                                  borderRadius: BorderRadius.circular(10.r),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _O.green.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.check_rounded,
                                      color: Colors.white,
                                      size: 16.sp,
                                    ),
                                    SizedBox(width: 6.w),
                                    Text(
                                      'Accept',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _handleAction(order, index, 'CANCELLED'),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          decoration: BoxDecoration(
                            color: _O.redLight,
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(color: _O.red.withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.close_rounded,
                                color: _O.red,
                                size: 16.sp,
                              ),
                              SizedBox(width: 6.w),
                              Text(
                                'Decline',
                                style: TextStyle(
                                  color: _O.red,
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 14.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _orderTypeBadge(String type) {
    String label;
    Color color;
    Color bg;
    switch (type) {
      case 'DINE_IN':
        label = 'Dine In';
        color = _O.purple;
        bg = _O.purpleLight;
        break;
      case 'DELIVERY':
        label = 'Delivery';
        color = _O.blue;
        bg = _O.blueLight;
        break;
      case 'TAKEAWAY':
        label = 'Take Away';
        color = _O.teal;
        bg = _O.tealLight;
        break;
      case 'TABLE_DINE_IN':
        label = 'Table Dine In';
        color = _O.purple;
        bg = _O.purpleLight;
        break;
      case 'CATERING':
        label = 'Catering';
        color = _O.cateringColor;
        bg = _O.cateringLight;
        break;
      default:
        label = type.replaceAll('_', ' ');
        color = _O.text2;
        bg = _O.bg;
    }
    return _badge(label, color, bg);
  }

  Widget _badge(String label, Color color, Color bg) => Container(
    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(6.r),
    ),
    child: Text(
      label,
      style: TextStyle(
        fontSize: 10.sp,
        fontWeight: FontWeight.w700,
        color: color,
      ),
    ),
  );

  Future<void> _handleAccept(Map<String, dynamic> order, int index) async {
    setState(() => isConnecting = true);
    try {
      if (widget.shouldPrint) {
        _openPrinterSheet(order, index);
      } else {
        await _handleAction(order, index, 'CONFIRMED');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to accept order: $e'),
          backgroundColor: _O.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() => isConnecting = false);
    }
  }

  void _openPrinterSheet(Map<String, dynamic> order, int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PrinterBottomSheet(
        order: order,
        index: index,
        onPrintComplete: () async =>
            await _handleAction(order, index, 'CONFIRMED'),
        onSetDefault: saveDefaultPrinter,
        onCancelPrint: () async =>
            await _handleAction(order, index, 'CONFIRMED'),
      ),
    );
  }

  Future<void> _handleAction(
    Map<String, dynamic> order,
    int index,
    String status,
  ) async {
    final id = order['orderId'] ?? order['cartId'];
    final orderType = (order['orderType'] ?? '').toString().toUpperCase();
    bool success = false;

    if (orderType == 'CATERING') {
      try {
        final backendStatus = status == 'CONFIRMED' ? 'CONFIRMED' : 'CANCELLED';
        final endpoint = 'api/vendor/orders/status';
        final uri = Uri.parse(endpoint).replace(
          queryParameters: {
            'orderId': id.toString(),
            'orderStatus': backendStatus,
            if (status == 'CANCELLED')
              'cancelReason': 'Order declined by vendor',
          },
        );
        final resp = await ApiClient.put(
          uri.toString().replaceFirst('catering/', ''),
          null,
          service: 'catering',
        );
        success = resp.statusCode == 200;
      } catch (_) {
        success = false;
      }
    } else if (orderType == 'TABLE_DINE_IN') {
      int? itemId;

      if (order['itemId'] != null) {
        itemId = order['itemId'] is int
            ? order['itemId']
            : int.tryParse(order['itemId'].toString());
      } else if (order['cartId'] != null) {
        itemId = order['cartId'] is int
            ? order['cartId']
            : int.tryParse(order['cartId'].toString());
      } else if (order['orderId'] != null) {
        itemId = order['orderId'] is int
            ? order['orderId']
            : int.tryParse(order['orderId'].toString());
      }

      if (itemId == null &&
          order['cartItems'] != null &&
          order['cartItems'] is List &&
          (order['cartItems'] as List).isNotEmpty) {
        final firstItem = (order['cartItems'] as List).first;
        if (firstItem is Map && firstItem['itemId'] != null) {
          itemId = firstItem['itemId'] is int
              ? firstItem['itemId']
              : int.tryParse(firstItem['itemId'].toString());
        }
      }

      if (itemId == null) {
        debugPrint('Could not extract itemId from order: $order');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid order ID format'),
            backgroundColor: _O.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      final apiStatus = status == 'CONFIRMED' ? 'CONFIRMED' : 'CANCELLED';
      debugPrint(
        'Updating TABLE_DINE_IN order with itemId: $itemId, status: $apiStatus',
      );
      success = await food_authservice.updateTableDineInOrderStatus(
        itemId,
        apiStatus,
      );
    } else {
      success = await food_authservice.updateOrderStatus(id, status);
    }

    if (!mounted) return;

    if (success) {
      if (status == 'CONFIRMED') widget.onOrderAccepted(id.toString());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Order #$id ${status == 'CONFIRMED'
                ? 'accepted ✅'
                : status == 'CANCELLED'
                ? 'declined'
                : 'updated'}',
          ),
          backgroundColor: status == 'CONFIRMED' ? _O.green : _O.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      // Remove only this order locally
      widget.onOrderRemoved(order);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update order status'),
          backgroundColor: _O.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String _calcTotal(List items, Map<String, dynamic> order) {
    final gt = order['grandTotal'] ?? order['total'];
    if (gt != null && (gt as num) > 0) return (gt as num).toStringAsFixed(0);
    final sum = items.fold(
      0.0,
      (s, it) => s + ((it['totalPrice'] ?? 0) as num),
    );
    return sum.toStringAsFixed(0);
  }

  DateTime _toIST(String raw) =>
      DateTime.parse(raw).add(const Duration(hours: 5, minutes: 30));

  Map<String, String> _fmtDt(String raw) {
    try {
      final d = _toIST(raw);
      return {
        'date': DateFormat('dd MMM yyyy').format(d),
        'time': DateFormat('hh:mm a').format(d),
      };
    } catch (_) {
      return {'date': 'N/A', 'time': 'N/A'};
    }
  }

  String _fmtDate(String? s) {
    if (s == null || s.isEmpty) return 'Not specified';
    try {
      return DateFormat('dd-MMM-yyyy').format(DateTime.parse(s));
    } catch (_) {
      return s;
    }
  }

  String _fmtTime(String? s) {
    if (s == null || s.isEmpty) return 'Not specified';
    try {
      return DateFormat('h:mm a').format(DateFormat('HH:mm:ss').parse(s));
    } catch (_) {
      try {
        return DateFormat('h:mm a').format(DateFormat('HH:mm').parse(s));
      } catch (_) {
        return s;
      }
    }
  }

  Widget _buildLoadingState() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(color: _O.accent, strokeWidth: 2),
        SizedBox(height: 14.h),
        Text(
          'Loading orders...',
          style: TextStyle(color: _O.text2, fontSize: 13.sp),
        ),
      ],
    ),
  );
}

// ─── ProcessingTab ────────────────────────────────────────────────────────────
class ProcessingTab extends StatefulWidget {
  final int vendorId;
  const ProcessingTab({super.key, required this.vendorId});
  @override
  State<ProcessingTab> createState() => _ProcessingTabState();
}

// ─── FIX 3: AutomaticKeepAliveClientMixin preserves scroll on tab switch ──────
class _ProcessingTabState extends State<ProcessingTab>
    with AutomaticKeepAliveClientMixin {
  List<dynamic> processingOrders = [];
  bool isLoading = true;
  bool isError = false;
  String errorMessage = '';

  @override
  bool get wantKeepAlive => true;

  static const _processingStatuses = [
    'CONFIRMED',
    'BEING_PREPARED',
    'ORDER_IS_READY',
    'WAITING_FOR_PICKUP',
    'PROCESSING',
  ];

  @override
  void initState() {
    super.initState();
    _fetchProcessingOrders();
  }

  Future<List<Map<String, dynamic>>> _fetchTableDineInByStatus(
    String token,
    String status,
  ) async {
    try {
      final endpoint =
          'api/cart/get/ordertype=TABLE_DINE_IN/${widget.vendorId}/$status';
      final response = await ApiClient.get(endpoint, service: 'food');
      if (response.statusCode != 200) return [];
      final dynamic data = json.decode(response.body);
      List<dynamic> raw = [];
      if (data is List) {
        raw = data;
      } else if (data is Map<String, dynamic>) {
        raw =
            (data['data'] as List?) ??
            (data['content'] as List?) ??
            (data['orders'] as List?) ??
            [];
        if (raw.isEmpty && data.containsKey('cartId')) raw = [data];
      }
      return raw.map((o) {
        if (o is! Map<String, dynamic>) return <String, dynamic>{};
        final m = Map<String, dynamic>.from(o);
        m['orderType'] ??= 'TABLE_DINE_IN';
        m['status'] ??= status;
        m['vendorId'] ??= widget.vendorId;
        if (m['orderId'] == null && m['cartId'] != null)
          m['orderId'] = m['cartId'];
        m['grandTotal'] ??= m['total'] ?? 0.0;
        m['orderDateAndTime'] ??=
            m['createdAt'] ?? m['orderDateTime'] ?? m['updatedAt'];
        if ((m['userName'] == null || m['userName'].toString().isEmpty) &&
            m['name'] != null)
          m['userName'] = m['name'];
        if (m['cartItems'] != null && m['order'] == null) {
          final cartItems = m['cartItems'] as List? ?? [];
          m['order'] = cartItems.map((item) {
            final itemMap = item as Map<String, dynamic>;
            return {
              'dishName': itemMap['dishName'] ?? 'Unknown Item',
              'quantity': itemMap['quantity'] ?? 1,
              'totalPrice': itemMap['totalPrice'] ?? itemMap['price'] ?? 0,
            };
          }).toList();
        }
        return m;
      }).toList();
    } catch (e) {
      debugPrint('TABLE_DINE_IN fetch ($status) error: $e');
      return [];
    }
  }

  String? _getToken(SharedPreferences prefs) {
    for (var key in [
      'authToken',
      'token',
      'accessToken',
      'jwtToken',
      'bearerToken',
      'userToken',
    ]) {
      final v = prefs.get(key);
      if (v != null) return v.toString();
    }
    return null;
  }

  // Future<void> _fetchProcessingOrders() async {
  //   setState(() {
  //     isLoading = true;
  //     isError = false;
  //   });
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     final token = _getToken(prefs);
  //     final allStandard = await food_authservice.getAllOrders();
  //     final standard = allStandard.where((o) {
  //       final status = o['status'] ?? '';
  //       final vendorId = o['vendorId'] ?? 0;
  //       final type = (o['orderType'] ?? '').toString().toUpperCase();
  //       return vendorId == widget.vendorId &&
  //           _processingStatuses.contains(status) &&
  //           ['DINE_IN', 'DELIVERY', 'TAKEAWAY'].contains(type);
  //     }).toList();
  //     final tableResults = <dynamic>[];
  //     if (token != null) {
  //       for (final s in _processingStatuses) {
  //         tableResults.addAll(await _fetchTableDineInByStatus(token, s));
  //       }
  //     }
  //     final seen = <String>{};
  //     final merged = <dynamic>[];
  //     for (final o in [...standard, ...tableResults]) {
  //       final id = o['orderId'] ?? o['cartId'];
  //       final orderType = o['orderType'] ?? '';
  //       final key = '${orderType}_$id';
  //       if (id != null && seen.add(key)) merged.add(o);
  //     }
  //     merged.sort((a, b) {
  //       final idA = (a['orderId'] ?? a['cartId'] ?? 0) as num;
  //       final idB = (b['orderId'] ?? b['cartId'] ?? 0) as num;
  //       return idB.compareTo(idA);
  //     });
  //
  //     merged.removeWhere((o) {
  //       final s = (o['status'] ?? '').toString().toUpperCase();
  //       return s == 'DELIVERED' || s == 'COMPLETED';
  //     });
  //
  //     for (var order in merged) {
  //       final type = (order['orderType'] ?? '').toString().toUpperCase();
  //       final status = order['status'] ?? '';
  //
  //       if (type == 'DELIVERY' &&
  //           (status == 'WAITING_FOR_PICKUP' ||
  //               status == 'PROCESSING' ||
  //               status == 'CONFIRMED')) {
  //         try {
  //           final id = order['orderId'] ?? order['cartId'];
  //
  //           final response = await ApiClient.get(
  //             'api/get/order?orderId=$id&appType=FOOD_AND_BEVERAGES',
  //             service: 'delivery',
  //           );
  //
  //           if (response.statusCode == 200) {
  //             final deliveryData = json.decode(response.body);
  //             order['vendorOtp'] = deliveryData['vendorOtp'];
  //
  //             debugPrint(
  //               'Fetched OTP for order $id - Vendor OTP: ${deliveryData['vendorOtp']}, User OTP: ${deliveryData['userOtp']}',
  //             );
  //           } else {
  //             debugPrint(
  //               'Failed to fetch delivery data for order $id: ${response.statusCode}',
  //             );
  //             order['vendorOtp'] = null;
  //           }
  //         } catch (e) {
  //           debugPrint(
  //             'Error fetching delivery data for order ${order['orderId']}: $e',
  //           );
  //           order['vendorOtp'] = null;
  //         }
  //       }
  //     }
  //
  //     setState(() {
  //       processingOrders = merged;
  //       isLoading = false;
  //     });
  //   } catch (e) {
  //     setState(() {
  //       isLoading = false;
  //       isError = true;
  //       errorMessage = 'Failed to load orders. Please try again.';
  //     });
  //   }
  // }

  Future<void> _fetchProcessingOrders() async {
    setState(() {
      isLoading = true;
      isError = false;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = _getToken(prefs);
      final allStandard = await food_authservice.getAllOrders();
      final standard = allStandard.where((o) {
        final status = o['status'] ?? '';
        final vendorId = o['vendorId'] ?? 0;
        final type = (o['orderType'] ?? '').toString().toUpperCase();
        return vendorId == widget.vendorId &&
            _processingStatuses.contains(status) &&
            ['DINE_IN', 'DELIVERY', 'TAKEAWAY'].contains(type);
      }).toList();

      final tableResults = <dynamic>[];
      if (token != null) {
        // FIX: parallel instead of sequential — 5 statuses = 1 batch, not 5 round trips
        final tableResultLists = await Future.wait(
          _processingStatuses.map((s) => _fetchTableDineInByStatus(token, s)),
        );
        for (final list in tableResultLists) {
          tableResults.addAll(list);
        }
      }

      final seen = <String>{};
      final merged = <dynamic>[];
      for (final o in [...standard, ...tableResults]) {
        final id = o['orderId'] ?? o['cartId'];
        final orderType = o['orderType'] ?? '';
        final key = '${orderType}_$id';
        if (id != null && seen.add(key)) merged.add(o);
      }
      merged.sort((a, b) {
        final idA = (a['orderId'] ?? a['cartId'] ?? 0) as num;
        final idB = (b['orderId'] ?? b['cartId'] ?? 0) as num;
        return idB.compareTo(idA);
      });

      merged.removeWhere((o) {
        final s = (o['status'] ?? '').toString().toUpperCase();
        return s == 'DELIVERED' || s == 'COMPLETED';
      });

      // FIX: parallel OTP fetch instead of sequential await-in-loop
      final otpEligible = merged.where((order) {
        final type = (order['orderType'] ?? '').toString().toUpperCase();
        final status = order['status'] ?? '';
        return type == 'DELIVERY' &&
            (status == 'WAITING_FOR_PICKUP' ||
                status == 'PROCESSING' ||
                status == 'CONFIRMED');
      }).toList();

      await Future.wait(
        otpEligible.map((order) async {
          final id = order['orderId'] ?? order['cartId'];
          try {
            final response = await ApiClient.get(
              'api/get/order?orderId=$id&appType=FOOD_AND_BEVERAGES',
              service: 'delivery',
            );
            if (response.statusCode == 200) {
              final deliveryData = json.decode(response.body);
              order['vendorOtp'] = deliveryData['vendorOtp'];
              debugPrint(
                'Fetched OTP for order $id - Vendor OTP: ${deliveryData['vendorOtp']}, User OTP: ${deliveryData['userOtp']}',
              );
            } else {
              debugPrint(
                'Failed to fetch delivery data for order $id: ${response.statusCode}',
              );
              order['vendorOtp'] = null;
            }
          } catch (e) {
            debugPrint('Error fetching delivery data for order $id: $e');
            order['vendorOtp'] = null;
          }
        }),
      );

      setState(() {
        processingOrders = merged;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        isError = true;
        errorMessage = 'Failed to load orders. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (isLoading) return _loadingView();
    if (isError) return _errorView();
    if (processingOrders.isEmpty) return _emptyView();
    return RefreshIndicator(
      color: _O.accent,
      onRefresh: _fetchProcessingOrders,
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 24.h),
        itemCount: processingOrders.length,
        itemBuilder: (_, i) => _buildOrderCard(processingOrders[i], i),
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> rawOrder, int index) {
    final order = _normaliseOrder(rawOrder);
    final items = order['order'] as List? ?? [];
    final dtRaw =
        order['orderDateAndTime'] ??
        order['createdAt'] ??
        order['orderDateTime'] ??
        '';
    final time = _fmtDt(dtRaw as String? ?? '');
    final status = order['status'] as String? ?? '';
    final statusColor = _statusColor(status);
    final orderType = (order['orderType'] ?? '').toString().toUpperCase();
    final orderId = (order['orderId'] ?? order['cartId']) as int?;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: _O.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: _O.border),
        boxShadow: [
          BoxShadow(
            color: _O.shadow,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(14.r),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.06),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
            ),
            child: Row(
              children: [
                Container(
                  width: 36.r,
                  height: 36.r,
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    orderType == 'TABLE_DINE_IN'
                        ? Icons.table_restaurant_rounded
                        : Icons.receipt_long_rounded,
                    color: statusColor,
                    size: 18.sp,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order #${order['orderId']}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w800,
                          color: _O.text1,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Wrap(
                        spacing: 6.w,
                        runSpacing: 4.h,
                        children: [
                          _statusBadge(_statusLabel(status), statusColor),
                          _typeBadge(orderType),
                          if (orderType == 'TABLE_DINE_IN' &&
                              (order['tableCode'] ?? '').toString().isNotEmpty)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 3.h,
                              ),
                              decoration: BoxDecoration(
                                color: _O.amberLight,
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Text(
                                'Table: ${order['tableCode']}',
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w700,
                                  color: _O.amber,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      time['date']!,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: _O.text2,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      time['time']!,
                      style: TextStyle(fontSize: 11.sp, color: _O.text2),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 14.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if ((order['userName'] as String?)?.isNotEmpty == true) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline_rounded,
                        size: 13.sp,
                        color: _O.text3,
                      ),
                      SizedBox(width: 5.w),
                      Text(
                        order['userName'].toString(),
                        style: TextStyle(fontSize: 12.sp, color: _O.text2),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                ],
                if (orderType == 'TABLE_DINE_IN' &&
                    (order['tableCode'] ?? '').toString().isNotEmpty) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.table_restaurant_rounded,
                        size: 13.sp,
                        color: _O.text3,
                      ),
                      SizedBox(width: 5.w),
                      Text(
                        'Table: ${order['tableCode']}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: _O.amber,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                ],
                Text(
                  'Items',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: _O.text1,
                  ),
                ),
                SizedBox(height: 6.h),
                ...items.map(
                  (it) => Padding(
                    padding: EdgeInsets.symmetric(vertical: 3.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Row(
                            children: [
                              Container(
                                width: 5.r,
                                height: 5.r,
                                decoration: const BoxDecoration(
                                  color: _O.accent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Flexible(
                                child: Text(
                                  '${it['dishName']} × ${it['quantity']}',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: _O.text2,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '₹${it['totalPrice']}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: _O.text1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 10.h,
                  ),
                  decoration: BoxDecoration(
                    color: _O.orangeLight,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.local_offer_rounded,
                            color: _O.orange,
                            size: 14.sp,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            'Grand Total',
                            style: TextStyle(
                              color: _O.orange,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '₹${_calcTotal(items)}',
                        style: TextStyle(
                          color: _O.orange,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
                if (orderType == 'DELIVERY') ...[
                  if (orderId != null && orderId > 0)
                    DeliveryOtpCard(orderId: orderId)
                  else
                    Container(
                      margin: EdgeInsets.only(top: 12.h),
                      padding: EdgeInsets.all(12.r),
                      decoration: BoxDecoration(
                        color: _O.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: _O.red.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, size: 14.sp, color: _O.red),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              'Invalid order ID: ${order['orderId']}',
                              style: TextStyle(color: _O.red, fontSize: 12.sp),
                            ),
                          ),
                        ],
                      ),
                    ),
                  SizedBox(height: 12.h),
                ],
                _buildProgressStepper(status, orderType),
                _buildStageButton(order, status),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static const _stageOrder = [
    'Placed',
    'Preparing',
    'Prepared',
    'Dispatched',
    'Delivered',
  ];
  static const _statusToStage = {
    'CONFIRMED': 'Placed',
    'PROCESSING': 'Preparing',
    'BEING_PREPARED': 'Preparing',
    'ORDER_IS_READY': 'Prepared',
    'WAITING_FOR_PICKUP': 'Dispatched',
    'DELIVERED': 'Delivered',
  };
  static const _stageToApiStatus = {
    'Preparing': 'BEING_PREPARED',
    'Prepared': 'ORDER_IS_READY',
    'Dispatched': 'WAITING_FOR_PICKUP',
    'Delivered': 'DELIVERED',
  };
  static const _stageButtonColors = {
    'Placed': Color(0xFFE66D33),
    'Preparing': Color(0xFF17A2B8),
    'Prepared': Color(0xFF20C997),
    'Dispatched': Color(0xFF6F42C1),
    'Delivered': Color(0xFF28A745),
  };

  int _currentStageIndex(String status) {
    final stage = _statusToStage[status] ?? 'Placed';
    return _stageOrder.indexOf(stage);
  }

  Widget _buildProgressStepper(String status, [String orderType = '']) {
    const steps = [
      {
        'label': 'Confirmed',
        'icon': Icons.check_circle_outline_rounded,
        'key': 'CONFIRMED',
      },
      {
        'label': 'Preparing',
        'icon': Icons.soup_kitchen_rounded,
        'key': 'BEING_PREPARED',
      },
      {
        'label': 'Ready',
        'icon': Icons.done_all_rounded,
        'key': 'ORDER_IS_READY',
      },
      {
        'label': 'Pickup',
        'icon': Icons.local_shipping_outlined,
        'key': 'WAITING_FOR_PICKUP',
      },
      {
        'label': 'Delivered',
        'icon': Icons.delivery_dining_rounded,
        'key': 'DELIVERED',
      },
    ];
    const relevantStatuses = _processingStatuses; // same list for all types
    final currentIdx = relevantStatuses
        .indexOf(status)
        .clamp(0, steps.length - 1);
    return Row(
      children: List.generate(steps.length * 2 - 1, (i) {
        if (i.isOdd) {
          final stepIdx = i ~/ 2;
          final isActive = stepIdx < currentIdx;
          return Expanded(
            child: Container(
              height: 2.h,
              color: isActive ? _O.green : _O.border,
            ),
          );
        }
        final stepIdx = i ~/ 2;
        final isActive = stepIdx <= currentIdx;
        final step = steps[stepIdx];
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 28.r,
              height: 28.r,
              decoration: BoxDecoration(
                color: isActive ? _O.green : _O.bg,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isActive ? _O.green : _O.border,
                  width: 1.5,
                ),
              ),
              child: Icon(
                step['icon'] as IconData,
                color: isActive ? Colors.white : _O.text3,
                size: 14.sp,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              step['label'] as String,
              style: TextStyle(
                fontSize: 9.sp,
                color: isActive ? _O.green : _O.text3,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildStageButton(Map<String, dynamic> order, String status) {
    final currentIdx = _currentStageIndex(status);
    if (currentIdx >= _stageOrder.length - 1) return const SizedBox.shrink();
    final orderType = (order['orderType'] ?? '').toString().toUpperCase();
    final isDelivery = orderType == 'DELIVERY';
    final isTableDineIn = orderType == 'TABLE_DINE_IN';
    final currentStage = _stageOrder[currentIdx];
    final nextStage = _stageOrder[currentIdx + 1];
    if (isDelivery) {
      final preparedIdx = _stageOrder.indexOf('Prepared');
      if (currentIdx >= preparedIdx) return _deliveryPartnerPill();
      if (_stageOrder.indexOf(nextStage) > preparedIdx)
        return _deliveryPartnerPill();
    }

    final btnColor = _stageButtonColors[currentStage] ?? _O.accent;
    final btnLabel = 'Move to $nextStage';
    return Padding(
      padding: EdgeInsets.only(top: 14.h),
      child: GestureDetector(
        onTap: () => _advanceStage(order, nextStage),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: btnColor,
            borderRadius: BorderRadius.circular(10.r),
            boxShadow: [
              BoxShadow(
                color: btnColor.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Text(
              btnLabel,
              style: TextStyle(
                color: Colors.white,
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _deliveryPartnerPill() => Padding(
    padding: EdgeInsets.only(top: 14.h),
    child: Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 11.h),
      decoration: BoxDecoration(
        color: _O.blueLight,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: _O.blue.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.delivery_dining_rounded, color: _O.blue, size: 16.sp),
          SizedBox(width: 8.w),
          Text(
            'Awaiting Delivery Partner',
            style: TextStyle(
              color: _O.blue,
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    ),
  );

  Future<void> _advanceStage(
    Map<String, dynamic> order,
    String nextStage,
  ) async {
    final apiStatus = _stageToApiStatus[nextStage];
    if (apiStatus == null) return;

    final id = order['orderId'] ?? order['cartId'];
    final orderType = (order['orderType'] ?? '').toString().toUpperCase();
    bool success = false;

    try {
      if (orderType == 'TABLE_DINE_IN') {
        // ── Use cartId to update the ENTIRE order at once ──────────
        int? cartId = order['cartId'] is int
            ? order['cartId']
            : int.tryParse(order['cartId']?.toString() ?? '');

        cartId ??= order['orderId'] is int
            ? order['orderId']
            : int.tryParse(order['orderId']?.toString() ?? '');

        if (cartId == null) {
          if (mounted) _snackErr('Invalid cart ID');
          return;
        }

        // ── Get ALL itemIds from cartItems ─────────────────────────
        final cartItems = order['cartItems'] as List? ?? [];

        if (cartItems.isEmpty) {
          // Fallback: no cartItems, try single itemId
          final itemId = order['itemId'] is int
              ? order['itemId']
              : int.tryParse(order['itemId']?.toString() ?? '');
          if (itemId == null) {
            if (mounted) _snackErr('No items found in order');
            return;
          }
          success = await food_authservice.updateTableDineInOrderStatus(
            itemId,
            apiStatus,
          );
        } else {
          // ── Update ALL items together ──────────────────────────
          final List<int> itemIds = [];
          for (final item in cartItems) {
            if (item is Map) {
              final itemId = item['itemId'] is int
                  ? item['itemId'] as int
                  : int.tryParse(item['itemId']?.toString() ?? '');
              if (itemId != null) itemIds.add(itemId);
            }
          }

          if (itemIds.isEmpty) {
            if (mounted) _snackErr('Could not extract item IDs');
            return;
          }

          debugPrint(
            '[TABLE_DINE_IN] Updating ALL ${itemIds.length} items: $itemIds → $apiStatus',
          );

          // ── Call status update for every item in parallel ──────
          final results = await Future.wait(
            itemIds.map(
              (itemId) => food_authservice
                  .updateTableDineInOrderStatus(itemId, apiStatus)
                  .catchError((_) => false),
            ),
          );

          // Success only if ALL items updated
          success = results.every((r) => r == true);
        }
      } else {
        success = await food_authservice.updateOrderStatus(id, apiStatus);
      }
    } catch (e) {
      if (mounted) _snackErr('Error: $e');
      return;
    }

    if (!mounted) return;

    if (success) {
      setState(() {
        final idx = processingOrders.indexWhere((o) {
          final oid = o['orderId'] ?? o['cartId'];
          return oid.toString() == id.toString();
        });
        if (idx != -1) {
          if (nextStage == 'Delivered') {
            processingOrders.removeAt(idx);
          } else {
            processingOrders[idx] = Map<String, dynamic>.from(
              processingOrders[idx],
            )..['status'] = apiStatus;
          }
        }
      });
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text(
      //       nextStage == 'Delivered'
      //           ? 'Order #$id completed ✅'
      //           : 'All items moved to $nextStage ✅',
      //     ),
      //     backgroundColor: nextStage == 'Delivered' ? _O.green : _O.amber,
      //     behavior: SnackBarBehavior.floating,
      //     shape: RoundedRectangleBorder(
      //       borderRadius: BorderRadius.circular(10),
      //     ),
      //   ),
      // );
    } else {}
  }

  void _snackErr(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: _O.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _statusBadge(String label, Color color) => Container(
    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(6.r),
    ),
    child: Text(
      label,
      style: TextStyle(
        fontSize: 10.sp,
        fontWeight: FontWeight.w700,
        color: color,
      ),
    ),
  );

  Widget _typeBadge(String type) {
    String label;
    Color color;
    Color bg;
    switch (type) {
      case 'DINE_IN':
        label = 'Dine In';
        color = _O.purple;
        bg = _O.purpleLight;
        break;
      case 'DELIVERY':
        label = 'Delivery';
        color = _O.blue;
        bg = _O.blueLight;
        break;
      case 'TAKEAWAY':
        label = 'Take Away';
        color = _O.teal;
        bg = _O.tealLight;
        break;
      case 'TABLE_DINE_IN':
        label = 'Table Dine In';
        color = _O.purple;
        bg = _O.purpleLight;
        break;
      default:
        label = type.replaceAll('_', ' ');
        color = _O.text2;
        bg = _O.bg;
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  String _statusLabel(String s) {
    const m = {
      'CONFIRMED': 'Confirmed',
      'BEING_PREPARED': 'Preparing',
      'ORDER_IS_READY': 'Ready',
      'WAITING_FOR_PICKUP': 'Pickup',
      'PROCESSING': 'Delivering',
    };
    return m[s] ?? s.replaceAll('_', ' ');
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'CONFIRMED':
        return _O.blue;
      case 'BEING_PREPARED':
        return _O.amber;
      case 'ORDER_IS_READY':
        return _O.purple;
      case 'WAITING_FOR_PICKUP':
        return _O.teal;
      case 'PROCESSING':
        return const Color(0xFF6366F1);
      default:
        return _O.text3;
    }
  }

  double _calcTotal(List items) =>
      items.fold(0.0, (s, it) => s + (it['totalPrice'] ?? 0));

  Map<String, String> _fmtDt(String raw) {
    try {
      final d = DateTime.parse(raw).toLocal();
      return {
        'date': DateFormat('dd MMM yyyy').format(d),
        'time': DateFormat('hh:mm a').format(d),
      };
    } catch (_) {
      return {'date': 'N/A', 'time': 'N/A'};
    }
  }

  Widget _loadingView() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(color: _O.accent, strokeWidth: 2),
        SizedBox(height: 14.h),
        Text(
          'Loading processing orders...',
          style: TextStyle(color: _O.text2, fontSize: 13.sp),
        ),
      ],
    ),
  );

  Widget _errorView() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 64.r,
          height: 64.r,
          decoration: BoxDecoration(color: _O.redLight, shape: BoxShape.circle),
          child: Icon(Icons.error_outline_rounded, color: _O.red, size: 28.sp),
        ),
        SizedBox(height: 12.h),
        Text(
          'Error loading orders',
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
            color: _O.text1,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          errorMessage,
          style: TextStyle(fontSize: 12.sp, color: _O.text2),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 16.h),
        GestureDetector(
          onTap: _fetchProcessingOrders,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_O.accent, _O.accentDark],
              ),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Text(
              'Retry',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _emptyView() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 72.r,
          height: 72.r,
          decoration: BoxDecoration(
            color: _O.bg,
            shape: BoxShape.circle,
            border: Border.all(color: _O.border),
          ),
          child: Icon(
            Icons.pending_actions_rounded,
            size: 30.sp,
            color: _O.text3,
          ),
        ),
        SizedBox(height: 14.h),
        Text(
          'No Processing Orders',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: _O.text1,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          'Processing orders will appear here',
          style: TextStyle(fontSize: 12.sp, color: _O.text2),
        ),
        SizedBox(height: 20.h),
        GestureDetector(
          onTap: _fetchProcessingOrders,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: _O.accentLight,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: _O.accent.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.refresh_rounded, color: _O.accent, size: 16.sp),
                SizedBox(width: 6.w),
                Text(
                  'Refresh',
                  style: TextStyle(
                    color: _O.accent,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

// ─── Printer Bottom Sheet ─────────────────────────────────────────────────────
class _PrinterBottomSheet extends StatefulWidget {
  final Map<String, dynamic> order;
  final int index;
  final VoidCallback onPrintComplete;
  final Function(String) onSetDefault;
  final VoidCallback onCancelPrint;

  const _PrinterBottomSheet({
    required this.order,
    required this.index,
    required this.onPrintComplete,
    required this.onSetDefault,
    required this.onCancelPrint,
  });

  @override
  State<_PrinterBottomSheet> createState() => __PrinterBottomSheetState();
}

class __PrinterBottomSheetState extends State<_PrinterBottomSheet> {
  List<BluetoothInfo> pairedDevices = [];
  bool isLoading = true;
  bool isConnecting = false;

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  Future<void> _loadDevices() async {
    setState(() => isLoading = true);
    try {
      final paired = await PrintBluetoothThermal.pairedBluetooths;
      setState(() {
        pairedDevices = paired;
        isLoading = false;
      });
    } catch (_) {
      setState(() => isLoading = false);
    }
  }

  Future<void> _connectAndPrint(String mac, String name) async {
    setState(() => isConnecting = true);
    try {
      await PrintBluetoothThermal.disconnect;
      final connected = await PrintBluetoothThermal.connect(
        macPrinterAddress: mac,
      );
      if (connected) {
        await _printReceipt({
          ..._normaliseOrder(widget.order),
          'date': DateFormat('dd/MM/yyyy').format(DateTime.now()),
          'time': DateFormat('hh:mm a').format(DateTime.now()),
          'vendorRegisteredName':
              widget.order['vendorRegisteredName'] ?? 'RESTAURANT',
        });
        widget.onSetDefault(mac);
        widget.onPrintComplete();
        Navigator.pop(context);
      } else {
        throw Exception('Failed to connect to printer');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to print: $e'), backgroundColor: _O.red),
      );
    } finally {
      setState(() => isConnecting = false);
    }
  }

  Future<void> _printReceipt(Map<String, dynamic> data) async {
    final normData = _normaliseOrder(data);
    final items = normData['order'] as List<dynamic>? ?? [];

    await PrintBluetoothThermal.writeBytes(Uint8List.fromList([27, 97, 1]));
    await PrintBluetoothThermal.writeBytes(Uint8List.fromList([27, 69, 1]));
    await PrintBluetoothThermal.writeString(
      printText: PrintTextSize(
        size: 2,
        text: '${data['vendorRegisteredName']}\n',
      ),
    );
    await PrintBluetoothThermal.writeBytes(Uint8List.fromList([27, 33, 0]));
    await PrintBluetoothThermal.writeString(
      printText: PrintTextSize(
        size: 2,
        text: '------------------------------------------------\n',
      ),
    );

    String makeRow(String l, String r) {
      int sp = 48 - l.length - r.length;
      if (sp < 1) sp = 1;
      return l + (' ' * sp) + r;
    }

    await PrintBluetoothThermal.writeString(
      printText: PrintTextSize(
        size: 2,
        text:
            makeRow('Order ID : ${data['orderId']}', 'Date : ${data['date']}') +
            '\n',
      ),
    );

    final orderType = (data['orderType'] ?? '').toString().toUpperCase();
    final typeLabel = _fmtType(data['orderType']);
    final rightInfo =
        orderType == 'TABLE_DINE_IN' &&
            (data['tableCode'] ?? '').toString().isNotEmpty
        ? 'Table: ${data['tableCode']}'
        : 'Time : ${data['time']}';

    await PrintBluetoothThermal.writeString(
      printText: PrintTextSize(
        size: 2,
        text: makeRow('Type     : $typeLabel', rightInfo) + '\n',
      ),
    );
    await PrintBluetoothThermal.writeString(
      printText: PrintTextSize(
        size: 2,
        text: '------------------------------------------------\n',
      ),
    );
    await PrintBluetoothThermal.writeBytes(Uint8List.fromList([27, 33, 8]));
    await PrintBluetoothThermal.writeString(
      printText: PrintTextSize(
        size: 2,
        text: 'ITEM                       QTY\n',
      ),
    );
    await PrintBluetoothThermal.writeBytes(Uint8List.fromList([27, 33, 0]));
    await PrintBluetoothThermal.writeString(
      printText: PrintTextSize(
        size: 2,
        text: '------------------------------------------------\n',
      ),
    );

    for (var item in items) {
      String name = (item['dishName'] ?? 'N/A').toString();
      if (name.length > 26) name = name.substring(0, 26);
      await PrintBluetoothThermal.writeString(
        printText: PrintTextSize(
          size: 2,
          text:
              '${name.padRight(28)}'
              '${(item['quantity']?.toString() ?? '0').padRight(10)}\n',
        ),
      );
    }
    await PrintBluetoothThermal.writeString(
      printText: PrintTextSize(
        size: 2,
        text: '------------------------------------------------\n',
      ),
    );
  }

  String _fmtType(String? t) {
    switch (t) {
      case 'TAKEAWAY':
        return 'Take Away';
      case 'DINE_IN':
        return 'Dine In';
      case 'DELIVERY':
        return 'Delivery';
      case 'TABLE_DINE_IN':
        return 'Table Dine In';
      case 'CATERING':
        return 'Catering';
      default:
        return t?.replaceAll('_', ' ') ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _O.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              margin: EdgeInsets.only(top: 10.h),
              decoration: BoxDecoration(
                color: _O.border,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.r),
              child: Row(
                children: [
                  Container(
                    width: 38.r,
                    height: 38.r,
                    decoration: BoxDecoration(
                      color: _O.blueLight,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      Icons.print_rounded,
                      color: _O.blue,
                      size: 20.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select Printer',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w800,
                            color: _O.text1,
                          ),
                        ),
                        Text(
                          'For Order #${widget.order['orderId']}',
                          style: TextStyle(fontSize: 11.sp, color: _O.text2),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: _O.border, height: 1),
            SizedBox(
              height: 220.h,
              child: isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: _O.accent,
                        strokeWidth: 2,
                      ),
                    )
                  : pairedDevices.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.bluetooth_disabled_rounded,
                            size: 40.sp,
                            color: _O.text3,
                          ),
                          SizedBox(height: 10.h),
                          Text(
                            'No printers found',
                            style: TextStyle(
                              color: _O.text2,
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Please pair your printer first',
                            style: TextStyle(color: _O.text3, fontSize: 11.sp),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                      itemCount: pairedDevices.length,
                      itemBuilder: (_, i) {
                        final device = pairedDevices[i];
                        return Container(
                          margin: EdgeInsets.only(bottom: 8.h),
                          padding: EdgeInsets.all(12.r),
                          decoration: BoxDecoration(
                            color: _O.bg,
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(color: _O.border),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 34.r,
                                height: 34.r,
                                decoration: BoxDecoration(
                                  color: _O.blueLight,
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Icon(
                                  Icons.print_rounded,
                                  color: _O.blue,
                                  size: 16.sp,
                                ),
                              ),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      device.name,
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w600,
                                        color: _O.text1,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      device.macAdress,
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        color: _O.text3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: isConnecting
                                    ? null
                                    : () => _connectAndPrint(
                                        device.macAdress,
                                        device.name,
                                      ),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12.w,
                                    vertical: 7.h,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [_O.green, Color(0xFF059669)],
                                    ),
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: isConnecting
                                      ? SizedBox(
                                          width: 14.r,
                                          height: 14.r,
                                          child:
                                              const CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2,
                                              ),
                                        )
                                      : Text(
                                          'Print',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            Divider(color: _O.border, height: 1),
            Padding(
              padding: EdgeInsets.all(16.r),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: widget.onCancelPrint,
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 13.h),
                        decoration: BoxDecoration(
                          color: _O.amberLight,
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(color: _O.amber.withOpacity(0.3)),
                        ),
                        child: Center(
                          child: Text(
                            'Accept Without Print',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                              color: _O.amber,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 13.h),
                        decoration: BoxDecoration(
                          color: _O.bg,
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(color: _O.border),
                        ),
                        child: Center(
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                              color: _O.text2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class HistoryTab extends StatefulWidget {
  final int vendorId;
  final bool shouldPrint;

  const HistoryTab({
    super.key,
    required this.vendorId,
    this.shouldPrint = true,
  });

  @override
  State<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab>
    with AutomaticKeepAliveClientMixin {
  // ── State ─────────────────────────────────────────────────────────────────
  List<Map<String, dynamic>> _orders = [];
  bool _loading = true;
  String? _error;

  // Server-side pagination (mirrors React: 0-based API page)
  int _currentPage = 0;
  static const int _pageSize = 10;
  int _totalPages = 0;
  int _totalOrders = 0;
  bool _isFirstPage = true;
  bool _isLastPage = false;

  // Date filter  (mirrors React dateFilter state)
  String _dateFilter =
      'all'; // all | today | yesterday | week | last30days | thisMonth | custom
  String? _fromDate; // yyyy-MM-dd
  String? _toDate; // yyyy-MM-dd
  bool _filterOpen = false;

  // Custom-range modal
  bool _showCustomModal = false;
  String _customStart = '';
  String _customEnd = '';

  // Search (order-ID lookup, same as React)
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';
  bool _searchLoading = false;

  // Expand/collapse cards
  final Set<dynamic> _expandedOrders = {};

  @override
  bool get wantKeepAlive => true;

  // ── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _fetchOrdersWithoutDates(page: 0);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── Token helper ──────────────────────────────────────────────────────────
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    for (final k in [
      'authToken',
      'token',
      'accessToken',
      'jwtToken',
      'bearerToken',
      'userToken',
    ]) {
      final v = prefs.get(k);
      if (v != null) return v.toString();
    }
    return null;
  }

  Future<void> _fetchOrdersWithoutDates({int page = 0}) async {
    if (widget.vendorId == 0) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final endpoint =
          'api/orders/vendor/paginated/${widget.vendorId}/$page/$_pageSize';
      final resp = await ApiClient.get(endpoint, service: 'food');

      if (resp.statusCode == 200) {
        final data = json.decode(resp.body) as Map<String, dynamic>;
        final content = (data['content'] as List? ?? [])
            .whereType<Map<String, dynamic>>()
            .toList();

        setState(() {
          _orders = content;
          _totalPages = data['totalPages'] ?? 1;
          _totalOrders = data['totalElements'] ?? 0;
          _isFirstPage = data['first'] ?? (page == 0);
          _isLastPage = data['last'] ?? (page >= (_totalPages - 1));
          _currentPage = page;
        });
      } else {
        setState(() {
          _orders = [];
          _totalPages = 1;
          _totalOrders = 0;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _orders = [];
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _cancelOrder(dynamic orderId) async {
    String? reason = await _showCancelReasonDialog();
    if (reason == null || reason.trim().isEmpty) return;

    try {
      final encodedReason = Uri.encodeComponent(reason.trim());
      final endpoint =
          'api/orders/cancel/total/order/$orderId?reason=$encodedReason';

      debugPrint('[CANCEL] PUT $endpoint');

      final resp = await ApiClient.put(endpoint, null, service: 'food');

      debugPrint('[CANCEL] Status: ${resp.statusCode}');
      debugPrint('[CANCEL] Body: ${resp.body}');

      if (resp.statusCode == 200 ||
          resp.statusCode == 201 ||
          resp.statusCode == 204) {
        _snack('Order #$orderId cancelled successfully', _O.green);
        if (_dateFilter == 'all' || _fromDate == null) {
          _fetchOrdersWithoutDates(page: _currentPage);
        } else {
          _fetchOrdersWithDates(
            from: _fromDate!,
            to: _toDate!,
            page: _currentPage,
          );
        }
      } else {
        debugPrint('[CANCEL] Failed: ${resp.statusCode} → ${resp.body}');
        _snack('Failed (${resp.statusCode}): ${resp.body}', _O.red);
      }
    } catch (e, st) {
      debugPrint('[CANCEL] Exception: $e\n$st');
      _snack('Error: $e', _O.red);
    }
  }

  Future<String?> _showCancelReasonDialog() async {
    final ctrl = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.r),
        ),
        title: Text(
          'Cancel Order',
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
        ),
        content: TextField(
          controller: ctrl,
          decoration: InputDecoration(
            hintText: 'Enter reason for cancellation',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Back', style: TextStyle(color: _O.text2)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _O.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            onPressed: () => Navigator.pop(context, ctrl.text),
            child: const Text('Confirm', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _fetchOrdersWithDates({
    required String from,
    required String to,
    int page = 0,
  }) async {
    if (widget.vendorId == 0) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final fromEncoded = Uri.encodeComponent('${from}T00:00:00');
      final toEncoded = Uri.encodeComponent('${to}T23:59:59');
      final endpoint =
          'api/orders/vendor/paginated/${widget.vendorId}/$page/$_pageSize'
          '?fromDate=$fromEncoded&toDate=$toEncoded';

      final resp = await ApiClient.get(endpoint, service: 'food');

      if (resp.statusCode == 200) {
        final data = json.decode(resp.body) as Map<String, dynamic>;
        final content = (data['content'] as List? ?? [])
            .whereType<Map<String, dynamic>>()
            .toList();

        setState(() {
          _orders = content;
          _totalPages = data['totalPages'] ?? 1;
          _totalOrders = data['totalElements'] ?? 0;
          _isFirstPage = data['first'] ?? (page == 0);
          _isLastPage = data['last'] ?? (page >= (_totalPages - 1));
          _currentPage = page;
        });
      } else {
        setState(() {
          _orders = [];
          _totalPages = 1;
          _totalOrders = 0;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _orders = [];
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _searchByOrderId(String orderId) async {
    if (orderId.trim().isEmpty) return;
    setState(() => _searchLoading = true);

    try {
      final resp = await ApiClient.get(
        'api/orders/order/$orderId',
        service: 'food',
      );

      if (resp.statusCode == 200) {
        final dynamic raw = json.decode(resp.body);
        if (raw != null) {
          final Map<String, dynamic> orderData = Map<String, dynamic>.from(
            raw as Map,
          );

          final orderList = orderData['order'] as List?;
          if (orderList != null && orderList.isNotEmpty) {
            orderData['items'] = orderList
                .map(
                  (item) => <String, dynamic>{
                    'itemName': item['dishName'],
                    'dishName': item['dishName'],
                    'quantity': item['quantity'],
                    'price': item['price'],
                    'total': item['totalPrice'],
                    'totalPrice': item['totalPrice'],
                  },
                )
                .toList();
          }

          setState(() {
            _orders = [orderData];
            _totalPages = 1;
            _totalOrders = 1;
            _isFirstPage = true;
            _isLastPage = true;
            _currentPage = 0;
          });
        } else {
          setState(() => _orders = []);
          _snack('Order not found', _O.red);
        }
      } else if (resp.statusCode == 404) {
        setState(() => _orders = []);
        _snack('Order #$orderId not found', _O.red);
      } else {
        _snack('Error fetching order details', _O.red);
      }
    } catch (e) {
      setState(() => _orders = []);
      _snack('Error fetching order details', _O.red);
    } finally {
      setState(() => _searchLoading = false);
    }
  }

  void _handlePageChange(int uiPage) {
    final apiPage = uiPage - 1;
    if (_dateFilter == 'all' || _fromDate == null || _toDate == null) {
      _fetchOrdersWithoutDates(page: apiPage);
    } else {
      _fetchOrdersWithDates(from: _fromDate!, to: _toDate!, page: apiPage);
    }
  }

  Future<void> _handleDateFilterSelect(String filterValue) async {
    final today = DateTime.now();
    final todayStr = _toDateStr(today);
    String newFrom = todayStr;
    String newTo = todayStr;

    switch (filterValue) {
      case 'today':
        newFrom = newTo = todayStr;
        break;
      case 'yesterday':
        final y = today.subtract(const Duration(days: 1));
        newFrom = newTo = _toDateStr(y);
        break;
      case 'week':
        newFrom = _toDateStr(today.subtract(const Duration(days: 7)));
        newTo = todayStr;
        break;
      case 'last30days':
        newFrom = _toDateStr(today.subtract(const Duration(days: 30)));
        newTo = todayStr;
        break;
      case 'thisMonth':
        newFrom = _toDateStr(DateTime(today.year, today.month, 1));
        newTo = todayStr;
        break;
      case 'all':
        setState(() {
          _fromDate = null;
          _toDate = null;
          _dateFilter = 'all';
          _filterOpen = false;
        });
        await _fetchOrdersWithoutDates(page: 0);
        return;
      default:
        return;
    }

    setState(() {
      _fromDate = newFrom;
      _toDate = newTo;
      _dateFilter = filterValue;
      _filterOpen = false;
    });
    await _fetchOrdersWithDates(from: newFrom, to: newTo, page: 0);
  }

  // Custom range apply  (mirrors React handleApplyCustomRange)
  Future<void> _applyCustomRange() async {
    if (_customStart.isEmpty || _customEnd.isEmpty) {
      _snack('Please select both start and end dates', _O.amber);
      return;
    }
    setState(() {
      _fromDate = _customStart;
      _toDate = _customEnd;
      _dateFilter = 'custom';
      _showCustomModal = false;
      _filterOpen = false;
    });
    await _fetchOrdersWithDates(from: _customStart, to: _customEnd, page: 0);
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  String _toDateStr(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// Mirror React getDateFilterText()
  String get _filterLabel {
    switch (_dateFilter) {
      case 'all':
        return 'All Orders';
      case 'today':
        return 'Today';
      case 'yesterday':
        return 'Yesterday';
      case 'week':
        return 'Last 7 Days';
      case 'last30days':
        return 'Last 30 Days';
      case 'thisMonth':
        return 'This Month';
      case 'custom':
        return 'Custom Range';
      default:
        return 'All Orders';
    }
  }

  void _snack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ── IST date formatter ────────────────────────────────────────────────────
  DateTime _toIST(String raw) =>
      DateTime.parse(raw).add(const Duration(hours: 5, minutes: 30));

  String _fmtDateTime(Map o) {
    try {
      final raw =
          (o['orderDateAndTime'] ??
                  o['createdAt'] ??
                  o['orderDateTime'] ??
                  o['date'] ??
                  '')
              .toString();
      if (raw.isEmpty) return 'N/A';
      final d = _toIST(raw);
      final dd = d.day.toString().padLeft(2, '0');
      final mm = d.month.toString().padLeft(2, '0');
      final hh = d.hour % 12 == 0 ? 12 : d.hour % 12;
      final min = d.minute.toString().padLeft(2, '0');
      final ap = d.hour >= 12 ? 'PM' : 'AM';
      return '${d.year}-$mm-$dd  $hh:$min $ap';
    } catch (_) {
      return 'N/A';
    }
  }

  String _fmtTimeOnly(Map o) {
    try {
      final raw =
          (o['orderDateAndTime'] ??
                  o['createdAt'] ??
                  o['orderDateTime'] ??
                  o['date'] ??
                  '')
              .toString();
      if (raw.isEmpty) return 'N/A';
      final d = _toIST(raw);
      final hh = d.hour % 12 == 0 ? 12 : d.hour % 12;
      final min = d.minute.toString().padLeft(2, '0');
      return '$hh:$min ${d.hour >= 12 ? 'PM' : 'AM'}';
    } catch (_) {
      return 'N/A';
    }
  }

  // ── Status / type helpers (unchanged from original) ───────────────────────
  Color _statusColor(String? s) {
    switch (s) {
      case 'CONFIRMED':
        return const Color(0xFF2196F3);
      case 'PROCESSING':
      case 'BEING_PREPARED':
        return const Color(0xFF17A2B8);
      case 'ORDER_IS_READY':
      case 'WAITING_FOR_PICKUP':
        return const Color(0xFFE66D33);
      case 'DELIVERED':
      case 'COMPLETED':
        return const Color(0xFF28A745);
      case 'CANCELLED':
      case 'REJECTED':
        return const Color(0xFFF44336);
      default:
        return const Color(0xFF777777);
    }
  }

  String _statusLabel(String? s) {
    const m = {
      'CONFIRMED': 'Confirmed',
      'PROCESSING': 'Processing',
      'BEING_PREPARED': 'Preparing',
      'ORDER_IS_READY': 'Ready',
      'WAITING_FOR_PICKUP': 'Pickup',
      'DELIVERED': 'Delivered',
      'COMPLETED': 'Completed',
      'CANCELLED': 'Cancelled',
      'REJECTED': 'Rejected',
      'PENDING': 'Pending',
    };
    return m[s] ?? (s?.replaceAll('_', ' ') ?? 'Unknown');
  }

  String _orderTypeLabel(String? t) {
    switch (t) {
      case 'DINE_IN':
        return 'Dine In';
      case 'TABLE_DINE_IN':
        return 'Table Dine In';
      case 'TAKEAWAY':
        return 'Takeaway';
      case 'DELIVERY':
        return 'Delivery';
      case 'CATERING':
        return 'Catering';
      default:
        return t?.replaceAll('_', ' ') ?? '-';
    }
  }

  Color _typeColor(String? t) {
    switch (t) {
      case 'DINE_IN':
        return const Color(0xFF1E90FF);
      case 'TABLE_DINE_IN':
        return const Color(0xFF8B5CF6);
      case 'TAKEAWAY':
        return const Color(0xFFFF6347);
      case 'DELIVERY':
        return const Color(0xFF20B2AA);
      case 'CATERING':
        return _O.cateringColor;
      default:
        return _O.accent;
    }
  }

  IconData _orderTypeIcon(String? t) {
    switch (t) {
      case 'DINE_IN':
        return Icons.dining_rounded;
      case 'TABLE_DINE_IN':
        return Icons.table_restaurant_rounded;
      case 'TAKEAWAY':
        return Icons.shopping_bag_rounded;
      case 'DELIVERY':
        return Icons.delivery_dining_rounded;
      case 'CATERING':
        return Icons.restaurant_menu_rounded;
      default:
        return Icons.receipt_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Stack(
      children: [
        Column(
          children: [
            _buildSearchFilterBar(),
            _buildInfoRow(),
            Expanded(child: _buildBody()),
            if (_totalPages > 1) _buildPagination(),
          ],
        ),
        if (_showCustomModal) _buildCustomRangeModal(),
      ],
    );
  }

  // ── Search + Filter bar ───────────────────────────────────────────────────
  Widget _buildSearchFilterBar() {
    return Container(
      color: _O.white,
      padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 8.h),
      child: Row(
        children: [
          // Search field
          Expanded(
            child: Container(
              height: 40.h,
              decoration: BoxDecoration(
                color: _O.bg,
                borderRadius: BorderRadius.circular(9.r),
                border: Border.all(color: _O.border),
              ),
              child: TextField(
                controller: _searchCtrl,
                style: TextStyle(fontSize: 13.sp, color: _O.text1),
                textInputAction: TextInputAction.search,
                onSubmitted: (v) {
                  if (v.trim().isNotEmpty) {
                    _searchByOrderId(v.trim());
                  }
                },
                onChanged: (v) {
                  setState(() => _searchQuery = v);
                  // If user clears search, reload all orders
                  if (v.trim().isEmpty) {
                    _dateFilter == 'all' || _fromDate == null
                        ? _fetchOrdersWithoutDates(page: 0)
                        : _fetchOrdersWithDates(
                            from: _fromDate!,
                            to: _toDate!,
                            page: 0,
                          );
                  }
                },
                decoration: InputDecoration(
                  hintText: 'Search Order ID…',
                  hintStyle: TextStyle(fontSize: 12.sp, color: _O.text3),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    size: 17.sp,
                    color: _O.text3,
                  ),
                  suffixIcon: _searchLoading
                      ? Padding(
                          padding: EdgeInsets.all(10.r),
                          child: SizedBox(
                            width: 16.r,
                            height: 16.r,
                            child: CircularProgressIndicator(
                              color: _O.accent,
                              strokeWidth: 2,
                            ),
                          ),
                        )
                      : _searchQuery.isNotEmpty
                      ? GestureDetector(
                          onTap: () {
                            _searchCtrl.clear();
                            setState(() => _searchQuery = '');
                            _dateFilter == 'all' || _fromDate == null
                                ? _fetchOrdersWithoutDates(page: 0)
                                : _fetchOrdersWithDates(
                                    from: _fromDate!,
                                    to: _toDate!,
                                    page: 0,
                                  );
                          },
                          child: Icon(
                            Icons.close_rounded,
                            size: 16.sp,
                            color: _O.text3,
                          ),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 11.h),
                ),
              ),
            ),
          ),

          SizedBox(width: 8.w),

          // Filter dropdown trigger
          GestureDetector(
            onTap: () => setState(() => _filterOpen = !_filterOpen),
            child: Container(
              height: 40.h,
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              decoration: BoxDecoration(
                color: _dateFilter != 'all' ? _O.accent : _O.accentLight,
                borderRadius: BorderRadius.circular(9.r),
                border: Border.all(color: _O.accent.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.filter_list_rounded,
                    color: _dateFilter != 'all' ? Colors.white : _O.accent,
                    size: 16.sp,
                  ),
                  SizedBox(width: 5.w),
                  Text(
                    _filterLabel,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: _dateFilter != 'all' ? Colors.white : _O.accent,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Icon(
                    Icons.arrow_drop_down_rounded,
                    color: _dateFilter != 'all' ? Colors.white : _O.accent,
                    size: 18.sp,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Inline dropdown — same options as React
  Widget _buildFilterMenu() {
    const options = [
      ('all', 'All Orders'),
      ('today', 'Today'),
      ('yesterday', 'Yesterday'),
      ('week', 'Last 7 Days'),
      ('last30days', 'Last 30 Days'),
      ('thisMonth', 'This Month'),
      ('custom', 'Custom Range'),
    ];
    return Positioned(
      top: 54.h,
      right: 14.w,
      child: Material(
        elevation: 6,
        borderRadius: BorderRadius.circular(10.r),
        child: Container(
          width: 190.w,
          decoration: BoxDecoration(
            color: _O.white,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: _O.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: options.map((opt) {
              final isActive = _dateFilter == opt.$1;
              return GestureDetector(
                onTap: () {
                  if (opt.$1 == 'custom') {
                    setState(() {
                      _filterOpen = false;
                      _showCustomModal = true;
                    });
                  } else {
                    _handleDateFilterSelect(opt.$1);
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 11.h,
                  ),
                  decoration: BoxDecoration(
                    color: isActive ? _O.accentLight : Colors.transparent,
                  ),
                  child: Text(
                    opt.$2,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                      color: isActive ? _O.accent : _O.text1,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  // ── Info row ──────────────────────────────────────────────────────────────
  Widget _buildInfoRow() {
    return Container(
      color: _O.bg,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$_totalOrders orders',
            style: TextStyle(
              fontSize: 12.sp,
              color: _O.text2,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (_totalPages > 1)
            Text(
              'Page ${_currentPage + 1} / $_totalPages',
              style: TextStyle(fontSize: 12.sp, color: _O.text2),
            ),
        ],
      ),
    );
  }

  // ── Main body ─────────────────────────────────────────────────────────────
  Widget _buildBody() {
    if (_loading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: _O.accent, strokeWidth: 2),
            SizedBox(height: 12.h),
            Text(
              'Loading history…',
              style: TextStyle(color: _O.text2, fontSize: 13.sp),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60.r,
              height: 60.r,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFFEE2E2),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                color: _O.red,
                size: 28.sp,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'Failed to load history',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: _O.text1,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              _error!,
              style: TextStyle(fontSize: 11.sp, color: _O.text2),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            GestureDetector(
              onTap: () => _dateFilter == 'all' || _fromDate == null
                  ? _fetchOrdersWithoutDates(page: _currentPage)
                  : _fetchOrdersWithDates(
                      from: _fromDate!,
                      to: _toDate!,
                      page: _currentPage,
                    ),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 9.h),
                decoration: BoxDecoration(
                  color: _O.accent,
                  borderRadius: BorderRadius.circular(9.r),
                ),
                child: Text(
                  'Retry',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13.sp,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_orders.isEmpty) {
      return RefreshIndicator(
        color: _O.accent,
        onRefresh: () => _dateFilter == 'all' || _fromDate == null
            ? _fetchOrdersWithoutDates(page: 0)
            : _fetchOrdersWithDates(from: _fromDate!, to: _toDate!, page: 0),
        child: ListView(
          children: [
            SizedBox(height: 80.h),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.inbox_rounded, size: 40.sp, color: _O.text3),
                  SizedBox(height: 10.h),
                  Text(
                    'No orders found for $_filterLabel',
                    style: TextStyle(fontSize: 14.sp, color: _O.text2),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        RefreshIndicator(
          color: _O.accent,
          onRefresh: () => _dateFilter == 'all' || _fromDate == null
              ? _fetchOrdersWithoutDates(page: 0)
              : _fetchOrdersWithDates(from: _fromDate!, to: _toDate!, page: 0),
          child: ListView.builder(
            padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 24.h),
            itemCount: _orders.length,
            itemBuilder: (_, i) => _buildHistoryCard(_orders[i]),
          ),
        ),
        // Show filter dropdown on top of list when open
        if (_filterOpen) _buildFilterMenu(),
      ],
    );
  }

  Widget _buildPagination() {
    final currentUi = _currentPage + 1; // 1-based for display
    final total = _totalPages;

    // Visible page numbers window (mirrors React logic)
    int start = (currentUi - 2).clamp(1, total);
    int end = (currentUi + 2).clamp(1, total);
    if (end - start < 4) {
      if (start == 1) end = (start + 4).clamp(1, total);
      if (end == total) start = (end - 4).clamp(1, total);
    }

    return Container(
      color: _O.white,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // First «
          _PaginationBtn(
            label: '«',
            enabled: currentUi > 1,
            onTap: () => _handlePageChange(1),
          ),
          SizedBox(width: 4.w),
          // Prev ‹
          _PaginationBtn(
            label: '‹',
            enabled: currentUi > 1,
            onTap: () => _handlePageChange(currentUi - 1),
          ),
          SizedBox(width: 6.w),
          // Page numbers
          ...List.generate(end - start + 1, (i) {
            final pg = start + i;
            final isActive = pg == currentUi;
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 3.w),
              child: GestureDetector(
                onTap: isActive ? null : () => _handlePageChange(pg),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: isActive ? _O.accent : _O.white,
                    borderRadius: BorderRadius.circular(6.r),
                    border: Border.all(color: isActive ? _O.accent : _O.border),
                  ),
                  child: Text(
                    '$pg',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                      color: isActive ? Colors.white : _O.text1,
                    ),
                  ),
                ),
              ),
            );
          }),
          SizedBox(width: 6.w),
          // Next ›
          _PaginationBtn(
            label: '›',
            enabled: currentUi < total,
            onTap: () => _handlePageChange(currentUi + 1),
          ),
          SizedBox(width: 4.w),
          // Last »
          _PaginationBtn(
            label: '»',
            enabled: currentUi < total,
            onTap: () => _handlePageChange(total),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomRangeModal() {
    return Positioned.fill(
      child: GestureDetector(
        onTap: () => setState(() => _showCustomModal = false),
        child: Container(
          color: Colors.black.withOpacity(0.45),
          child: Center(
            child: GestureDetector(
              onTap: () {}, // prevent tap-through
              child: Container(
                width: 340.w,
                decoration: BoxDecoration(
                  color: _O.white,
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Padding(
                      padding: EdgeInsets.fromLTRB(18.w, 16.h, 12.w, 8.h),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Select Date Range',
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w700,
                                color: _O.text1,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () =>
                                setState(() => _showCustomModal = false),
                            child: Icon(
                              Icons.close_rounded,
                              color: _O.text2,
                              size: 20.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(color: _O.border, height: 1),
                    // Date pickers
                    Padding(
                      padding: EdgeInsets.all(18.r),
                      child: Row(
                        children: [
                          Expanded(
                            child: _DatePickerField(
                              label: 'Start Date',
                              value: _customStart,
                              onChanged: (v) =>
                                  setState(() => _customStart = v),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: _DatePickerField(
                              label: 'End Date',
                              value: _customEnd,
                              onChanged: (v) => setState(() => _customEnd = v),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(color: _O.border, height: 1),
                    // Footer
                    Padding(
                      padding: EdgeInsets.all(14.r),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: () =>
                                setState(() => _showCustomModal = false),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 14.w,
                                vertical: 9.h,
                              ),
                              decoration: BoxDecoration(
                                color: _O.bg,
                                borderRadius: BorderRadius.circular(8.r),
                                border: Border.all(color: _O.border),
                              ),
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color: _O.text2,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10.w),
                          GestureDetector(
                            onTap: _applyCustomRange,
                            child: Opacity(
                              opacity:
                                  (_customStart.isNotEmpty &&
                                      _customEnd.isNotEmpty)
                                  ? 1.0
                                  : 0.5,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 14.w,
                                  vertical: 9.h,
                                ),
                                decoration: BoxDecoration(
                                  color: _O.accent,
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Text(
                                  'Apply Range',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget _buildHistoryCard(Map<String, dynamic> rawO) {
  //   final o = _normaliseOrder(rawO);
  //   final orderId = o['orderId'] ?? '-';
  //   final isExpanded = _expandedOrders.contains(orderId);
  //   final orderType = (o['orderType'] as String? ?? '').toUpperCase();
  //   final typeColor = _typeColor(orderType);
  //   final status =
  //       (orderType == 'CATERING' ? o['orderStatus'] : o['status']) as String? ??
  //       '';
  //
  //   // Unify items (same as React formatItems logic)
  //   final rawItems = o['items'] as List?;
  //   final orderItems = o['order'] as List?;
  //   final displayItems = rawItems != null
  //       ? rawItems.map((it) {
  //           if (it is! Map) return it;
  //           return <String, dynamic>{
  //             'itemName': it['itemName'] ?? it['dishName'] ?? '-',
  //             'quantity': it['quantity'] ?? 1,
  //             'total': it['total'] ?? it['totalPrice'] ?? 0,
  //           };
  //         }).toList()
  //       : (orderItems ?? []).map((it) {
  //           if (it is! Map) return it;
  //           return <String, dynamic>{
  //             'itemName': it['dishName'] ?? '-',
  //             'quantity': it['quantity'] ?? 1,
  //             'total': it['totalPrice'] ?? it['total'] ?? 0,
  //           };
  //         }).toList();
  //
  //   final borderColor = orderType == 'CATERING'
  //       ? _O.cateringColor
  //       : const Color(0xFFE66D33);
  //
  //   return Container(
  //     margin: EdgeInsets.only(bottom: 10.h),
  //     decoration: BoxDecoration(
  //       color: _O.white,
  //       borderRadius: BorderRadius.circular(14.r),
  //       border: Border(left: BorderSide(color: borderColor, width: 3)),
  //       boxShadow: [
  //         BoxShadow(
  //           color: _O.shadow,
  //           blurRadius: 6,
  //           offset: const Offset(0, 2),
  //         ),
  //       ],
  //     ),
  //     child: Column(
  //       children: [
  //         // ── Collapsed header ──────────────────────────────────────────────
  //         GestureDetector(
  //           onTap: () => setState(() {
  //             isExpanded
  //                 ? _expandedOrders.remove(orderId)
  //                 : _expandedOrders.add(orderId);
  //           }),
  //           child: Padding(
  //             padding: EdgeInsets.all(12.r),
  //             child: Row(
  //               children: [
  //                 Container(
  //                   width: 40.r,
  //                   height: 40.r,
  //                   decoration: BoxDecoration(
  //                     color: borderColor.withOpacity(0.12),
  //                     borderRadius: BorderRadius.circular(10.r),
  //                   ),
  //                   child: Icon(
  //                     _orderTypeIcon(orderType),
  //                     color: const Color(0xFF2E7D32),
  //                     size: 22.sp,
  //                   ),
  //                 ),
  //                 SizedBox(width: 12.w),
  //                 Expanded(
  //                   child: Column(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     children: [
  //                       Text(
  //                         'Order #$orderId',
  //                         style: TextStyle(
  //                           fontSize: 14.sp,
  //                           fontWeight: FontWeight.w800,
  //                           color: _O.accent,
  //                         ),
  //                       ),
  //                       SizedBox(height: 4.h),
  //                       Wrap(
  //                         spacing: 6.w,
  //                         runSpacing: 4.h,
  //                         children: [
  //                           _chip(
  //                             _orderTypeLabel(orderType),
  //                             typeColor,
  //                             typeColor.withOpacity(0.12),
  //                           ),
  //                           _chip(
  //                             _statusLabel(status),
  //                             _statusColor(status),
  //                             _statusColor(status).withOpacity(0.12),
  //                           ),
  //                           if (orderType == 'TABLE_DINE_IN' &&
  //                               (o['tableCode'] ?? '').toString().isNotEmpty)
  //                             _chip(
  //                               'Table: ${o['tableCode']}',
  //                               _O.amber,
  //                               _O.amberLight,
  //                             ),
  //                           if (orderType == 'CATERING' &&
  //                               (o['eventType'] ?? '').toString().isNotEmpty)
  //                             _chip(
  //                               o['eventType'].toString(),
  //                               _O.purple,
  //                               _O.purpleLight,
  //                             ),
  //                         ],
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //                 Column(
  //                   crossAxisAlignment: CrossAxisAlignment.end,
  //                   children: [
  //                     Text(
  //                       _fmtTimeOnly(o),
  //                       style: TextStyle(
  //                         fontSize: 11.sp,
  //                         fontWeight: FontWeight.w600,
  //                         color: _O.text2,
  //                       ),
  //                     ),
  //                     SizedBox(height: 6.h),
  //                     Row(
  //                       mainAxisSize: MainAxisSize.min,
  //                       children: [
  //                         // GestureDetector(
  //                         //   onTap: () {},
  //                         //   child: Container(
  //                         //     padding: EdgeInsets.all(6.r),
  //                         //     decoration: BoxDecoration(
  //                         //       color: _O.blueLight,
  //                         //       borderRadius: BorderRadius.circular(6.r),
  //                         //     ),
  //                         //     child: Icon(
  //                         //       Icons.print_rounded,
  //                         //       color: _O.infBlue,
  //                         //       size: 14.sp,
  //                         //     ),
  //                         //   ),
  //                         // ),
  //                         // SizedBox(width: 6.w),
  //                         GestureDetector(
  //                           onTap: () => _cancelOrder(orderId),
  //                           child: Container(
  //                             padding: EdgeInsets.symmetric(
  //                               horizontal: 10.w,
  //                               vertical: 5.h,
  //                             ),
  //                             decoration: BoxDecoration(
  //                               color: _O.red,
  //                               borderRadius: BorderRadius.circular(6.r),
  //                             ),
  //                             child: Text(
  //                               'Cancel',
  //                               style: TextStyle(
  //                                 fontSize: 11.sp,
  //                                 fontWeight: FontWeight.w700,
  //                                 color: Colors.white,
  //                               ),
  //                             ),
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                     SizedBox(height: 4.h),
  //                     Icon(
  //                       isExpanded ? Icons.expand_less : Icons.expand_more,
  //                       color: _O.text3,
  //                       size: 20.sp,
  //                     ),
  //                   ],
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //
  //         // ── Expanded detail ───────────────────────────────────────────────
  //         if (isExpanded)
  //           Container(
  //             decoration: BoxDecoration(
  //               border: Border(top: BorderSide(color: _O.border, width: 0.5)),
  //             ),
  //             child: Padding(
  //               padding: EdgeInsets.all(12.r),
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   _infoRow(Icons.schedule_rounded, _fmtDateTime(o)),
  //                   SizedBox(height: 8.h),
  //                   _infoRow(Icons.payment, o['paymentMethod'] ?? 'N/A'),
  //                   if ((o['userName'] ?? '').toString().isNotEmpty &&
  //                       o['userName'].toString() != 'null') ...[
  //                     SizedBox(height: 8.h),
  //                     _infoRow(
  //                       Icons.person_outline_rounded,
  //                       'Customer: ${o['userName']}',
  //                     ),
  //                   ],
  //                   SizedBox(height: 8.h),
  //                   _infoRow(
  //                     Icons.store_outlined,
  //                     o['vendorRegisteredName'] ?? 'Vendor',
  //                   ),
  //                   if (orderType == 'CATERING') ...[
  //                     if ((o['cateringDate'] ?? '').toString().isNotEmpty) ...[
  //                       SizedBox(height: 8.h),
  //                       _infoRow(
  //                         Icons.event_rounded,
  //                         'Catering Date: ${o['cateringDate']}',
  //                         iconColor: _O.green,
  //                         textColor: _O.green,
  //                       ),
  //                     ],
  //                     if ((o['deliveryAddress'] ?? '')
  //                         .toString()
  //                         .isNotEmpty) ...[
  //                       SizedBox(height: 8.h),
  //                       _infoRow(
  //                         Icons.location_on_rounded,
  //                         o['deliveryAddress'].toString(),
  //                         iconColor: _O.red,
  //                       ),
  //                     ],
  //                   ],
  //                   if (orderType == 'TABLE_DINE_IN' &&
  //                       (o['tableCode'] ?? '').toString().isNotEmpty) ...[
  //                     SizedBox(height: 8.h),
  //                     _infoRow(
  //                       Icons.table_restaurant_rounded,
  //                       'Table: ${o['tableCode']}',
  //                       textColor: _O.amber,
  //                     ),
  //                   ],
  //                   SizedBox(height: 12.h),
  //                   Divider(height: 1, color: _O.border),
  //                   SizedBox(height: 8.h),
  //                   Text(
  //                     'Order Items',
  //                     style: TextStyle(
  //                       fontSize: 12.sp,
  //                       fontWeight: FontWeight.w700,
  //                       color: _O.text1,
  //                     ),
  //                   ),
  //                   SizedBox(height: 6.h),
  //                   if (displayItems.isEmpty)
  //                     Text(
  //                       'No items found',
  //                       style: TextStyle(fontSize: 12.sp, color: _O.text3),
  //                     )
  //                   else
  //                     ...displayItems.map((it) {
  //                       if (it is! Map) return const SizedBox.shrink();
  //                       return Padding(
  //                         padding: EdgeInsets.only(bottom: 6.h),
  //                         child: Row(
  //                           children: [
  //                             Container(
  //                               width: 4.r,
  //                               height: 4.r,
  //                               margin: EdgeInsets.only(right: 8.w),
  //                               decoration: BoxDecoration(
  //                                 shape: BoxShape.circle,
  //                                 color: orderType == 'CATERING'
  //                                     ? _O.cateringColor
  //                                     : _O.accent,
  //                               ),
  //                             ),
  //                             Expanded(
  //                               child: Text(
  //                                 '${it['itemName'] ?? '-'} × ${it['quantity'] ?? 1}',
  //                                 style: TextStyle(
  //                                   fontSize: 12.sp,
  //                                   color: _O.text2,
  //                                 ),
  //                               ),
  //                             ),
  //                             Text(
  //                               '₹${it['total'] ?? 0}',
  //                               style: TextStyle(
  //                                 fontSize: 12.sp,
  //                                 fontWeight: FontWeight.w600,
  //                                 color: _O.text1,
  //                               ),
  //                             ),
  //                           ],
  //                         ),
  //                       );
  //                     }),
  //                   SizedBox(height: 10.h),
  //                   Divider(height: 1, color: _O.border),
  //                   SizedBox(height: 6.h),
  //                   _buildTotalsSection(o, displayItems, orderType),
  //                   SizedBox(height: 10.h),
  //                 ],
  //               ),
  //             ),
  //           ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildHistoryCard(Map<String, dynamic> rawO) {
    final o = _normaliseOrder(rawO);
    final orderId = o['orderId'] ?? '-';
    final isExpanded = _expandedOrders.contains(orderId);
    final orderType = (o['orderType'] as String? ?? '').toUpperCase();
    final typeColor = _typeColor(orderType);
    final status =
        (orderType == 'CATERING' ? o['orderStatus'] : o['status']) as String? ??
        '';
    final bool isPos = o['userId'] == null;

    // Unify items (same as React formatItems logic)
    final rawItems = o['items'] as List?;
    final orderItems = o['order'] as List?;
    final displayItems = rawItems != null
        ? rawItems.map((it) {
            if (it is! Map) return it;
            return <String, dynamic>{
              'itemName': it['itemName'] ?? it['dishName'] ?? '-',
              'quantity': it['quantity'] ?? 1,
              'total': it['total'] ?? it['totalPrice'] ?? 0,
            };
          }).toList()
        : (orderItems ?? []).map((it) {
            if (it is! Map) return it;
            return <String, dynamic>{
              'itemName': it['dishName'] ?? '-',
              'quantity': it['quantity'] ?? 1,
              'total': it['totalPrice'] ?? it['total'] ?? 0,
            };
          }).toList();

    final borderColor = orderType == 'CATERING'
        ? _O.cateringColor
        : const Color(0xFFE66D33);

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: _O.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border(left: BorderSide(color: borderColor, width: 3)),
        boxShadow: [
          BoxShadow(
            color: _O.shadow,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Collapsed header ──────────────────────────────────────────────
          GestureDetector(
            onTap: () => setState(() {
              isExpanded
                  ? _expandedOrders.remove(orderId)
                  : _expandedOrders.add(orderId);
            }),
            child: Padding(
              padding: EdgeInsets.all(12.r),
              child: Row(
                children: [
                  Container(
                    width: 40.r,
                    height: 40.r,
                    decoration: BoxDecoration(
                      color: borderColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      _orderTypeIcon(orderType),
                      color: const Color(0xFF2E7D32),
                      size: 22.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Order ID + source badge + cancel button in one row ──
                        Row(
                          children: [
                            Text(
                              'Order #$orderId',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w800,
                                color: _O.accent,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            // ── Source badge (vendorId / userId) ──────────
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 4.h,
                              ),

                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isPos
                                        ? Icons.point_of_sale_rounded
                                        : Icons.smartphone_rounded,
                                    size: 11.sp,
                                    color: isPos ? _O.infBlue : _O.teal,
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    isPos ? 'POS' : 'User',
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.w700,
                                      color: isPos ? _O.infBlue : _O.teal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 8.w),
                            GestureDetector(
                              onTap: () => _cancelOrder(orderId),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10.w,
                                  vertical: 5.h,
                                ),
                                decoration: BoxDecoration(
                                  color: _O.red,
                                  borderRadius: BorderRadius.circular(6.r),
                                ),
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        Wrap(
                          spacing: 6.w,
                          runSpacing: 4.h,
                          children: [
                            _chip(
                              _orderTypeLabel(orderType),
                              typeColor,
                              typeColor.withOpacity(0.12),
                            ),
                            _chip(
                              _statusLabel(status),
                              _statusColor(status),
                              _statusColor(status).withOpacity(0.12),
                            ),
                            if (orderType == 'TABLE_DINE_IN' &&
                                (o['tableCode'] ?? '').toString().isNotEmpty)
                              _chip(
                                'Table: ${o['tableCode']}',
                                _O.amber,
                                _O.amberLight,
                              ),
                            if (orderType == 'CATERING' &&
                                (o['eventType'] ?? '').toString().isNotEmpty)
                              _chip(
                                o['eventType'].toString(),
                                _O.purple,
                                _O.purpleLight,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // ── Trailing: time (same place as before) + expand icon ──
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _fmtTimeOnly(o),
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: _O.text2,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Icon(
                        isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: _O.text3,
                        size: 20.sp,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Expanded detail ───────────────────────────────────────────────
          if (isExpanded)
            Container(
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: _O.border, width: 0.5)),
              ),
              child: Padding(
                padding: EdgeInsets.all(12.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _infoRow(Icons.schedule_rounded, _fmtDateTime(o)),
                    SizedBox(height: 8.h),
                    _infoRow(Icons.payment, o['paymentMethod'] ?? 'N/A'),
                    if ((o['userName'] ?? '').toString().isNotEmpty &&
                        o['userName'].toString() != 'null') ...[
                      SizedBox(height: 8.h),
                      _infoRow(
                        Icons.person_outline_rounded,
                        'Customer: ${o['userName']}',
                      ),
                    ],
                    SizedBox(height: 8.h),
                    _infoRow(
                      Icons.store_outlined,
                      o['vendorRegisteredName'] ?? 'Vendor',
                    ),
                    SizedBox(height: 8.h),

                    if (orderType == 'CATERING') ...[
                      if ((o['cateringDate'] ?? '').toString().isNotEmpty) ...[
                        SizedBox(height: 8.h),
                        _infoRow(
                          Icons.event_rounded,
                          'Catering Date: ${o['cateringDate']}',
                          iconColor: _O.green,
                          textColor: _O.green,
                        ),
                      ],
                      if ((o['deliveryAddress'] ?? '')
                          .toString()
                          .isNotEmpty) ...[
                        SizedBox(height: 8.h),
                        _infoRow(
                          Icons.location_on_rounded,
                          o['deliveryAddress'].toString(),
                          iconColor: _O.red,
                        ),
                      ],
                    ],
                    if (orderType == 'TABLE_DINE_IN' &&
                        (o['tableCode'] ?? '').toString().isNotEmpty) ...[
                      SizedBox(height: 8.h),
                      _infoRow(
                        Icons.table_restaurant_rounded,
                        'Table: ${o['tableCode']}',
                        textColor: _O.amber,
                      ),
                    ],
                    SizedBox(height: 12.h),
                    Divider(height: 1, color: _O.border),
                    SizedBox(height: 8.h),
                    Text(
                      'Order Items',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: _O.text1,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    if (displayItems.isEmpty)
                      Text(
                        'No items found',
                        style: TextStyle(fontSize: 12.sp, color: _O.text3),
                      )
                    else
                      ...displayItems.map((it) {
                        if (it is! Map) return const SizedBox.shrink();
                        return Padding(
                          padding: EdgeInsets.only(bottom: 6.h),
                          child: Row(
                            children: [
                              Container(
                                width: 4.r,
                                height: 4.r,
                                margin: EdgeInsets.only(right: 8.w),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: orderType == 'CATERING'
                                      ? _O.cateringColor
                                      : _O.accent,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  '${it['itemName'] ?? '-'} × ${it['quantity'] ?? 1}',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: _O.text2,
                                  ),
                                ),
                              ),
                              Text(
                                '₹${it['total'] ?? 0}',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color: _O.text1,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    SizedBox(height: 10.h),
                    Divider(height: 1, color: _O.border),
                    SizedBox(height: 6.h),
                    _buildTotalsSection(o, displayItems, orderType),
                    SizedBox(height: 10.h),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTotalsSection(Map o, List displayItems, String orderType) {
    final subtotal = displayItems.fold<double>(
      0.0,
      (s, it) => s + ((it['total'] as num?)?.toDouble() ?? 0.0),
    );
    final grandTotal = (o['grandTotal'] as num?)?.toDouble() ?? 0.0;
    final totalAmount = (o['totalAmount'] as num?)?.toDouble() ?? 0.0;
    final discount = (o['discountAmount'] as num?)?.toDouble() ?? 0.0;
    final taxCharges = totalAmount - subtotal;
    final displayTotal = grandTotal > 0 ? grandTotal : totalAmount;

    Row fRow(String label, String val, {Color? valColor}) => Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 11.sp, color: _O.text2),
        ),
        Text(
          val,
          style: TextStyle(
            fontSize: 11.sp,
            color: valColor ?? _O.text1,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );

    return Column(
      children: [
        fRow('Subtotal', '₹${subtotal.toStringAsFixed(2)}'),
        if (taxCharges > 0) ...[
          SizedBox(height: 3.h),
          fRow('Tax & Charges', '₹${taxCharges.toStringAsFixed(2)}'),
        ],
        if (discount > 0) ...[
          SizedBox(height: 3.h),
          fRow(
            'Discount',
            '-₹${discount.toStringAsFixed(2)}',
            valColor: _O.green,
          ),
        ],
        SizedBox(height: 6.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total Amount',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: _O.text1,
              ),
            ),
            Text(
              '₹${displayTotal.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w800,
                color: orderType == 'CATERING' ? _O.cateringColor : _O.accent,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Small widget helpers ──────────────────────────────────────────────────
  Widget _chip(String label, Color textColor, Color bgColor) => Container(
    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
    decoration: BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(12.r),
    ),
    child: Text(
      label,
      style: TextStyle(
        fontSize: 9.sp,
        fontWeight: FontWeight.w700,
        color: textColor,
      ),
    ),
  );

  Widget _infoRow(
    IconData icon,
    String text, {
    Color? iconColor,
    Color? textColor,
  }) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, size: 14.sp, color: iconColor ?? _O.text3),
      SizedBox(width: 6.w),
      Expanded(
        child: Text(
          text,
          style: TextStyle(fontSize: 12.sp, color: textColor ?? _O.text2),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );
}

// ─── Date-picker field ────────────────────────────────────────────────────────
class _DatePickerField extends StatelessWidget {
  final String label;
  final String value;
  final Function(String) onChanged;

  const _DatePickerField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value.isNotEmpty
              ? DateTime.parse(value)
              : DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );
        if (picked != null)
          onChanged(picked.toIso8601String().split('T').first);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              color: _O.text2,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 5.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: _O.bg,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: _O.border),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 14.sp,
                  color: _O.accent,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    value.isEmpty ? 'Select' : value,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: value.isEmpty ? _O.text3 : _O.text1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Pagination button ────────────────────────────────────────────────────────
class _PaginationBtn extends StatelessWidget {
  final String label;
  final bool enabled;
  final VoidCallback onTap;

  const _PaginationBtn({
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
        decoration: BoxDecoration(
          color: enabled ? _O.accentLight : _O.bg,
          borderRadius: BorderRadius.circular(6.r),
          border: Border.all(color: enabled ? _O.accent : _O.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: enabled ? _O.accent : _O.text3,
          ),
        ),
      ),
    );
  }
}

// ─── Date field ───────────────────────────────────────────────────────────────
class _DateField extends StatelessWidget {
  final String label;
  final String value;
  final Function(String) onChanged;

  const _DateField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value.isNotEmpty
              ? DateTime.parse(value)
              : DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );
        if (picked != null) {
          onChanged(picked.toIso8601String().split('T').first);
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: _O.bg,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: _O.border),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_rounded, size: 14.sp, color: _O.accent),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                value.isEmpty ? label : value,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: value.isEmpty ? _O.text3 : _O.text1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Pagination button ────────────────────────────────────────────────────────
class _PageBtn extends StatelessWidget {
  final String label;
  final bool enabled;
  final VoidCallback onTap;

  const _PageBtn({
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: enabled ? _O.accentLight : _O.bg,
          borderRadius: BorderRadius.circular(6.r),
          border: Border.all(color: enabled ? _O.accent : _O.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w600,
            color: enabled ? _O.accent : _O.text3,
          ),
        ),
      ),
    );
  }
}
