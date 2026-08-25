import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:maamaaspartner/user_module/screens/tickets_screen.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../API/delivery_service.dart';
import '../API/food_authservice.dart';
import '../Models/delivery/fooddelivery.dart';
import '../Models/orders_model.dart';
import 'Food&beverages/table_bookings.dart';
import 'catering_orders.dart';

enum OrderVertical { food, catering, groceries, table }

class AppStyles {
  static EdgeInsets get cardPadding => EdgeInsets.all(16.w);
  static EdgeInsets get sectionPadding => EdgeInsets.symmetric(vertical: 8.h);
  static TextStyle get titleStyle => TextStyle(
    fontSize: 18.sp,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );
  static TextStyle get subtitleStyle =>
      TextStyle(fontSize: 14.sp, color: Colors.grey[600]);
}

class OrdersScreen extends StatefulWidget {
  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool isLoading = true;
  List<Order> orders = [];
  bool isDrawerOpen = false;

  DeliveryOrderModel? deliveryorder;
  OrderVertical _selectedVertical = OrderVertical.food;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    try {
      final response = await food_Authservice.getAllOrdersByUserId();
      setState(() {
        orders = response.map((json) => Order.fromJson(json)).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading orders: $e')));
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        // 👇 this actually increases usable height
        toolbarHeight: 100,

        automaticallyImplyLeading: true,

        flexibleSpace: SafeArea(child: Center(child: _buildVerticalChips())),
      ),

      body: SafeArea(child: _buildOrdersByVertical()),
    );
  }

  Widget _buildVerticalChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: OrderVertical.values.map((vertical) {
          final isSelected = _selectedVertical == vertical;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: GestureDetector(
              onTap: () => setState(() => _selectedVertical = vertical),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? const Color(0xFF6C63FF) : Colors.white,
                  boxShadow: [
                    if (isSelected)
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                  ],
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF6C63FF)
                        : Colors.grey.shade300,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _verticalIcon(vertical),
                      size: 22,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _shortLabel(vertical),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _shortLabel(OrderVertical v) {
    switch (v) {
      case OrderVertical.food:
        return "Food";
      case OrderVertical.table:
        return "Table";
      case OrderVertical.catering:
        return "Catering";
      case OrderVertical.groceries:
        return "Grocery";
    }
  }

  IconData _verticalIcon(OrderVertical v) {
    switch (v) {
      case OrderVertical.food:
        return Icons.fastfood;
      case OrderVertical.table:
        return Icons.event_seat;
      case OrderVertical.catering:
        return Icons.restaurant;
      case OrderVertical.groceries:
        return Icons.local_grocery_store;
    }
  }

  Widget _buildOrdersByVertical() {
    switch (_selectedVertical) {
      case OrderVertical.food:
        return _buildFoodOrderList();
      case OrderVertical.table:
        return TableBookings();
      case OrderVertical.catering:
        return CateringOrdersScreen();
      case OrderVertical.groceries:
        return _buildGroceryOrderList();
    }
  }

  Widget _buildGroceryOrderList() {
    return const Center(child: Text("Grocery Orders"));
  }

  Widget _buildFoodOrderList() {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    final activeOrders = orders
        .where((order) => order.isActive)
        .toList()
        .reversed
        .toList();
    final pastOrders = orders
        .where((order) => !order.isActive)
        .toList()
        .reversed
        .toList();

    if (orders.isEmpty) {
      return Center(
        child: Text("No Food orders found", style: AppStyles.subtitleStyle),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadOrders,
      child: ListView(
        padding: AppStyles.cardPadding,
        children: [
          if (activeOrders.isNotEmpty) ...[
            Text("Active Orders", style: AppStyles.titleStyle),
            SizedBox(height: 8.h),
            ...activeOrders.map(
              (order) => OrderCard(
                order: order,
                isActive: true,
                onTap: () => _navigateToOrderDetails(context, order),
              ),
            ),
            SizedBox(height: 16.h),
          ],
          if (pastOrders.isNotEmpty) ...[
            Text("Past Orders", style: AppStyles.titleStyle),
            SizedBox(height: 8.h),
            ...pastOrders.map(
              (order) => OrderCard(
                order: order,
                isActive: false,
                onTap: () => _navigateToOrderDetails(context, order),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _navigateToOrderDetails(BuildContext context, Order order) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OrderDetailsScreen(
          orderId: order.orderId,
          order: order,
          // deliveryModel: deliveryorder,
          formattedDate: DateFormat('dd MMM yyyy').format(order.parsedDateTime),
          formattedTime: DateFormat('hh:mm a').format(order.parsedDateTime),
          items: order.items,
          isActive: order.isActive,
          date: order.date,
          time: order.time,
        ),
      ),
    );
  }
}

class OrderCard extends StatefulWidget {
  final Order order;
  final bool isActive;
  final VoidCallback onTap;

  const OrderCard({
    Key? key,
    required this.order,
    required this.isActive,
    required this.onTap,
  }) : super(key: key);

  @override
  State<OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard> {
  int currentRating = 0;
  bool isLoading = true;
  late bool isCancelled;
  Map<int, bool> _submittedOrders = {};

  @override
  void initState() {
    super.initState();
    isCancelled = widget.order.status == OrderStatus.cancelled;
    _fetchRating();
  }

  Future<void> _fetchRating() async {
    setState(() => isLoading = true);

    final rating = await food_Authservice.fetchRating(widget.order.orderId);

    setState(() {
      currentRating = rating;
      isLoading = false;
    });
  }

  Future<bool> _submitRating(int rating) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

    if (userId == null) return false;

    final success = await food_Authservice.submitRating(
      userId,
      widget.order.orderId,
      rating,
    );

    if (!mounted) return false;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? "Thank you! Your feedback has been submitted."
              : "Failed to submit feedback. Please try again.",
        ),
        backgroundColor: success ? Colors.green : Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );

    return success;
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;

    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: _getStatusColor(
            order.status,
            // ignore: deprecated_member_use
          ).withOpacity(isCancelled ? 0.2 : 0.4),
          width: 1,
        ),
      ),
      // color: isCancelled ? Colors.grey[100] : null,
      color: isCancelled ? Colors.grey[100] : Color(0xFFF8FAFC),
      child: InkWell(
        onTap: widget.onTap,
        child: Padding(
          padding: AppStyles.cardPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(widget.order),
              if (widget.isActive) _buildProgressIndicator(order),
              if (isCancelled) _buildCancelledBadge(widget.order),
              if (!widget.isActive &&
                  !order.isRated &&
                  order.status == OrderStatus.completed &&
                  !isCancelled)
                _buildRatingButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCancelledBadge(Order order) {
    return Container(
      margin: EdgeInsets.only(top: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'Cancelled',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w500,
          fontSize: 12.sp,
        ),
      ),
    );
  }

  Widget _buildRatingButton(BuildContext context) {
    final orderId = widget.order.orderId;
    final isSubmitted = _submittedOrders[orderId] ?? false;

    return Column(
      children: [
        Divider(),
        Text("Rate Order", style: TextStyle(fontSize: 16)),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            return GestureDetector(
              onTap: isSubmitted
                  ? null
                  : () async {
                      setState(() {
                        currentRating = index + 1;
                      });

                      bool success = await _submitRating(currentRating);
                      if (success) {
                        setState(() {
                          _submittedOrders[orderId] =
                              true; // mark this order as rated
                        });
                      }
                    },
              child: Icon(
                index < currentRating ? Icons.star : Icons.star_border,
                size: 36,
                color: Colors.amber,
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildHeader(Order order) {
    final dateTime = DateTime.parse(order.orderDateAndTime);
    final formattedDate = DateFormat('dd MMM yyyy').format(dateTime);
    final formattedTime = DateFormat('hh:mm a').format(dateTime);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                "Order ID: ${order.id}",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    order.orderType
                        .toString()
                        .split('.')
                        .last, // e.g., 'DINE_IN'
                    style: TextStyle(color: Colors.white, fontSize: 12.sp),
                  ),
                ),
                SizedBox(width: 8), // spacing between status chip and icon
                Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              ],
            ),
          ],
        ),
        SizedBox(height: 8),
        Text("Date: $formattedDate", style: AppStyles.subtitleStyle),
        Text("Time: $formattedTime", style: AppStyles.subtitleStyle),
      ],
    );
  }

  Widget _buildProgressIndicator(Order order) {
    // Determine intermediate status label
    String intermediateStatus;
    if (order.status == OrderStatus.hold) {
      intermediateStatus = "Pending";
    } else if (order.status == OrderStatus.pending) {
      intermediateStatus = "Not accepted";
    } else if (order.status == OrderStatus.confirmed) {
      intermediateStatus = "Order Confirmed";
    } else if (order.status == OrderStatus.beingPrepared) {
      intermediateStatus = "Preparing";
    } else if (order.status == OrderStatus.orderIsReady) {
      intermediateStatus = "Order Prepared";
    } else if (order.status == OrderStatus.waitingForPickup) {
      intermediateStatus = "waiting for Pickup";
    } else if (order.status == OrderStatus.ontheway) {
      intermediateStatus = "On the Way";
    } else if (order.status == OrderStatus.completed) {
      intermediateStatus = "Delivered";
    } else {
      intermediateStatus = "Not accepted";
    }

    return SizedBox(
      height: 100.h,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Confirmed Step
          _buildProgressStep(
            icon: "✅",
            label: "Confirmed",
            isCompleted: order.status != OrderStatus.confirmed ? true : false,
          ),

          // Intermediate Status
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                intermediateStatus,
                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 4.h),
              Icon(Icons.circle, size: 12.sp, color: Colors.grey),
            ],
          ),

          // Delivered Step
          _buildProgressStep(
            icon: "📦",
            label: "Delivered",
            isCompleted: order.status == OrderStatus.completed,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressStep({
    required String icon,
    required String label,
    required bool isCompleted,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 30.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: isCompleted ? Colors.green : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: isCompleted ? Colors.green : Colors.grey,
                width: 1.w,
              ),
            ),
            child: Center(
              child: Text(icon, style: TextStyle(fontSize: 20.sp)),
            ),
          ),
          SizedBox(height: 5.h),
          SizedBox(
            width: 70.w,
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12.sp),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.cancelled:
        return Colors.red;
      case OrderStatus.completed:
        return Colors.green;
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.confirmed:
      case OrderStatus.beingPrepared:
      case OrderStatus.processing:
      case OrderStatus.waitingForPickup:
      case OrderStatus.orderIsReady:
        return Colors.blue;
      default:
        return Colors.blueGrey;
    }
  }
}

const trackingStatuses = {
  'WAITING_FOR_PICKUP',
  'OUT_FOR_DELIVERY',
  'DELIVERING',
};

extension OrderStatusX on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.hold:
        return "Pending";
      case OrderStatus.pending:
        return "Not accepted";
      case OrderStatus.confirmed:
        return "Confirmed";
      case OrderStatus.beingPrepared:
        return "Preparing";
      case OrderStatus.orderIsReady:
        return "Order is Ready";
      case OrderStatus.waitingForPickup:
        return "Waiting for Pickup";
      case OrderStatus.ontheway:
        return "On the Way";
      case OrderStatus.completed:
        return "Delivered";
      case OrderStatus.cancelled:
        return "Cancelled";
      case OrderStatus.unknown:
      default:
        return "Unknown";
    }
  }
}

class OrderDetailsScreen extends StatefulWidget {
  final int orderId;
  final Order order;
  final String formattedDate;
  final String formattedTime;
  final List<OrderItem> items;
  final bool isActive;
  final String date;
  final String time;

  const OrderDetailsScreen({
    required this.orderId,
    required this.order,
    required this.formattedDate,
    required this.formattedTime,
    required this.items,
    required this.isActive,
    required this.date,
    required this.time,
  });

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  DeliveryOrderModel? delivery;
  DeliveryOrderModel? deliveryModel;
  bool isLoadingDelivery = true;
  @override
  void initState() {
    super.initState();
    _loadDeliveryOrder();
  }

  Future<void> _loadDeliveryOrder() async {
    try {
      final result = await DeliveryOrderService.getOrder(widget.order.orderId);

      setState(() {
        deliveryModel = result;
        isLoadingDelivery = false;
      });
    } catch (e) {
      isLoadingDelivery = false;
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isScheduled = widget.order.sheduled == true;
    final bool hasDeliveryModel = deliveryModel != null;

    final bool showDeliveryWidget =
        widget.order.orderType == OrderType.DELIVERY &&
        widget.order.status == OrderStatus.confirmed;

    final bool showAssignedPartner =
        widget.order.orderType == OrderType.DELIVERY &&
        hasDeliveryModel &&
        widget.order.status != OrderStatus.completed;

    final bool showLiveTracking =
        widget.order.orderType == OrderType.DELIVERY &&
        hasDeliveryModel &&
        [
          // OrderStatus.,
          OrderStatus.orderIsReady,
          OrderStatus.waitingForPickup,
          OrderStatus.ontheway,
        ].contains(widget.order.status);

    final bool showPartnerAfterCompletion =
        widget.order.orderType == OrderType.DELIVERY &&
        hasDeliveryModel &&
        widget.order.status == OrderStatus.completed;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50),
        child: AppBar(
          backgroundColor: Colors.white,
          title: Text("Order Details"),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppStyles.cardPadding,

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Order #${widget.order.id}",
                    style: AppStyles.titleStyle.copyWith(fontSize: 18.sp),
                  ),
                  Chip(
                    label: Text(
                      widget.order.status.label,
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: _getStatusColor(widget.order.status),
                  ),
                ],
              ),

              SizedBox(height: 12.h),

              /// BASIC INFO
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: Colors.grey.shade100,
                child: Padding(
                  padding: EdgeInsets.all(12.w),
                  child: Column(
                    children: [
                      _infoRow(
                        Icons.calendar_today,
                        "Date",
                        widget.formattedDate,
                      ),
                      _infoRow(Icons.access_time, "Time", widget.formattedTime),
                      _infoRow(
                        Icons.local_shipping,
                        "Order Type",
                        widget.order.orderType.name.replaceAll('_', ' '),
                        isBold: true,
                      ),
                    ],
                  ),
                ),
              ),

              /// SCHEDULED DETAILS
              if (isScheduled) ...[
                SizedBox(height: 14.h),
                Text(
                  "Scheduled Details",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),

                Card(
                  color: Colors.blue.shade50,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(12.w),
                    child: Column(
                      children: [
                        _infoRow(Icons.event, "Date", widget.order.date),
                        _infoRow(Icons.schedule, "Time", widget.order.time),
                      ],
                    ),
                  ),
                ),
              ],

              /// DELIVERY DETAILS
              if (widget.order.orderType == OrderType.DELIVERY) ...[
                SizedBox(height: 14.h),
                Text(
                  "Delivery Details",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),

                Card(
                  color: Colors.green.shade50,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(12.w),
                    child: Column(
                      children: [
                        if (showDeliveryWidget)
                          const Text(
                            "Waiting for delivery partner to be assigned",
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),

                        if (showAssignedPartner ||
                            showLiveTracking ||
                            showPartnerAfterCompletion)
                          LiveDeliveryTracking(orderId: widget.order.orderId),
                      ],
                    ),
                  ),
                ),
              ],

              SizedBox(height: 12.h),

              /// LIVE TRACKING
              // (widget.order.orderType == OrderType.DELIVERY &&
              //         widget.order.status == OrderStatus.orderIsReady &&
              //         widget.order.status == OrderStatus.waitingForPickup &&
              //         widget.order.status == OrderStatus.ontheway)
              //     ? (isLoadingDelivery
              //           ? const Center(child: CircularProgressIndicator())
              //           : LiveDeliveryTracking(orderId: widget.order.orderId))
              //     : const SizedBox.shrink(),
              Divider(height: 24.h),

              /// ITEMS
              Text("Items", style: AppStyles.titleStyle),
              SizedBox(height: 8.h),
              ...widget.items.map((item) => _buildOrderItem(item)),

              Divider(height: 24.h),

              /// SUMMARY
              Text(
                "Order Summary",
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.h),

              _buildOrderSummary(),
              _buildActiveTicket(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
    bool isBold = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16.sp, color: Colors.grey.shade600),
          SizedBox(width: 8.w),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade700),
                children: [
                  TextSpan(
                    text: "$label: ",
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(
                    text: value,
                    style: TextStyle(
                      fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                      color: valueColor ?? Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(OrderItem item) {
    return Card(
      color: Colors.white,
      margin: EdgeInsets.symmetric(vertical: 4.h),
      child: Padding(
        padding: AppStyles.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  item.dishName,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Spacer(),
                Text("Qty: ${item.quantity}"),
              ],
            ),
            SizedBox(height: 8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Price: ₹${item.price.toStringAsFixed(2)}"),
                Text(
                  "Total: ₹${item.totalPrice.toStringAsFixed(2)}",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Column(
      children: [
        // Order Summary Items
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Subtotal:", style: TextStyle(fontSize: 14.sp)),
            Text(
              "₹${widget.order.subTotal.toStringAsFixed(2)}",
              style: TextStyle(fontSize: 14.sp),
            ),
          ],
        ),
        if (widget.order.discountAmount > 0)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Discount Amount:", style: TextStyle(fontSize: 14.sp)),

              Text(
                "₹${widget.order.discountAmount.toStringAsFixed(2)}",
                style: TextStyle(fontSize: 14.sp),
              ),
            ],
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Platform Charges:", style: TextStyle(fontSize: 14.sp)),
            Text(
              "₹${widget.order.platformCharges.toStringAsFixed(2)}",
              style: TextStyle(fontSize: 14.sp),
            ),
          ],
        ),

        if (widget.order.orderType != OrderType.DINE_IN)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Packing Charges:", style: TextStyle(fontSize: 14.sp)),
              Text(
                "₹${widget.order.packingCharges.toStringAsFixed(2)}",
                style: TextStyle(fontSize: 14.sp),
              ),
            ],
          ),
        if (widget.order.orderType == OrderType.DELIVERY)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Delivery Charges:", style: TextStyle(fontSize: 14.sp)),
              Text(
                "₹${widget.order.deliveryCharges.toStringAsFixed(2)}",
                style: TextStyle(fontSize: 14.sp),
              ),
            ],
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Sgst:", style: TextStyle(fontSize: 14.sp)),
            Text(
              "₹${widget.order.sgst.toStringAsFixed(2)}",
              style: TextStyle(fontSize: 14.sp),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Cgst:", style: TextStyle(fontSize: 14.sp)),
            Text(
              "₹${widget.order.cgst.toStringAsFixed(2)}",
              style: TextStyle(fontSize: 14.sp),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Total:", style: TextStyle(fontSize: 14.sp)),
            Text(
              "₹${widget.order.grandTotal.toStringAsFixed(2)}",
              style: TextStyle(fontSize: 14.sp),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        if (widget.order.status == OrderStatus.completed)
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              gradient: LinearGradient(
                colors: [Colors.blue[700]!, Colors.blue[500]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  // ignore: deprecated_member_use
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 4.r,
                  offset: Offset(0, 2.r),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              icon: Icon(Icons.receipt, size: 20.sp, color: Colors.white),
              label: Text(
                "Download Invoice",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              style:
                  ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    minimumSize: Size(double.infinity, 48.h),
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    elevation: 0,
                  ).copyWith(
                    overlayColor: WidgetStateProperty.resolveWith<Color?>((
                      states,
                    ) {
                      if (states.contains(WidgetState.pressed)) {
                        // ignore: deprecated_member_use
                        return Colors.black.withOpacity(0.15);
                      }
                      return null;
                    }),
                  ),
              onPressed: _downloadInvoice,
            ),
          ),
      ],
    );
  }

  Future<void> downloadPdf(Uint8List pdfBytes, String fileName) async {
    try {
      // Get external storage directory (Downloads folder on Android)
      Directory? directory;
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
        // optional: to save directly in Downloads folder
        String newPath = "";
        List<String> paths = directory!.path.split("/");
        for (int x = 1; x < paths.length; x++) {
          String folder = paths[x];
          if (folder != "Android") {
            newPath += "/" + folder;
          } else {
            break;
          }
        }
        newPath = newPath + "/Download";
        directory = Directory(newPath);
      } else {
        // iOS documents directory
        directory = await getApplicationDocumentsDirectory();
      }

      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      final filePath = "${directory.path}/$fileName";
      final file = File(filePath);

      // Write PDF bytes to file
      await file.writeAsBytes(pdfBytes);

      // Open the PDF file
      await OpenFile.open(filePath);

      // print("PDF saved at: $filePath");
    } catch (e) {
      // print("Error saving PDF: $e");
    }
  }

  Future<void> _downloadInvoice() async {
    final data = await food_Authservice.fetchOrderById(widget.order.orderId);
    if (data == null) return;

    final pdfBytes = await generateOrderPdf(data);
    await downloadPdf(pdfBytes, "Invoice_${widget.order.orderId}.pdf");
  }

  Future<Uint8List> generateOrderPdf(Map<String, dynamic> data) async {
    final pdf = pw.Document();

    final List items = List.from(data['order'] ?? []);

    final imageBytes = await rootBundle.load('assets/MAAMAAS.jpeg');
    final image = pw.MemoryImage(imageBytes.buffer.asUint8List());

    final fontData = await rootBundle.load("assets/fonts/Roboto-Regular.ttf");
    final ttf = pw.Font.ttf(fontData);

    String formatAmount(dynamic value) {
      if (value == null) return '0.00';
      return double.tryParse(value.toString())?.toStringAsFixed(2) ?? '0.00';
    }

    final isDelivery = data['orderType']?.toString() == "DELIVERY";
    final isTakeaway = data['orderType']?.toString() == "TAKEAWAY";

    pw.Widget keyValue(String key, String value, {bool bold = false}) {
      return pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 2),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              key,
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
              ),
            ),
            pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
              ),
            ),
          ],
        ),
      );
    }

    pdf.addPage(
      pw.MultiPage(
        theme: pw.ThemeData.withFont(base: ttf, bold: ttf),
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // ================= HEADER =================
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Row(
                children: [
                  pw.Container(width: 60, height: 60, child: pw.Image(image)),
                  pw.SizedBox(width: 10),
                  pw.Text(
                    'MAAMAAS',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
              pw.Text(
                'INVOICE',
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
          pw.Divider(),

          // ================= ORDER INFO =================
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey400),
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // LEFT COLUMN — Order Details
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      keyValue(
                        'Order ID',
                        data['orderId']?.toString() ?? 'N/A',
                      ),
                      // keyValue('Customer', data['userName'] ?? 'N/A'),
                      if (data['orderDateAndTime'] != null &&
                          data['orderDateAndTime'].toString().isNotEmpty)
                        () {
                          final orderDateTime = DateTime.tryParse(
                            data['orderDateAndTime'],
                          );
                          if (orderDateTime != null) {
                            return pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                keyValue(
                                  'Date',
                                  "${orderDateTime.day}-${orderDateTime.month}-${orderDateTime.year}",
                                ),
                                keyValue(
                                  'Time',
                                  "${orderDateTime.hour.toString().padLeft(2, '0')}:${orderDateTime.minute.toString().padLeft(2, '0')}",
                                ),
                              ],
                            );
                          } else {
                            return pw.Container(); // fallback if parse fails
                          }
                        }(),

                      // if (data['date'] != null &&
                      //     data['date'].toString().isNotEmpty)
                      //   keyValue('Date', data['date']),
                      // if (data['time'] != null &&
                      //     data['time'].toString().isNotEmpty)
                      //   keyValue('Time', data['time']),
                      keyValue(
                        'Order Type',
                        data['orderType']?.toString().replaceAll('_', ' ') ??
                            'N/A',
                      ),
                      keyValue(
                        'Payment',
                        data['paymentMethod']?.toString().replaceAll(
                              '_',
                              ' ',
                            ) ??
                            'N/A',
                      ),
                      if (data['transactionId'] != null)
                        keyValue('Transaction ID', data['transactionId']),
                      if (data["sheduled"] == true) ...[
                        pw.Text(
                          'Scheduled Details',
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),

                        if (data['date']?.toString().isNotEmpty ?? false)
                          keyValue('Scheduled Date', data['date']),

                        if (data['time']?.toString().isNotEmpty ?? false)
                          keyValue('Scheduled Time', data['time']),
                      ],
                    ],
                  ),
                ),

                pw.SizedBox(width: 20),

                // RIGHT COLUMN — Restaurant Details
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      keyValue(
                        'Restaurant Name',
                        data['vendorRegisteredName']?.toString().replaceAll(
                              '_',
                              ' ',
                            ) ??
                            'N/A',
                      ),
                      keyValue(
                        'FSSAI No',
                        data['vendorFssai']?.toString() ?? 'N/A',
                      ),
                      keyValue(
                        'GSTIN',
                        data['vendorGstIn']?.toString() ?? 'N/A',
                      ),
                      keyValue(
                        'Restaurant Address',
                        [
                                  data['vendorFullAddress'],
                                  data['vendorCity'],
                                  data['vendorState'],
                                ]
                                .where(
                                  (e) => e != null && e.toString().isNotEmpty,
                                )
                                .join(', ')
                                .isNotEmpty
                            ? [
                                    data['vendorFullAddress'],
                                    data['vendorCity'],
                                    data['vendorState'],
                                  ]
                                  .where(
                                    (e) => e != null && e.toString().isNotEmpty,
                                  )
                                  .join(', ')
                            : 'N/A',
                      ),
                      if (data['orderType']?.toString() == "DELIVERY") ...[
                        keyValue(
                          "Customer Name:",
                          (data['deliveryUserName']
                                  ?.toString()
                                  .toUpperCase()) ??
                              'N/A',
                        ),
                        keyValue(
                          "Mobile Number:",
                          data['mobileNo'] != null
                              ? "+91 ${data['mobileNo'].toString()}"
                              : "N/A",
                        ),
                        keyValue(
                          "Delivery Address:",
                          (data['deliveryAddress'] as String?)?.replaceAll(
                                '_',
                                ' ',
                              ) ??
                              'N/A',
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 20),

          // ================= ITEMS TABLE =================
          pw.Text(
            'Ordered Items',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),

          pw.TableHelper.fromTextArray(
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
            headerStyle: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
            ),
            cellStyle: pw.TextStyle(fontSize: 9),
            cellPadding: const pw.EdgeInsets.symmetric(
              vertical: 6,
              horizontal: 4,
            ),
            headers: ['#', 'Item', 'Qty', 'Price', 'Total'],
            data: List.generate(items.length, (index) {
              final item = items[index];
              return [
                (index + 1).toString(),
                item['dishName'] ?? 'N/A',
                item['quantity'].toString(),
                "₹${formatAmount(item['price'])}",
                "₹${formatAmount(item['totalPrice'])}",
              ];
            }),
          ),

          pw.SizedBox(height: 20),

          // ================= BILLING SUMMARY =================
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Container(
              width: 240,
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey400),
                borderRadius: pw.BorderRadius.circular(6),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Billing Summary',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 8),

                  // Base amounts
                  keyValue('Sub Total', "₹${formatAmount(data['subTotal'])}"),
                  keyValue('SGST', "₹${formatAmount(data['sgst'])}"),
                  keyValue('CGST', "₹${formatAmount(data['cgst'])}"),

                  if ((data['platformCharges'] ?? 0) > 0)
                    keyValue(
                      'Platform Charges',
                      "₹${formatAmount(data['platformCharges'])}",
                    ),

                  if ((data['discountAmount'] ?? 0) > 0)
                    keyValue(
                      'Discount',
                      "- ₹${formatAmount(data['discountAmount'])}",
                    ),

                  if (isTakeaway || isDelivery)
                    keyValue(
                      'Packing Charges',
                      "₹${formatAmount(data['packingCharges'])}",
                    ),
                  keyValue(
                    'Packing Charges',
                    "₹${formatAmount(data['packingCharges'])}",
                  ),

                  if (isDelivery)
                    keyValue(
                      'Delivery Charges',
                      "₹${formatAmount(data['deliveryCharges'])}",
                    ),

                  pw.Divider(height: 12),

                  keyValue(
                    'Grand Total',
                    "₹${formatAmount(data['grandTotal'])}",
                    bold: true,
                  ),
                ],
              ),
            ),
          ),

          pw.SizedBox(height: 30),

          // ================= FOOTER =================
          pw.Center(
            child: pw.Text(
              'Thank you for ordering with MAAMAAS',
              style: pw.TextStyle(fontSize: 10, fontStyle: pw.FontStyle.italic),
            ),
          ),
        ],
      ),
    );

    return pdf.save();
  }

  Widget keyValueMultiline(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppStyles.subtitleStyle.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(value, style: AppStyles.subtitleStyle),
      ],
    );
  }

  // Widget _buildOrderMapTracking() {
  //   if (deliveryModel == null) {
  //     return const SizedBox();
  //   }
  //   return Column(
  //     children: [
  //       const Divider(thickness: 1.2),
  //
  //       // Map Container
  //       Container(
  //         height: 200.h,
  //         decoration: BoxDecoration(
  //           borderRadius: BorderRadius.circular(12.r),
  //           boxShadow: [
  //             BoxShadow(
  //               // ignore: deprecated_member_use
  //               color: Colors.grey.withOpacity(0.3),
  //               blurRadius: 6.r,
  //               offset: const Offset(0, 2),
  //             ),
  //           ],
  //         ),
  //         child: ClipRRect(
  //           borderRadius: BorderRadius.circular(12.r),
  //           child: GoogleMap(
  //             initialCameraPosition: CameraPosition(
  //               target: LatLng(
  //                 deliveryModel!.userLatitude,
  //                 deliveryModel!.userLongitude,
  //               ),
  //               zoom: 14,
  //             ),
  //             markers: {
  //               Marker(
  //                 markerId: const MarkerId("delivery_boy"),
  //                 position: LatLng(
  //                   deliveryModel!.deliveryPartnerLatitude,
  //                   deliveryModel!.deliveryPartnerLongitude,
  //                 ),
  //                 infoWindow: InfoWindow(
  //                   title: deliveryModel!.deliveryPartnerName,
  //                 ),
  //               ),
  //               Marker(
  //                 markerId: const MarkerId("customer"),
  //                 position: LatLng(
  //                   deliveryModel!.userLatitude,
  //                   deliveryModel!.userLongitude,
  //                 ),
  //                 infoWindow: const InfoWindow(title: "Your Location"),
  //               ),
  //             },
  //           ),
  //         ),
  //       ),
  //
  //       SizedBox(height: 16.h),
  //
  //       // Delivery Info Section
  //       Row(
  //         children: [
  //           // Delivery Boy Avatar
  //           Container(
  //             decoration: BoxDecoration(
  //               shape: BoxShape.circle,
  //               border: Border.all(color: Colors.blue, width: 1.5.w),
  //             ),
  //             child: CircleAvatar(
  //               radius: 24.r,
  //               backgroundColor: Colors.grey[300],
  //               child: Icon(
  //                 Icons.delivery_dining,
  //                 size: 24.r,
  //                 color: Colors.blue[700],
  //               ),
  //               // backgroundImage: AssetImage('assets/delivery_boy.png'),
  //             ),
  //           ),
  //           SizedBox(width: 12.w),
  //
  //           // Delivery Info
  //           Expanded(
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Text(
  //                   deliveryModel!.deliveryPartnerName,
  //                   style: TextStyle(
  //                     fontSize: 16.sp,
  //                     fontWeight: FontWeight.w600,
  //                   ),
  //                 ),
  //                 SizedBox(height: 4.h),
  //                 Row(
  //                   children: [
  //                     Icon(
  //                       Icons.directions_bike,
  //                       size: 14.r,
  //                       color: Colors.grey[600],
  //                     ),
  //                     SizedBox(width: 4.w),
  //                     Text(
  //                       "On the way to your location",
  //                       style: TextStyle(
  //                         fontSize: 12.sp,
  //                         color: Colors.grey[600],
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //                 SizedBox(height: 4.h),
  //                 Text(
  //                   "Vehicle No: TS07AB1234", // Add if available
  //                   style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
  //                 ),
  //                 Text(
  //                   deliveryModel!.vehicleStatus.name.replaceAll("_", " "),
  //                   style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
  //                 ),
  //               ],
  //             ),
  //           ),
  //
  //           // Call Button
  //           IconButton(
  //             icon: Container(
  //               padding: EdgeInsets.all(8.r),
  //               decoration: BoxDecoration(
  //                 color: Colors.green[50],
  //                 shape: BoxShape.circle,
  //                 border: Border.all(color: Colors.green[200]!, width: 1.w),
  //               ),
  //               child: Icon(Icons.phone, size: 20.r, color: Colors.green[800]),
  //             ),
  //             onPressed: () {
  //               // Implement call functionality
  //               _makeSupportCall();
  //             },
  //           ),
  //         ],
  //       ),
  //       SizedBox(height: 16.h),
  //
  //       // Estimated Time Section
  //       Container(
  //         padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
  //         decoration: BoxDecoration(
  //           color: Colors.blue[50],
  //           borderRadius: BorderRadius.circular(8.r),
  //           border: Border.all(color: Colors.blue[100]!, width: 1.w),
  //         ),
  //         child: Row(
  //           children: [
  //             Icon(Icons.access_time, size: 20.r, color: Colors.blue[800]),
  //             SizedBox(width: 12.w),
  //             Expanded(
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   Text(
  //                     "Estimated delivery time",
  //                     style: TextStyle(
  //                       fontSize: 12.sp,
  //                       color: Colors.grey[600],
  //                     ),
  //                   ),
  //                   Text(
  //                     "${deliveryModel!.estimatedDeliveryTimeMinutes} mins",
  //                     style: TextStyle(
  //                       fontSize: 14.sp,
  //                       fontWeight: FontWeight.w600,
  //                       color: Colors.blue[800],
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //             // Add tracking button if needed
  //             GestureDetector(
  //               onTap: () {
  //                 // Implement tracking action
  //               },
  //               child: Text(
  //                 "TRACK",
  //                 style: TextStyle(
  //                   fontSize: 12.sp,
  //                   fontWeight: FontWeight.bold,
  //                   color: Colors.blue[800],
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Future<void> _makeSupportCall() async {
    const supportNumber = 'tel:+919063888450';
    if (await canLaunchUrl(Uri.parse(supportNumber))) {
      await launchUrl(Uri.parse(supportNumber));
    } else {
      throw 'Could not launch $supportNumber';
    }
  }

  Widget _buildActiveTicket(BuildContext context) {
    return Column(
      children: [
        Divider(),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Having issues with this order?",
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.h),
              Text(
                "Raise a ticket and our support team will help you",
                style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
              ),
              SizedBox(height: 16.h),
              ElevatedButton(
                onPressed: () {
                  debugPrint(
                    "➡️ Navigating with orderId: ${widget.order.orderId}",
                  );

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CreateTicketScreen(orderId: widget.order.orderId),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 48.h),
                  backgroundColor: Colors.orange[700],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  "Raise Ticket",
                  style: TextStyle(fontSize: 16.sp, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.cancelled:
        return Colors.red;
      case OrderStatus.completed:
        return Colors.green;
      case OrderStatus.pending:
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }
}

enum CateringOrderStatus { pending, confirmed, preparing, delivered, cancelled }

class LiveDeliveryTracking extends StatefulWidget {
  final int orderId;

  const LiveDeliveryTracking({super.key, required this.orderId});

  @override
  State<LiveDeliveryTracking> createState() => _LiveDeliveryTrackingState();
}

class _LiveDeliveryTrackingState extends State<LiveDeliveryTracking>
    with SingleTickerProviderStateMixin {
  GoogleMapController? _mapController;

  DeliveryOrderModel? delivery;

  Timer? _pollingTimer;

  Marker? _partnerMarker;

  LatLng? _lastPartnerPosition;

  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  List<BitmapDescriptor> _bikeFrames = [];
  int _currentFrame = 0;

  Timer? _etaTimer;
  int? _remainingEtaSeconds;

  late final AnimationController _mapFadeController;
  late final Animation<double> _mapFadeAnimation;

  // 🔑 PUT YOUR GOOGLE MAPS KEY HERE
  final String googleApiKey = "AIzaSyCf7bYn7iDIs2T6-sDnmr7qWy9oFZOPOuc";

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _mapFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _mapFadeAnimation = CurvedAnimation(
      parent: _mapFadeController,
      curve: Curves.easeOut,
    );

    _mapFadeController.forward();
    await _loadVehicleIcon();
    await _loadDelivery();
    _startLiveTracking();
  }

  // 📡 LOAD DELIVERY DATA
  Future<void> _loadDelivery() async {
    final data = await DeliveryOrderService.getOrder(widget.orderId);

    if (!mounted) return;

    setState(() {
      delivery = data;
    });
    if (delivery?.estimatedDeliveryTimeMinutes != null) {
      _remainingEtaSeconds = delivery!.estimatedDeliveryTimeMinutes * 60;
      _startEtaCountdown();
    }

    if (delivery != null) {
      _setupStaticMarkers();
      _drawPolyline();
    }
  }

  void _startEtaCountdown() {
    _etaTimer?.cancel();
    _etaTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remainingEtaSeconds == null ||
          _remainingEtaSeconds! <= 0 ||
          delivery?.status == deliveryStatus.DELIVERED) {
        _etaTimer?.cancel();
        return;
      }

      setState(() {
        _remainingEtaSeconds = _remainingEtaSeconds! - 1;
      });
    });
  }

  // 🔁 LIVE POLLING
  void _startLiveTracking() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 8), (_) async {
      final updated = await DeliveryOrderService.getOrder(widget.orderId);

      if (updated == null) return;

      // 🛑 STOP tracking after delivery
      if (updated.status == deliveryStatus.DELIVERED) {
        _mapFadeController.reverse();
        _pollingTimer?.cancel();
      }

      final newPosition = LatLng(
        updated.deliveryPartnerLatitude,
        updated.deliveryPartnerLongitude,
      );

      if (_lastPartnerPosition == null) {
        _addInitialPartnerMarker(newPosition);
      } else {
        await _animateMarker(_lastPartnerPosition!, newPosition);
      }
      if (!mounted) return;

      setState(() {
        delivery = updated;
      });

      _lastPartnerPosition = newPosition;
    });
  }

  // 📍 STATIC MARKERS
  void _setupStaticMarkers() {
    final d = delivery!;
    _markers.add(
      Marker(
        markerId: const MarkerId('customer'),
        position: LatLng(d.userLatitude, d.userLongitude),
        infoWindow: const InfoWindow(title: "Your Location"),
      ),
    );

    _markers.add(
      Marker(
        markerId: const MarkerId('vendor'),
        position: LatLng(d.vendorLatitude, d.vendorLongitude),
        infoWindow: const InfoWindow(title: "Restaurant"),
      ),
    );
  }

  // 🚚 INITIAL PARTNER MARKER
  void _addInitialPartnerMarker(LatLng position) {
    _partnerMarker = Marker(
      markerId: const MarkerId('partner'),
      position: position,
      icon: _bikeFrames.first,
      anchor: const Offset(0.5, 0.5),
      rotation: 0,
    );

    _markers.add(_partnerMarker!);
    setState(() {});
  }

  Future<void> _loadVehicleIcon() async {
    final frames = [
      'assets/icons/bike_1.png',
      'assets/icons/bike_2.png',
      'assets/icons/bike_3.png',
      'assets/icons/bike_4.png',
    ];

    for (final path in frames) {
      // ignore: deprecated_member_use
      final icon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(48, 48)),
        path,
      );
      _bikeFrames.add(icon);
    }
  }

  // 🎥 SMOOTH ANIMATION
  Future<void> _animateMarker(LatLng from, LatLng to) async {
    const int steps = 30;
    const Duration delay = Duration(milliseconds: 60);

    for (int i = 1; i <= steps; i++) {
      final lat = from.latitude + (to.latitude - from.latitude) * (i / steps);
      final lng =
          from.longitude + (to.longitude - from.longitude) * (i / steps);

      final rotation = _getBearing(from, to);

      _currentFrame = (_currentFrame + 1) % _bikeFrames.length;

      _partnerMarker = _partnerMarker!.copyWith(
        positionParam: LatLng(lat, lng),
        rotationParam: rotation,
        iconParam: _bikeFrames[_currentFrame],
      );

      _markers
        ..removeWhere((m) => m.markerId.value == 'partner')
        ..add(_partnerMarker!);

      setState(() {});
      await Future.delayed(delay);
    }

    _mapController?.animateCamera(CameraUpdate.newLatLng(to));
  }

  // 🧭 BEARING CALCULATION
  double _getBearing(LatLng start, LatLng end) {
    final lat1 = start.latitude * pi / 180;
    final lat2 = end.latitude * pi / 180;
    final dLon = (end.longitude - start.longitude) * pi / 180;

    final y = sin(dLon) * cos(lat2);
    final x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);

    return (atan2(y, x) * 180 / pi + 360) % 360;
  }

  // 🧵 POLYLINE ROUTE
  Future<void> _drawPolyline() async {
    final d = delivery!;
    final polylinePoints = PolylinePoints();

    final result = await polylinePoints.getRouteBetweenCoordinates(
      request: PolylineRequest(
        origin: PointLatLng(d.vendorLatitude, d.vendorLongitude),
        destination: PointLatLng(d.userLatitude, d.userLongitude),
        mode: TravelMode.driving,
      ),
      googleApiKey: googleApiKey,
    );

    if (result.points.isEmpty) return;

    final polylineCoords = result.points
        .map((p) => LatLng(p.latitude, p.longitude))
        .toList();

    _polylines.add(
      Polyline(
        polylineId: const PolylineId('route'),
        color: Colors.blue,
        width: 4,
        points: polylineCoords,
      ),
    );

    setState(() {});
  }

  // ⏱ ETA CALCULATION
  String get etaText {
    if (_remainingEtaSeconds == null) return "Calculating ETA...";
    final mins = (_remainingEtaSeconds! / 60).ceil();
    return "$mins mins";
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _makeSupportCall() async {
    const supportNumber = 'tel:+919063888450';
    if (await canLaunchUrl(Uri.parse(supportNumber))) {
      await launchUrl(Uri.parse(supportNumber));
    } else {
      throw 'Could not launch $supportNumber';
    }
  }

  @override
  Widget build(BuildContext context) {
    // if (_isLoading) {
    //   return const Center(child: CircularProgressIndicator());
    // }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),

          child: _buildBottomCard(),
        ),
      ],
    );
  }

  Widget _buildBottomCard() {
    // 1️⃣ Still assigning partner
    if (delivery == null) {
      return _buildAssigningPartnerCard();
    }

    // 2️⃣ Order ON THE WAY + Partner accepted
    if (delivery!.status == deliveryStatus.ACCEPTED ||
        delivery!.status == deliveryStatus.PICKED_UP ||
        delivery!.status == deliveryStatus.ONGOING ||
        delivery!.status == deliveryStatus.ARRIVED) {
      return _buildPartnerAssignedCard();
    }

    // 3️⃣ Delivered (BOTH order + delivery completed)
    if (delivery!.status == deliveryStatus.DELIVERED) {
      return _buildAssignedPartnerDetails();
    }

    return const SizedBox.shrink();
  }

  Widget _buildAssignedPartnerDetails() {
    return Column(
      children: [
        Row(
          children: [
            const Icon(Icons.delivery_dining, color: Colors.green, size: 28),
            const SizedBox(width: 8),
            const Text(
              "Delivery Partner Details",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),

        const Divider(height: 24),

        // PARTNER INFO
        Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: Colors.green.shade100,
              child: const Icon(Icons.person, color: Colors.green),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    delivery!.deliveryPartnerName.isEmpty
                        ? "Delivery Partner"
                        : delivery!.deliveryPartnerName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.timer, size: 16, color: Colors.green),
                      const SizedBox(width: 6),
                      Text(
                        "ETA: $etaText",
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),
                  Text(
                    "Vehicle: ${delivery!.vehicleStatus.name.replaceAll('_', ' ')}",
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAssigningPartnerCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 36,
            height: 36,
            child: CircularProgressIndicator(strokeWidth: 3),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              "Assigning delivery partner...\nPlease wait",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildmap() {
    return FadeTransition(
      opacity: _mapFadeAnimation,
      child: SizedBox(
        height: 300,
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(
                delivery?.vendorLatitude ?? 17.385044,
                delivery?.vendorLongitude ?? 78.486671,
              ),
              zoom: 14,
            ),

            markers: _markers,
            polylines: _polylines,
            onMapCreated: (c) => _mapController = c,
            myLocationEnabled: false,
            zoomControlsEnabled: false,
            gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
              Factory<OneSequenceGestureRecognizer>(
                () => EagerGestureRecognizer(),
              ),
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPartnerAssignedCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildmap(),

          const SizedBox(height: 16),
          // HEADER
          Row(
            children: [
              const Icon(Icons.delivery_dining, color: Colors.green, size: 28),
              const SizedBox(width: 8),
              const Text(
                "Delivery Partner Assigned",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),

          const Divider(height: 24),

          // PARTNER INFO
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: Colors.green.shade100,
                child: const Icon(Icons.person, color: Colors.green),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      delivery!.deliveryPartnerName.isEmpty
                          ? "Delivery Partner"
                          : delivery!.deliveryPartnerName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Vehicle: ${delivery!.vehicleStatus.name.replaceAll('_', ' ')}",
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.call, color: Colors.green),
                onPressed: () {
                  _makeSupportCall();
                },
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(),

          // 🔐 OTP ROW
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Delivery OTP",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green),
                ),
                child: Row(
                  children: [
                    Text(
                      delivery!.userOtp.toString(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.lock_outline, size: 18, color: Colors.green),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
