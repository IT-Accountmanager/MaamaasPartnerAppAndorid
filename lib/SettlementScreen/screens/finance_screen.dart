import 'package:flutter/material.dart';
import '../../WalletScreen/WalletScreen.dart';
import '../widgets/theme.dart';
import 'CashBilllingScreen.dart';
import 'settlements_tab.dart';
import 'credits_tab.dart';
import 'ledger_tab.dart';

class FinanceScreen extends StatefulWidget {
  const FinanceScreen({super.key});
  @override
  State<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 5, vsync: this);
    _tabs.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: fnBg,
    body: SafeArea(
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: const [
                LedgerTab(),
                SettlementsTab(),
                CreditsTab(),
                CashBillingTab(),
                WalletScreen(),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildHeader() => Container(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
    decoration: const BoxDecoration(
      color: fnCard,
      border: Border(bottom: BorderSide(color: fnBorder)),
    ),
    child: Row(
      children: [
        // ── Back button ──────────────────────────────────────────────────
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: fnBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: fnBorder),
            ),
            child: const Icon(
              Icons.arrow_back_ios_rounded,
              size: 15,
              color: fnText1,
            ),
          ),
        ),
        const SizedBox(width: 10),

        // ── Scrollable tab chips ─────────────────────────────────────────
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _tabChip(label: 'Ledger', index: 0),
                const SizedBox(width: 6),
                _tabChip(label: 'Settlements', index: 1),
                const SizedBox(width: 6),
                _tabChip(label: 'Credits', index: 2),
                const SizedBox(width: 6),
                _tabChip(label: 'Cash Billing', index: 3),
                // const SizedBox(width: 6),
                // _tabChip(label: 'Wallet', index: 4),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  Widget _tabChip({required String label, required int index}) {
    final isActive = _tabs.index == index;

    return GestureDetector(
      onTap: () => _tabs.animateTo(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? Colors
                    .green // 🟢 selected
              : const Color(0xFFE66D33), // 🟧 default
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Colors.white, // ⚪ always white
          ),
        ),
      ),
    );
  }
}
