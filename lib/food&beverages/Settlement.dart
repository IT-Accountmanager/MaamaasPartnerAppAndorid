import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../Api/food_authservice.dart';

class SettlementScreen extends StatefulWidget {
  const SettlementScreen({Key? key}) : super(key: key);

  @override
  State<SettlementScreen> createState() => _SettlementScreenState();
}

class _SettlementScreenState extends State<SettlementScreen> {
  List<Map<String, dynamic>> settlementList = [];
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchSettlementData();
  }

  Future<void> fetchSettlementData() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final vendorId = prefs.getInt("vendorId") ?? 0;

      if (vendorId == 0) {
        throw Exception("Vendor ID not found");
      }

      final response = await SettlementAuthService.getTransactionHistory(
        vendorId,
      );

      List<dynamic> dataList = [];

      if (response is List) {
        dataList = response;
      } else if (response is Map<String, dynamic>) {
        if (response.containsKey("data")) {
          dataList = response["data"] is List ? response["data"] : [];
        } else if (response.containsKey("message")) {
          // Handle API message response
          debugPrint("ℹ️ API Message: ${response["message"]}");
        }
      }

      setState(() {
        settlementList = List<Map<String, dynamic>>.from(dataList);
        isLoading = false;
        hasError = false;
      });
    } catch (e) {
      debugPrint("❌ Error fetching settlements: $e");
      setState(() {
        errorMessage = e.toString().contains("Failed to load")
            ? "Failed to load settlement data"
            : "An error occurred. Please try again.";
        isLoading = false;
        hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // removes back arrow
        title: const Text(
          "",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.deepPurple),
      );
    }

    if (hasError) {
      return _buildErrorView();
    }

    if (settlementList.isEmpty) {
      return _buildEmptyView();
    }

    return RefreshIndicator(
      onRefresh: fetchSettlementData,
      color: Colors.deepPurple,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: settlementList.length,
        itemBuilder: (context, index) {
          final txn = settlementList[index];
          return _buildSettlementCard(txn);
        },
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 60, color: Colors.red[400]),
          const SizedBox(height: 16),
          Text(
            errorMessage,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: fetchSettlementData,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            icon: const Icon(Icons.refresh, color: Colors.white, size: 20),
            label: const Text(
              "Try Again",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 20),
          Text(
            "No settlements found",
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Your settlement history will appear here",
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: fetchSettlementData,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text("Refresh"),
          ),
        ],
      ),
    );
  }

  Widget _buildSettlementCard(Map<String, dynamic> txn) {
    final amountAfterTds = txn["amountAfterTds"] ?? 0;
    final isPositive = amountAfterTds is num && amountAfterTds > 0;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Settlement ID and Status
            Row(
              children: [
                Expanded(
                  child: Text(
                    txn["settlementId"]?.toString() ?? "N/A",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.deepPurple,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(txn["paymentStatus"]),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    txn["paymentStatus"]?.toString().toUpperCase() ?? "PENDING",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Date Range
            if (txn["fromDate"] != null || txn["toDate"] != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              "${txn["fromDate"] ?? "N/A"} - ${txn["toDate"] ?? "N/A"}",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[700],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            // Settlement Date
            if (txn["settlementDate"] != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Icon(Icons.date_range, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 6),
                    Text(
                      "Settled on: ${txn["settlementDate"]}",
                      style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),

            const Divider(height: 20),

            // Amount Details
            _buildAmountRow(
              "Total Sales",
              txn["totalGrandTotal"],
              isCurrency: true,
            ),
            _buildAmountRow(
              "Service Charges",
              txn["totalServiceCharges"],
              isCurrency: true,
            ),
            _buildAmountRow(
              "Platform Charges",
              txn["totalPlatformCharges"],
              isCurrency: true,
            ),

            const SizedBox(height: 8),

            // Net Amount
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isPositive ? Colors.green.shade50 : Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isPositive
                      ? Colors.green.shade100
                      : Colors.blue.shade100,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                    color: isPositive ? Colors.green : Colors.blue,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Net Amount",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                  Text(
                    "₹${(amountAfterTds is num ? amountAfterTds : 0).toStringAsFixed(2)}",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isPositive ? Colors.green : Colors.blue,
                    ),
                  ),
                ],
              ),
            ),

            // Payment Details
            if (txn["pytMode"] != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  children: [
                    Icon(Icons.payment, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 6),
                    Text(
                      "Paid via ${txn["pytMode"]}",
                      style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),

            // Remarks
            if (txn["remarks"] != null && txn["remarks"].toString().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Remarks:",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        txn["remarks"].toString(),
                        style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountRow(
    String label,
    dynamic amount, {
    bool isCurrency = false,
  }) {
    final amountValue = amount ?? 0;
    final amountText = isCurrency && amountValue is num
        ? "₹${amountValue.toStringAsFixed(2)}"
        : amountValue.toString();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[700], fontSize: 14),
            ),
          ),
          Text(
            amountText,
            style: TextStyle(
              color: Colors.grey[800],
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'completed':
      case 'paid':
      case 'success':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class SettlementAuthService {
  static const String baseUrl = "http://staging.maamaas.com:8080/food/api";

  // Consider moving timeout and retry logic here
  static const Duration timeoutDuration = Duration(seconds: 30);

  static Future<dynamic> getTransactionHistory(int vendorId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final url = Uri.parse("$baseUrl/settlements/vendor/$vendorId");

    debugPrint("📡 Fetching settlements for vendor: $vendorId");
    debugPrint("🔐 Token available: ${token != null && token.isNotEmpty}");

    try {
      final response = await http
          .get(
            url,
            headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer $token",
            },
          )
          .timeout(timeoutDuration);

      debugPrint("🔵 Status Code: ${response.statusCode}");

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        debugPrint("🟢 Response received successfully");
        return decoded;
      } else if (response.statusCode == 401) {
        throw Exception("Authentication failed. Please login again.");
      } else if (response.statusCode == 404) {
        throw Exception("Vendor not found");
      } else {
        debugPrint("🔴 Error Response: ${response.body}");
        throw Exception("Server responded with status ${response.statusCode}");
      }
    } on http.ClientException catch (e) {
      debugPrint("🌐 Network Error: $e");
      throw Exception("Network error. Please check your connection.");
    }
  }
}
