import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../Api/food_authservice.dart';
import '../Models/food&beverages/cash_billing_model.dart';

// ─── Design Tokens ─────────────────────────────────────────────────────────────
class _A {
  static const bg = Color(0xFFF7F8FC);
  static const white = Color(0xFFFFFFFF);
  static const border = Color(0xFFEEEFF5);
  static const accent = Color(0xFFE66D33);
  static const accentDark = Color(0xFFE66D33);
  static const accentLight = Color(0xFFF5E8FA);
  static const green = Color(0xFF10B981);
  static const greenLight = Color(0xFFD1FAE5);
  static const greenDark = Color(0xFF059669);
  static const red = Color(0xFFEF4444);
  static const redLight = Color(0xFFFEE2E2);
  static const blue = Color(0xFF3B82F6);
  static const blueLight = Color(0xFFDBEAFE);
  static const amber = Color(0xFFF59E0B);
  static const amberLight = Color(0xFFFEF3C7);
  static const purple = Color(0xFF8B5CF6);
  static const purpleLight = Color(0xFFEDE9FE);
  static const teal = Color(0xFF14B8A6);
  static const tealLight = Color(0xFFCCFBF1);
  static const text1 = Color(0xFF111827);
  static const text2 = Color(0xFF6B7280);
  static const text3 = Color(0xFFB0B3C1);
  static const shadow = Color(0x0A000000);
  static const shadowMd = Color(0x14000000);

  static LinearGradient get gradient => const LinearGradient(
    colors: [accent, accentDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

// ─── Settlement Service ───────────────────────────────────────────────────────
class SettlementService {
  static Future<List<Map<String, dynamic>>> fetchVendorSettlements({
    required int vendorId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token =
          prefs.getString('token') ?? prefs.getString('authToken') ?? '';
      if (token.isEmpty)
        throw Exception('Please login first to access settlements.');
      final res = await http.get(
        Uri.parse(
          'http://staging.maamaas.com:8080/food/api/settlements/vendor/$vendorId',
        ),
        headers: {'accept': '*/*', 'Authorization': 'Bearer $token'},
      );
      if (res.statusCode == 200) {
        final decoded = json.decode(res.body);
        return decoded is List ? List<Map<String, dynamic>>.from(decoded) : [];
      } else if (res.statusCode == 403) {
        throw Exception(
          'Access denied. You do not have permission to view settlements.',
        );
      } else {
        throw Exception('Server error: ${res.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}

// ─── AccountHistoryPage ───────────────────────────────────────────────────────
enum TabType { overview, settlement }

class AccountHistoryPage extends StatefulWidget {
  const AccountHistoryPage({Key? key}) : super(key: key);
  @override
  State<AccountHistoryPage> createState() => _AccountHistoryPageState();
}

class _AccountHistoryPageState extends State<AccountHistoryPage> {
  TabType selectedTab = TabType.overview;

  // Settlement
  List<Map<String, dynamic>> settlementList = [];
  bool isLoadingSettlements = false;
  String? settlementError;

  // Cash Billing
  List<CashBilling> cashBillingList = [];
  bool isLoadingCash = false;
  int currentPage = 0;
  final int size = 10;
  bool hasMore = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // _scrollController.addListener(_onScroll);
  }

  // void _onScroll() {
  //   if (_scrollController.position.pixels >=
  //           _scrollController.position.maxScrollExtent - 200 &&
  //       hasMore &&
  //       !isLoadingCash &&
  //       selectedTab == TabType.cashBilling) {
  //     _loadMoreCash();
  //   }
  // }

  Future<void> fetchSettlementData() async {
    if (isLoadingSettlements) return;
    setState(() {
      isLoadingSettlements = true;
      settlementError = null;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final vendorId = prefs.getInt('vendorId') ?? 0;
      if (vendorId == 0)
        throw Exception('Vendor ID not found. Please login again.');
      final data = await SettlementService.fetchVendorSettlements(
        vendorId: vendorId,
      );
      setState(() => settlementList = data);
    } catch (e) {
      setState(() {
        settlementError = e.toString();
        settlementList = [];
      });
      _snack('Error: $e', _A.red);
    } finally {
      setState(() => isLoadingSettlements = false);
    }
  }

  Future<void> fetchCashBilling({int page = 0}) async {
    if (isLoadingCash) return;
    setState(() => isLoadingCash = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final vendorId = prefs.getInt('vendorId') ?? 0;
      final uri = Uri.parse(
        'http://staging.maamaas.com:8080/food/api/cash-billing/vendor/billing?'
        'vendorId=$vendorId&page=$page&size=$size&sortField=id&sortDir=desc',
      );
      final res = await http.get(uri);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final fetched = (data['content'] as List)
            .map((e) => CashBilling.fromJson(e))
            .toList();
        setState(() {
          if (page == 0)
            cashBillingList = fetched;
          else
            cashBillingList.addAll(fetched);
          currentPage = data['number'] ?? page;
          hasMore = currentPage < (data['totalPages'] ?? 1) - 1;
        });
      } else {
        throw Exception('Failed to load: ${res.statusCode}');
      }
    } catch (e) {
      // debugPrint('Cash billing error: $e');
      if (mounted && page == 0) _snack('Failed to load cash records', _A.amber);
    } finally {
      setState(() => isLoadingCash = false);
    }
  }

  Future<void> _loadMoreCash() async {
    if (!hasMore || isLoadingCash) return;
    await fetchCashBilling(page: currentPage + 1);
  }

  void _snack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // ── BUILD ─────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _A.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: const BoxDecoration(
        color: _A.white,
        border: Border(bottom: BorderSide(color: _A.border, width: 1)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _A.bg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _A.border),
              ),
              child: const Icon(
                Icons.arrow_back_ios_rounded,
                color: _A.text1,
                size: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Account Management',
                  style: TextStyle(
                    color: _A.text1,
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                    letterSpacing: -0.3,
                  ),
                ),

              ],
            ),
          ),

        ],
      ),
    );
  }

  // ── Tab Bar ───────────────────────────────────────────────────────────────────
  Widget _buildTabBar() {
    final tabs = [
      {
        'tab': TabType.overview,
        'label': 'Overview',
        'icon': Icons.dashboard_rounded,
      },
      {
        'tab': TabType.settlement,
        'label': 'Settlement',
        'icon': Icons.account_balance_rounded,
      },
      // {
      //   'tab': TabType.cashBilling,
      //   'label': 'Cash',
      //   'icon': Icons.payments_rounded,
      // },
    ];

    return Container(
      color: _A.white,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: _A.bg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _A.border),
            ),
            child: Row(
              children: tabs.map((t) {
                final isSelected = selectedTab == t['tab'];
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() => selectedTab = t['tab'] as TabType);
                      if (t['tab'] == TabType.settlement &&
                          settlementList.isEmpty &&
                          settlementError == null)
                        fetchSettlementData();
                      // if (t['tab'] == TabType.cashBilling &&
                      //     cashBillingList.isEmpty)
                      //   fetchCashBilling();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: isSelected ? _A.gradient : null,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: _A.accent.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            t['icon'] as IconData,
                            size: 14,
                            color: isSelected ? Colors.white : _A.text2,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            t['label'] as String,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isSelected ? Colors.white : _A.text2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          const Divider(color: _A.border, height: 1),
        ],
      ),
    );
  }

  // ── Content ───────────────────────────────────────────────────────────────────
  Widget _buildContent() {
    switch (selectedTab) {
      case TabType.overview:
        return OverviewDashboard(
          onSettlementTap: () {
            setState(() => selectedTab = TabType.settlement);
            fetchSettlementData();
          },
        );
      case TabType.settlement:
        return _buildSettlementSection();
      // case TabType.cashBilling:
      //   return _buildCashBillingSection();
    }
  }

  // ── Settlement Section ────────────────────────────────────────────────────────
  Widget _buildSettlementSection() {
    if (isLoadingSettlements) return _buildLoader(_A.accent);

    if (settlementError != null) {
      return _buildErrorState(
        'Failed to Load Settlements',
        settlementError!,
        onRetry: fetchSettlementData,
      );
    }

    if (settlementList.isEmpty) {
      return _buildEmptyState(
        Icons.account_balance_rounded,
        'No Settlements Yet',
        'Your settlement history will appear here once you have completed transactions.',
        onAction: fetchSettlementData,
        actionLabel: 'Load Settlements',
      );
    }

    return RefreshIndicator(
      onRefresh: fetchSettlementData,
      color: _A.accent,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        itemCount: settlementList.length,
        itemBuilder: (_, i) => _buildSettlementCard(settlementList[i], i),
      ),
    );
  }

  // ── Settlement Card ───────────────────────────────────────────────────────────
  Widget _buildSettlementCard(Map<String, dynamic> txn, int index) {
    final double grandTotal = (txn['totalGrandTotal'] ?? 0).toDouble();
    final double svcCharges = (txn['totalServiceCharges'] ?? 0).toDouble();
    final double platCharges = (txn['totalPlatformCharges'] ?? 0).toDouble();
    final double cgst = (txn['totalCgst'] ?? 0).toDouble();
    final double sgst = (txn['totalSgst'] ?? 0).toDouble();
    final double tds = (txn['tdsAmount'] ?? 0).toDouble();
    final double finalAmount = (txn['finalAmount'] ?? 0).toDouble();
    final double totalCash = (txn['totalCash'] ?? 0).toDouble();
    final double totalOnline = (txn['totalOnlinePayment'] ?? 0).toDouble();
    final double totalWallet = (txn['totalWalletPayment'] ?? 0).toDouble();
    final double vendorPlat = (txn['totalVendorPlatformCharges'] ?? 0)
        .toDouble();
    final double vendorPlatGst = (txn['totalVendorPlatformChargesGst'] ?? 0)
        .toDouble();
    final double commission = (txn['commission'] ?? 0).toDouble();
    final double? amtAfterCash = txn['amountAfterCash'] != null
        ? (txn['amountAfterCash'] as num).toDouble()
        : null;

    final double gstTotal = cgst + sgst;
    final double vendorPlatTotal = vendorPlat + vendorPlatGst;
    final double otherDeductions =
        svcCharges +
        platCharges +
        tds +
        gstTotal +
        vendorPlatTotal +
        commission;

    double cashDeduction = 0;
    if (amtAfterCash == null) {
      final nonCash = totalOnline + totalWallet;
      final actualCash = finalAmount > nonCash ? finalAmount - nonCash : 0.0;
      cashDeduction = (totalCash - actualCash).clamp(0.0, double.infinity);
    } else {
      cashDeduction = (totalCash - amtAfterCash).clamp(0.0, double.infinity);
    }

    final double totalDeductions = otherDeductions + cashDeduction;
    final double netAmount = grandTotal - totalDeductions;
    final status = txn['paymentStatus']?.toString() ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: _A.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _A.border),
        boxShadow: [
          const BoxShadow(
            color: _A.shadow,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Card Header ────────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
            decoration: BoxDecoration(
              color: _A.accentLight.withOpacity(0.3),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    gradient: _A.gradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.account_balance_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Settlement #${txn["settlementId"] ?? "N/A"}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: _A.text1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        txn["description"]?.toString() ?? "Settlement",
                        style: const TextStyle(fontSize: 11, color: _A.text2),
                      ),
                    ],
                  ),
                ),
                _statusBadge(status),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // ── Gross earnings ─────────────────────────────────────────────────
                _sectionLabel(
                  'Gross Earnings',
                  Icons.trending_up_rounded,
                  _A.green,
                ),
                const SizedBox(height: 8),
                _amountRow(
                  'Total',
                  '₹${grandTotal.toStringAsFixed(2)}',
                  _A.text1,
                  bold: true,
                ),
                const SizedBox(height: 6),
                if (totalCash > 0)
                  _paymentMethodRow(
                    'Cash',
                    totalCash,
                    Icons.money_rounded,
                    _A.amber,
                  ),
                if (totalOnline > 0)
                  _paymentMethodRow(
                    'Online',
                    totalOnline,
                    Icons.credit_card_rounded,
                    _A.blue,
                  ),
                if (totalWallet > 0)
                  _paymentMethodRow(
                    'Wallet',
                    totalWallet,
                    Icons.account_balance_wallet_rounded,
                    _A.purple,
                  ),

                const SizedBox(height: 14),
                const Divider(color: _A.border, height: 1),
                const SizedBox(height: 14),

                // ── Deductions ─────────────────────────────────────────────────────
                _sectionLabel(
                  'Deductions',
                  Icons.remove_circle_outline_rounded,
                  _A.red,
                ),
                const SizedBox(height: 8),
                if (svcCharges > 0)
                  _deductionRow('Service Charges', svcCharges),
                if (platCharges > 0)
                  _deductionRow('Platform Charges', platCharges),
                if (gstTotal > 0)
                  _deductionRow(
                    'GST (CGST + SGST)',
                    gstTotal,
                    tooltip:
                        'CGST: ₹${cgst.toStringAsFixed(2)} + SGST: ₹${sgst.toStringAsFixed(2)}',
                  ),
                if (tds > 0) _deductionRow('TDS', tds),
                if (cashDeduction > 0)
                  _deductionRow(
                    'Cash Deduction',
                    cashDeduction,
                    tooltip: 'Deduction applied to cash payments',
                  ),
                if (vendorPlatTotal > 0)
                  _deductionRow(
                    'Vendor Platform Charges',
                    vendorPlatTotal,
                    tooltip:
                        'Platform: ₹${vendorPlat.toStringAsFixed(2)} + GST: ₹${vendorPlatGst.toStringAsFixed(2)}',
                  ),
                if (commission > 0) _deductionRow('Commission', commission),
                const SizedBox(height: 6),
                if (totalDeductions > 0)
                  _amountRow(
                    'Total Deductions',
                    '- ₹${totalDeductions.toStringAsFixed(2)}',
                    _A.red,
                    bold: true,
                  ),

                const SizedBox(height: 14),
                const Divider(color: _A.border, height: 1),
                const SizedBox(height: 14),

                // ── Net calculation ────────────────────────────────────────────────
                _sectionLabel('Summary', Icons.calculate_rounded, _A.blue),
                const SizedBox(height: 8),
                _amountRow(
                  'Gross Earnings',
                  '₹${grandTotal.toStringAsFixed(2)}',
                  _A.text1,
                ),
                _amountRow(
                  'Total Deductions',
                  '- ₹${totalDeductions.toStringAsFixed(2)}',
                  _A.red,
                ),
                const SizedBox(height: 6),
                Container(
                  height: 1.5,
                  decoration: BoxDecoration(gradient: _A.gradient),
                ),
                const SizedBox(height: 6),
                _amountRow(
                  'Net Amount',
                  '₹${netAmount.toStringAsFixed(2)}',
                  _A.blue,
                  bold: true,
                ),

                const SizedBox(height: 14),

                // ── Final amount box ───────────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: finalAmount >= 0
                          ? [
                              _A.green.withOpacity(0.08),
                              _A.greenLight.withOpacity(0.3),
                            ]
                          : [
                              _A.amber.withOpacity(0.08),
                              _A.amberLight.withOpacity(0.3),
                            ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: (finalAmount >= 0 ? _A.green : _A.amber)
                          .withOpacity(0.25),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: (finalAmount >= 0 ? _A.green : _A.amber)
                              .withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          finalAmount >= 0
                              ? Icons.check_circle_rounded
                              : Icons.warning_rounded,
                          color: finalAmount >= 0 ? _A.green : _A.amber,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              finalAmount >= 0
                                  ? 'Final Payable Amount'
                                  : 'Adjustment Required',
                              style: TextStyle(
                                color: finalAmount >= 0
                                    ? _A.greenDark
                                    : _A.amber,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '₹${finalAmount.abs().toStringAsFixed(2)}',
                              style: TextStyle(
                                color: finalAmount >= 0
                                    ? _A.greenDark
                                    : _A.amber,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Cash summary ───────────────────────────────────────────────────
                if (totalCash > 0) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _A.blueLight.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _A.blue.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.money_rounded,
                              color: _A.blue,
                              size: 14,
                            ),
                            const SizedBox(width: 5),
                            const Text(
                              'Cash Summary',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: _A.blue,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _amountRow(
                          'Total Cash Collected',
                          '₹${totalCash.toStringAsFixed(2)}',
                          _A.blue,
                        ),
                        if (cashDeduction > 0)
                          _amountRow(
                            'Cash Deduction',
                            '- ₹${cashDeduction.toStringAsFixed(2)}',
                            _A.red,
                          ),
                        _amountRow(
                          'Net Cash',
                          '₹${(totalCash - cashDeduction).toStringAsFixed(2)}',
                          _A.greenDark,
                          bold: true,
                        ),
                      ],
                    ),
                  ),
                ],

                // ── Footer ─────────────────────────────────────────────────────────
                const SizedBox(height: 14),
                const Divider(color: _A.border, height: 1),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _footerInfo(
                        'Settlement Date',
                        txn["settlementDate"]?.toString() ?? 'N/A',
                        Icons.calendar_today_rounded,
                      ),
                    ),
                    Expanded(
                      child: _footerInfo(
                        'Payment Mode',
                        txn["pytMode"]?.toString() ?? 'N/A',
                        Icons.credit_card_rounded,
                        align: CrossAxisAlignment.end,
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

  // ── Cash Billing Section ──────────────────────────────────────────────────────
  Widget _buildCashBillingSection() {
    if (cashBillingList.isEmpty && !isLoadingCash) {
      return _buildEmptyState(
        Icons.payments_rounded,
        'No Cash Records',
        'Cash billing information will appear here',
      );
    }
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: cashBillingList.length + (hasMore ? 1 : 0),
      itemBuilder: (_, i) {
        if (i >= cashBillingList.length)
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(
                color: _A.accent,
                strokeWidth: 2,
              ),
            ),
          );
        return _buildCashBillingCard(cashBillingList[i], i);
      },
    );
  }

  Widget _buildCashBillingCard(CashBilling cash, int index) {
    final totalNotes =
        cash.twoThousandRupee +
        cash.fiveHundredRupee +
        cash.twoHundredRupee +
        cash.hundredRupee +
        cash.fiftyRupee +
        cash.twentyRupee +
        cash.tenRupee +
        cash.fiveRupee +
        cash.twoRupee +
        cash.oneRupee;

    final denominations = [
      {'label': '₹2000', 'count': cash.twoThousandRupee},
      {'label': '₹500', 'count': cash.fiveHundredRupee},
      {'label': '₹200', 'count': cash.twoHundredRupee},
      {'label': '₹100', 'count': cash.hundredRupee},
      {'label': '₹50', 'count': cash.fiftyRupee},
      {'label': '₹20', 'count': cash.twentyRupee},
      {'label': '₹10', 'count': cash.tenRupee},
      {'label': '₹5', 'count': cash.fiveRupee},
      {'label': '₹2', 'count': cash.twoRupee},
      {'label': '₹1', 'count': cash.oneRupee},
    ].where((d) => (d['count'] as int) > 0).toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: _A.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _A.border),
        boxShadow: [
          const BoxShadow(
            color: _A.shadow,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
            decoration: BoxDecoration(
              color: _A.amberLight.withOpacity(0.4),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [_A.amber, Color(0xFFD97706)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.money_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Order #${cash.orderId}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: _A.text1,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _A.amberLight,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _A.amber.withOpacity(0.3)),
                  ),
                  child: const Text(
                    'CASH',
                    style: TextStyle(
                      color: _A.amber,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Amount summary
                Row(
                  children: [
                    Expanded(
                      child: _amountBox(
                        'Grand Total',
                        '₹${cash.grandTotal}',
                        _A.blue,
                        _A.blueLight,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _amountBox(
                        'Paid',
                        '₹${cash.paid}',
                        _A.green,
                        _A.greenLight,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _amountBox(
                        'Return',
                        '₹${cash.returnMoney}',
                        _A.amber,
                        _A.amberLight,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),
                const Divider(color: _A.border, height: 1),
                const SizedBox(height: 12),

                // Cash breakdown
                Row(
                  children: [
                    const Icon(
                      Icons.receipt_long_rounded,
                      color: _A.text2,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Cash Denomination Breakdown',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _A.text1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                if (denominations.isEmpty)
                  const Center(
                    child: Text(
                      'No denominations recorded',
                      style: TextStyle(fontSize: 12, color: _A.text3),
                    ),
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: denominations.map((d) {
                      final count = d['count'] as int;
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _A.bg,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: _A.border),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              d['label'] as String,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: _A.text1,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _A.greenLight,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '×$count',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: _A.greenDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),

                const SizedBox(height: 10),
                const Divider(color: _A.border, height: 1),
                const SizedBox(height: 8),

                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Total Notes',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _A.text2,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _A.blueLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$totalNotes notes',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: _A.blue,
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

  // ── Shared Widgets ────────────────────────────────────────────────────────────
  Widget _statusBadge(String status) {
    Color color;
    Color bg;
    switch (status.toLowerCase()) {
      case 'paid':
      case 'completed':
        color = _A.greenDark;
        bg = _A.greenLight;
        break;
      case 'pending':
        color = _A.amber;
        bg = _A.amberLight;
        break;
      case 'failed':
      case 'rejected':
        color = _A.red;
        bg = _A.redLight;
        break;
      default:
        color = _A.blue;
        bg = _A.blueLight;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Text(
        status.isEmpty ? '--' : status,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _sectionLabel(String label, IconData icon, Color color) => Row(
    children: [
      Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, color: color, size: 13),
      ),
      const SizedBox(width: 7),
      Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    ],
  );

  Widget _amountRow(
    String label,
    String value,
    Color valueColor, {
    bool bold = false,
  }) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: _A.text2,
              fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    ),
  );

  Widget _deductionRow(String label, double amount, {String? tooltip}) {
    final row = Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 4,
            decoration: const BoxDecoration(
              color: _A.red,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 11, color: _A.text2),
            ),
          ),
          if (tooltip != null)
            const Icon(Icons.info_outline_rounded, size: 12, color: _A.text3),
          if (tooltip != null) const SizedBox(width: 4),
          Text(
            '- ₹${amount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _A.red,
            ),
          ),
        ],
      ),
    );
    return tooltip != null ? Tooltip(message: tooltip, child: row) : row;
  }

  Widget _paymentMethodRow(
    String label,
    double amount,
    IconData icon,
    Color color,
  ) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Icon(icon, size: 11, color: color),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 11, color: _A.text2),
          ),
        ),
        Text(
          '₹${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    ),
  );

  Widget _footerInfo(
    String label,
    String value,
    IconData icon, {
    CrossAxisAlignment align = CrossAxisAlignment.start,
  }) => Column(
    crossAxisAlignment: align,
    children: [
      Row(
        mainAxisAlignment: align == CrossAxisAlignment.end
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          Icon(icon, size: 11, color: _A.text3),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 10, color: _A.text3)),
        ],
      ),
      const SizedBox(height: 2),
      Text(
        value,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: _A.text2,
        ),
      ),
    ],
  );

  Widget _amountBox(String label, String value, Color color, Color bg) =>
      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: bg.withOpacity(0.5),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: _A.text2,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
          ],
        ),
      );

  Widget _buildLoader(Color color) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: _A.gradient,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.account_balance_rounded,
            color: Colors.white,
            size: 26,
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'Loading...',
          style: TextStyle(
            fontSize: 13,
            color: _A.text2,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );

  Widget _buildErrorState(
    String title,
    String message, {
    required VoidCallback onRetry,
  }) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: _A.redLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              color: _A.red,
              size: 30,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _A.text1,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            message,
            style: const TextStyle(fontSize: 12, color: _A.text2),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: onRetry,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                gradient: _A.gradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.refresh_rounded, color: Colors.white, size: 16),
                  SizedBox(width: 6),
                  Text(
                    'Try Again',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildEmptyState(
    IconData icon,
    String title,
    String subtitle, {
    VoidCallback? onAction,
    String? actionLabel,
  }) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: _A.gradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _A.accent.withOpacity(0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 32),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: _A.text1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 12, color: _A.text2),
            textAlign: TextAlign.center,
          ),
          if (onAction != null) ...[
            const SizedBox(height: 20),
            GestureDetector(
              onTap: onAction,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  gradient: _A.gradient,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: _A.accent.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.refresh_rounded,
                      color: Colors.white,
                      size: 15,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      actionLabel ?? 'Refresh',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    ),
  );
}

// ─── OverviewDashboard ────────────────────────────────────────────────────────
class OverviewDashboard extends StatefulWidget {
  final VoidCallback onSettlementTap;
  const OverviewDashboard({Key? key, required this.onSettlementTap})
    : super(key: key);
  @override
  State<OverviewDashboard> createState() => _OverviewDashboardState();
}

class _OverviewDashboardState extends State<OverviewDashboard> {
  List<Map<String, dynamic>> allOrders = [];
  List<Map<String, dynamic>> filteredOrders = [];
  Map<String, double> overviewData = {
    'Total Income': 0,
    'Wallet Income': 0,
    'Online Income': 0,
    'Cash Income': 0,
  };
  String selectedFilter = 'Today';
  final List<String> filters = [
    'Custom',
    'Today',
    'Weekly',
    'Monthly',
    'Yearly',
  ];
  bool _isLoadingOrders = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoadingOrders = true);
    try {
      allOrders = await food_authservice.getAllOrders();
      _applyFilter('Today');
    } catch (e) {
      // debugPrint('Error loading orders: $e');
    } finally {
      setState(() => _isLoadingOrders = false);
    }
  }

  bool _isWithin(DateTime date, DateTime? start, DateTime? end) {
    if (start != null && date.isBefore(start)) return false;
    if (end != null && date.isAfter(end)) return false;
    return true;
  }

  void _applyFilter(String filter) {
    DateTime now = DateTime.now();
    DateTime? start;
    DateTime? end = now;
    switch (filter) {
      case 'Today':
        start = DateTime(now.year, now.month, now.day);
        break;
      case 'Weekly':
        start = now.subtract(const Duration(days: 7));
        break;
      case 'Monthly':
        start = DateTime(now.year, now.month, 1);
        break;
      case 'Yearly':
        start = DateTime(now.year, 1, 1);
        break;
      case 'Custom':
        return;
    }
    double total = 0, wallet = 0, online = 0, cash = 0;
    for (var o in allOrders) {
      try {
        final dt = DateTime.parse(o['orderDateAndTime']);
        if (!_isWithin(dt, start, end)) continue;
        final amount = (o['totalAmount'] ?? 0).toDouble();
        total += amount;
        final method = o['paymentMethod'];
        if (method == 'Maamaas_Wallet') wallet += amount;
        if (method == 'Online_Payment') online += amount;
        if (method == 'Cash') cash += amount;
      } catch (_) {}
    }
    final tx =
        allOrders.where((o) {
          try {
            return _isWithin(DateTime.parse(o['orderDateAndTime']), start, end);
          } catch (_) {
            return false;
          }
        }).toList()..sort(
          (a, b) => DateTime.parse(
            b['orderDateAndTime'],
          ).compareTo(DateTime.parse(a['orderDateAndTime'])),
        );
    setState(() {
      overviewData = {
        'Total Income': total,
        'Wallet Income': wallet,
        'Online Income': online,
        'Cash Income': cash,
      };
      filteredOrders = tx;
      selectedFilter = filter;
    });
  }

  Future<void> _pickCustomDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: DateTime.now().subtract(const Duration(days: 7)),
        end: DateTime.now(),
      ),
      builder: (ctx, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(primary: _A.accent),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    double total = 0, wallet = 0, online = 0, cash = 0;
    for (var o in allOrders) {
      try {
        final dt = DateTime.parse(o['orderDateAndTime']);
        if (!_isWithin(dt, picked.start, picked.end)) continue;
        final amount = (o['totalAmount'] ?? 0).toDouble();
        total += amount;
        final method = o['paymentMethod'];
        if (method == 'Maamaas_Wallet') wallet += amount;
        if (method == 'Online_Payment') online += amount;
        if (method == 'Cash') cash += amount;
      } catch (_) {}
    }
    final tx =
        allOrders.where((o) {
          try {
            return _isWithin(
              DateTime.parse(o['orderDateAndTime']),
              picked.start,
              picked.end,
            );
          } catch (_) {
            return false;
          }
        }).toList()..sort(
          (a, b) => DateTime.parse(
            b['orderDateAndTime'],
          ).compareTo(DateTime.parse(a['orderDateAndTime'])),
        );
    setState(() {
      overviewData = {
        'Total Income': total,
        'Wallet Income': wallet,
        'Online Income': online,
        'Cash Income': cash,
      };
      filteredOrders = tx;
      selectedFilter = 'Custom';
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildFilterBar(),
          _buildSummaryCards(),
          _buildRecentActivity(),
        ],
      ),
    );
  }

  // ── Filter Bar ────────────────────────────────────────────────────────────────
  Widget _buildFilterBar() => Container(
    color: _A.white,
    padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((f) {
          final isSelected = f == selectedFilter;
          return GestureDetector(
            onTap: () {
              if (f == 'Custom')
                _pickCustomDateRange();
              else
                _applyFilter(f);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                gradient: isSelected ? _A.gradient : null,
                color: isSelected ? null : _A.bg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: isSelected ? _A.accent : _A.border),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: _A.accent.withOpacity(0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (f == 'Custom') ...[
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 12,
                      color: isSelected ? Colors.white : _A.accent,
                    ),
                    const SizedBox(width: 5),
                  ],
                  Text(
                    f,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white : _A.text2,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    ),
  );

  // ── Summary Cards ─────────────────────────────────────────────────────────────
  Widget _buildSummaryCards() {
    final cards = [
      {
        'title': 'Total Income',
        'icon': Icons.attach_money_rounded,
        'colors': [const Color(0xFF3B82F6), const Color(0xFF2563EB)],
      },
      {
        'title': 'Wallet Income',
        'icon': Icons.account_balance_wallet_rounded,
        'colors': [const Color(0xFFF59E0B), const Color(0xFFD97706)],
      },
      {
        'title': 'Online Income',
        'icon': Icons.credit_card_rounded,
        'colors': [const Color(0xFF10B981), const Color(0xFF059669)],
      },
      {
        'title': 'Cash Income',
        'icon': Icons.money_rounded,
        'colors': [_A.accent, _A.accentDark],
      },
    ];

    if (_isLoadingOrders) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(12),
        itemCount: 4,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.2,
        ),
        itemBuilder: (_, __) => Container(
          decoration: BoxDecoration(
            color: _A.border,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Center(
            child: CircularProgressIndicator(color: _A.accent, strokeWidth: 2),
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(12),
      itemCount: cards.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemBuilder: (_, i) {
        final card = cards[i];
        final value = overviewData[card['title'] as String] ?? 0.0;
        final colors = card['colors'] as List<Color>;
        return AnimatedContainer(
          duration: Duration(milliseconds: 400 + (i * 100)),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: colors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: colors[0].withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(
                    card['icon'] as IconData,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      card['title'] as String,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '₹${value.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
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

  // ── Recent Activity ───────────────────────────────────────────────────────────
  Widget _buildRecentActivity() {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _A.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _A.border),
        boxShadow: [
          const BoxShadow(
            color: _A.shadow,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Recent Activity',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: _A.text1,
                ),
              ),
              const Spacer(),
              if (filteredOrders.isNotEmpty)
                Text(
                  '${filteredOrders.length} txns',
                  style: const TextStyle(fontSize: 11, color: _A.text3),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (filteredOrders.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Column(
                  children: [
                    Icon(Icons.receipt_long_rounded, size: 40, color: _A.text3),
                    SizedBox(height: 8),
                    Text(
                      'No transactions',
                      style: TextStyle(fontSize: 13, color: _A.text2),
                    ),
                  ],
                ),
              ),
            )
          else
            ...filteredOrders.take(5).map((o) => _buildTransactionTile(o)),
          if (filteredOrders.length > 5) ...[
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Showing 5 of ${filteredOrders.length} transactions',
                style: const TextStyle(fontSize: 11, color: _A.text3),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTransactionTile(Map<String, dynamic> order) {
    DateTime? date;
    try {
      date = DateTime.parse(order['orderDateAndTime']);
    } catch (_) {}
    final formatted = date != null
        ? '${date.day}/${date.month}/${date.year} · ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}'
        : '--';
    final method = order['paymentMethod']?.toString() ?? '';
    final methodColor = method == 'Cash'
        ? _A.amber
        : method == 'Online_Payment'
        ? _A.blue
        : _A.purple;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _A.bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _A.border),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: _A.gradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.receipt_long_rounded,
              color: Colors.white,
              size: 17,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order #${order['orderId']}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: _A.text1,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: methodColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        method.replaceAll('_', ' '),
                        style: TextStyle(
                          color: methodColor,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      formatted,
                      style: const TextStyle(color: _A.text3, fontSize: 9),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Text(
            '₹${order['totalAmount']}',
            style: const TextStyle(
              color: _A.green,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
