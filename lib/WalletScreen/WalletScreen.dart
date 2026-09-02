import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Model.dart';
import 'Services.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  // ── Constants ───────────────────────────────────────────────────────────────
  static const Color primaryOrange = Color(0xFFE9692C);
  static const Color pageBg = Color(0xFFF3F4F8);
  static const Color creditColor = Color(0xFF2E9E5B);
  static const Color debitColor = Color(0xFFE6493B);

  // ── Razorpay ────────────────────────────────────────────────────────────────
  static const String _razorpayKey = 'rzp_test_TJECsclCivENpY';
  late Razorpay _razorpay;

  // ── State ───────────────────────────────────────────────────────────────────
  WalletBalance? _walletBalance;
  List<WalletTransaction> _transactions = [];
  List<WalletTransaction> _filteredTransactions = [];
  bool _isLoading = true;
  bool _isPaymentLoading = false;
  String? _errorMessage;

  double _pendingAmount = 0;
  String _pendingOrderId = '';

  // ── Filter State ────────────────────────────────────────────────────────────
  String _activeFilterLabel = 'Filter';
  DateTime? _filterStart;
  DateTime? _filterEnd;

  @override
  void initState() {
    super.initState();
    _initRazorpay();
    _loadData();
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  // ── Razorpay Setup ──────────────────────────────────────────────────────────

  void _initRazorpay() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onPaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _onPaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _onExternalWallet);
  }

  Future<void> _onPaymentSuccess(PaymentSuccessResponse response) async {
    final paymentId = response.paymentId ?? '';
    final orderId = response.orderId ?? _pendingOrderId;

    setState(() => _isPaymentLoading = true);

    try {
      await WalletService.capturePayment(
        paymentId: paymentId,
        amount: _pendingAmount,
        receipt: 'WALLET_${DateTime.now().millisecondsSinceEpoch}',
      );

      // 2. Credit wallet
      final result = await WalletService.addCashAfterPayment(
        amount: _pendingAmount,
        paymentId: paymentId,
        orderId: orderId,
      );

      if (result != null && result.status == 'SUCCESS') {
        _showSnackBar(
          '₹${_pendingAmount.toStringAsFixed(2)} added to your wallet!',
          isError: false,
        );
        await _loadData();
      } else {
        _showSnackBar(
          'Payment received but wallet update failed. Contact support.',
        );
      }
    } catch (e) {
      _showSnackBar('Error updating wallet: $e');
    } finally {
      if (mounted) setState(() => _isPaymentLoading = false);
    }
  }

  void _onPaymentError(PaymentFailureResponse response) {
    setState(() => _isPaymentLoading = false);
    _showSnackBar('Payment failed: ${response.message ?? 'Unknown error'}');
  }

  void _onExternalWallet(ExternalWalletResponse response) {
    setState(() => _isPaymentLoading = false);
    _showSnackBar(
      'External wallet selected: ${response.walletName}',
      isError: false,
    );
  }

  // ── Data Loading ────────────────────────────────────────────────────────────

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        WalletService.fetchWalletBalance(),
        WalletService.fetchTransactions(),
      ]);

      if (mounted) {
        final txns = results[1] as List<WalletTransaction>;
        txns.sort((a, b) {
          final aTime = DateTime.tryParse(a.time) ?? DateTime(0);
          final bTime = DateTime.tryParse(b.time) ?? DateTime(0);
          return bTime.compareTo(aTime); // newest first
        });
        setState(() {
          _walletBalance = results[0] as WalletBalance?;
          _transactions = txns;
          _applyDateFilter();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  // ── Filter Logic ────────────────────────────────────────────────────────────

  void _applyDateFilter() {
    if (_filterStart == null || _filterEnd == null) {
      _filteredTransactions = _transactions;
      return;
    }

    _filteredTransactions = _transactions.where((t) {
      final dt = DateTime.tryParse(t.time);
      if (dt == null) return false;
      return !dt.isBefore(_filterStart!) && !dt.isAfter(_filterEnd!);
    }).toList();
  }

  void _setFilterRange(String label, DateTime start, DateTime end) {
    setState(() {
      _activeFilterLabel = label;
      _filterStart = start;
      _filterEnd = end;
      _applyDateFilter();
    });
  }

  void _clearFilter() {
    setState(() {
      _activeFilterLabel = 'Filter';
      _filterStart = null;
      _filterEnd = null;
      _applyDateFilter();
    });
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        Widget option(String label, VoidCallback onTap) {
          return ListTile(
            title: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            trailing: _activeFilterLabel == label
                ? const Icon(Icons.check_circle, color: primaryOrange)
                : null,
            onTap: onTap,
          );
        }

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 12),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Filter by date',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              option('Today', () {
                final now = DateTime.now();
                final start = DateTime(now.year, now.month, now.day);
                final end = start
                    .add(const Duration(days: 1))
                    .subtract(const Duration(milliseconds: 1));
                Navigator.pop(ctx);
                _setFilterRange('Today', start, end);
              }),
              option('Yesterday', () {
                final now = DateTime.now();
                final today = DateTime(now.year, now.month, now.day);
                final start = today.subtract(const Duration(days: 1));
                final end = today.subtract(const Duration(milliseconds: 1));
                Navigator.pop(ctx);
                _setFilterRange('Yesterday', start, end);
              }),
              option('This Week', () {
                final now = DateTime.now();
                final today = DateTime(now.year, now.month, now.day);
                final start = today.subtract(Duration(days: today.weekday - 1));
                final end = start
                    .add(const Duration(days: 7))
                    .subtract(const Duration(milliseconds: 1));
                Navigator.pop(ctx);
                _setFilterRange('This Week', start, end);
              }),
              option('This Month', () {
                final now = DateTime.now();
                final start = DateTime(now.year, now.month, 1);
                final end = DateTime(
                  now.year,
                  now.month + 1,
                  1,
                ).subtract(const Duration(milliseconds: 1));
                Navigator.pop(ctx);
                _setFilterRange('This Month', start, end);
              }),
              option('Custom Range', () async {
                Navigator.pop(ctx);
                final picked = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: primaryOrange,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (picked != null) {
                  final start = DateTime(
                    picked.start.year,
                    picked.start.month,
                    picked.start.day,
                  );
                  final end = DateTime(
                    picked.end.year,
                    picked.end.month,
                    picked.end.day,
                    23,
                    59,
                    59,
                    999,
                  );
                  _setFilterRange('Custom Range', start, end);
                }
              }),
              if (_filterStart != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _clearFilter();
                    },
                    child: const Text(
                      'Clear Filter',
                      style: TextStyle(color: debitColor),
                    ),
                  ),
                ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  // ── Load Money Flow ─────────────────────────────────────────────────────────

  void _onLoadMoneyTapped() {
    _showAmountDialog();
  }

  void _showAmountDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Add Money',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter the amount you want to add to your wallet'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                prefixText: '₹  ',
                hintText: '0.00',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: primaryOrange, width: 2),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryOrange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              final raw = controller.text.trim();
              final amount = double.tryParse(raw);

              if (amount == null || amount <= 0) {
                _showSnackBar('Please enter a valid amount');
                return;
              }

              Navigator.pop(ctx);
              await _initiatePayment(amount);
            },
            child: const Text(
              'Proceed',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _initiatePayment(double amount) async {
    setState(() => _isPaymentLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final phoneNumber =
          prefs.getString('userPhone') ?? '9999999999'; // fallback

      // Create order on backend first
      final orderData = await WalletService.createOrder(
        amount: amount,
        phoneNumber: phoneNumber,
        description: 'Wallet top-up ₹${amount.toStringAsFixed(2)}',
      );

      final orderId = orderData['id'] ?? orderData['orderId'] ?? '';

      _pendingAmount = amount;
      _pendingOrderId = orderId;

      final options = {
        'key': _razorpayKey,
        'amount': (amount * 100).toInt(),
        'name': 'MaaMaas Partner',
        'description': 'Wallet top-up',
        'order_id': orderId,
        'currency': 'INR',
        'prefill': {'contact': phoneNumber},
        'theme': {'color': '#E9692C'},
      };

      setState(() => _isPaymentLoading = false);
      _razorpay.open(options);
    } catch (e) {
      setState(() => _isPaymentLoading = false);
      _showSnackBar('Could not initiate payment: $e');
    }
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  void _showSnackBar(String message, {bool isError = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? debitColor : creditColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  String _formatAmount(double amount) => '₹${amount.toStringAsFixed(2)}';

  String _fmtDate(String raw) {
    try {
      final utc = DateTime.parse(raw);
      final ist = utc.add(const Duration(hours: 5, minutes: 30));
      return DateFormat('dd MMM yyyy, hh:mm a').format(ist);
    } catch (_) {
      return raw;
    }
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBg,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // _buildAppBar(),
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: primaryOrange,
                          ),
                        )
                      : _errorMessage != null
                      ? _buildError()
                      : _buildContent(),
                ),
              ],
            ),

            if (_isPaymentLoading)
              Container(
                color: Colors.black45,
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: Colors.white),
                      SizedBox(height: 16),
                      Text(
                        'Processing payment…',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── App Bar ─────────────────────────────────────────────────────────────────
  //
  // Widget _buildAppBar() {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  //     child: Stack(
  //       alignment: Alignment.center,
  //       children: [
  //         Align(
  //           alignment: Alignment.centerLeft,
  //           child: Container(
  //             width: 42,
  //             height: 42,
  //             decoration: const BoxDecoration(
  //               color: Colors.white,
  //               shape: BoxShape.circle,
  //             ),
  //             child: IconButton(
  //               icon: const Icon(
  //                 Icons.arrow_back_ios_new,
  //                 size: 18,
  //                 color: Colors.black87,
  //               ),
  //               onPressed: () => Navigator.maybePop(context),
  //             ),
  //           ),
  //         ),
  //         const Text(
  //           'Wallet',
  //           style: TextStyle(
  //             fontSize: 22,
  //             fontWeight: FontWeight.w700,
  //             color: Colors.black,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // ── Error State ─────────────────────────────────────────────────────────────

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64, color: debitColor),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'Something went wrong',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadData,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryOrange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Retry', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  // ── Main Content ────────────────────────────────────────────────────────────

  Widget _buildContent() {
    return RefreshIndicator(
      color: primaryOrange,
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _buildBalanceCard(),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  iconBg: const Color(0xFFE7E1FB),
                  iconColor: const Color(0xFF6C5CE7),
                  label: 'Self',
                  value: _formatAmount(_walletBalance?.selfLoadedAmount ?? 0),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInfoCard(
                  iconBg: const Color(0xFFFCEBD3),
                  iconColor: const Color(0xFFE8A23D),
                  label: 'Cashback',
                  value: _formatAmount(_walletBalance?.cashbackAmount ?? 0),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Transaction History',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
              _buildFilterChip(),
            ],
          ),

          const SizedBox(height: 16),

          if (_filteredTransactions.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Text(
                  _transactions.isEmpty
                      ? 'No transactions yet'
                      : 'No transactions in this range',
                  style: const TextStyle(color: Colors.black45, fontSize: 16),
                ),
              ),
            )
          else
            ..._filteredTransactions.map(
              (t) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _buildTransactionCard(t),
              ),
            ),
        ],
      ),
    );
  }

  // ── Balance Card ────────────────────────────────────────────────────────────

  Widget _buildBalanceCard() {
    final total = _walletBalance?.totalBalance ?? 0.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE9692C), Color(0xFFD8551C)],
        ),
        boxShadow: [
          BoxShadow(
            color: primaryOrange.withOpacity(0.3),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  const SizedBox(width: 12),
                  const Text(
                    'Total Balance',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              ElevatedButton.icon(
                onPressed: _onLoadMoneyTapped,
                icon: const Icon(Icons.add, color: Colors.black87, size: 18),
                label: const Text(
                  'Load Money',
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          Text(
            _formatAmount(total),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  // ── Info Card ───────────────────────────────────────────────────────────────

  Widget _buildInfoCard({
    required Color iconBg,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 15, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  // ── Filter Chip ─────────────────────────────────────────────────────────────

  Widget _buildFilterChip() {
    final bool isActive = _filterStart != null;
    return GestureDetector(
      onTap: _showFilterSheet,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFE7E1FB),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.tune_rounded, size: 18, color: Color(0xFF6C5CE7)),
            const SizedBox(width: 8),
            Text(
              _activeFilterLabel,
              style: const TextStyle(
                color: Color(0xFF6C5CE7),
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
            if (isActive) ...[
              const SizedBox(width: 6),
              GestureDetector(
                onTap: _clearFilter,
                child: const Icon(
                  Icons.close_rounded,
                  size: 16,
                  color: Color(0xFF6C5CE7),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── Transaction Card ────────────────────────────────────────────────────────

  Widget _buildTransactionCard(WalletTransaction txn) {
    final bool isCredit = txn.isCredit;
    final Color amountColor = isCredit ? creditColor : debitColor;
    final Color iconBg = isCredit
        ? const Color(0xFFDFF6E8)
        : const Color(0xFFFBE1DD);
    final Color iconColor = isCredit ? creditColor : debitColor;
    final IconData icon = isCredit
        ? Icons.add_circle_rounded
        : Icons.shopping_bag_rounded;

    final String amountStr = isCredit
        ? '+${_formatAmount(txn.amount)}'
        : '-${_formatAmount(txn.amount)}';

    final String title = isCredit ? 'CREDIT' : 'DEBIT';
    final String description = txn.cashback > 0
        ? 'Cashback ₹${txn.cashback.toStringAsFixed(2)} · ${txn.paymentId}'
        : 'ID: ${txn.paymentId}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 44,
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      amountStr,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: amountColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      _fmtDate(txn.time),
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade400,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: txn.status == 'SUCCESS'
                            ? const Color(0xFFDFF6E8)
                            : const Color(0xFFFBE1DD),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        txn.status,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: txn.status == 'SUCCESS'
                              ? creditColor
                              : debitColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
