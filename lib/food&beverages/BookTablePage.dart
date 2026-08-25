import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookTablePage extends StatefulWidget {
  final String floorName;
  final String tableCode;
  final int capacity;
  final int seatingId;

  const BookTablePage({
    super.key,
    required this.floorName,
    required this.tableCode,
    required this.capacity,
    required this.seatingId,
  });

  @override
  State<BookTablePage> createState() => _BookTablePageState();
}

class _BookTablePageState extends State<BookTablePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _durationController = TextEditingController(
    text: "90",
  );
  final TextEditingController _notesController = TextEditingController();

  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  // =======================
  // PICK DATE
  // =======================
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  // =======================
  // PICK TIME
  // =======================
  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null) setState(() => selectedTime = picked);
  }

  // =======================
  // SUBMIT BOOKING
  // =======================
  Future<void> _submitBooking() async {
    // debugPrint("🔹 Submit booking called");

    if (!_formKey.currentState!.validate()) return;
    // debugPrint("✅ Form validation passed");

    final prefs = await SharedPreferences.getInstance();
    final vendorId = prefs.getInt('vendorId') ?? 0;
    final token = prefs.getString('token') ?? "";

    if (vendorId == 0) {
      // debugPrint("❌ vendorId missing");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Vendor ID missing")));
      return;
    }

    if (widget.seatingId == 0) {
      // debugPrint("❌ seatingId missing");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Invalid seating ID")));
      return;
    }

    final url = Uri.parse(
      "http://staging.maamaas.com:8080/food/api/seatingdetails/vendor/$vendorId",
    );
    // debugPrint("🌐 API URL: $url");

    // Build selected DateTime
    DateTime selectedDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    // Prevent past booking: auto-adjust if selected in past
    if (selectedDateTime.isBefore(DateTime.now())) {
      selectedDateTime = DateTime.now().add(Duration(minutes: 5));
      selectedDate = selectedDateTime;
      selectedTime = TimeOfDay(
        hour: selectedDateTime.hour,
        minute: selectedDateTime.minute,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("⚠ Booking time updated to future")),
      );
    }

    // Format start time as string
    final startTimeStr =
        "${selectedTime.hour.toString().padLeft(2, "0")}:${selectedTime.minute.toString().padLeft(2, "0")}:00";

    // Build full booking request
    final bookingRequest = {
      "id": 0,
      "userId": 0,
      "guestName": _nameController.text.trim(),
      "phoneNumber": _phoneController.text.trim(),
      "bookingDate": DateFormat('yyyy-MM-dd').format(selectedDate),
      "startTime": startTimeStr,
      "durationMinutes": int.tryParse(_durationController.text.trim()) ?? 90,
      "arrivalStatus": "NOT_ARRIVED",
      "types": "BOOK_NOW",
      "capacity": widget.capacity,
      "seating": {
        "id": widget.seatingId,
        "name": widget.tableCode,

        "seatingStatus": "Available",
        "code": widget.tableCode,
        "capacity": widget.capacity,
        "description": "",
        "remarks": "",
        "cleanTime": "00:00:00",
        "manuallyUpdated": false,
      },
      "seatingId": widget.seatingId,
      "vendorId": vendorId,
      "code": widget.tableCode,
      "notes": _notesController.text.trim(),
    };

    // debugPrint("📤 FINAL REQUEST JSON:\n${jsonEncode(bookingRequest)}");

    try {
      final response = await http.post(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode(bookingRequest),
      );

      // debugPrint("📡 Status: ${response.statusCode}");
      // debugPrint("📦 Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("✔ Table booked successfully")));
        Navigator.pop(context, true);
      } else {
        String message = "Unknown error";
        try {
          final body = jsonDecode(response.body);
          message = body["message"] ?? "Booking failed";
        } catch (e) {}

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("❌ Failed: $message")));
      }
    } catch (e) {
      // debugPrint("⚠ Error submitting booking: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("⚠ Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Book Table (${widget.tableCode})"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                "Book Table (Capacity: ${widget.capacity})",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.deepPurple,
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Table Code: ${widget.tableCode} • Floor: ${widget.floorName}",
              ),
              SizedBox(height: 20),

              // NAME
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "Guest Name *",
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? "Enter guest name" : null,
              ),

              SizedBox(height: 12),

              // PHONE
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: "Phone (optional)",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),

              SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: Icon(Icons.calendar_today),
                      label: Text(
                        DateFormat('dd-MM-yyyy').format(selectedDate),
                      ),
                      onPressed: _pickDate,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: Icon(Icons.access_time),
                      label: Text(selectedTime.format(context)),
                      onPressed: _pickTime,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 12),

              // DURATION
              TextFormField(
                controller: _durationController,
                decoration: InputDecoration(
                  labelText: "Duration (minutes) *",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (v) =>
                    v == null || v.isEmpty ? "Enter duration" : null,
              ),

              SizedBox(height: 12),

              // NOTES
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: "Notes",
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),

              SizedBox(height: 20),

              ElevatedButton(
                onPressed: _submitBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
                child: Text(
                  "Confirm Booking",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
