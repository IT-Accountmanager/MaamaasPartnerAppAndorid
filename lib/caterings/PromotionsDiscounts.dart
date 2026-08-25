import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../CateringModels/Promotion.dart';
import 'Account&Histort.dart';
import 'Home.dart';
import 'Leads.dart';
import 'MenuManagement.dart';
import 'OrderManagement.dart';
import 'Profile.dart';

import 'ReportAndAnalysisPage.dart';

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

  List<Promotion> _promotionsList = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchPromotions(); // Fetch data when screen loads
  }

  Future<void> fetchPromotions() async {
    setState(() => _isLoading = true);

    try {
      // ✅ Get saved token and vendor ID from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final vendorId = prefs.getInt('vendorId') ?? 1; // fallback to 1

      if (token == null) {
        print("⚠️ No token found! Please login first.");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Session expired. Please login again.")),
        );
        return;
      }

      // final url = Uri.parse(
      //   "http://staging.maamaas.com:8080/catering/api/vendor/catering/coupon/getByVendor/$vendorId",
      // );
      final url = Uri.parse(
        "http://staging.maamaas.com:8080/catering/api/vendor/catering/coupon/getByVendor/$vendorId",
      );

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token', // ✅ Add token here
          'Content-Type': 'application/json',
        },
      );

      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        print("Decoded JSON type: ${decoded.runtimeType}");

        // ✅ FIXED: Added flexible handling for different backend formats
        if (decoded is List) {
          setState(() {
            _promotionsList = decoded
                .map((e) => Promotion.fromJson(e))
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
              _promotionsList = list.map((e) => Promotion.fromJson(e)).toList();
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

  // Show Request Coupon Dialog
  void _showRequestCouponDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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

                          // Start and End Date Pickers
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
                                      setDialogState(() => _startDate = picked);
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
                                      setDialogState(() => _endDate = picked);
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

                          // Choose File with Preview
                          ElevatedButton.icon(
                            onPressed: () async {
                              final pickedFile = await picker.pickImage(
                                source: ImageSource.gallery,
                              );
                              if (pickedFile != null) {
                                setDialogState(() {
                                  _selectedImage = File(pickedFile.path);
                                });
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                            ),
                            icon: const Icon(
                              Icons.upload_file,
                              color: Colors.white,
                            ),
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
                          const SizedBox(height: 16),

                          Align(
                            alignment: Alignment.bottomLeft,
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _promotions.add({
                                    'type': _couponTypeController.text,
                                    'description': _descriptionController.text,
                                    'goal': _goalController.text,
                                    'discount': _discountController.text,
                                    'start': _startDate != null
                                        ? DateFormat(
                                            'dd-MM-yyyy',
                                          ).format(_startDate!)
                                        : '-',
                                    'end': _endDate != null
                                        ? DateFormat(
                                            'dd-MM-yyyy',
                                          ).format(_endDate!)
                                        : '-',
                                    'status': 'Pending',
                                    'image': _selectedImage,
                                  });
                                });

                                _couponTypeController.clear();
                                _descriptionController.clear();
                                _goalController.clear();
                                _discountController.clear();
                                _startDate = null;
                                _endDate = null;
                                _selectedImage = null;

                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                              ),
                              child: const Text(
                                "Submit Request",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
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
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.deepPurple),
              child: Text(
                "Menu",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home, color: Colors.deepPurple),
              title: const Text("Home"),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CateringLandingPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.restaurant_menu,
                color: Colors.deepPurple,
              ),
              title: const Text("Menu Management"),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MenuManagementPage(),
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.list_alt, color: Colors.deepPurple),
              title: const Text("order Management"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const OrderManagementPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.account_balance_wallet,
                color: Colors.deepPurple,
              ),
              title: const Text("Account &History"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CateringAccountHistoryPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.discount, color: Colors.deepPurple),
              title: const Text("Promotions Discounts"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PromotionsPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Colors.deepPurple),
              title: const Text("profile"),
              // onTap: () {
              //   Navigator.pop(context);
              //   Navigator.push(
              //     context,
              //     MaterialPageRoute(
              //       builder: (context) => const ProfilePage(),
              //     ),
              //   );
              // },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.leaderboard, color: Colors.deepPurple),
              title: const Text("leads"),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LeadManagementPage()),
                );
              },
            ),
            const ListTile(
              leading: Icon(Icons.settings, color: Colors.deepPurple),
              title: Text("Settings & Control"),
            ),
            ListTile(
              leading: const Icon(Icons.pie_chart, color: Colors.deepPurple),
              title: const Text("Report & Analysis"),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ReportAndAnalysisPagecatering(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text(
          "Promotions",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
      ),

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

                        if (promo.image != null && promo.image!.isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              promo.image!,
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
        onPressed: _showRequestCouponDialog,
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
