import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/lead_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/state_views.dart';

class _DashboardStats {
  int totalLeads = 0;
  int maskedLeads = 0;
  int fullLeads = 0;
  int paidLeads = 0;
  int quotedLeads = 0;
  int assignedLeads = 0;
  int closedLeads = 0;
  int rejectedLeads = 0;
  double totalSpent = 0;
}

/// Ports LeadsDashboard.jsx.
class LeadsDashboardScreen extends StatefulWidget {
  final void Function(int tabIndex)? onNavigateToTab;

  const LeadsDashboardScreen({super.key, this.onNavigateToTab});

  @override
  State<LeadsDashboardScreen> createState() => _LeadsDashboardScreenState();
}

class _LeadsDashboardScreenState extends State<LeadsDashboardScreen> {
  bool _loading = true;
  String? _error;
  bool _hasData = false;
  _DashboardStats _stats = _DashboardStats();

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final vendorId = await Authservice.getVendorId();
      if (vendorId == null) {
        setState(() {
          _error = 'Please login again';
          _loading = false;
          _hasData = false;
        });
        return;
      }

      final vendorIdStr = vendorId.toString();
      final result = await LeadService.getAllLeads(vendorIdStr);
      final fullLeads = result.full;
      final maskedLeads = result.masked;

      if (fullLeads.isEmpty && maskedLeads.isEmpty) {
        setState(() {
          _hasData = false;
          _stats = _DashboardStats();
          _loading = false;
        });
        return;
      }

      final quotationMap = await LeadService.getVendorQuotationsMap(vendorIdStr);

      int quotedCount = 0, assignedCount = 0, closedCount = 0, rejectedCount = 0;
      double totalSpent = 0;

      for (final lead in fullLeads) {
        final status = lead.leadStatus.toUpperCase();
        final quotStatus = quotationMap[lead.id]?.status?.toUpperCase() ?? '';

        if (status == 'CLOSED') {
          closedCount++;
        } else if (status == 'REJECTED' || status == 'CANCELLED') {
          rejectedCount++;
        }

        if (quotStatus == 'SELECTED' || quotStatus == 'ACCEPTED') {
          assignedCount++;
          quotedCount++;
        } else if (quotStatus == 'SUBMITTED') {
          quotedCount++;
        }

        if (status == 'PAYMENT_RECEIVED' || status == 'APPROVED' || status == 'CLOSED') {
          totalSpent += lead.paymentAmount ?? lead.leadPrice;
        }
      }

      final paidLeadsCount = fullLeads
          .where((l) => l.leadStatus.toUpperCase() == 'PAYMENT_RECEIVED' || l.leadStatus.toUpperCase() == 'APPROVED')
          .length;

      setState(() {
        _hasData = true;
        _stats = _DashboardStats()
          ..totalLeads = fullLeads.length + maskedLeads.length
          ..maskedLeads = maskedLeads.length
          ..fullLeads = fullLeads.length
          ..paidLeads = paidLeadsCount
          ..quotedLeads = quotedCount
          ..assignedLeads = assignedCount
          ..closedLeads = closedCount
          ..rejectedLeads = rejectedCount
          ..totalSpent = totalSpent;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _hasData = false;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const LoadingView(message: 'Loading dashboard...');

    return RefreshIndicator(
      onRefresh: _fetchDashboardData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Leads Dashboard',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textDark),
          ),
          const SizedBox(height: 4),
          const Text(
            'Overview of all your leads and their status',
            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
          const SizedBox(height: 16),
          if (_error != null)
            ErrorStateView(message: _error!, onRetry: _fetchDashboardData)
          else if (!_hasData)
            const EmptyStateView(
              icon: '📊',
              title: 'No Leads Yet',
              message: "You haven't purchased any leads yet. Start exploring available leads to grow your business!",
            )
          else ...[
            StatsGrid(cards: [
              StatCard(
                label: 'Total Leads',
                value: '${_stats.totalLeads}',
                subtext: '${_stats.maskedLeads} masked · ${_stats.fullLeads} full',
                onTap: () => widget.onNavigateToTab?.call(1),
              ),
              StatCard(
                label: 'Masked Leads',
                value: '${_stats.maskedLeads}',
                valueColor: AppColors.neutral,
                subtext: 'Awaiting purchase',
                onTap: () => widget.onNavigateToTab?.call(1),
              ),
              StatCard(
                label: 'My Leads',
                value: '${_stats.fullLeads}',
                valueColor: AppColors.info,
                subtext: 'Purchased leads',
                onTap: () => widget.onNavigateToTab?.call(2),
              ),
              StatCard(
                label: 'Total Spent',
                value: formatInr(_stats.totalSpent),
                valueColor: AppColors.success,
                subtext: 'On all purchased leads',
              ),
            ]),
            const SizedBox(height: 10),
            StatsGrid(cards: [
              StatCard(
                label: 'Quotations',
                value: '${_stats.quotedLeads}',
                valueColor: AppColors.info,
                subtext: 'Quotes sent',
                onTap: () => widget.onNavigateToTab?.call(3),
              ),
              StatCard(
                label: 'Assigned',
                value: '${_stats.assignedLeads}',
                valueColor: AppColors.warning,
                subtext: 'Accepted quotations',
                onTap: () => widget.onNavigateToTab?.call(4),
              ),
              StatCard(
                label: 'Completed',
                value: '${_stats.closedLeads + _stats.rejectedLeads}',
                valueColor: AppColors.purple,
                subtext: '${_stats.closedLeads} closed · ${_stats.rejectedLeads} rejected',
                onTap: () => widget.onNavigateToTab?.call(5),
              ),
              StatCard(
                label: 'Rejected Leads',
                value: '${_stats.rejectedLeads}',
                valueColor: AppColors.danger,
                subtext: 'Cancelled / Rejected',
                onTap: () => widget.onNavigateToTab?.call(5),
              ),
            ]),
          ],
        ],
      ),
    );
  }
}
