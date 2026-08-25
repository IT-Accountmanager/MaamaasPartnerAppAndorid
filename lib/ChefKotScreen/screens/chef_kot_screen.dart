import 'dart:async';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/kot_model.dart';
import '../services/api_service.dart';
import '../widgets/theme.dart';

// ─── Design tokens ──────────────────────────────────────────────────────────────
const _kW = Color(0xFFFFFFFF);
const _kBg = Color(0xFFF7F8FC);
const _kBrd = Color(0xFFEEEFF5);
const _kP = Color(0xFFB15DC6);
const _kPDk = Color(0xFF8B3FA0);
const _kPLt = Color(0xFFF5E8FA);
const _kSuc = Color(0xFF10B981);
const _kSLt = Color(0xFFD1FAE5);
const _kSDk = Color(0xFF059669);
const _kDng = Color(0xFFEF4444);
const _kDLt = Color(0xFFFEE2E2);
const _kWrn = Color(0xFFF59E0B);
const _kWLt = Color(0xFFFEF3C7);
const _kInf = Color(0xFF3B82F6);
const _kILt = Color(0xFFDBEAFE);
const _kT1 = Color(0xFF111827);
const _kT2 = Color(0xFF6B7280);
const _kT3 = Color(0xFFB0B3C1);
const _kShd = Color(0x0A000000);
const _kGrd = LinearGradient(
  colors: [_kP, _kPDk],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);
const _kMint = Color(0xFF20C997);
const _kMintLt = Color(0xFFD0F5EA);

const _kPrinterKey = 'default_printer_mac';

Color orderTypeColor(KotOrderType t) {
  switch (t) {
    case KotOrderType.table:
      return const Color(0xFF8B5CF6);
    case KotOrderType.delivery:
      return const Color(0xFF3B82F6);
    case KotOrderType.takeaway:
      return const Color(0xFF14B8A6);
    case KotOrderType.dineIn:
      return const Color(0xFFE66D33);
  }
}

Color orderTypeBadgeColor(KotOrderType t) {
  switch (t) {
    case KotOrderType.table:
      return const Color(0xFF8B5CF6);
    case KotOrderType.delivery:
      return const Color(0xFF3B82F6);
    case KotOrderType.takeaway:
      return const Color(0xFF14B8A6);
    case KotOrderType.dineIn:
      return const Color(0xFFE66D33);
  }
}

String orderTypeLabel(KotOrder o) {
  switch (o.orderType) {
    case KotOrderType.table:
      return 'Table ${o.tableNumber}';
    case KotOrderType.delivery:
      return 'Delivery';
    case KotOrderType.takeaway:
      return 'Takeaway';
    case KotOrderType.dineIn:
      return 'Dine In';
  }
}

Color statusDotColor(KotStatus s) {
  switch (s) {
    case KotStatus.pending:
      return _kWrn;
    case KotStatus.preparing:
      return _kSuc;
    case KotStatus.ready:
      return _kInf;
    case KotStatus.declined:
      return _kDng;
  }
}

String statusLabel(KotStatus s) {
  switch (s) {
    case KotStatus.pending:
      return 'PENDING';
    case KotStatus.preparing:
      return 'PREPARING';
    case KotStatus.ready:
      return 'READY';
    case KotStatus.declined:
      return 'DECLINED';
  }
}

class ChefKotScreen extends StatefulWidget {
  const ChefKotScreen({super.key});
  @override
  State<ChefKotScreen> createState() => _ChefKotScreenState();
}

class _ChefKotScreenState extends State<ChefKotScreen> {
  List<KotOrder> _orders = [];
  bool _loading = true;
  String? _error;

  // Decline
  String? _declineOrderId;
  String _selectedReason = '';
  String _declineNote = '';
  Map<dynamic, bool> _selectedItems = {};
  KotStatus? _filterStatus;

  // Poll
  Timer? _pollTimer;

  // ── Print state ────────────────────────────────────────────────────────────────
  bool _printSelected = true;
  String? _connectedPrinterMac;
  bool _isConnected = false;
  bool _isConnecting = false;

  // ── Sound / ringing state ──────────────────────────────────────────────────────
  final AudioPlayer _audioPlayer = AudioPlayer();
  Set<String> _pendingOrderIds = {};
  Set<String> _ringingOrderIds = {};
  Set<String> _acknowledgedOrderIds = {};
  bool _isPlaying = false;
  bool _isSoundEnabled = true;

  // Metrics
  int get _activeKot => _orders.length;
  int get _preparing =>
      _orders.where((o) => o.status == KotStatus.preparing).length;
  int get _chefAvailable => 4;

  List<KotOrder> get _filteredOrders {
    if (_filterStatus == null) return _orders;
    return _orders.where((o) => o.status == _filterStatus).toList();
  }

  // ── Lifecycle ──────────────────────────────────────────────────────────────────
  // @override
  // void initState() {
  //   super.initState();
  //   _initializeSound();
  //   _restorePrinterConnection();
  //   _fetch();
  //   _pollTimer = Timer.periodic(const Duration(seconds: 30), (_) {
  //     if (mounted) _fetchBackground();
  //   });
  // }

  // @override
  // void dispose() {
  //   _pollTimer?.cancel();
  //   _stopAllRinging();
  //   _audioPlayer.dispose();
  //   super.dispose();
  // }

  @override
  void initState() {
    super.initState();

    _initializeSound();
    _restorePrinterConnection();

    _fetch();

    ChefKotApi.startRealtimeUpdates(
      onNewOrder: (orders) {
        if (!mounted) return;

        setState(() {
          _orders = orders;
        });
      },
      onOrderUpdate: (update) {
        // debugPrint('📩 KOT WS Update: $update');
      },
    );

    _pollTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) _fetchBackground();
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();

    ChefKotApi.stopRealtimeUpdates();

    _stopAllRinging();
    _audioPlayer.dispose();

    super.dispose();
  }

  // ── Fetch ──────────────────────────────────────────────────────────────────────
  Future<void> _fetch() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final orders = await ChefKotApi.fetchOrders();
      if (mounted) {
        final prev = _orders.length;
        setState(() {
          _orders = orders;
          _loading = false;
        });
        if (orders.length > prev)
          _findAndRingNewOrders(prev, orders);
        else if (orders.length < prev)
          _cleanupCompletedOrders(orders);
      }
    } catch (e) {
      if (mounted)
        setState(() {
          _error = e.toString();
          _loading = false;
        });
    }
  }

  Future<void> _fetchBackground() async {
    try {
      final orders = await ChefKotApi.fetchOrders();
      if (mounted) {
        final prev = _orders.length;
        setState(() => _orders = orders);
        if (orders.length > prev)
          _findAndRingNewOrders(prev, orders);
        else if (orders.length < prev)
          _cleanupCompletedOrders(orders);
      }
    } catch (_) {}
  }

  // ── KOT actions ────────────────────────────────────────────────────────────────
  Future<void> _accept(KotOrder order) async {
    final selectedItemIds = order.orderType == KotOrderType.table
        ? _selectedItems.entries
              .where((e) => e.value)
              .map((e) => e.key)
              .toList()
        : <dynamic>[];

    if (order.orderType == KotOrderType.table && selectedItemIds.isEmpty) {
      showToast(context, 'Select at least one item', error: true);
      return;
    }

    if (_printSelected) {
      await _handleAcceptWithPrint(order);
      return;
    }

    try {
      await ChefKotApi.acceptOrder(order, selectedItemIds);
      _stopRingingForOrder(order.id.toString());
      if (mounted) {
        setState(() {
          final idx = _orders.indexWhere((o) => o.id == order.id);
          if (idx != -1) _orders[idx].status = KotStatus.preparing;
          _selectedItems.clear();
        });
        showToast(context, 'Order accepted ✅', desc: order.kotNumber);
      }
    } catch (e) {
      if (mounted)
        showToast(context, 'Accept failed', desc: e.toString(), error: true);
    }
  }

  Future<void> _confirmDecline() async {
    if (_declineOrderId == null) return;
    final order = _orders.firstWhere(
      (o) => o.id.toString() == _declineOrderId,
      orElse: () => throw '',
    );
    try {
      await ChefKotApi.declineOrder(order);
      if (mounted) {
        _stopRingingForOrder(_declineOrderId!);
        setState(() {
          _orders.removeWhere((o) => o.id.toString() == _declineOrderId);
          _declineOrderId = null;
          _selectedReason = '';
          _declineNote = '';
        });
        showToast(
          context,
          'Order declined',
          desc: _selectedReason,
          error: true,
        );
      }
    } catch (e) {
      if (mounted) showToast(context, 'Decline failed', error: true);
    }
  }

  Future<void> _markReady(KotOrder order) async {
    try {
      await ChefKotApi.markReady(order);
      if (mounted) {
        setState(() => _orders.removeWhere((o) => o.id == order.id));
        showToast(context, '${order.kotNumber} ready for pickup ✅');
      }
    } catch (e) {
      if (mounted) showToast(context, 'Mark ready failed', error: true);
    }
  }

  // ── Print functionality ────────────────────────────────────────────────────────
  Future<void> saveDefaultPrinter(String mac) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPrinterKey, mac);
  }

  Future<String?> getDefaultPrinter() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kPrinterKey);
  }

  Future<void> _restorePrinterConnection() async {
    try {
      final mac = await getDefaultPrinter();
      if (mac != null && mac.isNotEmpty) {
        final connected = await PrintBluetoothThermal.connect(
          macPrinterAddress: mac,
        );
        if (connected && await PrintBluetoothThermal.connectionStatus) {
          _connectedPrinterMac = mac;
          _isConnected = true;
        }
      }
    } catch (_) {
      _connectedPrinterMac = null;
      _isConnected = false;
    }
  }

  Future<void> _handleAcceptWithPrint(KotOrder order) async {
    setState(() => _isConnecting = true);
    try {
      final savedMac = await getDefaultPrinter();
      final bluetoothOn = await PrintBluetoothThermal.bluetoothEnabled;
      if (bluetoothOn && savedMac != null && savedMac.isNotEmpty) {
        bool connected = await PrintBluetoothThermal.connectionStatus;
        if (!connected) {
          await PrintBluetoothThermal.disconnect;
          await Future.delayed(const Duration(milliseconds: 300));
          connected = await PrintBluetoothThermal.connect(
            macPrinterAddress: savedMac,
          );
        }
        if (connected) {
          try {
            await _printThermalKot(order);
            await _acceptOrderAfterPrint(order);
            return;
          } catch (_) {
            if (mounted) _showPrinterSelectionDialog(order);
            return;
          }
        }
      }
      if (mounted) _showPrinterSelectionDialog(order);
    } finally {
      if (mounted) setState(() => _isConnecting = false);
    }
  }

  Future<void> _printThermalKot(KotOrder order) async {
    String makeRow(String l, String r) {
      int sp = 48 - l.length - r.length;
      return l + ' ' * (sp < 1 ? 1 : sp) + r;
    }

    await PrintBluetoothThermal.writeBytes(Uint8List.fromList([27, 97, 1]));
    await PrintBluetoothThermal.writeBytes(Uint8List.fromList([27, 69, 1]));
    await PrintBluetoothThermal.writeString(
      printText: PrintTextSize(size: 2, text: 'KOT: ${order.kotNumber}\n'),
    );
    await PrintBluetoothThermal.writeString(
      printText: PrintTextSize(
        size: 2,
        text: '------------------------------------------------\n',
      ),
    );
    await PrintBluetoothThermal.writeString(
      printText: PrintTextSize(
        size: 2,
        text:
            makeRow('Order : ${order.id}', 'Time  : ${order.orderTime}') + '\n',
      ),
    );
    await PrintBluetoothThermal.writeString(
      printText: PrintTextSize(
        size: 2,
        text: '------------------------------------------------\n',
      ),
    );
    await PrintBluetoothThermal.writeString(
      printText: PrintTextSize(
        size: 2,
        text: 'ITEM                           QTY\n',
      ),
    );
    await PrintBluetoothThermal.writeString(
      printText: PrintTextSize(
        size: 2,
        text: '------------------------------------------------\n',
      ),
    );
    for (final item in order.items) {
      String name = item.name;
      if (name.length > 26) name = name.substring(0, 26);
      await PrintBluetoothThermal.writeString(
        printText: PrintTextSize(
          size: 2,
          text:
              '${name.padRight(28)}${item.quantity.toString().padRight(10)}\n',
        ),
      );
    }
    await PrintBluetoothThermal.writeString(
      printText: PrintTextSize(
        size: 2,
        text: '------------------------------------------------\n',
      ),
    );
    await PrintBluetoothThermal.writeBytes([29, 86, 65, 0]);
    await PrintBluetoothThermal.writeBytes([27, 100, 2]);
  }

  void _showPrinterSelectionDialog(KotOrder order) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Row(
          children: [
            Container(
              width: 34.r,
              height: 34.r,
              decoration: BoxDecoration(
                color: _kILt,
                borderRadius: BorderRadius.circular(9.r),
              ),
              child: Icon(Icons.print_rounded, color: _kInf, size: 18.sp),
            ),
            SizedBox(width: 10.w),
            Text(
              'Select Printer',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w800,
                color: _kT1,
              ),
            ),
          ],
        ),
        content: FutureBuilder<List<BluetoothInfo>>(
          future: PrintBluetoothThermal.pairedBluetooths,
          builder: (_, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return SizedBox(
                height: 100.h,
                child: const Center(
                  child: CircularProgressIndicator(color: _kP, strokeWidth: 2),
                ),
              );
            }
            if (snap.data == null || snap.data!.isEmpty) {
              return SizedBox(
                height: 100.h,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.print_disabled_rounded,
                        size: 40.sp,
                        color: _kT3,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'No paired printers found',
                        style: TextStyle(color: _kT2, fontSize: 13.sp),
                      ),
                    ],
                  ),
                ),
              );
            }
            return SizedBox(
              height: 200.h,
              width: double.maxFinite,
              child: ListView.separated(
                itemCount: snap.data!.length,
                separatorBuilder: (_, __) =>
                    const Divider(color: _kBrd, height: 1),
                itemBuilder: (_, i) {
                  final p = snap.data![i];
                  return ListTile(
                    leading: Container(
                      width: 34.r,
                      height: 34.r,
                      decoration: BoxDecoration(
                        color: _kPLt,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(Icons.print_rounded, color: _kP, size: 17.sp),
                    ),
                    title: Text(
                      p.name,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: _kT1,
                      ),
                    ),
                    subtitle: Text(
                      p.macAdress,
                      style: TextStyle(fontSize: 10.sp, color: _kT2),
                    ),
                    trailing: GestureDetector(
                      onTap: () async {
                        Navigator.pop(context);
                        await _tryPrintWithSelectedPrinter(order, p);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          gradient: _kGrd,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          'Print',
                          style: TextStyle(
                            color: _kW,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _acceptWithoutPrint(order);
            },
            child: Text(
              'Accept Without Print',
              style: TextStyle(
                color: _kWrn,
                fontWeight: FontWeight.w600,
                fontSize: 13.sp,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: _kT2, fontSize: 13.sp),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _tryPrintWithSelectedPrinter(
    KotOrder order,
    BluetoothInfo printer,
  ) async {
    setState(() => _isConnecting = true);
    try {
      await PrintBluetoothThermal.connect(macPrinterAddress: printer.macAdress);
      await _printThermalKot(order);
      await saveDefaultPrinter(printer.macAdress);
      await _acceptOrderAfterPrint(order);
    } catch (e) {
      if (mounted) {
        showToast(context, 'Print failed', desc: e.toString(), error: true);
        _showPrinterSelectionDialog(order);
      }
    } finally {
      if (mounted) setState(() => _isConnecting = false);
    }
  }

  Future<void> _acceptOrderAfterPrint(KotOrder order) async {
    await ChefKotApi.acceptOrder(order, []);
    _stopRingingForOrder(order.id.toString());
    if (mounted) {
      setState(() {
        final idx = _orders.indexWhere((o) => o.id == order.id);
        if (idx != -1) _orders[idx].status = KotStatus.preparing;
        _selectedItems.clear();
      });
      showToast(context, 'Order accepted & printed ✅', desc: order.kotNumber);
    }
  }

  Future<void> _acceptWithoutPrint(KotOrder order) async {
    await ChefKotApi.acceptOrder(order, []);
    _stopRingingForOrder(order.id.toString());
    if (mounted) {
      setState(() {
        final idx = _orders.indexWhere((o) => o.id == order.id);
        if (idx != -1) _orders[idx].status = KotStatus.preparing;
        _selectedItems.clear();
      });
      showToast(context, 'Order accepted (no print)', desc: order.kotNumber);
    }
  }

  // ── Sound / ringing ────────────────────────────────────────────────────────────
  Future<void> _initializeSound() async {
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
  }

  Future<void> _startRingingForOrder(String orderId) async {
    if (!_isSoundEnabled || _isPlaying) return;
    try {
      _isPlaying = true;
      await _audioPlayer.play(AssetSource('school-bell-310293.mp3'));
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
      _acknowledgedOrderIds.add(orderId);
      if (_pendingOrderIds.isEmpty && _isPlaying) _stopAllRinging();
    }
  }

  void _triggerVibration() {
    try {
      HapticFeedback.lightImpact();
    } catch (_) {}
  }

  void _triggerOrderNotificationIfNeeded(KotOrder order) {
    final orderId = order.id.toString();
    if (order.status == KotStatus.pending &&
        !_acknowledgedOrderIds.contains(orderId) &&
        !_ringingOrderIds.contains(orderId)) {
      _pendingOrderIds.add(orderId);
      _ringingOrderIds.add(orderId);
      if (!_isPlaying && _isSoundEnabled) _startRingingForOrder(orderId);
      _triggerVibration();
    }
  }

  void _findAndRingNewOrders(int previousCount, List<KotOrder> current) {
    if (previousCount == 0) {
      for (var o in current) _triggerOrderNotificationIfNeeded(o);
      return;
    }
    final previousIds = _orders
        .take(previousCount)
        .map((o) => o.id.toString())
        .toSet();
    for (var o in current) {
      if (!previousIds.contains(o.id.toString()))
        _triggerOrderNotificationIfNeeded(o);
    }
  }

  void _cleanupCompletedOrders(List<KotOrder> current) {
    final currentIds = current.map((o) => o.id.toString()).toSet();
    final toRemove = _ringingOrderIds
        .where((id) => !currentIds.contains(id))
        .toList();
    for (var id in toRemove) {
      _pendingOrderIds.remove(id);
      _ringingOrderIds.remove(id);
      _acknowledgedOrderIds.remove(id);
    }
    if (_pendingOrderIds.isEmpty && _isPlaying) _stopAllRinging();
  }

  // ── Build ──────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: RefreshIndicator(
                    color: _kP,
                    onRefresh: _fetch,
                    child: CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(
                              14.w,
                              12.h,
                              14.w,
                              10.h,
                            ),
                            child: Row(
                              children: [
                                Text('📋', style: TextStyle(fontSize: 16.sp)),
                                SizedBox(width: 8.w),
                                Text(
                                  'Live KOT Panel',
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w800,
                                    color: _kT1,
                                  ),
                                ),
                                const Spacer(),
                                if (_orders.isNotEmpty)
                                  Text(
                                    '${_filteredOrders.length} order${_filteredOrders.length == 1 ? '' : 's'}',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: _kT2,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        if (_loading)
                          SliverFillRemaining(child: _loadingView())
                        else if (_error != null)
                          SliverFillRemaining(
                            child: _ErrView(msg: _error!, onRetry: _fetch),
                          )
                        else if (_filteredOrders.isEmpty)
                          SliverFillRemaining(
                            child: _EmptyView(onRefresh: _fetch),
                          )
                        else
                          SliverPadding(
                            padding: EdgeInsets.fromLTRB(
                              14.w,
                              0,
                              14.w,
                              bottom + 20.h,
                            ),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate((_, i) {
                                final order = _filteredOrders[i];
                                return _KotCard(
                                  order: order,
                                  selectedItems: _selectedItems,
                                  isConnecting: _isConnecting,
                                  onItemToggle: (id) => setState(
                                    () => _selectedItems[id] =
                                        !(_selectedItems[id] ?? false),
                                  ),
                                  onAccept: () => _accept(order),
                                  onDecline: () => setState(() {
                                    _declineOrderId = order.id.toString();
                                    _selectedReason = '';
                                    _declineNote = '';
                                  }),
                                  onMarkReady: () => _markReady(order),
                                );
                              }, childCount: _filteredOrders.length),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // ── Decline overlay ──────────────────────────────────────────────────
            if (_declineOrderId != null)
              _DeclineSheet(
                selectedReason: _selectedReason,
                note: _declineNote,
                onReasonSelected: (r) => setState(() => _selectedReason = r),
                onNoteChanged: (n) => setState(() => _declineNote = n),
                onCancel: () => setState(() => _declineOrderId = null),
                onConfirm: _confirmDecline,
                canConfirm:
                    _selectedReason.isNotEmpty || _declineNote.isNotEmpty,
              ),
          ],
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      color: _kW,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 10.h),
            child: Row(
              children: [
                // Back button
                if (Navigator.canPop(context))
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36.r,
                      height: 36.r,
                      margin: EdgeInsets.only(right: 10.w),
                      decoration: BoxDecoration(
                        color: _kBg,
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(color: _kBrd),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: _kT1,
                        size: 15.sp,
                      ),
                    ),
                  ),

                // Scrollable metric chips
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => setState(() => _filterStatus = null),
                          child: _metricChip(
                            label: 'Active',
                            value: _activeKot,
                            isActive: _filterStatus == null,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        GestureDetector(
                          onTap: () => setState(() {
                            _filterStatus = _filterStatus == KotStatus.preparing
                                ? null
                                : KotStatus.preparing;
                          }),
                          child: _metricChip(
                            label: 'Preparing',
                            value: _preparing,
                            isActive: _filterStatus == KotStatus.preparing,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        GestureDetector(
                          onTap: () => setState(() => _filterStatus = null),
                          child: _metricChip(
                            label: 'Chefs',
                            value: _chefAvailable,
                            isActive: false,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(width: 8.w),

                // Print toggle
                GestureDetector(
                  onTap: () {
                    setState(() => _printSelected = !_printSelected);
                    showToast(
                      context,
                      _printSelected
                          ? 'Printing Enabled ✅'
                          : 'Printing Disabled ❌',
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 7.h,
                    ),
                    decoration: BoxDecoration(
                      color: _printSelected ? _kILt : _kBg,
                      borderRadius: BorderRadius.circular(9.r),
                      border: Border.all(
                        color: _printSelected ? _kInf.withOpacity(0.3) : _kBrd,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.print_rounded,
                          color: _printSelected ? _kInf : _kT2,
                          size: 16.sp,
                        ),
                        SizedBox(width: 3.w),
                        Text(
                          _printSelected ? 'ON' : 'OFF',
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w800,
                            color: _printSelected ? _kInf : _kT2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(width: 6.w),

                // Sound toggle
                GestureDetector(
                  onTap: () {
                    setState(() => _isSoundEnabled = !_isSoundEnabled);
                    if (!_isSoundEnabled && _isPlaying) {
                      _stopAllRinging();
                    } else if (_isSoundEnabled &&
                        _pendingOrderIds.isNotEmpty &&
                        !_isPlaying) {
                      _startRingingForOrder(_pendingOrderIds.first);
                    }
                    showToast(
                      context,
                      _isSoundEnabled ? 'Sound ON 🔔' : 'Sound OFF 🔕',
                    );
                  },
                  child: Stack(
                    children: [
                      Container(
                        width: 36.r,
                        height: 36.r,
                        decoration: BoxDecoration(
                          color: _pendingOrderIds.isNotEmpty && _isPlaying
                              ? _kDng.withOpacity(0.1)
                              : _kBg,
                          borderRadius: BorderRadius.circular(9.r),
                          border: Border.all(
                            color: _pendingOrderIds.isNotEmpty && _isPlaying
                                ? _kDng.withOpacity(0.3)
                                : _kBrd,
                          ),
                        ),
                        child: Icon(
                          _isSoundEnabled
                              ? Icons.notifications_active_rounded
                              : Icons.notifications_off_rounded,
                          color: _pendingOrderIds.isNotEmpty && _isPlaying
                              ? _kDng
                              : _kT2,
                          size: 18.sp,
                        ),
                      ),
                      if (_pendingOrderIds.isNotEmpty && _isPlaying)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Container(
                            width: 7.r,
                            height: 7.r,
                            decoration: const BoxDecoration(
                              color: _kDng,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: _kBrd),
        ],
      ),
    );
  }

  Widget _loadingView() => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularProgressIndicator(color: _kP, strokeWidth: 2),
        SizedBox(height: 12.h),
        Text(
          'Loading orders...',
          style: TextStyle(color: _kT2, fontSize: 13.sp),
        ),
      ],
    ),
  );
}

// ── Metric Chip ────────────────────────────────────────────────────────────────
Widget _metricChip({
  required String label,
  required int value,
  required bool isActive,
}) {
  return AnimatedContainer(
    duration: const Duration(milliseconds: 200),
    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
    decoration: BoxDecoration(
      color: isActive ? Colors.green : const Color(0xFFE66D33),
      borderRadius: BorderRadius.circular(10.r),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$value',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        SizedBox(width: 5.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    ),
  );
}

// ── KOT Card ───────────────────────────────────────────────────────────────────
class _KotCard extends StatelessWidget {
  final KotOrder order;
  final Map<dynamic, bool> selectedItems;
  final bool isConnecting;
  final ValueChanged<dynamic> onItemToggle;
  final VoidCallback onAccept, onDecline, onMarkReady;

  const _KotCard({
    required this.order,
    required this.selectedItems,
    required this.isConnecting,
    required this.onItemToggle,
    required this.onAccept,
    required this.onDecline,
    required this.onMarkReady,
  });

  @override
  Widget build(BuildContext context) {
    final typeColor = orderTypeColor(order.orderType);
    final badgeColor = orderTypeBadgeColor(order.orderType);
    final dotColor = statusDotColor(order.status);
    final isPreparing = order.status == KotStatus.preparing;

    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      decoration: BoxDecoration(
        color: _kW,
        borderRadius: BorderRadius.circular(14.r),
        border: Border(left: BorderSide(color: typeColor, width: 4)),
        boxShadow: [
          BoxShadow(color: _kShd, blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(14.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header row ─────────────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: Text(
                    order.kotNumber,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                      color: _kT1,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    orderTypeLabel(order),
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      color: _kW,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),

            // ── Status dot ─────────────────────────────────────────────────────
            Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 10.r,
                  height: 10.r,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                    boxShadow: isPreparing
                        ? [
                            BoxShadow(
                              color: dotColor.withOpacity(0.5),
                              blurRadius: 6,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  statusLabel(order.status),
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: dotColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),

            // ── Time row ───────────────────────────────────────────────────────
            // order.orderTime is already IST-formatted in kot_model.dart
            Row(
              children: [
                Icon(Icons.access_time_rounded, size: 13.sp, color: _kT3),
                SizedBox(width: 4.w),
                Text(
                  order.orderTime.isNotEmpty ? order.orderTime : 'N/A',
                  style: TextStyle(fontSize: 12.sp, color: _kT2),
                ),
                SizedBox(width: 14.w),
                Icon(Icons.timer_outlined, size: 13.sp, color: _kT3),
                SizedBox(width: 4.w),
                Text(
                  '~${order.estimatedPrepTime} min',
                  style: TextStyle(fontSize: 12.sp, color: _kT3),
                ),
              ],
            ),
            SizedBox(height: 10.h),

            // ── Items container ────────────────────────────────────────────────
            Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color: _kBg,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: _kBrd),
              ),
              child: Column(
                children: order.items.asMap().entries.map((e) {
                  final item = e.value;
                  final isLast = e.key == order.items.length - 1;
                  return Column(
                    children: [
                      Row(
                        children: [
                          if (order.orderType == KotOrderType.table &&
                              order.status == KotStatus.pending) ...[
                            SizedBox(
                              width: 22.r,
                              height: 22.r,
                              child: Checkbox(
                                value: selectedItems[item.itemId] ?? false,
                                onChanged: (_) => onItemToggle(item.itemId),
                                activeColor: _kP,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                            SizedBox(width: 6.w),
                          ],
                          Expanded(
                            child: Text(
                              item.name,
                              style: TextStyle(fontSize: 13.sp, color: _kT1),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: _kPLt,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text(
                              '×${item.quantity}',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w800,
                                color: _kP,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (!isLast) Divider(height: 10.h, color: _kBrd),
                    ],
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 12.h),

            // ── Action buttons ─────────────────────────────────────────────────
            _ActionButtons(
              status: order.status,
              isConnecting: isConnecting,
              onAccept: onAccept,
              onDecline: onDecline,
              onMarkReady: onMarkReady,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Action Buttons ─────────────────────────────────────────────────────────────
class _ActionButtons extends StatelessWidget {
  final KotStatus status;
  final bool isConnecting;
  final VoidCallback onAccept, onDecline, onMarkReady;

  const _ActionButtons({
    required this.status,
    required this.isConnecting,
    required this.onAccept,
    required this.onDecline,
    required this.onMarkReady,
  });

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case KotStatus.pending:
        return Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: isConnecting ? null : onAccept,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 42.h,
                  decoration: BoxDecoration(
                    color: isConnecting ? _kBrd : null,
                    gradient: isConnecting
                        ? null
                        : const LinearGradient(colors: [_kSuc, _kSDk]),
                    borderRadius: BorderRadius.circular(9.r),
                    boxShadow: isConnecting
                        ? null
                        : [
                            BoxShadow(
                              color: _kSuc.withOpacity(0.25),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                  ),
                  child: Center(
                    child: isConnecting
                        ? SizedBox(
                            width: 18.r,
                            height: 18.r,
                            child: const CircularProgressIndicator(
                              color: _kT2,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            '✅  Accept',
                            style: TextStyle(
                              color: _kW,
                              fontWeight: FontWeight.w700,
                              fontSize: 13.sp,
                            ),
                          ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: _Btn(label: '❌  Decline', color: _kDng, onTap: onDecline),
            ),
          ],
        );

      case KotStatus.preparing:
        return _PulseBtn(label: '🍽️  Mark Ready', onTap: onMarkReady);

      case KotStatus.ready:
        return Container(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: _kSLt,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Center(
            child: Text(
              '✅  Ready for pickup',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: _kSDk,
              ),
            ),
          ),
        );

      case KotStatus.declined:
        return Container(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: _kDLt,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Center(
            child: Text(
              '❌  Declined',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: _kDng,
              ),
            ),
          ),
        );
    }
  }
}

class _Btn extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _Btn({required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      height: 42.h,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(9.r),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.25),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: _kW,
            fontWeight: FontWeight.w700,
            fontSize: 13.sp,
          ),
        ),
      ),
    ),
  );
}

class _PulseBtn extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  const _PulseBtn({required this.label, required this.onTap});
  @override
  State<_PulseBtn> createState() => _PulseBtnState();
}

class _PulseBtnState extends State<_PulseBtn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _anim = Tween(
      begin: 0.0,
      end: 6.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _anim,
    builder: (_, child) => Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(9.r),
        boxShadow: [
          BoxShadow(
            color: _kSuc.withOpacity(0.45),
            blurRadius: _anim.value,
            spreadRadius: _anim.value / 3,
          ),
        ],
      ),
      child: child,
    ),
    child: GestureDetector(
      onTap: widget.onTap,
      child: Container(
        height: 44.h,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [_kSuc, _kSDk]),
          borderRadius: BorderRadius.circular(9.r),
        ),
        child: Center(
          child: Text(
            widget.label,
            style: TextStyle(
              color: _kW,
              fontWeight: FontWeight.w800,
              fontSize: 14.sp,
            ),
          ),
        ),
      ),
    ),
  );
}

// ── Decline Sheet ──────────────────────────────────────────────────────────────
class _DeclineSheet extends StatelessWidget {
  final String selectedReason, note;
  final ValueChanged<String> onReasonSelected, onNoteChanged;
  final VoidCallback onCancel, onConfirm;
  final bool canConfirm;

  const _DeclineSheet({
    required this.selectedReason,
    required this.note,
    required this.onReasonSelected,
    required this.onNoteChanged,
    required this.onCancel,
    required this.onConfirm,
    required this.canConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final keyboard = MediaQuery.of(context).viewInsets.bottom;
    return GestureDetector(
      onTap: onCancel,
      child: Container(
        color: Colors.black54,
        child: Center(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: _kW,
                borderRadius: BorderRadius.circular(18.r),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, keyboard + 20.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 36.w,
                        height: 4.h,
                        margin: EdgeInsets.only(bottom: 14.h),
                        decoration: BoxDecoration(
                          color: _kBrd,
                          borderRadius: BorderRadius.circular(2.r),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8.r),
                          decoration: BoxDecoration(
                            color: _kDLt,
                            borderRadius: BorderRadius.circular(9.r),
                          ),
                          child: Icon(
                            Icons.cancel_rounded,
                            color: _kDng,
                            size: 18.sp,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Reason for Decline',
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w800,
                                  color: _kT1,
                                ),
                              ),
                              Text(
                                'Select or enter a reason',
                                style: TextStyle(fontSize: 11.sp, color: _kT2),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: onCancel,
                          child: Container(
                            padding: EdgeInsets.all(5.r),
                            decoration: BoxDecoration(
                              color: _kBg,
                              borderRadius: BorderRadius.circular(7.r),
                            ),
                            child: Icon(
                              Icons.close_rounded,
                              color: _kT2,
                              size: 16.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: kDeclineReasons.map((r) {
                        final isActive = selectedReason == r;
                        return GestureDetector(
                          onTap: () => onReasonSelected(r),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 7.h,
                            ),
                            decoration: BoxDecoration(
                              color: isActive ? _kDng : _kBg,
                              border: Border.all(
                                color: isActive ? _kDng : _kBrd,
                                width: isActive ? 1.5 : 1,
                              ),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Text(
                              r,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: isActive ? _kW : _kT1,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 14.h),
                    Text(
                      'Additional notes',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: _kT2,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Container(
                      decoration: BoxDecoration(
                        color: _kBg,
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(color: _kBrd),
                      ),
                      child: TextField(
                        onChanged: onNoteChanged,
                        maxLines: 3,
                        style: TextStyle(fontSize: 13.sp, color: _kT1),
                        decoration: InputDecoration(
                          hintText: 'Additional notes...',
                          hintStyle: TextStyle(color: _kT3, fontSize: 13.sp),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(12.r),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.r),
                            borderSide: const BorderSide(
                              color: _kDng,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: onCancel,
                            child: Container(
                              height: 44.h,
                              decoration: BoxDecoration(
                                color: _kBg,
                                borderRadius: BorderRadius.circular(9.r),
                                border: Border.all(color: _kBrd),
                              ),
                              child: Center(
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(
                                    color: _kT2,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13.sp,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: GestureDetector(
                            onTap: canConfirm ? onConfirm : null,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              height: 44.h,
                              decoration: BoxDecoration(
                                color: canConfirm ? _kDng : _kBrd,
                                borderRadius: BorderRadius.circular(9.r),
                                boxShadow: canConfirm
                                    ? [
                                        BoxShadow(
                                          color: _kDng.withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Center(
                                child: Text(
                                  'Confirm Decline',
                                  style: TextStyle(
                                    color: _kW,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13.sp,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
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
}

// ── Empty View ─────────────────────────────────────────────────────────────────
class _EmptyView extends StatelessWidget {
  final VoidCallback onRefresh;
  const _EmptyView({required this.onRefresh});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 72.r,
          height: 72.r,
          decoration: BoxDecoration(
            gradient: _kGrd,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: _kP.withOpacity(0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: Text('🍽️', style: TextStyle(fontSize: 30.sp)),
          ),
        ),
        SizedBox(height: 16.h),
        Text(
          'No orders right now',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: _kT1,
          ),
        ),
        SizedBox(height: 5.h),
        Text(
          'New KOTs will appear here automatically',
          style: TextStyle(fontSize: 13.sp, color: _kT2),
        ),
        SizedBox(height: 20.h),
        GestureDetector(
          onTap: onRefresh,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            decoration: BoxDecoration(
              gradient: _kGrd,
              borderRadius: BorderRadius.circular(10.r),
              boxShadow: [
                BoxShadow(
                  color: _kP.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.refresh_rounded, color: _kW, size: 16.sp),
                SizedBox(width: 6.w),
                Text(
                  'Refresh',
                  style: TextStyle(
                    color: _kW,
                    fontWeight: FontWeight.w700,
                    fontSize: 13.sp,
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

// ── Error View ─────────────────────────────────────────────────────────────────
class _ErrView extends StatelessWidget {
  final String msg;
  final VoidCallback onRetry;
  const _ErrView({required this.msg, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: EdgeInsets.all(24.r),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60.r,
            height: 60.r,
            decoration: const BoxDecoration(
              color: _kDLt,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.error_outline_rounded, color: _kDng, size: 28.sp),
          ),
          SizedBox(height: 14.h),
          Text(
            'Error loading orders',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: _kT1,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            msg,
            style: TextStyle(fontSize: 12.sp, color: _kT2),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 18.h),
          GestureDetector(
            onTap: onRetry,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              decoration: BoxDecoration(
                gradient: _kGrd,
                borderRadius: BorderRadius.circular(10.r),
                boxShadow: [
                  BoxShadow(
                    color: _kP.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.refresh_rounded, color: _kW, size: 16.sp),
                  SizedBox(width: 6.w),
                  Text(
                    'Retry',
                    style: TextStyle(
                      color: _kW,
                      fontWeight: FontWeight.w700,
                      fontSize: 13.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
