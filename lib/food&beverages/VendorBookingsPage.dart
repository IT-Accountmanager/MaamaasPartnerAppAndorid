import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'BookTablePage.dart';
import 'add_floor_page.dart';
import 'add_waitlist_page.dart';

class VendorBookingsPage extends StatefulWidget {
  const VendorBookingsPage({super.key});

  @override
  State<VendorBookingsPage> createState() => _VendorBookingsPageState();
}

class _VendorBookingsPageState extends State<VendorBookingsPage> {
  void _showEditPopup(
    String floorName,
    List<dynamic> floorItems,
    int capacity,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            "Edit Floor: $floorName",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: floorItems.map((item) {
                final tableId = item['id'].toString();
                final code = item['code'] ?? '—';
                final status = item['seatingStatus'] ?? '—';

                return Card(
                  child: ListTile(
                    title: Text("Table: $code"),
                    subtitle: Text("Status: $status   |  Cap: $capacity"),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        // Print all available table IDs first
                        for (var floor in floorData) {
                          if (floor['tables'] != null) {
                            for (var table in floor['tables']) {
                              debugPrint("Available table ID: ${table['id']}");
                            }
                          }
                        }

                        final tableId = item['id']; // The ID you want to delete
                        final tableCode = item['code'] ?? '—'; // Add this line
                        debugPrint(
                          "🟢 Attempting to delete table with ID: $tableId",
                        );

                        _deleteTable(
                          tableId,
                          tableCode,
                        ); // Pass both id and code
                      },
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  bool isLoading = true;
  List<dynamic> floorData = [];

  @override
  void initState() {
    super.initState();
    _fetchFloorData();
    _fetchWaitingList(); // fetch waitlist
    _fetchVendorBookings(); // <--- ADD THIS
  }

  List<dynamic> waitingList = [];
  bool isWaitingLoading = true;

  List<dynamic> vendorBookings = [];
  bool isBookingsLoading = true;

  Future<void> _fetchWaitingList() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final vendorId = prefs.getInt('vendorId') ?? 1;
      final token = prefs.getString('token') ?? '';

      final url = Uri.parse(
        "http://staging.maamaas.com:8080/food/api/seatingdetails/waiting/vendor/$vendorId",
      );

      debugPrint("🔗 Fetching waiting list: $url");

      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      debugPrint("📡 Status: ${response.statusCode}");
      debugPrint("📦 Response: ${response.body}");

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        setState(() {
          waitingList = decoded is List ? decoded : [];
          isWaitingLoading = false;
        });
      } else {
        setState(() => isWaitingLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "❌ Failed to fetch waiting list: ${response.statusCode}",
            ),
          ),
        );
      }
    } catch (e) {
      setState(() => isWaitingLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("⚠️ Error fetching waiting list: $e")),
      );
    }
  }

  Future<void> _deleteWaitingGuest(dynamic id, String name) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final url = Uri.parse(
        "http://staging.maamaas.com:8080/food/api/seatingdetails/delete/waiting-list/$id",
      );

      final response = await http.delete(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        setState(() {
          waitingList.removeWhere((guest) => guest['id'] == id);
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Deleted $name successfully")));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("❌ Failed to delete $name: ${response.statusCode}"),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("⚠️ Error deleting $name: $e")));
    }
  }

  Future<void> _fetchFloorData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final vendorId = prefs.getInt('vendorId') ?? 1;
      final token = prefs.getString('token') ?? '';

      final url = Uri.parse(
        "http://staging.maamaas.com:8080/food/api/seating/all/vendor/$vendorId",
      );

      debugPrint("🔗 Fetching floors: $url");

      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      debugPrint("📡 Status: ${response.statusCode}");
      debugPrint("📦 Response: ${response.body}");

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        List<dynamic> floors = [];
        if (decoded is List) {
          floors = decoded;
        } else if (decoded is Map && decoded['floors'] is List) {
          floors = decoded['floors'];
        }

        setState(() {
          floorData = floors;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("❌ Failed to fetch data: ${response.statusCode}"),
          ),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("⚠️ Error: $e")));
    }
  }

  Future<void> _deleteTable(int id, String tableCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      // 1️⃣ Delete all seating_details that reference this table
      final detailsUrl = Uri.parse(
        "http://staging.maamaas.com:8080/food/api/seating-details/by-seating/$id",
      );

      final detailsResponse = await http.get(
        detailsUrl,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (detailsResponse.statusCode == 200) {
        final detailsList = jsonDecode(detailsResponse.body) as List<dynamic>;

        for (var detail in detailsList) {
          final detailId = detail['id'];
          final deleteDetailUrl = Uri.parse(
            "http://staging.maamaas.com:8080/food/api/seating-details/delete/$detailId",
          );

          final resp = await http.delete(
            deleteDetailUrl,
            headers: {
              "Authorization": "Bearer $token",
              "Content-Type": "application/json",
            },
          );

          debugPrint("Deleted seating_detail $detailId: ${resp.statusCode}");
        }
      }

      // 2️⃣ Now delete the seating table itself
      final url = Uri.parse(
        "http://staging.maamaas.com:8080/food/api/seating/delete/$id",
      );

      final response = await http.delete(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        setState(() {
          floorData = floorData.map((floor) {
            if (floor['tables'] != null) {
              return {
                ...floor,
                'tables': List.from(floor['tables'])
                  ..removeWhere((item) => item['id'] == id),
              };
            }
            return floor;
          }).toList();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Table $tableCode deleted successfully")),
        );
      } else {
        final body = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "❌ Failed: ${body['message'] ?? response.statusCode}",
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("⚠️ Error deleting $tableCode: $e")),
      );
    }
  }

  Future<void> _fetchVendorBookings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final vendorId = prefs.getInt('vendorId') ?? 1;
      final token = prefs.getString('token') ?? '';

      final url = Uri.parse(
        "http://staging.maamaas.com:8080/food/api/seatingdetails/vendor/$vendorId/vendor-bookings",
      );

      debugPrint("🔗 Fetching vendor bookings: $url");

      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      debugPrint("📡 Status: ${response.statusCode}");
      debugPrint("📦 Body: ${response.body}");

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        setState(() {
          vendorBookings = decoded is List ? decoded : [];
          isBookingsLoading = false;
        });
      } else {
        setState(() => isBookingsLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("❌ Failed to fetch bookings: ${response.statusCode}"),
          ),
        );
      }
    } catch (e) {
      setState(() => isBookingsLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("⚠️ Error fetching bookings: $e")));
    }
  }

  Future<void> _deleteBooking(int id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final url = Uri.parse(
        "http://staging.maamaas.com:8080/food/api/seatingdetails/seatingdetails/$id",
      );

      debugPrint("🗑 Deleting booking: $url");

      final response = await http.delete(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      debugPrint("📡 DELETE Status: ${response.statusCode}");
      debugPrint("📦 DELETE Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 204) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✔ Booking deleted successfully")),
        );

        // Refresh the list
        _fetchVendorBookings();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Failed to delete: ${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("⚠ Error: $e")));
    }
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.deepPurple,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _pickTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  Widget _infoChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.deepPurple,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Map<String, List<dynamic>> groupedFloors = {};
    for (var item in floorData) {
      final floorName = item['name'] ?? 'Unnamed Floor';
      if (!groupedFloors.containsKey(floorName)) {
        groupedFloors[floorName] = [];
      }
      groupedFloors[floorName]!.add(item);
    }

    return Scaffold(
      backgroundColor: Colors.deepPurple.shade50,
      appBar: AppBar(
        title: const Text(
          "Vendor Bookings",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.purple,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                // Date & Time Selector - Commented out as per your code
                // Card(...),
                const SizedBox(height: 25),

                // Floor / Add Floor / Waitlist Buttons - ALWAYS VISIBLE
                Row(
                  children: [
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AddFloorPage(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(
                          Icons.add_home_work,
                          color: Colors.white,
                        ),
                        label: const Text(
                          "Add Floor",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AddWaitlistPage(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.list_alt, color: Colors.white),
                        label: const Text(
                          "Waitlist",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // Floors List - Only show if data exists
                if (floorData.isNotEmpty) ...[
                  const Text(
                    "🏢 Floors List",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 16),

                  ...groupedFloors.entries.map((entry) {
                    final floorName = entry.key;
                    final floorItems = entry.value;
                    final totalCapacity =
                        int.tryParse(
                          floorItems.first['capacity']?.toString() ?? '0',
                        ) ??
                        0;
                    final totalTables = floorItems.length;
                    final availableTables = floorItems.where((item) {
                      final status =
                          item['seatingStatus']?.toString().toLowerCase() ?? '';
                      return status == 'available';
                    }).length;

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 4,
                      shadowColor: Colors.deepPurple.withOpacity(0.3),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "🏢 $floorName",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepPurple,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.deepPurple,
                                  ),
                                  onPressed: () {
                                    _showEditPopup(
                                      floorName,
                                      floorItems,
                                      totalCapacity,
                                    );
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _infoChip("Capacity", totalCapacity.toString()),
                                _infoChip(
                                  "Total Tables",
                                  totalTables.toString(),
                                ),
                                _infoChip(
                                  "Available",
                                  availableTables.toString(),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 6,
                                    horizontal: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.deepPurple.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    "🪑 Tables Status & Actions",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.deepPurple,
                                    ),
                                  ),
                                ),
                                ...floorItems.map((table) {
                                  final code = table['code'] ?? '---';
                                  final seatingId = table['id'];

                                  if (seatingId == null) {
                                    debugPrint(
                                      "❌ seatingId NULL for table: $table",
                                    );
                                    return Container();
                                  }

                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => BookTablePage(
                                            floorName: floorName,
                                            tableCode: code,
                                            capacity: totalCapacity,
                                            seatingId: seatingId,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 6,
                                        horizontal: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade100,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: Colors.green.shade300,
                                        ),
                                      ),
                                      child: Text(
                                        code,
                                        style: const TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),

                  const SizedBox(height: 40),
                ] else ...[
                  // Show message when no floor data exists
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: Text(
                        "No floors found for this vendor.",
                        style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                      ),
                    ),
                  ),
                ],

                // ------------------ Waiting List ------------------
                const SizedBox(height: 40),
                const Text(
                  "📝 Waiting List",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 16),

                isWaitingLoading
                    ? const Center(child: CircularProgressIndicator())
                    : waitingList.isEmpty
                    ? Center(
                        child: Text(
                          "No waiting guests.",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                        ),
                      )
                    : Column(
                        children: waitingList.map<Widget>((guest) {
                          final id = guest['id'];
                          final name = guest['guestName'];
                          final size = guest['capacity'].toString();
                          final phone = guest['phoneNumber'];
                          final duration = guest['durationMinutes'].toString();
                          final floor = guest['floor'];
                          final date = guest['date'];

                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "$name ($floor)",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.deepPurple,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Size: $size"),
                                      Text("Phone: $phone"),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Duration: $duration min"),
                                      Text("Date: $date"),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  ElevatedButton(
                                    onPressed: () async {
                                      await _deleteWaitingGuest(id, name);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.deepPurple,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                        horizontal: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text(
                                      "Remove",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                // ------------------ Vendor Bookings ------------------
                const SizedBox(height: 40),
                const Text(
                  "📘 Vendor Bookings",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 16),

                isBookingsLoading
                    ? const Center(child: CircularProgressIndicator())
                    : vendorBookings.isEmpty
                    ? Center(
                        child: Text(
                          "No bookings available.",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : Column(
                        children: vendorBookings.map<Widget>((booking) {
                          final id = booking['id'];
                          final name = booking['guestName'];
                          final table = booking['tableCode'];
                          final size = booking['capacity'];
                          final phone = booking['phoneNumber'] ?? "N/A";
                          final date = booking['bookingDate'] ?? "N/A";
                          final time = booking['startTime'] ?? "N/A";
                          final duration = booking['durationMinutes'] ?? "N/A";

                          return SizedBox(
                            width: double.infinity,
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              margin: const EdgeInsets.only(bottom: 12),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "$name - Table $table",
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.deepPurple,
                                          ),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            _deleteBooking(id);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 14,
                                              vertical: 8,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: const Text(
                                            "Remove",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text("Size: $size"),
                                    Text("Phone: $phone"),
                                    Text("Date: $date"),
                                    Text("Time: $time"),
                                    Text("Duration: $duration mins"),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
              ],
            ),
    );
  }
}
