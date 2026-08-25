import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'DineOutMenu_Managemnet.dart';
import '../DineOut_Services/DineOutAuthService.dart';
import 'DineoutHelpers.dart';

class OnlineBooking {
  final int id;
  final int userId;
  final String startTime;
  final int durationMinutes;
  final String phoneNumber;
  final String guestName;
  final String bookingDate;
  final String arrivalStatus;
  final String types;
  final String createdAt;
  final int capacity;
  final int seatingId;
  final int vendorId;
  final String code;

  const OnlineBooking({
    required this.id,
    required this.userId,
    required this.startTime,
    required this.durationMinutes,
    required this.phoneNumber,
    required this.guestName,
    required this.bookingDate,
    required this.arrivalStatus,
    required this.types,
    required this.createdAt,
    required this.capacity,
    required this.seatingId,
    required this.vendorId,
    required this.code,
  });

  factory OnlineBooking.fromJson(Map<String, dynamic> j) => OnlineBooking(
    id: (j['id'] as num?)?.toInt() ?? 0,
    userId: (j['userId'] as num?)?.toInt() ?? 0,
    startTime: j['startTime'] ?? '',
    durationMinutes: (j['durationMinutes'] as num?)?.toInt() ?? 0,
    phoneNumber: j['phoneNumber'] ?? '',
    guestName: j['guestName'] ?? '',
    bookingDate: j['bookingDate'] ?? '',
    arrivalStatus: j['arrivalStatus'] ?? '',
    types: j['types'] ?? '',
    createdAt: j['createdAt'] ?? '',
    capacity: (j['capacity'] as num?)?.toInt() ?? 0,
    seatingId: (j['seatingId'] as num?)?.toInt() ?? 0,
    vendorId: (j['vendorId'] as num?)?.toInt() ?? 0,
    code: j['code'] ?? '',
  );

  bool get isActive =>
      arrivalStatus != 'COMPLETED' && arrivalStatus != 'CANCELLED';
}

// ─────────────────────────────────────────────────────────────────────────────
//  BOOKING TAB WIDGET
// ─────────────────────────────────────────────────────────────────────────────
class BookingTab extends StatefulWidget {
  final List<Map<String, dynamic>> tables;
  final List<Map<String, dynamic>> reservations;
  final Function() onTablesUpdated;

  const BookingTab({
    super.key,
    required this.tables,
    required this.reservations,
    required this.onTablesUpdated,
  });

  @override
  State<BookingTab> createState() => _BookingTabState();
}

class _BookingTabState extends State<BookingTab>
    with AutomaticKeepAliveClientMixin {
  // ── Palette ──────────────────────────────────────────────────────────────────
  static const Color _orange = Color(0xFFE87722);
  static const Color _orangeLight = Color(0xFFFFF4EC);
  static const Color _white = Color(0xFFFFFFFF);
  static const Color _border = Color(0xFFEEECEA);
  static const Color _textDark = Color(0xFF1A1A1A);
  static const Color _textMuted = Color(0xFF888888);
  static const Color _success = Color(0xFF4CAF50);
  static const Color _error = Color(0xFFE53935);
  static const Color _bgLight = Color(0xFFF8F8F8);
  static const Color _onlineBlue = Color(0xFF1976D2);

  List<Map<String, dynamic>> _tables = [];
  late ScrollController _scrollController;
  bool _isStatusCardsVisible = true;

  Map<String, dynamic>? _selectedTableCart;
  bool _isLoadingCart = false;
  Map<String, double> _tableCartTotals = {};
  bool _isFetchingCartTotals = false;
  bool _isProcessingPayment = false;
  String _paymentMethod = '';
  final TextEditingController _couponController = TextEditingController();
  bool _isCouponApplied = false;
  double _couponDiscount = 0;

  Map<String, int> _tableTimerSeconds = {};
  Timer? _tickTimer;

  Map<int, OnlineBooking> _onlineBySeating = {};
  bool _isFetchingOnline = false;
  Map<int, int> _bookingUserIdMap = {};

  @override
  bool get wantKeepAlive => true;

  // ── Lifecycle ─────────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _tables = List.from(widget.tables);
    _scrollController = ScrollController()..addListener(_onScroll);
    _startTickTimer();
    _fetchAllCartTotals();
    _refreshActiveBookings();
    _fetchOnlineBookings();
  }

  @override
  void didUpdateWidget(BookingTab old) {
    super.didUpdateWidget(old);
    if (old.tables != widget.tables) {
      setState(() => _tables = List.from(widget.tables));
      _buildTimerSecondsMap();
      _fetchAllCartTotals();
      _refreshActiveBookings();
      _fetchOnlineBookings();
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _tickTimer?.cancel();
    _couponController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final vis = _scrollController.offset <= 50;
    if (_isStatusCardsVisible != vis) {
      setState(() => _isStatusCardsVisible = vis);
    }
  }

  // ── Online bookings ───────────────────────────────────────────────────────────
  Future<void> _fetchOnlineBookings() async {
    if (_isFetchingOnline) return;
    _isFetchingOnline = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final vendorId = prefs.getInt('vendorId') ?? 0;
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

      final raw = await DineoutAuthService.fetchIsBookedByUser(
        vendorId: vendorId,
      );

      final Map<int, OnlineBooking> map = {};
      for (final item in raw) {
        try {
          final b = OnlineBooking.fromJson(item as Map<String, dynamic>);
          if (b.bookingDate == today && b.isActive && b.types == 'SHEDULE') {
            if (!map.containsKey(b.seatingId) || b.id > map[b.seatingId]!.id) {
              map[b.seatingId] = b;
            }
          }
        } catch (_) {}
      }

      if (mounted) setState(() => _onlineBySeating = map);
    } catch (e) {
      // debugPrint('❌ _fetchOnlineBookings: $e');
    } finally {
      _isFetchingOnline = false;
    }
  }

  OnlineBooking? _onlineFor(int seatingId) => _onlineBySeating[seatingId];

  // ── Resolve userId ────────────────────────────────────────────────────────────
  int _resolveUserId(int seatingId, int bookingId) {
    final online = _onlineFor(seatingId);
    if (online != null && online.userId != 0) return online.userId;
    if (_bookingUserIdMap.containsKey(bookingId)) {
      return _bookingUserIdMap[bookingId]!;
    }
    return 0;
  }

  // ── Helper: convert time string to minutes ────────────────────────────────────
  int _timeToMinutes(String timeStr) {
    if (timeStr.isEmpty) return 0;
    final parts = timeStr.split(':');
    if (parts.length < 2) return 0;
    return (int.tryParse(parts[0]) ?? 0) * 60 + (int.tryParse(parts[1]) ?? 0);
  }

  // ── Get active booking data for a table (mirrors React logic exactly) ─────────
  Future<Map<String, int?>> _getActiveBookingDataForTable(
    int seatingId,
    int vendorId,
  ) async {
    if (vendorId == 0) return {'id': null, 'userId': null};
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    final reservations = await DineoutAuthService.fetchReservations(
      vendorId: vendorId,
      date: today,
    );

    final now = DateTime.now();
    final currentMinutes = now.hour * 60 + now.minute;

    // Filter: only non-completed, non-cancelled for this seatingId
    final tableBookings = reservations.where((b) {
      final s = b['arrivalStatus'] ?? b['status'] ?? '';
      return s != 'COMPLETED' &&
          s != 'CANCELLED' &&
          b['seatingId'] == seatingId;
    }).toList();

    if (tableBookings.isEmpty) return {'id': null, 'userId': null};

    Map<String, dynamic>? currentActive;
    Map<String, dynamic>? mostRecent;
    Map<String, dynamic>? nextUpcoming;
    int mostRecentDiff = 999999;
    int smallestFutureDiff = 999999;

    for (final booking in tableBookings) {
      final startMin = _timeToMinutes(
        booking['time'] ?? booking['startTime'] ?? '',
      );
      final dur =
          (booking['durationMinutes'] as num?)?.toInt() ??
          int.tryParse(
            (booking['duration'] ?? '').replaceAll(RegExp(r'[^0-9]'), ''),
          ) ??
          90;
      final endMin = startMin + dur;

      if (currentMinutes >= startMin && currentMinutes <= endMin) {
        currentActive = booking;
        break;
      }

      if (endMin < currentMinutes) {
        final diff = currentMinutes - endMin;
        if (diff < mostRecentDiff) {
          mostRecentDiff = diff;
          mostRecent = booking;
        }
      }

      if (startMin > currentMinutes) {
        final diff = startMin - currentMinutes;
        if (diff < smallestFutureDiff) {
          smallestFutureDiff = diff;
          nextUpcoming = booking;
        }
      }
    }

    final active =
        currentActive ?? mostRecent ?? nextUpcoming ?? tableBookings.first;

    final activeId = active['id'] is int
        ? active['id']
        : int.tryParse('${active['id']}');
    final activeUserId = (active['userId'] as num?)?.toInt();

    return {'id': activeId, 'userId': activeUserId};
  }

  // ── Refresh active bookings ───────────────────────────────────────────────────
  Future<void> _refreshActiveBookings() async {
    final prefs = await SharedPreferences.getInstance();
    final vendorId = prefs.getInt('vendorId') ?? 0;
    if (vendorId == 0) return;

    final updated = List<Map<String, dynamic>>.from(_tables);
    bool changed = false;

    for (final t in updated) {
      final status = t['status'] ?? '';
      if (status == 'Reserved' || status == 'Occupied') {
        final id = t['id'] is int ? t['id'] : int.tryParse('${t['id']}') ?? 0;
        final data = await _getActiveBookingDataForTable(id, vendorId);
        final activeId = data['id'];
        final activeUserId = data['userId'];

        if (activeId != null && activeId != 0 && t['bookingId'] != activeId) {
          t['bookingId'] = activeId;
          changed = true;
        }
        if (activeId != null && activeUserId != null && activeUserId != 0) {
          _bookingUserIdMap[activeId] = activeUserId;
        }
      }
    }
    if (changed && mounted) setState(() => _tables = updated);
  }

  // ── Countdown timer ───────────────────────────────────────────────────────────
  void _buildTimerSecondsMap() {
    final now = DateTime.now();
    final map = <String, int>{};
    for (final t in _tables) {
      final bId = t['bookingId'];
      final stStr = t['bookingStartTime'] ?? '';
      final dur = t['bookingDuration'] ?? 0;
      if (bId != null && bId != 0 && stStr.isNotEmpty && dur > 0) {
        final p = stStr.split(':');
        if (p.length >= 2) {
          final start = DateTime(
            now.year,
            now.month,
            now.day,
            int.tryParse(p[0]) ?? 0,
            int.tryParse(p[1]) ?? 0,
          );
          final diff = start
              .add(Duration(minutes: dur as int))
              .difference(now)
              .inSeconds;
          map[t['id'].toString()] = diff > 0 ? diff : 0;
        }
      }
    }
    setState(() => _tableTimerSeconds = map);
  }

  void _startTickTimer() {
    _buildTimerSecondsMap();
    _tickTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _tableTimerSeconds.updateAll((k, v) => v > 0 ? v - 1 : 0));
    });
  }

  String _fmtSecs(int s) =>
      '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';

  // ── Cart totals ───────────────────────────────────────────────────────────────
  Future<void> _fetchAllCartTotals() async {
    if (_isFetchingCartTotals) return;
    _isFetchingCartTotals = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final vendorId = prefs.getInt('vendorId') ?? 0;
      if (vendorId == 0) return;

      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final bookings = await DineoutAuthService.fetchReservations(
        vendorId: vendorId,
        date: today,
      );

      final active = bookings.where((b) {
        final s = b['arrivalStatus'] ?? b['status'] ?? '';
        return s != 'COMPLETED' && s != 'CANCELLED';
      }).toList();

      final totals = <String, double>{};
      for (final b in active) {
        final bId = b['id'];
        if (bId == null) continue;

        final bUserId = (b['userId'] as num?)?.toInt();
        if (bUserId != null && bUserId != 0) {
          final bIdInt = bId is int ? bId : int.tryParse('$bId') ?? 0;
          if (bIdInt != 0) _bookingUserIdMap[bIdInt] = bUserId;
        }

        try {
          final cart = await DineoutAuthService.fetchCartByBooking(
            vendorId: vendorId,
            bookingId: bId is int ? bId : int.tryParse('$bId') ?? 0,
          );
          final code = b['code'] ?? '';
          if (cart != null && cart.grandTotal > 0 && code.isNotEmpty) {
            totals[code] = cart.grandTotal;
          }
        } catch (_) {}
      }
      if (mounted) setState(() => _tableCartTotals = totals);
    } catch (_) {
    } finally {
      _isFetchingCartTotals = false;
    }
  }

  // ── Main table tap handler (mirrors React handleTableClick exactly) ────────────

  Future<void> _handleTableTap(Map<String, dynamic> table) async {
    final String status = table['status'] ?? 'Available';
    final String code = table['code'] ?? '';
    final int tableId = table['id'] is int
        ? table['id']
        : int.tryParse('${table['id']}') ?? 0;
    final int capacity = table['seats'] is int
        ? table['seats']
        : int.tryParse('${table['seats'] ?? table['capacity'] ?? 2}') ?? 2;
    final String tableName = table['name'] ?? '';

    final prefs = await SharedPreferences.getInstance();

    // ── AVAILABLE: create booking silently then open menu ───────────────────────

    if (status == 'Available') {
      final vendorId = prefs.getInt('vendorId') ?? 0;
      if (vendorId == 0) {
        _showSnack('Vendor ID not found');
        return;
      }

      // Clear stale booking data
      await prefs.remove('pendingCartItems');
      await prefs.remove('existingBookingId');
      await prefs.remove('bookingId');

      // Store table details in prefs (same keys as React localStorage)
      await prefs.setString('selectedTableCode', code);
      await prefs.setInt('selectedSeatingId', tableId);
      await prefs.setInt('selectedTableId', tableId);
      await prefs.setInt('selectedTableCapacity', capacity);
      await prefs.setString('selectedTableName', tableName);
      await prefs.setString('tableStatus', 'available');

      // debugPrint(
      //   '📦 Available table tapped → creating booking silently. '
      //   'tableCode: $code, seatingId: $tableId',
      // );

      final now = DateTime.now();
      final ok = await DineoutAuthService.createReservation(
        vendorId: vendorId,
        guestName: '',
        phoneNumber: '',
        capacity: capacity,
        bookingDate: DateFormat('yyyy-MM-dd').format(now),
        startTime: DateFormat('HH:mm:ss').format(now),
        durationMinutes: 90,
        seatingId: tableId,
        types: 'BOOK_NOW',
        seating: {
          'id': tableId,
          'name': tableName,
          'seatingStatus': 'Reserved',
          'code': code,
          'capacity': capacity,
          'description': null,
          'remarks': null,
          'cleanTime': '00:30:00',
          'manuallyUpdated': true,
        },
      );

      if (!ok || !mounted) {
        if (mounted) _showSnack('❌ Failed to open table');
        return;
      }

      await widget.onTablesUpdated();
      await _refreshActiveBookings();

      final data = await _getActiveBookingDataForTable(tableId, vendorId);
      final newBookingId = data['id'] ?? 0;
      final newUserId = data['userId'] ?? _onlineFor(tableId)?.userId ?? 0;

      if (newBookingId == 0) {
        _showSnack('❌ Could not retrieve booking');
        return;
      }

      if (newUserId != 0) _bookingUserIdMap[newBookingId] = newUserId;

      // Store real bookingId in prefs
      await prefs.setInt('existingBookingId', newBookingId);
      await prefs.setInt('bookingId', newBookingId);

      // debugPrint(
      //   '✅ Available table booking created → bookingId: $newBookingId, '
      //   'tableCode: $code, userId: $newUserId',
      // );

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DineOutMenu_Managemnet(
              bookingId: newBookingId,
              tableCode: code,
              userId: newUserId != 0 ? newUserId : null,
            ),
          ),
        ).then((_) async {
          await widget.onTablesUpdated();
          await _refreshActiveBookings();
          await _fetchAllCartTotals();
          await _fetchOnlineBookings();
        });
      }
      return;
    }

    // ── RESERVED / OCCUPIED: use existing bookingId, open menu ───────────────
    if (status == 'Reserved' || status == 'Occupied') {
      final vendorId = prefs.getInt('vendorId') ?? 0;
      final data = await _getActiveBookingDataForTable(tableId, vendorId);
      final int existingBookingId =
          data['id'] ??
          (table['bookingId'] is int
              ? table['bookingId']
              : int.tryParse('${table['bookingId']}') ?? 0);
      final int fUserId =
          data['userId'] ?? _resolveUserId(tableId, existingBookingId);

      if (existingBookingId == 0) {
        _showSnack('No active booking found for this table');
        return;
      }

      if (fUserId != 0) _bookingUserIdMap[existingBookingId] = fUserId;

      await prefs.remove('pendingCartItems');
      await prefs.setString('selectedTableCode', code);
      await prefs.setInt('selectedSeatingId', tableId);
      await prefs.setInt('selectedTableId', tableId);
      await prefs.setInt('selectedTableCapacity', capacity);
      await prefs.setString('selectedTableName', tableName);
      await prefs.setInt('existingBookingId', existingBookingId);
      await prefs.setInt('bookingId', existingBookingId);
      await prefs.setString('tableStatus', status.toLowerCase());

      // debugPrint(
      //   '🟠 Booked/Occupied table tapped → bookingId: $existingBookingId, '
      //   'tableCode: $code, userId: $fUserId',
      // );

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DineOutMenu_Managemnet(
              bookingId: existingBookingId,
              tableCode: code,
              userId: fUserId != 0 ? fUserId : null,
            ),
          ),
        ).then((_) async {
          await widget.onTablesUpdated();
          await _refreshActiveBookings();
          await _fetchAllCartTotals();
          await _fetchOnlineBookings();
        });
      }
      return;
    }

    // ── Other statuses ────────────────────────────────────────────────────────
    if (status == 'Vacant') {
      _showSnack('This table is vacant. No active order.');
    } else if (status == 'Cleaning') {
      _showSnack('Table is under cleaning. Please wait.');
    } else if (status == 'Maintenance') {
      _showSnack('Table is under maintenance.');
    }
  }

  Future<void> _navigateToMenu({
    int? bookingId,
    required String tableCode,
    required int tableId,
    int? userid,
    String customerName = '',
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (customerName.isNotEmpty) {
      await prefs.setString('customerName', customerName);
    }

    final finalId = bookingId ?? 0;
    final resolvedUserId = userid ?? _resolveUserId(tableId, finalId);

    // debugPrint(
    //   '🧭 _navigateToMenu → bookingId: $finalId, '
    //   'tableCode: $tableCode, userId: $resolvedUserId',
    // );

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DineOutMenu_Managemnet(
            bookingId: finalId,
            tableCode: tableCode,
            userId: resolvedUserId != 0 ? resolvedUserId : null,
          ),
        ),
      ).then((_) async {
        await widget.onTablesUpdated();
        await _refreshActiveBookings();
        await _fetchAllCartTotals();
        await _fetchOnlineBookings();
      });
    }
  }

  // ── Book table dialog (long press) ────────────────────────────────────────────
  void _showBookTableDialog(Map<String, dynamic> table) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    final timeCtrl = TextEditingController();
    String duration = '90';
    DateTime selDate = DateTime.now();
    TimeOfDay selTime = TimeOfDay.now();
    timeCtrl.text = selTime.format(context);
    final cap = table['capacity'] ?? table['seats'] ?? 2;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (ctx, _, __) => StatefulBuilder(
        builder: (ctx2, setDlg) => Scaffold(
          backgroundColor: Colors.black54,
          body: SafeArea(
            child: Column(
              children: [
                const Spacer(),
                Container(
                  decoration: const BoxDecoration(
                    color: _white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 12),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: _border,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 16, top: 8),
                        child: Align(
                          alignment: Alignment.topRight,
                          child: GestureDetector(
                            onTap: () => Navigator.pop(ctx2),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: _orangeLight,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close_rounded,
                                size: 18,
                                color: _orange,
                              ),
                            ),
                          ),
                        ),
                      ),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(ctx2).size.height * 0.75,
                        ),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 22,
                            vertical: 8,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: _orangeLight,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.calendar_today_rounded,
                                      color: _orange,
                                      size: 17,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'Book Table',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: _textDark,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: _success.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: _success),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.check_circle_rounded,
                                      color: _success,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Selected Table',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'Table ${table['code']} – $cap seater on ${table['name']}',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: _textMuted,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              DineoutHelpers.fieldLabel('CUSTOMER NAME'),
                              const SizedBox(height: 6),
                              DineoutHelpers.inputField(
                                controller: nameCtrl,
                                hint: 'Enter customer name',
                                icon: Icons.person_outline_rounded,
                              ),
                              const SizedBox(height: 14),
                              DineoutHelpers.fieldLabel('PHONE NUMBER'),
                              const SizedBox(height: 6),
                              DineoutHelpers.inputField(
                                controller: phoneCtrl,
                                hint: 'Enter phone number',
                                icon: Icons.phone_outlined,
                                keyboardType: TextInputType.phone,
                              ),
                              const SizedBox(height: 14),
                              DineoutHelpers.fieldLabel('NUMBER OF GUESTS'),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 13,
                                ),
                                decoration: BoxDecoration(
                                  color: _border.withOpacity(0.3),
                                  border: Border.all(color: _border),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.group_outlined,
                                      color: _textMuted,
                                      size: 17,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      '$cap guests',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: _textDark,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 14),
                              DineoutHelpers.fieldLabel('DATE'),
                              const SizedBox(height: 6),
                              GestureDetector(
                                onTap: () async {
                                  final p = await showDatePicker(
                                    context: ctx2,
                                    initialDate: selDate,
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime.now().add(
                                      const Duration(days: 365),
                                    ),
                                    builder: (c, ch) => Theme(
                                      data: Theme.of(c).copyWith(
                                        colorScheme: const ColorScheme.light(
                                          primary: _orange,
                                          onPrimary: Colors.white,
                                          onSurface: _textDark,
                                        ),
                                      ),
                                      child: ch!,
                                    ),
                                  );
                                  if (p != null) setDlg(() => selDate = p);
                                },
                                child: _pickerBox(
                                  icon: Icons.calendar_today_rounded,
                                  label: DateFormat(
                                    'dd/MM/yyyy',
                                  ).format(selDate),
                                ),
                              ),
                              const SizedBox(height: 14),
                              DineoutHelpers.fieldLabel('TIME'),
                              const SizedBox(height: 6),
                              GestureDetector(
                                onTap: () async {
                                  final p = await showTimePicker(
                                    context: ctx2,
                                    initialTime: selTime,
                                    builder: (c, ch) => Theme(
                                      data: Theme.of(c).copyWith(
                                        colorScheme: const ColorScheme.light(
                                          primary: _orange,
                                          onPrimary: Colors.white,
                                        ),
                                      ),
                                      child: ch!,
                                    ),
                                  );
                                  if (p != null) {
                                    setDlg(() {
                                      selTime = p;
                                      timeCtrl.text = p.format(ctx2);
                                    });
                                  }
                                },
                                child: _pickerBox(
                                  icon: Icons.access_time_rounded,
                                  label: timeCtrl.text,
                                  trailing: const Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    size: 16,
                                    color: _textMuted,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              DineoutHelpers.fieldLabel('DURATION'),
                              const SizedBox(height: 6),
                              _dropdownBox(
                                child: DropdownButton<String>(
                                  value: duration,
                                  isExpanded: true,
                                  underline: const SizedBox(),
                                  icon: const Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: _textMuted,
                                  ),
                                  items: const [
                                    DropdownMenuItem(
                                      value: '30',
                                      child: Text('30 minutes'),
                                    ),
                                    DropdownMenuItem(
                                      value: '60',
                                      child: Text('1 hour'),
                                    ),
                                    DropdownMenuItem(
                                      value: '90',
                                      child: Text('1.5 hours (Default)'),
                                    ),
                                    DropdownMenuItem(
                                      value: '120',
                                      child: Text('2 hours'),
                                    ),
                                    DropdownMenuItem(
                                      value: '150',
                                      child: Text('2.5 hours'),
                                    ),
                                    DropdownMenuItem(
                                      value: '180',
                                      child: Text('3 hours'),
                                    ),
                                    DropdownMenuItem(
                                      value: '240',
                                      child: Text('4 hours'),
                                    ),
                                  ],
                                  onChanged: (v) => setDlg(() => duration = v!),
                                ),
                              ),
                              const SizedBox(height: 14),
                              DineoutHelpers.fieldLabel('NOTES (OPTIONAL)'),
                              const SizedBox(height: 6),
                              DineoutHelpers.inputField(
                                controller: notesCtrl,
                                hint: 'Any special requests or notes',
                                icon: Icons.notes_rounded,
                                maxLines: 2,
                              ),
                              const SizedBox(height: 22),
                              Row(
                                children: [
                                  Expanded(
                                    child: DineoutHelpers.cancelButton(
                                      onTap: () => Navigator.pop(ctx2),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: DineoutHelpers.primaryButton(
                                      label: 'Book Table',
                                      onTap: () async {
                                        final name = nameCtrl.text.trim();
                                        final phone = phoneCtrl.text.trim();
                                        if (name.isEmpty) {
                                          _showSnack('Enter customer name');
                                          return;
                                        }
                                        if (phone.isEmpty) {
                                          _showSnack('Enter phone number');
                                          return;
                                        }
                                        String raw =
                                            DineoutHelpers.convertTo24HourFormat(
                                              timeCtrl.text,
                                            );
                                        final fTime = raw.length == 5
                                            ? '$raw:00'
                                            : raw;
                                        final fDate = DateFormat(
                                          'yyyy-MM-dd',
                                        ).format(selDate);
                                        final prefs =
                                            await SharedPreferences.getInstance();
                                        final vId =
                                            prefs.getInt('vendorId') ?? 0;
                                        if (vId == 0) {
                                          _showSnack('Vendor ID not found');
                                          return;
                                        }
                                        final tId = table['id'] ?? 0;
                                        final tCode = table['code'] ?? '';
                                        final tName = table['name'] ?? '';
                                        Navigator.pop(ctx2);
                                        _showSnack('Creating booking…');
                                        final ok =
                                            await DineoutAuthService.createReservation(
                                              vendorId: vId,
                                              guestName: name,
                                              phoneNumber: phone,
                                              capacity: cap is int
                                                  ? cap
                                                  : int.tryParse('$cap') ?? 2,
                                              bookingDate: fDate,
                                              startTime: fTime,
                                              durationMinutes: int.parse(
                                                duration,
                                              ),
                                              seatingId: tId is int
                                                  ? tId
                                                  : int.tryParse('$tId') ?? 0,
                                              types: 'BOOK_NOW',
                                              seating: {
                                                'id': tId,
                                                'name': tName,
                                                'seatingStatus': 'Reserved',
                                                'code': tCode,
                                                'capacity': cap,
                                                'description': notesCtrl.text
                                                    .trim(),
                                                'remarks': phone,
                                                'cleanTime': '00:30:00',
                                                'manuallyUpdated': true,
                                              },
                                            );
                                        if (ok && mounted) {
                                          _showSnack(
                                            '✅ Table $tCode booked for $name',
                                          );
                                          await widget.onTablesUpdated();
                                          await _refreshActiveBookings();
                                          await Future.delayed(
                                            const Duration(seconds: 1),
                                          );
                                          await _fetchAllCartTotals();
                                          await _fetchOnlineBookings();

                                          final tIdInt = tId is int
                                              ? tId
                                              : int.tryParse('$tId') ?? 0;
                                          final data =
                                              await _getActiveBookingDataForTable(
                                                tIdInt,
                                                vId,
                                              );
                                          final newId = data['id'];
                                          final newUserId = data['userId'] ?? 0;
                                          if (newId != null && newUserId != 0) {
                                            _bookingUserIdMap[newId] =
                                                newUserId;
                                          }

                                          _navigateToMenu(
                                            bookingId: newId,
                                            tableCode: tCode,
                                            tableId: tIdInt,
                                            userid: newUserId != 0
                                                ? newUserId
                                                : null,
                                            customerName: name,
                                          );
                                        } else if (mounted) {
                                          _showSnack(
                                            '❌ Failed to create booking',
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                            ],
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
      transitionBuilder: (_, a, __, child) {
        final t = Tween(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOutCubic));
        return SlideTransition(position: a.drive(t), child: child);
      },
    );
  }

  // ── Coupon ────────────────────────────────────────────────────────────────────
  void _applyCoupon() {
    final code = _couponController.text.trim().toUpperCase();
    if (code.isEmpty) {
      _showSnack('Please enter a coupon code');
      return;
    }
    const valid = {
      'SAVE10': {'discount': 10.0, 'type': 'percentage'},
      'SAVE20': {'discount': 20.0, 'type': 'percentage'},
      'FLAT50': {'discount': 50.0, 'type': 'fixed'},
      'WELCOME': {'discount': 15.0, 'type': 'percentage'},
    };
    final c = valid[code];
    if (c != null) {
      final gt = (_selectedTableCart?['grandTotal'] as num?)?.toDouble() ?? 0;
      final disc = c['type'] == 'percentage'
          ? gt * ((c['discount'] as double) / 100)
          : c['discount'] as double;
      setState(() {
        _couponDiscount = disc;
        _isCouponApplied = true;
      });
      _showSnack('Coupon "$code" applied! Saved ₹${disc.toStringAsFixed(2)}');
    } else {
      _couponController.clear();
      _showSnack('Invalid coupon code.');
    }
  }

  void _removeCoupon() {
    setState(() {
      _couponController.clear();
      _isCouponApplied = false;
      _couponDiscount = 0;
    });
    _showSnack('Coupon removed.');
  }

  // ── Payment ───────────────────────────────────────────────────────────────────
  Future<void> _processPayment() async {
    if (_paymentMethod.isEmpty) {
      _showSnack('Please select a payment method');
      return;
    }
    final cart = _selectedTableCart;
    if (cart == null || (cart['cartId'] as int? ?? 0) == 0) {
      _showSnack('Cart is empty');
      return;
    }
    setState(() => _isProcessingPayment = true);
    final prefs = await SharedPreferences.getInstance();
    final vendorId = prefs.getInt('vendorId') ?? 0;
    final phone = (cart['phoneNumber'] as String?)?.replaceAll(
      RegExp(r'\D'),
      '',
    );
    final effPhone = (phone != null && phone.length >= 10)
        ? phone.substring(phone.length - 10)
        : '9999999999';
    try {
      final result = await DineoutAuthService.placeDirectOrder(
        vendorId: vendorId,
        cartId: cart['cartId'] as int,
        paymentMethod: _paymentMethod,
        razorpayPaymentId: '',
        razorpayOrderId: '',
        userId: cart['userId'] as int?,
        isUserOrder: cart['userId'] != null,
        phoneNumber: effPhone,
        amount: (cart['grandTotal'] as num?)?.toDouble(),
      );
      if (result != null) {
        _showSnack(
          '✅ Order #${result['orderId'] ?? result['id'] ?? ''} placed!',
        );
        setState(() {
          _selectedTableCart = null;
          _paymentMethod = '';
          _isCouponApplied = false;
          _couponDiscount = 0;
          _couponController.clear();
        });
        await widget.onTablesUpdated();
        await _refreshActiveBookings();
        await _fetchAllCartTotals();
        await _fetchOnlineBookings();
      } else {
        _showSnack('❌ Payment failed. Please try again.');
      }
    } catch (e) {
      _showSnack('Payment failed: $e');
    } finally {
      if (mounted) setState(() => _isProcessingPayment = false);
    }
  }

  // ── Cart bottom sheet ─────────────────────────────────────────────────────────
  void _showCartSheet() {
    final cart = _selectedTableCart;
    if (cart == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, set) {
          final items = (cart['items'] as List?) ?? [];
          final grandTotal = (cart['grandTotal'] as num?)?.toDouble() ?? 0;
          final subtotal = (cart['subtotal'] as num?)?.toDouble() ?? 0;
          final gst = (cart['gst'] as num?)?.toDouble() ?? 0;
          final svc = (cart['serviceCharges'] as num?)?.toDouble() ?? 0;
          final finalAmount = grandTotal - _couponDiscount;

          return DraggableScrollableSheet(
            initialChildSize: 0.85,
            minChildSize: 0.4,
            maxChildSize: 0.95,
            builder: (ctx2, sc) => Container(
              decoration: const BoxDecoration(
                color: _white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 4),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: _border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: _orangeLight,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.receipt_long_rounded,
                            color: _orange,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Order – Table ${cart['tableNo']}',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: _textDark,
                                ),
                              ),
                              if ((cart['customerName'] as String?)
                                      ?.isNotEmpty ==
                                  true)
                                Text(
                                  '${cart['customerName']}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: _textMuted,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(ctx2),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: _orangeLight,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              size: 16,
                              color: _orange,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: _border),
                  Expanded(
                    child: ListView(
                      controller: sc,
                      padding: const EdgeInsets.all(20),
                      children: [
                        if (items.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 32),
                              child: Column(
                                children: [
                                  Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: _orangeLight,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: const Icon(
                                      Icons.shopping_cart_outlined,
                                      color: _orange,
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  const Text(
                                    'No items in cart',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: _textDark,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Tap on the table to add items',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: _textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          ...items.map<Widget>((item) {
                            final qty = item['quantity'] ?? 1;
                            final price =
                                (item['price'] as num?)?.toDouble() ?? 0;
                            final tot =
                                (item['totalPrice'] as num?)?.toDouble() ??
                                price * qty;
                            final st = item['orderStatus'] ?? '';
                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _bgLight,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: _border),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item['dishName'] ?? '',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: _textDark,
                                          ),
                                        ),
                                        if (st.isNotEmpty) ...[
                                          const SizedBox(height: 4),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: st == 'CONFIRMED'
                                                  ? _success.withOpacity(0.12)
                                                  : _orange.withOpacity(0.12),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              st,
                                              style: TextStyle(
                                                fontSize: 9,
                                                fontWeight: FontWeight.w700,
                                                color: st == 'CONFIRMED'
                                                    ? _success
                                                    : _orange,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        'x$qty',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: _textMuted,
                                        ),
                                      ),
                                      Text(
                                        '₹${tot.toStringAsFixed(0)}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: _textDark,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }),
                        if (items.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: _bgLight,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: _border),
                            ),
                            child: Column(
                              children: [
                                _billRow('Subtotal', subtotal),
                                if (gst > 0) _billRow('GST', gst),
                                if (svc > 0) _billRow('Service Charges', svc),
                                if (_couponDiscount > 0)
                                  _billRow(
                                    'Coupon Discount',
                                    -_couponDiscount,
                                    isDiscount: true,
                                  ),
                                const Divider(height: 16, color: _border),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Total',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: _textDark,
                                      ),
                                    ),
                                    Text(
                                      '₹${finalAmount.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: _orange,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildCouponSection(set),
                          const SizedBox(height: 16),
                          _buildPaymentSelector(set),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isProcessingPayment
                                  ? null
                                  : () async {
                                      Navigator.pop(ctx2);
                                      await _processPayment();
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _orange,
                                foregroundColor: _white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                disabledBackgroundColor: _orange.withOpacity(
                                  0.5,
                                ),
                              ),
                              child: _isProcessingPayment
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: _white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      'Pay ₹${finalAmount.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Bill row ──────────────────────────────────────────────────────────────────
  Widget _billRow(String label, double amount, {bool isDiscount = false}) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: _textMuted),
            ),
            Text(
              isDiscount
                  ? '-₹${amount.abs().toStringAsFixed(2)}'
                  : '₹${amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDiscount ? _success : _textDark,
              ),
            ),
          ],
        ),
      );

  // ── Coupon section ────────────────────────────────────────────────────────────
  Widget _buildCouponSection(StateSetter set) {
    if (_isCouponApplied) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _success.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _success.withOpacity(0.4)),
        ),
        child: Row(
          children: [
            const Icon(Icons.local_offer_rounded, color: _success, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Coupon applied – saved ₹${_couponDiscount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _success,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                _removeCoupon();
                set(() {});
              },
              child: const Icon(Icons.close_rounded, size: 18, color: _success),
            ),
          ],
        ),
      );
    }
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              border: Border.all(color: _border),
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextField(
              controller: _couponController,
              textCapitalization: TextCapitalization.characters,
              style: const TextStyle(fontSize: 13),
              decoration: const InputDecoration(
                hintText: 'Enter coupon code',
                hintStyle: TextStyle(fontSize: 12, color: _textMuted),
                prefixIcon: Icon(
                  Icons.local_offer_outlined,
                  size: 16,
                  color: _textMuted,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () {
            _applyCoupon();
            set(() {});
          },
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: _orange,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: const Text(
              'Apply',
              style: TextStyle(
                color: _white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Payment selector ──────────────────────────────────────────────────────────
  Widget _buildPaymentSelector(StateSetter set) {
    final methods = [
      {'id': 'CASH', 'label': 'Cash', 'icon': Icons.payments_outlined},
      {'id': 'CARD', 'label': 'Card', 'icon': Icons.credit_card_outlined},
      {'id': 'UPI', 'label': 'UPI', 'icon': Icons.qr_code_scanner_outlined},
      {'id': 'ONLINE', 'label': 'Online', 'icon': Icons.language_outlined},
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'PAYMENT METHOD',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: _textMuted,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: methods.map((m) {
            final sel = _paymentMethod == m['id'];
            return Expanded(
              child: GestureDetector(
                onTap: () => set(() => _paymentMethod = m['id'] as String),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: sel ? _orange : _bgLight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: sel ? _orange : _border,
                      width: sel ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        m['icon'] as IconData,
                        size: 18,
                        color: sel ? _white : _textMuted,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        m['label'] as String,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: sel ? _white : _textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ── BUILD ─────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final counts = _calcStatusCounts();
    final colors = _statusColors();
    final bgs = _statusBgs();
    final order = _statusOrder();
    final grouped = _groupTables();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedCrossFade(
          firstChild: Column(
            children: [
              _buildStatusCards(counts, colors, bgs, order),
              const SizedBox(height: 16),
            ],
          ),
          secondChild: const SizedBox.shrink(),
          crossFadeState: _isStatusCardsVisible
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          duration: const Duration(milliseconds: 200),
        ),
        Expanded(
          child: RefreshIndicator(
            color: _orange,
            onRefresh: () async {
              await widget.onTablesUpdated();
              await _refreshActiveBookings();
              await _fetchAllCartTotals();
              await _fetchOnlineBookings();
            },
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              child: _buildGrid(grouped),
            ),
          ),
        ),
      ],
    );
  }

  // ── Status helpers ────────────────────────────────────────────────────────────
  Map<String, int> _calcStatusCounts() {
    final c = <String, int>{
      'Available': 0,
      'Reserved': 0,
      'Vacant': 0,
      'Occupied': 0,
      'Cleaning': 0,
      'Maintenance': 0,
    };
    for (final t in widget.tables) {
      final s = t['status'] as String? ?? 'Available';
      c[s] = (c[s] ?? 0) + 1;
    }
    return c;
  }

  Map<String, Color> _statusColors() => {
    'Available': _success,
    'Reserved': _orange,
    'Vacant': Colors.teal,
    'Occupied': _error,
    'Cleaning': Colors.blue,
    'Maintenance': _textMuted,
  };

  Map<String, Color> _statusBgs() => {
    'Available': _success.withOpacity(0.1),
    'Reserved': _orange.withOpacity(0.1),
    'Vacant': Colors.teal.withOpacity(0.1),
    'Occupied': _error.withOpacity(0.1),
    'Cleaning': Colors.blue.withOpacity(0.1),
    'Maintenance': _textMuted.withOpacity(0.1),
  };

  List<String> _statusOrder() => [
    'Available',
    'Reserved',
    'Vacant',
    'Occupied',
    'Cleaning',
    'Maintenance',
  ];

  Map<String, List<Map<String, dynamic>>> _groupTables() {
    final g = <String, List<Map<String, dynamic>>>{};
    for (final t in _tables) {
      final k = '${t['name'] ?? 'Unknown'}|${t['seats'] ?? t['capacity'] ?? 2}';
      g.putIfAbsent(k, () => []).add(t);
    }
    return g;
  }

  int _floorOrder(String n) =>
      const {
        'Ground Floor': 0,
        'First Floor': 1,
        'Second Floor': 2,
        'Third Floor': 3,
        'Fourth Floor': 4,
        'Fifth Floor': 5,
        'Roof Top': 6,
        'Terrace': 7,
        'Basement': 8,
      }[n] ??
      999;

  // ── Status cards ──────────────────────────────────────────────────────────────
  Widget _buildStatusCards(
    Map<String, int> counts,
    Map<String, Color> colors,
    Map<String, Color> bgs,
    List<String> order,
  ) {
    Widget card(String s) {
      final count = counts[s] ?? 0;
      final col = colors[s] ?? _textMuted;
      final bg = bgs[s] ?? _white;
      return Expanded(
        child: Container(
          margin: const EdgeInsets.only(right: 4),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: col.withOpacity(0.3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: col,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                s,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w600,
                  color: col,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        children: [
          Row(children: order.take(3).map(card).toList()),
          const SizedBox(height: 4),
          Row(children: order.skip(3).take(3).map(card).toList()),
        ],
      ),
    );
  }

  // ── Tables grid ───────────────────────────────────────────────────────────────
  Widget _buildGrid(Map<String, List<Map<String, dynamic>>> grouped) {
    if (_tables.isEmpty) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: _white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _border),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: _orangeLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.table_restaurant_outlined,
                  size: 30,
                  color: _orange,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'No tables added yet',
                style: TextStyle(
                  color: _textDark,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Tap "Add Table" to create a table',
                style: TextStyle(color: _textMuted, fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    final keys = grouped.keys.toList()
      ..sort((a, b) {
        final fA = a.split('|')[0], fB = b.split('|')[0];
        final cA = int.tryParse(a.split('|')[1]) ?? 0;
        final cB = int.tryParse(b.split('|')[1]) ?? 0;
        final fc = _floorOrder(fA).compareTo(_floorOrder(fB));
        return fc != 0 ? fc : cA.compareTo(cB);
      });

    return Column(
      children: keys.map((key) {
        final tables = grouped[key]!;
        final parts = key.split('|');
        final name = parts[0];
        final cap = int.tryParse(parts[1]) ?? 2;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: _white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: _orangeLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.table_restaurant_rounded,
                      size: 18,
                      color: _orange,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: _textDark,
                          ),
                        ),
                        Text(
                          '$cap seater',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: _textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _orangeLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${tables.length} ${tables.length == 1 ? 'table' : 'tables'}',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: _orange,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.75,
              ),
              itemCount: tables.length,
              itemBuilder: (_, i) => _buildCell(tables[i]),
            ),
            const SizedBox(height: 20),
          ],
        );
      }).toList(),
    );
  }

  // ── Single table cell ─────────────────────────────────────────────────────────
  Widget _buildCell(Map<String, dynamic> table) {
    final String status = table['status'] ?? 'Available';
    final String code = table['code'] ?? '';
    final int tableId = table['id'] is int
        ? table['id']
        : int.tryParse('${table['id']}') ?? 0;
    int bookingId = table['bookingId'] is int
        ? table['bookingId']
        : int.tryParse('${table['bookingId']}') ?? 0;

    final OnlineBooking? online = _onlineFor(tableId);
    final int resolvedUserId = _resolveUserId(tableId, bookingId);
    final bool isActive = status == 'Reserved' || status == 'Occupied';
    final double? total = _tableCartTotals[code];
    final int remSecs = _tableTimerSeconds[tableId.toString()] ?? 0;

    final Color statusCol = _statusColors()[status] ?? _textMuted;
    final Color statusBg = _statusBgs()[status] ?? _white;
    final bool hasOnline = online != null;

    return GestureDetector(
      onLongPress: status == 'Available'
          ? () => _showBookTableDialog(table)
          : null,
      onTap: () => _handleTableTap(table),
      child: Container(
        decoration: BoxDecoration(
          color: statusBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: statusCol.withOpacity(0.4), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: statusCol.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (ctx, constraints) {
            final bool compact = constraints.maxHeight < 110;

            return ClipRect(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── ① ONLINE BADGE ──────────────────────────────────────
                  if (hasOnline) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _onlineBlue,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.wifi_rounded, size: 7, color: _white),
                          SizedBox(width: 2),
                          Text(
                            'Online',
                            style: TextStyle(
                              fontSize: 7,
                              fontWeight: FontWeight.w800,
                              color: _white,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                  ] else
                    SizedBox(height: compact ? 0 : 4),

                  // ── ② Table icon ────────────────────────────────────────
                  Container(
                    width: compact ? 26 : 30,
                    height: compact ? 26 : 30,
                    decoration: BoxDecoration(
                      color: statusCol.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.table_restaurant_rounded,
                      size: compact ? 13 : 16,
                      color: statusCol,
                    ),
                  ),
                  const SizedBox(height: 2),

                  // ── ③ Table code ────────────────────────────────────────
                  Text(
                    code,
                    style: TextStyle(
                      fontSize: compact ? 11 : 12,
                      fontWeight: FontWeight.w800,
                      color: statusCol,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // ── ④ Status ────────────────────────────────────────────
                  Text(
                    status,
                    style: TextStyle(
                      fontSize: 8,
                      color: statusCol.withOpacity(0.8),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // ── ⑤ Guest name from online booking ───────────────────
                  if (hasOnline && online!.guestName.isNotEmpty) ...[
                    const SizedBox(height: 1),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        online.guestName,
                        style: const TextStyle(
                          fontSize: 7,
                          color: _onlineBlue,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],

                  // ── ⑥ Cart total badge ──────────────────────────────────
                  if (total != null && total > 0 && isActive) ...[
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: _orange,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '₹${total.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 8,
                          color: _white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],

                  // ── ⑦ Countdown timer ───────────────────────────────────
                  if (isActive && bookingId != 0 && remSecs > 0) ...[
                    const SizedBox(height: 2),
                    Text(
                      _fmtSecs(remSecs),
                      style: TextStyle(
                        fontSize: 8,
                        color: remSecs < 300 ? _error : statusCol,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ── Small widget helpers ──────────────────────────────────────────────────────
  Widget _pickerBox({
    required IconData icon,
    required String label,
    Widget? trailing,
  }) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
    decoration: BoxDecoration(
      color: _white,
      border: Border.all(color: _border),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Icon(icon, size: 17, color: _textMuted),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(fontSize: 13, color: _textDark)),
        if (trailing != null) ...[const Spacer(), trailing],
      ],
    ),
  );

  Widget _dropdownBox({required Widget child}) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
      color: _white,
      border: Border.all(color: _border),
      borderRadius: BorderRadius.circular(12),
    ),
    child: child,
  );

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
