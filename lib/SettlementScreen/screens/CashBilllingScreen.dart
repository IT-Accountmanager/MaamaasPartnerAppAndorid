import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/finance_models.dart';
import '../services/finance_service.dart';

// ── Design tokens — shared with the rest of the finance module ────────────────
const Color _accent = Color(0xFFE66D33);
const Color _accentL = Color(0xFFFFF0E8);
const Color _bg = Color(0xFFF6F7FB);
const Color _card = Color(0xFFFFFFFF);
const Color _border = Color(0xFFE2E8F0);
const Color _text1 = Color(0xFF0F172A);
const Color _text2 = Color(0xFF64748B);
const Color _text3 = Color(0xFF94A3B8);
const Color _green = Color(0xFF10B981);
const Color _greenL = Color(0xFFD1FAE5);
const Color _amber = Color(0xFFF59E0B);
const Color _amberL = Color(0xFFFEF3C7);
const Color _shadow = Color(0x0A000000);

BoxDecoration _cardDeco({double radius = 14, Color? border}) => BoxDecoration(
  color: _card,
  borderRadius: BorderRadius.circular(radius),
  border: Border.all(color: border ?? _border),
  boxShadow: const [
    BoxShadow(color: _shadow, blurRadius: 6, offset: Offset(0, 2)),
  ],
);

// ─── Filter key → label mapping ───────────────────────────────────────────────
const Map<String, String> _filterLabels = {
  'today': 'Today',
  'yesterday': 'Yesterday',
  'week': 'Last 7 Days',
  'last30days': 'Last 30 Days',
  'thisMonth': 'This Month',
  'custom': 'Custom Range',
  'all': 'All Orders',
};

class CashBillingTab extends StatefulWidget {
  const CashBillingTab({super.key});
  @override
  State<CashBillingTab> createState() => _CashBillingTabState();
}

class _CashBillingTabState extends State<CashBillingTab> {
  static const int _pageSize = 10;

  CashBillingPage? _page;
  bool _loading = false;
  int _currentPg = 0;

  // Date filter
  String _dateFilter = 'today';
  String? _fromDate;
  String? _toDate;
  bool _filterOpen = false;
  bool _showCustom = false;
  DateTime? _customFrom;
  DateTime? _customTo;

  // Search
  final _searchCtrl = TextEditingController();
  String _searchTerm = '';
  bool _searching = false;

  // Detail modal
  CashBillingRecord? _selectedRecord;
  bool _showModal = false;

  @override
  void initState() {
    super.initState();
    final today = _todayStr();
    _fromDate = today;
    _toDate = today;
    _fetchPage(0);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  String _todayStr() => DateFormat('yyyy-MM-dd').format(DateTime.now());

  String _fmt(double v) => '₹${NumberFormat('#,##,###.##').format(v.abs())}';

  String _dateLabel() => _filterLabels[_dateFilter] ?? 'Today';

  bool get _filterActive => _dateFilter != 'today';

  // ── Fetch list ────────────────────────────────────────────────────────────
  Future<void> _fetchPage(int page) async {
    setState(() {
      _loading = true;
      _searching = false;
      _searchTerm = '';
      _searchCtrl.clear();
    });
    final result = await CashBillingService.fetchBillingPage(
      page: page,
      pageSize: _pageSize,
      startDate: _fromDate,
      endDate: _toDate,
    );
    if (mounted)
      setState(() {
        _page = result;
        _currentPg = page;
        _loading = false;
      });
  }

  // ── Search by order ID ────────────────────────────────────────────────────
  Future<void> _searchOrderId() async {
    final id = _searchCtrl.text.trim();
    if (id.isEmpty) {
      _fetchPage(_currentPg);
      return;
    }
    setState(() {
      _loading = true;
      _searching = true;
    });
    final rec = await CashBillingService.fetchByOrderId(id);
    if (mounted) {
      if (rec != null) {
        setState(() {
          _page = CashBillingPage(records: [rec], totalElements: 1);
          _loading = false;
        });
      } else {
        setState(() {
          _loading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order not found'),
            backgroundColor: _accent,
          ),
        );
        _fetchPage(_currentPg);
      }
    }
  }

  void _clearSearch() {
    _searchCtrl.clear();
    setState(() {
      _searchTerm = '';
      _searching = false;
    });
    _fetchPage(_currentPg);
  }

  // ── Date filter select ────────────────────────────────────────────────────
  void _applyFilter(String key) {
    final now = DateTime.now();
    final todayStr = _todayStr();
    String from = todayStr, to = todayStr;

    switch (key) {
      case 'today':
        from = todayStr;
        to = todayStr;
        break;
      case 'yesterday':
        final y = DateFormat(
          'yyyy-MM-dd',
        ).format(now.subtract(const Duration(days: 1)));
        from = y;
        to = y;
        break;
      case 'week':
        from = DateFormat(
          'yyyy-MM-dd',
        ).format(now.subtract(const Duration(days: 7)));
        to = todayStr;
        break;
      case 'last30days':
        from = DateFormat(
          'yyyy-MM-dd',
        ).format(now.subtract(const Duration(days: 30)));
        to = todayStr;
        break;
      case 'thisMonth':
        from = DateFormat(
          'yyyy-MM-dd',
        ).format(DateTime(now.year, now.month, 1));
        to = todayStr;
        break;
      case 'all':
        from = '2020-01-01';
        to = todayStr;
        break;
      default:
        return;
    }

    setState(() {
      _dateFilter = key;
      _fromDate = from;
      _toDate = to;
      _filterOpen = false;
      _currentPg = 0;
    });
    _fetchPage(0);
  }

  void _applyCustomRange() {
    if (_customFrom == null || _customTo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Select both dates'),
          backgroundColor: _amber,
        ),
      );
      return;
    }
    final from = DateFormat('yyyy-MM-dd').format(_customFrom!);
    final to = DateFormat('yyyy-MM-dd').format(_customTo!);
    setState(() {
      _dateFilter = 'custom';
      _fromDate = from;
      _toDate = to;
      _showCustom = false;
      _filterOpen = false;
      _currentPg = 0;
    });
    _fetchPage(0);
  }

  // ─── BUILD ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) => Stack(
    children: [
      Column(
        children: [
          // ── Summary denom strip ─────────────────────────────────────────────
          if (_page != null && _page!.hasSummary) _buildSummaryStrip(),

          // ── Search + Filter bar ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
            child: Row(
              children: [
                // Search
                Expanded(
                  child: Container(
                    height: 42,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: _card,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _border),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.search_rounded,
                          size: 16,
                          color: _text3,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _searchCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              hintText: 'Search Order ID',
                              hintStyle: TextStyle(color: _text3, fontSize: 12),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                              isDense: true,
                            ),
                            style: const TextStyle(fontSize: 13, color: _text1),
                            onChanged: (v) => setState(() => _searchTerm = v),
                            onSubmitted: (_) => _searchOrderId(),
                          ),
                        ),
                        if (_searchTerm.isNotEmpty)
                          GestureDetector(
                            onTap: _clearSearch,
                            child: const Icon(
                              Icons.close_rounded,
                              size: 14,
                              color: _text3,
                            ),
                          ),
                        if (_searchTerm.isNotEmpty)
                          GestureDetector(
                            onTap: _searchOrderId,
                            child: Container(
                              margin: const EdgeInsets.only(left: 6),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _accent,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'Go',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Filter button
                GestureDetector(
                  onTap: () => setState(() => _filterOpen = !_filterOpen),
                  child: Container(
                    height: 42,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: _filterActive ? _accent : _card,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _filterActive ? _accent : _border,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.filter_list_rounded,
                          size: 14,
                          color: _filterActive ? Colors.white : _text2,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _dateLabel(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _filterActive ? Colors.white : _text2,
                          ),
                        ),
                        const SizedBox(width: 3),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 14,
                          color: _filterActive ? Colors.white : _text2,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Filter dropdown ─────────────────────────────────────────────────
          if (_filterOpen) _buildFilterDropdown(),

          // ── Content ─────────────────────────────────────────────────────────
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: _accent,
                      strokeWidth: 2,
                    ),
                  )
                : (_page == null || _page!.records.isEmpty)
                ? _buildEmpty()
                : RefreshIndicator(
                    color: _accent,
                    onRefresh: () => _fetchPage(_currentPg),
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                      itemCount: _page!.records.length,
                      itemBuilder: (_, i) => _buildRecordCard(
                        _page!.records[i],
                        i + 1 + _currentPg * _pageSize,
                      ),
                    ),
                  ),
          ),

          // ── Pagination ──────────────────────────────────────────────────────
          if (!_loading &&
              _page != null &&
              _page!.totalElements > _pageSize &&
              !_searching)
            _buildPagination(),
        ],
      ),

      // Custom range modal overlay
      if (_showCustom) _buildCustomRangeModal(),
      // Record detail modal
      if (_showModal && _selectedRecord != null) _buildDetailModal(),
    ],
  );

  // ── Summary denomination strip ────────────────────────────────────────────
  Widget _buildSummaryStrip() => Container(
    margin: const EdgeInsets.fromLTRB(12, 10, 12, 0),
    decoration: _cardDeco(radius: 12),
    padding: const EdgeInsets.all(12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.receipt_long_outlined, size: 14, color: _accent),
            const SizedBox(width: 6),
            Text(
              'Notes Collected — ${_dateLabel()}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _text1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _page!.summaryDenoms
              .map(
                (d) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _accentL,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _accent.withOpacity(0.25)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        d['label'] as String,
                        style: const TextStyle(fontSize: 11, color: _text2),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${d['count']}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: _accent,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ],
    ),
  );

  // ── Filter dropdown panel ─────────────────────────────────────────────────
  Widget _buildFilterDropdown() => Padding(
    padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
    child: Container(
      decoration: _cardDeco(radius: 12),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: _filterLabels.entries.map((e) {
          final isActive = _dateFilter == e.key;
          return GestureDetector(
            onTap: () {
              if (e.key == 'custom') {
                setState(() {
                  _filterOpen = false;
                  _showCustom = true;
                });
              } else
                _applyFilter(e.key);
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              decoration: BoxDecoration(
                color: isActive ? _accentL : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  if (isActive)
                    const Icon(Icons.check_rounded, size: 13, color: _accent),
                  if (isActive) const SizedBox(width: 6),
                  Text(
                    e.value,
                    style: TextStyle(
                      fontSize: 13,
                      color: isActive ? _accent : _text1,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    ),
  );

  // ── Record card (mobile card style from React) ────────────────────────────
  Widget _buildRecordCard(CashBillingRecord r, int idx) => GestureDetector(
    onTap: () => setState(() {
      _selectedRecord = r;
      _showModal = true;
    }),
    child: Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: _cardDeco(),
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          // Header row
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: _accentL,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '$idx',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: _accent,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '#${r.orderId}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: _accent,
                      ),
                    ),
                    Text(
                      r.date,
                      style: const TextStyle(fontSize: 10, color: _text3),
                    ),
                  ],
                ),
              ),
              _statusBadge(r.paymentStatus),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(color: _border, height: 1),
          const SizedBox(height: 10),

          // Denominations inline
          if (r.denomBreakdown.isNotEmpty) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 6,
                runSpacing: 4,
                children: r.denomBreakdown
                    .map(
                      (d) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: _bg,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: _border),
                        ),
                        child: Text(
                          '${d['label']}×${d['count']}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: _text2,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 8),
          ],

          // Amounts row
          Row(
            children: [
              _amountCell('Grand Total', _fmt(r.grandTotal), _text1),
              _amountCell('Paid', _fmt(r.paid), _green),
              _amountCell('Return', _fmt(r.returnMoney), _accent),
            ],
          ),
        ],
      ),
    ),
  );

  Widget _amountCell(String label, String value, Color color) => Expanded(
    child: Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: _text3)),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    ),
  );

  Widget _statusBadge(String status) {
    final paid = status.toUpperCase() == 'PAID';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: paid ? _greenL : _amberL,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        paid ? 'PAID' : 'PENDING',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: paid ? _green : _amber,
        ),
      ),
    );
  }

  // ── Pagination ────────────────────────────────────────────────────────────
  Widget _buildPagination() {
    final totalPages = (_page!.totalElements / _pageSize).ceil();
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _pageBtn('◀ Prev', _currentPg > 0, () => _fetchPage(_currentPg - 1)),
          const SizedBox(width: 12),
          Text(
            'Page ${_currentPg + 1} of $totalPages  (${_page!.totalElements} records)',
            style: const TextStyle(fontSize: 11, color: _text2),
          ),
          const SizedBox(width: 12),
          _pageBtn(
            'Next ▶',
            _currentPg < totalPages - 1,
            () => _fetchPage(_currentPg + 1),
          ),
        ],
      ),
    );
  }

  Widget _pageBtn(String label, bool enabled, VoidCallback onTap) =>
      GestureDetector(
        onTap: enabled ? onTap : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: enabled ? _accent : _border,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: enabled ? Colors.white : _text3,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );

  // ── Empty state ───────────────────────────────────────────────────────────
  Widget _buildEmpty() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: _accentL,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.receipt_long_outlined,
            color: _accent,
            size: 28,
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'No records found',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: _text1,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'for ${_dateLabel()}',
          style: const TextStyle(color: _text2, fontSize: 12),
        ),
      ],
    ),
  );

  // ── Custom range modal ────────────────────────────────────────────────────
  Widget _buildCustomRangeModal() => Positioned.fill(
    child: GestureDetector(
      onTap: () => setState(() => _showCustom = false),
      child: Container(
        color: Colors.black54,
        child: Center(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Select Date Range',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: _text1,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _datePicker(
                    'Start Date',
                    _customFrom,
                    (d) => setState(() => _customFrom = d),
                  ),
                  const SizedBox(height: 12),
                  _datePicker(
                    'End Date',
                    _customTo,
                    (d) => setState(() => _customTo = d),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _showCustom = false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _bg,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: _border),
                            ),
                            child: const Center(
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  color: _text2,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: _applyCustomRange,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _accent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Center(
                              child: Text(
                                'Apply Range',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );

  Widget _datePicker(
    String label,
    DateTime? val,
    ValueChanged<DateTime> onPick,
  ) => GestureDetector(
    onTap: () async {
      final d = await showDatePicker(
        context: context,
        initialDate: val ?? DateTime.now(),
        firstDate: DateTime(2020),
        lastDate: DateTime.now(),
        builder: (ctx, child) => Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: _accent),
          ),
          child: child!,
        ),
      );
      if (d != null) onPick(d);
    },
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today_rounded, size: 14, color: _text2),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              val != null ? DateFormat('dd/MM/yyyy').format(val) : label,
              style: TextStyle(
                fontSize: 13,
                color: val != null ? _text1 : _text3,
                fontWeight: val != null ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    ),
  );

  // ── Detail modal ──────────────────────────────────────────────────────────
  Widget _buildDetailModal() {
    final r = _selectedRecord!;
    return Positioned.fill(
      child: GestureDetector(
        onTap: () => setState(() => _showModal = false),
        child: Container(
          color: Colors.black54,
          child: Center(
            child: GestureDetector(
              onTap: () {},
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: _card,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.fromLTRB(18, 18, 12, 14),
                      decoration: const BoxDecoration(
                        border: Border(bottom: BorderSide(color: _border)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Order #${r.orderId}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: _text1,
                                  ),
                                ),
                                Text(
                                  r.date,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: _text3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _statusBadge(r.paymentStatus),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(
                              Icons.close_rounded,
                              size: 20,
                              color: _text2,
                            ),
                            onPressed: () => setState(() => _showModal = false),
                          ),
                        ],
                      ),
                    ),

                    // Body
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          // Denomination breakdown grid
                          if (r.denomBreakdown.isNotEmpty) ...[
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Cash Denominations',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: _text1,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _bg,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: _border),
                              ),
                              child: Column(
                                children: r.denomBreakdown.map((d) {
                                  final count = d['count'] as int;
                                  final value = d['value'] as int;
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 5,
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 44,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _accentL,
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              d['label'] as String,
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                                color: _accent,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          '$count notes',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: _text2,
                                          ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          '= ₹${count * value}',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: _text1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            const SizedBox(height: 14),
                          ],

                          // Summary breakdown
                          _summaryRow(
                            'Grand Total',
                            _fmt(r.grandTotal),
                            _text1,
                          ),
                          const Divider(color: _border),
                          _summaryRow('Total Paid', _fmt(r.paid), _green),
                          _summaryRow(
                            'Return Amount',
                            _fmt(r.returnMoney),
                            _accent,
                          ),
                          _summaryRow('Date', r.date, _text2),
                          _summaryRow(
                            'Status',
                            r.paymentStatus,
                            r.isPaid ? _green : _amber,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String val, Color valColor) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: _text2)),
        const Spacer(),
        Text(
          val,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: valColor,
          ),
        ),
      ],
    ),
  );
}
