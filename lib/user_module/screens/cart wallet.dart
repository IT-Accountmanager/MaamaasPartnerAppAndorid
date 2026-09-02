import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import '../API/Auth_service.dart';
import '../API/food_authservice.dart';
import '../Models/food/cart_model.dart';
import '../Models/wallet_model.dart';

class cartwallet extends StatefulWidget {
  final Wallet? wallet; // add this
  final void Function(String paymentMethod, Set<String> subWallets)
  onSelectionChanged;

  const cartwallet({
    super.key,
    required this.onSelectionChanged,
    this.wallet, // add this
  });

  @override
  State<cartwallet> createState() => _cartwalletState();
}

class _cartwalletState extends State<cartwallet> {
  late TextEditingController _amountController; // ✅ declare it
  CartModel? cartData;
  bool isLoading = true;
  String selectedPaymentMethod = "";
  String? selectedSubWallet = "";
  // Wallet? wallet;
  Map<String, dynamic>? checkoutData;
  late ScrollController _scrollController;
  Set<String> selectedSubWallets = {};
  String? _userType;
  Razorpay? razorpay;
  double _cashbackAmount = 0.0;
  double _lastPaidAmount = 0.0;
  String? _email;
  String? _mobile;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();
    _amountController = TextEditingController(); // ✅ FIX
    _initializeRazorpay(); // ✅ FIX
    _loadUserType(); // ✅ FIX
    // loadWallet();
    _loadCart();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _amountController.dispose();
    razorpay!.clear();
    super.dispose();
  }

  void _initializeRazorpay() {
    razorpay = Razorpay();
    razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    final paymentId = response.paymentId!;
    final orderId = response.orderId!;
    final amount = _lastPaidAmount; // save this when calling Razorpay.open()

    // debugPrint("✅ Payment Success: $paymentId | $orderId");

    final captured = await AuthService.capturePayment(
      paymentId: paymentId,
      amount: amount,
    );

    if (captured) {
      await AuthService.addCashToWallet(
        paymentId: paymentId,
        orderId: orderId,
        amount: amount,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Wallet recharged successfully 🎉")),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Payment capture failed ❌")));
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // debugPrint("❌ Payment Error: ${response.message}");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Payment Failed: ${response.message}")),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // debugPrint("🌍 External Wallet Selected: ${response.walletName}");
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

  double getSelectedWalletBalance() {
    if (widget.wallet == null) return 0;

    double total = 0;

    if (selectedSubWallets.contains("Company Loaded")) {
      total += widget.wallet!.companyLoadedAmount;
    }

    if (selectedSubWallets.contains("Self Loaded")) {
      total += widget.wallet!.selfLoadedAmount;
    }

    if (selectedSubWallets.contains("Cashbacks")) {
      total += widget.wallet!.cashbackAmount;
    }

    if (selectedSubWallets.contains("Postpaid used amount")) {
      total += widget.wallet!.postPaidUsage;
    }

    return total;
  }

  Future<void> _loadCart() async {
    setState(() => isLoading = true);

    try {
      final fetchedCart = await food_Authservice.fetchCart();

      if (mounted) {
        setState(() {
          cartData = fetchedCart;

          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _notifyParent() {
    widget.onSelectionChanged(selectedPaymentMethod, selectedSubWallets);
  }

  Future<String> getUserType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userType') ?? "PERSONAL";
  }

  Future<void> _loadUserType() async {
    final type = await getUserType();
    if (!mounted) return;

    setState(() {
      _userType = type.toUpperCase();
    });
  }

  void _showAmountBottomSheetProfessionalUser(
    BuildContext context,
    Razorpay razorpay,
  ) {
    final TextEditingController amountController = TextEditingController();
    bool useCashback = false;
    double enteredAmount = 0;
    double amountToPay = 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        top: false,
        child: StatefulBuilder(
          builder: (context, setState) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              top: 20,
              left: 20,
              right: 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Load Wallet",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    prefixText: "₹",
                    hintText: "Enter amount to load",
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      enteredAmount = double.tryParse(value) ?? 0;
                      amountToPay =
                          (enteredAmount - (useCashback ? _cashbackAmount : 0))
                              .clamp(0, enteredAmount)
                              .toDouble();
                    });
                  },
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  children: [100, 200, 500, 1000, 2000].map((e) {
                    return OutlinedButton(
                      onPressed: () {
                        setState(() {
                          enteredAmount = e.toDouble();
                          amountController.text = e.toString();
                          amountToPay =
                              (enteredAmount -
                                      (useCashback ? _cashbackAmount : 0))
                                  .clamp(0, enteredAmount)
                                  .toDouble();
                        });
                      },
                      child: Text("₹$e"),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      useCashback = !useCashback;
                      amountToPay =
                          (enteredAmount - (useCashback ? _cashbackAmount : 0))
                              .clamp(0, enteredAmount)
                              .toDouble();
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Checkbox(
                          value: useCashback,
                          onChanged: (val) {
                            setState(() {
                              useCashback = val ?? false;
                              amountToPay =
                                  (enteredAmount -
                                          (useCashback ? _cashbackAmount : 0))
                                      .clamp(0, enteredAmount)
                                      .toDouble();
                            });
                          },
                        ),
                        Text(
                          "USE CASHBACK  Available: ₹${_cashbackAmount.toStringAsFixed(2)}",
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Column(
                  children: [
                    Text(
                      "Entered Amount: ₹${enteredAmount.toStringAsFixed(2)}",
                    ),
                    Text(
                      "Proceed to Pay: ₹${amountToPay.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: amountToPay <= 0
                        ? null
                        : () async {
                            Navigator.pop(context);
                            _lastPaidAmount = amountToPay;

                            // Step 1: Create Razorpay order
                            final orderId = await AuthService.createOrder(
                              amountToPay,
                            );
                            if (orderId == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Failed to create Razorpay order ❌",
                                  ),
                                ),
                              );
                              return;
                            }

                            // Step 2: Open Razorpay payment
                            var options = {
                              'key': 'rzp_test_TJECsclCivENpY',
                              // 'key': 'rzp_test_TJECsclCivENpY',
                              'order_id': orderId,
                              'amount': (amountToPay * 100).toInt(), // paise
                              'name': 'Wallet Top-Up',
                              'description': 'Self-loaded wallet via Razorpay',
                              'prefill': {
                                'contact': _mobile ?? "9999999999",
                                'email': _email ?? "customer@email.com",
                              },
                            };

                            try {
                              razorpay.open(options);
                            } catch (e) {
                              debugPrint('⚠️ Razorpay Error: $e');
                            }

                            // Step 3: On payment success, call professionalSelfLoaded API
                            razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, (
                              response,
                            ) async {
                              final paymentId = response.paymentId!;
                              final success =
                                  await AuthService.professionalSelfLoaded(
                                    amount: amountToPay,
                                    paymentId: paymentId,
                                    orderId: orderId,
                                    useCashback: useCashback,
                                  );

                              if (success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Wallet recharged successfully 🎉",
                                    ),
                                  ),
                                );
                                // await loadWallet(); // refresh wallet UI
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Failed to update wallet ❌"),
                                  ),
                                );
                              }
                            });

                            razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, (
                              response,
                            ) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Payment Failed: ${response.message}",
                                  ),
                                ),
                              );
                            });
                          },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                      "Proceed to Pay ₹${amountToPay.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAmountBottomSheet(BuildContext context, Razorpay razorpay) {
    final TextEditingController amountController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // ✅ REQUIRED
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: SingleChildScrollView(
            // ✅ IMPORTANT
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom:
                  MediaQuery.of(context).viewInsets.bottom + 20, // ✅ KEY FIX
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Enter Amount",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Amount",
                    hintText: "Enter amount to load",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final amount = double.tryParse(amountController.text);
                      if (amount == null || amount <= 0) return;

                      Navigator.pop(context);
                      _lastPaidAmount = amount;

                      final orderId = await AuthService.createOrder(amount);
                      if (orderId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Failed to create Razorpay order ❌"),
                          ),
                        );
                        return;
                      }

                      razorpay.open({
                        // 'key': 'rzp_test_TJECsclCivENpY',
                        'key': 'rzp_test_TJECsclCivENpY',
                        'order_id': orderId,
                        'amount': (amount * 100).toInt(),
                        'name': 'Wallet Top-Up',
                        'description': 'Self-loaded wallet via Razorpay',
                        'prefill': {
                          'contact': _mobile ?? "9999999999",
                          'email': _email ?? "customer@email.com",
                        },
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.payment_rounded, size: 22),
                        SizedBox(width: 10),
                        Text(
                          "Proceed to Pay",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      controller: _scrollController, // ✅ ATTACH IT
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.only(bottom: 20.h),
        child: _buildPaymentSection(theme, colorScheme),
      ),
    );
  }

  Widget _buildPaymentSection(ThemeData theme, ColorScheme colorScheme) {
    if (cartData == null || isLoading) {
      return _paymentSkeleton();
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
                widget.wallet != null) ...[
              SizedBox(height: 8.h),
              Padding(
                padding: EdgeInsets.only(left: 32.w),
                child: Column(
                  children: [
                    _buildSubWalletOption(
                      "Company Loaded",
                      widget.wallet!.companyLoadedAmount,
                      theme,
                      colorScheme,
                    ),
                    _buildSubWalletselfloadedOption(
                      "Self Loaded",
                      widget.wallet!.selfLoadedAmount,
                      theme,
                      colorScheme,
                      onAdd: () {
                        debugPrint("Add Self Loaded Amount");

                        if (razorpay == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Payment service not ready ❌"),
                            ),
                          );
                          return;
                        }

                        if (_userType == "PROFESSIONAL") {
                          _showAmountBottomSheetProfessionalUser(
                            context,
                            razorpay!,
                          );
                        } else {
                          _showAmountBottomSheet(context, razorpay!);
                        }
                      },
                    ),
                    _buildSubWalletOption(
                      "Cashbacks",
                      widget.wallet!.cashbackAmount,
                      theme,
                      colorScheme,
                    ),
                    if ((cartData?.userCompany ?? '').isNotEmpty)
                      _buildSubWalletOption(
                        "Postpaid used amount",
                        widget.wallet!.postPaidUsage,
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
            if (value != "Maamaas_Wallet") {
              selectedSubWallets.clear();
            }
          });
          _notifyParent(); // 🔥 send to cart

          if (value == "Maamaas_Wallet" && selectedSubWallets.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Please select at least one sub wallet"),
              ),
            );
          }

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
                          child: widget.wallet != null
                              ? Text(
                                  "₹${widget.wallet!.totalBalance.toStringAsFixed(2)}",
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

          _notifyParent();
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

                  _notifyParent();
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

          _notifyParent();
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

                  _notifyParent();
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
}

Widget _paymentSkeleton() {
  return Column(
    children: List.generate(
      3,
      (_) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    ),
  );
}
