import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Api/food_authservice.dart';

class ScheduleOrdersPage extends StatefulWidget {
  const ScheduleOrdersPage({super.key});

  @override
  State<ScheduleOrdersPage> createState() => _ScheduleOrdersPageState();
}

class _ScheduleOrdersPageState extends State<ScheduleOrdersPage> {
  List<dynamic> _scheduledOrders = [];
  bool _isLoading = true;
  bool _isError = false;
  String _errorMessage = '';
  int _vendorId = 0;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadVendorId();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(Duration(seconds: 15), (timer) {
      if (mounted && _vendorId > 0) {
        _fetchScheduledOrders();
      }
    });
  }

  Future<void> _loadVendorId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      int storedVendorId = prefs.getInt('vendorId') ?? 0;

      if (storedVendorId == 0) {
        storedVendorId = prefs.getInt('VendorId') ?? 0;
      }

      if (storedVendorId == 0) {
        storedVendorId = 1; // Default fallback
      }

      setState(() {
        _vendorId = storedVendorId;
      });

      await _fetchScheduledOrders();
    } catch (e) {
      setState(() {
        _vendorId = 1;
      });
      await _fetchScheduledOrders();
    }
  }

  Future<void> _fetchScheduledOrders() async {
    if (_vendorId == 0) {
      setState(() {
        _isLoading = false;
        _isError = true;
        _errorMessage = 'Vendor information not loaded yet. Please wait...';
      });
      return;
    }

    if (!_isError) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final allOrders = await food_authservice.getAllOrders();

      final scheduledOrders = allOrders.where((order) {
        final status = order['status']?.toString() ?? '';
        final vendorId = order['vendorId'] ?? 0;
        final type = (order['orderType'] ?? '').toString().toUpperCase();

        return vendorId == _vendorId &&
            status == 'HOLD' &&
            ['DINE_IN', 'DELIVERY', 'TAKEAWAY'].contains(type);
      }).toList()..sort((a, b) => b['orderId'].compareTo(a['orderId']));

      setState(() {
        _scheduledOrders = scheduledOrders;
        _isLoading = false;
        _isError = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isError = true;
        _errorMessage = 'Failed to load scheduled orders. Please try again.';
      });
    }
  }

  Future<void> _acceptOrder(int orderId) async {
    try {
      final success = await food_authservice.updateOrderStatus(
        orderId,
        'CONFIRMED',
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order #$orderId accepted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        await _fetchScheduledOrders();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to accept order'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to accept order'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _declineOrder(int orderId) async {
    try {
      final success = await food_authservice.updateOrderStatus(
        orderId,
        'CANCELLED',
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order #$orderId declined'),
            backgroundColor: Colors.orange,
          ),
        );
        await _fetchScheduledOrders();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to decline order'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to decline order'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  double _calculateGrandTotal(List items) {
    return items.fold(0.0, (sum, it) => sum + (it['totalPrice'] ?? 0));
  }

  Map<String, String> _formatDateTime(String raw) {
    try {
      final d = DateTime.parse(raw);
      return {
        'date': DateFormat('dd MMM yyyy').format(d),
        'time': DateFormat('hh:mm a').format(d),
      };
    } catch (e) {
      return {'date': 'N/A', 'time': 'N/A'};
    }
  }

  String _getOrderTypeDisplayText(String orderType) {
    switch (orderType) {
      case 'DINE_IN':
        return "Dine In";
      case 'DELIVERY':
        return "Delivery";
      case 'TAKEAWAY':
        return "Take Away";
      case 'TABLE_DINE_IN':
        return "Table Dine In";
      default:
        return orderType;
    }
  }

  Widget _buildOrderCard(Map<String, dynamic> order, int index) {
    final items = order['order'] ?? [];
    final time = _formatDateTime(order['orderDateAndTime']);
    final isDelivery =
        (order['orderType'] ?? '').toString().toUpperCase() == 'DELIVERY';
    final isDineIn =
        (order['orderType'] ?? '').toString().toUpperCase() == 'DINE_IN';

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Order #${order['orderId']}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 4),
                    // Container(
                    //   padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    //   decoration: BoxDecoration(
                    //     color: Colors.orange.withOpacity(0.1),
                    //     borderRadius: BorderRadius.circular(12),
                    //   ),
                    //   // child: Text(
                    //   //   "Scheduled",
                    //   //   style: TextStyle(
                    //   //     color: Colors.orange,
                    //   //     fontSize: 12,
                    //   //     fontWeight: FontWeight.w500,
                    //   //   ),
                    //   // ),
                    // ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      time['date']!,
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    Text(
                      time['time']!,
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12),

            if (isDineIn || isDelivery)
              Container(
                margin: EdgeInsets.only(bottom: 8),
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isDineIn ? Icons.restaurant : Icons.delivery_dining,
                      size: 14,
                      color: Colors.blue,
                    ),
                    SizedBox(width: 4),
                    Text(
                      isDineIn ? "Dine In" : "Delivery",
                      style: TextStyle(color: Colors.blue, fontSize: 12),
                    ),
                  ],
                ),
              ),

            if (order['userName'] != null &&
                order['userName'].toString().isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Customer:",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  SizedBox(height: 4),
                  Text(
                    order['userName'].toString(),
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                  SizedBox(height: 12),
                ],
              ),

            Text(
              "Items:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 8),
            Column(
              children: items.map<Widget>((it) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          "- ${it['dishName']} x${it['quantity']}",
                          style: TextStyle(fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        "₹${it['totalPrice']}",
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),

            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(0x1CDA3BFF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Grand Total:",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    "₹${_calculateGrandTotal(items)}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.deepPurple,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _declineOrder(order['orderId']),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade50,
                      foregroundColor: Colors.green,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.greenAccent.shade200),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check, size: 18),
                        SizedBox(width: 6),
                        Text("Accept", style: TextStyle(fontSize: 14)),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _acceptOrder(order['orderId']),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade50,
                      foregroundColor: Colors.red,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.red.shade200),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.close, size: 18),
                        SizedBox(width: 6),
                        Text("Decline", style: TextStyle(fontSize: 14)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Color(0xFFB15DC6)),
          SizedBox(height: 20),
          Text(
            "Loading scheduled orders...",
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red),
          SizedBox(height: 16),
          Text(
            "Error loading orders",
            style: TextStyle(color: Colors.red, fontSize: 18),
          ),
          SizedBox(height: 8),
          Text(
            _errorMessage,
            style: TextStyle(color: Colors.grey, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _fetchScheduledOrders,
            child: Text("Retry"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFB15DC6),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.schedule_outlined, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            "No Scheduled Orders",
            style: TextStyle(color: Colors.grey, fontSize: 20),
          ),
          SizedBox(height: 8),
          Text(
            "Orders with 'HOLD' status will appear here",
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _fetchScheduledOrders,
            child: Text("Refresh"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFB15DC6),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Scheduled Orders",
          style: TextStyle(
            color: Color(0xFF2A0947),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF2A0947)),
          onPressed: () => Navigator.pop(context),
        ),
        // actions: [
        //   IconButton(
        //     icon: Icon(Icons.refresh, color: Color(0xFF2A0947)),
        //     onPressed: _fetchScheduledOrders,
        //   ),
        // ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchScheduledOrders,
        child: _isLoading
            ? _buildLoadingState()
            : _isError
            ? _buildErrorState()
            : _scheduledOrders.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 8),
                itemCount: _scheduledOrders.length,
                itemBuilder: (context, index) {
                  return _buildOrderCard(_scheduledOrders[index], index);
                },
              ),
      ),
    );
  }
}
