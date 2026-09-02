// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:razorpay_flutter/razorpay_flutter.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
// import '../../API/Apiclient.dart';
// import '../../API/food_authservice.dart';
// import '../../Models/food&beverages/orders_model.dart';
// import '../../food&beverages/Invoice.dart';
// import '../../widgets_helper/food/utils.dart';
// import '../DineOut_Model/DineOut_CartModel.dart' as dineout;
// import '../DineOut_Services/DineOutAuthService.dart';
// import 'DineOutMenu_Managemnet.dart';
//
// // ═══════════════════════════════════════════════════════════════════════════
// // MODELS
// // ═══════════════════════════════════════════════════════════════════════════
//
// class TableRequestModel {
//   final int vendorId;
//   final int userId;
//   final int itemId;
//   final int removalQuantity;
//   final int cartId;
//   final int tableBookingId;
//   final String tableCode;
//   final String requestType;
//   final int employeeId;
//   final String customerId;
//   final String reason;
//
//   const TableRequestModel({
//     required this.vendorId,
//     required this.userId,
//     required this.itemId,
//     required this.removalQuantity,
//     required this.cartId,
//     required this.tableBookingId,
//     required this.tableCode,
//     required this.requestType,
//     required this.employeeId,
//     required this.customerId,
//     required this.reason,
//   });
//
//   Map<String, dynamic> toJson() => {
//     'vendorId': vendorId,
//     if (userId != 0) 'userId': userId,
//     'itemId': itemId,
//     'removalQuantity': removalQuantity,
//     'cartId': cartId,
//     'tableBookingId': tableBookingId,
//     'tableCode': tableCode,
//     'requestType': requestType,
//     if (employeeId != 0) 'employeeId': employeeId,
//     if (customerId != '0') 'customerId': customerId,
//     'reason': reason,
//   };
// }
//
// // Keep for backward compatibility
// class CreateTableRequestModel {
//   final int vendorId;
//   final int userId;
//   final int itemId;
//   final int cartId;
//   final int tableBookingId;
//   final String tableCode;
//   final String requestType;
//   final int employeeId;
//   final String reason;
//
//   const CreateTableRequestModel({
//     required this.vendorId,
//     required this.userId,
//     required this.itemId,
//     required this.cartId,
//     required this.tableBookingId,
//     required this.tableCode,
//     required this.requestType,
//     required this.employeeId,
//     required this.reason,
//   });
//
//   Map<String, dynamic> toJson() => {
//     'vendorId': vendorId,
//     'userId': userId,
//     'itemId': itemId,
//     'cartId': cartId,
//     'tableBookingId': tableBookingId,
//     'tableCode': tableCode,
//     'requestType': requestType,
//     'employeeId': employeeId,
//     'reason': reason,
//   };
// }
//
// /// Response model from GET api/table-requests/cart/{cartId}
// class TableRequestEntry {
//   final int id;
//   final int vendorId;
//   final int userId;
//   final String name;
//   final int itemId;
//   final int cartId;
//   final int tableBookingId;
//   final String tableCode;
//   final String status; // PENDING | ACCEPT | DECLINE
//   final String requestType;
//   final String? reason;
//   final String? itemName;
//   final int? quantity;
//
//   const TableRequestEntry({
//     required this.id,
//     required this.vendorId,
//     required this.userId,
//     required this.name,
//     required this.itemId,
//     required this.cartId,
//     required this.tableBookingId,
//     required this.tableCode,
//     required this.status,
//     required this.requestType,
//     this.reason,
//     this.itemName,
//     this.quantity,
//   });
//
//   factory TableRequestEntry.fromJson(Map<String, dynamic> json) {
//     return TableRequestEntry(
//       id: json['id'] ?? 0,
//       vendorId: json['vendorId'] ?? 0,
//       userId: json['userId'] ?? 0,
//       name: json['name'] ?? '',
//       itemId: json['itemId'] ?? 0,
//       cartId: json['cartId'] ?? 0,
//       tableBookingId: json['tableBookingId'] ?? 0,
//       tableCode: json['tableCode'] ?? '',
//       status: json['status'] ?? 'PENDING',
//       requestType: json['requestType'] ?? '',
//       reason: json['reason'],
//       itemName: json['itemName'],
//       quantity: json['quantity'],
//     );
//   }
//
//   bool get isPending => status == 'PENDING';
//   bool get isAccepted => status == 'ACCEPT';
//   bool get isDeclined => status == 'DECLINE';
// }
//
// // ═══════════════════════════════════════════════════════════════════════════
// // SERVICE
// // ═══════════════════════════════════════════════════════════════════════════
//
// class TableRequestService {
//   static Future<List<TableRequestEntry>> fetchRequestsByCart(int cartId) async {
//     try {
//       debugPrint('📥 GET api/table-requests/cart/$cartId');
//       final response = await ApiClient.get(
//         'api/table-requests/cart/$cartId',
//         service: 'food',
//       );
//       debugPrint('📡 Status: ${response.statusCode}');
//       debugPrint('📥 Body: ${response.body}');
//       if (response.statusCode == 200) {
//         final List<dynamic> list = jsonDecode(response.body);
//         return list.map((e) => TableRequestEntry.fromJson(e)).toList();
//       }
//       return [];
//     } catch (e) {
//       debugPrint('❌ fetchRequestsByCart error: $e');
//       return [];
//     }
//   }
//
//   static Future<bool> createRemovalRequest({
//     required TableRequestModel request,
//   }) async {
//     try {
//       final payload = request.toJson();
//       debugPrint('📤 POST api/table-requests/create');
//       debugPrint('📦 Payload: ${jsonEncode(payload)}');
//
//       final response = await ApiClient.post(
//         'api/table-requests/create',
//         payload,
//         service: 'food',
//       );
//
//       debugPrint('📡 Status: ${response.statusCode}');
//       debugPrint('📥 Response: ${response.body}');
//
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         try {
//           final responseBody = jsonDecode(response.body);
//           if (responseBody is Map && responseBody.containsKey('error')) {
//             debugPrint('❌ API returned error: ${responseBody['error']}');
//             return false;
//           }
//         } catch (_) {}
//         return true;
//       }
//       return false;
//     } catch (e) {
//       debugPrint('❌ createRemovalRequest error: $e');
//       return false;
//     }
//   }
//
//   static Future<bool> updateRequestStatus({
//     required int requestId,
//     required String status,
//   }) async {
//     try {
//       debugPrint('📤 PUT api/table-requests/update/$requestId?status=$status');
//       final response = await ApiClient.put(
//         'api/table-requests/update/$requestId?status=$status',
//         {},
//         service: 'food',
//       );
//       debugPrint('📡 Status: ${response.statusCode}');
//       debugPrint('📥 Body: ${response.body}');
//       return response.statusCode == 200 || response.statusCode == 204;
//     } catch (e) {
//       debugPrint('❌ updateRequestStatus error: $e');
//       return false;
//     }
//   }
//
//   static Future<List<TableRequestEntry>> getPendingRequestsForItem({
//     required int cartId,
//     required int itemId,
//   }) async {
//     final all = await fetchRequestsByCart(cartId);
//     return all
//         .where((r) => r.itemId == itemId && r.status == 'PENDING')
//         .toList();
//   }
// }
//
// // ═══════════════════════════════════════════════════════════════════════════
// // DESIGN TOKENS
// // ═══════════════════════════════════════════════════════════════════════════
//
// class AppColors {
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
//   static const blue = Color(0xFF17A2B8);
//   static const text1 = Color(0xFF1A1A2E);
//   static const text2 = Color(0xFF6B6B8A);
//   static const text3 = Color(0xFFAAAAAC);
// }
//
// enum ScreenMode { cart, billing }
//
// // ═══════════════════════════════════════════════════════════════════════════
// // MAIN WIDGET
// // ═══════════════════════════════════════════════════════════════════════════
//
// class DineOutfood_CartScreen1 extends StatefulWidget {
//   final int? cartId;
//   final int? bookingId;
//   final String? tableCode;
//   final int? userId;
//   final Map<String, dynamic>? vendorDetails;
//   final Map<String, dynamic>? bannerData;
//   final VoidCallback? onBack;
//   final Function(Map<String, dynamic>)? onCartUpdate;
//   final Function? onPaymentSuccess;
//
//   const DineOutfood_CartScreen1({
//     super.key,
//     this.cartId,
//     required double savedAmount,
//     required bool showSavedPopup,
//     this.bookingId,
//     this.tableCode,
//     this.userId,
//     this.vendorDetails,
//     this.bannerData,
//     this.onBack,
//     this.onCartUpdate,
//     this.onPaymentSuccess,
//   });
//
//   @override
//   State<DineOutfood_CartScreen1> createState() =>
//       _DineOutfood_CartScreenState();
// }
//
// class _DineOutfood_CartScreenState extends State<DineOutfood_CartScreen1>
//     with WidgetsBindingObserver {
//   // ── Screen Mode ───────────────────────────────────────────────────────────
//   ScreenMode _screenMode = ScreenMode.cart;
//
//   // ── Role State ────────────────────────────────────────────────────────────
//   /// true  → ROLE_VENDOR  → direct decrement without popup (PUT API)
//   /// false → ROLE_EMPLOYEE → show removal request popup
//   bool _isVendorRole = false;
//
//   // ── Cart State ────────────────────────────────────────────────────────────
//   dineout.DineoutCartmodel? cartData;
//   bool isLoading = true;
//   bool isPlacingOrder = false;
//   String selectedPaymentMethod = '';
//   bool _isUpdating = false;
//   Map<int, bool> _itemLoadingMap = {};
//   Map<int, int> _availableQuantities = {};
//   Map<int, String> _itemNotes = {};
//
//   // ── Table Requests State ──────────────────────────────────────────────────
//   List<TableRequestEntry> _tableRequests = [];
//   bool _isLoadingRequests = false;
//
//   // ── Discount State ────────────────────────────────────────────────────────
//   final TextEditingController _discountController = TextEditingController();
//   double _discountAmount = 0.0;
//   bool _isApplyingDiscount = false;
//   bool _isDiscountApplied = false;
//
//   // ── Coupon State ──────────────────────────────────────────────────────────
//   String couponCode = '';
//   bool isCouponApplied = false;
//   double couponDiscount = 0.0;
//
//   // ── KOT State ─────────────────────────────────────────────────────────────
//   bool _isSendingToKitchen = false;
//   bool _isSaveAndSending = false;
//   bool _isKOTSending = false;
//
//   // ── QR State ──────────────────────────────────────────────────────────────
//   bool _isGeneratingQr = false;
//   String? _qrImageUrl;
//   String? _qrOrderId;
//   Timer? _qrPollingTimer;
//   int _qrTimer = 300;
//   Timer? _qrCountdownTimer;
//
//   // ── Modal States ──────────────────────────────────────────────────────────
//   bool _isNoteModalVisible = false;
//   dineout.CartItem? _selectedItemForNote;
//   String _tempNote = '';
//
//   // ── Razorpay ──────────────────────────────────────────────────────────────
//   late Razorpay _razorpay;
//   int? appliedCouponId;
//
//   // ── Billing State ─────────────────────────────────────────────────────────
//   bool isServiceChargeApplied = true;
//   Map<String, bool> _paymentMethodsConfig = {
//     'cash': true,
//     'upi': true,
//     'qrCode': true,
//   };
//
//   // ─────────────────────────────────────────────────────────────────────────
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//     _razorpay = Razorpay();
//     _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
//     _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
//     _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
//     _loadUserRole();
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
//   // =========================================================================
//   // ROLE LOADING
//   // =========================================================================
//
//   Future<void> _loadUserRole() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final role = prefs.getString('role') ?? '';
//       debugPrint('👤 Loaded role: $role');
//       if (mounted) {
//         setState(() {
//           _isVendorRole = role == 'ROLE_VENDOR';
//         });
//       }
//     } catch (e) {
//       debugPrint('❌ _loadUserRole error: $e');
//     }
//   }
//
//   // ── Computed Getters ──────────────────────────────────────────────────────
//
//   List<dineout.CartItem> get _itemsToSend {
//     return (cartData?.cartItems ?? []).where((item) {
//       final isPending = item.orderStatus == null || item.orderStatus!.isEmpty;
//       final wasIncreased =
//           (item.previousQuantity > 0) &&
//           (item.quantity > item.previousQuantity);
//       return isPending || wasIncreased;
//     }).toList();
//   }
//
//   bool get _areAllItemsDelivered {
//     if (cartData == null || cartData!.cartItems.isEmpty) return false;
//     return cartData!.cartItems.every((i) {
//       if (i.orderStatus != 'DELIVERED') return false;
//       if (i.quantity > i.previousQuantity) return false;
//       return true;
//     });
//   }
//
//   bool get _isUserLoggedIn => widget.userId != null && widget.userId != 0;
//
//   double get finalAmount => (cartData?.grandTotal ?? 0) - couponDiscount;
//
//   void _onCartCountChanged() {
//     if (!_isUpdating) {
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
//   // DATA LOADING
//   // =========================================================================
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
//     } catch (e) {
//       debugPrint('Error fetching payment config: $e');
//     }
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
//     } catch (e) {
//       debugPrint('Error loading quantities: $e');
//     }
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
//         if (widget.onCartUpdate != null && cartData != null) {
//           widget.onCartUpdate!({
//             'items': cartData!.cartItems,
//             'grandTotal': cartData!.grandTotal,
//             'subtotal': cartData!.subtotal,
//             'gst': cartData!.gstTotal,
//           });
//         }
//         if (cartData != null && cartData!.cartId != 0) {
//           _loadTableRequests();
//         }
//       }
//     } catch (e) {
//       debugPrint('Error loading cart: $e');
//       if (mounted) setState(() => isLoading = false);
//     }
//   }
//
//   // =========================================================================
//   // TABLE REQUESTS — GET
//   // =========================================================================
//
//   Future<void> _loadTableRequests() async {
//     if (cartData == null || cartData!.cartId == 0) return;
//     setState(() => _isLoadingRequests = true);
//     try {
//       final requests = await TableRequestService.fetchRequestsByCart(
//         cartData!.cartId,
//       );
//       if (mounted) {
//         setState(() => _tableRequests = requests);
//       }
//     } catch (e) {
//       debugPrint('Error loading table requests: $e');
//     } finally {
//       if (mounted) setState(() => _isLoadingRequests = false);
//     }
//   }
//
//   List<TableRequestEntry> _pendingRequestsFor(int itemId) {
//     return _tableRequests
//         .where((r) => r.itemId == itemId && r.isPending)
//         .toList();
//   }
//
//   List<TableRequestEntry> _allRequestsFor(int itemId) {
//     return _tableRequests.where((r) => r.itemId == itemId).toList();
//   }
//
//   // =========================================================================
//   // TABLE REQUESTS — PUT (ACCEPT / DECLINE)
//   // Only callable when [_isVendorRole] is true.
//   // =========================================================================
//
//   Future<void> _acceptRequest(TableRequestEntry request) async {
//     if (!_isVendorRole) {
//       _showSnackbar(
//         'Only vendor accounts can accept requests',
//         AppColors.orange,
//       );
//       return;
//     }
//
//     final success = await TableRequestService.updateRequestStatus(
//       requestId: request.id,
//       status: 'ACCEPT',
//     );
//
//     if (success) {
//       final cartItem = cartData?.cartItems
//           .where((item) => item.itemId == request.itemId)
//           .firstOrNull;
//
//       if (cartItem != null) {
//         final removeQty = request.quantity ?? 1;
//         final newQty = cartItem.quantity - removeQty;
//
//         debugPrint(
//           '🔄 Accept: itemId=${cartItem.itemId}, '
//           'currentQty=${cartItem.quantity}, removeQty=$removeQty, newQty=$newQty',
//         );
//
//         final removed = await _callUpdateCartApi(
//           cartId: cartData!.cartId,
//           itemId: cartItem.itemId,
//           quantity: newQty < 0 ? 0 : newQty,
//           status:
//               (cartItem.orderStatus != null && cartItem.orderStatus!.isNotEmpty)
//               ? cartItem.orderStatus!
//               : 'CONFIRMED',
//         );
//
//         if (removed) {
//           _showSnackbar(
//             'Request accepted — ${cartItem.dishName} qty updated',
//             AppColors.green,
//           );
//         } else {
//           _showSnackbar(
//             'Request accepted but failed to update item. Check API logs.',
//             AppColors.orange,
//           );
//         }
//       } else {
//         _showSnackbar('Request accepted', AppColors.green);
//       }
//
//       await _loadCart();
//       await _loadTableRequests();
//     } else {
//       _showSnackbar('Failed to accept request', AppColors.red);
//     }
//   }
//
//   Future<void> _declineRequest(TableRequestEntry request) async {
//     if (!_isVendorRole) {
//       _showSnackbar(
//         'Only vendor accounts can decline requests',
//         AppColors.orange,
//       );
//       return;
//     }
//
//     final success = await TableRequestService.updateRequestStatus(
//       requestId: request.id,
//       status: 'DECLINE',
//     );
//     if (success) {
//       _showSnackbar('Request declined', AppColors.orange);
//       await _loadTableRequests();
//     } else {
//       _showSnackbar('Failed to decline request', AppColors.red);
//     }
//   }
//
//   // =========================================================================
//   // DISCOUNT API
//   // =========================================================================
//
//   Future<void> _applyVendorDiscount() async {
//     final input = _discountController.text.trim();
//     if (input.isEmpty) {
//       _showSnackbar('Please enter a discount amount', AppColors.orange);
//       return;
//     }
//     final amount = double.tryParse(input);
//     if (amount == null || amount <= 0) {
//       _showSnackbar('Enter a valid discount amount', AppColors.red);
//       return;
//     }
//     if (cartData == null || cartData!.cartId == 0) {
//       _showSnackbar('Cart not loaded', AppColors.red);
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
//         _showSnackbar(
//           'Discount of ₹${amount.toStringAsFixed(2)} applied!',
//           AppColors.green,
//         );
//         await _loadCart();
//       } else {
//         _showSnackbar('Failed to apply discount', AppColors.red);
//       }
//     } catch (e) {
//       _showSnackbar('Error applying discount: $e', AppColors.red);
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
//     _showSnackbar('Discount removed', AppColors.green);
//     _loadCart();
//   }
//
//   // =========================================================================
//   // REMOVAL REQUEST POPUP  (shown only for ROLE_EMPLOYEE)
//   // =========================================================================
//
//   Future<void> _showRemovalRequestPopup(dineout.CartItem item) async {
//     if (cartData == null) return;
//
//     final prefs = await SharedPreferences.getInstance();
//     final vendorId = prefs.getInt('vendorId') ?? 0;
//     final employeeId = prefs.getInt('employeeId') ?? 0;
//     final customerId = prefs.getString('customerId') ?? '0';
//
//     debugPrint('👤 vendorId: $vendorId');
//     debugPrint('👤 employeeId: $employeeId');
//     debugPrint('👤 customerId: $customerId');
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
//         customerId: customerId,
//         bookingId: widget.bookingId ?? 0,
//         tableCode: widget.tableCode ?? '',
//         onSuccess: () {
//           _showSnackbar(
//             'Removal request submitted successfully!',
//             AppColors.green,
//           );
//           _loadCart();
//           _loadTableRequests();
//           _loadAvailableQuantities();
//         },
//         onError: (msg) => _showSnackbar(msg, AppColors.red),
//       ),
//     );
//   }
//
//   Future<void> _vendorDirectDecrement(
//     dineout.CartItem item,
//     int newQuantity,
//   ) async {
//     if (_isUpdating) return;
//
//     _isUpdating = true;
//     setState(() => _itemLoadingMap[item.itemId] = true);
//
//     try {
//       final targetQty = newQuantity < 0 ? 0 : newQuantity;
//       final status = (item.orderStatus != null && item.orderStatus!.isNotEmpty)
//           ? item.orderStatus!
//           : 'CONFIRMED';
//
//       debugPrint(
//         '🏪 VENDOR direct decrement → itemId=${item.itemId} '
//         'qty=$targetQty status=$status',
//       );
//
//       final success = await _callUpdateCartApi(
//         cartId: cartData!.cartId,
//         itemId: item.itemId,
//         quantity: targetQty,
//         status: status,
//       );
//
//       if (success) {
//         _showSnackbar(
//           targetQty == 0
//               ? '${item.dishName} removed from cart'
//               : '${item.dishName} quantity updated to $targetQty',
//           AppColors.green,
//         );
//         await _loadCart();
//         await _loadAvailableQuantities();
//       } else {
//         _showSnackbar('Failed to update quantity', AppColors.red);
//       }
//     } catch (e) {
//       debugPrint('_vendorDirectDecrement error: $e');
//       _showSnackbar('Error updating item', AppColors.red);
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
//   // =========================================================================
//   // QUANTITY UPDATE  — entry point for − button and × (close) button
//   // =========================================================================
//
//   Future<void> _updateQuantity(dineout.CartItem item, int newQuantity) async {
//     if (_isUpdating) return;
//
//     final bool isAlreadySent =
//         item.orderStatus != null && item.orderStatus!.isNotEmpty;
//
//     if (_isVendorRole) {
//       // VENDOR: direct API call
//       if (newQuantity < item.quantity) {
//         await _vendorDirectDecrement(item, newQuantity);
//         return;
//       }
//     } else {
//       // EMPLOYEE: show removal request popup when reducing
//       if (isAlreadySent && newQuantity < item.previousQuantity) {
//         await _showRemovalRequestPopup(item);
//         return;
//       }
//       if (!isAlreadySent && newQuantity < 1) {
//         await _showRemovalRequestPopup(item);
//         return;
//       }
//     }
//
//     // ── Common path: increment or normal update ──────────────────────────────
//     final available = _availableQuantities[item.dishId] ?? 0;
//     if (newQuantity > available && available > 0) {
//       _showSnackbar('Only $available items available', AppColors.red);
//       return;
//     }
//
//     _isUpdating = true;
//     setState(() => _itemLoadingMap[item.itemId] = true);
//
//     try {
//       final success = await _callUpdateCartApi(
//         cartId: cartData!.cartId,
//         itemId: item.itemId,
//         quantity: newQuantity,
//         status: (item.orderStatus != null && item.orderStatus!.isNotEmpty)
//             ? item.orderStatus!
//             : 'CONFIRMED',
//       );
//       if (success) {
//         await _loadCart();
//         await _loadAvailableQuantities();
//       } else {
//         _showSnackbar('Failed to update quantity', AppColors.red);
//       }
//     } catch (e) {
//       debugPrint('_updateQuantity error: $e');
//       _showSnackbar('Error updating item', AppColors.red);
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
//   Future<bool> _callUpdateCartApi({
//     required int cartId,
//     required int itemId,
//     required int quantity,
//     String status = 'CONFIRMED',
//   }) async {
//     try {
//       final endpoint =
//           'api/cart/update/table/quantity/status/$cartId'
//           '?itemId=$itemId&quantity=$quantity&status=$status';
//       debugPrint('📤 PUT $endpoint');
//       final response = await ApiClient.put(endpoint, {}, service: 'food');
//       debugPrint('📡 Status: ${response.statusCode}');
//       return response.statusCode == 200 || response.statusCode == 204;
//     } catch (e) {
//       debugPrint('PUT cart update error: $e');
//       return false;
//     }
//   }
//
//   // =========================================================================
//   // CONFIRM REMOVE  — × button on cart item
//   // =========================================================================
//   void _confirmRemove(dineout.CartItem item) {
//     if (_isVendorRole) {
//       _vendorDirectDecrement(item, 0);
//     } else {
//       // EMPLOYEE: show removal request popup
//       _showRemovalRequestPopup(item);
//     }
//   }
//   // =========================================================================
//   // KITCHEN OPERATIONS
//   // =========================================================================
//
//   Future<void> _sendToKitchen() async {
//     final toSend = _itemsToSend;
//     if (toSend.isEmpty) {
//       _showSnackbar('No pending items to send to kitchen', AppColors.orange);
//       return;
//     }
//     setState(() => _isSendingToKitchen = true);
//     int successCount = 0;
//     List<String> failedItems = [];
//     for (final item in toSend) {
//       final note = _itemNotes[item.itemId] ?? '';
//       try {
//         final success = await DineoutAuthService.sendItemToKitchen(
//           itemId: item.itemId,
//           status: 'CONFIRMED',
//           note: note,
//         );
//         if (success) {
//           successCount++;
//         } else {
//           failedItems.add(item.dishName);
//         }
//       } catch (e) {
//         failedItems.add(item.dishName);
//       }
//     }
//     if (successCount > 0) {
//       _showSnackbar(
//         '$successCount item(s) sent to kitchen successfully!',
//         AppColors.green,
//       );
//       setState(() => _itemNotes.clear());
//       await _loadCart();
//       await _loadAvailableQuantities();
//     }
//     if (failedItems.isNotEmpty) {
//       _showSnackbar('Failed to send: ${failedItems.join(", ")}', AppColors.red);
//     }
//     setState(() => _isSendingToKitchen = false);
//   }
//
//   Future<void> _saveAndPrint() async {
//     final toSend = _itemsToSend;
//     if (toSend.isEmpty) {
//       _showSnackbar('No pending items to send to kitchen', AppColors.orange);
//       return;
//     }
//     setState(() => _isSaveAndSending = true);
//     int successCount = 0;
//     List<String> failedItems = [];
//     for (final item in toSend) {
//       final note = _itemNotes[item.itemId] ?? '';
//       try {
//         final success = await DineoutAuthService.sendItemToKitchen(
//           itemId: item.itemId,
//           status: 'CONFIRMED',
//           note: note,
//         );
//         if (success) {
//           successCount++;
//         } else {
//           failedItems.add(item.dishName);
//         }
//       } catch (e) {
//         failedItems.add(item.dishName);
//       }
//     }
//     setState(() => _itemNotes.clear());
//     if (successCount > 0) {
//       _showSnackbar('$successCount item(s) sent to kitchen!', AppColors.green);
//       await _loadCart();
//       await _loadAvailableQuantities();
//     }
//     if (failedItems.isNotEmpty) {
//       _showSnackbar('Failed to send: ${failedItems.join(", ")}', AppColors.red);
//     }
//     setState(() => _isSaveAndSending = false);
//   }
//
//   Future<void> _handleKOTAndPrint() async {
//     final toSend = _itemsToSend;
//     if (toSend.isEmpty) {
//       _showSnackbar('No pending items to send to kitchen', AppColors.orange);
//       return;
//     }
//     setState(() => _isKOTSending = true);
//     int successCount = 0;
//     List<String> failedItems = [];
//     for (final item in toSend) {
//       final note = _itemNotes[item.itemId] ?? '';
//       try {
//         final success = await DineoutAuthService.sendItemToKitchen(
//           itemId: item.itemId,
//           status: 'CONFIRMED',
//           note: note,
//         );
//         if (success) {
//           successCount++;
//         } else {
//           failedItems.add(item.dishName);
//         }
//       } catch (e) {
//         failedItems.add(item.dishName);
//       }
//     }
//     if (successCount > 0) {
//       _showSnackbar('$successCount item(s) sent to kitchen!', AppColors.green);
//       setState(() => _itemNotes.clear());
//       await _loadCart();
//       await _loadAvailableQuantities();
//     }
//     if (failedItems.isNotEmpty) {
//       _showSnackbar('Failed to send: ${failedItems.join(", ")}', AppColors.red);
//     }
//     setState(() => _isKOTSending = false);
//   }
//
//   void _updateItemNote(int itemId, String note) {
//     setState(() {
//       if (note.isEmpty) {
//         _itemNotes.remove(itemId);
//       } else {
//         _itemNotes[itemId] = note;
//       }
//     });
//   }
//
//   // ── Note Modal ────────────────────────────────────────────────────────────
//   void _showNoteModal(dineout.CartItem item) {
//     setState(() {
//       _selectedItemForNote = item;
//       _tempNote = _itemNotes[item.itemId] ?? '';
//       _isNoteModalVisible = true;
//     });
//   }
//
//   void _saveNote() {
//     if (_selectedItemForNote != null) {
//       _updateItemNote(_selectedItemForNote!.itemId, _tempNote);
//     }
//     setState(() {
//       _isNoteModalVisible = false;
//       _selectedItemForNote = null;
//       _tempNote = '';
//     });
//   }
//
//   void _cancelNote() {
//     setState(() {
//       _isNoteModalVisible = false;
//       _selectedItemForNote = null;
//       _tempNote = '';
//     });
//   }
//
//   void _proceedToBilling() {
//     setState(() {
//       _screenMode = ScreenMode.billing;
//       selectedPaymentMethod = '';
//     });
//   }
//
//   void _backToCart() {
//     setState(() {
//       _screenMode = ScreenMode.cart;
//       selectedPaymentMethod = '';
//     });
//   }
//
//   void _handleRemoveCoupon() {
//     setState(() {
//       couponCode = '';
//       isCouponApplied = false;
//       couponDiscount = 0;
//     });
//     _showSnackbar('Coupon removed successfully!', AppColors.green);
//   }
//
//   Future<void> placeOrder() async {
//     if (isPlacingOrder) return;
//     if (cartData == null || cartData!.cartId == 0) {
//       await _loadCart();
//       if (cartData == null || cartData!.cartId == 0) {
//         _showSnackbar('Cart is empty', AppColors.red);
//         return;
//       }
//     }
//     if (selectedPaymentMethod.isEmpty) {
//       _showSnackbar('Please select a payment method', AppColors.orange);
//       return;
//     }
//     setState(() => isPlacingOrder = true);
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
//         amount: finalAmount,
//       );
//       if (orderResult != null &&
//           mounted &&
//           orderResult.containsKey('orderId')) {
//         _showSnackbar(
//           'Order #${orderResult['orderId']} placed successfully!',
//           AppColors.green,
//         );
//         _clearCart();
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder: (_) => food_Invoice(orderId: orderResult['orderId']),
//           ),
//         );
//       } else {
//         _showSnackbar('Failed to place order', AppColors.red);
//       }
//     } catch (e) {
//       _showSnackbar('Error placing order: $e', AppColors.red);
//     } finally {
//       if (mounted) setState(() => isPlacingOrder = false);
//     }
//   }
//
//   void _clearCart() {
//     setState(() => cartData = null);
//     Utils.itemCount.value = 0;
//   }
//
//   // ── QR Payment ────────────────────────────────────────────────────────────
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
//         'amount': finalAmount,
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
//         _showSnackbar('QR generation failed', AppColors.red);
//       }
//     } catch (e) {
//       _showSnackbar('Failed to generate QR: $e', AppColors.red);
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
//         if (mounted) {
//           setState(() => _qrTimer = 0);
//           Navigator.of(context, rootNavigator: true).pop();
//           _showSnackbar('QR payment timed out', AppColors.orange);
//         }
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
//         final response = await http.get(
//           Uri.parse(
//             'http://staging.maamaas.com:8080/food/api/payments/status/$orderId',
//           ),
//           headers: {'Authorization': 'Bearer $token'},
//         );
//         if (response.statusCode == 200) {
//           final body = jsonDecode(response.body);
//           if (body['status'] == 'SUCCESS') {
//             t.cancel();
//             _qrCountdownTimer?.cancel();
//             Navigator.of(context, rootNavigator: true).pop();
//             await _createOrderAfterQrSuccess();
//           } else if (body['status'] == 'FAILED') {
//             t.cancel();
//             _qrCountdownTimer?.cancel();
//             Navigator.of(context, rootNavigator: true).pop();
//             _showSnackbar('Payment failed. Please try again.', AppColors.red);
//           }
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
//       amount: finalAmount,
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
//       _showSnackbar(
//         'Payment succeeded but order creation failed',
//         AppColors.orange,
//       );
//     }
//   }
//
//   void _showQrDialog(String orderId) {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (_) => StatefulBuilder(
//         builder: (ctx, setDialogState) {
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
//               setDialogState(() => _qrTimer--);
//             }
//           });
//           final mins = _qrTimer ~/ 60;
//           final secs = _qrTimer % 60;
//           return Dialog(
//             backgroundColor: Colors.transparent,
//             child: Container(
//               decoration: BoxDecoration(
//                 color: AppColors.white,
//                 borderRadius: BorderRadius.circular(24.r),
//               ),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Container(
//                     padding: EdgeInsets.all(20.w),
//                     decoration: BoxDecoration(
//                       color: AppColors.accentDark,
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
//                           '₹${finalAmount.toStringAsFixed(2)}',
//                           style: TextStyle(
//                             fontSize: 28.sp,
//                             fontWeight: FontWeight.w900,
//                             color: AppColors.green,
//                           ),
//                         ),
//                         SizedBox(height: 16.h),
//                         if (_qrImageUrl != null)
//                           Image.network(
//                             _qrImageUrl!,
//                             width: 200.w,
//                             height: 200.h,
//                             errorBuilder: (context, error, stackTrace) =>
//                                 Container(
//                                   width: 200.w,
//                                   height: 200.h,
//                                   color: Colors.grey.shade200,
//                                   child: const Icon(Icons.error),
//                                 ),
//                           ),
//                         SizedBox(height: 12.h),
//                         Text(
//                           'Scan using any UPI app',
//                           style: TextStyle(
//                             fontSize: 13.sp,
//                             color: AppColors.text2,
//                           ),
//                         ),
//                         SizedBox(height: 8.h),
//                         Text(
//                           'Time remaining: $mins:${secs.toString().padLeft(2, '0')}',
//                           style: TextStyle(
//                             fontSize: 12.sp,
//                             color: AppColors.orange,
//                           ),
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
//   // ── Razorpay ──────────────────────────────────────────────────────────────
//
//   Future<void> _initiateRazorpay() async {
//     if (cartData == null) return;
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final vendorId = prefs.getInt('vendorId') ?? 0;
//       final phone = prefs.getString('phone') ?? '9999999999';
//       final uniqueOrderId = 'ORD-${DateTime.now().millisecondsSinceEpoch}';
//       final response = await ApiClient.post('api/payments/create-order/user', {
//         'amount': finalAmount,
//         'cartId': cartData!.cartId,
//         'vendorId': vendorId,
//         'phone': phone,
//         'orderId': uniqueOrderId,
//       }, service: 'food');
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         final razorpayOrderId = data['orderId']?.toString();
//         if (razorpayOrderId == null) {
//           _showSnackbar('Failed to create payment order', AppColors.red);
//           return;
//         }
//         _razorpay.open({
//           'key': 'rzp_test_TJECsclCivENpY',
//           'amount': (finalAmount * 100).toInt(),
//           'currency': 'INR',
//           'name': widget.bannerData?['companyName'] ?? 'MAAMAAS HOUSE',
//           'description': 'Order for Table ${widget.tableCode ?? ''}',
//           'order_id': razorpayOrderId,
//           'prefill': {'contact': phone, 'email': 'customer@example.com'},
//           'theme': {'color': '#E66D33'},
//         });
//       } else {
//         _showSnackbar('Failed to create Razorpay order', AppColors.red);
//       }
//     } catch (e) {
//       _showSnackbar('Error initiating payment: $e', AppColors.red);
//     }
//   }
//
//   void _handlePaymentSuccess(PaymentSuccessResponse res) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final vendorId = prefs.getInt('vendorId') ?? 0;
//       final phone = prefs.getString('phone') ?? '';
//       final orderResult = await DineoutAuthService.placeDirectOrder(
//         vendorId: vendorId,
//         cartId: cartData!.cartId,
//         paymentMethod: 'Online_Payment',
//         razorpayPaymentId: res.paymentId ?? '',
//         razorpayOrderId: res.orderId ?? '',
//         userId: widget.userId,
//         isUserOrder: _isUserLoggedIn,
//         phoneNumber: phone,
//         couponId: appliedCouponId,
//         amount: finalAmount,
//       );
//       if (orderResult != null &&
//           mounted &&
//           orderResult.containsKey('orderId')) {
//         _showSnackbar('Payment successful! Order placed.', AppColors.green);
//         _clearCart();
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder: (_) => food_Invoice(orderId: orderResult['orderId']),
//           ),
//         );
//       } else {
//         _showSnackbar(
//           'Payment succeeded but order creation failed',
//           AppColors.orange,
//         );
//       }
//     } catch (e) {
//       _showSnackbar('Error processing successful payment: $e', AppColors.red);
//     }
//   }
//
//   void _handlePaymentError(PaymentFailureResponse res) {
//     _showSnackbar('Payment failed: ${res.message}', AppColors.red);
//   }
//
//   void _handleExternalWallet(ExternalWalletResponse res) {}
//
//   // =========================================================================
//   // HELPERS
//   // =========================================================================
//
//   void _showSnackbar(String msg, Color color) {
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
//         duration: const Duration(seconds: 3),
//       ),
//     );
//   }
//
//   String convertUTCToIST(String? utcDateString) {
//     if (utcDateString == null) return 'N/A';
//     try {
//       final utcDate = DateTime.parse(utcDateString);
//       final istDate = utcDate.add(const Duration(hours: 5, minutes: 30));
//       final hour = istDate.hour > 12 ? istDate.hour - 12 : istDate.hour;
//       final ampm = istDate.hour >= 12 ? 'PM' : 'AM';
//       return '${hour.toString().padLeft(2, '0')}:${istDate.minute.toString().padLeft(2, '0')} $ampm';
//     } catch (e) {
//       return 'N/A';
//     }
//   }
//
//   String capitalizeWords(String str) {
//     if (str.isEmpty) return '';
//     return str
//         .split(' ')
//         .map(
//           (word) => word.isEmpty
//               ? word
//               : word[0].toUpperCase() + word.substring(1).toLowerCase(),
//         )
//         .join(' ');
//   }
//
//   // =========================================================================
//   // BUILD
//   // =========================================================================
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.bg,
//       body: SafeArea(
//         child: Stack(
//           children: [
//             Column(
//               children: [
//                 _buildHeader(),
//                 Expanded(
//                   child: isLoading
//                       ? const Center(child: CircularProgressIndicator())
//                       : (cartData == null || cartData!.cartItems.isEmpty)
//                       ? _buildEmptyCart()
//                       : _screenMode == ScreenMode.billing
//                       ? _buildBillingBody()
//                       : _buildCartBody(),
//                 ),
//               ],
//             ),
//             if (_isNoteModalVisible) _buildNoteModal(),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildHeader() {
//     final pendingCount = _itemsToSend.length;
//     final pendingRemovalCount = _tableRequests.where((r) => r.isPending).length;
//
//     return Container(
//       padding: EdgeInsets.fromLTRB(16.w, 12.h, 8.w, 12.h),
//       decoration: BoxDecoration(
//         color: AppColors.white,
//         border: Border(bottom: BorderSide(color: AppColors.border)),
//       ),
//       child: Row(
//         children: [
//           GestureDetector(
//             onTap: _screenMode == ScreenMode.billing
//                 ? _backToCart
//                 : () => Navigator.pop(context),
//             child: Container(
//               width: 36.r,
//               height: 36.r,
//               decoration: BoxDecoration(
//                 color: AppColors.bg,
//                 borderRadius: BorderRadius.circular(10.r),
//                 border: Border.all(color: AppColors.border),
//               ),
//               child: Icon(
//                 Icons.arrow_back_ios_rounded,
//                 color: AppColors.text1,
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
//                   _screenMode == ScreenMode.billing ? 'Billing' : 'Your Cart',
//                   style: TextStyle(
//                     fontSize: 17.sp,
//                     fontWeight: FontWeight.w800,
//                     color: AppColors.text1,
//                   ),
//                 ),
//                 if (cartData != null)
//                   Text(
//                     'Table ${widget.tableCode ?? ''} • ${cartData!.cartItems.length} items • $pendingCount pending',
//                     style: TextStyle(fontSize: 12.sp, color: AppColors.text2),
//                   ),
//               ],
//             ),
//           ),
//           // Pending requests badge — only visible to ROLE_VENDOR
//           if (_isVendorRole && pendingRemovalCount > 0)
//             GestureDetector(
//               onTap: _showPendingRequestsSheet,
//               child: Container(
//                 margin: EdgeInsets.only(right: 8.w),
//                 padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
//                 decoration: BoxDecoration(
//                   color: AppColors.orange.withOpacity(0.15),
//                   borderRadius: BorderRadius.circular(20.r),
//                   border: Border.all(color: AppColors.orange.withOpacity(0.4)),
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Icon(
//                       Icons.pending_actions_rounded,
//                       color: AppColors.orange,
//                       size: 14.sp,
//                     ),
//                     SizedBox(width: 4.w),
//                     Text(
//                       '$pendingRemovalCount',
//                       style: TextStyle(
//                         fontSize: 12.sp,
//                         fontWeight: FontWeight.w700,
//                         color: AppColors.orange,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
//
//   // =========================================================================
//   // PENDING REQUESTS BOTTOM SHEET
//   // =========================================================================
//
//   void _showPendingRequestsSheet() {
//     if (!_isVendorRole) return;
//
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (_) => _PendingRequestsSheet(
//         requests: _tableRequests,
//         isVendorRole: _isVendorRole,
//         onAccept: (req) async {
//           Navigator.pop(context);
//           await _acceptRequest(req);
//         },
//         onDecline: (req) async {
//           Navigator.pop(context);
//           await _declineRequest(req);
//         },
//         onRefresh: () async {
//           await _loadTableRequests();
//         },
//       ),
//     );
//   }
//
//   // =========================================================================
//   // CART BODY
//   // =========================================================================
//
//   Widget _buildCartBody() {
//     return RefreshIndicator(
//       color: AppColors.accent,
//       onRefresh: () async {
//         await _loadCart();
//         await _loadAvailableQuantities();
//         await _loadTableRequests();
//       },
//       child: SingleChildScrollView(
//         padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 32.h),
//         child: Column(
//           children: [
//             // Pending banner only visible to ROLE_VENDOR
//             if (_isVendorRole && _tableRequests.any((r) => r.isPending))
//               _buildPendingRequestsBanner(),
//             if (_isVendorRole && _tableRequests.any((r) => r.isPending))
//               SizedBox(height: 12.h),
//             _buildCartItemsCard(),
//             SizedBox(height: 12.h),
//             _buildAddMoreRow(),
//             SizedBox(height: 12.h),
//             _buildActionButtonsRow(),
//             SizedBox(height: 12.h),
//             if (_areAllItemsDelivered) _buildProceedToBillingBtn(),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildPendingRequestsBanner() {
//     final pendingList = _tableRequests.where((r) => r.isPending).toList();
//     return GestureDetector(
//       onTap: _showPendingRequestsSheet,
//       child: Container(
//         padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
//         decoration: BoxDecoration(
//           color: AppColors.orange.withOpacity(0.12),
//           borderRadius: BorderRadius.circular(12.r),
//           border: Border.all(color: AppColors.orange.withOpacity(0.4)),
//         ),
//         child: Row(
//           children: [
//             Icon(
//               Icons.pending_actions_rounded,
//               color: AppColors.orange,
//               size: 18.sp,
//             ),
//             SizedBox(width: 10.w),
//             Expanded(
//               child: Text(
//                 '${pendingList.length} removal request(s) awaiting approval',
//                 style: TextStyle(
//                   fontSize: 13.sp,
//                   fontWeight: FontWeight.w600,
//                   color: AppColors.orange,
//                 ),
//               ),
//             ),
//             Icon(
//               Icons.arrow_forward_ios_rounded,
//               color: AppColors.orange,
//               size: 14.sp,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildCartItemsCard() {
//     if (cartData == null || cartData!.cartItems.isEmpty) {
//       return const SizedBox.shrink();
//     }
//     return Container(
//       decoration: BoxDecoration(
//         color: AppColors.white,
//         borderRadius: BorderRadius.circular(16.r),
//         border: Border.all(color: AppColors.border),
//       ),
//       child: Padding(
//         padding: EdgeInsets.symmetric(horizontal: 16.w),
//         child: Column(
//           children: cartData!.cartItems.map((item) {
//             return Column(
//               key: ValueKey(item.itemId),
//               children: [
//                 _buildCartItem(item),
//                 Divider(height: 1, color: AppColors.border),
//               ],
//             );
//           }).toList(),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildCartItem(dineout.CartItem item) {
//     final isItemLoading = _itemLoadingMap[item.itemId] == true;
//     final available = _availableQuantities[item.dishId] ?? 0;
//     final canIncrease = item.quantity < available;
//     final isModified = item.orderStatus == 'MODIFIED';
//     final istTime = convertUTCToIST(item.createdAt);
//
//     // Pending request chips are only shown for ROLE_VENDOR
//     final pendingRequests = _pendingRequestsFor(item.itemId);
//     final hasPending = pendingRequests.isNotEmpty;
//
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 10.h),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // ── × remove button ─────────────────────────────────────────
//               // ROLE_VENDOR  → direct API decrement to 0, no popup
//               // ROLE_EMPLOYEE → show removal request popup
//               GestureDetector(
//                 onTap: () => _confirmRemove(item),
//                 child: Container(
//                   width: 28.r,
//                   height: 28.r,
//                   margin: EdgeInsets.only(right: 8.w),
//                   decoration: BoxDecoration(
//                     color: AppColors.redLight,
//                     borderRadius: BorderRadius.circular(8.r),
//                   ),
//                   child: Icon(
//                     Icons.close_rounded,
//                     size: 14.sp,
//                     color: AppColors.red,
//                   ),
//                 ),
//               ),
//               Expanded(
//                 flex: 2,
//                 child: GestureDetector(
//                   onTap: () => _showNoteModal(item),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           Expanded(
//                             child: Text(
//                               capitalizeWords(item.dishName),
//                               style: TextStyle(
//                                 fontSize: 14.sp,
//                                 fontWeight: FontWeight.w600,
//                                 color: AppColors.text1,
//                               ),
//                             ),
//                           ),
//                           if (isModified)
//                             Container(
//                               padding: EdgeInsets.symmetric(
//                                 horizontal: 6.w,
//                                 vertical: 2.h,
//                               ),
//                               decoration: BoxDecoration(
//                                 color: AppColors.orange.withOpacity(0.2),
//                                 borderRadius: BorderRadius.circular(4.r),
//                               ),
//                               child: Text(
//                                 'Modified',
//                                 style: TextStyle(
//                                   fontSize: 9.sp,
//                                   color: AppColors.orange,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                             ),
//                         ],
//                       ),
//                       if (_itemNotes[item.itemId]?.isNotEmpty ?? false)
//                         Padding(
//                           padding: EdgeInsets.only(top: 2.h),
//                           child: Text(
//                             '📝 ${_itemNotes[item.itemId]}',
//                             style: TextStyle(
//                               fontSize: 10.sp,
//                               color: AppColors.accent,
//                             ),
//                           ),
//                         ),
//                     ],
//                   ),
//                 ),
//               ),
//               SizedBox(width: 8.w),
//               // ── Qty stepper ─────────────────────────────────────────────
//               Container(
//                 decoration: BoxDecoration(
//                   color: AppColors.bg,
//                   borderRadius: BorderRadius.circular(10.r),
//                   border: Border.all(color: AppColors.border),
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     // ── − button ───────────────────────────────────────────
//                     // ROLE_VENDOR  → always direct API call (no popup)
//                     // ROLE_EMPLOYEE → popup when reducing confirmed items
//                     _buildQtyBtn(
//                       icon: item.quantity == 1
//                           ? Icons.delete_outline_rounded
//                           : Icons.remove_rounded,
//                       color: AppColors.red,
//                       onTap: !_isUpdating
//                           ? () => _updateQuantity(item, item.quantity - 1)
//                           : null,
//                     ),
//                     Padding(
//                       padding: EdgeInsets.symmetric(horizontal: 10.w),
//                       child: isItemLoading
//                           ? SizedBox(
//                               width: 14.w,
//                               height: 14.w,
//                               child: const CircularProgressIndicator(
//                                 strokeWidth: 1.5,
//                               ),
//                             )
//                           : Text(
//                               '${item.quantity}',
//                               style: TextStyle(
//                                 fontSize: 13.sp,
//                                 fontWeight: FontWeight.w700,
//                               ),
//                             ),
//                     ),
//                     _buildQtyBtn(
//                       icon: Icons.add_rounded,
//                       color: canIncrease ? AppColors.green : AppColors.text3,
//                       onTap: !_isUpdating && canIncrease
//                           ? () => _updateQuantity(item, item.quantity + 1)
//                           : null,
//                     ),
//                   ],
//                 ),
//               ),
//               SizedBox(width: 12.w),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.end,
//                 children: [
//                   Text(
//                     '₹${item.price.toStringAsFixed(2)}',
//                     style: TextStyle(fontSize: 11.sp, color: AppColors.text2),
//                   ),
//                   Text(
//                     '₹${item.totalPrice.toStringAsFixed(2)}',
//                     style: TextStyle(
//                       fontSize: 13.sp,
//                       fontWeight: FontWeight.w700,
//                       color: AppColors.accent,
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(width: 8.w),
//               Text(
//                 istTime,
//                 style: TextStyle(fontSize: 10.sp, color: AppColors.text3),
//               ),
//             ],
//           ),
//           // Pending request chips — only for ROLE_VENDOR
//           if (_isVendorRole && hasPending) ...[
//             SizedBox(height: 8.h),
//             ...pendingRequests.map((req) => _buildRequestChip(req)),
//           ],
//         ],
//       ),
//     );
//   }
//
//   Widget _buildRequestChip(TableRequestEntry req) {
//     return Container(
//       margin: EdgeInsets.only(bottom: 4.h),
//       padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
//       decoration: BoxDecoration(
//         color: AppColors.orange.withOpacity(0.08),
//         borderRadius: BorderRadius.circular(8.r),
//         border: Border.all(color: AppColors.orange.withOpacity(0.3)),
//       ),
//       child: Row(
//         children: [
//           Icon(Icons.pending_rounded, color: AppColors.orange, size: 13.sp),
//           SizedBox(width: 6.w),
//           Expanded(
//             child: Text(
//               'Removal Req #${req.id} — qty ${req.quantity ?? 1}'
//               '${req.reason != null && req.reason!.isNotEmpty ? ' • ${req.reason}' : ''}',
//               style: TextStyle(
//                 fontSize: 11.sp,
//                 color: AppColors.orange,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//           GestureDetector(
//             onTap: () => _declineRequest(req),
//             child: Container(
//               padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
//               decoration: BoxDecoration(
//                 color: AppColors.redLight,
//                 borderRadius: BorderRadius.circular(6.r),
//               ),
//               child: Text(
//                 'Decline',
//                 style: TextStyle(
//                   fontSize: 10.sp,
//                   color: AppColors.red,
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//             ),
//           ),
//           SizedBox(width: 6.w),
//           GestureDetector(
//             onTap: () => _acceptRequest(req),
//             child: Container(
//               padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
//               decoration: BoxDecoration(
//                 color: AppColors.greenLight,
//                 borderRadius: BorderRadius.circular(6.r),
//               ),
//               child: Text(
//                 'Accept',
//                 style: TextStyle(
//                   fontSize: 10.sp,
//                   color: AppColors.green,
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildQtyBtn({
//     required IconData icon,
//     required Color color,
//     required VoidCallback? onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: EdgeInsets.all(6.w),
//         decoration: BoxDecoration(
//           color: (onTap == null ? AppColors.text3 : color).withOpacity(0.10),
//           borderRadius: BorderRadius.circular(8.r),
//         ),
//         child: Icon(
//           icon,
//           size: 14.sp,
//           color: onTap == null ? AppColors.text3 : color,
//         ),
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
//               ),
//             ),
//           );
//           _loadCart();
//           _loadAvailableQuantities();
//         },
//         child: Container(
//           padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
//           child: Row(mainAxisSize: MainAxisSize.min, children: []),
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
//           SizedBox(width: 12.w),
//           _buildActionButton('Check Out', AppColors.orange, _proceedToBilling),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildActionButton(
//     String label,
//     Color color,
//     VoidCallback? onTap, {
//     bool isLoading = false,
//   }) {
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
//                 child: const CircularProgressIndicator(
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
//
//   Widget _buildProceedToBillingBtn() {
//     return GestureDetector(
//       onTap: _proceedToBilling,
//       child: Container(
//         width: double.infinity,
//         padding: EdgeInsets.symmetric(vertical: 14.h),
//       ),
//     );
//   }
//
//   // =========================================================================
//   // BILLING BODY
//   // =========================================================================
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
//         color: AppColors.white,
//         borderRadius: BorderRadius.circular(16.r),
//         border: Border.all(color: AppColors.border),
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
//                     color: AppColors.accentLight,
//                     borderRadius: BorderRadius.circular(8.r),
//                   ),
//                   child: Icon(
//                     Icons.list_alt_outlined,
//                     color: AppColors.accent,
//                     size: 14.sp,
//                   ),
//                 ),
//                 SizedBox(width: 8.w),
//                 Text(
//                   'Order Items',
//                   style: TextStyle(
//                     fontSize: 15.sp,
//                     fontWeight: FontWeight.w700,
//                     color: AppColors.text1,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Divider(color: AppColors.border),
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
//                       color: AppColors.text2,
//                     ),
//                   ),
//                 ),
//                 SizedBox(
//                   width: 50.w,
//                   child: Text(
//                     'Qty',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       fontSize: 12.sp,
//                       fontWeight: FontWeight.w700,
//                       color: AppColors.text2,
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
//                       color: AppColors.text2,
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
//                       color: AppColors.text2,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Divider(color: AppColors.border),
//           ...cartData!.cartItems.map((item) {
//             final total = item.price * item.quantity;
//             return Padding(
//               padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
//               child: Row(
//                 children: [
//                   Expanded(
//                     flex: 3,
//                     child: Text(
//                       item.dishName,
//                       style: TextStyle(fontSize: 13.sp, color: AppColors.text1),
//                     ),
//                   ),
//                   SizedBox(
//                     width: 50.w,
//                     child: Text(
//                       '${item.quantity}',
//                       textAlign: TextAlign.center,
//                       style: TextStyle(fontSize: 13.sp),
//                     ),
//                   ),
//                   SizedBox(
//                     width: 60.w,
//                     child: Text(
//                       '₹${item.price.toStringAsFixed(2)}',
//                       textAlign: TextAlign.right,
//                       style: TextStyle(fontSize: 12.sp, color: AppColors.text2),
//                     ),
//                   ),
//                   SizedBox(
//                     width: 70.w,
//                     child: Text(
//                       '₹${total.toStringAsFixed(2)}',
//                       textAlign: TextAlign.right,
//                       style: TextStyle(
//                         fontSize: 13.sp,
//                         color: AppColors.accent,
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
//     final total = finalAmount;
//     return Container(
//       decoration: BoxDecoration(
//         color: AppColors.white,
//         borderRadius: BorderRadius.circular(16.r),
//         border: Border.all(color: AppColors.accent.withOpacity(0.3)),
//       ),
//       child: Column(
//         children: [
//           Container(
//             padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 12.h),
//             decoration: BoxDecoration(
//               gradient: const LinearGradient(
//                 colors: [AppColors.accent, AppColors.accentDark],
//               ),
//               borderRadius: const BorderRadius.vertical(
//                 top: Radius.circular(16),
//               ),
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
//               ],
//             ),
//           ),
//           Padding(
//             padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 14.h),
//             child: Column(
//               children: [
//                 _buildSummaryRow('Subtotal', cartData!.subtotal),
//                 _buildSummaryRow('GST', cartData!.gstTotal),
//                 if (cartData!.serviceCharges > 0) _buildChargeRow(),
//                 if (cartData!.packingTotal > 0)
//                   _buildSummaryRow('Packing Charges', cartData!.packingTotal),
//                 _buildVendorDiscountSection(),
//                 _buildCouponSection(),
//                 if (isCouponApplied && couponDiscount > 0)
//                   _buildSummaryRow(
//                     'Coupon Discount',
//                     -couponDiscount,
//                     isDiscount: true,
//                   ),
//                 SizedBox(height: 8.h),
//                 Divider(color: AppColors.accent.withOpacity(0.2)),
//                 SizedBox(height: 6.h),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       'Grand Total',
//                       style: TextStyle(
//                         fontSize: 16.sp,
//                         fontWeight: FontWeight.w800,
//                         color: AppColors.text1,
//                       ),
//                     ),
//                     Container(
//                       padding: EdgeInsets.symmetric(
//                         horizontal: 12.w,
//                         vertical: 6.h,
//                       ),
//                       decoration: BoxDecoration(
//                         gradient: const LinearGradient(
//                           colors: [AppColors.accent, AppColors.accentDark],
//                         ),
//                         borderRadius: BorderRadius.circular(10.r),
//                       ),
//                       child: Text(
//                         '₹${total.toStringAsFixed(2)}',
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
//   Widget _buildVendorDiscountSection() {
//     return Column(
//       children: [
//         SizedBox(height: 8.h),
//         Row(
//           children: [
//             Icon(
//               Icons.local_offer_outlined,
//               size: 14.sp,
//               color: AppColors.accent,
//             ),
//             SizedBox(width: 6.w),
//             Text(
//               'Discount',
//               style: TextStyle(
//                 fontSize: 13.sp,
//                 fontWeight: FontWeight.w600,
//                 color: AppColors.text1,
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
//                     border: Border.all(color: AppColors.border),
//                     borderRadius: BorderRadius.circular(8.r),
//                   ),
//                   child: TextField(
//                     controller: _discountController,
//                     keyboardType: const TextInputType.numberWithOptions(
//                       decimal: true,
//                     ),
//                     decoration: InputDecoration(
//                       hintText: 'Enter discount amount (₹)',
//                       hintStyle: TextStyle(
//                         fontSize: 12.sp,
//                         color: AppColors.text3,
//                       ),
//                       border: InputBorder.none,
//                       prefixIcon: Icon(
//                         Icons.currency_rupee,
//                         size: 14.sp,
//                         color: AppColors.text3,
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
//                         ? AppColors.accent.withOpacity(0.5)
//                         : AppColors.accent,
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
//               color: AppColors.greenLight,
//               borderRadius: BorderRadius.circular(8.r),
//               border: Border.all(color: AppColors.green.withOpacity(0.3)),
//             ),
//             child: Row(
//               children: [
//                 Icon(
//                   Icons.check_circle_outline_rounded,
//                   color: AppColors.green,
//                   size: 16.sp,
//                 ),
//                 SizedBox(width: 8.w),
//                 Expanded(
//                   child: Text(
//                     'Discount of ₹${_discountAmount.toStringAsFixed(2)} applied!',
//                     style: TextStyle(
//                       fontSize: 12.sp,
//                       color: AppColors.green,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//                 GestureDetector(
//                   onTap: _removeVendorDiscount,
//                   child: Icon(Icons.close, size: 14.sp, color: AppColors.red),
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
//   Widget _buildChargeRow() {
//     final double chargeAmount = _isUserLoggedIn
//         ? (cartData?.platformCharges ?? 0.0)
//         : (cartData?.serviceCharges ?? 0.0);
//     final String chargeLabel = _isUserLoggedIn
//         ? 'Platform Charges'
//         : 'Service Charges';
//     if (chargeAmount <= 0) return const SizedBox.shrink();
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 4.h),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             chargeLabel,
//             style: TextStyle(fontSize: 13.sp, color: AppColors.text2),
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
//                         ? AppColors.redLight
//                         : AppColors.accentLight,
//                     borderRadius: BorderRadius.circular(20.r),
//                   ),
//                   child: Text(
//                     isServiceChargeApplied ? 'Remove' : 'Apply',
//                     style: TextStyle(
//                       fontSize: 11.sp,
//                       fontWeight: FontWeight.w700,
//                       color: AppColors.accent,
//                     ),
//                   ),
//                 ),
//               ),
//               SizedBox(width: 8.w),
//               Text(
//                 '₹${chargeAmount.toStringAsFixed(2)}',
//                 style: TextStyle(
//                   fontSize: 13.sp,
//                   color: AppColors.text1,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildCouponSection() => Column(children: [SizedBox(height: 8.h)]);
//
//   Widget _buildSummaryRow(
//     String label,
//     double value, {
//     bool isDiscount = false,
//   }) {
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 4.h),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             label,
//             style: TextStyle(fontSize: 13.sp, color: AppColors.text2),
//           ),
//           Text(
//             '${value >= 0 ? '₹' : '-₹'}${value.abs().toStringAsFixed(2)}',
//             style: TextStyle(
//               fontSize: 13.sp,
//               color: isDiscount ? AppColors.green : AppColors.text1,
//               fontWeight: isDiscount ? FontWeight.w600 : FontWeight.normal,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildPaymentSection() {
//     final List<Widget> paymentOptions = [];
//     if (_paymentMethodsConfig['cash'] == true)
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
//           'Online Payment (Razorpay)',
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
//
//     return Container(
//       decoration: BoxDecoration(
//         color: AppColors.white,
//         borderRadius: BorderRadius.circular(16.r),
//         border: Border.all(color: AppColors.border),
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
//                     color: AppColors.accentLight,
//                     borderRadius: BorderRadius.circular(8.r),
//                   ),
//                   child: Icon(
//                     Icons.payment_outlined,
//                     color: AppColors.accent,
//                     size: 14.sp,
//                   ),
//                 ),
//                 SizedBox(width: 8.w),
//                 Text(
//                   'Payment Method',
//                   style: TextStyle(
//                     fontSize: 15.sp,
//                     fontWeight: FontWeight.w700,
//                     color: AppColors.text1,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Divider(color: AppColors.border),
//           Padding(
//             padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 12.h),
//             child: paymentOptions.isEmpty
//                 ? Padding(
//                     padding: EdgeInsets.symmetric(vertical: 12.h),
//                     child: Text(
//                       'No payment methods available',
//                       style: TextStyle(fontSize: 13.sp, color: AppColors.text3),
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
//           color: isSelected ? AppColors.accentLight : AppColors.bg,
//           borderRadius: BorderRadius.circular(12.r),
//           border: Border.all(
//             color: isSelected ? AppColors.accent : AppColors.border,
//             width: isSelected ? 1.5 : 1,
//           ),
//         ),
//         child: Row(
//           children: [
//             Container(
//               width: 36.r,
//               height: 36.r,
//               decoration: BoxDecoration(
//                 color: isSelected ? AppColors.accent : AppColors.white,
//                 borderRadius: BorderRadius.circular(10.r),
//                 border: isSelected ? null : Border.all(color: AppColors.border),
//               ),
//               child: Icon(
//                 icon,
//                 color: isSelected ? Colors.white : AppColors.text2,
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
//                   color: isSelected ? AppColors.accent : AppColors.text1,
//                 ),
//               ),
//             ),
//             if (value == 'QR_Payment' && _isGeneratingQr)
//               SizedBox(
//                 width: 18.w,
//                 height: 18.w,
//                 child: CircularProgressIndicator(
//                   color: AppColors.accent,
//                   strokeWidth: 2,
//                 ),
//               )
//             else if (isSelected)
//               Container(
//                 width: 20.r,
//                 height: 20.r,
//                 decoration: const BoxDecoration(
//                   color: AppColors.accent,
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
//                   border: Border.all(color: AppColors.border, width: 1.5),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildPlaceOrderBtn() {
//     final isDisabled = isPlacingOrder || selectedPaymentMethod.isEmpty;
//     return GestureDetector(
//       onTap: isDisabled ? null : placeOrder,
//       child: Container(
//         width: double.infinity,
//         padding: EdgeInsets.symmetric(vertical: 15.h),
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: isDisabled
//                 ? [AppColors.text3, AppColors.text3]
//                 : [AppColors.accent, AppColors.accentDark],
//           ),
//           borderRadius: BorderRadius.circular(14.r),
//         ),
//         child: isPlacingOrder
//             ? Center(
//                 child: SizedBox(
//                   width: 22.w,
//                   height: 22.w,
//                   child: const CircularProgressIndicator(
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
//                         : 'Pay ₹${finalAmount.toStringAsFixed(2)}',
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
//             decoration: const BoxDecoration(
//               color: AppColors.accentLight,
//               shape: BoxShape.circle,
//             ),
//             child: Icon(
//               Icons.shopping_cart_outlined,
//               size: 40.sp,
//               color: AppColors.accent,
//             ),
//           ),
//           SizedBox(height: 16.h),
//           Text(
//             'Your cart is empty',
//             style: TextStyle(
//               fontSize: 18.sp,
//               fontWeight: FontWeight.w700,
//               color: AppColors.text1,
//             ),
//           ),
//           SizedBox(height: 6.h),
//           Text(
//             'Add some delicious items',
//             style: TextStyle(fontSize: 13.sp, color: AppColors.text2),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildNoteModal() {
//     return Dialog(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
//       child: Container(
//         padding: EdgeInsets.all(20.w),
//         width: 350.w,
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(
//               'Add Note for ${_selectedItemForNote?.dishName ?? ''}',
//               style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 16.h),
//             TextField(
//               onChanged: (value) => _tempNote = value,
//               controller: TextEditingController(text: _tempNote),
//               maxLines: 4,
//               decoration: InputDecoration(
//                 hintText: 'Enter special instructions...',
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8.r),
//                 ),
//               ),
//             ),
//             SizedBox(height: 16.h),
//             Row(
//               children: [
//                 Expanded(
//                   child: OutlinedButton(
//                     onPressed: _cancelNote,
//                     child: const Text('Cancel'),
//                   ),
//                 ),
//                 SizedBox(width: 12.w),
//                 Expanded(
//                   child: ElevatedButton(
//                     onPressed: _saveNote,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppColors.accent,
//                     ),
//                     child: const Text('Save'),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // ═══════════════════════════════════════════════════════════════════════════════
// // PENDING REQUESTS BOTTOM SHEET
// // ═══════════════════════════════════════════════════════════════════════════════
//
// class _PendingRequestsSheet extends StatelessWidget {
//   final List<TableRequestEntry> requests;
//   final bool isVendorRole;
//   final Future<void> Function(TableRequestEntry) onAccept;
//   final Future<void> Function(TableRequestEntry) onDecline;
//   final Future<void> Function() onRefresh;
//
//   const _PendingRequestsSheet({
//     required this.requests,
//     required this.isVendorRole,
//     required this.onAccept,
//     required this.onDecline,
//     required this.onRefresh,
//   });
//
//   Color _statusColor(String status) {
//     switch (status) {
//       case 'ACCEPT':
//         return AppColors.green;
//       case 'DECLINE':
//         return AppColors.red;
//       default:
//         return AppColors.orange;
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       constraints: BoxConstraints(
//         maxHeight: MediaQuery.of(context).size.height * 0.75,
//       ),
//       decoration: BoxDecoration(
//         color: AppColors.white,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
//       ),
//       child: SafeArea(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               width: 40.w,
//               height: 4.h,
//               margin: EdgeInsets.only(top: 12.h),
//               decoration: BoxDecoration(
//                 color: AppColors.border,
//                 borderRadius: BorderRadius.circular(2.r),
//               ),
//             ),
//             Padding(
//               padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
//               child: Row(
//                 children: [
//                   Container(
//                     width: 42.r,
//                     height: 42.r,
//                     decoration: BoxDecoration(
//                       color: AppColors.orange.withOpacity(0.12),
//                       borderRadius: BorderRadius.circular(12.r),
//                     ),
//                     child: Icon(
//                       Icons.pending_actions_rounded,
//                       color: AppColors.orange,
//                       size: 22.sp,
//                     ),
//                   ),
//                   SizedBox(width: 12.w),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Removal Requests',
//                           style: TextStyle(
//                             fontSize: 17.sp,
//                             fontWeight: FontWeight.w800,
//                             color: AppColors.text1,
//                           ),
//                         ),
//                         Text(
//                           '${requests.where((r) => r.isPending).length} pending • ${requests.length} total',
//                           style: TextStyle(
//                             fontSize: 12.sp,
//                             color: AppColors.text2,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   GestureDetector(
//                     onTap: () => Navigator.pop(context),
//                     child: Container(
//                       width: 30.r,
//                       height: 30.r,
//                       decoration: BoxDecoration(
//                         color: AppColors.bg,
//                         borderRadius: BorderRadius.circular(8.r),
//                         border: Border.all(color: AppColors.border),
//                       ),
//                       child: Icon(
//                         Icons.close,
//                         size: 16.sp,
//                         color: AppColors.text2,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             SizedBox(height: 12.h),
//             Divider(color: AppColors.border),
//             Flexible(
//               child: requests.isEmpty
//                   ? Center(
//                       child: Padding(
//                         padding: EdgeInsets.all(32.r),
//                         child: Text(
//                           'No requests found',
//                           style: TextStyle(
//                             fontSize: 14.sp,
//                             color: AppColors.text3,
//                           ),
//                         ),
//                       ),
//                     )
//                   : ListView.separated(
//                       shrinkWrap: true,
//                       padding: EdgeInsets.all(16.r),
//                       itemCount: requests.length,
//                       separatorBuilder: (_, __) => SizedBox(height: 10.h),
//                       itemBuilder: (ctx, i) {
//                         final req = requests[i];
//                         return Container(
//                           padding: EdgeInsets.all(14.r),
//                           decoration: BoxDecoration(
//                             color: AppColors.bg,
//                             borderRadius: BorderRadius.circular(12.r),
//                             border: Border.all(color: AppColors.border),
//                           ),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Row(
//                                 children: [
//                                   Container(
//                                     width: 34.r,
//                                     height: 34.r,
//                                     decoration: BoxDecoration(
//                                       color: AppColors.accentLight,
//                                       borderRadius: BorderRadius.circular(8.r),
//                                     ),
//                                     child: Icon(
//                                       Icons.remove_shopping_cart_outlined,
//                                       color: AppColors.accent,
//                                       size: 16.sp,
//                                     ),
//                                   ),
//                                   SizedBox(width: 10.w),
//                                   Expanded(
//                                     child: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         Text(
//                                           req.itemName ?? 'Item #${req.itemId}',
//                                           style: TextStyle(
//                                             fontSize: 13.sp,
//                                             fontWeight: FontWeight.w700,
//                                             color: AppColors.text1,
//                                           ),
//                                         ),
//                                         Text(
//                                           'Req #${req.id} • Qty: ${req.quantity ?? 1} • By: ${req.name}',
//                                           style: TextStyle(
//                                             fontSize: 11.sp,
//                                             color: AppColors.text2,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                   Container(
//                                     padding: EdgeInsets.symmetric(
//                                       horizontal: 8.w,
//                                       vertical: 3.h,
//                                     ),
//                                     decoration: BoxDecoration(
//                                       color: _statusColor(
//                                         req.status,
//                                       ).withOpacity(0.12),
//                                       borderRadius: BorderRadius.circular(20.r),
//                                     ),
//                                     child: Text(
//                                       req.status,
//                                       style: TextStyle(
//                                         fontSize: 10.sp,
//                                         fontWeight: FontWeight.w700,
//                                         color: _statusColor(req.status),
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               if (req.reason != null &&
//                                   req.reason!.isNotEmpty) ...[
//                                 SizedBox(height: 8.h),
//                                 Container(
//                                   padding: EdgeInsets.all(8.r),
//                                   decoration: BoxDecoration(
//                                     color: AppColors.white,
//                                     borderRadius: BorderRadius.circular(8.r),
//                                     border: Border.all(color: AppColors.border),
//                                   ),
//                                   child: Row(
//                                     children: [
//                                       Icon(
//                                         Icons.notes_rounded,
//                                         size: 12.sp,
//                                         color: AppColors.text3,
//                                       ),
//                                       SizedBox(width: 6.w),
//                                       Expanded(
//                                         child: Text(
//                                           req.reason!,
//                                           style: TextStyle(
//                                             fontSize: 12.sp,
//                                             color: AppColors.text2,
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                               // Accept / Decline only for ROLE_VENDOR
//                               if (isVendorRole && req.isPending) ...[
//                                 SizedBox(height: 10.h),
//                                 Row(
//                                   children: [
//                                     Expanded(
//                                       child: GestureDetector(
//                                         onTap: () => onDecline(req),
//                                         child: Container(
//                                           padding: EdgeInsets.symmetric(
//                                             vertical: 10.h,
//                                           ),
//                                           decoration: BoxDecoration(
//                                             color: AppColors.redLight,
//                                             borderRadius: BorderRadius.circular(
//                                               8.r,
//                                             ),
//                                             border: Border.all(
//                                               color: AppColors.red.withOpacity(
//                                                 0.3,
//                                               ),
//                                             ),
//                                           ),
//                                           child: Row(
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.center,
//                                             children: [
//                                               Icon(
//                                                 Icons.close_rounded,
//                                                 color: AppColors.red,
//                                                 size: 14.sp,
//                                               ),
//                                               SizedBox(width: 4.w),
//                                               Text(
//                                                 'Decline',
//                                                 style: TextStyle(
//                                                   fontSize: 13.sp,
//                                                   fontWeight: FontWeight.w700,
//                                                   color: AppColors.red,
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                     SizedBox(width: 10.w),
//                                     Expanded(
//                                       flex: 2,
//                                       child: GestureDetector(
//                                         onTap: () => onAccept(req),
//                                         child: Container(
//                                           padding: EdgeInsets.symmetric(
//                                             vertical: 10.h,
//                                           ),
//                                           decoration: BoxDecoration(
//                                             gradient: LinearGradient(
//                                               colors: [
//                                                 AppColors.green,
//                                                 const Color(0xFF27AE60),
//                                               ],
//                                             ),
//                                             borderRadius: BorderRadius.circular(
//                                               8.r,
//                                             ),
//                                           ),
//                                           child: Row(
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.center,
//                                             children: [
//                                               Icon(
//                                                 Icons.check_rounded,
//                                                 color: Colors.white,
//                                                 size: 14.sp,
//                                               ),
//                                               SizedBox(width: 4.w),
//                                               Text(
//                                                 'Accept',
//                                                 style: TextStyle(
//                                                   fontSize: 13.sp,
//                                                   fontWeight: FontWeight.w700,
//                                                   color: Colors.white,
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ],
//                           ),
//                         );
//                       },
//                     ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // ═══════════════════════════════════════════════════════════════════════════════
// // REQUEST TYPE ENUM
// // ═══════════════════════════════════════════════════════════════════════════════
//
// enum RemovalRequestType { removalQuantity, removeItem }
//
// // ═══════════════════════════════════════════════════════════════════════════════
// // REMOVAL REQUEST DIALOG  (shown only for ROLE_EMPLOYEE)
// // ═══════════════════════════════════════════════════════════════════════════════
//
// class _RemovalRequestDialog extends StatefulWidget {
//   final dineout.CartItem item;
//   final int cartId;
//   final int vendorId;
//   final int userId;
//   final int employeeId;
//   final String customerId;
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
//     required this.customerId,
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
//
//   RemovalRequestType _selectedType = RemovalRequestType.removalQuantity;
//   bool _dropdownOpen = false;
//   int _removeQty = 1;
//
//   @override
//   void dispose() {
//     _reasonController.dispose();
//     super.dispose();
//   }
//
//   String get _requestTypeValue =>
//       _selectedType == RemovalRequestType.removalQuantity
//       ? 'REMOVAL_QUANTITY'
//       : 'REMOVE_ITEM';
//
//   String get _dropdownLabel =>
//       _selectedType == RemovalRequestType.removalQuantity
//       ? 'Removal Quantity'
//       : 'Remove Item';
//
//   Color get _typeColor => _selectedType == RemovalRequestType.removalQuantity
//       ? AppColors.orange
//       : AppColors.red;
//
//   IconData get _typeIcon => _selectedType == RemovalRequestType.removalQuantity
//       ? Icons.remove_circle_outline_rounded
//       : Icons.delete_outline_rounded;
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
//           backgroundColor: AppColors.orange,
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
//       final payload = TableRequestModel(
//         vendorId: widget.vendorId,
//         userId: widget.userId,
//         itemId: widget.item.itemId,
//         removalQuantity: _selectedType == RemovalRequestType.removalQuantity
//             ? _removeQty
//             : widget.item.quantity,
//         cartId: widget.cartId,
//         tableBookingId: widget.bookingId,
//         tableCode: widget.tableCode,
//         requestType: _requestTypeValue,
//         employeeId: widget.employeeId,
//         customerId: widget.customerId,
//         reason: reason,
//       );
//
//       debugPrint('📤 Submitting removal request:');
//       debugPrint(jsonEncode(payload.toJson()));
//
//       final ok = await TableRequestService.createRemovalRequest(
//         request: payload,
//       );
//
//       if (!ok) {
//         widget.onError('Failed to submit request. Please try again.');
//         if (mounted) Navigator.pop(context);
//         return;
//       }
//
//       if (mounted) Navigator.pop(context);
//       widget.onSuccess();
//     } catch (e) {
//       widget.onError('Error: $e');
//       if (mounted) Navigator.pop(context);
//     } finally {
//       if (mounted) setState(() => _isSubmitting = false);
//     }
//   }
//
//   void _selectType(RemovalRequestType type) {
//     setState(() {
//       _selectedType = type;
//       _dropdownOpen = false;
//       _removeQty = 1;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.only(
//         bottom: MediaQuery.of(context).viewInsets.bottom,
//       ),
//       child: Container(
//         decoration: BoxDecoration(
//           color: AppColors.white,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
//         ),
//         child: SafeArea(
//           child: SingleChildScrollView(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Container(
//                   width: 40.w,
//                   height: 4.h,
//                   margin: EdgeInsets.only(top: 12.h),
//                   decoration: BoxDecoration(
//                     color: AppColors.border,
//                     borderRadius: BorderRadius.circular(2.r),
//                   ),
//                 ),
//                 Padding(
//                   padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
//                   child: Row(
//                     children: [
//                       Container(
//                         width: 44.r,
//                         height: 44.r,
//                         decoration: BoxDecoration(
//                           color: AppColors.redLight,
//                           borderRadius: BorderRadius.circular(12.r),
//                         ),
//                         child: Icon(
//                           Icons.remove_shopping_cart_outlined,
//                           color: AppColors.red,
//                           size: 22.sp,
//                         ),
//                       ),
//                       SizedBox(width: 12.w),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'Removal Request',
//                               style: TextStyle(
//                                 fontSize: 17.sp,
//                                 fontWeight: FontWeight.w800,
//                                 color: AppColors.text1,
//                               ),
//                             ),
//                             Text(
//                               'Choose request type and fill details',
//                               style: TextStyle(
//                                 fontSize: 12.sp,
//                                 color: AppColors.text2,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       GestureDetector(
//                         onTap: () => Navigator.pop(context),
//                         child: Container(
//                           width: 30.r,
//                           height: 30.r,
//                           decoration: BoxDecoration(
//                             color: AppColors.bg,
//                             borderRadius: BorderRadius.circular(8.r),
//                             border: Border.all(color: AppColors.border),
//                           ),
//                           child: Icon(
//                             Icons.close,
//                             size: 16.sp,
//                             color: AppColors.text2,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 SizedBox(height: 16.h),
//                 Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 20.w),
//                   child: Container(
//                     padding: EdgeInsets.all(14.r),
//                     decoration: BoxDecoration(
//                       color: AppColors.accentLight,
//                       borderRadius: BorderRadius.circular(12.r),
//                       border: Border.all(
//                         color: AppColors.accent.withOpacity(0.3),
//                       ),
//                     ),
//                     child: Row(
//                       children: [
//                         Container(
//                           width: 40.r,
//                           height: 40.r,
//                           decoration: BoxDecoration(
//                             color: AppColors.accent,
//                             borderRadius: BorderRadius.circular(10.r),
//                           ),
//                           child: Icon(
//                             Icons.restaurant_menu_rounded,
//                             color: Colors.white,
//                             size: 20.sp,
//                           ),
//                         ),
//                         SizedBox(width: 12.w),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 widget.item.dishName,
//                                 style: TextStyle(
//                                   fontSize: 14.sp,
//                                   fontWeight: FontWeight.w700,
//                                   color: AppColors.text1,
//                                 ),
//                               ),
//                               SizedBox(height: 2.h),
//                               Row(
//                                 children: [
//                                   _infoChip(
//                                     '${widget.item.quantity} in cart',
//                                     Icons.shopping_cart_outlined,
//                                     AppColors.accent,
//                                   ),
//                                   SizedBox(width: 8.w),
//                                   _infoChip(
//                                     '₹${widget.item.price.toStringAsFixed(0)} each',
//                                     Icons.currency_rupee,
//                                     AppColors.green,
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 16.h),
//                 Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 20.w),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           Icon(
//                             Icons.tune_rounded,
//                             size: 14.sp,
//                             color: AppColors.text2,
//                           ),
//                           SizedBox(width: 6.w),
//                           Text(
//                             'Request Type',
//                             style: TextStyle(
//                               fontSize: 13.sp,
//                               fontWeight: FontWeight.w700,
//                               color: AppColors.text1,
//                             ),
//                           ),
//                         ],
//                       ),
//                       SizedBox(height: 8.h),
//                       GestureDetector(
//                         onTap: () =>
//                             setState(() => _dropdownOpen = !_dropdownOpen),
//                         child: AnimatedContainer(
//                           duration: const Duration(milliseconds: 200),
//                           padding: EdgeInsets.symmetric(
//                             horizontal: 14.w,
//                             vertical: 13.h,
//                           ),
//                           decoration: BoxDecoration(
//                             color: _typeColor.withOpacity(0.07),
//                             borderRadius: BorderRadius.circular(12.r),
//                             border: Border.all(
//                               color: _typeColor.withOpacity(0.5),
//                               width: 1.5,
//                             ),
//                           ),
//                           child: Row(
//                             children: [
//                               Container(
//                                 width: 32.r,
//                                 height: 32.r,
//                                 decoration: BoxDecoration(
//                                   color: _typeColor.withOpacity(0.12),
//                                   borderRadius: BorderRadius.circular(8.r),
//                                 ),
//                                 child: Icon(
//                                   _typeIcon,
//                                   color: _typeColor,
//                                   size: 16.sp,
//                                 ),
//                               ),
//                               SizedBox(width: 12.w),
//                               Expanded(
//                                 child: Text(
//                                   _dropdownLabel,
//                                   style: TextStyle(
//                                     fontSize: 14.sp,
//                                     fontWeight: FontWeight.w700,
//                                     color: _typeColor,
//                                   ),
//                                 ),
//                               ),
//                               AnimatedRotation(
//                                 turns: _dropdownOpen ? 0.5 : 0,
//                                 duration: const Duration(milliseconds: 200),
//                                 child: Icon(
//                                   Icons.keyboard_arrow_down_rounded,
//                                   color: _typeColor,
//                                   size: 20.sp,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                       AnimatedCrossFade(
//                         duration: const Duration(milliseconds: 200),
//                         crossFadeState: _dropdownOpen
//                             ? CrossFadeState.showFirst
//                             : CrossFadeState.showSecond,
//                         firstChild: Container(
//                           margin: EdgeInsets.only(top: 4.h),
//                           decoration: BoxDecoration(
//                             color: AppColors.white,
//                             borderRadius: BorderRadius.circular(12.r),
//                             border: Border.all(color: AppColors.border),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black.withOpacity(0.06),
//                                 blurRadius: 12,
//                                 offset: const Offset(0, 4),
//                               ),
//                             ],
//                           ),
//                           child: Column(
//                             children: [
//                               _buildDropdownOption(
//                                 type: RemovalRequestType.removalQuantity,
//                                 label: 'Removal Quantity',
//                                 sublabel: 'Reduce quantity of this item',
//                                 icon: Icons.remove_circle_outline_rounded,
//                                 color: AppColors.orange,
//                                 isLast: false,
//                               ),
//                               _buildDropdownOption(
//                                 type: RemovalRequestType.removeItem,
//                                 label: 'Remove Item',
//                                 sublabel: 'Remove entire item from cart',
//                                 icon: Icons.delete_outline_rounded,
//                                 color: AppColors.red,
//                                 isLast: true,
//                               ),
//                             ],
//                           ),
//                         ),
//                         secondChild: const SizedBox.shrink(),
//                       ),
//                     ],
//                   ),
//                 ),
//                 SizedBox(height: 16.h),
//                 if (_selectedType == RemovalRequestType.removalQuantity)
//                   _buildQuantitySection(),
//                 if (_selectedType == RemovalRequestType.removeItem)
//                   _buildRemoveItemPreview(),
//                 SizedBox(height: 16.h),
//                 Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 20.w),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           Icon(
//                             Icons.edit_note_rounded,
//                             size: 14.sp,
//                             color: AppColors.text2,
//                           ),
//                           SizedBox(width: 6.w),
//                           Text(
//                             'Reason for Removal',
//                             style: TextStyle(
//                               fontSize: 13.sp,
//                               fontWeight: FontWeight.w700,
//                               color: AppColors.text1,
//                             ),
//                           ),
//                           Text(
//                             ' *',
//                             style: TextStyle(
//                               fontSize: 13.sp,
//                               color: AppColors.red,
//                             ),
//                           ),
//                         ],
//                       ),
//                       SizedBox(height: 8.h),
//                       Container(
//                         decoration: BoxDecoration(
//                           color: AppColors.bg,
//                           borderRadius: BorderRadius.circular(12.r),
//                           border: Border.all(color: AppColors.border),
//                         ),
//                         child: TextField(
//                           controller: _reasonController,
//                           maxLines: 3,
//                           decoration: InputDecoration(
//                             hintText:
//                                 'e.g. Customer changed mind, wrong item ordered...',
//                             hintStyle: TextStyle(
//                               fontSize: 12.sp,
//                               color: AppColors.text3,
//                             ),
//                             border: InputBorder.none,
//                             contentPadding: EdgeInsets.all(12.r),
//                           ),
//                           style: TextStyle(
//                             fontSize: 13.sp,
//                             color: AppColors.text1,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 SizedBox(height: 20.h),
//                 Padding(
//                   padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 8.h),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: GestureDetector(
//                           onTap: () => Navigator.pop(context),
//                           child: Container(
//                             padding: EdgeInsets.symmetric(vertical: 14.h),
//                             decoration: BoxDecoration(
//                               color: AppColors.bg,
//                               borderRadius: BorderRadius.circular(12.r),
//                               border: Border.all(color: AppColors.border),
//                             ),
//                             child: Center(
//                               child: Text(
//                                 'Cancel',
//                                 style: TextStyle(
//                                   fontSize: 14.sp,
//                                   fontWeight: FontWeight.w700,
//                                   color: AppColors.text2,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                       SizedBox(width: 12.w),
//                       Expanded(
//                         flex: 2,
//                         child: GestureDetector(
//                           onTap: _isSubmitting ? null : _submit,
//                           child: AnimatedContainer(
//                             duration: const Duration(milliseconds: 150),
//                             padding: EdgeInsets.symmetric(vertical: 14.h),
//                             decoration: BoxDecoration(
//                               gradient: LinearGradient(
//                                 colors: _isSubmitting
//                                     ? [AppColors.text3, AppColors.text3]
//                                     : _selectedType ==
//                                           RemovalRequestType.removeItem
//                                     ? [AppColors.red, const Color(0xFFB91C1C)]
//                                     : [
//                                         AppColors.orange,
//                                         const Color(0xFFD97706),
//                                       ],
//                               ),
//                               borderRadius: BorderRadius.circular(12.r),
//                               boxShadow: _isSubmitting
//                                   ? []
//                                   : [
//                                       BoxShadow(
//                                         color: _typeColor.withOpacity(0.3),
//                                         blurRadius: 8,
//                                         offset: const Offset(0, 4),
//                                       ),
//                                     ],
//                             ),
//                             child: _isSubmitting
//                                 ? Center(
//                                     child: SizedBox(
//                                       width: 20.w,
//                                       height: 20.w,
//                                       child: const CircularProgressIndicator(
//                                         color: Colors.white,
//                                         strokeWidth: 2,
//                                       ),
//                                     ),
//                                   )
//                                 : Row(
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: [
//                                       Icon(
//                                         Icons.send_rounded,
//                                         color: Colors.white,
//                                         size: 16.sp,
//                                       ),
//                                       SizedBox(width: 8.w),
//                                       Text(
//                                         'Submit Request',
//                                         style: TextStyle(
//                                           fontSize: 14.sp,
//                                           fontWeight: FontWeight.w700,
//                                           color: Colors.white,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildDropdownOption({
//     required RemovalRequestType type,
//     required String label,
//     required String sublabel,
//     required IconData icon,
//     required Color color,
//     required bool isLast,
//   }) {
//     final isSelected = _selectedType == type;
//     return GestureDetector(
//       onTap: () => _selectType(type),
//       child: Container(
//         padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
//         decoration: BoxDecoration(
//           color: isSelected ? color.withOpacity(0.06) : Colors.transparent,
//           borderRadius: isLast
//               ? BorderRadius.vertical(bottom: Radius.circular(12.r))
//               : BorderRadius.zero,
//           border: isLast
//               ? null
//               : Border(bottom: BorderSide(color: AppColors.border)),
//         ),
//         child: Row(
//           children: [
//             Container(
//               width: 34.r,
//               height: 34.r,
//               decoration: BoxDecoration(
//                 color: color.withOpacity(isSelected ? 0.15 : 0.08),
//                 borderRadius: BorderRadius.circular(8.r),
//               ),
//               child: Icon(icon, color: color, size: 16.sp),
//             ),
//             SizedBox(width: 12.w),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     label,
//                     style: TextStyle(
//                       fontSize: 13.sp,
//                       fontWeight: isSelected
//                           ? FontWeight.w700
//                           : FontWeight.w600,
//                       color: isSelected ? color : AppColors.text1,
//                     ),
//                   ),
//                   Text(
//                     sublabel,
//                     style: TextStyle(fontSize: 11.sp, color: AppColors.text3),
//                   ),
//                 ],
//               ),
//             ),
//             if (isSelected)
//               Container(
//                 width: 20.r,
//                 height: 20.r,
//                 decoration: BoxDecoration(color: color, shape: BoxShape.circle),
//                 child: Icon(
//                   Icons.check_rounded,
//                   color: Colors.white,
//                   size: 12.sp,
//                 ),
//               )
//             else
//               Container(
//                 width: 20.r,
//                 height: 20.r,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   border: Border.all(color: AppColors.border, width: 1.5),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildQuantitySection() {
//     final presentQty = widget.item.quantity;
//     final remainQty = presentQty - _removeQty;
//
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 20.w),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(
//                 Icons.format_list_numbered_rounded,
//                 size: 14.sp,
//                 color: AppColors.text2,
//               ),
//               SizedBox(width: 6.w),
//               Text(
//                 'Quantity Details',
//                 style: TextStyle(
//                   fontSize: 13.sp,
//                   fontWeight: FontWeight.w700,
//                   color: AppColors.text1,
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 10.h),
//           Container(
//             padding: EdgeInsets.all(14.r),
//             decoration: BoxDecoration(
//               color: AppColors.bg,
//               borderRadius: BorderRadius.circular(12.r),
//               border: Border.all(color: AppColors.border),
//             ),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: _qtyStatBox(
//                     label: 'Present',
//                     value: presentQty,
//                     color: AppColors.blue,
//                     icon: Icons.inventory_2_outlined,
//                   ),
//                 ),
//                 Container(width: 1, height: 48.h, color: AppColors.border),
//                 Expanded(
//                   child: _qtyStatBox(
//                     label: 'Removing',
//                     value: _removeQty,
//                     color: AppColors.red,
//                     icon: Icons.remove_circle_outline_rounded,
//                   ),
//                 ),
//                 Container(width: 1, height: 48.h, color: AppColors.border),
//                 Expanded(
//                   child: _qtyStatBox(
//                     label: 'Remaining',
//                     value: remainQty < 0 ? 0 : remainQty,
//                     color: AppColors.green,
//                     icon: Icons.check_circle_outline_rounded,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           SizedBox(height: 12.h),
//           Container(
//             padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
//             decoration: BoxDecoration(
//               color: AppColors.white,
//               borderRadius: BorderRadius.circular(12.r),
//               border: Border.all(color: AppColors.border),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 GestureDetector(
//                   onTap: _removeQty > 1
//                       ? () => setState(() => _removeQty--)
//                       : null,
//                   child: AnimatedContainer(
//                     duration: const Duration(milliseconds: 120),
//                     width: 40.r,
//                     height: 40.r,
//                     decoration: BoxDecoration(
//                       color: _removeQty > 1
//                           ? AppColors.red.withOpacity(0.1)
//                           : AppColors.border.withOpacity(0.4),
//                       borderRadius: BorderRadius.circular(10.r),
//                     ),
//                     child: Icon(
//                       Icons.remove_rounded,
//                       size: 20.sp,
//                       color: _removeQty > 1 ? AppColors.red : AppColors.text3,
//                     ),
//                   ),
//                 ),
//                 Expanded(
//                   child: Column(
//                     children: [
//                       Text(
//                         '$_removeQty',
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                           fontSize: 26.sp,
//                           fontWeight: FontWeight.w900,
//                           color: AppColors.red,
//                           height: 1.1,
//                         ),
//                       ),
//                       Text(
//                         'to remove',
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                           fontSize: 10.sp,
//                           color: AppColors.text3,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 GestureDetector(
//                   onTap: _removeQty < presentQty
//                       ? () => setState(() => _removeQty++)
//                       : null,
//                   child: AnimatedContainer(
//                     duration: const Duration(milliseconds: 120),
//                     width: 40.r,
//                     height: 40.r,
//                     decoration: BoxDecoration(
//                       color: _removeQty < presentQty
//                           ? AppColors.green.withOpacity(0.1)
//                           : AppColors.border.withOpacity(0.4),
//                       borderRadius: BorderRadius.circular(10.r),
//                     ),
//                     child: Icon(
//                       Icons.add_rounded,
//                       size: 20.sp,
//                       color: _removeQty < presentQty
//                           ? AppColors.green
//                           : AppColors.text3,
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
//   Widget _qtyStatBox({
//     required String label,
//     required int value,
//     required Color color,
//     required IconData icon,
//   }) {
//     return Column(
//       children: [
//         Icon(icon, color: color, size: 18.sp),
//         SizedBox(height: 4.h),
//         Text(
//           '$value',
//           style: TextStyle(
//             fontSize: 18.sp,
//             fontWeight: FontWeight.w900,
//             color: color,
//           ),
//         ),
//         Text(
//           label,
//           style: TextStyle(fontSize: 10.sp, color: AppColors.text3),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildRemoveItemPreview() {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 20.w),
//       child: Container(
//         padding: EdgeInsets.all(14.r),
//         decoration: BoxDecoration(
//           color: AppColors.redLight,
//           borderRadius: BorderRadius.circular(12.r),
//           border: Border.all(color: AppColors.red.withOpacity(0.3)),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Icon(
//                   Icons.warning_amber_rounded,
//                   color: AppColors.red,
//                   size: 16.sp,
//                 ),
//                 SizedBox(width: 6.w),
//                 Text(
//                   'This will remove the entire item',
//                   style: TextStyle(
//                     fontSize: 12.sp,
//                     fontWeight: FontWeight.w700,
//                     color: AppColors.red,
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: 10.h),
//             Container(
//               padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
//               decoration: BoxDecoration(
//                 color: AppColors.white.withOpacity(0.7),
//                 borderRadius: BorderRadius.circular(8.r),
//               ),
//               child: Row(
//                 children: [
//                   Container(
//                     width: 28.r,
//                     height: 28.r,
//                     decoration: BoxDecoration(
//                       color: AppColors.red.withOpacity(0.15),
//                       shape: BoxShape.circle,
//                     ),
//                     child: Icon(
//                       Icons.close_rounded,
//                       color: AppColors.red,
//                       size: 14.sp,
//                     ),
//                   ),
//                   SizedBox(width: 10.w),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Stack(
//                           alignment: Alignment.center,
//                           children: [
//                             Text(
//                               widget.item.dishName,
//                               style: TextStyle(
//                                 fontSize: 14.sp,
//                                 fontWeight: FontWeight.w600,
//                                 color: AppColors.text2,
//                               ),
//                             ),
//                             Positioned.fill(
//                               child: Center(
//                                 child: Container(
//                                   height: 1.5,
//                                   color: AppColors.red.withOpacity(0.7),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                         SizedBox(height: 2.h),
//                         Text(
//                           '${widget.item.quantity} qty × ₹${widget.item.price.toStringAsFixed(0)}',
//                           style: TextStyle(
//                             fontSize: 11.sp,
//                             color: AppColors.text3,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Stack(
//                     alignment: Alignment.center,
//                     children: [
//                       Text(
//                         '₹${widget.item.totalPrice.toStringAsFixed(0)}',
//                         style: TextStyle(
//                           fontSize: 13.sp,
//                           fontWeight: FontWeight.w700,
//                           color: AppColors.text2,
//                         ),
//                       ),
//                       Positioned.fill(
//                         child: Center(
//                           child: Container(
//                             height: 1.5,
//                             color: AppColors.red.withOpacity(0.7),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _infoChip(String label, IconData icon, Color color) {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.12),
//         borderRadius: BorderRadius.circular(20.r),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(icon, size: 10.sp, color: color),
//           SizedBox(width: 3.w),
//           Text(
//             label,
//             style: TextStyle(
//               fontSize: 10.sp,
//               color: color,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
