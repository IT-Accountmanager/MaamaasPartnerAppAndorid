import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:maamaaspartner/user_module/API/catering_authservice.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../API/Auth_service.dart';
import '../../Models/caterings/catering_cart_model.dart';
import '../../Models/wallet_model.dart';
import '../../widgets/skeleton/cart_skeleton.dart';
import '../addressmodel_provider.dart';
import '../cart wallet.dart';
import '../saved_address.dart';
import 'catering_invoice.dart';

class catering_cart extends ConsumerStatefulWidget {
  const catering_cart({super.key});

  @override
  ConsumerState<catering_cart> createState() => _catering_cartState();
}

class _catering_cartState extends ConsumerState<catering_cart> {
  catering_Cart? cart;
  String? appliedCouponCode;
  bool isExpanded = false;
  String selectedPaymentMethod = " ";
  String selectedSubWallet = " ";
  bool isPlacingOrder = false;
  DateTime? selectedDate;
  DateTime? selectedDateTime;
  String? selectedAddress;
  bool isLoading = true;
  Map<String, dynamic>? checkoutData;
  late List<CartPackage> items = [];
  Wallet? wallet;
  String? _email;
  String? _mobile;
  late Razorpay _razorpay;
  int? cartId;
  bool _isCateringSummaryExpanded = false;
  // late ScrollController _scrollController;
  Set<String> selectedSubWallets = {};

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    _loadCartData();
    _loadWallet();
    _loadUserProfile();
    refreshCart();
  }

  @override
  void dispose() {
    _razorpay.clear();
    _scrollController.dispose();
    super.dispose();
  }

  ScrollController _scrollController = ScrollController();

  // Only scroll on button click
  void scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _loadWallet() async {
    try {
      final fetchedWallet = await AuthService.fetchWallet(); // API call
      if (!mounted) return; // safety
      setState(() {
        wallet = fetchedWallet;
      });
    } catch (e) {
      debugPrint("⚠️ _loadWallet failed: $e");
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
    debugPrint("✅ Payment Success: ${response.paymentId}");
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId') ?? 0;
    final grandTotal = cart?.total ?? 0;

    final String paymentMethod = "Online_Payment";
    final bool captured = await catering_authservice.capturePayment(
      paymentId: response.paymentId!,
      amount: (cart?.total ?? 0).toDouble(),
    );
    if (captured) {
      await _callOrderApi(
        userId: userId,
        paymentMethod: paymentMethod,
        razorpayPaymentId: response.paymentId ?? "",
        razorpayOrderId: response.orderId ?? "",
        grandTotal: grandTotal,
      );
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    debugPrint("❌ Payment Failed: ${response.code} - ${response.message}");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Payment failed: ${response.message}")),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint("👜 External Wallet: ${response.walletName}");
  }

  Future<void> _onRefresh() async {
    final updatedCart = await catering_authservice.fetchUserCart();
    final updatedwallet = await AuthService.fetchWallet();

    if (!mounted) return;

    setState(() {
      cart = updatedCart;
      wallet = updatedwallet;
    });
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

  final List<Map<String, dynamic>> coupons = [
    {
      "code": "WELCOME10",
      "discountPercentage": 10,
      "endDate": "2025-12-31",
      "vendorId": null,
      "couponId": 1,
    },
    {
      "code": "FAMILY20",
      "discountPercentage": 20,
      "endDate": "2025-01-01",
      "vendorId": null,
      "couponId": 2,
    },
  ];

  Future<void> _loadCartData() async {
    setState(() => isLoading = true);

    try {
      final catering_Cart? cart = await catering_authservice.fetchUserCart();
      debugPrint("🛒 cart from API: $cart");

      if (cart == null) {
        debugPrint("❌ Cart is null (no cart for user)");
        items = [];
      } else {
        items = cart.items;
        debugPrint("🛍️ Cart items: $items");
      }
    } catch (e) {
      debugPrint("❌ Error fetching cart: $e");
    }

    setState(() => isLoading = false);
  }

  Future<void> placeOrder() async {
    final prefs = await SharedPreferences.getInstance();
    final int userId = prefs.getInt('userId') ?? 0;
    final double grandTotal = cart?.total ?? 0.0;

    debugPrint("📌 Starting placeOrder() for userId: $userId");

    if (selectedPaymentMethod.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Please select a payment method")),
      );
      return;
    }

    setState(() => isPlacingOrder = true);

    try {
      final String paymentMethod = selectedPaymentMethod;
      debugPrint("💳 Selected Payment Method: $paymentMethod");

      // 🏦 Handle wallet logic
      final String? walletType = paymentMethod == "Maamaas_Wallet"
          ? _mapSubWalletToBackend(selectedSubWallet)
          : null;

      if (paymentMethod == "Maamaas_Wallet") {
        double required = grandTotal;
        double available = 0;

        switch (walletType) {
          case "COMPANY_LOADED":
            available = wallet!.companyLoadedAmount;
            break;
          case "SELF_LOADED":
            available = wallet!.selfLoadedAmount;
            break;
          case "CASHBACK":
            available = wallet!.cashbackAmount;
            break;
        }

        if (available < required) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Insufficient wallet balance! Available ₹${available.toStringAsFixed(2)}, Required ₹${required.toStringAsFixed(2)}",
              ),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }

      // 🌐 Online Payment → Razorpay
      if (paymentMethod == "Online_Payment") {
        debugPrint("🛒 Opening Razorpay for ₹$grandTotal");
        final orderId = await catering_authservice.createOrder(grandTotal);
        if (orderId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to create Razorpay order ❌")),
          );
          return;
        }
        _openRazorpayCheckout(grandTotal);
        return; // Razorpay callback will call _callOrderApi()
      }

      // 💰 Wallet / Cash on Delivery
      await _callOrderApi(
        userId: userId,
        paymentMethod: paymentMethod,
        razorpayPaymentId: "",
        razorpayOrderId: "",
        // walletType: walletType,
        grandTotal: grandTotal,
      );
    } catch (e, stack) {
      debugPrint("❌ Error in placeOrder: $e");
      debugPrint("📜 Stacktrace: $stack");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error placing order: $e")));
    } finally {
      setState(() => isPlacingOrder = false);
    }
  }

  String? _mapSubWalletToBackend(String? subWallet) {
    switch (subWallet) {
      case "Company Credited Amount":
        return "COMPANY_LOADED";
      case "Self Credited Amount":
        return "SELF_LOADED";
      case "Cashbacks":
        return "CASHBACK";
      case "Earned Amount":
        return "EARNED_AMOUNT";
      default:
        return null;
    }
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

  void _openRazorpayCheckout(double amount) {
    final double finalAmount = (cart?.total ?? amount) * 100;
    var options = {
      'key': 'rzp_test_TJECsclCivENpY',
      'amount': finalAmount.toInt(),
      'name': 'Maamaas App',
      'description': 'Order Payment',
      'prefill': {
        'contact': _mobile ?? "9999999999",
        'email': _email ?? "customer@email.com",
      },
    };

    try {
      debugPrint("💰 Opening Razorpay with amount ₹${finalAmount / 100}");
      _razorpay.open(options);
    } catch (e) {
      debugPrint("❌ Razorpay open error: $e");
    }
  }

  Future<void> _callOrderApi({
    required int userId,  // Keep this for reference, but don't use in URL
    required String paymentMethod,
    required String razorpayPaymentId,
    required String razorpayOrderId,
    required double grandTotal,
    List<String>? walletTypes,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final cartId = prefs.getInt('cartId');

    // // Also get customerId from prefs or wherever it's stored
    // final customerId = prefs.getString('customerId') ?? '';

    if (cartId == null || cartId <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Cart ID missing or invalid")),
      );
      return;
    }

    debugPrint("📦 [Order API] cartId: $cartId, userId: $userId");
    debugPrint("💳 paymentMethod: $paymentMethod");
    debugPrint("💰 grandTotal: $grandTotal");
    debugPrint("🏦 walletType: $walletTypes");

    final result = await catering_authservice.placeOrder(
      // customerId: customerId,  // Pass this to the service
      cartId: cartId,
      paymentMethod: paymentMethod,
      razorpayPaymentId: razorpayPaymentId,
      razorpayOrderId: razorpayOrderId,
      walletTypes: mapWalletsToEnum(selectedSubWallets.toList()),
      grandTotal: grandTotal,
    );

    // 🔥 FIX HERE
    final int? orderId = result?['orderId'];

    if (orderId != null && orderId > 0) {
      await prefs.setInt('orderId', orderId);

      debugPrint("✅ Order placed successfully → Order ID: $orderId");

      // Optional: clear cart after successful order
      await prefs.remove('cartId');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Order placed successfully")),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => catering_invoice(orderId: orderId),
        ),
      );
    } else {
      debugPrint("❌ Failed to place order → Response: $result");

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("❌ Failed to place order")));
    }
  }

  // @override
  // Widget build(BuildContext context) {
  //   final theme = Theme.of(context);
  //   final colorScheme = theme.colorScheme;
  //   return Scaffold(
  //     backgroundColor: Colors.grey[50],
  //     appBar: AppBar(
  //       title: const Text("Review Your cart"),
  //       centerTitle: true,
  //       backgroundColor: Colors.white,
  //       actions: [_buildClearCart(Icons.clear)],
  //     ),
  //     body: FutureBuilder<catering_Cart?>(
  //       future: catering_authservice.fetchUserCart(),
  //       builder: (context, snapshot) {
  //         if (snapshot.connectionState == ConnectionState.waiting) {
  //           return const Center(child: CircularProgressIndicator());
  //         }
  //
  //         if (snapshot.hasError) {
  //           return Center(child: Text("Error: ${snapshot.error}"));
  //         }
  //
  //         final cart = snapshot.data;
  //
  //         return Column(
  //           children: [
  //             Expanded(
  //               child: SingleChildScrollView(
  //                 controller: _scrollController,
  //                 physics: const AlwaysScrollableScrollPhysics(), // 🔥 REQUIRED
  //                 padding: const EdgeInsets.all(16),
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     if (!isLoading && (cart!.items.isEmpty))
  //                       _buildEmptyCart()
  //                     else ...[
  //                       _buildCartItems(), // make sure this uses 'items'
  //                       // const SizedBox(height: 16),
  //                       // _buildCouponRow(theme, colorScheme),
  //                       const SizedBox(height: 16),
  //                       _buildDateAndTime(),
  //                       const SizedBox(height: 16),
  //                       _buildDeliveryAddress(),
  //                       const SizedBox(height: 16),
  //                       buildBillSummaryFromCart(cart!), // ✅ now cart exists
  //                       const SizedBox(height: 16),
  //                       // _buildCheckoutSection(theme, colorScheme),
  //                       _buildCheckoutCard(),
  //                       if (isExpanded)
  //                         _buildCheckoutDetails(theme, colorScheme),
  //                     ],
  //                   ],
  //                 ),
  //               ),
  //             ),
  //           ],
  //         );
  //       },
  //     ),
  //   );
  // }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Center(child: Text("Catering Cart")),
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: Colors.white,
        backgroundColor: Colors.blueAccent,
        displacement: 40,
        strokeWidth: 3,

        /// 👇 THIS IS REQUIRED
        child: isLoading
            ? CartSkeleton(type: CartSkeletonType.fullCart)
            : SingleChildScrollView(
                controller: _scrollController,
                physics:
                    const AlwaysScrollableScrollPhysics(), // 🔥 IMPORTANT for RefreshIndicator
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    items.isEmpty ? _buildEmptyCart() : _buildCartItems(),

                    const SizedBox(height: 16),

                    if (cart != null)
                      buildCateringSummaryCard(
                        cart!,
                        Theme.of(context),
                        Theme.of(context).colorScheme,
                      ),

                    const SizedBox(height: 16),

                    _buildDateAndTime(),

                    const SizedBox(height: 16),

                    _buildDeliveryAddress(),

                    const SizedBox(height: 16),

                    _buildCheckoutCard(),

                    if (isExpanded) _buildCheckoutDetails(theme, colorScheme),

                    const SizedBox(height: 30), // bottom spacing
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Center(
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildClearCart(IconData icon) {
    return CircleAvatar(
      radius: 22,
      backgroundColor: Colors.grey[200],
      child: IconButton(
        icon: Icon(icon, size: 22, color: Colors.black),
        onPressed: () async {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Clear Cart?'),
              content: const Text(
                'Are you sure you want to remove all the packages from your cart?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Clear'),
                ),
              ],
            ),
          );

          if (confirmed == true) {
            final success = await catering_authservice.clearCart();

            if (success) {
              setState(() {
                items.clear(); // Clear your local cart list
              });

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("✅ Cart cleared successfully"),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("❌ Failed to clear cart"),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 2),
                ),
              );
            }
          }
        },
      ),
    );
  }

  Future<void> _pickDateTime() async {
    DateTime today = DateTime.now();
    DateTime firstAllowedDate = today.add(
      Duration(days: 2),
    ); // Only after 2 days
    DateTime lastAllowedDate = today.add(Duration(days: 365));
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: firstAllowedDate, // Start picker from allowed date
      firstDate: firstAllowedDate, // Disable all before this
      lastDate: lastAllowedDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.deepPurple, // header background color
              onPrimary: Colors.white, // header text color
              onSurface: Colors.black, // body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.black, // buttons color
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (date == null) return;

    // ⏰ Pick Time
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(selectedDateTime ?? DateTime.now()),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.deepPurple, // header background color
              onPrimary: Colors.white, // header text color
              onSurface: Colors.black, // body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.black, // buttons color
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (time == null) return;

    // Combine date & time
    final combined = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    setState(() => selectedDateTime = combined);

    // 🔄 Call API to update backend
    await _updateDateTimeOnServer(combined);
  }

  Future<void> _updateDateTimeOnServer(DateTime dateTime) async {
    final success = await catering_authservice.updateDateTime(
      context,
      selectedDateTime!,
    );
    ;

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? "Date & Time updated successfully!"
              : "Failed to update date & time.",
        ),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  Widget _buildDateAndTime() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Date & Time *",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickDateTime,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time, color: Color(0xFFB15DC6)),
                const SizedBox(width: 12),
                Text(
                  selectedDateTime == null
                      ? "Select Date & Time"
                      : DateFormat(
                          'MMM dd, yyyy - hh:mm a',
                        ).format(selectedDateTime!),
                  style: TextStyle(
                    color: selectedDateTime == null
                        ? Colors.grey[500]
                        : Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showAddressBottomSheet(BuildContext context, int cartId) async {
    List<dynamic> savedAddresses = [];
    bool isLoading = true;
    String? errorMessage;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            Future<void> _fetchAddresses() async {
              try {
                final data =
                    await AuthService.fetchAddresses(); // ✅ working API
                setModalState(() {
                  savedAddresses = data;
                  isLoading = false;
                });
              } catch (e) {
                setModalState(() {
                  isLoading = false;
                  errorMessage = "Error: $e";
                });
              }
            }

            // Trigger initial load once
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (isLoading) _fetchAddresses();
            });

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.7,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Select Delivery Address",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    if (isLoading)
                      const Expanded(
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (errorMessage != null)
                      Expanded(child: Center(child: Text(errorMessage!)))
                    else if (savedAddresses.isEmpty)
                      const Expanded(
                        child: Center(child: Text("No saved addresses found")),
                      )
                    else
                      Expanded(
                        child: ListView.builder(
                          itemCount: savedAddresses.length,
                          itemBuilder: (context, index) {
                            final address = savedAddresses[index];
                            final displayText =
                                "${address.doorNumber}, ${address.addressLine}, ${address.city} - ${address.pincode}";

                            return GestureDetector(
                              onTap: () async {
                                final success = await catering_authservice
                                    .updateCartAddress(
                                      cartId: cartId,
                                      addressId: address.id,
                                    );

                                if (success) {
                                  Navigator.pop(context, displayText);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "✅ Address updated successfully",
                                      ),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "❌ Failed to update address",
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on,
                                      color: Color(0xFFB15DC6),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            displayText,
                                            style: const TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                    const SizedBox(height: 8),

                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddressFormScreen(),
                            ),
                          );
                          if (result != null && result is String) {
                            setModalState(() {
                              savedAddresses.add({
                                "doorNumber": "",
                                "addressLine": result,
                                "city": "",
                                "pincode": "",
                                "category": "Custom",
                                "name": "",
                                "phoneNumber": "",
                              });
                            });
                          }
                        },
                        icon: const Icon(
                          Icons.add_location_alt,
                          color: Color(0xFFB15DC6),
                        ),
                        label: const Text(
                          "Add new Address",
                          style: TextStyle(color: Colors.white),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFB15DC6)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: Color(0xFFB15DC6),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).then((selected) {
      if (selected != null && selected is String) {
        setState(() {
          selectedAddress = selected; // ✅ update state here
        });
        debugPrint("✅ Selected Address: $selected");
      }
    });
  }

  // Widget _buildDeliveryAddress(int cartId) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       const Text(
  //         "Delivery Address",
  //         style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
  //       ),
  //       const SizedBox(height: 8),
  //       GestureDetector(
  //         onTap: () => _showAddressBottomSheet(context, cartId),
  //         child: Container(
  //           width: double.infinity,
  //           padding: const EdgeInsets.all(16),
  //           decoration: BoxDecoration(
  //             color: Colors.white,
  //             borderRadius: BorderRadius.circular(12),
  //             // border: Border.all(color: Colors.grey.shade300),
  //             boxShadow: const [
  //               BoxShadow(
  //                 color: Colors.black12,
  //                 blurRadius: 8,
  //                 offset: Offset(0, 4),
  //               ),
  //             ],
  //           ),
  //           child: Row(
  //             children: [
  //               const Icon(Icons.location_on, color: Color(0xFFB15DC6)),
  //               const SizedBox(width: 12),
  //               Expanded(
  //                 child: Text(
  //                   selectedAddress ?? "select address",
  //                   style: TextStyle(
  //                     fontSize: 14,
  //                     color: selectedAddress == null
  //                         ? Colors.grey[500]
  //                         : Colors.black,
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }

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
                // debugPrint(
                //   "🌟 Address selected: $city, $state, $pincode, id=$addressId",
                // );

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

                // debugPrint("🌟 Provider updated: ${ref.read(addressProvider)}");

                // 2️⃣ Update cart delivery address API
                // ignore: unnecessary_null_comparison
                if (cart!.id != null && addressId != 0) {
                  // debugPrint(
                  //   "🌟 Calling API to update cart delivery address...",
                  // );

                  final success =
                      await AddressNotifier.updatecateringDeliveryAddress(
                        cartId: cart!.id,
                        addressId: addressId,
                      );

                  // debugPrint("🌟 API call success: $success");

                  if (success && mounted) {
                    // 🔥 REFRESH CART IMMEDIATELY
                    final updatedCart = await catering_authservice
                        .fetchUserCart();

                    if (mounted) {
                      setState(() {
                        cart = updatedCart;
                      });
                    }
                  }
                } else {
                  // debugPrint(
                  //   "⚠️ cartId or addressId invalid, skipping API call",
                  // );
                }

                // 3️⃣ Close SavedAddress screen
                // if (mounted) Navigator.pop(context);
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
                  if ((cart?.deliveryAddress ?? '').trim().isNotEmpty) ...[
                    Text(
                      [
                        cart!.deliveryAddress,
                        cart!.name,
                        cart!.mobileNo,
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

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        children: [
          Icon(Icons.shopping_cart_outlined, size: 60, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Your catering cart is empty',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Add some delicious items',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItems() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _buildCartItemCard(items[index], index);
      },
    );
  }

  Future<void> refreshCart() async {
    final catering_Cart? updatedCart = await catering_authservice
        .fetchUserCart();

    if (updatedCart != null) {
      setState(() {
        cart = updatedCart;
      });
    }
  }

  Widget _buildCartItemCard(CartPackage item, int index) {
    return StatefulBuilder(
      builder: (context, setInnerState) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            // border: Border.all(color: Colors.grey, width: 1),
            boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(
                  13,
                  0,
                  0,
                  0,
                ), // 13 ≈ 5% opacity (0.05 * 255)
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.packageName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        item.isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                      ),
                      onPressed: () {
                        setInnerState(() {
                          item.isExpanded = !item.isExpanded;
                        });
                      },
                    ),
                  ],
                ),

                // Expandable items
                if (item.isExpanded) ...[
                  const SizedBox(height: 6),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: item.packageItems
                        .map(
                          (i) => Text(
                            "• ${i.itemName}",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],

                const Divider(),

                // Price + Quantity Selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "₹${(item.packagePrice * item.quantity).toStringAsFixed(0)}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.green,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          // Decrement Button
                          IconButton(
                            icon: const Icon(Icons.remove, size: 18),
                            onPressed: () async {
                              final prefs =
                                  await SharedPreferences.getInstance();
                              final userId = prefs.getInt('userId') ?? 0;
                              final cartId = prefs.getInt('cartId') ?? 0;

                              if (item.quantity > 1) {
                                // Reduce quantity
                                setInnerState(() => item.quantity--);

                                final success = await catering_authservice
                                    .updateCartQuantity(
                                      cartId: cartId,
                                      userId: userId,
                                      packageId: item.packageId,
                                      quantity: item.quantity,
                                    );

                                if (success) {
                                  await refreshCart(); // 🔥 Fetch updated cart
                                }
                              } else {
                                // Remove item if quantity becomes 0
                                final success = await catering_authservice
                                    .deletePackageFromCart(
                                      cartId: cartId,
                                      packageId: item.packageId,
                                    );

                                if (success) {
                                  setState(() {
                                    items.remove(item); // remove from UI list
                                  });
                                  await refreshCart();
                                }
                              }
                            },
                          ),

                          // Quantity Text
                          Text(
                            item.quantity.toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),

                          // Increment Button
                          IconButton(
                            icon: const Icon(Icons.add, size: 18),
                            onPressed: () async {
                              setInnerState(() => item.quantity++);

                              final prefs =
                                  await SharedPreferences.getInstance();
                              final userId = prefs.getInt('userId') ?? 0;
                              final cartId = prefs.getInt('cartId') ?? 0;

                              final success = await catering_authservice
                                  .updateCartQuantity(
                                    cartId: cartId,
                                    userId: userId,
                                    packageId: item.packageId,
                                    quantity: item.quantity,
                                  );

                              if (success) {
                                await refreshCart(); // 🔥 Fetch updated cart
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Dynamic Bill Summary Widget
  Widget buildCateringSummaryCard(
    catering_Cart cart,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final subtotal = cart.subtotal;
    final gstAmount = cart.gstAmount;
    final platformFee = cart.platformFeeAmount;
    final deliveryFee = cart.deliveryFee;
    final total = cart.total;

    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      shadowColor: Colors.black26,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔽 Header with expand/collapse
            InkWell(
              onTap: () {
                setState(() {
                  _isCateringSummaryExpanded = !_isCateringSummaryExpanded;
                });
              },
              child: Row(
                children: [
                  Icon(
                    Icons.receipt_long,
                    color: colorScheme.primary,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      "Order Summary",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _isCateringSummaryExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.keyboard_arrow_down),
                  ),
                ],
              ),
            ),

            /// 🔹 Expandable section
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 250),
              crossFadeState: _isCateringSummaryExpanded
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              firstChild: Column(
                children: [
                  const Divider(height: 24),

                  _buildBillRow("Subtotal", "₹${subtotal.toStringAsFixed(2)}"),

                  _buildBillRow("GST", "₹${gstAmount.toStringAsFixed(2)}"),

                  _buildBillRow(
                    "Platform Fee",
                    "₹${platformFee.toStringAsFixed(2)}",
                  ),

                  if (deliveryFee > 0)
                    _buildBillRow(
                      "Delivery Fee",
                      "₹${deliveryFee.toStringAsFixed(2)}",
                    ),
                ],
              ),
              secondChild: const SizedBox.shrink(),
            ),

            const Divider(height: 24),

            /// 💰 Total (ALWAYS visible)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Total",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Text(
                  "₹${total.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBillRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                  size: 20,
                  color: isCouponApplied
                      ? colorScheme.primary
                      : Colors.grey.shade600,
                ),
                const SizedBox(width: 12),
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

            // Show Remove button if coupon applied, else arrow
            isCouponApplied
                ? GestureDetector(
                    onTap: () {
                      setState(() {
                        appliedCouponCode = null;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Coupon removed"),
                          backgroundColor: Colors.red,
                        ),
                      );
                    },
                    child: Text(
                      "Remove",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                : Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
          ],
        ),
      ),
    );
  }

  void _showCouponBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade200,
                      blurRadius: 3,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Available Coupons",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // Coupon list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: coupons.length,
                  itemBuilder: (context, index) {
                    final coupon = coupons[index];
                    final code = coupon["code"];
                    final discount = coupon["discountPercentage"];
                    final expiryDate = coupon["endDate"];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0x33000000,
                            ), // ~20% opacity grey/black
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        border: Border.all(
                          color: _isCouponExpired(expiryDate)
                              ? Colors.red.shade200
                              : Colors.green.shade200,
                          width: 1,
                        ),
                      ),
                      child: ListTile(
                        leading: Icon(
                          Icons.local_offer,
                          color: _isCouponExpired(expiryDate)
                              ? Colors.red
                              : Colors.green,
                        ),
                        title: Row(
                          children: [
                            Text(
                              code,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _isCouponExpired(expiryDate)
                                    ? Colors.red
                                    : Colors.black,
                              ),
                            ),
                            if (_isCouponExpired(expiryDate)) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade200,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  "Expired",
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        subtitle: Text(
                          _isCouponExpired(expiryDate)
                              ? "Expired"
                              : "Get $discount% off",
                          style: TextStyle(
                            color: _isCouponExpired(expiryDate)
                                ? Colors.red
                                : Colors.black54,
                          ),
                        ),
                        trailing: _isCouponExpired(expiryDate)
                            ? const Icon(Icons.block, color: Colors.red)
                            : const Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: Colors.green,
                              ),
                        onTap: _isCouponExpired(expiryDate)
                            ? null
                            : () {
                                setState(() {
                                  appliedCouponCode = code;
                                });
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "Coupon $appliedCouponCode applied!",
                                    ),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  bool _isCouponExpired(String? endDate) {
    if (endDate == null) return false;
    try {
      final expiry = DateTime.parse(endDate);
      return DateTime.now().isAfter(expiry);
    } catch (e) {
      return false; // if parsing fails
    }
  }

  Widget _buildCheckoutCard() {
    return ElevatedButton(
      onPressed: () {
        setState(() => isExpanded = !isExpanded);
        WidgetsBinding.instance.addPostFrameCallback((_) => scrollToBottom());
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFB15DC6),
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(
        isExpanded ? 'Hide payment options' : 'Show payment options',
        style: const TextStyle(color: Colors.white),
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
        const SizedBox(height: 16),
        _buildPlaceOrderButton(theme, colorScheme),
      ],
    );
  }

  Widget _buildPaymentSection(ThemeData theme, ColorScheme colorScheme) {
    // final orderType = cartData?.orderType ?? "DINE_IN";
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
                      "Company Credited Amount",
                      wallet!.companyLoadedAmount,
                      theme,
                      colorScheme,
                    ),
                    _buildSubWalletOption(
                      "Self Credited Amount",
                      wallet!.selfLoadedAmount,
                      theme,
                      colorScheme,
                    ),
                    _buildSubWalletOption(
                      "Cashbacks",
                      wallet!.cashbackAmount,
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
          WidgetsBinding.instance.addPostFrameCallback((_) => scrollToBottom());
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
                    Text(title, style: theme.textTheme.titleMedium),
                    if (value == "Maamaas_Wallet")
                      Container(
                        decoration: BoxDecoration(
                          // ignore: deprecated_member_use
                          color: colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            wallet != null
                                ? "₹${wallet!.totalBalance.toStringAsFixed(2)}"
                                : "Loading...",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? colorScheme.primary
                                  : Colors.grey[700],
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

  Widget _buildSubWalletOption(
    String title,
    double amount,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final isSelected = selectedSubWallet == title;
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
        onTap: () => setState(() => selectedSubWallet = title),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Row(
            children: [
              Expanded(child: Text(title, style: theme.textTheme.bodyMedium)),
              Container(
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
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
              ),
              if (isSelected)
                Icon(Icons.check, size: 18, color: colorScheme.primary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceOrderButton(ThemeData theme, ColorScheme colorScheme) {
    double total = cart?.total ?? 0.0;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: (cart == null || isPlacingOrder)
            ? null
            : () {
                if (selectedDateTime == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "⚠️ Please select a date and time before placing the order.",
                      ),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                  return; // ⛔ Stop here
                }
                // if (selectedAddress == null || selectedAddress!.isEmpty) {
                //   ScaffoldMessenger.of(context).showSnackBar(
                //     const SnackBar(
                //       content: Text("🏠 Please select a delivery address."),
                //       backgroundColor: Colors.redAccent,
                //     ),
                //   );
                //   return;
                // }

                // ✅ Proceed only if date/time selected
                placeOrder();
              },
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
                      "₹${total.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class DateTimePickerField extends StatefulWidget {
  final String label;
  const DateTimePickerField({super.key, required this.label});

  @override
  State<DateTimePickerField> createState() => _DateTimePickerFieldState();
}

class _DateTimePickerFieldState extends State<DateTimePickerField> {
  DateTime? selectedDateTime;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Date & Time",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime(2100),
            );
            if (pickedDate != null) {
              TimeOfDay? pickedTime = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );
              if (pickedTime != null) {
                setState(() {
                  selectedDateTime = DateTime(
                    pickedDate.year,
                    pickedDate.month,
                    pickedDate.day,
                    pickedTime.hour,
                    pickedTime.minute,
                  );
                });
              }
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Icon(Icons.access_time, color: Color(0xFFB15DC6)),
                SizedBox(width: 12),
                Text(
                  selectedDateTime == null
                      ? widget.label
                      : DateFormat(
                          'MMM dd, yyyy - hh:mm a',
                        ).format(selectedDateTime!),
                  style: TextStyle(
                    color: selectedDateTime == null
                        ? Colors.grey[500]
                        : Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

Widget buildCartSkeleton() {
  return ListView.builder(
    padding: const EdgeInsets.all(16),
    shrinkWrap: true,
    itemCount: 3,
    itemBuilder: (context, index) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        height: 100,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(12),
        ),
      );
    },
  );
}
