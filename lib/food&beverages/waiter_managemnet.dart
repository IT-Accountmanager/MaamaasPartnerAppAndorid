import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../Api/food_authservice.dart';

class waiter_management extends StatefulWidget {
  const waiter_management({super.key});

  @override
  State<waiter_management> createState() => _OrderManagementState();
}

class _OrderManagementState extends State<waiter_management> {
  final List<String> _tabTitles = ["All", "Processing", "Reports"];
  int _selectedTab = 0;
  bool _isDrawerOpen = false;
  List<dynamic> _orders = [];
  bool _isLoading = true;

  Future<void> _fetchOrders() async {
    setState(() => _isLoading = true);

    try {
      final fetchedOrders = await food_authservice.getAllOrders();

      final filteredOrders = fetchedOrders.where((order) {
        final type = (order['orderType'] ?? '').toString().toUpperCase();
        return ['DINE_IN', 'DELIVERY', 'TAKEAWAY'].contains(type);
      }).toList();

      setState(() => _orders = filteredOrders);
    } catch (e) {
      _showError('Failed to load orders');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Waiter Management",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,

        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          // Tab Bar Only - Header Stats Removed
          _buildTabBar(),
          // Content Area
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.grey[50]!, Colors.grey[100]!],
                ),
              ),
              child: IndexedStack(
                index: _selectedTab,
                children: [
                  AllOrdersTab(
                    orders: _orders,
                    isLoading: _isLoading,
                    onRefresh: _fetchOrders,
                  ),
                  ProcessingTab(
                    orders: _orders,
                    isLoading: _isLoading,
                    onRefresh: _fetchOrders,
                  ),
                  ReportsTab(orders: _orders, isLoading: _isLoading),
                ],
              ),
            ),
          ),
        ],
      ),
      // bottomNavigationBar: Footer(),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: 16.r,
        vertical: 16.r,
      ), // Increased vertical margin
      padding: EdgeInsets.all(6.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: List.generate(_tabTitles.length, (index) {
          final isSelected = _selectedTab == index;
          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              decoration: BoxDecoration(
                color: isSelected ? Colors.deepPurple : Colors.transparent,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.deepPurple.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => setState(() => _selectedTab = index),
                  borderRadius: BorderRadius.circular(12.r),
                  child: Container(
                    height: 42.h,
                    alignment: Alignment.center,
                    child: Text(
                      _tabTitles[index],
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : Colors.grey[700],
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// Rest of the code remains exactly the same...
class AllOrdersTab extends StatefulWidget {
  final List<dynamic> orders;
  final bool isLoading;
  final VoidCallback onRefresh;

  const AllOrdersTab({
    super.key,
    required this.orders,
    required this.isLoading,
    required this.onRefresh,
  });

  @override
  State<AllOrdersTab> createState() => _AllOrdersTabState();
}

class _AllOrdersTabState extends State<AllOrdersTab> {
  final Map<int, bool> _expandedStates = {};
  final List<String> _knownPendingOrderIds = [];
  final Map<int, bool> _selectedItems = {};

  @override
  void initState() {
    super.initState();
    _checkForNewPendingOrders();
  }

  void _checkForNewPendingOrders() {
    final pendingOrders = widget.orders
        .where((order) => order['status'] == 'ORDER_IS_READY')
        .map((order) => order['orderId'].toString())
        .toList();

    final newOrderIds = pendingOrders
        .where((id) => !_knownPendingOrderIds.contains(id))
        .toList();

    if (newOrderIds.isNotEmpty) {
      _knownPendingOrderIds.addAll(newOrderIds);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return _buildLoadingState();
    }

    final pendingOrders = widget.orders
        .where((order) => order['status'] == 'ORDER_IS_READY')
        .toList()
        .reversed
        .toList();

    if (pendingOrders.isEmpty) {
      return _buildEmptyState(
        icon: Icons.inbox_outlined,
        message: 'No pending orders',
        subtitle: 'New orders will appear here',
      );
    }

    return RefreshIndicator(
      onRefresh: () async => widget.onRefresh(),
      backgroundColor: Colors.white,
      color: Colors.deepPurple,
      child: ListView.builder(
        itemCount: pendingOrders.length,
        padding: EdgeInsets.all(16.w),
        itemBuilder: (context, index) {
          return _buildOrderCard(pendingOrders[index], index);
        },
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order, int index) {
    final items = order['order'] ?? [];
    final formattedDateTime = _formatDateTime(order['orderDateAndTime']);

    return AnimatedContainer(
      duration: Duration(milliseconds: 300 + (index * 100)),
      curve: Curves.easeInOut,
      margin: EdgeInsets.only(bottom: 16.h),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        elevation: 4,
        shadowColor: Colors.deepPurple.withOpacity(0.1),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.r),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Colors.grey[50]!],
            ),
          ),
          child: Column(
            children: [
              // Header Section - No Expansion
              Padding(
                padding: EdgeInsets.all(16.r),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Order #${order['orderId'] ?? 'N/A'}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.sp,
                                  color: Colors.grey[800],
                                ),
                              ),
                              _buildOrderTypeChip(order['orderType']),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          _buildDateTimeRow(formattedDateTime),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Order Items Section - Always Visible
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Ordered Items',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16.sp,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    ...items.map((item) => _buildOrderItem(item)).toList(),
                    SizedBox(height: 10.h),
                    _buildActionButtons(order, index),
                    SizedBox(height: 10.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderTypeChip(String? orderType) {
    final color = _getOrderTypeColor(orderType);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        (orderType ?? 'UNKNOWN').toString().replaceAll('_', ' '),
        style: TextStyle(
          fontSize: 10.sp,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildDateTimeRow(Map<String, String> formattedDateTime) {
    return Row(
      children: [
        _buildDateTimeChip(
          Icons.calendar_today,
          formattedDateTime['date'] ?? 'N/A',
        ),
        SizedBox(width: 8.w),
        _buildDateTimeChip(
          Icons.access_time,
          formattedDateTime['time'] ?? 'N/A',
        ),
      ],
    );
  }

  Widget _buildDateTimeChip(IconData icon, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.sp, color: Colors.grey[600]),
          SizedBox(width: 4.w),
          Text(
            text,
            style: TextStyle(
              fontSize: 11.sp,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(Map<String, dynamic> item) {
    final listId = item['listId'] ?? 0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Checkbox(
            value: _selectedItems[listId] ?? false,
            onChanged: (value) {
              setState(() {
                _selectedItems[listId] = value ?? false;
              });
            },
            activeColor: Colors.green,
            checkColor: Colors.white,
            shape: CircleBorder(),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              item['dishName'] ?? 'Unknown Item',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
                color: Colors.grey[800],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          _buildInfoChip('Qty: ${item['quantity']}'),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.deepPurple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11.sp,
          color: Colors.deepPurple,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildActionButtons(Map<String, dynamic> order, int index) {
    return Row(
      children: [
        Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            child: ElevatedButton.icon(
              icon: Icon(Icons.check_circle, size: 18.sp),
              label: Text(
                'Accept',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
              ),
              onPressed: () => _handleOrderAction(order, index, 'PROCESSING'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                elevation: 3,
                shadowColor: Colors.green.withOpacity(0.3),
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            child: OutlinedButton.icon(
              icon: Icon(Icons.cancel, size: 18.sp),
              label: Text(
                'Decline',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
              ),
              onPressed: () => _handleOrderAction(order, index, 'CANCELLED'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: BorderSide(color: Colors.red, width: 1.5),
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _getOrderTypeColor(String? orderType) {
    const typeColors = {
      'DELIVERY': Colors.blue,
      'TAKEAWAY': Colors.green,
      'DINE_IN': Colors.orange,
      'TABLE_DINE_IN': Colors.purple,
    };
    return typeColors[orderType?.toUpperCase()] ?? Colors.grey;
  }

  Future<void> _handleOrderAction(
    Map<String, dynamic> order,
    int index,
    String status,
  ) async {
    final orderId = order['orderId'];
    final items = order['order'] ?? [];

    if (status == 'PROCESSING') {
      for (var item in items) {
        final listId = item['listId'];
        final isChecked = _selectedItems[listId] ?? true;

        if (!isChecked) {
          final cancelled = await food_authservice.cancelOrderItem(listId);
          if (cancelled) {
            debugPrint('✅ Item $listId cancelled successfully');
          } else {
            debugPrint('❌ Failed to cancel item $listId');
          }
        }
      }
    }

    final success = await food_authservice.updateOrderStatus(orderId, status);

    if (success && mounted) {
      setState(() {
        widget.orders[index] = Map<String, dynamic>.from(widget.orders[index])
          ..['status'] = status;
      });

      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text('Order $status successfully'),
      //     backgroundColor: Colors.green,
      //     behavior: SnackBarBehavior.floating,
      //     shape: RoundedRectangleBorder(
      //       borderRadius: BorderRadius.circular(12.r),
      //     ),
      //     action: SnackBarAction(
      //       label: 'OK',
      //       textColor: Colors.white,
      //       onPressed: () {},
      //     ),
      //   ),
      // );

      widget.onRefresh();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update order status'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      );
    }
  }

  Map<String, String> _formatDateTime(String? rawDateTime) {
    if (rawDateTime == null) return {'date': 'N/A', 'time': 'N/A'};
    try {
      final parsedDateTime = DateTime.parse(rawDateTime);
      return {
        'date': DateFormat('dd MMM yyyy').format(parsedDateTime),
        'time': DateFormat('hh:mm a').format(parsedDateTime),
      };
    } catch (e) {
      return {'date': 'N/A', 'time': 'N/A'};
    }
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20.r),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
              strokeWidth: 3,
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            'Loading orders...',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String message,
    String? subtitle,
  }) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24.r),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(icon, size: 48.sp, color: Colors.grey[400]),
            ),
            SizedBox(height: 20.h),
            Text(
              message,
              style: TextStyle(
                fontSize: 18.sp,
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              SizedBox(height: 8.h),
              Text(
                subtitle,
                style: TextStyle(fontSize: 14.sp, color: Colors.grey[500]),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ProcessingTab extends StatefulWidget {
  final List<dynamic> orders;
  final bool isLoading;
  final VoidCallback onRefresh;

  const ProcessingTab({
    super.key,
    required this.orders,
    required this.isLoading,
    required this.onRefresh,
  });

  @override
  State<ProcessingTab> createState() => _ProcessingTabState();
}

class _ProcessingTabState extends State<ProcessingTab> {
  final Map<int, bool> _selectedItems = {};

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return _buildLoadingState();
    }

    final pendingOrders = widget.orders
        .where((order) => order['status'] == 'PROCESSING')
        .toList()
        .reversed
        .toList();

    if (pendingOrders.isEmpty) {
      return _buildEmptyState(
        icon: Icons.update,
        message: 'No processing orders',
        subtitle: 'Orders being prepared will appear here',
      );
    }

    return RefreshIndicator(
      onRefresh: () async => widget.onRefresh(),
      backgroundColor: Colors.white,
      color: Colors.purple,
      child: ListView.builder(
        itemCount: pendingOrders.length,
        padding: EdgeInsets.all(16.w),
        itemBuilder: (context, index) {
          return _buildOrderCard(pendingOrders[index], index);
        },
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order, int index) {
    final items = order['order'] ?? [];
    final formattedDateTime = _formatDateTime(order['orderDateAndTime']);

    return AnimatedContainer(
      duration: Duration(milliseconds: 300 + (index * 100)),
      curve: Curves.easeInOut,
      margin: EdgeInsets.only(bottom: 16.h),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        elevation: 4,
        shadowColor: Colors.orange.withOpacity(0.1),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.r),
            color: Colors.white,
          ),
          child: Column(
            children: [
              // Header Section
              Padding(
                padding: EdgeInsets.all(16.r),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Order #${order['orderId'] ?? 'N/A'}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.sp,
                                  color: Colors.grey[800],
                                ),
                              ),
                              _buildOrderTypeChip(order['orderType']),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          _buildDateTimeRow(formattedDateTime),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Order Items Section
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Ordered Items',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16.sp,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    ...items.map((item) => _buildOrderItem(item)).toList(),
                    SizedBox(height: 24.h),
                    _buildActionButtons(order, index),
                    SizedBox(height: 16.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderTypeChip(String? orderType) {
    final color = _getOrderTypeColor(orderType);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        (orderType ?? 'UNKNOWN').toString().replaceAll('_', ' '),
        style: TextStyle(
          fontSize: 10.sp,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildDateTimeRow(Map<String, String> formattedDateTime) {
    return Row(
      children: [
        _buildDateTimeChip(
          Icons.calendar_today,
          formattedDateTime['date'] ?? 'N/A',
        ),
        SizedBox(width: 8.w),
        _buildDateTimeChip(
          Icons.access_time,
          formattedDateTime['time'] ?? 'N/A',
        ),
      ],
    );
  }

  Widget _buildDateTimeChip(IconData icon, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.sp, color: Colors.grey[600]),
          SizedBox(width: 4.w),
          Text(
            text,
            style: TextStyle(
              fontSize: 11.sp,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(Map<String, dynamic> item) {
    final listId = item['listId'] ?? 0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Checkbox(
            value: _selectedItems[listId] ?? false,
            onChanged: (value) {
              setState(() {
                _selectedItems[listId] = value ?? false;
              });
            },
            activeColor: Colors.green,
            checkColor: Colors.white,
            shape: CircleBorder(),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),

          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              item['dishName'] ?? 'Unknown Item',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
                color: Colors.grey[800],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          _buildInfoChip('Qty: ${item['quantity']}'),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11.sp,
          color: Colors.orange,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildActionButtons(Map<String, dynamic> order, int index) {
    return Row(
      children: [
        Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            child: ElevatedButton.icon(
              icon: Icon(Icons.delivery_dining, size: 18.sp),
              label: Text(
                'Delivered',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
              ),
              onPressed: () => _handleOrderAction(order, index, 'DELIVERED'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                elevation: 3,
                shadowColor: Colors.green.withOpacity(0.3),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _getOrderTypeColor(String? orderType) {
    const typeColors = {
      'DELIVERY': Colors.blue,
      'TAKEAWAY': Colors.green,
      'DINE_IN': Colors.orange,
      'TABLE_DINE_IN': Colors.purple,
    };
    return typeColors[orderType?.toUpperCase()] ?? Colors.grey;
  }

  Future<void> _handleOrderAction(
    Map<String, dynamic> order,
    int index,
    String status,
  ) async {
    final orderId = order['orderId'];
    final success = await food_authservice.updateOrderStatus(orderId, status);

    if (success && mounted) {
      setState(() {
        widget.orders[index] = Map<String, dynamic>.from(widget.orders[index])
          ..['status'] = status;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order marked as $status'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      );

      widget.onRefresh();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update order status'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      );
    }
  }

  Map<String, String> _formatDateTime(String? rawDateTime) {
    if (rawDateTime == null) return {'date': 'N/A', 'time': 'N/A'};
    try {
      final parsedDateTime = DateTime.parse(rawDateTime);
      return {
        'date': DateFormat('dd MMM yyyy').format(parsedDateTime),
        'time': DateFormat('hh:mm a').format(parsedDateTime),
      };
    } catch (e) {
      return {'date': 'N/A', 'time': 'N/A'};
    }
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20.r),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
              strokeWidth: 3,
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            'Loading orders...',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String message,
    String? subtitle,
  }) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24.r),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(icon, size: 48.sp, color: Colors.grey[400]),
            ),
            SizedBox(height: 20.h),
            Text(
              message,
              style: TextStyle(
                fontSize: 18.sp,
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              SizedBox(height: 8.h),
              Text(
                subtitle,
                style: TextStyle(fontSize: 14.sp, color: Colors.grey[500]),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ReportsTab - Fixed to remove dropdown
class ReportsTab extends StatefulWidget {
  final List<dynamic> orders;
  final bool isLoading;

  const ReportsTab({super.key, required this.orders, required this.isLoading});

  @override
  State<ReportsTab> createState() => _ReportsTabState();
}

class _ReportsTabState extends State<ReportsTab> {
  String? _selectedDay, _selectedMonth, _selectedYear, _selectedStatus;

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) return _buildLoadingState();
    if (widget.orders.isEmpty) return _buildEmptyState();

    final filteredOrders = _getFilteredOrders();

    return Column(
      children: [Expanded(child: _buildOrdersList(filteredOrders))],
    );
  }

  Widget _buildOrdersList(List<Map<String, dynamic>> filteredOrders) {
    if (filteredOrders.isEmpty) return _buildNoResultsState();

    return ListView.builder(
      padding: EdgeInsets.all(16.r),
      itemCount: filteredOrders.length,
      itemBuilder: (context, index) {
        return _buildOrderCard(filteredOrders[index], index);
      },
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order, int index) {
    final formattedDateTime = _formatDateTime(order['orderDateAndTime']);
    final totalAmount = _calculateTotalAmount(order);

    return AnimatedContainer(
      duration: Duration(milliseconds: 300 + (index * 100)),
      margin: EdgeInsets.only(bottom: 12.h),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        elevation: 3,
        shadowColor: Colors.green.withOpacity(0.1),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            color: Colors.white,
          ),
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 45.w,
                      height: 45.h,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.green, Colors.lightGreen],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.assignment_turned_in,
                        color: Colors.white,
                        size: 20.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order #${order['orderId']}',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15.sp,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            '${formattedDateTime['date']} • ${formattedDateTime['time']}',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'Total: ₹$totalAmount',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                ..._buildOrderDetails(order),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildOrderDetails(Map<String, dynamic> order) {
    final items = order['order'] ?? [];

    return [
      _buildDetailRow(
        'Order Type',
        (order['orderType'] ?? 'N/A').toString().replaceAll('_', ' '),
      ),
      _buildDetailRow('Status', order['status'] ?? 'N/A'),
      SizedBox(height: 16.h),
      Text(
        'Order Items',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15.sp,
          color: Colors.grey[800],
        ),
      ),
      SizedBox(height: 12.h),
      ...items.map((item) => _buildOrderItem(item)).toList(),
    ];
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.sp),
          ),
          Expanded(
            child: Text(value, style: TextStyle(fontSize: 13.sp)),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(Map<String, dynamic> item) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              item['dishName'] ?? 'Unknown Item',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14.sp),
            ),
          ),
          Text(
            'Qty: ${item['quantity']}',
            style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  double _calculateTotalAmount(Map<String, dynamic> order) {
    final items = order['order'] ?? [];
    double total = 0;
    for (var item in items) {
      total += (item['totalPrice'] ?? 0).toDouble();
    }
    return total;
  }

  bool get _hasActiveFilters =>
      _selectedDay != null ||
      _selectedMonth != null ||
      _selectedYear != null ||
      _selectedStatus != null;

  List<Map<String, dynamic>> _getFilteredOrders() {
    List<Map<String, dynamic>> filteredOrders = List.from(widget.orders);
    filteredOrders = filteredOrders.where((order) {
      final status = (order['status'] ?? '').toString().toUpperCase();
      return status == 'DELIVERED';
    }).toList();

    if (_selectedStatus != null && _selectedStatus != 'All') {
      filteredOrders = filteredOrders
          .where((order) => order['status'] == _selectedStatus)
          .toList();
    }

    return filteredOrders;
  }

  void _clearFilters() => setState(() {
    _selectedDay = _selectedMonth = _selectedYear = _selectedStatus = null;
  });

  void _showFilterDialog() {
    // Filter dialog implementation
  }

  Map<String, String> _formatDateTime(String? rawDateTime) {
    if (rawDateTime == null) return {'date': 'N/A', 'time': 'N/A'};
    try {
      final parsedDateTime = DateTime.parse(rawDateTime);
      return {
        'date': DateFormat('dd MMM yyyy').format(parsedDateTime),
        'time': DateFormat('hh:mm a').format(parsedDateTime),
      };
    } catch (e) {
      return {'date': 'N/A', 'time': 'N/A'};
    }
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20.r),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              strokeWidth: 3,
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            'Loading reports...',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24.r),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(
                Icons.bar_chart,
                size: 48.sp,
                color: Colors.grey[400],
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'No completed orders',
              style: TextStyle(
                fontSize: 18.sp,
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Delivered orders will appear here',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24.r),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(
                Icons.search_off,
                size: 48.sp,
                color: Colors.grey[400],
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'No orders found',
              style: TextStyle(
                fontSize: 18.sp,
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Try adjusting your filters',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }
}
