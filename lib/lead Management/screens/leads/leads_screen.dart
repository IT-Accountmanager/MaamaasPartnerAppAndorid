import 'package:flutter/material.dart';
import '../../models/lead_model.dart';
import '../../services/auth_service.dart';
import '../../services/lead_service.dart';
import '../../services/razorpay_payment_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';
import '../../widgets/filters_bar.dart';
import '../../widgets/lead_card.dart';
import '../../widgets/state_views.dart';
import '../../widgets/stat_card.dart';

/// Ports Lead.jsx — the list of masked (unpurchased) leads with a
/// "Pay ₹X" button that unlocks the full lead via Razorpay.
class LeadsScreen extends StatefulWidget {
  const LeadsScreen({super.key});

  @override
  State<LeadsScreen> createState() => _LeadsScreenState();
}

class _LeadsScreenState extends State<LeadsScreen> {
  List<LeadModel> _leads = [];
  List<LeadModel> _filtered = [];
  bool _loading = true;
  String _searchTerm = '';
  String _filterType = 'all';
  String? _vendorId;

  late final RazorpayPaymentService _paymentService;
  int? _payingLeadId;

  @override
  void initState() {
    super.initState();
    _paymentService = RazorpayPaymentService()
      ..onSuccess = _onPaymentSuccess
      ..onError = _onPaymentError;
    _fetchLeads();
  }

  @override
  void dispose() {
    _paymentService.dispose();
    super.dispose();
  }

  Future<void> _fetchLeads() async {
    setState(() => _loading = true);
    try {
      final vendorId = await Authservice.getVendorId();
      if (vendorId == null) {
        setState(() => _loading = false);
        return;
      }
      _vendorId = vendorId.toString();
      final leads = await LeadService.getMaskedLeads(_vendorId!);
      setState(() {
        _leads = leads;
        _applyFilters();
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching leads: $e')),
        );
      }
    }
  }

  void _applyFilters() {
    var filtered = List<LeadModel>.from(_leads);

    if (_searchTerm.trim().isNotEmpty) {
      final term = _searchTerm.toLowerCase().trim();
      filtered = filtered
          .where((l) =>
              l.id.toString().contains(term) ||
              l.name.toLowerCase().contains(term) ||
              l.mobile.contains(term))
          .toList();
    }

    if (_filterType != 'all') {
      filtered = filtered.where((l) => l.eventType.toUpperCase() == _filterType.toUpperCase()).toList();
    }

    _filtered = filtered;
  }

  Future<void> _handlePay(LeadModel lead) async {
    if (_vendorId == null) return;
    setState(() => _payingLeadId = lead.id);
    await _paymentService.payForLead(lead: lead, vendorId: _vendorId!);
  }

  void _onPaymentSuccess(LeadModel lead) {
    setState(() => _payingLeadId = null);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Payment successful! Lead purchased.'), backgroundColor: AppColors.success),
    );
    Future.delayed(const Duration(milliseconds: 800), _fetchLeads);
  }

  void _onPaymentError(String message) {
    setState(() => _payingLeadId = null);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('❌ $message'), backgroundColor: AppColors.danger),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalLeads = _filtered.length;
    final totalAmount = _filtered.fold<double>(0, (s, l) => s + l.leadPrice);
    final avgPrice = totalLeads > 0 ? totalAmount / totalLeads : 0;
    final eventTypeCount = _filtered.map((l) => l.eventType).toSet().length;

    return RefreshIndicator(
      onRefresh: _fetchLeads,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          StatsGrid(cards: [
            StatCard(label: 'Total Leads', value: '$totalLeads', subtext: 'Masked leads available'),
            StatCard(label: 'Total Value', value: formatInr(totalAmount), valueColor: AppColors.success, subtext: 'Total lead prices'),
            StatCard(label: 'Avg Price', value: formatInr(avgPrice.round()), valueColor: AppColors.primary, subtext: 'Per lead average'),
            StatCard(label: 'Event Types', value: '$eventTypeCount', valueColor: AppColors.purple, subtext: 'Unique event types'),
          ]),
          const SizedBox(height: 14),
          FiltersBar(
            searchHint: 'Search by ID, Name or Phone...',
            onSearchChanged: (v) => setState(() {
              _searchTerm = v;
              _applyFilters();
            }),
            typeOptions: eventTypeFilterOptions,
            typeValue: _filterType,
            onTypeChanged: (v) => setState(() {
              _filterType = v;
              _applyFilters();
            }),
            onRefresh: _fetchLeads,
          ),
          const SizedBox(height: 14),
          if (_loading)
            const LoadingView(message: 'Loading leads...')
          else if (_filtered.isEmpty)
            EmptyStateView(
              icon: '📭',
              title: 'No Masked Leads Found',
              message: _leads.isEmpty
                  ? 'No masked leads available at the moment.'
                  : 'No leads match your current filters.',
            )
          else
            ..._filtered.map((lead) {
              final isPaying = _payingLeadId == lead.id;
              return LeadCard(
                lead: lead,
                showPrice: false,
                trailing: Row(
                  children: [
                    _PlateBadge(label: 'Veg', value: lead.vegPlates),
                    const SizedBox(width: 6),
                    _PlateBadge(label: 'Non-Veg', value: lead.nonVegPlates),
                    const SizedBox(width: 6),
                    _PlateBadge(label: 'Mixed', value: lead.mixedPlates),
                  ],
                ),
                actions: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isPaying ? null : () => _handlePay(lead),
                      child: isPaying
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : Text('Pay ${formatInr(lead.leadPrice)}'),
                    ),
                  ),
                ],
              );
            }),
        ],
      ),
    );
  }
}

class _PlateBadge extends StatelessWidget {
  final String label;
  final int value;
  const _PlateBadge({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(color: AppColors.bgLight, borderRadius: BorderRadius.circular(8)),
        child: Column(
          children: [
            Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
            Text('$value', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
