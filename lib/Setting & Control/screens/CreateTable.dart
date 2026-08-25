//
// // import 'dart:convert';
// // import 'package:flutter/material.dart';
// // import 'package:shared_preferences/shared_preferences.dart';
// // import 'package:http/http.dart' as http;
// // import '../services/TableService.dart';
// //
// // const _kOrange = Color(0xFFE66D33);
// // const _kOrangeSoft = Color(0xFFFFF0E8);
// // const _kWhite = Color(0xFFFFFFFF);
// // const _kBg = Color(0xFFF7F8FC);
// // const _kBorder = Color(0xFFEEEFF5);
// // const _kText1 = Color(0xFF111827);
// // const _kText2 = Color(0xFF6B7280);
// // const _kText3 = Color(0xFF374151);
// // const _kGreen = Color(0xFF10B981);
// // const _kGreenLight = Color(0xFFD1FAE5);
// // const _kAmber = Color(0xFFF59E0B);
// // const _kAmberLight = Color(0xFFFEF3C7);
// // const _kRed = Color(0xFFEF4444);
// // const _kRedLight = Color(0xFFFEE2E2);
// // const _kBlue = Color(0xFF3B82F6);
// // const _kBlueLight = Color(0xFFDBEAFE);
// // const _kPurple = Color(0xFF8B5CF6);
// // const _kPurpleLight = Color(0xFFEDE9FE);
// // const _kGrey = Color(0xFF9CA3AF);
// // const _kGreyLight = Color(0xFFF3F4F6);
// //
// // enum TableStatus {
// //   available,
// //   vacant,
// //   reserved,
// //   occupied,
// //   cleaning,
// //   maintenance,
// // }
// //
// // extension TableStatusX on TableStatus {
// //   String get label {
// //     switch (this) {
// //       case TableStatus.available:
// //         return 'Available';
// //       case TableStatus.vacant:
// //         return 'Vacant';
// //       case TableStatus.reserved:
// //         return 'Reserved';
// //       case TableStatus.occupied:
// //         return 'Occupied';
// //       case TableStatus.cleaning:
// //         return 'Cleaning';
// //       case TableStatus.maintenance:
// //         return 'Maintenance';
// //     }
// //   }
// //
// //   String get apiValue {
// //     switch (this) {
// //       case TableStatus.available:
// //         return 'Available';
// //       case TableStatus.vacant:
// //         return 'Vacant';
// //       case TableStatus.reserved:
// //         return 'Reserved';
// //       case TableStatus.occupied:
// //         return 'Occupied';
// //       case TableStatus.cleaning:
// //         return 'Cleaning';
// //       case TableStatus.maintenance:
// //         return 'Maintenance';
// //     }
// //   }
// //
// //   Color get color {
// //     switch (this) {
// //       case TableStatus.available:
// //         return _kGreen;
// //       case TableStatus.vacant:
// //         return _kGrey;
// //       case TableStatus.reserved:
// //         return _kAmber;
// //       case TableStatus.occupied:
// //         return _kRed;
// //       case TableStatus.cleaning:
// //         return _kBlue;
// //       case TableStatus.maintenance:
// //         return _kPurple;
// //     }
// //   }
// //
// //   Color get lightColor {
// //     switch (this) {
// //       case TableStatus.available:
// //         return _kGreenLight;
// //       case TableStatus.vacant:
// //         return _kGreyLight;
// //       case TableStatus.reserved:
// //         return _kAmberLight;
// //       case TableStatus.occupied:
// //         return _kRedLight;
// //       case TableStatus.cleaning:
// //         return _kBlueLight;
// //       case TableStatus.maintenance:
// //         return _kPurpleLight;
// //     }
// //   }
// //
// //   IconData get icon {
// //     switch (this) {
// //       case TableStatus.available:
// //         return Icons.check_circle_outline_rounded;
// //       case TableStatus.vacant:
// //         return Icons.radio_button_unchecked_rounded;
// //       case TableStatus.reserved:
// //         return Icons.event_seat_rounded;
// //       case TableStatus.occupied:
// //         return Icons.people_rounded;
// //       case TableStatus.cleaning:
// //         return Icons.cleaning_services_rounded;
// //       case TableStatus.maintenance:
// //         return Icons.build_circle_outlined;
// //     }
// //   }
// //
// //   static TableStatus fromApi(String? s) {
// //     switch ((s ?? '').toLowerCase()) {
// //       case 'available':
// //         return TableStatus.available;
// //       case 'vacant':
// //         return TableStatus.vacant;
// //       case 'reserved':
// //         return TableStatus.reserved;
// //       case 'occupied':
// //         return TableStatus.occupied;
// //       case 'cleaning':
// //         return TableStatus.cleaning;
// //       case 'maintenance':
// //         return TableStatus.maintenance;
// //       default:
// //         return TableStatus.available;
// //     }
// //   }
// // }
// //
// // class TableModel {
// //   final String id;
// //   final String tableNo;
// //   final String floorName;
// //   final TableStatus status;
// //   final int capacity;
// //   final String customer;
// //   final String phone;
// //   final String guests;
// //   final String bookingTime;
// //   final Map<String, dynamic> originalData;
// //   final int? bookingId;
// //
// //   const TableModel({
// //     required this.id,
// //     required this.tableNo,
// //     required this.floorName,
// //     required this.status,
// //     required this.capacity,
// //     required this.customer,
// //     required this.phone,
// //     required this.guests,
// //     required this.bookingTime,
// //     required this.originalData,
// //     this.bookingId,
// //   });
// // }
// //
// // class WaitlistItem {
// //   final int id;
// //   final String customerName;
// //   final String phone;
// //   final String guests;
// //   final String bookingDate;
// //   final String requestTime;
// //
// //   const WaitlistItem({
// //     required this.id,
// //     required this.customerName,
// //     required this.phone,
// //     required this.guests,
// //     required this.bookingDate,
// //     required this.requestTime,
// //   });
// // }
// //
// // String _todayDate() {
// //   final d = DateTime.now();
// //   return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
// // }
// //
// // String _floorFromName(String? name) {
// //   if (name == null || name.isEmpty) return 'Other';
// //   final n = name.toLowerCase();
// //   if (n.contains('ground')) return 'Ground Floor';
// //   if (n.contains('first')) return 'First Floor';
// //   if (n.contains('second')) return 'Second Floor';
// //   if (n.contains('third')) return 'Third Floor';
// //   if (n.contains('basement')) return 'Basement';
// //   if (n.contains('party')) return 'Party Hall';
// //   if (n.contains('terrace')) return 'Terrace';
// //   if (n.contains('roof')) return 'Roof Top';
// //   return name;
// // }
// //
// // const _floorOrder = [
// //   'Ground Floor',
// //   'First Floor',
// //   'Second Floor',
// //   'Third Floor',
// //   'Basement',
// //   'Party Hall',
// //   'Terrace',
// //   'Roof Top',
// //   'Other',
// // ];
// //
// // class TableManagementScreen extends StatefulWidget {
// //   const TableManagementScreen({super.key});
// //
// //   @override
// //   State<TableManagementScreen> createState() => _TableManagementScreenState();
// // }
// //
// // class _TableManagementScreenState extends State<TableManagementScreen>
// //     with TickerProviderStateMixin {
// //   List<TableModel> _tables = [];
// //   List<WaitlistItem> _waitlist = [];
// //   bool _loading = true;
// //   String? _error;
// //   String _vendorId = '';
// //   String _authToken = '';
// //   int _activeTabIndex = 0;
// //
// //   // ── SELECTION MODE ────────────────────────────────────────────────────────
// //   bool _selectionMode = false;
// //   final Set<String> _selectedIds = {};
// //   bool _deleting = false;
// //   // ─────────────────────────────────────────────────────────────────────────
// //
// //   String selectedFloor = 'All Floors';
// //
// //   final List<String> floors = [
// //     'All Floors',
// //     'Ground Floor',
// //     'First Floor',
// //     'Second Floor',
// //     'Third Floor',
// //     'Basement',
// //     'Party Hall',
// //     'Terrace',
// //     'Roof Top',
// //   ];
// //
// //   late TabController _tabCtrl;
// //   late ScrollController _tablesScrollCtrl;
// //   late ScrollController _waitlistScrollCtrl;
// //
// //   late AnimationController _summaryAnimCtrl;
// //   late Animation<double> _summaryAnim;
// //   bool _summaryVisible = true;
// //   double _lastScrollOffset = 0;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //
// //     _tabCtrl = TabController(length: 2, vsync: this);
// //     _tabCtrl.addListener(() {
// //       if (mounted) {
// //         setState(() => _activeTabIndex = _tabCtrl.index);
// //         if (_tabCtrl.index == 0 && !_summaryVisible) _showSummary();
// //       }
// //     });
// //
// //     _summaryAnimCtrl = AnimationController(
// //       vsync: this,
// //       duration: const Duration(milliseconds: 220),
// //       value: 1.0,
// //     );
// //     _summaryAnim = CurvedAnimation(
// //       parent: _summaryAnimCtrl,
// //       curve: Curves.easeInOut,
// //     );
// //
// //     _tablesScrollCtrl = ScrollController()..addListener(_onTablesScroll);
// //     _waitlistScrollCtrl = ScrollController();
// //
// //     _init();
// //   }
// //
// //   @override
// //   void dispose() {
// //     _tabCtrl.dispose();
// //     _summaryAnimCtrl.dispose();
// //     _tablesScrollCtrl.removeListener(_onTablesScroll);
// //     _tablesScrollCtrl.dispose();
// //     _waitlistScrollCtrl.dispose();
// //     super.dispose();
// //   }
// //
// //   void _onTablesScroll() {
// //     final offset = _tablesScrollCtrl.offset;
// //     final delta = offset - _lastScrollOffset;
// //     _lastScrollOffset = offset;
// //
// //     if (offset <= 10) {
// //       if (!_summaryVisible) _showSummary();
// //       return;
// //     }
// //
// //     if (delta > 6 && _summaryVisible) {
// //       _hideSummary();
// //     } else if (delta < -6 && !_summaryVisible) {
// //       _showSummary();
// //     }
// //   }
// //
// //   void _hideSummary() {
// //     if (!mounted) return;
// //     setState(() => _summaryVisible = false);
// //     _summaryAnimCtrl.reverse();
// //   }
// //
// //   void _showSummary() {
// //     if (!mounted) return;
// //     setState(() => _summaryVisible = true);
// //     _summaryAnimCtrl.forward();
// //   }
// //
// //   Future<void> _init() async {
// //     final prefs = await SharedPreferences.getInstance();
// //     _vendorId = (prefs.getInt('vendorId') ?? prefs.getInt('vendor_id') ?? 0)
// //         .toString();
// //     await _fetchAll();
// //   }
// //
// //   Future<void> _fetchAll() async {
// //     if (!mounted) return;
// //     setState(() {
// //       _loading = true;
// //       _error = null;
// //     });
// //     try {
// //       await _fetchTables();
// //       await _fetchWaitlist();
// //     } catch (e) {
// //       if (mounted) setState(() => _error = e.toString());
// //     } finally {
// //       if (mounted) setState(() => _loading = false);
// //     }
// //   }
// //
// //   Future<void> _fetchTables() async {
// //     try {
// //       final vendorIdStr = _vendorId;
// //       if (vendorIdStr.isEmpty) return;
// //
// //       final tabData = await TableService.fetchTables(vendorIdStr);
// //
// //       final bookData = await TableService.fetchBookings(
// //         vendorIdStr,
// //         _todayDate(),
// //       );
// //
// //       final Map<String, dynamic> bMap = {};
// //       for (final b in bookData) {
// //         final sid = b['seatingId']?.toString();
// //         if (sid != null) {
// //           bMap[sid] = {
// //             'bookingId': b['id'],
// //             'customerName': b['guestName'],
// //             'phoneNumber': b['phoneNumber'],
// //             'guests': b['capacity'],
// //             'bookingDate': b['bookingDate'],
// //             'startTime': b['startTime'],
// //           };
// //         }
// //       }
// //
// //       final transformed = tabData.map<TableModel>((item) {
// //         final sid = item['id'].toString();
// //         final bk = bMap[sid];
// //         return TableModel(
// //           id: sid,
// //           tableNo: item['code']?.toString() ?? '',
// //           floorName: _floorFromName(item['name']?.toString()),
// //           status: TableStatusX.fromApi(item['seatingStatus']?.toString()),
// //           capacity: (item['capacity'] as num?)?.toInt() ?? 4,
// //           customer: bk?['customerName'] ?? item['description'] ?? '',
// //           phone: bk?['phoneNumber'] ?? item['remarks'] ?? '',
// //           guests: bk?['guests']?.toString() ?? '',
// //           bookingTime: bk?['startTime'] ?? '',
// //           originalData: Map<String, dynamic>.from(item),
// //           bookingId: bk?['bookingId'] as int?,
// //         );
// //       }).toList();
// //
// //       if (mounted) {
// //         setState(() {
// //           _tables = transformed;
// //         });
// //       }
// //     } catch (e) {
// //       debugPrint('_fetchTables ERROR: $e');
// //       rethrow;
// //     }
// //   }
// //
// //   Future<void> _fetchWaitlist() async {
// //     try {
// //       final data = await TableService.fetchWaitlist(_vendorId);
// //       if (mounted) {
// //         setState(() {
// //           _waitlist = data
// //               .map<WaitlistItem>(
// //                 (w) => WaitlistItem(
// //                   id: w['id'] as int,
// //                   customerName: w['guestName'] ?? '',
// //                   phone: w['phoneNumber'] ?? '',
// //                   guests: w['capacity']?.toString() ?? '',
// //                   bookingDate: w['bookingDate'] ?? '',
// //                   requestTime: w['requestTime'] ?? '',
// //                 ),
// //               )
// //               .toList();
// //         });
// //       }
// //     } catch (e) {
// //       debugPrint('_fetchWaitlist ERROR: $e');
// //     }
// //   }
// //
// //   Map<String, Map<int, List<TableModel>>> _getGrouped() {
// //     final filtered = selectedFloor == 'All Floors'
// //         ? _tables
// //         : _tables.where((t) => t.floorName == selectedFloor).toList();
// //
// //     final Map<String, Map<int, List<TableModel>>> result = {};
// //     for (final t in filtered) {
// //       result.putIfAbsent(t.floorName, () => {});
// //       result[t.floorName]!.putIfAbsent(t.capacity, () => []);
// //       result[t.floorName]![t.capacity]!.add(t);
// //     }
// //     for (final floor in result.keys) {
// //       final sorted = Map.fromEntries(
// //         result[floor]!.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
// //       );
// //       result[floor] = sorted;
// //     }
// //     return result;
// //   }
// //
// //   List<String> _sortedFloors(Map<String, Map<int, List<TableModel>>> g) =>
// //       g.keys.toList()..sort((a, b) {
// //         final ia = _floorOrder.indexOf(a);
// //         final ib = _floorOrder.indexOf(b);
// //         if (ia != -1 && ib != -1) return ia.compareTo(ib);
// //         if (ia != -1) return -1;
// //         if (ib != -1) return 1;
// //         return a.compareTo(b);
// //       });
// //
// //   // ── SELECTION MODE HELPERS ────────────────────────────────────────────────
// //
// //   /// Enter selection mode and select the long-pressed table
// //   void _enterSelectionMode(String tableId) {
// //     setState(() {
// //       _selectionMode = true;
// //       _selectedIds.clear();
// //       _selectedIds.add(tableId);
// //     });
// //   }
// //
// //   /// Exit selection mode and clear selection
// //   void _exitSelectionMode() {
// //     setState(() {
// //       _selectionMode = false;
// //       _selectedIds.clear();
// //     });
// //   }
// //
// //   /// Toggle a single table's selection
// //   void _toggleSelection(String tableId) {
// //     setState(() {
// //       if (_selectedIds.contains(tableId)) {
// //         _selectedIds.remove(tableId);
// //         // If nothing is selected, leave selection mode
// //         if (_selectedIds.isEmpty) _selectionMode = false;
// //       } else {
// //         _selectedIds.add(tableId);
// //       }
// //     });
// //   }
// //
// //   /// Confirm and delete all selected tables
// //   Future<void> _confirmDeleteSelected() async {
// //     final count = _selectedIds.length;
// //     final confirmed = await showDialog<bool>(
// //       context: context,
// //       builder: (ctx) => AlertDialog(
// //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
// //         title: Row(
// //           children: [
// //             Container(
// //               width: 36,
// //               height: 36,
// //               decoration: BoxDecoration(
// //                 color: _kRedLight,
// //                 borderRadius: BorderRadius.circular(10),
// //               ),
// //               child: const Icon(Icons.delete_rounded, color: _kRed, size: 18),
// //             ),
// //             const SizedBox(width: 10),
// //             Text(
// //               'Delete $count Table${count > 1 ? 's' : ''}',
// //               style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
// //             ),
// //           ],
// //         ),
// //         content: Text(
// //           'Are you sure you want to delete $count selected table${count > 1 ? 's' : ''}? This action cannot be undone.',
// //           style: const TextStyle(fontSize: 14, color: _kText2),
// //         ),
// //         actions: [
// //           TextButton(
// //             onPressed: () => Navigator.pop(ctx, false),
// //             child: const Text('Cancel', style: TextStyle(color: _kText2)),
// //           ),
// //           ElevatedButton(
// //             onPressed: () => Navigator.pop(ctx, true),
// //             style: ElevatedButton.styleFrom(
// //               backgroundColor: _kRed,
// //               foregroundColor: _kWhite,
// //               elevation: 0,
// //               shape: RoundedRectangleBorder(
// //                 borderRadius: BorderRadius.circular(10),
// //               ),
// //             ),
// //             child: Text('Delete $count'),
// //           ),
// //         ],
// //       ),
// //     );
// //
// //     if (confirmed != true) return;
// //
// //     setState(() => _deleting = true);
// //     int successCount = 0;
// //     final List<String> failed = [];
// //
// //     for (final id in _selectedIds.toList()) {
// //       try {
// //         final success = await TableService.deleteTable(tableId: id);
// //         if (success) {
// //           successCount++;
// //         } else {
// //           failed.add(id);
// //         }
// //       } catch (e) {
// //         failed.add(id);
// //         debugPrint('Delete table $id error: $e');
// //       }
// //     }
// //
// //     setState(() => _deleting = false);
// //     _exitSelectionMode();
// //
// //     if (failed.isEmpty) {
// //       _snack(
// //         'Deleted $successCount table${successCount > 1 ? 's' : ''}!',
// //         success: true,
// //       );
// //     }
// //     await _fetchTables();
// //   }
// //
// //   // ─────────────────────────────────────────────────────────────────────────
// //
// //   Future<void> _addTable({
// //     required String name,
// //     required int numberOfTables,
// //     required int capacity,
// //   }) async {
// //     final success = await TableService.addTable(
// //       vendorId: _vendorId,
// //       name: name,
// //       numberOfTables: numberOfTables,
// //       capacity: capacity,
// //     );
// //
// //     if (!success) {
// //       throw Exception('Failed to add table');
// //     }
// //   }
// //
// //   Future<void> _updateTable({
// //     required String tableId,
// //     required String name,
// //     required String code,
// //     required int capacity,
// //     required String status,
// //     required String cleanTime,
// //     required String description,
// //     required String remarks,
// //     required bool manuallyUpdated,
// //   }) async {
// //     final success = await TableService.updateTable(
// //       tableId: tableId,
// //       name: name,
// //       code: code,
// //       capacity: capacity,
// //       status: status,
// //       cleanTime: cleanTime,
// //       description: description,
// //       remarks: remarks,
// //       manuallyUpdated: manuallyUpdated,
// //     );
// //
// //     if (!success) {
// //       throw Exception('Failed to update table');
// //     }
// //   }
// //
// //   Map<TableStatus, int> get _counts {
// //     final m = {for (final s in TableStatus.values) s: 0};
// //     for (final t in _tables) m[t.status] = (m[t.status] ?? 0) + 1;
// //     return m;
// //   }
// //
// //   Future<void> _removeWaitlist(int id) async {
// //     final success = await TableService.removeWaitlist(id);
// //     if (!success) {
// //       throw Exception('Failed to remove waitlist item');
// //     }
// //     await _fetchWaitlist();
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return WillPopScope(
// //       // Back button exits selection mode instead of navigating away
// //       onWillPop: () async {
// //         if (_selectionMode) {
// //           _exitSelectionMode();
// //           return false;
// //         }
// //         return true;
// //       },
// //       child: Scaffold(
// //         backgroundColor: _kBg,
// //         floatingActionButton: _selectionMode ? null : _buildFab(),
// //         body: Column(
// //           children: [
// //             Container(
// //               color: _kWhite,
// //               child: SafeArea(
// //                 bottom: false,
// //                 child: Column(
// //                   mainAxisSize: MainAxisSize.min,
// //                   children: [
// //                     // ── Top bar: normal or selection-mode ─────────────────
// //                     _selectionMode
// //                         ? _buildSelectionTopBar()
// //                         : _buildNormalTopBar(),
// //
// //                     if (_activeTabIndex == 0 &&
// //                         !_loading &&
// //                         _error == null &&
// //                         !_selectionMode)
// //                       SizeTransition(
// //                         sizeFactor: _summaryAnim,
// //                         axisAlignment: 1.0,
// //                         child: _buildSummaryBar(),
// //                       ),
// //
// //                     Container(height: 1, color: _kBorder),
// //                   ],
// //                 ),
// //               ),
// //             ),
// //
// //             Expanded(
// //               child: SafeArea(
// //                 top: false,
// //                 child: _loading
// //                     ? const Center(
// //                         child: CircularProgressIndicator(color: _kOrange),
// //                       )
// //                     : _error != null
// //                     ? _buildError()
// //                     : IndexedStack(
// //                         index: _activeTabIndex,
// //                         children: [_buildTablesTab(), _buildWaitlistTab()],
// //                       ),
// //               ),
// //             ),
// //           ],
// //         ),
// //
// //         // ── Delete bottom bar in selection mode ─────────────────────────
// //         bottomNavigationBar: _selectionMode ? _buildDeleteBottomBar() : null,
// //       ),
// //     );
// //   }
// //
// //   // ── Normal top bar ────────────────────────────────────────────────────────
// //   Widget _buildNormalTopBar() => Container(
// //     padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
// //     decoration: const BoxDecoration(color: _kWhite),
// //     child: Row(
// //       children: [
// //         Expanded(
// //           child: GestureDetector(
// //             onTap: () {
// //               _tabCtrl.animateTo(0);
// //               setState(() {});
// //             },
// //             child: AnimatedContainer(
// //               duration: const Duration(milliseconds: 200),
// //               height: 42,
// //               decoration: BoxDecoration(
// //                 color: _tabCtrl.index == 0 ? Colors.green : _kOrange,
// //                 borderRadius: BorderRadius.circular(10),
// //               ),
// //               alignment: Alignment.center,
// //               child: const Text(
// //                 'Tables',
// //                 style: TextStyle(
// //                   fontSize: 13,
// //                   fontWeight: FontWeight.w700,
// //                   color: _kWhite,
// //                 ),
// //               ),
// //             ),
// //           ),
// //         ),
// //
// //         const SizedBox(width: 10),
// //
// //         Expanded(
// //           child: GestureDetector(
// //             onTap: () {
// //               _tabCtrl.animateTo(1);
// //               setState(() {});
// //             },
// //             child: AnimatedContainer(
// //               duration: const Duration(milliseconds: 200),
// //               height: 42,
// //               decoration: BoxDecoration(
// //                 color: _tabCtrl.index == 1 ? Colors.green : _kOrange,
// //                 borderRadius: BorderRadius.circular(10),
// //               ),
// //               alignment: Alignment.center,
// //               child: Row(
// //                 mainAxisAlignment: MainAxisAlignment.center,
// //                 children: [
// //                   const Text(
// //                     'Waitlist',
// //                     style: TextStyle(
// //                       fontSize: 13,
// //                       fontWeight: FontWeight.w700,
// //                       color: _kWhite,
// //                     ),
// //                   ),
// //                   if (_waitlist.isNotEmpty) ...[
// //                     const SizedBox(width: 6),
// //                     Container(
// //                       padding: const EdgeInsets.symmetric(
// //                         horizontal: 6,
// //                         vertical: 2,
// //                       ),
// //                       decoration: BoxDecoration(
// //                         color: Colors.white.withOpacity(0.25),
// //                         borderRadius: BorderRadius.circular(10),
// //                       ),
// //                       child: Text(
// //                         '${_waitlist.length}',
// //                         style: const TextStyle(
// //                           fontSize: 10,
// //                           fontWeight: FontWeight.w800,
// //                           color: _kWhite,
// //                         ),
// //                       ),
// //                     ),
// //                   ],
// //                 ],
// //               ),
// //             ),
// //           ),
// //         ),
// //
// //         const SizedBox(width: 12),
// //
// //         PopupMenuButton<String>(
// //           initialValue: selectedFloor,
// //           onSelected: (value) {
// //             setState(() => selectedFloor = value);
// //           },
// //           itemBuilder: (context) => floors
// //               .map(
// //                 (floor) => PopupMenuItem<String>(
// //                   value: floor,
// //                   child: Row(
// //                     children: [
// //                       Icon(
// //                         Icons.layers_rounded,
// //                         size: 14,
// //                         color: selectedFloor == floor ? _kOrange : _kText2,
// //                       ),
// //                       const SizedBox(width: 8),
// //                       Text(
// //                         floor,
// //                         style: TextStyle(
// //                           fontSize: 13,
// //                           fontWeight: selectedFloor == floor
// //                               ? FontWeight.w700
// //                               : FontWeight.w500,
// //                           color: selectedFloor == floor ? _kOrange : _kText1,
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //               )
// //               .toList(),
// //           child: Container(
// //             height: 42,
// //             padding: const EdgeInsets.symmetric(horizontal: 12),
// //             decoration: BoxDecoration(
// //               borderRadius: BorderRadius.circular(10),
// //               border: Border.all(color: _kOrange),
// //               color: _kOrangeSoft,
// //             ),
// //             child: Row(
// //               mainAxisSize: MainAxisSize.min,
// //               children: [
// //                 const Icon(Icons.layers_rounded, size: 15, color: _kOrange),
// //                 const SizedBox(width: 6),
// //                 ConstrainedBox(
// //                   constraints: const BoxConstraints(maxWidth: 80),
// //                   child: Text(
// //                     selectedFloor == 'All Floors'
// //                         ? 'All'
// //                         : selectedFloor
// //                               .replaceAll(' Floor', '')
// //                               .replaceAll(' Hall', ''),
// //                     style: const TextStyle(
// //                       fontSize: 12,
// //                       fontWeight: FontWeight.w700,
// //                       color: _kOrange,
// //                     ),
// //                     overflow: TextOverflow.ellipsis,
// //                   ),
// //                 ),
// //                 const SizedBox(width: 4),
// //                 const Icon(
// //                   Icons.keyboard_arrow_down_rounded,
// //                   size: 16,
// //                   color: _kOrange,
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ],
// //     ),
// //   );
// //
// //   // ── Selection mode top bar ────────────────────────────────────────────────
// //   Widget _buildSelectionTopBar() => Container(
// //     padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
// //     decoration: const BoxDecoration(color: _kWhite),
// //     child: Row(
// //       children: [
// //         // Cancel / back button
// //         GestureDetector(
// //           onTap: _exitSelectionMode,
// //           child: Container(
// //             width: 40,
// //             height: 40,
// //             decoration: BoxDecoration(
// //               color: _kGreyLight,
// //               borderRadius: BorderRadius.circular(10),
// //             ),
// //             child: const Icon(Icons.close_rounded, color: _kText2, size: 18),
// //           ),
// //         ),
// //         const SizedBox(width: 12),
// //         Expanded(
// //           child: Text(
// //             _selectedIds.isEmpty
// //                 ? 'Select tables'
// //                 : '${_selectedIds.length} selected',
// //             style: const TextStyle(
// //               fontSize: 15,
// //               fontWeight: FontWeight.w700,
// //               color: _kText1,
// //             ),
// //           ),
// //         ),
// //         // Select All / Deselect All
// //         GestureDetector(
// //           onTap: () {
// //             final grouped = _getGrouped();
// //             final allIds = grouped.values
// //                 .expand((cap) => cap.values)
// //                 .expand((list) => list)
// //                 .map((t) => t.id)
// //                 .toSet();
// //             setState(() {
// //               if (_selectedIds.length == allIds.length) {
// //                 // All selected → deselect all, exit mode
// //                 _exitSelectionMode();
// //               } else {
// //                 _selectedIds
// //                   ..clear()
// //                   ..addAll(allIds);
// //               }
// //             });
// //           },
// //           child: Container(
// //             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
// //             decoration: BoxDecoration(
// //               color: _kOrangeSoft,
// //               borderRadius: BorderRadius.circular(10),
// //               border: Border.all(color: _kOrange.withOpacity(0.4)),
// //             ),
// //             child: Row(
// //               mainAxisSize: MainAxisSize.min,
// //               children: [
// //                 Icon(
// //                   _selectedIds.length == _tables.length
// //                       ? Icons.deselect_rounded
// //                       : Icons.select_all_rounded,
// //                   size: 14,
// //                   color: _kOrange,
// //                 ),
// //                 const SizedBox(width: 4),
// //                 Text(
// //                   _selectedIds.length == _tables.length
// //                       ? 'Deselect All'
// //                       : 'Select All',
// //                   style: const TextStyle(
// //                     fontSize: 12,
// //                     fontWeight: FontWeight.w700,
// //                     color: _kOrange,
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ],
// //     ),
// //   );
// //
// //   // ── Delete bottom action bar ──────────────────────────────────────────────
// //   Widget _buildDeleteBottomBar() => SafeArea(
// //     child: Container(
// //       padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
// //       decoration: BoxDecoration(
// //         color: _kWhite,
// //         boxShadow: [
// //           BoxShadow(
// //             color: Colors.black.withOpacity(0.08),
// //             blurRadius: 12,
// //             offset: const Offset(0, -3),
// //           ),
// //         ],
// //       ),
// //       child: Row(
// //         children: [
// //           // Info chip
// //           Container(
// //             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
// //             decoration: BoxDecoration(
// //               color: _kRedLight,
// //               borderRadius: BorderRadius.circular(10),
// //             ),
// //             child: Row(
// //               mainAxisSize: MainAxisSize.min,
// //               children: [
// //                 const Icon(
// //                   Icons.table_restaurant_outlined,
// //                   color: _kRed,
// //                   size: 16,
// //                 ),
// //                 const SizedBox(width: 6),
// //                 Text(
// //                   '${_selectedIds.length}',
// //                   style: const TextStyle(
// //                     fontSize: 15,
// //                     fontWeight: FontWeight.w800,
// //                     color: _kRed,
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //           const SizedBox(width: 12),
// //           // Delete button
// //           Expanded(
// //             child: ElevatedButton.icon(
// //               onPressed: _selectedIds.isEmpty || _deleting
// //                   ? null
// //                   : _confirmDeleteSelected,
// //               style: ElevatedButton.styleFrom(
// //                 backgroundColor: _kRed,
// //                 foregroundColor: _kWhite,
// //                 disabledBackgroundColor: _kRedLight,
// //                 elevation: 0,
// //                 shape: RoundedRectangleBorder(
// //                   borderRadius: BorderRadius.circular(12),
// //                 ),
// //                 padding: const EdgeInsets.symmetric(vertical: 14),
// //               ),
// //               icon: _deleting
// //                   ? const SizedBox(
// //                       width: 16,
// //                       height: 16,
// //                       child: CircularProgressIndicator(
// //                         color: _kWhite,
// //                         strokeWidth: 2,
// //                       ),
// //                     )
// //                   : const Icon(Icons.delete_rounded, size: 18),
// //               label: Text(
// //                 _deleting
// //                     ? 'Deleting...'
// //                     : _selectedIds.isEmpty
// //                     ? 'Select tables to delete'
// //                     : 'Delete ${_selectedIds.length} Table${_selectedIds.length > 1 ? 's' : ''}',
// //                 style: const TextStyle(
// //                   fontWeight: FontWeight.w700,
// //                   fontSize: 14,
// //                 ),
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     ),
// //   );
// //
// //   Widget _buildSummaryBar() {
// //     final c = _counts;
// //
// //     Widget _card(String label, int count, Color color, Color bg) {
// //       return Expanded(
// //         child: Container(
// //           margin: const EdgeInsets.symmetric(horizontal: 3),
// //           padding: const EdgeInsets.symmetric(vertical: 10),
// //           decoration: BoxDecoration(
// //             color: bg,
// //             borderRadius: BorderRadius.circular(10),
// //             border: Border.all(color: color.withOpacity(0.35), width: 1.2),
// //             boxShadow: [
// //               BoxShadow(
// //                 color: color.withOpacity(0.06),
// //                 blurRadius: 6,
// //                 offset: const Offset(0, 2),
// //               ),
// //             ],
// //           ),
// //           child: Column(
// //             mainAxisSize: MainAxisSize.min,
// //             children: [
// //               Text(
// //                 '$count',
// //                 style: TextStyle(
// //                   fontSize: 20,
// //                   fontWeight: FontWeight.w800,
// //                   color: color,
// //                 ),
// //               ),
// //               const SizedBox(height: 2),
// //               Text(
// //                 label,
// //                 style: TextStyle(
// //                   fontSize: 9,
// //                   fontWeight: FontWeight.w600,
// //                   color: color,
// //                   letterSpacing: 0.2,
// //                 ),
// //                 textAlign: TextAlign.center,
// //               ),
// //             ],
// //           ),
// //         ),
// //       );
// //     }
// //
// //     return Container(
// //       color: _kWhite,
// //       padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
// //       child: Column(
// //         children: [
// //           Row(
// //             children: [
// //               _card(
// //                 'Available',
// //                 c[TableStatus.available]!,
// //                 _kGreen,
// //                 _kGreenLight,
// //               ),
// //               _card(
// //                 'Reserved',
// //                 c[TableStatus.reserved]!,
// //                 _kAmber,
// //                 _kAmberLight,
// //               ),
// //               _card('Vacant', c[TableStatus.vacant]!, _kGrey, _kGreyLight),
// //             ],
// //           ),
// //           const SizedBox(height: 6),
// //           Row(
// //             children: [
// //               _card('Occupied', c[TableStatus.occupied]!, _kRed, _kRedLight),
// //               _card('Cleaning', c[TableStatus.cleaning]!, _kBlue, _kBlueLight),
// //               _card(
// //                 'Maintnce',
// //                 c[TableStatus.maintenance]!,
// //                 _kPurple,
// //                 _kPurpleLight,
// //               ),
// //             ],
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _buildFab() => FloatingActionButton.extended(
// //     backgroundColor: _kOrange,
// //     foregroundColor: _kWhite,
// //     elevation: 4,
// //     onPressed: _showAddTableBottomSheet,
// //     icon: const Icon(Icons.add_rounded),
// //     label: const Text(
// //       'Add Table',
// //       style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
// //     ),
// //   );
// //
// //   Widget _buildError() => Center(
// //     child: Padding(
// //       padding: const EdgeInsets.all(32),
// //       child: Column(
// //         mainAxisAlignment: MainAxisAlignment.center,
// //         children: [
// //           Container(
// //             width: 64,
// //             height: 64,
// //             decoration: BoxDecoration(
// //               color: _kRedLight,
// //               borderRadius: BorderRadius.circular(18),
// //             ),
// //             child: const Icon(Icons.wifi_off_rounded, color: _kRed, size: 30),
// //           ),
// //           const SizedBox(height: 16),
// //           const Text(
// //             'Failed to load tables',
// //             style: TextStyle(
// //               fontSize: 16,
// //               fontWeight: FontWeight.w700,
// //               color: _kText1,
// //             ),
// //           ),
// //           const SizedBox(height: 6),
// //           Text(
// //             _error ?? '',
// //             style: const TextStyle(fontSize: 12, color: _kText2),
// //             textAlign: TextAlign.center,
// //           ),
// //           const SizedBox(height: 20),
// //           ElevatedButton.icon(
// //             onPressed: _fetchAll,
// //             style: ElevatedButton.styleFrom(
// //               backgroundColor: _kOrange,
// //               foregroundColor: _kWhite,
// //               elevation: 0,
// //               shape: RoundedRectangleBorder(
// //                 borderRadius: BorderRadius.circular(12),
// //               ),
// //             ),
// //             icon: const Icon(Icons.refresh_rounded, size: 18),
// //             label: const Text('Retry'),
// //           ),
// //         ],
// //       ),
// //     ),
// //   );
// //
// //   Widget _buildTablesTab() {
// //     final grouped = _getGrouped();
// //     final sortedFloors = _sortedFloors(grouped);
// //
// //     if (sortedFloors.isEmpty) {
// //       return Center(
// //         child: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             Container(
// //               width: 72,
// //               height: 72,
// //               decoration: BoxDecoration(
// //                 color: _kGreyLight,
// //                 borderRadius: BorderRadius.circular(20),
// //               ),
// //               child: const Icon(
// //                 Icons.table_restaurant_outlined,
// //                 color: _kGrey,
// //                 size: 36,
// //               ),
// //             ),
// //             const SizedBox(height: 16),
// //             Text(
// //               selectedFloor == 'All Floors'
// //                   ? 'No tables added yet'
// //                   : 'No tables on $selectedFloor',
// //               style: const TextStyle(
// //                 fontSize: 15,
// //                 fontWeight: FontWeight.w700,
// //                 color: _kText1,
// //               ),
// //             ),
// //             const SizedBox(height: 6),
// //             const Text(
// //               'Tap + Add Table to get started',
// //               style: TextStyle(fontSize: 12, color: _kText2),
// //             ),
// //           ],
// //         ),
// //       );
// //     }
// //
// //     final listItems = <_ListItem>[];
// //     for (final floor in sortedFloors) {
// //       listItems.add(
// //         _FloorHeaderItem(
// //           floor,
// //           grouped[floor]!.values.fold(0, (s, l) => s + l.length),
// //         ),
// //       );
// //       for (final capEntry in grouped[floor]!.entries) {
// //         listItems.add(_CapacityHeaderItem(capEntry.key, capEntry.value.length));
// //         listItems.add(_TableGridItem(capEntry.value));
// //       }
// //     }
// //
// //     return ListView.builder(
// //       controller: _tablesScrollCtrl,
// //       padding: EdgeInsets.fromLTRB(16, 12, 16, _selectionMode ? 16 : 120),
// //       physics: const BouncingScrollPhysics(
// //         parent: AlwaysScrollableScrollPhysics(),
// //       ),
// //       itemCount: listItems.length,
// //       itemBuilder: (_, i) {
// //         final item = listItems[i];
// //         if (item is _FloorHeaderItem) return _buildFloorHeader(item);
// //         if (item is _CapacityHeaderItem) return _buildCapacityHeader(item);
// //         if (item is _TableGridItem) return _buildTableGrid(item.tables);
// //         return const SizedBox.shrink();
// //       },
// //     );
// //   }
// //
// //   Widget _buildFloorHeader(_FloorHeaderItem item) => Padding(
// //     padding: const EdgeInsets.only(bottom: 10, top: 4),
// //     child: Row(
// //       children: [
// //         Container(
// //           padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
// //           decoration: BoxDecoration(
// //             color: _kOrange,
// //             borderRadius: BorderRadius.circular(12),
// //           ),
// //           child: Row(
// //             mainAxisSize: MainAxisSize.min,
// //             children: [
// //               const Icon(Icons.layers_rounded, color: _kWhite, size: 16),
// //               const SizedBox(width: 8),
// //               Text(
// //                 item.floor,
// //                 style: const TextStyle(
// //                   fontSize: 14,
// //                   fontWeight: FontWeight.w700,
// //                   color: _kWhite,
// //                 ),
// //               ),
// //               const SizedBox(width: 8),
// //               Text(
// //                 '${item.total} tables',
// //                 style: TextStyle(
// //                   fontSize: 11,
// //                   color: _kWhite.withOpacity(0.85),
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ],
// //     ),
// //   );
// //
// //   Widget _buildCapacityHeader(_CapacityHeaderItem item) => Padding(
// //     padding: const EdgeInsets.only(bottom: 8, top: 2),
// //     child: Row(
// //       children: [
// //         Container(
// //           width: 3,
// //           height: 16,
// //           decoration: BoxDecoration(
// //             color: _kOrange,
// //             borderRadius: BorderRadius.circular(2),
// //           ),
// //         ),
// //         const SizedBox(width: 8),
// //         Text(
// //           '${item.capacity} Seater Tables',
// //           style: const TextStyle(
// //             fontSize: 12,
// //             fontWeight: FontWeight.w600,
// //             color: _kText2,
// //           ),
// //         ),
// //         const SizedBox(width: 8),
// //         Container(
// //           padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
// //           decoration: BoxDecoration(
// //             color: _kBorder,
// //             borderRadius: BorderRadius.circular(8),
// //           ),
// //           child: Text(
// //             '${item.count}',
// //             style: const TextStyle(
// //               fontSize: 10,
// //               fontWeight: FontWeight.w700,
// //               color: _kText2,
// //             ),
// //           ),
// //         ),
// //       ],
// //     ),
// //   );
// //
// //   Widget _buildTableGrid(List<TableModel> tables) => Padding(
// //     padding: const EdgeInsets.only(bottom: 16),
// //     child: GridView.builder(
// //       shrinkWrap: true,
// //       physics: const NeverScrollableScrollPhysics(),
// //       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
// //         crossAxisCount: 4,
// //         crossAxisSpacing: 8,
// //         mainAxisSpacing: 8,
// //         childAspectRatio: 0.88,
// //       ),
// //       itemCount: tables.length,
// //       itemBuilder: (_, ti) {
// //         final table = tables[ti];
// //         final isSelected = _selectedIds.contains(table.id);
// //
// //         return _TableCard(
// //           table: table,
// //           selectionMode: _selectionMode,
// //           isSelected: isSelected,
// //           onTap: () {
// //             if (_selectionMode) {
// //               _toggleSelection(table.id);
// //             } else {
// //               _showEditTableSheet(table);
// //             }
// //           },
// //           onLongPress: () {
// //             if (!_selectionMode) {
// //               _enterSelectionMode(table.id);
// //             }
// //           },
// //         );
// //       },
// //     ),
// //   );
// //
// //   Widget _buildWaitlistTab() {
// //     if (_waitlist.isEmpty) {
// //       return Center(
// //         child: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             Container(
// //               width: 72,
// //               height: 72,
// //               decoration: BoxDecoration(
// //                 color: _kAmberLight,
// //                 borderRadius: BorderRadius.circular(20),
// //               ),
// //               child: const Icon(
// //                 Icons.hourglass_empty_rounded,
// //                 color: _kAmber,
// //                 size: 36,
// //               ),
// //             ),
// //             const SizedBox(height: 16),
// //             const Text(
// //               'No one waiting',
// //               style: TextStyle(
// //                 fontSize: 15,
// //                 fontWeight: FontWeight.w700,
// //                 color: _kText1,
// //               ),
// //             ),
// //             const SizedBox(height: 6),
// //             const Text(
// //               'Waitlist is currently empty',
// //               style: TextStyle(fontSize: 12, color: _kText2),
// //             ),
// //           ],
// //         ),
// //       );
// //     }
// //
// //     return ListView.builder(
// //       controller: _waitlistScrollCtrl,
// //       padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
// //       physics: const BouncingScrollPhysics(
// //         parent: AlwaysScrollableScrollPhysics(),
// //       ),
// //       itemCount: _waitlist.length,
// //       itemBuilder: (_, i) => _WaitlistCard(
// //         item: _waitlist[i],
// //         onRemove: () => _confirmRemoveWaitlist(_waitlist[i]),
// //       ),
// //     );
// //   }
// //
// //   void _showAddTableBottomSheet() {
// //     final nameCtrl = TextEditingController();
// //     final countCtrl = TextEditingController(text: '1');
// //
// //     String selectedName = '';
// //     bool isCustom = false;
// //     int selectedCap = 4;
// //     bool saving = false;
// //
// //     const predefined = [
// //       'Ground Floor',
// //       'First Floor',
// //       'Second Floor',
// //       'Third Floor',
// //       'Basement',
// //       'Party Hall',
// //       'Terrace',
// //       'Roof Top',
// //     ];
// //
// //     const capacities = [2, 4, 5, 6, 8, 10, 12, 20, 30];
// //
// //     showModalBottomSheet(
// //       context: context,
// //       isScrollControlled: true,
// //       backgroundColor: Colors.transparent,
// //       builder: (ctx) => SafeArea(
// //         child: Padding(
// //           padding: EdgeInsets.only(
// //             bottom: MediaQuery.of(ctx).viewInsets.bottom,
// //           ),
// //           child: StatefulBuilder(
// //             builder: (ctx2, setBS) => _BottomSheetWrapper(
// //               title: 'Add New Table(s)',
// //               icon: Icons.add_circle_outline_rounded,
// //               child: SingleChildScrollView(
// //                 child: Column(
// //                   crossAxisAlignment: CrossAxisAlignment.start,
// //                   children: [
// //                     _BSLabel('Table Floor / Name *'),
// //                     _BSDropdown<String>(
// //                       value: selectedName.isEmpty ? null : selectedName,
// //                       hint: 'Select table location',
// //                       items: [
// //                         ...predefined.map(
// //                           (p) => DropdownMenuItem(value: p, child: Text(p)),
// //                         ),
// //                         const DropdownMenuItem(
// //                           value: '__custom__',
// //                           child: Text('Other (Custom Name)'),
// //                         ),
// //                       ],
// //                       onChanged: (v) => setBS(() {
// //                         if (v == '__custom__') {
// //                           isCustom = true;
// //                           selectedName = '';
// //                         } else {
// //                           isCustom = false;
// //                           selectedName = v ?? '';
// //                         }
// //                       }),
// //                     ),
// //
// //                     if (isCustom) ...[
// //                       const SizedBox(height: 10),
// //                       _BSTextField(
// //                         ctrl: nameCtrl,
// //                         hint: 'Enter custom name (e.g. VIP Section)',
// //                         onChanged: (v) => selectedName = v,
// //                       ),
// //                     ],
// //
// //                     const SizedBox(height: 16),
// //                     _BSLabel('Number of Tables (max 10)'),
// //                     _BSTextField(
// //                       ctrl: countCtrl,
// //                       hint: '1',
// //                       keyboardType: TextInputType.number,
// //                       onChanged: (_) {},
// //                     ),
// //
// //                     const SizedBox(height: 16),
// //                     _BSLabel('Capacity per Table'),
// //                     _BSDropdown<int>(
// //                       value: selectedCap,
// //                       items: capacities
// //                           .map(
// //                             (c) => DropdownMenuItem(
// //                               value: c,
// //                               child: Text('$c seats'),
// //                             ),
// //                           )
// //                           .toList(),
// //                       onChanged: (v) => setBS(() => selectedCap = v ?? 4),
// //                     ),
// //
// //                     const SizedBox(height: 10),
// //                     Container(
// //                       padding: const EdgeInsets.all(10),
// //                       decoration: BoxDecoration(
// //                         color: _kBlueLight,
// //                         borderRadius: BorderRadius.circular(8),
// //                       ),
// //                       child: const Row(
// //                         children: [
// //                           Icon(
// //                             Icons.info_outline_rounded,
// //                             size: 14,
// //                             color: _kBlue,
// //                           ),
// //                           SizedBox(width: 6),
// //                           Expanded(
// //                             child: Text(
// //                               'Cleaning time is automatically set to 30 minutes.',
// //                               style: TextStyle(fontSize: 11, color: _kBlue),
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                     ),
// //
// //                     const SizedBox(height: 24),
// //                     Row(
// //                       children: [
// //                         Expanded(
// //                           child: OutlinedButton(
// //                             onPressed: () => Navigator.pop(ctx),
// //                             style: OutlinedButton.styleFrom(
// //                               side: const BorderSide(color: _kBorder),
// //                               shape: RoundedRectangleBorder(
// //                                 borderRadius: BorderRadius.circular(12),
// //                               ),
// //                               padding: const EdgeInsets.symmetric(vertical: 14),
// //                             ),
// //                             child: const Text(
// //                               'Cancel',
// //                               style: TextStyle(color: _kText2),
// //                             ),
// //                           ),
// //                         ),
// //                         const SizedBox(width: 12),
// //                         Expanded(
// //                           flex: 2,
// //                           child: ElevatedButton(
// //                             onPressed: saving
// //                                 ? null
// //                                 : () async {
// //                                     final finalName = isCustom
// //                                         ? nameCtrl.text.trim()
// //                                         : selectedName;
// //
// //                                     if (finalName.isEmpty) {
// //                                       _snack('Please select or enter a name');
// //                                       return;
// //                                     }
// //
// //                                     final cnt =
// //                                         int.tryParse(countCtrl.text) ?? 1;
// //
// //                                     if (cnt < 1 || cnt > 10) {
// //                                       _snack('Number must be between 1-10');
// //                                       return;
// //                                     }
// //
// //                                     setBS(() => saving = true);
// //
// //                                     try {
// //                                       await _addTable(
// //                                         name: finalName,
// //                                         numberOfTables: cnt,
// //                                         capacity: selectedCap,
// //                                       );
// //
// //                                       if (ctx.mounted) {
// //                                         Navigator.pop(ctx);
// //                                       }
// //
// //                                       _snack('Added $cnt table', success: true);
// //
// //                                       await _fetchTables();
// //                                     } catch (e) {
// //                                       _snack(e.toString());
// //                                     } finally {
// //                                       setBS(() => saving = false);
// //                                     }
// //                                   },
// //                             style: ElevatedButton.styleFrom(
// //                               backgroundColor: _kOrange,
// //                               foregroundColor: _kWhite,
// //                               elevation: 0,
// //                               shape: RoundedRectangleBorder(
// //                                 borderRadius: BorderRadius.circular(12),
// //                               ),
// //                               padding: const EdgeInsets.symmetric(vertical: 14),
// //                             ),
// //                             child: saving
// //                                 ? const SizedBox(
// //                                     width: 18,
// //                                     height: 18,
// //                                     child: CircularProgressIndicator(
// //                                       color: _kWhite,
// //                                       strokeWidth: 2,
// //                                     ),
// //                                   )
// //                                 : const Text(
// //                                     'Add Table(s)',
// //                                     style: TextStyle(
// //                                       fontWeight: FontWeight.w700,
// //                                       fontSize: 15,
// //                                     ),
// //                                   ),
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// //
// //   void _showEditTableSheet(TableModel table) {
// //     bool isCustom = false;
// //     String editName = _floorFromName(table.originalData['name']?.toString());
// //     String editCode = table.tableNo;
// //     int editCap = table.capacity;
// //     String editStatus = table.status.apiValue;
// //     String editClean = '00:30:00';
// //     String editDesc = table.originalData['description']?.toString() ?? '';
// //     String editRem = table.originalData['remarks']?.toString() ?? '';
// //     bool editManual = true;
// //     bool saving = false;
// //
// //     final ct = table.originalData['cleanTime'];
// //     if (ct is String && ct.isNotEmpty) {
// //       editClean = ct;
// //     } else if (ct is Map) {
// //       final h = ct['hour'] ?? 0;
// //       final m = ct['minute'] ?? 30;
// //       final s = ct['second'] ?? 0;
// //       editClean =
// //           '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
// //     }
// //
// //     final codeCtrl = TextEditingController(text: editCode);
// //     final capCtrl = TextEditingController(text: editCap.toString());
// //     final descCtrl = TextEditingController(text: editDesc);
// //     final remCtrl = TextEditingController(text: editRem);
// //     final customNameCtrl = TextEditingController(text: editName);
// //
// //     const predefined = [
// //       'Ground Floor',
// //       'First Floor',
// //       'Second Floor',
// //       'Third Floor',
// //       'Basement',
// //       'Party Hall',
// //       'Terrace',
// //       'Roof Top',
// //     ];
// //     const cleanOpts = [
// //       {'label': '15 minutes', 'value': '00:15:00'},
// //       {'label': '30 minutes', 'value': '00:30:00'},
// //       {'label': '45 minutes', 'value': '00:45:00'},
// //       {'label': '1 hour', 'value': '01:00:00'},
// //       {'label': '1 hr 30 min', 'value': '01:30:00'},
// //       {'label': '2 hours', 'value': '02:00:00'},
// //       {'label': '2 hr 30 min', 'value': '02:30:00'},
// //       {'label': '3 hours', 'value': '03:00:00'},
// //     ];
// //     const statusOpts = [
// //       'Available',
// //       'Reserved',
// //       'Vacant',
// //       'Occupied',
// //       'Cleaning',
// //       'Maintenance',
// //     ];
// //
// //     showModalBottomSheet(
// //       context: context,
// //       isScrollControlled: true,
// //       backgroundColor: Colors.transparent,
// //       builder: (ctx) => SafeArea(
// //         child: StatefulBuilder(
// //           builder: (ctx2, setBS) => _BottomSheetWrapper(
// //             title: 'Edit Table: ${table.tableNo}',
// //             icon: Icons.edit_rounded,
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 _BSLabel('Table Floor / Name'),
// //                 _BSDropdown<String>(
// //                   value: predefined.contains(editName)
// //                       ? editName
// //                       : '__custom__',
// //                   items: [
// //                     ...predefined.map(
// //                       (p) => DropdownMenuItem(value: p, child: Text(p)),
// //                     ),
// //                     const DropdownMenuItem(
// //                       value: '__custom__',
// //                       child: Text('Other (Custom Name)'),
// //                     ),
// //                   ],
// //                   onChanged: (v) => setBS(() {
// //                     if (v == '__custom__') {
// //                       isCustom = true;
// //                       editName = customNameCtrl.text;
// //                     } else {
// //                       isCustom = false;
// //                       editName = v ?? '';
// //                       customNameCtrl.text = editName;
// //                     }
// //                   }),
// //                 ),
// //                 if (isCustom || !predefined.contains(editName)) ...[
// //                   const SizedBox(height: 10),
// //                   _BSTextField(
// //                     ctrl: customNameCtrl,
// //                     hint: 'Custom name',
// //                     onChanged: (v) => editName = v,
// //                   ),
// //                 ],
// //                 const SizedBox(height: 14),
// //
// //                 Row(
// //                   children: [
// //                     Expanded(
// //                       child: Column(
// //                         crossAxisAlignment: CrossAxisAlignment.start,
// //                         children: [
// //                           _BSLabel('Table Code'),
// //                           _BSTextField(
// //                             ctrl: codeCtrl,
// //                             hint: 'e.g. T01',
// //                             onChanged: (v) => editCode = v,
// //                           ),
// //                         ],
// //                       ),
// //                     ),
// //                     const SizedBox(width: 12),
// //                     Expanded(
// //                       child: Column(
// //                         crossAxisAlignment: CrossAxisAlignment.start,
// //                         children: [
// //                           _BSLabel('Capacity'),
// //                           _BSTextField(
// //                             ctrl: capCtrl,
// //                             hint: '4',
// //                             keyboardType: TextInputType.number,
// //                             onChanged: (v) =>
// //                                 editCap = int.tryParse(v) ?? editCap,
// //                           ),
// //                         ],
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //                 const SizedBox(height: 14),
// //
// //                 _BSLabel('Status'),
// //                 _BSDropdown<String>(
// //                   value: editStatus,
// //                   items: statusOpts
// //                       .map((s) => DropdownMenuItem(value: s, child: Text(s)))
// //                       .toList(),
// //                   onChanged: (v) => setBS(() => editStatus = v ?? editStatus),
// //                 ),
// //                 const SizedBox(height: 14),
// //
// //                 _BSLabel('Cleaning Duration'),
// //                 _BSDropdown<String>(
// //                   value: cleanOpts.any((o) => o['value'] == editClean)
// //                       ? editClean
// //                       : '00:30:00',
// //                   items: cleanOpts
// //                       .map(
// //                         (o) => DropdownMenuItem(
// //                           value: o['value'],
// //                           child: Text(o['label']!),
// //                         ),
// //                       )
// //                       .toList(),
// //                   onChanged: (v) => setBS(() => editClean = v ?? editClean),
// //                 ),
// //                 const SizedBox(height: 14),
// //
// //                 _BSLabel('Description'),
// //                 _BSTextField(
// //                   ctrl: descCtrl,
// //                   hint: 'Optional description',
// //                   maxLines: 2,
// //                   onChanged: (v) => editDesc = v,
// //                 ),
// //                 const SizedBox(height: 14),
// //
// //                 _BSLabel('Remarks'),
// //                 _BSTextField(
// //                   ctrl: remCtrl,
// //                   hint: 'Optional remarks',
// //                   maxLines: 2,
// //                   onChanged: (v) => editRem = v,
// //                 ),
// //                 const SizedBox(height: 10),
// //
// //                 GestureDetector(
// //                   onTap: () => setBS(() => editManual = !editManual),
// //                   child: Container(
// //                     padding: const EdgeInsets.symmetric(
// //                       horizontal: 14,
// //                       vertical: 12,
// //                     ),
// //                     decoration: BoxDecoration(
// //                       color: _kBg,
// //                       borderRadius: BorderRadius.circular(10),
// //                       border: Border.all(color: _kBorder),
// //                     ),
// //                     child: Row(
// //                       children: [
// //                         const Expanded(
// //                           child: Text(
// //                             'Manually Updated',
// //                             style: TextStyle(
// //                               fontSize: 13,
// //                               fontWeight: FontWeight.w500,
// //                               color: _kText1,
// //                             ),
// //                           ),
// //                         ),
// //                         Switch(
// //                           value: editManual,
// //                           onChanged: (v) => setBS(() => editManual = v),
// //                           activeColor: _kOrange,
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                 ),
// //                 const SizedBox(height: 24),
// //
// //                 Row(
// //                   children: [
// //                     Expanded(
// //                       child: OutlinedButton(
// //                         onPressed: () => Navigator.pop(ctx),
// //                         style: OutlinedButton.styleFrom(
// //                           side: const BorderSide(color: _kBorder),
// //                           shape: RoundedRectangleBorder(
// //                             borderRadius: BorderRadius.circular(12),
// //                           ),
// //                           padding: const EdgeInsets.symmetric(vertical: 14),
// //                         ),
// //                         child: const Text(
// //                           'Cancel',
// //                           style: TextStyle(color: _kText2),
// //                         ),
// //                       ),
// //                     ),
// //                     const SizedBox(width: 12),
// //                     Expanded(
// //                       flex: 2,
// //                       child: ElevatedButton(
// //                         onPressed: saving
// //                             ? null
// //                             : () async {
// //                                 setBS(() => saving = true);
// //                                 try {
// //                                   await _updateTable(
// //                                     tableId: table.id,
// //                                     name: editName,
// //                                     code: codeCtrl.text.trim(),
// //                                     capacity: editCap,
// //                                     status: editStatus,
// //                                     cleanTime: editClean,
// //                                     description: descCtrl.text.trim(),
// //                                     remarks: remCtrl.text.trim(),
// //                                     manuallyUpdated: editManual,
// //                                   );
// //                                   if (ctx.mounted) Navigator.pop(ctx);
// //                                   _snack('Table updated!', success: true);
// //                                   await _fetchTables();
// //                                 } catch (e) {
// //                                   _snack(e.toString());
// //                                 } finally {
// //                                   setBS(() => saving = false);
// //                                 }
// //                               },
// //                         style: ElevatedButton.styleFrom(
// //                           backgroundColor: _kGreen,
// //                           foregroundColor: _kWhite,
// //                           elevation: 0,
// //                           shape: RoundedRectangleBorder(
// //                             borderRadius: BorderRadius.circular(12),
// //                           ),
// //                           padding: const EdgeInsets.symmetric(vertical: 14),
// //                         ),
// //                         child: saving
// //                             ? const SizedBox(
// //                                 width: 18,
// //                                 height: 18,
// //                                 child: CircularProgressIndicator(
// //                                   color: _kWhite,
// //                                   strokeWidth: 2,
// //                                 ),
// //                               )
// //                             : const Text(
// //                                 'Save Changes',
// //                                 style: TextStyle(
// //                                   fontWeight: FontWeight.w700,
// //                                   fontSize: 15,
// //                                 ),
// //                               ),
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// //
// //   void _confirmRemoveWaitlist(WaitlistItem item) {
// //     showDialog(
// //       context: context,
// //       builder: (ctx) => AlertDialog(
// //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
// //         title: const Text(
// //           'Remove from Waitlist',
// //           style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
// //         ),
// //         content: Text(
// //           'Remove ${item.customerName} from the waiting list?',
// //           style: const TextStyle(fontSize: 14, color: _kText2),
// //         ),
// //         actions: [
// //           TextButton(
// //             onPressed: () => Navigator.pop(ctx),
// //             child: const Text('Cancel', style: TextStyle(color: _kText2)),
// //           ),
// //           ElevatedButton(
// //             onPressed: () async {
// //               Navigator.pop(ctx);
// //               try {
// //                 await _removeWaitlist(item.id);
// //                 _snack('Removed from waitlist', success: true);
// //               } catch (e) {
// //                 _snack(e.toString());
// //               }
// //             },
// //             style: ElevatedButton.styleFrom(
// //               backgroundColor: _kRed,
// //               foregroundColor: _kWhite,
// //               elevation: 0,
// //               shape: RoundedRectangleBorder(
// //                 borderRadius: BorderRadius.circular(10),
// //               ),
// //             ),
// //             child: const Text('Remove'),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   void _snack(String msg, {bool success = false}) {
// //     if (!mounted) return;
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       SnackBar(
// //         content: Text(msg),
// //         backgroundColor: success ? _kGreen : _kRed,
// //         behavior: SnackBarBehavior.floating,
// //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
// //         margin: const EdgeInsets.all(12),
// //       ),
// //     );
// //   }
// // }
// //
// // // ─────────────────────────────────────────────────────────────────────────────
// // // List item types
// // // ─────────────────────────────────────────────────────────────────────────────
// //
// // abstract class _ListItem {}
// //
// // class _FloorHeaderItem extends _ListItem {
// //   final String floor;
// //   final int total;
// //   _FloorHeaderItem(this.floor, this.total);
// // }
// //
// // class _CapacityHeaderItem extends _ListItem {
// //   final int capacity;
// //   final int count;
// //   _CapacityHeaderItem(this.capacity, this.count);
// // }
// //
// // class _TableGridItem extends _ListItem {
// //   final List<TableModel> tables;
// //   _TableGridItem(this.tables);
// // }
// //
// // class _SummaryItem {
// //   final String label;
// //   final int count;
// //   final Color color;
// //   final Color bg;
// //   const _SummaryItem(this.label, this.count, this.color, this.bg);
// // }
// //
// // // ─────────────────────────────────────────────────────────────────────────────
// // // _TableCard — updated with long-press & selection overlay
// // // ─────────────────────────────────────────────────────────────────────────────
// //
// // class _TableCard extends StatelessWidget {
// //   final TableModel table;
// //   final bool selectionMode;
// //   final bool isSelected;
// //   final VoidCallback onTap;
// //   final VoidCallback onLongPress;
// //
// //   const _TableCard({
// //     required this.table,
// //     required this.selectionMode,
// //     required this.isSelected,
// //     required this.onTap,
// //     required this.onLongPress,
// //   });
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     final s = table.status;
// //
// //     return GestureDetector(
// //       onTap: onTap,
// //       onLongPress: onLongPress,
// //       child: AnimatedContainer(
// //         duration: const Duration(milliseconds: 180),
// //         decoration: BoxDecoration(
// //           color: isSelected ? _kRedLight : s.lightColor,
// //           borderRadius: BorderRadius.circular(12),
// //           border: Border.all(
// //             color: isSelected ? _kRed : s.color.withOpacity(0.4),
// //             width: isSelected ? 2 : 1.5,
// //           ),
// //           boxShadow: isSelected
// //               ? [
// //                   BoxShadow(
// //                     color: _kRed.withOpacity(0.18),
// //                     blurRadius: 8,
// //                     offset: const Offset(0, 2),
// //                   ),
// //                 ]
// //               : null,
// //         ),
// //         child: Stack(
// //           children: [
// //             // Main content
// //             Column(
// //               mainAxisAlignment: MainAxisAlignment.center,
// //               children: [
// //                 Container(
// //                   width: 30,
// //                   height: 30,
// //                   decoration: BoxDecoration(
// //                     color: isSelected
// //                         ? _kRed.withOpacity(0.15)
// //                         : s.color.withOpacity(0.15),
// //                     borderRadius: BorderRadius.circular(8),
// //                   ),
// //                   child: Icon(
// //                     isSelected ? Icons.delete_rounded : s.icon,
// //                     color: isSelected ? _kRed : s.color,
// //                     size: 5,
// //                   ),
// //                 ),
// //                 const SizedBox(height: 4),
// //                 Text(
// //                   table.tableNo,
// //                   style: TextStyle(
// //                     fontSize: 11,
// //                     fontWeight: FontWeight.w800,
// //                     color: isSelected ? _kRed : s.color,
// //                   ),
// //                   textAlign: TextAlign.center,
// //                   maxLines: 1,
// //                   overflow: TextOverflow.ellipsis,
// //                 ),
// //                 Text(
// //                   '${table.capacity}P',
// //                   style: TextStyle(
// //                     fontSize: 9,
// //                     fontWeight: FontWeight.w500,
// //                     color: isSelected
// //                         ? _kRed.withOpacity(0.75)
// //                         : s.color.withOpacity(0.75),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //
// //             // Selection checkbox badge (top-right corner)
// //             if (selectionMode)
// //               Positioned(
// //                 top: 4,
// //                 right: 4,
// //                 child: AnimatedContainer(
// //                   duration: const Duration(milliseconds: 180),
// //                   width: 16,
// //                   height: 16,
// //                   decoration: BoxDecoration(
// //                     color: isSelected ? _kRed : _kWhite,
// //                     shape: BoxShape.circle,
// //                     border: Border.all(
// //                       color: isSelected ? _kRed : _kGrey,
// //                       width: 1.5,
// //                     ),
// //                     boxShadow: [
// //                       BoxShadow(
// //                         color: Colors.black.withOpacity(0.1),
// //                         blurRadius: 2,
// //                         offset: const Offset(0, 1),
// //                       ),
// //                     ],
// //                   ),
// //                   child: isSelected
// //                       ? const Icon(
// //                           Icons.check_rounded,
// //                           size: 10,
// //                           color: _kWhite,
// //                         )
// //                       : null,
// //                 ),
// //               ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }
// //
// // // ─────────────────────────────────────────────────────────────────────────────
// // // _WaitlistCard
// // // ─────────────────────────────────────────────────────────────────────────────
// //
// // class _WaitlistCard extends StatelessWidget {
// //   final WaitlistItem item;
// //   final VoidCallback onRemove;
// //   const _WaitlistCard({required this.item, required this.onRemove});
// //
// //   @override
// //   Widget build(BuildContext context) => Container(
// //     margin: const EdgeInsets.only(bottom: 10),
// //     decoration: BoxDecoration(
// //       color: _kWhite,
// //       borderRadius: BorderRadius.circular(14),
// //       border: Border.all(color: _kBorder),
// //       boxShadow: const [
// //         BoxShadow(
// //           color: Color(0x08000000),
// //           blurRadius: 8,
// //           offset: Offset(0, 2),
// //         ),
// //       ],
// //     ),
// //     child: Padding(
// //       padding: const EdgeInsets.all(14),
// //       child: Row(
// //         children: [
// //           Container(
// //             width: 44,
// //             height: 44,
// //             decoration: BoxDecoration(
// //               color: _kAmberLight,
// //               borderRadius: BorderRadius.circular(12),
// //             ),
// //             child: Center(
// //               child: Text(
// //                 item.customerName.isNotEmpty
// //                     ? item.customerName[0].toUpperCase()
// //                     : '?',
// //                 style: const TextStyle(
// //                   fontSize: 18,
// //                   fontWeight: FontWeight.w800,
// //                   color: _kAmber,
// //                 ),
// //               ),
// //             ),
// //           ),
// //           const SizedBox(width: 12),
// //           Expanded(
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 Text(
// //                   item.customerName,
// //                   style: const TextStyle(
// //                     fontSize: 14,
// //                     fontWeight: FontWeight.w700,
// //                     color: _kText1,
// //                   ),
// //                 ),
// //                 const SizedBox(height: 3),
// //                 Row(
// //                   children: [
// //                     if (item.phone.isNotEmpty) ...[
// //                       const Icon(Icons.phone_rounded, size: 12, color: _kText2),
// //                       const SizedBox(width: 4),
// //                       Text(
// //                         item.phone,
// //                         style: const TextStyle(fontSize: 11, color: _kText2),
// //                       ),
// //                       const SizedBox(width: 10),
// //                     ],
// //                     const Icon(Icons.people_rounded, size: 12, color: _kText2),
// //                     const SizedBox(width: 4),
// //                     Text(
// //                       '${item.guests} guests',
// //                       style: const TextStyle(fontSize: 11, color: _kText2),
// //                     ),
// //                   ],
// //                 ),
// //                 if (item.requestTime.isNotEmpty) ...[
// //                   const SizedBox(height: 3),
// //                   Row(
// //                     children: [
// //                       const Icon(
// //                         Icons.access_time_rounded,
// //                         size: 12,
// //                         color: _kText2,
// //                       ),
// //                       const SizedBox(width: 4),
// //                       Text(
// //                         '${item.bookingDate}  '
// //                         '${item.requestTime.length >= 5 ? item.requestTime.substring(0, 5) : item.requestTime}',
// //                         style: const TextStyle(fontSize: 11, color: _kText2),
// //                       ),
// //                     ],
// //                   ),
// //                 ],
// //               ],
// //             ),
// //           ),
// //           GestureDetector(
// //             onTap: onRemove,
// //             child: Container(
// //               width: 36,
// //               height: 36,
// //               decoration: BoxDecoration(
// //                 color: _kRedLight,
// //                 borderRadius: BorderRadius.circular(10),
// //               ),
// //               child: const Icon(
// //                 Icons.person_remove_rounded,
// //                 color: _kRed,
// //                 size: 17,
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     ),
// //   );
// // }
// //
// // // ─────────────────────────────────────────────────────────────────────────────
// // // Bottom sheet wrapper & helpers
// // // ─────────────────────────────────────────────────────────────────────────────
// //
// // class _BottomSheetWrapper extends StatelessWidget {
// //   final String title;
// //   final IconData icon;
// //   final Widget child;
// //   const _BottomSheetWrapper({
// //     required this.title,
// //     required this.icon,
// //     required this.child,
// //   });
// //
// //   @override
// //   Widget build(BuildContext context) => Container(
// //     decoration: const BoxDecoration(
// //       color: _kWhite,
// //       borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
// //     ),
// //     child: Column(
// //       mainAxisSize: MainAxisSize.min,
// //       children: [
// //         Container(
// //           width: 40,
// //           height: 4,
// //           margin: const EdgeInsets.only(top: 12),
// //           decoration: BoxDecoration(
// //             color: _kBorder,
// //             borderRadius: BorderRadius.circular(2),
// //           ),
// //         ),
// //         Padding(
// //           padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
// //           child: Row(
// //             children: [
// //               Container(
// //                 width: 36,
// //                 height: 36,
// //                 decoration: BoxDecoration(
// //                   color: _kOrangeSoft,
// //                   borderRadius: BorderRadius.circular(10),
// //                 ),
// //                 child: Icon(icon, color: _kOrange, size: 18),
// //               ),
// //               const SizedBox(width: 10),
// //               Expanded(
// //                 child: Text(
// //                   title,
// //                   style: const TextStyle(
// //                     fontSize: 16,
// //                     fontWeight: FontWeight.w800,
// //                     color: _kText1,
// //                   ),
// //                 ),
// //               ),
// //               GestureDetector(
// //                 onTap: () => Navigator.pop(context),
// //                 child: Container(
// //                   width: 30,
// //                   height: 30,
// //                   decoration: BoxDecoration(
// //                     color: _kBg,
// //                     borderRadius: BorderRadius.circular(8),
// //                   ),
// //                   child: const Icon(
// //                     Icons.close_rounded,
// //                     size: 16,
// //                     color: _kText2,
// //                   ),
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //         const SizedBox(height: 4),
// //         const Divider(height: 1),
// //         Flexible(
// //           child: SingleChildScrollView(
// //             padding: EdgeInsets.fromLTRB(
// //               20,
// //               14,
// //               20,
// //               MediaQuery.of(context).viewInsets.bottom + 24,
// //             ),
// //             child: child,
// //           ),
// //         ),
// //       ],
// //     ),
// //   );
// // }
// //
// // Widget _BSLabel(String text) => Padding(
// //   padding: const EdgeInsets.only(bottom: 6),
// //   child: Text(
// //     text,
// //     style: const TextStyle(
// //       fontSize: 12,
// //       fontWeight: FontWeight.w600,
// //       color: _kText3,
// //     ),
// //   ),
// // );
// //
// // Widget _BSTextField({
// //   required TextEditingController ctrl,
// //   required String hint,
// //   required ValueChanged<String> onChanged,
// //   TextInputType keyboardType = TextInputType.text,
// //   int maxLines = 1,
// // }) => Container(
// //   decoration: BoxDecoration(
// //     color: _kBg,
// //     borderRadius: BorderRadius.circular(10),
// //     border: Border.all(color: _kBorder),
// //   ),
// //   child: TextField(
// //     controller: ctrl,
// //     keyboardType: keyboardType,
// //     maxLines: maxLines,
// //     onChanged: onChanged,
// //     style: const TextStyle(fontSize: 14, color: _kText1),
// //     decoration: InputDecoration(
// //       hintText: hint,
// //       hintStyle: const TextStyle(color: _kGrey, fontSize: 14),
// //       border: InputBorder.none,
// //       contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
// //     ),
// //   ),
// // );
// //
// // Widget _BSDropdown<T>({
// //   required T? value,
// //   required List<DropdownMenuItem<T>> items,
// //   required ValueChanged<T?> onChanged,
// //   String? hint,
// // }) {
// //   // Guard: if value isn't in items, treat as null to show hint
// //   final safeValue = items.any((item) => item.value == value) ? value : null;
// //
// //   return Container(
// //     decoration: BoxDecoration(
// //       color: _kBg,
// //       borderRadius: BorderRadius.circular(10),
// //       border: Border.all(color: _kBorder),
// //     ),
// //     padding: const EdgeInsets.symmetric(horizontal: 14),
// //     child: DropdownButtonHideUnderline(
// //       child: DropdownButton<T>(
// //         value: safeValue,
// //         isExpanded: true,
// //         hint: hint != null
// //             ? Text(hint, style: const TextStyle(color: _kGrey, fontSize: 14))
// //             : null,
// //         items: items,
// //         onChanged: onChanged,
// //         style: const TextStyle(
// //           fontSize: 14,
// //           color: _kText1,
// //           fontWeight: FontWeight.w500,
// //         ),
// //         icon: const Icon(Icons.keyboard_arrow_down_rounded, color: _kText2),
// //       ),
// //     ),
// //   );
// // }
// //
// // extension on http.Response {
// //   bool get ok => statusCode >= 200 && statusCode < 300;
// // }

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/TableService.dart';

// ── Design tokens (from BookingTab style) ───────────────────────────────────
const Color _orange = Color(0xFFE87722);
const Color _orangeLight = Color(0xFFFFF4EC);
const Color _white = Color(0xFFFFFFFF);
const Color _border = Color(0xFFEEECEA);
const Color _textDark = Color(0xFF1A1A1A);
const Color _textMuted = Color(0xFF888888);
const Color _success = Color(0xFF4CAF50);
const Color _error = Color(0xFFE53935);
const Color _vacant = Color(0xFF00BCD4);
const Color _cleaning = Color(0xFF2196F3);
const Color _maintenance = Color(0xFF9C27B0);
const Color _amber = Color(0xFFFF9800);

enum TableStatus {
  available,
  vacant,
  reserved,
  occupied,
  cleaning,
  maintenance,
}

extension TableStatusX on TableStatus {
  String get label {
    switch (this) {
      case TableStatus.available:
        return 'Available';
      case TableStatus.vacant:
        return 'Vacant';
      case TableStatus.reserved:
        return 'Reserved';
      case TableStatus.occupied:
        return 'Occupied';
      case TableStatus.cleaning:
        return 'Cleaning';
      case TableStatus.maintenance:
        return 'Maintenance';
    }
  }

  String get apiValue {
    switch (this) {
      case TableStatus.available:
        return 'Available';
      case TableStatus.vacant:
        return 'Vacant';
      case TableStatus.reserved:
        return 'Reserved';
      case TableStatus.occupied:
        return 'Occupied';
      case TableStatus.cleaning:
        return 'Cleaning';
      case TableStatus.maintenance:
        return 'Maintenance';
    }
  }

  Color get color {
    switch (this) {
      case TableStatus.available:
        return _success;
      case TableStatus.vacant:
        return _vacant;
      case TableStatus.reserved:
        return _amber;
      case TableStatus.occupied:
        return _error;
      case TableStatus.cleaning:
        return _cleaning;
      case TableStatus.maintenance:
        return _maintenance;
    }
  }

  Color get lightColor {
    switch (this) {
      case TableStatus.available:
        return _success.withOpacity(0.1);
      case TableStatus.vacant:
        return _vacant.withOpacity(0.1);
      case TableStatus.reserved:
        return _amber.withOpacity(0.1);
      case TableStatus.occupied:
        return _error.withOpacity(0.1);
      case TableStatus.cleaning:
        return _cleaning.withOpacity(0.1);
      case TableStatus.maintenance:
        return _maintenance.withOpacity(0.1);
    }
  }

  IconData get icon {
    switch (this) {
      case TableStatus.available:
        return Icons.check_circle_outline_rounded;
      case TableStatus.vacant:
        return Icons.radio_button_unchecked_rounded;
      case TableStatus.reserved:
        return Icons.event_seat_rounded;
      case TableStatus.occupied:
        return Icons.people_rounded;
      case TableStatus.cleaning:
        return Icons.cleaning_services_rounded;
      case TableStatus.maintenance:
        return Icons.build_circle_outlined;
    }
  }

  static TableStatus fromApi(String? s) {
    switch ((s ?? '').toLowerCase()) {
      case 'available':
        return TableStatus.available;
      case 'vacant':
        return TableStatus.vacant;
      case 'reserved':
        return TableStatus.reserved;
      case 'occupied':
        return TableStatus.occupied;
      case 'cleaning':
        return TableStatus.cleaning;
      case 'maintenance':
        return TableStatus.maintenance;
      default:
        return TableStatus.available;
    }
  }
}

class TableModel {
  final String id;
  final String tableNo;
  final String floorName;
  final TableStatus status;
  final int capacity;
  final String customer;
  final String phone;
  final String guests;
  final String bookingTime;
  final Map<String, dynamic> originalData;
  final int? bookingId;

  const TableModel({
    required this.id,
    required this.tableNo,
    required this.floorName,
    required this.status,
    required this.capacity,
    required this.customer,
    required this.phone,
    required this.guests,
    required this.bookingTime,
    required this.originalData,
    this.bookingId,
  });
}

class WaitlistItem {
  final int id;
  final String customerName;
  final String phone;
  final String guests;
  final String bookingDate;
  final String requestTime;

  const WaitlistItem({
    required this.id,
    required this.customerName,
    required this.phone,
    required this.guests,
    required this.bookingDate,
    required this.requestTime,
  });
}

String _todayDate() {
  final d = DateTime.now();
  return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

String _floorFromName(String? name) {
  if (name == null || name.isEmpty) return 'Other';
  final n = name.toLowerCase();
  if (n.contains('ground')) return 'Ground Floor';
  if (n.contains('first')) return 'First Floor';
  if (n.contains('second')) return 'Second Floor';
  if (n.contains('third')) return 'Third Floor';
  if (n.contains('basement')) return 'Basement';
  if (n.contains('party')) return 'Party Hall';
  if (n.contains('terrace')) return 'Terrace';
  if (n.contains('roof')) return 'Roof Top';
  return name;
}

int _getFloorOrder(String floorName) {
  const floorOrder = {
    'Ground Floor': 0,
    'First Floor': 1,
    'Second Floor': 2,
    'Third Floor': 3,
    'Basement': 4,
    'Party Hall': 5,
    'Terrace': 6,
    'Roof Top': 7,
    'Other': 8,
  };
  return floorOrder[floorName] ?? 999;
}

class TableManagementScreen extends StatefulWidget {
  const TableManagementScreen({super.key});

  @override
  State<TableManagementScreen> createState() => _TableManagementScreenState();
}

class _TableManagementScreenState extends State<TableManagementScreen> {
  List<TableModel> _tables = [];
  List<WaitlistItem> _waitlist = [];
  bool _loading = true;
  String? _errorMsg;
  String _vendorId = '';

  // Selection mode
  bool _selectionMode = false;
  final Set<String> _selectedIds = {};
  bool _deleting = false;

  String selectedFloor = 'All Floors';

  // Dynamic floors based on actual tables
  List<String> get _availableFloors {
    final uniqueFloors = _tables.map((t) => t.floorName).toSet().toList();
    uniqueFloors.sort((a, b) => _getFloorOrder(a).compareTo(_getFloorOrder(b)));
    return ['All Floors', ...uniqueFloors];
  }

  late ScrollController _tablesScrollCtrl;

  double _lastScrollPosition = 0;
  bool _showStatusCards = true;

  @override
  void initState() {
    super.initState();
    _tablesScrollCtrl = ScrollController();
    _tablesScrollCtrl.addListener(_scrollListener);
    _init();
  }

  void _scrollListener() {
    final currentPosition = _tablesScrollCtrl.position.pixels;
    final isScrollingUp = currentPosition < _lastScrollPosition;
    final isScrollingDown = currentPosition > _lastScrollPosition;

    if (isScrollingUp && !_showStatusCards && currentPosition > 0) {
      setState(() {
        _showStatusCards = true;
      });
    } else if (isScrollingDown && _showStatusCards && currentPosition > 50) {
      setState(() {
        _showStatusCards = false;
      });
    }

    _lastScrollPosition = currentPosition;
  }

  @override
  void dispose() {
    _tablesScrollCtrl.removeListener(_scrollListener);
    _tablesScrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    _vendorId = (prefs.getInt('vendorId') ?? prefs.getInt('vendor_id') ?? 0)
        .toString();
    await _fetchAll();
  }

  Future<void> _fetchAll() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _errorMsg = null;
    });
    try {
      await _fetchTables();
      await _fetchWaitlist();
    } catch (e) {
      if (mounted) setState(() => _errorMsg = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _fetchTables() async {
    try {
      final vendorIdStr = _vendorId;
      if (vendorIdStr.isEmpty) return;

      final tabData = await TableService.fetchTables(vendorIdStr);
      final bookData = await TableService.fetchBookings(
        vendorIdStr,
        _todayDate(),
      );

      final Map<String, dynamic> bMap = {};
      for (final b in bookData) {
        final sid = b['seatingId']?.toString();
        if (sid != null) {
          bMap[sid] = {
            'bookingId': b['id'],
            'customerName': b['guestName'],
            'phoneNumber': b['phoneNumber'],
            'guests': b['capacity'],
            'bookingDate': b['bookingDate'],
            'startTime': b['startTime'],
          };
        }
      }

      final transformed = tabData.map<TableModel>((item) {
        final sid = item['id'].toString();
        final bk = bMap[sid];
        return TableModel(
          id: sid,
          tableNo: item['code']?.toString() ?? '',
          floorName: _floorFromName(item['name']?.toString()),
          status: TableStatusX.fromApi(item['seatingStatus']?.toString()),
          capacity: (item['capacity'] as num?)?.toInt() ?? 4,
          customer: bk?['customerName'] ?? item['description'] ?? '',
          phone: bk?['phoneNumber'] ?? item['remarks'] ?? '',
          guests: bk?['guests']?.toString() ?? '',
          bookingTime: bk?['startTime'] ?? '',
          originalData: Map<String, dynamic>.from(item),
          bookingId: bk?['bookingId'] as int?,
        );
      }).toList();

      if (mounted) {
        setState(() {
          _tables = transformed;
        });
      }
    } catch (e) {
      debugPrint('_fetchTables ERROR: $e');
      rethrow;
    }
  }

  Future<void> _fetchWaitlist() async {
    try {
      final data = await TableService.fetchWaitlist(_vendorId);
      if (mounted) {
        setState(() {
          _waitlist = data
              .map<WaitlistItem>(
                (w) => WaitlistItem(
                  id: w['id'] as int,
                  customerName: w['guestName'] ?? '',
                  phone: w['phoneNumber'] ?? '',
                  guests: w['capacity']?.toString() ?? '',
                  bookingDate: w['bookingDate'] ?? '',
                  requestTime: w['requestTime'] ?? '',
                ),
              )
              .toList();
        });
      }
    } catch (e) {
      debugPrint('_fetchWaitlist ERROR: $e');
    }
  }

  Map<String, Map<int, List<TableModel>>> _getGrouped() {
    final filtered = selectedFloor == 'All Floors'
        ? _tables
        : _tables.where((t) => t.floorName == selectedFloor).toList();

    final Map<String, Map<int, List<TableModel>>> result = {};
    for (final t in filtered) {
      result.putIfAbsent(t.floorName, () => {});
      result[t.floorName]!.putIfAbsent(t.capacity, () => []);
      result[t.floorName]![t.capacity]!.add(t);
    }
    for (final floor in result.keys) {
      final sorted = Map.fromEntries(
        result[floor]!.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
      );
      result[floor] = sorted;
    }
    return result;
  }

  List<String> _sortedFloors(Map<String, Map<int, List<TableModel>>> g) =>
      g.keys.toList()
        ..sort((a, b) => _getFloorOrder(a).compareTo(_getFloorOrder(b)));

  Map<TableStatus, int> get _counts {
    final m = {for (final s in TableStatus.values) s: 0};
    for (final t in _tables) m[t.status] = (m[t.status] ?? 0) + 1;
    return m;
  }

  void _enterSelectionMode(String tableId) {
    setState(() {
      _selectionMode = true;
      _selectedIds.clear();
      _selectedIds.add(tableId);
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _selectionMode = false;
      _selectedIds.clear();
    });
  }

  void _toggleSelection(String tableId) {
    setState(() {
      if (_selectedIds.contains(tableId)) {
        _selectedIds.remove(tableId);
        if (_selectedIds.isEmpty) _selectionMode = false;
      } else {
        _selectedIds.add(tableId);
      }
    });
  }

  Future<void> _confirmDeleteSelected() async {
    final count = _selectedIds.length;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.delete_rounded, color: _error, size: 18),
            ),
            const SizedBox(width: 10),
            Text(
              'Delete $count Table${count > 1 ? 's' : ''}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _textDark,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to delete $count selected table${count > 1 ? 's' : ''}? This action cannot be undone.',
          style: const TextStyle(fontSize: 14, color: _textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: _textMuted)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: _error,
              foregroundColor: _white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text('Delete $count'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _deleting = true);
    int successCount = 0;

    for (final id in _selectedIds.toList()) {
      try {
        final success = await TableService.deleteTable(tableId: id);
        if (success) successCount++;
      } catch (e) {
        debugPrint('Delete table $id error: $e');
      }
    }

    setState(() => _deleting = false);
    _exitSelectionMode();

    if (successCount > 0) {
      _snack(
        'Deleted $successCount table${successCount > 1 ? 's' : ''}!',
        success: true,
      );
    }
    await _fetchTables();
  }

  Future<void> _addTable({
    required String name,
    required int numberOfTables,
    required int capacity,
  }) async {
    final success = await TableService.addTable(
      vendorId: _vendorId,
      name: name,
      numberOfTables: numberOfTables,
      capacity: capacity,
    );
    if (!success) throw Exception('Failed to add table');
  }

  Future<void> _updateTable({
    required String tableId,
    required String name,
    required String code,
    required int capacity,
    required String status,
    required String cleanTime,
    required String description,
    required String remarks,
    required bool manuallyUpdated,
  }) async {
    final success = await TableService.updateTable(
      tableId: tableId,
      name: name,
      code: code,
      capacity: capacity,
      status: status,
      cleanTime: cleanTime,
      description: description,
      remarks: remarks,
      manuallyUpdated: manuallyUpdated,
    );
    if (!success) throw Exception('Failed to update table');
  }

  Future<void> _removeWaitlist(int id) async {
    final success = await TableService.removeWaitlist(id);
    if (!success) throw Exception('Failed to remove waitlist item');
    await _fetchWaitlist();
  }

  void _snack(String msg, {bool success = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: success ? _success : _error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_selectionMode) {
          _exitSelectionMode();
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: _white,
        body: Column(
          children: [
            _buildTopBar(),
            // Animated status cards that hide on scroll up
            AnimatedOpacity(
              opacity: _showStatusCards && !_selectionMode ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height:
                    _showStatusCards &&
                        !_selectionMode &&
                        !_loading &&
                        _errorMsg == null
                    ? null
                    : 0,
                child:
                    _showStatusCards &&
                        !_selectionMode &&
                        !_loading &&
                        _errorMsg == null
                    ? _buildStatusCards()
                    : const SizedBox.shrink(),
              ),
            ),
            const SizedBox(height: 1),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(color: _orange),
                    )
                  : _errorMsg != null
                  ? _buildError()
                  : _buildTablesTab(),
            ),
          ],
        ),
        bottomNavigationBar: _selectionMode ? _buildDeleteBottomBar() : null,
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      color: _white,
      child: SafeArea(
        bottom: false,
        child: _selectionMode
            ? _buildSelectionTopBar()
            : Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        height: 48,
                        decoration: BoxDecoration(
                          color: _orangeLight,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: _orange.withOpacity(0.3)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _availableFloors.contains(selectedFloor)
                                ? selectedFloor
                                : 'All Floors',
                            isExpanded: true,
                            icon: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: _orange,
                            ),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _textDark,
                            ),
                            items: _availableFloors.map((floor) {
                              return DropdownMenuItem(
                                value: floor,
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.layers_rounded,
                                      size: 16,
                                      color: _orange,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(floor),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() => selectedFloor = value!);
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    _buildAddTableButton(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildAddTableButton() {
    return GestureDetector(
      onTap: _showAddTableBottomSheet,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: _orange,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: _orange.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Row(
          children: [
            Icon(Icons.add_rounded, color: _white, size: 18),
            SizedBox(width: 6),
            Text(
              'Add Table',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionTopBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      color: _white,
      child: Row(
        children: [
          GestureDetector(
            onTap: _exitSelectionMode,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _border,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.close_rounded,
                color: _textMuted,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _selectedIds.isEmpty
                  ? 'Select tables'
                  : '${_selectedIds.length} selected',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: _textDark,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              final allIds = _tables.map((t) => t.id).toSet();
              setState(() {
                if (_selectedIds.length == allIds.length) {
                  _exitSelectionMode();
                } else {
                  _selectedIds
                    ..clear()
                    ..addAll(allIds);
                }
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _orangeLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _orange.withOpacity(0.4)),
              ),
              child: Row(
                children: [
                  Icon(
                    _selectedIds.length == _tables.length
                        ? Icons.deselect_rounded
                        : Icons.select_all_rounded,
                    size: 14,
                    color: _orange,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _selectedIds.length == _tables.length
                        ? 'Deselect All'
                        : 'Select All',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _orange,
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

  Widget _buildDeleteBottomBar() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(
          color: _white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: _error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.table_restaurant_outlined,
                    color: _error,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${_selectedIds.length}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: _error,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _selectedIds.isEmpty || _deleting
                    ? null
                    : _confirmDeleteSelected,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _error,
                  foregroundColor: _white,
                  disabledBackgroundColor: _error.withOpacity(0.5),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: _deleting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          color: _white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.delete_rounded, size: 18),
                label: Text(
                  _deleting
                      ? 'Deleting...'
                      : _selectedIds.isEmpty
                      ? 'Select tables to delete'
                      : 'Delete ${_selectedIds.length} Table${_selectedIds.length > 1 ? 's' : ''}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Status cards (matching BookingTab style) ──────────────────────────────
  Widget _buildStatusCards() {
    final statusOrder = [
      TableStatus.available,
      TableStatus.reserved,
      TableStatus.vacant,
      TableStatus.occupied,
      TableStatus.cleaning,
      TableStatus.maintenance,
    ];

    Widget card(TableStatus status) {
      final int count = _counts[status] ?? 0;
      final Color color = status.color;

      return Expanded(
        child: Container(
          margin: const EdgeInsets.only(right: 4), // reduced margin
          padding: const EdgeInsets.symmetric(
            vertical: 8, // reduced height
            horizontal: 4, // reduced width
          ),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8), // smaller radius
            border: Border.all(color: color.withOpacity(0.3), width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 16, // reduced font size
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              const SizedBox(height: 2), // reduced spacing
              Text(
                status.label,
                style: TextStyle(
                  fontSize: 8, // smaller text
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
      child: Column(
        children: [
          Row(children: statusOrder.take(3).map(card).toList()),
          const SizedBox(height: 4),
          Row(children: statusOrder.skip(3).take(3).map(card).toList()),
        ],
      ),
    );
  }

  Widget _buildError() => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: _error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.wifi_off_rounded, color: _error, size: 30),
          ),
          const SizedBox(height: 16),
          const Text(
            'Failed to load tables',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _textDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _errorMsg ?? '',
            style: const TextStyle(fontSize: 12, color: _textMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _fetchAll,
            style: ElevatedButton.styleFrom(
              backgroundColor: _orange,
              foregroundColor: _white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Retry'),
          ),
        ],
      ),
    ),
  );

  // ── Tables grid (matching BookingTab layout) ──────────────────────────────
  Widget _buildTablesTab() {
    final grouped = _getGrouped();
    final sortedFloors = _sortedFloors(grouped);

    if (_tables.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
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
              Text(
                'Tap "Add Table" to create a table',
                style: TextStyle(color: _textMuted, fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      controller: _tablesScrollCtrl,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
      physics: const BouncingScrollPhysics(),
      itemCount: sortedFloors.length,
      itemBuilder: (_, i) {
        final floor = sortedFloors[i];
        final capacities = grouped[floor]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Floor Header (matching BookingTab style)
            Container(
              margin: const EdgeInsets.only(bottom: 10, top: 8),
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
                          floor,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: _textDark,
                            letterSpacing: 0.3,
                          ),
                        ),
                        Text(
                          '${_getTotalTablesForFloor(floor, capacities)} tables',
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
                      '${_getTotalTablesForFloor(floor, capacities)} ${_getTotalTablesForFloor(floor, capacities) == 1 ? 'table' : 'tables'}',
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

            // Capacity sections
            ...capacities.entries.map((capEntry) {
              final capacity = capEntry.key;
              final tables = capEntry.value;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 6),
                  // Capacity header
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10, left: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: 18,
                          decoration: BoxDecoration(
                            color: _orange,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '$capacity Seater',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _textDark,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: _border,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${tables.length}',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: _textMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Tables grid (4 columns like BookingTab)
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.9,
                        ),
                    itemCount: tables.length,
                    itemBuilder: (_, ti) {
                      final table = tables[ti];
                      final isSelected = _selectedIds.contains(table.id);

                      return _TableCard(
                        table: table,
                        selectionMode: _selectionMode,
                        isSelected: isSelected,
                        onTap: () {
                          if (_selectionMode) {
                            _toggleSelection(table.id);
                          } else {
                            _showEditTableSheet(table);
                          }
                        },
                        onLongPress: () {
                          if (!_selectionMode) {
                            _enterSelectionMode(table.id);
                          }
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              );
            }).toList(),
          ],
        );
      },
    );
  }

  int _getTotalTablesForFloor(
    String floor,
    Map<int, List<TableModel>> capacities,
  ) {
    int total = 0;
    for (final tables in capacities.values) {
      total += tables.length;
    }
    return total;
  }

  void _showAddTableBottomSheet() {
    final nameCtrl = TextEditingController();
    final countCtrl = TextEditingController(text: '1');

    String selectedName = '';
    bool isCustom = false;
    int selectedCap = 4;
    bool saving = false;

    const predefined = [
      'Ground Floor',
      'First Floor',
      'Second Floor',
      'Third Floor',
      'Basement',
      'Party Hall',
      'Terrace',
      'Roof Top',
    ];

    const capacities = [2, 4, 5, 6, 8, 10, 12, 20, 30];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx2, setBS) => Container(
          decoration: const BoxDecoration(
            color: _white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 4,
                margin: const EdgeInsets.only(top: 12),
                decoration: BoxDecoration(
                  color: _border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _orangeLight,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.add_circle_outline_rounded,
                        color: _orange,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Add New Table(s)',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: _textDark,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: _border,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 16,
                          color: _textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Divider(height: 1, color: _border),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    16,
                    20,
                    MediaQuery.of(ctx).viewInsets.bottom + 24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Table Floor / Name *',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _textDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: _orangeLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _orange.withOpacity(0.3)),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedName.isEmpty ? null : selectedName,
                            isExpanded: true,
                            hint: const Text(
                              'Select table location',
                              style: TextStyle(color: _textMuted, fontSize: 14),
                            ),
                            items: [
                              ...predefined.map(
                                (p) =>
                                    DropdownMenuItem(value: p, child: Text(p)),
                              ),
                              const DropdownMenuItem(
                                value: '__custom__',
                                child: Text('Other (Custom Name)'),
                              ),
                            ],
                            onChanged: (v) => setBS(() {
                              if (v == '__custom__') {
                                isCustom = true;
                                selectedName = '';
                              } else {
                                isCustom = false;
                                selectedName = v ?? '';
                              }
                            }),
                            style: const TextStyle(
                              fontSize: 14,
                              color: _textDark,
                            ),
                            icon: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: _orange,
                            ),
                          ),
                        ),
                      ),
                      if (isCustom) ...[
                        const SizedBox(height: 12),
                        Container(
                          decoration: BoxDecoration(
                            color: _orangeLight,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _orange.withOpacity(0.3)),
                          ),
                          child: TextField(
                            controller: nameCtrl,
                            onChanged: (v) => selectedName = v,
                            decoration: const InputDecoration(
                              hintText: 'Enter custom name',
                              hintStyle: TextStyle(
                                color: _textMuted,
                                fontSize: 14,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 14,
                              ),
                            ),
                            style: const TextStyle(
                              fontSize: 14,
                              color: _textDark,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      const Text(
                        'Number of Tables (max 10)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _textDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: _orangeLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _orange.withOpacity(0.3)),
                        ),
                        child: TextField(
                          controller: countCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: '1',
                            hintStyle: TextStyle(
                              color: _textMuted,
                              fontSize: 14,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 14,
                            ),
                          ),
                          style: const TextStyle(
                            fontSize: 14,
                            color: _textDark,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Capacity per Table',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _textDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: _orangeLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _orange.withOpacity(0.3)),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: selectedCap,
                            isExpanded: true,
                            items: capacities
                                .map(
                                  (c) => DropdownMenuItem(
                                    value: c,
                                    child: Text('$c seats'),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) => setBS(() => selectedCap = v ?? 4),
                            style: const TextStyle(
                              fontSize: 14,
                              color: _textDark,
                            ),
                            icon: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: _orange,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _orange.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              size: 14,
                              color: _orange,
                            ),
                            SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Cleaning time is automatically set to 30 minutes.',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: _textMuted,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(ctx),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: _border),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(color: _textMuted),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: saving
                                  ? null
                                  : () async {
                                      final finalName = isCustom
                                          ? nameCtrl.text.trim()
                                          : selectedName;
                                      if (finalName.isEmpty) {
                                        _snack('Please select or enter a name');
                                        return;
                                      }
                                      final cnt =
                                          int.tryParse(countCtrl.text) ?? 1;
                                      if (cnt < 1 || cnt > 10) {
                                        _snack('Number must be between 1-10');
                                        return;
                                      }
                                      setBS(() => saving = true);
                                      try {
                                        await _addTable(
                                          name: finalName,
                                          numberOfTables: cnt,
                                          capacity: selectedCap,
                                        );
                                        if (ctx.mounted) Navigator.pop(ctx);
                                        _snack(
                                          'Added $cnt table(s)!',
                                          success: true,
                                        );
                                        await Future.delayed(
                                          const Duration(milliseconds: 300),
                                        );
                                        await _fetchTables();
                                      } catch (e) {
                                        _snack(e.toString());
                                      } finally {
                                        setBS(() => saving = false);
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _orange,
                                foregroundColor: _white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                              child: saving
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        color: _white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'Add Table(s)',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
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
            ],
          ),
        ),
      ),
    );
  }

  void _showEditTableSheet(TableModel table) {
    bool isCustom = false;
    String editName = _floorFromName(table.originalData['name']?.toString());
    String editCode = table.tableNo;
    int editCap = table.capacity;
    String editStatus = table.status.apiValue;
    String editClean = '00:30:00';
    String editDesc = table.originalData['description']?.toString() ?? '';
    String editRem = table.originalData['remarks']?.toString() ?? '';
    bool editManual = true;
    bool saving = false;

    final codeCtrl = TextEditingController(text: editCode);
    final capCtrl = TextEditingController(text: editCap.toString());
    final descCtrl = TextEditingController(text: editDesc);
    final remCtrl = TextEditingController(text: editRem);
    final customNameCtrl = TextEditingController(text: editName);

    const predefined = [
      'Ground Floor',
      'First Floor',
      'Second Floor',
      'Third Floor',
      'Basement',
      'Party Hall',
      'Terrace',
      'Roof Top',
    ];
    const statusOpts = [
      'Available',
      'Reserved',
      'Vacant',
      'Occupied',
      'Cleaning',
      'Maintenance',
    ];
    const cleanOpts = [
      {'label': '15 minutes', 'value': '00:15:00'},
      {'label': '30 minutes', 'value': '00:30:00'},
      {'label': '45 minutes', 'value': '00:45:00'},
      {'label': '1 hour', 'value': '01:00:00'},
      {'label': '1 hr 30 min', 'value': '01:30:00'},
      {'label': '2 hours', 'value': '02:00:00'},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx2, setBS) => SafeArea(
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.92,
            minChildSize: 0.60,
            maxChildSize: 0.95,
            builder: (_, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: _white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 50,
                      height: 4,
                      margin: const EdgeInsets.only(top: 12),
                      decoration: BoxDecoration(
                        color: _border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: _orangeLight,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              Icons.edit_rounded,
                              color: _orange,
                              size: 22,
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Text(
                              'Edit Table: ${table.tableNo}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: _textDark,
                              ),
                            ),
                          ),

                          GestureDetector(
                            onTap: () => Navigator.pop(ctx),
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: _border,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.close_rounded,
                                size: 16,
                                color: _textMuted,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Divider(height: 1, color: _border),

                    Expanded(
                      child: SingleChildScrollView(
                        controller: scrollController,
                        padding: EdgeInsets.fromLTRB(
                          20,
                          16,
                          20,
                          MediaQuery.of(ctx).viewInsets.bottom + 24,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Table Floor / Name',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _textDark,
                              ),
                            ),

                            const SizedBox(height: 8),

                            Container(
                              decoration: BoxDecoration(
                                color: _orangeLight,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _orange.withOpacity(0.3),
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: predefined.contains(editName)
                                      ? editName
                                      : '__custom__',
                                  isExpanded: true,
                                  items: [
                                    ...predefined.map(
                                      (p) => DropdownMenuItem(
                                        value: p,
                                        child: Text(p),
                                      ),
                                    ),
                                    const DropdownMenuItem(
                                      value: '__custom__',
                                      child: Text('Other (Custom Name)'),
                                    ),
                                  ],
                                  onChanged: (v) => setBS(() {
                                    if (v == '__custom__') {
                                      isCustom = true;
                                      editName = customNameCtrl.text;
                                    } else {
                                      isCustom = false;
                                      editName = v ?? '';
                                      customNameCtrl.text = editName;
                                    }
                                  }),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: _textDark,
                                  ),
                                  icon: Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: _orange,
                                  ),
                                ),
                              ),
                            ),

                            if (isCustom || !predefined.contains(editName)) ...[
                              const SizedBox(height: 12),

                              Container(
                                decoration: BoxDecoration(
                                  color: _orangeLight,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _orange.withOpacity(0.3),
                                  ),
                                ),
                                child: TextField(
                                  controller: customNameCtrl,
                                  onChanged: (v) => editName = v,
                                  decoration: const InputDecoration(
                                    hintText: 'Custom name',
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ],

                            const SizedBox(height: 14),

                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Table Code',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: _textDark,
                                        ),
                                      ),

                                      const SizedBox(height: 8),

                                      Container(
                                        decoration: BoxDecoration(
                                          color: _orangeLight,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: _orange.withOpacity(0.3),
                                          ),
                                        ),
                                        child: TextField(
                                          controller: codeCtrl,
                                          onChanged: (v) => editCode = v,
                                          decoration: const InputDecoration(
                                            hintText: 'e.g. T01',
                                            border: InputBorder.none,
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                  horizontal: 14,
                                                  vertical: 14,
                                                ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(width: 12),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Capacity',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: _textDark,
                                        ),
                                      ),

                                      const SizedBox(height: 8),

                                      Container(
                                        decoration: BoxDecoration(
                                          color: _orangeLight,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: _orange.withOpacity(0.3),
                                          ),
                                        ),
                                        child: TextField(
                                          controller: capCtrl,
                                          keyboardType: TextInputType.number,
                                          onChanged: (v) {
                                            editCap =
                                                int.tryParse(v) ?? editCap;
                                          },
                                          decoration: const InputDecoration(
                                            hintText: '4',
                                            border: InputBorder.none,
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                  horizontal: 14,
                                                  vertical: 14,
                                                ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 14),

                            const Text(
                              'Status',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _textDark,
                              ),
                            ),

                            const SizedBox(height: 8),

                            Container(
                              decoration: BoxDecoration(
                                color: _orangeLight,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _orange.withOpacity(0.3),
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: editStatus,
                                  isExpanded: true,
                                  items: statusOpts
                                      .map(
                                        (s) => DropdownMenuItem(
                                          value: s,
                                          child: Text(s),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (v) => setBS(() {
                                    editStatus = v ?? editStatus;
                                  }),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: _textDark,
                                  ),
                                  icon: Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: _orange,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 14),

                            const Text(
                              'Cleaning Duration',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _textDark,
                              ),
                            ),

                            const SizedBox(height: 8),

                            Container(
                              decoration: BoxDecoration(
                                color: _orangeLight,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _orange.withOpacity(0.3),
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value:
                                      cleanOpts.any(
                                        (o) => o['value'] == editClean,
                                      )
                                      ? editClean
                                      : '00:30:00',
                                  isExpanded: true,
                                  items: cleanOpts
                                      .map(
                                        (o) => DropdownMenuItem(
                                          value: o['value'],
                                          child: Text(o['label']!),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (v) => setBS(() {
                                    editClean = v ?? editClean;
                                  }),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: _textDark,
                                  ),
                                  icon: Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: _orange,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 14),

                            const Text(
                              'Description',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _textDark,
                              ),
                            ),

                            const SizedBox(height: 8),

                            Container(
                              decoration: BoxDecoration(
                                color: _orangeLight,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _orange.withOpacity(0.3),
                                ),
                              ),
                              child: TextField(
                                controller: descCtrl,
                                maxLines: 2,
                                onChanged: (v) => editDesc = v,
                                decoration: const InputDecoration(
                                  hintText: 'Optional',
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 14),

                            const Text(
                              'Remarks',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _textDark,
                              ),
                            ),

                            const SizedBox(height: 8),

                            Container(
                              decoration: BoxDecoration(
                                color: _orangeLight,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _orange.withOpacity(0.3),
                                ),
                              ),
                              child: TextField(
                                controller: remCtrl,
                                maxLines: 2,
                                onChanged: (v) => editRem = v,
                                decoration: const InputDecoration(
                                  hintText: 'Optional',
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(color: _border),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                    ),
                                    child: const Text(
                                      'Cancel',
                                      style: TextStyle(color: _textMuted),
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 12),

                                Expanded(
                                  flex: 2,
                                  child: ElevatedButton(
                                    onPressed: saving
                                        ? null
                                        : () async {
                                            setBS(() => saving = true);

                                            try {
                                              await _updateTable(
                                                tableId: table.id,
                                                name: editName,
                                                code: codeCtrl.text.trim(),
                                                capacity: editCap,
                                                status: editStatus,
                                                cleanTime: editClean,
                                                description: descCtrl.text
                                                    .trim(),
                                                remarks: remCtrl.text.trim(),
                                                manuallyUpdated: editManual,
                                              );

                                              if (ctx.mounted) {
                                                Navigator.pop(ctx);
                                              }

                                              _snack(
                                                'Table updated!',
                                                success: true,
                                              );

                                              await _fetchTables();
                                            } catch (e) {
                                              _snack(e.toString());
                                            } finally {
                                              setBS(() => saving = false);
                                            }
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _success,
                                      foregroundColor: _white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                    ),
                                    child: saving
                                        ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              color: _white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Text(
                                            'Save Changes',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 15,
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
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// ── Table Card Widget (matching BookingTab's TableCard style) ───────────────
class _TableCard extends StatelessWidget {
  final TableModel table;
  final bool selectionMode;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _TableCard({
    required this.table,
    required this.selectionMode,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final s = table.status;
    final bgColor = isSelected ? _error.withOpacity(0.08) : s.lightColor;
    final borderColor = isSelected ? _error : s.color;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: borderColor.withOpacity(0.4),
            width: isSelected ? 2 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: (isSelected ? _error : s.color).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isSelected ? Icons.delete_rounded : s.icon,
                    color: isSelected ? _error : s.color,
                    size: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Flexible(
                  child: Text(
                    table.tableNo,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? _error : s.color,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 2),
                Flexible(
                  child: Text(
                    '${table.capacity} seats',
                    style: const TextStyle(fontSize: 8, color: _textMuted),
                    maxLines: 1,
                  ),
                ),
              ],
            ),
            if (selectionMode)
              Positioned(
                top: 4,
                right: 4,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: isSelected ? _error : _white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? _error : _textMuted,
                      width: 1.5,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check_rounded, size: 12, color: _white)
                      : null,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
