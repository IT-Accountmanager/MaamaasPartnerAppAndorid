// import 'dart:io';
// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:maamaas_app/API/Auth_service.dart';
// import 'package:maamaas_app/API/food_authservice.dart';
// import 'package:maamaas_app/screens/Fresh&Groceries/grocerystore_screen.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:razorpay_flutter/razorpay_flutter.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../Models/food/catering_cart_model.dart';
// import '../../Models/wallet_model.dart';
// import '../../widgets/appbar.dart';
// import '../../widgets/food/food_footer.dart';
// import '../../widgets/profiledrawer.dart';
// import 'grocery_Invoice_screen.dart';
//
// class CartScreen extends StatefulWidget {
//   final String? vendorId;
//   final int? cartId;
//   const CartScreen({super.key, this.vendorId, this.cartId});
//   @override
//   _CartScreenState createState() => _CartScreenState();
// }
//
// class _CartScreenState extends State<CartScreen> {
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
//   Wallet? wallet;
//   int? appliedCouponId;
//   String? appliedCouponCode;
//   late CartModel? updatedCartData = cartData;
//   DateTime? _selectedDate;
//   TimeOfDay? _selectedTime;
//   String? _email;
//   String? _mobile;
//   double _lastPaidAmount = 0.0;
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
//     _loadWallet();
//     _loadUserProfile();
//     _loadCart();
//   }
//
//   @override
//   void dispose() {
//     _razorpay.clear();
//     super.dispose();
//   }
//
//   Future<void> _loadWallet() async {
//     try {
//       final fetchedWallet = await AuthService.fetchWallet(); // API call
//       if (!mounted) return; // safety
//       setState(() {
//         wallet = fetchedWallet;
//       });
//     } catch (e) {
//       debugPrint("⚠️ _loadWallet failed: $e");
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text("❌ Failed to load wallet"),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }
//
//   void _handlePaymentSuccess(PaymentSuccessResponse response) async {
//     debugPrint("✅ Payment Success: ${response.paymentId}");
//
//     final prefs = await SharedPreferences.getInstance();
//     final userId = prefs.getInt('userId') ?? 0;
//     final paymentId = response.paymentId!;
//     final orderId = response.orderId!;
//
//     final String paymentMethod = "Online_Payment";
//     final bool isScheduled = _selectedDate != null || _selectedTime != null;
//
//     // 1️⃣ Capture payment
//     debugPrint("✅ Payment Success: ${response.paymentId}");
//     final bool captured = await food_Authservice.capturePayment(
//       paymentId: response.paymentId!,
//       amount: (cartData?.grandTotal ?? 0).toDouble(),
//     );
//
//     if (captured) {
//       if (isScheduled) {
//         await _callScheduledOrderApi(
//           userId: userId,
//           paymentMethod: paymentMethod,
//           razorpayPaymentId: paymentId,
//           razorpayOrderId: orderId,
//         );
//       } else {
//         await _callOrderApi(
//           userId: userId,
//           paymentMethod: paymentMethod,
//           razorpayPaymentId: paymentId,
//           razorpayOrderId: orderId,
//         );
//       }
//     } else {
//       debugPrint("❌ Payment capture failed");
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text("❌ Payment capture failed!")));
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
//       final fetchedCart = await food_Authservice.fetchCart();
//
//       if (mounted) {
//         setState(() {
//           cartData = fetchedCart;
//           // ✅ Update coupon code from backend (refreshes field)
//           appliedCouponCode = fetchedCart?.couponCode ?? null;
//           isLoading = false;
//         });
//       }
//
//       debugPrint("✅ Cart reloaded, coupon: $appliedCouponCode");
//     } catch (e) {
//       debugPrint("❌ Error loading cart: $e");
//       if (mounted) setState(() => isLoading = false);
//     }
//   }
//
//   Future<void> placeOrder() async {
//     final prefs = await SharedPreferences.getInstance();
//     final int userId = prefs.getInt('userId') ?? 0;
//     debugPrint("📌 Starting placeOrder() for userId: $userId");
//
//     if (selectedPaymentMethod.isEmpty) {
//       debugPrint("⚠️ No payment method selected");
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("⚠️ Please select a payment method")),
//       );
//       return;
//     }
//
//     setState(() => isPlacingOrder = true);
//
//     try {
//       final bool isScheduled = _selectedDate != null || _selectedTime != null;
//       debugPrint("📅 Is Scheduled Order? $isScheduled");
//
//       final String paymentMethod = selectedPaymentMethod;
//       debugPrint("💳 Selected Payment Method: $paymentMethod");
//
//       final String? walletType = paymentMethod == "Maamaas_Wallet"
//           ? _mapSubWalletToBackend(selectedSubWallet)
//           : null;
//       debugPrint("👛 Wallet Type: $walletType");
//
//       if (paymentMethod == "Maamaas_Wallet" && walletType == null) {
//         debugPrint("⚠️ Sub-wallet not selected");
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("⚠️ Please select a sub-wallet")),
//         );
//         return;
//       }
//
//       // ONLINE PAYMENT → Razorpay
//       if (paymentMethod == "Online_Payment") {
//         final amount = (cartData?.grandTotal ?? 0).toDouble();
//
//         debugPrint("🌐 Opening Razorpay Checkout with amount: $amount");
//
//         // 1️⃣ Create Razorpay Order from backend
//         final orderId = await food_Authservice.createOrder(amount);
//         if (orderId == null) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text("Failed to create Razorpay order ❌")),
//           );
//           return;
//         }
//
//         // 2️⃣ Open Razorpay checkout with the generated orderId
//         _openRazorpayCheckout(amount, orderId);
//         return; // Wait for Razorpay callbacks
//       }
//
//       // CASH OR WALLET → call API directly
//       if (isScheduled) {
//         debugPrint("⏰ Calling Scheduled Order API");
//         await _callScheduledOrderApi(
//           userId: userId,
//           paymentMethod: paymentMethod,
//           razorpayPaymentId: "",
//           razorpayOrderId: "",
//           walletType: walletType,
//         );
//       } else {
//         debugPrint("📦 Calling Direct Order API");
//         await _callOrderApi(
//           userId: userId,
//           paymentMethod: paymentMethod,
//           razorpayPaymentId: "",
//           razorpayOrderId: "",
//           walletType: walletType,
//         );
//       }
//     } catch (e, stack) {
//       debugPrint("❌ Error in placeOrder: $e");
//       debugPrint("📌 Stacktrace: $stack");
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text("Error placing order: $e")));
//     } finally {
//       setState(() => isPlacingOrder = false);
//     }
//   }
//
//   String? _mapSubWalletToBackend(String? subWallet) {
//     switch (subWallet) {
//       case "Company Credited Amount":
//         return "COMPANY_LOADED";
//       case "Self Credited Amount":
//         return "SELF_LOADED";
//       case "Cashbacks":
//         return "CASHBACK";
//       case "Earned Amount":
//         return "EARNED_AMOUNT";
//       case "Postpaid used amount": // ✅ FIXED
//         return "POST_PAID";
//       default:
//         return null;
//     }
//   }
//
//   Future<void> _loadUserProfile() async {
//     final profile = await AuthService.fetchUserProfileData();
//     if (profile != null) {
//       setState(() {
//         _email = profile.emailId;
//         _mobile = profile.mobileNumber;
//       });
//     }
//   }
//
//   void _openRazorpayCheckout(double amount, String orderId) {
//     var options = {
//       'key': 'rzp_live_TJDvykibQEsCuN', // 🔹 use live key in production
//       'order_id': orderId,
//       'amount': (amount * 100).toInt(), // Razorpay expects amount in paise
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
//   Future<void> _callScheduledOrderApi({
//     required int userId,
//     required String paymentMethod,
//     required String razorpayPaymentId,
//     required String razorpayOrderId,
//     String? walletType,
//   }) async {
//     final prefs = await SharedPreferences.getInstance();
//     final cartId = prefs.getInt('cartId');
//     if (cartId == null) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text("❌ Cart ID missing")));
//       return;
//     }
//
//     final dateToSend = _selectedDate ?? DateTime.now();
//     final timeToSend = _selectedTime ?? TimeOfDay.now();
//
//     final result = await AuthService.scheduleOrder(
//       userId: userId,
//       cartId: cartId,
//       date: dateToSend,
//       time: timeToSend,
//       paymentMethod: paymentMethod,
//       razorpayPaymentId: razorpayPaymentId,
//       razorpayOrderId: razorpayOrderId,
//       walletType: walletType,
//     );
//
//     if (result != null && result.containsKey('orderId')) {
//       final orderId = result['orderId'];
//       await prefs.setInt('orderId', orderId);
//       debugPrint("✅ Scheduled Order placed successfully. OrderId: $orderId");
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("✅ Order placed successfully")),
//       );
//
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => grocery_Invoice(orderId: orderId),
//         ),
//       );
//     } else {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text("❌ Failed to place order")));
//     }
//   }
//
//   Future<void> _callOrderApi({
//     required int userId,
//     required String paymentMethod,
//     required String razorpayPaymentId,
//     required String razorpayOrderId,
//     String? walletType,
//   }) async {
//     final prefs = await SharedPreferences.getInstance();
//     final cartId = prefs.getInt('cartId');
//
//     if (cartId == null) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text("❌ Cart ID missing")));
//       return;
//     }
//
//     final result = await AuthService.placeDirectOrder(
//       userId: userId,
//       cartId: cartId,
//       paymentMethod: paymentMethod,
//       razorpayPaymentId: razorpayPaymentId,
//       razorpayOrderId: razorpayOrderId,
//       walletType: walletType,
//     );
//
//     if (result != null && result.containsKey('orderId')) {
//       final orderId = result['orderId'];
//       await prefs.setInt('orderId', orderId);
//
//       debugPrint("✅ Direct Order placed successfully. OrderId: $orderId");
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("✅ Order placed successfully")),
//       );
//
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => grocery_Invoice(orderId: orderId),
//         ),
//       );
//     } else {
//       debugPrint("❌ Failed to place direct order");
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text("❌ Failed to place order")));
//     }
//   }
//
//   Future<void> changeQuantity(CartItem item, int newQuantity) async {
//     if (cartData == null || cartData!.cartId == 0) {
//       await _loadCart();
//       if (cartData == null || cartData!.cartId == 0) return;
//     }
//
//     final oldQuantity = item.quantity;
//
//     setState(() {
//       isLoading = true;
//     });
//
//     bool success = false;
//
//     if (newQuantity < 1) {
//       success = await AuthService.removeCartItem(item.itemId);
//     } else {
//       success = await AuthService.updateCartQuantity(
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
//   final TextEditingController _searchController = TextEditingController();
//
//   Future<void> _openCamera() async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(source: ImageSource.camera);
//     if (pickedFile != null) {
//       File image = File(pickedFile.path);
//       print("📸 Image picked: ${image.path}");
//     }
//   }
//
//   Future<void> _startRecording() async {
//     var status = await Permission.microphone.request();
//     if (status.isGranted) {
//       print("🎤 Start recording audio...");
//     } else {
//       print("❌ Microphone permission denied");
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     ScreenUtil.init(context);
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;
//     return SafeArea(
//       child: Scaffold(
//         backgroundColor: Colors.grey[50],
//         appBar: customappBar(
//           searchController: _searchController,
//           onCameraTap: _openCamera,
//           onMicTap: _startRecording,
//           // onProfileTap: () => ProfileDrawer.open(context), // ✅ reusable
//         ),
//         body: Column(
//           children: [
//             Expanded(
//               child: SingleChildScrollView(
//                 padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     if (!isLoading &&
//                         (cartData == null || cartData!.cartItems.isEmpty))
//                       _buildEmptyCart()
//                     else ...[
//                       Row(
//                         children: [
//                           Expanded(
//                             child: Align(
//                               alignment: Alignment.center,
//                               child: _buildSectionTitle("Review Your cart"),
//                             ),
//                           ),
//                           _buildClearCart(Icons.clear),
//                         ],
//                       ),
//                       SizedBox(height: 12.h),
//                       _buildCartItems(),
//                       SizedBox(height: 12.h),
//                       _buildaddmoretext(),
//                       SizedBox(height: 12.h),
//                       _buildCouponRow(theme, colorScheme),
//                       SizedBox(height: 12.h),
//                       _buildsummaryCard(theme, colorScheme),
//                       SizedBox(height: 12.h),
//                       _buildScheduleOrder(),
//                       SizedBox(height: 12.h),
//                       _buildCheckoutCard(),
//                       if (isExpanded) _buildCheckoutDetails(theme, colorScheme),
//                     ],
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//         bottomNavigationBar: food_foooter(
//           onFilterTap: () => _openFilterBottomSheet(),
//         ),
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
//                 color: Colors.blue, // Highlight clickable text
//                 decoration: TextDecoration.underline, // Underline effect
//               ),
//               recognizer: TapGestureRecognizer()
//                 ..onTap = () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (_) =>
//                           store_Screen(vendorId: cartData?.vendorId.toString()),
//                     ),
//                   );
//                 },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildCouponRow(ThemeData theme, ColorScheme colorScheme) {
//     final bool isCouponApplied =
//         appliedCouponCode != null && appliedCouponCode!.isNotEmpty;
//
//     return GestureDetector(
//       onTap: () {
//         if (!isCouponApplied) {
//           _showCouponBottomSheet();
//         }
//       },
//       child: Container(
//         padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
//         decoration: BoxDecoration(
//           color: isCouponApplied
//               ? colorScheme.primary.withOpacity(0.1)
//               : Colors.grey.shade100,
//           borderRadius: BorderRadius.circular(12.r),
//           border: Border.all(
//             color: isCouponApplied
//                 ? colorScheme.primary.withOpacity(0.3)
//                 : Colors.grey.shade300,
//             width: 1.0,
//           ),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Row(
//               children: [
//                 Icon(
//                   Icons.local_offer_outlined,
//                   size: 20.sp,
//                   color: isCouponApplied
//                       ? colorScheme.primary
//                       : Colors.grey.shade600,
//                 ),
//                 SizedBox(width: 12.w),
//                 Text(
//                   isCouponApplied ? appliedCouponCode! : "Apply Coupon",
//                   style: theme.textTheme.bodyMedium?.copyWith(
//                     fontWeight: FontWeight.w500,
//                     color: isCouponApplied
//                         ? colorScheme.primary
//                         : Colors.grey.shade800,
//                   ),
//                 ),
//               ],
//             ),
//
//             // Show Remove button if coupon applied, else arrow
//             isCouponApplied
//                 ? GestureDetector(
//                     onTap: () async {
//                       if (cartData?.cartId == null || appliedCouponId == null) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(
//                             content: Text("No active coupon found"),
//                             backgroundColor: Colors.red,
//                           ),
//                         );
//                         return;
//                       }
//
//                       debugPrint(
//                         "🧾 Removing coupon ID: $appliedCouponId for cart ${cartData!.cartId}",
//                       );
//
//                       try {
//                         final success = await food_Authservice
//                             .updateCartSettings(
//                               cartId: cartData!.cartId,
//                               id: appliedCouponId,
//                               applyCoupon: "NOT_APPLIED",
//                             );
//
//                         if (success) {
//                           setState(() {
//                             appliedCouponCode = null;
//                             appliedCouponId = null;
//                             cartData?.couponCode = null;
//                           });
//
//                           await _loadCart(); // moved after setState
//
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             const SnackBar(
//                               content: Text("Coupon removed successfully"),
//                               backgroundColor: Colors.green,
//                             ),
//                           );
//                         } else {
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             const SnackBar(
//                               content: Text(
//                                 "Failed to remove coupon. Please try again.",
//                               ),
//                               backgroundColor: Colors.red,
//                             ),
//                           );
//                         }
//                       } catch (e) {
//                         debugPrint("❌ Error removing coupon: $e");
//                       }
//                     },
//
//                     child: Text(
//                       "Remove",
//                       style: theme.textTheme.bodySmall?.copyWith(
//                         color: Colors.red,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   )
//                 : Icon(
//                     Icons.arrow_forward_ios_rounded,
//                     size: 16.sp,
//                     color: Colors.grey.shade600,
//                   ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _showCouponBottomSheet() async {
//     final coupons = await food_Authservice.getCoupons(); // ✅ Fetch coupons
//
//     final cartVendorId = cartData?.vendorId; // ✅ Get current cart vendor
//     coupons.sort((a, b) {
//       bool aExpired = _isCouponExpired(a["endDate"]);
//       bool bExpired = _isCouponExpired(b["endDate"]);
//
//       bool aMismatch = a["vendorId"] != null && a["vendorId"] != cartVendorId;
//       bool bMismatch = b["vendorId"] != null && b["vendorId"] != cartVendorId;
//       if (aExpired != bExpired) return aExpired ? 1 : -1;
//       if (aMismatch != bMismatch) return aMismatch ? 1 : -1;
//
//       return 0;
//     });
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) {
//         if (coupons.isEmpty) {
//           return Container(
//             height: MediaQuery.of(context).size.height * 0.3,
//             decoration: const BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.only(
//                 topLeft: Radius.circular(20),
//                 topRight: Radius.circular(20),
//               ),
//             ),
//             child: const Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(
//                     Icons.confirmation_number_outlined,
//                     size: 50,
//                     color: Colors.grey,
//                   ),
//                   SizedBox(height: 16),
//                   Text(
//                     "No coupons available",
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.w500,
//                       color: Colors.grey,
//                     ),
//                   ),
//                   SizedBox(height: 8),
//                   Text(
//                     "Check back later for new offers",
//                     style: TextStyle(fontSize: 14, color: Colors.grey),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         }
//
//         return Container(
//           height: MediaQuery.of(context).size.height * 0.8,
//           decoration: const BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.only(
//               topLeft: Radius.circular(20),
//               topRight: Radius.circular(20),
//             ),
//           ),
//           child: Column(
//             children: [
//               // Header
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.grey.withOpacity(0.2),
//                       blurRadius: 3,
//                       offset: const Offset(0, 2),
//                     ),
//                   ],
//                   borderRadius: const BorderRadius.only(
//                     topLeft: Radius.circular(20),
//                     topRight: Radius.circular(20),
//                   ),
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     const Text(
//                       "Available Coupons",
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     IconButton(
//                       icon: const Icon(Icons.close),
//                       onPressed: () => Navigator.pop(context),
//                     ),
//                   ],
//                 ),
//               ),
//               Expanded(
//                 child: ListView.builder(
//                   padding: const EdgeInsets.all(16),
//                   itemCount: coupons.length,
//                   itemBuilder: (context, index) {
//                     final coupon = coupons[index];
//                     final couponCode = coupon["code"];
//                     final discount = coupon["discountPercentage"].toString();
//                     final expiryDate = coupon["endDate"];
//                     return Container(
//                       margin: const EdgeInsets.only(bottom: 16),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(12),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.grey.withOpacity(0.2),
//                             blurRadius: 8,
//                             offset: const Offset(0, 2),
//                           ),
//                         ],
//                         border: Border.all(
//                           color: _isCouponExpired(expiryDate)
//                               ? Colors.red.withOpacity(0.3)
//                               : Colors.green.withOpacity(0.3),
//                           width: 1,
//                         ),
//                       ),
//                       child: ListTile(
//                         leading: Icon(
//                           Icons.local_offer,
//                           color: _isCouponExpired(expiryDate)
//                               ? Colors.red
//                               : Colors.green,
//                         ),
//                         title: Row(
//                           children: [
//                             Text(
//                               couponCode,
//                               style: TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 color: _isCouponExpired(expiryDate)
//                                     ? Colors.red
//                                     : Colors.black,
//                               ),
//                             ),
//                             if (_isCouponExpired(expiryDate)) ...[
//                               const SizedBox(width: 8),
//                               Container(
//                                 padding: const EdgeInsets.symmetric(
//                                   horizontal: 6,
//                                   vertical: 2,
//                                 ),
//                                 decoration: BoxDecoration(
//                                   color: Colors.red.withOpacity(0.1),
//                                   borderRadius: BorderRadius.circular(6),
//                                 ),
//                                 child: const Text(
//                                   "Expired",
//                                   style: TextStyle(
//                                     color: Colors.red,
//                                     fontSize: 12,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ],
//                         ),
//                         subtitle: Text(
//                           _isCouponExpired(expiryDate)
//                               ? "Expired"
//                               : coupon["vendorId"] == null
//                               ? "Get $discount% off"
//                               : coupon["vendorId"] == cartData?.vendorId
//                               ? "Get $discount% off "
//                               : "This coupon is not applicable for this restaurent", // 🔴 mismatch
//                           style: TextStyle(
//                             color: _isCouponExpired(expiryDate)
//                                 ? Colors.red
//                                 : coupon["vendorId"] != null &&
//                                       coupon["vendorId"] != cartData?.vendorId
//                                 ? Colors
//                                       .orange // mismatch
//                                 : Colors.black54,
//                           ),
//                         ),
//
//                         trailing: _isCouponExpired(expiryDate)
//                             ? const Icon(Icons.block, color: Colors.red)
//                             : coupon["vendorId"] != null &&
//                                   coupon["vendorId"] != cartData?.vendorId
//                             ? const Icon(
//                                 Icons.block,
//                                 color: Colors.orange,
//                               ) // mismatch
//                             : const Icon(
//                                 Icons.arrow_forward_ios,
//                                 size: 16,
//                                 color: Colors.green,
//                               ),
//
//                         onTap: _isCouponExpired(expiryDate)
//                             ? null
//                             : () async {
//                                 final messenger = ScaffoldMessenger.of(context);
//
//                                 if (cartData?.cartId == null) {
//                                   messenger.showSnackBar(
//                                     const SnackBar(
//                                       content: Text(
//                                         "Cannot apply coupon - cart is empty",
//                                       ),
//                                       backgroundColor: Colors.red,
//                                     ),
//                                   );
//                                   return;
//                                 }
//
//                                 // ✅ Check vendor restriction
//                                 final couponVendorId = coupon["vendorId"];
//                                 final cartVendorId = cartData!.vendorId;
//
//                                 if (couponVendorId != null &&
//                                     couponVendorId != cartVendorId) {
//                                   messenger.showSnackBar(
//                                     const SnackBar(
//                                       content: Text(
//                                         "This coupon is not valid for this restuarent",
//                                       ),
//                                       backgroundColor: Colors.orange,
//                                     ),
//                                   );
//                                   return;
//                                 }
//
//                                 try {
//                                   await food_Authservice.updateCartSettings(
//                                     cartId: cartData!.cartId,
//                                     id: coupon["couponId"],
//                                     applyCoupon: "APPLIED",
//                                   );
//                                   await _loadCart();
//                                   debugPrint(
//                                     "🔸 appliedCouponCode before load: $appliedCouponCode",
//                                   );
//                                   debugPrint(
//                                     "🔸 appliedCouponId before load: $appliedCouponId",
//                                   );
//                                   setState(() {
//                                     appliedCouponCode = coupon["code"];
//                                     appliedCouponId =
//                                         coupon["couponId"]; // 👈 add this line
//                                     cartData?.couponCode = coupon["code"];
//                                   });
//                                   messenger.showSnackBar(
//                                     SnackBar(
//                                       content: Text(
//                                         "Coupon $appliedCouponCode applied successfully!",
//                                       ),
//                                       backgroundColor: Colors.green,
//                                     ),
//                                   );
//                                 } catch (e) {
//                                   messenger.showSnackBar(
//                                     const SnackBar(
//                                       content: Text(
//                                         "Something went wrong. Please try again.",
//                                       ),
//                                       backgroundColor: Colors.red,
//                                     ),
//                                   );
//                                 }
//                                 Navigator.pop(context);
//                               },
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   bool _isCouponExpired(String? endDate) {
//     if (endDate == null) return false;
//     try {
//       final expiry = DateTime.parse(endDate);
//       return DateTime.now().isAfter(expiry);
//     } catch (e) {
//       return false; // in case of parse error
//     }
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
//     return CircleAvatar(
//       radius: 22,
//       backgroundColor: Colors.grey[200],
//       child: IconButton(
//         icon: Icon(icon, size: 22, color: Colors.black),
//         onPressed: () async {
//           final success = await AuthService.deleteCart();
//           if (success) {
//             setState(() {
//               cartData?.cartItems.clear();
//             });
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(content: Text("Cart cleared successfully")),
//             );
//           } else {
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(content: Text("Failed to clear cart")),
//             );
//           }
//         },
//       ),
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
//                             offset: Offset(0, 2),
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
//                                 child: Text(
//                                   item.dishName,
//                                   style: TextStyle(
//                                     fontSize: 16.sp,
//                                     fontWeight: FontWeight.w600,
//                                     color: Colors.black87,
//                                   ),
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
//             onTap: () => changeQuantity(item, item.quantity + 1),
//             color: Colors.green,
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
//   Widget _builddiscountRow(String label, num value, {bool isBold = false}) {
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
//             "-₹$value",
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
//     final orderType = cartData?.orderType ?? "DINE_IN";
//     final subtotal = cartData?.subtotal ?? 0;
//     final packingTotal = cartData?.packingTotal ?? 0;
//     final deliveryCharges = cartData?.deliveryCharges ?? 0;
//     final platformCharges = cartData?.platformCharges ?? 0;
//     final discountAmount = cartData?.discountAmount ?? 0;
//     final gstTotal = cartData?.gstTotal ?? 0;
//     final grandTotal = cartData?.grandTotal ?? 0;
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
//             Divider(thickness: 1, color: Colors.grey),
//             _buildTotalRow("Sub Total", subtotal),
//             if (orderType == "DELIVERY" || orderType == "TAKEAWAY")
//               _buildTotalRow("Packing Charges", packingTotal),
//             if (orderType == "DELIVERY")
//               _buildTotalRow("Delivery Charges", deliveryCharges),
//             if (orderType == "DELIVERY" || orderType == "TAKEAWAY")
//               _buildTotalRow("Platform Charges", platformCharges),
//             if (orderType == "DINE_IN")
//               _buildServiceChargesRow(theme, colorScheme),
//             // if (couponApplied)
//             _builddiscountRow("Discount Amount", discountAmount),
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
//                   await food_Authservice.updateServiceCharges(
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
//                   await _loadCart(); // ✅ no assignment needed
//                 },
//
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
//
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
//   Widget _buildScheduleOrder() {
//     final bool isScheduled = _selectedDate != null && _selectedTime != null;
//     DateTime today = DateTime.now();
//     DateTime firstAllowedDate = today;
//     DateTime lastAllowedDate = today.add(const Duration(days: 365));
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           "📌 If you want, you can schedule your order:",
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.w500,
//             color: Colors.black87,
//           ),
//         ),
//         const SizedBox(height: 12),
//
//         // 🔹 Schedule / Change Button
//         Row(
//           children: [
//             Expanded(
//               child: ElevatedButton.icon(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: isScheduled ? Colors.green : Colors.blue,
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 20,
//                     vertical: 14,
//                   ),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   elevation: isScheduled ? 6 : 2,
//                 ),
//                 icon: const Icon(Icons.schedule, color: Colors.white),
//                 label: Text(
//                   isScheduled ? "🔄 Change Date & Time" : "📅 Schedule Order",
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//                 onPressed: () async {
//                   final DateTime? pickedDate = await showDatePicker(
//                     context: context,
//                     initialDate: firstAllowedDate,
//                     firstDate: firstAllowedDate,
//                     lastDate: lastAllowedDate,
//                   );
//
//                   if (pickedDate == null) return;
//
//                   final TimeOfDay? pickedTime = await showTimePicker(
//                     context: context,
//                     initialTime: _selectedTime ?? TimeOfDay.now(),
//                   );
//
//                   if (pickedTime == null) return;
//
//                   setState(() {
//                     _selectedDate = pickedDate;
//                     _selectedTime = pickedTime;
//                   });
//                 },
//               ),
//             ),
//
//             // 🔹 Clear Button (Visible only if scheduled)
//             if (isScheduled) ...[
//               const SizedBox(width: 10),
//               IconButton(
//                 tooltip: "Clear schedule",
//                 onPressed: () {
//                   setState(() {
//                     _selectedDate = null;
//                     _selectedTime = null;
//                   });
//                 },
//                 style: IconButton.styleFrom(
//                   backgroundColor: Colors.red.shade100,
//                   foregroundColor: Colors.red.shade700,
//                 ),
//                 icon: const Icon(Icons.clear),
//               ),
//             ],
//           ],
//         ),
//
//         const SizedBox(height: 10),
//
//         // 🔹 Scheduled info box
//         if (isScheduled)
//           Container(
//             margin: const EdgeInsets.only(top: 10),
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(12),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.1),
//                   blurRadius: 6,
//                   offset: const Offset(0, 3),
//                 ),
//               ],
//               border: Border.all(color: Colors.green.shade300, width: 1.5),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   "✅ Your order is scheduled for:",
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.green,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   "📅 Date: ${_selectedDate!.day}-${_selectedDate!.month}-${_selectedDate!.year}",
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   "⏰ Time: ${_selectedTime!.format(context)}",
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//       ],
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
//             _buildPaymentOption(
//               "Maamaas_Wallet",
//               Icons.account_balance_wallet_outlined,
//               "Maamaas_Wallet",
//               theme,
//               colorScheme,
//             ),
//             if (selectedPaymentMethod == "Maamaas_Wallet" &&
//                 wallet != null) ...[
//               SizedBox(height: 8.h),
//               Padding(
//                 padding: EdgeInsets.only(left: 32.w),
//                 child: Column(
//                   children: [
//                     _buildSubWalletOption(
//                       "Company Credited Amount",
//                       wallet!.companyLoadedAmount,
//                       theme,
//                       colorScheme,
//                     ),
//                     _buildSubWalletOption(
//                       "Self Credited Amount",
//                       wallet!.selfLoadedAmount,
//                       theme,
//                       colorScheme,
//                     ),
//                     _buildSubWalletOption(
//                       "Cashbacks",
//                       wallet!.cashbackAmount,
//                       theme,
//                       colorScheme,
//                     ),
//                     if ((cartData?.userCompany ?? '').isNotEmpty)
//                       _buildSubWalletOption(
//                         "Postpaid used amount",
//                         wallet!.postPaidUsage,
//                         theme,
//                         colorScheme,
//                       ),
//                   ],
//                 ),
//               ),
//             ],
//             orderType != "DELIVERY"
//                 ? _buildPaymentOption(
//                     "Cash on Delivery",
//                     Icons.money_outlined,
//                     "Cash",
//                     theme,
//                     colorScheme,
//                   )
//                 : SizedBox.shrink(),
//             _buildPaymentOption(
//               "Online Payment",
//               Icons.credit_card_outlined,
//               "Online_Payment",
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
//                     if (value == "Maamaas_Wallet")
//                       Container(
//                         decoration: BoxDecoration(
//                           color: colorScheme.primary.withOpacity(0.1),
//                           borderRadius: BorderRadius.circular(10.r),
//                         ),
//                         child: Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: Text(
//                             wallet != null
//                                 ? "₹${wallet!.totalBalance.toStringAsFixed(2)}"
//                                 : "Loading...",
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               color: isSelected
//                                   ? colorScheme.primary
//                                   : Colors.grey[700],
//                             ),
//                           ),
//                         ),
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
//   Widget _buildSubWalletOption(
//     String title,
//     double amount,
//     ThemeData theme,
//     ColorScheme colorScheme,
//   ) {
//     final isSelected = selectedSubWallet == title;
//     return Card(
//       elevation: 0,
//       margin: EdgeInsets.only(bottom: 8.h),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(8.r),
//         side: BorderSide(
//           color: isSelected ? colorScheme.primary : Colors.grey.shade200,
//           width: isSelected ? 1.5 : 1,
//         ),
//       ),
//       color: isSelected ? colorScheme.primary.withOpacity(0.05) : Colors.white,
//       child: InkWell(
//         borderRadius: BorderRadius.circular(8.r),
//         onTap: () => setState(() => selectedSubWallet = title),
//         child: Padding(
//           padding: EdgeInsets.all(12.w),
//           child: Row(
//             children: [
//               Expanded(child: Text(title, style: theme.textTheme.bodyMedium)),
//               Container(
//                 decoration: BoxDecoration(
//                   color: colorScheme.primary.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(10.r),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Text(
//                     "₹${amount.toStringAsFixed(2)}",
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       color: isSelected
//                           ? colorScheme.primary
//                           : Colors.grey[700],
//                     ),
//                   ),
//                 ),
//               ),
//               if (isSelected)
//                 Icon(Icons.check, size: 18, color: colorScheme.primary),
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
//
// class _openFilterBottomSheet {}
