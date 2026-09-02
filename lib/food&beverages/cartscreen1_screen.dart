// import 'dart:convert';
// import 'dart:io';
// import 'dart:async';
// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart';
// import 'package:maamaaspartner/Api/food_authservice.dart';
// import 'package:razorpay_flutter/razorpay_flutter.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:qr_flutter/qr_flutter.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:flutter/services.dart';
//
// import '../Models/food&beverages/cart_model.dart';
// import '../widgets_helper/food/footer.dart';
// import 'Invoice.dart';
// import 'Menu_managemnet.dart';
//
// class food_cartScreen extends StatefulWidget {
//   final int? cartId;
//   const food_cartScreen({super.key, this.cartId});
//   @override
//   _food_cartScreenState createState() => _food_cartScreenState();
// }
//
// class _food_cartScreenState extends State<food_cartScreen> {
//   CartModel? cartData;
//   bool isLoading = true;
//   bool isPlacingOrder = false;
//   Map<String, dynamic>? checkoutData;
//   bool couponApplied = false;
//   String selectedPaymentMethod = "";
//   String selectedSubWallet = "";
//   String couponCode = "";
//   bool isServiceChargeApplied = true;
//   bool isExpanded = false;
//   late Razorpay _razorpay;
//   int? appliedCouponId;
//   String? appliedCouponCode;
//   late CartModel? updatedCartData = cartData;
//   DateTime? _selectedDate;
//   TimeOfDay? _selectedTime;
//   String? _email;
//   String? _mobile;
//   double _lastPaidAmount = 0.0;
//
//   // QR Code related variables
//   bool _isGeneratingQr = false;
//   String? _generatedQrData;
//   String? _qrOrderId;
//   String? _qrPaymentId;
//   String? _qrImageUrl;
//   bool _qrPaymentVerified = false;
//   Timer? _qrPollingTimer;
//
//   Map<String, int> cashDenominations = {
//     "oneRupee": 0,
//     "twoRupee": 0,
//     "fiveRupee": 0,
//     "tenRupee": 0,
//     "twentyRupee": 0,
//     "fiftyRupee": 0,
//     "hundredRupee": 0,
//     "twoHundredRupee": 0,
//     "fiveHundredRupee": 0,
//     "twoThousandRupee": 0,
//   };
//   double paidAmount = 0.0;
//   double returnMoney = 0.0;
//   Map<int, int> _availableQuantities = {};
//
//   @override
//   void initState() {
//     super.initState();
//     _razorpay = Razorpay();
//     _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
//     _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
//     _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
//     checkoutData = {
//       'subTotal': 0,
//       'orderType': 'DELIVERY',
//       'packingCharges': 0,
//       'deliveryCharges': 0,
//       'platformCharges': 0,
//       'sgst': 0,
//       'cgst': 0,
//       'grandTotal': 0,
//       'serviceCharges': 0,
//     };
//     _loadCart();
//     _loadAvailableQuantities();
//   }
//
//   @override
//   void dispose() {
//     _razorpay.clear();
//     _qrPollingTimer?.cancel();
//     super.dispose();
//   }
//
//   Future<void> _loadAvailableQuantities() async {
//     try {
//       final dishes = await food_authservice.fetchDishes();
//       setState(() {
//         for (var dish in dishes) {
//           _availableQuantities[dish.dishId] = dish.balanceQuantity;
//         }
//       });
//     } catch (e) {
//       debugPrint("❌ Error loading available quantities: $e");
//     }
//   }
//
//   void _handlePaymentSuccess(PaymentSuccessResponse response) async {
//     debugPrint("✅ Payment Success: ${response.paymentId}");
//
//     final prefs = await SharedPreferences.getInstance();
//     final vendorId = prefs.getInt('vendorId') ?? 0;
//     final paymentId = response.paymentId!;
//     final razorpayOrderId = response.orderId!;
//
//     // Capture payment
//     final bool captured = await food_authservice.capturePayment(
//       paymentId: response.paymentId!,
//       amount: (cartData?.grandTotal ?? 0).toDouble(),
//     );
//
//     if (!captured) {
//       debugPrint("❌ Payment capture failed");
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("❌ Payment capture failed!")),
//       );
//       return;
//     }
//
//     // Place order after payment success
//     final orderId = await _callOrderApi(
//       vendorId: vendorId,
//       paymentMethod: "Online_Payment",
//       razorpayPaymentId: paymentId,
//       razorpayOrderId: razorpayOrderId,
//     );
//
//     // ✅ Navigate to invoice
//     if (orderId != null && mounted) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (_) => food_Invoice(orderId: orderId)),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("❌ Failed to place order after payment")),
//       );
//     }
//   }
//
//   void _handlePaymentError(PaymentFailureResponse response) {
//     debugPrint("❌ Payment Failed: ${response.code} - ${response.message}");
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text("Payment failed: ${response.message}")),
//     );
//   }
//
//   void _handleExternalWallet(ExternalWalletResponse response) {
//     debugPrint("👜 External Wallet: ${response.walletName}");
//   }
//
//   Future<void> _loadCart() async {
//     setState(() => isLoading = true);
//
//     try {
//       final fetchedCart = await food_authservice.fetchCart();
//
//       if (mounted) {
//         setState(() {
//           cartData = fetchedCart;
//           isLoading = false;
//         });
//       }
//     } catch (e) {
//       debugPrint("❌ Error loading cart: $e");
//       if (mounted) setState(() => isLoading = false);
//     }
//   }
//
//   // ==================== AUTHENTICATION HELPERS ====================
//
//   Future<Map<String, String>> _getAuthHeaders() async {
//     final prefs = await SharedPreferences.getInstance();
//
//     // Check for all possible authentication methods
//     final sessionCookie =
//         prefs.getString('sessionCookie') ?? prefs.getString('JSESSIONID') ?? '';
//     final authToken =
//         prefs.getString('authToken') ?? prefs.getString('token') ?? '';
//     final vendorId = prefs.getInt('vendorId') ?? 0;
//
//     Map<String, String> headers = {
//       'Content-Type': 'application/json',
//       'Accept': 'application/json',
//     };
//
//     // Add vendor ID as a header (most likely needed)
//     if (vendorId > 0) {
//       headers['vendorId'] = vendorId.toString();
//       headers['vendor-id'] = vendorId.toString();
//     }
//
//     // Try session cookie first (common for Spring Boot)
//     if (sessionCookie.isNotEmpty) {
//       headers['Cookie'] = sessionCookie;
//       debugPrint(
//         "🍪 Using session cookie: ${sessionCookie.substring(0, 20)}...",
//       );
//     }
//     // Try Bearer token
//     else if (authToken.isNotEmpty) {
//       headers['Authorization'] = 'Bearer $authToken';
//       debugPrint("🔐 Using Bearer token");
//     }
//
//     return headers;
//   }
//
//   // ==================== QR CODE PAYMENT METHODS ====================
//
//   Future<void> _generateDynamicQr() async {
//     if (cartData == null || cartData!.grandTotal == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Cart total is not available")),
//       );
//       return;
//     }
//
//     setState(() {
//       _isGeneratingQr = true;
//       _generatedQrData = null;
//       _qrImageUrl = null;
//       _qrPaymentVerified = false;
//     });
//
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final vendorId = prefs.getInt('vendorId') ?? 0;
//       final phone = prefs.getString('phone') ?? "9876543210";
//
//       // Generate unique order ID
//       final uniqueOrderId =
//           "ORD${DateTime.now().millisecondsSinceEpoch}${cartData!.cartId}";
//
//       final Map<String, dynamic> requestData = {
//         "amount": cartData!.grandTotal,
//         "cartId": cartData!.cartId,
//         "vendorId": vendorId,
//         "phone": phone,
//         "orderId": uniqueOrderId,
//       };
//
//       debugPrint("📱 Generating QR with data: ${jsonEncode(requestData)}");
//
//       final response = await http.post(
//         Uri.parse('http://staging.maamaas.com:8080/food/api/payments/create/qr'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//         },
//         body: jsonEncode(requestData),
//       );
//
//       debugPrint("📡 QR API Response status: ${response.statusCode}");
//
//       if (response.statusCode == 200) {
//         final responseData = jsonDecode(response.body);
//         debugPrint("✅ QR API Response: $responseData");
//
//         // Store all response data
//         setState(() {
//           _qrImageUrl = responseData['image_url']?.toString();
//           _qrOrderId = uniqueOrderId;
//           _qrPaymentId = responseData['id']?.toString();
//           selectedPaymentMethod = "QR_Payment";
//         });
//
//         // Start polling immediately
//         _startQrPolling();
//
//         // Show QR dialog after a small delay to ensure image is loaded
//         Future.delayed(const Duration(milliseconds: 300), () {
//           if (mounted) {
//             _showQrDialog();
//           }
//         });
//       } else {
//         debugPrint(
//           "❌ QR Generation failed with status: ${response.statusCode}",
//         );
//         throw Exception("Failed to generate QR: ${response.statusCode}");
//       }
//     } catch (e) {
//       debugPrint("❌ Error generating QR: $e");
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text("Failed to generate QR: ${e.toString()}"),
//           backgroundColor: Colors.red,
//         ),
//       );
//     } finally {
//       setState(() => _isGeneratingQr = false);
//     }
//   }
//
//   void _showQrDialog() {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) {
//         return Dialog(
//           backgroundColor: Colors.transparent,
//           insetPadding: EdgeInsets.all(10.w),
//           child: Container(
//             width: double.infinity,
//             constraints: BoxConstraints(
//               maxHeight: MediaQuery.of(context).size.height * 0.85,
//             ),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(25),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.3),
//                   blurRadius: 30,
//                   spreadRadius: 5,
//                 ),
//               ],
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 // Header (fixed height)
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 20,
//                     vertical: 15,
//                   ),
//                   decoration: BoxDecoration(
//                     color: Colors.blue[700],
//                     borderRadius: const BorderRadius.only(
//                       topLeft: Radius.circular(25),
//                       topRight: Radius.circular(25),
//                     ),
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       const Text(
//                         "SCAN TO PAY",
//                         style: TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                         ),
//                       ),
//                       IconButton(
//                         icon: const Icon(
//                           Icons.close,
//                           size: 28,
//                           color: Colors.white,
//                         ),
//                         onPressed: () {
//                           _qrPollingTimer?.cancel();
//                           Navigator.pop(context);
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//
//                 // Scrollable content area
//                 Expanded(
//                   child: SingleChildScrollView(
//                     child: Padding(
//                       padding: const EdgeInsets.all(5),
//                       child: Column(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           // Amount display
//                           Container(
//                             margin: const EdgeInsets.only(bottom: 15),
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 20,
//                               vertical: 8,
//                             ),
//
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 const Icon(
//                                   Icons.currency_rupee,
//                                   color: Colors.green,
//                                   size: 24,
//                                 ),
//                                 const SizedBox(width: 8),
//                                 Text(
//                                   "${cartData?.grandTotal ?? 0}",
//                                   style: const TextStyle(
//                                     fontSize: 28,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.green,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//
//                           // QR Code Container with fixed size
//                           Container(
//                             width: 400,
//                             height: 800,
//
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               borderRadius: BorderRadius.circular(20),
//                               border: Border.all(
//                                 color: Colors.blue[100]!,
//                                 width: 2,
//                               ),
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: Colors.blue.withOpacity(0.2),
//                                   blurRadius: 15,
//                                   spreadRadius: 3,
//                                 ),
//                               ],
//                             ),
//                             child: Center(
//                               child: _qrImageUrl != null
//                                   ? Image.network(
//                                       _qrImageUrl!,
//                                       fit: BoxFit.contain,
//                                     )
//                                   : CircularProgressIndicator(
//                                       strokeWidth: 3,
//                                       color: Colors.blue[400],
//                                     ),
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
//         );
//       },
//     ).then((_) {
//       _qrPollingTimer?.cancel();
//     });
//   }
//
//   // Start polling for QR payment verification - WITH AUTHENTICATION
//   void _startQrPolling() {
//     _qrPollingTimer?.cancel();
//
//     // Start polling after 3 seconds (give time for customer to scan)
//     Future.delayed(const Duration(seconds: 3), () {
//       _qrPollingTimer = Timer.periodic(const Duration(seconds: 3), (
//         timer,
//       ) async {
//         await _checkPaymentStatus(timer);
//       });
//     });
//   }
//
//   Future<void> _checkPaymentStatus(Timer timer) async {
//     // Check if we have cart data
//     if (cartData == null || cartData!.cartId == 0) {
//       debugPrint("❌ Cart data is not available");
//       return;
//     }
//
//     final cartId = cartData!.cartId; // Get the actual cart ID
//
//     if (_qrPaymentId == null) {
//       debugPrint("❌ QR Payment ID is null");
//       return;
//     }
//
//     try {
//       debugPrint("🔍 Checking payment status for Payment ID: $_qrPaymentId");
//       debugPrint("🎫 Order ID: $_qrOrderId");
//       debugPrint("🛒 Cart ID: $cartId");
//
//       // Get authentication headers
//       final headers = await _getAuthHeaders();
//
//       // Try different endpoints and methods
//
//       // Method 1: GET with query parameters (most common)
//       final getUrl =
//           'http://staging.maamaas.com:8080/food/api/orders/order/check/status?cartId=$cartId';
//       debugPrint("🌐 Trying GET: $getUrl");
//
//       final getResponse = await http.get(Uri.parse(getUrl), headers: headers);
//
//       debugPrint("📡 GET Response status: ${getResponse.statusCode}");
//
//       if (getResponse.statusCode == 200) {
//         await _handlePaymentResponse(jsonDecode(getResponse.body), timer);
//         return;
//       } else if (getResponse.statusCode == 403) {
//         debugPrint("🔒 GET 403 Forbidden, trying POST...");
//         await _tryPostMethod(timer, cartId, headers);
//       } else {
//         debugPrint(
//           "⚠️ GET failed: ${getResponse.statusCode}, trying alternative...",
//         );
//         await _tryAlternativeMethods(timer, cartId, headers);
//       }
//     } catch (e) {
//       debugPrint("❌ Error checking payment status: $e");
//     }
//   }
//
//   Future<void> _tryPostMethod(
//     Timer timer,
//     int cartId,
//     Map<String, String> headers,
//   ) async {
//     try {
//       debugPrint("🔄 Trying POST method...");
//
//       final postResponse = await http.post(
//         Uri.parse(
//           'http://staging.maamaas.com:8080/food/api/orders/order/check/status',
//         ),
//         headers: headers,
//         body: jsonEncode({
//           'cartId': cartId,
//           'paymentId': _qrPaymentId,
//           'orderId': _qrOrderId,
//         }),
//       );
//
//       debugPrint("📡 POST Response status: ${postResponse.statusCode}");
//
//       if (postResponse.statusCode == 200) {
//         await _handlePaymentResponse(jsonDecode(postResponse.body), timer);
//       } else if (postResponse.statusCode == 403) {
//         debugPrint("🔒 POST also 403, trying payment-specific endpoint...");
//         await _tryPaymentSpecificEndpoint(timer, cartId);
//       }
//     } catch (e) {
//       debugPrint("❌ Error with POST method: $e");
//     }
//   }
//
//   Future<void> _tryAlternativeMethods(
//     Timer timer,
//     int cartId,
//     Map<String, String> headers,
//   ) async {
//     try {
//       debugPrint("🔄 Trying alternative endpoints...");
//
//       // Try payment-specific endpoint
//       final paymentUrl =
//           'http://staging.maamaas.com:8080/food/api/payments/check/status?paymentId=$_qrPaymentId&orderId=$_qrOrderId';
//       final paymentResponse = await http.get(
//         Uri.parse(paymentUrl),
//         headers: headers,
//       );
//
//       debugPrint("📡 Payment endpoint response: ${paymentResponse.statusCode}");
//
//       if (paymentResponse.statusCode == 200) {
//         await _handlePaymentResponse(jsonDecode(paymentResponse.body), timer);
//       } else {
//         debugPrint("❌ All endpoints failed, continuing polling...");
//       }
//     } catch (e) {
//       debugPrint("❌ Error with alternative methods: $e");
//     }
//   }
//
//   Future<void> _tryPaymentSpecificEndpoint(Timer timer, int cartId) async {
//     try {
//       debugPrint("🔄 Trying payment-specific endpoint with minimal headers...");
//
//       // Try with just vendorId (no other auth)
//       final prefs = await SharedPreferences.getInstance();
//       final vendorId = prefs.getInt('vendorId') ?? 0;
//
//       final response = await http.get(
//         Uri.parse(
//           'http://staging.maamaas.com:8080/food/api/orders/order/check/status?cartId=$cartId&vendorId=$vendorId',
//         ),
//         headers: {
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//         },
//       );
//
//       if (response.statusCode == 200) {
//         await _handlePaymentResponse(jsonDecode(response.body), timer);
//       } else {
//         debugPrint(
//           "❌ Payment-specific endpoint failed: ${response.statusCode}",
//         );
//       }
//     } catch (e) {
//       debugPrint("❌ Error with payment-specific endpoint: $e");
//     }
//   }
//
//   Future<void> _handlePaymentResponse(dynamic responseData, Timer timer) async {
//     try {
//       debugPrint("🎯 Processing payment status response: $responseData");
//
//       String status = 'pending';
//
//       // Parse the response
//       if (responseData is Map) {
//         // Check all possible status fields
//         status =
//             (responseData['status']?.toString() ??
//                     responseData['paymentStatus']?.toString() ??
//                     responseData['orderStatus']?.toString() ??
//                     responseData['payment_status']?.toString() ??
//                     'pending')
//                 .toLowerCase();
//
//         // Also check for boolean success indicators
//         final isSuccess =
//             responseData['success'] == true ||
//             responseData['isSuccess'] == true;
//         final isPaid =
//             responseData['paid'] == true || responseData['isPaid'] == true;
//
//         if (isSuccess || isPaid) {
//           status = 'success';
//         }
//       }
//
//       debugPrint("🎯 Parsed status: $status");
//
//       // Check if payment is successful
//       final bool isSuccessful =
//           status.contains('success') ||
//           status.contains('completed') ||
//           status.contains('paid') ||
//           status.contains('confirmed') ||
//           status.contains('captured');
//
//       final bool isFailed =
//           status.contains('failed') ||
//           status.contains('cancelled') ||
//           status.contains('expired') ||
//           status.contains('rejected');
//
//       if (isSuccessful) {
//         debugPrint("✅ Payment verified successfully!");
//
//         if (mounted) {
//           setState(() {
//             _qrPaymentVerified = true;
//           });
//
//           timer.cancel();
//
//           // Wait 1 second, then complete order
//           Future.delayed(const Duration(seconds: 1), () {
//             if (Navigator.of(context).canPop()) {
//               Navigator.pop(context);
//             }
//             _completeQrPaymentAndNavigate();
//           });
//         }
//       } else if (isFailed) {
//         debugPrint("❌ Payment failed: $status");
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text("Payment $status"),
//               backgroundColor: Colors.red,
//             ),
//           );
//           timer.cancel();
//           if (Navigator.of(context).canPop()) {
//             Navigator.pop(context);
//           }
//         }
//       } else {
//         debugPrint("⏳ Payment still pending: $status");
//       }
//     } catch (e) {
//       debugPrint("❌ Error handling payment response: $e");
//     }
//   }
//
//   // Complete QR payment and navigate to menu
//   Future<void> _completeQrPaymentAndNavigate() async {
//     setState(() => isPlacingOrder = true);
//
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final vendorId = prefs.getInt('vendorId') ?? 0;
//
//       debugPrint("🎯 Placing order with QR payment...");
//
//       // If payment is verified, proceed
//       if (_qrPaymentVerified) {
//         debugPrint("✅ Payment already verified, placing order...");
//       } else {
//         debugPrint("⚠️ Payment not verified, but proceeding anyway...");
//
//         // Try one final verification
//         try {
//           final headers = await _getAuthHeaders();
//           if (cartData != null && cartData!.cartId != 0) {
//             final url =
//                 'http://staging.maamaas.com:8080/food/api/orders/order/check/status?cartId=${cartData!.cartId}';
//             final response = await http.get(Uri.parse(url), headers: headers);
//             if (response.statusCode == 200) {
//               final responseData = jsonDecode(response.body);
//               final status =
//                   responseData['status']?.toString().toLowerCase() ?? 'pending';
//               debugPrint("🔍 Final check status: $status");
//             }
//           }
//         } catch (e) {
//           debugPrint("⚠️ Final check failed: $e");
//         }
//       }
//
//       // ✅ FIXED: Call the order API and get the orderId
//       final orderId = await _callOrderApi(
//         vendorId: vendorId,
//         paymentMethod: "QR_Payment",
//         razorpayPaymentId: _qrPaymentId ?? _qrOrderId!,
//         razorpayOrderId: _qrOrderId!,
//       );
//
//       // Clear cart data
//       _clearCartAfterOrder();
//
//       // Show success message
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text("✅ Payment successful! Order placed."),
//             backgroundColor: Colors.green,
//             duration: Duration(seconds: 2),
//           ),
//         );
//
//         // ✅ FIXED: Navigate to Invoice screen with orderId
//         if (orderId != null && mounted) {
//           // Close QR dialog if it's still open
//           if (Navigator.of(context).canPop()) {
//             Navigator.pop(context);
//           }
//
//           // Navigate to invoice
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (_) => food_Invoice(orderId: orderId)),
//           );
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text("❌ Failed to place order after payment"),
//             ),
//           );
//         }
//       }
//     } catch (e) {
//       debugPrint("❌ Error completing QR payment: $e");
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text("Error: ${e.toString()}"),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() => isPlacingOrder = false);
//       }
//     }
//   }
//
//   // ==================== MAIN PLACE ORDER METHOD ====================
//
//   Future<void> placeOrder() async {
//     final prefs = await SharedPreferences.getInstance();
//     final int vendorId = prefs.getInt('vendorId') ?? 0;
//
//     // First verify cart exists and is valid
//     if (cartData == null || cartData!.cartId == 0) {
//       await _loadCart();
//       if (cartData == null || cartData!.cartId == 0) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("❌ Cart is empty or invalid")),
//         );
//         return;
//       }
//     }
//
//     if (selectedPaymentMethod.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("⚠️ Please select a payment method")),
//       );
//       return;
//     }
//
//     setState(() => isPlacingOrder = true);
//
//     try {
//       final String paymentMethod = selectedPaymentMethod;
//
//       // QR PAYMENT → Generate dynamic QR
//       if (paymentMethod == "QR_Payment") {
//         await _generateDynamicQr();
//         setState(() => isPlacingOrder = false);
//         return;
//       }
//
//       // ONLINE PAYMENT → Razorpay
//       if (paymentMethod == "Online_Payment") {
//         final amount = (cartData?.grandTotal ?? 0).toDouble();
//         final orderId = await food_authservice.createOrder(amount);
//         if (orderId == null) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text("Failed to create Razorpay order ❌")),
//           );
//           return;
//         }
//
//         _openRazorpayCheckout(amount, orderId);
//         return;
//       }
//
//       // CASH PAYMENT → Direct order placement without denominations dialog
//       if (paymentMethod == "Cash") {
//         final orderId = await _callOrderApi(
//           vendorId: vendorId,
//           paymentMethod: paymentMethod,
//           razorpayPaymentId: "",
//           razorpayOrderId: "",
//         );
//
//         // ✅ Navigate to invoice after cash payment
//         if (orderId != null && mounted) {
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (_) => food_Invoice(orderId: orderId)),
//           );
//         }
//       } else {
//         // For other payment methods
//         final orderId = await _callOrderApi(
//           vendorId: vendorId,
//           paymentMethod: paymentMethod,
//           razorpayPaymentId: "",
//           razorpayOrderId: "",
//         );
//
//         // ✅ Navigate to invoice after other payment methods
//         if (orderId != null && mounted) {
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (_) => food_Invoice(orderId: orderId)),
//           );
//         }
//       }
//     } catch (e) {
//       debugPrint("❌ Error in placeOrder: $e");
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text("Error placing order: $e")));
//     } finally {
//       setState(() => isPlacingOrder = false);
//     }
//   }
//
//   // ==================== OTHER METHODS ====================
//
//   void _openRazorpayCheckout(double amount, String orderId) {
//     var options = {
//       'key': 'rzp_test_TJECsclCivENpY',
//       'order_id': orderId,
//       'amount': (amount * 100).toInt(),
//       'name': 'Order Payment',
//       'description': 'Online Payment via Razorpay',
//       'prefill': {
//         'contact': _mobile ?? "9999999999",
//         'email': _email ?? "customer@email.com",
//       },
//       'theme': {'color': '#3399cc'},
//     };
//
//     try {
//       _razorpay.open(options);
//     } catch (e) {
//       debugPrint('⚠️ Razorpay Open Error: $e');
//     }
//   }
//
//   Future<int?> _callOrderApi({
//     required int vendorId,
//     required String paymentMethod,
//     required String razorpayPaymentId,
//     required String razorpayOrderId,
//     String? walletType,
//     Map<String, int>? cashDenominations,
//     double? paidAmount,
//     double? returnMoney,
//   }) async {
//     try {
//       // First, fetch the latest cart to get the correct cartId
//       await _loadCart();
//
//       if (cartData == null || cartData!.cartId == 0) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("❌ Cart is empty or not found")),
//         );
//         return null;
//       }
//
//       final currentCartId = cartData!.cartId;
//       debugPrint("🎯 Using current cart ID: $currentCartId");
//
//       final result = await food_authservice.placeDirectOrder(
//         vendorId: vendorId,
//         cartId: currentCartId,
//         paymentMethod: paymentMethod,
//         razorpayPaymentId: razorpayPaymentId,
//         razorpayOrderId: razorpayOrderId,
//         walletType: walletType,
//       );
//
//       if (result != null && result.containsKey('orderId')) {
//         final orderId = result['orderId'];
//         final prefs = await SharedPreferences.getInstance();
//         await prefs.setInt('orderId', orderId);
//
//         debugPrint("✅ Direct Order placed successfully. OrderId: $orderId");
//
//         // Clear cart after successful order
//         _clearCartAfterOrder();
//
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("✅ Order placed successfully")),
//         );
//
//         // ✅ Return the orderId
//         return orderId;
//       } else {
//         debugPrint("❌ Failed to place direct order");
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("❌ Failed to place order")),
//         );
//         return null;
//       }
//     } catch (e) {
//       debugPrint("❌ Error in _callOrderApi: $e");
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text("Error: $e")));
//       return null;
//     }
//   }
//
//   void _clearCartAfterOrder() {
//     setState(() {
//       cartData = null;
//       cashDenominations = {
//         "oneRupee": 0,
//         "twoRupee": 0,
//         "fiveRupee": 0,
//         "tenRupee": 0,
//         "twentyRupee": 0,
//         "fiftyRupee": 0,
//         "hundredRupee": 0,
//         "twoHundredRupee": 0,
//         "fiveHundredRupee": 0,
//         "twoThousandRupee": 0,
//       };
//       paidAmount = 0.0;
//       returnMoney = 0.0;
//       _availableQuantities.clear();
//       _generatedQrData = null;
//       _qrImageUrl = null;
//       _qrOrderId = null;
//       _qrPaymentId = null;
//       _qrPaymentVerified = false;
//     });
//   }
//
//   Future<void> changeQuantity(CartItem item, int newQuantity) async {
//     if (cartData == null || cartData!.cartId == 0) {
//       await _loadCart();
//       if (cartData == null || cartData!.cartId == 0) return;
//     }
//
//     final oldQuantity = item.quantity;
//     final dishId = item.dishId;
//     final availableQuantity = _availableQuantities[dishId] ?? 0;
//
//     if (newQuantity > oldQuantity) {
//       final quantityToAdd = newQuantity - oldQuantity;
//       if (quantityToAdd > availableQuantity) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text("Only $availableQuantity items available"),
//             backgroundColor: Colors.red,
//           ),
//         );
//         return;
//       }
//     }
//
//     setState(() {
//       isLoading = true;
//     });
//
//     bool success = false;
//
//     if (newQuantity < 1) {
//       success = await food_authservice.removeCartItem(item.itemId);
//     } else {
//       success = await food_authservice.updateCartQuantity(
//         cartData!.cartId,
//         item.itemId,
//         newQuantity,
//       );
//     }
//
//     if (success) {
//       await _loadCart();
//     } else {
//       setState(() {
//         item.quantity = oldQuantity;
//         item.totalPrice = item.price * oldQuantity;
//         isLoading = false;
//       });
//     }
//   }
//
//   // ==================== UI WIDGETS ====================
//
//   @override
//   Widget build(BuildContext context) {
//     ScreenUtil.init(context);
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;
//
//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       appBar: AppBar(
//         automaticallyImplyLeading: false, // 👈 removes back arrow
//         title: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Expanded(
//               child: Align(
//                 alignment: Alignment.center,
//                 child: _buildSectionTitle("Review Your cart"),
//               ),
//             ),
//             _buildClearCart(Icons.clear),
//           ],
//         ),
//       ),
//
//       body: Column(
//         children: [
//           Expanded(
//             child: SingleChildScrollView(
//               padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   if (!isLoading &&
//                       (cartData == null || cartData!.cartItems.isEmpty))
//                     _buildEmptyCart()
//                   else ...[
//                     _buildCartItems(),
//                     SizedBox(height: 12.h),
//                     _buildaddmoretext(),
//                     SizedBox(height: 12.h),
//                     _buildsummaryCard(theme, colorScheme),
//                     SizedBox(height: 12.h),
//                     _buildCheckoutCard(),
//                     if (isExpanded) _buildCheckoutDetails(theme, colorScheme),
//                   ],
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildaddmoretext() {
//     return Center(
//       child: RichText(
//         text: TextSpan(
//           text: "Missed Something? ",
//           style: TextStyle(
//             fontSize: 14.sp,
//             fontWeight: FontWeight.bold,
//             color: Colors.black,
//           ),
//           children: [
//             TextSpan(
//               text: "Add more items",
//               style: TextStyle(
//                 fontSize: 14.sp,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.blue,
//                 decoration: TextDecoration.underline,
//               ),
//               recognizer: TapGestureRecognizer()
//                 ..onTap = () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (_) => Menu_Managemnet()),
//                   );
//                 },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildSectionTitle(String title) {
//     return Center(
//       child: Text(
//         title,
//         style: TextStyle(
//           fontSize: 16.sp,
//           fontWeight: FontWeight.bold,
//           color: Colors.black87,
//         ),
//       ),
//     );
//   }
//
//   Widget _buildClearCart(IconData icon) {
//     return IconButton(
//       icon: Icon(icon, color: Colors.red),
//       onPressed: () async {
//         if (cartData == null) return;
//
//         final bool success = await food_authservice.deleteCart(
//           cartData!.cartId,
//         );
//
//         if (success) {
//           setState(() {
//             cartData!.cartItems.clear();
//           });
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text("Cart cleared successfully!")),
//           );
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text("Failed to clear cart.")),
//           );
//         }
//       },
//     );
//   }
//
//   Widget _buildCartItems() {
//     if (isLoading) {
//       return const Center(child: CircularProgressIndicator());
//     }
//     if (cartData == null || cartData!.cartItems.isEmpty) {
//       return const SizedBox.shrink();
//     }
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
//       shadowColor: Colors.black12,
//       child: Padding(
//         padding: EdgeInsets.all(12.w),
//         child: Column(
//           children: [
//             for (var item in cartData!.cartItems) ...[
//               Padding(
//                 padding: EdgeInsets.symmetric(vertical: 8.h),
//                 child: Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Container(
//                       width: 80.w,
//                       height: 80.w,
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(12.r),
//                         color: Colors.grey[100],
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black12,
//                             blurRadius: 4,
//                             offset: const Offset(0, 2),
//                           ),
//                         ],
//                       ),
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.circular(12.r),
//                         child: _buildDishImage(item.dishImage),
//                       ),
//                     ),
//                     SizedBox(width: 12.w),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             children: [
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       item.dishName,
//                                       style: TextStyle(
//                                         fontSize: 16.sp,
//                                         fontWeight: FontWeight.w600,
//                                         color: Colors.black87,
//                                       ),
//                                     ),
//                                     if (_availableQuantities.containsKey(
//                                       item.dishId,
//                                     ))
//                                       Text(
//                                         "${_availableQuantities[item.dishId]! - item.quantity} available",
//                                         style: TextStyle(
//                                           fontSize: 11.sp,
//                                           color:
//                                               _availableQuantities[item
//                                                           .dishId]! -
//                                                       item.quantity >
//                                                   0
//                                               ? Colors.green
//                                               : Colors.red,
//                                         ),
//                                       ),
//                                   ],
//                                 ),
//                               ),
//                               Container(
//                                 padding: EdgeInsets.symmetric(
//                                   horizontal: 8.w,
//                                   vertical: 4.h,
//                                 ),
//                                 decoration: BoxDecoration(
//                                   color: Colors.grey[200],
//                                   borderRadius: BorderRadius.circular(8.r),
//                                 ),
//                                 child: Text(
//                                   "₹${item.price}",
//                                   style: TextStyle(
//                                     fontSize: 14.sp,
//                                     fontWeight: FontWeight.w500,
//                                     color: Colors.black87,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           SizedBox(height: 6.h),
//                           Row(
//                             children: [
//                               _buildQuantityControl(item),
//                               const Spacer(),
//                               Text(
//                                 "₹${item.totalPrice}",
//                                 style: TextStyle(
//                                   fontSize: 16.sp,
//                                   fontWeight: FontWeight.bold,
//                                   color: Theme.of(context).primaryColor,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               if (item != cartData!.cartItems.last)
//                 Divider(height: 1, thickness: 0.5, color: Colors.grey[300]),
//             ],
//             Divider(thickness: 1, color: Colors.grey[300]),
//             Padding(
//               padding: EdgeInsets.symmetric(vertical: 8.h),
//               child: _buildTotalRow(
//                 "Sub Total",
//                 cartData?.subtotal ?? 0,
//                 isBold: true,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildEmptyCart() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.shopping_cart_outlined, size: 60, color: Colors.grey[400]),
//           SizedBox(height: 16.h),
//           Text(
//             'Your cart is empty',
//             style: TextStyle(fontSize: 18.sp, color: Colors.grey[600]),
//           ),
//           SizedBox(height: 8.h),
//           Text(
//             'Add some delicious items',
//             style: TextStyle(fontSize: 14.sp, color: Colors.grey[500]),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildQuantityControl(CartItem item) {
//     final availableQuantity = _availableQuantities[item.dishId] ?? 0;
//     final canIncrease = item.quantity < availableQuantity;
//
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12.r),
//         border: Border.all(color: const Color(0xFFB15DC6), width: 2),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 4.r,
//             offset: Offset(0, 2.h),
//           ),
//         ],
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           _buildQtyButton(
//             icon: Icons.remove,
//             onTap: () => changeQuantity(item, item.quantity - 1),
//             color: Colors.redAccent,
//           ),
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: 10.w),
//             child: Text(
//               "${item.quantity}",
//               style: TextStyle(
//                 fontSize: 14.sp,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.black87,
//               ),
//             ),
//           ),
//           _buildQtyButton(
//             icon: Icons.add,
//             onTap: canIncrease
//                 ? () => changeQuantity(item, item.quantity + 1)
//                 : () {
//                     if (availableQuantity <= 0) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(
//                           content: Text("Item is out of stock"),
//                           backgroundColor: Colors.red,
//                         ),
//                       );
//                     } else {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(
//                           content: Text(
//                             "Only $availableQuantity items available",
//                           ),
//                           backgroundColor: Colors.red,
//                         ),
//                       );
//                     }
//                   },
//             color: canIncrease ? Colors.green : Colors.grey,
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildQtyButton({
//     required IconData icon,
//     required VoidCallback onTap,
//     required Color color,
//   }) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(8.r),
//       child: Container(
//         padding: EdgeInsets.all(4.w),
//         decoration: BoxDecoration(
//           color: color.withOpacity(0.1),
//           borderRadius: BorderRadius.circular(8.r),
//         ),
//         child: Icon(icon, size: 18.sp, color: color),
//       ),
//     );
//   }
//
//   Widget _buildDishImage(String? imageUrl) {
//     if (imageUrl == null || imageUrl.isEmpty) {
//       return const Icon(Icons.fastfood, size: 40, color: Colors.grey);
//     }
//
//     debugPrint("🖼️ Loading MinIO image: $imageUrl");
//
//     return Image.network(
//       imageUrl,
//       fit: BoxFit.cover,
//       errorBuilder: (context, error, stackTrace) {
//         debugPrint("❌ Failed to load image: $error");
//         return const Icon(Icons.broken_image, size: 40, color: Colors.red);
//       },
//       loadingBuilder: (context, child, loadingProgress) {
//         if (loadingProgress == null) return child;
//         return const Center(
//           child: SizedBox(
//             width: 24,
//             height: 24,
//             child: CircularProgressIndicator(strokeWidth: 2),
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildCheckoutCard() {
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 300),
//       margin: EdgeInsets.only(bottom: 12.h),
//       width: double.infinity,
//       child: ElevatedButton(
//         onPressed: () {
//           setState(() => isExpanded = !isExpanded);
//         },
//         style: ElevatedButton.styleFrom(
//           backgroundColor: const Color(0xFFB15DC6),
//           padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.w),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12.r),
//           ),
//           elevation: 3,
//         ),
//         child: AnimatedSwitcher(
//           duration: const Duration(milliseconds: 300),
//           transitionBuilder: (child, animation) =>
//               FadeTransition(opacity: animation, child: child),
//           child: isExpanded
//               ? Text(
//                   'Hide payment options',
//                   key: const ValueKey(1),
//                   style: TextStyle(
//                     fontSize: 16.sp,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 )
//               : Text(
//                   'Show payment options',
//                   key: const ValueKey(2),
//                   style: TextStyle(
//                     fontSize: 16.sp,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildCheckoutDetails(ThemeData theme, ColorScheme colorScheme) {
//     return Column(
//       children: [
//         _buildPaymentSection(theme, colorScheme),
//         SizedBox(height: 16.h),
//         _buildPlaceOrderButton(theme, colorScheme),
//       ],
//     );
//   }
//
//   Widget _buildTotalRow(String label, num value, {bool isBold = false}) {
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 4.h),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             label,
//             style: TextStyle(
//               fontSize: 14.sp,
//               fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
//               color: isBold ? Colors.black87 : Colors.grey[700],
//             ),
//           ),
//           Text(
//             "₹$value",
//             style: TextStyle(
//               fontSize: 14.sp,
//               fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
//               color: isBold ? Theme.of(context).primaryColor : Colors.grey[700],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildsummaryCard(ThemeData theme, ColorScheme colorScheme) {
//     if (cartData == null) {
//       return const Center(child: CircularProgressIndicator());
//     }
//
//     final subtotal = cartData?.subtotal ?? 0;
//     final packingTotal = cartData?.packingTotal ?? 0;
//     final platformCharges = cartData?.platformCharges ?? 0;
//     final gstTotal = cartData?.gstTotal ?? 0;
//     final grandTotal = cartData?.grandTotal ?? 0;
//
//     bool hasDineIn = cartData!.cartItems.any(
//       (item) => item.orderType == "DINE_IN",
//     );
//     bool hasTakeaway = cartData!.cartItems.any(
//       (item) => item.orderType == "TAKEAWAY",
//     );
//
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16.r),
//         side: BorderSide(color: colorScheme.outline.withOpacity(0.2)),
//       ),
//       child: Padding(
//         padding: EdgeInsets.all(16.w),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Icon(
//                   Icons.receipt_outlined,
//                   color: colorScheme.primary,
//                   size: 22,
//                 ),
//                 SizedBox(width: 8.w),
//                 Text(
//                   'Order Summary',
//                   style: theme.textTheme.titleLarge?.copyWith(
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//             const Divider(thickness: 1, color: Colors.grey),
//             _buildTotalRow("Sub Total", subtotal),
//
//             if (hasTakeaway) _buildTotalRow("Packing Charges", packingTotal),
//             if (hasTakeaway || hasDineIn)
//               _buildTotalRow("Platform Charges", platformCharges),
//             if (hasDineIn) _buildServiceChargesRow(theme, colorScheme),
//
//             _buildTotalRow("SGST", gstTotal / 2),
//             _buildTotalRow("CGST", gstTotal / 2),
//
//             Divider(height: 24.h, thickness: 1, color: Colors.grey),
//             _buildTotalRow("Grand Total", grandTotal, isBold: true),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildServiceChargesRow(ThemeData theme, ColorScheme colorScheme) {
//     final serviceCharges = cartData?.serviceCharges ?? 0.0;
//     return Container(
//       decoration: BoxDecoration(
//         color: colorScheme.surfaceContainerHighest.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(8.r),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             "Service Charges",
//             style: theme.textTheme.bodyMedium?.copyWith(
//               color: colorScheme.onSurface.withOpacity(0.9),
//             ),
//           ),
//           Row(
//             children: [
//               GestureDetector(
//                 onTap: () async {
//                   final newState = !isServiceChargeApplied;
//                   if (cartData?.cartId == null) return;
//
//                   await food_authservice.updateServiceCharges(
//                     cartId: cartData!.cartId,
//                     serviceCharge: isServiceChargeApplied
//                         ? "NOT_APPLICABLE"
//                         : "APPLICABLE",
//                   );
//
//                   setState(() {
//                     isServiceChargeApplied = newState;
//                   });
//
//                   await _loadCart();
//                 },
//                 child: Container(
//                   padding: EdgeInsets.symmetric(
//                     horizontal: 12.w,
//                     vertical: 6.h,
//                   ),
//                   decoration: BoxDecoration(
//                     color: isServiceChargeApplied
//                         ? colorScheme.errorContainer
//                         : colorScheme.primaryContainer,
//                     borderRadius: BorderRadius.circular(20.r),
//                   ),
//                   child: Text(
//                     isServiceChargeApplied ? "Remove" : "Apply",
//                     style: theme.textTheme.labelSmall?.copyWith(
//                       color: isServiceChargeApplied
//                           ? colorScheme.onErrorContainer
//                           : colorScheme.onPrimaryContainer,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),
//               SizedBox(width: 10.w),
//               Text(
//                 isServiceChargeApplied
//                     ? "-₹${serviceCharges.toStringAsFixed(2)}"
//                     : "₹${serviceCharges.toStringAsFixed(2)}",
//                 style: theme.textTheme.bodyMedium?.copyWith(
//                   color: colorScheme.onSurface,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildPaymentSection(ThemeData theme, ColorScheme colorScheme) {
//     final orderType = cartData?.orderType ?? "DINE_IN";
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Icon(Icons.payment_outlined, color: colorScheme.primary, size: 22),
//             SizedBox(width: 8.w),
//             Text(
//               'Payment Method',
//               style: theme.textTheme.titleLarge?.copyWith(
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
//         ),
//         SizedBox(height: 12.h),
//         Column(
//           children: [
//             orderType != "DELIVERY"
//                 ? _buildPaymentOption(
//                     "Cash on Delivery",
//                     Icons.money_outlined,
//                     "Cash",
//                     theme,
//                     colorScheme,
//                   )
//                 : const SizedBox.shrink(),
//             _buildPaymentOption(
//               "Online Payment",
//               Icons.credit_card_outlined,
//               "Online_Payment",
//               theme,
//               colorScheme,
//             ),
//             _buildPaymentOption(
//               "QR Code Payment",
//               Icons.qr_code_2_outlined,
//               "QR_Payment",
//               theme,
//               colorScheme,
//             ),
//           ],
//         ),
//       ],
//     );
//   }
//
//   Widget _buildPaymentOption(
//     String title,
//     IconData icon,
//     String value,
//     ThemeData theme,
//     ColorScheme colorScheme,
//   ) {
//     final isSelected = selectedPaymentMethod == value;
//     return Card(
//       elevation: 0,
//       margin: EdgeInsets.only(bottom: 8.h),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12.r),
//         side: BorderSide(
//           color: isSelected ? colorScheme.primary : Colors.grey.shade300,
//           width: isSelected ? 1.5 : 1,
//         ),
//       ),
//       color: isSelected ? colorScheme.primary.withOpacity(0.05) : Colors.white,
//       child: InkWell(
//         borderRadius: BorderRadius.circular(12.r),
//         onTap: () {
//           setState(() {
//             selectedPaymentMethod = value;
//             if (checkoutData != null) checkoutData!['paymentMethod'] = value;
//             if (value != "Maamaas_Wallet") selectedSubWallet = "";
//
//             if (value == "QR_Payment") {
//               _generateDynamicQr();
//             }
//           });
//         },
//         child: Padding(
//           padding: EdgeInsets.all(16.w),
//           child: Row(
//             children: [
//               Icon(
//                 icon,
//                 color: isSelected ? colorScheme.primary : Colors.grey[600],
//               ),
//               SizedBox(width: 12.w),
//               Expanded(
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(title, style: theme.textTheme.titleMedium),
//                     if (value == "QR_Payment" && _isGeneratingQr)
//                       const SizedBox(
//                         width: 20,
//                         height: 20,
//                         child: CircularProgressIndicator(strokeWidth: 2),
//                       ),
//                   ],
//                 ),
//               ),
//               if (isSelected)
//                 Icon(Icons.check_circle, color: colorScheme.primary),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildPlaceOrderButton(ThemeData theme, ColorScheme colorScheme) {
//     return SizedBox(
//       width: double.infinity,
//       child: ElevatedButton(
//         onPressed: isPlacingOrder ? null : placeOrder,
//         style: ElevatedButton.styleFrom(
//           padding: EdgeInsets.symmetric(vertical: 16.h),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12.r),
//           ),
//           backgroundColor: colorScheme.primary,
//           foregroundColor: colorScheme.onPrimary,
//           elevation: 2,
//         ),
//         child: isPlacingOrder
//             ? SizedBox(
//                 width: 22.w,
//                 height: 22.w,
//                 child: CircularProgressIndicator(
//                   color: colorScheme.onPrimary,
//                   strokeWidth: 2,
//                 ),
//               )
//             : Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     'Place Order',
//                     style: TextStyle(
//                       fontSize: 16.sp,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   SizedBox(width: 8.w),
//                   Container(
//                     padding: EdgeInsets.symmetric(
//                       horizontal: 8.w,
//                       vertical: 4.h,
//                     ),
//                     decoration: BoxDecoration(
//                       color: colorScheme.onPrimary.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Text(
//                       '₹${(cartData?.grandTotal ?? 0).toStringAsFixed(2)}',
//                       style: TextStyle(
//                         fontSize: 14.sp,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//       ),
//     );
//   }
// }
