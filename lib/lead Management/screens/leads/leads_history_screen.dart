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

const _statusFilterOptions = [
  FilterOption('all', 'All Status'),
  FilterOption('QUOTED', 'Quoted'),
  FilterOption('NOT_QUOTED', 'Not Quoted'),
  FilterOption('NEW', 'New'),
  FilterOption('ASSIGNED', 'Assigned'),
  FilterOption('PAYMENT_RECEIVED', 'Payment Received'),
  FilterOption('APPROVED', 'Approved'),
  FilterOption('CLOSED', 'Closed'),
  FilterOption('REJECTED', 'Rejected'),
  FilterOption('CANCELLED', 'Cancelled'),
];

/// Ports LeadsHistory.jsx — the full purchase/quotation history of every
/// full lead, newest first.
class LeadsHistoryScreen extends StatefulWidget {
  const LeadsHistoryScreen({super.key});

  @override
  State<LeadsHistoryScreen> createState() => _LeadsHistoryScreenState();
}

class _LeadsHistoryScreenState extends State<LeadsHistoryScreen> {
  List<LeadModel> _leads = [];
  List<LeadModel> _filtered = [];
  bool _loading = true;
  String? _error;
  String _searchTerm = '';
  String _filterType = 'all';
  String _filterStatus = 'all';

  @override
  void initState() {
    super.initState();
    _fetchFullLeads();
  }

  Future<void> _fetchFullLeads() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final vendorId = await Authservice.getVendorId();
      if (vendorId == null) {
        setState(() {
          _error = 'Vendor ID not found. Please login again.';
          _loading = false;
        });
        return;
      }
      final vendorIdStr = vendorId.toString();

      final fullLeads = await LeadService.getFullLeads(vendorIdStr);
      if (fullLeads.isEmpty) {
        setState(() {
          _leads = [];
          _filtered = [];
          _loading = false;
        });
        return;
      }

      final quotationMap = await LeadService.getVendorQuotationsMap(vendorIdStr);
      final withQuotation = fullLeads.map((l) => l.withQuotation(quotationMap[l.id])).toList();

      // Sort newest first by createdAt.
      withQuotation.sort((a, b) {
        final da = DateTime.tryParse(a.createdAt ?? '') ?? DateTime(1970);
        final db = DateTime.tryParse(b.createdAt ?? '') ?? DateTime(1970);
        return db.compareTo(da);
      });

      setState(() {
        _leads = withQuotation;
        _applyFilters();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _leads = [];
        _filtered = [];
        _loading = false;
      });
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
      if (_filterStatus == 'QUOTED') {
        filtered = filtered.where((l) => l.hasQuotation).toList();
      } else if (_filterStatus == 'NOT_QUOTED') {
        filtered = filtered.where((l) => !l.hasQuotation).toList();
      } else {
        filtered = filtered.where((l) => l.leadStatus.toUpperCase() == _filterStatus.toUpperCase()).toList();
      }
    }

    _filtered = filtered;
  }

  @override
  Widget build(BuildContext context) {
    final totalLeads = _filtered.length;
    final totalAmount = _filtered.fold<double>(0, (s, l) => s + (l.paymentAmount ?? l.leadPrice));
    final quotedCount = _filtered.where((l) => l.hasQuotation).length;
    final closedCount = _filtered.where((l) => l.leadStatus.toUpperCase() == 'CLOSED').length;

    return RefreshIndicator(
      onRefresh: _fetchFullLeads,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          StatsGrid(cards: [
            StatCard(label: 'Total Leads', value: '$totalLeads', subtext: 'Purchased leads'),
            StatCard(label: 'Total Value', value: formatInr(totalAmount), valueColor: AppColors.success, subtext: 'Amount paid'),
            StatCard(label: 'Quoted', value: '$quotedCount', valueColor: AppColors.info, subtext: 'Have a quotation'),
            StatCard(label: 'Closed', value: '$closedCount', valueColor: AppColors.neutral, subtext: 'Completed leads'),
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
            statusOptions: _statusFilterOptions,
            statusValue: _filterStatus,
            onStatusChanged: (v) => setState(() {
              _filterStatus = v;
              _applyFilters();
            }),
            onRefresh: _fetchFullLeads,
          ),
          const SizedBox(height: 14),
          if (_loading)
            const LoadingView(message: 'Loading history...')
          else if (_error != null)
            ErrorStateView(message: _error!, onRetry: _fetchFullLeads)
          else if (_filtered.isEmpty)
            const EmptyStateView(
              icon: '🗂️',
              title: 'No History Found',
              message: 'No purchased leads match your filters yet.',
            )
          else
            ..._filtered.map((lead) {
              final status = leadStatusBadge(lead.leadStatus);
              return LeadCard(
                lead: lead,
                onTap: () => showLeadDetailSheet(context, lead: lead),
                trailing: Row(
                  children: [
                    StatusChip.status(status),
                    if (lead.hasQuotation) ...[
                      const SizedBox(width: 6),
                      StatusChip.status(quotationStatusBadge(lead.quotationStatus)),
                    ],
                  ],
                ),
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
