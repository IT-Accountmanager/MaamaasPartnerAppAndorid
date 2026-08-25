import 'package:flutter/material.dart';
import '../models/sub_models.dart';
import '../services/subscription_service.dart';
import '../widgets/theme.dart';

class ActiveModulesScreen extends StatefulWidget {
  final VoidCallback onConfigureTap;
  const ActiveModulesScreen({super.key, required this.onConfigureTap});
  @override
  State<ActiveModulesScreen> createState() => _ActiveModulesScreenState();
}

class _ActiveModulesScreenState extends State<ActiveModulesScreen> {
  ActiveSubscription? _data;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final res = await SubscriptionService.getVendorActiveSubscription();
    if (!mounted) return;

    if (res == null) {
      setState(() => _loading = false);
      return;
    }

    final filtered = res.selectedModules
        .where((m) => m.isOrderType || m.isFeatureAddOn)
        .toList();

    setState(() {
      _data = ActiveSubscription(
        subscriptionId: res.subscriptionId,
        status: res.status,
        billingCycle: res.billingCycle,
        remainingDays: res.remainingDays,
        startDate: res.startDate,
        endDate: res.endDate,
        totalAmount: res.totalAmount,
        selectedModules: filtered,
      );
      _loading = false;
    });
  }

  String _fmtDate(String s) {
    if (s.isEmpty) return '';
    try {
      final parts = s.split('-');
      if (parts.length == 3) return '${parts[2]}-${parts[1]}-${parts[0]}';
    } catch (_) {}
    return s;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading)
      return const Center(
        child: CircularProgressIndicator(color: sdAccent, strokeWidth: 2),
      );

    final noData = _data == null || _data!.selectedModules.isEmpty;

    if (noData) return _buildEmpty();

    return RefreshIndicator(
      color: sdAccent,
      onRefresh: _load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Active Header ──────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: sdCardDeco(radius: 14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Active Modules (${_data!.selectedModules.length})',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: sdText1,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${sdTitleCase(_data!.billingCycle)} billing • Total ₹${_data!.totalAmount.toStringAsFixed(0)}',
                          style: const TextStyle(fontSize: 12, color: sdGray),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: widget.onConfigureTap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: sdAccent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Edit Plan',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Module Cards ───────────────────────────────────────────────────
            ..._data!.selectedModules.map((m) => _buildModuleCard(m)),
          ],
        ),
      ),
    );
  }

  Widget _buildModuleCard(ActiveModuleItem m) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    decoration: sdCardDeco(radius: 14),
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top row: name + badge + price
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        sdTitleCase(m.displayName),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: sdText1,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: sdGreenL,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'ACTIVE',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: sdGreenD,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    m.displayCategory,
                    style: const TextStyle(fontSize: 12, color: sdGray),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₹${_data!.totalAmount.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: sdText1,
                  ),
                ),
                const Text(
                  '/ year',
                  style: TextStyle(fontSize: 11, color: sdGray),
                ),
              ],
            ),
          ],
        ),

        const Divider(color: sdBorder, height: 16),

        // Date row: Start | End | Duration | Renews On
        Row(
          children: [
            _dateCol('START', _fmtDate(_data!.startDate)),
            _dateCol('END / EXPIRY', _fmtDate(_data!.endDate)),
            _dateCol('DURATION', '${_data!.remainingDays} days'),
            _dateCol('RENEWS ON', _fmtDate(_data!.endDate)),
          ],
        ),
      ],
    ),
  );

  Widget _dateCol(String label, String value) => Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            color: sdText3,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: sdText1,
          ),
        ),
      ],
    ),
  );

  Widget _buildEmpty() => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFFDEBD3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Text('📄', style: TextStyle(fontSize: 28)),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'No active subscriptions',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: sdText1,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "You haven't selected any modules yet. Configure your plan to see subscription details here.",
            style: TextStyle(fontSize: 13, color: sdGray, height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: widget.onConfigureTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFF97316), Color(0xFFEA6B0E)],
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: sdAccent.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Text(
                'Configure Subscription',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
