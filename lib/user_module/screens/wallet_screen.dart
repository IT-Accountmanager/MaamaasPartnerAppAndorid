import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../API/Auth_service.dart';
import '../Models/transaction_model.dart';
import '../Models/wallet_model.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  late TextEditingController _amountController; // ✅ declare it

  double _balance = 0;
  double _companyCreditedAmount = 0.0;
  double _selfCreditedAmount = 0.0;
  double _cashbackAmount = 0.0;
  double _postPaidUsage = 0.0;
  double _creditLimit = 0.0;
  bool _isLoading = true;
  bool isDrawerOpen = false;
  int selectedIndex = -1;
  String? selectedYear;
  String? selectedMonth;
  String? selectedWeek;
  String? selectedDate;
  List<String> years = [];
  List<String> months = [];
  List<String> dates = [];
  late Razorpay _razorpay;
  double _lastPaidAmount = 0.0;
  bool _postPaid = true;
  String? _email;
  String? _mobile;
  double amountToPay = 0.0;
  double cashbackAvailable = 0.0;

  String? _userType;

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(); // ✅ initialize it
    _initializeRazorpay(); // ✅ Razorpay setup
    _loadInitialData();
    _loadUserProfile();
    _loadUserType(); // ✅ Async wallet/transactions setup
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

  void _initializeRazorpay() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  Future<void> _loadInitialData() async {
    await loadWallet();
    _loadTransactions();
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

  @override
  void dispose() {
    _amountController.dispose();
    _razorpay.clear();
    super.dispose();
  }

  void _initializeDateFilters(List<Transactions> transactions) {
    // Extract unique years from transactions
    years =
        transactions
            .map((t) => t.transactionDate.year.toString())
            .toSet()
            .toList()
          ..sort(
            (a, b) => int.parse(b).compareTo(int.parse(a)),
          ); // descending order

    // Extract unique months
    months = transactions
        .map((t) => DateFormat('MMMM').format(t.transactionDate))
        .toSet()
        .toList();

    // Extract unique days
    dates = transactions
        .map((t) => t.transactionDate.day.toString())
        .toSet()
        .toList();
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

  Future<void> _refreshData() async {
    try {
      await Future.wait([loadWallet(), _loadTransactions()]);
    } catch (e) {
      // print('Refresh failed: $e');
    }
  }

  Future<void> loadWallet() async {
    try {
      final Wallet? data = await AuthService.fetchWallet(); // now nullable
      if (data != null) {
        setState(() {
          _balance = data.totalBalance;
          _selfCreditedAmount = data.selfLoadedAmount;
          _companyCreditedAmount = data.companyLoadedAmount;
          _cashbackAmount = data.cashbackAmount;
          _creditLimit = data.creditLimit;
          _postPaidUsage = data.postPaidUsage;
          _postPaid = data.postPaid;

          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        // print("⚠️ No wallet found for this user.");
      }
    } catch (e) {
      setState(() => _isLoading = false);
      // print("❌ Wallet API error: $e");
      // print("🔍 Stack trace: $stackTrace");
    }
  }

  List<Transactions> _transactions = [];
  List<Transactions> _filteredTransactions = [];

  Future<void> _loadTransactions() async {
    try {
      // 1️⃣ Fetch transactions from your API
      final transactions = await AuthService.fetchTransactions();

      // 2️⃣ Initialize dynamic filters based on actual transaction data
      _initializeDateFilters(transactions);

      // 3️⃣ Apply filters (if any) and update state
      setState(() {
        _transactions = transactions;
        _filteredTransactions = _applyFilters(transactions);
      });

      // print("✅ Transactions fetched: ${transactions.length}");
      // print("🗓️ Available Years: $years");
      // print("🗓️ Available Months: $months");
      // print("🗓️ Available Dates: $dates");
    } catch (e) {
      // print("⚠️ Failed to load transactions: $e");
    }
  }

  List<Transactions> _applyFilters(List<Transactions> transactions) {
    if (selectedYear == null &&
        selectedMonth == null &&
        selectedWeek == null &&
        selectedDate == null) {
      return transactions;
    }

    return transactions.where((transaction) {
      final date = transaction.transactionDate;
      final yearMatch =
          selectedYear == null || date.year.toString() == selectedYear;

      final monthMatch =
          selectedMonth == null ||
          DateFormat('MMMM').format(date) == selectedMonth;

      final weekMatch =
          selectedWeek == null ||
          ((date.day / 7).ceil().toString() ==
              selectedWeek?.replaceAll('Week ', ''));

      final dayMatch =
          selectedDate == null || date.day.toString() == selectedDate;

      return yearMatch && monthMatch && weekMatch && dayMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50), // or your needed height
        child: AppBar(
          title: Text("Wallet"),
          centerTitle: true,
          backgroundColor: Colors.white,
        ),
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            key: _refreshIndicatorKey,
            onRefresh: _refreshData,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Column(
                  children: [
                    _buildHeaderCard(),
                    _build_history_filters(),
                    Expanded(
                      child: _filteredTransactions.isEmpty
                          ? Center(
                              child: Text(
                                "No transactions found",
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: Colors.grey,
                                ),
                              ),
                            )
                          : ListView(
                              padding: EdgeInsets.all(6.w),
                              children: _buildTransactionList(),
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      // bottomNavigationBar: SafeArea(top: false, child: home_footer()),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: const [
          BoxShadow(color: Colors.grey, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(color: Colors.black87),
            )
          else
            Column(
              children: [
                Text(
                  "Your Balance:",
                  style: TextStyle(color: Colors.black87, fontSize: 18.sp),
                ),
                Text(
                  "₹${_balance.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontSize: 25.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Column(
                    children: [
                      // 🔹 Self Wallet Card
                      buildWalletCardself(
                        context,
                        "Self",
                        _selfCreditedAmount,
                        icon: Icons.account_balance_wallet,
                        onRefresh: loadWallet,
                        razorpay: _razorpay,
                      ),

                      if (_postPaid) ...[
                        SizedBox(height: 8.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            buildWalletCardcompany(
                              context,
                              "Postpaid Usage",
                              _postPaidUsage,
                              icon: Icons.data_usage,
                            ),
                            buildWalletCardcompany(
                              context,
                              "Credit Limit",
                              _creditLimit,
                              icon: Icons.wallet_membership,
                            ),
                          ],
                        ),
                      ],

                      // 🔹 Company + Cashback Cards
                      SizedBox(height: 8.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          buildWalletCardcompany(
                            context,
                            "Company",
                            _companyCreditedAmount,
                            icon: Icons.business,
                          ),
                          buildWalletCardcompany(
                            context,
                            "Cashback",
                            _cashbackAmount,
                            icon: Icons.wallet_giftcard,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget buildWalletCardself(
    BuildContext context,
    String label,
    dynamic amount, {
    IconData? icon,
    required VoidCallback onRefresh,
    required Razorpay razorpay,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      margin: EdgeInsets.symmetric(horizontal: 10.w),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(16.r),
        ),
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (icon != null)
                      Padding(
                        padding: EdgeInsets.only(right: 10.w),
                        child: Icon(
                          icon,
                          color: Theme.of(context).primaryColor,
                          size: 20.sp,
                        ),
                      ),
                    Text(
                      label.toUpperCase(),
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                Text(
                  "₹${amount.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
            Spacer(),

            ElevatedButton(
              onPressed: () => _userType == "PROFESSIONAL"
                  ? _showAmountBottomSheetProfessionalUser(context, razorpay)
                  : _showAmountBottomSheet(context, razorpay),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB15DC6),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              child: Text(
                'Load Money',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAmountBottomSheet(BuildContext context, Razorpay razorpay) {
    final TextEditingController amountController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        top: false, // bottom sheet doesn't need top safe area
        child: Padding(
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

                    var options = {
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
                    };

                    try {
                      _razorpay.open(options);
                    } catch (e) {}
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
                          letterSpacing: 0.5,
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
      ),
    );
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
                                await loadWallet(); // refresh wallet UI
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

  Widget buildWalletCardcompany(
    BuildContext context,
    String label,
    dynamic amount, {
    IconData? icon,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(16.r),
        ),
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null)
                  Padding(
                    padding: EdgeInsets.only(right: 10.w),
                    child: Icon(
                      icon,
                      color: Theme.of(context).primaryColor,
                      size: 20.sp,
                    ),
                  ),
                Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Text(
              "₹${amount.toStringAsFixed(2)}",
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _build_history_filters() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "History",
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
          if (selectedYear != null ||
              selectedMonth != null ||
              selectedWeek != null ||
              selectedDate != null)
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade400, width: 1),
              ),
              child: IconButton(
                icon: const Icon(Icons.clear, color: Colors.red),
                onPressed: () {
                  setState(() {
                    selectedYear = null;
                    selectedMonth = null;
                    selectedWeek = null;
                    selectedDate = null;
                    _filteredTransactions = _applyFilters(_transactions);
                  });
                },
              ),
            ),

          IconButton(
            icon: Icon(
              Icons.filter_list,
              color: Colors.deepPurple,
              size: 18.sp,
            ),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20.r),
                  ),
                ),
                builder: (context) {
                  return SafeArea(
                    // ← 100% FIX
                    child: Padding(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom + 10.h,
                        left: 16.w,
                        right: 16.w,
                        top: 16.h,
                      ),
                      child: FilterBottomSheet(
                        selectedYear: selectedYear,
                        selectedMonth: selectedMonth,
                        selectedDate: selectedDate,
                        years: years,
                        months: months,
                        dates: dates,
                        onApply: (year, month, week, date) {
                          setState(() {
                            selectedYear = year;
                            selectedMonth = month;
                            selectedWeek = week;
                            selectedDate = date;
                            _filteredTransactions = _applyFilters(
                              _transactions,
                            );
                          });
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTransactionList() {
    final screenWidth = MediaQuery.of(context).size.width;

    // Dynamically scale sizes based on screen width
    final isSmallScreen = screenWidth < 600;
    final double fontSize = isSmallScreen ? 12 : 14;
    final double iconSize = isSmallScreen ? 18 : 22;
    final double verticalMargin = isSmallScreen ? 2 : 4;

    return _filteredTransactions.reversed.map((transaction) {
      IconData icon;
      Color color;

      switch (transaction.transactionType) {
        case 'CASHBACK':
          icon = Icons.wallet_giftcard;
          color = Colors.orange;
          break;
        case 'CREDIT':
          icon = Icons.wallet_giftcard;
          color = Colors.green;
          break;
        case 'DEBIT':
          icon = Icons.shopping_cart;
          color = Colors.red;
          break;
        default:
          icon = Icons.attach_money;
          color = Colors.grey;
      }

      final bool isDebit = transaction.transactionType == 'DEBIT';
      final amountText =
          (isDebit ? "-" : "+") +
          "₹${transaction.amount.abs().toStringAsFixed(2)}";

      return Card(
        elevation: 0.8,
        color: Colors.grey[100],
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: verticalMargin),
        child: ListTile(
          dense: true, // 👈 Makes the tile height smaller
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          leading: CircleAvatar(
            radius: isSmallScreen ? 16 : 20,
            backgroundColor: color,
            child: Icon(icon, color: Colors.white, size: iconSize),
          ),
          title: Text(
            transaction.transactionType.replaceAll("_", " "),
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: fontSize + 1,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Date: ${DateFormat('yyyy-MM-dd').format(transaction.transactionDate)}",
                style: TextStyle(fontSize: fontSize, color: Colors.black87),
              ),
              Text(
                "Report: ${transaction.description}",
                style: TextStyle(fontSize: fontSize, color: Colors.black87),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              Text(
                "Time: ${DateFormat('HH:mm').format(transaction.transactionDate)}",
                style: TextStyle(fontSize: fontSize, color: Colors.black87),
              ),
            ],
          ),
          trailing: Text(
            amountText,
            style: TextStyle(
              color: isDebit ? Colors.red : Colors.green,
              fontWeight: FontWeight.bold,
              fontSize: fontSize + 2,
            ),
          ),
        ),
      );
    }).toList();
  }
}

class FilterBottomSheet extends StatefulWidget {
  final String? selectedYear, selectedMonth, selectedDate;
  final List<String> years, months, dates;
  final Function(String?, String?, String?, String?) onApply;

  const FilterBottomSheet({
    super.key,
    required this.selectedYear,
    required this.selectedMonth,
    required this.selectedDate,
    required this.years,
    required this.months,
    required this.dates,
    required this.onApply,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  String? _year, _month, _week, _date;

  @override
  void initState() {
    super.initState();
    _year = widget.selectedYear;
    _month = widget.selectedMonth;
    _date = widget.selectedDate;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Text(
            "Filter By Date",
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
          ),

          SizedBox(height: 20.h),
          Row(
            children: [
              Expanded(
                child: dropdownField(
                  "Year",
                  _year,
                  widget.years,
                  (val) => setState(() => _year = val),
                ),
              ),
              SizedBox(width: 20.w),
              Expanded(
                child: dropdownField(
                  "Month",
                  _month,
                  widget.months,
                  (val) => setState(() => _month = val),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: dropdownField(
                  "Date",
                  _date,
                  widget.dates,
                  (val) => setState(() => _date = val),
                ),
              ),
            ],
          ),

          SizedBox(height: 10.h),
          ElevatedButton(
            onPressed: () => widget.onApply(_year, _month, _week, _date),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFB15DC6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
            ),
            child: Text(
              "Apply Filter",
              style: TextStyle(color: Colors.white, fontSize: 14.sp),
            ),
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }
}

Widget dropdownField(
  String title,
  String? selectedValue,
  List<String> options,
  Function(String) onChanged,
) {
  return Container(
    width: 80.w,
    height: 50.h,
    padding: EdgeInsets.symmetric(horizontal: 10.w),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10.r),
      border: Border.all(color: Colors.black, width: 2.w),
    ),
    child: DropdownButtonFormField<String>(
      dropdownColor: Colors.white,
      initialValue: selectedValue,
      decoration: InputDecoration(
        border: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(vertical: 10.h),
      ),
      isExpanded: true,
      hint: Text(
        title,
        style: TextStyle(
          color: Colors.black,
          fontSize: 14.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
      onChanged: (String? newValue) {
        if (newValue != null) onChanged(newValue);
      },
      items: options.map((String option) {
        return DropdownMenuItem<String>(
          value: option,
          child: Text(option, style: TextStyle(fontSize: 14.sp)),
        );
      }).toList(),
    ),
  );
}
