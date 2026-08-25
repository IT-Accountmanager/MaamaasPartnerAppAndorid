
// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:intl/intl.dart';
// import 'package:razorpay_flutter/razorpay_flutter.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
// import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
// import '../../API/Apiclient.dart';
// import '../../API/food_authservice.dart';
// import '../../food&beverages/Invoice.dart';
// import '../../widgets_helper/food/utils.dart';
// import '../DineOut_Model/DineOut_CartModel.dart' as dineout;
// import '../DineOut_Model/dummy service.dart';
// import '../DineOut_Model/dummymodel.dart';
// import '../DineOut_Services/DineOutAuthService.dart';
// import 'DineOutMenu_Managemnet.dart';
//
// // ─── Design Tokens (same as original) ────────────────────────────────────────
// class _C {
//   static const bg = Color(0xFFF6F7FB);
//   static const white = Color(0xFFFFFFFF);
//   static const border = Color(0xFFEAEBF2);
//   static const accent = Color(0xFFE66D33);
//   static const accentLight = Color(0xFFFEF0E8);
//   static const accentDark = Color(0xFFE66D33);
//   static const green = Color(0xFF2ECC71);
//   static const greenLight = Color(0xFFE8F8F0);
//   static const red = Color(0xFFE74C3C);
//   static const redLight = Color(0xFFFEECEB);
//   static const orange = Color(0xFFF39C12);
//   static const orangeLight = Color(0xFFFFEDD5);
//   static const blue = Color(0xFF17A2B8);
//   static const blueLight = Color(0xFFE8F7FA);
//   static const purple = Color(0xFF6C757D);
//   static const text1 = Color(0xFF1A1A2E);
//   static const text2 = Color(0xFF6B6B8A);
//   static const text3 = Color(0xFFAAAAAC);
//   static const shadow = Color(0x0F000000);
//   static const amber = Color(0xFFF59E0B);
//   static const amberLight = Color(0xFFFEF3C7);
// }
//
// // ─── Screen Mode ─────────────────────────────────────────────────────────────
// enum _ScreenMode { cart, billing }
//
// // ═══════════════════════════════════════════════════════════════════════════════
// // SCREEN  (paste over your existing DineOutfood_CartScreen)
// // ═══════════════════════════════════════════════════════════════════════════════
//
// class DineOutfood_CartScreen extends StatefulWidget {
//   final int? cartId;
//   final int? bookingId;
//   final String? tableCode;
//   final int? userId;
//
//   const DineOutfood_CartScreen({
//     super.key,
//     this.cartId,
//     required double savedAmount,
//     required bool showSavedPopup,
//     this.bookingId,
//     this.tableCode,
//     this.userId,
//   });
//
//   @override
//   State<DineOutfood_CartScreen> createState() => _DineOutfood_CartScreenState();
// }
//
// class _DineOutfood_CartScreenState extends State<DineOutfood_CartScreen>
//     with WidgetsBindingObserver {
//   // ─── All original state fields (unchanged) ────────────────────────────────
//   _ScreenMode _screenMode = _ScreenMode.cart;
//   dineout.DineoutCartmodel? cartData;
//   bool isLoading = true;
//   bool isPlacingOrder = false;
//   String selectedPaymentMethod = '';
//   bool isServiceChargeApplied = true;
//   bool _isUpdating = false;
//   Map<int, bool> _itemLoadingMap = {};
//   Map<int, int> _availableQuantities = {};
//
//
//   bool _isSaving = false;
//   bool _isSaveAndPrinting = false;
//   bool _isKOT = false;
//   bool _isKOTAndPrinting = false;
//
//   List<BluetoothInfo> _pairedDevices = [];
//   bool _isLoadingPrinter = false;
//   bool _isPrinting = false;
//
//   final TextEditingController _discountController = TextEditingController();
//   double _discountAmount = 0.0;
//   bool _isApplyingDiscount = false;
//   bool _isDiscountApplied = false;
//
//   Map<int, String> _itemNotes = {};
//   Set<int> _itemsBeingSent = {};
//
//   bool _isGeneratingQr = false;
//   String? _qrImageUrl;
//   String? _qrOrderId;
//   Timer? _qrPollingTimer;
//   int _qrTimer = 300;
//   Timer? _qrCountdownTimer;
//
//   late Razorpay _razorpay;
//   int? appliedCouponId;
//   bool _isPlacingOrder = false;
//
//   Map<String, bool> _paymentMethodsConfig = {
//     'cash': true,
//     'upi': true,
//     'qrCode': true,
//   };
//
//   // ─── NEW: submission flag ─────────────────────────────────────────────────
//   bool _isSubmittingRequest = false;
//
//   // =========================================================================
//   // LIFECYCLE (unchanged)
//   // =========================================================================
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//     _razorpay = Razorpay();
//     _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
//     _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
//     _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
//     _loadCart();
//     _loadAvailableQuantities();
//     _fetchPaymentMethodsConfig();
//     Utils.itemCount.addListener(_onCartCountChanged);
//   }
//
//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.resumed) {
//       _loadCart();
//       _loadAvailableQuantities();
//     }
//   }
//
//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     Utils.itemCount.removeListener(_onCartCountChanged);
//     _razorpay.clear();
//     _qrPollingTimer?.cancel();
//     _qrCountdownTimer?.cancel();
//     _discountController.dispose();
//     super.dispose();
//   }
//
//   // =========================================================================
//   // COMPUTED GETTERS (unchanged)
//   // =========================================================================
//
//   List<dineout.CartItem> get _pendingItems =>
//       (cartData?.cartItems ?? []).where((item) {
//         final s = item.orderStatus;
//         return s == null || s.isEmpty || s == 'PENDING';
//       }).toList();
//
//   List<dineout.CartItem> get _sentToKitchenItems =>
//       (cartData?.cartItems ?? []).where((item) {
//         final s = item.orderStatus;
//         return s != null && s.isNotEmpty && s != 'PENDING';
//       }).toList();
//
//   bool get _isUserLoggedIn => widget.userId != null && widget.userId != 0;
//
//   double get _finalAmount {
//     double total = cartData?.grandTotal ?? 0;
//     if (_isDiscountApplied) total -= _discountAmount;
//     return total > 0 ? total : 0;
//   }
//
//   double get _currentChargeAmount => _isUserLoggedIn
//       ? cartData?.platformCharges ?? 0.0
//       : cartData?.serviceCharges ?? 0.0;
//
//   String get _chargeLabel =>
//       _isUserLoggedIn ? 'Platform Charges' : 'Service Charges';
//
//   void _onCartCountChanged() {
//     if (!_isUpdating) {
//       _loadCart();
//       _loadAvailableQuantities();
//     }
//   }
//
//   // =========================================================================
//   // ███  NEW: REMOVAL-REQUEST POPUP  ████████████████████████████████████████
//   // =========================================================================
//
//   Future<void> _showRemovalRequestPopup(dineout.CartItem item) async {
//     if (cartData == null) return;
//
//     final prefs = await SharedPreferences.getInstance();
//     final vendorId = prefs.getInt('vendorId') ?? 0;
//     final employeeId = prefs.getInt('employeeId') ?? 0;
//     final employeeName = prefs.getString('employeeName') ?? '';
//
//     if (!mounted) return;
//
//     await showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (_) => _RemovalRequestDialog(
//         item: item,
//         cartId: cartData!.cartId,
//         vendorId: vendorId,
//         userId: widget.userId ?? 0,
//         employeeId: employeeId,
//         employeeName: employeeName,
//         bookingId: widget.bookingId ?? 0,
//         tableCode: widget.tableCode ?? '',
//         onSuccess: () {
//           _snack('Removal request submitted successfully!', _C.green);
//           _loadCart();
//           _loadAvailableQuantities();
//         },
//         onError: (msg) => _snack(msg, _C.red),
//       ),
//     );
//   }
//
//   // =========================================================================
//   // QUANTITY UPDATE — modified to show popup on wrong decrement
//   // =========================================================================
//
//   Future<void> _updateQuantity(dineout.CartItem item, int newQuantity) async {
//     if (_isUpdating) return;
//
//     // Check if item is already sent to kitchen (status is not 'PENDING')
//     final bool isAlreadySent =
//         item.orderStatus != null &&
//         item.orderStatus != 'PENDING' &&
//         item.orderStatus!.isNotEmpty;
//
//     // CASE 1: Item already sent to kitchen - can only request removal
//     if (isAlreadySent && newQuantity < item.quantity) {
//       await _showRemovalRequestPopup(item);
//       return;
//     }
//
//     // CASE 2: Item is PENDING and trying to remove (decrement to 0)
//     if (!isAlreadySent && newQuantity < 1) {
//       await _showRemovalRequestPopup(item);
//       return;
//     }
//
//     // Check stock availability
//     final available = _availableQuantities[item.dishId] ?? 0;
//     if (newQuantity > available && available > 0) {
//       _snack('Only $available items available', _C.red);
//       return;
//     }
//
//     // Proceed with normal quantity update
//     final int originalQuantity = item.quantity;
//     _isUpdating = true;
//     setState(() => _itemLoadingMap[item.itemId] = true);
//
//     try {
//       // Optimistic update
//       setState(() {
//         final idx = cartData!.cartItems.indexWhere(
//           (i) => i.itemId == item.itemId,
//         );
//         if (idx != -1) cartData!.cartItems[idx].quantity = newQuantity;
//       });
//
//       final status = item.orderStatus ?? 'PENDING';
//       final success = await _callUpdateCartApi(
//         cartId: cartData!.cartId,
//         itemId: item.itemId,
//         quantity: newQuantity,
//         status: status,
//       );
//
//       if (success) {
//         await _loadCart();
//         await _loadAvailableQuantities();
//         _snack('Quantity updated', _C.green);
//       } else {
//         // Rollback on failure
//         setState(() {
//           final idx = cartData!.cartItems.indexWhere(
//             (i) => i.itemId == item.itemId,
//           );
//           if (idx != -1) cartData!.cartItems[idx].quantity = originalQuantity;
//         });
//         _snack('Failed to update quantity. Please try again.', _C.red);
//       }
//     } catch (e) {
//       // Rollback on error
//       setState(() {
//         final idx = cartData!.cartItems.indexWhere(
//           (i) => i.itemId == item.itemId,
//         );
//         if (idx != -1) cartData!.cartItems[idx].quantity = originalQuantity;
//       });
//       _snack('Error updating item: $e', _C.red);
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isUpdating = false;
//           _itemLoadingMap[item.itemId] = false;
//         });
//       }
//     }
//   }
//
//   // ── All remaining methods are IDENTICAL to the original ───────────────────
//
//   Future<bool> _callUpdateCartApi({
//     required int cartId,
//     required int itemId,
//     required int quantity,
//     String status = '',
//   }) async {
//     try {
//       final endpoint = status.isNotEmpty
//           ? 'api/cart/update/table/quantity/status/$cartId?itemId=$itemId&quantity=$quantity&status=$status'
//           : 'api/cart/update/table/quantity/$cartId?itemId=$itemId&quantity=$quantity';
//       final response = await ApiClient.put(endpoint, {}, service: 'food');
//       return response.statusCode == 200 ||
//           response.statusCode == 201 ||
//           response.statusCode == 204;
//     } catch (e) {
//       return false;
//     }
//   }
//
//   Future<void> _fetchPaymentMethodsConfig() async {
//     try {
//       final vendorId = await _getVendorId();
//       final response = await ApiClient.get(
//         'api/billing/get/$vendorId',
//         service: 'food',
//       );
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         if (mounted) {
//           setState(() {
//             _paymentMethodsConfig = {
//               'cash': data['cash'] ?? false,
//               'upi': data['upi'] ?? false,
//               'qrCode': data['qrCode'] ?? false,
//             };
//           });
//         }
//       }
//     } catch (_) {}
//   }
//
//   Future<int> _getVendorId() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getInt('vendorId') ?? 0;
//   }
//
//   Future<void> _loadAvailableQuantities() async {
//     try {
//       final dishes = await food_authservice.fetchDishes();
//       if (mounted) {
//         setState(() {
//           for (var dish in dishes) {
//             _availableQuantities[dish.dishId] = dish.balanceQuantity;
//           }
//         });
//       }
//     } catch (_) {}
//   }
//
//   Future<void> _checkServiceChargeStatus() {
//     if (cartData != null && mounted) {
//       setState(
//         () => isServiceChargeApplied = (cartData?.serviceCharges ?? 0) > 0,
//       );
//     }
//     return Future.value();
//   }
//
//   Future<void> _loadCart() async {
//     if (!_isUpdating && mounted) setState(() => isLoading = true);
//     try {
//       if (widget.bookingId == null || widget.bookingId == 0) {
//         setState(() {
//           cartData = null;
//           isLoading = false;
//         });
//         return;
//       }
//       final prefs = await SharedPreferences.getInstance();
//       final vendorId = prefs.getInt('vendorId') ?? 0;
//       final fetched = await DineoutAuthService.fetchCartByBooking(
//         vendorId: vendorId,
//         bookingId: widget.bookingId!,
//       );
//       if (mounted) {
//         setState(() {
//           cartData = fetched;
//           isLoading = false;
//         });
//         await _checkServiceChargeStatus();
//       }
//     } catch (e) {
//       if (mounted) setState(() => isLoading = false);
//     }
//   }
//
//   Future<void> _applyVendorDiscount() async {
//     final input = _discountController.text.trim();
//     if (input.isEmpty) {
//       _snack('Please enter a discount amount', _C.orange);
//       return;
//     }
//     final amount = double.tryParse(input);
//     if (amount == null || amount <= 0) {
//       _snack('Enter a valid discount amount', _C.red);
//       return;
//     }
//     if (cartData == null || cartData!.cartId == 0) {
//       _snack('Cart not loaded', _C.red);
//       return;
//     }
//     setState(() => _isApplyingDiscount = true);
//     try {
//       final success = await DineoutAuthService.applyVendorDiscount(
//         cartId: cartData!.cartId,
//         discountAmount: amount,
//       );
//       if (success) {
//         setState(() {
//           _discountAmount = amount;
//           _isDiscountApplied = true;
//         });
//         _snack('Discount of ₹${amount.toStringAsFixed(2)} applied!', _C.green);
//         await _loadCart();
//       } else {
//         _snack('Failed to apply discount', _C.red);
//       }
//     } catch (e) {
//       _snack('Error applying discount: $e', _C.red);
//     } finally {
//       if (mounted) setState(() => _isApplyingDiscount = false);
//     }
//   }
//
//   void _removeVendorDiscount() {
//     setState(() {
//       _discountAmount = 0.0;
//       _isDiscountApplied = false;
//       _discountController.clear();
//     });
//     _snack('Discount removed', _C.green);
//     _loadCart();
//   }
//
//   Future<void> _loadPairedDevices() async {
//     if (!mounted) return;
//     setState(() => _isLoadingPrinter = true);
//     try {
//       final paired = await PrintBluetoothThermal.pairedBluetooths;
//       if (mounted)
//         setState(() {
//           _pairedDevices = paired;
//           _isLoadingPrinter = false;
//         });
//     } catch (e) {
//       if (mounted) setState(() => _isLoadingPrinter = false);
//       _snack('Could not load printers.', _C.orange);
//     }
//   }
//
//   Future<void> _printToBluetooth(
//     String macAddress,
//     List<dineout.CartItem> items, {
//     required bool isKOT,
//   }) async {
//     if (!mounted) return;
//     setState(() => _isPrinting = true);
//     try {
//       await PrintBluetoothThermal.disconnect;
//       final connected = await PrintBluetoothThermal.connect(
//         macPrinterAddress: macAddress,
//       );
//       if (connected) {
//         await _sendToPrinter(items, isKOT: isKOT);
//         if (mounted)
//           _snack(isKOT ? 'KOT printed!' : 'Receipt printed!', _C.green);
//       } else {
//         throw Exception('Failed to connect to printer');
//       }
//     } catch (e) {
//       if (mounted) _snack('Failed to print: $e', _C.red);
//     } finally {
//       if (mounted) setState(() => _isPrinting = false);
//     }
//   }
//
//   Future<void> _sendToPrinter(
//     List<dineout.CartItem> items, {
//     required bool isKOT,
//   }) async {
//     final prefs = await SharedPreferences.getInstance();
//     final companyName = prefs.getString('companyName') ?? 'MAAMAAS HOUSE';
//     final now = DateTime.now();
//     final dateStr = DateFormat('dd/MM/yyyy').format(now);
//     final timeStr = DateFormat('hh:mm a').format(now);
//     List<int> centerAlign = [27, 97, 1];
//     List<int> boldOn = [27, 69, 1];
//     List<int> boldOff = [27, 33, 0];
//     List<int> doubleHeightOn = [27, 33, 8];
//     await PrintBluetoothThermal.writeBytes(centerAlign);
//     await PrintBluetoothThermal.writeBytes(boldOn);
//     await PrintBluetoothThermal.writeString(
//       printText: PrintTextSize(size: 2, text: '$companyName\n'),
//     );
//     await PrintBluetoothThermal.writeBytes(boldOff);
//     await PrintBluetoothThermal.writeString(
//       printText: PrintTextSize(
//         size: 2,
//         text: isKOT
//             ? '*** KITCHEN ORDER TICKET ***\n'
//             : '*** ORDER SUMMARY ***\n',
//       ),
//     );
//     String makeRow(String l, String r) {
//       int sp = 48 - l.length - r.length;
//       if (sp < 1) sp = 1;
//       return l + (' ' * sp) + r;
//     }
//
//     await PrintBluetoothThermal.writeString(
//       printText: PrintTextSize(
//         size: 2,
//         text:
//             makeRow('Table: ${widget.tableCode ?? "N/A"}', 'Date: $dateStr') +
//             '\n',
//       ),
//     );
//     await PrintBluetoothThermal.writeString(
//       printText: PrintTextSize(
//         size: 2,
//         text:
//             makeRow('Booking #${widget.bookingId ?? ""}', 'Time: $timeStr') +
//             '\n',
//       ),
//     );
//     await PrintBluetoothThermal.writeString(
//       printText: PrintTextSize(
//         size: 2,
//         text: '------------------------------------------------\n',
//       ),
//     );
//     await PrintBluetoothThermal.writeBytes(doubleHeightOn);
//     await PrintBluetoothThermal.writeString(
//       printText: PrintTextSize(
//         size: 2,
//         text: 'ITEM                       QTY\n',
//       ),
//     );
//     await PrintBluetoothThermal.writeBytes(boldOff);
//     await PrintBluetoothThermal.writeString(
//       printText: PrintTextSize(
//         size: 2,
//         text: '------------------------------------------------\n',
//       ),
//     );
//     for (var item in items) {
//       String name = item.dishName;
//       if (name.length > 26) name = name.substring(0, 26);
//       await PrintBluetoothThermal.writeString(
//         printText: PrintTextSize(
//           size: 2,
//           text:
//               '${name.padRight(28)}${item.quantity.toString().padRight(10)}\n',
//         ),
//       );
//       if (_itemNotes[item.itemId] != null &&
//           _itemNotes[item.itemId]!.isNotEmpty) {
//         await PrintBluetoothThermal.writeString(
//           printText: PrintTextSize(
//             size: 1,
//             text: '   Note: ${_itemNotes[item.itemId]}\n',
//           ),
//         );
//       }
//     }
//     await PrintBluetoothThermal.writeString(
//       printText: PrintTextSize(
//         size: 1,
//         text: isKOT ? '** Kitchen Copy **\n' : '** Customer Copy **\n',
//       ),
//     );
//     await PrintBluetoothThermal.writeBytes([10, 10, 10]);
//   }
//
//   void _showPrinterSelectionDialog(
//     List<dineout.CartItem> items, {
//     required bool isKOT,
//   }) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (_) => _PrinterBottomSheet(
//         items: items,
//         isKOT: isKOT,
//         onPrint: (mac) => _printToBluetooth(mac, items, isKOT: isKOT),
//         onSkipPrint: () => _snack(
//           isKOT ? 'Items sent without print' : 'Items saved without print',
//           _C.orange,
//         ),
//         onLoadDevices: _loadPairedDevices,
//         pairedDevices: _pairedDevices,
//         isLoading: _isLoadingPrinter,
//       ),
//     );
//   }
//
//   Future<void> _handleSave() async {
//     if (_isSaving) return;
//     final items = _pendingItems;
//     if (items.isEmpty) {
//       _snack('No pending items to save.', _C.orange);
//       return;
//     }
//     setState(() => _isSaving = true);
//     try {
//       int ok = 0;
//       List<String> fail = [];
//       for (final item in items) {
//         final success = await DineoutAuthService.saveItemToCart(
//           itemId: item.itemId,
//           status: 'PENDING',
//           note: _itemNotes[item.itemId] ?? '',
//         );
//         success ? ok++ : fail.add(item.dishName);
//       }
//       if (ok > 0) {
//         _snack('$ok item(s) saved!', _C.green);
//         await _loadCart();
//         await _loadAvailableQuantities();
//       }
//       if (fail.isNotEmpty) _snack('Failed: ${fail.join(", ")}', _C.orange);
//     } catch (_) {
//       _snack('Error saving items', _C.red);
//     } finally {
//       if (mounted) setState(() => _isSaving = false);
//     }
//   }
//
//   Future<void> _handleSaveAndPrint() async {
//     if (_isSaveAndPrinting) return;
//     final items = _pendingItems;
//     if (items.isEmpty) {
//       _snack('No pending items.', _C.orange);
//       return;
//     }
//     setState(() => _isSaveAndPrinting = true);
//     try {
//       int ok = 0;
//       List<String> fail = [];
//       for (final item in items) {
//         final success = await DineoutAuthService.saveItemToCart(
//           itemId: item.itemId,
//           status: 'PENDING',
//           note: _itemNotes[item.itemId] ?? '',
//         );
//         success ? ok++ : fail.add(item.dishName);
//       }
//       if (ok > 0) {
//         await _loadPairedDevices();
//         if (mounted) _showPrinterSelectionDialog(items, isKOT: false);
//         _snack('$ok item(s) saved!', _C.green);
//         await _loadCart();
//         await _loadAvailableQuantities();
//       }
//       if (fail.isNotEmpty) _snack('Failed: ${fail.join(", ")}', _C.orange);
//     } catch (e) {
//       _snack('Error: $e', _C.red);
//     } finally {
//       if (mounted) setState(() => _isSaveAndPrinting = false);
//     }
//   }
//
//   Future<void> _handleKOT() async {
//     if (_isKOT) return;
//     final items = _pendingItems;
//     if (items.isEmpty) {
//       _snack('No pending items', _C.orange);
//       return;
//     }
//     setState(() => _isKOT = true);
//     try {
//       int ok = 0;
//       List<String> fail = [];
//       for (final item in items) {
//         final success = await DineoutAuthService.sendItemToKitchen(
//           itemId: item.itemId,
//           status: 'CONFIRMED',
//           note: _itemNotes[item.itemId] ?? '',
//         );
//         success ? ok++ : fail.add(item.dishName);
//       }
//       if (ok > 0) {
//         _snack('$ok item(s) sent to kitchen!', _C.green);
//         _itemNotes.clear();
//         await _loadCart();
//         await _loadAvailableQuantities();
//       }
//       if (fail.isNotEmpty) _snack('Failed: ${fail.join(", ")}', _C.orange);
//     } catch (_) {
//       _snack('Error sending to kitchen', _C.red);
//     } finally {
//       if (mounted) setState(() => _isKOT = false);
//     }
//   }
//
//   Future<void> _handleKOTAndPrint() async {
//     if (_isKOTAndPrinting) return;
//     final items = _pendingItems;
//     if (items.isEmpty) {
//       _snack('No pending items', _C.orange);
//       return;
//     }
//     setState(() => _isKOTAndPrinting = true);
//     try {
//       int ok = 0;
//       List<String> fail = [];
//       for (final item in items) {
//         final success = await DineoutAuthService.sendItemToKitchen(
//           itemId: item.itemId,
//           status: 'CONFIRMED',
//           note: _itemNotes[item.itemId] ?? '',
//         );
//         success ? ok++ : fail.add(item.dishName);
//       }
//       if (ok > 0) {
//         await _loadPairedDevices();
//         if (mounted) _showPrinterSelectionDialog(items, isKOT: true);
//         _snack('$ok item(s) sent!', _C.green);
//         _itemNotes.clear();
//         await _loadCart();
//         await _loadAvailableQuantities();
//       }
//       if (fail.isNotEmpty) _snack('Failed: ${fail.join(", ")}', _C.orange);
//     } catch (e) {
//       _snack('Error: $e', _C.red);
//     } finally {
//       if (mounted) setState(() => _isKOTAndPrinting = false);
//     }
//   }
//
//   void _updateItemNote(int itemId, String note) {
//     setState(() {
//       note.isEmpty ? _itemNotes.remove(itemId) : _itemNotes[itemId] = note;
//     });
//   }
//
//   void _proceedToBilling() => setState(() {
//     _screenMode = _ScreenMode.billing;
//     selectedPaymentMethod = '';
//   });
//   void _backToCart() => setState(() {
//     _screenMode = _ScreenMode.cart;
//     selectedPaymentMethod = '';
//   });
//
//
//
//   void _handlePaymentSuccess(PaymentSuccessResponse res) async {
//     final prefs = await SharedPreferences.getInstance();
//     final vendorId = prefs.getInt('vendorId') ?? 0;
//     final phone = prefs.getString('phone') ?? '';
//     final orderResult = await DineoutAuthService.placeDirectOrder(
//       vendorId: vendorId,
//       cartId: cartData!.cartId,
//       paymentMethod: 'Online_Payment',
//       razorpayPaymentId: res.paymentId!,
//       razorpayOrderId: res.orderId!,
//       userId: widget.userId,
//       isUserOrder: _isUserLoggedIn,
//       phoneNumber: phone,
//       couponId: appliedCouponId,
//       amount: _finalAmount,
//     );
//     if (orderResult != null && mounted && orderResult.containsKey('orderId')) {
//       _clearCart();
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (_) => food_Invoice(orderId: orderResult['orderId']),
//         ),
//       );
//     } else {
//       _snack('Payment succeeded but order creation failed', _C.orange);
//     }
//   }
//
//   void _handlePaymentError(PaymentFailureResponse res) =>
//       _snack('Payment failed: ${res.message}', _C.red);
//   void _handleExternalWallet(ExternalWalletResponse res) {}
//
//   Future<void> placeOrder() async {
//     if (_isPlacingOrder) return;
//     if (cartData == null || cartData!.cartId == 0) {
//       await _loadCart();
//       if (cartData == null || cartData!.cartId == 0) {
//         _snack('Cart is empty', _C.red);
//         return;
//       }
//     }
//     if (selectedPaymentMethod.isEmpty) {
//       _snack('Please select a payment method', _C.orange);
//       return;
//     }
//     setState(() {
//       isPlacingOrder = true;
//       _isPlacingOrder = true;
//     });
//     try {
//       if (selectedPaymentMethod == 'QR_Payment' && !_isUserLoggedIn) {
//         await _generateDynamicQrAndPoll();
//         setState(() => isPlacingOrder = false);
//         return;
//       }
//       if (selectedPaymentMethod == 'Online_Payment' && _isUserLoggedIn) {
//         await _initiateRazorpay();
//         setState(() => isPlacingOrder = false);
//         return;
//       }
//       final vendorId = await _getVendorId();
//       final prefs = await SharedPreferences.getInstance();
//       final phone = prefs.getString('phone') ?? '';
//       final orderResult = await DineoutAuthService.placeDirectOrder(
//         vendorId: vendorId,
//         cartId: cartData!.cartId,
//         paymentMethod: selectedPaymentMethod,
//         razorpayPaymentId: '',
//         razorpayOrderId: '',
//         userId: widget.userId,
//         isUserOrder: _isUserLoggedIn,
//         phoneNumber: phone,
//         couponId: appliedCouponId,
//         amount: _finalAmount,
//       );
//       if (orderResult != null &&
//           mounted &&
//           orderResult.containsKey('orderId')) {
//         _clearCart();
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder: (_) => food_Invoice(orderId: orderResult['orderId']),
//           ),
//         );
//       } else {
//         _snack('Failed to place order', _C.red);
//       }
//     } catch (e) {
//       _snack('Error placing order: $e', _C.red);
//     } finally {
//       if (mounted) setState(() => isPlacingOrder = false);
//       _isPlacingOrder = false;
//     }
//   }
//
//   Future<void> _generateDynamicQrAndPoll() async {
//     if (cartData == null) return;
//     setState(() {
//       _isGeneratingQr = true;
//       _qrImageUrl = null;
//     });
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final vendorId = prefs.getInt('vendorId') ?? 0;
//       final phone = prefs.getString('phone') ?? '9876543210';
//       final uniqueOrderId =
//           'ORD${DateTime.now().millisecondsSinceEpoch}${cartData!.cartId}';
//       final response = await ApiClient.post('api/payments/create/qr', {
//         'amount': _finalAmount,
//         'cartId': cartData!.cartId,
//         'vendorId': vendorId,
//         'phone': phone,
//         'orderId': uniqueOrderId,
//       }, service: 'food');
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         setState(() {
//           _qrImageUrl = data['image_url']?.toString();
//           _qrOrderId = uniqueOrderId;
//           _qrTimer = 300;
//         });
//         _showQrDialog(uniqueOrderId);
//         _startQrCountdown();
//         _startQrPolling(uniqueOrderId);
//       } else {
//         _snack('QR generation failed', _C.red);
//       }
//     } catch (e) {
//       _snack('Failed to generate QR: $e', _C.red);
//     } finally {
//       if (mounted) setState(() => _isGeneratingQr = false);
//     }
//   }
//
//   void _startQrCountdown() {
//     _qrCountdownTimer?.cancel();
//     _qrCountdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
//       if (!mounted) {
//         t.cancel();
//         return;
//       }
//       if (_qrTimer <= 1) {
//         t.cancel();
//         _qrPollingTimer?.cancel();
//         if (mounted) setState(() => _qrTimer = 0);
//         Navigator.of(context, rootNavigator: true).pop();
//       } else {
//         setState(() => _qrTimer--);
//       }
//     });
//   }
//
//   void _startQrPolling(String orderId) {
//     _qrPollingTimer?.cancel();
//     _qrPollingTimer = Timer.periodic(const Duration(seconds: 3), (t) async {
//       try {
//         final prefs = await SharedPreferences.getInstance();
//         final token = prefs.getString('token') ?? '';
//         final res = await http.get(
//           Uri.parse(
//             'http://staging.maamaas.com:8080/food/api/payments/status/$orderId',
//           ),
//           headers: {'Authorization': 'Bearer $token'},
//         );
//         final body = jsonDecode(res.body);
//         if (body['status'] == 'SUCCESS') {
//           t.cancel();
//           _qrCountdownTimer?.cancel();
//           Navigator.of(context, rootNavigator: true).pop();
//           await _createOrderAfterQrSuccess();
//         } else if (body['status'] == 'FAILED') {
//           t.cancel();
//           _qrCountdownTimer?.cancel();
//           Navigator.of(context, rootNavigator: true).pop();
//           _snack('Payment failed.', _C.red);
//         }
//       } catch (_) {}
//     });
//   }
//
//   Future<void> _createOrderAfterQrSuccess() async {
//     final prefs = await SharedPreferences.getInstance();
//     final vendorId = prefs.getInt('vendorId') ?? 0;
//     final phone = prefs.getString('phone') ?? '';
//     final orderResult = await DineoutAuthService.placeDirectOrder(
//       vendorId: vendorId,
//       cartId: cartData!.cartId,
//       paymentMethod: 'Online_Payment',
//       razorpayPaymentId: '',
//       razorpayOrderId: _qrOrderId ?? '',
//       userId: widget.userId,
//       isUserOrder: _isUserLoggedIn,
//       phoneNumber: phone,
//       couponId: appliedCouponId,
//       amount: _finalAmount,
//     );
//     if (orderResult != null && mounted && orderResult.containsKey('orderId')) {
//       _clearCart();
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (_) => food_Invoice(orderId: orderResult['orderId']),
//         ),
//       );
//     } else {
//       _snack('Payment succeeded but order creation failed', _C.orange);
//     }
//   }
//
//   void _showQrDialog(String orderId) {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (_) => StatefulBuilder(
//         builder: (ctx, setS) {
//           _qrCountdownTimer?.cancel();
//           _qrCountdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
//             if (!mounted) {
//               t.cancel();
//               return;
//             }
//             if (_qrTimer <= 1) {
//               t.cancel();
//               _qrPollingTimer?.cancel();
//               Navigator.of(ctx, rootNavigator: true).pop();
//             } else {
//               setS(() => _qrTimer--);
//             }
//           });
//           final mins = _qrTimer ~/ 60;
//           final secs = _qrTimer % 60;
//           return Dialog(
//             backgroundColor: Colors.transparent,
//             child: Container(
//               decoration: BoxDecoration(
//                 color: _C.white,
//                 borderRadius: BorderRadius.circular(24.r),
//               ),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Container(
//                     padding: EdgeInsets.all(20.w),
//                     decoration: BoxDecoration(
//                       color: _C.accentDark,
//                       borderRadius: BorderRadius.vertical(
//                         top: Radius.circular(24.r),
//                       ),
//                     ),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           'Scan & Pay',
//                           style: TextStyle(
//                             fontSize: 18.sp,
//                             fontWeight: FontWeight.w800,
//                             color: Colors.white,
//                           ),
//                         ),
//                         GestureDetector(
//                           onTap: () {
//                             _qrPollingTimer?.cancel();
//                             _qrCountdownTimer?.cancel();
//                             Navigator.pop(ctx);
//                           },
//                           child: Icon(
//                             Icons.close,
//                             color: Colors.white,
//                             size: 18.sp,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Padding(
//                     padding: EdgeInsets.all(20.w),
//                     child: Column(
//                       children: [
//                         Text(
//                           '₹${_finalAmount.toStringAsFixed(2)}',
//                           style: TextStyle(
//                             fontSize: 28.sp,
//                             fontWeight: FontWeight.w900,
//                             color: _C.green,
//                           ),
//                         ),
//                         SizedBox(height: 16.h),
//                         if (_qrImageUrl != null)
//                           Image.network(
//                             _qrImageUrl!,
//                             width: 200.w,
//                             height: 200.h,
//                           ),
//                         SizedBox(height: 12.h),
//                         Text(
//                           'Scan using any UPI app',
//                           style: TextStyle(fontSize: 13.sp, color: _C.text2),
//                         ),
//                         SizedBox(height: 8.h),
//                         Text(
//                           'Time remaining: $mins:${secs.toString().padLeft(2, '0')}',
//                           style: TextStyle(fontSize: 12.sp, color: _C.orange),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   Future<void> _initiateRazorpay() async {
//     if (cartData == null) return;
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final vendorId = prefs.getInt('vendorId') ?? 0;
//       final phone = prefs.getString('phone') ?? '9999999999';
//       final uniqueOrderId = 'ORD-${DateTime.now().millisecondsSinceEpoch}';
//       final response = await ApiClient.post('api/payments/create-order/user', {
//         'amount': _finalAmount,
//         'cartId': cartData!.cartId,
//         'vendorId': vendorId,
//         'phone': phone,
//         'orderId': uniqueOrderId,
//       }, service: 'food');
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         final razorpayOrderId = data['orderId']?.toString();
//         if (razorpayOrderId == null) {
//           _snack('Failed to create payment order', _C.red);
//           return;
//         }
//         _razorpay.open({
//           'key': 'rzp_live_TJDvykibQEsCuN',
//           'amount': (_finalAmount * 100).toInt(),
//           'currency': 'INR',
//           'name': 'MAAMAAS HOUSE',
//           'description': 'Order for Table ${widget.tableCode ?? ''}',
//           'order_id': razorpayOrderId,
//           'prefill': {'contact': phone},
//           'theme': {'color': '#E66D33'},
//         });
//       } else {
//         _snack('Failed to create Razorpay order', _C.red);
//       }
//     } catch (e) {
//       _snack('Error initiating payment: $e', _C.red);
//     }
//   }
//
//   void _clearCart() {
//     setState(() => cartData = null);
//     Utils.itemCount.value = 0;
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
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(10.r),
//         ),
//       ),
//     );
//   }
//
//   String _statusLabel(String? status) {
//     switch (status) {
//       case 'DELIVERED':
//         return '✓ Delivered';
//       case 'ORDER_IS_READY':
//         return '✓ Ready';
//       case 'BEING_PREPARED':
//         return '🍳 Preparing';
//       case 'CONFIRMED':
//         return '⏳ Confirmed';
//       case 'PROCESSING':
//         return '⏳ Processing';
//       case 'PENDING':
//         return '📝 Saved';
//       case 'CANCELLED':
//         return '✕ Cancelled';
//       default:
//         return '📝 Draft';
//     }
//   }
//
//   Color _statusColor(String? status) {
//     switch (status) {
//       case 'DELIVERED':
//         return _C.green;
//       case 'ORDER_IS_READY':
//         return _C.green;
//       case 'BEING_PREPARED':
//         return _C.blue;
//       case 'CONFIRMED':
//         return _C.orange;
//       case 'PENDING':
//         return _C.purple;
//       case 'CANCELLED':
//         return _C.red;
//       default:
//         return _C.text3;
//     }
//   }
//
//   // =========================================================================
//   // BUILD (unchanged from original)
//   // =========================================================================
//
//   @override
//   Widget build(BuildContext context) {
//     ScreenUtil.init(context);
//     return Scaffold(
//       backgroundColor: _C.bg,
//       body: SafeArea(
//         child: Column(
//           children: [
//             _buildHeader(),
//             Expanded(
//               child: isLoading
//                   ? Center(child: CircularProgressIndicator(color: _C.accent))
//                   : (cartData == null || cartData!.cartItems.isEmpty)
//                   ? _buildEmptyCart()
//                   : _screenMode == _ScreenMode.billing
//                   ? _buildBillingBody()
//                   : _buildCartBody(),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildHeader() {
//     return Container(
//       padding: EdgeInsets.fromLTRB(16.w, 12.h, 8.w, 12.h),
//       decoration: BoxDecoration(
//         color: _C.white,
//         border: Border(bottom: BorderSide(color: _C.border)),
//       ),
//       child: Row(
//         children: [
//           GestureDetector(
//             onTap: _screenMode == _ScreenMode.billing
//                 ? _backToCart
//                 : () => Navigator.pop(context),
//             child: Container(
//               width: 36.r,
//               height: 36.r,
//               decoration: BoxDecoration(
//                 color: _C.bg,
//                 borderRadius: BorderRadius.circular(10.r),
//                 border: Border.all(color: _C.border),
//               ),
//               child: Icon(
//                 Icons.arrow_back_ios_rounded,
//                 color: _C.text1,
//                 size: 15.sp,
//               ),
//             ),
//           ),
//           SizedBox(width: 12.w),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   _screenMode == _ScreenMode.billing ? 'Billing' : 'Your Cart',
//                   style: TextStyle(
//                     fontSize: 17.sp,
//                     fontWeight: FontWeight.w800,
//                     color: _C.text1,
//                   ),
//                 ),
//                 if (cartData != null)
//                   Text(
//                     _buildHeaderSubtitle(),
//                     style: TextStyle(fontSize: 12.sp, color: _C.text2),
//                   ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   String _buildHeaderSubtitle() {
//     final tableLabel =
//         (widget.tableCode != null && widget.tableCode!.isNotEmpty)
//         ? 'Table ${widget.tableCode}  •  '
//         : '';
//     if (cartData == null) return '';
//     if (_screenMode == _ScreenMode.billing) {
//       final total = cartData!.cartItems.fold(0, (s, i) => s + i.quantity);
//       return '${tableLabel}$total items';
//     }
//     final pending = _pendingItems.fold(0, (s, i) => s + i.quantity);
//     final sent = _sentToKitchenItems.fold(0, (s, i) => s + i.quantity);
//     return '${tableLabel}$pending pending • $sent sent';
//   }
//
//   Widget _buildCartBody() {
//     return RefreshIndicator(
//       color: _C.accent,
//       onRefresh: () async {
//         await _loadCart();
//         await _loadAvailableQuantities();
//       },
//       child: SingleChildScrollView(
//         physics: const AlwaysScrollableScrollPhysics(),
//         padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 32.h),
//         child: Column(
//           children: [
//             if (_pendingItems.isNotEmpty) _buildCartItemsCard(),
//             if (_sentToKitchenItems.isNotEmpty) _buildSentItemsSection(),
//             if (_pendingItems.isEmpty && _sentToKitchenItems.isEmpty)
//               _buildEmptyCartMessage(),
//             SizedBox(height: 12.h),
//             _buildAddMoreRow(),
//             SizedBox(height: 12.h),
//             _buildActionButtonsRow(),
//             SizedBox(height: 12.h),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildSentItemsSection() {
//     return Container(
//       margin: EdgeInsets.only(bottom: 12.h),
//       child: Column(
//         children: [
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
//             child: Row(
//               children: [
//                 Icon(Icons.check_circle, color: _C.green, size: 16.sp),
//                 SizedBox(width: 8.w),
//                 Text(
//                   'Sent to Kitchen (${_sentToKitchenItems.length} items)',
//                   style: TextStyle(
//                     fontSize: 14.sp,
//                     fontWeight: FontWeight.w600,
//                     color: _C.orange,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           ..._sentToKitchenItems.map(
//             (item) => Padding(
//               padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: Text(
//                       item.dishName,
//                       style: TextStyle(fontSize: 16.sp, color: Colors.black),
//                     ),
//                   ),
//                   Text(
//                     '${item.quantity}',
//                     style: TextStyle(fontSize: 16.sp, color: Colors.black),
//                   ),
//                   SizedBox(width: 16.w),
//                   Text(
//                     _statusLabel(item.orderStatus),
//                     style: TextStyle(
//                       fontSize: 12.sp,
//                       color: _statusColor(item.orderStatus),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           SizedBox(height: 8.h),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildEmptyCartMessage() {
//     return Container(
//       padding: EdgeInsets.symmetric(vertical: 32.h, horizontal: 16.w),
//       child: Column(
//         children: [
//           Icon(Icons.shopping_cart_outlined, size: 48.sp, color: _C.text3),
//           SizedBox(height: 12.h),
//           Text(
//             'Your cart is empty',
//             style: TextStyle(
//               fontSize: 16.sp,
//               fontWeight: FontWeight.w600,
//               color: _C.text2,
//             ),
//           ),
//           SizedBox(height: 8.h),
//           Text(
//             'Add items from the menu',
//             style: TextStyle(fontSize: 13.sp, color: _C.text3),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildCartItemsCard() {
//     return Container(
//       decoration: BoxDecoration(
//         color: _C.white,
//         borderRadius: BorderRadius.circular(16.r),
//         border: Border.all(color: _C.border),
//       ),
//       child: Column(
//         children: [
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
//             child: Row(
//               children: [
//                 SizedBox(width: 32.w),
//                 Expanded(
//                   child: Text(
//                     'Item',
//                     style: TextStyle(
//                       fontSize: 12.sp,
//                       fontWeight: FontWeight.w700,
//                       color: _C.text2,
//                     ),
//                   ),
//                 ),
//                 SizedBox(
//                   width: 90.w,
//                   child: Text(
//                     'Qty',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       fontSize: 12.sp,
//                       fontWeight: FontWeight.w700,
//                       color: _C.text2,
//                     ),
//                   ),
//                 ),
//                 SizedBox(
//                   width: 72.w,
//                   child: Text(
//                     'Price',
//                     textAlign: TextAlign.right,
//                     style: TextStyle(
//                       fontSize: 12.sp,
//                       fontWeight: FontWeight.w700,
//                       color: _C.text2,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Divider(height: 1, color: _C.border),
//           ...(_pendingItems.asMap().entries.map((entry) {
//             final index = entry.key;
//             final item = entry.value;
//             final isLast = index == _pendingItems.length - 1;
//             return Column(
//               key: ValueKey(item.itemId),
//               children: [
//                 _buildCartItem(item),
//                 if (!isLast) Divider(height: 1, color: _C.border),
//               ],
//             );
//           }).toList()),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildCartItem(dineout.CartItem item) {
//     final isItemLoading = _itemLoadingMap[item.itemId] == true;
//     final available = _availableQuantities[item.dishId] ?? 0;
//     final bool canIncrease = available <= 0 || item.quantity < available;
//     final bool isAlreadySent = _sentToKitchenItems.any(
//       (i) => i.itemId == item.itemId,
//     );
//     final int sentQty = isAlreadySent ? item.previousQuantity : 0;
//     final int newQty = item.quantity - sentQty;
//     final double pendingPrice =
//         item.price * (isAlreadySent ? newQty : item.quantity);
//
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.w),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               GestureDetector(
//                 onTap: () => _showRemovalRequestPopup(item),
//                 child: Container(
//                   width: 28.r,
//                   height: 28.r,
//                   decoration: BoxDecoration(
//                     color: _C.red.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(6.r),
//                   ),
//                   child: Icon(Icons.close_rounded, size: 14.sp, color: _C.red),
//                 ),
//               ),
//               SizedBox(width: 8.w),
//               Expanded(
//                 child: GestureDetector(
//                   onTap: () => _showNoteDialog(item),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         item.dishName,
//                         style: TextStyle(
//                           fontSize: 13.sp,
//                           fontWeight: FontWeight.w600,
//                           color: _C.text1,
//                         ),
//                       ),
//                       if (item.orderStatus != null &&
//                           item.orderStatus!.isNotEmpty)
//                         Padding(
//                           padding: EdgeInsets.only(top: 3.h),
//                           child: Text(
//                             _statusLabel(item.orderStatus),
//                             style: TextStyle(
//                               fontSize: 10.sp,
//                               color: _statusColor(item.orderStatus),
//                             ),
//                           ),
//                         ),
//                       if (_itemNotes[item.itemId] != null)
//                         Padding(
//                           padding: EdgeInsets.only(top: 3.h),
//                           child: Text(
//                             'Note: ${_itemNotes[item.itemId]}',
//                             style: TextStyle(
//                               fontSize: 10.sp,
//                               color: _C.text3,
//                               fontStyle: FontStyle.italic,
//                             ),
//                           ),
//                         ),
//                     ],
//                   ),
//                 ),
//               ),
//               _buildQtyControl(
//                 item: item,
//                 isLoading: isItemLoading,
//                 canIncrease: canIncrease,
//                 available: available,
//                 isAlreadySent: isAlreadySent,
//                 sentQty: sentQty,
//                 newQty: newQty,
//               ),
//               SizedBox(
//                 width: 72.w,
//                 child: Text(
//                   '₹${pendingPrice.toStringAsFixed(2)}',
//                   textAlign: TextAlign.right,
//                   style: TextStyle(
//                     fontSize: 13.sp,
//                     fontWeight: FontWeight.w700,
//                     color: _C.accent,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           Padding(
//             padding: EdgeInsets.only(top: 8.h, left: 36.w),
//             child: Container(
//               padding: EdgeInsets.symmetric(horizontal: 10.w),
//               decoration: BoxDecoration(
//                 color: _C.bg,
//                 borderRadius: BorderRadius.circular(8.r),
//                 border: Border.all(color: _C.border),
//               ),
//               child: TextField(
//                 onChanged: (v) => _updateItemNote(item.itemId, v),
//                 decoration: InputDecoration(
//                   hintText: 'Add note...',
//                   hintStyle: TextStyle(fontSize: 11.sp, color: _C.text3),
//                   border: InputBorder.none,
//                   contentPadding: EdgeInsets.symmetric(vertical: 8.h),
//                 ),
//                 style: TextStyle(fontSize: 12.sp),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _showNoteDialog(dineout.CartItem item) {
//     final controller = TextEditingController(
//       text: _itemNotes[item.itemId] ?? '',
//     );
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(16.r),
//         ),
//         title: Text(
//           'Add Note for ${item.dishName}',
//           style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700),
//         ),
//         content: TextField(
//           controller: controller,
//           autofocus: true,
//           maxLines: 3,
//           decoration: InputDecoration(
//             hintText: 'Enter special instructions...',
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8.r),
//             ),
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(ctx),
//             child: Text('Cancel', style: TextStyle(color: _C.text2)),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               _updateItemNote(item.itemId, controller.text);
//               Navigator.pop(ctx);
//             },
//             style: ElevatedButton.styleFrom(backgroundColor: _C.accent),
//             child: const Text('Save', style: TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildQtyControl({
//     required dineout.CartItem item,
//     required bool isLoading,
//     required bool canIncrease,
//     required int available,
//     required bool isAlreadySent,
//     required int sentQty,
//     required int newQty,
//   }) {
//     return Container(
//       decoration: BoxDecoration(
//         color: _C.bg,
//         borderRadius: BorderRadius.circular(10.r),
//         border: Border.all(color: _C.border),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           _qtyBtn(
//             icon: Icons.remove_rounded,
//             color: _C.red,
//             onTap: _isUpdating
//                 ? null
//                 : () => _updateQuantity(item, item.quantity - 1),
//           ),
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: 10.w),
//             child: isLoading
//                 ? SizedBox(
//                     width: 14.w,
//                     height: 14.w,
//                     child: CircularProgressIndicator(
//                       color: _C.accent,
//                       strokeWidth: 1.5,
//                     ),
//                   )
//                 : isAlreadySent
//                 ? RichText(
//                     text: TextSpan(
//                       children: [
//                         TextSpan(
//                           text: '$sentQty+',
//                           style: TextStyle(
//                             fontSize: 11.sp,
//                             color: _C.text3,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                         TextSpan(
//                           text: '$newQty',
//                           style: TextStyle(
//                             fontSize: 13.sp,
//                             color: _C.accent,
//                             fontWeight: FontWeight.w700,
//                           ),
//                         ),
//                       ],
//                     ),
//                   )
//                 : Text(
//                     '${item.quantity}',
//                     style: TextStyle(
//                       fontSize: 13.sp,
//                       fontWeight: FontWeight.w700,
//                       color: _C.text1,
//                     ),
//                   ),
//           ),
//           _qtyBtn(
//             icon: Icons.add_rounded,
//             color: canIncrease ? _C.green : _C.text3,
//             onTap: _isUpdating
//                 ? null
//                 : canIncrease
//                 ? () => _updateQuantity(item, item.quantity + 1)
//                 : () => _snack(
//                     available <= 0
//                         ? 'Out of stock'
//                         : 'Only $available available',
//                     _C.orange,
//                   ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _qtyBtn({
//     required IconData icon,
//     required Color color,
//     required VoidCallback? onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: EdgeInsets.all(6.w),
//         decoration: BoxDecoration(
//           color: (onTap == null ? _C.text3 : color).withOpacity(0.10),
//           borderRadius: BorderRadius.circular(8.r),
//         ),
//         child: Icon(icon, size: 14.sp, color: onTap == null ? _C.text3 : color),
//       ),
//     );
//   }
//
//   Widget _buildAddMoreRow() {
//     return Center(
//       child: GestureDetector(
//         onTap: () async {
//           await Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (_) => DineOutMenu_Managemnet(
//                 bookingId: widget.bookingId,
//                 tableCode: widget.tableCode,
//                 userId: widget.userId,
//               ),
//             ),
//           );
//           _loadCart();
//           _loadAvailableQuantities();
//         },
//         child: Container(
//           padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
//           decoration: BoxDecoration(
//             color: _C.white,
//             borderRadius: BorderRadius.circular(12.r),
//             border: Border.all(color: _C.accent.withOpacity(0.4)),
//           ),
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Icon(
//                 Icons.add_circle_outline_rounded,
//                 color: _C.accent,
//                 size: 16.sp,
//               ),
//               SizedBox(width: 8.w),
//               Text(
//                 'Add more items',
//                 style: TextStyle(
//                   color: _C.accent,
//                   fontWeight: FontWeight.w700,
//                   decoration: TextDecoration.underline,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildActionButtonsRow() {
//     return SingleChildScrollView(
//       scrollDirection: Axis.horizontal,
//       child: Row(
//         children: [
//           _ActionButton(
//             label: 'Save',
//             color: _C.purple,
//             isLoading: _isSaving,
//             onTap: _isSaving ? null : _handleSave,
//           ),
//           SizedBox(width: 8.w),
//           _ActionButton(
//             label: 'Save & Print',
//             color: _C.blue,
//             isLoading: _isSaveAndPrinting,
//             onTap: _isSaveAndPrinting ? null : _handleSaveAndPrint,
//           ),
//           SizedBox(width: 8.w),
//           _ActionButton(
//             label: 'KOT',
//             color: _C.green,
//             isLoading: _isKOT,
//             onTap: _isKOT ? null : _handleKOT,
//           ),
//           SizedBox(width: 8.w),
//           _ActionButton(
//             label: 'KOT & Print',
//             color: _C.red,
//             isLoading: _isKOTAndPrinting,
//             onTap: _isKOTAndPrinting ? null : _handleKOTAndPrint,
//           ),
//           SizedBox(width: 8.w),
//           _ActionButton(
//             label: 'Check Out',
//             color: _C.orange,
//             isLoading: false,
//             onTap: _proceedToBilling,
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildBillingBody() {
//     return SingleChildScrollView(
//       padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 32.h),
//       child: Column(
//         children: [
//           _buildBillingItemsTable(),
//           SizedBox(height: 12.h),
//           _buildSummaryCard(),
//           SizedBox(height: 12.h),
//           _buildPaymentSection(),
//           SizedBox(height: 12.h),
//           _buildPlaceOrderBtn(),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildBillingItemsTable() {
//     if (cartData == null) return const SizedBox.shrink();
//     return Container(
//       decoration: BoxDecoration(
//         color: _C.white,
//         borderRadius: BorderRadius.circular(16.r),
//         border: Border.all(color: _C.border),
//       ),
//       child: Column(
//         children: [
//           Padding(
//             padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 12.h),
//             child: Row(
//               children: [
//                 Container(
//                   width: 28.r,
//                   height: 28.r,
//                   decoration: BoxDecoration(
//                     color: _C.accentLight,
//                     borderRadius: BorderRadius.circular(8.r),
//                   ),
//                   child: Icon(
//                     Icons.list_alt_outlined,
//                     color: _C.accent,
//                     size: 14.sp,
//                   ),
//                 ),
//                 SizedBox(width: 8.w),
//                 Text(
//                   'Order Items',
//                   style: TextStyle(
//                     fontSize: 15.sp,
//                     fontWeight: FontWeight.w700,
//                     color: _C.text1,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Divider(color: _C.border),
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
//             child: Row(
//               children: [
//                 Expanded(
//                   flex: 3,
//                   child: Text(
//                     'Item',
//                     style: TextStyle(
//                       fontSize: 12.sp,
//                       fontWeight: FontWeight.w700,
//                       color: _C.text2,
//                     ),
//                   ),
//                 ),
//                 SizedBox(
//                   width: 40.w,
//                   child: Text(
//                     'Qty',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       fontSize: 12.sp,
//                       fontWeight: FontWeight.w700,
//                       color: _C.text2,
//                     ),
//                   ),
//                 ),
//                 SizedBox(
//                   width: 60.w,
//                   child: Text(
//                     'Price',
//                     textAlign: TextAlign.right,
//                     style: TextStyle(
//                       fontSize: 12.sp,
//                       fontWeight: FontWeight.w700,
//                       color: _C.text2,
//                     ),
//                   ),
//                 ),
//                 SizedBox(
//                   width: 70.w,
//                   child: Text(
//                     'Total',
//                     textAlign: TextAlign.right,
//                     style: TextStyle(
//                       fontSize: 12.sp,
//                       fontWeight: FontWeight.w700,
//                       color: _C.text2,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Divider(color: _C.border, height: 1),
//           ...cartData!.cartItems.map((item) {
//             final total = item.price * item.quantity;
//             return Padding(
//               padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
//               child: Row(
//                 children: [
//                   Expanded(
//                     flex: 3,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           item.dishName,
//                           style: TextStyle(
//                             fontSize: 13.sp,
//                             color: _C.text1,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                         if (item.orderStatus != null &&
//                             item.orderStatus!.isNotEmpty)
//                           Text(
//                             _statusLabel(item.orderStatus),
//                             style: TextStyle(
//                               fontSize: 10.sp,
//                               color: _statusColor(item.orderStatus),
//                             ),
//                           ),
//                       ],
//                     ),
//                   ),
//                   SizedBox(
//                     width: 40.w,
//                     child: Text(
//                       '${item.quantity}',
//                       textAlign: TextAlign.center,
//                       style: TextStyle(fontSize: 13.sp, color: _C.text1),
//                     ),
//                   ),
//                   SizedBox(
//                     width: 60.w,
//                     child: Text(
//                       '₹${item.price.toStringAsFixed(2)}',
//                       textAlign: TextAlign.right,
//                       style: TextStyle(fontSize: 12.sp, color: _C.text2),
//                     ),
//                   ),
//                   SizedBox(
//                     width: 70.w,
//                     child: Text(
//                       '₹${total.toStringAsFixed(2)}',
//                       textAlign: TextAlign.right,
//                       style: TextStyle(
//                         fontSize: 13.sp,
//                         color: _C.accent,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           }).toList(),
//           SizedBox(height: 8.h),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSummaryCard() {
//     if (cartData == null) return const SizedBox.shrink();
//     final hasTakeaway = cartData!.cartItems.any(
//       (i) => i.orderType == 'TAKEAWAY',
//     );
//     return Container(
//       decoration: BoxDecoration(
//         color: _C.white,
//         borderRadius: BorderRadius.circular(16.r),
//         border: Border.all(color: _C.accent.withOpacity(0.3)),
//       ),
//       child: Column(
//         children: [
//           Container(
//             padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 12.h),
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [_C.accent, _C.accentDark],
//                 begin: Alignment.centerLeft,
//                 end: Alignment.centerRight,
//               ),
//               borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
//             ),
//             child: Row(
//               children: [
//                 Container(
//                   width: 28.r,
//                   height: 28.r,
//                   decoration: BoxDecoration(
//                     color: Colors.white.withOpacity(0.2),
//                     borderRadius: BorderRadius.circular(8.r),
//                   ),
//                   child: Icon(
//                     Icons.receipt_long_outlined,
//                     color: Colors.white,
//                     size: 14.sp,
//                   ),
//                 ),
//                 SizedBox(width: 8.w),
//                 Text(
//                   'Order Summary',
//                   style: TextStyle(
//                     fontSize: 15.sp,
//                     fontWeight: FontWeight.w700,
//                     color: Colors.white,
//                   ),
//                 ),
//                 const Spacer(),
//                 Container(
//                   padding: EdgeInsets.symmetric(
//                     horizontal: 10.w,
//                     vertical: 4.h,
//                   ),
//                   decoration: BoxDecoration(
//                     color: Colors.white.withOpacity(0.2),
//                     borderRadius: BorderRadius.circular(20.r),
//                   ),
//                   child: Text(
//                     '₹${_finalAmount.toStringAsFixed(0)}',
//                     style: TextStyle(
//                       fontSize: 13.sp,
//                       fontWeight: FontWeight.w800,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Padding(
//             padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 14.h),
//             child: Column(
//               children: [
//                 _summaryRow('Sub Total', cartData?.subtotal ?? 0),
//                 if (hasTakeaway)
//                   _summaryRow('Packing Charges', cartData?.packingTotal ?? 0),
//                 _buildServiceChargeRow(),
//                 if (_isUserLoggedIn && (cartData?.platformCharges ?? 0) > 0)
//                   _summaryRow(
//                     'Platform Charges',
//                     cartData?.platformCharges ?? 0,
//                   ),
//                 _summaryRow('SGST', (cartData?.gstTotal ?? 0) / 2),
//                 _summaryRow('CGST', (cartData?.gstTotal ?? 0) / 2),
//                 _buildVendorDiscountSection(),
//                 if (_isDiscountApplied && _discountAmount > 0)
//                   _summaryRow('Discount', -_discountAmount, isDiscount: true),
//                 SizedBox(height: 8.h),
//                 Divider(color: _C.accent.withOpacity(0.2)),
//                 SizedBox(height: 6.h),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       'Grand Total',
//                       style: TextStyle(
//                         fontSize: 16.sp,
//                         fontWeight: FontWeight.w800,
//                         color: _C.text1,
//                       ),
//                     ),
//                     Container(
//                       padding: EdgeInsets.symmetric(
//                         horizontal: 12.w,
//                         vertical: 6.h,
//                       ),
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                           colors: [_C.accent, _C.accentDark],
//                         ),
//                         borderRadius: BorderRadius.circular(10.r),
//                       ),
//                       child: Text(
//                         '₹${_finalAmount.toStringAsFixed(2)}',
//                         style: TextStyle(
//                           fontSize: 15.sp,
//                           fontWeight: FontWeight.w900,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildServiceChargeRow() {
//     final double chargeAmount = cartData?.serviceCharges ?? 0;
//     if (chargeAmount <= 0) return const SizedBox.shrink();
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 4.h),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             'Service Charges',
//             style: TextStyle(fontSize: 13.sp, color: _C.text2),
//           ),
//           Row(
//             children: [
//               GestureDetector(
//                 onTap: () async {
//                   if (cartData?.cartId == null) return;
//                   final newStatus = isServiceChargeApplied
//                       ? 'NOT_APPLICABLE'
//                       : 'APPLICABLE';
//                   await food_authservice.updateServiceCharges(
//                     cartId: cartData!.cartId,
//                     serviceCharge: newStatus,
//                   );
//                   setState(
//                     () => isServiceChargeApplied = !isServiceChargeApplied,
//                   );
//                   await _loadCart();
//                 },
//                 child: Container(
//                   padding: EdgeInsets.symmetric(
//                     horizontal: 10.w,
//                     vertical: 4.h,
//                   ),
//                   decoration: BoxDecoration(
//                     color: isServiceChargeApplied
//                         ? _C.redLight
//                         : _C.accentLight,
//                     borderRadius: BorderRadius.circular(20.r),
//                   ),
//                   child: Text(
//                     isServiceChargeApplied ? 'Remove' : 'Apply',
//                     style: TextStyle(
//                       fontSize: 11.sp,
//                       fontWeight: FontWeight.w700,
//                       color: _C.accent,
//                     ),
//                   ),
//                 ),
//               ),
//               SizedBox(width: 8.w),
//               Text(
//                 '₹${chargeAmount.toStringAsFixed(2)}',
//                 style: TextStyle(
//                   fontSize: 13.sp,
//                   fontWeight: FontWeight.w600,
//                   color: isServiceChargeApplied ? _C.text1 : _C.text3,
//                   decoration: isServiceChargeApplied
//                       ? TextDecoration.none
//                       : TextDecoration.lineThrough,
//                   decorationColor: _C.text3,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildVendorDiscountSection() {
//     return Column(
//       children: [
//         SizedBox(height: 8.h),
//         Row(
//           children: [
//             Icon(Icons.local_offer_outlined, size: 14.sp, color: _C.accent),
//             SizedBox(width: 6.w),
//             Text(
//               'Discount',
//               style: TextStyle(
//                 fontSize: 13.sp,
//                 fontWeight: FontWeight.w600,
//                 color: _C.text1,
//               ),
//             ),
//           ],
//         ),
//         SizedBox(height: 8.h),
//         if (!_isDiscountApplied) ...[
//           Row(
//             children: [
//               Expanded(
//                 child: Container(
//                   height: 38.h,
//                   decoration: BoxDecoration(
//                     border: Border.all(color: _C.border),
//                     borderRadius: BorderRadius.circular(8.r),
//                   ),
//                   child: TextField(
//                     controller: _discountController,
//                     keyboardType: const TextInputType.numberWithOptions(
//                       decimal: true,
//                     ),
//                     decoration: InputDecoration(
//                       hintText: 'Enter discount amount (₹)',
//                       hintStyle: TextStyle(fontSize: 12.sp, color: _C.text3),
//                       border: InputBorder.none,
//                       prefixIcon: Icon(
//                         Icons.currency_rupee,
//                         size: 14.sp,
//                         color: _C.text3,
//                       ),
//                       contentPadding: EdgeInsets.symmetric(vertical: 10.h),
//                     ),
//                     style: TextStyle(fontSize: 12.sp),
//                   ),
//                 ),
//               ),
//               SizedBox(width: 8.w),
//               GestureDetector(
//                 onTap: _isApplyingDiscount ? null : _applyVendorDiscount,
//                 child: Container(
//                   padding: EdgeInsets.symmetric(
//                     horizontal: 16.w,
//                     vertical: 10.h,
//                   ),
//                   decoration: BoxDecoration(
//                     color: _isApplyingDiscount
//                         ? _C.accent.withOpacity(0.5)
//                         : _C.accent,
//                     borderRadius: BorderRadius.circular(8.r),
//                   ),
//                   child: _isApplyingDiscount
//                       ? SizedBox(
//                           width: 14.w,
//                           height: 14.w,
//                           child: const CircularProgressIndicator(
//                             color: Colors.white,
//                             strokeWidth: 2,
//                           ),
//                         )
//                       : Text(
//                           'Apply',
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.w600,
//                             fontSize: 12.sp,
//                           ),
//                         ),
//                 ),
//               ),
//             ],
//           ),
//         ] else ...[
//           Container(
//             padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
//             decoration: BoxDecoration(
//               color: _C.greenLight,
//               borderRadius: BorderRadius.circular(8.r),
//               border: Border.all(color: _C.green.withOpacity(0.3)),
//             ),
//             child: Row(
//               children: [
//                 Icon(
//                   Icons.check_circle_outline_rounded,
//                   color: _C.green,
//                   size: 16.sp,
//                 ),
//                 SizedBox(width: 8.w),
//                 Expanded(
//                   child: Text(
//                     'Discount of ₹${_discountAmount.toStringAsFixed(2)} applied!',
//                     style: TextStyle(
//                       fontSize: 12.sp,
//                       color: _C.green,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//                 GestureDetector(
//                   onTap: _removeVendorDiscount,
//                   child: Icon(Icons.close, size: 14.sp, color: _C.red),
//                 ),
//               ],
//             ),
//           ),
//         ],
//         SizedBox(height: 4.h),
//       ],
//     );
//   }
//
//   Widget _summaryRow(String label, num value, {bool isDiscount = false}) {
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 4.h),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             label,
//             style: TextStyle(fontSize: 13.sp, color: _C.text2),
//           ),
//           Text(
//             '${value >= 0 ? '₹' : '-₹'}${value.abs().toStringAsFixed(2)}',
//             style: TextStyle(
//               fontSize: 13.sp,
//               color: isDiscount ? _C.green : _C.text1,
//               fontWeight: isDiscount ? FontWeight.w600 : FontWeight.normal,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildPaymentSection() {
//     final orderType = cartData?.orderType ?? 'DINE_IN';
//     final List<Widget> paymentOptions = [];
//     if (_paymentMethodsConfig['cash'] == true && orderType != 'DELIVERY')
//       paymentOptions.add(
//         _buildPaymentOption('Cash', Icons.payments_outlined, 'Cash'),
//       );
//     if (_paymentMethodsConfig['upi'] == true)
//       paymentOptions.add(
//         _buildPaymentOption(
//           'UPI',
//           Icons.account_balance_wallet_outlined,
//           'UPI',
//         ),
//       );
//     if (_isUserLoggedIn)
//       paymentOptions.add(
//         _buildPaymentOption(
//           'Razorpay',
//           Icons.credit_card_outlined,
//           'Online_Payment',
//         ),
//       );
//     if (!_isUserLoggedIn && _paymentMethodsConfig['qrCode'] == true)
//       paymentOptions.add(
//         _buildPaymentOption(
//           'QR Code Payment',
//           Icons.qr_code_2_outlined,
//           'QR_Payment',
//         ),
//       );
//     return Container(
//       decoration: BoxDecoration(
//         color: _C.white,
//         borderRadius: BorderRadius.circular(16.r),
//         border: Border.all(color: _C.border),
//       ),
//       child: Column(
//         children: [
//           Padding(
//             padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 12.h),
//             child: Row(
//               children: [
//                 Container(
//                   width: 28.r,
//                   height: 28.r,
//                   decoration: BoxDecoration(
//                     color: _C.accentLight,
//                     borderRadius: BorderRadius.circular(8.r),
//                   ),
//                   child: Icon(
//                     Icons.payment_outlined,
//                     color: _C.accent,
//                     size: 14.sp,
//                   ),
//                 ),
//                 SizedBox(width: 8.w),
//                 Text(
//                   'Payment Method',
//                   style: TextStyle(
//                     fontSize: 15.sp,
//                     fontWeight: FontWeight.w700,
//                     color: _C.text1,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Divider(color: _C.border),
//           Padding(
//             padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 12.h),
//             child: paymentOptions.isEmpty
//                 ? Padding(
//                     padding: EdgeInsets.symmetric(vertical: 12.h),
//                     child: Text(
//                       'No payment methods available',
//                       style: TextStyle(fontSize: 13.sp, color: _C.text3),
//                     ),
//                   )
//                 : Column(children: paymentOptions),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildPaymentOption(String label, IconData icon, String value) {
//     final isSelected = selectedPaymentMethod == value;
//     return GestureDetector(
//       onTap: () {
//         setState(() => selectedPaymentMethod = value);
//         if (value == 'QR_Payment') _generateDynamicQrAndPoll();
//       },
//       child: Container(
//         margin: EdgeInsets.only(bottom: 8.h),
//         padding: EdgeInsets.all(14.w),
//         decoration: BoxDecoration(
//           color: isSelected ? _C.accentLight : _C.bg,
//           borderRadius: BorderRadius.circular(12.r),
//           border: Border.all(
//             color: isSelected ? _C.accent : _C.border,
//             width: isSelected ? 1.5 : 1,
//           ),
//         ),
//         child: Row(
//           children: [
//             Container(
//               width: 36.r,
//               height: 36.r,
//               decoration: BoxDecoration(
//                 color: isSelected ? _C.accent : _C.white,
//                 borderRadius: BorderRadius.circular(10.r),
//                 border: isSelected ? null : Border.all(color: _C.border),
//               ),
//               child: Icon(
//                 icon,
//                 color: isSelected ? Colors.white : _C.text2,
//                 size: 18.sp,
//               ),
//             ),
//             SizedBox(width: 12.w),
//             Expanded(
//               child: Text(
//                 label,
//                 style: TextStyle(
//                   fontSize: 14.sp,
//                   fontWeight: FontWeight.w600,
//                   color: isSelected ? _C.accent : _C.text1,
//                 ),
//               ),
//             ),
//             if (value == 'QR_Payment' && _isGeneratingQr)
//               SizedBox(
//                 width: 18.w,
//                 height: 18.w,
//                 child: CircularProgressIndicator(
//                   color: _C.accent,
//                   strokeWidth: 2,
//                 ),
//               )
//             else if (isSelected)
//               Container(
//                 width: 20.r,
//                 height: 20.r,
//                 decoration: BoxDecoration(
//                   color: _C.accent,
//                   shape: BoxShape.circle,
//                 ),
//                 child: Icon(
//                   Icons.check_rounded,
//                   color: Colors.white,
//                   size: 13.sp,
//                 ),
//               )
//             else
//               Container(
//                 width: 20.r,
//                 height: 20.r,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   border: Border.all(color: _C.border, width: 1.5),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildPlaceOrderBtn() {
//     return GestureDetector(
//       onTap: isPlacingOrder ? null : placeOrder,
//       child: Container(
//         width: double.infinity,
//         padding: EdgeInsets.symmetric(vertical: 15.h),
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: isPlacingOrder
//                 ? [_C.text3, _C.text3]
//                 : [_C.accent, _C.accentDark],
//           ),
//           borderRadius: BorderRadius.circular(14.r),
//         ),
//         child: isPlacingOrder
//             ? Center(
//                 child: SizedBox(
//                   width: 22.w,
//                   height: 22.w,
//                   child: CircularProgressIndicator(
//                     color: Colors.white,
//                     strokeWidth: 2,
//                   ),
//                 ),
//               )
//             : Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(
//                     Icons.check_circle_outline_rounded,
//                     color: Colors.white,
//                     size: 18.sp,
//                   ),
//                   SizedBox(width: 8.w),
//                   Text(
//                     selectedPaymentMethod.isEmpty
//                         ? 'Select Payment Method'
//                         : 'Pay ₹${_finalAmount.toStringAsFixed(2)}',
//                     style: TextStyle(
//                       fontSize: 15.sp,
//                       fontWeight: FontWeight.w800,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ],
//               ),
//       ),
//     );
//   }
//
//   Widget _buildEmptyCart() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             width: 90.r,
//             height: 90.r,
//             decoration: BoxDecoration(
//               color: _C.accentLight,
//               shape: BoxShape.circle,
//             ),
//             child: Icon(
//               Icons.shopping_cart_outlined,
//               size: 40.sp,
//               color: _C.accent,
//             ),
//           ),
//           SizedBox(height: 16.h),
//           Text(
//             'Your cart is empty',
//             style: TextStyle(
//               fontSize: 18.sp,
//               fontWeight: FontWeight.w700,
//               color: _C.text1,
//             ),
//           ),
//           SizedBox(height: 6.h),
//           Text(
//             'Add some delicious items',
//             style: TextStyle(fontSize: 13.sp, color: _C.text2),
//           ),
//           SizedBox(height: 24.h),
//           GestureDetector(
//             onTap: () async {
//               await Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (_) => DineOutMenu_Managemnet(
//                     bookingId: widget.bookingId,
//                     tableCode: widget.tableCode,
//                     userId: widget.userId,
//                   ),
//                 ),
//               );
//               _loadCart();
//               _loadAvailableQuantities();
//             },
//             child: Container(
//               padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 13.h),
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(colors: [_C.accent, _C.accentDark]),
//                 borderRadius: BorderRadius.circular(14.r),
//               ),
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Icon(
//                     Icons.restaurant_menu_rounded,
//                     color: Colors.white,
//                     size: 16.sp,
//                   ),
//                   SizedBox(width: 8.w),
//                   Text(
//                     'Browse Menu',
//                     style: TextStyle(
//                       fontSize: 14.sp,
//                       fontWeight: FontWeight.w700,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _RemovalRequestDialog extends StatefulWidget {
//   final dineout.CartItem item;
//   final int cartId;
//   final int vendorId;
//   final int userId;
//   final int employeeId;
//   final String employeeName;
//   final int bookingId;
//   final String tableCode;
//   final VoidCallback onSuccess;
//   final void Function(String) onError;
//
//   const _RemovalRequestDialog({
//     required this.item,
//     required this.cartId,
//     required this.vendorId,
//     required this.userId,
//     required this.employeeId,
//     required this.employeeName,
//     required this.bookingId,
//     required this.tableCode,
//     required this.onSuccess,
//     required this.onError,
//   });
//
//   @override
//   State<_RemovalRequestDialog> createState() => _RemovalRequestDialogState();
// }
//
// class _RemovalRequestDialogState extends State<_RemovalRequestDialog> {
//   final _reasonController = TextEditingController();
//   bool _isSubmitting = false;
//   int _requestedQty = 1;
//
//   @override
//   void dispose() {
//     _reasonController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _submit() async {
//     final reason = _reasonController.text.trim();
//     if (reason.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: const Text(
//             'Please enter a reason',
//             style: TextStyle(color: Colors.white),
//           ),
//           backgroundColor: _C.orange,
//           behavior: SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(10.r),
//           ),
//         ),
//       );
//       return;
//     }
//
//     setState(() => _isSubmitting = true);
//
//     try {
//       final removalRequest = TableRequestModel(
//         vendorId: widget.vendorId,
//         userId: widget.userId,
//         name: widget.employeeName,
//         itemId: widget.item.itemId,
//         cartId: widget.cartId,
//         tableBookingId: widget.bookingId,
//         tableCode: widget.tableCode,
//         status: 'PENDING',
//         requestType: 'REMOVAL_QUANTITY',
//         itemName: widget.item.dishName,
//         quantity: _requestedQty,
//       );
//
//       final step1 = await TableRequestService.submitRemovalRequest(
//         cartId: widget.cartId,
//         request: removalRequest,
//       );
//
//       if (!step1) {
//         widget.onError('Failed to submit removal request. Please try again.');
//         Navigator.pop(context);
//         return;
//       }
//
//       final createRequest = CreateTableRequestModel(
//         vendorId: widget.vendorId,
//         userId: widget.userId,
//         itemId: widget.item.itemId,
//         cartId: widget.cartId,
//         tableBookingId: widget.bookingId,
//         tableCode: widget.tableCode,
//         requestType: 'REMOVAL_QUANTITY',
//         employeeId: widget.employeeId,
//         reason: reason,
//       );
//
//       final step2 = await TableRequestService.createTableRequest(
//         request: createRequest,
//       );
//
//       Navigator.pop(context);
//
//       if (step2) {
//         widget.onSuccess();
//       } else {
//         // step1 succeeded so partial success
//         widget.onSuccess();
//       }
//     } catch (e) {
//       widget.onError('Error: $e');
//       Navigator.pop(context);
//     } finally {
//       if (mounted) setState(() => _isSubmitting = false);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     ScreenUtil.init(context);
//
//     return Padding(
//       padding: EdgeInsets.only(
//         bottom: MediaQuery.of(context).viewInsets.bottom,
//       ),
//       child: Container(
//         decoration: BoxDecoration(
//           color: _C.white,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
//         ),
//         child: SafeArea(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // ── Handle ─────────────────────────────────────────────────────
//               Container(
//                 width: 40.w,
//                 height: 4.h,
//                 margin: EdgeInsets.only(top: 12.h),
//                 decoration: BoxDecoration(
//                   color: _C.border,
//                   borderRadius: BorderRadius.circular(2.r),
//                 ),
//               ),
//
//               // ── Header ─────────────────────────────────────────────────────
//               Padding(
//                 padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
//                 child: Row(
//                   children: [
//                     Container(
//                       width: 42.r,
//                       height: 42.r,
//                       decoration: BoxDecoration(
//                         color: _C.redLight,
//                         borderRadius: BorderRadius.circular(12.r),
//                       ),
//                       child: Icon(
//                         Icons.remove_shopping_cart_outlined,
//                         color: _C.red,
//                         size: 22.sp,
//                       ),
//                     ),
//                     SizedBox(width: 12.w),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Removal Request',
//                             style: TextStyle(
//                               fontSize: 17.sp,
//                               fontWeight: FontWeight.w800,
//                               color: _C.text1,
//                             ),
//                           ),
//                           Text(
//                             'Raise a request to reduce item quantity',
//                             style: TextStyle(fontSize: 12.sp, color: _C.text2),
//                           ),
//                         ],
//                       ),
//                     ),
//                     GestureDetector(
//                       onTap: () => Navigator.pop(context),
//                       child: Container(
//                         width: 30.r,
//                         height: 30.r,
//                         decoration: BoxDecoration(
//                           color: _C.bg,
//                           borderRadius: BorderRadius.circular(8.r),
//                           border: Border.all(color: _C.border),
//                         ),
//                         child: Icon(Icons.close, size: 16.sp, color: _C.text2),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//
//               // ── Item Info Card ──────────────────────────────────────────────
//               Padding(
//                 padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
//                 child: Container(
//                   padding: EdgeInsets.all(14.r),
//                   decoration: BoxDecoration(
//                     color: _C.accentLight,
//                     borderRadius: BorderRadius.circular(12.r),
//                     border: Border.all(color: _C.accent.withOpacity(0.3)),
//                   ),
//                   child: Row(
//                     children: [
//                       Container(
//                         width: 36.r,
//                         height: 36.r,
//                         decoration: BoxDecoration(
//                           color: _C.accent,
//                           borderRadius: BorderRadius.circular(10.r),
//                         ),
//                         child: Icon(
//                           Icons.restaurant_menu_rounded,
//                           color: Colors.white,
//                           size: 18.sp,
//                         ),
//                       ),
//                       SizedBox(width: 10.w),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               widget.item.dishName,
//                               style: TextStyle(
//                                 fontSize: 14.sp,
//                                 fontWeight: FontWeight.w700,
//                                 color: _C.text1,
//                               ),
//                             ),
//                             Text(
//                               'Current qty: ${widget.item.quantity}  •  ₹${widget.item.price.toStringAsFixed(2)} each',
//                               style: TextStyle(
//                                 fontSize: 11.sp,
//                                 color: _C.text2,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//
//               // ── Quantity Selector ──────────────────────────────────────────
//               Padding(
//                 padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Quantity to Remove',
//                       style: TextStyle(
//                         fontSize: 13.sp,
//                         fontWeight: FontWeight.w600,
//                         color: _C.text1,
//                       ),
//                     ),
//                     SizedBox(height: 10.h),
//                     Container(
//                       padding: EdgeInsets.symmetric(
//                         horizontal: 4.w,
//                         vertical: 6.h,
//                       ),
//                       decoration: BoxDecoration(
//                         color: _C.bg,
//                         borderRadius: BorderRadius.circular(12.r),
//                         border: Border.all(color: _C.border),
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           // Decrement
//                           GestureDetector(
//                             onTap: _requestedQty > 1
//                                 ? () => setState(() => _requestedQty--)
//                                 : null,
//                             child: Container(
//                               width: 38.r,
//                               height: 38.r,
//                               decoration: BoxDecoration(
//                                 color: _requestedQty > 1
//                                     ? _C.red.withOpacity(0.1)
//                                     : _C.border.withOpacity(0.4),
//                                 borderRadius: BorderRadius.circular(10.r),
//                               ),
//                               child: Icon(
//                                 Icons.remove_rounded,
//                                 size: 18.sp,
//                                 color: _requestedQty > 1 ? _C.red : _C.text3,
//                               ),
//                             ),
//                           ),
//                           SizedBox(width: 20.w),
//                           Text(
//                             '$_requestedQty',
//                             style: TextStyle(
//                               fontSize: 22.sp,
//                               fontWeight: FontWeight.w900,
//                               color: _C.red,
//                             ),
//                           ),
//                           SizedBox(width: 20.w),
//                           // Increment
//                           GestureDetector(
//                             onTap: _requestedQty < widget.item.quantity
//                                 ? () => setState(() => _requestedQty++)
//                                 : null,
//                             child: Container(
//                               width: 38.r,
//                               height: 38.r,
//                               decoration: BoxDecoration(
//                                 color: _requestedQty < widget.item.quantity
//                                     ? _C.green.withOpacity(0.1)
//                                     : _C.border.withOpacity(0.4),
//                                 borderRadius: BorderRadius.circular(10.r),
//                               ),
//                               child: Icon(
//                                 Icons.add_rounded,
//                                 size: 18.sp,
//                                 color: _requestedQty < widget.item.quantity
//                                     ? _C.green
//                                     : _C.text3,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//
//               // ── Reason Input ──────────────────────────────────────────────
//               Padding(
//                 padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Reason for Removal',
//                       style: TextStyle(
//                         fontSize: 13.sp,
//                         fontWeight: FontWeight.w600,
//                         color: _C.text1,
//                       ),
//                     ),
//                     SizedBox(height: 8.h),
//                     Container(
//                       decoration: BoxDecoration(
//                         color: _C.bg,
//                         borderRadius: BorderRadius.circular(12.r),
//                         border: Border.all(color: _C.border),
//                       ),
//                       child: TextField(
//                         controller: _reasonController,
//                         maxLines: 3,
//                         autofocus: false,
//                         decoration: InputDecoration(
//                           hintText:
//                               'e.g. Customer changed mind, wrong item, etc.',
//                           hintStyle: TextStyle(
//                             fontSize: 12.sp,
//                             color: _C.text3,
//                           ),
//                           border: InputBorder.none,
//                           contentPadding: EdgeInsets.all(12.r),
//                         ),
//                         style: TextStyle(fontSize: 13.sp, color: _C.text1),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//
//               // ── Action Buttons ─────────────────────────────────────────────
//               Padding(
//                 padding: EdgeInsets.all(20.r),
//                 child: Row(
//                   children: [
//                     // Cancel
//                     Expanded(
//                       child: GestureDetector(
//                         onTap: () => Navigator.pop(context),
//                         child: Container(
//                           padding: EdgeInsets.symmetric(vertical: 14.h),
//                           decoration: BoxDecoration(
//                             color: _C.bg,
//                             borderRadius: BorderRadius.circular(12.r),
//                             border: Border.all(color: _C.border),
//                           ),
//                           child: Center(
//                             child: Text(
//                               'Cancel',
//                               style: TextStyle(
//                                 fontSize: 14.sp,
//                                 fontWeight: FontWeight.w700,
//                                 color: _C.text2,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                     SizedBox(width: 12.w),
//                     // Submit
//                     Expanded(
//                       flex: 2,
//                       child: GestureDetector(
//                         onTap: _isSubmitting ? null : _submit,
//                         child: Container(
//                           padding: EdgeInsets.symmetric(vertical: 14.h),
//                           decoration: BoxDecoration(
//                             gradient: LinearGradient(
//                               colors: _isSubmitting
//                                   ? [_C.text3, _C.text3]
//                                   : [_C.red, const Color(0xFFB91C1C)],
//                             ),
//                             borderRadius: BorderRadius.circular(12.r),
//                           ),
//                           child: _isSubmitting
//                               ? Center(
//                                   child: SizedBox(
//                                     width: 20.w,
//                                     height: 20.w,
//                                     child: const CircularProgressIndicator(
//                                       color: Colors.white,
//                                       strokeWidth: 2,
//                                     ),
//                                   ),
//                                 )
//                               : Row(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     Icon(
//                                       Icons.send_rounded,
//                                       color: Colors.white,
//                                       size: 16.sp,
//                                     ),
//                                     SizedBox(width: 8.w),
//                                     Text(
//                                       'Submit Request',
//                                       style: TextStyle(
//                                         fontSize: 14.sp,
//                                         fontWeight: FontWeight.w700,
//                                         color: Colors.white,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // ─── Action Button Widget (unchanged) ────────────────────────────────────────
// class _ActionButton extends StatelessWidget {
//   final String label;
//   final Color color;
//   final VoidCallback? onTap;
//   final bool isLoading;
//
//   const _ActionButton({
//     required this.label,
//     required this.color,
//     this.onTap,
//     this.isLoading = false,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
//         decoration: BoxDecoration(
//           color: onTap == null ? color.withOpacity(0.4) : color,
//           borderRadius: BorderRadius.circular(8.r),
//         ),
//         child: isLoading
//             ? SizedBox(
//                 width: 14.w,
//                 height: 14.w,
//                 child: CircularProgressIndicator(
//                   color: Colors.white,
//                   strokeWidth: 2,
//                 ),
//               )
//             : Text(
//                 label,
//                 style: TextStyle(
//                   fontSize: 11.sp,
//                   fontWeight: FontWeight.w700,
//                   color: Colors.white,
//                 ),
//               ),
//       ),
//     );
//   }
// }
//
// // ─── Printer Bottom Sheet (unchanged) ────────────────────────────────────────
// class _PrinterBottomSheet extends StatefulWidget {
//   final List<dineout.CartItem> items;
//   final bool isKOT;
//   final Function(String) onPrint;
//   final VoidCallback onSkipPrint;
//   final Future<void> Function() onLoadDevices;
//   final List<BluetoothInfo> pairedDevices;
//   final bool isLoading;
//
//   const _PrinterBottomSheet({
//     required this.items,
//     required this.isKOT,
//     required this.onPrint,
//     required this.onSkipPrint,
//     required this.onLoadDevices,
//     required this.pairedDevices,
//     required this.isLoading,
//   });
//
//   @override
//   State<_PrinterBottomSheet> createState() => __PrinterBottomSheetState();
// }
//
// class __PrinterBottomSheetState extends State<_PrinterBottomSheet> {
//   bool _isConnecting = false;
//
//   @override
//   void initState() {
//     super.initState();
//     widget.onLoadDevices();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: _C.white,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
//       ),
//       child: SafeArea(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               width: 40.w,
//               height: 4.h,
//               margin: EdgeInsets.only(top: 10.h),
//               decoration: BoxDecoration(
//                 color: _C.border,
//                 borderRadius: BorderRadius.circular(2.r),
//               ),
//             ),
//             Padding(
//               padding: EdgeInsets.all(16.r),
//               child: Row(
//                 children: [
//                   Container(
//                     width: 38.r,
//                     height: 38.r,
//                     decoration: BoxDecoration(
//                       color: _C.blueLight,
//                       borderRadius: BorderRadius.circular(10.r),
//                     ),
//                     child: Icon(
//                       Icons.print_rounded,
//                       color: _C.blue,
//                       size: 20.sp,
//                     ),
//                   ),
//                   SizedBox(width: 12.w),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Select Printer',
//                           style: TextStyle(
//                             fontSize: 16.sp,
//                             fontWeight: FontWeight.w800,
//                             color: _C.text1,
//                           ),
//                         ),
//                         Text(
//                           '${widget.items.length} item(s)',
//                           style: TextStyle(fontSize: 11.sp, color: _C.text2),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Divider(color: _C.border, height: 1),
//             SizedBox(
//               height: 220.h,
//               child: widget.isLoading
//                   ? Center(
//                       child: CircularProgressIndicator(
//                         color: _C.accent,
//                         strokeWidth: 2,
//                       ),
//                     )
//                   : widget.pairedDevices.isEmpty
//                   ? Center(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(
//                             Icons.bluetooth_disabled_rounded,
//                             size: 40.sp,
//                             color: _C.text3,
//                           ),
//                           SizedBox(height: 10.h),
//                           Text(
//                             'No printers found',
//                             style: TextStyle(
//                               color: _C.text2,
//                               fontSize: 13.sp,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                           SizedBox(height: 4.h),
//                           Text(
//                             'Please pair your printer first',
//                             style: TextStyle(color: _C.text3, fontSize: 11.sp),
//                           ),
//                         ],
//                       ),
//                     )
//                   : ListView.builder(
//                       padding: EdgeInsets.symmetric(
//                         horizontal: 16.w,
//                         vertical: 8.h,
//                       ),
//                       itemCount: widget.pairedDevices.length,
//                       itemBuilder: (_, i) {
//                         final device = widget.pairedDevices[i];
//                         return Container(
//                           margin: EdgeInsets.only(bottom: 8.h),
//                           padding: EdgeInsets.all(12.r),
//                           decoration: BoxDecoration(
//                             color: _C.bg,
//                             borderRadius: BorderRadius.circular(10.r),
//                             border: Border.all(color: _C.border),
//                           ),
//                           child: Row(
//                             children: [
//                               Container(
//                                 width: 34.r,
//                                 height: 34.r,
//                                 decoration: BoxDecoration(
//                                   color: _C.blueLight,
//                                   borderRadius: BorderRadius.circular(8.r),
//                                 ),
//                                 child: Icon(
//                                   Icons.print_rounded,
//                                   color: _C.blue,
//                                   size: 16.sp,
//                                 ),
//                               ),
//                               SizedBox(width: 10.w),
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       device.name,
//                                       style: TextStyle(
//                                         fontSize: 13.sp,
//                                         fontWeight: FontWeight.w600,
//                                         color: _C.text1,
//                                       ),
//                                       overflow: TextOverflow.ellipsis,
//                                     ),
//                                     Text(
//                                       device.macAdress,
//                                       style: TextStyle(
//                                         fontSize: 10.sp,
//                                         color: _C.text3,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               GestureDetector(
//                                 onTap: _isConnecting
//                                     ? null
//                                     : () async {
//                                         setState(() => _isConnecting = true);
//                                         await widget.onPrint(device.macAdress);
//                                         if (mounted) Navigator.pop(context);
//                                       },
//                                 child: Container(
//                                   padding: EdgeInsets.symmetric(
//                                     horizontal: 12.w,
//                                     vertical: 7.h,
//                                   ),
//                                   decoration: BoxDecoration(
//                                     gradient: const LinearGradient(
//                                       colors: [
//                                         Color(0xFF10B981),
//                                         Color(0xFF059669),
//                                       ],
//                                     ),
//                                     borderRadius: BorderRadius.circular(8.r),
//                                   ),
//                                   child: _isConnecting
//                                       ? SizedBox(
//                                           width: 14.r,
//                                           height: 14.r,
//                                           child:
//                                               const CircularProgressIndicator(
//                                                 color: Colors.white,
//                                                 strokeWidth: 2,
//                                               ),
//                                         )
//                                       : Text(
//                                           'Print',
//                                           style: TextStyle(
//                                             color: Colors.white,
//                                             fontSize: 12.sp,
//                                             fontWeight: FontWeight.w700,
//                                           ),
//                                         ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         );
//                       },
//                     ),
//             ),
//             Divider(color: _C.border, height: 1),
//             Padding(
//               padding: EdgeInsets.all(16.r),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: GestureDetector(
//                       onTap: () {
//                         widget.onSkipPrint();
//                         Navigator.pop(context);
//                       },
//                       child: Container(
//                         padding: EdgeInsets.symmetric(vertical: 13.h),
//                         decoration: BoxDecoration(
//                           color: _C.amberLight,
//                           borderRadius: BorderRadius.circular(10.r),
//                           border: Border.all(color: _C.orange.withOpacity(0.3)),
//                         ),
//                         child: Center(
//                           child: Text(
//                             widget.isKOT
//                                 ? 'Send Without Print'
//                                 : 'Save Without Print',
//                             style: TextStyle(
//                               fontSize: 12.sp,
//                               fontWeight: FontWeight.w700,
//                               color: _C.orange,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                   SizedBox(width: 10.w),
//                   Expanded(
//                     child: GestureDetector(
//                       onTap: () => Navigator.pop(context),
//                       child: Container(
//                         padding: EdgeInsets.symmetric(vertical: 13.h),
//                         decoration: BoxDecoration(
//                           color: _C.bg,
//                           borderRadius: BorderRadius.circular(10.r),
//                           border: Border.all(color: _C.border),
//                         ),
//                         child: Center(
//                           child: Text(
//                             'Cancel',
//                             style: TextStyle(
//                               fontSize: 12.sp,
//                               fontWeight: FontWeight.w700,
//                               color: _C.text2,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
