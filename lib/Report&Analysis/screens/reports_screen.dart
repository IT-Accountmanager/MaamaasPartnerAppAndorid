import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/report_models.dart';
import '../services/report_service.dart';
import '../widgets/theme.dart';
import 'Rating_Tab_screen.dart';
import 'overview_tab.dart';
import 'revenue_tab.dart';
import 'orders_tab.dart';
import 'payments_tab.dart';

class _TabDef {
  final String id, label, subModuleKey;
  final IconData icon;
  const _TabDef({
    required this.id,
    required this.label,
    required this.icon,
    required this.subModuleKey,
  });
}

const _allTabs = [
  _TabDef(
    id: 'overview',
    label: 'Overview',
    icon: Icons.dashboard_outlined,
    subModuleKey: 'REPORTS_OVERVIEW',
  ),
  _TabDef(
    id: 'revenue',
    label: 'Revenue',
    icon: Icons.trending_up_rounded,
    subModuleKey: 'REPORTS_REVENUE',
  ),
  _TabDef(
    id: 'orders',
    label: 'Orders',
    icon: Icons.receipt_long_outlined,
    subModuleKey: 'REPORTS_ORDERS',
  ),
  _TabDef(
    id: 'ratings',
    label: 'Ratings',
    icon: Icons.star_outline_rounded,
    subModuleKey: 'REPORTS_RATINGS',
  ),
];

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});
  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabCtrl;
  List<_TabDef> _tabs = [];

  String _period = 'week';
  DateTimeRange? _customRange;

  ReportData? _data;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initTabs();
  }

  Future<void> _initTabs() async {
    final role = await ReportService.getRole();
    final subModules = await ReportService.getSubModules();

    List<_TabDef> available;
    if (role == 'ROLE_EMPLOYEE') {
      available = _allTabs.where((t) {
        if (t.id == 'ratings') return true;
        return subModules.contains(t.subModuleKey);
      }).toList();
    } else {
      available = List<_TabDef>.from(_allTabs);
    }

    if (!mounted) return;
    setState(() {
      _tabs = available.isEmpty ? List.from(_allTabs) : available;
      _tabCtrl = TabController(length: _tabs.length, vsync: this);
      _tabCtrl!.addListener(() => setState(() {}));
    });

    _fetch();
  }

  ReportFilter get _filter {
    final now = DateTime.now();
    final fmt = DateFormat('yyyy-MM-dd');

    String start, end;

    switch (_period) {
      case 'yesterday':
        final y = now.subtract(const Duration(days: 1));
        start = fmt.format(y);
        end = fmt.format(y);
        break;
      case 'week':
        start = fmt.format(now.subtract(const Duration(days: 6)));
        end = fmt.format(now);
        break;

      case 'month':
        start = fmt.format(DateTime(now.year, now.month, 1));
        end = fmt.format(now);
        break;

      case 'custom':
        final s = _customRange?.start ?? now.subtract(const Duration(days: 7));
        final e = _customRange?.end ?? now;

        start = fmt.format(s);
        end = fmt.format(e);
        break;

      default:
        start = end = fmt.format(now);
    }

    return ReportFilter(startDate: start, endDate: end, period: _period);
  }

  Future<void> _fetch() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await ReportService.fetch(_filter);
      if (mounted)
        setState(() {
          _data = result;
          _loading = false;
        });
    } catch (e) {
      if (mounted)
        setState(() {
          _error = e.toString();
          _loading = false;
        });
    }
  }

  void _changePeriod(String period, {DateTimeRange? customRange}) {
    setState(() {
      _period = period;
      if (period == 'custom' && customRange != null) {
        _customRange = customRange;
      }
    });
    _fetch();
  }

  @override
  Widget build(BuildContext context) {
    if (_tabCtrl == null) {
      return const Scaffold(
        backgroundColor: rpBg,
        body: Center(child: CircularProgressIndicator(color: rpAccent)),
      );
    }
    return Scaffold(
      backgroundColor: rpBg,
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            Expanded(child: _tabView()),
          ],
        ),
      ),
    );
  }

  Widget _header() => Container(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
    decoration: const BoxDecoration(
      color: rpCard,
      border: Border(bottom: BorderSide(color: rpBorder)),
    ),
    child: Row(
      children: [
        // ── Back button ───────────────────────────────────────────────
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: rpBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: rpBorder),
            ),
            child: const Icon(
              Icons.arrow_back_ios_rounded,
              size: 15,
              color: rpText1,
            ),
          ),
        ),
        const SizedBox(width: 10),

        // ── Scrollable tab chips ──────────────────────────────────────
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: _tabs.asMap().entries.map((entry) {
                final i = entry.key;
                final t = entry.value;
                return Padding(
                  padding: EdgeInsets.only(right: i < _tabs.length - 1 ? 6 : 0),
                  child: _tabChip(label: t.label, index: i),
                );
              }).toList(),
            ),
          ),
        ),

        // ── Loader (moved to top-right corner) ───────────────────────
        if (_loading) ...[
          const SizedBox(width: 8),
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(color: rpAccent, strokeWidth: 2),
          ),
        ],
      ],
    ),
  );

  Widget _tabChip({required String label, required int index}) {
    final isActive = _tabCtrl?.index == index;

    return GestureDetector(
      onTap: () => _tabCtrl?.animateTo(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),

        decoration: BoxDecoration(
          color: isActive
              ? Colors
                    .green
              : const Color(0xFFE66D33),
          borderRadius: BorderRadius.circular(10),
        ),

        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _tabView() => TabBarView(
    controller: _tabCtrl!,
    children: _tabs
        .map(
          (t) => RefreshIndicator(
            color: rpAccent,
            onRefresh: _fetch,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: _error != null
                  ? RpEmpty(
                      message: 'Error: $_error\n\nPull to retry.',
                      icon: Icons.error_outline,
                    )
                  : _tabContent(t.id),
            ),
          ),
        )
        .toList(),
  );

  Widget _tabContent(String id) {
    final periodSelector = PeriodSelector(
      period: _period,
      customRange: _customRange,
      onPeriodChanged: _changePeriod,
    );

    switch (id) {
      case 'overview':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            periodSelector,
            const SizedBox(height: 12),
            OverviewTab(data: _data, isLoading: _loading),
          ],
        );
      case 'revenue':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            periodSelector,
            const SizedBox(height: 12),
            RevenueTab(data: _data, isLoading: _loading),
          ],
        );
      case 'orders':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            periodSelector,
            const SizedBox(height: 12),
            OrdersTab(data: _data, isLoading: _loading),
          ],
        );
      case 'ratings':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            periodSelector,
            const SizedBox(height: 12),
            RatingTab(data: _data, isLoading: _loading),
          ],
        );
      default:
        return const RpEmpty(message: 'Tab not available');
    }
  }

  @override
  void dispose() {
    _tabCtrl?.dispose();
    super.dispose();
  }
}

class PeriodSelector extends StatelessWidget {
  final String period;
  final DateTimeRange? customRange;
  final Function(String, {DateTimeRange? customRange}) onPeriodChanged;

  const PeriodSelector({
    super.key,
    required this.period,
    this.customRange,
    required this.onPeriodChanged,
  });
  Future<DateTime?> _pickDate(
    BuildContext context, {
    required String title,
    DateTime? initial,
    DateTime? firstDate,
  }) async {
    final now = DateTime.now();

    final date = await showDatePicker(
      context: context,
      initialDate: initial ?? now,
      firstDate: firstDate ?? DateTime(2023),
      lastDate: now,
      helpText: title,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: rpAccent,
            onPrimary: Colors.white,
            onSurface: Colors.black,
          ),
        ),
        child: child!,
      ),
    );

    return date;
  }

  String _getFormattedDateText() {
    final now = DateTime.now();
    final fmt = DateFormat('dd-MM-yyyy');

    switch (period) {
      case 'today':
        return fmt.format(now);

      case 'yesterday':
        final yesterday = now.subtract(const Duration(days: 1));
        return fmt.format(yesterday);

      case 'week':
        final start = now.subtract(const Duration(days: 6));
        return "${fmt.format(start)} to ${fmt.format(now)}";

      case 'month':
        final start = DateTime(now.year, now.month, 1);
        return "${fmt.format(start)} to ${fmt.format(now)}";

      case 'custom':
        if (customRange != null) {
          return "${fmt.format(customRange!.start)} to ${fmt.format(customRange!.end)}";
        }
        return '';

      default:
        return '';
    }
  }

  String _getPeriodDisplayText() {
    switch (period) {
      case 'today':
        return 'Today';
      case 'yesterday':
        return 'Yesterday';
      case 'week':
        return 'This Week';
      case 'month':
        return 'This Month';
      case 'custom':
        if (customRange != null) {
          final start = DateFormat('dd MMM').format(customRange!.start);
          final end = DateFormat('dd MMM').format(customRange!.end);
          return '$start → $end';
        }
        return 'Custom';
      default:
        return 'Today';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            _getFormattedDateText(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: rpText1,
            ),
          ),

          const SizedBox(width: 8),

          Container(
            height: 34,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: rpBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: rpBorder),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: period,
                isDense: true,
                icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
                style: const TextStyle(
                  fontSize: 12,
                  color: rpText1,
                  fontWeight: FontWeight.w600,
                ),
                onChanged: (value) async {
                  if (value == null) return;

                  if (value == 'custom') {
                    final fromDate = await _pickDate(
                      context,
                      title: "Select From Date",
                    );
                    if (fromDate == null) return;

                    final toDate = await _pickDate(
                      context,
                      title: "Select To Date",
                      initial: fromDate,
                      firstDate: fromDate,
                    );
                    if (toDate == null) return;

                    final range = DateTimeRange(start: fromDate, end: toDate);

                    onPeriodChanged('custom', customRange: range);
                  } else {
                    onPeriodChanged(value);
                  }
                },
                items: const [
                  DropdownMenuItem(value: 'today', child: Text('Today')),
                  DropdownMenuItem(
                    value: 'yesterday',
                    child: Text('Yesterday'),
                  ),
                  DropdownMenuItem(value: 'week', child: Text('Week')),
                  DropdownMenuItem(value: 'month', child: Text('Month')),
                  DropdownMenuItem(value: 'custom', child: Text('Custom')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
