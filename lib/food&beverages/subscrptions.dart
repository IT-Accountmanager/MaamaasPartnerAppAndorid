// // // // import 'dart:convert';
// // // // import 'package:flutter/material.dart';
// // // // import 'package:razorpay_flutter/razorpay_flutter.dart';
// // // // import 'package:shared_preferences/shared_preferences.dart';
// // // // import '../API/food_authservice.dart';
// // // // import '../Models/food&beverages/subsctiption_plans.dart';
// // // //
// // // // class subscrptions extends StatefulWidget {
// // // //   const subscrptions({Key? key}) : super(key: key);
// // // //
// // // //   @override
// // // //   State<subscrptions> createState() => _SubscriptionsScreenState();
// // // // }
// // // //
// // // // class _SubscriptionsScreenState extends State<subscrptions> {
// // // //   late Future<SubscriptionModel?> futurePlan;
// // // //   Map<int, bool> selectedModules = {};
// // // //   bool isProcessingPayment = false;
// // // //   bool termsAccepted = false;
// // // //   late Razorpay _razorpay;
// // // //   double _currentTotal = 0;
// // // //   List<Module> _allModules = [];
// // // //
// // // //   final food_authservice foodService = food_authservice();
// // // //   String authToken = ""; // loaded from SharedPreferences
// // // //
// // // //   @override
// // // //   void initState() {
// // // //     super.initState();
// // // //     _razorpay = Razorpay();
// // // //     _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
// // // //     _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
// // // //     _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
// // // //
// // // //     _loadTokenAndPlan();
// // // //   }
// // // //
// // // //   @override
// // // //   void dispose() {
// // // //     _razorpay.clear();
// // // //     super.dispose();
// // // //   }
// // // //
// // // //   Future<void> _loadTokenAndPlan() async {
// // // //     final prefs = await SharedPreferences.getInstance();
// // // //     authToken = prefs.getString('token') ?? "";
// // // //
// // // //     setState(() {
// // // //       futurePlan = foodService.fetchSubscriptionPlan(
// // // //         planType: "STANDARD",
// // // //         businessVertical: "FOOD_AND_BEVERAGES",
// // // //       );
// // // //     });
// // // //   }
// // // //
// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     return Scaffold(
// // // //       appBar: AppBar(
// // // //         title: const Text("Subscription Plan"),
// // // //         backgroundColor: const Color(0xFFFBFBFD),
// // // //       ),
// // // //       body: SafeArea(
// // // //         child: FutureBuilder<SubscriptionModel?>(
// // // //           future: futurePlan,
// // // //           builder: (context, snapshot) {
// // // //             if (snapshot.connectionState == ConnectionState.waiting) {
// // // //               return const Center(child: CircularProgressIndicator());
// // // //             }
// // // //
// // // //             if (snapshot.hasError) {
// // // //               return Center(child: Text("Error: ${snapshot.error}"));
// // // //             }
// // // //
// // // //             if (!snapshot.hasData || snapshot.data == null) {
// // // //               return const Center(child: Text("No Data Found"));
// // // //             }
// // // //
// // // //             final plan = snapshot.data!;
// // // //             final allModules = plan.modules;
// // // //             _allModules = allModules;
// // // //             final mandatoryModules = allModules
// // // //                 .where((m) => m.defaultIncluded == "MANDATORY")
// // // //                 .toList();
// // // //             final includedModules = allModules
// // // //                 .where((m) => m.defaultIncluded == "INCLUDE")
// // // //                 .toList();
// // // //             final toggleModules = allModules
// // // //                 .where((m) => m.defaultIncluded == "EXCLUDE")
// // // //                 .toList();
// // // //
// // // //             return Column(
// // // //               children: [
// // // //                 Expanded(
// // // //                   child: SingleChildScrollView(
// // // //                     padding: const EdgeInsets.all(16),
// // // //                     child: Card(
// // // //                       color: Colors.white,
// // // //                       shape: RoundedRectangleBorder(
// // // //                         borderRadius: BorderRadius.circular(12),
// // // //                       ),
// // // //                       elevation: 4,
// // // //                       child: Column(
// // // //                         crossAxisAlignment: CrossAxisAlignment.start,
// // // //                         children: [
// // // //                           if (mandatoryModules.isNotEmpty)
// // // //                             _buildSectionHeader("Mandatory"),
// // // //                           ...mandatoryModules.map((m) => _buildModuleRow(m)),
// // // //
// // // //                           if (includedModules.isNotEmpty)
// // // //                             _buildSectionHeader("Included Features"),
// // // //                           ...includedModules.map((m) => _buildModuleRow(m)),
// // // //
// // // //                           if (toggleModules.isNotEmpty)
// // // //                             _buildSectionHeader("Add-On Features"),
// // // //                           ...toggleModules.map((m) => _buildModuleRow(m)),
// // // //                         ],
// // // //                       ),
// // // //                     ),
// // // //                   ),
// // // //                 ),
// // // //                 _buildPaymentBar(allModules),
// // // //               ],
// // // //             );
// // // //           },
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }
// // // //
// // // //   Widget _buildModuleRow(Module module) {
// // // //     selectedModules.putIfAbsent(module.id, () => false);
// // // //     final isSelected = selectedModules[module.id]!;
// // // //
// // // //     return Container(
// // // //       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
// // // //       decoration: BoxDecoration(
// // // //         border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
// // // //       ),
// // // //       child: Row(
// // // //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // // //         children: [
// // // //           Expanded(
// // // //             child: Column(
// // // //               crossAxisAlignment: CrossAxisAlignment.start,
// // // //               children: [
// // // //                 Text(
// // // //                   module.code.replaceAll("_", " "),
// // // //                   style: const TextStyle(
// // // //                     fontWeight: FontWeight.bold,
// // // //                     fontSize: 14,
// // // //                   ),
// // // //                 ),
// // // //                 const SizedBox(height: 4),
// // // //                 Text(
// // // //                   module.description,
// // // //                   style: const TextStyle(fontSize: 12, color: Colors.grey),
// // // //                 ),
// // // //               ],
// // // //             ),
// // // //           ),
// // // //           if (module.defaultIncluded == "MANDATORY")
// // // //             Text(
// // // //               '₹${module.yearlyPrice.toInt()} /year',
// // // //               style: const TextStyle(
// // // //                 fontWeight: FontWeight.bold,
// // // //                 color: Colors.green,
// // // //               ),
// // // //             )
// // // //           else if (module.defaultIncluded == "INCLUDE")
// // // //             _buildBadge(
// // // //               text: "Included",
// // // //               bgColor: const Color(0xFFD1FAE5),
// // // //               borderColor: const Color(0xFFA7F3D0),
// // // //               textColor: const Color(0xFF059669),
// // // //             )
// // // //           else
// // // //             Column(
// // // //               crossAxisAlignment: CrossAxisAlignment.end,
// // // //               children: [
// // // //                 Switch(
// // // //                   value: isSelected,
// // // //                   onChanged: (value) {
// // // //                     setState(() {
// // // //                       selectedModules[module.id] = value;
// // // //                     });
// // // //                   },
// // // //                   activeColor: Colors.green,
// // // //                 ),
// // // //                 const SizedBox(height: 4),
// // // //                 Text(
// // // //                   '₹${module.yearlyPrice.toInt()} /year',
// // // //                   style: TextStyle(
// // // //                     fontWeight: FontWeight.w600,
// // // //                     color: isSelected ? Colors.green : Colors.black,
// // // //                   ),
// // // //                 ),
// // // //               ],
// // // //             ),
// // // //         ],
// // // //       ),
// // // //     );
// // // //   }
// // // //
// // // //   Widget _buildPaymentBar(List<Module> modules) {
// // // //     double total = 0;
// // // //     for (var module in modules) {
// // // //       if (module.defaultIncluded == "MANDATORY") total += module.yearlyPrice;
// // // //       if (module.defaultIncluded == "EXCLUDE" &&
// // // //           selectedModules[module.id] == true) {
// // // //         total += module.yearlyPrice;
// // // //       }
// // // //     }
// // // //
// // // //     return Container(
// // // //       padding: const EdgeInsets.all(16),
// // // //       decoration: const BoxDecoration(
// // // //         color: Colors.white,
// // // //         boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
// // // //       ),
// // // //       child: Column(
// // // //         crossAxisAlignment: CrossAxisAlignment.start,
// // // //         children: [
// // // //           // Total
// // // //           Row(
// // // //             children: [
// // // //               Expanded(
// // // //                 child: Column(
// // // //                   crossAxisAlignment: CrossAxisAlignment.start,
// // // //                   children: [
// // // //                     const Text(
// // // //                       "Total Amount",
// // // //                       style: TextStyle(fontSize: 12, color: Colors.grey),
// // // //                     ),
// // // //                     Text(
// // // //                       "₹${total.toInt()} /year",
// // // //                       style: const TextStyle(
// // // //                         fontSize: 18,
// // // //                         fontWeight: FontWeight.bold,
// // // //                         color: Colors.green,
// // // //                       ),
// // // //                     ),
// // // //                   ],
// // // //                 ),
// // // //               ),
// // // //             ],
// // // //           ),
// // // //
// // // //           const SizedBox(height: 8),
// // // //
// // // //           // Terms Checkbox
// // // //           Row(
// // // //             children: [
// // // //               Checkbox(
// // // //                 value: termsAccepted,
// // // //                 onChanged: (value) {
// // // //                   setState(() {
// // // //                     termsAccepted = value ?? false;
// // // //                   });
// // // //                 },
// // // //                 activeColor: Colors.green,
// // // //               ),
// // // //               Expanded(
// // // //                 child: GestureDetector(
// // // //                   onTap: () {
// // // //                     setState(() {
// // // //                       termsAccepted = !termsAccepted;
// // // //                     });
// // // //                   },
// // // //                   child: const Text(
// // // //                     "I accept the Terms and Conditions",
// // // //                     style: TextStyle(fontSize: 12),
// // // //                   ),
// // // //                 ),
// // // //               ),
// // // //             ],
// // // //           ),
// // // //
// // // //           const SizedBox(height: 8),
// // // //
// // // //           // Payment Button
// // // //           SizedBox(
// // // //             width: double.infinity,
// // // //             child: ElevatedButton(
// // // //               onPressed: total > 0 && !isProcessingPayment && termsAccepted
// // // //                   ? () => _handlePayment(modules, total)
// // // //                   : null,
// // // //               style: ElevatedButton.styleFrom(
// // // //                 backgroundColor: Colors.green,
// // // //                 padding: const EdgeInsets.symmetric(
// // // //                   horizontal: 24,
// // // //                   vertical: 14,
// // // //                 ),
// // // //                 shape: RoundedRectangleBorder(
// // // //                   borderRadius: BorderRadius.circular(8),
// // // //                 ),
// // // //               ),
// // // //               child: isProcessingPayment
// // // //                   ? const CircularProgressIndicator(color: Colors.white)
// // // //                   : const Text(
// // // //                       "Proceed to Payment",
// // // //                       style: TextStyle(fontSize: 14),
// // // //                     ),
// // // //             ),
// // // //           ),
// // // //         ],
// // // //       ),
// // // //     );
// // // //   }
// // // //
// // // //   void _handlePayment(List<Module> modules, double total) async {
// // // //     setState(() => isProcessingPayment = true);
// // // //
// // // //     try {
// // // //       final order = await foodService.createOrderSub(amount: total);
// // // //
// // // //       final orderId = order["orderId"];
// // // //
// // // //       if (orderId == null) {
// // // //         throw Exception("Order ID not returned from backend");
// // // //       }
// // // //
// // // //       _currentTotal = total;
// // // //
// // // //       var options = {
// // // //         'key': 'rzp_test_TJECsclCivENpY',
// // // //         'amount': (total * 100).toInt(),
// // // //         'currency': 'INR',
// // // //         'order_id': orderId,
// // // //         'name': 'Maamaas',
// // // //         'description': 'Subscription Payment',
// // // //         'prefill': {'contact': '', 'email': ''},
// // // //       };
// // // //
// // // //       _razorpay.open(options);
// // // //     } catch (e) {
// // // //       print("FLOW ERROR: $e");
// // // //       ScaffoldMessenger.of(
// // // //         context,
// // // //       ).showSnackBar(SnackBar(content: Text("Error: $e")));
// // // //       setState(() => isProcessingPayment = false);
// // // //     }
// // // //   }
// // // //
// // // //   void _handlePaymentSuccess(PaymentSuccessResponse response) async {
// // // //     try {
// // // //       print("Payment ID: ${response.paymentId}");
// // // //
// // // //       // ✅ FIXED: Correct method name, removed token
// // // //       await foodService.capturePaymentSub(
// // // //         paymentId: response.paymentId!,
// // // //         amount: _currentTotal,
// // // //       );
// // // //
// // // //       final selectedModuleIds = _allModules
// // // //           .where(
// // // //             (m) =>
// // // //                 m.defaultIncluded == "MANDATORY" ||
// // // //                 (m.defaultIncluded == "EXCLUDE" &&
// // // //                     selectedModules[m.id] == true),
// // // //           )
// // // //           .map((m) => m.id)
// // // //           .toList();
// // // //
// // // //       // ✅ FIXED: Removed token
// // // //       await foodService.createVendorSubscription(
// // // //         planType: "STANDARD",
// // // //         businessVertical: "FOOD_AND_BEVERAGES",
// // // //         billingCycle: "YEARLY",
// // // //         selectedModules: selectedModuleIds,
// // // //         transactionId: response.paymentId!,
// // // //         totalAmount: _currentTotal,
// // // //         termsAccepted: termsAccepted,
// // // //       );
// // // //
// // // //       ScaffoldMessenger.of(context).showSnackBar(
// // // //         const SnackBar(content: Text("Subscription Successful ✅")),
// // // //       );
// // // //     } catch (e) {
// // // //       print("CAPTURE ERROR: $e");
// // // //     } finally {
// // // //       setState(() => isProcessingPayment = false);
// // // //     }
// // // //   }
// // // //
// // // //   void _handlePaymentError(PaymentFailureResponse response) {
// // // //     print("Payment Failed: ${response.message}");
// // // //     setState(() => isProcessingPayment = false);
// // // //
// // // //     ScaffoldMessenger.of(
// // // //       context,
// // // //     ).showSnackBar(const SnackBar(content: Text("Payment Failed ❌")));
// // // //   }
// // // //
// // // //   void _handleExternalWallet(ExternalWalletResponse response) {
// // // //     print("External Wallet: ${response.walletName}");
// // // //   }
// // // //
// // // //   Widget _buildSectionHeader(String title) {
// // // //     return Container(
// // // //       width: double.infinity,
// // // //       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
// // // //       color: const Color(0xFFF8FAFC),
// // // //       child: Text(
// // // //         title,
// // // //         style: const TextStyle(
// // // //           fontWeight: FontWeight.bold,
// // // //           fontSize: 13,
// // // //           color: Colors.grey,
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }
// // // //
// // // //   Widget _buildBadge({
// // // //     required String text,
// // // //     required Color bgColor,
// // // //     required Color borderColor,
// // // //     required Color textColor,
// // // //   }) {
// // // //     return Container(
// // // //       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
// // // //       decoration: BoxDecoration(
// // // //         color: bgColor,
// // // //         borderRadius: BorderRadius.circular(12),
// // // //         border: Border.all(color: borderColor),
// // // //       ),
// // // //       child: Text(
// // // //         text,
// // // //         style: TextStyle(
// // // //           fontSize: 10,
// // // //           fontWeight: FontWeight.w600,
// // // //           color: textColor,
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }
// // // // }
// //
// // import 'dart:convert';
// // import 'package:flutter/material.dart';
// // import 'package:razorpay_flutter/razorpay_flutter.dart';
// // import 'package:shared_preferences/shared_preferences.dart';
// // import '../API/food_authservice.dart';
// // import '../Models/food&beverages/subsctiption_plans.dart';
// //
// // // ─── Design Tokens ─────────────────────────────────────────────────────────────
// // class _S {
// //   static const bg = Color(0xFFF7F8FC);
// //   static const white = Color(0xFFFFFFFF);
// //   static const border = Color(0xFFEEEFF5);
// //   static const accent = Color(0xFFB15DC6);
// //   static const accentDark = Color(0xFF8B3FA0);
// //   static const accentLight = Color(0xFFF5E8FA);
// //   static const green = Color(0xFF10B981);
// //   static const greenLight = Color(0xFFD1FAE5);
// //   static const greenDark = Color(0xFF059669);
// //   static const amber = Color(0xFFF59E0B);
// //   static const amberLight = Color(0xFFFEF3C7);
// //   static const blue = Color(0xFF3B82F6);
// //   static const blueLight = Color(0xFFDBEAFE);
// //   static const text1 = Color(0xFF111827);
// //   static const text2 = Color(0xFF6B7280);
// //   static const text3 = Color(0xFFB0B3C1);
// //   static const shadow = Color(0x0A000000);
// //   static const shadowMd = Color(0x14000000);
// //
// //   static LinearGradient get gradient => const LinearGradient(
// //     colors: [accent, accentDark],
// //     begin: Alignment.topLeft,
// //     end: Alignment.bottomRight,
// //   );
// // }
// //
// // // ─── Subscriptions Widget ─────────────────────────────────────────────────────
// // class subscrptions extends StatefulWidget {
// //   const subscrptions({Key? key}) : super(key: key);
// //
// //   @override
// //   State<subscrptions> createState() => _SubscriptionsScreenState();
// // }
// //
// // class _SubscriptionsScreenState extends State<subscrptions> {
// //   late Future<SubscriptionModel?> futurePlan;
// //   Map<int, bool> selectedModules = {};
// //   bool isProcessingPayment = false;
// //   bool termsAccepted = false;
// //   late Razorpay _razorpay;
// //   double _currentTotal = 0;
// //   List<Module> _allModules = [];
// //
// //   final food_authservice foodService = food_authservice();
// //   String authToken = '';
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _razorpay = Razorpay();
// //     _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
// //     _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
// //     _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
// //     _loadTokenAndPlan();
// //   }
// //
// //   @override
// //   void dispose() {
// //     _razorpay.clear();
// //     super.dispose();
// //   }
// //
// //   Future<void> _loadTokenAndPlan() async {
// //     final prefs = await SharedPreferences.getInstance();
// //     authToken = prefs.getString('token') ?? '';
// //     setState(() {
// //       futurePlan = foodService.fetchSubscriptionPlan(
// //         planType: 'STANDARD',
// //         businessVertical: 'FOOD_AND_BEVERAGES',
// //       );
// //     });
// //   }
// //
// //   // ── Payments ─────────────────────────────────────────────────────────────────
// //   void _handlePayment(List<Module> modules, double total) async {
// //     setState(() => isProcessingPayment = true);
// //     try {
// //       final order = await foodService.createOrderSub(amount: total);
// //       final orderId = order['orderId'];
// //       if (orderId == null)
// //         throw Exception('Order ID not returned from backend');
// //       _currentTotal = total;
// //       _razorpay.open({
// //         'key': 'rzp_test_TJECsclCivENpY',
// //         'amount': (total * 100).toInt(),
// //         'currency': 'INR',
// //         'order_id': orderId,
// //         'name': 'Maamaas',
// //         'description': 'Subscription Payment',
// //         'prefill': {'contact': '', 'email': ''},
// //       });
// //     } catch (e) {
// //       _snack('Error: $e', Colors.red);
// //       setState(() => isProcessingPayment = false);
// //     }
// //   }
// //
// //   void _handlePaymentSuccess(PaymentSuccessResponse response) async {
// //     try {
// //       await foodService.capturePaymentSub(
// //         paymentId: response.paymentId!,
// //         amount: _currentTotal,
// //       );
// //       final selectedModuleIds = _allModules
// //           .where(
// //             (m) =>
// //                 m.defaultIncluded == 'MANDATORY' ||
// //                 (m.defaultIncluded == 'EXCLUDE' &&
// //                     selectedModules[m.id] == true),
// //           )
// //           .map((m) => m.id)
// //           .toList();
// //       await foodService.createVendorSubscription(
// //         planType: 'STANDARD',
// //         businessVertical: 'FOOD_AND_BEVERAGES',
// //         billingCycle: 'YEARLY',
// //         selectedModules: selectedModuleIds,
// //         transactionId: response.paymentId!,
// //         totalAmount: _currentTotal,
// //         termsAccepted: termsAccepted,
// //       );
// //       _snack('Subscription Successful ✅', _S.green);
// //     } catch (e) {
// //       debugPrint('CAPTURE ERROR: $e');
// //     } finally {
// //       setState(() => isProcessingPayment = false);
// //     }
// //   }
// //
// //   void _handlePaymentError(PaymentFailureResponse response) {
// //     setState(() => isProcessingPayment = false);
// //     _snack('Payment Failed ❌', Colors.red);
// //   }
// //
// //   void _handleExternalWallet(ExternalWalletResponse response) {}
// //
// //   void _snack(String msg, Color color) {
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       SnackBar(
// //         content: Text(
// //           msg,
// //           style: const TextStyle(
// //             color: Colors.white,
// //             fontWeight: FontWeight.w600,
// //           ),
// //         ),
// //         backgroundColor: color,
// //         behavior: SnackBarBehavior.floating,
// //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
// //       ),
// //     );
// //   }
// //
// //   // ── BUILD ────────────────────────────────────────────────────────────────────
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: _S.bg,
// //       body: SafeArea(
// //         child: FutureBuilder<SubscriptionModel?>(
// //           future: futurePlan,
// //           builder: (context, snapshot) {
// //             if (snapshot.connectionState == ConnectionState.waiting) {
// //               return const Center(
// //                 child: CircularProgressIndicator(
// //                   color: _S.accent,
// //                   strokeWidth: 2,
// //                 ),
// //               );
// //             }
// //             if (snapshot.hasError) {
// //               return _buildError(snapshot.error.toString());
// //             }
// //             if (!snapshot.hasData || snapshot.data == null) {
// //               return _buildEmpty();
// //             }
// //
// //             final plan = snapshot.data!;
// //             final allModules = plan.modules;
// //             _allModules = allModules;
// //
// //             final mandatory = allModules
// //                 .where((m) => m.defaultIncluded == 'MANDATORY')
// //                 .toList();
// //             final included = allModules
// //                 .where((m) => m.defaultIncluded == 'INCLUDE')
// //                 .toList();
// //             final addOns = allModules
// //                 .where((m) => m.defaultIncluded == 'EXCLUDE')
// //                 .toList();
// //
// //             // Compute total
// //             double total = 0;
// //             for (final m in allModules) {
// //               if (m.defaultIncluded == 'MANDATORY') total += m.yearlyPrice;
// //               if (m.defaultIncluded == 'EXCLUDE' &&
// //                   selectedModules[m.id] == true)
// //                 total += m.yearlyPrice;
// //             }
// //
// //             return Column(
// //               children: [
// //                 _buildHeader(),
// //                 Expanded(
// //                   child: SingleChildScrollView(
// //                     padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
// //                     child: Column(
// //                       children: [
// //                         _buildPlanBanner(),
// //                         if (mandatory.isNotEmpty) ...[
// //                           _sectionHeader(
// //                             'Core Features',
// //                             Icons.verified_rounded,
// //                             _S.accent,
// //                           ),
// //                           ...mandatory.map((m) => _buildModuleCard(m)),
// //                         ],
// //                         if (included.isNotEmpty) ...[
// //                           _sectionHeader(
// //                             'Included Features',
// //                             Icons.check_circle_rounded,
// //                             _S.green,
// //                           ),
// //                           ...included.map((m) => _buildModuleCard(m)),
// //                         ],
// //                         if (addOns.isNotEmpty) ...[
// //                           _sectionHeader(
// //                             'Add-On Features',
// //                             Icons.add_circle_rounded,
// //                             _S.amber,
// //                           ),
// //                           ...addOns.map((m) => _buildModuleCard(m)),
// //                         ],
// //                         const SizedBox(height: 8),
// //                       ],
// //                     ),
// //                   ),
// //                 ),
// //                 _buildPaymentBar(allModules, total),
// //               ],
// //             );
// //           },
// //         ),
// //       ),
// //     );
// //   }
// //
// //   // ── Header ────────────────────────────────────────────────────────────────────
// //   Widget _buildHeader() {
// //     return Container(
// //       padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
// //       decoration: const BoxDecoration(
// //         color: _S.white,
// //         border: Border(bottom: BorderSide(color: _S.border)),
// //       ),
// //       child: Row(
// //         children: [
// //           GestureDetector(
// //             onTap: () => Navigator.pop(context),
// //             child: Container(
// //               width: 36,
// //               height: 36,
// //               decoration: BoxDecoration(
// //                 color: _S.bg,
// //                 borderRadius: BorderRadius.circular(10),
// //                 border: Border.all(color: _S.border),
// //               ),
// //               child: const Icon(
// //                 Icons.arrow_back_ios_rounded,
// //                 color: _S.text1,
// //                 size: 15,
// //               ),
// //             ),
// //           ),
// //           const SizedBox(width: 12),
// //           const Expanded(
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 Text(
// //                   'Subscription Plan',
// //                   style: TextStyle(
// //                     fontSize: 17,
// //                     fontWeight: FontWeight.w800,
// //                     color: _S.text1,
// //                     letterSpacing: -0.3,
// //                   ),
// //                 ),
// //
// //               ],
// //             ),
// //           ),
// //
// //         ],
// //       ),
// //     );
// //   }
// //
// //   // ── Plan Banner ───────────────────────────────────────────────────────────────
// //   Widget _buildPlanBanner() {
// //     return Container(
// //       margin: const EdgeInsets.only(top: 16, bottom: 4),
// //       padding: const EdgeInsets.all(16),
// //       decoration: BoxDecoration(
// //         gradient: const LinearGradient(
// //           colors: [Color(0xFF7C3AED), _S.accent, Color(0xFFEC4899)],
// //           begin: Alignment.topLeft,
// //           end: Alignment.bottomRight,
// //         ),
// //         borderRadius: BorderRadius.circular(16),
// //         boxShadow: [
// //           BoxShadow(
// //             color: _S.accent.withOpacity(0.35),
// //             blurRadius: 16,
// //             offset: const Offset(0, 6),
// //           ),
// //         ],
// //       ),
// //       child: Stack(
// //         children: [
// //           // Decorative circle
// //           Positioned(
// //             right: -16,
// //             top: -16,
// //             child: Container(
// //               width: 80,
// //               height: 80,
// //               decoration: BoxDecoration(
// //                 shape: BoxShape.circle,
// //                 color: Colors.white.withOpacity(0.07),
// //               ),
// //             ),
// //           ),
// //           Row(
// //             crossAxisAlignment: CrossAxisAlignment.start,
// //             children: [
// //               Expanded(
// //                 child: Column(
// //                   crossAxisAlignment: CrossAxisAlignment.start,
// //                   children: [
// //                     Container(
// //                       padding: const EdgeInsets.symmetric(
// //                         horizontal: 8,
// //                         vertical: 3,
// //                       ),
// //                       decoration: BoxDecoration(
// //                         color: Colors.white.withOpacity(0.18),
// //                         borderRadius: BorderRadius.circular(6),
// //                       ),
// //                       child: const Text(
// //                         'FOOD & BEVERAGES',
// //                         style: TextStyle(
// //                           color: Colors.white,
// //                           fontSize: 9,
// //                           fontWeight: FontWeight.w700,
// //                           letterSpacing: 1,
// //                         ),
// //                       ),
// //                     ),
// //                     const SizedBox(height: 8),
// //                     const Text(
// //                       'Standard Plan',
// //                       style: TextStyle(
// //                         color: Colors.white,
// //                         fontSize: 20,
// //                         fontWeight: FontWeight.w900,
// //                         letterSpacing: -0.3,
// //                       ),
// //                     ),
// //                     const SizedBox(height: 4),
// //                     Text(
// //                       'Yearly billing · All features included',
// //                       style: TextStyle(
// //                         color: Colors.white.withOpacity(0.8),
// //                         fontSize: 12,
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //               Column(
// //                 crossAxisAlignment: CrossAxisAlignment.end,
// //                 children: [
// //                   const Text(
// //                     '/year',
// //                     style: TextStyle(
// //                       color: Colors.white,
// //                       fontSize: 11,
// //                       fontWeight: FontWeight.w500,
// //                     ),
// //                   ),
// //                   Container(
// //                     padding: const EdgeInsets.symmetric(
// //                       horizontal: 8,
// //                       vertical: 3,
// //                     ),
// //                     decoration: BoxDecoration(
// //                       color: Colors.white.withOpacity(0.18),
// //                       borderRadius: BorderRadius.circular(6),
// //                     ),
// //                     child: const Text(
// //                       'Billed Yearly',
// //                       style: TextStyle(
// //                         color: Colors.white,
// //                         fontSize: 10,
// //                         fontWeight: FontWeight.w600,
// //                       ),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ],
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   // ── Section Header ────────────────────────────────────────────────────────────
// //   Widget _sectionHeader(String title, IconData icon, Color color) {
// //     return Padding(
// //       padding: const EdgeInsets.fromLTRB(0, 18, 0, 10),
// //       child: Row(
// //         children: [
// //           Container(
// //             width: 28,
// //             height: 28,
// //             decoration: BoxDecoration(
// //               color: color.withOpacity(0.1),
// //               borderRadius: BorderRadius.circular(8),
// //             ),
// //             child: Icon(icon, color: color, size: 15),
// //           ),
// //           const SizedBox(width: 8),
// //           Text(
// //             title,
// //             style: TextStyle(
// //               fontSize: 13,
// //               fontWeight: FontWeight.w800,
// //               color: color,
// //             ),
// //           ),
// //           const SizedBox(width: 8),
// //           Expanded(
// //             child: Divider(color: color.withOpacity(0.15), thickness: 1),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   // ── Module Card ───────────────────────────────────────────────────────────────
// //   Widget _buildModuleCard(Module module) {
// //     selectedModules.putIfAbsent(module.id, () => false);
// //     final isSelected = selectedModules[module.id]!;
// //     final isMandatory = module.defaultIncluded == 'MANDATORY';
// //     final isIncluded = module.defaultIncluded == 'INCLUDE';
// //     final isAddOn = module.defaultIncluded == 'EXCLUDE';
// //
// //     return Container(
// //       margin: const EdgeInsets.only(bottom: 8),
// //       decoration: BoxDecoration(
// //         color: _S.white,
// //         borderRadius: BorderRadius.circular(12),
// //         border: Border.all(
// //           color: isAddOn && isSelected
// //               ? _S.green.withOpacity(0.4)
// //               : isMandatory
// //               ? _S.accent.withOpacity(0.15)
// //               : _S.border,
// //           width: isAddOn && isSelected ? 1.5 : 1,
// //         ),
// //         boxShadow: [
// //           BoxShadow(
// //             color: _S.shadow,
// //             blurRadius: 6,
// //             offset: const Offset(0, 2),
// //           ),
// //         ],
// //       ),
// //       child: Padding(
// //         padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
// //         child: Row(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             // Icon
// //             Container(
// //               width: 36,
// //               height: 36,
// //               decoration: BoxDecoration(
// //                 color: isMandatory
// //                     ? _S.accentLight
// //                     : isIncluded
// //                     ? _S.greenLight
// //                     : isAddOn && isSelected
// //                     ? _S.greenLight
// //                     : _S.amberLight,
// //                 borderRadius: BorderRadius.circular(10),
// //               ),
// //               child: Icon(
// //                 isMandatory
// //                     ? Icons.verified_rounded
// //                     : isIncluded
// //                     ? Icons.check_circle_rounded
// //                     : Icons.extension_rounded,
// //                 color: isMandatory
// //                     ? _S.accent
// //                     : isIncluded
// //                     ? _S.green
// //                     : isAddOn && isSelected
// //                     ? _S.green
// //                     : _S.amber,
// //                 size: 18,
// //               ),
// //             ),
// //             const SizedBox(width: 12),
// //
// //             // Text
// //             Expanded(
// //               child: Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   Text(
// //                     module.code.replaceAll('_', ' '),
// //                     style: const TextStyle(
// //                       fontSize: 13,
// //                       fontWeight: FontWeight.w700,
// //                       color: _S.text1,
// //                     ),
// //                   ),
// //                   const SizedBox(height: 3),
// //                   Text(
// //                     module.description,
// //                     style: const TextStyle(
// //                       fontSize: 11,
// //                       color: _S.text2,
// //                       height: 1.4,
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //             const SizedBox(width: 8),
// //
// //             // Right side
// //             if (isMandatory)
// //               Column(
// //                 crossAxisAlignment: CrossAxisAlignment.end,
// //                 children: [
// //                   Container(
// //                     padding: const EdgeInsets.symmetric(
// //                       horizontal: 7,
// //                       vertical: 3,
// //                     ),
// //                     decoration: BoxDecoration(
// //                       color: _S.accentLight,
// //                       borderRadius: BorderRadius.circular(6),
// //                       border: Border.all(color: _S.accent.withOpacity(0.2)),
// //                     ),
// //                     child: const Text(
// //                       'Required',
// //                       style: TextStyle(
// //                         fontSize: 9,
// //                         fontWeight: FontWeight.w700,
// //                         color: _S.accent,
// //                       ),
// //                     ),
// //                   ),
// //                   const SizedBox(height: 5),
// //                   Text(
// //                     '₹${module.yearlyPrice.toInt()}',
// //                     style: const TextStyle(
// //                       fontSize: 13,
// //                       fontWeight: FontWeight.w800,
// //                       color: _S.text1,
// //                     ),
// //                   ),
// //                   const Text(
// //                     '/year',
// //                     style: TextStyle(fontSize: 9, color: _S.text2),
// //                   ),
// //                 ],
// //               )
// //             else if (isIncluded)
// //               Container(
// //                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
// //                 decoration: BoxDecoration(
// //                   color: _S.greenLight,
// //                   borderRadius: BorderRadius.circular(8),
// //                   border: Border.all(color: _S.green.withOpacity(0.2)),
// //                 ),
// //                 child: const Text(
// //                   'Included',
// //                   style: TextStyle(
// //                     fontSize: 10,
// //                     fontWeight: FontWeight.w700,
// //                     color: _S.greenDark,
// //                   ),
// //                 ),
// //               )
// //             else
// //               Column(
// //                 crossAxisAlignment: CrossAxisAlignment.end,
// //                 children: [
// //                   // Custom toggle
// //                   GestureDetector(
// //                     onTap: () => setState(
// //                       () => selectedModules[module.id] = !isSelected,
// //                     ),
// //                     child: AnimatedContainer(
// //                       duration: const Duration(milliseconds: 200),
// //                       width: 44,
// //                       height: 24,
// //                       decoration: BoxDecoration(
// //                         color: isSelected ? _S.green : _S.border,
// //                         borderRadius: BorderRadius.circular(12),
// //                       ),
// //                       child: AnimatedAlign(
// //                         duration: const Duration(milliseconds: 200),
// //                         alignment: isSelected
// //                             ? Alignment.centerRight
// //                             : Alignment.centerLeft,
// //                         child: Container(
// //                           width: 20,
// //                           height: 20,
// //                           margin: const EdgeInsets.symmetric(horizontal: 2),
// //                           decoration: const BoxDecoration(
// //                             color: Colors.white,
// //                             shape: BoxShape.circle,
// //                             boxShadow: [
// //                               BoxShadow(
// //                                 color: Color(0x22000000),
// //                                 blurRadius: 3,
// //                               ),
// //                             ],
// //                           ),
// //                         ),
// //                       ),
// //                     ),
// //                   ),
// //                   const SizedBox(height: 5),
// //                   Text(
// //                     '₹${module.yearlyPrice.toInt()}',
// //                     style: TextStyle(
// //                       fontSize: 12,
// //                       fontWeight: FontWeight.w800,
// //                       color: isSelected ? _S.green : _S.text2,
// //                     ),
// //                   ),
// //                   const Text(
// //                     '/year',
// //                     style: TextStyle(fontSize: 9, color: _S.text2),
// //                   ),
// //                 ],
// //               ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// //
// //   // ── Payment Bar ───────────────────────────────────────────────────────────────
// //   Widget _buildPaymentBar(List<Module> modules, double total) {
// //     final addOnCount = modules
// //         .where(
// //           (m) =>
// //               m.defaultIncluded == 'EXCLUDE' && selectedModules[m.id] == true,
// //         )
// //         .length;
// //
// //     final canPay = total > 0 && !isProcessingPayment && termsAccepted;
// //
// //     return Container(
// //       padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
// //       decoration: BoxDecoration(
// //         color: _S.white,
// //         border: const Border(top: BorderSide(color: _S.border)),
// //         boxShadow: [
// //           BoxShadow(
// //             color: _S.shadowMd,
// //             blurRadius: 16,
// //             offset: const Offset(0, -4),
// //           ),
// //         ],
// //       ),
// //       child: Column(
// //         mainAxisSize: MainAxisSize.min,
// //         children: [
// //           // Summary row
// //           Row(
// //             children: [
// //               Expanded(
// //                 child: Column(
// //                   crossAxisAlignment: CrossAxisAlignment.start,
// //                   children: [
// //                     const Text(
// //                       'Total Amount',
// //                       style: TextStyle(
// //                         fontSize: 11,
// //                         color: _S.text2,
// //                         fontWeight: FontWeight.w500,
// //                       ),
// //                     ),
// //                     const SizedBox(height: 2),
// //                     Row(
// //                       crossAxisAlignment: CrossAxisAlignment.end,
// //                       children: [
// //                         Text(
// //                           '₹${total.toInt()}',
// //                           style: const TextStyle(
// //                             fontSize: 22,
// //                             fontWeight: FontWeight.w900,
// //                             color: _S.text1,
// //                           ),
// //                         ),
// //                         const Text(
// //                           ' /year',
// //                           style: TextStyle(
// //                             fontSize: 12,
// //                             color: _S.text2,
// //                             fontWeight: FontWeight.w500,
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //               if (addOnCount > 0)
// //                 Container(
// //                   padding: const EdgeInsets.symmetric(
// //                     horizontal: 10,
// //                     vertical: 5,
// //                   ),
// //                   decoration: BoxDecoration(
// //                     color: _S.amberLight,
// //                     borderRadius: BorderRadius.circular(8),
// //                     border: Border.all(color: _S.amber.withOpacity(0.3)),
// //                   ),
// //                   child: Text(
// //                     '+$addOnCount add-on${addOnCount > 1 ? 's' : ''}',
// //                     style: const TextStyle(
// //                       fontSize: 11,
// //                       fontWeight: FontWeight.w700,
// //                       color: _S.amber,
// //                     ),
// //                   ),
// //                 ),
// //             ],
// //           ),
// //
// //           const SizedBox(height: 10),
// //
// //           // Terms checkbox
// //           GestureDetector(
// //             onTap: () => setState(() => termsAccepted = !termsAccepted),
// //             child: Row(
// //               children: [
// //                 AnimatedContainer(
// //                   duration: const Duration(milliseconds: 200),
// //                   width: 20,
// //                   height: 20,
// //                   decoration: BoxDecoration(
// //                     color: termsAccepted ? _S.green : _S.white,
// //                     borderRadius: BorderRadius.circular(6),
// //                     border: Border.all(
// //                       color: termsAccepted ? _S.green : _S.border,
// //                       width: 1.5,
// //                     ),
// //                   ),
// //                   child: termsAccepted
// //                       ? const Icon(
// //                           Icons.check_rounded,
// //                           color: Colors.white,
// //                           size: 13,
// //                         )
// //                       : null,
// //                 ),
// //                 const SizedBox(width: 10),
// //                 const Expanded(
// //                   child: Text(
// //                     'I accept the Terms and Conditions',
// //                     style: TextStyle(
// //                       fontSize: 12,
// //                       color: _S.text2,
// //                       fontWeight: FontWeight.w500,
// //                     ),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //
// //           const SizedBox(height: 12),
// //
// //           // Pay button
// //           GestureDetector(
// //             onTap: canPay ? () => _handlePayment(modules, total) : null,
// //             child: AnimatedContainer(
// //               duration: const Duration(milliseconds: 200),
// //               width: double.infinity,
// //               padding: const EdgeInsets.symmetric(vertical: 14),
// //               decoration: BoxDecoration(
// //                 gradient: canPay
// //                     ? const LinearGradient(
// //                         colors: [Color(0xFF10B981), Color(0xFF059669)],
// //                         begin: Alignment.topLeft,
// //                         end: Alignment.bottomRight,
// //                       )
// //                     : null,
// //                 color: canPay ? null : _S.border,
// //                 borderRadius: BorderRadius.circular(12),
// //                 boxShadow: canPay
// //                     ? [
// //                         BoxShadow(
// //                           color: _S.green.withOpacity(0.4),
// //                           blurRadius: 12,
// //                           offset: const Offset(0, 4),
// //                         ),
// //                       ]
// //                     : null,
// //               ),
// //               child: isProcessingPayment
// //                   ? const Center(
// //                       child: SizedBox(
// //                         width: 20,
// //                         height: 20,
// //                         child: CircularProgressIndicator(
// //                           color: Colors.white,
// //                           strokeWidth: 2,
// //                         ),
// //                       ),
// //                     )
// //                   : Row(
// //                       mainAxisAlignment: MainAxisAlignment.center,
// //                       children: [
// //                         Icon(
// //                           Icons.lock_rounded,
// //                           color: canPay ? Colors.white : _S.text3,
// //                           size: 16,
// //                         ),
// //                         const SizedBox(width: 8),
// //                         Text(
// //                           canPay
// //                               ? 'Proceed to Payment  ₹${total.toInt()}'
// //                               : 'Accept terms to continue',
// //                           style: TextStyle(
// //                             color: canPay ? Colors.white : _S.text3,
// //                             fontSize: 14,
// //                             fontWeight: FontWeight.w800,
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   // ── Empty & Error States ──────────────────────────────────────────────────────
// //   Widget _buildError(String error) {
// //     return Center(
// //       child: Column(
// //         mainAxisAlignment: MainAxisAlignment.center,
// //         children: [
// //           Container(
// //             width: 64,
// //             height: 64,
// //             decoration: BoxDecoration(
// //               color: const Color(0xFFFEE2E2),
// //               shape: BoxShape.circle,
// //             ),
// //             child: const Icon(
// //               Icons.error_outline_rounded,
// //               color: Color(0xFFEF4444),
// //               size: 30,
// //             ),
// //           ),
// //           const SizedBox(height: 14),
// //           const Text(
// //             'Failed to load plan',
// //             style: TextStyle(
// //               fontSize: 16,
// //               fontWeight: FontWeight.w700,
// //               color: _S.text1,
// //             ),
// //           ),
// //           const SizedBox(height: 4),
// //           Text(
// //             error,
// //             style: const TextStyle(fontSize: 12, color: _S.text2),
// //             textAlign: TextAlign.center,
// //           ),
// //           const SizedBox(height: 20),
// //           GestureDetector(
// //             onTap: _loadTokenAndPlan,
// //             child: Container(
// //               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
// //               decoration: BoxDecoration(
// //                 gradient: _S.gradient,
// //                 borderRadius: BorderRadius.circular(10),
// //               ),
// //               child: const Text(
// //                 'Retry',
// //                 style: TextStyle(
// //                   color: Colors.white,
// //                   fontWeight: FontWeight.w700,
// //                 ),
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _buildEmpty() {
// //     return Center(
// //       child: Column(
// //         mainAxisAlignment: MainAxisAlignment.center,
// //         children: [
// //           Container(
// //             width: 64,
// //             height: 64,
// //             decoration: BoxDecoration(
// //               color: _S.bg,
// //               shape: BoxShape.circle,
// //               border: Border.all(color: _S.border),
// //             ),
// //             child: const Icon(
// //               Icons.subscriptions_rounded,
// //               color: _S.text3,
// //               size: 28,
// //             ),
// //           ),
// //           const SizedBox(height: 14),
// //           const Text(
// //             'No plan found',
// //             style: TextStyle(
// //               fontSize: 16,
// //               fontWeight: FontWeight.w700,
// //               color: _S.text1,
// //             ),
// //           ),
// //           const SizedBox(height: 4),
// //           const Text(
// //             'Please contact support',
// //             style: TextStyle(fontSize: 12, color: _S.text2),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
// // ─── subscriptions_screen.dart ────────────────────────────────────────────────
// // Fully integrated with SubscriptionService + SubscriptionModel.
// // Replace your existing subscrptions widget with this file.
//
// // import 'package:flutter/material.dart';
// // import 'package:razorpay_flutter/razorpay_flutter.dart';
// //
// // import '../Api/food_authservice.dart';
// // import '../Models/food&beverages/subsctiption_plans.dart';
// //
// //
// // // ─── Design Tokens ─────────────────────────────────────────────────────────────
// // class _S {
// //   static const bg = Color(0xFFF7F8FC);
// //   static const white = Color(0xFFFFFFFF);
// //   static const border = Color(0xFFEEEFF5);
// //   static const accent = Color(0xFFB15DC6);
// //   static const accentDark = Color(0xFF8B3FA0);
// //   static const accentLight = Color(0xFFF5E8FA);
// //   static const green = Color(0xFF10B981);
// //   static const greenLight = Color(0xFFD1FAE5);
// //   static const greenDark = Color(0xFF059669);
// //   static const amber = Color(0xFFF59E0B);
// //   static const amberLight = Color(0xFFFEF3C7);
// //   static const text1 = Color(0xFF111827);
// //   static const text2 = Color(0xFF6B7280);
// //   static const text3 = Color(0xFFB0B3C1);
// //   static const shadow = Color(0x0A000000);
// //   static const shadowMd = Color(0x14000000);
// //
// //   static LinearGradient get gradient => const LinearGradient(
// //     colors: [accent, accentDark],
// //     begin: Alignment.topLeft,
// //     end: Alignment.bottomRight,
// //   );
// // }
// //
// // // ─── Razorpay test key — swap for live key before release ──────────────────────
// // const _kRazorpayKey = 'rzp_test_TJECsclCivENpY';
// //
// // // ─── Screen ───────────────────────────────────────────────────────────────────
// // class SubscriptionsScreen extends StatefulWidget {
// //   const SubscriptionsScreen({Key? key}) : super(key: key);
// //
// //   @override
// //   State<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
// // }
// //
// // class _SubscriptionsScreenState extends State<SubscriptionsScreen> {
// //   // ── Service ──────────────────────────────────────────────────────────────────
// //   final _service = SubscriptionService();
// //
// //   // ── State ─────────────────────────────────────────────────────────────────────
// //   late Future<SubscriptionModel?> _futurePlan;
// //   List<Module> _allModules = [];
// //   Map<int, bool> _toggleState = {}; // add-on toggle per module id
// //   bool _isProcessing = false;
// //   bool _termsAccepted = false;
// //   double _currentTotal = 0;
// //
// //   // ── Razorpay ──────────────────────────────────────────────────────────────────
// //   late Razorpay _razorpay;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _razorpay = Razorpay()
// //       ..on(Razorpay.EVENT_PAYMENT_SUCCESS, _onPaymentSuccess)
// //       ..on(Razorpay.EVENT_PAYMENT_ERROR, _onPaymentError)
// //       ..on(Razorpay.EVENT_EXTERNAL_WALLET, _onExternalWallet);
// //     _loadPlan();
// //   }
// //
// //   @override
// //   void dispose() {
// //     _razorpay.clear();
// //     super.dispose();
// //   }
// //
// //   // ── Data ──────────────────────────────────────────────────────────────────────
// //   void _loadPlan() {
// //     setState(() {
// //       _futurePlan = _service.fetchSubscriptionPlan(
// //         planType: 'STANDARD',
// //         businessVertical: 'FOOD_AND_BEVERAGES',
// //       );
// //     });
// //   }
// //
// //   double _computeTotal() =>
// //       _service.computeTotal(allModules: _allModules, toggleState: _toggleState);
// //
// //   List<int> _resolveModuleIds() => _service.resolveSelectedModuleIds(
// //     allModules: _allModules,
// //     toggleState: _toggleState,
// //   );
// //
// //   // ── Payment flow ──────────────────────────────────────────────────────────────
// //   Future<void> _startPayment() async {
// //     setState(() => _isProcessing = true);
// //     try {
// //       final total = _computeTotal();
// //       final order = await _service.createOrder(amount: total);
// //       final orderId = order['orderId'];
// //       if (orderId == null)
// //         throw Exception('orderId missing from backend response');
// //
// //       _currentTotal = total;
// //       _razorpay.open({
// //         'key': _kRazorpayKey,
// //         'amount': (total * 100).toInt(), // paise
// //         'currency': 'INR',
// //         'order_id': orderId,
// //         'name': 'Maamaas',
// //         'description': 'Subscription Payment',
// //         'prefill': {'contact': '', 'email': ''},
// //       });
// //     } catch (e) {
// //       _snack('Error initiating payment: $e', Colors.red);
// //       setState(() => _isProcessing = false);
// //     }
// //   }
// //
// //   void _onPaymentSuccess(PaymentSuccessResponse response) async {
// //     try {
// //       // 1. Capture the payment on backend
// //       await _service.capturePayment(
// //         paymentId: response.paymentId!,
// //         amount: _currentTotal,
// //       );
// //
// //       // 2. Create the vendor subscription record
// //       final success = await _service.createVendorSubscription(
// //         planType: 'STANDARD',
// //         businessVertical: 'FOOD_AND_BEVERAGES',
// //         billingCycle: 'YEARLY',
// //         selectedModuleIds: _resolveModuleIds(),
// //         transactionId: response.paymentId!,
// //         totalAmount: _currentTotal,
// //         termsAccepted: _termsAccepted,
// //       );
// //
// //       if (success) {
// //         _snack('Subscription activated ✅', _S.green);
// //         // Optionally navigate away or refresh:
// //         // Navigator.pop(context);
// //       } else {
// //         _snack('Subscription record failed — contact support', Colors.orange);
// //       }
// //     } catch (e) {
// //       debugPrint('Post-payment error: $e');
// //       _snack(
// //         'Payment captured but setup failed. Contact support.',
// //         Colors.orange,
// //       );
// //     } finally {
// //       setState(() => _isProcessing = false);
// //     }
// //   }
// //
// //   void _onPaymentError(PaymentFailureResponse response) {
// //     setState(() => _isProcessing = false);
// //     _snack('Payment failed ❌ ${response.message ?? ''}', Colors.red);
// //   }
// //
// //   void _onExternalWallet(ExternalWalletResponse response) {
// //     // handle external wallet if needed
// //   }
// //
// //   // ── Snackbar ─────────────────────────────────────────────────────────────────
// //   void _snack(String msg, Color color) {
// //     if (!mounted) return;
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       SnackBar(
// //         content: Text(
// //           msg,
// //           style: const TextStyle(
// //             color: Colors.white,
// //             fontWeight: FontWeight.w600,
// //           ),
// //         ),
// //         backgroundColor: color,
// //         behavior: SnackBarBehavior.floating,
// //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
// //       ),
// //     );
// //   }
// //
// //   // ─────────────────────────────────────────────────────────────────────────────
// //   // BUILD
// //   // ─────────────────────────────────────────────────────────────────────────────
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: _S.bg,
// //       body: SafeArea(
// //         child: FutureBuilder<SubscriptionModel?>(
// //           future: _futurePlan,
// //           builder: (context, snapshot) {
// //             if (snapshot.connectionState == ConnectionState.waiting) {
// //               return const Center(
// //                 child: CircularProgressIndicator(
// //                   color: _S.accent,
// //                   strokeWidth: 2,
// //                 ),
// //               );
// //             }
// //             if (snapshot.hasError)
// //               return _buildError(snapshot.error.toString());
// //             if (!snapshot.hasData || snapshot.data == null)
// //               return _buildEmpty();
// //
// //             final plan = snapshot.data!;
// //             _allModules = plan.modules;
// //
// //             // Ensure toggle map is initialised for all add-ons
// //             for (final m in _allModules) {
// //               _toggleState.putIfAbsent(m.id, () => false);
// //             }
// //
// //             final mandatory = plan.modules
// //                 .where((m) => m.defaultIncluded == 'MANDATORY')
// //                 .toList();
// //             final included = plan.modules
// //                 .where((m) => m.defaultIncluded == 'INCLUDE')
// //                 .toList();
// //             final addOns = plan.modules
// //                 .where((m) => m.defaultIncluded == 'EXCLUDE')
// //                 .toList();
// //
// //             final total = _computeTotal();
// //             final canPay = total > 0 && !_isProcessing && _termsAccepted;
// //
// //             return Column(
// //               children: [
// //                 _buildHeader(),
// //                 Expanded(
// //                   child: SingleChildScrollView(
// //                     padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
// //                     child: Column(
// //                       children: [
// //                         _buildPlanBanner(),
// //                         if (mandatory.isNotEmpty) ...[
// //                           _sectionHeader(
// //                             'Core Features',
// //                             Icons.verified_rounded,
// //                             _S.accent,
// //                           ),
// //                           ...mandatory.map(_buildModuleCard),
// //                         ],
// //                         if (included.isNotEmpty) ...[
// //                           _sectionHeader(
// //                             'Included Features',
// //                             Icons.check_circle_rounded,
// //                             _S.green,
// //                           ),
// //                           ...included.map(_buildModuleCard),
// //                         ],
// //                         if (addOns.isNotEmpty) ...[
// //                           _sectionHeader(
// //                             'Add-On Features',
// //                             Icons.add_circle_rounded,
// //                             _S.amber,
// //                           ),
// //                           ...addOns.map(_buildModuleCard),
// //                         ],
// //                         const SizedBox(height: 8),
// //                       ],
// //                     ),
// //                   ),
// //                 ),
// //                 _buildPaymentBar(
// //                   total: total,
// //                   canPay: canPay,
// //                   addOnCount: _allModules
// //                       .where(
// //                         (m) =>
// //                             m.defaultIncluded == 'EXCLUDE' &&
// //                             _toggleState[m.id] == true,
// //                       )
// //                       .length,
// //                 ),
// //               ],
// //             );
// //           },
// //         ),
// //       ),
// //     );
// //   }
// //
// //   // ── Header ───────────────────────────────────────────────────────────────────
// //   Widget _buildHeader() => Container(
// //     padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
// //     decoration: const BoxDecoration(
// //       color: _S.white,
// //       border: Border(bottom: BorderSide(color: _S.border)),
// //     ),
// //     child: Row(
// //       children: [
// //         GestureDetector(
// //           onTap: () => Navigator.pop(context),
// //           child: Container(
// //             width: 36,
// //             height: 36,
// //             decoration: BoxDecoration(
// //               color: _S.bg,
// //               borderRadius: BorderRadius.circular(10),
// //               border: Border.all(color: _S.border),
// //             ),
// //             child: const Icon(
// //               Icons.arrow_back_ios_rounded,
// //               color: _S.text1,
// //               size: 15,
// //             ),
// //           ),
// //         ),
// //         const SizedBox(width: 12),
// //         const Text(
// //           'Subscription Plan',
// //           style: TextStyle(
// //             fontSize: 17,
// //             fontWeight: FontWeight.w800,
// //             color: _S.text1,
// //             letterSpacing: -0.3,
// //           ),
// //         ),
// //       ],
// //     ),
// //   );
// //
// //   // ── Plan Banner ──────────────────────────────────────────────────────────────
// //   Widget _buildPlanBanner() => Container(
// //     margin: const EdgeInsets.only(top: 16, bottom: 4),
// //     padding: const EdgeInsets.all(16),
// //     decoration: BoxDecoration(
// //       gradient: const LinearGradient(
// //         colors: [Color(0xFF7C3AED), _S.accent, Color(0xFFEC4899)],
// //         begin: Alignment.topLeft,
// //         end: Alignment.bottomRight,
// //       ),
// //       borderRadius: BorderRadius.circular(16),
// //       boxShadow: [
// //         BoxShadow(
// //           color: _S.accent.withOpacity(0.35),
// //           blurRadius: 16,
// //           offset: const Offset(0, 6),
// //         ),
// //       ],
// //     ),
// //     child: Stack(
// //       children: [
// //         Positioned(
// //           right: -16,
// //           top: -16,
// //           child: Container(
// //             width: 80,
// //             height: 80,
// //             decoration: BoxDecoration(
// //               shape: BoxShape.circle,
// //               color: Colors.white.withOpacity(0.07),
// //             ),
// //           ),
// //         ),
// //         Row(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             Expanded(
// //               child: Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   Container(
// //                     padding: const EdgeInsets.symmetric(
// //                       horizontal: 8,
// //                       vertical: 3,
// //                     ),
// //                     decoration: BoxDecoration(
// //                       color: Colors.white.withOpacity(0.18),
// //                       borderRadius: BorderRadius.circular(6),
// //                     ),
// //                     child: const Text(
// //                       'FOOD & BEVERAGES',
// //                       style: TextStyle(
// //                         color: Colors.white,
// //                         fontSize: 9,
// //                         fontWeight: FontWeight.w700,
// //                         letterSpacing: 1,
// //                       ),
// //                     ),
// //                   ),
// //                   const SizedBox(height: 8),
// //                   const Text(
// //                     'Standard Plan',
// //                     style: TextStyle(
// //                       color: Colors.white,
// //                       fontSize: 20,
// //                       fontWeight: FontWeight.w900,
// //                       letterSpacing: -0.3,
// //                     ),
// //                   ),
// //                   const SizedBox(height: 4),
// //                   Text(
// //                     'Yearly billing · All features included',
// //                     style: TextStyle(
// //                       color: Colors.white.withOpacity(0.8),
// //                       fontSize: 12,
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //             Column(
// //               crossAxisAlignment: CrossAxisAlignment.end,
// //               children: [
// //                 const Text(
// //                   '/year',
// //                   style: TextStyle(
// //                     color: Colors.white,
// //                     fontSize: 11,
// //                     fontWeight: FontWeight.w500,
// //                   ),
// //                 ),
// //                 const SizedBox(height: 4),
// //                 Container(
// //                   padding: const EdgeInsets.symmetric(
// //                     horizontal: 8,
// //                     vertical: 3,
// //                   ),
// //                   decoration: BoxDecoration(
// //                     color: Colors.white.withOpacity(0.18),
// //                     borderRadius: BorderRadius.circular(6),
// //                   ),
// //                   child: const Text(
// //                     'Billed Yearly',
// //                     style: TextStyle(
// //                       color: Colors.white,
// //                       fontSize: 10,
// //                       fontWeight: FontWeight.w600,
// //                     ),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ],
// //         ),
// //       ],
// //     ),
// //   );
// //
// //   // ── Section Header ───────────────────────────────────────────────────────────
// //   Widget _sectionHeader(String title, IconData icon, Color color) => Padding(
// //     padding: const EdgeInsets.fromLTRB(0, 18, 0, 10),
// //     child: Row(
// //       children: [
// //         Container(
// //           width: 28,
// //           height: 28,
// //           decoration: BoxDecoration(
// //             color: color.withOpacity(0.1),
// //             borderRadius: BorderRadius.circular(8),
// //           ),
// //           child: Icon(icon, color: color, size: 15),
// //         ),
// //         const SizedBox(width: 8),
// //         Text(
// //           title,
// //           style: TextStyle(
// //             fontSize: 13,
// //             fontWeight: FontWeight.w800,
// //             color: color,
// //           ),
// //         ),
// //         const SizedBox(width: 8),
// //         Expanded(child: Divider(color: color.withOpacity(0.15), thickness: 1)),
// //       ],
// //     ),
// //   );
// //
// //   // ── Module Card ──────────────────────────────────────────────────────────────
// //   Widget _buildModuleCard(Module m) {
// //     final isSelected = _toggleState[m.id] ?? false;
// //     final isMandatory = m.defaultIncluded == 'MANDATORY';
// //     final isIncluded = m.defaultIncluded == 'INCLUDE';
// //     final isAddOn = m.defaultIncluded == 'EXCLUDE';
// //
// //     final iconColor = isMandatory
// //         ? _S.accent
// //         : isIncluded
// //         ? _S.green
// //         : isAddOn && isSelected
// //         ? _S.green
// //         : _S.amber;
// //
// //     final bgColor = isMandatory
// //         ? _S.accentLight
// //         : isIncluded
// //         ? _S.greenLight
// //         : isAddOn && isSelected
// //         ? _S.greenLight
// //         : _S.amberLight;
// //
// //     final cardIcon = isMandatory
// //         ? Icons.verified_rounded
// //         : isIncluded
// //         ? Icons.check_circle_rounded
// //         : Icons.extension_rounded;
// //
// //     return Container(
// //       margin: const EdgeInsets.only(bottom: 8),
// //       decoration: BoxDecoration(
// //         color: _S.white,
// //         borderRadius: BorderRadius.circular(12),
// //         border: Border.all(
// //           color: isAddOn && isSelected
// //               ? _S.green.withOpacity(0.4)
// //               : isMandatory
// //               ? _S.accent.withOpacity(0.15)
// //               : _S.border,
// //           width: isAddOn && isSelected ? 1.5 : 1,
// //         ),
// //         boxShadow: [
// //           BoxShadow(
// //             color: _S.shadow,
// //             blurRadius: 6,
// //             offset: const Offset(0, 2),
// //           ),
// //         ],
// //       ),
// //       child: Padding(
// //         padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
// //         child: Row(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             // Icon
// //             Container(
// //               width: 36,
// //               height: 36,
// //               decoration: BoxDecoration(
// //                 color: bgColor,
// //                 borderRadius: BorderRadius.circular(10),
// //               ),
// //               child: Icon(cardIcon, color: iconColor, size: 18),
// //             ),
// //             const SizedBox(width: 12),
// //
// //             // Label + description
// //             Expanded(
// //               child: Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   Text(
// //                     m.code.replaceAll('_', ' '),
// //                     style: const TextStyle(
// //                       fontSize: 13,
// //                       fontWeight: FontWeight.w700,
// //                       color: _S.text1,
// //                     ),
// //                   ),
// //                   if (m.description.isNotEmpty) ...[
// //                     const SizedBox(height: 3),
// //                     Text(
// //                       m.description,
// //                       style: const TextStyle(
// //                         fontSize: 11,
// //                         color: _S.text2,
// //                         height: 1.4,
// //                       ),
// //                     ),
// //                   ],
// //                 ],
// //               ),
// //             ),
// //             const SizedBox(width: 8),
// //
// //             // Right badge / toggle
// //             if (isMandatory)
// //               _mandatoryBadge(m)
// //             else if (isIncluded)
// //               _includedBadge()
// //             else
// //               _addOnToggle(m, isSelected),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _mandatoryBadge(Module m) => Column(
// //     crossAxisAlignment: CrossAxisAlignment.end,
// //     children: [
// //       Container(
// //         padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
// //         decoration: BoxDecoration(
// //           color: _S.accentLight,
// //           borderRadius: BorderRadius.circular(6),
// //           border: Border.all(color: _S.accent.withOpacity(0.2)),
// //         ),
// //         child: const Text(
// //           'Required',
// //           style: TextStyle(
// //             fontSize: 9,
// //             fontWeight: FontWeight.w700,
// //             color: _S.accent,
// //           ),
// //         ),
// //       ),
// //       const SizedBox(height: 5),
// //       Text(
// //         '₹${m.yearlyPrice.toInt()}',
// //         style: const TextStyle(
// //           fontSize: 13,
// //           fontWeight: FontWeight.w800,
// //           color: _S.text1,
// //         ),
// //       ),
// //       const Text('/year', style: TextStyle(fontSize: 9, color: _S.text2)),
// //     ],
// //   );
// //
// //   Widget _includedBadge() => Container(
// //     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
// //     decoration: BoxDecoration(
// //       color: _S.greenLight,
// //       borderRadius: BorderRadius.circular(8),
// //       border: Border.all(color: _S.green.withOpacity(0.2)),
// //     ),
// //     child: const Text(
// //       'Included',
// //       style: TextStyle(
// //         fontSize: 10,
// //         fontWeight: FontWeight.w700,
// //         color: _S.greenDark,
// //       ),
// //     ),
// //   );
// //
// //   Widget _addOnToggle(Module m, bool isSelected) => Column(
// //     crossAxisAlignment: CrossAxisAlignment.end,
// //     children: [
// //       GestureDetector(
// //         onTap: () => setState(() => _toggleState[m.id] = !isSelected),
// //         child: AnimatedContainer(
// //           duration: const Duration(milliseconds: 200),
// //           width: 44,
// //           height: 24,
// //           decoration: BoxDecoration(
// //             color: isSelected ? _S.green : _S.border,
// //             borderRadius: BorderRadius.circular(12),
// //           ),
// //           child: AnimatedAlign(
// //             duration: const Duration(milliseconds: 200),
// //             alignment: isSelected
// //                 ? Alignment.centerRight
// //                 : Alignment.centerLeft,
// //             child: Container(
// //               width: 20,
// //               height: 20,
// //               margin: const EdgeInsets.symmetric(horizontal: 2),
// //               decoration: const BoxDecoration(
// //                 color: Colors.white,
// //                 shape: BoxShape.circle,
// //                 boxShadow: [BoxShadow(color: Color(0x22000000), blurRadius: 3)],
// //               ),
// //             ),
// //           ),
// //         ),
// //       ),
// //       const SizedBox(height: 5),
// //       Text(
// //         '₹${m.yearlyPrice.toInt()}',
// //         style: TextStyle(
// //           fontSize: 12,
// //           fontWeight: FontWeight.w800,
// //           color: isSelected ? _S.green : _S.text2,
// //         ),
// //       ),
// //       const Text('/year', style: TextStyle(fontSize: 9, color: _S.text2)),
// //     ],
// //   );
// //
// //   // ── Payment Bar ──────────────────────────────────────────────────────────────
// //   Widget _buildPaymentBar({
// //     required double total,
// //     required bool canPay,
// //     required int addOnCount,
// //   }) => Container(
// //     padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
// //     decoration: const BoxDecoration(
// //       color: _S.white,
// //       border: Border(top: BorderSide(color: _S.border)),
// //       boxShadow: [
// //         BoxShadow(color: _S.shadowMd, blurRadius: 16, offset: Offset(0, -4)),
// //       ],
// //     ),
// //     child: Column(
// //       mainAxisSize: MainAxisSize.min,
// //       children: [
// //         // Amount row
// //         Row(
// //           children: [
// //             Expanded(
// //               child: Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   const Text(
// //                     'Total Amount',
// //                     style: TextStyle(
// //                       fontSize: 11,
// //                       color: _S.text2,
// //                       fontWeight: FontWeight.w500,
// //                     ),
// //                   ),
// //                   const SizedBox(height: 2),
// //                   Row(
// //                     crossAxisAlignment: CrossAxisAlignment.end,
// //                     children: [
// //                       Text(
// //                         '₹${total.toInt()}',
// //                         style: const TextStyle(
// //                           fontSize: 22,
// //                           fontWeight: FontWeight.w900,
// //                           color: _S.text1,
// //                         ),
// //                       ),
// //                       const Text(
// //                         ' /year',
// //                         style: TextStyle(
// //                           fontSize: 12,
// //                           color: _S.text2,
// //                           fontWeight: FontWeight.w500,
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ],
// //               ),
// //             ),
// //             if (addOnCount > 0)
// //               Container(
// //                 padding: const EdgeInsets.symmetric(
// //                   horizontal: 10,
// //                   vertical: 5,
// //                 ),
// //                 decoration: BoxDecoration(
// //                   color: _S.amberLight,
// //                   borderRadius: BorderRadius.circular(8),
// //                   border: Border.all(color: _S.amber.withOpacity(0.3)),
// //                 ),
// //                 child: Text(
// //                   '+$addOnCount add-on${addOnCount > 1 ? 's' : ''}',
// //                   style: const TextStyle(
// //                     fontSize: 11,
// //                     fontWeight: FontWeight.w700,
// //                     color: _S.amber,
// //                   ),
// //                 ),
// //               ),
// //           ],
// //         ),
// //
// //         const SizedBox(height: 10),
// //
// //         // Terms checkbox
// //         GestureDetector(
// //           onTap: () => setState(() => _termsAccepted = !_termsAccepted),
// //           child: Row(
// //             children: [
// //               AnimatedContainer(
// //                 duration: const Duration(milliseconds: 200),
// //                 width: 20,
// //                 height: 20,
// //                 decoration: BoxDecoration(
// //                   color: _termsAccepted ? _S.green : _S.white,
// //                   borderRadius: BorderRadius.circular(6),
// //                   border: Border.all(
// //                     color: _termsAccepted ? _S.green : _S.border,
// //                     width: 1.5,
// //                   ),
// //                 ),
// //                 child: _termsAccepted
// //                     ? const Icon(
// //                         Icons.check_rounded,
// //                         color: Colors.white,
// //                         size: 13,
// //                       )
// //                     : null,
// //               ),
// //               const SizedBox(width: 10),
// //               const Expanded(
// //                 child: Text(
// //                   'I accept the Terms and Conditions',
// //                   style: TextStyle(
// //                     fontSize: 12,
// //                     color: _S.text2,
// //                     fontWeight: FontWeight.w500,
// //                   ),
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //
// //         const SizedBox(height: 12),
// //
// //         // Pay button
// //         GestureDetector(
// //           onTap: canPay ? _startPayment : null,
// //           child: AnimatedContainer(
// //             duration: const Duration(milliseconds: 200),
// //             width: double.infinity,
// //             padding: const EdgeInsets.symmetric(vertical: 14),
// //             decoration: BoxDecoration(
// //               gradient: canPay
// //                   ? const LinearGradient(
// //                       colors: [Color(0xFF10B981), Color(0xFF059669)],
// //                       begin: Alignment.topLeft,
// //                       end: Alignment.bottomRight,
// //                     )
// //                   : null,
// //               color: canPay ? null : _S.border,
// //               borderRadius: BorderRadius.circular(12),
// //               boxShadow: canPay
// //                   ? [
// //                       BoxShadow(
// //                         color: _S.green.withOpacity(0.4),
// //                         blurRadius: 12,
// //                         offset: const Offset(0, 4),
// //                       ),
// //                     ]
// //                   : null,
// //             ),
// //             child: _isProcessing
// //                 ? const Center(
// //                     child: SizedBox(
// //                       width: 20,
// //                       height: 20,
// //                       child: CircularProgressIndicator(
// //                         color: Colors.white,
// //                         strokeWidth: 2,
// //                       ),
// //                     ),
// //                   )
// //                 : Row(
// //                     mainAxisAlignment: MainAxisAlignment.center,
// //                     children: [
// //                       Icon(
// //                         Icons.lock_rounded,
// //                         color: canPay ? Colors.white : _S.text3,
// //                         size: 16,
// //                       ),
// //                       const SizedBox(width: 8),
// //                       Text(
// //                         canPay
// //                             ? 'Proceed to Payment  ₹${total.toInt()}'
// //                             : 'Accept terms to continue',
// //                         style: TextStyle(
// //                           color: canPay ? Colors.white : _S.text3,
// //                           fontSize: 14,
// //                           fontWeight: FontWeight.w800,
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //           ),
// //         ),
// //       ],
// //     ),
// //   );
// //
// //   // ── Error & Empty States ──────────────────────────────────────────────────────
// //   Widget _buildError(String error) => Center(
// //     child: Padding(
// //       padding: const EdgeInsets.all(24),
// //       child: Column(
// //         mainAxisAlignment: MainAxisAlignment.center,
// //         children: [
// //           Container(
// //             width: 64,
// //             height: 64,
// //             decoration: const BoxDecoration(
// //               color: Color(0xFFFEE2E2),
// //               shape: BoxShape.circle,
// //             ),
// //             child: const Icon(
// //               Icons.error_outline_rounded,
// //               color: Color(0xFFEF4444),
// //               size: 30,
// //             ),
// //           ),
// //           const SizedBox(height: 14),
// //           const Text(
// //             'Failed to load plan',
// //             style: TextStyle(
// //               fontSize: 16,
// //               fontWeight: FontWeight.w700,
// //               color: _S.text1,
// //             ),
// //           ),
// //           const SizedBox(height: 4),
// //           Text(
// //             error,
// //             style: const TextStyle(fontSize: 12, color: _S.text2),
// //             textAlign: TextAlign.center,
// //           ),
// //           const SizedBox(height: 20),
// //           GestureDetector(
// //             onTap: _loadPlan,
// //             child: Container(
// //               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
// //               decoration: BoxDecoration(
// //                 gradient: _S.gradient,
// //                 borderRadius: BorderRadius.circular(10),
// //               ),
// //               child: const Text(
// //                 'Retry',
// //                 style: TextStyle(
// //                   color: Colors.white,
// //                   fontWeight: FontWeight.w700,
// //                 ),
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     ),
// //   );
// //
// //   Widget _buildEmpty() => const Center(
// //     child: Column(
// //       mainAxisAlignment: MainAxisAlignment.center,
// //       children: [
// //         Icon(Icons.subscriptions_rounded, color: _S.text3, size: 48),
// //         SizedBox(height: 14),
// //         Text(
// //           'No plan found',
// //           style: TextStyle(
// //             fontSize: 16,
// //             fontWeight: FontWeight.w700,
// //             color: _S.text1,
// //           ),
// //         ),
// //         SizedBox(height: 4),
// //         Text(
// //           'Please contact support',
// //           style: TextStyle(fontSize: 12, color: _S.text2),
// //         ),
// //       ],
// //     ),
// //   );
// // }
//
// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:razorpay_flutter/razorpay_flutter.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../Api/SubscriptionServices.dart';
// import '../Models/food&beverages/subsctiption_plans.dart';
//
// // ─── Design tokens ─────────────────────────────────────────────────────────────
// class _C {
//   static const bg = Color(0xFFFAFAFC);
//   static const white = Color(0xFFFFFFFF);
//   static const border = Color(0xFFE5E7EB);
//   static const orange = Color(0xFFF97316);
//   static const orangeD = Color(0xFFEA580C);
//   static const orangeL = Color(0xFFFFF7ED);
//   static const green = Color(0xFF10B981);
//   static const greenD = Color(0xFF059669);
//   static const greenL = Color(0xFFD1FAE5);
//   static const greenDk = Color(0xFF065F46);
//   static const amber = Color(0xFFF59E0B);
//   static const amberL = Color(0xFFFEF3C7);
//   static const blue = Color(0xFF3B82F6);
//   static const blueL = Color(0xFFEFF6FF);
//   static const yellow = Color(0xFFFACC15);
//   static const yellowL = Color(0xFFFFFBEB);
//   static const text1 = Color(0xFF111827);
//   static const text2 = Color(0xFF6B7280);
//   static const text3 = Color(0xFF9CA3AF);
//   static const red = Color(0xFFEF4444);
//   static const redL = Color(0xFFFEE2E2);
//
//   static LinearGradient get orangeGrad => const LinearGradient(
//     colors: [orange, orangeD],
//     begin: Alignment.topLeft,
//     end: Alignment.bottomRight,
//   );
//   static LinearGradient get greenGrad => const LinearGradient(
//     colors: [green, greenD],
//     begin: Alignment.topLeft,
//     end: Alignment.bottomRight,
//   );
//   static LinearGradient get amberGrad => const LinearGradient(
//     colors: [amber, Color(0xFFD97706)],
//     begin: Alignment.topLeft,
//     end: Alignment.bottomRight,
//   );
// }
//
// // ─── Screen ───────────────────────────────────────────────────────────────────
// class SubscriptionScreen extends StatefulWidget {
//   const SubscriptionScreen({Key? key}) : super(key: key);
//
//   @override
//   State<SubscriptionScreen> createState() => _SubscriptionScreenState();
// }
//
// class _SubscriptionScreenState extends State<SubscriptionScreen>
//     with SingleTickerProviderStateMixin {
//   final _api = SubscriptionApiService();
//   late AnimationController _animCtrl;
//   late Animation<double> _fadeAnim;
//
//   // ── State ────────────────────────────────────────────────────────────────────
//   SubscriptionPlan? _plan;
//   ActiveSubscription? _activeSub;
//   SubscriptionStatus _subStatus = SubscriptionStatus.loading;
//
//   Map<String, bool> _toggleState = {};
//   bool _termsAccepted = false;
//   bool _isLoading = false;
//   bool _planLoading = true;
//   String? _error;
//
//   bool _showSuccess = false;
//   bool _showRenewalWarning = false;
//   bool _showFreeTrial = false;
//   int _countdown = 5;
//   Timer? _countdownTimer;
//
//   int _vendorId = 0;
//
//   late Razorpay _razorpay;
//   double _pendingAmount = 0;
//
//   @override
//   void initState() {
//     super.initState();
//     _animCtrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 600),
//     );
//     _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
//     _razorpay = Razorpay()
//       ..on(Razorpay.EVENT_PAYMENT_SUCCESS, _onPaySuccess)
//       ..on(Razorpay.EVENT_PAYMENT_ERROR, _onPayError)
//       ..on(Razorpay.EVENT_EXTERNAL_WALLET, _onExternalWallet);
//     _init();
//   }
//
//   @override
//   void dispose() {
//     _razorpay.clear();
//     _animCtrl.dispose();
//     _countdownTimer?.cancel();
//     super.dispose();
//   }
//
//   // ── Init ─────────────────────────────────────────────────────────────────────
//   Future<void> _init() async {
//     final prefs = await SharedPreferences.getInstance();
//     _vendorId = prefs.getInt('vendorId') ?? 0;
//
//     await Future.wait([_loadActiveSub(), _loadPlan()]);
//     _animCtrl.forward();
//   }
//
//   Future<void> _loadActiveSub() async {
//     if (_vendorId == 0) {
//       setState(() => _subStatus = SubscriptionStatus.none);
//       return;
//     }
//     try {
//       final sub = await _api.fetchActiveSubscription(_vendorId);
//       if (!mounted) return;
//       setState(() {
//         _activeSub = sub;
//         if (sub == null) {
//           _subStatus = SubscriptionStatus.none;
//         } else if (sub.isTrial) {
//           _subStatus = SubscriptionStatus.trial;
//         } else if (sub.isExpired) {
//           _subStatus = SubscriptionStatus.expired;
//         } else {
//           _subStatus = SubscriptionStatus.active;
//         }
//       });
//     } catch (e) {
//       setState(() => _subStatus = SubscriptionStatus.none);
//     }
//   }
//
//   Future<void> _loadPlan() async {
//     try {
//       final plan = await _api.fetchSubscriptionPlan();
//       if (!mounted) return;
//       if (plan != null) {
//         final initial = <String, bool>{};
//         for (final m in plan.modules) {
//           if (m.isMandatory || m.isIncluded)
//             initial[m.code] = true;
//           else
//             initial[m.code] = false;
//         }
//         // Pre-select from active subscription
//         if (_activeSub != null) {
//           for (final code in _activeSub!.selectedModules) {
//             initial[code] = true;
//           }
//         }
//         setState(() {
//           _plan = plan;
//           _toggleState = initial;
//           _planLoading = false;
//         });
//       } else {
//         setState(() {
//           _error = 'Failed to load subscription plans';
//           _planLoading = false;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _error = e.toString();
//         _planLoading = false;
//       });
//     }
//   }
//
//   // ── Totals ───────────────────────────────────────────────────────────────────
//   double get _subtotal => _plan == null
//       ? 0
//       : _api.computeSubtotal(
//           allModules: _plan!.modules,
//           toggleState: _toggleState,
//         );
//
//   double get _gst => _subtotal * 0.18;
//   double get _grandTotal => _subtotal + _gst;
//
//   List<String> get _selectedCodes => _plan == null
//       ? []
//       : _api.resolveSelectedModuleCodes(
//           allModules: _plan!.modules,
//           toggleState: _toggleState,
//         );
//
//   // ── Subscription state helpers ────────────────────────────────────────────────
//   bool get _shouldShowRenew =>
//       _subStatus == SubscriptionStatus.expired ||
//       (_subStatus == SubscriptionStatus.active &&
//           (_activeSub?.remainingDays ?? 0) <= 7);
//
//   bool get _shouldShowNew =>
//       _subStatus == SubscriptionStatus.none ||
//       _subStatus == SubscriptionStatus.trial;
//
//   bool get _shouldShowFreeTrial {
//     final prefs_future = SharedPreferences.getInstance();
//     return _subStatus == SubscriptionStatus.none;
//   }
//
//   bool get _canPay =>
//       _termsAccepted && !_isLoading && _selectedCodes.isNotEmpty;
//
//   // ── Payment ───────────────────────────────────────────────────────────────────
//   Future<void> _handlePayButton() async {
//     if (_selectedCodes.isEmpty) {
//       _snack('Please select at least one module', Colors.orange);
//       return;
//     }
//     if (!_termsAccepted) {
//       _snack('Please accept Terms & Conditions', Colors.orange);
//       return;
//     }
//
//     if (_subStatus == SubscriptionStatus.active &&
//         (_activeSub?.remainingDays ?? 0) > 7) {
//       _showActiveWarningDialog();
//       return;
//     }
//
//     if (_shouldShowRenew &&
//         _subStatus == SubscriptionStatus.active &&
//         (_activeSub?.remainingDays ?? 0) <= 7) {
//       setState(() => _showRenewalWarning = true);
//       return;
//     }
//
//     await _startPayment();
//   }
//
//   Future<void> _startPayment() async {
//     setState(() {
//       _isLoading = true;
//       _showRenewalWarning = false;
//     });
//     try {
//       final amount = _grandTotal;
//       final order = await _api.createOrder(amount: amount, vendorId: _vendorId);
//       final orderId = order['orderId'] ?? order['id'];
//       if (orderId == null) throw Exception('Order ID missing from backend');
//
//       _pendingAmount = amount;
//       _razorpay.open({
//         'key': _api.razorpayKey,
//         'amount': (amount * 100).toInt(),
//         'currency': 'INR',
//         'order_id': orderId,
//         'name': 'Maamaas Subscription',
//         'description': _shouldShowRenew
//             ? 'Renew Subscription'
//             : 'New Subscription',
//         'prefill': {'method': 'upi'},
//         'theme': {'color': _shouldShowRenew ? '#F59E0B' : '#059669'},
//       });
//     } catch (e) {
//       _snack('Payment error: $e', _C.red);
//       setState(() => _isLoading = false);
//     }
//   }
//
//   void _onPaySuccess(PaymentSuccessResponse r) async {
//     try {
//       await _api.capturePayment(
//         paymentId: r.paymentId!,
//         amount: _pendingAmount,
//         vendorId: _vendorId,
//       );
//
//       if (_shouldShowRenew) {
//         await _api.renewSubscription(
//           vendorId: _vendorId,
//           selectedModules: _selectedCodes,
//           paymentId: r.paymentId!,
//           totalAmount: _pendingAmount,
//           termsAccepted: _termsAccepted,
//         );
//       } else {
//         await _api.createSubscription(
//           vendorId: _vendorId,
//           selectedModules: _selectedCodes,
//           paymentId: r.paymentId!,
//           totalAmount: _pendingAmount,
//           termsAccepted: _termsAccepted,
//         );
//       }
//       _startSuccessCountdown();
//     } catch (e) {
//       _snack(
//         'Payment captured but setup failed. Contact support.',
//         Colors.orange,
//       );
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }
//
//   void _onPayError(PaymentFailureResponse r) {
//     setState(() => _isLoading = false);
//     _snack('Payment failed ❌ ${r.message ?? ''}', _C.red);
//   }
//
//   void _onExternalWallet(ExternalWalletResponse r) {
//     setState(() => _isLoading = false);
//   }
//
//   // ── Free Trial ────────────────────────────────────────────────────────────────
//   Future<void> _activateFreeTrial() async {
//     if (!_termsAccepted) {
//       _snack('Please accept Terms & Conditions', Colors.orange);
//       return;
//     }
//     setState(() {
//       _isLoading = true;
//       _showFreeTrial = false;
//     });
//     try {
//       final allCodes = _plan?.modules.map((m) => m.code).toList() ?? [];
//       await _api.activateFreeTrial(
//         vendorId: _vendorId,
//         allModules: allCodes,
//         termsAccepted: _termsAccepted,
//       );
//       _startSuccessCountdown();
//     } catch (e) {
//       _snack('Free trial activation failed: $e', _C.red);
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }
//
//   // ── Success countdown ─────────────────────────────────────────────────────────
//   void _startSuccessCountdown() {
//     setState(() {
//       _showSuccess = true;
//       _countdown = 5;
//     });
//     _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
//       if (_countdown <= 1) {
//         t.cancel();
//         if (mounted) {
//           setState(() => _showSuccess = false);
//           Navigator.of(context).pushReplacementNamed('/fooddashboard');
//         }
//       } else {
//         setState(() => _countdown--);
//       }
//     });
//   }
//
//   void _showActiveWarningDialog() {
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 color: _C.amberL,
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: const Icon(
//                 Icons.warning_amber_rounded,
//                 color: _C.amber,
//                 size: 20,
//               ),
//             ),
//             const SizedBox(width: 10),
//             const Text(
//               'Active Subscription',
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
//             ),
//           ],
//         ),
//         content: Text(
//           'Your current plan is valid for ${_activeSub?.remainingDays ?? 0} more days '
//           '(until ${_activeSub?.endDate ?? ''}).\n\n'
//           'You can renew when your plan has 7 days or less remaining.',
//           style: const TextStyle(color: _C.text2, fontSize: 14),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text(
//               'OK',
//               style: TextStyle(fontWeight: FontWeight.w700),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _snack(String msg, Color color) {
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
//       ),
//     );
//   }
//
//   // ─────────────────────────────────────────────────────────────────────────────
//   // BUILD
//   // ─────────────────────────────────────────────────────────────────────────────
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: _C.bg,
//       body: Stack(
//         children: [
//           SafeArea(
//             child: Column(
//               children: [
//                 _buildHeader(),
//                 if (_planLoading)
//                   const Expanded(
//                     child: Center(
//                       child: CircularProgressIndicator(
//                         color: _C.orange,
//                         strokeWidth: 2,
//                       ),
//                     ),
//                   )
//                 else if (_error != null)
//                   Expanded(child: _buildError())
//                 else
//                   Expanded(
//                     child: FadeTransition(
//                       opacity: _fadeAnim,
//                       child: SingleChildScrollView(
//                         padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
//                         child: Column(
//                           children: [
//                             // Active subscription banner
//                             if (_activeSub != null) _buildSubBanner(),
//                             // Plan hero
//                             _buildPlanHero(),
//                             // Base Plan
//                             if (_plan!.basePlan.isNotEmpty) ...[
//                               _sectionTitle(
//                                 'Core Platform',
//                                 Icons.verified_rounded,
//                                 _C.orange,
//                               ),
//                               ..._plan!.basePlan.map(_buildModuleCard),
//                             ],
//                             // Feature Add-Ons
//                             if (_plan!.featureAddOns.isNotEmpty) ...[
//                               _sectionTitle(
//                                 'Optional Add-Ons',
//                                 Icons.add_circle_rounded,
//                                 _C.blue,
//                               ),
//                               ..._plan!.featureAddOns.map(_buildModuleCard),
//                             ],
//                             // Order Types
//                             if (_plan!.orderTypes.isNotEmpty) ...[
//                               _sectionTitle(
//                                 'Order Channels',
//                                 Icons.storefront_rounded,
//                                 _C.green,
//                               ),
//                               ..._plan!.orderTypes.map(_buildModuleCard),
//                             ],
//                             _buildUsagePolicy(),
//                             _buildSettlementInfo(),
//                             _buildBillingSummary(),
//                             _buildTermsBox(),
//                             _buildActionButtons(),
//                             const SizedBox(height: 16),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//
//           // Popups
//           if (_showSuccess) _buildSuccessOverlay(),
//           if (_showRenewalWarning) _buildRenewalWarningOverlay(),
//           if (_showFreeTrial) _buildFreeTrialOverlay(),
//           if (_isLoading && !_showSuccess) _buildLoadingOverlay(),
//         ],
//       ),
//     );
//   }
//
//   // ── Header ───────────────────────────────────────────────────────────────────
//   Widget _buildHeader() => Container(
//     padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
//     decoration: const BoxDecoration(
//       color: _C.white,
//       border: Border(bottom: BorderSide(color: _C.border)),
//       boxShadow: [
//         BoxShadow(
//           color: Color(0x08000000),
//           blurRadius: 8,
//           offset: Offset(0, 2),
//         ),
//       ],
//     ),
//     child: Row(
//       children: [
//         GestureDetector(
//           onTap: () => Navigator.pop(context),
//           child: Container(
//             width: 36,
//             height: 36,
//             decoration: BoxDecoration(
//               color: _C.bg,
//               borderRadius: BorderRadius.circular(10),
//               border: Border.all(color: _C.border),
//             ),
//             child: const Icon(
//               Icons.arrow_back_ios_rounded,
//               color: _C.text1,
//               size: 15,
//             ),
//           ),
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 'Subscription Plans',
//                 style: TextStyle(
//                   fontSize: 17,
//                   fontWeight: FontWeight.w800,
//                   color: _C.text1,
//                 ),
//               ),
//               Text(
//                 'MAAMAAS Restaurant Platform',
//                 style: TextStyle(
//                   fontSize: 11,
//                   color: _C.text2.withOpacity(0.8),
//                 ),
//               ),
//             ],
//           ),
//         ),
//         if (_activeSub != null)
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//             decoration: BoxDecoration(
//               color: _subStatus == SubscriptionStatus.active
//                   ? _C.greenL
//                   : _C.amberL,
//               borderRadius: BorderRadius.circular(20),
//               border: Border.all(
//                 color: _subStatus == SubscriptionStatus.active
//                     ? _C.green.withOpacity(0.3)
//                     : _C.amber.withOpacity(0.3),
//               ),
//             ),
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Container(
//                   width: 6,
//                   height: 6,
//                   decoration: BoxDecoration(
//                     color: _subStatus == SubscriptionStatus.active
//                         ? _C.greenD
//                         : _C.amber,
//                     shape: BoxShape.circle,
//                   ),
//                 ),
//                 const SizedBox(width: 5),
//                 Text(
//                   _subStatus == SubscriptionStatus.active ? 'Active' : 'Trial',
//                   style: TextStyle(
//                     fontSize: 11,
//                     fontWeight: FontWeight.w700,
//                     color: _subStatus == SubscriptionStatus.active
//                         ? _C.greenDk
//                         : _C.amber,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//       ],
//     ),
//   );
//
//   // ── Active Sub Banner ─────────────────────────────────────────────────────────
//   Widget _buildSubBanner() {
//     final sub = _activeSub!;
//     final isUrgent = sub.remainingDays <= 7;
//     return Container(
//       margin: const EdgeInsets.only(top: 16),
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: isUrgent ? _C.amberL : _C.greenL,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//           color: isUrgent
//               ? _C.amber.withOpacity(0.4)
//               : _C.green.withOpacity(0.3),
//         ),
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 40,
//             height: 40,
//             decoration: BoxDecoration(
//               color: isUrgent
//                   ? _C.amber.withOpacity(0.15)
//                   : _C.green.withOpacity(0.1),
//               shape: BoxShape.circle,
//             ),
//             child: Icon(
//               isUrgent ? Icons.warning_amber_rounded : Icons.verified_rounded,
//               color: isUrgent ? _C.amber : _C.greenD,
//               size: 20,
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   isUrgent
//                       ? '⚠️ Renewal Required Soon'
//                       : '✅ Active Subscription',
//                   style: TextStyle(
//                     fontSize: 13,
//                     fontWeight: FontWeight.w800,
//                     color: isUrgent ? _C.amber : _C.greenDk,
//                   ),
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   isUrgent
//                       ? '${sub.remainingDays} days left — renew now to avoid disruption'
//                       : '${sub.remainingDays} days remaining · Valid till ${sub.endDate}',
//                   style: const TextStyle(fontSize: 11, color: _C.text2),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ── Plan Hero ─────────────────────────────────────────────────────────────────
//   Widget _buildPlanHero() => Container(
//     margin: const EdgeInsets.only(top: 16, bottom: 4),
//     padding: const EdgeInsets.all(18),
//     decoration: BoxDecoration(
//       gradient: const LinearGradient(
//         colors: [Color(0xFFEA580C), Color(0xFFF97316), Color(0xFFFB923C)],
//         begin: Alignment.topLeft,
//         end: Alignment.bottomRight,
//       ),
//       borderRadius: BorderRadius.circular(16),
//       boxShadow: [
//         BoxShadow(
//           color: _C.orange.withOpacity(0.35),
//           blurRadius: 18,
//           offset: const Offset(0, 6),
//         ),
//       ],
//     ),
//     child: Stack(
//       children: [
//         Positioned(
//           right: -20,
//           top: -20,
//           child: Container(
//             width: 90,
//             height: 90,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               color: Colors.white.withOpacity(0.06),
//             ),
//           ),
//         ),
//         Positioned(
//           right: 20,
//           bottom: -10,
//           child: Container(
//             width: 50,
//             height: 50,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               color: Colors.white.withOpacity(0.04),
//             ),
//           ),
//         ),
//         Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 8,
//                       vertical: 3,
//                     ),
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.18),
//                       borderRadius: BorderRadius.circular(6),
//                     ),
//                     child: const Text(
//                       'FOOD & BEVERAGES',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 9,
//                         fontWeight: FontWeight.w700,
//                         letterSpacing: 1.2,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   const Text(
//                     'Standard Plan',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 22,
//                       fontWeight: FontWeight.w900,
//                       letterSpacing: -0.3,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     'Yearly billing · GST inclusive · All channels',
//                     style: TextStyle(
//                       color: Colors.white.withOpacity(0.85),
//                       fontSize: 12,
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   Row(
//                     children: [
//                       _heroBadge(Icons.shield_rounded, 'Secure'),
//                       const SizedBox(width: 8),
//                       _heroBadge(Icons.bolt_rounded, 'Instant'),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.end,
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(10),
//                   decoration: BoxDecoration(
//                     color: Colors.white.withOpacity(0.15),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: const Icon(
//                     Icons.restaurant_rounded,
//                     color: Colors.white,
//                     size: 24,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ],
//     ),
//   );
//
//   Widget _heroBadge(IconData icon, String label) => Container(
//     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//     decoration: BoxDecoration(
//       color: Colors.white.withOpacity(0.15),
//       borderRadius: BorderRadius.circular(6),
//     ),
//     child: Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Icon(icon, color: Colors.white, size: 11),
//         const SizedBox(width: 4),
//         Text(
//           label,
//           style: const TextStyle(
//             color: Colors.white,
//             fontSize: 10,
//             fontWeight: FontWeight.w700,
//           ),
//         ),
//       ],
//     ),
//   );
//
//   // ── Section Title ─────────────────────────────────────────────────────────────
//   Widget _sectionTitle(String title, IconData icon, Color color) => Padding(
//     padding: const EdgeInsets.fromLTRB(0, 20, 0, 10),
//     child: Row(
//       children: [
//         Container(
//           width: 30,
//           height: 30,
//           decoration: BoxDecoration(
//             color: color.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Icon(icon, color: color, size: 15),
//         ),
//         const SizedBox(width: 8),
//         Text(
//           title,
//           style: TextStyle(
//             fontSize: 13,
//             fontWeight: FontWeight.w800,
//             color: color,
//           ),
//         ),
//         const SizedBox(width: 8),
//         Expanded(child: Divider(color: color.withOpacity(0.2), thickness: 1)),
//       ],
//     ),
//   );
//
//   // ── Module Card ───────────────────────────────────────────────────────────────
//   Widget _buildModuleCard(PlanModule m) {
//     final isSelected = _toggleState[m.code] ?? false;
//
//     Color accentColor;
//     Color bgColor;
//     IconData moduleIcon;
//
//     if (m.isMandatory) {
//       accentColor = _C.orange;
//       bgColor = _C.orangeL;
//     } else if (m.isIncluded) {
//       accentColor = _C.green;
//       bgColor = _C.greenL;
//     } else {
//       accentColor = isSelected ? _C.green : _C.amber;
//       bgColor = isSelected ? _C.greenL : _C.amberL;
//     }
//
//     moduleIcon = _getModuleIcon(m.code);
//
//     return Container(
//       margin: const EdgeInsets.only(bottom: 8),
//       decoration: BoxDecoration(
//         color: _C.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//           color: m.isAddOn && isSelected
//               ? _C.green.withOpacity(0.4)
//               : m.isMandatory
//               ? _C.orange.withOpacity(0.15)
//               : _C.border,
//           width: m.isAddOn && isSelected ? 1.5 : 1,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.04),
//             blurRadius: 6,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Padding(
//         padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             // Icon
//             Container(
//               width: 38,
//               height: 38,
//               decoration: BoxDecoration(
//                 color: bgColor,
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: Icon(moduleIcon, color: accentColor, size: 18),
//             ),
//             const SizedBox(width: 12),
//
//             // Text
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     m.displayName,
//                     style: const TextStyle(
//                       fontSize: 13,
//                       fontWeight: FontWeight.w700,
//                       color: _C.text1,
//                     ),
//                   ),
//                   if (m.description.isNotEmpty &&
//                       m.description != 'string') ...[
//                     const SizedBox(height: 2),
//                     Text(
//                       m.description,
//                       style: const TextStyle(
//                         fontSize: 11,
//                         color: _C.text2,
//                         height: 1.3,
//                       ),
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ],
//                 ],
//               ),
//             ),
//             const SizedBox(width: 10),
//
//             // Right side
//             if (m.isMandatory)
//               _mandatoryRight(m)
//             else if (m.isIncluded)
//               _includedBadge()
//             else
//               _toggleRight(m, isSelected),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _mandatoryRight(PlanModule m) => Column(
//     crossAxisAlignment: CrossAxisAlignment.end,
//     children: [
//       Container(
//         padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
//         decoration: BoxDecoration(
//           color: _C.orangeL,
//           borderRadius: BorderRadius.circular(6),
//           border: Border.all(color: _C.orange.withOpacity(0.2)),
//         ),
//         child: const Text(
//           'Required',
//           style: TextStyle(
//             fontSize: 9,
//             fontWeight: FontWeight.w700,
//             color: _C.orange,
//           ),
//         ),
//       ),
//       const SizedBox(height: 4),
//       Text(
//         '₹${m.yearlyPrice.toInt()}',
//         style: const TextStyle(
//           fontSize: 13,
//           fontWeight: FontWeight.w800,
//           color: _C.text1,
//         ),
//       ),
//       const Text('/yr', style: TextStyle(fontSize: 9, color: _C.text2)),
//     ],
//   );
//
//   Widget _includedBadge() => Container(
//     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
//     decoration: BoxDecoration(
//       color: _C.greenL,
//       borderRadius: BorderRadius.circular(8),
//       border: Border.all(color: _C.green.withOpacity(0.2)),
//     ),
//     child: const Text(
//       'Free',
//       style: TextStyle(
//         fontSize: 11,
//         fontWeight: FontWeight.w700,
//         color: _C.greenDk,
//       ),
//     ),
//   );
//
//   Widget _toggleRight(PlanModule m, bool isSelected) => Column(
//     crossAxisAlignment: CrossAxisAlignment.end,
//     children: [
//       GestureDetector(
//         onTap: () => setState(() => _toggleState[m.code] = !isSelected),
//         child: AnimatedContainer(
//           duration: const Duration(milliseconds: 200),
//           width: 44,
//           height: 24,
//           decoration: BoxDecoration(
//             color: isSelected ? _C.green : _C.border,
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: AnimatedAlign(
//             duration: const Duration(milliseconds: 200),
//             alignment: isSelected
//                 ? Alignment.centerRight
//                 : Alignment.centerLeft,
//             child: Container(
//               width: 20,
//               height: 20,
//               margin: const EdgeInsets.symmetric(horizontal: 2),
//               decoration: const BoxDecoration(
//                 color: Colors.white,
//                 shape: BoxShape.circle,
//                 boxShadow: [BoxShadow(color: Color(0x22000000), blurRadius: 3)],
//               ),
//             ),
//           ),
//         ),
//       ),
//       const SizedBox(height: 4),
//       Text(
//         '₹${m.yearlyPrice.toInt()}',
//         style: TextStyle(
//           fontSize: 12,
//           fontWeight: FontWeight.w800,
//           color: isSelected ? _C.green : _C.text2,
//         ),
//       ),
//       const Text('/yr', style: TextStyle(fontSize: 9, color: _C.text2)),
//     ],
//   );
//
//   // ── Usage Policy ─────────────────────────────────────────────────────────────
//   Widget _buildUsagePolicy() => Container(
//     margin: const EdgeInsets.only(top: 20),
//     padding: const EdgeInsets.all(16),
//     decoration: BoxDecoration(
//       color: _C.yellowL,
//       borderRadius: BorderRadius.circular(14),
//       border: Border.all(color: _C.yellow.withOpacity(0.5)),
//     ),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Container(
//               width: 34,
//               height: 34,
//               decoration: BoxDecoration(
//                 color: _C.amberL,
//                 borderRadius: BorderRadius.circular(17),
//               ),
//               child: const Center(
//                 child: Text(
//                   'i',
//                   style: TextStyle(
//                     fontWeight: FontWeight.w900,
//                     color: Color(0xFFB45309),
//                     fontSize: 15,
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(width: 10),
//             const Text(
//               'Platform Usage Policy',
//               style: TextStyle(
//                 fontSize: 15,
//                 fontWeight: FontWeight.w800,
//                 color: _C.text1,
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 14),
//         _policySection('Credit Model (Earn Now, Pay Later)', [
//           'Charges are added to your outstanding balance automatically',
//           'Clear dues within billing cycle for smooth operations',
//           'Credit limit reached → Cash/UPI payment options disabled',
//           'Other features remain active; transactions may be restricted',
//         ]),
//         const SizedBox(height: 12),
//         _policySection('Order Processing Fees', [
//           'Dine-In Orders → 0.5% per order',
//           'Takeaway Orders → 0.5% per order',
//         ]),
//         const SizedBox(height: 12),
//         _policySection('Tax Policy', [
//           'All platform charges are subject to GST as per government regulations',
//         ]),
//       ],
//     ),
//   );
//
//   Widget _policySection(String title, List<String> points) => Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       Text(
//         title,
//         style: const TextStyle(
//           fontSize: 12,
//           fontWeight: FontWeight.w700,
//           color: _C.text1,
//         ),
//       ),
//       const SizedBox(height: 6),
//       ...points.map(
//         (p) => Padding(
//           padding: const EdgeInsets.only(bottom: 4),
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text('• ', style: TextStyle(fontSize: 12, color: _C.text2)),
//               Expanded(
//                 child: Text(
//                   p,
//                   style: const TextStyle(
//                     fontSize: 12,
//                     color: _C.text2,
//                     height: 1.4,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     ],
//   );
//
//   // ── Settlement Info ───────────────────────────────────────────────────────────
//   Widget _buildSettlementInfo() => Container(
//     margin: const EdgeInsets.only(top: 12),
//     padding: const EdgeInsets.all(16),
//     decoration: BoxDecoration(
//       color: _C.blueL,
//       borderRadius: BorderRadius.circular(14),
//       border: Border.all(color: _C.blue.withOpacity(0.2)),
//     ),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Container(
//               width: 36,
//               height: 36,
//               decoration: BoxDecoration(
//                 color: _C.blue.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(18),
//               ),
//               child: const Center(
//                 child: Text(
//                   '₹',
//                   style: TextStyle(
//                     fontWeight: FontWeight.w900,
//                     color: Color(0xFF2563EB),
//                     fontSize: 16,
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(width: 10),
//             const Text(
//               'Vendor Payment Settlement',
//               style: TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w800,
//                 color: _C.text1,
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 10),
//         ...[
//           'Customer payments are processed through a secure payment gateway.',
//           'Vendor earnings are transferred within 48 working hours after payment confirmation.',
//           'Track all settlements in the Accounts & Finance Dashboard.',
//         ].map(
//           (t) => Padding(
//             padding: const EdgeInsets.only(bottom: 6),
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   '• ',
//                   style: TextStyle(fontSize: 13, color: _C.text2),
//                 ),
//                 Expanded(
//                   child: Text(
//                     t,
//                     style: const TextStyle(
//                       fontSize: 12,
//                       color: _C.text2,
//                       height: 1.5,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     ),
//   );
//
//   // ── Billing Summary ───────────────────────────────────────────────────────────
//   Widget _buildBillingSummary() => Container(
//     margin: const EdgeInsets.only(top: 12),
//     decoration: BoxDecoration(
//       color: _C.white,
//       borderRadius: BorderRadius.circular(14),
//       border: Border.all(color: _C.border),
//       boxShadow: [
//         BoxShadow(
//           color: Colors.black.withOpacity(0.04),
//           blurRadius: 10,
//           offset: const Offset(0, 4),
//         ),
//       ],
//     ),
//     child: Column(
//       children: [
//         // Header
//         Container(
//           padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(colors: [_C.orange, _C.orangeD]),
//             borderRadius: BorderRadius.only(
//               topLeft: Radius.circular(14),
//               topRight: Radius.circular(14),
//             ),
//           ),
//           child: Row(
//             children: [
//               const Icon(
//                 Icons.receipt_long_rounded,
//                 color: Colors.white,
//                 size: 18,
//               ),
//               const SizedBox(width: 8),
//               const Text(
//                 'Billing Summary',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 14,
//                   fontWeight: FontWeight.w800,
//                 ),
//               ),
//             ],
//           ),
//         ),
//         Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             children: [
//               _billRow(
//                 'Platform Activation',
//                 _subtotal -
//                     (_plan?.modules
//                             .where(
//                               (m) =>
//                                   m.isAddOn && (_toggleState[m.code] ?? false),
//                             )
//                             .fold(0.0, (s, m) => s! + m.yearlyPrice) ??
//                         0),
//               ),
//               const SizedBox(height: 8),
//               _billRow(
//                 'Add-On Modules',
//                 _plan?.modules
//                         .where(
//                           (m) => m.isAddOn && (_toggleState[m.code] ?? false),
//                         )
//                         .fold(0.0, (s, m) => s! + m.yearlyPrice) ??
//                     0,
//               ),
//               Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 10),
//                 child: Divider(color: _C.border, thickness: 1),
//               ),
//               _billRow('Subtotal', _subtotal, bold: true),
//               const SizedBox(height: 6),
//               _billRow('GST (18%)', _gst),
//             ],
//           ),
//         ),
//         Container(
//           padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
//           decoration: const BoxDecoration(
//             color: _C.greenL,
//             borderRadius: BorderRadius.only(
//               bottomLeft: Radius.circular(14),
//               bottomRight: Radius.circular(14),
//             ),
//           ),
//           child: Row(
//             children: [
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'Total Payable (Yearly)',
//                       style: TextStyle(fontSize: 12, color: _C.greenDk),
//                     ),
//                     Text(
//                       '₹${_grandTotal.toStringAsFixed(0)}',
//                       style: const TextStyle(
//                         fontSize: 26,
//                         fontWeight: FontWeight.w900,
//                         color: _C.greenDk,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 12,
//                   vertical: 6,
//                 ),
//                 decoration: BoxDecoration(
//                   color: _C.green.withOpacity(0.2),
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: const Text(
//                   'INR • Yearly',
//                   style: TextStyle(
//                     fontSize: 11,
//                     fontWeight: FontWeight.w700,
//                     color: _C.greenDk,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     ),
//   );
//
//   Widget _billRow(String label, double amount, {bool bold = false}) => Row(
//     children: [
//       Expanded(
//         child: Text(
//           label,
//           style: TextStyle(
//             fontSize: 13,
//             color: bold ? _C.text1 : _C.text2,
//             fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
//           ),
//         ),
//       ),
//       Text(
//         '₹${amount.toStringAsFixed(0)}',
//         style: TextStyle(
//           fontSize: 13,
//           fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
//           color: bold ? _C.text1 : _C.text2,
//         ),
//       ),
//     ],
//   );
//
//   // ── Terms Box ─────────────────────────────────────────────────────────────────
//   Widget _buildTermsBox() => Container(
//     margin: const EdgeInsets.only(top: 12),
//     padding: const EdgeInsets.all(14),
//     decoration: BoxDecoration(
//       color: _C.bg,
//       borderRadius: BorderRadius.circular(12),
//       border: Border.all(color: _C.border),
//     ),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         GestureDetector(
//           onTap: () => setState(() => _termsAccepted = !_termsAccepted),
//           child: Row(
//             children: [
//               AnimatedContainer(
//                 duration: const Duration(milliseconds: 200),
//                 width: 22,
//                 height: 22,
//                 decoration: BoxDecoration(
//                   color: _termsAccepted ? _C.green : _C.white,
//                   borderRadius: BorderRadius.circular(6),
//                   border: Border.all(
//                     color: _termsAccepted ? _C.green : _C.border,
//                     width: 1.5,
//                   ),
//                 ),
//                 child: _termsAccepted
//                     ? const Icon(
//                         Icons.check_rounded,
//                         color: Colors.white,
//                         size: 14,
//                       )
//                     : null,
//               ),
//               const SizedBox(width: 10),
//               const Expanded(
//                 child: Text(
//                   'I confirm that I have read and agree to the MAAMAAS Terms & Conditions, '
//                   'Platform Usage Policy, and Vendor Settlement Terms.',
//                   style: TextStyle(fontSize: 12, color: _C.text2, height: 1.4),
//                 ),
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(height: 10),
//         ...[
//           'Subscription fee is for account activation only',
//           'Platform commissions or service charges may apply',
//           'Vendor payments settled within 48 working hours',
//           'All charges include GST',
//         ].map(
//           (t) => Padding(
//             padding: const EdgeInsets.only(bottom: 3),
//             child: Row(
//               children: [
//                 const Text(
//                   '• ',
//                   style: TextStyle(fontSize: 11, color: _C.text3),
//                 ),
//                 Expanded(
//                   child: Text(
//                     t,
//                     style: const TextStyle(fontSize: 11, color: _C.text3),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     ),
//   );
//
//   // ── Action Buttons ────────────────────────────────────────────────────────────
//   Widget _buildActionButtons() {
//     final showFreeTrialBtn = _subStatus == SubscriptionStatus.none;
//
//     return Column(
//       children: [
//         const SizedBox(height: 14),
//         // Free trial button
//         if (showFreeTrialBtn) ...[
//           GestureDetector(
//             onTap: _termsAccepted
//                 ? () => setState(() => _showFreeTrial = true)
//                 : () =>
//                       _snack('Accept terms to start free trial', Colors.orange),
//             child: Container(
//               width: double.infinity,
//               padding: const EdgeInsets.symmetric(vertical: 14),
//               decoration: BoxDecoration(
//                 color: _termsAccepted ? Colors.transparent : _C.bg,
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(
//                   color: _termsAccepted ? _C.amber : _C.border,
//                   width: 1.5,
//                 ),
//                 gradient: _termsAccepted
//                     ? LinearGradient(
//                         colors: [_C.amberL, const Color(0xFFFEF9C3)],
//                       )
//                     : null,
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(
//                     Icons.card_giftcard_rounded,
//                     color: _termsAccepted ? _C.amber : _C.text3,
//                     size: 18,
//                   ),
//                   const SizedBox(width: 8),
//                   Text(
//                     'Start 7-Day Free Trial',
//                     style: TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.w800,
//                       color: _termsAccepted ? _C.amber : _C.text3,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           const SizedBox(height: 10),
//         ],
//         // Main pay button
//         GestureDetector(
//           onTap: _canPay ? _handlePayButton : null,
//           child: AnimatedContainer(
//             duration: const Duration(milliseconds: 200),
//             width: double.infinity,
//             padding: const EdgeInsets.symmetric(vertical: 16),
//             decoration: BoxDecoration(
//               gradient: _canPay
//                   ? (_shouldShowRenew ? _C.amberGrad : _C.greenGrad)
//                   : null,
//               color: _canPay ? null : _C.border,
//               borderRadius: BorderRadius.circular(12),
//               boxShadow: _canPay
//                   ? [
//                       BoxShadow(
//                         color: (_shouldShowRenew ? _C.amber : _C.green)
//                             .withOpacity(0.4),
//                         blurRadius: 14,
//                         offset: const Offset(0, 5),
//                       ),
//                     ]
//                   : null,
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(
//                   _shouldShowRenew
//                       ? Icons.autorenew_rounded
//                       : Icons.lock_rounded,
//                   color: _canPay ? Colors.white : _C.text3,
//                   size: 18,
//                 ),
//                 const SizedBox(width: 8),
//                 Text(
//                   _canPay
//                       ? (_shouldShowRenew
//                             ? 'Renew Plan  ₹${_grandTotal.toStringAsFixed(0)}'
//                             : 'Pay  ₹${_grandTotal.toStringAsFixed(0)}')
//                       : 'Accept terms to continue',
//                   style: TextStyle(
//                     fontSize: 15,
//                     fontWeight: FontWeight.w800,
//                     color: _canPay ? Colors.white : _C.text3,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   // ── Overlays ──────────────────────────────────────────────────────────────────
//   Widget _buildSuccessOverlay() => _overlay(
//     child: Container(
//       margin: const EdgeInsets.all(24),
//       padding: const EdgeInsets.all(28),
//       decoration: BoxDecoration(
//         color: _C.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 30),
//         ],
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(
//             width: 72,
//             height: 72,
//             decoration: BoxDecoration(
//               gradient: _C.greenGrad,
//               shape: BoxShape.circle,
//               boxShadow: [
//                 BoxShadow(color: _C.green.withOpacity(0.35), blurRadius: 18),
//               ],
//             ),
//             child: const Icon(
//               Icons.check_rounded,
//               color: Colors.white,
//               size: 34,
//             ),
//           ),
//           const SizedBox(height: 18),
//           const Text(
//             'Payment Successful! 🎉',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.w900,
//               color: _C.text1,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 8),
//           const Text(
//             'Your subscription has been activated.',
//             style: TextStyle(fontSize: 13, color: _C.text2),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 20),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//             decoration: BoxDecoration(
//               color: _C.greenL,
//               borderRadius: BorderRadius.circular(20),
//             ),
//             child: Text(
//               'Redirecting in ${_countdown}s...',
//               style: const TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w700,
//                 color: _C.greenDk,
//               ),
//             ),
//           ),
//         ],
//       ),
//     ),
//   );
//
//   Widget _buildRenewalWarningOverlay() => _overlay(
//     child: Container(
//       margin: const EdgeInsets.all(24),
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         color: _C.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 30),
//         ],
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(
//             width: 60,
//             height: 60,
//             decoration: BoxDecoration(color: _C.amberL, shape: BoxShape.circle),
//             child: const Icon(
//               Icons.warning_amber_rounded,
//               color: _C.amber,
//               size: 28,
//             ),
//           ),
//           const SizedBox(height: 14),
//           const Text(
//             'Early Renewal Warning',
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w800,
//               color: _C.text1,
//             ),
//           ),
//           const SizedBox(height: 10),
//           Text(
//             'Your plan still has ${_activeSub?.remainingDays ?? 0} days remaining.\n'
//             'If you renew now, the new subscription starts immediately.',
//             style: const TextStyle(fontSize: 13, color: _C.text2, height: 1.5),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 20),
//           Row(
//             children: [
//               Expanded(
//                 child: GestureDetector(
//                   onTap: () => setState(() => _showRenewalWarning = false),
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(vertical: 12),
//                     decoration: BoxDecoration(
//                       color: _C.bg,
//                       borderRadius: BorderRadius.circular(10),
//                       border: Border.all(color: _C.border),
//                     ),
//                     child: const Center(
//                       child: Text(
//                         'Cancel',
//                         style: TextStyle(
//                           fontWeight: FontWeight.w700,
//                           color: _C.text2,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: GestureDetector(
//                   onTap: _startPayment,
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(vertical: 12),
//                     decoration: BoxDecoration(
//                       gradient: _C.amberGrad,
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: const Center(
//                       child: Text(
//                         'Renew Now',
//                         style: TextStyle(
//                           fontWeight: FontWeight.w700,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     ),
//   );
//
//   Widget _buildFreeTrialOverlay() => _overlay(
//     child: Container(
//       margin: const EdgeInsets.all(24),
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         color: _C.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 30),
//         ],
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(
//             width: 60,
//             height: 60,
//             decoration: const BoxDecoration(
//               color: Color(0xFFFFF3E0),
//               shape: BoxShape.circle,
//             ),
//             child: const Icon(
//               Icons.card_giftcard_rounded,
//               color: Color(0xFFF57C00),
//               size: 28,
//             ),
//           ),
//           const SizedBox(height: 14),
//           const Text(
//             'Start 7-Day Free Trial',
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w800,
//               color: _C.text1,
//             ),
//           ),
//           const SizedBox(height: 10),
//           const Text(
//             'All modules included. No payment required.',
//             style: TextStyle(fontSize: 13, color: _C.text2, height: 1.5),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 20),
//           Row(
//             children: [
//               Expanded(
//                 child: GestureDetector(
//                   onTap: () => setState(() => _showFreeTrial = false),
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(vertical: 12),
//                     decoration: BoxDecoration(
//                       color: _C.bg,
//                       borderRadius: BorderRadius.circular(10),
//                       border: Border.all(color: _C.border),
//                     ),
//                     child: const Center(
//                       child: Text(
//                         'Cancel',
//                         style: TextStyle(
//                           fontWeight: FontWeight.w700,
//                           color: _C.text2,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: GestureDetector(
//                   onTap: _activateFreeTrial,
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(vertical: 12),
//                     decoration: BoxDecoration(
//                       gradient: const LinearGradient(
//                         colors: [Color(0xFFF57C00), Color(0xFFE65100)],
//                       ),
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: const Center(
//                       child: Text(
//                         'Start Trial',
//                         style: TextStyle(
//                           fontWeight: FontWeight.w700,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     ),
//   );
//
//   Widget _buildLoadingOverlay() => Container(
//     color: Colors.black.withOpacity(0.25),
//     child: const Center(
//       child: CircularProgressIndicator(color: _C.orange, strokeWidth: 2),
//     ),
//   );
//
//   Widget _overlay({required Widget child}) => Positioned.fill(
//     child: Container(
//       color: Colors.black.withOpacity(0.5),
//       child: Center(child: child),
//     ),
//   );
//
//   // ── Error ─────────────────────────────────────────────────────────────────────
//   Widget _buildError() => Center(
//     child: Padding(
//       padding: const EdgeInsets.all(24),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             width: 64,
//             height: 64,
//             decoration: const BoxDecoration(
//               color: _C.redL,
//               shape: BoxShape.circle,
//             ),
//             child: const Icon(
//               Icons.error_outline_rounded,
//               color: _C.red,
//               size: 28,
//             ),
//           ),
//           const SizedBox(height: 14),
//           const Text(
//             'Failed to load plans',
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w700,
//               color: _C.text1,
//             ),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             _error ?? 'Unknown error',
//             style: const TextStyle(fontSize: 12, color: _C.text2),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 20),
//           GestureDetector(
//             onTap: () {
//               setState(() {
//                 _error = null;
//                 _planLoading = true;
//               });
//               _loadPlan();
//             },
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//               decoration: BoxDecoration(
//                 gradient: _C.orangeGrad,
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: const Text(
//                 'Retry',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     ),
//   );
//
//   // ── Module icon mapping ───────────────────────────────────────────────────────
//   IconData _getModuleIcon(String code) {
//     const icons = {
//       'DASHBOARD': Icons.dashboard_rounded,
//       'PLATFORM_ACCESS': Icons.rocket_launch_rounded,
//       'SETTINGS_CONTROLS': Icons.settings_rounded,
//       'MENU_MANAGEMENT': Icons.restaurant_menu_rounded,
//       'ORDER_MANAGEMENT': Icons.shopping_bag_rounded,
//       'CHEF_MANAGEMENT': Icons.soup_kitchen_rounded,
//       'TEAM_MANAGEMENT': Icons.groups_rounded,
//       'FINANCE_ACCOUNTING': Icons.account_balance_wallet_rounded,
//       'VENDOR_PROFILE': Icons.store_rounded,
//       'HELP_DESK': Icons.headset_mic_rounded,
//       'LEGAL_COMPLIANCE': Icons.gavel_rounded,
//       'REPORTS': Icons.bar_chart_rounded,
//       'NOTIFICATIONS': Icons.notifications_rounded,
//       'DELIVERY': Icons.delivery_dining_rounded,
//       'DINE_IN': Icons.table_restaurant_rounded,
//       'TAKEAWAY': Icons.takeout_dining_rounded,
//       'PROMOTIONS': Icons.local_offer_rounded,
//       'INVENTORY': Icons.inventory_rounded,
//     };
//     return icons[code] ?? Icons.widgets_rounded;
//   }
// }
