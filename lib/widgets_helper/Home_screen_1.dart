
import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:shimmer/shimmer.dart';
import '../API/APIclient.dart';
import '../CampaignScreens/CampaignDetailScreen.dart';
import '../ChefKotScreen/screens/chef_kot_screen.dart';
import '../Registration01/screens/food_registration_screen.dart';
import '../Report&Analysis/screens/reports_screen.dart';
import '../SUB01/screens/main_screen.dart';
import '../Setting & Control/screens/SettingScreen.dart';
import '../SettlementScreen/screens/finance_screen.dart';
import '../SupportScreen/screens/support_screen.dart';
import '../TeamManagement/screens/team_directory_screen.dart';
import '../caterings/Leads.dart';
import '../food&beverages/AddEmployee.dart';
import '../food&beverages/Company.dart';
import '../food&beverages/Deals.dart';
import '../food&beverages/Delivery_management.dart';
import '../food&beverages/ScheduleOrdersPage.dart';
import '../food&beverages/Inventory_management.dart';
import '../food&beverages/Menu_managemnet.dart';
import '../food&beverages/PromotionsDiscounts.dart';
import '../food&beverages/Settings&Controls.dart';
import '../food&beverages/TableManagementPage.dart';
import '../food&beverages/order_management.dart';
import '../food&beverages/support_team.dart';
import '../login_screen.dart';
import '../standard Menu/screens/standard_menu_screen.dart';
import '../user_module/screens/saved_address.dart' show SavedAddress;
import '../Api/food_authservice.dart';
import '../Report&Analysis/models/report_models.dart';
import '../Report&Analysis/services/report_service.dart';
import '../Api/NotificationService.dart';
import '../Setting & Control/services/api_service.dart';
import 'food/SessionInfoScreen.dart';

// ─── Design Tokens ─────────────────────────────────────────────────────────────
class _H {
  static const bg = Color(0xFFF7F8FC);
  static const white = Color(0xFFFFFFFF);
  static const border = Color(0xFFEEEFF5);
  static const accent = Color(0xFFE66D33);
  static const accentDark = Color(0xFFE66D33);
  static const accentLight = Color(0xFFF5E8FA);
  static const amber = Color(0xFFF59E0B);
  static const amberLight = Color(0xFFFEF3C7);
  static const green = Color(0xFF10B981);
  static const greenLight = Color(0xFFD1FAE5);
  static const blue = Color(0xFF3B82F6);
  static const blueLight = Color(0xFFDBEAFE);
  static const red = Color(0xFFEF4444);
  static const purpleLight = Color(0xFFEDE9FE);
  static const redLight = Color(0xFFFEE2E2);
  static const purple = Color(0xFF8B5CF6);
  static const teal = Color(0xFF14B8A6);
  static const text1 = Color(0xFF111827);
  static const text2 = Color(0xFF6B7280);
  static const text3 = Color(0xFF000000);
  static const shadow = Color(0x0A000000);
  static const shadowMd = Color(0x1A000000);
}

// ─── Shimmer Helpers ──────────────────────────────────────────────────────────
class _ShimmerBox extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  const _ShimmerBox({this.width, this.height, this.borderRadius});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: borderRadius ?? BorderRadius.circular(8),
      ),
    );
  }
}

Widget _shimmerWrap({required Widget child}) {
  return Shimmer.fromColors(
    baseColor: _H.border,
    highlightColor: _H.bg,
    child: child,
  );
}

// Shimmer replacement for the Today's Revenue/Orders/Rating stats row.
class _StatsRowShimmer extends StatelessWidget {
  const _StatsRowShimmer();

  @override
  Widget build(BuildContext context) {
    Widget cell() => Column(
      children: [
        _ShimmerBox(
          width: 38,
          height: 38,
          borderRadius: BorderRadius.circular(10),
        ),
        const SizedBox(height: 6),
        _ShimmerBox(width: 40, height: 14),
        const SizedBox(height: 4),
        _ShimmerBox(width: 60, height: 9),
      ],
    );
    return _shimmerWrap(
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
        decoration: BoxDecoration(
          color: _H.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _H.border),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          child: Row(
            children: [
              Expanded(child: cell()),
              Container(width: 1, height: 44, color: _H.border),
              Expanded(child: cell()),
              Container(width: 1, height: 44, color: _H.border),
              Expanded(child: cell()),
            ],
          ),
        ),
      ),
    );
  }
}

// Generic shimmer card matching the rounded white card style used across
// the dashboard (order types, order status, collection summary, etc).
class _DashCardShimmer extends StatelessWidget {
  final double height;
  const _DashCardShimmer({this.height = 130});

  @override
  Widget build(BuildContext context) {
    return _shimmerWrap(
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
        height: height,
        decoration: BoxDecoration(
          color: _H.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _H.border),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _ShimmerBox(
                    width: 28,
                    height: 28,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  const SizedBox(width: 8),
                  _ShimmerBox(width: 110, height: 14),
                ],
              ),
              const SizedBox(height: 16),
              _ShimmerBox(height: 10, width: double.infinity),
              const SizedBox(height: 10),
              _ShimmerBox(height: 10, width: double.infinity),
              const SizedBox(height: 10),
              _ShimmerBox(height: 10, width: 160),
            ],
          ),
        ),
      ),
    );
  }
}

// Shimmer for the Top Selling Items chart card.
class _TopSellingShimmer extends StatelessWidget {
  const _TopSellingShimmer();

  @override
  Widget build(BuildContext context) {
    return _shimmerWrap(
      child: Container(
        decoration: BoxDecoration(
          color: _H.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _H.border),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _ShimmerBox(
                    width: 28,
                    height: 28,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  const SizedBox(width: 8),
                  _ShimmerBox(width: 130, height: 14),
                ],
              ),
              const SizedBox(height: 16),
              ...List.generate(
                4,
                (i) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      _ShimmerBox(
                        width: 32,
                        height: 32,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: _ShimmerBox(height: 12)),
                      const SizedBox(width: 12),
                      _ShimmerBox(width: 24, height: 14),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Shimmer for the banner/campaign carousel.
class _BannerShimmer extends StatelessWidget {
  const _BannerShimmer();

  @override
  Widget build(BuildContext context) {
    return _shimmerWrap(
      child: Container(
        color: Colors.white,
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _ShimmerBox(width: 160, height: 20),
                const SizedBox(height: 8),
                _ShimmerBox(width: 110, height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Shimmer for the Bluetooth printer device list.
class _PrinterListShimmer extends StatelessWidget {
  const _PrinterListShimmer();

  @override
  Widget build(BuildContext context) {
    return _shimmerWrap(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: 3,
        itemBuilder: (_, __) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _H.bg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _H.border),
          ),
          child: Row(
            children: [
              _ShimmerBox(
                width: 34,
                height: 34,
                borderRadius: BorderRadius.circular(8),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ShimmerBox(height: 12, width: 120),
                    const SizedBox(height: 6),
                    _ShimmerBox(height: 10, width: 90),
                  ],
                ),
              ),
              _ShimmerBox(
                width: 50,
                height: 26,
                borderRadius: BorderRadius.circular(8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Shimmer for the full-screen role-loading state.
class _ScaffoldLoadingShimmer extends StatelessWidget {
  const _ScaffoldLoadingShimmer();

  @override
  Widget build(BuildContext context) {
    return _shimmerWrap(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ShimmerBox(
                height: 180,
                width: double.infinity,
                borderRadius: BorderRadius.circular(20),
              ),
              const SizedBox(height: 16),
              _ShimmerBox(
                height: 96,
                width: double.infinity,
                borderRadius: BorderRadius.circular(16),
              ),
              const SizedBox(height: 14),
              _ShimmerBox(
                height: 130,
                width: double.infinity,
                borderRadius: BorderRadius.circular(16),
              ),
              const SizedBox(height: 14),
              _ShimmerBox(
                height: 110,
                width: double.infinity,
                borderRadius: BorderRadius.circular(16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Shared print helpers (used by the New Order popup) ───────────────────────

String formatOrderType(String? t) {
  switch ((t ?? '').toUpperCase()) {
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

Future<void> printOrderReceipt(Map<String, dynamic> rawOrder) async {
  final orderId = rawOrder['orderId'] ?? rawOrder['cartId'] ?? '-';
  final orderType = (rawOrder['orderType'] ?? '').toString();
  final tableCode = (rawOrder['tableCode'] ?? '').toString();
  final now = DateTime.now();
  final dateStr = DateFormat('dd/MM/yyyy').format(now);
  final timeStr = DateFormat('hh:mm a').format(now);

  final cartItems = rawOrder['cartItems'] as List? ?? [];
  final orderItems = rawOrder['order'] as List? ?? [];
  final items = orderItems.isNotEmpty ? orderItems : cartItems;

  final vendorName =
      rawOrder['vendorRegisteredName'] ??
      rawOrder['companyName'] ??
      'RESTAURANT';

  await PrintBluetoothThermal.writeBytes(Uint8List.fromList([27, 97, 1]));
  await PrintBluetoothThermal.writeBytes(Uint8List.fromList([27, 69, 1]));
  await PrintBluetoothThermal.writeString(
    printText: PrintTextSize(size: 2, text: '$vendorName\n'),
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
      text: makeRow('Order ID : $orderId', 'Date : $dateStr') + '\n',
    ),
  );
  final rightInfo = tableCode.isNotEmpty
      ? 'Table: $tableCode'
      : 'Time : $timeStr';
  await PrintBluetoothThermal.writeString(
    printText: PrintTextSize(
      size: 2,
      text:
          makeRow('Type     : ${formatOrderType(orderType)}', rightInfo) + '\n',
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
    printText: PrintTextSize(size: 2, text: 'ITEM                       QTY\n'),
  );
  await PrintBluetoothThermal.writeBytes(Uint8List.fromList([27, 33, 0]));
  await PrintBluetoothThermal.writeString(
    printText: PrintTextSize(
      size: 2,
      text: '------------------------------------------------\n',
    ),
  );

  for (var item in items) {
    if (item is! Map) continue;
    String dishName = (item['dishName'] ?? item['itemsName'] ?? 'N/A')
        .toString();
    if (dishName.length > 26) dishName = dishName.substring(0, 26);
    final qty = (item['quantity'] ?? 1).toString();
    await PrintBluetoothThermal.writeString(
      printText: PrintTextSize(
        size: 2,
        text: '${dishName.padRight(28)}${qty.padRight(10)}\n',
      ),
    );

    // ── Print addons under the item, indented ──
    final addons = (item['addons'] as List? ?? [])
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .where((a) => (a['addonName'] ?? '').toString().isNotEmpty)
        .toList();

    for (final addon in addons) {
      String addonName = (addon['addonName'] ?? '').toString();
      if (addonName.length > 24) addonName = addonName.substring(0, 24);
      final addonQty = (addon['quantity'] ?? 1).toString();
      await PrintBluetoothThermal.writeString(
        printText: PrintTextSize(
          size: 2,
          text: '  + ${addonName.padRight(24)}$addonQty\n',
        ),
      );
    }
  }

  await PrintBluetoothThermal.writeString(
    printText: PrintTextSize(
      size: 2,
      text: '------------------------------------------------\n',
    ),
  );
  await PrintBluetoothThermal.writeString(
    printText: PrintTextSize(size: 2, text: '\n\n\n\n\n\n'),
  );
}

// ─── HomeWrapper ───────────────────────────────────────────────────────────────
class HomeWrapper extends StatefulWidget {
  const HomeWrapper({Key? key}) : super(key: key);
  @override
  State<HomeWrapper> createState() => _HomeWrapperState();
}

class _HomeWrapperState extends State<HomeWrapper> {
  int _selectedFooterIndex = 0;

  String planType = 'BASIC';
  bool _updateAvailable = false;
  AppUpdateInfo? _updateInfo;
  String? _addressFromApi;

  Timer? _newOrderPollingTimer;
  Set<String> _seenOrderIds = {};
  List<Map<String, dynamic>> _pendingPopupOrders = [];
  bool _orderPopupVisible = false; // guards against stacking multiple popups

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String _role = 'ROLE_VENDOR';
  List<BusinessModules> _employeeModules = [];
  bool _roleLoaded = false;

  // Sound control
  bool _isSoundEnabled = true;
  bool _printEnabled = true;
  static const String _kDefaultPrinterKey = 'default_printer_mac';

  // ── Restaurant online/offline status ────────────────────────────────────────
  bool _isOnline = false;
  bool _statusBusy = false;
  bool _statusLoading = true;

  // Cached future so FutureBuilder doesn't refetch on every setState/toggle
  Future<Map<String, dynamic>?>? _vendorDetailsFuture;

  @override
  void initState() {
    super.initState();
    _vendorDetailsFuture = _fetchVendorDetails();
    _loadLocationFromAPI();
    _checkForUpdate();
    _loadPlanType();
    _loadRoleAndModules();
    _startOrderPolling();
    _loadSoundPreference();
    _loadRestaurantStatus(); // ← NEW
  }

  // ─── Restaurant Status Methods ──────────────────────────────────────────────

  Future<void> _loadRestaurantStatus() async {
    dev.log('[HomeWrapper] _loadRestaurantStatus — fetching...', name: 'HW');
    if (mounted) setState(() => _statusLoading = true);
    try {
      final online = await RestaurantStatusApi.fetchStatus();
      dev.log(
        '[HomeWrapper] _loadRestaurantStatus — online=$online',
        name: 'HW',
      );
      if (mounted) setState(() => _isOnline = online);
    } catch (e, stack) {
      dev.log(
        '[HomeWrapper] _loadRestaurantStatus — ERROR: $e',
        name: 'HW',
        error: e,
        stackTrace: stack,
      );
    } finally {
      if (mounted) setState(() => _statusLoading = false);
    }
  }

  Future<void> _toggleRestaurantStatus(bool val) async {
    dev.log(
      '[HomeWrapper] _toggleRestaurantStatus — TAP RECEIVED val=$val (current _isOnline=$_isOnline)',
      name: 'HW',
    );
    if (val) {
      setState(() {
        _isOnline = true;
        _statusBusy = true;
      });
      try {
        dev.log(
          '[HomeWrapper] calling RestaurantStatusApi.setOnline()...',
          name: 'HW',
        );
        await RestaurantStatusApi.setOnline();
        dev.log('[HomeWrapper] setOnline() SUCCESS', name: 'HW');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Restaurant is now Open ✅',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: _H.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } catch (e, stack) {
        dev.log(
          '[HomeWrapper] setOnline() FAILED: $e',
          name: 'HW',
          error: e,
          stackTrace: stack,
        );
        if (mounted) {
          setState(() => _isOnline = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to go online: $e'),
              backgroundColor: _H.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _statusBusy = false);
        dev.log('[HomeWrapper] toggle done. _isOnline=$_isOnline', name: 'HW');
      }
    } else {
      dev.log('[HomeWrapper] going offline, showing reason sheet', name: 'HW');
      _showOfflineReasonSheet();
    }
  }

  void _showOfflineReasonSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _OfflineSheet(
        onConfirm: (reasons) async {
          dev.log(
            '[HomeWrapper] offline confirmed, reasons=$reasons',
            name: 'HW',
          );
          Navigator.pop(context);
          setState(() {
            _isOnline = false;
            _statusBusy = true;
          });
          try {
            dev.log(
              '[HomeWrapper] calling RestaurantStatusApi.setOffline()...',
              name: 'HW',
            );
            await RestaurantStatusApi.setOffline(reasons);
            dev.log('[HomeWrapper] setOffline() SUCCESS', name: 'HW');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text(
                    'Restaurant is now Closed',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: _H.red,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          } catch (e, stack) {
            dev.log(
              '[HomeWrapper] setOffline() FAILED: $e',
              name: 'HW',
              error: e,
              stackTrace: stack,
            );
            if (mounted) {
              setState(() => _isOnline = true);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to go offline: $e'),
                  backgroundColor: _H.red,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            }
          } finally {
            if (mounted) setState(() => _statusBusy = false);
          }
        },
        onCancel: () => Navigator.pop(context),
      ),
    );
  }

  // ─── Sound Control Methods ──────────────────────────────────────────────────

  Future<void> _loadSoundPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getBool('notification_sound_enabled') ?? true;
    setState(() => _isSoundEnabled = saved);
    NotificationService.toggleSound(saved);
  }

  Future<void> _saveSoundPreference(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notification_sound_enabled', enabled);
  }

  @override
  void dispose() {
    _newOrderPollingTimer?.cancel();
    NotificationService.stopOrderSound();
    super.dispose();
  }

  Future<void> _loadRoleAndModules() async {
    final prefs = await SharedPreferences.getInstance();
    final storedRole = prefs.getString('role') ?? 'ROLE_VENDOR';
    List<BusinessModules> resolved = [];
    if (storedRole == 'ROLE_EMPLOYEE') {
      final businessModules = prefs.getStringList('businessModules') ?? [];
      resolved = businessModules
          .map((m) => SessionInfo.backendToEnum[m])
          .whereType<String>()
          .map(
            (enumName) => BusinessModules.values.firstWhere(
              (bm) => bm.toString().split('.').last == enumName,
              orElse: () => BusinessModules.subscription,
            ),
          )
          .toList();
    }
    if (mounted) {
      setState(() {
        _role = storedRole;
        _employeeModules = resolved;
        _roleLoaded = true;
      });
    }
  }

  Future<void> _loadPlanType() async {
    final prefs = await SharedPreferences.getInstance();
    final plan = prefs.getStringList('planTypes') ?? ['BASIC'];
    if (mounted) {
      setState(() => planType = plan.contains('PREMIUM') ? 'PREMIUM' : 'BASIC');
    }
  }

  Future<void> _startRinging(String orderId) async {
    if (!_isSoundEnabled) return;
    await NotificationService.triggerOrderSound();
  }

  Future<void> _stopRinging() async {
    await NotificationService.stopOrderSound();
  }

  void _stopRingingForOrder(String orderId) {
    if (_pendingPopupOrders.isEmpty) {
      _stopRinging();
    }
  }

  void _toggleSound() {
    bool newState = !_isSoundEnabled;
    setState(() => _isSoundEnabled = newState);
    NotificationService.toggleSound(newState);
    _saveSoundPreference(newState);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isSoundEnabled ? '🔔 Sound Enabled' : '🔕 Sound Disabled',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: _isSoundEnabled ? _H.green : _H.text2,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _togglePrint() {
    setState(() => _printEnabled = !_printEnabled);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _printEnabled ? '🖨️ Printing Enabled' : '🖨️ Printing Disabled',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: _printEnabled ? _H.blue : _H.text2,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _saveDefaultPrinter(String mac) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kDefaultPrinterKey, mac);
  }

  // ─── New Order Popup ────────────────────────────────────────────────────────
  //
  // Single source of truth for showing the "new order" popup. Only one popup
  // is ever on screen at a time; as soon as it resolves (accept / decline /
  // accept-without-print) the next queued order (if any) is shown.
  void _maybeShowOrderPopup() {
    if (_orderPopupVisible) return;
    if (_pendingPopupOrders.isEmpty) return;
    if (!mounted) return;

    _orderPopupVisible = true;
    final order = _pendingPopupOrders.first;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false, // block Android back button / back gesture entirely
        child: _NewOrderPopupDialog(
          order: order,
          isSoundEnabled: _isSoundEnabled,
          printEnabled: _printEnabled,
          onToggleSound: _toggleSound,
          onTogglePrint: _togglePrint,
          onSetDefaultPrinter: _saveDefaultPrinter,
          onAccept: () {
            Navigator.of(context, rootNavigator: true).pop();
            _acceptOrderFromPopup(order);
          },
          onDecline: () {
            Navigator.of(context, rootNavigator: true).pop();
            _declineOrderFromPopup(order);
          },
        ),
      ),
    ).then((_) {
      _orderPopupVisible = false;
      // small delay so dialogs don't visually collide when several orders queue up
      Future.delayed(const Duration(milliseconds: 250), _maybeShowOrderPopup);
    });
  }

  // ─── Location Methods ────────────────────────────────────────────────────────

  Future<void> _loadLocationFromAPI() async {
    final prefs = await SharedPreferences.getInstance();
    final responseBody = prefs.getString('location_api_response');
    if (responseBody != null && responseBody.isNotEmpty) {
      try {
        final decoded = jsonDecode(responseBody);
        String address = decoded['address'] ?? '';
        if (mounted) setState(() => _addressFromApi = address);
      } catch (_) {
        await _fetchCurrentLocation();
      }
    } else {
      await _fetchCurrentLocation();
    }
  }

  Future<void> _fetchCurrentLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final vendorId =
          prefs.getInt('vendorId') ??
          prefs.getInt('vendor_id') ??
          prefs.getInt('id') ??
          0;
      if (vendorId == 0) {
        if (mounted) setState(() => _addressFromApi = 'Tap to select location');
        return;
      }
      final response = await ApiClient.get(
        'api/vendors/$vendorId',
        service: 'food',
      );
      if (!mounted) return;
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final vendorData = jsonDecode(response.body);
        final fullAddress = vendorData['fullAddress']?.toString() ?? '';
        if (fullAddress.isNotEmpty) {
          await _saveAddressFromApi(jsonEncode({'address': fullAddress}));
          if (mounted) setState(() => _addressFromApi = fullAddress);
        } else {
          if (mounted)
            setState(() => _addressFromApi = 'Tap to select location');
        }
      } else {
        if (mounted) setState(() => _addressFromApi = 'Tap to select location');
      }
    } catch (_) {
      if (mounted) setState(() => _addressFromApi = 'Tap to select location');
    }
  }

  void _navigateToSavedAddress() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SavedAddress(
          onAddressSelected: (city, pincode, state, lat, lng, addressId) {
            final formatted = '$city, $state - $pincode';
            _saveAddressFromApi(
              jsonEncode({
                'address': formatted,
                'city': city,
                'state': state,
                'pincode': pincode,
                'latitude': lat,
                'longitude': lng,
              }),
            );
            _showSuccessMessage();
          },
        ),
      ),
    );
    if (mounted) _loadLocationFromAPI();
  }

  Future<void> _saveAddressFromApi(dynamic apiResponse) async {
    final prefs = await SharedPreferences.getInstance();
    final str = apiResponse is String ? apiResponse : jsonEncode(apiResponse);
    if (str.isNotEmpty) {
      await prefs.setString('location_api_response', str);
      try {
        final d = jsonDecode(str);
        String address = d['address'] ?? '';
        if (address.isEmpty) {
          address = [
            d['city'],
            d['state'],
            d['pincode']?.toString(),
          ].where((e) => e != null).join(', ');
        }
        if (mounted) {
          setState(
            () => _addressFromApi = address.isNotEmpty
                ? address
                : 'Tap to select location',
          );
        }
      } catch (_) {}
    }
  }

  void _showSuccessMessage() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          '📍 Location updated successfully',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: _H.green,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ─── Order Polling Methods ──────────────────────────────────────────────────

  void _startOrderPolling() {
    _newOrderPollingTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (mounted) _pollForNewOrders();
    });
    _pollForNewOrders();
  }

  Future<void> _pollForNewOrders() async {
    if (_role != 'ROLE_VENDOR') return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final vendorId =
          prefs.getInt('vendorId') ??
          prefs.getInt('vendor_id') ??
          prefs.getInt('id') ??
          0;
      if (vendorId == 0) return;

      final standardRaw = await food_authservice.getAllOrders() as List;
      final standardPending = standardRaw.where((o) {
        final status = (o['status'] ?? '').toString().toUpperCase();
        final type = (o['orderType'] ?? '').toString().toUpperCase();
        return status == 'PENDING' &&
            ['DINE_IN', 'DELIVERY', 'TAKEAWAY'].contains(type);
      }).toList();

      final tablePending = await _fetchTableDineInPending(vendorId);
      final cateringPending = await _fetchCateringPending(vendorId);

      final allPending = <Map<String, dynamic>>[
        ...standardPending.map((o) => o as Map<String, dynamic>),
        ...tablePending,
        ...cateringPending,
      ];

      if (!mounted) return;

      final newOrders = <Map<String, dynamic>>[];

      for (final order in allPending) {
        final id = (order['orderId'] ?? order['cartId'] ?? '').toString();
        final type = (order['orderType'] ?? '').toString().toUpperCase();
        final key = '${type}_$id';
        if (id.isNotEmpty && !_seenOrderIds.contains(key)) {
          _seenOrderIds.add(key);
          final alreadyQueued = _pendingPopupOrders.any((o) {
            final oid = (o['orderId'] ?? o['cartId'] ?? '').toString();
            final otype = (o['orderType'] ?? '').toString().toUpperCase();
            return '${otype}_$oid' == key;
          });
          if (!alreadyQueued) {
            newOrders.add(order);
          }
        }
      }

      if (newOrders.isNotEmpty) {
        setState(() => _pendingPopupOrders.addAll(newOrders));
        if (_isSoundEnabled) await NotificationService.triggerOrderSound();
        for (final order in newOrders) {
          final id = (order['orderId'] ?? order['cartId'] ?? '').toString();
          if (id.isNotEmpty) _showLocalNotification(order);
        }
        _maybeShowOrderPopup();
      }
    } catch (e) {
      debugPrint('Order poll error: $e');
    }
  }

  Future<void> _showLocalNotification(Map<String, dynamic> order) async {
    final orderId = order['orderId'] ?? order['cartId'] ?? '';
    final orderType = (order['orderType'] ?? '').toString();
    try {
      await NotificationService.showLocalNotification(
        title: '🆕 New Order #$orderId',
        body: 'New $orderType order received!',
        payload: 'order_$orderId',
      );
    } catch (e) {
      debugPrint('Notification error: $e');
    }
  }

  Future<List<Map<String, dynamic>>> _fetchTableDineInPending(
    int vendorId,
  ) async {
    try {
      final response = await ApiClient.get(
        'api/cart/get/ordertype=TABLE_DINE_IN/$vendorId/PENDING',
        service: 'food',
      );
      if (response.statusCode != 200) return [];
      final dynamic data = jsonDecode(response.body);
      List<dynamic> raw = [];
      if (data is List) {
        raw = data;
      } else if (data is Map<String, dynamic>) {
        raw =
            data['data'] as List? ??
            data['content'] as List? ??
            data['orders'] as List? ??
            [];
        if (raw.isEmpty && data.containsKey('cartId')) raw = [data];
      }
      return raw.map((o) {
        if (o is! Map<String, dynamic>) return <String, dynamic>{};
        final m = Map<String, dynamic>.from(o);
        m['orderType'] = 'TABLE_DINE_IN';
        m['status'] = 'PENDING';
        if (m['orderId'] == null && m['cartId'] != null)
          m['orderId'] = m['cartId'];
        return m;
      }).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _fetchCateringPending(int vendorId) async {
    try {
      final response = await ApiClient.get(
        'api/vendor/getall/$vendorId',
        service: 'catering',
      );
      if (response.statusCode != 200) return [];
      final dynamic resp = jsonDecode(response.body);
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
            return m;
          })
          .toList();
    } catch (_) {
      return [];
    }
  }

  // ─── Order Action Methods ───────────────────────────────────────────────────

  void _dismissPopupOrder(Map<String, dynamic> order) {
    if (!mounted) return;
    final id = (order['orderId'] ?? order['cartId'] ?? '').toString();
    final type = (order['orderType'] ?? '').toString().toUpperCase();
    setState(() {
      _pendingPopupOrders.removeWhere((o) {
        final oid = (o['orderId'] ?? o['cartId'] ?? '').toString();
        final otype = (o['orderType'] ?? '').toString().toUpperCase();
        return '${otype}_$oid' == '${type}_$id';
      });
    });
    if (_pendingPopupOrders.isEmpty) _stopRinging();
  }

  // IMPORTANT: the order is removed from the queue (and ringing stopped)
  // SYNCHRONOUSLY, before any awaiting. This prevents the popup queue from
  // re-showing the SAME order again while its confirm/cancel API call is
  // still in flight (which was causing the accept/print loop).
  Future<void> _acceptOrderFromPopup(Map<String, dynamic> order) async {
    _dismissPopupOrder(order);

    final id = order['orderId'] ?? order['cartId'];
    final orderType = (order['orderType'] ?? '').toString().toUpperCase();
    bool success = false;
    try {
      if (orderType == 'CATERING') {
        final resp = await ApiClient.put(
          'api/vendor/orders/status?orderId=$id&orderStatus=CONFIRMED',
          null,
          service: 'catering',
        );
        success = resp.statusCode == 200;
      } else if (orderType == 'TABLE_DINE_IN') {
        int? itemId = order['itemId'] is int
            ? order['itemId']
            : int.tryParse(order['itemId']?.toString() ?? '');
        itemId ??= order['cartId'] is int
            ? order['cartId']
            : int.tryParse(order['cartId']?.toString() ?? '');
        itemId ??= order['orderId'] is int
            ? order['orderId']
            : int.tryParse(order['orderId']?.toString() ?? '');
        if (itemId != null) {
          success = await food_authservice.updateTableDineInOrderStatus(
            itemId,
            'CONFIRMED',
          );
        }
      } else {
        success = await food_authservice.updateOrderStatus(id, 'CONFIRMED');
      }
    } catch (e) {
      debugPrint('Accept from popup error: $e');
    }

    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✅ Order #$id accepted',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Future<void> _declineOrderFromPopup(Map<String, dynamic> order) async {
    _dismissPopupOrder(order);

    final id = order['orderId'] ?? order['cartId'];
    final orderType = (order['orderType'] ?? '').toString().toUpperCase();
    bool success = false;
    try {
      if (orderType == 'CATERING') {
        final resp = await ApiClient.put(
          'api/vendor/orders/status?orderId=$id&orderStatus=CANCELLED&cancelReason=Order declined by vendor',
          null,
          service: 'catering',
        );
        success = resp.statusCode == 200;
      } else if (orderType == 'TABLE_DINE_IN') {
        int? itemId = order['itemId'] is int
            ? order['itemId']
            : int.tryParse(order['itemId']?.toString() ?? '');
        itemId ??= order['cartId'] is int
            ? order['cartId']
            : int.tryParse(order['cartId']?.toString() ?? '');
        itemId ??= order['orderId'] is int
            ? order['orderId']
            : int.tryParse(order['orderId']?.toString() ?? '');
        if (itemId != null) {
          success = await food_authservice.updateTableDineInOrderStatus(
            itemId,
            'CANCELLED',
          );
        }
      } else {
        success = await food_authservice.updateOrderStatus(id, 'CANCELLED');
      }
    } catch (e) {
      debugPrint('Decline from popup error: $e');
    }

    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '❌ Order #$id declined',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  // ─── Update Methods ─────────────────────────────────────────────────────────

  Future<void> _checkForUpdate() async {
    try {
      final info = await InAppUpdate.checkForUpdate();
      if (!mounted) return;
      setState(() {
        _updateInfo = info;
        _updateAvailable =
            info.updateAvailability == UpdateAvailability.updateAvailable;
      });
    } catch (e) {
      debugPrint('Update check failed: $e');
    }
  }

  void _startFlexibleUpdate() async {
    if (_updateInfo != null) {
      try {
        await InAppUpdate.performImmediateUpdate();
      } catch (e) {
        debugPrint('Update error: $e');
      }
    }
  }

  // ─── Logout Method ──────────────────────────────────────────────────────────

  Future<void> _logout() async {
    if (!mounted) return;
    final confirm =
        await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('Logout'),
            content: const Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ) ??
        false;
    if (confirm) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage1()),
          (_) => false,
        );
      }
    }
  }

  // ─── Module Methods ─────────────────────────────────────────────────────────

  List<Map<String, dynamic>> _getFoodBeveragesModules() => [
    {
      'icon': Icons.settings,
      'title': 'Settings Management',
      'page': SettingsScreen(),
      'module': BusinessModules.SettingsScreen,
      'color': _H.green,
    },
    {
      'icon': Icons.restaurant_menu,
      'title': 'Product & Prices',
      'page': Menu_Managemnet(),
      'module': BusinessModules.Menu_Management,
      'color': _H.accent,
    },
    {
      'icon': Icons.shopping_bag,
      'title': 'Order Management',
      'page': Order_management(),
      'module': BusinessModules.Order_Management,
      'color': _H.purple,
    },
    {
      'icon': Icons.soup_kitchen,
      'title': 'Chef Management',
      'page': const ChefKotScreen(),
      'module': BusinessModules.ChefKotScreen,
      'color': _H.amber,
    },
    {
      'icon': Icons.group,
      'title': 'Team Management',
      'page': const TeamDirectoryScreen(),
      'module': BusinessModules.TeamDirectoryScreen,
      'color': _H.teal,
    },
    {
      'icon': Icons.manage_accounts,
      'title': 'Account Management',
      'page': const FinanceScreen(),
      'module': BusinessModules.Account_History,
      'color': Color(0xFFEC4899),
    },
    {
      'icon': Icons.campaign,
      'title': 'Promotions & Marketing',
      'page': CampaignListScreen(),
      'module': BusinessModules.CampaignListScreen,
      'color': Color(0xFFEC4899),
    },
    {
      'icon': Icons.support_agent,
      'title': 'Support Management',
      'page': const SupportScreen(),
      'module': BusinessModules.SupportScreen,
      'color': _H.teal,
    },
    {
      'icon': Icons.assessment,
      'title': 'Report & Analysis',
      'page': const ReportsScreen(),
      'module': BusinessModules.Report_Analysis,
      'color': Color(0xFF6366F1),
    },
    {
      'icon': Icons.table_restaurant,
      'title': 'Table Management',
      'page': const TableManagementPage(),
      'module': BusinessModules.Table_Management,
      'color': _H.blue,
    },
    {
      'icon': Icons.schedule,
      'title': 'Schedule Orders',
      'page': ScheduleOrdersPage(),
      'module': BusinessModules.Schedule_Orders,
      'color': _H.green,
    },
    {
      'icon': Icons.inventory,
      'title': 'Inventory',
      'page': const premium_InventoryManagement(),
      'module': BusinessModules.Inventory_Management,
      'color': _H.amber,
    },
    {
      'icon': Icons.subscriptions,
      'title': 'Subscription',
      'page': MainScreen1(),
      'module': BusinessModules.subscription,
      'color': _H.blue,
    },
    {
      'icon': Icons.app_registration,
      'title': 'Registration',
      'page': FoodRegistrationScreen01(),
      'module': BusinessModules.FoodRegistrationScreen,
      'color': _H.blue,
    },

    // {
    //   'icon': Icons.app_registration,
    //   'title': 'Sale Management',
    //   'page': LeadManagementPage(),
    //   'module': BusinessModules.LeadManagementPage,
    //   'color': _H.blue,
    // },
  ];

  void _navigateToModule(Map<String, dynamic> module, BuildContext context) {
    final type = module['module'] as BusinessModules;
    switch (type) {
      case BusinessModules.Menu_Management:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => Menu_Managemnet()),
        );
        break;
      case BusinessModules.Promotions_Discounts:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PromotionDiscountPage()),
        );
        break;
      case BusinessModules.Report_Analysis:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ReportsScreen()),
        );
        break;
      case BusinessModules.ChefKotScreen:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ChefKotScreen()),
        );
        break;
      case BusinessModules.subscription:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => MainScreen1()),
        );
        break;
      case BusinessModules.Settings_Controls:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SettingsAndControlsPage()),
        );
        break;
      case BusinessModules.SettingsScreen:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => SettingsScreen()),
        );
        break;
      case BusinessModules.Delivery_Management:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const DeliveryOtpCard(orderId: 0)),
        );
        break;
      case BusinessModules.Table_Management:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TableManagementPage()),
        );
        break;
      case BusinessModules.Schedule_Orders:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ScheduleOrdersPage()),
        );
        break;
      case BusinessModules.Account_History:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const FinanceScreen()),
        );
        break;
      case BusinessModules.Inventory_Management:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const premium_InventoryManagement(),
          ),
        );
        break;
      case BusinessModules.Supportteam:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const Supportteam()),
        );
        break;
      case BusinessModules.CampaignListScreen:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => CampaignListScreen()),
        );
        break;
      case BusinessModules.TeamDirectoryScreen:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TeamDirectoryScreen()),
        );
        break;
      case BusinessModules.StandardMenuScreen:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => StandardMenuScreen()),
        );
        break;
      default:
        if (module['page'] is Widget) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => module['page'] as Widget),
          );
        }
    }
  }

  // ─── Drawer Builders ────────────────────────────────────────────────────────

  Widget _buildProfileDrawer() {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.78,
      backgroundColor: _H.white,
      child: _DrawerContentRefresher(
        onMount: _loadRestaurantStatus,
        child: SafeArea(
          child: Column(
            children: [
              _buildDrawerHeader(),
              Expanded(child: _buildDrawerMenu()),
              _buildDrawerFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: FutureBuilder<Map<String, dynamic>?>(
        future: _vendorDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _shimmerWrap(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _ShimmerBox(
                    width: 52,
                    height: 52,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ShimmerBox(height: 15, width: 140),
                        const SizedBox(height: 8),
                        _ShimmerBox(height: 10, width: 60),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
          final registeredName =
              snapshot.data?['registeredName'] ??
              snapshot.data?['companyName'] ??
              'Vendor';
          final companyLogoUrl = snapshot.data?['companyLogo']?.toString();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: (companyLogoUrl != null && companyLogoUrl.isNotEmpty)
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.network(
                              companyLogoUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.storefront_rounded,
                                color: Colors.black87,
                                size: 28,
                              ),
                            ),
                          )
                        : const Icon(
                            Icons.storefront_rounded,
                            color: Colors.black87,
                            size: 28,
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          registeredName.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            height: 1.1,
                          ),
                          maxLines: 2,
                          softWrap: true,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            _isOnline
                                ? _PulsingDot(color: _H.green)
                                : Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: _H.red,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                            const SizedBox(width: 6),
                            Text(
                              _isOnline ? 'ON' : 'OFF',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: _isOnline ? _H.green : _H.red,
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (_statusBusy || _statusLoading)
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: _isOnline ? _H.green : _H.red,
                                ),
                              )
                            else
                              Transform.scale(
                                scale: 0.7,
                                child: Switch(
                                  value: _isOnline,
                                  onChanged: _toggleRestaurantStatus,
                                  activeColor: _H.green,
                                  activeTrackColor: _H.green.withOpacity(0.25),
                                  inactiveThumbColor: _H.red,
                                  inactiveTrackColor: _H.red.withOpacity(0.25),
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDrawerMenu() {
    final allModules = _getFoodBeveragesModules();
    final hiddenFromDrawer = [
      BusinessModules.Table_Management,
      BusinessModules.Schedule_Orders,
      BusinessModules.Inventory_Management,
      BusinessModules.Promotions_Discounts,
      BusinessModules.Delivery_Management,
    ];
    final filtered = allModules.where((m) {
      final module = m['module'] as BusinessModules;
      if (hiddenFromDrawer.contains(module)) return false;
      if (_role == 'ROLE_EMPLOYEE') return _employeeModules.contains(module);
      return true;
    }).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      children: [
        if (_role == 'ROLE_VENDOR')
          ListTile(
            leading: _drawerIcon(Icons.app_registration_rounded, _H.amber),
            title: const Text(
              'Profile Management',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _H.text1,
              ),
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 13,
              color: _H.text3,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => Company()),
              );
            },
          ),
        if (_role == 'ROLE_VENDOR') const SizedBox(height: 8),
        if (filtered.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'No modules assigned.\nContact your admin.',
              style: TextStyle(color: _H.text3, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          )
        else
          ...filtered.map(
            (m) => ListTile(
              leading: _drawerIcon(m['icon'] as IconData, _H.accent),
              title: Text(
                m['title'] as String,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _H.text1,
                ),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 12,
                color: _H.text3,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onTap: () {
                Navigator.pop(context);
                _navigateToModule(m, context);
              },
            ),
          ),

        const SizedBox(height: 4),
        const Divider(height: 1, color: _H.border),
        ListTile(
          dense: true,
          visualDensity: VisualDensity.compact,
          leading: _drawerIcon(Icons.logout_rounded, _H.red),
          title: const Text(
            'Logout',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _H.red,
            ),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 12,
            color: _H.text3,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          onTap: _logout,
        ),
      ],
    );
  }

  Widget _drawerIcon(IconData icon, Color color) => Container(
    width: 34,
    height: 34,
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(9),
    ),
    child: Icon(icon, size: 17, color: color),
  );

  Future<Map<String, dynamic>?> _fetchVendorDetails() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final vendorId =
          prefs.getInt('vendorId') ??
          prefs.getInt('vendor_id') ??
          prefs.getInt('id') ??
          0;
      if (vendorId == 0) return null;
      final vendorResponse = await ApiClient.get(
        'api/vendors/$vendorId',
        service: 'food',
      );
      Map<String, dynamic> vendorData = {};
      if (vendorResponse.statusCode == 200 && vendorResponse.body.isNotEmpty) {
        vendorData = jsonDecode(vendorResponse.body);
      }
      Map<String, dynamic> bannerData = {};
      try {
        final bannerResponse = await ApiClient.get(
          'api/banner/$vendorId',
          service: 'food',
          requiresAuth: false,
        );
        if (bannerResponse.statusCode == 200 &&
            bannerResponse.body.isNotEmpty) {
          final decoded = jsonDecode(bannerResponse.body);
          if (decoded is Map<String, dynamic>) {
            bannerData = decoded;
          } else if (decoded is List && decoded.isNotEmpty) {
            bannerData = decoded[0] as Map<String, dynamic>;
          }
        }
      } catch (e) {
        debugPrint("⚠️ Banner fetch error: $e");
      }
      return {
        ...vendorData,
        'companyLogo': bannerData['companyLogo'] ?? vendorData['companyLogo'],
      };
    } catch (e) {
      debugPrint("❌ Vendor fetch error: $e");
      return null;
    }
  }

  Widget _buildDrawerFooter() {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _vendorDetailsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _shimmerWrap(
            child: Container(
              margin: const EdgeInsets.all(5),
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  _ShimmerBox(
                    width: 38,
                    height: 38,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ShimmerBox(height: 12, width: 100),
                        const SizedBox(height: 6),
                        _ShimmerBox(height: 10, width: 140),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        final vendorName = snapshot.data?['ownerName'] ?? 'Vendor';
        final vendorEmail = snapshot.data?['email'] ?? 'vendor@maamaas.com';
        return Container(
          margin: const EdgeInsets.all(5),
          padding: const EdgeInsets.all(14),

          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_H.amber, Color(0xFFD97706)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vendorName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: _H.text1,
                      ),
                    ),
                    Text(
                      vendorEmail,
                      style: const TextStyle(color: _H.text2, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ─── Update Banner ──────────────────────────────────────────────────────────

  Widget _buildUpdateBanner() {
    return Positioned(
      left: 16,
      right: 16,
      bottom: 80,
      child: Container(
        decoration: BoxDecoration(
          color: _H.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _H.border),
          boxShadow: [
            BoxShadow(
              color: _H.shadowMd,
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: _H.redLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.system_update_rounded,
                      color: _H.red,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'New Update Available',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _H.text1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: _H.border),
            InkWell(
              onTap: _startFlexibleUpdate,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      'UPDATE NOW',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: _H.red,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(Icons.download_rounded, color: _H.red, size: 17),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Footer ─────────────────────────────────────────────────────────────────

  Widget _buildFooter() {
    final hasPendingOrders =
        _pendingPopupOrders.isNotEmpty && _role == 'ROLE_VENDOR';

    return Container(
      decoration: BoxDecoration(
        color: _H.white,
        border: Border(top: BorderSide(color: _H.border)),
        boxShadow: [
          BoxShadow(
            color: _H.shadow,
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedFooterIndex.clamp(0, 3),
        onTap: (i) {
          if (mounted) setState(() => _selectedFooterIndex = i);
        },
        backgroundColor: Colors.transparent,
        selectedItemColor: _H.accent,
        unselectedItemColor: _H.text3,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.local_offer_rounded),
            label: 'Deals',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu_rounded),
            label: 'Menu',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.shopping_bag_rounded),
                if (hasPendingOrders)
                  Positioned(
                    top: -4,
                    right: -6,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: _H.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: _H.white, width: 1.5),
                      ),
                      child: Center(
                        child: Text(
                          _pendingPopupOrders.length > 9
                              ? '9+'
                              : '${_pendingPopupOrders.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            label: 'Orders',
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_roleLoaded) {
      return const Scaffold(
        backgroundColor: _H.bg,
        body: _ScaffoldLoadingShimmer(),
      );
    }
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: _H.bg,
      appBar: null,
      endDrawer: _buildProfileDrawer(),
      body: Stack(
        children: [
          HomePageContent(
            selectedFooterIndex: _selectedFooterIndex,
            onFooterItemTapped: (i) {
              if (mounted) setState(() => _selectedFooterIndex = i);
            },
            addressFromApi: _addressFromApi,
            role: _role,
            employeeModules: _employeeModules,
            planType: planType,
            pendingOrders: _pendingPopupOrders,
            onAcceptOrder: _acceptOrderFromPopup,
            onDeclineOrder: _declineOrderFromPopup,
            onDismissOrder: _dismissPopupOrder,
            isSoundEnabled: _isSoundEnabled,
            onToggleSound: _toggleSound,
            printEnabled: _printEnabled,
            onTogglePrint: _togglePrint,
            onDrawerOpen: _loadRestaurantStatus,
          ),
          if (_updateAvailable) _buildUpdateBanner(),
        ],
      ),
      bottomNavigationBar: _role == 'ROLE_EMPLOYEE' ? null : _buildFooter(),
    );
  }
}

// ─── HomePageContent ───────────────────────────────────────────────────────────
class HomePageContent extends StatefulWidget {
  final int selectedFooterIndex;
  final Function(int) onFooterItemTapped;
  final Function(String)? onLocationUpdated;
  final String? addressFromApi;
  final VoidCallback? onLocationTap;
  final String role;
  final List<BusinessModules> employeeModules;
  final String planType;

  final List<Map<String, dynamic>> pendingOrders;
  final Function(Map<String, dynamic>)? onAcceptOrder;
  final Function(Map<String, dynamic>)? onDeclineOrder;
  final Function(Map<String, dynamic>)? onDismissOrder;

  final bool isSoundEnabled;
  final VoidCallback? onToggleSound;
  final bool printEnabled;
  final VoidCallback? onTogglePrint;
  final VoidCallback? onDrawerOpen;

  const HomePageContent({
    Key? key,
    required this.selectedFooterIndex,
    required this.onFooterItemTapped,
    this.onLocationUpdated,
    this.addressFromApi,
    this.onLocationTap,
    this.role = 'ROLE_VENDOR',
    this.employeeModules = const [],
    this.planType = 'BASIC',
    this.pendingOrders = const [],
    this.onAcceptOrder,
    this.onDeclineOrder,
    this.onDismissOrder,
    this.isSoundEnabled = true,
    this.onToggleSound,
    this.printEnabled = true,
    this.onTogglePrint,
    this.onDrawerOpen,
  }) : super(key: key);

  @override
  State<HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  bool get _isVendor => widget.role == 'ROLE_VENDOR';
  bool get _isEmployee => widget.role == 'ROLE_EMPLOYEE';

  String planType = 'BASIC';
  String role = 'ROLE_VENDOR';
  bool isLoading = true;
  int vendorId = 0;
  String? _authToken;
  bool _isMobile = false;

  late ScrollController _scrollController;
  bool _isBannerCollapsed = false;

  List<Map<String, dynamic>> _campaigns = [];
  bool _campaignsLoading = true;
  int _bannerPage = 0;
  Timer? _bannerTimer;
  PageController _bannerController = PageController();

  DashboardStatsModel? _dashboardStats;
  bool _isLoadingStats = true;

  List<File> _offerImages = [];
  int _currentPage = 0;
  Timer? _carouselTimer;
  PageController _pageController = PageController();

  ReportData? _weeklyDetailedStats;
  bool _isLoadingWeeklyStats = true;

  ReportData? _allTimeDetailedStats;
  bool _isLoadingAllTimeStats = true;

  ReportData? _todayDetailedStats;
  bool _isLoadingOrderTypes = true;

  Map<String, dynamic>? _vendorStats;
  bool _isLoadingVendorStats = true;

  static const double _bannerBottomRadius = 28.0;

  double get _bannerHeight {
    if (!mounted) return 200;
    final h = MediaQuery.of(context).size.height;
    return (h * 0.28).clamp(180.0, 220.0);
  }

  static const double _stickyBarHeight = 110.0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _bannerController = PageController();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    planType = widget.planType;
    role = widget.role;

    _loadVendorIdAndFetchStats();
    _loadSavedImages();

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _fetchCampaigns();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _checkMobile());
    isLoading = false;
  }

  @override
  void didUpdateWidget(HomePageContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.role != widget.role ||
        oldWidget.planType != widget.planType) {
      setState(() {
        role = widget.role;
        planType = widget.planType;
      });
    }
  }

  void _onScroll() {
    final collapseThreshold = _bannerHeight - kToolbarHeight - 4;
    final collapsed = _scrollController.offset > collapseThreshold;
    if (collapsed != _isBannerCollapsed && mounted) {
      setState(() => _isBannerCollapsed = collapsed);
    }
  }

  void _checkMobile() {
    if (!mounted) return;
    setState(() => _isMobile = MediaQuery.of(context).size.width < 768);
  }

  Future<void> _loadVendorIdAndFetchStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final vid =
          prefs.getInt('vendorId') ??
          prefs.getInt('vendor_id') ??
          prefs.getInt('id') ??
          0;
      _authToken =
          prefs.getString('authToken') ??
          prefs.getString('token') ??
          prefs.getString('accessToken');
      if (mounted) setState(() => vendorId = vid);

      if (vid > 0 && _authToken != null && _isVendor) {
        await _fetchDashboardStats();
        await _fetchTodayDetailedStats();
        await _fetchWeeklyChartStats();
        await _fetchAllTimeChartStats();
        await _fetchVendorStats();
      } else {
        if (mounted) {
          setState(() {
            _isLoadingStats = false;
            _isLoadingOrderTypes = false;
            _isLoadingWeeklyStats = false;
            _isLoadingAllTimeStats = false;
            _isLoadingVendorStats = false;
          });
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoadingStats = false;
          _isLoadingOrderTypes = false;
          _isLoadingWeeklyStats = false;
          _isLoadingAllTimeStats = false;
          _isLoadingVendorStats = false;
        });
      }
    }
  }

  Future<void> _fetchDashboardStats() async {
    if (vendorId == 0 || !_isVendor) {
      if (mounted) setState(() => _isLoadingStats = false);
      return;
    }
    if (mounted) setState(() => _isLoadingStats = true);
    try {
      final today = DateTime.now();
      final stats = await getVendorDashboardStats(
        vendorId,
        fromDate: today,
        toDate: today,
      );
      if (mounted)
        setState(() {
          _dashboardStats = stats;
          _isLoadingStats = false;
        });
    } catch (e) {
      debugPrint('Dashboard error: $e');
      if (mounted) setState(() => _isLoadingStats = false);
    }
  }

  Future<void> _fetchTodayDetailedStats() async {
    if (!_isVendor) {
      if (mounted) setState(() => _isLoadingOrderTypes = false);
      return;
    }
    if (mounted) setState(() => _isLoadingOrderTypes = true);
    try {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final stats = await ReportService.fetch(
        ReportFilter(startDate: today, endDate: today),
      );
      if (mounted)
        setState(() {
          _todayDetailedStats = stats;
          _isLoadingOrderTypes = false;
        });
    } catch (e) {
      debugPrint('Today detailed stats error: $e');
      if (mounted) setState(() => _isLoadingOrderTypes = false);
    }
  }

  Future<void> _fetchWeeklyChartStats() async {
    if (!_isVendor) {
      if (mounted) setState(() => _isLoadingWeeklyStats = false);
      return;
    }
    if (mounted) setState(() => _isLoadingWeeklyStats = true);
    try {
      final now = DateTime.now();
      final from = DateFormat(
        'yyyy-MM-dd',
      ).format(now.subtract(const Duration(days: 6)));
      final to = DateFormat('yyyy-MM-dd').format(now);
      final stats = await ReportService.fetch(
        ReportFilter(startDate: from, endDate: to),
      );
      if (mounted)
        setState(() {
          _weeklyDetailedStats = stats;
          _isLoadingWeeklyStats = false;
        });
    } catch (e) {
      debugPrint('Weekly chart stats error: $e');
      if (mounted) setState(() => _isLoadingWeeklyStats = false);
    }
  }

  Future<void> _fetchAllTimeChartStats() async {
    if (!_isVendor) {
      if (mounted) setState(() => _isLoadingAllTimeStats = false);
      return;
    }
    if (mounted) setState(() => _isLoadingAllTimeStats = true);
    try {
      final from = '2020-01-01';
      final to = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final stats = await ReportService.fetch(
        ReportFilter(startDate: from, endDate: to),
      );
      if (mounted)
        setState(() {
          _allTimeDetailedStats = stats;
          _isLoadingAllTimeStats = false;
        });
    } catch (e) {
      debugPrint('All-time chart stats error: $e');
      if (mounted) setState(() => _isLoadingAllTimeStats = false);
    }
  }

  Future<void> _fetchVendorStats() async {
    if (!_isVendor || vendorId == 0) {
      if (mounted) setState(() => _isLoadingVendorStats = false);
      return;
    }
    if (mounted) setState(() => _isLoadingVendorStats = true);
    try {
      final response = await ApiClient.get(
        'api/orders/vendor/statistics/$vendorId',
        service: 'food',
      );
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (mounted)
          setState(() {
            _vendorStats = data;
            _isLoadingVendorStats = false;
          });
      } else {
        if (mounted) setState(() => _isLoadingVendorStats = false);
      }
    } catch (e) {
      debugPrint('❌ Vendor stats fetch error: $e');
      if (mounted) setState(() => _isLoadingVendorStats = false);
    }
  }

  Future<void> _refreshDashboard() async {
    if (!_isVendor) return;
    await _fetchDashboardStats();
    await _fetchTodayDetailedStats();
    await _fetchWeeklyChartStats();
    await _fetchAllTimeChartStats();
    await _fetchVendorStats();
  }

  Future<void> _fetchCampaigns() async {
    if (mounted) setState(() => _campaignsLoading = true);
    try {
      final response = await ApiClient.get(
        'api/banner/$vendorId',
        service: 'food',
        requiresAuth: false,
      );
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        dynamic decoded;
        try {
          decoded = jsonDecode(response.body);
        } catch (e) {
          if (mounted) setState(() => _campaignsLoading = false);
          return;
        }
        final List<Map<String, dynamic>> banners = [];
        if (decoded is Map<String, dynamic>) {
          banners.add(decoded);
        } else if (decoded is List) {
          for (final item in decoded) {
            if (item is Map<String, dynamic>) banners.add(item);
          }
        }
        if (mounted) {
          setState(() {
            _campaigns = banners;
            _campaignsLoading = false;
          });
          if (banners.length > 1) _startBannerAutoScroll();
        }
      } else {
        if (mounted) setState(() => _campaignsLoading = false);
      }
    } catch (e, st) {
      debugPrint('💥 Banner fetch error: $e\n$st');
      if (mounted) setState(() => _campaignsLoading = false);
    }
  }

  void _startBannerAutoScroll() {
    _bannerTimer?.cancel();
    if (_campaigns.length > 1) {
      _bannerTimer = Timer.periodic(const Duration(seconds: 4), (_) {
        if (!mounted || !_bannerController.hasClients) return;
        final next = (_bannerPage + 1) % _campaigns.length;
        _bannerController.animateToPage(
          next,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
        setState(() => _bannerPage = next);
      });
    }
  }

  @override
  void dispose() {
    _carouselTimer?.cancel();
    _bannerTimer?.cancel();
    _pageController.dispose();
    _bannerController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedImages() async {
    final prefs = await SharedPreferences.getInstance();
    final paths = prefs.getStringList('offer_images') ?? [];
    if (mounted)
      setState(() => _offerImages = paths.map((p) => File(p)).toList());
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _carouselTimer?.cancel();
    if (_offerImages.length > 1) {
      _carouselTimer = Timer.periodic(const Duration(seconds: 3), (_) {
        if (!mounted || !_pageController.hasClients) return;
        final next = (_currentPage + 1) % _offerImages.length;
        _pageController.animateToPage(
          next,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
        setState(() => _currentPage = next);
      });
    }
  }

  List<Map<String, dynamic>> _getFoodBeveragesModules() => [
    {
      'icon': Icons.settings_rounded,
      'title': 'Settings',
      'module': BusinessModules.SettingsScreen,
      'color': _H.green,
      'page': SettingsScreen(),
    },
    {
      'icon': Icons.subscriptions_rounded,
      'title': 'Subscription',
      'module': BusinessModules.subscription,
      'color': _H.blue,
      'page': MainScreen1(),
    },
    {
      'icon': Icons.soup_kitchen_rounded,
      'title': 'Chef Mgmt',
      'module': BusinessModules.ChefKotScreen,
      'color': _H.amber,
      'page': const ChefKotScreen(),
    },
    {
      'icon': Icons.assessment_rounded,
      'title': 'Reports',
      'module': BusinessModules.Report_Analysis,
      'color': Color(0xFF6366F1),
      'page': const ReportsScreen(),
    },
    {
      'icon': Icons.restaurant_menu_rounded,
      'title': 'Product & TableServices',
      'module': BusinessModules.StandardMenuScreen,
      'color': Color(0xFF3B82F6),
      'page': StandardMenuScreen(),
    },
    {
      'icon': Icons.manage_accounts_rounded,
      'title': 'Accounts',
      'module': BusinessModules.Account_History,
      'color': Color(0xFFEC4899),
      'page': const FinanceScreen(),
    },
    {
      'icon': Icons.support_agent_rounded,
      'title': 'Support',
      'module': BusinessModules.Supportteam,
      'color': _H.teal,
      'page': const Supportteam(),
    },
    {
      'icon': Icons.restaurant_menu_rounded,
      'title': 'Menu',
      'module': BusinessModules.Menu_Management,
      'color': _H.accent,
      'page': Menu_Managemnet(),
    },
    {
      'icon': Icons.shopping_bag_rounded,
      'title': 'Orders',
      'module': BusinessModules.Order_Management,
      'color': _H.purple,
      'page': const Order_management(),
    },
    {
      'icon': Icons.group_rounded,
      'title': 'Team',
      'module': BusinessModules.TeamDirectoryScreen,
      'color': _H.teal,
      'page': const TeamDirectoryScreen(),
    },
  ];

  void _navigateToModule(Map<String, dynamic> m, BuildContext ctx) {
    if (m['page'] is Widget) {
      Navigator.push(
        ctx,
        MaterialPageRoute(builder: (_) => m['page'] as Widget),
      );
    }
  }

  @override
  Widget build(BuildContext context) => _buildBody();

  Widget _buildBody() {
    if (_isEmployee) {
      switch (widget.selectedFooterIndex) {
        case 1:
          return _buildEmployeeModulesFullPage();
        case 0:
        default:
          return _buildHomeContent();
      }
    }
    switch (widget.selectedFooterIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return ReelsScreen(
          onBackPressed: () {
            if (mounted) widget.onFooterItemTapped(0);
          },
        );
      case 2:
        return Menu_Managemnet();
      case 3:
        return Order_management();
      default:
        return _buildHomeContent();
    }
  }

  Widget _buildEmployeeModulesFullPage() {
    final allModules = _getFoodBeveragesModules();
    final List<Map<String, dynamic>> visible = widget.employeeModules.isNotEmpty
        ? allModules
              .where((m) => widget.employeeModules.contains(m['module']))
              .toList()
        : [];

    return Container(
      color: _H.bg,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              color: _H.white,
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: _H.accentLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.dashboard_rounded,
                      color: _H.accent,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'My Modules',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: _H.text1,
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: _H.border),
            Expanded(
              child: visible.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: _H.redLight,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: const Icon(
                              Icons.lock_rounded,
                              color: _H.red,
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No modules assigned yet',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: _H.text1,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Contact your admin to get access.',
                            style: TextStyle(fontSize: 13, color: _H.text2),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.95,
                          ),
                      itemCount: visible.length,
                      itemBuilder: (ctx, i) {
                        final m = visible[i];
                        final color = (m['color'] as Color?) ?? _H.accent;
                        return GestureDetector(
                          onTap: () => _navigateToModule(m, ctx),
                          child: Container(
                            decoration: BoxDecoration(
                              color: _H.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: _H.border),
                              boxShadow: [
                                BoxShadow(
                                  color: _H.shadow,
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 46,
                                  height: 46,
                                  decoration: BoxDecoration(
                                    color: color.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(13),
                                  ),
                                  child: Icon(
                                    m['icon'] as IconData,
                                    color: color,
                                    size: 23,
                                  ),
                                ),
                                const SizedBox(height: 9),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                  ),
                                  child: Text(
                                    m['title'] as String,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: _H.text1,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ── MAIN HOME CONTENT ────────────────────────────────────────────────────────

  Widget _buildHomeContent() {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        _isMobile = constraints.maxWidth < 768;

        return Container(
          color: _H.bg,
          child: RefreshIndicator(
            color: _H.accent,
            onRefresh: _isVendor ? _refreshDashboard : () async {},
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverAppBar(
                  expandedHeight: _bannerHeight,
                  collapsedHeight: kToolbarHeight,
                  pinned: true,
                  elevation: 0,
                  scrolledUnderElevation: 0,
                  backgroundColor: _isBannerCollapsed
                      ? _H.white
                      : Colors.transparent,
                  automaticallyImplyLeading: false,
                  title: _buildStickyLocationRow(isDark: _isBannerCollapsed),
                  actions: [
                    Builder(
                      builder: (context) => IconButton(
                        icon: Icon(
                          Icons.menu,
                          color: _isBannerCollapsed
                              ? Colors.black
                              : Colors.white,
                        ),
                        onPressed: () {
                          widget.onDrawerOpen?.call();
                          Scaffold.of(context).openEndDrawer();
                        },
                      ),
                    ),
                  ],
                  bottom: _isBannerCollapsed
                      ? PreferredSize(
                          preferredSize: const Size.fromHeight(1),
                          child: Divider(color: _H.border, height: 1),
                        )
                      : null,
                  flexibleSpace: FlexibleSpaceBar(
                    collapseMode: CollapseMode.pin,
                    background: _buildBannerCard(),
                  ),
                ),

                if (_isVendor) ...[
                  SliverToBoxAdapter(child: _buildStatsRow()),
                  SliverToBoxAdapter(child: _buildOrderTypesCard()),
                  SliverToBoxAdapter(child: _buildOrderStatusCard()),
                  SliverToBoxAdapter(child: _buildCollectionSummaryCard()),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                      child: _buildTopSellingChart(),
                    ),
                  ),
                ],

                if (_isEmployee)
                  SliverToBoxAdapter(child: _buildEmployeeModuleGrid()),

                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmployeeModuleGrid() {
    final allModules = _getFoodBeveragesModules();
    final List<Map<String, dynamic>> visible;
    if (widget.employeeModules.isNotEmpty) {
      visible = allModules
          .where((m) => widget.employeeModules.contains(m['module']))
          .toList();
    } else {
      visible = [];
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: _H.accentLight,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(
                  Icons.dashboard_rounded,
                  color: _H.accent,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Your Modules',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: _H.text1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (visible.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: _H.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _H.border),
              ),
              child: Center(
                child: Column(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: _H.redLight,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.lock_rounded,
                        color: _H.red,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'No modules assigned yet',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _H.text1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Contact your admin to get access.',
                      style: TextStyle(fontSize: 13, color: _H.text2),
                    ),
                  ],
                ),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.95,
              ),
              itemCount: visible.length,
              itemBuilder: (ctx, i) {
                final m = visible[i];
                final color = (m['color'] as Color?) ?? _H.accent;
                return GestureDetector(
                  onTap: () => _navigateToModule(m, ctx),
                  child: Container(
                    decoration: BoxDecoration(
                      color: _H.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _H.border),
                      boxShadow: [
                        BoxShadow(
                          color: _H.shadow,
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: Icon(
                            m['icon'] as IconData,
                            color: color,
                            size: 23,
                          ),
                        ),
                        const SizedBox(height: 9),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Text(
                            m['title'] as String,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: _H.text1,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildStickyLocationRow({required bool isDark}) {
    final Color iconBg = isDark
        ? _H.accentLight
        : Colors.white.withOpacity(0.20);
    final Color iconColor = isDark ? _H.accent : Colors.white;
    final Color labelColor = isDark ? _H.text2 : Colors.white.withOpacity(0.85);
    final Color addressColor = isDark ? _H.text1 : Colors.white;
    final Color chevronColor = isDark ? _H.accent : Colors.white;

    return GestureDetector(
      onTap: widget.onLocationTap,
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.location_on_rounded, size: 18, color: iconColor),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Current Location',
                  style: TextStyle(
                    fontSize: 10,
                    color: labelColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.addressFromApi ?? 'Tap to select location',
                        style: TextStyle(
                          fontSize: 13,
                          color: addressColor,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 18,
                      color: chevronColor,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerCard() {
    const double _bannerBottomRadius = 20;
    const backgroundDecoration = BoxDecoration(
      gradient: LinearGradient(
        colors: [Color(0xFFE66D33), Color(0xFFFF8A50), Color(0xFFE66D33)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    );

    Widget inner;

    if (_campaignsLoading) {
      inner = const _BannerShimmer();
    } else if (_campaigns.isNotEmpty) {
      inner = Stack(
        children: [
          PageView.builder(
            controller: _bannerController,
            itemCount: _campaigns.length,
            onPageChanged: (i) => setState(() => _bannerPage = i),
            itemBuilder: (_, i) {
              final c = _campaigns[i];
              final imageUrl = (c['companyBanner'] ?? '').toString();
              final title = (c['companyName'] ?? '').toString();
              final subtitle = "${c['city'] ?? ''}, ${c['state'] ?? ''}";
              return Container(
                decoration: backgroundDecoration,
                child: Stack(
                  children: [
                    if (imageUrl.isNotEmpty)
                      Positioned.fill(
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          alignment: Alignment.center,
                          loadingBuilder: (_, child, progress) =>
                              progress == null ? child : const SizedBox(),
                          errorBuilder: (_, __, ___) => const SizedBox(),
                        ),
                      ),
                    Positioned.fill(
                      child: Container(color: Colors.black.withOpacity(0.25)),
                    ),
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withOpacity(0.7),
                              Colors.transparent,
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            stops: const [0.0, 0.6],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: -20,
                      top: -20,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.06),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 20,
                      right: 20,
                      bottom: 28,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title.isNotEmpty ? title : 'Restaurant',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              shadows: [
                                Shadow(
                                  blurRadius: 8,
                                  color: Colors.black,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 12,
                              shadows: const [
                                Shadow(
                                  blurRadius: 6,
                                  color: Colors.black,
                                  offset: Offset(0, 1),
                                ),
                              ],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          if (_campaigns.length > 1)
            Positioned(
              bottom: 10,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_campaigns.length, (i) {
                  final isActive = i == _bannerPage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: isActive ? 18 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isActive
                          ? Colors.white
                          : Colors.white.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
            ),
        ],
      );
    } else {
      inner = Container(
        decoration: backgroundDecoration,
        child: const Center(
          child: Text(
            'No banners available',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(_bannerBottomRadius),
        bottomRight: Radius.circular(_bannerBottomRadius),
      ),
      child: inner,
    );
  }

  Widget _buildStatsRow() {
    if (_isLoadingStats) {
      return const _StatsRowShimmer();
    }

    final hasData = _dashboardStats != null;
    final rev = hasData ? _dashboardStats!.dailyRevenue : 0.0;
    final orders = hasData ? _dashboardStats!.dailyOrders : 0;
    final rating = hasData ? _dashboardStats!.averageRating : '0.00';

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      decoration: BoxDecoration(
        color: _H.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _H.border),
        boxShadow: [
          BoxShadow(
            color: _H.shadow,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        child: Row(
          children: [
            Expanded(
              child: _statCell(
                '₹${rev.toStringAsFixed(0)}',
                "Today's Revenue",
                _H.green,
                Icons.trending_up_rounded,
              ),
            ),
            _vertDivider(),
            Expanded(
              child: _statCell(
                orders.toString(),
                "Today's Orders",
                _H.blue,
                Icons.shopping_bag_rounded,
              ),
            ),
            _vertDivider(),
            Expanded(
              child: _statCell(
                rating,
                'Avg Rating',
                _H.amber,
                Icons.star_rounded,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _vertDivider() => Container(width: 1, height: 44, color: _H.border);

  Widget _statCell(String value, String label, Color color, IconData icon) {
    return Column(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: _H.text1,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: _H.text2),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _todayBadge() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: _H.accentLight,
      borderRadius: BorderRadius.circular(20),
    ),
    child: const Text(
      'Today',
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: _H.accent,
      ),
    ),
  );

  Widget _cardIcon(IconData icon, Color bg, Color iconColor) => Container(
    width: 28,
    height: 28,
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Icon(icon, color: iconColor, size: 14),
  );

  BoxDecoration _cardDecoration() => BoxDecoration(
    color: _H.white,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: _H.border),
    boxShadow: [
      BoxShadow(color: _H.shadow, blurRadius: 8, offset: const Offset(0, 3)),
    ],
  );

  Widget _loadingCard(double height) => _DashCardShimmer(height: height);

  Widget _buildOrderTypesCard() {
    if (_isLoadingOrderTypes) return _loadingCard(130);
    int dineIn = 0, takeaway = 0, delivery = 0;
    if (_todayDetailedStats != null) {
      dineIn = _todayDetailedStats!.dineInOrders;
      takeaway = _todayDetailedStats!.takeawayOrders;
      delivery = _todayDetailedStats!.deliveryOrders;
    }
    final total = dineIn + takeaway + delivery;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      decoration: _cardDecoration(),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _cardIcon(
                  Icons.pie_chart_outline_rounded,
                  _H.accentLight,
                  _H.accent,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Order Types',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _H.text1,
                    ),
                  ),
                ),
                _todayBadge(),
              ],
            ),
            const SizedBox(height: 16),
            _orderTypeBar('Dine In', dineIn, total, _H.accent),
            const SizedBox(height: 12),
            _orderTypeBar('Takeaway', takeaway, total, _H.blue),
            const SizedBox(height: 12),
            _orderTypeBar('Delivery', delivery, total, _H.green),
          ],
        ),
      ),
    );
  }

  Widget _orderTypeBar(String label, int count, int total, Color color) {
    final pct = total > 0 ? count / total : 0.0;
    return Row(
      children: [
        SizedBox(
          width: 62,
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, color: _H.text2),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 6,
              backgroundColor: _H.border,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 28,
          child: Text(
            '$count',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
            textAlign: TextAlign.right,
          ),
        ),
        const SizedBox(width: 4),
        SizedBox(
          width: 36,
          child: Text(
            '${(pct * 100).toStringAsFixed(0)}%',
            style: const TextStyle(fontSize: 10, color: _H.text2),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderStatusCard() {
    if (_isLoadingOrderTypes) return _loadingCard(110);
    final completed = _todayDetailedStats?.completedOrders ?? 0;
    final cancelled = _todayDetailedStats?.cancelledOrders ?? 0;
    final preparing = _todayDetailedStats?.preparingOrders ?? 0;
    final pending = _todayDetailedStats?.pendingOrders ?? 0;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      decoration: _cardDecoration(),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Order Status',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _H.text1,
                    ),
                  ),
                ),
                _todayBadge(),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _orderStatusItem('Completed', completed, _H.green),
                ),
                Expanded(
                  child: _orderStatusItem('Cancelled', cancelled, _H.red),
                ),
                Expanded(
                  child: _orderStatusItem('Preparing', preparing, _H.amber),
                ),
                Expanded(child: _orderStatusItem('Pending', pending, _H.blue)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _orderStatusItem(String label, int count, Color color) {
    return Column(
      children: [
        const SizedBox(height: 8),
        Text(
          '$count',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: _H.text2,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  static const _paymentConfig = {
    'Cash': (label: 'Cash', color: _H.green, icon: Icons.payments_outlined),
    'UPI': (label: 'UPI', color: _H.purple, icon: Icons.qr_code_2_outlined),
    'QR_PAYMENT': (
      label: 'QR Payment',
      color: _H.blue,
      icon: Icons.qr_code_scanner_outlined,
    ),
    'USER_ONLINE_PAYMENT': (
      label: 'Online',
      color: _H.blue,
      icon: Icons.credit_card_outlined,
    ),
    'Maamaas_Wallet': (
      label: 'Wallet',
      color: _H.amber,
      icon: Icons.account_balance_wallet_outlined,
    ),
    'Card': (label: 'Card', color: _H.blue, icon: Icons.credit_card_outlined),
  };

  Widget _buildCollectionSummaryCard() {
    if (_isLoadingOrderTypes) {
      return _DashCardShimmer(height: 130);
    }
    if (_todayDetailedStats == null ||
        _todayDetailedStats!.paymentBreakdown.isEmpty) {
      return const SizedBox.shrink();
    }
    final totalCollected = _todayDetailedStats!.paymentBreakdown.entries
        .where((e) => e.key != 'Online_Payment')
        .fold(0.0, (s, e) => s + e.value);
    final filteredEntries = _todayDetailedStats!.paymentBreakdown.entries
        .where((e) => e.key != 'Online_Payment')
        .toList();
    if (filteredEntries.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      decoration: BoxDecoration(
        color: _H.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _H.border),
        boxShadow: [
          BoxShadow(
            color: _H.shadow,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: _H.accentLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_outlined,
                    color: _H.accent,
                    size: 14,
                  ),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Collection Summary',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _H.text1,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: _H.accentLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Today',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: _H.accent,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ...filteredEntries.map((e) {
              final cfg = _paymentConfig[e.key];
              if (cfg == null) return const SizedBox.shrink();
              final label = cfg.label;
              final color = cfg.color;
              final pct = totalCollected > 0
                  ? (e.value / totalCollected) * 100
                  : 0.0;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        label,
                        style: const TextStyle(fontSize: 13, color: _H.text2),
                      ),
                    ),
                    Text(
                      '₹${e.value.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${pct.toStringAsFixed(1)}%',
                      style: const TextStyle(fontSize: 11, color: _H.text3),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSellingChart() {
    if (_isLoadingVendorStats) {
      return const _TopSellingShimmer();
    }

    final colors = [
      _H.green,
      _H.amber,
      _H.blue,
      _H.purple,
      _H.red,
      _H.teal,
      const Color(0xFFEC4899),
      const Color(0xFF6366F1),
    ];
    List<Map<String, dynamic>> items = [];
    if (_vendorStats != null) {
      final rawList = _vendorStats!['topSellingItems'];
      if (rawList is List) {
        items = rawList.asMap().entries.map((e) {
          final entry = e.value as Map<String, dynamic>;
          return {
            'label': entry['dishName']?.toString() ?? 'Unknown',
            'orders': (entry['quantity'] ?? 0) as int,
            'color': colors[e.key % colors.length],
          };
        }).toList();
      }
    }

    if (items.isEmpty) {
      return _chartCard(
        title: 'Top Selling Items',
        subtitle: 'All time',
        child: const SizedBox(
          height: 80,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.bar_chart_rounded,
                  size: 40,
                  color: Color(0xFFB0B3C1),
                ),
                SizedBox(height: 8),
                Text(
                  'No top selling data',
                  style: TextStyle(color: Color(0xFF6B7280), fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return _chartCard(
      title: 'Top Selling Items',
      subtitle: 'All time',
      child: Column(
        children: List.generate(items.length, (index) {
          final item = items[index];
          final color = item['color'] as Color;
          final qty = item['orders'] as int;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: color,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['label'] as String,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _H.text1,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.shopping_bag_rounded,
                          size: 13,
                          color: color,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          qty.toString(),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (index != items.length - 1)
                const Divider(height: 1, color: Color(0xFFEEEFF5)),
            ],
          );
        }),
      ),
    );
  }

  Widget _chartCard({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _H.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _H.border),
        boxShadow: [
          BoxShadow(
            color: _H.shadow,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: _H.accentLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.bar_chart_rounded,
                    color: _H.accent,
                    size: 14,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _H.text1,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

// ─── Offline Reasons Sheet ─────────────────────────────────────────────────────

class _OfflineSheet extends StatefulWidget {
  final Function(List<String>) onConfirm;
  final VoidCallback onCancel;

  const _OfflineSheet({required this.onConfirm, required this.onCancel});

  @override
  State<_OfflineSheet> createState() => _OfflineSheetState();
}

class _OfflineSheetState extends State<_OfflineSheet> {
  static const _reasons = [
    'Items out of stock',
    'Ingredients not available',
    'Kitchen equipment issue',
    'Staff shortage',
    'Power outage',
    'Maintenance work',
    'Weather conditions',
  ];

  final Set<String> _sel = {};
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keyboardH = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: keyboardH + 16,
        left: 20,
        right: 20,
        top: 12,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: _H.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _H.amberLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: _H.amber,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Reason for going offline',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: _H.text1,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: widget.onCancel,
                  child: const Icon(Icons.close, color: _H.text2, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Select at least one reason:',
              style: TextStyle(fontSize: 12, color: _H.text2),
            ),
            const SizedBox(height: 10),
            ..._reasons.map(
              (r) => CheckboxListTile(
                value: _sel.contains(r),
                onChanged: (v) =>
                    setState(() => v! ? _sel.add(r) : _sel.remove(r)),
                title: Text(
                  r,
                  style: const TextStyle(fontSize: 13, color: _H.text1),
                ),
                activeColor: _H.accent,
                contentPadding: EdgeInsets.zero,
                dense: true,
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _ctrl,
              maxLines: 2,
              maxLength: 200,
              decoration: InputDecoration(
                hintText: 'Other reason (optional)...',
                hintStyle: const TextStyle(fontSize: 12, color: _H.text2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: _H.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: _H.accent),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: widget.onCancel,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      decoration: BoxDecoration(
                        color: _H.bg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _H.border),
                      ),
                      child: const Center(
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _H.text2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      final list = [..._sel];
                      if (_ctrl.text.trim().isNotEmpty) {
                        list.add('Other: ${_ctrl.text.trim()}');
                      }
                      if (list.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                              'Please select at least one reason',
                            ),
                            backgroundColor: _H.amber,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                        return;
                      }
                      widget.onConfirm(list);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      decoration: BoxDecoration(
                        color: _H.amber,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Text(
                          'Go Offline',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
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
    );
  }
}

// ─── New Order Popup ────────────────────────────────────────────────────────

enum _PopupStep { details, selectPrinter }

class _NewOrderPopupDialog extends StatefulWidget {
  final Map<String, dynamic> order;
  final bool isSoundEnabled;
  final bool printEnabled;
  final VoidCallback onToggleSound;
  final VoidCallback onTogglePrint;
  final Function(String mac) onSetDefaultPrinter;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const _NewOrderPopupDialog({
    required this.order,
    required this.isSoundEnabled,
    required this.printEnabled,
    required this.onToggleSound,
    required this.onTogglePrint,
    required this.onSetDefaultPrinter,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  State<_NewOrderPopupDialog> createState() => _NewOrderPopupDialogState();
}

class _NewOrderPopupDialogState extends State<_NewOrderPopupDialog> {
  _PopupStep _step = _PopupStep.details;
  bool _acting = false;
  late bool _sound;
  late bool _print;

  List<BluetoothInfo> _devices = [];
  bool _loadingDevices = false;
  bool _connecting = false;

  @override
  void initState() {
    super.initState();
    _sound = widget.isSoundEnabled;
    _print = widget.printEnabled;
  }

  List<Map<String, dynamic>> _items() {
    final cartItems = widget.order['cartItems'] as List? ?? [];
    final orderItems = widget.order['order'] as List? ?? [];
    final raw = orderItems.isNotEmpty ? orderItems : cartItems;
    return raw
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  // ── Step transitions ──────────────────────────────────────────────

  void _handleDecline() {
    if (_acting) return;
    setState(() => _acting = true);
    widget.onDecline();
  }

  Future<void> _handleAcceptTap() async {
    if (_acting) return;
    if (_print) {
      setState(() {
        _step = _PopupStep.selectPrinter;
        _loadingDevices = true;
      });
      try {
        final paired = await PrintBluetoothThermal.pairedBluetooths;
        if (mounted) {
          setState(() {
            _devices = paired;
            _loadingDevices = false;
          });
        }
      } catch (_) {
        if (mounted) setState(() => _loadingDevices = false);
      }
    } else {
      setState(() => _acting = true);
      widget.onAccept();
    }
  }

  Future<void> _connectAndPrint(String mac) async {
    setState(() => _connecting = true);
    try {
      await PrintBluetoothThermal.disconnect;
      final connected = await PrintBluetoothThermal.connect(
        macPrinterAddress: mac,
      );
      if (connected) {
        await printOrderReceipt(widget.order);
        widget.onSetDefaultPrinter(mac);
        widget.onAccept(); // parent pops the dialog and finalizes the order
      } else {
        throw Exception('Failed to connect to printer');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _connecting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to print: $e'),
            backgroundColor: _H.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  void _acceptWithoutPrinting() {
    if (_acting) return;
    setState(() => _acting = true);
    widget.onAccept();
  }

  void _backToDetails() {
    if (_connecting) return;
    setState(() => _step = _PopupStep.details);
  }

  // ── UI ───────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: _H.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: _step == _PopupStep.details
              ? _buildDetailsStep(key: const ValueKey('details'))
              : _buildPrinterStep(key: const ValueKey('printer')),
        ),
      ),
    );
  }

  Widget _buildDetailsStep({Key? key}) {
    final order = widget.order;
    final orderId = order['orderId'] ?? order['cartId'] ?? '-';
    final orderType = (order['orderType'] ?? '').toString();
    final tableCode = (order['tableCode'] ?? '').toString();
    final items = _items();

    return Column(
      key: key,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header
        Container(
          padding: const EdgeInsets.fromLTRB(20, 18, 16, 16),
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [_H.accent, Color(0xFFFF8A50)]),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.notifications_active_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'New Order Received',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '#$orderId  •  ${formatOrderType(orderType)}'
                          '${tableCode.isNotEmpty ? ' • Table $tableCode' : ''}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Sound + print toggles — same as the old footer bar
              Row(
                children: [
                  _headerPill(
                    icon: _sound
                        ? Icons.notifications_active_rounded
                        : Icons.notifications_off_rounded,
                    label: _sound ? 'Sound On' : 'Sound Off',
                    onTap: () {
                      widget.onToggleSound();
                      setState(() => _sound = !_sound);
                    },
                  ),
                  const SizedBox(width: 8),
                  _headerPill(
                    icon: Icons.print_rounded,
                    label: _print ? 'Print On' : 'Print Off',
                    onTap: () {
                      widget.onTogglePrint();
                      setState(() => _print = !_print);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),

        // Items list
        Flexible(
          child: items.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'No item details available',
                    style: TextStyle(color: _H.text2),
                  ),
                )
              : ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 260),
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    itemCount: items.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, color: _H.border),
                    itemBuilder: (_, i) => _itemRow(items[i]),
                  ),
                ),
        ),

        // Actions (or spinner while acting)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: _acting
              ? const SizedBox(
                  height: 46,
                  child: Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: _H.accent,
                        strokeWidth: 2.4,
                      ),
                    ),
                  ),
                )
              : Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: _handleDecline,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF0F0),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _H.red.withOpacity(0.3)),
                          ),
                          child: const Center(
                            child: Text(
                              'Decline',
                              style: TextStyle(
                                color: _H.red,
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: _handleAcceptTap,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF10B981), Color(0xFF059669)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              _print ? 'Accept & Print' : 'Accept',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
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
    );
  }

  Widget _buildPrinterStep({Key? key}) {
    return Column(
      key: key,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 16, 12),
          child: Row(
            children: [
              GestureDetector(
                onTap: _connecting ? null : _backToDetails,
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: _H.bg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.arrow_back_rounded,
                    size: 18,
                    color: _H.text1,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select Printer',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: _H.text1,
                      ),
                    ),
                    Text(
                      'For Order #${widget.order['orderId'] ?? widget.order['cartId']}',
                      style: const TextStyle(fontSize: 11, color: _H.text2),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: _H.border),
        SizedBox(
          height: 220,
          child: _loadingDevices
              ? const _PrinterListShimmer()
              : _devices.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.bluetooth_disabled_rounded,
                        size: 40,
                        color: _H.text2,
                      ),
                      SizedBox(height: 10),
                      Text(
                        'No printers found',
                        style: TextStyle(
                          color: _H.text2,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Please pair your printer first',
                        style: TextStyle(color: _H.text2, fontSize: 11),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  itemCount: _devices.length,
                  itemBuilder: (_, i) {
                    final device = _devices[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _H.bg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _H.border),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: _H.blueLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.print_rounded,
                              color: _H.blue,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  device.name,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: _H.text1,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  device.macAdress,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: _H.text2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: _connecting
                                ? null
                                : () => _connectAndPrint(device.macAdress),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [_H.green, Color(0xFF059669)],
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: _connecting
                                  ? const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'Print',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
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
        const Divider(height: 1, color: _H.border),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: _connecting ? null : _acceptWithoutPrinting,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    decoration: BoxDecoration(
                      color: _H.amberLight,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _H.amber.withOpacity(0.3)),
                    ),
                    child: const Center(
                      child: Text(
                        'Accept Without Print',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _H.amber,
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
    );
  }

  Widget _headerPill({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.18),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 14),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _itemRow(Map<String, dynamic> item) {
    final name = (item['dishName'] ?? item['itemsName'] ?? 'Item').toString();
    final qty = (item['quantity'] ?? 1).toString();
    final price = item['price'] ?? item['itemPrice'];
    final addons = (item['addons'] as List? ?? [])
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .where((a) => (a['addonName'] ?? '').toString().isNotEmpty)
        .toList();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 26,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _H.accentLight,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Text(
                  'x$qty',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: _H.accent,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _H.text1,
                  ),
                ),
              ),
              if (price != null)
                Text(
                  '₹$price',
                  style: const TextStyle(fontSize: 12, color: _H.text2),
                ),
            ],
          ),
          if (addons.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 40, top: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: addons.map((a) {
                  final aName = (a['addonName'] ?? 'Addon').toString();
                  final aQty = (a['quantity'] ?? 1).toString();
                  final aPrice = a['totalPrice'] ?? a['addonPrice'];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.add_rounded,
                          size: 12,
                          color: _H.text2,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            aQty != '1' ? '$aName  x$aQty' : aName,
                            style: const TextStyle(
                              fontSize: 11,
                              color: _H.text2,
                            ),
                          ),
                        ),
                        if (aPrice != null)
                          Text(
                            '₹$aPrice',
                            style: const TextStyle(
                              fontSize: 11,
                              color: _H.text2,
                            ),
                          ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Drawer Content Refresher ──────────────────────────────────────────────────
class _DrawerContentRefresher extends StatefulWidget {
  final Widget child;
  final VoidCallback onMount;

  const _DrawerContentRefresher({required this.child, required this.onMount});

  @override
  State<_DrawerContentRefresher> createState() =>
      _DrawerContentRefresherState();
}

class _DrawerContentRefresherState extends State<_DrawerContentRefresher> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onMount();
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _PulsingDot extends StatefulWidget {
  final Color color;
  const _PulsingDot({required this.color});

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _scale = Tween<double>(
      begin: 0.7,
      end: 1.3,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: widget.color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: widget.color.withOpacity(0.5),
              blurRadius: 6,
              spreadRadius: 1,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── DashboardStatsModel ──────────────────────────────────────────────────────

class DashboardStatsModel {
  final double totalRevenue;
  final int totalOrders;
  final String averageRating;
  final int totalRatings;
  final double netRevenue;
  final double discountAmount;
  final double grossRevenue;
  final String profitMargin;
  final String period;
  final List<DailyStat> dailyStats;

  DashboardStatsModel({
    required this.totalRevenue,
    required this.totalOrders,
    required this.averageRating,
    required this.totalRatings,
    required this.netRevenue,
    required this.discountAmount,
    required this.grossRevenue,
    required this.profitMargin,
    required this.period,
    required this.dailyStats,
  });

  double get dailyRevenue =>
      dailyStats.isNotEmpty ? dailyStats.first.revenue : 0.0;
  int get dailyOrders => dailyStats.isNotEmpty ? dailyStats.first.orders : 0;

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) =>
      DashboardStatsModel(
        totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
        totalOrders: (json['totalOrders'] ?? 0).toInt(),
        averageRating: json['averageRating'] ?? '0.00',
        totalRatings: (json['totalRatings'] ?? 0).toInt(),
        netRevenue: (json['netRevenue'] ?? 0).toDouble(),
        discountAmount: (json['discountAmount'] ?? 0).toDouble(),
        grossRevenue: (json['grossRevenue'] ?? 0).toDouble(),
        profitMargin: json['profitMargin'] ?? '0%',
        period: json['period'] ?? '',
        dailyStats: (json['dailyStats'] as List? ?? [])
            .map((e) => DailyStat.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

// ─── API Helper ───────────────────────────────────────────────────────────────

Future<DashboardStatsModel> getVendorDashboardStats(
  int vendorId, {
  required DateTime fromDate,
  required DateTime toDate,
}) async {
  final from =
      '${fromDate.year}-${fromDate.month.toString().padLeft(2, '0')}-${fromDate.day.toString().padLeft(2, '0')}';
  final to =
      '${toDate.year}-${toDate.month.toString().padLeft(2, '0')}-${toDate.day.toString().padLeft(2, '0')}';

  final response = await ApiClient.get(
    'api/orders/vendor/statistics/custom',
    service: 'food',
    queryParams: {
      'vendorId': vendorId.toString(),
      'fromDate': from,
      'toDate': to,
    },
  );

  if (response.statusCode == 200) {
    return DashboardStatsModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }
  if (response.statusCode == 404)
    throw Exception('Vendor statistics not found');
  throw Exception(
    'Failed to load stats: ${response.statusCode} ${response.body}',
  );
}
