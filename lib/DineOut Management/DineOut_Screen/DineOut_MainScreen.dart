import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../DineOut_Services/DineOutAuthService.dart';
import 'BookingTab.dart';
import 'REQUEST ITEM.dart';
import 'ReservationTab.dart';

class DineOut extends StatefulWidget {
  const DineOut({super.key});

  @override
  State<DineOut> createState() => _DineOutState();
}

class _DineOutState extends State<DineOut> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> _titles = ['REQUESTS', 'RESERVATION', 'TABLES'];

  List<Map<String, dynamic>> _tables = [];
  List<Map<String, dynamic>> _reservations = [];

  bool _isDataFetched = false;

  // ── Colors ────────────────────────────────────────────────────────────────
  static const Color _orange = Color(0xFFE87722);
  static const Color _green = Color(0xFF4CAF50);

  static const Color _bg = Color(0xFFF7F6F3);
  static const Color _white = Color(0xFFFFFFFF);
  static const Color _border = Color(0xFFEEECEA);

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: _titles.length, vsync: this);

    _tabController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  // ── Fetch Tables ──────────────────────────────────────────────────────────
  Future<void> _fetchTablesFromApi() async {
    if (!mounted) return;

    try {
      final prefs = await SharedPreferences.getInstance();

      int vendorId = prefs.getInt('vendorId') ?? 0;

      if (vendorId == 0) return;

      List<Map<String, dynamic>> fetchedTables =
          await DineoutAuthService.fetchTables(vendorId);

      if (mounted) {
        setState(() {
          _tables = fetchedTables;
        });
      }
    } catch (e) {
      // debugPrint("Error fetching tables: $e");
    }
  }

  // ── Fetch Reservations ────────────────────────────────────────────────────
  Future<void> _fetchReservationsFromApi() async {
    if (!mounted) return;

    try {
      final prefs = await SharedPreferences.getInstance();

      int vendorId = prefs.getInt('vendorId') ?? 0;

      if (vendorId == 0) return;

      String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

      List<Map<String, dynamic>> fetchedReservations =
          await DineoutAuthService.fetchReservations(
            vendorId: vendorId,
            date: formattedDate,
          );

      if (mounted) {
        setState(() {
          _reservations = fetchedReservations;
        });
      }
    } catch (e) {
      // debugPrint("Error fetching reservations: $e");
    }
  }

  // ── Filter Reservation By Date ────────────────────────────────────────────
  Future<void> _filterReservationsByDate(DateTime date) async {
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();

    int vendorId = prefs.getInt('vendorId') ?? 0;

    if (vendorId == 0) return;

    String formattedDate = DateFormat('yyyy-MM-dd').format(date);

    List<Map<String, dynamic>> fetchedReservations =
        await DineoutAuthService.fetchReservations(
          vendorId: vendorId,
          date: formattedDate,
        );

    if (mounted) {
      setState(() {
        _reservations = fetchedReservations;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ── Initial API Calls ───────────────────────────────────────────────────
    if (!_isDataFetched) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await _fetchTablesFromApi();
        await _fetchReservationsFromApi();

        if (mounted) {
          setState(() {
            _isDataFetched = true;
          });
        }
      });
    }

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  // ✅ REQUESTS Tab (index 0)
                  const TableRequestScreen(),

                  // ✅ RESERVATION Tab (index 1)
                  ReservationTab(
                    reservations: _reservations,
                    onFilterDateChanged: (date) {
                      _filterReservationsByDate(date);
                    },
                    onRefresh: () {
                      _fetchReservationsFromApi();
                    },
                  ),

                  // ✅ TABLES Tab (index 2)
                  BookingTab(
                    tables: _tables,
                    reservations: _reservations,
                    onTablesUpdated: () {
                      _fetchTablesFromApi();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 14, 16, 14),
      decoration: const BoxDecoration(
        color: _white,
        border: Border(bottom: BorderSide(color: _border, width: 1)),
      ),
      child: Row(
        children: [
          // ✅ Back Arrow
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.pop(context);
            },
          ),

          // ── Tabs ─────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: List.generate(_titles.length, (index) {
                  // ✅ ACTIVE TAB CHECK
                  final bool isActive = _tabController.index == index;

                  return Padding(
                    padding: EdgeInsets.only(
                      right: index < _titles.length - 1 ? 6 : 0,
                    ),
                    child: GestureDetector(
                      onTap: () {
                        // ✅ Change Tab
                        _tabController.animateTo(index);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          // ✅ GREEN = Selected
                          // ✅ ORANGE = Unselected
                          color: isActive ? _green : _orange,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: isActive
                              ? [
                                  BoxShadow(
                                    color: _green.withOpacity(0.25),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : [],
                        ),
                        child: Text(
                          _titles[index],
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
