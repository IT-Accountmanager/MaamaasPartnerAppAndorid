// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../Models/food&beverages/booking_model.dart';
//
// class UserBookingsPage extends StatefulWidget {
//   const UserBookingsPage({super.key});
//
//   @override
//   State<UserBookingsPage> createState() => _UserBookingsPageState();
// }
//
// class _UserBookingsPageState extends State<UserBookingsPage> {
//   bool isLoading = true;
//   List<Booking> bookings = [];
//
//   @override
//   void initState() {
//     super.initState();
//     fetchUserBookings();
//   }
//
//   Future<void> fetchUserBookings() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final vendorId = prefs.getInt('vendorId') ?? 1;
//       final token = prefs.getString('token') ?? '';
//
//       final url =
//           "http://staging.maamaas.com:8080/food/api/seatingdetails/isBooked/user/$vendorId";
//
//       debugPrint("📡 Fetching User Bookings from: $url");
//
//       final response = await http.get(
//         Uri.parse(url),
//         headers: {
//           "Content-Type": "application/json",
//           "Authorization": "Bearer $token",
//         },
//       );
//
//       debugPrint("✅ STATUS CODE: ${response.statusCode}");
//
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         debugPrint("🧩 Booking data: $data");
//
//         List<dynamic> rawList = data is List ? data : [data];
//
//         setState(() {
//           bookings = rawList.map((e) => Booking.fromJson(e)).toList();
//           isLoading = false;
//         });
//       } else {
//         setState(() => isLoading = false);
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("❌ Failed: ${response.statusCode}")),
//         );
//       }
//     } catch (e) {
//       setState(() => isLoading = false);
//       debugPrint("🔥 ERROR: $e");
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
//     }
//   }
//
//   Widget _buildBookingCard(Booking booking) {
//     return Card(
//       elevation: 3,
//       margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Expanded(
//                   child: Text(
//                     "Guest Name: ${booking.guestName}",
//                     style: const TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.deepPurple,
//                     ),
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//                 const Icon(Icons.person, color: Colors.deepPurple),
//               ],
//             ),
//             const SizedBox(height: 8),
//             _buildDetailRow(Icons.phone, "Phone", booking.phone),
//             _buildDetailRow(Icons.calendar_today, "Date", booking.date),
//             _buildDetailRow(Icons.access_time, "Time", booking.time),
//             _buildDetailRow(Icons.timer, "Duration", booking.duration),
//             _buildDetailRow(Icons.layers, "Floor", booking.floor),
//             _buildDetailRow(Icons.table_bar, "Table", booking.table),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildDetailRow(IconData icon, String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 3),
//       child: Row(
//         children: [
//           Icon(icon, size: 18, color: Colors.grey[600]),
//           const SizedBox(width: 8),
//           Text("$label: ", style: const TextStyle(fontWeight: FontWeight.w600)),
//           Expanded(
//             child: Text(
//               value,
//               style: const TextStyle(color: Colors.black54),
//               overflow: TextOverflow.ellipsis,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("User Bookings"),
//         backgroundColor: Colors.deepPurple,
//       ),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : bookings.isEmpty
//           ? const Center(
//               child: Text(
//                 "No bookings found.",
//                 style: TextStyle(fontSize: 16, color: Colors.grey),
//               ),
//             )
//           : RefreshIndicator(
//               onRefresh: fetchUserBookings,
//               child: ListView.builder(
//                 itemCount: bookings.length,
//                 itemBuilder: (context, index) {
//                   return _buildBookingCard(bookings[index]);
//                 },
//               ),
//             ),
//     );
//   }
// }
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../Models/food&beverages/booking_model.dart';
import '../Models/food&beverages/waiter_booking_model.dart';
import 'Waitermenu.dart';

// ─── Design Tokens ────────────────────────────────────────────────────────────
class _T {
  static const bg         = Color(0xFFF4F0FB);
  static const surface    = Color(0xFFFFFFFF);
  static const surfaceAlt = Color(0xFFF9F7FD);
  static const primary    = Color(0xFF5B21B6);
  static const primaryLt  = Color(0xFFEDE9FE);
  static const accent     = Color(0xFFF59E0B);
  static const accentLt   = Color(0xFFFEF3C7);
  static const green      = Color(0xFF059669);
  static const greenLt    = Color(0xFFD1FAE5);
  static const orange     = Color(0xFFEA580C);
  static const orangeLt   = Color(0xFFFFEDD5);
  static const red        = Color(0xFFDC2626);
  static const redLt      = Color(0xFFFEE2E2);
  static const teal       = Color(0xFF0D9488);
  static const tealLt     = Color(0xFFCCFBF1);
  static const text1      = Color(0xFF1E1B4B);
  static const text2      = Color(0xFF6B7280);
  static const text3      = Color(0xFFB0B3C1);
  static const border     = Color(0xFFE8E4F3);
  static const shadow     = Color(0x12000000);
}

// ─── Token helper ─────────────────────────────────────────────────────────────
Future<String?> _getToken() async {
  final p = await SharedPreferences.getInstance();
  for (final k in [
    'token', 'authToken', 'accessToken',
    'jwtToken', 'bearerToken', 'userToken',
  ]) {
    final v = p.get(k);
    if (v != null) return v.toString();
  }
  return null;
}

Future<int> _getVendorId() async {
  final p = await SharedPreferences.getInstance();
  return p.getInt('vendorId') ?? p.getInt('VendorId') ?? 1;
}

// ═══════════════════════════════════════════════════════════════════════════════
// USER BOOKINGS PAGE
// ═══════════════════════════════════════════════════════════════════════════════
class UserBookingsPage extends StatefulWidget {
  const UserBookingsPage({super.key});

  @override
  State<UserBookingsPage> createState() => _UserBookingsPageState();
}

class _UserBookingsPageState extends State<UserBookingsPage> {
  bool isLoading = true;
  List<Booking> bookings = [];

  @override
  void initState() {
    super.initState();
    fetchUserBookings();
  }

  Future<void> fetchUserBookings() async {
    setState(() => isLoading = true);
    try {
      final token    = await _getToken();
      final vendorId = await _getVendorId();

      final response = await http.get(
        Uri.parse(
          'http://staging.maamaas.com:8080/food/api/seatingdetails/isBooked/user/$vendorId',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data    = json.decode(response.body);
        final rawList = data is List ? data : [data];
        setState(() {
          bookings  = rawList.map((e) => Booking.fromJson(e)).toList();
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        _snack('Failed: ${response.statusCode}', _T.red);
      }
    } catch (e) {
      setState(() => isLoading = false);
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

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: _T.bg,
        body: SafeArea(
          child: Column(
            children: [
              // ── Header ──────────────────────────────────────────────────
              _PageHeader(
                title: 'User Bookings',
                subtitle: 'Customer table reservations',
                icon: Icons.person_pin_rounded,
                iconColor: _T.green,
                iconBg: _T.greenLt,
                onBack: () => Navigator.pop(context),
              ),

              // ── Body ────────────────────────────────────────────────────
              Expanded(
                child: isLoading
                    ? const _LoadingView()
                    : bookings.isEmpty
                    ? _EmptyView(
                  icon: Icons.event_seat_outlined,
                  title: 'No Bookings Yet',
                  subtitle:
                  'Customer bookings will appear here once made.',
                  onRefresh: fetchUserBookings,
                )
                    : RefreshIndicator(
                  color: _T.primary,
                  onRefresh: fetchUserBookings,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      16, 16, 16, 24,
                    ),
                    itemCount: bookings.length,
                    itemBuilder: (_, i) =>
                        _UserBookingCard(booking: bookings[i]),
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

// ─── User booking card ────────────────────────────────────────────────────────
class _UserBookingCard extends StatelessWidget {
  final Booking booking;
  const _UserBookingCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _T.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _T.border),
        boxShadow: const [
          BoxShadow(color: _T.shadow, blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Card header ────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            decoration: BoxDecoration(
              color: _T.greenLt,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _T.green.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: _T.green,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    booking.guestName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: _T.text1,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _T.green.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    booking.table,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: _T.green,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Card body ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    _DetailTile(
                      icon: Icons.phone_outlined,
                      label: 'Phone',
                      value: booking.phone,
                      color: _T.primary,
                    ),
                    const SizedBox(width: 10),
                    _DetailTile(
                      icon: Icons.layers_rounded,
                      label: 'Floor',
                      value: booking.floor,
                      color: _T.orange,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _DetailTile(
                      icon: Icons.calendar_today_rounded,
                      label: 'Date',
                      value: booking.date,
                      color: _T.teal,
                    ),
                    const SizedBox(width: 10),
                    _DetailTile(
                      icon: Icons.access_time_rounded,
                      label: 'Time',
                      value: booking.time,
                      color: _T.accent,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _DetailTile(
                  icon: Icons.timer_outlined,
                  label: 'Duration',
                  value: booking.duration,
                  color: _T.green,
                  fullWidth: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// WAITER BOOKINGS PAGE
// ═══════════════════════════════════════════════════════════════════════════════
class WaiterBookingsPage extends StatefulWidget {
  const WaiterBookingsPage({super.key});

  @override
  State<WaiterBookingsPage> createState() => _WaiterBookingsPageState();
}

class _WaiterBookingsPageState extends State<WaiterBookingsPage> {
  bool isLoading = true;
  List<WaiterBooking> bookings = [];

  @override
  void initState() {
    super.initState();
    fetchWaiterBookings();
  }

  Future<void> fetchWaiterBookings() async {
    setState(() => isLoading = true);
    try {
      final token    = await _getToken();
      final vendorId = await _getVendorId();

      final response = await http.get(
        Uri.parse(
          'http://staging.maamaas.com:8080/food/api/seatingdetails/vendor/$vendorId/vendor-bookings',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data    = json.decode(response.body);
        final rawList = data is List ? data : [data];
        setState(() {
          bookings  = rawList.map((e) => WaiterBooking.fromJson(e)).toList();
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        _snack('Failed: ${response.statusCode}', _T.red);
      }
    } catch (e) {
      setState(() => isLoading = false);
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

  Future<void> _onAddItems(WaiterBooking booking) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('seatingId', booking.seatingId ?? 0);
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Menu_Waiter(booking: booking),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: _T.bg,
        body: SafeArea(
          child: Column(
            children: [
              // ── Header ──────────────────────────────────────────────────
              _PageHeader(
                title: 'Waiter Bookings',
                subtitle: '',
                icon: Icons.room_service_rounded,
                iconColor: _T.orange,
                iconBg: _T.orangeLt,
                onBack: () => Navigator.pop(context),
              ),

              // ── Body ────────────────────────────────────────────────────
              Expanded(
                child: isLoading
                    ? const _LoadingView()
                    : bookings.isEmpty
                    ? _EmptyView(
                  icon: Icons.room_service_outlined,
                  title: 'No Waiter Bookings',
                  subtitle: 'Waiter bookings will appear here.',
                  onRefresh: fetchWaiterBookings,
                )
                    : RefreshIndicator(
                  color: _T.primary,
                  onRefresh: fetchWaiterBookings,
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      16, 16, 16, 24,
                    ),
                    itemCount: bookings.length,
                    itemBuilder: (_, i) => _WaiterBookingCard(
                      booking: bookings[i],
                      index: i,
                      onAddItems: () => _onAddItems(bookings[i]),
                    ),
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

// ─── Waiter booking card ──────────────────────────────────────────────────────
class _WaiterBookingCard extends StatelessWidget {
  final WaiterBooking booking;
  final int index;
  final VoidCallback onAddItems;

  const _WaiterBookingCard({
    required this.booking,
    required this.index,
    required this.onAddItems,
  });

  Color get _arrivalColor {
    final s = booking.arrivalStatus.toLowerCase();
    if (s.contains('arrived') || s.contains('present')) return _T.green;
    if (s.contains('pending') || s.contains('waiting')) return _T.accent;
    return _T.text2;
  }

  Color get _arrivalBg {
    final s = booking.arrivalStatus.toLowerCase();
    if (s.contains('arrived') || s.contains('present')) return _T.greenLt;
    if (s.contains('pending') || s.contains('waiting')) return _T.accentLt;
    return _T.surfaceAlt;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: _T.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _T.border),
        boxShadow: const [
          BoxShadow(color: _T.shadow, blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Card header ────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
            decoration: BoxDecoration(
              color: _T.orangeLt,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: _T.orange.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: _T.orange,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.guestName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: _T.text1,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _T.primaryLt,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Table ${booking.tableNumber}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: _T.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _arrivalBg,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              booking.arrivalStatus,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: _arrivalColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: _T.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.receipt_long_rounded,
                    color: _T.orange,
                    size: 17,
                  ),
                ),
              ],
            ),
          ),

          // ── Card body ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    _DetailTile(
                      icon: Icons.calendar_today_rounded,
                      label: 'Date',
                      value: booking.bookingDate,
                      color: _T.teal,
                    ),
                    const SizedBox(width: 10),
                    _DetailTile(
                      icon: Icons.access_time_rounded,
                      label: 'Time',
                      value: booking.time,
                      color: _T.accent,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _DetailTile(
                      icon: Icons.people_outline_rounded,
                      label: 'Capacity',
                      value: booking.capacity.toString(),
                      color: _T.primary,
                    ),
                    const SizedBox(width: 10),
                    _DetailTile(
                      icon: Icons.phone_outlined,
                      label: 'Phone',
                      value: booking.phoneNumber,
                      color: _T.green,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _DetailTile(
                  icon: Icons.event_seat_rounded,
                  label: 'Seating ID',
                  value: booking.seatingId?.toString() ?? '—',
                  color: _T.orange,
                  fullWidth: true,
                ),
                const SizedBox(height: 14),
                const Divider(height: 1, color: _T.border),
                const SizedBox(height: 14),

                // ── Add items button ─────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  child: GestureDetector(
                    onTap: onAddItems,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4C1D95), Color(0xFF7C3AED)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: _T.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.add_circle_outline_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Add Items',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
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

// ═══════════════════════════════════════════════════════════════════════════════
// SHARED WIDGETS
// ═══════════════════════════════════════════════════════════════════════════════

// ─── Page header ──────────────────────────────────────────────────────────────
class _PageHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final VoidCallback onBack;

  const _PageHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _T.surface,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(
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
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: _T.text1,
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: _T.text2,
                    fontWeight: FontWeight.w500,
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

// ─── Detail tile ──────────────────────────────────────────────────────────────
class _DetailTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool fullWidth;

  const _DetailTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.fullWidth = false,
  });

  Widget _content() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
    decoration: BoxDecoration(
      color: color.withOpacity(0.06),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: color.withOpacity(0.15)),
    ),
    child: Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Flexible(
          child: RichText(
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$label: ',
                  style: TextStyle(
                    fontSize: 11,
                    color: color.withOpacity(0.7),
                    fontWeight: FontWeight.w600,
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

  @override
  Widget build(BuildContext context) {
    if (fullWidth) return _content();
    return Expanded(child: _content());
  }
}

// ─── Loading view ─────────────────────────────────────────────────────────────
class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) => const Center(
    child: CircularProgressIndicator(color: _T.primary, strokeWidth: 2.5),
  );
}

// ─── Empty view ───────────────────────────────────────────────────────────────
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
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
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