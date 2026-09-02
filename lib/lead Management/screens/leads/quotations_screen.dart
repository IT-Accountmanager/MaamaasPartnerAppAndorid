import 'package:flutter/material.dart';
import '../../models/lead_model.dart';
import '../../services/auth_service.dart';
import '../../services/lead_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';
import '../../widgets/filters_bar.dart';
import '../../widgets/lead_card.dart';
import '../../widgets/lead_detail_sheet.dart';
import '../../widgets/state_views.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/status_chip.dart';

const _quotationStatusFilterOptions = [
  FilterOption('all', 'All Status'),
  FilterOption('SUBMITTED', 'Submitted'),
  FilterOption('SELECTED', 'Selected'),
  FilterOption('ACCEPTED', 'Accepted'),
  FilterOption('REJECTED', 'Rejected'),
];

/// Ports Quotations.jsx — full leads that HAVE a quotation, with status
/// filtering.
class QuotationsScreen extends StatefulWidget {
  const QuotationsScreen({super.key});

  @override
  State<QuotationsScreen> createState() => _QuotationsScreenState();
}

class _QuotationsScreenState extends State<QuotationsScreen> {
  List<LeadModel> _leads = [];
  List<LeadModel> _filtered = [];
  bool _loading = true;
  String _searchTerm = '';
  String _filterType = 'all';
  String _filterStatus = 'all';

  @override
  void initState() {
    super.initState();
    _fetchQuotedLeads();
  }

  Future<void> _fetchQuotedLeads() async {
    setState(() => _loading = true);
    try {
      final vendorId = await Authservice.getVendorId();
      if (vendorId == null) {
        setState(() => _loading = false);
        return;
      }
      final vendorIdStr = vendorId.toString();

      final fullLeads = await LeadService.getFullLeads(vendorIdStr);
      final quotationMap = await LeadService.getVendorQuotationsMap(vendorIdStr);
      final withQuotation = fullLeads.map((l) => l.withQuotation(quotationMap[l.id])).toList();

      // ✅ FILTER: only leads that HAVE a quotation.
      final quoted = withQuotation.where((l) => l.hasQuotation).toList();

      setState(() {
        _leads = quoted;
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

    if (_filterStatus != 'all') {
      filtered = filtered.where((l) => l.quotationStatus?.toUpperCase() == _filterStatus.toUpperCase()).toList();
    }

    _filtered = filtered;
  }

  @override
  Widget build(BuildContext context) {
    final totalLeads = _filtered.length;
    final totalAmount = _filtered.fold<double>(0, (s, l) => s + l.leadPrice);
    final submittedCount = _filtered.where((l) => l.quotationStatus?.toUpperCase() == 'SUBMITTED').length;
    final selectedCount = _filtered
        .where((l) => l.quotationStatus?.toUpperCase() == 'SELECTED' || l.quotationStatus?.toUpperCase() == 'ACCEPTED')
        .length;

    return RefreshIndicator(
      onRefresh: _fetchQuotedLeads,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          StatsGrid(cards: [
            StatCard(label: 'Total Quoted', value: '$totalLeads', subtext: 'Leads with quotations'),
            StatCard(label: 'Total Value', value: formatInr(totalAmount), valueColor: AppColors.success, subtext: 'Total lead prices'),
            StatCard(label: 'Submitted', value: '$submittedCount', valueColor: AppColors.info, subtext: 'Pending review'),
            StatCard(label: 'Selected', value: '$selectedCount', valueColor: AppColors.success, subtext: 'Accepted quotations'),
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
            statusOptions: _quotationStatusFilterOptions,
            statusValue: _filterStatus,
            onStatusChanged: (v) => setState(() {
              _filterStatus = v;
              _applyFilters();
            }),
            onRefresh: _fetchQuotedLeads,
          ),
          const SizedBox(height: 14),
          if (_loading)
            const LoadingView(message: 'Loading quoted leads...')
          else if (_filtered.isEmpty)
            const EmptyStateView(
              icon: '📋',
              title: 'No Quotations Found',
              message: 'No leads with quotations available.',
            )
          else
            ..._filtered.map((lead) {
              final status = quotationStatusBadge(lead.quotationStatus);
              return LeadCard(
                lead: lead,
                showPrice: false,
                onTap: () => showLeadDetailSheet(context, lead: lead),
                trailing: StatusChip.status(status),
                actions: [
                  OutlinedButton(
                    onPressed: () => showLeadDetailSheet(context, lead: lead),
                    child: const Text('View'),
                  ),
                ],
              );
            }),
        ],
      ),
    );
  }
}
