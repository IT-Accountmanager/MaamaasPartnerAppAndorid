import 'package:flutter/material.dart';
import '../../models/add_on_model.dart';
import '../../models/lead_model.dart';
import '../../models/quotation_model.dart';
import '../../services/auth_service.dart';
import '../../services/lead_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';
import '../../widgets/filters_bar.dart';
import '../../widgets/lead_card.dart';
import '../../widgets/lead_detail_sheet.dart';
import '../../widgets/state_views.dart';
import '../../widgets/stat_card.dart';

/// Ports PaidLeads.jsx — full leads that don't have a quotation yet, with
/// a "Quote" action that opens a pricing form and sends the quotation.
class PaidLeadsScreen extends StatefulWidget {
  const PaidLeadsScreen({super.key});

  @override
  State<PaidLeadsScreen> createState() => _PaidLeadsScreenState();
}

class _PaidLeadsScreenState extends State<PaidLeadsScreen> {
  List<LeadModel> _leads = [];
  List<LeadModel> _filtered = [];
  bool _loading = true;
  String _searchTerm = '';
  String _filterType = 'all';
  String? _vendorId;

  @override
  void initState() {
    super.initState();
    _fetchFullLeads();
  }

  Future<void> _fetchFullLeads() async {
    setState(() => _loading = true);
    try {
      final vendorId = await Authservice.getVendorId();
      if (vendorId == null) {
        setState(() => _loading = false);
        return;
      }
      _vendorId = vendorId.toString();

      final fullLeads = await LeadService.getFullLeads(_vendorId!);
      final quotationMap = await LeadService.getVendorQuotationsMap(_vendorId!);

      final withQuotation = fullLeads.map((l) => l.withQuotation(quotationMap[l.id])).toList();

      // ✅ FILTER: Only leads that DON'T have a quotation yet.
      final unquoted = withQuotation.where((l) => !l.hasQuotation).toList();

      setState(() {
        _leads = unquoted;
        _applyFilters();
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
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
              l.mobile.contains(term) ||
              l.email.toLowerCase().contains(term))
          .toList();
    }

    if (_filterType != 'all') {
      filtered = filtered.where((l) => l.eventType.toUpperCase() == _filterType.toUpperCase()).toList();
    }

    _filtered = filtered;
  }

  Future<void> _openQuotationSheet(LeadModel lead) async {
    final sent = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => _QuotationForm(lead: lead, vendorId: _vendorId!),
    );

    if (sent == true) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Quotation sent successfully!'), backgroundColor: AppColors.success),
        );
      }
      _fetchFullLeads();
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalLeads = _filtered.length;
    final totalAmount = _filtered.fold<double>(0, (s, l) => s + l.leadPrice);
    final eventTypeCount = _filtered.map((l) => l.eventType).toSet().length;
    final totalPlates = _filtered.fold<int>(0, (s, l) => s + l.totalPlates);

    return RefreshIndicator(
      onRefresh: _fetchFullLeads,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          StatsGrid(cards: [
            StatCard(label: 'Unquoted Leads', value: '$totalLeads', subtext: 'Awaiting quotation'),
            StatCard(label: 'Total Value', value: formatInr(totalAmount), valueColor: AppColors.success, subtext: 'Total lead prices'),
            StatCard(label: 'Event Types', value: '$eventTypeCount', valueColor: AppColors.purple, subtext: 'Unique event types'),
            StatCard(label: 'Total Plates', value: '$totalPlates', valueColor: AppColors.primary, subtext: 'Across all leads'),
          ]),
          const SizedBox(height: 14),
          FiltersBar(
            searchHint: 'Search by ID, Name, Phone or Email...',
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
            onRefresh: _fetchFullLeads,
          ),
          const SizedBox(height: 14),
          if (_loading)
            const LoadingView(message: 'Loading unquoted leads...')
          else if (_filtered.isEmpty)
            const EmptyStateView(
              icon: '✅',
              title: 'All Leads Quoted!',
              message: 'All full leads have been quoted. Check back later for new leads.',
            )
          else
            ..._filtered.map((lead) {
              return LeadCard(
                lead: lead,
                onTap: () => showLeadDetailSheet(context, lead: lead, footerActions: [
                  OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _openQuotationSheet(lead);
                    },
                    child: const Text('Create Quotation'),
                  ),
                ]),
                actions: [
                  OutlinedButton(
                    onPressed: () => showLeadDetailSheet(context, lead: lead),
                    child: const Text('View'),
                  ),
                  ElevatedButton(
                    onPressed: () => _openQuotationSheet(lead),
                    child: const Text('Quote'),
                  ),
                ],
              );
            }),
        ],
      ),
    );
  }
}

/// The pricing form + confirmation step, ported from the two modals in
/// PaidLeads.jsx (`showQuotationModal` and `showConfirmationModal`).
class _QuotationForm extends StatefulWidget {
  final LeadModel lead;
  final String vendorId;
  const _QuotationForm({required this.lead, required this.vendorId});

  @override
  State<_QuotationForm> createState() => _QuotationFormState();
}

class _QuotationFormState extends State<_QuotationForm> {
  final _vegController = TextEditingController();
  final _nonVegController = TextEditingController();
  final _mixedController = TextEditingController();
  final _detailsController = TextEditingController();
  late Map<int, TextEditingController> _addonControllers;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _addonControllers = {
      for (final a in widget.lead.addOns)
        if (a.id != null) a.id!: TextEditingController(),
    };
  }

  @override
  void dispose() {
    _vegController.dispose();
    _nonVegController.dispose();
    _mixedController.dispose();
    _detailsController.dispose();
    for (final c in _addonControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  double _parse(String text) => double.tryParse(text) ?? 0;

  Future<void> _confirmAndSend() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Quotation'),
        content: const Text(
          'Once you send this quotation, you cannot change the quoted amount.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Send Quotation')),
        ],
      ),
    );

    if (confirmed != true) return;
    await _send();
  }

  Future<void> _send() async {
    setState(() => _sending = true);
    try {
      final quotation = QuotationModel(
        vegPerPlatePrice: _parse(_vegController.text),
        nonVegPerPlatePrice: _parse(_nonVegController.text),
        mixedPerPlatePrice: _parse(_mixedController.text),
        quotationDetails: _detailsController.text,
        addOnPrices: widget.lead.addOns
            .where((a) => a.id != null)
            .map((a) => AddOnPrice(
                  addOnId: a.id!,
                  price: _parse(_addonControllers[a.id]?.text ?? '0'),
                  addOnType: a.addOnType,
                  quantity: a.quantity,
                ))
            .toList(),
      );

      await LeadService.sendQuotation(widget.lead.id, widget.vendorId, quotation);

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      setState(() => _sending = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Failed to send quotation: $e'), backgroundColor: AppColors.danger),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lead = widget.lead;
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 12,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Send Quotation for Lead #${lead.id}',
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              const Divider(height: 24),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    Text('👤 ${lead.name} · ${lead.mobile}', style: const TextStyle(color: AppColors.textMuted)),
                    const SizedBox(height: 16),
                    const Text('🍽️ Plate Pricing', style: TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    _PriceField(
                      label: 'Veg Plate (₹) · ${lead.vegPlates} plates',
                      controller: _vegController,
                    ),
                    const SizedBox(height: 10),
                    _PriceField(
                      label: 'Non-Veg Plate (₹) · ${lead.nonVegPlates} plates',
                      controller: _nonVegController,
                    ),
                    if (lead.mixedPlates > 0) ...[
                      const SizedBox(height: 10),
                      _PriceField(
                        label: 'Mixed Plate (₹) · ${lead.mixedPlates} plates',
                        controller: _mixedController,
                      ),
                    ],
                    if (lead.addOns.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text('📦 Add-On Pricing', style: TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      ...lead.addOns.where((a) => a.id != null).map(
                            (a) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _PriceField(
                                label: '${a.displayType} × ${a.quantity} (₹)',
                                controller: _addonControllers[a.id]!,
                              ),
                            ),
                          ),
                    ],
                    const SizedBox(height: 16),
                    const Text('📝 Quotation Details', style: TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _detailsController,
                      maxLines: 3,
                      decoration: const InputDecoration(hintText: 'Add any details about the quotation...'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _sending ? null : () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _sending ? null : _confirmAndSend,
                      child: _sending
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Send Quotation'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PriceField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  const _PriceField({required this.label, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(hintText: 'Price per plate'),
        ),
      ],
    );
  }
}
