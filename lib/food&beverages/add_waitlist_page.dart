import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddWaitlistPage extends StatefulWidget {
  const AddWaitlistPage({super.key});

  @override
  State<AddWaitlistPage> createState() => _AddWaitlistPageState();
}

class _AddWaitlistPageState extends State<AddWaitlistPage> {
  final _formKey = GlobalKey<FormState>();

  String? selectedFloor;
  final TextEditingController _guestNameController = TextEditingController();
  final TextEditingController _partySizeController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();

  DateTime? selectedDate;

  // Example static floors (replace with API later)
  List<String> floorOptions = [];
  bool isLoadingFloors = true;

  @override
  void initState() {
    super.initState();
    _fetchFloors(); // fetch floors from API
  }

  Future<void> _fetchFloors() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final vendorId = prefs.getInt('vendorId') ?? 1;
      final token = prefs.getString('token') ?? '';

      final url = Uri.parse(
        "http://staging.maamaas.com:8080/food/api/seating/all/vendor/$vendorId",
      );

      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        List<String> floors = [];

        if (decoded is List) {
          floors = decoded.map<String>((f) => f['name'].toString()).toList();
        } else if (decoded is Map && decoded['floors'] is List) {
          floors = (decoded['floors'] as List)
              .map<String>((f) => f['name'].toString())
              .toList();
        }

        // Remove duplicates
        floors = floors.toSet().toList();

        setState(() {
          floorOptions = floors;
          isLoadingFloors = false;
        });
      } else {
        setState(() => isLoadingFloors = false);
      }
    } catch (e) {
      setState(() => isLoadingFloors = false);
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return; // Stop if form is invalid
    }
    if (selectedDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("❌ Please select a date")));
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final vendorId = prefs.getInt('vendorId') ?? 1;
      final token = prefs.getString('token') ?? '';

      final url = Uri.parse(
        "http://staging.maamaas.com:8080/food/api/seatingdetails/waiting-list/addBy/$vendorId",
      );

      // Prepare POST body
      final body = {
        "floorName": selectedFloor ?? "",
        "guestName": _guestNameController.text,
        "capacity":
            int.tryParse(_partySizeController.text) ??
            1, // mapped from partySize
        "phoneNumber": _phoneController.text.isEmpty
            ? "N/A"
            : _phoneController.text,
        "bookingDate": DateFormat('yyyy-MM-dd').format(selectedDate!),
        "durationMinutes": int.tryParse(_durationController.text) ?? 60,
      };

      final response = await http.post(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ Guest added to waitlist successfully!"),
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Failed to add guest: ${response.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ Error: $e")));
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

  @override
  Widget build(BuildContext context) {
    final dateText = selectedDate != null
        ? DateFormat('dd-MM-yyyy').format(selectedDate!)
        : "Select Date";

    return Scaffold(
      backgroundColor: Colors.deepPurple.shade50,
      appBar: AppBar(
        title: const Text(
          "Add Guest to Waitlist",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🌟 Floor dropdown
              const Text(
                "Floor:*",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: selectedFloor,
                items: isLoadingFloors
                    ? [
                        const DropdownMenuItem(
                          child: Text("Loading floors..."),
                          value: null,
                        ),
                      ]
                    : floorOptions
                          .map(
                            (floor) => DropdownMenuItem(
                              value: floor,
                              child: Text(floor),
                            ),
                          )
                          .toList(),
                onChanged: (value) => setState(() => selectedFloor = value),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Select Floor",
                ),
                validator: (value) =>
                    value == null ? "Please select a floor" : null,
              ),
              const SizedBox(height: 20),

              // 🌟 Guest Name
              const Text(
                "Guest Name:*",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _guestNameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Enter guest name",
                ),
                validator: (value) =>
                    value!.isEmpty ? "Please enter guest name" : null,
              ),

              const SizedBox(height: 20),

              // 🌟 Party Size
              const Text(
                "Party Size:*",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _partySizeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Enter party size (e.g., 4)",
                ),
                validator: (value) =>
                    value!.isEmpty ? "Please enter party size" : null,
              ),

              const SizedBox(height: 20),

              // 🌟 Phone (Optional)
              const Text(
                "Phone (Optional):",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Enter phone number (optional)",
                ),
              ),

              const SizedBox(height: 20),

              // 🌟 Date Picker
              const Text(
                "Date:*",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              InkWell(
                onTap: () => _pickDate(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Select date",
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(dateText),
                      const Icon(
                        Icons.calendar_today,
                        color: Colors.deepPurple,
                      ),
                    ],
                  ),
                ),
              ),
              if (selectedDate == null)
                const Padding(
                  padding: EdgeInsets.only(left: 8, top: 6),
                  child: Text(
                    "Please select a date",
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),

              const SizedBox(height: 20),

              // 🌟 Duration
              const Text(
                "Duration (minutes):*",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _durationController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "e.g., 90",
                ),
                validator: (value) =>
                    value!.isEmpty ? "Please enter duration" : null,
              ),

              const SizedBox(height: 30),

              // 🌟 Add to Waitlist button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurpleAccent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.person_add, color: Colors.white),
                  label: const Text(
                    "Add to Waitlist",
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
}
