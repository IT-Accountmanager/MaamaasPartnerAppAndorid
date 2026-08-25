// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:intl/intl.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../Api/APIclient.dart';
//
// // ================== DATA MODELS ==================
//
// class OrderUpdateModel {
//   final String orderId;
//   final String status;
//   final String? otp;
//   final String? deliveryBoyId;
//   final String cashStatus;
//
//   OrderUpdateModel({
//     required this.orderId,
//     required this.status,
//     String? otp,
//     this.deliveryBoyId,
//     this.cashStatus = 'ACCEPT',
//   }) : otp = otp?.toString();
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//
//     data['orderId'] = orderId;
//     data['status'] = status;
//     data['cashStatus'] = cashStatus;
//
//     if (otp != null && otp!.isNotEmpty) {
//       data['otp'] = otp!;
//     }
//
//     if (deliveryBoyId != null && deliveryBoyId!.isNotEmpty) {
//       data['deliveryBoyId'] = deliveryBoyId;
//       data['assignedTo'] = deliveryBoyId;
//     }
//
//     return data;
//   }
// }
//
// class DeliveryAuthService {
//   static Future<List<dynamic>> getDeliveryOrdersByStatusRange({
//     required String vendorId,
//     String fromStatus = 'ORDER_IS_READY',
//     String toStatus = 'ON_THE_WAY',
//   }) async {
//     final response = await ApiClient.get(
//       'food/api/orders/status-range',
//       service: 'food',
//     );
//
//     if (response.statusCode == 200) {
//       final decoded = jsonDecode(response.body);
//       return List<dynamic>.from(decoded);
//     } else {
//       throw Exception('Failed to fetch orders: ${response.body}');
//     }
//   }
//
//   static Future<Map<String, dynamic>> updateOrderStatus(
//     String orderId,
//     String status, {
//     String? otp,
//     String? deliveryBoyId,
//     String cashStatus = 'ACCEPT',
//   }) async {
//     try {
//       final body = {
//         "orderId": orderId,
//         "status": status,
//         "otp": otp,
//         "deliveryBoyId": deliveryBoyId,
//         "cashStatus": cashStatus,
//       };
//
//       final response = await ApiClient.put(
//         'food/api/orders/edit-orders/$orderId/$status?cashStatus=$cashStatus',
//         body,
//         service: 'food',
//       );
//
//       if (response.statusCode == 200) {
//         return {'success': true, 'data': jsonDecode(response.body)};
//       } else {
//         return {'success': false, 'error': response.body};
//       }
//     } catch (e) {
//       return {'success': false, 'error': e.toString()};
//     }
//   }
//
//   static Future<Map<String, dynamic>> getOrderDetailsWithOTP(
//     String orderId,
//   ) async {
//     try {
//       final response = await ApiClient.get(
//         'delivery/api/get/order?orderId=$orderId&appType=FOOD_AND_BEVERAGES',
//         service: 'delivery',
//       );
//
//       if (response.statusCode == 200) {
//         final decoded = jsonDecode(response.body);
//
//         final vendorOtpRaw = decoded['vendorOtp'];
//         final vendorOtpStr = vendorOtpRaw?.toString() ?? '0';
//
//         final hasOtp =
//             vendorOtpStr != '0' &&
//             vendorOtpStr != 'null' &&
//             vendorOtpStr.isNotEmpty;
//
//         return {
//           'success': true,
//           'data': decoded,
//           'vendorOtp': vendorOtpStr,
//           'vendorOtpRaw': vendorOtpRaw,
//           'hasOtp': hasOtp,
//         };
//       } else {
//         return {'success': false, 'error': response.body};
//       }
//     } catch (e) {
//       return {'success': false, 'error': e.toString()};
//     }
//   }
//
//   static Future<Map<String, dynamic>> acceptReadyOrder(String orderId) async {
//     print('🚀 acceptReadyOrder called for order: $orderId');
//     print('📋 Status transition: ORDER_IS_READY → WAITING_FOR_PICKUP');
//     return await updateOrderStatus(orderId, 'WAITING_FOR_PICKUP');
//   }
//
//   static Future<Map<String, dynamic>> acceptPickupOrder(
//     String orderId,
//     String otp,
//     String deliveryBoyId,
//   ) async {
//     print('🚀 acceptPickupOrder called for order: $orderId');
//     print('📋 Status transition: WAITING_FOR_PICKUP → ON_THE_WAY');
//     print('🔑 OTP: $otp (Type: ${otp.runtimeType})');
//     print('👤 Delivery Boy: $deliveryBoyId');
//
//     final otpString = otp.toString();
//
//     return await updateOrderStatus(
//       orderId,
//       'ON_THE_WAY',
//       otp: otpString,
//       deliveryBoyId: deliveryBoyId,
//     );
//   }
//
//   // ================== STATUS HELPER METHODS ==================
//
//   static bool isReadyOrder(String status) {
//     return status.toUpperCase() == 'ORDER_IS_READY';
//   }
//
//   static bool isWaitingForPickup(String status) {
//     return status.toUpperCase() == 'WAITING_FOR_PICKUP';
//   }
//
//   static bool isOnTheWay(String status) {
//     return status.toUpperCase() == 'ON_THE_WAY';
//   }
//
//   static bool isDeliveryOrder(Map<String, dynamic> order) {
//     final type = (order['orderType'] ?? '').toString().toUpperCase();
//     return type == 'DELIVERY';
//   }
//
//   static String getStatusDisplayName(String status) {
//     switch (status.toUpperCase()) {
//       case 'ORDER_IS_READY':
//         return 'Ready';
//       case 'WAITING_FOR_PICKUP':
//         return 'Waiting';
//       case 'ON_THE_WAY':
//         return 'On Way';
//       case 'DELIVERED':
//         return 'Delivered';
//       default:
//         return status;
//     }
//   }
//
//   static Color getStatusColor(String status) {
//     switch (status.toUpperCase()) {
//       case 'ORDER_IS_READY':
//         return Colors.blue;
//       case 'WAITING_FOR_PICKUP':
//         return Colors.orange;
//       case 'ON_THE_WAY':
//         return Colors.purple;
//       case 'DELIVERED':
//         return Colors.green;
//       default:
//         return Colors.grey;
//     }
//   }
//
//   static IconData getStatusIcon(String status) {
//     switch (status.toUpperCase()) {
//       case 'ORDER_IS_READY':
//         return Icons.restaurant;
//       case 'WAITING_FOR_PICKUP':
//         return Icons.timer;
//       case 'ON_THE_WAY':
//         return Icons.directions_bike;
//       case 'DELIVERED':
//         return Icons.check_circle;
//       default:
//         return Icons.info;
//     }
//   }
// }
//
// // ================== MAIN DELIVERY MANAGEMENT SCREEN ==================
//
// class delivery_management extends StatefulWidget {
//   final String vendorId;
//
//   const delivery_management({super.key, required this.vendorId});
//
//   @override
//   State<delivery_management> createState() => _DeliveryManagementState();
// }
//
// class _DeliveryManagementState extends State<delivery_management> {
//   final List<String> _tabTitles = ["Delivery Orders", "Tracking Orders"];
//   int _selectedTab = 0;
//   List<dynamic> _orders = [];
//   bool _isLoading = true;
//   final Map<String, bool> _acceptingOrders = {};
//   final Map<String, TextEditingController> _otpControllers = {};
//   String? _selectedDeliveryBoy;
//   final List<String> _deliveryBoys = [
//     'Rajesh',
//     'Suresh',
//     'Mahesh',
//     'Ganesh',
//     'Ramesh',
//   ];
//   final Map<String, String> _deliveryBoyIds = {
//     'Rajesh': 'DEL001',
//     'Suresh': 'DEL002',
//     'Mahesh': 'DEL003',
//     'Ganesh': 'DEL004',
//     'Ramesh': 'DEL005',
//   };
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchOrders();
//   }
//
//   @override
//   void dispose() {
//     _otpControllers.values.forEach((controller) => controller.dispose());
//     super.dispose();
//   }
//
//   Future<void> _fetchOrders() async {
//     setState(() => _isLoading = true);
//     try {
//       final vendorId = widget.vendorId.isNotEmpty ? widget.vendorId : '1';
//
//       final fetchedOrders =
//           await DeliveryAuthService.getDeliveryOrdersByStatusRange(
//             vendorId: vendorId,
//             fromStatus: 'ORDER_IS_READY',
//             toStatus: 'ON_THE_WAY',
//           );
//
//       final filteredOrders = fetchedOrders.where((order) {
//         return DeliveryAuthService.isDeliveryOrder(order);
//       }).toList();
//
//       setState(() => _orders = filteredOrders);
//     } catch (e) {
//       _showError('Failed to load orders: $e');
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }
//
//   void _showError(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.red,
//         duration: const Duration(seconds: 5),
//       ),
//     );
//   }
//
//   void _showSuccess(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.green,
//         duration: const Duration(seconds: 3),
//       ),
//     );
//   }
//
//   Future<String?> _showDeliveryBoySelectionDialog(
//     String orderId,
//     String orderNumber,
//     String customerName,
//   ) async {
//     String? selectedBoy;
//
//     await showDialog(
//       context: context,
//       builder: (context) => StatefulBuilder(
//         builder: (context, setState) {
//           return AlertDialog(
//             title: const Text('Assign Delivery Boy'),
//             content: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Order #$orderNumber',
//                   style: const TextStyle(fontWeight: FontWeight.bold),
//                 ),
//                 SizedBox(height: 4.h),
//                 Text(
//                   'Customer: $customerName',
//                   style: TextStyle(fontSize: 12.sp),
//                 ),
//                 SizedBox(height: 16.h),
//                 Container(
//                   padding: EdgeInsets.all(8.r),
//                   decoration: BoxDecoration(
//                     color: Colors.grey[50],
//                     borderRadius: BorderRadius.circular(8.r),
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         'Select Delivery Boy:',
//                         style: TextStyle(fontWeight: FontWeight.w500),
//                       ),
//                       SizedBox(height: 8.h),
//                       DropdownButtonFormField<String>(
//                         value: _selectedDeliveryBoy,
//                         isExpanded: true,
//                         decoration: const InputDecoration(
//                           hintText: 'Select delivery boy',
//                           border: OutlineInputBorder(),
//                         ),
//                         items: _deliveryBoys.map((boy) {
//                           return DropdownMenuItem(
//                             value: boy,
//                             child: Row(
//                               children: [
//                                 Icon(Icons.person, size: 18.sp),
//                                 SizedBox(width: 8.w),
//                                 Text(boy),
//                               ],
//                             ),
//                           );
//                         }).toList(),
//                         onChanged: (value) {
//                           setState(() {
//                             _selectedDeliveryBoy = value;
//                             selectedBoy = value;
//                           });
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: const Text('Cancel'),
//               ),
//               ElevatedButton(
//                 onPressed: () {
//                   if (_selectedDeliveryBoy != null) {
//                     Navigator.pop(context);
//                   } else {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(
//                         content: Text('Please select a delivery boy'),
//                       ),
//                     );
//                   }
//                 },
//                 child: const Text('Continue'),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.blue,
//                   foregroundColor: Colors.white,
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//
//     return selectedBoy;
//   }
//
//   Future<void> _acceptReadyOrder(Map<String, dynamic> order, int index) async {
//     final orderId = order['orderId'].toString();
//     final orderNumber = order['orderId'] ?? 'N/A';
//
//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Accept Delivery Order?'),
//         content: Text('Accept Order #$orderNumber for delivery?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () => Navigator.pop(context, true),
//             child: const Text('Accept'),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.blue,
//               foregroundColor: Colors.white,
//             ),
//           ),
//         ],
//       ),
//     );
//
//     if (confirmed != true) return;
//
//     setState(() {
//       _acceptingOrders[orderId] = true;
//     });
//
//     try {
//       final result = await DeliveryAuthService.acceptReadyOrder(orderId);
//
//       if (result['success'] == true && mounted) {
//         _showSuccess('✅ Order #$orderNumber accepted for delivery!');
//
//         setState(() {
//           _orders[index]['status'] = 'WAITING_FOR_PICKUP';
//         });
//
//         await Future.delayed(const Duration(seconds: 1));
//         await _fetchOrders();
//       } else if (mounted) {
//         final error = result['error'] ?? 'Unknown error';
//         _showError('❌ Failed to accept order: $error');
//       }
//     } catch (e) {
//       if (mounted) {
//         _showError('❌ Error accepting order: $e');
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           _acceptingOrders.remove(orderId);
//         });
//       }
//     }
//   }
//
//   Future<void> _showOTPForVendorAndStartDelivery(
//     Map<String, dynamic> order,
//     int index,
//   ) async {
//     final orderId = order['orderId'].toString();
//     final orderNumber = order['orderId'] ?? 'N/A';
//     final customerName =
//         order['deliveryUserName'] ?? order['userName'] ?? 'Customer';
//
//     String? selectedDeliveryBoy = await _showDeliveryBoySelectionDialog(
//       orderId,
//       orderNumber,
//       customerName,
//     );
//
//     if (selectedDeliveryBoy == null) {
//       return;
//     }
//
//     setState(() {
//       _acceptingOrders[orderId] = true;
//     });
//
//     try {
//       final orderDetails = await DeliveryAuthService.getOrderDetailsWithOTP(
//         orderId,
//       );
//
//       if (orderDetails['success'] == true && mounted) {
//         final vendorOtpRaw = orderDetails['vendorOtpRaw'];
//         final vendorOtpStr = orderDetails['vendorOtp']?.toString() ?? '0';
//         final hasOtp = orderDetails['hasOtp'] == true;
//
//         print(
//           '🔍 OTP Check - Raw: $vendorOtpRaw, Type: ${vendorOtpRaw?.runtimeType}',
//         );
//         print('🔍 OTP Check - String: $vendorOtpStr, hasOtp: $hasOtp');
//
//         final proceedToManualEntry = await showDialog<bool>(
//           context: context,
//           builder: (context) => AlertDialog(
//             title: Row(
//               children: [
//                 const Icon(Icons.restaurant, color: Colors.blue),
//                 SizedBox(width: 8.w),
//                 Text('Order #$orderNumber - Customer OTP'),
//               ],
//             ),
//             content: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Customer: $customerName',
//                   style: const TextStyle(fontWeight: FontWeight.w500),
//                 ),
//                 SizedBox(height: 4.h),
//                 Text(
//                   'Assigned to: $selectedDeliveryBoy',
//                   style: TextStyle(color: Colors.grey[600]),
//                 ),
//                 SizedBox(height: 20.h),
//
//                 if (hasOtp && vendorOtpStr != '0' && vendorOtpStr != 'null')
//                   Container(
//                     padding: EdgeInsets.all(16.r),
//                     decoration: BoxDecoration(
//                       color: Colors.blue[50],
//                       borderRadius: BorderRadius.circular(12.r),
//                       border: Border.all(color: Colors.blue, width: 2),
//                     ),
//                     child: Column(
//                       children: [
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(
//                               Icons.share,
//                               size: 16.sp,
//                               color: Colors.blue[700],
//                             ),
//                             SizedBox(width: 6.w),
//                             Text(
//                               'Share with Delivery Boy',
//                               style: TextStyle(
//                                 fontSize: 14.sp,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.blue[800],
//                               ),
//                             ),
//                           ],
//                         ),
//                         SizedBox(height: 16.h),
//                         Text(
//                           vendorOtpStr,
//                           style: TextStyle(
//                             fontSize: 42.sp,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.blue[900],
//                           ),
//                         ),
//                         SizedBox(height: 12.h),
//                         Container(
//                           padding: EdgeInsets.all(8.r),
//                           decoration: BoxDecoration(
//                             color: Colors.yellow[50],
//                             borderRadius: BorderRadius.circular(8.r),
//                           ),
//                           child: Row(
//                             children: [
//                               Icon(
//                                 Icons.info_outline,
//                                 size: 16.sp,
//                                 color: Colors.orange[700],
//                               ),
//                               SizedBox(width: 8.w),
//                               Expanded(
//                                 child: Text(
//                                   'Give this OTP to delivery boy for customer verification',
//                                   style: TextStyle(
//                                     fontSize: 12.sp,
//                                     color: Colors.orange[800],
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   )
//                 else
//                   Column(
//                     children: [
//                       Icon(Icons.warning, size: 48.sp, color: Colors.orange),
//                       SizedBox(height: 16.h),
//                       Text(
//                         'No OTP available for this order',
//                         style: TextStyle(
//                           fontSize: 16.sp,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                       SizedBox(height: 8.h),
//                       Text(
//                         'Please contact customer for OTP',
//                         style: TextStyle(fontSize: 12.sp, color: Colors.grey),
//                       ),
//                     ],
//                   ),
//
//                 SizedBox(height: 20.h),
//                 Text(
//                   'Delivery boy will enter OTP manually',
//                   style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
//                 ),
//               ],
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () {
//                   setState(() {
//                     _acceptingOrders.remove(orderId);
//                   });
//                   Navigator.pop(context, false);
//                 },
//                 child: const Text('Cancel'),
//               ),
//               ElevatedButton(
//                 onPressed: () => Navigator.pop(context, true),
//                 child: const Text('Continue to OTP Entry'),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.blue,
//                   foregroundColor: Colors.white,
//                 ),
//               ),
//             ],
//           ),
//         );
//
//         if (proceedToManualEntry != true) {
//           setState(() {
//             _acceptingOrders.remove(orderId);
//           });
//           return;
//         }
//
//         await _showManualOTPDialog(order, index, selectedDeliveryBoy);
//       } else if (mounted) {
//         final error = orderDetails['error'] ?? 'Failed to fetch OTP';
//         print('⚠️ OTP fetch failed: $error');
//
//         setState(() {
//           _acceptingOrders.remove(orderId);
//         });
//
//         await _showManualOTPDialog(order, index, selectedDeliveryBoy);
//       }
//     } catch (e) {
//       print('❌ Error in _showOTPForVendorAndStartDelivery: $e');
//       if (mounted) {
//         _showError('❌ Error: ${e.toString()}');
//         setState(() {
//           _acceptingOrders.remove(orderId);
//         });
//       }
//     } finally {
//       if (mounted && _acceptingOrders.containsKey(orderId)) {
//         setState(() {
//           _acceptingOrders.remove(orderId);
//         });
//       }
//     }
//   }
//
//   Future<void> _showManualOTPDialog(
//     Map<String, dynamic> order,
//     int index,
//     String deliveryBoyName,
//   ) async {
//     final orderId = order['orderId'].toString();
//     final orderNumber = order['orderId'] ?? 'N/A';
//     final customerName =
//         order['deliveryUserName'] ?? order['userName'] ?? 'Customer';
//
//     if (!_otpControllers.containsKey(orderId)) {
//       _otpControllers[orderId] = TextEditingController();
//     }
//
//     await showDialog(
//       context: context,
//       builder: (context) => StatefulBuilder(
//         builder: (context, setState) {
//           return AlertDialog(
//             title: Row(
//               children: [
//                 const Icon(Icons.directions_bike, color: Colors.green),
//                 SizedBox(width: 8.w),
//                 Text('Order #$orderNumber - Enter OTP'),
//               ],
//             ),
//             content: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Delivery Boy: $deliveryBoyName',
//                   style: const TextStyle(fontWeight: FontWeight.w500),
//                 ),
//                 SizedBox(height: 4.h),
//                 Text(
//                   'Customer: $customerName',
//                   style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
//                 ),
//                 SizedBox(height: 20.h),
//
//                 Container(
//                   padding: EdgeInsets.all(12.r),
//                   decoration: BoxDecoration(
//                     color: Colors.grey[50],
//                     borderRadius: BorderRadius.circular(8.r),
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           Icon(Icons.vpn_key, size: 16.sp, color: Colors.green),
//                           SizedBox(width: 6.w),
//                           Text(
//                             'Enter OTP from Vendor:',
//                             style: const TextStyle(fontWeight: FontWeight.w500),
//                           ),
//                         ],
//                       ),
//                       SizedBox(height: 12.h),
//                       TextFormField(
//                         controller: _otpControllers[orderId],
//                         decoration: InputDecoration(
//                           border: const OutlineInputBorder(),
//                           hintText: 'Enter 4-digit OTP',
//                           prefixIcon: const Icon(Icons.confirmation_number),
//                           suffixIcon: IconButton(
//                             icon: const Icon(Icons.clear),
//                             onPressed: () => _otpControllers[orderId]?.clear(),
//                           ),
//                           counterText: '',
//                         ),
//                         keyboardType: TextInputType.number,
//                         maxLength: 4,
//                         textInputAction: TextInputAction.done,
//                         autofocus: true,
//                       ),
//                       SizedBox(height: 8.h),
//                       Text(
//                         'Enter the OTP provided by the vendor',
//                         style: TextStyle(fontSize: 11.sp, color: Colors.grey),
//                       ),
//                     ],
//                   ),
//                 ),
//                 SizedBox(height: 16.h),
//
//                 if (_otpControllers[orderId]?.text.isNotEmpty == true)
//                   Container(
//                     padding: EdgeInsets.all(12.r),
//                     decoration: BoxDecoration(
//                       color: Colors.green[50],
//                       borderRadius: BorderRadius.circular(8.r),
//                     ),
//                     child: Row(
//                       children: [
//                         const Icon(
//                           Icons.check_circle,
//                           color: Colors.green,
//                           size: 16,
//                         ),
//                         SizedBox(width: 8.w),
//                         Expanded(
//                           child: Text(
//                             'Ready to start delivery. OTP will be verified with customer.',
//                             style: TextStyle(
//                               fontSize: 12.sp,
//                               color: Colors.green[800],
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//               ],
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () {
//                   _otpControllers[orderId]?.clear();
//                   Navigator.pop(context);
//                 },
//                 child: const Text('Cancel'),
//               ),
//               ElevatedButton.icon(
//                 onPressed: () async {
//                   final otp = _otpControllers[orderId]?.text ?? '';
//
//                   if (otp.isEmpty || otp.length != 4) {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(
//                         content: Text('Please enter a valid 4-digit OTP'),
//                       ),
//                     );
//                     return;
//                   }
//
//                   Navigator.pop(context);
//
//                   setState(() {
//                     _acceptingOrders[orderId] = true;
//                   });
//
//                   try {
//                     final deliveryBoyId =
//                         _deliveryBoyIds[deliveryBoyName] ?? deliveryBoyName;
//                     final result = await DeliveryAuthService.acceptPickupOrder(
//                       orderId,
//                       otp,
//                       deliveryBoyId,
//                     );
//
//                     if (result['success'] == true && mounted) {
//                       _showSuccess(
//                         '✅ Order #$orderNumber assigned to $deliveryBoyName! Delivery started.',
//                       );
//
//                       setState(() {
//                         _orders[index]['status'] = 'ON_THE_WAY';
//                       });
//
//                       await Future.delayed(const Duration(seconds: 1));
//                       await _fetchOrders();
//                     } else if (mounted) {
//                       final error = result['error'] ?? 'Unknown error';
//                       _showError('❌ Failed to start delivery: $error');
//                     }
//                   } catch (e) {
//                     if (mounted) {
//                       _showError('❌ Error: $e');
//                     }
//                   } finally {
//                     if (mounted) {
//                       setState(() {
//                         _acceptingOrders.remove(orderId);
//                         _otpControllers[orderId]?.clear();
//                       });
//                     }
//                   }
//                 },
//                 icon: const Icon(Icons.directions_bike, size: 18),
//                 label: const Text('Start Delivery'),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.green,
//                   foregroundColor: Colors.white,
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           "Delivery Management",
//           style: TextStyle(fontWeight: FontWeight.w600),
//         ),
//         // actions: [
//         //   IconButton(
//         //     icon: const Icon(Icons.refresh),
//         //     onPressed: _fetchOrders,
//         //     tooltip: 'Refresh orders',
//         //   ),
//         // ],
//       ),
//       body: Column(
//         children: [
//           Container(
//             padding: EdgeInsets.all(8.r),
//             color: Colors.white,
//             child: Row(
//               children: _tabTitles.map((title) {
//                 final index = _tabTitles.indexOf(title);
//                 final isSelected = _selectedTab == index;
//                 return Expanded(
//                   child: GestureDetector(
//                     onTap: () => setState(() => _selectedTab = index),
//                     child: Container(
//                       padding: EdgeInsets.symmetric(vertical: 12.r),
//                       decoration: BoxDecoration(
//                         color: isSelected ? Colors.blue : Colors.transparent,
//                         borderRadius: BorderRadius.circular(8.r),
//                         border: isSelected
//                             ? null
//                             : Border.all(color: Colors.grey[300]!),
//                       ),
//                       child: Center(
//                         child: Text(
//                           title,
//                           style: TextStyle(
//                             fontSize: 13.sp,
//                             color: isSelected ? Colors.white : Colors.grey[700],
//                             fontWeight: FontWeight.w500,
//                           ),
//                           overflow: TextOverflow.ellipsis,
//                           maxLines: 1,
//                         ),
//                       ),
//                     ),
//                   ),
//                 );
//               }).toList(),
//             ),
//           ),
//
//           Expanded(child: _buildMainContent()),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildMainContent() {
//     if (_isLoading) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const CircularProgressIndicator(),
//             SizedBox(height: 16.h),
//             Text(
//               'Loading orders...',
//               style: TextStyle(color: Colors.grey[600]),
//             ),
//           ],
//         ),
//       );
//     }
//
//     return _selectedTab == 0 ? _buildDeliveryOrders() : _buildTrackingOrders();
//   }
//
//   Widget _buildDeliveryOrders() {
//     final deliveryOrders =
//         _orders
//             .where(
//               (order) =>
//                   DeliveryAuthService.isReadyOrder(order['status'] ?? ''),
//             )
//             .toList()
//           ..sort((a, b) {
//             final dateA = DateTime.tryParse(a['orderDateAndTime'] ?? '');
//             final dateB = DateTime.tryParse(b['orderDateAndTime'] ?? '');
//             return (dateA ?? DateTime.now()).compareTo(dateB ?? DateTime.now());
//           });
//
//     if (deliveryOrders.isEmpty) {
//       return _buildEmptyState(
//         'No delivery orders ready',
//         Icons.restaurant,
//         'Orders with status "ORDER_IS_READY" will appear here',
//       );
//     }
//
//     return RefreshIndicator(
//       onRefresh: _fetchOrders,
//       child: ListView.builder(
//         padding: EdgeInsets.all(16.r),
//         itemCount: deliveryOrders.length,
//         itemBuilder: (context, index) {
//           return _buildDeliveryOrderCard(deliveryOrders[index], index);
//         },
//       ),
//     );
//   }
//
//   Widget _buildTrackingOrders() {
//     final trackingOrders =
//         _orders.where((order) {
//           final status = order['status'] ?? '';
//           return DeliveryAuthService.isWaitingForPickup(status) ||
//               DeliveryAuthService.isOnTheWay(status);
//         }).toList()..sort((a, b) {
//           final dateA = DateTime.tryParse(a['orderDateAndTime'] ?? '');
//           final dateB = DateTime.tryParse(b['orderDateAndTime'] ?? '');
//           return (dateA ?? DateTime.now()).compareTo(dateB ?? DateTime.now());
//         });
//
//     if (trackingOrders.isEmpty) {
//       return _buildEmptyState(
//         'No orders in tracking',
//         Icons.track_changes,
//         'Accepted orders will appear here',
//       );
//     }
//
//     return RefreshIndicator(
//       onRefresh: _fetchOrders,
//       child: ListView(
//         padding: EdgeInsets.all(16.r),
//         children: [
//           ...trackingOrders
//               .where(
//                 (order) => DeliveryAuthService.isWaitingForPickup(
//                   order['status'] ?? '',
//                 ),
//               )
//               .map((order) {
//                 final index = _orders.indexOf(order);
//                 return _buildTrackingOrderCard(
//                   order,
//                   index,
//                   showStartButton: true,
//                 );
//               })
//               .toList(),
//
//           ...trackingOrders
//               .where(
//                 (order) =>
//                     DeliveryAuthService.isOnTheWay(order['status'] ?? ''),
//               )
//               .map((order) {
//                 final index = _orders.indexOf(order);
//                 return _buildTrackingOrderCard(
//                   order,
//                   index,
//                   showStartButton: false,
//                 );
//               })
//               .toList(),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildDeliveryOrderCard(Map<String, dynamic> order, int index) {
//     return _buildOrderCardTemplate(
//       order: order,
//       index: index,
//       showActionButton: true,
//       buttonText: 'Accept for Delivery',
//       buttonColor: Colors.blue,
//       onButtonPressed: () => _acceptReadyOrder(order, index),
//     );
//   }
//
//   Widget _buildTrackingOrderCard(
//     Map<String, dynamic> order,
//     int index, {
//     required bool showStartButton,
//   }) {
//     final status = order['status'] ?? '';
//     final isWaiting = DeliveryAuthService.isWaitingForPickup(status);
//
//     return _buildOrderCardTemplate(
//       order: order,
//       index: index,
//       showActionButton: showStartButton && isWaiting,
//       buttonText: 'Start Delivery',
//       buttonColor: Colors.green,
//       onButtonPressed: () => _showOTPForVendorAndStartDelivery(order, index),
//     );
//   }
//
//   Widget _buildOrderCardTemplate({
//     required Map<String, dynamic> order,
//     required int index,
//     required bool showActionButton,
//     required String buttonText,
//     required Color buttonColor,
//     required Function() onButtonPressed,
//   }) {
//     final status = order['status'] ?? '';
//     final orderId = order['orderId'] ?? 'N/A';
//     final customerName =
//         order['deliveryUserName'] ?? order['userName'] ?? 'Customer';
//     final address = order['deliveryAddress'] ?? 'No address';
//     final phone = order['mobileNo'] ?? 'No phone';
//     final totalAmount = order['totalAmount'] ?? 0.0;
//     final orderDate = order['orderDateAndTime'] ?? '';
//     final items = order['order'] ?? [];
//     final isAccepting = _acceptingOrders[orderId.toString()] ?? false;
//
//     final formattedDate = orderDate.isNotEmpty
//         ? DateFormat(
//             'dd MMM, hh:mm a',
//           ).format(DateTime.tryParse(orderDate) ?? DateTime.now())
//         : 'N/A';
//
//     return Card(
//       margin: EdgeInsets.only(bottom: 16.r),
//       elevation: 3,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
//       child: Padding(
//         padding: EdgeInsets.all(16.r),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Flexible(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Order #$orderId',
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 16.sp,
//                         ),
//                         overflow: TextOverflow.ellipsis,
//                         maxLines: 1,
//                       ),
//                       SizedBox(height: 2.h),
//                       Text(
//                         formattedDate,
//                         style: TextStyle(
//                           fontSize: 11.sp,
//                           color: Colors.grey[600],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 SizedBox(width: 8.w),
//                 _buildStatusChip(status),
//               ],
//             ),
//
//             SizedBox(height: 12.h),
//
//             Row(
//               children: [
//                 Container(
//                   width: 28.r,
//                   height: 28.r,
//                   decoration: BoxDecoration(
//                     color: Colors.blue[100],
//                     borderRadius: BorderRadius.circular(14.r),
//                   ),
//                   child: Icon(Icons.person, size: 16.sp, color: Colors.blue),
//                 ),
//                 SizedBox(width: 8.w),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         customerName,
//                         style: TextStyle(
//                           fontSize: 14.sp,
//                           fontWeight: FontWeight.w500,
//                         ),
//                         overflow: TextOverflow.ellipsis,
//                         maxLines: 1,
//                       ),
//                       Text(
//                         phone,
//                         style: TextStyle(
//                           fontSize: 12.sp,
//                           color: Colors.grey[600],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//
//             SizedBox(height: 8.h),
//
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Container(
//                   width: 28.r,
//                   height: 28.r,
//                   decoration: BoxDecoration(
//                     color: Colors.red[100],
//                     borderRadius: BorderRadius.circular(14.r),
//                   ),
//                   child: Icon(
//                     Icons.location_on,
//                     size: 16.sp,
//                     color: Colors.red[400],
//                   ),
//                 ),
//                 SizedBox(width: 8.w),
//                 Expanded(
//                   child: Text(
//                     address,
//                     style: TextStyle(fontSize: 13.sp, color: Colors.grey[700]),
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//               ],
//             ),
//
//             SizedBox(height: 12.h),
//
//             Container(
//               padding: EdgeInsets.all(12.r),
//               decoration: BoxDecoration(
//                 color: Colors.grey[50],
//                 borderRadius: BorderRadius.circular(8.r),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         'Order Items:',
//                         style: TextStyle(
//                           fontWeight: FontWeight.w500,
//                           fontSize: 13.sp,
//                         ),
//                       ),
//                       Text(
//                         '₹${totalAmount.toStringAsFixed(2)}',
//                         style: TextStyle(
//                           fontSize: 16.sp,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.green[700],
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: 8.h),
//                   ...items.take(2).map<Widget>((item) {
//                     final itemName = item['dishName'] ?? 'Item';
//                     final quantity = item['quantity'] ?? 1;
//
//                     return Padding(
//                       padding: EdgeInsets.only(bottom: 4.h),
//                       child: Text(
//                         '• $itemName x $quantity',
//                         style: TextStyle(
//                           fontSize: 12.sp,
//                           color: Colors.grey[600],
//                         ),
//                       ),
//                     );
//                   }).toList(),
//                   if (items.length > 2) ...[
//                     Text(
//                       '+ ${items.length - 2} more items',
//                       style: TextStyle(
//                         fontSize: 11.sp,
//                         color: Colors.grey[500],
//                       ),
//                     ),
//                   ],
//                 ],
//               ),
//             ),
//
//             SizedBox(height: 12.h),
//
//             if (showActionButton)
//               Row(
//                 children: [
//                   Expanded(
//                     child: Column(
//                       children: [
//                         // Show OTP if available and order is waiting for pickup
//                         if (status.toUpperCase() == 'WAITING_FOR_PICKUP')
//                           FutureBuilder<Map<String, dynamic>>(
//                             future: DeliveryAuthService.getOrderDetailsWithOTP(
//                               order['orderId'].toString(),
//                             ),
//                             builder: (context, snapshot) {
//                               if (snapshot.connectionState ==
//                                   ConnectionState.waiting) {
//                                 return Padding(
//                                   padding: EdgeInsets.only(bottom: 8.h),
//                                   child: Row(
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: [
//                                       SizedBox(
//                                         width: 16.w,
//                                         height: 16.h,
//                                         child: CircularProgressIndicator(
//                                           strokeWidth: 2,
//                                         ),
//                                       ),
//                                       SizedBox(width: 8.w),
//                                       Text(
//                                         'Fetching OTP...',
//                                         style: TextStyle(
//                                           fontSize: 12.sp,
//                                           color: Colors.blue,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 );
//                               }
//
//                               if (snapshot.hasData &&
//                                   snapshot.data!['success'] == true) {
//                                 final vendorOtp =
//                                     snapshot.data!['vendorOtp'] ?? '';
//                                 final hasOtp =
//                                     vendorOtp.isNotEmpty &&
//                                     vendorOtp != '0' &&
//                                     vendorOtp != 'null';
//
//                                 if (hasOtp) {
//                                   return Padding(
//                                     padding: EdgeInsets.only(bottom: 8.h),
//                                     child: Column(
//                                       children: [
//                                         Text(
//                                           'Customer OTP',
//                                           style: TextStyle(
//                                             fontSize: 11.sp,
//                                             color: Colors.grey[600],
//                                             fontWeight: FontWeight.w500,
//                                           ),
//                                         ),
//                                         SizedBox(height: 4.h),
//                                         Container(
//                                           padding: EdgeInsets.symmetric(
//                                             horizontal: 12.w,
//                                             vertical: 6.h,
//                                           ),
//                                           decoration: BoxDecoration(
//                                             color: Colors.blue[50],
//                                             borderRadius: BorderRadius.circular(
//                                               8.r,
//                                             ),
//                                             border: Border.all(
//                                               color: Colors.blue[200]!,
//                                             ),
//                                           ),
//                                           child: Row(
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.center,
//                                             children: [
//                                               Icon(
//                                                 Icons.vpn_key,
//                                                 size: 14.sp,
//                                                 color: Colors.blue,
//                                               ),
//                                               SizedBox(width: 6.w),
//                                               Text(
//                                                 vendorOtp,
//                                                 style: TextStyle(
//                                                   fontSize: 16.sp,
//                                                   fontWeight: FontWeight.bold,
//                                                   color: Colors.blue[800],
//                                                   letterSpacing: 2.w,
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                         SizedBox(height: 4.h),
//                                         Text(
//                                           'Share with delivery boy',
//                                           style: TextStyle(
//                                             fontSize: 10.sp,
//                                             color: Colors.grey[500],
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   );
//                                 }
//                               }
//
//                               // Return empty container if no OTP or error
//                               return SizedBox(height: 4.h);
//                             },
//                           ),
//
//                         // Action button
//                         ElevatedButton.icon(
//                           onPressed: isAccepting ? null : onButtonPressed,
//                           icon: isAccepting
//                               ? SizedBox(
//                                   width: 16.w,
//                                   height: 16.h,
//                                   child: CircularProgressIndicator(
//                                     strokeWidth: 2,
//                                     valueColor:
//                                         const AlwaysStoppedAnimation<Color>(
//                                           Colors.white,
//                                         ),
//                                   ),
//                                 )
//                               : Icon(
//                                   buttonText.contains('Start')
//                                       ? Icons.directions_bike
//                                       : Icons.check,
//                                   size: 18.sp,
//                                 ),
//                           label: Text(
//                             isAccepting ? 'Processing...' : buttonText,
//                             style: TextStyle(
//                               fontSize: 14.sp,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: buttonColor,
//                             foregroundColor: Colors.white,
//                             padding: EdgeInsets.symmetric(vertical: 14.h),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(10.r),
//                             ),
//                             elevation: 2,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildStatusChip(String status) {
//     final statusColor = DeliveryAuthService.getStatusColor(status);
//     final statusLabel = DeliveryAuthService.getStatusDisplayName(status);
//     final statusIcon = DeliveryAuthService.getStatusIcon(status);
//
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
//       decoration: BoxDecoration(
//         color: statusColor.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(20.r),
//         border: Border.all(color: statusColor, width: 1.5),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(statusIcon, size: 12.sp, color: statusColor),
//           SizedBox(width: 6.w),
//           Flexible(
//             child: Text(
//               statusLabel,
//               style: TextStyle(
//                 fontSize: 11.sp,
//                 color: statusColor,
//                 fontWeight: FontWeight.w600,
//               ),
//               overflow: TextOverflow.ellipsis,
//               maxLines: 1,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildEmptyState(String title, IconData icon, String subtitle) {
//     return Center(
//       child: Padding(
//         padding: EdgeInsets.all(32.r),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               padding: EdgeInsets.all(20.r),
//               decoration: BoxDecoration(
//                 color: Colors.grey[100],
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(icon, size: 48.sp, color: Colors.grey[400]),
//             ),
//             SizedBox(height: 20.h),
//             Text(
//               title,
//               style: TextStyle(
//                 fontSize: 18.sp,
//                 color: Colors.grey[600],
//                 fontWeight: FontWeight.w600,
//               ),
//               textAlign: TextAlign.center,
//             ),
//             SizedBox(height: 8.h),
//             Text(
//               subtitle,
//               style: TextStyle(fontSize: 14.sp, color: Colors.grey[500]),
//               textAlign: TextAlign.center,
//             ),
//             SizedBox(height: 20.h),
//             ElevatedButton.icon(
//               onPressed: _fetchOrders,
//               icon: const Icon(Icons.refresh),
//               label: const Text('Refresh'),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.blue,
//                 foregroundColor: Colors.white,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../Api/DeliveryServices.dart';

// ─── Design tokens (match _O in Order_management) ─────────────────────────────
const _accent = Color(0xFFE66D33);
const _green = Color(0xFF10B981);
const _amber = Color(0xFFF59E0B);
const _red = Color(0xFFEF4444);
const _blue = Color(0xFFE66D33); // reusing accent per _O.blue = accent
const _bg = Color(0xFFF7F8FC);
const _white = Color(0xFFFFFFFF);
const _border = Color(0xFFEEEFF5);
const _text1 = Color(0xFF111827);
const _text2 = Color(0xFF6B7280);
const _text3 = Color(0xFFB0B3C1);

// ─── DeliveryOtpCard ──────────────────────────────────────────────────────────
// class DeliveryOtpCard extends StatefulWidget {
//   final int orderId;
//   const DeliveryOtpCard({super.key, required this.orderId});
//
//   @override
//   State<DeliveryOtpCard> createState() => _DeliveryOtpCardState();
// }
//
// class _DeliveryOtpCardState extends State<DeliveryOtpCard> {
//   DeliveryOrder? _data;
//   bool _loading = true;
//   bool _hasError = false;
//   bool _isExpanded = false; // Add this state variable
//
//   @override
//   void initState() {
//     super.initState();
//     _fetch();
//   }
//
//   Future<void> _fetch() async {
//     setState(() {
//       _loading = true;
//       _hasError = false;
//     });
//     try {
//       final d = await DeliveryApi.fetchOrder(widget.orderId);
//       if (mounted)
//         setState(() {
//           _data = d;
//           _loading = false;
//         });
//     } catch (_) {
//       if (mounted)
//         setState(() {
//           _hasError = true;
//           _loading = false;
//         });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (_loading) {
//       return Container(
//         margin: const EdgeInsets.only(top: 12),
//         padding: const EdgeInsets.all(14),
//         decoration: BoxDecoration(
//           color: _bg,
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: _border),
//         ),
//         child: const Row(
//           children: [
//             SizedBox(
//               width: 16,
//               height: 16,
//               child: CircularProgressIndicator(strokeWidth: 2, color: _accent),
//             ),
//             SizedBox(width: 10),
//             Text(
//               'Loading delivery info...',
//               style: TextStyle(fontSize: 12, color: _text2),
//             ),
//           ],
//         ),
//       );
//     }
//
//     if (_hasError || _data == null) {
//       return Container(
//         margin: const EdgeInsets.only(top: 12),
//         padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//         decoration: BoxDecoration(
//           color: _red.withOpacity(0.06),
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: _red.withOpacity(0.2)),
//         ),
//         child: Row(
//           children: [
//             const Icon(Icons.info_outline, size: 14, color: _red),
//             const SizedBox(width: 8),
//             const Expanded(
//               child: Text(
//                 'Delivery details not available yet',
//                 style: TextStyle(fontSize: 12, color: _text2),
//               ),
//             ),
//             GestureDetector(
//               onTap: _fetch,
//               child: const Icon(Icons.refresh, size: 16, color: _accent),
//             ),
//           ],
//         ),
//       );
//     }
//
//     final d = _data!;
//
//     return Container(
//       margin: const EdgeInsets.only(top: 12),
//       decoration: BoxDecoration(
//         color: _white,
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(color: _amber.withOpacity(0.35), width: 1.5),
//         boxShadow: [BoxShadow(color: _amber.withOpacity(0.08), blurRadius: 10)],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // ── Header with Expand/Collapse Icon ──────────────────────────────────
//           GestureDetector(
//             onTap: () {
//               setState(() {
//                 _isExpanded = !_isExpanded;
//               });
//             },
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//               decoration: BoxDecoration(
//                 color: _amber.withOpacity(0.1),
//                 borderRadius: const BorderRadius.vertical(
//                   top: Radius.circular(13),
//                 ),
//               ),
//               child: Row(
//                 children: [
//                   const Icon(
//                     Icons.local_shipping_rounded,
//                     size: 16,
//                     color: _amber,
//                   ),
//                   const SizedBox(width: 8),
//                   const Expanded(
//                     child: Text(
//                       'Delivery Opt',
//                       style: TextStyle(
//                         fontSize: 13,
//                         fontWeight: FontWeight.w800,
//                         color: _text1,
//                       ),
//                     ),
//                   ),
//                   // Expand/Collapse Icon
//                   Icon(
//                     _isExpanded
//                         ? Icons.keyboard_arrow_up_rounded
//                         : Icons.keyboard_arrow_down_rounded,
//                     size: 20,
//                     color: _text2,
//                   ),
//                 ],
//               ),
//             ),
//           ),
//
//           // ── Expandable Content ──────────────────────────────────────────────
//           AnimatedCrossFade(
//             duration: const Duration(milliseconds: 300),
//             crossFadeState: _isExpanded
//                 ? CrossFadeState.showFirst
//                 : CrossFadeState.showSecond,
//             firstChild: Padding(
//               padding: const EdgeInsets.all(14),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // ── OTP Section ─────────────────────────────────────────────────
//                   Row(
//                     children: [
//                       Expanded(
//                         child: _OtpBox(
//                           otp: d.hasVendorOtp ? d.vendorOtp.toString() : '----',
//                           hasOtp: d.hasVendorOtp,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height:3),
//
//
//                   // ── Delivery partner info ─────────────────────────────────────
//                   // Commented out the delivery partner info section
//                   /*
//                   if (d.hasPartner) ...[
//                     Container(
//                       padding: const EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                         color: _bg,
//                         borderRadius: BorderRadius.circular(10),
//                         border: Border.all(color: _border),
//                       ),
//                       child: Column(
//                         children: [
//                           // Partner name + vehicle
//                           Row(
//                             children: [
//                               Container(
//                                 width: 36,
//                                 height: 36,
//                                 decoration: BoxDecoration(
//                                   color: _blue.withOpacity(0.1),
//                                   borderRadius: BorderRadius.circular(10),
//                                 ),
//                                 child: const Icon(
//                                   Icons.delivery_dining_rounded,
//                                   size: 18,
//                                   color: _blue,
//                                 ),
//                               ),
//                               const SizedBox(width: 10),
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       d.deliveryPartnerName ??
//                                           'Partner Assigned',
//                                       style: const TextStyle(
//                                         fontSize: 13,
//                                         fontWeight: FontWeight.w700,
//                                         color: _text1,
//                                       ),
//                                     ),
//                                     Text(
//                                       _vehicleLabel(d.vehicleStatus),
//                                       style: const TextStyle(
//                                         fontSize: 11,
//                                         color: _text2,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               // Status badge
//                               _StatusBadge(status: d.status),
//                             ],
//                           ),
//
//                           const SizedBox(height: 10),
//                           const Divider(color: _border, height: 1),
//                           const SizedBox(height: 10),
//
//                           // Delivery address
//                           Row(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               const Icon(
//                                 Icons.location_on_rounded,
//                                 size: 14,
//                                 color: _red,
//                               ),
//                               const SizedBox(width: 6),
//                               Expanded(
//                                 child: Text(
//                                   d.deliveryAddress,
//                                   style: const TextStyle(
//                                     fontSize: 12,
//                                     color: _text2,
//                                   ),
//                                   maxLines: 3,
//                                   overflow: TextOverflow.ellipsis,
//                                 ),
//                               ),
//                             ],
//                           ),
//
//                           const SizedBox(height: 8),
//
//                           // Customer name + phone
//                           Row(
//                             children: [
//                               const Icon(
//                                 Icons.person_outline_rounded,
//                                 size: 14,
//                                 color: _text3,
//                               ),
//                               const SizedBox(width: 6),
//                               Expanded(
//                                 child: Text(
//                                   '${d.userName}  ·  ${d.userPhone}',
//                                   style: const TextStyle(
//                                     fontSize: 12,
//                                     color: _text2,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ] else ...[
//                     // No partner yet
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 12,
//                         vertical: 10,
//                       ),
//                       decoration: BoxDecoration(
//                         color: _amber.withOpacity(0.07),
//                         borderRadius: BorderRadius.circular(10),
//                         border: Border.all(color: _amber.withOpacity(0.25)),
//                       ),
//                       child: const Row(
//                         children: [
//                           Icon(
//                             Icons.hourglass_top_rounded,
//                             size: 14,
//                             color: _amber,
//                           ),
//                           SizedBox(width: 8),
//                           Expanded(
//                             child: Text(
//                               'Waiting for delivery partner to accept',
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 color: _amber,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                   */
//                 ],
//               ),
//             ),
//             secondChild:
//             const SizedBox.shrink(), // Collapsed state - show nothing
//           ),
//         ],
//       ),
//     );
//   }
//
//   String _vehicleLabel(String? v) {
//     switch (v) {
//       case 'TWO_WHEELER':
//         return '🛵 Two Wheeler';
//       case 'THREE_WHEELER':
//         return '🛺 Three Wheeler';
//       case 'FOUR_WHEELER':
//         return '🚗 Four Wheeler';
//       default:
//         return v?.replaceAll('_', ' ') ?? 'Vehicle';
//     }
//   }
// }
// class DeliveryOtpCard extends StatefulWidget {
//   final int orderId;
//   const DeliveryOtpCard({super.key, required this.orderId});
//
//   @override
//   State<DeliveryOtpCard> createState() => _DeliveryOtpCardState();
// }
//
// class _DeliveryOtpCardState extends State<DeliveryOtpCard> {
//   DeliveryOrder? _data;
//   bool _loading = true;
//   bool _hasError = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _fetch();
//   }
//
//   Future<void> _fetch() async {
//     setState(() {
//       _loading = true;
//       _hasError = false;
//     });
//     try {
//       final d = await DeliveryApi.fetchOrder(widget.orderId);
//       if (mounted)
//         setState(() {
//           _data = d;
//           _loading = false;
//         });
//     } catch (_) {
//       if (mounted)
//         setState(() {
//           _hasError = true;
//           _loading = false;
//         });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (_loading) {
//       return Container(
//         margin: const EdgeInsets.only(top: 12),
//         padding: const EdgeInsets.all(14),
//         decoration: BoxDecoration(
//           color: _bg,
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: _border),
//         ),
//         child: const Row(
//           children: [
//             SizedBox(
//               width: 16,
//               height: 16,
//               child: CircularProgressIndicator(strokeWidth: 2, color: _accent),
//             ),
//             SizedBox(width: 10),
//             Text(
//               'Loading delivery info...',
//               style: TextStyle(fontSize: 12, color: _text2),
//             ),
//           ],
//         ),
//       );
//     }
//
//     if (_hasError || _data == null) {
//       return Container(
//         margin: const EdgeInsets.only(top: 12),
//         padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//         decoration: BoxDecoration(
//           color: _red.withOpacity(0.06),
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: _red.withOpacity(0.2)),
//         ),
//         child: Row(
//           children: [
//             const Icon(Icons.info_outline, size: 14, color: _red),
//             const SizedBox(width: 8),
//             const Expanded(
//               child: Text(
//                 'Delivery details not available yet',
//                 style: TextStyle(fontSize: 12, color: _text2),
//               ),
//             ),
//             GestureDetector(
//               onTap: _fetch,
//               child: const Icon(Icons.refresh, size: 16, color: _accent),
//             ),
//           ],
//         ),
//       );
//     }
//
//     final d = _data!;
//
//     return Container(
//       margin: const EdgeInsets.only(top: 12),
//       decoration: BoxDecoration(
//         color: _white,
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(color: _amber.withOpacity(0.35), width: 1.5),
//         boxShadow: [BoxShadow(color: _amber.withOpacity(0.08), blurRadius: 10)],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // ── Header with OTP beside text ──────────────────────────────────
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//             decoration: BoxDecoration(
//               color: _amber.withOpacity(0.1),
//               borderRadius: const BorderRadius.vertical(
//                 top: Radius.circular(13),
//               ),
//             ),
//             child: Row(
//               children: [
//                 const Icon(
//                   Icons.local_shipping_rounded,
//                   size: 16,
//                   color: _amber,
//                 ),
//                 const SizedBox(width: 8),
//                 const Text(
//                   'Delivery OTP',
//                   style: TextStyle(
//                     fontSize: 13,
//                     fontWeight: FontWeight.w800,
//                     color: _text1,
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 // OTP number beside the text
//                 Text(
//                   d.hasVendorOtp
//                       ? d.vendorOtp.toString().padLeft(3, '0')
//                       : '----',
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w900,
//                     color: Colors.black,
//                     letterSpacing: 1,
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
//   String _vehicleLabel(String? v) {
//     switch (v) {
//       case 'TWO_WHEELER':
//         return '🛵 Two Wheeler';
//       case 'THREE_WHEELER':
//         return '🛺 Three Wheeler';
//       case 'FOUR_WHEELER':
//         return '🚗 Four Wheeler';
//       default:
//         return v?.replaceAll('_', ' ') ?? 'Vehicle';
//     }
//   }
// }
//
// // ─── OTP Box ──────────────────────────────────────────────────────────────────
// class _OtpBox extends StatelessWidget {
//   final String otp;
//   final bool hasOtp;
//
//   const _OtpBox({required this.otp, required this.hasOtp});
//
//   @override
//   Widget build(BuildContext context) => Padding(
//     padding: const EdgeInsets.symmetric(vertical: 0),
//     child: Text(
//       hasOtp ? otp.padLeft(3, '0') : '----',
//       style: const TextStyle(
//         fontSize: 23,
//         fontWeight: FontWeight.w900,
//         color: Colors.black,
//         letterSpacing: 1,
//         height: 0.60,
//       ),
//     ),
//   );
// }
//
// // ─── Status Badge ─────────────────────────────────────────────────────────────
// class _StatusBadge extends StatelessWidget {
//   final String status;
//   const _StatusBadge({required this.status});
//
//   Color get _color {
//     switch (status) {
//       case 'ASSIGNED':
//         return _blue;
//       case 'PICKED_UP':
//         return _amber;
//       case 'DELIVERED':
//         return _green;
//       case 'CANCELLED':
//         return _red;
//       default:
//         return _text2;
//     }
//   }
//
//   String get _label => status.replaceAll('_', ' ');
//
//   @override
//   Widget build(BuildContext context) => Container(
//     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//     decoration: BoxDecoration(
//       color: _color.withOpacity(0.1),
//       borderRadius: BorderRadius.circular(20),
//       border: Border.all(color: _color.withOpacity(0.3)),
//     ),
//     child: Text(
//       _label,
//       style: TextStyle(
//         fontSize: 10,
//         fontWeight: FontWeight.w700,
//         color: _color,
//       ),
//     ),
//   );
// }
class DeliveryOtpCard extends StatefulWidget {
  final int orderId;
  const DeliveryOtpCard({super.key, required this.orderId});

  @override
  State<DeliveryOtpCard> createState() => _DeliveryOtpCardState();
}

class _DeliveryOtpCardState extends State<DeliveryOtpCard> {
  DeliveryOrder? _data;
  bool _loading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() {
      _loading = true;
      _hasError = false;
    });
    try {
      final d = await DeliveryApi.fetchOrder(widget.orderId);
      if (mounted)
        setState(() {
          _data = d;
          _loading = false;
        });
    } catch (_) {
      if (mounted)
        setState(() {
          _hasError = true;
          _loading = false;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Container(
        margin: const EdgeInsets.only(top: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _border),
        ),
        child: const Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: _accent),
            ),
            SizedBox(width: 10),
            Text(
              'Loading delivery info...',
              style: TextStyle(fontSize: 12, color: _text2),
            ),
          ],
        ),
      );
    }

    if (_hasError || _data == null) {
      return Container(
        margin: const EdgeInsets.only(top: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: _red.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _red.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline, size: 14, color: _red),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Delivery details not available yet',
                style: TextStyle(fontSize: 12, color: _text2),
              ),
            ),
            GestureDetector(
              onTap: _fetch,
              child: const Icon(Icons.refresh, size: 16, color: _accent),
            ),
          ],
        ),
      );
    }

    final d = _data!;

    return Container(
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _amber.withOpacity(0.35), width: 1.5),
        boxShadow: [BoxShadow(color: _amber.withOpacity(0.08), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: _amber.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(13),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.local_shipping_rounded, size: 16, color: _amber),
                SizedBox(width: 8),
                Text(
                  'Delivery Details',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: _text1,
                  ),
                ),
              ],
            ),
          ),

          // ── Body with both OTPs ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                // Two OTP boxes side by side
                Row(
                  children: [
                    Expanded(
                      child: _OtpCard(
                        otp: d.hasVendorOtp
                            ? d.vendorOtp.toString().padLeft(3, '0')
                            : '---',
                        hasOtp: d.hasVendorOtp,
                        color: _blue,
                      ),
                    ),
                    const SizedBox(width: 12),

                  ],
                ),

                const SizedBox(height: 12),


              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── OTP Card Widget ──────────────────────────────────────────────────────────
class _OtpCard extends StatelessWidget {
  final String otp;
  final bool hasOtp;
  final Color color;

  const _OtpCard({
    required this.otp,
    required this.hasOtp,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 4,
      ),


      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [

          Text(
            hasOtp ? otp : 'Not available',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: hasOtp ? _text1 : _text3,
              letterSpacing: 2,
              fontFamily: 'monospace',
              height: 1.0,
            ),
          ),

        ],
      ),
    );
  }
}


