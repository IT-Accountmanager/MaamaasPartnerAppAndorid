import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:maamaaspartner/widgets_helper/drawer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Models/food&beverages/Promotions.dart';

class PromotionsPage extends StatefulWidget {
  const PromotionsPage({super.key});

  @override
  State<PromotionsPage> createState() => _PromotionsPageState();
}

class _PromotionsPageState extends State<PromotionsPage> {
  int _selectedIndex = 0;

  final TextEditingController _couponTypeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _goalController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  File? _selectedImage;
  final picker = ImagePicker();

  final List<Map<String, dynamic>> _promotions = [];

  List<FBPromotion> _promotionsList = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchPromotions(); // Fetch data when screen loads
  }

  Future<void> fetchPromotions() async {
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final vendorId = prefs.getInt('vendorId') ?? 1;

      if (token == null) {
        print("⚠️ No token found! Please login first.");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Session expired. Please login again.")),
        );
        return;
      }

      // ✅ Updated Food & Beverages URL
      final url = Uri.parse(
        "http://staging.maamaas.com:8080/food/vendor/coupon/getByVendor/$vendorId",
      );

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print("📡 API URL: $url");
      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        if (decoded is List) {
          setState(() {
            _promotionsList = decoded
                .map((e) => FBPromotion.fromJson(e))
                .toList();
          });
        } else if (decoded is Map) {
          final list =
              decoded['data'] ??
              decoded['content'] ??
              decoded['promotions'] ??
              decoded['results'] ??
              decoded['items'];

          if (list is List) {
            setState(() {
              _promotionsList = list
                  .map((e) => FBPromotion.fromJson(e))
                  .toList();
            });
          } else {
            print("⚠️ No valid list found in JSON: $decoded");
          }
        } else {
          print("Unexpected JSON format: $decoded");
        }
      } else if (response.statusCode == 403) {
        print("🚫 Access denied — Invalid or expired token");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Access denied. Please re-login.")),
        );
      } else {
        print("Failed to load promotions: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error fetching promotions: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> createPromotion() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final vendorId = prefs.getInt('vendorId'); // dynamic vendorId

      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Session expired. Please login again.")),
        );
        return;
      }

      // ✅ Convert image to Base64
      String? base64Image;
      if (_selectedImage != null) {
        final bytes = await _selectedImage!.readAsBytes();
        base64Image = base64Encode(bytes);
      }

      // ✅ Prepare request body
      // Generate coupon code if backend doesn't do it
      final couponCode =
          _couponTypeController.text; // or generate automatically

      final body = jsonEncode({
        "couponCode": couponCode, // 👈 match backend field
        "description": _descriptionController.text,
        "gole": _goalController.text, // backend expects 'gole'
        "discount": double.tryParse(_discountController.text) ?? 0,
        "startDate": _startDate?.toIso8601String(),
        "endDate": _endDate?.toIso8601String(),
        "image": base64Image,
      });

      // ✅ Updated URL
      final url = Uri.parse(
        "http://staging.maamaas.com:8080/food/vendor/coupon/add/$vendorId",
      );

      print("📤 POST URL: $url");
      print("📤 Request Body: $body");

      // ✅ Send POST request
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: body,
      );

      print("📩 Response Status: ${response.statusCode}");
      print("📩 Response Body: ${response.body}");

      // ✅ Handle response
      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Promotion created successfully!")),
        );

        Navigator.pop(context); // close dialog
        fetchPromotions(); // refresh list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to create promotion: ${response.statusCode}"),
          ),
        );
      }
    } catch (e) {
      print("❌ Error creating promotion: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  // Show Request Coupon Dialog
  void _showRequestCouponBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Makes sheet full height when keyboard opens
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(
                  context,
                ).viewInsets.bottom, // Adjust for keyboard
                top: 16,
                left: 16,
                right: 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Container(
                        width: 60,
                        height: 5,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                    const Center(
                      child: Text(
                        "Request Promotion",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: _couponTypeController,
                      decoration: const InputDecoration(
                        hintText: "Coupon Type",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: "Description",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: _goalController,
                      decoration: const InputDecoration(
                        hintText: "Goal",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Date Pickers
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2023),
                                lastDate: DateTime(2030),
                              );
                              if (picked != null) {
                                setSheetState(() => _startDate = picked);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 14,
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _startDate == null
                                        ? "Start Date"
                                        : DateFormat(
                                            'dd-MM-yyyy',
                                          ).format(_startDate!),
                                  ),
                                  const Icon(
                                    Icons.calendar_today,
                                    color: Colors.deepPurple,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2023),
                                lastDate: DateTime(2030),
                              );
                              if (picked != null) {
                                setSheetState(() => _endDate = picked);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 14,
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _endDate == null
                                        ? "End Date"
                                        : DateFormat(
                                            'dd-MM-yyyy',
                                          ).format(_endDate!),
                                  ),
                                  const Icon(
                                    Icons.calendar_today,
                                    color: Colors.deepPurple,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: _discountController,
                      decoration: const InputDecoration(
                        hintText: "Discount (%)",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    ElevatedButton.icon(
                      onPressed: () async {
                        final pickedFile = await picker.pickImage(
                          source: ImageSource.gallery,
                        );
                        if (pickedFile != null) {
                          setSheetState(() {
                            _selectedImage = File(pickedFile.path);
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                      ),
                      icon: const Icon(Icons.upload_file, color: Colors.white),
                      label: const Text(
                        "Choose File",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),

                    if (_selectedImage != null) ...[
                      const SizedBox(height: 8),
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            _selectedImage!,
                            height: 100,
                            width: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),

                    Align(
                      alignment: Alignment.bottomCenter,
                      child: ElevatedButton(
                        onPressed: () async {
                          // Show progress indicator overlay
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) => const Center(
                              child: CircularProgressIndicator(
                                color: Colors.deepPurple,
                              ),
                            ),
                          );

                          await createPromotion(); // 🔥 API call
                          Navigator.pop(context); // Close progress indicator
                          Navigator.pop(context); // Close bottom sheet
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          minimumSize: const Size(double.infinity, 48),
                        ),
                        child: const Text(
                          "Submit Request",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Payment simulation
  void _onPayNow(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Payment"),
        content: const Text(
          "Payment successful! Your promotion is now active.",
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _promotions[index]['status'] = 'Paid';
              });
              Navigator.pop(context);
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Promotions",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      drawer: CustomDrawer(),

      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.deepPurple),
            )
          : _promotionsList.isEmpty
          ? const Center(
              child: Text(
                "No promotions found.\nTap 'Request Coupon' to add one.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _promotionsList.length,
              itemBuilder: (context, index) {
                final promo = _promotionsList[index];
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              promo.couponCode,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.deepPurple,
                              ),
                            ),
                            Text(
                              promo.paymentStatus,
                              style: TextStyle(
                                color: promo.paymentStatus == 'PAID'
                                    ? Colors.green
                                    : Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        if (promo.decodedImage != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.memory(
                              promo.decodedImage!,
                              height: 120,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),

                        const SizedBox(height: 10),
                        Text("Description: ${promo.description}"),
                        Text("Goal: ${promo.goal}"),
                        Text("Discount: ${promo.discount}%"),
                        Text("Start: ${promo.startDate.split('T')[0]}"),
                        Text("End: ${promo.endDate.split('T')[0]}"),
                        Text("Amount: ₹${promo.amount.toStringAsFixed(2)}"),
                        const SizedBox(height: 10),

                        if (promo.paymentStatus != 'PAID')
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton(
                              onPressed: () => _onPayNow(index),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                              ),
                              child: const Text(
                                "Pay Now",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.deepPurple,
        onPressed: _showRequestCouponBottomSheet,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "Request Coupon",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.deepPurple,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: "Menu"),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: "Cart",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
