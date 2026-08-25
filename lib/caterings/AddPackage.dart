import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mime/mime.dart';

import '../Api/APIclient.dart';

class AddPackagePage extends StatefulWidget {
  final Function(dynamic pkg) onPackageAdded;
  const AddPackagePage({super.key, required this.onPackageAdded});

  @override
  State<AddPackagePage> createState() => _AddPackagePageState();
}

class _AddPackagePageState extends State<AddPackagePage> {
  final TextEditingController packageNameController = TextEditingController();
  final List<Map<String, TextEditingController>> items = [];
  final List<String> packageTypes = ["Veg", "Non-veg", "Drinks"];
  final Map<String, String> packageTypeMap = {
    "Veg": "Veg",
    "Non-veg": "Non_veg", // 👈 backend expects underscore version
    "Drinks": "Drinks",
  };

  String? selectedPackageType;
  File? packageImageFile;
  double totalPrice = 0.0;

  // final String apiUrl = "http://staging.maamaas.com:8080/catering";
  final String apiUrl = "http://staging.maamaas.com:8080/catering";

  // 🖼️ Pick image from gallery
  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => packageImageFile = File(picked.path));
    }
  }

  // ➕ Add new item
  void addNewItem() {
    setState(() {
      final priceController = TextEditingController();
      // Auto-update total when price changes
      priceController.addListener(_calculateTotal);
      items.add({'name': TextEditingController(), 'price': priceController});
    });
  }

  // ❌ Remove item and recalculate
  void removeItem(int index) {
    setState(() {
      items[index]['price']?.removeListener(_calculateTotal);
      items.removeAt(index);
      _calculateTotal();
    });
  }

  // 💰 Recalculate total price
  void _calculateTotal() {
    double sum = 0.0;
    for (var item in items) {
      double price =
          double.tryParse(
            item['price']!.text.trim().isEmpty ? '0' : item['price']!.text,
          ) ??
          0;
      sum += price;
    }
    setState(() => totalPrice = sum);
  }

  // 🚀 Save package
  Future<void> savePackage() async {
    debugPrint("🟢 savePackage() called");

    // ✅ Validate required fields
    if (packageNameController.text.trim().isEmpty ||
        selectedPackageType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields")),
      );
      return;
    }

    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please add at least one item")),
      );
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final vendorId = prefs.getInt("vendorId");

      if (vendorId == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Vendor ID not found")));
        return;
      }

      // ✅ Prepare Package JSON
      final packageData = {
        "id": 0,
        "vendorId": vendorId,
        "packageName": packageNameController.text.trim(),
        "packageType": packageTypeMap[selectedPackageType]!,
        "items": items.map((item) {
          return {
            "id": 0,
            "itemName": item['name']!.text.trim(),
            "price": double.tryParse(item['price']!.text.trim()) ?? 0.0,
          };
        }).toList(),
        "totalPrice": totalPrice,
      };

      debugPrint("📦 PACKAGE JSON: ${jsonEncode(packageData)}");

      // ✅ Send multipart request using ApiClient
      final response = await ApiClient.sendMultipartRequest(
        endpoint: "api/vendor/$vendorId/package",
        method: "POST",
        service: "catering",
        data: {"packageData": jsonEncode(packageData)},
        files: {if (packageImageFile != null) "image": packageImageFile!},
      );

      debugPrint("📡 STATUS: ${response.statusCode}");
      debugPrint("📦 BODY: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Package saved successfully")),
        );

        widget.onPackageAdded(jsonDecode(response.body));
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("❌ Failed: ${response.statusCode}\n${response.body}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e, st) {
      debugPrint("💥 Exception: $e");
      debugPrint("🪜 Stack: $st");

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  void dispose() {
    for (var item in items) {
      item['price']?.removeListener(_calculateTotal);
      item['name']?.dispose();
      item['price']?.dispose();
    }
    packageNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Add Package",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 🖼️ Image Picker
              GestureDetector(
                onTap: pickImage,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.deepPurple, width: 2),
                  ),
                  child: packageImageFile == null
                      ? const Center(child: Text("Tap to upload image"))
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            packageImageFile!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),

              // 📦 Package Name
              TextField(
                controller: packageNameController,
                decoration: InputDecoration(
                  labelText: "Package Name",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // 🍛 Package Type
              DropdownButtonFormField<String>(
                value: selectedPackageType,
                items: packageTypes
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setState(() => selectedPackageType = v),
                decoration: InputDecoration(
                  labelText: "Package Type",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 25),

              // 🧾 Items Section
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Items:",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              const SizedBox(height: 10),

              // 🧾 Item Fields
              Column(
                children: List.generate(items.length, (index) {
                  final item = items[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: item['name'],
                            decoration: InputDecoration(
                              labelText: "Item Name",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 1,
                          child: TextField(
                            controller: item['price'],
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: "Price",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => removeItem(index),
                        ),
                      ],
                    ),
                  );
                }),
              ),

              Align(
                alignment: Alignment.centerLeft,
                child: ElevatedButton.icon(
                  onPressed: addNewItem,
                  icon: const Icon(Icons.add),
                  label: const Text("Add Item"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 💰 Total Price
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Total Price: ₹${totalPrice.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // 🔘 Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                      ),
                      child: const Text("Cancel"),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: savePackage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: const Text("Save"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
