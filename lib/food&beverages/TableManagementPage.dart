// import 'package:flutter/material.dart';
// import 'package:maamaaspartner/widgets_helper/drawer.dart';
//
// import 'UserBookingsPage.dart';
// import 'VendorBookingsPage.dart';
// import 'WaiterBookingsPage.dart';
//
// class TableManagementPage extends StatefulWidget {
//   const TableManagementPage({super.key});
//
//   @override
//   State<TableManagementPage> createState() => _TableManagementPageState();
// }
//
// class _TableManagementPageState extends State<TableManagementPage> {
//   int _selectedIndex = 0;
//
//   void _onItemTapped(int index) {
//     setState(() => _selectedIndex = index);
//   }
//
//   Widget _buildBookingCard(String title, IconData icon, Color color) {
//     return Card(
//       elevation: 3,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
//       child: InkWell(
//         onTap: () {
//           if (title == "Vendor Bookings") {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => const VendorBookingsPage(),
//               ),
//             );
//           } else if (title == "Waiter Bookings") {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => const WaiterBookingsPage(),
//               ),
//             );
//           } else if (title == "User Bookings") {
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (context) => const UserBookingsPage()),
//             );
//           } else {
//             ScaffoldMessenger.of(
//               context,
//             ).showSnackBar(SnackBar(content: Text("$title clicked")));
//           }
//         },
//         borderRadius: BorderRadius.circular(12),
//         child: Padding(
//           padding: const EdgeInsets.all(20),
//           child: Row(
//             children: [
//               Icon(icon, color: color, size: 40),
//               const SizedBox(width: 20),
//               Text(
//                 title,
//                 style: const TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // drawer:CustomDrawer(),
//       appBar: AppBar(
//         title: const Text(
//           "Table Management",
//           style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
//         ),
//         backgroundColor: Colors.white,
//         iconTheme: const IconThemeData(color: Colors.black),
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             const SizedBox(height: 16),
//             _buildBookingCard(
//               "Vendor Bookings",
//               Icons.store,
//               Colors.deepPurple,
//             ),
//             _buildBookingCard("Waiter Bookings", Icons.people, Colors.orange),
//             _buildBookingCard("User Bookings", Icons.person, Colors.green),
//           ],
//         ),
//       ),
//       // bottomNavigationBar: BottomNavigationBar(
//       //   backgroundColor: Colors.deepPurple,
//       //   selectedItemColor: Colors.white,
//       //   unselectedItemColor: Colors.white70,
//       //   type: BottomNavigationBarType.fixed,
//       //   currentIndex: _selectedIndex,
//       //   onTap: _onItemTapped,
//       //   items: const [
//       //     BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
//       //     BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: "Menu"),
//       //     BottomNavigationBarItem(
//       //         icon: Icon(Icons.shopping_cart), label: "Cart"),
//       //     BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
//       //   ],
//       // ),
//     );
//   }
// }
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'BookTablePage.dart';
import 'add_floor_page.dart';
import 'add_waitlist_page.dart';
import 'UserBookingsPage.dart';
import 'WaiterBookingsPage.dart' hide WaiterBookingsPage;

// ─── Design Tokens ────────────────────────────────────────────────────────────
class _T {
  // Core palette — deep plum + warm gold accent
  static const bg = Color(0xFFF4F0FB);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceAlt = Color(0xFFF9F7FD);
  static const primary = Color(0xFF5B21B6); // deep violet
  static const primaryLt = Color(0xFFEDE9FE);
  static const accent = Color(0xFFF59E0B); // warm amber
  static const accentLt = Color(0xFFFEF3C7);
  static const green = Color(0xFF059669);
  static const greenLt = Color(0xFFD1FAE5);
  static const orange = Color(0xFFEA580C);
  static const orangeLt = Color(0xFFFFEDD5);
  static const red = Color(0xFFDC2626);
  static const redLt = Color(0xFFFEE2E2);
  static const text1 = Color(0xFF1E1B4B);
  static const text2 = Color(0xFF6B7280);
  static const text3 = Color(0xFFB0B3C1);
  static const border = Color(0xFFE8E4F3);
  static const shadow = Color(0x12000000);
}

// ─── TABLE MANAGEMENT PAGE ────────────────────────────────────────────────────
class TableManagementPage extends StatefulWidget {
  const TableManagementPage({super.key});

  @override
  State<TableManagementPage> createState() => _TableManagementPageState();
}

class _TableManagementPageState extends State<TableManagementPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _ac;

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  static const _cards = [
    _MenuCard(
      title: 'Vendor Bookings',
      subtitle: 'Manage floors, tables & reservations',
      icon: Icons.store_mall_directory_rounded,
      color: _T.primary,
      colorLt: _T.primaryLt,
      delay: 0,
    ),
    _MenuCard(
      title: 'Waiter Bookings',
      subtitle: 'View & assign waiter-managed tables',
      icon: Icons.room_service_rounded,
      color: _T.orange,
      colorLt: _T.orangeLt,
      delay: 120,
    ),
    // _MenuCard(
    //   title: 'User Bookings',
    //   subtitle: 'Customer-placed table reservations',
    //   icon: Icons.person_pin_rounded,
    //   color: _T.green,
    //   colorLt: _T.greenLt,
    //   delay: 240,
    // ),
  ];

  void _navigate(String title) {
    Widget page;
    switch (title) {
      case 'Vendor Bookings':
        page = const VendorBookingsPage();
        break;
      case 'Waiter Bookings':
        page = const WaiterBookingsPage();
        break;
      default:
        page = const UserBookingsPage();
    }
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: _T.bg,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Custom app bar ──────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.maybePop(context),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _T.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _T.border),
                          boxShadow: const [
                            BoxShadow(color: _T.shadow, blurRadius: 6),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: _T.text1,
                          size: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Table Management',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: _T.text1,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 0.25),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const Text(
                  ' ',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _T.text2,
                    letterSpacing: 0.5,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ── Navigation cards ────────────────────────────────────────
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  itemCount: _cards.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final card = _cards[i];
                    return _AnimatedCard(
                      controller: _ac,
                      delay: card.delay,
                      child: _BookingNavCard(
                        card: card,
                        onTap: () => _navigate(card.title),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Menu card data class ──────────────────────────────────────────────────────
class _MenuCard {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Color colorLt;
  final int delay;
  const _MenuCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.colorLt,
    required this.delay,
  });
}

// ─── Animated entrance wrapper ────────────────────────────────────────────────
class _AnimatedCard extends StatelessWidget {
  final AnimationController controller;
  final int delay;
  final Widget child;

  const _AnimatedCard({
    required this.controller,
    required this.delay,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final start = delay / 900.0;
    final end = (delay + 500) / 900.0;
    final curve = CurvedAnimation(
      parent: controller,
      curve: Interval(
        start.clamp(0.0, 1.0),
        end.clamp(0.0, 1.0),
        curve: Curves.easeOutCubic,
      ),
    );
    return AnimatedBuilder(
      animation: curve,
      builder: (_, __) => Opacity(
        opacity: curve.value,
        child: Transform.translate(
          offset: Offset(0, 24 * (1 - curve.value)),
          child: child,
        ),
      ),
    );
  }
}

// ─── Booking navigation card ──────────────────────────────────────────────────
class _BookingNavCard extends StatelessWidget {
  final _MenuCard card;
  final VoidCallback onTap;

  const _BookingNavCard({required this.card, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: _T.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _T.border),
          boxShadow: const [
            BoxShadow(color: _T.shadow, blurRadius: 10, offset: Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: card.colorLt,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(card.icon, color: card.color, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    card.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: _T.text1,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    card.subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: _T.text2,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: card.colorLt,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                color: card.color,
                size: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── VENDOR BOOKINGS PAGE ─────────────────────────────────────────────────────
class VendorBookingsPage extends StatefulWidget {
  const VendorBookingsPage({super.key});

  @override
  State<VendorBookingsPage> createState() => _VendorBookingsPageState();
}

class _VendorBookingsPageState extends State<VendorBookingsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  bool isLoading = true;
  bool isWaitingLoading = true;
  bool isBookingsLoading = true;

  List<dynamic> floorData = [];
  List<dynamic> waitingList = [];
  List<dynamic> vendorBookings = [];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    _fetchFloorData();
    _fetchWaitingList();
    _fetchVendorBookings();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  // ── token helper ─────────────────────────────────────────────────────────────
  Future<String?> _token() async {
    final p = await SharedPreferences.getInstance();
    for (final k in [
      'token',
      'authToken',
      'accessToken',
      'jwtToken',
      'bearerToken',
      'userToken',
    ]) {
      final v = p.get(k);
      if (v != null) return v.toString();
    }
    return null;
  }

  Future<int> _vendorId() async {
    final p = await SharedPreferences.getInstance();
    return p.getInt('vendorId') ?? p.getInt('VendorId') ?? 1;
  }

  // ── API calls ─────────────────────────────────────────────────────────────────
  Future<void> _fetchFloorData() async {
    try {
      final token = await _token();
      final vendorId = await _vendorId();
      final response = await http.get(
        Uri.parse(
          'http://staging.maamaas.com:8080/food/api/seating/all/vendor/$vendorId',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        List<dynamic> floors = decoded is List
            ? decoded
            : decoded is Map && decoded['floors'] is List
            ? decoded['floors']
            : [];
        setState(() {
          floorData = floors;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        _snack('Failed to fetch floors: ${response.statusCode}', _T.red);
      }
    } catch (e) {
      setState(() => isLoading = false);
      _snack('Error: $e', _T.red);
    }
  }

  Future<void> _fetchWaitingList() async {
    try {
      final token = await _token();
      final vendorId = await _vendorId();
      final response = await http.get(
        Uri.parse(
          'http://staging.maamaas.com:8080/food/api/seatingdetails/waiting/vendor/$vendorId',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        setState(() {
          waitingList = decoded is List ? decoded : [];
          isWaitingLoading = false;
        });
      } else {
        setState(() => isWaitingLoading = false);
      }
    } catch (e) {
      setState(() => isWaitingLoading = false);
    }
  }

  Future<void> _fetchVendorBookings() async {
    try {
      final token = await _token();
      final vendorId = await _vendorId();
      final response = await http.get(
        Uri.parse(
          'http://staging.maamaas.com:8080/food/api/seatingdetails/vendor/$vendorId/vendor-bookings',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        setState(() {
          vendorBookings = decoded is List ? decoded : [];
          isBookingsLoading = false;
        });
      } else {
        setState(() => isBookingsLoading = false);
      }
    } catch (e) {
      setState(() => isBookingsLoading = false);
    }
  }

  Future<void> _deleteTable(int id, String tableCode) async {
    try {
      final token = await _token();
      // Delete related seating details first
      final detailsResp = await http.get(
        Uri.parse(
          'http://staging.maamaas.com:8080/food/api/seating-details/by-seating/$id',
        ),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (detailsResp.statusCode == 200) {
        final list = jsonDecode(detailsResp.body) as List<dynamic>;
        for (final d in list) {
          await http.delete(
            Uri.parse(
              'http://staging.maamaas.com:8080/food/api/seating-details/delete/${d['id']}',
            ),
            headers: {'Authorization': 'Bearer $token'},
          );
        }
      }
      final resp = await http.delete(
        Uri.parse(
          'http://staging.maamaas.com:8080/food/api/seating/delete/$id',
        ),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (resp.statusCode == 200 || resp.statusCode == 204) {
        setState(() {
          floorData = floorData.map((floor) {
            if (floor['tables'] != null) {
              return {
                ...floor,
                'tables': List.from(floor['tables'])
                  ..removeWhere((t) => t['id'] == id),
              };
            }
            return floor;
          }).toList();
        });
        _snack('Table $tableCode deleted', _T.green);
      } else {
        _snack('Failed to delete $tableCode', _T.red);
      }
    } catch (e) {
      _snack('Error: $e', _T.red);
    }
  }

  Future<void> _deleteWaitingGuest(dynamic id, String name) async {
    try {
      final token = await _token();
      final resp = await http.delete(
        Uri.parse(
          'http://staging.maamaas.com:8080/food/api/seatingdetails/delete/waiting-list/$id',
        ),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (resp.statusCode == 200 || resp.statusCode == 204) {
        setState(() => waitingList.removeWhere((g) => g['id'] == id));
        _snack('$name removed', _T.green);
      } else {
        _snack('Failed to remove $name', _T.red);
      }
    } catch (e) {
      _snack('Error: $e', _T.red);
    }
  }

  Future<void> _deleteBooking(int id) async {
    try {
      final token = await _token();
      final resp = await http.delete(
        Uri.parse(
          'http://staging.maamaas.com:8080/food/api/seatingdetails/seatingdetails/$id',
        ),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (resp.statusCode == 200 || resp.statusCode == 204) {
        _snack('Booking deleted', _T.green);
        _fetchVendorBookings();
      } else {
        _snack('Failed to delete booking', _T.red);
      }
    } catch (e) {
      _snack('Error: $e', _T.red);
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

  void _showEditPopup(
    String floorName,
    List<dynamic> floorItems,
    int capacity,
  ) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.all(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _T.primaryLt,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.edit_rounded,
                      color: _T.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      floorName,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: _T.text1,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, color: _T.text2),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: _T.border),
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 320),
                child: ListView(
                  shrinkWrap: true,
                  children: floorItems.map((item) {
                    final id = item['id'];
                    final code = item['code'] ?? '—';
                    final status = item['seatingStatus'] ?? '—';
                    final isAvail =
                        status.toString().toLowerCase() == 'available';
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: _T.surfaceAlt,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _T.border),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isAvail ? _T.greenLt : _T.redLt,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              code,
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                                color: isAvail ? _T.green : _T.red,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  status,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isAvail ? _T.green : _T.red,
                                  ),
                                ),
                                Text(
                                  'Cap: $capacity',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: _T.text2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              _deleteTable(id, code);
                            },
                            child: Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: _T.redLt,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.delete_rounded,
                                color: _T.red,
                                size: 18,
                              ),
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
        ),
      ),
    );
  }

  // ── BUILD ─────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: _T.bg,
        body: SafeArea(
          child: Column(
            children: [
              // ── Header ────────────────────────────────────────────────────
              _VendorHeader(
                onBack: () => Navigator.pop(context),
                onAddFloor: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddFloorPage()),
                ),
                onWaitlist: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddWaitlistPage()),
                ),
              ),

              // ── Tab bar ───────────────────────────────────────────────────
              Container(
                color: _T.surface,
                child: Column(
                  children: [
                    TabBar(
                      controller: _tabCtrl,
                      labelColor: _T.primary,
                      unselectedLabelColor: _T.text2,
                      labelStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      indicatorColor: _T.primary,
                      indicatorWeight: 3,
                      tabs: [
                        _tab('Floors', Icons.layers_rounded),
                        _tab('Waitlist', Icons.hourglass_top_rounded),
                        _tab('Bookings', Icons.book_rounded),
                      ],
                    ),
                    const Divider(height: 1, color: _T.border),
                  ],
                ),
              ),

              // ── Tab views ─────────────────────────────────────────────────
              Expanded(
                child: TabBarView(
                  controller: _tabCtrl,
                  children: [
                    _FloorsTab(
                      isLoading: isLoading,
                      floorData: floorData,
                      onEditFloor: _showEditPopup,
                      onRefresh: _fetchFloorData,
                    ),
                    _WaitlistTab(
                      isLoading: isWaitingLoading,
                      waitingList: waitingList,
                      onDelete: _deleteWaitingGuest,
                      onRefresh: _fetchWaitingList,
                    ),
                    _BookingsTab(
                      isLoading: isBookingsLoading,
                      bookings: vendorBookings,
                      onDelete: _deleteBooking,
                      onRefresh: _fetchVendorBookings,
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

  Tab _tab(String label, IconData icon) => Tab(
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [Icon(icon, size: 15), const SizedBox(width: 5), Text(label)],
    ),
  );
}

// ─── Vendor page header ────────────────────────────────────────────────────────
class _VendorHeader extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onAddFloor;
  final VoidCallback onWaitlist;

  const _VendorHeader({
    required this.onBack,
    required this.onAddFloor,
    required this.onWaitlist,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _T.surface,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: onBack,
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: _T.surfaceAlt,
                    borderRadius: BorderRadius.circular(11),
                    border: Border.all(color: _T.border),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: _T.text1,
                    size: 15,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Vendor Bookings',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: _T.text1,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ActionBtn(
                  label: 'Add Floor',
                  icon: Icons.add_home_work_rounded,
                  color: _T.primary,
                  colorLt: _T.primaryLt,
                  onTap: onAddFloor,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ActionBtn(
                  label: 'Add Waitlist',
                  icon: Icons.playlist_add_rounded,
                  color: _T.orange,
                  colorLt: _T.orangeLt,
                  onTap: onWaitlist,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Color colorLt;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.label,
    required this.icon,
    required this.color,
    required this.colorLt,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: colorLt,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── FLOORS TAB ───────────────────────────────────────────────────────────────
class _FloorsTab extends StatelessWidget {
  final bool isLoading;
  final List<dynamic> floorData;
  final Function(String, List<dynamic>, int) onEditFloor;
  final VoidCallback onRefresh;

  const _FloorsTab({
    required this.isLoading,
    required this.floorData,
    required this.onEditFloor,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const _LoadingView();

    // Group tables by floor name
    final Map<String, List<dynamic>> grouped = {};
    for (final item in floorData) {
      final name = item['name'] ?? 'Unnamed Floor';
      grouped.putIfAbsent(name, () => []).add(item);
    }

    if (grouped.isEmpty) {
      return _EmptyView(
        icon: Icons.layers_clear_rounded,
        title: 'No Floors Yet',
        subtitle: 'Tap "Add Floor" to create your first floor.',
        onRefresh: onRefresh,
      );
    }

    return RefreshIndicator(
      color: _T.primary,
      onRefresh: () async => onRefresh(),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        itemCount: grouped.length,
        itemBuilder: (_, i) {
          final entry = grouped.entries.elementAt(i);
          final floorName = entry.key;
          final items = entry.value;
          final capacity =
              int.tryParse(items.first['capacity']?.toString() ?? '0') ?? 0;
          final totalTables = items.length;
          final available = items
              .where(
                (t) =>
                    t['seatingStatus']?.toString().toLowerCase() == 'available',
              )
              .length;

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: _T.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _T.border),
              boxShadow: const [
                BoxShadow(
                  color: _T.shadow,
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
                  decoration: BoxDecoration(
                    color: _T.primaryLt,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(18),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: _T.primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.layers_rounded,
                          color: _T.primary,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          floorName,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: _T.primary,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => onEditFloor(floorName, items, capacity),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: _T.primary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(
                                Icons.edit_rounded,
                                color: _T.primary,
                                size: 14,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Edit',
                                style: TextStyle(
                                  color: _T.primary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    children: [
                      _StatChip(
                        label: 'Capacity',
                        value: capacity.toString(),
                        color: _T.primary,
                      ),
                      const SizedBox(width: 8),
                      _StatChip(
                        label: 'Tables',
                        value: totalTables.toString(),
                        color: _T.accent,
                      ),
                      const SizedBox(width: 8),
                      _StatChip(
                        label: 'Available',
                        value: available.toString(),
                        color: _T.green,
                      ),
                    ],
                  ),
                ),

                // Tables grid
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: items.map((table) {
                      final code = table['code'] ?? '---';
                      final seatingId = table['id'];
                      final status =
                          table['seatingStatus']?.toString().toLowerCase() ??
                          '';
                      final isAvail = status == 'available';

                      if (seatingId == null) return const SizedBox.shrink();

                      return GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BookTablePage(
                              floorName: floorName,
                              tableCode: code,
                              capacity: capacity,
                              seatingId: seatingId,
                            ),
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isAvail ? _T.greenLt : _T.redLt,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isAvail
                                  ? _T.green.withOpacity(0.3)
                                  : _T.red.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.table_restaurant_rounded,
                                size: 13,
                                color: isAvail ? _T.green : _T.red,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                code,
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                  color: isAvail ? _T.green : _T.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── WAITLIST TAB ─────────────────────────────────────────────────────────────
class _WaitlistTab extends StatelessWidget {
  final bool isLoading;
  final List<dynamic> waitingList;
  final Function(dynamic, String) onDelete;
  final VoidCallback onRefresh;

  const _WaitlistTab({
    required this.isLoading,
    required this.waitingList,
    required this.onDelete,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const _LoadingView();
    if (waitingList.isEmpty) {
      return _EmptyView(
        icon: Icons.hourglass_empty_rounded,
        title: 'No Waiting Guests',
        subtitle: 'The waitlist is clear right now.',
        onRefresh: onRefresh,
      );
    }

    return RefreshIndicator(
      color: _T.primary,
      onRefresh: () async => onRefresh(),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        itemCount: waitingList.length,
        itemBuilder: (_, i) {
          final guest = waitingList[i];
          final id = guest['id'];
          final name = guest['guestName'] ?? 'Guest';
          final size = guest['capacity']?.toString() ?? '—';
          final phone = guest['phoneNumber'] ?? '—';
          final duration = guest['durationMinutes']?.toString() ?? '—';
          final floor = guest['floor'] ?? '—';
          final date = guest['date'] ?? '—';

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: _T.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _T.border),
              boxShadow: const [
                BoxShadow(
                  color: _T.shadow,
                  blurRadius: 6,
                  offset: Offset(0, 2),
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
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _T.orangeLt,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.person_outline_rounded,
                          color: _T.orange,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: _T.text1,
                              ),
                            ),
                            Text(
                              floor,
                              style: const TextStyle(
                                fontSize: 12,
                                color: _T.text2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => onDelete(id, name),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: _T.redLt,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: _T.red.withOpacity(0.3)),
                          ),
                          child: const Text(
                            'Remove',
                            style: TextStyle(
                              color: _T.red,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: _T.border),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _InfoTile(
                        icon: Icons.people_outline_rounded,
                        label: 'Size',
                        value: size,
                      ),
                      const SizedBox(width: 12),
                      _InfoTile(
                        icon: Icons.phone_outlined,
                        label: 'Phone',
                        value: phone,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _InfoTile(
                        icon: Icons.timer_outlined,
                        label: 'Duration',
                        value: '$duration min',
                      ),
                      const SizedBox(width: 12),
                      _InfoTile(
                        icon: Icons.calendar_today_outlined,
                        label: 'Date',
                        value: date,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── BOOKINGS TAB ─────────────────────────────────────────────────────────────
class _BookingsTab extends StatelessWidget {
  final bool isLoading;
  final List<dynamic> bookings;
  final Function(int) onDelete;
  final VoidCallback onRefresh;

  const _BookingsTab({
    required this.isLoading,
    required this.bookings,
    required this.onDelete,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const _LoadingView();
    if (bookings.isEmpty) {
      return _EmptyView(
        icon: Icons.book_outlined,
        title: 'No Bookings',
        subtitle: 'No reservations have been made yet.',
        onRefresh: onRefresh,
      );
    }

    return RefreshIndicator(
      color: _T.primary,
      onRefresh: () async => onRefresh(),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        itemCount: bookings.length,
        itemBuilder: (_, i) {
          final b = bookings[i];
          final id = b['id'];
          final name = b['guestName'] ?? 'Guest';
          final table = b['tableCode'] ?? '—';
          final size = b['capacity']?.toString() ?? '—';
          final phone = b['phoneNumber'] ?? '—';
          final date = b['bookingDate'] ?? '—';
          final time = b['startTime'] ?? '—';
          final duration = b['durationMinutes']?.toString() ?? '—';

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: _T.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _T.border),
              boxShadow: const [
                BoxShadow(
                  color: _T.shadow,
                  blurRadius: 6,
                  offset: Offset(0, 2),
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
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _T.primaryLt,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.event_seat_rounded,
                          color: _T.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: _T.text1,
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 3),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _T.accentLt,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Table $table',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: _T.accent,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => onDelete(id),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: _T.redLt,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: _T.red.withOpacity(0.3)),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              color: _T.red,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: _T.border),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _InfoTile(
                        icon: Icons.people_outline_rounded,
                        label: 'Size',
                        value: size,
                      ),
                      const SizedBox(width: 12),
                      _InfoTile(
                        icon: Icons.phone_outlined,
                        label: 'Phone',
                        value: phone,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _InfoTile(
                        icon: Icons.calendar_today_outlined,
                        label: 'Date',
                        value: date,
                      ),
                      const SizedBox(width: 12),
                      _InfoTile(
                        icon: Icons.access_time_rounded,
                        label: 'Time',
                        value: time,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _InfoTile(
                    icon: Icons.timer_outlined,
                    label: 'Duration',
                    value: '$duration mins',
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Shared small widgets ─────────────────────────────────────────────────────

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 13, color: _T.text3),
          const SizedBox(width: 5),
          Flexible(
            child: RichText(
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: const TextStyle(
                      fontSize: 12,
                      color: _T.text2,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextSpan(
                    text: value,
                    style: const TextStyle(
                      fontSize: 12,
                      color: _T.text1,
                      fontWeight: FontWeight.w700,
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
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: _T.primary, strokeWidth: 2.5),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onRefresh;

  const _EmptyView({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: _T.primaryLt,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: _T.primary),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: _T.text1,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: _T.text2),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: onRefresh,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: _T.primaryLt,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _T.primary.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.refresh_rounded, color: _T.primary, size: 16),
                    SizedBox(width: 6),
                    Text(
                      'Refresh',
                      style: TextStyle(
                        color: _T.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
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
}
