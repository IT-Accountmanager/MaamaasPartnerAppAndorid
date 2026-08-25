import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AddFloorPage extends StatefulWidget {
  const AddFloorPage({super.key});

  @override
  State<AddFloorPage> createState() => _AddFloorPageState();
}

class _AddFloorPageState extends State<AddFloorPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _floorNameController = TextEditingController();
  final TextEditingController _cleaningDurationController =
      TextEditingController();
  final TextEditingController _capacityController = TextEditingController();
  final TextEditingController _tableCountController = TextEditingController();

  Future<void> _saveFloor() async {
    if (!_formKey.currentState!.validate()) return;

    final prefs = await SharedPreferences.getInstance();
    final vendorId = prefs.getInt('vendorId') ?? 1;
    final token = prefs.getString('token') ?? '';

    final url = Uri.parse(
      "http://staging.maamaas.com:8080/food/api/seating/vendor/$vendorId",
    );

    final int cleaningMinutes =
        int.tryParse(_cleaningDurationController.text) ?? 0;

    // ✅ Convert minutes to HH:mm:ss format string
    final hours = (cleaningMinutes ~/ 60).toString().padLeft(2, '0');
    final minutes = (cleaningMinutes % 60).toString().padLeft(2, '0');
    final cleaningTimeString = "$hours:$minutes:00";

    // ✅ Generate unique code
    final code = "FLOOR-${DateTime.now().millisecondsSinceEpoch}";

    final Map<String, dynamic> body = {
      "numberOfTables": int.tryParse(_tableCountController.text) ?? 0,
      "capacityPerTable": int.tryParse(_capacityController.text) ?? 0,
      "name": _floorNameController.text.trim(),
      "cleaningTime": cleaningTimeString,
      "code": code,
    };

    try {
      // debugPrint("📤 Sending Body: ${jsonEncode(body)}");
      // debugPrint("🔗 URL: $url");

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(body),
      );

      // debugPrint("📡 Status: ${response.statusCode}");
      // debugPrint("📦 Response: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Floor added successfully!")),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "❌ Failed: ${response.statusCode} - ${response.body}",
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("⚠️ Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade50,
      appBar: AppBar(
        title: const Text(
          "Add New Floor",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.purple,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Floor Name:*",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _floorNameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Enter floor name",
                ),
                validator: (value) =>
                    value!.isEmpty ? "Please enter floor name" : null,
              ),
              const SizedBox(height: 20),

              const Text(
                "Number of Tables:*",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _tableCountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "e.g., 10",
                ),
                validator: (value) =>
                    value!.isEmpty ? "Please enter number of tables" : null,
              ),
              const SizedBox(height: 20),

              const Text(
                "Capacity per Table:*",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _capacityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "e.g., 4",
                ),
                validator: (value) =>
                    value!.isEmpty ? "Please enter capacity per table" : null,
              ),
              const SizedBox(height: 20),

              const Text(
                "Cleaning Duration (minutes):*",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _cleaningDurationController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "e.g., 15",
                ),
                validator: (value) =>
                    value!.isEmpty ? "Please enter cleaning time" : null,
              ),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saveFloor,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurpleAccent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.save, color: Colors.white),
                  label: const Text(
                    "Submit Floor",
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
