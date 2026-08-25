import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../Models/food&beverages/waiter_booking_model.dart';
import 'Waitermenu.dart';

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
    try {
      final prefs = await SharedPreferences.getInstance();
      final vendorId = prefs.getInt('vendorId') ?? 1;
      final token = prefs.getString('token') ?? '';

      final url =
          "http://staging.maamaas.com:8080/food/api/seatingdetails/vendor/$vendorId/vendor-bookings";

      debugPrint("📡 Fetching Waiter Bookings from: $url");

      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> rawList = data is List ? data : [data];

        setState(() {
          bookings = rawList.map((e) => WaiterBooking.fromJson(e)).toList();
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Failed: ${response.statusCode}")),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
    }
  }

  Widget _buildBookingCard(WaiterBooking booking, int index) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 400 + (index * 100)),
      curve: Curves.easeOutCubic,
      child: Card(
        elevation: 5,
        shadowColor: Colors.deepPurple.withOpacity(0.3),
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple.shade50, Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      "👤 Guest Name: ${booking.guestName}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(
                    Icons.receipt_long_rounded,
                    color: Colors.deepPurple,
                    size: 26,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(thickness: 1, color: Colors.deepPurpleAccent),
              const SizedBox(height: 8),

              _buildDetailRow(
                Icons.calendar_today,
                "Booking Date",
                booking.bookingDate,
              ),
              _buildDetailRow(Icons.access_time, "Time", booking.time),
              _buildDetailRow(
                Icons.table_bar,
                "Table Number",
                booking.tableNumber,
              ),
              _buildDetailRow(
                Icons.people,
                "Capacity",
                booking.capacity.toString(),
              ),
              _buildDetailRow(
                Icons.verified,
                "Arrival Status",
                booking.arrivalStatus,
              ),
              _buildDetailRow(Icons.phone, "Phone Number", booking.phoneNumber),
              _buildDetailRow(
                Icons.event_seat,
                "Seating ID",
                booking.seatingId.toString(),
              ),

              const SizedBox(height: 12),
              const Divider(thickness: 1, color: Colors.deepPurpleAccent),
              const SizedBox(height: 10),

              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                  onPressed: () async {
                    // Store seatingId and get vendorId from prefs
                    final prefs = await SharedPreferences.getInstance();
                    final vendorId = prefs.getInt('vendorId') ?? 1;
                    await prefs.setInt('seatingId', booking.seatingId ?? 0);

                    debugPrint("✅ Stored seatingId: ${booking.seatingId}");
                    debugPrint("✅ Using vendorId from prefs: $vendorId");

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Menu_Waiter(booking: booking),
                      ),
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Add items for ${booking.guestName} (Table: ${booking.tableNumber})",
                        ),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.add_circle_outline,
                    color: Colors.white,
                  ),
                  label: const Text(
                    "Add Items",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
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

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.deepPurple.shade300),
          const SizedBox(width: 10),
          Text(
            "$label: ",
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
              fontSize: 15,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 15, color: Colors.grey[700]),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade100.withOpacity(0.1),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        title: const Text(
          "Waiter Bookings",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.deepPurple),
            )
          : bookings.isEmpty
          ? const Center(
              child: Text(
                "No waiter bookings found.",
                style: TextStyle(
                  fontSize: 17,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          : RefreshIndicator(
              color: Colors.deepPurple,
              onRefresh: fetchWaiterBookings,
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: bookings.length,
                itemBuilder: (context, index) {
                  return _buildBookingCard(bookings[index], index);
                },
              ),
            ),
    );
  }
}
