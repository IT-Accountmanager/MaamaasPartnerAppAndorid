import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../Api/food_authservice.dart';
import '../widgets_helper/food/footer.dart';

class OrderManagementBasic extends StatefulWidget {
  const OrderManagementBasic({super.key});

  @override
  State<OrderManagementBasic> createState() => _OrderManagementState();
}

class _OrderManagementState extends State<OrderManagementBasic> {
  final List<String> _tabTitles = ["All", "Processing", "Delivery", "Reports"];
  int _selectedTab = 0;
  bool _isDrawerOpen = false;
  List<dynamic> _orders = [];
  bool _isLoading = true;

  void _toggleDrawer() => setState(() => _isDrawerOpen = !_isDrawerOpen);

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
      // appBar: AppBar(
      //   title: const Text(
      //     "Order Management",
      //     style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      //   ),
      //   centerTitle: true,
      //   elevation: 0,
      //   backgroundColor: Colors.deepPurple,
      //   shape: const RoundedRectangleBorder(
      //     borderRadius: BorderRadius.vertical(
      //       bottom: Radius.circular(20),
      //     ),
      //   ),
      //   iconTheme: const IconThemeData(color: Colors.white),
      // ),
      body: Column(
        children: [
          // Tab Bar
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
                  ProcessingTab(orders: _orders, isLoading: _isLoading),
                  DeliveryTab(
                    orders: _orders,
                    isLoading: _isLoading,
                    onRefresh: _fetchOrders, // Make sure this is added
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
      margin: EdgeInsets.symmetric(horizontal: 16.r, vertical: 16.r),
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
        .where((order) => order['status'] == 'PENDING')
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
        .where((order) => order['status'] == 'PENDING')
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
      color: Colors.blue,
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
    final isExpanded = _expandedStates[index] ?? false;
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
        shadowColor: Colors.blue.withOpacity(0.1),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.r),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Colors.blue[50]!],
            ),
          ),
          child: Column(
            children: [
              // Header Section
              Padding(
                padding: EdgeInsets.all(16.r),
                child: Row(
                  children: [
                    Container(
                      width: 50.w,
                      height: 50.h,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue, Colors.lightBlue],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.shopping_bag_outlined,
                        color: Colors.white,
                        size: 22.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
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
                        Icon(
                          Icons.restaurant_menu,
                          size: 18.sp,
                          color: Colors.blue,
                        ),
                        SizedBox(width: 8.w),
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
          Container(
            padding: EdgeInsets.all(2.r),
            decoration: BoxDecoration(
              color: (_selectedItems[listId] ?? false)
                  ? Colors.green
                  : Colors.grey[300],
              shape: BoxShape.circle,
            ),
            child: Checkbox(
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
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['dishName'] ?? 'Unknown Item',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                    color: Colors.grey[800],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    _buildInfoChip('Qty: ${item['quantity']}'),
                    SizedBox(width: 8.w),
                    Text(
                      '₹${item['price']} each',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Total',
                style: TextStyle(
                  fontSize: 11.sp,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '₹${item['totalPrice']}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11.sp,
          color: Colors.blue,
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
              onPressed: () => _handleOrderAction(order, index, 'CONFIRMED'),
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

    if (status == 'CONFIRMED') {
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order $status successfully'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {},
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
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
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

class ProcessingTab extends StatelessWidget {
  final List<dynamic> orders;
  final bool isLoading;

  const ProcessingTab({
    super.key,
    required this.orders,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) return _buildLoadingState();

    final processingOrders = orders
        .where(
          (order) => [
            'CONFIRMED',
            'BEING_PREPARED',
            'ORDER_IS_READY',
            'WAITING_FOR_PICKUP',
            'PROCESSING',
          ].contains(order['status']),
        )
        .toList();

    if (processingOrders.isEmpty) {
      return _buildEmptyState(
        icon: Icons.local_shipping_outlined,
        message: 'No active orders at the moment',
        subtitle: 'Processing orders will appear here',
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: processingOrders.length,
      itemBuilder: (context, index) {
        return _buildOrderCard(processingOrders[index], context, index);
      },
    );
  }

  Widget _buildOrderCard(
    Map<String, dynamic> order,
    BuildContext context,
    int index,
  ) {
    final String currentStatus = order['status'] ?? 'UNKNOWN';
    final formattedDateTime = _formatDateTime(order['orderDateAndTime']);

    return AnimatedContainer(
      duration: Duration(milliseconds: 300 + (index * 100)),
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
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Colors.orange[50]!],
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 50.w,
                          height: 50.h,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.orange, Colors.deepOrange],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.orange.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.update,
                            color: Colors.white,
                            size: 22.sp,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Order #${order['orderId']}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.sp,
                                color: Colors.grey[800],
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              '${formattedDateTime['date']} • ${formattedDateTime['time']}',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    _buildOrderTypeChip(order['orderType']),
                  ],
                ),
                SizedBox(height: 20.h),
                _buildProgressStepper(currentStatus),
              ],
            ),
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

  Color _getOrderTypeColor(String? orderType) {
    const typeColors = {
      'DELIVERY': Colors.blue,
      'TAKEAWAY': Colors.green,
      'DINE_IN': Colors.orange,
      'TABLE_DINE_IN': Colors.purple,
    };
    return typeColors[orderType?.toUpperCase()] ?? Colors.grey;
  }

  Widget _buildProgressStepper(String currentStatus) {
    final steps = [
      {'key': 'CONFIRMED', 'icon': Icons.check, 'label': 'Confirmed'},
      {'key': 'BEING_PREPARED', 'icon': Icons.restaurant, 'label': 'Preparing'},
      {
        'key': 'ORDER_IS_READY',
        'icon': Icons.fastfood_outlined,
        'label': 'Ready',
      },
      {
        'key': 'PROCESSING',
        'icon': Icons.delivery_dining,
        'label': 'On The Way',
      },
      {'key': 'DELIVERED', 'icon': Icons.done_all, 'label': 'Delivered'},
    ];

    final currentIndex = steps.indexWhere((s) => s['key'] == currentStatus);
    final activeIndex = currentIndex != -1 ? currentIndex : 0;

    return Column(
      children: [
        // Progress bar
        Container(
          margin: EdgeInsets.symmetric(vertical: 16.h),
          height: 6.h,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3.r),
            child: LinearProgressIndicator(
              value: (activeIndex + 1) / steps.length,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                _getStatusColor(currentStatus),
              ),
            ),
          ),
        ),

        // Step Circles
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: steps.asMap().entries.map((entry) {
            final index = entry.key;
            final step = entry.value;
            final bool isCompleted = index < activeIndex;
            final bool isCurrent = index == activeIndex;

            Color circleColor = isCompleted
                ? Colors.green
                : isCurrent
                ? _getStatusColor(currentStatus)
                : Colors.grey[300]!;

            return Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 36.w,
                  height: 36.h,
                  decoration: BoxDecoration(
                    color: circleColor,
                    shape: BoxShape.circle,
                    boxShadow: isCurrent
                        ? [
                            BoxShadow(
                              color: circleColor.withOpacity(0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    step['icon'] as IconData,
                    color: isCompleted || isCurrent
                        ? Colors.white
                        : Colors.grey[600],
                    size: 16.sp,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  step['label'] as String,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: isCompleted || isCurrent
                        ? Colors.black87
                        : Colors.grey[500],
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'CONFIRMED':
        return Colors.blue;
      case 'BEING_PREPARED':
        return Colors.orange;
      case 'ORDER_IS_READY':
        return Colors.purple;
      case 'PROCESSING':
        return Colors.teal;
      case 'DELIVERED':
        return Colors.green;
      default:
        return Colors.grey;
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
    } catch (_) {
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

class DeliveryTab extends StatefulWidget {
  final List<dynamic> orders;
  final bool isLoading;
  final VoidCallback? onRefresh;

  const DeliveryTab({
    super.key,
    required this.orders,
    required this.isLoading,
    this.onRefresh,
  });

  @override
  State<DeliveryTab> createState() => _DeliveryTabState();
}

class _DeliveryTabState extends State<DeliveryTab> {
  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return _buildLoadingState();
    }

    // Show only delivery orders that are NOT delivered yet
    final deliveryOrders = widget.orders
        .where(
          (order) =>
              (order['orderType'] ?? '').toString().toUpperCase() ==
                  'DELIVERY' &&
              (order['status'] ?? '').toString().toUpperCase() != 'DELIVERED' &&
              (order['status'] ?? '').toString().toUpperCase() != 'COMPLETED',
        )
        .toList();

    if (deliveryOrders.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        if (widget.onRefresh != null) {
          widget.onRefresh!();
        }
      },
      child: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: deliveryOrders.length,
        itemBuilder: (context, index) {
          return _buildOrderCard(deliveryOrders[index], index);
        },
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order, int index) {
    final formattedDateTime = _formatDateTime(order['orderDateAndTime']);
    final items = order['order'] ?? [];
    final currentStatus = order['status'] ?? 'PENDING';

    return AnimatedContainer(
      duration: Duration(milliseconds: 300 + (index * 100)),
      margin: EdgeInsets.only(bottom: 16.h),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        elevation: 4,
        shadowColor: Colors.blue.withOpacity(0.1),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.r),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Colors.blue[50]!],
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 50.w,
                          height: 50.h,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.blue, Colors.lightBlue],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.delivery_dining,
                            color: Colors.white,
                            size: 22.sp,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Order #${order['orderId']}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.sp,
                                color: Colors.grey[800],
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              '${formattedDateTime['date']} • ${formattedDateTime['time']}',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    _buildStatusChip(currentStatus),
                  ],
                ),
                SizedBox(height: 16.h),

                // Customer Info
                if (order['customerName'] != null ||
                    order['deliveryAddress'] != null) ...[
                  _buildCustomerInfo(order),
                  SizedBox(height: 12.h),
                ],

                // Order Items
                Text(
                  'Order Items:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 8.h),
                ...items.map((item) => _buildOrderItem(item)).toList(),

                SizedBox(height: 16.h),
                _buildActionButtons(order, currentStatus),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerInfo(Map<String, dynamic> order) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Delivery Info',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14.sp,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 8.h),
          if (order['customerName'] != null)
            Row(
              children: [
                Icon(Icons.person, size: 16.sp, color: Colors.grey[600]),
                SizedBox(width: 8.w),
                Text(
                  '${order['customerName']}',
                  style: TextStyle(fontSize: 13.sp, color: Colors.grey[700]),
                ),
              ],
            ),
          if (order['deliveryAddress'] != null) ...[
            SizedBox(height: 4.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.location_on, size: 16.sp, color: Colors.grey[600]),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    '${order['deliveryAddress']}',
                    style: TextStyle(fontSize: 13.sp, color: Colors.grey[700]),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    final color = _getStatusColor(status);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15.r),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 10.sp,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildOrderItem(Map<String, dynamic> item) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['dishName'] ?? 'Unknown Item',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Text(
                      'Qty: ${item['quantity']}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      '₹${item['price']} each',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Text(
            '₹${item['totalPrice']}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.sp,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(Map<String, dynamic> order, String currentStatus) {
    return Row(
      children: [
        if (currentStatus == 'PENDING' || currentStatus == 'CONFIRMED')
          Expanded(
            child: ElevatedButton.icon(
              icon: Icon(Icons.directions_bike, size: 18.sp),
              label: Text('Start Delivery', style: TextStyle(fontSize: 14.sp)),
              onPressed: () => _updateOrderStatus(order, 'PROCESSING'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ),
        if (currentStatus == 'PROCESSING') ...[
          Expanded(
            child: ElevatedButton.icon(
              icon: Icon(Icons.check_circle, size: 18.sp),
              label: Text('Mark Delivered', style: TextStyle(fontSize: 14.sp)),
              onPressed: () => _updateOrderStatus(order, 'DELIVERED'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _updateOrderStatus(
    Map<String, dynamic> order,
    String newStatus,
  ) async {
    final orderId = order['orderId'];

    try {
      final success = await food_authservice.updateOrderStatus(
        orderId,
        newStatus,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order status updated to $newStatus'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
        );

        // Refresh the orders list
        if (widget.onRefresh != null) {
          widget.onRefresh!();
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update order status'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating order: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'DELIVERED':
        return Colors.green;
      case 'PROCESSING':
        return Colors.orange;
      case 'CONFIRMED':
        return Colors.blue;
      case 'PENDING':
        return Colors.red;
      default:
        return Colors.grey;
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
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              strokeWidth: 3,
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            'Loading delivery orders...',
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
                Icons.delivery_dining,
                size: 48.sp,
                color: Colors.grey[400],
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'No delivery orders',
              style: TextStyle(
                fontSize: 18.sp,
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              'All delivery orders are completed or no orders available',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

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
      children: [
        _buildFilterHeader(filteredOrders.length),
        Expanded(child: _buildOrdersList(filteredOrders)),
      ],
    );
  }

  Widget _buildFilterHeader(int orderCount) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order Reports',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Completed and cancelled orders',
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          if (_hasActiveFilters)
            Container(
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: TextButton(
                onPressed: _clearFilters,
                child: Text(
                  'Clear Filters',
                  style: TextStyle(color: Colors.red, fontSize: 12.sp),
                ),
              ),
            ),
          SizedBox(width: 8.w),
          Container(
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: IconButton(
              icon: Icon(Icons.filter_alt, size: 20.sp, color: Colors.green),
              onPressed: _showFilterDialog,
            ),
          ),
        ],
      ),
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
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Colors.green[50]!],
            ),
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
                    _buildStatusChip(order['status']),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['dishName'] ?? 'Unknown Item',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Text(
                      'Qty: ${item['quantity']}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      '₹${item['price']} each',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Total',
                style: TextStyle(fontSize: 11.sp, color: Colors.grey[600]),
              ),
              Text(
                '₹${item['totalPrice']}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15.sp,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String? status) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: _getStatusColor(status),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        status ?? 'N/A',
        style: TextStyle(
          fontSize: 10.sp,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    const statusColors = {
      'COMPLETED': Colors.green,
      'DELIVERED': Colors.green,
      'CANCELLED': Colors.red,
    };
    return statusColors[status] ?? Colors.grey;
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
      return status == 'COMPLETED' ||
          status == 'CANCELLED' ||
          status == 'DELIVERED';
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
              'No orders to display',
              style: TextStyle(
                fontSize: 18.sp,
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Completed orders will appear here',
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
