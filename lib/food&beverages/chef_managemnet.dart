// // import 'dart:typed_data';
// // import 'dart:async';
// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart';
// // import 'package:flutter_screenutil/flutter_screenutil.dart';
// // import 'package:intl/intl.dart';
// // import 'package:permission_handler/permission_handler.dart';
// // import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
// // import 'package:shared_preferences/shared_preferences.dart';
// // import 'package:audioplayers/audioplayers.dart';
// // import '../Api/food_authservice.dart';
// // import '../printservice/printservice.dart';
// //
// // class chef_management extends StatefulWidget {
// //   const chef_management({super.key});
// //
// //   @override
// //   State<chef_management> createState() => _ChefManagementState();
// // }
// //
// // class _ChefManagementState extends State<chef_management> {
// //   final List<String> _tabTitles = ["All", "Processing"];
// //   int _selectedTab = 0;
// //   List<dynamic> _allOrders = [];
// //   List<dynamic> _filteredOrders = [];
// //   List<dynamic> _displayOrders = [];
// //   bool _isLoading = true;
// //   bool _printSelected = true;
// //   String _selectedFilter = 'chef';
// //   Set<String> _acknowledgedOrderIds = {};
// //
// //   // Audio and ringing control
// //   final AudioPlayer _audioPlayer = AudioPlayer();
// //   Set<String> _pendingOrderIds = {};
// //   Set<String> _ringingOrderIds = {};
// //   Timer? _orderPollingTimer;
// //   bool _isPlaying = false;
// //   bool _isSoundEnabled = true;
// //
// //   // Role-based variables
// //   String? _employeeRole;
// //   String? _userRole;
// //   List<String> _validChefTypes = [
// //     'Chef_North',
// //     'Chef_South',
// //     'Chef_Continental',
// //     'Chef_Chinese',
// //     'Chef_All',
// //     'Tea_stall',
// //     'Snacks',
// //     'Bakery',
// //   ];
// //
// //   // Track previous order count for comparison
// //   int _previousOrderCount = 0;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _loadUserRoles();
// //     _initializeSound();
// //     _fetchOrders();
// //     _startOrderPolling();
// //   }
// //
// //   Future<void> _loadUserRoles() async {
// //     final prefs = await SharedPreferences.getInstance();
// //     setState(() {
// //       _employeeRole = prefs.getString('employeRole');
// //       _userRole = prefs.getString('role');
// //     });
// //   }
// //
// //   Future<void> _fetchOrders() async {
// //     setState(() => _isLoading = true);
// //
// //     try {
// //       final allOrders = await food_authservice.getAllOrders();
// //
// //       // Filter relevant order types
// //       List filteredOrders = allOrders.where((order) {
// //         final type = (order['orderType'] ?? '').toString().toUpperCase();
// //         return [
// //           'DINE_IN',
// //           'DELIVERY',
// //           'TAKEAWAY',
// //           'TABLE_DINE_IN',
// //         ].contains(type);
// //       }).toList();
// //
// //       // Apply role-based filtering
// //       filteredOrders = _applyRoleFiltering(filteredOrders);
// //
// //       // Store the count before update
// //       final previousCount = _allOrders.length;
// //
// //       setState(() {
// //         _allOrders = filteredOrders;
// //         _applyFilter();
// //         _updateDisplayOrders();
// //       });
// //
// //       // Check for new orders
// //       if (filteredOrders.length > previousCount) {
// //         debugPrint(
// //           '🎯 Detected new orders: Previous=$previousCount, Current=${filteredOrders.length}',
// //         );
// //         _findAndRingNewOrders(previousCount, filteredOrders);
// //       } else if (filteredOrders.length < previousCount) {
// //         // Some orders were completed/removed - clean up ringing
// //         _cleanupCompletedOrders(filteredOrders);
// //       }
// //
// //       // Store for next comparison
// //       _previousOrderCount = filteredOrders.length;
// //
// //       debugPrint('📊 Loaded ${filteredOrders.length} orders');
// //     } catch (e) {
// //       debugPrint('Error fetching orders: $e');
// //       _showError('Failed to load orders');
// //     } finally {
// //       setState(() => _isLoading = false);
// //     }
// //   }
// //
// //   void _findAndRingNewOrders(int previousCount, List<dynamic> currentOrders) {
// //     // If we had no orders before, all current orders are "new"
// //     if (previousCount == 0) {
// //       for (var order in currentOrders) {
// //         _triggerOrderNotificationIfNeeded(order);
// //       }
// //       return;
// //     }
// //
// //     // Get IDs of orders we had before (only take the previous count)
// //     final previousOrderIds = _allOrders
// //         .take(previousCount)
// //         .map((o) => o['orderId'].toString())
// //         .toSet();
// //
// //     // Check each order in the current list
// //     for (var order in currentOrders) {
// //       final orderId = order['orderId'].toString();
// //
// //       // If this order wasn't in our previous list, it's new
// //       if (!previousOrderIds.contains(orderId)) {
// //         _triggerOrderNotificationIfNeeded(order);
// //       }
// //     }
// //   }
// //
// //   void _triggerOrderNotificationIfNeeded(Map<String, dynamic> order) {
// //     final orderId = order['orderId'].toString();
// //     final status = (order['status'] ?? '').toString().toUpperCase();
// //
// //     // Define which statuses should trigger ringing
// //     final eligibleStatuses = _selectedFilter == 'chef'
// //         ? ['CONFIRMED']
// //         : ['PENDING', 'CONFIRMED'];
// //
// //     // Don't ring for completed/cancelled orders
// //     final excludedStatuses = [
// //       'ORDER_IS_READY',
// //       'DELIVERED',
// //       'CANCELLED',
// //       'BEING_PREPARED',
// //     ];
// //
// //     // Check if order is eligible for ringing
// //     if (eligibleStatuses.contains(status) &&
// //         !excludedStatuses.contains(status) &&
// //         !_acknowledgedOrderIds.contains(orderId) &&
// //         !_ringingOrderIds.contains(orderId)) {
// //       debugPrint('🔔 NEW ORDER DETECTED: #$orderId (Status: $status)');
// //
// //       _pendingOrderIds.add(orderId);
// //       _ringingOrderIds.add(orderId);
// //
// //       if (!_isPlaying && _isSoundEnabled) {
// //         _startRingingForOrder(orderId);
// //       }
// //
// //       _triggerVibration();
// //     }
// //   }
// //
// //   void _cleanupCompletedOrders(List<dynamic> currentOrders) {
// //     final currentOrderIds = currentOrders
// //         .map((o) => o['orderId'].toString())
// //         .toSet();
// //
// //     // Remove any ringing orders that are no longer in the list
// //     final ordersToRemove = _ringingOrderIds
// //         .where((orderId) => !currentOrderIds.contains(orderId))
// //         .toList();
// //
// //     if (ordersToRemove.isNotEmpty) {
// //       debugPrint('🗑️ Cleaning up ${ordersToRemove.length} completed orders');
// //       for (var orderId in ordersToRemove) {
// //         _pendingOrderIds.remove(orderId);
// //         _ringingOrderIds.remove(orderId);
// //         _acknowledgedOrderIds.remove(orderId);
// //       }
// //
// //       // Stop ringing if no pending orders left
// //       if (_pendingOrderIds.isEmpty && _isPlaying) {
// //         _stopAllRinging();
// //       }
// //     }
// //   }
// //
// //   List<dynamic> _applyRoleFiltering(List<dynamic> orders) {
// //     if (_userRole == 'ROLE_VENDOR') {
// //       return orders;
// //     }
// //
// //     if (_employeeRole != null && _employeeRole!.isNotEmpty) {
// //       if (_validChefTypes.contains(_employeeRole)) {
// //         return orders.where((order) {
// //           return _hasMatchingChefType(order, _employeeRole!);
// //         }).toList();
// //       }
// //     }
// //
// //     if (_employeeRole == null || _employeeRole!.isEmpty) {
// //       WidgetsBinding.instance.addPostFrameCallback((_) {
// //         _showRoleWarningDialog();
// //       });
// //     }
// //
// //     return [];
// //   }
// //
// //   bool _hasMatchingChefType(Map<String, dynamic> order, String employeeRole) {
// //     if (employeeRole == 'Chef_All') {
// //       return true;
// //     }
// //
// //     if (order['cartItems'] != null && order['cartItems'] is List) {
// //       if ((order['cartItems'] as List).any((item) {
// //         return item['chefType']?.toString() == employeeRole;
// //       })) {
// //         return true;
// //       }
// //     }
// //
// //     if (order['items'] != null && order['items'] is List) {
// //       if ((order['items'] as List).any((item) {
// //         return item['chefType']?.toString() == employeeRole;
// //       })) {
// //         return true;
// //       }
// //     }
// //
// //     if (order['order'] != null && order['order'] is List) {
// //       if ((order['order'] as List).any((item) {
// //         return item['chefType']?.toString() == employeeRole;
// //       })) {
// //         return true;
// //       }
// //     }
// //
// //     return false;
// //   }
// //
// //   void _showRoleWarningDialog() {
// //     showDialog(
// //       context: context,
// //       barrierDismissible: false,
// //       builder: (context) => AlertDialog(
// //         title: Row(
// //           children: [
// //             Icon(Icons.warning, color: Colors.orange),
// //             SizedBox(width: 10.w),
// //             Text('No Item Found', style: TextStyle(fontSize: 18.sp)),
// //           ],
// //         ),
// //         content: Column(
// //           mainAxisSize: MainAxisSize.min,
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             Text(
// //               'Please log in again or set one of the following roles:',
// //               style: TextStyle(fontSize: 14.sp),
// //             ),
// //             SizedBox(height: 12.h),
// //             for (var role in _validChefTypes)
// //               Padding(
// //                 padding: EdgeInsets.only(bottom: 4.h),
// //                 child: Text('• $role', style: TextStyle(fontSize: 13.sp)),
// //               ),
// //           ],
// //         ),
// //         actions: [
// //           TextButton(
// //             onPressed: () => Navigator.pop(context),
// //             child: Text('OK', style: TextStyle(fontSize: 16.sp)),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   void _applyFilter() {
// //     if (_selectedFilter == 'chef') {
// //       _filteredOrders = _allOrders.where((order) {
// //         final type = (order['orderType'] ?? '').toString().toUpperCase();
// //         return [
// //           'DINE_IN',
// //           'TAKEAWAY',
// //           'DELIVERY',
// //           'TABLE_DINE_IN',
// //         ].contains(type);
// //       }).toList();
// //     } else if (_selectedFilter == 'online') {
// //       _filteredOrders = _allOrders.where((order) {
// //         final type = (order['orderType'] ?? '').toString().toUpperCase();
// //         final status = (order['status'] ?? '').toString().toUpperCase();
// //         return ['DELIVERY', 'TAKEAWAY', 'DINE_IN'].contains(type) &&
// //             status == 'PENDING';
// //       }).toList();
// //     } else {
// //       _filteredOrders = List.from(_allOrders);
// //     }
// //
// //     _filteredOrders.sort((a, b) {
// //       final dateA =
// //           DateTime.tryParse(a['orderDateAndTime'] ?? '') ?? DateTime(2000);
// //       final dateB =
// //           DateTime.tryParse(b['orderDateAndTime'] ?? '') ?? DateTime(2000);
// //       return dateB.compareTo(dateA);
// //     });
// //
// //     debugPrint('📊 Filtered to ${_filteredOrders.length} orders');
// //   }
// //
// //   void _updateDisplayOrders() {
// //     if (_selectedTab == 0) {
// //       // All tab
// //       if (_selectedFilter == 'chef') {
// //         _displayOrders = _filteredOrders
// //             .where((order) => order['status'] == 'CONFIRMED')
// //             .toList()
// //             .reversed
// //             .toList();
// //       } else if (_selectedFilter == 'online') {
// //         _displayOrders = _filteredOrders
// //             .where((order) => order['status'] == 'PENDING')
// //             .toList()
// //             .reversed
// //             .toList();
// //       }
// //     } else if (_selectedTab == 1) {
// //       // Processing tab
// //       if (_selectedFilter == 'chef') {
// //         _displayOrders = _filteredOrders
// //             .where((order) => order['status'] == 'BEING_PREPARED')
// //             .toList()
// //             .reversed
// //             .toList();
// //       } else if (_selectedFilter == 'online') {
// //         _displayOrders = _filteredOrders
// //             .where(
// //               (order) =>
// //                   order['status'] == 'BEING_PREPARED' ||
// //                   order['status'] == 'CONFIRMED',
// //             )
// //             .toList()
// //             .reversed
// //             .toList();
// //       }
// //     }
// //
// //     debugPrint(
// //       '📋 Displaying ${_displayOrders.length} orders in tab $_selectedTab',
// //     );
// //   }
// //
// //   Future<void> _fetchOrdersInBackground() async {
// //     try {
// //       final allOrders = await food_authservice.getAllOrders();
// //
// //       // Filter relevant order types
// //       final filteredOrders = allOrders.where((order) {
// //         final type = (order['orderType'] ?? '').toString().toUpperCase();
// //         return [
// //           'DINE_IN',
// //           'DELIVERY',
// //           'TAKEAWAY',
// //           'TABLE_DINE_IN',
// //         ].contains(type);
// //       }).toList();
// //
// //       // Apply role filtering in background too
// //       final roleFilteredOrders = _applyRoleFiltering(filteredOrders);
// //
// //       // Store current count before update
// //       final previousCount = _allOrders.length;
// //
// //       if (mounted) {
// //         setState(() {
// //           _allOrders = roleFilteredOrders;
// //           _applyFilter();
// //           _updateDisplayOrders();
// //         });
// //       }
// //
// //       // Check for new orders in background
// //       if (roleFilteredOrders.length > previousCount) {
// //         debugPrint(
// //           '🔄 Background check: Found ${roleFilteredOrders.length - previousCount} new orders',
// //         );
// //         _findAndRingNewOrders(previousCount, roleFilteredOrders);
// //       } else if (roleFilteredOrders.length < previousCount) {
// //         _cleanupCompletedOrders(roleFilteredOrders);
// //       }
// //
// //       // Update previous count
// //       _previousOrderCount = roleFilteredOrders.length;
// //     } catch (e) {
// //       debugPrint('Background fetch error: $e');
// //     }
// //   }
// //
// //   void _startOrderPolling() {
// //     _orderPollingTimer = Timer.periodic(Duration(seconds: 10), (timer) {
// //       if (mounted) {
// //         _fetchOrdersInBackground();
// //       }
// //     });
// //   }
// //
// //   Future<void> _initializeSound() async {
// //     await _audioPlayer.setReleaseMode(ReleaseMode.loop);
// //   }
// //
// //   Future<void> _startRingingForOrder(String orderId) async {
// //     if (!_isSoundEnabled || _isPlaying) return;
// //
// //     try {
// //       _isPlaying = true;
// //       await _audioPlayer.play(AssetSource('school-bell-310293.mp3'));
// //       debugPrint('🔔 Started ringing for order #$orderId');
// //     } catch (e) {
// //       debugPrint('❌ Error starting ring: $e');
// //       _isPlaying = false;
// //     }
// //   }
// //
// //   Future<void> _stopAllRinging() async {
// //     if (_isPlaying) {
// //       await _audioPlayer.stop();
// //       _isPlaying = false;
// //       debugPrint('🔕 Stopped all ringing');
// //     }
// //   }
// //
// //   void _stopRingingForOrder(String orderId) {
// //     if (_pendingOrderIds.contains(orderId)) {
// //       _pendingOrderIds.remove(orderId);
// //       _ringingOrderIds.remove(orderId);
// //
// //       // Mark as acknowledged to prevent re-ringing
// //       _acknowledgedOrderIds.add(orderId);
// //
// //       debugPrint('✅ Order #$orderId accepted & acknowledged');
// //
// //       if (_pendingOrderIds.isEmpty && _isPlaying) {
// //         _stopAllRinging();
// //       }
// //     }
// //   }
// //
// //   void _showOrderAcceptedNotification(String orderId) {
// //     WidgetsBinding.instance.addPostFrameCallback((_) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(
// //           content: Row(
// //             children: [
// //               Icon(Icons.check_circle, color: Colors.white, size: 20.sp),
// //               SizedBox(width: 10.w),
// //               Expanded(
// //                 child: Text(
// //                   'Order #$orderId accepted ✅',
// //                   style: TextStyle(
// //                     fontWeight: FontWeight.bold,
// //                     fontSize: 14.sp,
// //                   ),
// //                 ),
// //               ),
// //             ],
// //           ),
// //           backgroundColor: Colors.green,
// //           duration: Duration(seconds: 3),
// //           behavior: SnackBarBehavior.floating,
// //           margin: EdgeInsets.all(16.r),
// //           padding: EdgeInsets.all(12.r),
// //         ),
// //       );
// //     });
// //   }
// //
// //   void _triggerVibration() {
// //     try {
// //       HapticFeedback.lightImpact();
// //     } catch (e) {
// //       try {
// //         SystemSound.play(SystemSoundType.click);
// //       } catch (e2) {}
// //     }
// //   }
// //
// //   String _getOrderTypeDisplayText(String orderType) {
// //     switch (orderType) {
// //       case 'DINE_IN':
// //         return "Dine In";
// //       case 'DELIVERY':
// //         return "Delivery";
// //       case 'TAKEAWAY':
// //         return "Take Away";
// //       case 'TABLE_DINE_IN':
// //         return "Table Dine In";
// //       default:
// //         return orderType;
// //     }
// //   }
// //
// //   Future<void> _handleRefresh() async {
// //     setState(() {
// //       _isLoading = true;
// //     });
// //
// //     await _fetchOrders();
// //   }
// //
// //   void _showError(String message) {
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       SnackBar(
// //         content: Text(message),
// //         backgroundColor: Colors.red,
// //         behavior: SnackBarBehavior.floating,
// //         shape: RoundedRectangleBorder(
// //           borderRadius: BorderRadius.circular(12.r),
// //         ),
// //       ),
// //     );
// //   }
// //
// //   void _handleOrderUpdate(String orderId, String newStatus) {
// //     final index = _allOrders.indexWhere(
// //       (order) => order['orderId'].toString() == orderId,
// //     );
// //     if (index != -1) {
// //       setState(() {
// //         _allOrders[index]['status'] = newStatus;
// //         _applyFilter();
// //         _updateDisplayOrders();
// //       });
// //
// //       // Reset acknowledged status if order moved to processing
// //       if (newStatus == 'BEING_PREPARED' &&
// //           _acknowledgedOrderIds.contains(orderId)) {
// //         _acknowledgedOrderIds.remove(orderId);
// //         debugPrint(
// //           '🔄 Reset acknowledged status for processing order #$orderId',
// //         );
// //       }
// //     }
// //   }
// //
// //   @override
// //   void dispose() {
// //     _orderPollingTimer?.cancel();
// //     _stopAllRinging();
// //     _audioPlayer.dispose();
// //     super.dispose();
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: Colors.white,
// //       appBar: AppBar(
// //         backgroundColor: Colors.transparent,
// //         elevation: 0,
// //         automaticallyImplyLeading: true,
// //         iconTheme: IconThemeData(color: Colors.black),
// //         title: Row(
// //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //           children: [
// //             Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 Text(
// //                   'Chef Management',
// //                   style: TextStyle(
// //                     color: Colors.black,
// //                     fontWeight: FontWeight.bold,
// //                     fontSize: 20.sp,
// //                   ),
// //                 ),
// //                 if (_employeeRole != null && _employeeRole!.isNotEmpty)
// //                   Text(
// //                     'Role: ${_employeeRole!.replaceAll('_', ' ')}',
// //                     style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
// //                   ),
// //               ],
// //             ),
// //             GestureDetector(
// //               onTap: () {
// //                 setState(() {
// //                   _printSelected = !_printSelected;
// //                 });
// //                 ScaffoldMessenger.of(context).showSnackBar(
// //                   SnackBar(
// //                     content: Text(
// //                       _printSelected
// //                           ? 'Printing ENABLED ✅'
// //                           : 'Printing DISABLED ❌',
// //                       textAlign: TextAlign.center,
// //                     ),
// //                     duration: Duration(seconds: 1),
// //                     backgroundColor: _printSelected ? Colors.blue : Colors.grey,
// //                   ),
// //                 );
// //               },
// //               child: Container(
// //                 padding: EdgeInsets.all(8.r),
// //                 decoration: BoxDecoration(
// //                   color: _printSelected
// //                       ? Colors.blue.withOpacity(0.1)
// //                       : Colors.grey.withOpacity(0.1),
// //                   borderRadius: BorderRadius.circular(10.r),
// //                   border: Border.all(
// //                     color: _printSelected ? Colors.blue : Colors.grey,
// //                     width: 1,
// //                   ),
// //                 ),
// //                 child: Row(
// //                   children: [
// //                     Icon(
// //                       Icons.print,
// //                       color: _printSelected ? Colors.blue : Colors.grey,
// //                       size: 22.sp,
// //                     ),
// //                     SizedBox(width: 6.w),
// //                     Text(
// //                       _printSelected ? 'ON' : 'OFF',
// //                       style: TextStyle(
// //                         color: _printSelected ? Colors.blue : Colors.grey,
// //                         fontWeight: FontWeight.bold,
// //                         fontSize: 12.sp,
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //             ),
// //           ],
// //         ),
// //         actions: [
// //           Stack(
// //             children: [
// //               IconButton(
// //                 icon: Icon(
// //                   _isSoundEnabled
// //                       ? Icons.notifications_active
// //                       : Icons.notifications_off,
// //                   color: _pendingOrderIds.isNotEmpty
// //                       ? Colors.red
// //                       : Color(0xFFB15DC6),
// //                 ),
// //                 onPressed: () {
// //                   setState(() => _isSoundEnabled = !_isSoundEnabled);
// //                   if (!_isSoundEnabled && _isPlaying) {
// //                     _stopAllRinging();
// //                   } else if (_isSoundEnabled &&
// //                       _pendingOrderIds.isNotEmpty &&
// //                       !_isPlaying) {
// //                     _startRingingForOrder(_pendingOrderIds.first);
// //                   }
// //                   ScaffoldMessenger.of(context).showSnackBar(
// //                     SnackBar(
// //                       content: Text(
// //                         _isSoundEnabled ? 'Sound ON 🔔' : 'Sound OFF 🔕',
// //                         textAlign: TextAlign.center,
// //                       ),
// //                       duration: Duration(seconds: 1),
// //                       backgroundColor: _isSoundEnabled
// //                           ? Color(0xFFB15DC6)
// //                           : Colors.grey,
// //                     ),
// //                   );
// //                 },
// //               ),
// //               if (_pendingOrderIds.isNotEmpty && _isPlaying)
// //                 Positioned(
// //                   right: 10,
// //                   top: 10,
// //                   child: Container(
// //                     width: 8,
// //                     height: 8,
// //                     decoration: BoxDecoration(
// //                       color: Colors.red,
// //                       shape: BoxShape.circle,
// //                     ),
// //                   ),
// //                 ),
// //             ],
// //           ),
// //         ],
// //       ),
// //       body: Stack(
// //         children: [
// //           Column(
// //             children: [
// //               _buildTabBarWithFilter(),
// //               Expanded(
// //                 child: Container(
// //                   decoration: BoxDecoration(
// //                     gradient: LinearGradient(
// //                       begin: Alignment.topCenter,
// //                       end: Alignment.bottomCenter,
// //                       colors: [Colors.grey[50]!, Colors.grey[100]!],
// //                     ),
// //                   ),
// //                   child: IndexedStack(
// //                     index: _selectedTab,
// //                     children: [
// //                       RefreshIndicator(
// //                         onRefresh: _handleRefresh,
// //                         color: Color(0xFFB15DC6),
// //                         backgroundColor: Colors.white,
// //                         strokeWidth: 3.0,
// //                         child: AllOrdersTab(
// //                           orders: _displayOrders,
// //                           isLoading: _isLoading,
// //                           printSelected: _printSelected,
// //                           onOrderAccepted: _stopRingingForOrder,
// //                           onOrderUpdated: _handleOrderUpdate,
// //                           isRinging: _pendingOrderIds.isNotEmpty,
// //                           filterType: _selectedFilter,
// //                           employeeRole: _employeeRole,
// //                           userRole: _userRole,
// //                         ),
// //                       ),
// //                       RefreshIndicator(
// //                         onRefresh: _handleRefresh,
// //                         color: Color(0xFFB15DC6),
// //                         backgroundColor: Colors.white,
// //                         strokeWidth: 3.0,
// //                         child: ProcessingTab(
// //                           orders: _displayOrders,
// //                           isLoading: _isLoading,
// //                           onOrderUpdated: _handleOrderUpdate,
// //                           filterType: _selectedFilter,
// //                           employeeRole: _employeeRole,
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //               ),
// //             ],
// //           ),
// //           Positioned(
// //             bottom: 20.h,
// //             right: 20.w,
// //             child: GestureDetector(
// //               onTap: _handleRefresh,
// //               child: Container(
// //                 width: 56.sp,
// //                 height: 56.sp,
// //                 decoration: BoxDecoration(
// //                   color: Colors.white,
// //                   shape: BoxShape.circle,
// //                   boxShadow: [
// //                     BoxShadow(
// //                       color: Colors.black.withOpacity(0.15),
// //                       blurRadius: 8,
// //                       offset: const Offset(0, 4),
// //                     ),
// //                   ],
// //                   gradient: LinearGradient(
// //                     colors: [Color(0xFFB15DC6), Color(0xFF9C4AB8)],
// //                     begin: Alignment.topLeft,
// //                     end: Alignment.bottomRight,
// //                   ),
// //                 ),
// //                 child: Stack(
// //                   alignment: Alignment.center,
// //                   children: [
// //                     Icon(Icons.refresh, color: Colors.white, size: 24.sp),
// //                     if (_isLoading)
// //                       CircularProgressIndicator(
// //                         strokeWidth: 3,
// //                         valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
// //                         backgroundColor: Colors.transparent,
// //                       ),
// //                   ],
// //                 ),
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _buildTabBarWithFilter() {
// //     return Column(
// //       children: [
// //         Container(
// //           margin: EdgeInsets.symmetric(horizontal: 16.r, vertical: 16.r),
// //           padding: EdgeInsets.all(6.r),
// //           decoration: BoxDecoration(
// //             color: Colors.white,
// //             borderRadius: BorderRadius.circular(15.r),
// //             boxShadow: [
// //               BoxShadow(
// //                 color: Colors.black.withOpacity(0.1),
// //                 blurRadius: 12,
// //                 offset: const Offset(0, 3),
// //               ),
// //             ],
// //           ),
// //           child: Row(
// //             children: List.generate(_tabTitles.length, (index) {
// //               final isSelected = _selectedTab == index;
// //               return Expanded(
// //                 child: AnimatedContainer(
// //                   duration: const Duration(milliseconds: 300),
// //                   curve: Curves.easeInOut,
// //                   margin: EdgeInsets.symmetric(horizontal: 4.w),
// //                   decoration: BoxDecoration(
// //                     color: isSelected ? Color(0xFFB15DC6) : Colors.transparent,
// //                     borderRadius: BorderRadius.circular(12.r),
// //                     boxShadow: isSelected
// //                         ? [
// //                             BoxShadow(
// //                               color: Color(0xFFB15DC6).withOpacity(0.3),
// //                               blurRadius: 8,
// //                               offset: const Offset(0, 2),
// //                             ),
// //                           ]
// //                         : null,
// //                   ),
// //                   child: Material(
// //                     color: Colors.transparent,
// //                     child: InkWell(
// //                       onTap: () => setState(() {
// //                         _selectedTab = index;
// //                         _updateDisplayOrders();
// //                       }),
// //                       borderRadius: BorderRadius.circular(12.r),
// //                       child: Container(
// //                         height: 42.h,
// //                         alignment: Alignment.center,
// //                         child: Text(
// //                           _tabTitles[index],
// //                           style: TextStyle(
// //                             fontWeight: FontWeight.w600,
// //                             color: isSelected ? Colors.white : Colors.grey[700],
// //                             fontSize: 14.sp,
// //                           ),
// //                         ),
// //                       ),
// //                     ),
// //                   ),
// //                 ),
// //               );
// //             }),
// //           ),
// //         ),
// //       ],
// //     );
// //   }
// // }
// //
// // class AllOrdersTab extends StatefulWidget {
// //   final List<dynamic> orders;
// //   final bool isLoading;
// //   final bool printSelected;
// //   final Function(String) onOrderAccepted;
// //   final Function(String, String) onOrderUpdated;
// //   final bool isRinging;
// //   final String filterType;
// //   final String? employeeRole;
// //   final String? userRole;
// //
// //   const AllOrdersTab({
// //     super.key,
// //     required this.orders,
// //     required this.isLoading,
// //     required this.printSelected,
// //     required this.onOrderAccepted,
// //     required this.onOrderUpdated,
// //     required this.isRinging,
// //     required this.filterType,
// //     required this.employeeRole,
// //     required this.userRole,
// //   });
// //
// //   @override
// //   State<AllOrdersTab> createState() => _AllOrdersTabState();
// // }
// //
// // class _AllOrdersTabState extends State<AllOrdersTab> {
// //   final Map<int, bool> _selectedItems = {};
// //   String? connectedPrinterMac;
// //   bool isConnected = false;
// //   bool isConnecting = false;
// //   static const String kDefaultPrinterKey = 'default_printer_mac';
// //
// //   bool get _isChefMode => widget.filterType == 'chef';
// //   bool get _isOnlineMode => widget.filterType == 'online';
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _restorePrinterConnection();
// //   }
// //
// //   Future<void> saveDefaultPrinter(String mac) async {
// //     final prefs = await SharedPreferences.getInstance();
// //     await prefs.setString(kDefaultPrinterKey, mac);
// //   }
// //
// //   Future<String?> getDefaultPrinter() async {
// //     final prefs = await SharedPreferences.getInstance();
// //     return prefs.getString(kDefaultPrinterKey);
// //   }
// //
// //   Future<void> _restorePrinterConnection() async {
// //     try {
// //       final mac = await getDefaultPrinter();
// //       if (mac != null && mac.isNotEmpty) {
// //         final connected = await PrintBluetoothThermal.connect(
// //           macPrinterAddress: mac,
// //         );
// //
// //         if (connected) {
// //           final status = await PrintBluetoothThermal.connectionStatus;
// //           if (status) {
// //             connectedPrinterMac = mac;
// //             isConnected = true;
// //           }
// //         } else {
// //           connectedPrinterMac = null;
// //           isConnected = false;
// //         }
// //       }
// //     } catch (e) {
// //       connectedPrinterMac = null;
// //       isConnected = false;
// //     }
// //   }
// //
// //   Future<void> printInvoiceToPrinter(
// //     Map<String, dynamic> data,
// //     String printerMac,
// //   ) async {
// //     try {
// //       bool isConnected = await PrintBluetoothThermal.connectionStatus;
// //
// //       if (!isConnected) {
// //         await PrintBluetoothThermal.disconnect;
// //         await Future.delayed(Duration(milliseconds: 300));
// //
// //         isConnected = await PrintBluetoothThermal.connect(
// //           macPrinterAddress: printerMac,
// //         );
// //
// //         if (!isConnected) {
// //           throw Exception('Failed to connect to printer: $printerMac');
// //         }
// //
// //         connectedPrinterMac = printerMac;
// //         isConnected = true;
// //       }
// //
// //       await _printThermalkot(data);
// //     } catch (e) {
// //       await PrintBluetoothThermal.disconnect;
// //       isConnected = false;
// //       connectedPrinterMac = null;
// //       throw e;
// //     }
// //   }
// //
// //   String formatOrderType(String? type) {
// //     switch (type) {
// //       case 'TAKEAWAY':
// //         return 'Take Away';
// //       case 'DINE_IN':
// //         return 'Dine In';
// //       case 'DELIVERY':
// //         return 'Delivery';
// //       case 'TABLE_DINE_IN':
// //         return 'Table Dine In';
// //       default:
// //         return type?.replaceAll('_', ' ') ?? '';
// //     }
// //   }
// //
// //   Future<void> _printThermalkot(Map<String, dynamic> data) async {
// //     final items = data['order'] as List<dynamic>? ?? [];
// //
// //     await PrintBluetoothThermal.writeBytes(Uint8List.fromList([27, 97, 1]));
// //     await PrintBluetoothThermal.writeBytes(Uint8List.fromList([27, 69, 1]));
// //
// //     await PrintBluetoothThermal.writeString(
// //       printText: PrintTextSize(
// //         size: 2,
// //         text: "${data['vendorRegisteredName']?.toString().toUpperCase()}\n",
// //       ),
// //     );
// //
// //     await PrintBluetoothThermal.writeBytes(Uint8List.fromList([27, 33, 0]));
// //     await PrintBluetoothThermal.writeString(
// //       printText: PrintTextSize(
// //         size: 2,
// //         text: "------------------------------------------------\n",
// //       ),
// //     );
// //     await PrintBluetoothThermal.writeBytes(Uint8List.fromList([27, 33, 8]));
// //
// //     String left1 = "Order ID : ${data['orderId']}";
// //     String right1 = "Date : ${data['date'] ?? ''}";
// //
// //     String left2 = "Type     : ${formatOrderType(data['orderType'])}";
// //     String right2 = "Time : ${data['time'] ?? ''}";
// //
// //     String makeRow(String left, String right) {
// //       int maxWidth = 48;
// //       int spaces = maxWidth - left.length - right.length;
// //       if (spaces < 1) spaces = 1;
// //       return left + (" " * spaces) + right;
// //     }
// //
// //     await PrintBluetoothThermal.writeString(
// //       printText: PrintTextSize(size: 2, text: makeRow(left1, right1) + "\n"),
// //     );
// //     await PrintBluetoothThermal.writeString(
// //       printText: PrintTextSize(size: 2, text: makeRow(left2, right2) + "\n"),
// //     );
// //     await PrintBluetoothThermal.writeBytes(Uint8List.fromList([27, 33, 0]));
// //
// //     await PrintBluetoothThermal.writeString(
// //       printText: PrintTextSize(
// //         size: 2,
// //         text: "------------------------------------------------\n",
// //       ),
// //     );
// //
// //     await PrintBluetoothThermal.writeBytes(Uint8List.fromList([27, 33, 8]));
// //     await PrintBluetoothThermal.writeString(
// //       printText: PrintTextSize(
// //         size: 2,
// //         text: "ITEM                       QTY\n",
// //       ),
// //     );
// //     await PrintBluetoothThermal.writeBytes(Uint8List.fromList([27, 33, 0]));
// //
// //     await PrintBluetoothThermal.writeString(
// //       printText: PrintTextSize(
// //         size: 2,
// //         text: "------------------------------------------------\n",
// //       ),
// //     );
// //
// //     for (var item in items) {
// //       String name = (item['dishName'] ?? 'N/A').toString();
// //       if (name.length > 26) name = name.substring(0, 26);
// //
// //       final qty = item['quantity']?.toString() ?? '0';
// //       final line = name.padRight(28) + qty.padRight(10);
// //
// //       await PrintBluetoothThermal.writeString(
// //         printText: PrintTextSize(size: 2, text: "$line\n"),
// //       );
// //     }
// //
// //     await PrintBluetoothThermal.writeString(
// //       printText: PrintTextSize(
// //         size: 2,
// //         text: "------------------------------------------------\n",
// //       ),
// //     );
// //
// //     await PrintBluetoothThermal.writeBytes([29, 86, 65, 0]);
// //     await cutPaper();
// //   }
// //
// //   Future<void> cutPaper() async {
// //     await PrintBluetoothThermal.writeBytes([27, 100, 2]);
// //   }
// //
// //   Future<bool> ensureBluetoothPermissions() async {
// //     try {
// //       final bool isBluetoothOn = await PrintBluetoothThermal.bluetoothEnabled;
// //       if (!isBluetoothOn) {
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           const SnackBar(
// //             content: Text('Bluetooth is turned off. Please enable Bluetooth.'),
// //             duration: Duration(seconds: 3),
// //           ),
// //         );
// //         return false;
// //       }
// //
// //       Map<Permission, PermissionStatus> statuses = await [
// //         Permission.bluetoothScan,
// //         Permission.bluetoothConnect,
// //         Permission.bluetoothAdvertise,
// //         Permission.locationWhenInUse,
// //       ].request();
// //
// //       if (statuses[Permission.bluetoothScan]?.isGranted != true ||
// //           statuses[Permission.bluetoothConnect]?.isGranted != true) {
// //         _showBluetoothPermissionDialog();
// //         return false;
// //       }
// //       return true;
// //     } catch (e) {
// //       return false;
// //     }
// //   }
// //
// //   void _showBluetoothPermissionDialog() {
// //     showDialog(
// //       context: context,
// //       builder: (context) => AlertDialog(
// //         title: Text('Bluetooth Permission Needed'),
// //         content: Column(
// //           mainAxisSize: MainAxisSize.min,
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             Text('Nearby Devices permission is OFF'),
// //             SizedBox(height: 12.h),
// //             Text('Go to Settings > Apps > Your App > Permissions'),
// //             Text('Enable "Nearby devices" & "Bluetooth Scan"'),
// //             SizedBox(height: 12.h),
// //             Text(
// //               'Or tap below to open Settings directly',
// //               style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
// //             ),
// //           ],
// //         ),
// //         actions: [
// //           TextButton(
// //             onPressed: () => Navigator.pop(context),
// //             child: Text('Cancel'),
// //           ),
// //           ElevatedButton.icon(
// //             onPressed: () {
// //               Navigator.pop(context);
// //               openAppSettings();
// //             },
// //             icon: Icon(Icons.settings),
// //             label: Text('Open Settings'),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   String _getAcceptStatus() {
// //     return 'BEING_PREPARED';
// //   }
// //
// //   Future<void> _handleAcceptWithPrint(Map<String, dynamic> order) async {
// //     if (!widget.printSelected) {
// //       await _handleOrderAction(order, _getAcceptStatus());
// //       widget.onOrderAccepted(order['orderId'].toString());
// //       return;
// //     }
// //
// //     setState(() => isConnecting = true);
// //
// //     try {
// //       final savedMac = await getDefaultPrinter();
// //       final bluetoothOn = await PrintBluetoothThermal.bluetoothEnabled;
// //
// //       if (bluetoothOn && savedMac != null && savedMac.isNotEmpty) {
// //         bool connected = await PrintBluetoothThermal.connectionStatus;
// //
// //         if (!connected) {
// //           await PrintBluetoothThermal.disconnect;
// //           await Future.delayed(const Duration(milliseconds: 300));
// //           connected = await PrintBluetoothThermal.connect(
// //             macPrinterAddress: savedMac,
// //           );
// //         }
// //
// //         if (connected) {
// //           try {
// //             await printInvoiceToPrinter(order, savedMac);
// //             await _acceptOrderAfterPrint(order);
// //             return;
// //           } catch (e) {
// //             if (mounted) {
// //               _showPrinterSelectionDialog(order);
// //             }
// //             return;
// //           }
// //         }
// //       }
// //
// //       if (mounted) {
// //         _showPrinterSelectionDialog(order);
// //       }
// //     } finally {
// //       setState(() => isConnecting = false);
// //     }
// //   }
// //
// //   void _showPrinterSelectionDialog(Map<String, dynamic> order) {
// //     showDialog(
// //       context: context,
// //       barrierDismissible: false,
// //       builder: (context) {
// //         return AlertDialog(
// //           title: Text('Select Printer'),
// //           content: FutureBuilder<List<BluetoothInfo>>(
// //             future: PrintBluetoothThermal.pairedBluetooths,
// //             builder: (context, snapshot) {
// //               if (snapshot.connectionState == ConnectionState.waiting) {
// //                 return Container(
// //                   height: 200.h,
// //                   child: Center(child: CircularProgressIndicator()),
// //                 );
// //               }
// //
// //               if (snapshot.hasError ||
// //                   snapshot.data == null ||
// //                   snapshot.data!.isEmpty) {
// //                 return Container(
// //                   height: 200.h,
// //                   child: Column(
// //                     mainAxisAlignment: MainAxisAlignment.center,
// //                     children: [
// //                       Icon(
// //                         Icons.print_disabled,
// //                         size: 48.sp,
// //                         color: Colors.grey,
// //                       ),
// //                       SizedBox(height: 12.h),
// //                       Text('No printers found'),
// //                       SizedBox(height: 8.h),
// //                       Text('Please pair your printer first'),
// //                     ],
// //                   ),
// //                 );
// //               }
// //
// //               final printers = snapshot.data!;
// //               return Container(
// //                 height: 300.h,
// //                 width: double.maxFinite,
// //                 child: ListView.builder(
// //                   itemCount: printers.length,
// //                   itemBuilder: (context, index) {
// //                     final printer = printers[index];
// //                     return ListTile(
// //                       leading: Icon(Icons.print),
// //                       title: Text(printer.name),
// //                       subtitle: Text(printer.macAdress),
// //                       trailing: ElevatedButton(
// //                         onPressed: () async {
// //                           Navigator.pop(context);
// //                           await _tryPrintWithSelectedPrinter(order, printer);
// //                         },
// //                         child: Text('Print'),
// //                       ),
// //                     );
// //                   },
// //                 ),
// //               );
// //             },
// //           ),
// //           actions: [
// //             TextButton(
// //               onPressed: () async {
// //                 Navigator.pop(context);
// //                 await _acceptWithoutPrint(order);
// //               },
// //               child: Text('Accept Without Print'),
// //             ),
// //             TextButton(
// //               onPressed: () => Navigator.pop(context),
// //               child: Text('Cancel'),
// //             ),
// //           ],
// //         );
// //       },
// //     );
// //   }
// //
// //   Future<void> _tryPrintWithSelectedPrinter(
// //     Map<String, dynamic> order,
// //     BluetoothInfo printer,
// //   ) async {
// //     setState(() => isConnecting = true);
// //
// //     try {
// //       await printInvoiceToPrinter(order, printer.macAdress);
// //       await saveDefaultPrinter(printer.macAdress);
// //       await _acceptOrderAfterPrint(order);
// //     } catch (e) {
// //       if (mounted) {
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           SnackBar(
// //             content: Text('Print failed: ${e.toString()}'),
// //             backgroundColor: Colors.red,
// //           ),
// //         );
// //         _showPrintRetryDialog(order);
// //       }
// //     } finally {
// //       setState(() => isConnecting = false);
// //     }
// //   }
// //
// //   void _showPrintRetryDialog(Map<String, dynamic> order) {
// //     showDialog(
// //       context: context,
// //       builder: (context) => AlertDialog(
// //         title: Text('Print Failed'),
// //         content: Text(
// //           'Would you like to retry printing or accept the order without printing?',
// //         ),
// //         actions: [
// //           TextButton(
// //             onPressed: () => Navigator.pop(context),
// //             child: Text('Cancel'),
// //           ),
// //           TextButton(
// //             onPressed: () async {
// //               Navigator.pop(context);
// //               await _acceptWithoutPrint(order);
// //             },
// //             child: Text('Accept Without Print'),
// //           ),
// //           ElevatedButton(
// //             onPressed: () {
// //               Navigator.pop(context);
// //               _showPrinterSelectionDialog(order);
// //             },
// //             child: Text('Retry With Another Printer'),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Future<void> _acceptOrderAfterPrint(Map<String, dynamic> order) async {
// //     await _handleOrderAction(order, _getAcceptStatus());
// //     widget.onOrderAccepted(order['orderId'].toString());
// //
// //     if (mounted) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(
// //           content: Text('✅ Order accepted and printed successfully'),
// //           backgroundColor: Colors.green,
// //         ),
// //       );
// //     }
// //   }
// //
// //   Future<void> _acceptWithoutPrint(Map<String, dynamic> order) async {
// //     await _handleOrderAction(order, _getAcceptStatus());
// //     widget.onOrderAccepted(order['orderId'].toString());
// //
// //     if (mounted) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(
// //           content: Text('✅ Order accepted (without printing)'),
// //           backgroundColor: Colors.orange,
// //         ),
// //       );
// //     }
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     if (widget.isLoading) {
// //       return _buildLoadingState();
// //     }
// //
// //     if (widget.orders.isEmpty) {
// //       String message = '';
// //       String subtitle = '';
// //
// //       if (widget.employeeRole == null || widget.employeeRole!.isEmpty) {
// //         message = 'No Item Found';
// //         subtitle = '';
// //       } else if (_isChefMode) {
// //         message = 'No pending orders';
// //         subtitle = 'New orders will appear here automatically';
// //       } else {
// //         message = 'No pending online orders';
// //         subtitle = 'Pending orders will appear here automatically';
// //       }
// //
// //       return _buildEmptyState(
// //         icon: widget.employeeRole == null
// //             ? Icons.warning
// //             : Icons.inbox_outlined,
// //         message: message,
// //         subtitle: subtitle,
// //       );
// //     }
// //
// //     return ListView.builder(
// //       itemCount: widget.orders.length,
// //       padding: EdgeInsets.all(16.w),
// //       itemBuilder: (context, index) {
// //         return _buildOrderCard(widget.orders[index]);
// //       },
// //     );
// //   }
// //
// //   Widget _buildOrderCard(Map<String, dynamic> order) {
// //     final items = order['order'] ?? [];
// //     final status = order['status'] ?? 'PENDING';
// //     final isPending = status == 'PENDING' || status == 'CONFIRMED';
// //
// //     // Check if order comes from vendor
// //     bool isFromVendor = false;
// //
// //     if (order['isFromVendor'] != null) {
// //       isFromVendor =
// //           order['isFromVendor'] == true ||
// //           order['isFromVendor'] == 'true' ||
// //           order['isFromVendor'].toString().toLowerCase() == 'true';
// //     } else if (order['vendorId'] != null && order['vendorId'] > 0) {
// //       isFromVendor = true;
// //     } else if (order['source'] != null &&
// //         order['source'].toString().toLowerCase() == 'vendor') {
// //       isFromVendor = true;
// //     } else if (order['orderType'] != null &&
// //         order['orderType'].toString().toLowerCase().contains('vendor')) {
// //       isFromVendor = true;
// //     }
// //
// //     return AnimatedContainer(
// //       duration: const Duration(milliseconds: 300),
// //       margin: EdgeInsets.only(bottom: 16.h),
// //       child: Card(
// //         shape: RoundedRectangleBorder(
// //           borderRadius: BorderRadius.circular(20.r),
// //         ),
// //         elevation: 4,
// //         shadowColor: _getStatusColor(status).withOpacity(0.1),
// //         child: Container(
// //           decoration: BoxDecoration(
// //             borderRadius: BorderRadius.circular(20.r),
// //             color: Colors.white,
// //             border: widget.isRinging && isPending
// //                 ? Border.all(color: Colors.red.withOpacity(0.5), width: 2)
// //                 : null,
// //             boxShadow: widget.isRinging && isPending
// //                 ? [
// //                     BoxShadow(
// //                       color: Colors.red.withOpacity(0.2),
// //                       blurRadius: 10,
// //                       spreadRadius: 2,
// //                     ),
// //                   ]
// //                 : null,
// //           ),
// //           child: Column(
// //             children: [
// //               // Header section with Order ID and Order Type
// //               Container(
// //                 padding: EdgeInsets.all(16.r),
// //                 decoration: BoxDecoration(
// //                   color: Colors.grey[50],
// //                   borderRadius: BorderRadius.only(
// //                     topLeft: Radius.circular(20.r),
// //                     topRight: Radius.circular(20.r),
// //                   ),
// //                 ),
// //                 child: Row(
// //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                   children: [
// //                     Row(
// //                       children: [
// //                         if (widget.isRinging && isPending)
// //                           Icon(
// //                             Icons.notifications_active,
// //                             color: Colors.red,
// //                             size: 18.sp,
// //                           ),
// //                         SizedBox(
// //                           width: widget.isRinging && isPending ? 8.w : 0,
// //                         ),
// //                         Text(
// //                           'Order #${order['orderId'] ?? 'N/A'}',
// //                           style: TextStyle(
// //                             fontWeight: FontWeight.bold,
// //                             fontSize: 16.sp,
// //                             color: Colors.grey[800],
// //                           ),
// //                         ),
// //                         _buildVendorBadge(order),
// //                       ],
// //                     ),
// //                     _buildOrderTypeChip(order['orderType']),
// //                   ],
// //                 ),
// //               ),
// //
// //               // Simplified Items section with checkboxes
// //               Padding(
// //                 padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 12.h),
// //                 child: Column(
// //                   crossAxisAlignment: CrossAxisAlignment.start,
// //                   children: [
// //                     Text(
// //                       'Items:',
// //                       style: TextStyle(
// //                         fontWeight: FontWeight.w600,
// //                         fontSize: 14.sp,
// //                         color: Colors.grey[700],
// //                       ),
// //                     ),
// //                     SizedBox(height: 8.h),
// //
// //                     // Simplified checkbox list
// //                     Column(
// //                       children: items.map<Widget>((item) {
// //                         final listId = item['listId'] ?? 0;
// //                         final dishName = item['dishName'] ?? 'Unknown Item';
// //                         final quantity = item['quantity'] ?? 1;
// //
// //                         return Container(
// //                           margin: EdgeInsets.only(bottom: 8.h),
// //                           child: Row(
// //                             children: [
// //                               Checkbox(
// //                                 value: _selectedItems[listId] ?? false,
// //                                 onChanged: (value) {
// //                                   setState(() {
// //                                     _selectedItems[listId] = value ?? false;
// //                                   });
// //                                 },
// //                                 activeColor: Colors.green,
// //                                 checkColor: Colors.white,
// //                               ),
// //                               SizedBox(width: 8.w),
// //                               Expanded(
// //                                 child: Text(
// //                                   '$dishName x$quantity',
// //                                   style: TextStyle(
// //                                     fontSize: 14.sp,
// //                                     color: Colors.grey[800],
// //                                   ),
// //                                 ),
// //                               ),
// //                             ],
// //                           ),
// //                         );
// //                       }).toList(),
// //                     ),
// //
// //                     SizedBox(height: 12.h),
// //                     _buildActionButtons(order),
// //                   ],
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildVendorBadge(Map<String, dynamic> order) {
// //     final userId = order['userId'];
// //
// //     // User order → show nothing
// //     if (userId == null) {
// //       return const SizedBox.shrink();
// //     }
// //
// //     // Vendor order → show badge
// //     return Container(
// //       margin: EdgeInsets.only(left: 8.w),
// //       padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
// //       decoration: BoxDecoration(
// //         color: Colors.blue.withOpacity(0.15),
// //         borderRadius: BorderRadius.circular(8.r),
// //         border: Border.all(color: Colors.blue),
// //       ),
// //       child: Text(
// //         // 'Vendor Order',
// //         'Online Order',
// //         style: TextStyle(
// //           fontSize: 10.sp,
// //           fontWeight: FontWeight.w600,
// //           color: Colors.blue,
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildOrderTypeChip(String? orderType) {
// //     final color = _getOrderTypeColor(orderType);
// //     return Container(
// //       padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
// //       decoration: BoxDecoration(
// //         gradient: LinearGradient(
// //           colors: [color, color.withOpacity(0.8)],
// //           begin: Alignment.topLeft,
// //           end: Alignment.bottomRight,
// //         ),
// //         borderRadius: BorderRadius.circular(15.r),
// //         boxShadow: [
// //           BoxShadow(
// //             color: color.withOpacity(0.3),
// //             blurRadius: 6,
// //             offset: const Offset(0, 2),
// //           ),
// //         ],
// //       ),
// //       child: Text(
// //         formatOrderType(orderType),
// //         style: TextStyle(
// //           fontSize: 10.sp,
// //           color: Colors.white,
// //           fontWeight: FontWeight.w600,
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Color _getStatusColor(String status) {
// //     switch (status) {
// //       case 'PENDING':
// //         return Colors.orange;
// //       case 'CONFIRMED':
// //         return Colors.blue;
// //       case 'BEING_PREPARED':
// //         return Colors.purple;
// //       case 'ORDER_IS_READY':
// //         return Colors.green;
// //       case 'CANCELLED':
// //         return Colors.red;
// //       case 'DELIVERED':
// //         return Colors.teal;
// //       default:
// //         return Colors.grey;
// //     }
// //   }
// //
// //   Widget _buildActionButtons(Map<String, dynamic> order) {
// //     return Row(
// //       children: [
// //         Expanded(
// //           child: AnimatedContainer(
// //             duration: const Duration(milliseconds: 300),
// //             child: ElevatedButton.icon(
// //               icon: isConnecting
// //                   ? SizedBox(
// //                       width: 18.sp,
// //                       height: 18.sp,
// //                       child: CircularProgressIndicator(
// //                         strokeWidth: 2,
// //                         valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
// //                       ),
// //                     )
// //                   : Icon(Icons.check_circle, size: 18.sp),
// //               label: Text(
// //                 isConnecting ? 'Processing...' : 'Accept',
// //                 style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
// //               ),
// //               onPressed: isConnecting
// //                   ? null
// //                   : () async {
// //                       await _handleAcceptWithPrint(order);
// //                     },
// //               style: ElevatedButton.styleFrom(
// //                 backgroundColor: Colors.green,
// //                 foregroundColor: Colors.white,
// //                 padding: EdgeInsets.symmetric(vertical: 14.h),
// //                 shape: RoundedRectangleBorder(
// //                   borderRadius: BorderRadius.circular(12.r),
// //                 ),
// //                 elevation: 3,
// //                 shadowColor: Colors.green.withOpacity(0.3),
// //               ),
// //             ),
// //           ),
// //         ),
// //         SizedBox(width: 12.w),
// //         Expanded(
// //           child: AnimatedContainer(
// //             duration: const Duration(milliseconds: 300),
// //             child: OutlinedButton.icon(
// //               icon: Icon(Icons.cancel, size: 18.sp),
// //               label: Text(
// //                 'Decline',
// //                 style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
// //               ),
// //               onPressed: () => _handleOrderAction(order, 'CANCELLED'),
// //               style: OutlinedButton.styleFrom(
// //                 foregroundColor: Colors.red,
// //                 side: BorderSide(color: Colors.red, width: 1.5),
// //                 padding: EdgeInsets.symmetric(vertical: 14.h),
// //                 shape: RoundedRectangleBorder(
// //                   borderRadius: BorderRadius.circular(12.r),
// //                 ),
// //               ),
// //             ),
// //           ),
// //         ),
// //       ],
// //     );
// //   }
// //
// //   Color _getOrderTypeColor(String? orderType) {
// //     const typeColors = {
// //       'DELIVERY': Colors.blue,
// //       'TAKEAWAY': Colors.green,
// //       'DINE_IN': Colors.orange,
// //       'TABLE_DINE_IN': Colors.purple,
// //     };
// //     return typeColors[orderType?.toUpperCase()] ?? Colors.grey;
// //   }
// //
// //   Future<void> _handleOrderAction(
// //     Map<String, dynamic> order,
// //     String status,
// //   ) async {
// //     final orderId = order['orderId'];
// //     final items = order['order'] ?? [];
// //
// //     if (status == 'BEING_PREPARED' && _isChefMode) {
// //       for (var item in items) {
// //         final listId = item['listId'];
// //         final isChecked = _selectedItems[listId] ?? true;
// //
// //         if (!isChecked) {
// //           await food_authservice.cancelOrderItem(listId);
// //         }
// //       }
// //     }
// //
// //     final success = await food_authservice.updateOrderStatus(orderId, status);
// //
// //     if (success && mounted) {
// //       widget.onOrderUpdated(orderId.toString(), status);
// //
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(
// //           content: Text('Order status updated to $status'),
// //           backgroundColor: Colors.green,
// //         ),
// //       );
// //     } else if (mounted) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(
// //           content: Text('Failed to update order status'),
// //           backgroundColor: Colors.red,
// //         ),
// //       );
// //     }
// //   }
// //
// //   Map<String, String> _formatDateTime(String? rawDateTime) {
// //     if (rawDateTime == null) return {'date': 'N/A', 'time': 'N/A'};
// //     try {
// //       final parsedDateTime = DateTime.parse(rawDateTime);
// //       return {
// //         'date': DateFormat('dd MMM yyyy').format(parsedDateTime),
// //         'time': DateFormat('hh:mm a').format(parsedDateTime),
// //       };
// //     } catch (e) {
// //       return {'date': 'N/A', 'time': 'N/A'};
// //     }
// //   }
// //
// //   Widget _buildLoadingState() {
// //     return Center(
// //       child: Column(
// //         mainAxisAlignment: MainAxisAlignment.center,
// //         children: [
// //           Container(
// //             padding: EdgeInsets.all(20.r),
// //             decoration: BoxDecoration(
// //               color: Colors.white,
// //               shape: BoxShape.circle,
// //               boxShadow: [
// //                 BoxShadow(
// //                   color: Colors.black.withOpacity(0.1),
// //                   blurRadius: 10,
// //                   offset: const Offset(0, 5),
// //                 ),
// //               ],
// //             ),
// //             child: CircularProgressIndicator(
// //               valueColor: AlwaysStoppedAnimation<Color>(Colors.deepOrange),
// //               strokeWidth: 3,
// //             ),
// //           ),
// //           SizedBox(height: 20.h),
// //           Text(
// //             'Loading orders...',
// //             style: TextStyle(
// //               fontSize: 16.sp,
// //               color: Colors.grey[600],
// //               fontWeight: FontWeight.w500,
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _buildEmptyState({
// //     required IconData icon,
// //     required String message,
// //     String? subtitle,
// //   }) {
// //     return Center(
// //       child: Padding(
// //         padding: EdgeInsets.all(32.r),
// //         child: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             Container(
// //               padding: EdgeInsets.all(24.r),
// //               decoration: BoxDecoration(
// //                 color: Colors.white,
// //                 shape: BoxShape.circle,
// //                 boxShadow: [
// //                   BoxShadow(
// //                     color: Colors.black.withOpacity(0.1),
// //                     blurRadius: 15,
// //                     offset: const Offset(0, 5),
// //                   ),
// //                 ],
// //               ),
// //               child: Icon(icon, size: 48.sp, color: Colors.grey[400]),
// //             ),
// //             SizedBox(height: 20.h),
// //             Text(
// //               message,
// //               style: TextStyle(
// //                 fontSize: 18.sp,
// //                 color: Colors.grey[600],
// //                 fontWeight: FontWeight.w600,
// //               ),
// //               textAlign: TextAlign.center,
// //             ),
// //             if (subtitle != null) ...[
// //               SizedBox(height: 8.h),
// //               Text(
// //                 subtitle,
// //                 style: TextStyle(fontSize: 14.sp, color: Colors.grey[500]),
// //                 textAlign: TextAlign.center,
// //               ),
// //             ],
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }
// //
// // class ProcessingTab extends StatefulWidget {
// //   final List<dynamic> orders;
// //   final bool isLoading;
// //   final Function(String, String) onOrderUpdated;
// //   final String filterType;
// //   final String? employeeRole;
// //
// //   const ProcessingTab({
// //     super.key,
// //     required this.orders,
// //     required this.isLoading,
// //     required this.onOrderUpdated,
// //     required this.filterType,
// //     required this.employeeRole,
// //   });
// //
// //   @override
// //   State<ProcessingTab> createState() => _ProcessingTabState();
// // }
// //
// // class _ProcessingTabState extends State<ProcessingTab> {
// //   final Map<int, bool> _selectedItems = {};
// //
// //   bool get _isChefMode => widget.filterType == 'chef';
// //   bool get _isOnlineMode => widget.filterType == 'online';
// //
// //   Color _getStatusColor(String status) {
// //     switch (status) {
// //       case 'PENDING':
// //         return Colors.orange;
// //       case 'CONFIRMED':
// //         return Colors.blue;
// //       case 'BEING_PREPARED':
// //         return Colors.purple;
// //       case 'ORDER_IS_READY':
// //         return Colors.green;
// //       case 'CANCELLED':
// //         return Colors.red;
// //       case 'DELIVERED':
// //         return Colors.teal;
// //       default:
// //         return Colors.grey;
// //     }
// //   }
// //
// //   Color _getOrderTypeColor(String? orderType) {
// //     const typeColors = {
// //       'DELIVERY': Colors.blue,
// //       'TAKEAWAY': Colors.green,
// //       'DINE_IN': Colors.orange,
// //       'TABLE_DINE_IN': Colors.purple,
// //     };
// //     return typeColors[orderType?.toUpperCase()] ?? Colors.grey;
// //   }
// //
// //   Widget _buildVendorBadge(Map<String, dynamic> order) {
// //     final userId = order['userId'];
// //
// //     if (userId != null) {
// //       return const SizedBox.shrink(); // User order → show nothing
// //     }
// //
// //     return Container(
// //       margin: EdgeInsets.only(left: 8.w),
// //       padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
// //       decoration: BoxDecoration(
// //         color: Colors.blue.withOpacity(0.15),
// //         borderRadius: BorderRadius.circular(8.r),
// //         border: Border.all(color: Colors.blue),
// //       ),
// //       child: Text(
// //         'Vendor Order',
// //         style: TextStyle(
// //           fontSize: 10.sp,
// //           fontWeight: FontWeight.w600,
// //           color: Colors.blue,
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildOrderTypeChip(String? orderType) {
// //     final color = _getOrderTypeColor(orderType);
// //     return Container(
// //       padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
// //       decoration: BoxDecoration(
// //         gradient: LinearGradient(
// //           colors: [color, color.withOpacity(0.8)],
// //           begin: Alignment.topLeft,
// //           end: Alignment.bottomRight,
// //         ),
// //         borderRadius: BorderRadius.circular(15.r),
// //         boxShadow: [
// //           BoxShadow(
// //             color: color.withOpacity(0.3),
// //             blurRadius: 6,
// //             offset: const Offset(0, 2),
// //           ),
// //         ],
// //       ),
// //       child: Text(
// //         formatOrderType(orderType),
// //         style: TextStyle(
// //           fontSize: 10.sp,
// //           color: Colors.white,
// //           fontWeight: FontWeight.w600,
// //         ),
// //       ),
// //     );
// //   }
// //
// //   String formatOrderType(String? type) {
// //     switch (type) {
// //       case 'TAKEAWAY':
// //         return 'Take Away';
// //       case 'DINE_IN':
// //         return 'Dine In';
// //       case 'DELIVERY':
// //         return 'Delivery';
// //       case 'TABLE_DINE_IN':
// //         return 'Table Dine In';
// //       default:
// //         return type?.replaceAll('_', ' ') ?? '';
// //     }
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     if (widget.isLoading) {
// //       return _buildLoadingState();
// //     }
// //
// //     if (widget.orders.isEmpty) {
// //       String message = '';
// //       String subtitle = '';
// //
// //       if (widget.employeeRole == null || widget.employeeRole!.isEmpty) {
// //         message = 'No Item Found';
// //         subtitle = '';
// //       } else if (_isChefMode) {
// //         message = 'No cooking orders';
// //         subtitle = 'Orders being cooked will appear here automatically';
// //       } else {
// //         message = 'No processing online orders';
// //         subtitle = 'Processing online orders will appear here automatically';
// //       }
// //
// //       return _buildEmptyState(
// //         icon: widget.employeeRole == null ? Icons.warning : Icons.update,
// //         message: message,
// //         subtitle: subtitle,
// //       );
// //     }
// //
// //     return ListView.builder(
// //       itemCount: widget.orders.length,
// //       padding: EdgeInsets.all(16.w),
// //       itemBuilder: (context, index) {
// //         return _buildOrderCard(widget.orders[index]);
// //       },
// //     );
// //   }
// //
// //   Widget _buildOrderCard(Map<String, dynamic> order) {
// //     final items = order['order'] ?? [];
// //     final status = order['status'] ?? 'BEING_PREPARED';
// //
// //     return AnimatedContainer(
// //       duration: const Duration(milliseconds: 300),
// //       margin: EdgeInsets.only(bottom: 16.h),
// //       child: Card(
// //         shape: RoundedRectangleBorder(
// //           borderRadius: BorderRadius.circular(20.r),
// //         ),
// //         elevation: 4,
// //         shadowColor: _getStatusColor(status).withOpacity(0.1),
// //         child: Container(
// //           decoration: BoxDecoration(
// //             borderRadius: BorderRadius.circular(20.r),
// //             color: Colors.white,
// //           ),
// //           child: Column(
// //             children: [
// //               // Header section with Order ID and Order Type
// //               Container(
// //                 padding: EdgeInsets.all(16.r),
// //                 decoration: BoxDecoration(
// //                   color: Colors.grey[50],
// //                   borderRadius: BorderRadius.only(
// //                     topLeft: Radius.circular(20.r),
// //                     topRight: Radius.circular(20.r),
// //                   ),
// //                 ),
// //                 child: Row(
// //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                   children: [
// //                     Row(
// //                       children: [
// //                         Text(
// //                           'Order #${order['orderId'] ?? 'N/A'}',
// //                           style: TextStyle(
// //                             fontWeight: FontWeight.bold,
// //                             fontSize: 16.sp,
// //                             color: Colors.grey[800],
// //                           ),
// //                         ),
// //                         _buildVendorBadge(order),
// //                       ],
// //                     ),
// //                     _buildOrderTypeChip(order['orderType']),
// //                   ],
// //                 ),
// //               ),
// //
// //               // Simplified Items section with checkboxes
// //               Padding(
// //                 padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 12.h),
// //                 child: Column(
// //                   crossAxisAlignment: CrossAxisAlignment.start,
// //                   children: [
// //                     Text(
// //                       'Items:',
// //                       style: TextStyle(
// //                         fontWeight: FontWeight.w600,
// //                         fontSize: 14.sp,
// //                         color: Colors.grey[700],
// //                       ),
// //                     ),
// //                     SizedBox(height: 8.h),
// //
// //                     // Simplified checkbox list
// //                     Column(
// //                       children: items.map<Widget>((item) {
// //                         final listId = item['listId'] ?? 0;
// //                         final dishName =
// //                             item['dishName'] ?? item['name'] ?? 'Unknown Item';
// //                         final quantity = item['quantity'] ?? 1;
// //
// //                         return Container(
// //                           margin: EdgeInsets.only(bottom: 8.h),
// //                           child: Row(
// //                             children: [
// //                               Checkbox(
// //                                 value: _selectedItems[listId] ?? false,
// //                                 onChanged: (value) {
// //                                   setState(() {
// //                                     _selectedItems[listId] = value ?? false;
// //                                   });
// //                                 },
// //                                 activeColor: Colors.orange,
// //                                 checkColor: Colors.white,
// //                               ),
// //                               SizedBox(width: 8.w),
// //                               Expanded(
// //                                 child: Text(
// //                                   '$dishName x$quantity',
// //                                   style: TextStyle(
// //                                     fontSize: 14.sp,
// //                                     color: Colors.grey[800],
// //                                   ),
// //                                 ),
// //                               ),
// //                             ],
// //                           ),
// //                         );
// //                       }).toList(),
// //                     ),
// //
// //                     SizedBox(height: 12.h),
// //                     _buildActionButtons(order),
// //                   ],
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildActionButtons(Map<String, dynamic> order) {
// //     final status = order['status'] ?? 'BEING_PREPARED';
// //     final isConfirmed = status == 'CONFIRMED';
// //     final isBeingPrepared = status == 'BEING_PREPARED';
// //
// //     return Row(
// //       children: [
// //         if (_isOnlineMode && isConfirmed)
// //           Expanded(
// //             child: AnimatedContainer(
// //               duration: const Duration(milliseconds: 300),
// //               child: ElevatedButton.icon(
// //                 icon: Icon(Icons.restaurant, size: 18.sp),
// //                 label: Text(
// //                   'Start Cooking',
// //                   style: TextStyle(
// //                     fontSize: 14.sp,
// //                     fontWeight: FontWeight.w600,
// //                   ),
// //                 ),
// //                 onPressed: () => _handleOrderAction(order, 'BEING_PREPARED'),
// //                 style: ElevatedButton.styleFrom(
// //                   backgroundColor: Colors.green,
// //                   foregroundColor: Colors.white,
// //                   padding: EdgeInsets.symmetric(vertical: 14.h),
// //                   shape: RoundedRectangleBorder(
// //                     borderRadius: BorderRadius.circular(12.r),
// //                   ),
// //                   elevation: 3,
// //                   shadowColor: Colors.green.withOpacity(0.3),
// //                 ),
// //               ),
// //             ),
// //           ),
// //
// //         if (_isOnlineMode && isConfirmed) SizedBox(width: 12.w),
// //
// //         if (isBeingPrepared)
// //           Expanded(
// //             child: AnimatedContainer(
// //               duration: const Duration(milliseconds: 300),
// //               child: ElevatedButton.icon(
// //                 icon: Icon(Icons.done_all, size: 18.sp),
// //                 label: Text(
// //                   _isChefMode ? 'Ready to Serve' : 'Mark as Ready',
// //                   style: TextStyle(
// //                     fontSize: 14.sp,
// //                     fontWeight: FontWeight.w600,
// //                   ),
// //                 ),
// //                 onPressed: () => _handleOrderAction(order, 'ORDER_IS_READY'),
// //                 style: ElevatedButton.styleFrom(
// //                   backgroundColor: Colors.green,
// //                   foregroundColor: Colors.white,
// //                   padding: EdgeInsets.symmetric(vertical: 14.h),
// //                   shape: RoundedRectangleBorder(
// //                     borderRadius: BorderRadius.circular(12.r),
// //                   ),
// //                   elevation: 3,
// //                   shadowColor: Colors.green.withOpacity(0.3),
// //                 ),
// //               ),
// //             ),
// //           ),
// //       ],
// //     );
// //   }
// //
// //   Future<void> _handleOrderAction(
// //     Map<String, dynamic> order,
// //     String status,
// //   ) async {
// //     final orderId = order['orderId'];
// //     final success = await food_authservice.updateOrderStatus(orderId, status);
// //
// //     if (success && mounted) {
// //       widget.onOrderUpdated(orderId.toString(), status);
// //
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(
// //           content: Text('Order marked as $status'),
// //           backgroundColor: Colors.green,
// //         ),
// //       );
// //     } else if (mounted) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(
// //           content: Text('Failed to update order status'),
// //           backgroundColor: Colors.red,
// //         ),
// //       );
// //     }
// //   }
// //
// //   Widget _buildLoadingState() {
// //     return Center(
// //       child: Column(
// //         mainAxisAlignment: MainAxisAlignment.center,
// //         children: [
// //           Container(
// //             padding: EdgeInsets.all(20.r),
// //             decoration: BoxDecoration(
// //               color: Colors.white,
// //               shape: BoxShape.circle,
// //               boxShadow: [
// //                 BoxShadow(
// //                   color: Colors.black.withOpacity(0.1),
// //                   blurRadius: 10,
// //                   offset: const Offset(0, 5),
// //                 ),
// //               ],
// //             ),
// //             child: CircularProgressIndicator(
// //               valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
// //               strokeWidth: 3,
// //             ),
// //           ),
// //           SizedBox(height: 20.h),
// //           Text(
// //             'Loading orders...',
// //             style: TextStyle(
// //               fontSize: 16.sp,
// //               color: Colors.grey[600],
// //               fontWeight: FontWeight.w500,
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _buildEmptyState({
// //     required IconData icon,
// //     required String message,
// //     String? subtitle,
// //   }) {
// //     return Center(
// //       child: Padding(
// //         padding: EdgeInsets.all(32.r),
// //         child: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             Container(
// //               padding: EdgeInsets.all(24.r),
// //               decoration: BoxDecoration(
// //                 color: Colors.white,
// //                 shape: BoxShape.circle,
// //                 boxShadow: [
// //                   BoxShadow(
// //                     color: Colors.black.withOpacity(0.1),
// //                     blurRadius: 15,
// //                     offset: const Offset(0, 5),
// //                   ),
// //                 ],
// //               ),
// //               child: Icon(icon, size: 48.sp, color: Colors.grey[400]),
// //             ),
// //             SizedBox(height: 20.h),
// //             Text(
// //               message,
// //               style: TextStyle(
// //                 fontSize: 18.sp,
// //                 color: Colors.grey[600],
// //                 fontWeight: FontWeight.w600,
// //               ),
// //               textAlign: TextAlign.center,
// //             ),
// //             if (subtitle != null) ...[
// //               SizedBox(height: 8.h),
// //               Text(
// //                 subtitle,
// //                 style: TextStyle(fontSize: 14.sp, color: Colors.grey[500]),
// //                 textAlign: TextAlign.center,
// //               ),
// //             ],
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }
//
// import 'dart:typed_data';
// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:intl/intl.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:audioplayers/audioplayers.dart';
// import '../Api/food_authservice.dart';
// import '../printservice/printservice.dart';
//
// // ─── Design Tokens ─────────────────────────────────────────────────────────────
// class _C {
//   static const bg = Color(0xFFF7F8FC);
//   static const white = Color(0xFFFFFFFF);
//   static const border = Color(0xFFEEEFF5);
//   static const accent = Color(0xFFB15DC6);
//   static const accentDark = Color(0xFF8B3FA0);
//   static const accentLight = Color(0xFFF5E8FA);
//   static const green = Color(0xFF10B981);
//   static const greenLight = Color(0xFFD1FAE5);
//   static const greenDark = Color(0xFF10B981);
//   static const red = Color(0xFFEF4444);
//   static const redLight = Color(0xFFFFFFFF);
//   static const blue = Color(0xFF3B82F6);
//   static const blueLight = Color(0xFFDBEAFE);
//   static const amber = Color(0xFFF59E0B);
//   static const amberLight = Color(0xFFFFFFFF);
//   static const purple = Color(0xFF8B5CF6);
//   static const purpleLight = Color(0xFFEDE9FE);
//   static const orange = Color(0xFFF97316);
//   static const orangeLight = Color(0xFFFFEDD5);
//   static const teal = Color(0xFF14B8A6);
//   static const tealLight = Color(0xFFCCFBF1);
//   static const text1 = Color(0xFF111827);
//   static const text2 = Color(0xFF6B7280);
//   static const text3 = Color(0xFFB0B3C1);
//   static const shadow = Color(0x0A000000);
//   static const shadowMd = Color(0x14000000);
//
//   static LinearGradient get gradient => const LinearGradient(
//     colors: [accent, accentDark],
//     begin: Alignment.topLeft,
//     end: Alignment.bottomRight,
//   );
// }
//
// // ─── chef_management ──────────────────────────────────────────────────────────
// class chef_management extends StatefulWidget {
//   const chef_management({super.key});
//   @override
//   State<chef_management> createState() => _ChefManagementState();
// }
//
// class _ChefManagementState extends State<chef_management>
//     with SingleTickerProviderStateMixin {
//   final List<String> _tabTitles = ['All Orders', 'Processing'];
//   int _selectedTab = 0;
//   List<dynamic> _allOrders = [];
//   List<dynamic> _filteredOrders = [];
//   List<dynamic> _displayOrders = [];
//   bool _isLoading = true;
//   bool _printSelected = true;
//   String _selectedFilter = 'chef';
//   Set<String> _acknowledgedOrderIds = {};
//
//   final AudioPlayer _audioPlayer = AudioPlayer();
//   Set<String> _pendingOrderIds = {};
//   Set<String> _ringingOrderIds = {};
//   Timer? _orderPollingTimer;
//   bool _isPlaying = false;
//   bool _isSoundEnabled = true;
//
//   String? _employeeRole;
//   String? _userRole;
//   int _previousOrderCount = 0;
//
//   final List<String> _validChefTypes = [
//     'Chef_North',
//     'Chef_South',
//     'Chef_Continental',
//     'Chef_Chinese',
//     'Chef_All',
//     'Tea_stall',
//     'Snacks',
//     'Bakery',
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     _loadUserRoles();
//     _initializeSound();
//     _fetchOrders();
//     _startOrderPolling();
//   }
//
//   Future<void> _loadUserRoles() async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       _employeeRole = prefs.getString('employeRole');
//       _userRole = prefs.getString('role');
//     });
//   }
//
//   Future<void> _fetchOrders() async {
//     setState(() => _isLoading = true);
//     try {
//       final allOrders = await food_authservice.getAllOrders();
//       List filteredOrders = allOrders.where((order) {
//         final type = (order['orderType'] ?? '').toString().toUpperCase();
//         return [
//           'DINE_IN',
//           'DELIVERY',
//           'TAKEAWAY',
//           'TABLE_DINE_IN',
//         ].contains(type);
//       }).toList();
//       filteredOrders = _applyRoleFiltering(filteredOrders);
//       final previousCount = _allOrders.length;
//       setState(() {
//         _allOrders = filteredOrders;
//         _applyFilter();
//         _updateDisplayOrders();
//       });
//       if (filteredOrders.length > previousCount) {
//         _findAndRingNewOrders(previousCount, filteredOrders);
//       } else if (filteredOrders.length < previousCount) {
//         _cleanupCompletedOrders(filteredOrders);
//       }
//       _previousOrderCount = filteredOrders.length;
//     } catch (e) {
//       debugPrint('Error fetching orders: $e');
//       _showSnack('Failed to load orders', _C.red);
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }
//
//   void _findAndRingNewOrders(int previousCount, List<dynamic> currentOrders) {
//     if (previousCount == 0) {
//       for (var order in currentOrders) _triggerOrderNotificationIfNeeded(order);
//       return;
//     }
//     final previousOrderIds = _allOrders
//         .take(previousCount)
//         .map((o) => o['orderId'].toString())
//         .toSet();
//     for (var order in currentOrders) {
//       if (!previousOrderIds.contains(order['orderId'].toString())) {
//         _triggerOrderNotificationIfNeeded(order);
//       }
//     }
//   }
//
//   void _triggerOrderNotificationIfNeeded(Map<String, dynamic> order) {
//     final orderId = order['orderId'].toString();
//     final status = (order['status'] ?? '').toString().toUpperCase();
//     final eligibleStatuses = _selectedFilter == 'chef'
//         ? ['CONFIRMED']
//         : ['PENDING', 'CONFIRMED'];
//     final excludedStatuses = [
//       'ORDER_IS_READY',
//       'DELIVERED',
//       'CANCELLED',
//       'BEING_PREPARED',
//     ];
//     if (eligibleStatuses.contains(status) &&
//         !excludedStatuses.contains(status) &&
//         !_acknowledgedOrderIds.contains(orderId) &&
//         !_ringingOrderIds.contains(orderId)) {
//       _pendingOrderIds.add(orderId);
//       _ringingOrderIds.add(orderId);
//       if (!_isPlaying && _isSoundEnabled) _startRingingForOrder(orderId);
//       _triggerVibration();
//     }
//   }
//
//   void _cleanupCompletedOrders(List<dynamic> currentOrders) {
//     final currentOrderIds = currentOrders
//         .map((o) => o['orderId'].toString())
//         .toSet();
//     final toRemove = _ringingOrderIds
//         .where((id) => !currentOrderIds.contains(id))
//         .toList();
//     for (var id in toRemove) {
//       _pendingOrderIds.remove(id);
//       _ringingOrderIds.remove(id);
//       _acknowledgedOrderIds.remove(id);
//     }
//     if (_pendingOrderIds.isEmpty && _isPlaying) _stopAllRinging();
//   }
//
//   List<dynamic> _applyRoleFiltering(List<dynamic> orders) {
//     if (_userRole == 'ROLE_VENDOR') return orders;
//     if (_employeeRole != null && _employeeRole!.isNotEmpty) {
//       if (_validChefTypes.contains(_employeeRole)) {
//         return orders
//             .where((order) => _hasMatchingChefType(order, _employeeRole!))
//             .toList();
//       }
//     }
//     if (_employeeRole == null || _employeeRole!.isEmpty) {
//       WidgetsBinding.instance.addPostFrameCallback(
//         (_) => _showRoleWarningDialog(),
//       );
//     }
//     return [];
//   }
//
//   bool _hasMatchingChefType(Map<String, dynamic> order, String role) {
//     if (role == 'Chef_All') return true;
//     for (final key in ['cartItems', 'items', 'order']) {
//       if (order[key] is List) {
//         if ((order[key] as List).any(
//           (item) => item['chefType']?.toString() == role,
//         ))
//           return true;
//       }
//     }
//     return false;
//   }
//
//   void _showRoleWarningDialog() {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (_) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: Row(
//           children: [
//             Container(
//               width: 32,
//               height: 32,
//               decoration: BoxDecoration(
//                 color: _C.amberLight,
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: const Icon(
//                 Icons.warning_rounded,
//                 color: _C.amber,
//                 size: 18,
//               ),
//             ),
//             const SizedBox(width: 10),
//             const Text(
//               'Role Required',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w800,
//                 color: _C.text1,
//               ),
//             ),
//           ],
//         ),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Please log in with a valid chef role:',
//               style: TextStyle(fontSize: 13, color: _C.text2),
//             ),
//             const SizedBox(height: 10),
//             Wrap(
//               spacing: 6,
//               runSpacing: 6,
//               children: _validChefTypes
//                   .map(
//                     (r) => Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 8,
//                         vertical: 3,
//                       ),
//                       decoration: BoxDecoration(
//                         color: _C.accentLight,
//                         borderRadius: BorderRadius.circular(6),
//                       ),
//                       child: Text(
//                         r.replaceAll('_', ' '),
//                         style: const TextStyle(
//                           fontSize: 11,
//                           fontWeight: FontWeight.w600,
//                           color: _C.accent,
//                         ),
//                       ),
//                     ),
//                   )
//                   .toList(),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text(
//               'OK',
//               style: TextStyle(color: _C.accent, fontWeight: FontWeight.w700),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _applyFilter() {
//     if (_selectedFilter == 'chef') {
//       _filteredOrders = _allOrders.where((o) {
//         final type = (o['orderType'] ?? '').toString().toUpperCase();
//         return [
//           'DINE_IN',
//           'TAKEAWAY',
//           'DELIVERY',
//           'TABLE_DINE_IN',
//         ].contains(type);
//       }).toList();
//     } else if (_selectedFilter == 'online') {
//       _filteredOrders = _allOrders.where((o) {
//         final type = (o['orderType'] ?? '').toString().toUpperCase();
//         final status = (o['status'] ?? '').toString().toUpperCase();
//         return ['DELIVERY', 'TAKEAWAY', 'DINE_IN'].contains(type) &&
//             status == 'PENDING';
//       }).toList();
//     } else {
//       _filteredOrders = List.from(_allOrders);
//     }
//     _filteredOrders.sort((a, b) {
//       final da =
//           DateTime.tryParse(a['orderDateAndTime'] ?? '') ?? DateTime(2000);
//       final db =
//           DateTime.tryParse(b['orderDateAndTime'] ?? '') ?? DateTime(2000);
//       return db.compareTo(da);
//     });
//   }
//
//   void _updateDisplayOrders() {
//     if (_selectedTab == 0) {
//       if (_selectedFilter == 'chef') {
//         _displayOrders = _filteredOrders
//             .where((o) => o['status'] == 'CONFIRMED')
//             .toList()
//             .reversed
//             .toList();
//       } else if (_selectedFilter == 'online') {
//         _displayOrders = _filteredOrders
//             .where((o) => o['status'] == 'PENDING')
//             .toList()
//             .reversed
//             .toList();
//       }
//     } else if (_selectedTab == 1) {
//       if (_selectedFilter == 'chef') {
//         _displayOrders = _filteredOrders
//             .where((o) => o['status'] == 'BEING_PREPARED')
//             .toList()
//             .reversed
//             .toList();
//       } else if (_selectedFilter == 'online') {
//         _displayOrders = _filteredOrders
//             .where(
//               (o) =>
//                   o['status'] == 'BEING_PREPARED' || o['status'] == 'CONFIRMED',
//             )
//             .toList()
//             .reversed
//             .toList();
//       }
//     }
//   }
//
//   Future<void> _fetchOrdersInBackground() async {
//     try {
//       final allOrders = await food_authservice.getAllOrders();
//       final filtered = _applyRoleFiltering(
//         allOrders.where((o) {
//           final type = (o['orderType'] ?? '').toString().toUpperCase();
//           return [
//             'DINE_IN',
//             'DELIVERY',
//             'TAKEAWAY',
//             'TABLE_DINE_IN',
//           ].contains(type);
//         }).toList(),
//       );
//       final prevCount = _allOrders.length;
//       if (mounted)
//         setState(() {
//           _allOrders = filtered;
//           _applyFilter();
//           _updateDisplayOrders();
//         });
//       if (filtered.length > prevCount)
//         _findAndRingNewOrders(prevCount, filtered);
//       else if (filtered.length < prevCount)
//         _cleanupCompletedOrders(filtered);
//       _previousOrderCount = filtered.length;
//     } catch (e) {
//       debugPrint('Background fetch error: $e');
//     }
//   }
//
//   void _startOrderPolling() {
//     _orderPollingTimer = Timer.periodic(const Duration(seconds: 10), (_) {
//       if (mounted) _fetchOrdersInBackground();
//     });
//   }
//
//   Future<void> _initializeSound() async {
//     await _audioPlayer.setReleaseMode(ReleaseMode.loop);
//   }
//
//   Future<void> _startRingingForOrder(String orderId) async {
//     if (!_isSoundEnabled || _isPlaying) return;
//     try {
//       _isPlaying = true;
//       await _audioPlayer.play(AssetSource('school-bell-310293.mp3'));
//     } catch (e) {
//       _isPlaying = false;
//     }
//   }
//
//   Future<void> _stopAllRinging() async {
//     if (_isPlaying) {
//       await _audioPlayer.stop();
//       _isPlaying = false;
//     }
//   }
//
//   void _stopRingingForOrder(String orderId) {
//     if (_pendingOrderIds.contains(orderId)) {
//       _pendingOrderIds.remove(orderId);
//       _ringingOrderIds.remove(orderId);
//       _acknowledgedOrderIds.add(orderId);
//       if (_pendingOrderIds.isEmpty && _isPlaying) _stopAllRinging();
//     }
//   }
//
//   void _triggerVibration() {
//     try {
//       HapticFeedback.lightImpact();
//     } catch (_) {}
//   }
//
//   void _handleOrderUpdate(String orderId, String newStatus) {
//     final idx = _allOrders.indexWhere(
//       (o) => o['orderId'].toString() == orderId,
//     );
//     if (idx != -1) {
//       setState(() {
//         _allOrders[idx]['status'] = newStatus;
//         _applyFilter();
//         _updateDisplayOrders();
//       });
//       if (newStatus == 'BEING_PREPARED') _acknowledgedOrderIds.remove(orderId);
//     }
//   }
//
//   Future<void> _handleRefresh() async {
//     setState(() => _isLoading = true);
//     await _fetchOrders();
//   }
//
//   void _showSnack(String msg, Color color) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(
//           msg,
//           style: const TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         backgroundColor: color,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//         duration: const Duration(seconds: 2),
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     _orderPollingTimer?.cancel();
//     _stopAllRinging();
//     _audioPlayer.dispose();
//     super.dispose();
//   }
//
//   // ══════════════════════════════════════════════════════════════════════════════
//   // BUILD
//   // ══════════════════════════════════════════════════════════════════════════════
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: _C.bg,
//       body: SafeArea(
//         child: Stack(
//           children: [
//             Column(
//               children: [
//                 _buildHeader(),
//                 _buildTabBar(),
//                 Expanded(
//                   child: IndexedStack(
//                     index: _selectedTab,
//                     children: [
//                       RefreshIndicator(
//                         onRefresh: _handleRefresh,
//                         color: _C.accent,
//                         child: AllOrdersTab(
//                           orders: _displayOrders,
//                           isLoading: _isLoading,
//                           printSelected: _printSelected,
//                           onOrderAccepted: _stopRingingForOrder,
//                           onOrderUpdated: _handleOrderUpdate,
//                           isRinging: _pendingOrderIds.isNotEmpty,
//                           filterType: _selectedFilter,
//                           employeeRole: _employeeRole,
//                           userRole: _userRole,
//                         ),
//                       ),
//                       RefreshIndicator(
//                         onRefresh: _handleRefresh,
//                         color: _C.accent,
//                         child: ProcessingTab(
//                           orders: _displayOrders,
//                           isLoading: _isLoading,
//                           onOrderUpdated: _handleOrderUpdate,
//                           filterType: _selectedFilter,
//                           employeeRole: _employeeRole,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             // FAB refresh
//             Positioned(
//               bottom: 20,
//               right: 16,
//               child: GestureDetector(
//                 onTap: _handleRefresh,
//                 child: Container(
//                   width: 52,
//                   height: 52,
//                   decoration: BoxDecoration(
//                     gradient: _C.gradient,
//                     shape: BoxShape.circle,
//                     boxShadow: [
//                       BoxShadow(
//                         color: _C.accent.withOpacity(0.4),
//                         blurRadius: 12,
//                         offset: const Offset(0, 5),
//                       ),
//                     ],
//                   ),
//                   child: Stack(
//                     alignment: Alignment.center,
//                     children: [
//                       Icon(
//                         Icons.refresh_rounded,
//                         color: Colors.white,
//                         size: 24.sp,
//                       ),
//                       if (_isLoading)
//                         const CircularProgressIndicator(
//                           strokeWidth: 2.5,
//                           valueColor: AlwaysStoppedAnimation<Color>(
//                             Colors.white,
//                           ),
//                           backgroundColor: Colors.transparent,
//                         ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // ── Header ────────────────────────────────────────────────────────────────────
//   Widget _buildHeader() {
//     return Container(
//       padding: EdgeInsets.fromLTRB(16.w, 12.h, 12.w, 12.h),
//       decoration: BoxDecoration(
//         gradient: _C.gradient,
//         boxShadow: [
//           BoxShadow(
//             color: _C.accent.withOpacity(0.3),
//             blurRadius: 12,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           GestureDetector(
//             onTap: () => Navigator.pop(context),
//             child: Container(
//               width: 36.r,
//               height: 36.r,
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.15),
//                 borderRadius: BorderRadius.circular(10.r),
//               ),
//               child: Icon(
//                 Icons.arrow_back_ios_rounded,
//                 color: Colors.black,
//                 size: 16.sp,
//               ),
//             ),
//           ),
//           SizedBox(width: 12.w),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Chef Management',
//                   style: TextStyle(
//                     color: Colors.black,
//                     fontWeight: FontWeight.w900,
//                     fontSize: 18.sp,
//                     letterSpacing: -0.3,
//                   ),
//                 ),
//                 if (_employeeRole != null && _employeeRole!.isNotEmpty)
//                   Text(
//                     _employeeRole!.replaceAll('_', ' '),
//                     style: TextStyle(
//                       color: Colors.white70,
//                       fontSize: 11.sp,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//               ],
//             ),
//           ),
//           // Print toggle
//           GestureDetector(
//             onTap: () {
//               setState(() => _printSelected = !_printSelected);
//               _showSnack(
//                 _printSelected ? 'Printing Enabled ✅' : 'Printing Disabled ❌',
//                 _printSelected ? _C.blue : _C.text2,
//               );
//             },
//             child: Container(
//               padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
//               decoration: BoxDecoration(
//                 color: _printSelected
//                     ? Colors.white.withOpacity(0.2)
//                     : Colors.white.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(10.r),
//                 border: Border.all(
//                   color: Colors.black.withOpacity(_printSelected ? 0.5 : 0.2),
//                 ),
//               ),
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Icon(Icons.print_rounded, color: Colors.black, size: 16.sp),
//                   SizedBox(width: 5.w),
//                   Text(
//                     _printSelected ? 'ON' : 'OFF',
//                     style: TextStyle(
//                       color: Colors.black,
//                       fontWeight: FontWeight.w800,
//                       fontSize: 11.sp,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           SizedBox(width: 8.w),
//           // Sound toggle
//           GestureDetector(
//             onTap: () {
//               setState(() => _isSoundEnabled = !_isSoundEnabled);
//               if (!_isSoundEnabled && _isPlaying)
//                 _stopAllRinging();
//               else if (_isSoundEnabled &&
//                   _pendingOrderIds.isNotEmpty &&
//                   !_isPlaying)
//                 _startRingingForOrder(_pendingOrderIds.first);
//               _showSnack(
//                 _isSoundEnabled ? 'Sound ON 🔔' : 'Sound OFF 🔕',
//                 _isSoundEnabled ? _C.accent : _C.text2,
//               );
//             },
//             child: Stack(
//               children: [
//                 Container(
//                   width: 36.r,
//                   height: 36.r,
//                   decoration: BoxDecoration(
//                     color: _pendingOrderIds.isNotEmpty && _isPlaying
//                         ? _C.red.withOpacity(0.8)
//                         : Colors.white.withOpacity(0.15),
//                     borderRadius: BorderRadius.circular(10.r),
//                   ),
//                   child: Icon(
//                     _isSoundEnabled
//                         ? Icons.notifications_active_rounded
//                         : Icons.notifications_off_rounded,
//                     color: Colors.black,
//                     size: 18.sp,
//                   ),
//                 ),
//                 if (_pendingOrderIds.isNotEmpty && _isPlaying)
//                   Positioned(
//                     top: 4,
//                     right: 4,
//                     child: Container(
//                       width: 7,
//                       height: 7,
//                       decoration: const BoxDecoration(
//                         color: Colors.black,
//                         shape: BoxShape.circle,
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ── Tab Bar ───────────────────────────────────────────────────────────────────
//   Widget _buildTabBar() {
//     // Pending count badge for All tab
//     final pendingCount = _allOrders
//         .where((o) => o['status'] == 'CONFIRMED' || o['status'] == 'PENDING')
//         .length;
//     final processingCount = _allOrders
//         .where((o) => o['status'] == 'BEING_PREPARED')
//         .length;
//
//     return Container(
//       color: _C.white,
//       padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 8.h),
//       child: Column(
//         children: [
//           Container(
//             padding: EdgeInsets.all(4.r),
//             decoration: BoxDecoration(
//               color: _C.bg,
//               borderRadius: BorderRadius.circular(14.r),
//               border: Border.all(color: _C.border),
//             ),
//             child: Row(
//               children: List.generate(_tabTitles.length, (i) {
//                 final isSelected = _selectedTab == i;
//                 final count = i == 0 ? pendingCount : processingCount;
//                 return Expanded(
//                   child: GestureDetector(
//                     onTap: () => setState(() {
//                       _selectedTab = i;
//                       _updateDisplayOrders();
//                     }),
//                     child: AnimatedContainer(
//                       duration: const Duration(milliseconds: 250),
//                       curve: Curves.easeInOut,
//                       height: 40.h,
//                       decoration: BoxDecoration(
//                         gradient: isSelected ? _C.gradient : null,
//                         borderRadius: BorderRadius.circular(10.r),
//                         boxShadow: isSelected
//                             ? [
//                                 BoxShadow(
//                                   color: _C.accent.withOpacity(0.3),
//                                   blurRadius: 8,
//                                   offset: const Offset(0, 2),
//                                 ),
//                               ]
//                             : null,
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Text(
//                             _tabTitles[i],
//                             style: TextStyle(
//                               fontSize: 13.sp,
//                               fontWeight: FontWeight.w700,
//                               color: isSelected ? Colors.white : _C.text2,
//                             ),
//                           ),
//                           if (count > 0) ...[
//                             SizedBox(width: 6.w),
//                             Container(
//                               padding: EdgeInsets.symmetric(
//                                 horizontal: 6.w,
//                                 vertical: 1.h,
//                               ),
//                               decoration: BoxDecoration(
//                                 color: isSelected
//                                     ? Colors.white.withOpacity(0.25)
//                                     : (i == 0 ? _C.red : _C.amber).withOpacity(
//                                         0.15,
//                                       ),
//                                 borderRadius: BorderRadius.circular(8.r),
//                               ),
//                               child: Text(
//                                 '$count',
//                                 style: TextStyle(
//                                   fontSize: 10.sp,
//                                   fontWeight: FontWeight.w800,
//                                   color: isSelected
//                                       ? Colors.white
//                                       : (i == 0 ? _C.red : _C.amber),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ],
//                       ),
//                     ),
//                   ),
//                 );
//               }),
//             ),
//           ),
//           const SizedBox(height: 8),
//           const Divider(color: _C.border, height: 1),
//         ],
//       ),
//     );
//   }
// }
//
// // ─── AllOrdersTab ─────────────────────────────────────────────────────────────
// class AllOrdersTab extends StatefulWidget {
//   final List<dynamic> orders;
//   final bool isLoading;
//   final bool printSelected;
//   final Function(String) onOrderAccepted;
//   final Function(String, String) onOrderUpdated;
//   final bool isRinging;
//   final String filterType;
//   final String? employeeRole;
//   final String? userRole;
//
//   const AllOrdersTab({
//     super.key,
//     required this.orders,
//     required this.isLoading,
//     required this.printSelected,
//     required this.onOrderAccepted,
//     required this.onOrderUpdated,
//     required this.isRinging,
//     required this.filterType,
//     required this.employeeRole,
//     required this.userRole,
//   });
//
//   @override
//   State<AllOrdersTab> createState() => _AllOrdersTabState();
// }
//
// class _AllOrdersTabState extends State<AllOrdersTab> {
//   final Map<int, bool> _selectedItems = {};
//   String? connectedPrinterMac;
//   bool isConnected = false;
//   bool isConnecting = false;
//   static const String kDefaultPrinterKey = 'default_printer_mac';
//
//   @override
//   void initState() {
//     super.initState();
//     _restorePrinterConnection();
//   }
//
//   Future<void> saveDefaultPrinter(String mac) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString(kDefaultPrinterKey, mac);
//   }
//
//   Future<String?> getDefaultPrinter() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString(kDefaultPrinterKey);
//   }
//
//   Future<void> _restorePrinterConnection() async {
//     try {
//       final mac = await getDefaultPrinter();
//       if (mac != null && mac.isNotEmpty) {
//         final connected = await PrintBluetoothThermal.connect(
//           macPrinterAddress: mac,
//         );
//         if (connected && await PrintBluetoothThermal.connectionStatus) {
//           connectedPrinterMac = mac;
//           isConnected = true;
//         }
//       }
//     } catch (_) {
//       connectedPrinterMac = null;
//       isConnected = false;
//     }
//   }
//
//   String formatOrderType(String? type) {
//     switch (type) {
//       case 'TAKEAWAY':
//         return 'Take Away';
//       case 'DINE_IN':
//         return 'Dine In';
//       case 'DELIVERY':
//         return 'Delivery';
//       case 'TABLE_DINE_IN':
//         return 'Table Dine In';
//       default:
//         return type?.replaceAll('_', ' ') ?? '';
//     }
//   }
//
//   Color _orderTypeColor(String? t) {
//     switch (t?.toUpperCase()) {
//       case 'DELIVERY':
//         return _C.blue;
//       case 'TAKEAWAY':
//         return _C.green;
//       case 'DINE_IN':
//         return _C.amber;
//       case 'TABLE_DINE_IN':
//         return _C.purple;
//       default:
//         return _C.text2;
//     }
//   }
//
//   IconData _orderTypeIcon(String? t) {
//     switch (t?.toUpperCase()) {
//       case 'DELIVERY':
//         return Icons.delivery_dining_rounded;
//       case 'TAKEAWAY':
//         return Icons.shopping_bag_rounded;
//       case 'DINE_IN':
//         return Icons.restaurant_rounded;
//       case 'TABLE_DINE_IN':
//         return Icons.table_restaurant_rounded;
//       default:
//         return Icons.receipt_rounded;
//     }
//   }
//
//   String _getAcceptStatus() => 'BEING_PREPARED';
//
//   Future<void> _handleAcceptWithPrint(Map<String, dynamic> order) async {
//     if (!widget.printSelected) {
//       await _handleOrderAction(order, _getAcceptStatus());
//       widget.onOrderAccepted(order['orderId'].toString());
//       return;
//     }
//     setState(() => isConnecting = true);
//     try {
//       final savedMac = await getDefaultPrinter();
//       final bluetoothOn = await PrintBluetoothThermal.bluetoothEnabled;
//       if (bluetoothOn && savedMac != null && savedMac.isNotEmpty) {
//         bool connected = await PrintBluetoothThermal.connectionStatus;
//         if (!connected) {
//           await PrintBluetoothThermal.disconnect;
//           await Future.delayed(const Duration(milliseconds: 300));
//           connected = await PrintBluetoothThermal.connect(
//             macPrinterAddress: savedMac,
//           );
//         }
//         if (connected) {
//           try {
//             await _printThermalkot(order);
//             await _acceptOrderAfterPrint(order);
//             return;
//           } catch (_) {
//             if (mounted) _showPrinterSelectionDialog(order);
//             return;
//           }
//         }
//       }
//       if (mounted) _showPrinterSelectionDialog(order);
//     } finally {
//       setState(() => isConnecting = false);
//     }
//   }
//
//   Future<void> _printThermalkot(Map<String, dynamic> data) async {
//     final items = data['order'] as List<dynamic>? ?? [];
//     await PrintBluetoothThermal.writeBytes(Uint8List.fromList([27, 97, 1]));
//     await PrintBluetoothThermal.writeBytes(Uint8List.fromList([27, 69, 1]));
//     await PrintBluetoothThermal.writeString(
//       printText: PrintTextSize(
//         size: 2,
//         text: "${data['vendorRegisteredName']?.toString().toUpperCase()}\n",
//       ),
//     );
//     await PrintBluetoothThermal.writeString(
//       printText: PrintTextSize(
//         size: 2,
//         text: "------------------------------------------------\n",
//       ),
//     );
//     String makeRow(String l, String r) {
//       int sp = 48 - l.length - r.length;
//       return l + " " * (sp < 1 ? 1 : sp) + r;
//     }
//
//     await PrintBluetoothThermal.writeString(
//       printText: PrintTextSize(
//         size: 2,
//         text:
//             makeRow(
//               "Order ID : ${data['orderId']}",
//               "Date : ${data['date'] ?? ''}",
//             ) +
//             "\n",
//       ),
//     );
//     await PrintBluetoothThermal.writeString(
//       printText: PrintTextSize(
//         size: 2,
//         text:
//             makeRow(
//               "Type     : ${formatOrderType(data['orderType'])}",
//               "Time : ${data['time'] ?? ''}",
//             ) +
//             "\n",
//       ),
//     );
//     await PrintBluetoothThermal.writeString(
//       printText: PrintTextSize(
//         size: 2,
//         text: "------------------------------------------------\n",
//       ),
//     );
//     await PrintBluetoothThermal.writeString(
//       printText: PrintTextSize(
//         size: 2,
//         text: "ITEM                       QTY\n",
//       ),
//     );
//     await PrintBluetoothThermal.writeString(
//       printText: PrintTextSize(
//         size: 2,
//         text: "------------------------------------------------\n",
//       ),
//     );
//     for (var item in items) {
//       String name = (item['dishName'] ?? 'N/A').toString();
//       if (name.length > 26) name = name.substring(0, 26);
//       await PrintBluetoothThermal.writeString(
//         printText: PrintTextSize(
//           size: 2,
//           text:
//               "${name.padRight(28)}${(item['quantity']?.toString() ?? '0').padRight(10)}\n",
//         ),
//       );
//     }
//     await PrintBluetoothThermal.writeString(
//       printText: PrintTextSize(
//         size: 2,
//         text: "------------------------------------------------\n",
//       ),
//     );
//     await PrintBluetoothThermal.writeBytes([29, 86, 65, 0]);
//     await PrintBluetoothThermal.writeBytes([27, 100, 2]);
//   }
//
//   void _showPrinterSelectionDialog(Map<String, dynamic> order) {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (_) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: Row(
//           children: [
//             Container(
//               width: 34,
//               height: 34,
//               decoration: BoxDecoration(
//                 color: _C.blueLight,
//                 borderRadius: BorderRadius.circular(9),
//               ),
//               child: const Icon(Icons.print_rounded, color: _C.blue, size: 18),
//             ),
//             const SizedBox(width: 10),
//             const Text(
//               'Select Printer',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w800,
//                 color: _C.text1,
//               ),
//             ),
//           ],
//         ),
//         content: FutureBuilder<List<BluetoothInfo>>(
//           future: PrintBluetoothThermal.pairedBluetooths,
//           builder: (_, snap) {
//             if (snap.connectionState == ConnectionState.waiting) {
//               return SizedBox(
//                 height: 120.h,
//                 child: const Center(
//                   child: CircularProgressIndicator(
//                     color: _C.accent,
//                     strokeWidth: 2,
//                   ),
//                 ),
//               );
//             }
//             if (snap.data == null || snap.data!.isEmpty) {
//               return SizedBox(
//                 height: 120.h,
//                 child: const Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(
//                         Icons.print_disabled_rounded,
//                         size: 40,
//                         color: _C.text3,
//                       ),
//                       SizedBox(height: 8),
//                       Text(
//                         'No paired printers found',
//                         style: TextStyle(color: _C.text2, fontSize: 13),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             }
//             return SizedBox(
//               height: 200.h,
//               width: double.maxFinite,
//               child: ListView.separated(
//                 itemCount: snap.data!.length,
//                 separatorBuilder: (_, __) =>
//                     const Divider(color: _C.border, height: 1),
//                 itemBuilder: (_, i) {
//                   final p = snap.data![i];
//                   return ListTile(
//                     leading: Container(
//                       width: 34,
//                       height: 34,
//                       decoration: BoxDecoration(
//                         color: _C.accentLight,
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: const Icon(
//                         Icons.print_rounded,
//                         color: _C.accent,
//                         size: 17,
//                       ),
//                     ),
//                     title: Text(
//                       p.name,
//                       style: const TextStyle(
//                         fontSize: 13,
//                         fontWeight: FontWeight.w700,
//                         color: _C.text1,
//                       ),
//                     ),
//                     subtitle: Text(
//                       p.macAdress,
//                       style: const TextStyle(fontSize: 10, color: _C.text2),
//                     ),
//                     trailing: GestureDetector(
//                       onTap: () async {
//                         Navigator.pop(context);
//                         await _tryPrintWithSelectedPrinter(order, p);
//                       },
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 12,
//                           vertical: 6,
//                         ),
//                         decoration: BoxDecoration(
//                           gradient: _C.gradient,
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: const Text(
//                           'Print',
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 12,
//                             fontWeight: FontWeight.w700,
//                           ),
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             );
//           },
//         ),
//         actions: [
//           TextButton(
//             onPressed: () async {
//               Navigator.pop(context);
//               await _acceptWithoutPrint(order);
//             },
//             child: const Text(
//               'Accept Without Print',
//               style: TextStyle(color: _C.amber, fontWeight: FontWeight.w600),
//             ),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel', style: TextStyle(color: _C.text2)),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Future<void> _tryPrintWithSelectedPrinter(
//     Map<String, dynamic> order,
//     BluetoothInfo printer,
//   ) async {
//     setState(() => isConnecting = true);
//     try {
//       await PrintBluetoothThermal.connect(macPrinterAddress: printer.macAdress);
//       await _printThermalkot(order);
//       await saveDefaultPrinter(printer.macAdress);
//       await _acceptOrderAfterPrint(order);
//     } catch (e) {
//       if (mounted) {
//         _snack('Print failed: $e', _C.red);
//         _showPrinterSelectionDialog(order);
//       }
//     } finally {
//       setState(() => isConnecting = false);
//     }
//   }
//
//   Future<void> _acceptOrderAfterPrint(Map<String, dynamic> order) async {
//     await _handleOrderAction(order, _getAcceptStatus());
//     widget.onOrderAccepted(order['orderId'].toString());
//     if (mounted) _snack('Order accepted & printed ✅', _C.green);
//   }
//
//   Future<void> _acceptWithoutPrint(Map<String, dynamic> order) async {
//     await _handleOrderAction(order, _getAcceptStatus());
//     widget.onOrderAccepted(order['orderId'].toString());
//     if (mounted) _snack('Order accepted (no print)', _C.amber);
//   }
//
//   Future<void> _handleOrderAction(
//     Map<String, dynamic> order,
//     String status,
//   ) async {
//     final orderId = order['orderId'];
//     final items = order['order'] ?? [];
//     if (status == 'BEING_PREPARED' && widget.filterType == 'chef') {
//       for (var item in items) {
//         if (!(_selectedItems[item['listId']] ?? true))
//           await food_authservice.cancelOrderItem(item['listId']);
//       }
//     }
//     final success = await food_authservice.updateOrderStatus(orderId, status);
//     if (success && mounted) {
//       widget.onOrderUpdated(orderId.toString(), status);
//       _snack('Order updated to ${status.replaceAll('_', ' ')}', _C.green);
//     } else if (mounted) {
//       _snack('Failed to update order', _C.red);
//     }
//   }
//
//   void _snack(String msg, Color color) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(
//           msg,
//           style: const TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         backgroundColor: color,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//         duration: const Duration(seconds: 2),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (widget.isLoading) return _buildLoading();
//     if (widget.orders.isEmpty) {
//       final noRole =
//           widget.employeeRole == null || widget.employeeRole!.isEmpty;
//       return _buildEmpty(
//         noRole ? Icons.warning_rounded : Icons.inbox_rounded,
//         noRole ? 'No Role Assigned' : 'No Pending Orders',
//         noRole ? '' : 'New orders will appear here automatically',
//         noRole ? _C.amber : _C.accent,
//       );
//     }
//     return ListView.builder(
//       padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 80.h),
//       itemCount: widget.orders.length,
//       itemBuilder: (_, i) => _buildOrderCard(widget.orders[i]),
//     );
//   }
//
//   Widget _buildOrderCard(Map<String, dynamic> order) {
//     final items = order['order'] ?? [];
//     final status = order['status'] ?? 'PENDING';
//     final isPending = status == 'PENDING' || status == 'CONFIRMED';
//     final isRinging = widget.isRinging && isPending;
//     final typeColor = _orderTypeColor(order['orderType']);
//     final hasUserId = order['userId'] != null;
//
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 300),
//       margin: EdgeInsets.only(bottom: 14.h),
//       decoration: BoxDecoration(
//         color: _C.white,
//         borderRadius: BorderRadius.circular(18.r),
//         border: Border.all(
//           color: isRinging ? _C.red.withOpacity(0.5) : _C.border,
//           width: isRinging ? 2 : 1,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: isRinging ? _C.red.withOpacity(0.12) : _C.shadow,
//             blurRadius: isRinging ? 16 : 8,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           // ── Card header ────────────────────────────────────────────────────────
//           Container(
//             padding: EdgeInsets.fromLTRB(14.w, 12.h, 12.w, 12.h),
//             decoration: BoxDecoration(
//               color: isRinging
//                   ? _C.redLight.withOpacity(0.3)
//                   : typeColor.withOpacity(0.05),
//               borderRadius: BorderRadius.vertical(top: Radius.circular(18.r)),
//             ),
//             child: Row(
//               children: [
//                 // Order type icon pill
//                 Container(
//                   width: 38.r,
//                   height: 38.r,
//                   decoration: BoxDecoration(
//                     color: typeColor.withOpacity(0.12),
//                     borderRadius: BorderRadius.circular(10.r),
//                   ),
//                   child: Icon(
//                     _orderTypeIcon(order['orderType']),
//                     color: typeColor,
//                     size: 19.sp,
//                   ),
//                 ),
//                 SizedBox(width: 10.w),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           if (isRinging) ...[
//                             SizedBox(width: 4.w),
//                           ],
//                           Text(
//                             'Order #${order['orderId'] ?? 'N/A'}',
//                             style: TextStyle(
//                               fontWeight: FontWeight.w800,
//                               fontSize: 15.sp,
//                               color: _C.text1,
//                             ),
//                           ),
//                           if (hasUserId) ...[
//                             SizedBox(width: 6.w),
//                             Container(
//                               padding: EdgeInsets.symmetric(
//                                 horizontal: 6.w,
//                                 vertical: 2.h,
//                               ),
//                               decoration: BoxDecoration(
//                                 color: _C.blueLight,
//                                 borderRadius: BorderRadius.circular(5.r),
//                                 border: Border.all(
//                                   color: _C.blue.withOpacity(0.2),
//                                 ),
//                               ),
//                               child: Text(
//                                 'Online',
//                                 style: TextStyle(
//                                   fontSize: 9.sp,
//                                   fontWeight: FontWeight.w700,
//                                   color: _C.blue,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ],
//                       ),
//                       SizedBox(height: 2.h),
//                       Text(
//                         _formatTime(order['orderDateAndTime']),
//                         style: TextStyle(fontSize: 10.sp, color: _C.text2),
//                       ),
//                     ],
//                   ),
//                 ),
//                 // Order type badge
//                 Container(
//                   padding: EdgeInsets.symmetric(
//                     horizontal: 10.w,
//                     vertical: 5.h,
//                   ),
//                   decoration: BoxDecoration(
//                     color: typeColor,
//                     borderRadius: BorderRadius.circular(10.r),
//                     boxShadow: [
//                       BoxShadow(
//                         color: typeColor.withOpacity(0.3),
//                         blurRadius: 6,
//                         offset: const Offset(0, 2),
//                       ),
//                     ],
//                   ),
//                   child: Text(
//                     formatOrderType(order['orderType']),
//                     style: TextStyle(
//                       fontSize: 10.sp,
//                       color: Colors.white,
//                       fontWeight: FontWeight.w700,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//
//           // ── Items list ─────────────────────────────────────────────────────────
//           Padding(
//             padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Items',
//                   style: TextStyle(
//                     fontSize: 12.sp,
//                     fontWeight: FontWeight.w700,
//                     color: _C.text2,
//                     letterSpacing: 0.3,
//                   ),
//                 ),
//                 SizedBox(height: 8.h),
//                 ...items.map<Widget>((item) {
//                   final listId = item['listId'] ?? 0;
//                   final isChecked = _selectedItems[listId] ?? false;
//                   return GestureDetector(
//                     onTap: () =>
//                         setState(() => _selectedItems[listId] = !isChecked),
//                     child: Container(
//                       margin: EdgeInsets.only(bottom: 6.h),
//                       padding: EdgeInsets.symmetric(
//                         horizontal: 10.w,
//                         vertical: 8.h,
//                       ),
//                       decoration: BoxDecoration(
//                         color: isChecked ? _C.greenLight : _C.bg,
//                         borderRadius: BorderRadius.circular(10.r),
//                         border: Border.all(
//                           color: isChecked
//                               ? _C.green.withOpacity(0.3)
//                               : _C.border,
//                         ),
//                       ),
//                       child: Row(
//                         children: [
//                           AnimatedContainer(
//                             duration: const Duration(milliseconds: 200),
//                             width: 20.r,
//                             height: 20.r,
//                             decoration: BoxDecoration(
//                               color: isChecked ? _C.green : _C.white,
//                               shape: BoxShape.circle,
//                               border: Border.all(
//                                 color: isChecked ? _C.green : _C.border,
//                                 width: 1.5,
//                               ),
//                             ),
//                             child: isChecked
//                                 ? Icon(
//                                     Icons.check_rounded,
//                                     color: Colors.white,
//                                     size: 12.sp,
//                                   )
//                                 : null,
//                           ),
//                           SizedBox(width: 10.w),
//                           Expanded(
//                             child: Text(
//                               '${item['dishName'] ?? 'Unknown'}',
//                               style: TextStyle(
//                                 fontSize: 13.sp,
//                                 color: _C.text1,
//                                 fontWeight: FontWeight.w600,
//                                 decoration: isChecked
//                                     ? TextDecoration.lineThrough
//                                     : null,
//                                 decorationColor: _C.green,
//                               ),
//                             ),
//                           ),
//                           Container(
//                             padding: EdgeInsets.symmetric(
//                               horizontal: 8.w,
//                               vertical: 2.h,
//                             ),
//                             decoration: BoxDecoration(
//                               color: _C.accentLight,
//                               borderRadius: BorderRadius.circular(6.r),
//                             ),
//                             child: Text(
//                               'x${item['quantity'] ?? 1}',
//                               style: TextStyle(
//                                 fontSize: 11.sp,
//                                 fontWeight: FontWeight.w800,
//                                 color: _C.accent,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 }).toList(),
//               ],
//             ),
//           ),
//
//           // ── Action buttons ─────────────────────────────────────────────────────
//           Padding(
//             padding: EdgeInsets.all(12.r),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: GestureDetector(
//                     onTap: isConnecting
//                         ? null
//                         : () => _handleAcceptWithPrint(order),
//                     child: AnimatedContainer(
//                       duration: const Duration(milliseconds: 200),
//                       padding: EdgeInsets.symmetric(vertical: 12.h),
//                       decoration: BoxDecoration(
//                         gradient: isConnecting
//                             ? null
//                             : const LinearGradient(
//                                 colors: [_C.green, _C.greenDark],
//                               ),
//                         color: isConnecting ? _C.border : null,
//                         borderRadius: BorderRadius.circular(12.r),
//                         boxShadow: isConnecting
//                             ? null
//                             : [
//                                 BoxShadow(
//                                   color: _C.green.withOpacity(0.35),
//                                   blurRadius: 10,
//                                   offset: const Offset(0, 4),
//                                 ),
//                               ],
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           if (isConnecting)
//                             SizedBox(
//                               width: 16.sp,
//                               height: 16.sp,
//                               child: const CircularProgressIndicator(
//                                 strokeWidth: 2,
//                                 color: _C.text2,
//                               ),
//                             )
//                           else
//                             Icon(
//                               Icons.check_circle_rounded,
//                               color: Colors.white,
//                               size: 17.sp,
//                             ),
//                           SizedBox(width: 6.w),
//                           Text(
//                             isConnecting ? 'Processing...' : 'Accept',
//                             style: TextStyle(
//                               fontSize: 13.sp,
//                               fontWeight: FontWeight.w800,
//                               color: isConnecting ? _C.text2 : Colors.white,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//                 SizedBox(width: 10.w),
//                 Expanded(
//                   child: GestureDetector(
//                     onTap: () => _handleOrderAction(order, 'CANCELLED'),
//                     child: Container(
//                       padding: EdgeInsets.symmetric(vertical: 12.h),
//                       decoration: BoxDecoration(
//                         color: _C.redLight,
//                         borderRadius: BorderRadius.circular(12.r),
//                         border: Border.all(color: _C.red.withOpacity(0.3)),
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(
//                             Icons.cancel_rounded,
//                             color: _C.red,
//                             size: 17.sp,
//                           ),
//                           SizedBox(width: 6.w),
//                           Text(
//                             'Decline',
//                             style: TextStyle(
//                               fontSize: 13.sp,
//                               fontWeight: FontWeight.w800,
//                               color: _C.red,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   String _formatTime(String? raw) {
//     if (raw == null) return '';
//     try {
//       return DateFormat('hh:mm a · dd MMM').format(DateTime.parse(raw));
//     } catch (_) {
//       return '';
//     }
//   }
//
//   Widget _buildLoading() => Center(
//     child: Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Container(
//           width: 60,
//           height: 60,
//           decoration: BoxDecoration(
//             gradient: _C.gradient,
//             shape: BoxShape.circle,
//             boxShadow: [
//               BoxShadow(
//                 color: _C.accent.withOpacity(0.3),
//                 blurRadius: 12,
//                 offset: const Offset(0, 5),
//               ),
//             ],
//           ),
//           child: const Icon(
//             Icons.restaurant_rounded,
//             color: Colors.white,
//             size: 28,
//           ),
//         ),
//         const SizedBox(height: 16),
//         const Text(
//           'Loading orders...',
//           style: TextStyle(
//             fontSize: 14,
//             color: _C.text2,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//       ],
//     ),
//   );
//
//   Widget _buildEmpty(
//     IconData icon,
//     String title,
//     String subtitle,
//     Color color,
//   ) => Center(
//     child: Padding(
//       padding: EdgeInsets.all(32.r),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             width: 70,
//             height: 70,
//             decoration: BoxDecoration(
//               color: color.withOpacity(0.1),
//               shape: BoxShape.circle,
//               border: Border.all(color: color.withOpacity(0.2), width: 2),
//             ),
//             child: Icon(icon, size: 32, color: color),
//           ),
//           const SizedBox(height: 16),
//           Text(
//             title,
//             style: TextStyle(
//               fontSize: 17,
//               fontWeight: FontWeight.w700,
//               color: _C.text1,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           if (subtitle.isNotEmpty) ...[
//             const SizedBox(height: 6),
//             Text(
//               subtitle,
//               style: const TextStyle(fontSize: 12, color: _C.text2),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ],
//       ),
//     ),
//   );
// }
//
// // ─── ProcessingTab ────────────────────────────────────────────────────────────
// class ProcessingTab extends StatefulWidget {
//   final List<dynamic> orders;
//   final bool isLoading;
//   final Function(String, String) onOrderUpdated;
//   final String filterType;
//   final String? employeeRole;
//
//   const ProcessingTab({
//     super.key,
//     required this.orders,
//     required this.isLoading,
//     required this.onOrderUpdated,
//     required this.filterType,
//     required this.employeeRole,
//   });
//
//   @override
//   State<ProcessingTab> createState() => _ProcessingTabState();
// }
//
// class _ProcessingTabState extends State<ProcessingTab> {
//   final Map<int, bool> _selectedItems = {};
//   bool get _isChefMode => widget.filterType == 'chef';
//   bool get _isOnlineMode => widget.filterType == 'online';
//
//   String formatOrderType(String? type) {
//     switch (type) {
//       case 'TAKEAWAY':
//         return 'Take Away';
//       case 'DINE_IN':
//         return 'Dine In';
//       case 'DELIVERY':
//         return 'Delivery';
//       case 'TABLE_DINE_IN':
//         return 'Table Dine In';
//       default:
//         return type?.replaceAll('_', ' ') ?? '';
//     }
//   }
//
//   Color _orderTypeColor(String? t) {
//     switch (t?.toUpperCase()) {
//       case 'DELIVERY':
//         return _C.blue;
//       case 'TAKEAWAY':
//         return _C.green;
//       case 'DINE_IN':
//         return _C.amber;
//       case 'TABLE_DINE_IN':
//         return _C.purple;
//       default:
//         return _C.text2;
//     }
//   }
//
//   IconData _orderTypeIcon(String? t) {
//     switch (t?.toUpperCase()) {
//       case 'DELIVERY':
//         return Icons.delivery_dining_rounded;
//       case 'TAKEAWAY':
//         return Icons.shopping_bag_rounded;
//       case 'DINE_IN':
//         return Icons.restaurant_rounded;
//       case 'TABLE_DINE_IN':
//         return Icons.table_restaurant_rounded;
//       default:
//         return Icons.receipt_rounded;
//     }
//   }
//
//   // Progress steps
//   List<Map<String, dynamic>> _getSteps(String status) {
//     final steps = [
//       {
//         'label': 'Confirmed',
//         'status': 'CONFIRMED',
//         'icon': Icons.check_rounded,
//       },
//       {
//         'label': 'Cooking',
//         'status': 'BEING_PREPARED',
//         'icon': Icons.soup_kitchen_rounded,
//       },
//       {
//         'label': 'Ready',
//         'status': 'ORDER_IS_READY',
//         'icon': Icons.done_all_rounded,
//       },
//     ];
//     return steps;
//   }
//
//   int _stepIndex(String status) {
//     switch (status) {
//       case 'CONFIRMED':
//         return 0;
//       case 'BEING_PREPARED':
//         return 1;
//       case 'ORDER_IS_READY':
//         return 2;
//       default:
//         return 0;
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (widget.isLoading) return _buildLoading();
//     if (widget.orders.isEmpty) {
//       final noRole =
//           widget.employeeRole == null || widget.employeeRole!.isEmpty;
//       return _buildEmpty(
//         noRole ? Icons.warning_rounded : Icons.soup_kitchen_rounded,
//         noRole ? 'No Role Assigned' : 'No Orders In Progress',
//         noRole ? '' : 'Orders being prepared will appear here',
//         noRole ? _C.amber : _C.orange,
//       );
//     }
//     return ListView.builder(
//       padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 80.h),
//       itemCount: widget.orders.length,
//       itemBuilder: (_, i) => _buildOrderCard(widget.orders[i]),
//     );
//   }
//
//   Widget _buildOrderCard(Map<String, dynamic> order) {
//     final items = order['order'] ?? [];
//     final status = order['status'] ?? 'BEING_PREPARED';
//     final typeColor = _orderTypeColor(order['orderType']);
//     final currentStep = _stepIndex(status);
//     final steps = _getSteps(status);
//
//     return Container(
//       margin: EdgeInsets.only(bottom: 14.h),
//       decoration: BoxDecoration(
//         color: _C.white,
//         borderRadius: BorderRadius.circular(18.r),
//         border: Border.all(color: _C.border),
//         boxShadow: [
//           const BoxShadow(
//             color: _C.shadow,
//             blurRadius: 8,
//             offset: Offset(0, 3),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           // ── Header ─────────────────────────────────────────────────────────────
//           Container(
//             padding: EdgeInsets.fromLTRB(14.w, 12.h, 12.w, 12.h),
//             decoration: BoxDecoration(
//               color: typeColor.withOpacity(0.06),
//               borderRadius: BorderRadius.vertical(top: Radius.circular(18.r)),
//             ),
//             child: Row(
//               children: [
//                 Container(
//                   width: 38.r,
//                   height: 38.r,
//                   decoration: BoxDecoration(
//                     color: typeColor.withOpacity(0.12),
//                     borderRadius: BorderRadius.circular(10.r),
//                   ),
//                   child: Icon(
//                     _orderTypeIcon(order['orderType']),
//                     color: typeColor,
//                     size: 19.sp,
//                   ),
//                 ),
//                 SizedBox(width: 10.w),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Order #${order['orderId'] ?? 'N/A'}',
//                         style: TextStyle(
//                           fontWeight: FontWeight.w800,
//                           fontSize: 15.sp,
//                           color: _C.text1,
//                         ),
//                       ),
//                       SizedBox(height: 2.h),
//                       Text(
//                         _formatTime(order['orderDateAndTime']),
//                         style: TextStyle(fontSize: 10.sp, color: _C.text2),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Container(
//                   padding: EdgeInsets.symmetric(
//                     horizontal: 10.w,
//                     vertical: 5.h,
//                   ),
//                   decoration: BoxDecoration(
//                     color: typeColor,
//                     borderRadius: BorderRadius.circular(10.r),
//                   ),
//                   child: Text(
//                     formatOrderType(order['orderType']),
//                     style: TextStyle(
//                       fontSize: 10.sp,
//                       color: Colors.white,
//                       fontWeight: FontWeight.w700,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//
//           // ── Progress stepper ───────────────────────────────────────────────────
//           Padding(
//             padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 4.h),
//             child: Row(
//               children: steps.asMap().entries.map((e) {
//                 final idx = e.key;
//                 final step = e.value;
//                 final isDone = idx <= currentStep;
//                 final isActive = idx == currentStep;
//                 final isLast = idx == steps.length - 1;
//                 return Expanded(
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: Column(
//                           children: [
//                             AnimatedContainer(
//                               duration: const Duration(milliseconds: 300),
//                               width: 28.r,
//                               height: 28.r,
//                               decoration: BoxDecoration(
//                                 gradient: isDone ? _C.gradient : null,
//                                 color: isDone ? null : _C.bg,
//                                 shape: BoxShape.circle,
//                                 border: Border.all(
//                                   color: isDone ? _C.accent : _C.border,
//                                   width: isActive ? 2 : 1,
//                                 ),
//                                 boxShadow: isActive
//                                     ? [
//                                         BoxShadow(
//                                           color: _C.accent.withOpacity(0.35),
//                                           blurRadius: 8,
//                                         ),
//                                       ]
//                                     : null,
//                               ),
//                               child: Icon(
//                                 step['icon'] as IconData,
//                                 size: 13.sp,
//                                 color: isDone ? Colors.white : _C.text3,
//                               ),
//                             ),
//                             SizedBox(height: 4.h),
//                             Text(
//                               step['label'] as String,
//                               style: TextStyle(
//                                 fontSize: 9.sp,
//                                 fontWeight: isActive
//                                     ? FontWeight.w800
//                                     : FontWeight.w500,
//                                 color: isDone ? _C.accent : _C.text3,
//                               ),
//                               textAlign: TextAlign.center,
//                             ),
//                           ],
//                         ),
//                       ),
//                       if (!isLast)
//                         Expanded(
//                           child: Container(
//                             height: 2,
//                             margin: const EdgeInsets.only(bottom: 16),
//                             color: idx < currentStep ? _C.accent : _C.border,
//                           ),
//                         ),
//                     ],
//                   ),
//                 );
//               }).toList(),
//             ),
//           ),
//
//           // ── Items ─────────────────────────────────────────────────────────────
//           Padding(
//             padding: EdgeInsets.fromLTRB(14.w, 6.h, 14.w, 0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Items',
//                   style: TextStyle(
//                     fontSize: 12.sp,
//                     fontWeight: FontWeight.w700,
//                     color: _C.text2,
//                   ),
//                 ),
//                 SizedBox(height: 8.h),
//                 ...items.map<Widget>((item) {
//                   final listId = item['listId'] ?? 0;
//                   final isChecked = _selectedItems[listId] ?? false;
//                   return GestureDetector(
//                     onTap: () =>
//                         setState(() => _selectedItems[listId] = !isChecked),
//                     child: Container(
//                       margin: EdgeInsets.only(bottom: 6.h),
//                       padding: EdgeInsets.symmetric(
//                         horizontal: 10.w,
//                         vertical: 8.h,
//                       ),
//                       decoration: BoxDecoration(
//                         color: isChecked ? _C.orangeLight : _C.bg,
//                         borderRadius: BorderRadius.circular(10.r),
//                         border: Border.all(
//                           color: isChecked
//                               ? _C.orange.withOpacity(0.3)
//                               : _C.border,
//                         ),
//                       ),
//                       child: Row(
//                         children: [
//                           AnimatedContainer(
//                             duration: const Duration(milliseconds: 200),
//                             width: 20.r,
//                             height: 20.r,
//                             decoration: BoxDecoration(
//                               color: isChecked ? _C.orange : _C.white,
//                               shape: BoxShape.circle,
//                               border: Border.all(
//                                 color: isChecked ? _C.orange : _C.border,
//                                 width: 1.5,
//                               ),
//                             ),
//                             child: isChecked
//                                 ? Icon(
//                                     Icons.check_rounded,
//                                     color: Colors.white,
//                                     size: 12.sp,
//                                   )
//                                 : null,
//                           ),
//                           SizedBox(width: 10.w),
//                           Expanded(
//                             child: Text(
//                               item['dishName'] ?? item['name'] ?? 'Unknown',
//                               style: TextStyle(
//                                 fontSize: 13.sp,
//                                 fontWeight: FontWeight.w600,
//                                 color: _C.text1,
//                               ),
//                             ),
//                           ),
//                           Container(
//                             padding: EdgeInsets.symmetric(
//                               horizontal: 8.w,
//                               vertical: 2.h,
//                             ),
//                             decoration: BoxDecoration(
//                               color: _C.orangeLight,
//                               borderRadius: BorderRadius.circular(6.r),
//                             ),
//                             child: Text(
//                               'x${item['quantity'] ?? 1}',
//                               style: TextStyle(
//                                 fontSize: 11.sp,
//                                 fontWeight: FontWeight.w800,
//                                 color: _C.orange,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 }).toList(),
//               ],
//             ),
//           ),
//
//           // ── Action buttons ─────────────────────────────────────────────────────
//           Padding(
//             padding: EdgeInsets.all(12.r),
//             child: Row(
//               children: [
//                 if (_isOnlineMode && status == 'CONFIRMED')
//                   Expanded(
//                     child: _actionBtn(
//                       'Start Cooking',
//                       Icons.soup_kitchen_rounded,
//                       _C.green,
//                       () => _handleOrderAction(order, 'BEING_PREPARED'),
//                     ),
//                   ),
//                 if (_isOnlineMode && status == 'CONFIRMED')
//                   SizedBox(width: 10.w),
//                 if (status == 'BEING_PREPARED')
//                   Expanded(
//                     child: _actionBtn(
//                       _isChefMode ? 'Ready to Serve' : 'Mark as Ready',
//                       Icons.done_all_rounded,
//                       _C.green,
//                       () => _handleOrderAction(order, 'ORDER_IS_READY'),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _actionBtn(
//     String label,
//     IconData icon,
//     Color color,
//     VoidCallback onTap,
//   ) => GestureDetector(
//     onTap: onTap,
//     child: Container(
//       padding: EdgeInsets.symmetric(vertical: 12.h),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [color, Color.lerp(color, Colors.black, 0.15)!],
//         ),
//         borderRadius: BorderRadius.circular(12.r),
//         boxShadow: [
//           BoxShadow(
//             color: color.withOpacity(0.35),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(icon, color: Colors.white, size: 17.sp),
//           SizedBox(width: 6.w),
//           Text(
//             label,
//             style: TextStyle(
//               fontSize: 13.sp,
//               fontWeight: FontWeight.w800,
//               color: Colors.white,
//             ),
//           ),
//         ],
//       ),
//     ),
//   );
//
//   Future<void> _handleOrderAction(
//     Map<String, dynamic> order,
//     String status,
//   ) async {
//     final orderId = order['orderId'];
//     final success = await food_authservice.updateOrderStatus(orderId, status);
//     if (success && mounted) {
//       widget.onOrderUpdated(orderId.toString(), status);
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             'Order: ${status.replaceAll('_', ' ')}',
//             style: const TextStyle(
//               color: Colors.white,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           backgroundColor: _C.green,
//           behavior: SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(10),
//           ),
//         ),
//       );
//     } else if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: const Text(
//             'Failed to update',
//             style: TextStyle(color: Colors.white),
//           ),
//           backgroundColor: _C.red,
//           behavior: SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(10),
//           ),
//         ),
//       );
//     }
//   }
//
//   String _formatTime(String? raw) {
//     if (raw == null) return '';
//     try {
//       return DateFormat('hh:mm a · dd MMM').format(DateTime.parse(raw));
//     } catch (_) {
//       return '';
//     }
//   }
//
//   Widget _buildLoading() => Center(
//     child: Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Container(
//           width: 60,
//           height: 60,
//           decoration: BoxDecoration(
//             color: _C.orangeLight,
//             shape: BoxShape.circle,
//           ),
//           child: const Icon(
//             Icons.soup_kitchen_rounded,
//             color: _C.orange,
//             size: 28,
//           ),
//         ),
//         const SizedBox(height: 16),
//         const Text(
//           'Loading orders...',
//           style: TextStyle(
//             fontSize: 14,
//             color: _C.text2,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//       ],
//     ),
//   );
//
//   Widget _buildEmpty(
//     IconData icon,
//     String title,
//     String subtitle,
//     Color color,
//   ) => Center(
//     child: Padding(
//       padding: EdgeInsets.all(32.r),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             width: 70,
//             height: 70,
//             decoration: BoxDecoration(
//               color: color.withOpacity(0.1),
//               shape: BoxShape.circle,
//               border: Border.all(color: color.withOpacity(0.2), width: 2),
//             ),
//             child: Icon(icon, size: 32, color: color),
//           ),
//           const SizedBox(height: 16),
//           Text(
//             title,
//             style: const TextStyle(
//               fontSize: 17,
//               fontWeight: FontWeight.w700,
//               color: _C.text1,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           if (subtitle.isNotEmpty) ...[
//             const SizedBox(height: 6),
//             Text(
//               subtitle,
//               style: const TextStyle(fontSize: 12, color: _C.text2),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ],
//       ),
//     ),
//   );
// }
import 'dart:typed_data';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import '../Api/food_authservice.dart';
import '../printservice/printservice.dart';

// ─── Design Tokens ─────────────────────────────────────────────────────────────
class _C {
  static const bg = Color(0xFFF7F8FC);
  static const white = Color(0xFFFFFFFF);
  static const border = Color(0xFFEEEFF5);
  static const accent = Color(0xFFE66D33);
  static const accentDark = Color(0xFFE66D33);
  static const accentLight = Color(0xFFF5E8FA);
  static const green = Color(0xFF63CF6E);
  static const greenLight = Color(0xFFD1FAE5);
  static const greenDark = Color(0xFF63CF6E);
  static const red = Color(0xFFEF4444);
  static const redLight = Color(0xFFFFFFFF);
  static const blue = Color(0xFF3B82F6);
  static const blueLight = Color(0xFFDBEAFE);
  static const amber = Color(0xFFF59E0B);
  static const amberLight = Color(0xFFFEF3C7);
  static const purple = Color(0xFF8B5CF6);
  static const purpleLight = Color(0xFFEDE9FE);
  static const orange = Color(0xFFF97316);
  static const orangeLight = Color(0xFFFFEDD5);
  static const teal = Color(0xFF14B8A6);
  static const tealLight = Color(0xFFCCFBF1);
  static const text1 = Color(0xFF111827);
  static const text2 = Color(0xFF6B7280);
  static const text3 = Color(0xFFB0B3C1);
  static const shadow = Color(0x0A000000);
  static const shadowMd = Color(0x14000000);

  static LinearGradient get gradient => const LinearGradient(
    colors: [accent, accentDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

// ─── chef_management ──────────────────────────────────────────────────────────
class chef_management extends StatefulWidget {
  const chef_management({super.key});
  @override
  State<chef_management> createState() => _ChefManagementState();
}

class _ChefManagementState extends State<chef_management>
    with SingleTickerProviderStateMixin {
  final List<String> _tabTitles = ['All Orders', 'Processing'];
  int _selectedTab = 0;
  List<dynamic> _allOrders = [];
  List<dynamic> _filteredOrders = [];
  List<dynamic> _displayOrders = [];
  bool _isLoading = true;
  bool _printSelected = true;
  String _selectedFilter = 'chef';
  Set<String> _acknowledgedOrderIds = {};

  final AudioPlayer _audioPlayer = AudioPlayer();
  Set<String> _pendingOrderIds = {};
  Set<String> _ringingOrderIds = {};
  Timer? _orderPollingTimer;
  bool _isPlaying = false;
  bool _isSoundEnabled = true;

  String? _employeeRole;
  String? _userRole;
  int _previousOrderCount = 0;

  final List<String> _validChefTypes = [
    'Chef_North',
    'Chef_South',
    'Chef_Continental',
    'Chef_Chinese',
    'Chef_All',
    'Tea_stall',
    'Snacks',
    'Bakery',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserRoles();
    _initializeSound();
    _fetchOrders();
    _startOrderPolling();
  }

  Future<void> _loadUserRoles() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _employeeRole = prefs.getString('employeRole');
      _userRole = prefs.getString('role');
    });
  }

  Future<void> _fetchOrders() async {
    setState(() => _isLoading = true);
    try {
      final allOrders = await food_authservice.getAllOrders();
      List filteredOrders = allOrders.where((order) {
        final type = (order['orderType'] ?? '').toString().toUpperCase();
        return [
          'DINE_IN',
          'DELIVERY',
          'TAKEAWAY',
          'TABLE_DINE_IN',
        ].contains(type);
      }).toList();
      filteredOrders = _applyRoleFiltering(filteredOrders);
      final previousCount = _allOrders.length;
      setState(() {
        _allOrders = filteredOrders;
        _applyFilter();
        _updateDisplayOrders();
      });
      if (filteredOrders.length > previousCount) {
        _findAndRingNewOrders(previousCount, filteredOrders);
      } else if (filteredOrders.length < previousCount) {
        _cleanupCompletedOrders(filteredOrders);
      }
      _previousOrderCount = filteredOrders.length;
    } catch (e) {
      debugPrint('Error fetching orders: $e');
      _showSnack('Failed to load orders', _C.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _findAndRingNewOrders(int previousCount, List<dynamic> currentOrders) {
    if (previousCount == 0) {
      for (var order in currentOrders) _triggerOrderNotificationIfNeeded(order);
      return;
    }
    final previousOrderIds = _allOrders
        .take(previousCount)
        .map((o) => o['orderId'].toString())
        .toSet();
    for (var order in currentOrders) {
      if (!previousOrderIds.contains(order['orderId'].toString())) {
        _triggerOrderNotificationIfNeeded(order);
      }
    }
  }

  void _triggerOrderNotificationIfNeeded(Map<String, dynamic> order) {
    final orderId = order['orderId'].toString();
    final status = (order['status'] ?? '').toString().toUpperCase();
    final eligibleStatuses = _selectedFilter == 'chef'
        ? ['CONFIRMED']
        : ['PENDING', 'CONFIRMED'];
    final excludedStatuses = [
      'ORDER_IS_READY',
      'DELIVERED',
      'CANCELLED',
      'BEING_PREPARED',
    ];
    if (eligibleStatuses.contains(status) &&
        !excludedStatuses.contains(status) &&
        !_acknowledgedOrderIds.contains(orderId) &&
        !_ringingOrderIds.contains(orderId)) {
      _pendingOrderIds.add(orderId);
      _ringingOrderIds.add(orderId);
      if (!_isPlaying && _isSoundEnabled) _startRingingForOrder(orderId);
      _triggerVibration();
    }
  }

  void _cleanupCompletedOrders(List<dynamic> currentOrders) {
    final currentOrderIds = currentOrders
        .map((o) => o['orderId'].toString())
        .toSet();
    final toRemove = _ringingOrderIds
        .where((id) => !currentOrderIds.contains(id))
        .toList();
    for (var id in toRemove) {
      _pendingOrderIds.remove(id);
      _ringingOrderIds.remove(id);
      _acknowledgedOrderIds.remove(id);
    }
    if (_pendingOrderIds.isEmpty && _isPlaying) _stopAllRinging();
  }

  List<dynamic> _applyRoleFiltering(List<dynamic> orders) {
    if (_userRole == 'ROLE_VENDOR') return orders;
    if (_employeeRole != null && _employeeRole!.isNotEmpty) {
      if (_validChefTypes.contains(_employeeRole)) {
        return orders
            .where((order) => _hasMatchingChefType(order, _employeeRole!))
            .toList();
      }
    }
    if (_employeeRole == null || _employeeRole!.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _showRoleWarningDialog(),
      );
    }
    return [];
  }

  bool _hasMatchingChefType(Map<String, dynamic> order, String role) {
    if (role == 'Chef_All') return true;
    for (final key in ['cartItems', 'items', 'order']) {
      if (order[key] is List) {
        if ((order[key] as List).any(
          (item) => item['chefType']?.toString() == role,
        ))
          return true;
      }
    }
    return false;
  }

  void _showRoleWarningDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _C.amberLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.warning_rounded,
                color: _C.amber,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Role Required',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: _C.text1,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Please log in with a valid chef role:',
              style: TextStyle(fontSize: 13, color: _C.text2),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _validChefTypes
                  .map(
                    (r) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: _C.accentLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        r.replaceAll('_', ' '),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _C.accent,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK',
              style: TextStyle(color: _C.accent, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  void _applyFilter() {
    if (_selectedFilter == 'chef') {
      _filteredOrders = _allOrders.where((o) {
        final type = (o['orderType'] ?? '').toString().toUpperCase();
        return [
          'DINE_IN',
          'TAKEAWAY',
          'DELIVERY',
          'TABLE_DINE_IN',
        ].contains(type);
      }).toList();
    } else if (_selectedFilter == 'online') {
      _filteredOrders = _allOrders.where((o) {
        final type = (o['orderType'] ?? '').toString().toUpperCase();
        final status = (o['status'] ?? '').toString().toUpperCase();
        return ['DELIVERY', 'TAKEAWAY', 'DINE_IN'].contains(type) &&
            status == 'PENDING';
      }).toList();
    } else {
      _filteredOrders = List.from(_allOrders);
    }
    _filteredOrders.sort((a, b) {
      final da =
          DateTime.tryParse(a['orderDateAndTime'] ?? '') ?? DateTime(2000);
      final db =
          DateTime.tryParse(b['orderDateAndTime'] ?? '') ?? DateTime(2000);
      return db.compareTo(da);
    });
  }

  void _updateDisplayOrders() {
    if (_selectedTab == 0) {
      if (_selectedFilter == 'chef') {
        _displayOrders = _filteredOrders
            .where((o) => o['status'] == 'CONFIRMED')
            .toList()
            .reversed
            .toList();
      } else if (_selectedFilter == 'online') {
        _displayOrders = _filteredOrders
            .where((o) => o['status'] == 'PENDING')
            .toList()
            .reversed
            .toList();
      }
    } else if (_selectedTab == 1) {
      if (_selectedFilter == 'chef') {
        _displayOrders = _filteredOrders
            .where((o) => o['status'] == 'BEING_PREPARED')
            .toList()
            .reversed
            .toList();
      } else if (_selectedFilter == 'online') {
        _displayOrders = _filteredOrders
            .where(
              (o) =>
                  o['status'] == 'BEING_PREPARED' || o['status'] == 'CONFIRMED',
            )
            .toList()
            .reversed
            .toList();
      }
    }
  }

  Future<void> _fetchOrdersInBackground() async {
    try {
      final allOrders = await food_authservice.getAllOrders();
      final filtered = _applyRoleFiltering(
        allOrders.where((o) {
          final type = (o['orderType'] ?? '').toString().toUpperCase();
          return [
            'DINE_IN',
            'DELIVERY',
            'TAKEAWAY',
            'TABLE_DINE_IN',
          ].contains(type);
        }).toList(),
      );
      final prevCount = _allOrders.length;
      if (mounted)
        setState(() {
          _allOrders = filtered;
          _applyFilter();
          _updateDisplayOrders();
        });
      if (filtered.length > prevCount)
        _findAndRingNewOrders(prevCount, filtered);
      else if (filtered.length < prevCount)
        _cleanupCompletedOrders(filtered);
      _previousOrderCount = filtered.length;
    } catch (e) {
      debugPrint('Background fetch error: $e');
    }
  }

  void _startOrderPolling() {
    _orderPollingTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (mounted) _fetchOrdersInBackground();
    });
  }

  Future<void> _initializeSound() async {
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
  }

  Future<void> _startRingingForOrder(String orderId) async {
    if (!_isSoundEnabled || _isPlaying) return;
    try {
      _isPlaying = true;
      await _audioPlayer.play(AssetSource('school-bell-310293.mp3'));
    } catch (e) {
      _isPlaying = false;
    }
  }

  Future<void> _stopAllRinging() async {
    if (_isPlaying) {
      await _audioPlayer.stop();
      _isPlaying = false;
    }
  }

  void _stopRingingForOrder(String orderId) {
    if (_pendingOrderIds.contains(orderId)) {
      _pendingOrderIds.remove(orderId);
      _ringingOrderIds.remove(orderId);
      _acknowledgedOrderIds.add(orderId);
      if (_pendingOrderIds.isEmpty && _isPlaying) _stopAllRinging();
    }
  }

  void _triggerVibration() {
    try {
      HapticFeedback.lightImpact();
    } catch (_) {}
  }

  void _handleOrderUpdate(String orderId, String newStatus) {
    final idx = _allOrders.indexWhere(
      (o) => o['orderId'].toString() == orderId,
    );
    if (idx != -1) {
      setState(() {
        _allOrders[idx]['status'] = newStatus;
        _applyFilter();
        _updateDisplayOrders();
      });
      if (newStatus == 'BEING_PREPARED') _acknowledgedOrderIds.remove(orderId);
    }
  }

  Future<void> _handleRefresh() async {
    setState(() => _isLoading = true);
    await _fetchOrders();
  }

  void _showSnack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _orderPollingTimer?.cancel();
    _stopAllRinging();
    _audioPlayer.dispose();
    super.dispose();
  }

  // ══════════════════════════════════════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildHeader(),
                _buildTabBar(),
                Expanded(
                  child: IndexedStack(
                    index: _selectedTab,
                    children: [
                      RefreshIndicator(
                        onRefresh: _handleRefresh,
                        color: _C.accent,
                        child: AllOrdersTab(
                          orders: _displayOrders,
                          isLoading: _isLoading,
                          printSelected: _printSelected,
                          onOrderAccepted: _stopRingingForOrder,
                          onOrderUpdated: _handleOrderUpdate,
                          isRinging: _pendingOrderIds.isNotEmpty,
                          filterType: _selectedFilter,
                          employeeRole: _employeeRole,
                          userRole: _userRole,
                        ),
                      ),
                      RefreshIndicator(
                        onRefresh: _handleRefresh,
                        color: _C.accent,
                        child: ProcessingTab(
                          orders: _displayOrders,
                          isLoading: _isLoading,
                          onOrderUpdated: _handleOrderUpdate,
                          filterType: _selectedFilter,
                          employeeRole: _employeeRole,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // FAB refresh
            Positioned(
              bottom: 20,
              right: 16,
              child: GestureDetector(
                onTap: _handleRefresh,
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: _C.gradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _C.accent.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.refresh_rounded,
                        color: Colors.white,
                        size: 24.sp,
                      ),
                      if (_isLoading)
                        const CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                          backgroundColor: Colors.transparent,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 12.w, 12.h),
      decoration: const BoxDecoration(
        color: _C.white,
        border: Border(bottom: BorderSide(color: _C.border, width: 1)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36.r,
              height: 36.r,
              decoration: BoxDecoration(
                color: _C.bg,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: _C.border),
              ),
              child: Icon(
                Icons.arrow_back_ios_rounded,
                color: _C.text1,
                size: 16.sp,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chef Management',
                  style: TextStyle(
                    color: _C.text1,
                    fontWeight: FontWeight.w900,
                    fontSize: 18.sp,
                    letterSpacing: -0.3,
                  ),
                ),
                if (_employeeRole != null && _employeeRole!.isNotEmpty)
                  Text(
                    _employeeRole!.replaceAll('_', ' '),
                    style: TextStyle(
                      color: _C.text2,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
          // Print toggle
          GestureDetector(
            onTap: () {
              setState(() => _printSelected = !_printSelected);
              _showSnack(
                _printSelected ? 'Printing Enabled ✅' : 'Printing Disabled ❌',
                _printSelected ? _C.blue : _C.text2,
              );
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
              decoration: BoxDecoration(
                color: _printSelected ? _C.blueLight : _C.bg,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: _printSelected ? _C.blue.withOpacity(0.3) : _C.border,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.print_rounded,
                    color: _printSelected ? _C.blue : _C.text2,
                    size: 16.sp,
                  ),
                  SizedBox(width: 5.w),
                  Text(
                    _printSelected ? 'ON' : 'OFF',
                    style: TextStyle(
                      color: _printSelected ? _C.blue : _C.text2,
                      fontWeight: FontWeight.w800,
                      fontSize: 11.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 8.w),
          // Sound toggle
          GestureDetector(
            onTap: () {
              setState(() => _isSoundEnabled = !_isSoundEnabled);
              if (!_isSoundEnabled && _isPlaying)
                _stopAllRinging();
              else if (_isSoundEnabled &&
                  _pendingOrderIds.isNotEmpty &&
                  !_isPlaying)
                _startRingingForOrder(_pendingOrderIds.first);
              _showSnack(
                _isSoundEnabled ? 'Sound ON 🔔' : 'Sound OFF 🔕',
                _isSoundEnabled ? _C.accent : _C.text2,
              );
            },
            child: Stack(
              children: [
                Container(
                  width: 36.r,
                  height: 36.r,
                  decoration: BoxDecoration(
                    color: _pendingOrderIds.isNotEmpty && _isPlaying
                        ? _C.red.withOpacity(0.1)
                        : _C.bg,
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(
                      color: _pendingOrderIds.isNotEmpty && _isPlaying
                          ? _C.red.withOpacity(0.3)
                          : _C.border,
                    ),
                  ),
                  child: Icon(
                    _isSoundEnabled
                        ? Icons.notifications_active_rounded
                        : Icons.notifications_off_rounded,
                    color: _pendingOrderIds.isNotEmpty && _isPlaying
                        ? _C.red
                        : _C.text2,
                    size: 18.sp,
                  ),
                ),
                if (_pendingOrderIds.isNotEmpty && _isPlaying)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: _C.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Tab Bar ───────────────────────────────────────────────────────────────────
  Widget _buildTabBar() {
    // Pending count badge for All tab
    final pendingCount = _allOrders
        .where((o) => o['status'] == 'CONFIRMED' || o['status'] == 'PENDING')
        .length;
    final processingCount = _allOrders
        .where((o) => o['status'] == 'BEING_PREPARED')
        .length;

    return Container(
      color: _C.white,
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 8.h),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(4.r),
            decoration: BoxDecoration(
              color: _C.bg,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: _C.border),
            ),
            child: Row(
              children: List.generate(_tabTitles.length, (i) {
                final isSelected = _selectedTab == i;
                final count = i == 0 ? pendingCount : processingCount;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() {
                      _selectedTab = i;
                      _updateDisplayOrders();
                    }),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      height: 40.h,
                      decoration: BoxDecoration(
                        gradient: isSelected ? _C.gradient : null,
                        borderRadius: BorderRadius.circular(10.r),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: _C.accent.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _tabTitles[i],
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                              color: isSelected ? Colors.white : _C.text2,
                            ),
                          ),
                          if (count > 0) ...[
                            SizedBox(width: 6.w),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6.w,
                                vertical: 1.h,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.white.withOpacity(0.25)
                                    : (i == 0 ? _C.red : _C.amber).withOpacity(
                                        0.15,
                                      ),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Text(
                                '$count',
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w800,
                                  color: isSelected
                                      ? Colors.white
                                      : (i == 0 ? _C.red : _C.amber),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 8),
          const Divider(color: _C.border, height: 1),
        ],
      ),
    );
  }
}

// ─── AllOrdersTab ─────────────────────────────────────────────────────────────
class AllOrdersTab extends StatefulWidget {
  final List<dynamic> orders;
  final bool isLoading;
  final bool printSelected;
  final Function(String) onOrderAccepted;
  final Function(String, String) onOrderUpdated;
  final bool isRinging;
  final String filterType;
  final String? employeeRole;
  final String? userRole;

  const AllOrdersTab({
    super.key,
    required this.orders,
    required this.isLoading,
    required this.printSelected,
    required this.onOrderAccepted,
    required this.onOrderUpdated,
    required this.isRinging,
    required this.filterType,
    required this.employeeRole,
    required this.userRole,
  });

  @override
  State<AllOrdersTab> createState() => _AllOrdersTabState();
}

class _AllOrdersTabState extends State<AllOrdersTab> {
  final Map<int, bool> _selectedItems = {};
  String? connectedPrinterMac;
  bool isConnected = false;
  bool isConnecting = false;
  static const String kDefaultPrinterKey = 'default_printer_mac';

  @override
  void initState() {
    super.initState();
    _restorePrinterConnection();
  }

  Future<void> saveDefaultPrinter(String mac) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(kDefaultPrinterKey, mac);
  }

  Future<String?> getDefaultPrinter() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(kDefaultPrinterKey);
  }

  Future<void> _restorePrinterConnection() async {
    try {
      final mac = await getDefaultPrinter();
      if (mac != null && mac.isNotEmpty) {
        final connected = await PrintBluetoothThermal.connect(
          macPrinterAddress: mac,
        );
        if (connected && await PrintBluetoothThermal.connectionStatus) {
          connectedPrinterMac = mac;
          isConnected = true;
        }
      }
    } catch (_) {
      connectedPrinterMac = null;
      isConnected = false;
    }
  }

  String formatOrderType(String? type) {
    switch (type) {
      case 'TAKEAWAY':
        return 'Take Away';
      case 'DINE_IN':
        return 'Dine In';
      case 'DELIVERY':
        return 'Delivery';
      case 'TABLE_DINE_IN':
        return 'Table Dine In';
      default:
        return type?.replaceAll('_', ' ') ?? '';
    }
  }

  Color _orderTypeColor(String? t) {
    switch (t?.toUpperCase()) {
      case 'DELIVERY':
        return _C.blue;
      case 'TAKEAWAY':
        return _C.green;
      case 'DINE_IN':
        return _C.amber;
      case 'TABLE_DINE_IN':
        return _C.purple;
      default:
        return _C.text2;
    }
  }

  IconData _orderTypeIcon(String? t) {
    switch (t?.toUpperCase()) {
      case 'DELIVERY':
        return Icons.delivery_dining_rounded;
      case 'TAKEAWAY':
        return Icons.shopping_bag_rounded;
      case 'DINE_IN':
        return Icons.restaurant_rounded;
      case 'TABLE_DINE_IN':
        return Icons.table_restaurant_rounded;
      default:
        return Icons.receipt_rounded;
    }
  }

  String _getAcceptStatus() => 'BEING_PREPARED';

  Future<void> _handleAcceptWithPrint(Map<String, dynamic> order) async {
    if (!widget.printSelected) {
      await _handleOrderAction(order, _getAcceptStatus());
      widget.onOrderAccepted(order['orderId'].toString());
      return;
    }
    setState(() => isConnecting = true);
    try {
      final savedMac = await getDefaultPrinter();
      final bluetoothOn = await PrintBluetoothThermal.bluetoothEnabled;
      if (bluetoothOn && savedMac != null && savedMac.isNotEmpty) {
        bool connected = await PrintBluetoothThermal.connectionStatus;
        if (!connected) {
          await PrintBluetoothThermal.disconnect;
          await Future.delayed(const Duration(milliseconds: 300));
          connected = await PrintBluetoothThermal.connect(
            macPrinterAddress: savedMac,
          );
        }
        if (connected) {
          try {
            await _printThermalkot(order);
            await _acceptOrderAfterPrint(order);
            return;
          } catch (_) {
            if (mounted) _showPrinterSelectionDialog(order);
            return;
          }
        }
      }
      if (mounted) _showPrinterSelectionDialog(order);
    } finally {
      setState(() => isConnecting = false);
    }
  }

  Future<void> _printThermalkot(Map<String, dynamic> data) async {
    final items = data['order'] as List<dynamic>? ?? [];
    await PrintBluetoothThermal.writeBytes(Uint8List.fromList([27, 97, 1]));
    await PrintBluetoothThermal.writeBytes(Uint8List.fromList([27, 69, 1]));
    await PrintBluetoothThermal.writeString(
      printText: PrintTextSize(
        size: 2,
        text: "${data['vendorRegisteredName']?.toString().toUpperCase()}\n",
      ),
    );
    await PrintBluetoothThermal.writeString(
      printText: PrintTextSize(
        size: 2,
        text: "------------------------------------------------\n",
      ),
    );
    String makeRow(String l, String r) {
      int sp = 48 - l.length - r.length;
      return l + " " * (sp < 1 ? 1 : sp) + r;
    }

    await PrintBluetoothThermal.writeString(
      printText: PrintTextSize(
        size: 2,
        text:
            makeRow(
              "Order ID : ${data['orderId']}",
              "Date : ${data['date'] ?? ''}",
            ) +
            "\n",
      ),
    );
    await PrintBluetoothThermal.writeString(
      printText: PrintTextSize(
        size: 2,
        text:
            makeRow(
              "Type     : ${formatOrderType(data['orderType'])}",
              "Time : ${data['time'] ?? ''}",
            ) +
            "\n",
      ),
    );
    await PrintBluetoothThermal.writeString(
      printText: PrintTextSize(
        size: 2,
        text: "------------------------------------------------\n",
      ),
    );
    await PrintBluetoothThermal.writeString(
      printText: PrintTextSize(
        size: 2,
        text: "ITEM                       QTY\n",
      ),
    );
    await PrintBluetoothThermal.writeString(
      printText: PrintTextSize(
        size: 2,
        text: "------------------------------------------------\n",
      ),
    );
    for (var item in items) {
      String name = (item['dishName'] ?? 'N/A').toString();
      if (name.length > 26) name = name.substring(0, 26);
      await PrintBluetoothThermal.writeString(
        printText: PrintTextSize(
          size: 2,
          text:
              "${name.padRight(28)}${(item['quantity']?.toString() ?? '0').padRight(10)}\n",
        ),
      );
    }
    await PrintBluetoothThermal.writeString(
      printText: PrintTextSize(
        size: 2,
        text: "------------------------------------------------\n",
      ),
    );
    await PrintBluetoothThermal.writeBytes([29, 86, 65, 0]);
    await PrintBluetoothThermal.writeBytes([27, 100, 2]);
  }

  void _showPrinterSelectionDialog(Map<String, dynamic> order) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: _C.blueLight,
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Icon(Icons.print_rounded, color: _C.blue, size: 18),
            ),
            const SizedBox(width: 10),
            const Text(
              'Select Printer',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: _C.text1,
              ),
            ),
          ],
        ),
        content: FutureBuilder<List<BluetoothInfo>>(
          future: PrintBluetoothThermal.pairedBluetooths,
          builder: (_, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return SizedBox(
                height: 120.h,
                child: const Center(
                  child: CircularProgressIndicator(
                    color: _C.accent,
                    strokeWidth: 2,
                  ),
                ),
              );
            }
            if (snap.data == null || snap.data!.isEmpty) {
              return SizedBox(
                height: 120.h,
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.print_disabled_rounded,
                        size: 40,
                        color: _C.text3,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'No paired printers found',
                        style: TextStyle(color: _C.text2, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              );
            }
            return SizedBox(
              height: 200.h,
              width: double.maxFinite,
              child: ListView.separated(
                itemCount: snap.data!.length,
                separatorBuilder: (_, __) =>
                    const Divider(color: _C.border, height: 1),
                itemBuilder: (_, i) {
                  final p = snap.data![i];
                  return ListTile(
                    leading: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: _C.accentLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.print_rounded,
                        color: _C.accent,
                        size: 17,
                      ),
                    ),
                    title: Text(
                      p.name,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _C.text1,
                      ),
                    ),
                    subtitle: Text(
                      p.macAdress,
                      style: const TextStyle(fontSize: 10, color: _C.text2),
                    ),
                    trailing: GestureDetector(
                      onTap: () async {
                        Navigator.pop(context);
                        await _tryPrintWithSelectedPrinter(order, p);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: _C.gradient,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Print',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _acceptWithoutPrint(order);
            },
            child: const Text(
              'Accept Without Print',
              style: TextStyle(color: _C.amber, fontWeight: FontWeight.w600),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: _C.text2)),
          ),
        ],
      ),
    );
  }

  Future<void> _tryPrintWithSelectedPrinter(
    Map<String, dynamic> order,
    BluetoothInfo printer,
  ) async {
    setState(() => isConnecting = true);
    try {
      await PrintBluetoothThermal.connect(macPrinterAddress: printer.macAdress);
      await _printThermalkot(order);
      await saveDefaultPrinter(printer.macAdress);
      await _acceptOrderAfterPrint(order);
    } catch (e) {
      if (mounted) {
        _snack('Print failed: $e', _C.red);
        _showPrinterSelectionDialog(order);
      }
    } finally {
      setState(() => isConnecting = false);
    }
  }

  Future<void> _acceptOrderAfterPrint(Map<String, dynamic> order) async {
    await _handleOrderAction(order, _getAcceptStatus());
    widget.onOrderAccepted(order['orderId'].toString());
    if (mounted) _snack('Order accepted & printed ✅', _C.green);
  }

  Future<void> _acceptWithoutPrint(Map<String, dynamic> order) async {
    await _handleOrderAction(order, _getAcceptStatus());
    widget.onOrderAccepted(order['orderId'].toString());
    if (mounted) _snack('Order accepted (no print)', _C.amber);
  }

  Future<void> _handleOrderAction(
    Map<String, dynamic> order,
    String status,
  ) async {
    final orderId = order['orderId'];
    final items = order['order'] ?? [];
    if (status == 'BEING_PREPARED' && widget.filterType == 'chef') {
      for (var item in items) {
        if (!(_selectedItems[item['listId']] ?? true))
          await food_authservice.cancelOrderItem(item['listId']);
      }
    }
    final success = await food_authservice.updateOrderStatus(orderId, status);
    if (success && mounted) {
      widget.onOrderUpdated(orderId.toString(), status);
      _snack('Order updated to ${status.replaceAll('_', ' ')}', _C.green);
    } else if (mounted) {
      _snack('Failed to update order', _C.red);
    }
  }

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) return _buildLoading();
    if (widget.orders.isEmpty) {
      final noRole =
          widget.employeeRole == null || widget.employeeRole!.isEmpty;
      return _buildEmpty(
        noRole ? Icons.warning_rounded : Icons.inbox_rounded,
        noRole ? 'No Role Assigned' : 'No Pending Orders',
        noRole ? '' : 'New orders will appear here automatically',
        noRole ? _C.amber : _C.accent,
      );
    }
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 80.h),
      itemCount: widget.orders.length,
      itemBuilder: (_, i) => _buildOrderCard(widget.orders[i]),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final items = order['order'] ?? [];
    final status = order['status'] ?? 'PENDING';
    final isPending = status == 'PENDING' || status == 'CONFIRMED';
    final isRinging = widget.isRinging && isPending;
    final typeColor = _orderTypeColor(order['orderType']);
    final hasUserId = order['userId'] != null;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: EdgeInsets.only(bottom: 14.h),
      decoration: BoxDecoration(
        color: _C.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: isRinging ? _C.red.withOpacity(0.5) : _C.border,
          width: isRinging ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isRinging ? _C.red.withOpacity(0.12) : _C.shadow,
            blurRadius: isRinging ? 16 : 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Card header ────────────────────────────────────────────────────────
          Container(
            padding: EdgeInsets.fromLTRB(14.w, 12.h, 12.w, 12.h),
            decoration: BoxDecoration(
              color: isRinging
                  ? _C.redLight.withOpacity(0.3)
                  : typeColor.withOpacity(0.05),
              borderRadius: BorderRadius.vertical(top: Radius.circular(18.r)),
            ),
            child: Row(
              children: [
                // Order type icon pill
                Container(
                  width: 38.r,
                  height: 38.r,
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    _orderTypeIcon(order['orderType']),
                    color: typeColor,
                    size: 19.sp,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (isRinging) ...[

                            SizedBox(width: 4.w),
                          ],
                          Text(
                            'Order #${order['orderId'] ?? 'N/A'}',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15.sp,
                              color: _C.text1,
                            ),
                          ),
                          if (hasUserId) ...[
                            SizedBox(width: 6.w),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: _C.blueLight,
                                borderRadius: BorderRadius.circular(5.r),
                                border: Border.all(
                                  color: _C.blue.withOpacity(0.2),
                                ),
                              ),
                              child: Text(
                                'Online',
                                style: TextStyle(
                                  fontSize: 9.sp,
                                  fontWeight: FontWeight.w700,
                                  color: _C.blue,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        _formatTime(order['orderDateAndTime']),
                        style: TextStyle(fontSize: 10.sp, color: _C.text2),
                      ),
                    ],
                  ),
                ),
                // Order type badge
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 5.h,
                  ),
                  decoration: BoxDecoration(
                    color: typeColor,
                    borderRadius: BorderRadius.circular(10.r),
                    boxShadow: [
                      BoxShadow(
                        color: typeColor.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    formatOrderType(order['orderType']),
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Items list ─────────────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Items',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: _C.text2,
                    letterSpacing: 0.3,
                  ),
                ),
                SizedBox(height: 8.h),
                ...items.map<Widget>((item) {
                  final listId = item['listId'] ?? 0;
                  final isChecked = _selectedItems[listId] ?? false;
                  return GestureDetector(
                    onTap: () =>
                        setState(() => _selectedItems[listId] = !isChecked),
                    child: Container(
                      margin: EdgeInsets.only(bottom: 6.h),
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: isChecked ? _C.greenLight : _C.bg,
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                          color: isChecked
                              ? _C.green.withOpacity(0.3)
                              : _C.border,
                        ),
                      ),
                      child: Row(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 20.r,
                            height: 20.r,
                            decoration: BoxDecoration(
                              color: isChecked ? _C.green : _C.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isChecked ? _C.green : _C.border,
                                width: 1.5,
                              ),
                            ),
                            child: isChecked
                                ? Icon(
                                    Icons.check_rounded,
                                    color: Colors.white,
                                    size: 12.sp,
                                  )
                                : null,
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Text(
                              '${item['dishName'] ?? 'Unknown'}',
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: _C.text1,
                                fontWeight: FontWeight.w600,
                                decoration: isChecked
                                    ? TextDecoration.lineThrough
                                    : null,
                                decorationColor: _C.green,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: _C.accentLight,
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              'x${item['quantity'] ?? 1}',
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w800,
                                color: _C.accent,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),

          // ── Action buttons ─────────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.all(12.r),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: isConnecting
                        ? null
                        : () => _handleAcceptWithPrint(order),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      decoration: BoxDecoration(
                        gradient: isConnecting
                            ? null
                            : const LinearGradient(
                                colors: [_C.green, _C.greenDark],
                              ),
                        color: isConnecting ? _C.border : null,
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: isConnecting
                            ? null
                            : [
                                BoxShadow(
                                  color: _C.green.withOpacity(0.35),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (isConnecting)
                            SizedBox(
                              width: 16.sp,
                              height: 16.sp,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: _C.text2,
                              ),
                            )
                          else
                            Icon(
                              Icons.check_circle_rounded,
                              color: Colors.white,
                              size: 17.sp,
                            ),
                          SizedBox(width: 6.w),
                          Text(
                            isConnecting ? 'Processing...' : 'Accept',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w800,
                              color: isConnecting ? _C.text2 : Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _handleOrderAction(order, 'CANCELLED'),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      decoration: BoxDecoration(
                        color: _C.redLight,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: _C.red.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.cancel_rounded,
                            color: _C.red,
                            size: 17.sp,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            'Decline',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w800,
                              color: _C.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(String? raw) {
    if (raw == null) return '';
    try {
      return DateFormat('hh:mm a · dd MMM').format(DateTime.parse(raw));
    } catch (_) {
      return '';
    }
  }

  Widget _buildLoading() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: _C.gradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: _C.accent.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: const Icon(
            Icons.restaurant_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Loading orders...',
          style: TextStyle(
            fontSize: 14,
            color: _C.text2,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );

  Widget _buildEmpty(
    IconData icon,
    String title,
    String subtitle,
    Color color,
  ) => Center(
    child: Padding(
      padding: EdgeInsets.all(32.r),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.2), width: 2),
            ),
            child: Icon(icon, size: 32, color: color),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: _C.text1,
            ),
            textAlign: TextAlign.center,
          ),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 12, color: _C.text2),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    ),
  );
}

// ─── ProcessingTab ────────────────────────────────────────────────────────────
class ProcessingTab extends StatefulWidget {
  final List<dynamic> orders;
  final bool isLoading;
  final Function(String, String) onOrderUpdated;
  final String filterType;
  final String? employeeRole;

  const ProcessingTab({
    super.key,
    required this.orders,
    required this.isLoading,
    required this.onOrderUpdated,
    required this.filterType,
    required this.employeeRole,
  });

  @override
  State<ProcessingTab> createState() => _ProcessingTabState();
}

class _ProcessingTabState extends State<ProcessingTab> {
  final Map<int, bool> _selectedItems = {};
  bool get _isChefMode => widget.filterType == 'chef';
  bool get _isOnlineMode => widget.filterType == 'online';

  String formatOrderType(String? type) {
    switch (type) {
      case 'TAKEAWAY':
        return 'Take Away';
      case 'DINE_IN':
        return 'Dine In';
      case 'DELIVERY':
        return 'Delivery';
      case 'TABLE_DINE_IN':
        return 'Table Dine In';
      default:
        return type?.replaceAll('_', ' ') ?? '';
    }
  }

  Color _orderTypeColor(String? t) {
    switch (t?.toUpperCase()) {
      case 'DELIVERY':
        return _C.blue;
      case 'TAKEAWAY':
        return _C.green;
      case 'DINE_IN':
        return _C.amber;
      case 'TABLE_DINE_IN':
        return _C.purple;
      default:
        return _C.text2;
    }
  }

  IconData _orderTypeIcon(String? t) {
    switch (t?.toUpperCase()) {
      case 'DELIVERY':
        return Icons.delivery_dining_rounded;
      case 'TAKEAWAY':
        return Icons.shopping_bag_rounded;
      case 'DINE_IN':
        return Icons.restaurant_rounded;
      case 'TABLE_DINE_IN':
        return Icons.table_restaurant_rounded;
      default:
        return Icons.receipt_rounded;
    }
  }

  // Progress steps
  List<Map<String, dynamic>> _getSteps(String status) {
    final steps = [
      {
        'label': 'Confirmed',
        'status': 'CONFIRMED',
        'icon': Icons.check_rounded,
      },
      {
        'label': 'Cooking',
        'status': 'BEING_PREPARED',
        'icon': Icons.soup_kitchen_rounded,
      },
      {
        'label': 'Ready',
        'status': 'ORDER_IS_READY',
        'icon': Icons.done_all_rounded,
      },
    ];
    return steps;
  }

  int _stepIndex(String status) {
    switch (status) {
      case 'CONFIRMED':
        return 0;
      case 'BEING_PREPARED':
        return 1;
      case 'ORDER_IS_READY':
        return 2;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) return _buildLoading();
    if (widget.orders.isEmpty) {
      final noRole =
          widget.employeeRole == null || widget.employeeRole!.isEmpty;
      return _buildEmpty(
        noRole ? Icons.warning_rounded : Icons.soup_kitchen_rounded,
        noRole ? 'No Role Assigned' : 'No Orders In Progress',
        noRole ? '' : 'Orders being prepared will appear here',
        noRole ? _C.amber : _C.orange,
      );
    }
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 80.h),
      itemCount: widget.orders.length,
      itemBuilder: (_, i) => _buildOrderCard(widget.orders[i]),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final items = order['order'] ?? [];
    final status = order['status'] ?? 'BEING_PREPARED';
    final typeColor = _orderTypeColor(order['orderType']);
    final currentStep = _stepIndex(status);
    final steps = _getSteps(status);

    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      decoration: BoxDecoration(
        color: _C.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: _C.border),
        boxShadow: [
          const BoxShadow(
            color: _C.shadow,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Header ─────────────────────────────────────────────────────────────
          Container(
            padding: EdgeInsets.fromLTRB(14.w, 12.h, 12.w, 12.h),
            decoration: BoxDecoration(
              color: typeColor.withOpacity(0.06),
              borderRadius: BorderRadius.vertical(top: Radius.circular(18.r)),
            ),
            child: Row(
              children: [
                Container(
                  width: 38.r,
                  height: 38.r,
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    _orderTypeIcon(order['orderType']),
                    color: typeColor,
                    size: 19.sp,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order #${order['orderId'] ?? 'N/A'}',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15.sp,
                          color: _C.text1,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        _formatTime(order['orderDateAndTime']),
                        style: TextStyle(fontSize: 10.sp, color: _C.text2),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 5.h,
                  ),
                  decoration: BoxDecoration(
                    color: typeColor,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Text(
                    formatOrderType(order['orderType']),
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Progress stepper ───────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 4.h),
            child: Row(
              children: steps.asMap().entries.map((e) {
                final idx = e.key;
                final step = e.value;
                final isDone = idx <= currentStep;
                final isActive = idx == currentStep;
                final isLast = idx == steps.length - 1;
                return Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: 28.r,
                              height: 28.r,
                              decoration: BoxDecoration(
                                gradient: isDone ? _C.gradient : null,
                                color: isDone ? null : _C.bg,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isDone ? _C.accent : _C.border,
                                  width: isActive ? 2 : 1,
                                ),
                                boxShadow: isActive
                                    ? [
                                        BoxShadow(
                                          color: _C.accent.withOpacity(0.35),
                                          blurRadius: 8,
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Icon(
                                step['icon'] as IconData,
                                size: 13.sp,
                                color: isDone ? Colors.white : _C.text3,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              step['label'] as String,
                              style: TextStyle(
                                fontSize: 9.sp,
                                fontWeight: isActive
                                    ? FontWeight.w800
                                    : FontWeight.w500,
                                color: isDone ? _C.accent : _C.text3,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      if (!isLast)
                        Expanded(
                          child: Container(
                            height: 2,
                            margin: const EdgeInsets.only(bottom: 16),
                            color: idx < currentStep ? _C.accent : _C.border,
                          ),
                        ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

          // ── Items ─────────────────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(14.w, 6.h, 14.w, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Items',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: _C.text2,
                  ),
                ),
                SizedBox(height: 8.h),
                ...items.map<Widget>((item) {
                  final listId = item['listId'] ?? 0;
                  final isChecked = _selectedItems[listId] ?? false;
                  return GestureDetector(
                    onTap: () =>
                        setState(() => _selectedItems[listId] = !isChecked),
                    child: Container(
                      margin: EdgeInsets.only(bottom: 6.h),
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: isChecked ? _C.orangeLight : _C.bg,
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                          color: isChecked
                              ? _C.orange.withOpacity(0.3)
                              : _C.border,
                        ),
                      ),
                      child: Row(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 20.r,
                            height: 20.r,
                            decoration: BoxDecoration(
                              color: isChecked ? _C.orange : _C.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isChecked ? _C.orange : _C.border,
                                width: 1.5,
                              ),
                            ),
                            child: isChecked
                                ? Icon(
                                    Icons.check_rounded,
                                    color: Colors.white,
                                    size: 12.sp,
                                  )
                                : null,
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Text(
                              item['dishName'] ?? item['name'] ?? 'Unknown',
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: _C.text1,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: _C.orangeLight,
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              'x${item['quantity'] ?? 1}',
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w800,
                                color: _C.orange,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),

          // ── Action buttons ─────────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.all(12.r),
            child: Row(
              children: [
                if (_isOnlineMode && status == 'CONFIRMED')
                  Expanded(
                    child: _actionBtn(
                      'Start Cooking',
                      Icons.soup_kitchen_rounded,
                      _C.green,
                      () => _handleOrderAction(order, 'BEING_PREPARED'),
                    ),
                  ),
                if (_isOnlineMode && status == 'CONFIRMED')
                  SizedBox(width: 10.w),
                if (status == 'BEING_PREPARED')
                  Expanded(
                    child: _actionBtn(
                      _isChefMode ? 'Ready to Serve' : 'Mark as Ready',
                      Icons.done_all_rounded,
                      _C.green,
                      () => _handleOrderAction(order, 'ORDER_IS_READY'),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionBtn(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, Color.lerp(color, Colors.black, 0.15)!],
        ),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.35),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 17.sp),
          SizedBox(width: 6.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ],
      ),
    ),
  );

  Future<void> _handleOrderAction(
    Map<String, dynamic> order,
    String status,
  ) async {
    final orderId = order['orderId'];
    final success = await food_authservice.updateOrderStatus(orderId, status);
    if (success && mounted) {
      widget.onOrderUpdated(orderId.toString(), status);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Order: ${status.replaceAll('_', ' ')}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: _C.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Failed to update',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: _C.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  String _formatTime(String? raw) {
    if (raw == null) return '';
    try {
      return DateFormat('hh:mm a · dd MMM').format(DateTime.parse(raw));
    } catch (_) {
      return '';
    }
  }

  Widget _buildLoading() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: _C.orangeLight,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.soup_kitchen_rounded,
            color: _C.orange,
            size: 28,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Loading orders...',
          style: TextStyle(
            fontSize: 14,
            color: _C.text2,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );

  Widget _buildEmpty(
    IconData icon,
    String title,
    String subtitle,
    Color color,
  ) => Center(
    child: Padding(
      padding: EdgeInsets.all(32.r),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.2), width: 2),
            ),
            child: Icon(icon, size: 32, color: color),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: _C.text1,
            ),
            textAlign: TextAlign.center,
          ),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 12, color: _C.text2),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    ),
  );
}
