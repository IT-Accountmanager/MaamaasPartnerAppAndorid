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

/// Ports AssignedLeads.jsx — full leads whose quotation was SELECTED /
/// ACCEPTED by the customer, with a "Close" action to mark them CLOSED.
class AssignedLeadsScreen extends StatefulWidget {
  const AssignedLeadsScreen({super.key});

  @override
  State<AssignedLeadsScreen> createState() => _AssignedLeadsScreenState();
}

class _AssignedLeadsScreenState extends State<AssignedLeadsScreen> {
  List<LeadModel> _leads = [];
  List<LeadModel> _filtered = [];
  bool _loading = true;
  String _searchTerm = '';
  String _filterType = 'all';
  String? _vendorId;
  int? _closingLeadId;

  @override
  void initState() {
    super.initState();
    _fetchAssignedLeads();
  }

  Future<void> _fetchAssignedLeads() async {
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

      // ✅ FILTER: only SELECTED/ACCEPTED quotations.
      final selected = withQuotation
          .where((l) =>
              l.quotationStatus?.toUpperCase() == 'SELECTED' ||
              l.quotationStatus?.toUpperCase() == 'ACCEPTED')
          .toList();

      setState(() {
        _leads = selected;
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

  Future<void> _handleComplete(LeadModel lead) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complete Lead'),
        content: Text('Are you sure you want to mark Lead #${lead.id} as COMPLETED?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Complete')),
        ],
      ),
    );
    if (confirmed != true || _vendorId == null) return;

    setState(() => _closingLeadId = lead.id);
    try {
      await LeadService.closeLead(lead.id, _vendorId!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ Lead #${lead.id} completed successfully!'), backgroundColor: AppColors.success),
        );
      }
      Future.delayed(const Duration(milliseconds: 800), _fetchAssignedLeads);
    } catch (e) {
      setState(() => _closingLeadId = null);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Failed to complete lead: $e'), backgroundColor: AppColors.danger),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalLeads = _filtered.length;
    final totalAmount = _filtered.fold<double>(0, (s, l) => s + l.leadPrice);
    final eventTypeCount = _filtered.map((l) => l.eventType).toSet().length;
    final totalPlates = _filtered.fold<int>(0, (s, l) => s + l.totalPlates);

    return RefreshIndicator(
      onRefresh: _fetchAssignedLeads,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          StatsGrid(cards: [
            StatCard(label: 'Assigned Leads', value: '$totalLeads', subtext: 'Selected/Accepted leads'),
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
            onRefresh: _fetchAssignedLeads,
          ),
          const SizedBox(height: 14),
          if (_loading)
            const LoadingView(message: 'Loading assigned leads...')
          else if (_filtered.isEmpty)
            const EmptyStateView(
              icon: '✅',
              title: 'No Assigned Leads',
              message: 'No leads have been selected/accepted yet.',
            )
          else
            ..._filtered.map((lead) {
              final isClosing = _closingLeadId == lead.id;
              final status = quotationStatusBadge(lead.quotationStatus);
              return LeadCard(
                lead: lead,
                showPrice: false,
                onTap: () => showLeadDetailSheet(context, lead: lead, footerActions: [
                  OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _handleComplete(lead);
                    },
                    child: const Text('✅ Complete'),
                  ),
                ]),
                trailing: StatusChip.status(status),
                actions: [
                  OutlinedButton(
                    onPressed: () => showLeadDetailSheet(context, lead: lead),
                    child: const Text('View'),
                  ),
                  ElevatedButton(
                    onPressed: isClosing ? null : () => _handleComplete(lead),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                    child: isClosing
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Close'),
                  ),
                ],
              );
            }),
        ],
      ),
    );
  }
}
