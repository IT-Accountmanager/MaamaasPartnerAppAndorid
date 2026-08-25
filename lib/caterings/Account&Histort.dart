import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:maamaaspartner/Api/authservice.dart';

class CateringAccountHistoryPage extends StatefulWidget {
  const CateringAccountHistoryPage({super.key});

  @override
  State<CateringAccountHistoryPage> createState() =>
      _CateringAccountHistoryPageState();
}

class _CateringAccountHistoryPageState
    extends State<CateringAccountHistoryPage> {
  int _selectedIndex = 0;
  String selectedFilter = 'Custom';
  final List<String> filters = [
    'Custom',
    'Today',
    'Weekly',
    'Monthly',
    'Yearly',
  ];

  // API Data
  List<dynamic>? _allOrders;
  Map<String, dynamic>? _paymentSummary;
  bool _isLoading = false;
  String? _errorMessage;
  int? _vendorId;
  String? _accessToken;

  // Date range for Custom filter
  DateTime? _fromDate;
  DateTime? _toDate;

  // API URLs
  final String dashboardApi =
      'http://staging.maamaas.com:8080/catering/api/dashboard/custom';
  // final String dashboardApi = 'http://staging.maamaas.com:8080/catering/api/dashboard/custom';
  final String ordersApi =
      'http://staging.maamaas.com:8080/catering/api/vendor/getall';
  // final String ordersApi = 'http://staging.maamaas.com:8080/catering/api/vendor/getall';

  final List<Widget> _pages = const [
    Center(child: Text("Home Page")),
    Center(child: Text("Menu Management")),
    Center(child: Text("Order Management")),
    Center(child: Text("Account & History")),
  ];

  @override
  void initState() {
    super.initState();
    // Set default date range (last 30 days)
    _fromDate = DateTime.now().subtract(const Duration(days: 30));
    _toDate = DateTime.now();

    // Load vendor data and token
    _loadVendorDataAndToken();
  }

  Future<void> _loadVendorDataAndToken() async {
    try {
      _vendorId = await Authservice.getVendorId();
      _accessToken = await Authservice.getAccessToken();

      if (_vendorId != null && _vendorId! > 0) {
        print('✅ Vendor ID loaded: $_vendorId');
        if (_accessToken != null && _accessToken!.isNotEmpty) {
          print('✅ Access token loaded');
          await _fetchAllData();
        } else {
          setState(() {
            _errorMessage =
                'Authentication token not found. Please login again.';
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Vendor ID not found. Please login again.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading vendor data: $e';
      });
    }
  }

  Future<void> _fetchAllData() async {
    await Future.wait([_fetchPaymentSummary(), _fetchAllOrders()]);
  }

  Future<void> _fetchPaymentSummary() async {
    if (_vendorId == null || _vendorId! <= 0) return;
    if (_accessToken == null || _accessToken!.isEmpty) return;
    if (_fromDate == null || _toDate == null) return;

    try {
      String fromDateStr = DateFormat('yyyy-MM-dd').format(_fromDate!);
      String toDateStr = DateFormat('yyyy-MM-dd').format(_toDate!);

      String url =
          '$dashboardApi?vendorId=$_vendorId&fromDate=$fromDateStr&toDate=$toDateStr';

      print('📡 Fetching payment summary from: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {'accept': '*/*', 'Authorization': 'Bearer $_accessToken'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _paymentSummary = data;
        });
        print('✅ Payment summary loaded');
      } else {
        print('❌ Failed to load payment summary: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching payment summary: $e');
    }
  }

  Future<void> _fetchAllOrders() async {
    if (_vendorId == null || _vendorId! <= 0) return;
    if (_accessToken == null || _accessToken!.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      String url = '$ordersApi/$_vendorId';

      print('📡 Fetching all orders from: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {'accept': '*/*', 'Authorization': 'Bearer $_accessToken'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> orders = json.decode(response.body);

        // Filter orders by date range
        final filteredOrders = orders.where((order) {
          try {
            DateTime orderDate = DateTime.parse(
              order['orderDateTime'] ?? DateTime.now().toIso8601String(),
            );
            return orderDate.isAfter(_fromDate!) &&
                orderDate.isBefore(_toDate!.add(const Duration(days: 1)));
          } catch (e) {
            return false;
          }
        }).toList();

        setState(() {
          _allOrders = filteredOrders;
          _isLoading = false;
        });
        print('✅ Loaded ${filteredOrders.length} orders');
      } else if (response.statusCode == 401) {
        // Token expired, try to refresh
        final newToken = await Authservice.refreshAccessToken();
        if (newToken != null) {
          _accessToken = newToken;
          await _fetchAllOrders(); // Retry
        } else {
          setState(() {
            _errorMessage = 'Session expired. Please login again.';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Failed to load orders: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  int _getTotalOrders() {
    if (_allOrders == null) return 0;
    return _allOrders!.length;
  }

  double _getTotalIncome() {
    if (_allOrders == null) return 0;
    double total = 0;
    for (var order in _allOrders!) {
      total += (order['amountPaid'] ?? 0).toDouble();
    }
    return total;
  }

  double _getPaymentAmount(String method) {
    if (_allOrders == null) return 0;
    double total = 0;
    for (var order in _allOrders!) {
      String paymentMethod = order['paymentMethod'] ?? '';
      if (paymentMethod.contains(method) ||
          (method == 'Online' && paymentMethod == 'Online_Payment')) {
        total += (order['amountPaid'] ?? 0).toDouble();
      }
    }
    return total;
  }

  void _updateDateRangeForFilter(String filter) {
    DateTime now = DateTime.now();
    switch (filter) {
      case 'Today':
        _fromDate = DateTime(now.year, now.month, now.day);
        _toDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case 'Weekly':
        _fromDate = now.subtract(Duration(days: now.weekday - 1));
        _toDate = now;
        break;
      case 'Monthly':
        _fromDate = DateTime(now.year, now.month, 1);
        _toDate = now;
        break;
      case 'Yearly':
        _fromDate = DateTime(now.year, 1, 1);
        _toDate = now;
        break;
      case 'Custom':
        _fromDate ??= now.subtract(const Duration(days: 30));
        _toDate ??= now;
        break;
    }
    _fetchAllData();
  }

  String _formatCurrency(double amount) {
    final format = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
    return format.format(amount);
  }

  String _formatDate(String? dateTimeStr) {
    if (dateTimeStr == null || dateTimeStr.isEmpty) return 'N/A';
    try {
      DateTime date = DateTime.parse(dateTimeStr);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return dateTimeStr;
    }
  }

  String _formatTime(String? dateTimeStr) {
    if (dateTimeStr == null || dateTimeStr.isEmpty) return '';
    try {
      DateTime date = DateTime.parse(dateTimeStr);
      return DateFormat('hh:mm a').format(date);
    } catch (e) {
      return '';
    }
  }

  Color _getStatusColor(String? status) {
    switch (status?.toUpperCase()) {
      case 'SUCCESS':
        return Colors.green;
      case 'PENDING':
        return Colors.orange;
      case 'CANCELLED':
        return Colors.red;
      case 'PARTIALLY_PAID':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Color _getPaymentMethodColor(String? method) {
    switch (method) {
      case 'Online_Payment':
        return Colors.green;
      case 'Cash':
        return Colors.orange;
      default:
        return Colors.deepPurple;
    }
  }

  String _formatPaymentMethod(String? method) {
    switch (method) {
      case 'Online_Payment':
        return 'Online';
      case 'Cash':
        return 'Cash';
      default:
        return method ?? 'N/A';
    }
  }

  String _getEventType(String? eventType) {
    return eventType ?? 'N/A';
  }

  int _getOrderItemsCount(List<dynamic>? orderItems) {
    if (orderItems == null) return 0;
    return orderItems.length;
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  int min(int a, int b) => a < b ? a : b;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Account & History",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        bottom: (_vendorId != null && _vendorId! > 0)
            ? PreferredSize(
                preferredSize: const Size.fromHeight(30),
                child: Container(padding: const EdgeInsets.only(bottom: 8)),
              )
            : null,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchAllData,
        child: Column(
          children: [
            // Filter Toggle Buttons
            _buildFilterToggleButtons(),

            const Divider(),

            // Income Summary Section
            _isLoading
                ? const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : _errorMessage != null
                ? Padding(
                    padding: const EdgeInsets.all(20),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 40,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: _fetchAllData,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                            ),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildIncomeCard(
                                "Total Income",
                                Icons.attach_money,
                                Colors.blue,
                                _getTotalIncome(),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildIncomeCard(
                                "Online Income",
                                Icons.credit_card,
                                Colors.green,
                                _getPaymentAmount('Online_Payment'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _buildIncomeCard(
                                "Cash Income",
                                Icons.money,
                                Colors.orange,
                                _getPaymentAmount('Cash'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildIncomeCard(
                                "Total Orders",
                                Icons.shopping_bag,
                                Colors.purple,
                                _getTotalOrders().toDouble(),
                                isCount: true,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

            const Divider(),

            // Recent Transactions Section
            Expanded(
              child: _allOrders == null || _allOrders!.isEmpty
                  ? const Center(
                      child: Text(
                        'No transactions found',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: _allOrders!.length,
                      itemBuilder: (context, index) {
                        final order = _allOrders![index];
                        return _buildTransactionCard(order);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterToggleButtons() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Row(
        children: filters.map((filter) {
          final isSelected = filter == selectedFilter;
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedFilter = filter;
                _updateDateRangeForFilter(filter);
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? Colors.deepPurple : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? Colors.deepPurple : Colors.grey.shade300,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.deepPurple.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                filter,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.deepPurple,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildIncomeCard(
    String title,
    IconData icon,
    Color color,
    double amount, {
    bool isCount = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              isCount ? amount.toInt().toString() : _formatCurrency(amount),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> order) {
    // Safely extract values with null checks
    final orderId = order['orderId']?.toString() ?? 'N/A';
    final orderDateTime = order['orderDateTime'] as String?;
    final paymentStatus = order['paymentStatus'] as String?;
    final eventType = order['eventType'] as String?;
    final paymentMethod = order['paymentMethod'] as String?;
    final amountPaid = (order['amountPaid'] ?? 0).toDouble();
    final orderItems = order['orderItems'] as List<dynamic>?;

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order #$orderId',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_formatDate(orderDateTime)} • ${_formatTime(orderDateTime)}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(paymentStatus).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getStatusColor(paymentStatus).withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    paymentStatus ?? 'PENDING',
                    style: TextStyle(
                      color: _getStatusColor(paymentStatus),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Event & Payment Method
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.event,
                    size: 16,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _getEventType(eventType),
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: _getPaymentMethodColor(
                      paymentMethod,
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    paymentMethod == 'Online_Payment'
                        ? Icons.credit_card
                        : Icons.money,
                    size: 16,
                    color: _getPaymentMethodColor(paymentMethod),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _formatPaymentMethod(paymentMethod),
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
                Text(
                  _formatCurrency(amountPaid),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.green,
                  ),
                ),
              ],
            ),

            if (orderItems != null && orderItems.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Items: ${orderItems.length}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
