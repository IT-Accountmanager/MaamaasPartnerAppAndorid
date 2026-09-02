import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:maamaaspartner/user_module/API/Auth_service.dart';
import 'package:maamaaspartner/user_module/API/food_authservice.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import '../../Models/address_model.dart';
import '../../Models/coupon_model.dart';
import '../../Models/food/cart_model.dart';
import '../../widgets/skeleton/cart_skeleton.dart';
import '../addressmodel_provider.dart';
import '../cart wallet.dart';
import '../ordertypebutton.dart';
import '../saved_address.dart';
import 'food_invoice.dart';
import '../../Models/wallet_model.dart';
import 'menu_screen.dart';

class food_cartScreen extends ConsumerStatefulWidget {
  final int? vendorId;
  final int? cartId;
  final double? savedAmount;
  final bool showSavedPopup;

  const food_cartScreen({
    super.key,
    this.vendorId,
    this.cartId,
    this.savedAmount,
    this.showSavedPopup = false,
  });

  @override
  ConsumerState<food_cartScreen> createState() => _food_cartScreenState();
}

class _food_cartScreenState extends ConsumerState<food_cartScreen> {
  CartModel? cartData;
  bool isLoading = true;
  bool isPlacingOrder = false;
  Map<String, dynamic>? checkoutData;
  bool couponApplied = false;
  String selectedPaymentMethod = "";
  String? selectedSubWallet = "";
  String couponCode = "";
  bool isServiceChargeApplied = true;
  bool isExpanded = false;
  late Razorpay _razorpay;
  Wallet? wallet;
  int? appliedCouponId;
  String? appliedCouponCode;
  late CartModel? updatedCartData = cartData;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _email;
  String? _mobile;
  late ScrollController _scrollController;
  Razorpay? razorpay;

  String _orderType = "now";
  bool _isPlacingOrder = false;
  // Address? selectedAddress;
  List<Address> addressList = [];
  bool hasUserSelectedOrderType = false;
  bool isCouponLoading = false;
  Set<String> selectedSubWallets = {};
  Map<String, double> subWalletAmounts = {};

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    _loadWallet();
    _loadUserProfile();
    _loadCart();
  }

  @override
  void dispose() {
    _razorpay.clear();
    _scrollController.dispose();
    super.dispose();
  }

  void _showSavedAmountFlash(double amount) {
    final overlay = Overlay.of(context);

    // Create a controller for the animation
    final animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: overlay, // Using overlay as the vsync
    );

    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 20, // Below status bar
        left: 20,
        right: 20,
        child: SlideTransition(
          position:
              Tween<Offset>(
                begin: const Offset(0, -1.5),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(
                  parent: animationController,
                  curve: Curves.elasticOut,
                ),
              ),
          child: FadeTransition(
            opacity: animationController,
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 24,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.green.shade600, Colors.green.shade400],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      // ignore: deprecated_member_use
                      color: Colors.green.shade800.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                    BoxShadow(
                      // ignore: deprecated_member_use
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  border: Border.all(
                    // ignore: deprecated_member_use
                    color: Colors.green.shade200.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        // ignore: deprecated_member_use
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Text("🎉", style: TextStyle(fontSize: 20)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Savings unlocked!",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              height: 1.2,
                            ),
                          ),
                          Text(
                            "₹${amount.toStringAsFixed(2)} saved",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        // ignore: deprecated_member_use
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.celebration,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    // Start the animation
    animationController.forward();

    // Remove after animation completes
    Future.delayed(const Duration(milliseconds: 2500)).then((_) {
      animationController.reverse().then((_) {
        overlayEntry.remove();
        animationController.dispose();
      });
    });
  }

  Future<void> _loadWallet() async {
    try {
      final fetchedWallet = await AuthService.fetchWallet(); // API call
      if (!mounted) return; // safety
      setState(() {
        wallet = fetchedWallet;
      });
    } catch (e) {
      // debugPrint("⚠️ _loadWallet failed: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Failed to load wallet"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    final paymentId = response.paymentId!;
    final razorpayOrderId = response.orderId!;
    const paymentMethod = "Online_Payment";

    final bool isScheduled = _selectedDate != null || _selectedTime != null;

    bool orderPlaced = false;

    // 1️⃣ Place order first
    if (isScheduled) {
      orderPlaced = await _placeScheduledOrder(
        // userId: userId,
        paymentMethod: paymentMethod,
        razorpayPaymentId: paymentId,
        razorpayOrderId: razorpayOrderId,
        amount: cartData!.grandTotal.toDouble(),
      );
    } else {
      orderPlaced = await _placeDirectOrder(
        // userId: userId,
        paymentMethod: paymentMethod,
        razorpayPaymentId: paymentId,
        razorpayOrderId: razorpayOrderId,
        amount: cartData!.grandTotal.toDouble(),
      );
    }

    // 2️⃣ Capture only if order placed
    if (orderPlaced) {
      final captured = await food_Authservice.capturePayment(
        paymentId: paymentId,
        amount: (cartData?.grandTotal ?? 0).toDouble(),
      );

      if (!captured) {
        _showRefundSnackBar();
      }
    } else {
      _showRefundSnackBar();
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // debugPrint("❌ Payment Failed: ${response.code} - ${response.message}");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Payment failed: ${response.message}")),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // debugPrint("👜 External Wallet: ${response.walletName}");
  }

  List<String> mapWalletsToEnum(List<String> selectedWallets) {
    return selectedWallets.map((wallet) {
      switch (wallet) {
        case "Cashbacks":
          return "CASHBACK";
        case "Self Loaded":
          return "SELF_LOADED";
        case "Postpaid used amount":
          return "POST_PAID";
        case "Company Loaded":
          return "COMPANY_LOADED";
        case "Earned Amount":
          return "EARNED_AMOUNT";
        default:
          return wallet.toUpperCase().replaceAll(' ', '_');
      }
    }).toList();
  }

  Future<void> _loadUserProfile() async {
    final profile = await AuthService.fetchUserProfileData();
    if (profile != null) {
      setState(() {
        _email = profile.emailId;
        _mobile = profile.mobileNumber;
      });
    }
  }

  Future<void> _loadCart() async {
    setState(() => isLoading = true);

    try {
      final fetchedCart = await food_Authservice.fetchCart();

      if (mounted) {
        setState(() {
          cartData = fetchedCart;

          // Update coupon code from backend
          appliedCouponCode = fetchedCart?.couponCode ?? null;

          isLoading = false;
        });
      }
      if (widget.showSavedPopup == true &&
          cartData?.savedAmount != null &&
          cartData!.savedAmount > 0) {
        // WidgetsBinding.instance.addPostFrameCallback((_) {
        //   _showSavedAmountFlash((cartData!.savedAmount).toDouble());
        // });
      }

      // debugPrint("✅ Cart reloaded, coupon: $appliedCouponCode");
    } catch (e) {
      // debugPrint("❌ Error loading cart: $e");
      if (mounted) setState(() => isLoading = false);
    }
  }

  bool _hasOutOfStockItems() {
    if (cartData == null) return false;

    return cartData!.cartItems.any((item) => item.available == false);
  }

  double getSelectedWalletBalance() {
    if (wallet == null) return 0;

    double total = 0;

    if (selectedSubWallets.contains("Company Loaded")) {
      total += wallet!.companyLoadedAmount;
    }
    if (selectedSubWallets.contains("Self Loaded")) {
      total += wallet!.selfLoadedAmount;
    }
    if (selectedSubWallets.contains("Cashbacks")) {
      total += wallet!.cashbackAmount;
    }
    if (selectedSubWallets.contains("Postpaid used amount")) {
      total += wallet!.postPaidUsage;
    }

    return total;
  }

  Future<void> placeOrder() async {
    // if (_hasOutOfStockItems()) {
    //   _showError(
    //     "Some items are out of stock.\nPlease remove them before placing order.",
    //   );
    //   return;
    // }

    /// 1️⃣ DELIVERY ADDRESS CHECK
    if ((cartData?.orderType ?? '').trim().toLowerCase() == 'delivery') {
      final hasDeliveryAddress = (cartData?.deliveryAddress ?? '')
          .trim()
          .isNotEmpty;

      if (!hasDeliveryAddress) {
        _showError("⚠️ Please select delivery address");
        return;
      }
    }

    if (selectedPaymentMethod == "Maamaas_Wallet") {
      final walletAmount =
          getSelectedWalletBalance(); // 👈 ensure this is accessible
      final grandTotal = (cartData?.grandTotal ?? 0).toDouble();

      if (walletAmount < grandTotal) {
        _showError(
          "❌ Insufficient wallet balance\n"
          "Wallet: ₹${walletAmount.toStringAsFixed(2)}\n"
          "Order Total: ₹${grandTotal.toStringAsFixed(2)}",
        );
        return;
      }
    }

    /// 2️⃣ PAYMENT METHOD CHECK
    if (selectedPaymentMethod.isEmpty) {
      _showError("⚠️ Please select a payment method");
      return;
    }

    /// 4️⃣ NOW SAFE TO PROCEED
    setState(() => isPlacingOrder = true);

    try {
      final bool isScheduled = _selectedDate != null || _selectedTime != null;

      /// 🔵 ONLINE PAYMENT
      if (selectedPaymentMethod == "Online_Payment") {
        final amount = (cartData?.grandTotal ?? 0).toDouble();

        final orderId = await food_Authservice.createOrder(amount);
        if (orderId == null) {
          _showError("❌ Failed to create payment order");
          return;
        }

        _openRazorpayCheckout(amount, orderId);
        return;
      }

      /// 🟣 WALLET / COD / OTHER PAYMENTS
      if (isScheduled) {
        await _placeScheduledOrder(
          // userId: userId,
          paymentMethod: selectedPaymentMethod,
          razorpayPaymentId: "",
          razorpayOrderId: "",
          // walletTypes: walletTypes,
          amount: cartData!.grandTotal.toDouble(),
        );
      } else {
        await _placeDirectOrder(
          // userId: userId,
          paymentMethod: selectedPaymentMethod,
          razorpayPaymentId: "",
          razorpayOrderId: "",
          // walletType: walletType,
          amount: cartData!.grandTotal.toDouble(),
        );
      }
    } catch (e) {
      // debugPrint("❌ Error in placeOrder: $e");
      // debugPrint("📌 Stacktrace: $stack");
      _showError("Error placing order");
    } finally {
      setState(() => isPlacingOrder = false);
    }
  }

  double getCartGrandTotal() {
    return cartData!.grandTotal.toDouble();
  }

  void _showError(String message) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (_) {
        return Container(
          margin: EdgeInsets.all(16.w),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.red.shade600,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.white,
                size: 24.sp,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    // ⏱ Auto close after 5 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    });
  }

  void _openRazorpayCheckout(double amount, String orderId) {
    var options = {
      // 'key': 'rzp_test_TJECsclCivENpY',
      'key': 'rzp_test_TJECsclCivENpY',
      'order_id': orderId,
      'amount': (amount * 100).toInt(), // Razorpay expects amount in paise
      'name': 'Order Payment',
      'description': 'Online Payment via Razorpay',
      'prefill': {
        'contact': _mobile ?? "9999999999",
        'email': _email ?? "customer@email.com",
      },
      'theme': {'color': '#3399cc'},
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      // debugPrint('⚠️ Razorpay Open Error: $e');
    }
  }

  Future<bool> _placeScheduledOrder({
    // required int userId,
    required String paymentMethod,
    required String razorpayPaymentId,
    required String razorpayOrderId,
    required double amount,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final cartId = prefs.getInt('cartId');

    if (cartId == null) return false;

    final dateToSend = _selectedDate ?? DateTime.now();
    final timeToSend = _selectedTime ?? TimeOfDay.now();

    final result = await food_Authservice.scheduleOrder(
      // userId: userId,
      cartId: cartId,
      date: dateToSend,
      time: timeToSend,
      paymentMethod: paymentMethod,
      razorpayPaymentId: razorpayPaymentId,
      razorpayOrderId: razorpayOrderId,

      // ✅ MULTI WALLET TYPES
      walletTypes: mapWalletsToEnum(selectedSubWallets.toList()), // <-- FIXED
      // ✅ GRAND TOTAL FROM CART
      amount: amount,
    );

    if (result != null && result.containsKey('orderId')) {
      final orderId = result['orderId'];
      await prefs.setInt('orderId', orderId);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => food_Invoice(orderId: orderId)),
      );
      return true;
    }

    return false;
  }

  Future<bool> _placeDirectOrder({
    // required int userId,
    required String paymentMethod,
    required String razorpayPaymentId,
    required String razorpayOrderId,
    // String? walletType,
    required double amount,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final cartId = prefs.getInt('cartId');

    if (cartId == null) return false;

    final result = await food_Authservice.placeDirectOrder(
      // userId: userId,
      cartId: cartId,
      paymentMethod: paymentMethod,
      razorpayPaymentId: razorpayPaymentId,
      razorpayOrderId: razorpayOrderId,
      walletTypes: mapWalletsToEnum(selectedSubWallets.toList()), // <-- FIXED
      amount: amount,
    );

    if (result != null && result.containsKey('orderId')) {
      final orderId = result['orderId'];
      await prefs.setInt('orderId', orderId);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => food_Invoice(orderId: orderId)),
      );
      return true;
    }

    return false;
  }

  void _showRefundSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.red,
        duration: Duration(seconds: 5),
        content: Text(
          "❌ Order failed. If any amount was debited, it will be refunded within 3–5 working days.",
        ),
      ),
    );
  }

  Future<void> changeQuantity(CartItem item, int newQuantity) async {
    if (cartData == null || cartData!.cartId == 0) {
      await _loadCart();
      if (cartData == null || cartData!.cartId == 0) return;
    }

    final oldQuantity = item.quantity;

    setState(() {
      isLoading = true;
    });

    bool success = false;

    if (newQuantity < 1) {
      success = await food_Authservice.removeCartItem(item.itemId);
    } else {
      success = await food_Authservice.updateCartQuantity(
        // cartData!.cartId,
        item.itemId,
        newQuantity,
      );
    }

    if (success) {
      await _loadCart();
    } else {
      setState(() {
        item.quantity = oldQuantity;
        item.totalPrice = item.price * oldQuantity;
        isLoading = false;
      });
    }
  }

  Future<void> _onRefresh() async {
    final updatedCart = await food_Authservice.fetchCart();
    final updatedwallet = await AuthService.fetchWallet();

    if (!mounted) return;

    setState(() {
      cartData = updatedCart;
      wallet = updatedwallet;
    });
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: SafeArea(
              bottom: false,
              child: AppBar(
                title: const Text("Review Your cart"),
                centerTitle: true,
                backgroundColor: Colors.white,
                actions: [_buildClearCart(Icons.clear)],
              ),
            ),
          ),
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: _onRefresh,
              color: Colors.white,
              backgroundColor: Colors.blueAccent,
              displacement: 40,
              strokeWidth: 3,

              child: isLoading
                  // ✅ LOADING STATE (NO CONTROLLER)
                  ? SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 8.h,
                      ),
                      child: const CartSkeleton(
                        type: CartSkeletonType.fullCart,
                      ),
                    )
                  // ✅ CONTENT STATE
                  : SingleChildScrollView(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 8.h,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (cartData == null || cartData!.cartItems.isEmpty)
                            _buildEmptyCart(context)
                          else ...[
                            _buildCartItems(theme, colorScheme),
                            SizedBox(height: 12.h),
                            _buildaddmoretext(),
                            SizedBox(height: 12.h),

                            OrderCartFooter(
                              onOrderTypeChanged: () async {
                                final updatedCart = await food_Authservice
                                    .fetchCart();

                                setState(() {
                                  cartData = updatedCart;
                                });
                              },
                            ),

                            SizedBox(height: 12.h),
                            _buildCouponRow(theme, colorScheme),
                            SizedBox(height: 10.h),

                            if ((cartData?.orderType ?? '')
                                    .trim()
                                    .toLowerCase() ==
                                'delivery')
                              _buildDeliveryAddress(),

                            SizedBox(height: 5.h),
                            _buildsummaryCard(theme, colorScheme),
                            SizedBox(height: 12.h),
                            _buildScheduleOrder(),
                            SizedBox(height: 12.h),
                            _buildCheckoutCard(),

                            if (isExpanded)
                              _buildCheckoutDetails(theme, colorScheme),
                          ],
                        ],
                      ),
                    ),
            ),
          ),

          // bottomNavigationBar: food_foooter(),
        ),

        // // 🔥 FULL SCREEN LOADER
        // if (_isPlacingOrder)
        //   Positioned.fill(
        //     child: AbsorbPointer(
        //       absorbing: true,
        //       child: Container(
        //         // ignore: deprecated_member_use
        //         color: Colors.black.withOpacity(0.4),
        //         child: const Center(child: CircularProgressIndicator()),
        //       ),
        //     ),
        //   ),
        // if (_isPlacingOrder)
        if (_isPlacingOrder)
          Positioned.fill(
            child: AbsorbPointer(
              absorbing: true,
              child: Container(
                // ignore: deprecated_member_use
                color: Colors.black.withOpacity(0.4),
                child: Center(
                  child: Lottie.asset(
                    'assets/animations/placing_order.json', // Your animation file
                    width: 150,
                    height: 150,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildaddmoretext() {
    return Center(
      child: RichText(
        text: TextSpan(
          text: "Missed Something? ",
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          children: [
            TextSpan(
              text: "Add more items",
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: Colors.blue, // Highlight clickable text
                decoration: TextDecoration.underline, // Underline effect
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MenuScreen(vendorId: cartData!.vendorId),
                    ),
                  );
                },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCouponRow(ThemeData theme, ColorScheme colorScheme) {
    final bool isCouponApplied =
        appliedCouponCode != null && appliedCouponCode!.isNotEmpty;

    return GestureDetector(
      onTap: () {
        if (!isCouponApplied) {
          _showCouponBottomSheet();
        }
      },
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.local_offer_outlined,
                  size: 20.sp,
                  color: isCouponApplied
                      ? colorScheme.primary
                      : Colors.grey.shade600,
                ),
                SizedBox(width: 12.w),
                Text(
                  isCouponApplied ? appliedCouponCode! : "Apply Coupon",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: isCouponApplied
                        ? colorScheme.primary
                        : Colors.grey.shade800,
                  ),
                ),
              ],
            ),

            // REMOVE BUTTON
            if (isCouponApplied)
              GestureDetector(
                onTap: () async {
                  final messenger = ScaffoldMessenger.of(context);

                  if (cartData?.cartId == null) {
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text("Invalid cart"),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  try {
                    // ✅ REMOVE COUPON → SEND 0
                    final result = await food_Authservice.updateCartSettings(
                      cartId: cartData!.cartId,
                      couponId: cartData!.couponId, // 🔥 IMPORTANT
                      applyCoupon: "NOT_APPLIED",
                    );

                    if (!result.success) {
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text("Failed to remove coupon."),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    // Reload server cart FIRST
                    await _loadCart();

                    // Sync UI AFTER server success
                    setState(() {
                      appliedCouponCode = null;
                      appliedCouponId = null;
                    });

                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text("Coupon removed successfully"),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                    // debugPrint("Coupon remove error: $e");
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text("Network error. Try again."),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: Text(
                  "Remove",
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            else
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16.sp,
                color: Colors.grey.shade600,
              ),
          ],
        ),
      ),
    );
  }

  void _showCouponBottomSheet() async {
    setState(() => isCouponLoading = true);
    final List<CouponModel> coupons = await AuthService.fetchCoupons();

    final int? cartVendor = cartData?.vendorId;

    setState(() => isCouponLoading = false);

    coupons.sort((a, b) {
      final aExpired = a.isExpired;
      final bExpired = b.isExpired;

      final aMismatch = !a.isApplicableForVendor(cartVendor);
      final bMismatch = !b.isApplicableForVendor(cartVendor);

      if (aExpired != bExpired) return aExpired ? 1 : -1;
      if (aMismatch != bMismatch) return aMismatch ? 1 : -1;
      return 0;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        if (coupons.isEmpty) {
          return _emptyCouponView();
        }

        return Scaffold(
          // ✅ ADD THIS
          backgroundColor: Colors.transparent,
          body: SafeArea(
            top: false,
            child: Container(
              height: MediaQuery.of(sheetContext).size.height * 1,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  _couponHeader(),
                  Expanded(
                    child: isCouponLoading
                        ? CartSkeleton(type: CartSkeletonType.coupons)
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: coupons.length,
                            itemBuilder: (context, index) {
                              final coupon = coupons[index];

                              final bool isExpired = coupon.isExpired;
                              final bool isMismatch = !coupon
                                  .isApplicableForVendor(cartVendor);

                              return _couponTile(
                                coupon: coupon,
                                isExpired: isExpired,
                                isMismatch: isMismatch,
                                isDisabled: isExpired || isMismatch,
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _couponTile({
    required CouponModel coupon,
    required bool isExpired,
    required bool isMismatch,
    required bool isDisabled,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: isExpired
              // ignore: deprecated_member_use
              ? Colors.red.withOpacity(0.4)
              : isMismatch
              // ignore: deprecated_member_use
              ? Colors.orange.withOpacity(0.4)
              // ignore: deprecated_member_use
              : Colors.green.withOpacity(0.4),
        ),
      ),
      child: ListTile(
        leading: Icon(
          Icons.local_offer,
          color: isExpired
              ? Colors.red
              : isMismatch
              ? Colors.orange
              : Colors.green,
        ),

        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: coupon.couponType == "PERCENTAGE"
                    // ignore: deprecated_member_use
                    ? Colors.blue.withOpacity(0.1)
                    // ignore: deprecated_member_use
                    : Colors.purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                coupon.couponType,

                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: coupon.couponType == "PERCENTAGE"
                      ? Colors.blue
                      : Colors.purple,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              coupon.code,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isExpired ? Colors.red : Colors.black,
              ),
            ),

            /// COUPON TYPE BADGE
          ],
        ),

        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isExpired
                  ? "Expired"
                  : isMismatch
                  ? "Not applicable for this restaurant"
                  : coupon.discountType == "PERCENTAGE"
                  ? "Get ${coupon.discountPercentage.toStringAsFixed(0)}% off"
                  : "Get ₹${coupon.discountPercentage.toStringAsFixed(0)} off",
              style: TextStyle(
                color: isExpired
                    ? Colors.red
                    : isMismatch
                    ? Colors.orange
                    : Colors.black,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              coupon.minimumOrderValue <= 0
                  ? "Applicable on any order"
                  : "Min order ₹${coupon.minimumOrderValue.toInt()}",
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ],
        ),

        trailing: isDisabled
            ? Icon(Icons.block, color: isExpired ? Colors.red : Colors.orange)
            : const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.green,
              ),

        onTap: isDisabled
            ? () => _showCouponError(isExpired)
            : () => _applyCoupon(coupon),
      ),
    );
  }

  void _showCouponError(bool isExpired) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isExpired
              ? "This coupon has expired"
              : "This coupon is not applicable for this restaurant",
        ),
        backgroundColor: isExpired ? Colors.red : Colors.orange,
      ),
    );
  }

  Widget _emptyCouponView() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.3,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.confirmation_number_outlined,
              size: 50,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              "No coupons available",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Check back later for new offers",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _couponHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Available Coupons",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Future<void> _applyCoupon(CouponModel coupon) async {
    final messenger = ScaffoldMessenger.of(context);

    if (cartData?.cartId == null) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text("Cart is empty"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final result = await food_Authservice.updateCartSettings(
      cartId: cartData!.cartId,
      couponId: coupon.id,
      applyCoupon: "APPLIED",
    );

    if (!result.success) {
      messenger.showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red.shade600,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  result.error ?? "Failed to apply coupon",
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      );
      return;
    }

    await _loadCart();

    setState(() {
      appliedCouponCode = coupon.code;
      appliedCouponId = coupon.id;
    });

    messenger.showSnackBar(
      SnackBar(
        content: Text("Coupon ${coupon.code} applied!"),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context);
  }

  Widget _buildClearCart(IconData icon) {
    return CircleAvatar(
      radius: 22,
      backgroundColor: Colors.grey.shade300,
      child: IconButton(
        icon: Icon(icon, size: 22, color: Colors.black),
        onPressed: () async {
          final success = await food_Authservice.deleteCart();
          if (success) {
            Navigator.of(context).popUntil((route) => route.isFirst);
            setState(() {
              cartData?.cartItems.clear();
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Cart cleared successfully")),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Failed to clear cart")),
            );
          }
        },
      ),
    );
  }

  Future<void> _removeItem(CartItem item) async {
    final bool success = await food_Authservice.removeCartItem(item.itemId);

    if (!success) {
      // ❌ API failed → show error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to remove item. Please try again."),
        ),
      );
      return;
    }

    // ✅ API success → update UI
    setState(() {
      cartData!.cartItems.remove(item);
    });

    // Optional success feedback
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Item removed from cart"),
        duration: Duration(seconds: 1),
      ),
    );
  }

  Widget _buildCartItems(ThemeData theme, ColorScheme colorScheme) {
    // if (isLoading) {
    //   return const Center(child: CircularProgressIndicator());
    // }
    if (isLoading) {
      return CartSkeleton(type: CartSkeletonType.items);
    }
    if (cartData == null || cartData!.cartItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      shadowColor: Colors.black,
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          children: cartData!.cartItems.map((item) {
            final bool isOutOfStock = item.available == false;

            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: Stack(
                    children: [
                      // MAIN CONTENT
                      // Opacity(
                      // opacity: isOutOfStock ? 0.5 : 1,
                      // child:
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Image
                          // Container(
                          //   width: 80.w,
                          //   height: 80.w,
                          //   decoration: BoxDecoration(
                          //     borderRadius: BorderRadius.circular(12.r),
                          //     color: Colors.grey[100],
                          //     boxShadow: const [
                          //       BoxShadow(
                          //         color: Colors.black12,
                          //         blurRadius: 4,
                          //         offset: Offset(0, 2),
                          //       ),
                          //     ],
                          //   ),
                          //   child: Stack(
                          //     children: [
                          //       /// 🖼️ Image
                          //       ClipRRect(
                          //         borderRadius: BorderRadius.circular(12.r),
                          //         child: _buildDishImage(item.dishImage),
                          //       ),
                          //
                          //       /// 🚫 Out of Stock Overlay
                          //       if (isOutOfStock)
                          //         Positioned.fill(
                          //           child: Container(
                          //             decoration: BoxDecoration(
                          //               color: Colors.black.withOpacity(0.55),
                          //               borderRadius: BorderRadius.circular(
                          //                 12.r,
                          //               ),
                          //             ),
                          //             child: const Center(
                          //               child: Text(
                          //                 "Out of Stock",
                          //                 textAlign: TextAlign.center,
                          //                 style: TextStyle(
                          //                   color: Colors.white,
                          //                   fontSize: 12,
                          //                   fontWeight: FontWeight.bold,
                          //                 ),
                          //               ),
                          //             ),
                          //           ),
                          //         ),
                          //     ],
                          //   ),
                          // ),
                          //
                          // SizedBox(width: 12.w),

                          // Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item.dishName,
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8.w,
                                        vertical: 4.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(
                                          8.r,
                                        ),
                                      ),
                                      child: Text(
                                        "₹${item.price}",
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: 6.h),

                                Row(
                                  children: [
                                    // isOutOfStock
                                    //     ? Text(
                                    //         "Out of Stock",
                                    //         style: TextStyle(
                                    //           fontSize: 14.sp,
                                    //           fontWeight: FontWeight.w600,
                                    //           color: Colors.red,
                                    //         ),
                                    //       )
                                    //     :
                                    _buildQuantityControl(item),

                                    const Spacer(),

                                    Text(
                                      "₹${item.totalPrice}",
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      // ),

                      // ❌ REMOVE BUTTON (ONLY IF OUT OF STOCK)
                      // if (isOutOfStock)
                      //   Positioned(
                      //     top: 0,
                      //     right: 0,
                      //     child: GestureDetector(
                      //       onTap: () => _removeItem(item),
                      //       child: Container(
                      //         padding: EdgeInsets.all(6.r),
                      //         decoration: BoxDecoration(
                      //           // ignore: deprecated_member_use
                      //           color: Colors.red.withOpacity(0.9),
                      //           // shape: BoxShape.circle,
                      //           boxShadow: const [
                      //             BoxShadow(
                      //               color: Colors.black26,
                      //               blurRadius: 4,
                      //               offset: Offset(0, 2),
                      //             ),
                      //           ],
                      //         ),
                      //         child: Row(
                      //           children: [
                      //             Icon(
                      //               Icons.close,
                      //               size: 16.sp,
                      //               color: Colors.white,
                      //             ),
                      //             Text(
                      //               "Remove",
                      //               style: TextStyle(color: Colors.white),
                      //             ),
                      //           ],
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                    ],
                  ),
                ),

                if (item != cartData!.cartItems.last)
                  Divider(height: 1, thickness: 0.5, color: Colors.grey[300]),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 64.sp,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16.h),

          Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8.h),

          Text(
            'Add some delicious items',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[500]),
          ),
          SizedBox(height: 24.h),

          SizedBox(
            width: 180.w,
            height: 44.h,
            child: ElevatedButton(
              onPressed: () {
                // 🔁 Go back to home / menu screen
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6D5BFF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                elevation: 2,
              ),
              child: Text(
                'Add Items',
                style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityControl(CartItem item) {
    final bool isOutOfStock = item.available == false;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFB15DC6), width: 2),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildQtyButton(
            icon: Icons.remove,
            onTap: () => changeQuantity(item, item.quantity - 1),
            color: Colors.redAccent,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: Text(
              "${item.quantity}",
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          _buildQtyButton(
            icon: Icons.add,
            onTap:
                // isOutOfStock
                //     ? null
                //     :
                () => changeQuantity(item, item.quantity + 1),
            color:
                // isOutOfStock ? Colors.grey :
                Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildQtyButton({
    required IconData icon,
    required VoidCallback? onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: onTap == null ? 0.4 : 1,
        child: Container(
          padding: EdgeInsets.all(6.w),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            // ignore: deprecated_member_use
            color: color.withOpacity(0.15),
          ),
          child: Icon(icon, color: color, size: 16.sp),
        ),
      ),
    );
  }

  Widget _buildDishImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return const Icon(Icons.fastfood, size: 40, color: Colors.grey);
    }

    // debugPrint("🖼️ Loading MinIO image: $imageUrl");

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        // debugPrint("❌ Failed to load image: $error");
        return const Icon(Icons.broken_image, size: 40, color: Colors.red);
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(color: Colors.white),
        );
      },
    );
  }

  Widget _buildCheckoutCard() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: EdgeInsets.only(bottom: 12.h),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            isExpanded = !isExpanded;
          });

          // Scroll to bottom AFTER UI rebuild
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (isExpanded) {
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOut,
              );
            }
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFB15DC6),
          padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          elevation: 3,
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) =>
              FadeTransition(opacity: animation, child: child),
          child: isExpanded
              ? Text(
                  'Hide payment options',
                  key: const ValueKey(1),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                )
              : Text(
                  'Show payment options',
                  key: const ValueKey(2),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildCheckoutDetails(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      children: [
        // _buildPaymentSection(theme, colorScheme),
        cartwallet(
          wallet: wallet,
          onSelectionChanged: (method, subWallets) {
            setState(() {
              selectedPaymentMethod = method;
              selectedSubWallets = subWallets;
            });

            debugPrint("Payment: $selectedPaymentMethod");
            debugPrint("Sub-wallets: $selectedSubWallets");
          },
        ),
        SizedBox(height: 16.h),
        _buildPlaceOrderButton(theme, colorScheme),
      ],
    );
  }

  Widget _buildTotalRow(String label, num value, {bool isBold = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isBold ? Colors.black87 : Colors.grey[700],
            ),
          ),
          Text(
            '₹ ${_fmt(value)}',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isBold ? Theme.of(context).primaryColor : Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscountSaved(
    String label,
    num oldValue,
    num newValue, {
    bool showActualPrice = true, // 👈 control flag
    bool isBold = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Label
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isBold ? Colors.black87 : Colors.grey[700],
            ),
          ),

          // Price Section
          Row(
            children: [
              // Old price (only if true)
              if (showActualPrice) ...[
                Text(
                  "₹${_fmt(oldValue)}",
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.red,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                SizedBox(width: 6.w),
              ],

              // New price
              Text(
                "₹${_fmt(newValue)}",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                  color: isBold
                      ? Theme.of(context).primaryColor
                      : Colors.grey[700],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _builddiscountRow(String label, num value, {bool isBold = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isBold ? Colors.black87 : Colors.grey[700],
            ),
          ),
          Text(
            "-₹$value",
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isBold ? Theme.of(context).primaryColor : Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedAmountCard() {
    if (cartData?.savedAmount == null || cartData!.savedAmount <= 0) {
      return SizedBox.shrink(); // don't show if nothing saved
    }

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      color: Colors.green.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
        child: Row(
          children: [
            Icon(Icons.savings, color: Colors.green, size: 22.sp),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                "🎉 You saved ₹${cartData!.savedAmount.toStringAsFixed(2)}",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -----------------------------
  // Delivery Address Widget
  // -----------------------------

  Widget _buildDeliveryAddress() {
    final addressState = ref.watch(addressProvider);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SavedAddress(
              hideExtraWidgets: true,
              onAddressSelected: (city, pincode, state, lat, lng, addressId) async {
                debugPrint(
                  "🌟 Address selected: $city, $state, $pincode, id=$addressId",
                );

                // 1️⃣ Update local provider
                await ref
                    .read(addressProvider.notifier)
                    .updateLocalAddress(
                      city: city,
                      stateName: state,
                      pincode: pincode,
                      latitude: lat,
                      longitude: lng,
                    );

                debugPrint("🌟 Provider updated: ${ref.read(addressProvider)}");

                // 2️⃣ Update cart delivery address API
                // ignore: unnecessary_null_comparison
                if (cartData!.cartId != null && addressId != 0) {
                  debugPrint(
                    "🌟 Calling API to update cart delivery address...",
                  );

                  final success = await AddressNotifier.updateDeliveryAddress(
                    cartId: cartData!.cartId,
                    addressId: addressId,
                  );

                  if (success && mounted) {
                    // 🔥 REFRESH CART IMMEDIATELY
                    final updatedCart = await food_Authservice.fetchCart();

                    if (mounted) {
                      setState(() {
                        cartData = updatedCart;
                      });
                    }
                  } else if (!success && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Failed to update cart address"),
                      ),
                    );
                  }
                } else {}
              },
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          // border: Border.all(color: Colors.grey.shade300),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.location_on, color: Colors.red),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// ✅ SHOW ONLY IF ADDRESS EXISTS
                  if ((cartData?.deliveryAddress ?? '').trim().isNotEmpty) ...[
                    Text(
                      [
                        cartData!.deliveryAddress,
                        cartData!.name,
                        cartData!.mobileNo,
                      ].where((e) => e.toString().trim().isNotEmpty).join(", "),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        // fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Change location",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ] else
                    const Text(
                      "Select delivery address",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ),
            const Icon(Icons.keyboard_arrow_down),
          ],
        ),
      ),
    );
  }

  String _fmt(num? value) => (value ?? 0).toStringAsFixed(2);
  bool _isSummaryExpanded = false;

  Widget _buildsummaryCard(ThemeData theme, ColorScheme colorScheme) {
    if (cartData == null || isLoading) {
      return CartSkeleton(type: CartSkeletonType.summary);
    }

    final orderType = cartData?.orderType ?? "DINE_IN";
    final subtotal = cartData?.subtotal ?? 0;
    final packingTotal = cartData?.packingTotal ?? 0;
    final deliveryCharges = cartData?.deliveryCharges ?? 0;
    final platformCharges = cartData?.platformCharges ?? 0;
    final discountAmount = cartData?.discountAmount ?? 0;
    final gstTotal = cartData?.gstTotal ?? 0;
    final grandTotal = cartData?.grandTotal ?? 0;
    final savedamount = cartData?.savedAmount ?? 0;

    final actualTotalAmount = double.parse(
      (savedamount + subtotal).toStringAsFixed(2),
    );

    final actualGrandTotalAmount = double.parse(
      (savedamount + grandTotal).toStringAsFixed(2),
    );

    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      shadowColor: Colors.black,
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔽 Header with dropdown icon
            InkWell(
              onTap: () {
                setState(() {
                  _isSummaryExpanded = !_isSummaryExpanded;
                });
              },
              child: Row(
                children: [
                  Icon(
                    Icons.receipt_outlined,
                    color: colorScheme.primary,
                    size: 22,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'Order Summary',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _isSummaryExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.keyboard_arrow_down),
                  ),
                ],
              ),
            ),

            /// 🔹 Expanded section (ALL charges EXCEPT grand total)
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 250),
              crossFadeState: _isSummaryExpanded
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              firstChild: Column(
                children: [
                  const Divider(thickness: 1),
                  _buildDiscountSaved(
                    "Sub Total",
                    actualTotalAmount,
                    subtotal,
                    showActualPrice: false,
                  ),

                  _buildTotalRow("Platform Charges", platformCharges),

                  if (orderType == "DELIVERY" || orderType == "TAKEAWAY")
                    _buildTotalRow("Packing Charges", packingTotal),

                  if (orderType == "DELIVERY")
                    _buildTotalRow("Delivery Charges", deliveryCharges),

                  if (discountAmount > 0)
                    _builddiscountRow("Discount Amount", discountAmount),

                  _buildTotalRow("SGST", gstTotal / 2),
                  _buildTotalRow("CGST", gstTotal / 2),

                  SizedBox(height: 8.h),
                ],
              ),
              secondChild: const SizedBox.shrink(),
            ),

            const Divider(thickness: 1),

            /// 💰 Grand Total (ALWAYS visible)
            _buildDiscountSaved(
              "Grand Total",
              actualGrandTotalAmount,
              grandTotal,
              isBold: true,
              showActualPrice: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceChargesRow(ThemeData theme, ColorScheme colorScheme) {
    final serviceCharges = cartData?.serviceCharges ?? 0.0;
    return Container(
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: colorScheme.surfaceContainerHighest.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Service Charges",
            style: theme.textTheme.bodyMedium?.copyWith(
              // ignore: deprecated_member_use
              color: colorScheme.onSurface.withOpacity(0.9),
            ),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () async {
                  final newState = !isServiceChargeApplied;
                  if (cartData?.cartId == null) return;

                  await food_Authservice.updateServiceCharges(
                    cartId: cartData!.cartId,
                    serviceCharge: isServiceChargeApplied
                        ? "NOT_APPLICABLE"
                        : "APPLICABLE",
                  );

                  setState(() {
                    isServiceChargeApplied = newState;
                  });

                  await _loadCart(); // ✅ no assignment needed
                },

                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: isServiceChargeApplied
                        ? colorScheme.errorContainer
                        : colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    isServiceChargeApplied ? "Remove" : "Apply",
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isServiceChargeApplied
                          ? colorScheme.onErrorContainer
                          : colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              SizedBox(width: 10.w),
              Text(
                isServiceChargeApplied
                    ? "₹${serviceCharges.toStringAsFixed(2)}"
                    : "-₹${serviceCharges.toStringAsFixed(2)}",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleOrder() {
    final bool showOrderNow = cartData!.cartItems.every(
      (item) => !item.shedule,
    );
    final bool isScheduled =
        _orderType == "schedule" &&
        _selectedDate != null &&
        _selectedTime != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (showOrderNow) ...[
              Radio<String>(
                value: "now",
                groupValue: _orderType,
                onChanged: (value) {
                  setState(() {
                    _orderType = value!;
                    _selectedDate = null;
                    _selectedTime = null;
                  });
                },
              ),
              const Text("Order Now", style: TextStyle(fontSize: 16)),
              const SizedBox(width: 20),
            ],

            Radio<String>(
              value: "schedule",
              // ignore: deprecated_member_use
              groupValue: _orderType,
              // ignore: deprecated_member_use
              onChanged: (value) async {
                setState(() {
                  _orderType = value!;
                  _selectedDate = null;
                  _selectedTime = null;
                });

                // 🔥 Open pickers immediately
                await _pickScheduleDateTime();
              },
            ),
            const Text("Schedule Order", style: TextStyle(fontSize: 16)),
          ],
        ),

        const SizedBox(height: 10),

        // 🔹 If "Schedule Order" selected, show pickers
        if (_orderType == "schedule")
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isScheduled)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        // ignore: deprecated_member_use
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                    border: Border.all(
                      color: Colors.green.shade300,
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Header + Edit Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "✅ Your order is scheduled for:",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),

                          /// ✏️ Edit Button
                          OutlinedButton.icon(
                            onPressed: () async {
                              await _pickScheduleDateTime();
                            },
                            // icon: const Icon(Icons.edit, size: 16),
                            label: const Text(
                              "Edit",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              side: BorderSide(color: Colors.blue),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      Text(
                        "📅 Date: ${_selectedDate!.day}-${_selectedDate!.month}-${_selectedDate!.year}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        "⏰ Time: ${_selectedTime!.format(context)}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
      ],
    );
  }

  Future<void> _pickScheduleDateTime() async {
    DateTime now = DateTime.now();
    DateTime firstAllowedDate = now.add(const Duration(minutes: 25));
    DateTime lastAllowedDate = now.add(const Duration(days: 365));

    /// 🎨 DATE PICKER WITH CUSTOM COLORS
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: firstAllowedDate,
      firstDate: firstAllowedDate,
      lastDate: lastAllowedDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFB15DC6), // header + selected date
              onPrimary: Colors.white, // text on header
              onSurface: Colors.black, // calendar text
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.black, // OK / CANCEL
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate == null) return;

    while (true) {
      /// 🎨 TIME PICKER WITH CUSTOM COLORS
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              timePickerTheme: TimePickerThemeData(
                backgroundColor: Colors.white,
                hourMinuteColor: WidgetStateColor.resolveWith(
                  (states) => states.contains(WidgetState.selected)
                      ? const Color(0xFFB15DC6)
                      : Colors.grey.shade200,
                ),
                hourMinuteTextColor: WidgetStateColor.resolveWith(
                  // ignore: deprecated_member_use
                  (states) => states.contains(MaterialState.selected)
                      ? Colors.white
                      : Colors.black,
                ),
                dialHandColor: const Color(0xFFB15DC6),
                dialBackgroundColor: Colors.grey.shade200,
                entryModeIconColor: Colors.black,
              ),
              colorScheme: const ColorScheme.light(
                // primary: Color(0xFFB15DC6),
                onPrimary: Colors.white,
                onSurface: Colors.black,
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(foregroundColor: Colors.black),
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime == null) return;

      final DateTime selectedDateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );

      /// ⛔ Block time less than 1.5 hours
      if (selectedDateTime.isBefore(now.add(const Duration(minutes: 25)))) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please select a time at least 25 minutes from now"),
            backgroundColor: Colors.red,
          ),
        );
        continue;
      }

      /// ✅ VALID
      setState(() {
        _selectedDate = pickedDate;
        _selectedTime = pickedTime;
      });
      break;
    }
  }

  Widget _buildPaymentSection(ThemeData theme, ColorScheme colorScheme) {
    // final orderType = cartData?.orderType ?? "DINE_IN";
    if (cartData == null || isLoading) {
      return CartSkeleton(type: CartSkeletonType.payment);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            _buildPaymentOption(
              "Maamaas_Wallet",
              Icons.account_balance_wallet_outlined,
              "Maamaas_Wallet",
              theme,
              colorScheme,
            ),
            if (selectedPaymentMethod == "Maamaas_Wallet" &&
                wallet != null) ...[
              SizedBox(height: 8.h),
              Padding(
                padding: EdgeInsets.only(left: 32.w),
                child: Column(
                  children: [
                    _buildSubWalletOption(
                      "Company Loaded",
                      wallet!.companyLoadedAmount,
                      theme,
                      colorScheme,
                    ),
                    _buildSubWalletselfloadedOption(
                      "Self Loaded",
                      wallet!.selfLoadedAmount,
                      theme,
                      colorScheme,
                      onAdd: () {
                        // if (razorpay == null) {
                        //   ScaffoldMessenger.of(context).showSnackBar(
                        //     const SnackBar(
                        //       content: Text("Payment service not ready ❌"),
                        //     ),
                        //   );
                        //   return;
                        // }

                        // WalletRechargeHelper.openRechargeSheet(
                        //   context: context,
                        //   razorpay: razorpay!, // now SAFE
                        //   isProfessional: true,
                        //   cashbackAmount: 100,
                        //   email: _email,
                        //   mobile: _mobile,
                        //   onSuccess: () async {},
                        // );
                      },
                    ),
                    _buildSubWalletOption(
                      "Cashbacks",
                      wallet!.cashbackAmount,
                      theme,
                      colorScheme,
                    ),
                    if ((cartData?.userCompany ?? '').isNotEmpty)
                      _buildSubWalletOption(
                        "Postpaid used amount",
                        wallet!.postPaidUsage,
                        theme,
                        colorScheme,
                      ),
                  ],
                ),
              ),
            ],
            _buildPaymentOption(
              "Online Payment",
              Icons.credit_card_outlined,
              "Online_Payment",
              theme,
              colorScheme,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentOption(
    String title,
    IconData icon,
    String value,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final isSelected = selectedPaymentMethod == value;
    return Card(
      elevation: 0,
      margin: EdgeInsets.only(bottom: 8.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(
          color: isSelected ? colorScheme.primary : Colors.grey.shade300,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      // ignore: deprecated_member_use
      color: isSelected ? colorScheme.primary.withOpacity(0.05) : Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: () {
          setState(() {
            selectedPaymentMethod = value;
            if (checkoutData != null) checkoutData!['paymentMethod'] = value;
            if (value != "Maamaas_Wallet") selectedSubWallet = "";
          });

          // Scroll after the UI updates
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients) {
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOut,
              );
            }
          });
        },

        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected ? colorScheme.primary : Colors.grey[600],
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title.replaceAll('_', ' '),
                      style: theme.textTheme.titleMedium,
                    ),
                    if (value == "Maamaas_Wallet")
                      Container(
                        decoration: BoxDecoration(
                          // ignore: deprecated_member_use
                          color: colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: wallet != null
                              ? Text(
                                  "₹${wallet!.totalBalance.toStringAsFixed(2)}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? colorScheme.primary
                                        : Colors.grey[700],
                                  ),
                                )
                              : Shimmer.fromColors(
                                  baseColor: Colors.grey.shade300,
                                  highlightColor: Colors.grey.shade100,
                                  child: Container(
                                    height: 16,
                                    width: 60,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                        ),
                      ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle, color: colorScheme.primary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubWalletselfloadedOption(
    String title,
    double amount,
    ThemeData theme,
    ColorScheme colorScheme, {
    required VoidCallback onAdd,
  }) {
    final isSelected = selectedSubWallets.contains(title);

    return Material(
      // ignore: deprecated_member_use
      color: isSelected ? colorScheme.primary.withOpacity(0.05) : Colors.white,
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: () {
          setState(() {
            isSelected
                ? selectedSubWallets.remove(title)
                : selectedSubWallets.add(title);
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          margin: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isSelected ? colorScheme.primary : Colors.grey.shade200,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              // ☑ Checkbox
              Checkbox(
                value: isSelected,
                activeColor: colorScheme.primary,
                onChanged: (val) {
                  setState(() {
                    val!
                        ? selectedSubWallets.add(title)
                        : selectedSubWallets.remove(title);
                  });
                },
              ),

              // Title & Amount
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.bodyMedium),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        // ignore: deprecated_member_use
                        color: colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Text(
                        "₹${amount.toStringAsFixed(2)}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? colorScheme.primary
                              : Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ➕ Add Button
              ElevatedButton(
                onPressed: onAdd,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text("Add"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubWalletOption(
    String title,
    double amount,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final isSelected = selectedSubWallets.contains(title);

    return Card(
      elevation: 0,
      margin: EdgeInsets.only(bottom: 8.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.r),
        side: BorderSide(
          color: isSelected ? colorScheme.primary : Colors.grey.shade200,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      // ignore: deprecated_member_use
      color: isSelected ? colorScheme.primary.withOpacity(0.05) : Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(8.r),
        onTap: () {
          setState(() {
            isSelected
                ? selectedSubWallets.remove(title)
                : selectedSubWallets.add(title);
          });
        },
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Row(
            children: [
              // ✅ Checkbox (NOT CheckboxListTile)
              Checkbox(
                value: isSelected,
                activeColor: colorScheme.primary,
                onChanged: (val) {
                  setState(() {
                    val!
                        ? selectedSubWallets.add(title)
                        : selectedSubWallets.remove(title);
                  });
                },
              ),

              // Title
              Expanded(child: Text(title, style: theme.textTheme.bodyMedium)),

              // Amount
              Container(
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                padding: const EdgeInsets.all(8),
                child: Text(
                  "₹${amount.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isSelected ? colorScheme.primary : Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceOrderButton(ThemeData theme, ColorScheme colorScheme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isPlacingOrder ? null : placeOrder,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 2,
        ),
        child: isPlacingOrder
            ? SizedBox(
                width: 22.w,
                height: 22.w,
                child: CircularProgressIndicator(
                  color: colorScheme.onPrimary,
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Place Order',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      // ignore: deprecated_member_use
                      color: colorScheme.onPrimary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '₹${(cartData?.grandTotal ?? 0).toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
