import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class OrderManagementPage extends StatefulWidget {
  const OrderManagementPage({super.key});

  @override
  State<OrderManagementPage> createState() => _OrderManagementPageState();
}

class _OrderManagementPageState extends State<OrderManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  /// API DATA
  List<PackageModel> orders = [];

  bool isLoadingOrders = true;

  /// CHANGE THESE
  final int vendorId = 1;
  final String token = 'YOUR_TOKEN_HERE';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadOrders();
  }

  // ==============================
  // API SERVICE (SAME PAGE)
  // ==============================
  Future<List<PackageModel>> fetchVendorPackages() async {
    // final url = Uri.parse(
    //   'http://staging.maamaas.com:8080/catering/api/package/$vendorId',
    // );
    final url = Uri.parse(
      'http://staging.maamaas.com:8080/catering/api/package/$vendorId',
    );

    final response = await http.get(
      url,
      headers: {
        'accept': '*/*',
        'Content-Type': 'application/json',
        // TRY BOTH – backend dependent
        'Authorization': token, // if token already contains Bearer
        // 'Authorization': 'Bearer $token',
      },
    );

    debugPrint('STATUS CODE: ${response.statusCode}');
    debugPrint('RESPONSE BODY: ${response.body}');

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => PackageModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load orders: ${response.statusCode}');
    }
  }

  Future<void> _loadOrders() async {
    setState(() => isLoadingOrders = true);

    try {
      final result = await fetchVendorPackages();
      setState(() {
        orders = result;
        isLoadingOrders = false;
      });
    } catch (e) {
      debugPrint(e.toString());
      setState(() => isLoadingOrders = false);
    }
  }

  // ==============================
  // UI
  // ==============================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Management'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Orders (${orders.length})'),
            const Tab(text: 'Packages'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOrdersTab(),
          const Center(child: Text("Packages Tab")),
        ],
      ),
    );
  }

  Widget _buildOrdersTab() {
    if (isLoadingOrders) {
      return const Center(child: CircularProgressIndicator());
    }

    if (orders.isEmpty) {
      return const Center(
        child: Text(
          "No Orders Available",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadOrders,
      child: ListView.builder(
        padding: const EdgeInsets.all(14),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          return _buildOrderCard(orders[index]);
        },
      ),
    );
  }

  Widget _buildOrderCard(PackageModel order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                order.packageName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                order.packageType,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),

          const SizedBox(height: 12),

          /// IMAGE
          if (order.image != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                order.image!,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

          const SizedBox(height: 12),

          /// ITEMS
          const Text("Items", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),

          Column(
            children: order.items.map((item) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(item.itemName, style: const TextStyle(fontSize: 12)),
                    Text(
                      "₹${item.price}",
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          /// TOTAL
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0x1CDA3BFF),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Grand Total",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  "₹${order.totalPrice}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.deepPurple,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

// ==============================
// MODEL (SAME PAGE)
// ==============================
class PackageModel {
  final int id;
  final int vendorId;
  final String packageName;
  final String packageType;
  final String? image;
  final double totalPrice;
  final List<PackageItem> items;

  PackageModel({
    required this.id,
    required this.vendorId,
    required this.packageName,
    required this.packageType,
    this.image,
    required this.totalPrice,
    required this.items,
  });

  factory PackageModel.fromJson(Map<String, dynamic> json) {
    return PackageModel(
      id: json['id'],
      vendorId: json['vendorId'],
      packageName: json['packageName'],
      packageType: json['packageType'],
      image: json['image'],
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
      items: (json['items'] as List)
          .map((e) => PackageItem.fromJson(e))
          .toList(),
    );
  }
}

class PackageItem {
  final int id;
  final String itemName;
  final double price;

  PackageItem({required this.id, required this.itemName, required this.price});

  factory PackageItem.fromJson(Map<String, dynamic> json) {
    return PackageItem(
      id: json['id'],
      itemName: json['itemName'],
      price: (json['price'] ?? 0).toDouble(),
    );
  }
}
