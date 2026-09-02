import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'assigned_leads_screen.dart';
import 'leads_dashboard_screen.dart';
import 'leads_history_screen.dart';
import 'leads_screen.dart';
import 'paid_leads_screen.dart';
import 'quotations_screen.dart';

class VendorLeadsScreen extends StatefulWidget {
  const VendorLeadsScreen({super.key});

  @override
  State<VendorLeadsScreen> createState() => _VendorLeadsScreenState();
}

class _VendorLeadsScreenState extends State<VendorLeadsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const _tabs = [
    Tab(text: 'Dashboard'),
    Tab(text: 'Leads'),
    Tab(text: 'PaidLeads'),
    Tab(text: 'Quotations'),
    Tab(text: 'Assigned'),
    Tab(text: 'History'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _goToTab(int index) {
    _tabController.animateTo(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leads'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textMuted,
          indicatorColor: AppColors.primary,
          tabs: _tabs,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          LeadsDashboardScreen(onNavigateToTab: _goToTab),
          const LeadsScreen(),
          const PaidLeadsScreen(),
          const QuotationsScreen(),
          const AssignedLeadsScreen(),
          const LeadsHistoryScreen(),
        ],
      ),
    );
  }
}
