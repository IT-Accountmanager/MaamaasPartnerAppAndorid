
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/report_models.dart';
import '../widgets/theme.dart';

class PaymentsTab extends StatelessWidget {
  final ReportData? data;
  final bool isLoading;
  const PaymentsTab({super.key, this.data, this.isLoading = false});


  static const _methodConfig = {
    'Cash': (label: 'Cash', color: rpGreen, icon: Icons.payments_outlined),

    // 'Online_Payment': (
    //   label: 'Online',
    //   color: rpBlue,
    //   icon: Icons.credit_card_outlined,
    // ),

    'USER_ONLINE_PAYMENT': (
    label: 'Online',
    color: rpBlue,
    icon: Icons.credit_card_outlined,
    ),

    'UPI': (label: 'UPI', color: rpPurple, icon: Icons.qr_code_2_outlined),

    'Maamaas_Wallet': (
    label: ' Wallet',
    color: rpAmber,
    icon: Icons.account_balance_wallet_outlined,
    ),
  };
  @override
  Widget build(BuildContext context) {
    if (isLoading) return _shimmer();
    if (data == null)
      return const RpEmpty(
        message: 'No payments data.',
        icon: Icons.credit_card_outlined,
      );

    final total = data!.paymentBreakdown.entries
        .where((e) => e.key != 'Online_Payment')
        .fold(0.0, (s, e) => s + e.value);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
          decoration: _rpCardDecoWithShadow(),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _statCell(
                        total.toStringAsFixed(2),
                        'Total Collected',
                        rpGreen,
                        Icons.currency_rupee_rounded,
                      ),
                    ),
                    _vertDivider(),
                    Expanded(
                      child: _statCell(
                        data!.refundAmount.toStringAsFixed(2),
                        'Refund Amount',
                        rpRed,
                        Icons.undo_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _statCell(
                        '${data!.successfulPayments}',
                        'Successful',
                        rpGreen,
                        Icons.check_circle_outline,
                      ),
                    ),
                    _vertDivider(),
                    Expanded(
                      child: _statCell(
                        '${data!.failedPayments}',
                        'Failed',
                        rpRed,
                        Icons.error_outline_rounded,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),


        // ── Summary table ─────────────────────────────────────────────────────
        const RpSectionHeader(title: 'Collection Summary'),
        Container(
          decoration: rpCardDeco(),
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
            ...data!.paymentBreakdown.entries
        .where((e) => e.key != 'Online_Payment')
        .map((e) {
                final cfg = _methodConfig[e.key];
                final label = cfg?.label ?? e.key.replaceAll('_', ' ');
                final color = cfg?.color ?? rpText2;
                final pct = total > 0 ? e.value / total * 100 : 0.0;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          label,
                          style: const TextStyle(fontSize: 13, color: rpText2),
                        ),
                      ),
                      Text(
                        '${pct.toStringAsFixed(1)}%',
                        style: const TextStyle(fontSize: 11, color: rpText3),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        e.value.toStringAsFixed(2),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                );
              }
              ),
              const Divider(color: rpBorder, height: 20),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Total Collected',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: rpText1,
                      ),
                    ),
                  ),
                  Text(
                    total.toStringAsFixed(2),
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 17,
                      color: rpGreen,
                    ),
                  ),
                ],
              ),
              if (data!.refundAmount > 0) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Refund Amount',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: rpText2,
                        ),
                      ),
                    ),
                    Text(
                      data!.refundAmount.toStringAsFixed(2),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: rpRed,
                      ),
                    ),
                  ],
                ),
              ],
              if (data!.pendingPayments > 0) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Pending Payments',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: rpText2,
                        ),
                      ),
                    ),
                    Text(
                      data!.pendingPayments.toStringAsFixed(2),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: rpAmber,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  BoxDecoration _rpCardDecoWithShadow() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: rpBorder),
      boxShadow: [
        BoxShadow(color: rpShadow, blurRadius: 8, offset: const Offset(0, 3)),
      ],
    );
  }

  Widget _statCell(
    String value,
    String label,
    Color color,
    IconData icon, {
    String? sub,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: rpText2,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: rpText1,
          ),
        ),
        if (sub != null) ...[
          const SizedBox(height: 2),
          Text(
            sub,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }

  Widget _vertDivider() {
    return Container(
      width: 1,
      height: 60,
      color: rpBorder,
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  Widget _shimmer() => Column(
    children: [
      Container(
        margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        height: 140,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: rpBorder),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: rpAccent, strokeWidth: 2),
        ),
      ),
      const SizedBox(height: 16),
      const RpShimmerCard(height: 200),
      const SizedBox(height: 16),
      const RpShimmerCard(height: 200),
    ],
  );
}
