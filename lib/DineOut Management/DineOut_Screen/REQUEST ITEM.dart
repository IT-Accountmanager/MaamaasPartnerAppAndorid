import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../API/Apiclient.dart';

// ─────────────────────────── MODEL ───────────────────────────

class TableRequestModel {
  final int id;
  final int vendorId;
  final int? userId;
  final String name;
  final int itemId;
  final int? removalQuantity;
  final int? customerId;
  final int cartId;
  final int? tableBookingId;
  final String? tableCode;
  final String status;
  final String requestType;
  final String? reason;
  final String? createdAt;

  const TableRequestModel({
    required this.id,
    required this.vendorId,
    this.userId,
    required this.name,
    required this.itemId,
    this.removalQuantity,
    this.customerId,
    required this.cartId,
    this.tableBookingId,
    this.tableCode,
    required this.status,
    required this.requestType,
    this.reason,
    this.createdAt,
  });

  factory TableRequestModel.fromJson(Map<String, dynamic> json) {
    return TableRequestModel(
      id: json['id'] ?? 0,
      vendorId: json['vendorId'] ?? 0,
      userId: json['userId'],
      name: json['name'] ?? '',
      itemId: json['itemId'] ?? 0,
      removalQuantity: json['removalQuantity'],
      customerId: json['customerId'],
      cartId: json['cartId'] ?? 0,
      tableBookingId: json['tableBookingId'],
      tableCode: json['tableCode'],
      status: json['status'] ?? '',
      requestType: json['requestType'] ?? '',
      reason: json['reason'],
      createdAt: json['createdAt'],
    );
  }
}

// ─────────────────────────── SERVICE ───────────────────────────

class TableRequestService {
  static Future<List<TableRequestModel>> fetchTableRequests({
    required int vendorId,
  }) async {
    try {
      final response = await ApiClient.get(
        'api/table/request/$vendorId',
        service: 'food',
      );

      // debugPrint('📩 Table Request Status: ${response.statusCode}');
      // debugPrint('📦 Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList
            .map(
              (item) =>
                  TableRequestModel.fromJson(item as Map<String, dynamic>),
            )
            .toList();
      } else {
        throw Exception('Failed: ${response.statusCode}');
      }
    } catch (e) {
      // debugPrint('💥 fetchTableRequests error: $e');
      rethrow;
    }
  }
}


class TableRequestScreen extends StatefulWidget {
  const TableRequestScreen({super.key});

  @override
  State<TableRequestScreen> createState() => _TableRequestScreenState();
}

class _TableRequestScreenState extends State<TableRequestScreen>
    with SingleTickerProviderStateMixin {
  // ── State ──
  List<TableRequestModel> _allRequests = [];
  List<TableRequestModel> _filteredRequests = [];
  bool _isLoading = false;
  String? _error;

  String _selectedFilter = 'All';
  DateTime? _selectedDate;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // Scroll to hide summary card
  final ScrollController _scrollController = ScrollController();
  bool _showSummaryCard = true;
  double _lastScrollOffset = 0;

  // ── Colours ──
  static const _primaryColor = Color(0xffEA7000);
  static const _lightOrange = Color(0xffFFF7ED);
  static const _cardBg = Colors.white;

  // ─────────────────────────── LIFECYCLE ───────────────────────────

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _scrollController.addListener(_onScroll);
    _loadRequests();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final currentOffset = _scrollController.offset;
    // Scrolling up (positive delta) vs scrolling down (negative delta)
    if (_lastScrollOffset < currentOffset &&
        _showSummaryCard &&
        currentOffset > 50) {
      // Scrolling down - hide summary card
      setState(() {
        _showSummaryCard = false;
      });
    } else if (_lastScrollOffset > currentOffset && !_showSummaryCard) {
      // Scrolling up - show summary card
      setState(() {
        _showSummaryCard = true;
      });
    }
    _lastScrollOffset = currentOffset;
  }

  // ─────────────────────────── DATA ───────────────────────────

  Future<void> _loadRequests() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    _fadeController.reset();

    try {
      final prefs = await SharedPreferences.getInstance();
      final vendorId = prefs.getInt('vendorId') ?? 1;

      final requests = await TableRequestService.fetchTableRequests(
        vendorId: vendorId,
      );

      setState(() {
        _allRequests = requests;
        _applyFilter();
        _isLoading = false;
      });
      _fadeController.forward();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _applyFilter() {
    final now = DateTime.now();
    List<TableRequestModel> filtered;

    switch (_selectedFilter) {
      case 'Today':
        filtered = _allRequests.where((r) {
          final d = _parseDate(r.createdAt ?? '');
          return d != null &&
              d.year == now.year &&
              d.month == now.month &&
              d.day == now.day;
        }).toList();
        break;

      case 'Yesterday':
        final yesterday = now.subtract(const Duration(days: 1));
        filtered = _allRequests.where((r) {
          final d = _parseDate(r.createdAt ?? '');
          return d != null &&
              d.year == yesterday.year &&
              d.month == yesterday.month &&
              d.day == yesterday.day;
        }).toList();
        break;

      case 'Select Date':
        if (_selectedDate != null) {
          filtered = _allRequests.where((r) {
            final d = _parseDate(r.createdAt ?? '');
            return d != null &&
                d.year == _selectedDate!.year &&
                d.month == _selectedDate!.month &&
                d.day == _selectedDate!.day;
          }).toList();
        } else {
          filtered = List.from(_allRequests);
        }
        break;

      default:
        filtered = List.from(_allRequests);
    }

    // Sort by createdAt descending — most recent request at the top
    filtered.sort((a, b) {
      final da = _parseDate(a.createdAt ?? '');
      final db = _parseDate(b.createdAt ?? '');
      if (da == null && db == null) return 0;
      if (da == null) return 1;
      if (db == null) return -1;
      return db.compareTo(da);
    });

    setState(() => _filteredRequests = filtered);
  }

  DateTime? _parseDate(String s) {
    try {
      return DateTime.parse(s);
    } catch (_) {
      return DateTime.tryParse(s.split('T').first);
    }
  }

  // ─────────────────────────── FILTER ───────────────────────────

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: _primaryColor),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _selectedFilter = 'Select Date';
        _applyFilter();
      });
    }
  }

  void _clearFilter() {
    setState(() {
      _selectedFilter = 'All';
      _selectedDate = null;
      _applyFilter();
    });
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _FilterBottomSheet(
        selectedFilter: _selectedFilter,
        onSelect: (value) {
          Navigator.pop(context);
          if (value == 'Select Date') {
            _selectDate();
          } else {
            setState(() {
              _selectedFilter = value;
              _selectedDate = null;
              _applyFilter();
            });
          }
        },
      ),
    );
  }

  // ─────────────────────────── HELPERS ───────────────────────────

  String _activeFilterLabel() {
    if (_selectedFilter == 'Select Date' && _selectedDate != null) {
      return DateFormat('dd MMM yyyy').format(_selectedDate!);
    }
    return _selectedFilter;
  }

  int get _totalCount => _filteredRequests.length;
  int get _pendingCount => _filteredRequests
      .where((e) => e.status.toUpperCase() == 'PENDING')
      .length;
  int get _approvedCount =>
      _filteredRequests.where((e) => e.status.toUpperCase() == 'ACCEPT').length;
  int get _rejectedCount => _filteredRequests
      .where((e) => e.status.toUpperCase() == 'DECLINE')
      .length;

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'ACCEPT':
        return const Color(0xff16A34A);
      case 'DECLINE':
        return const Color(0xffDC2626);
      case 'PENDING':
      default:
        return const Color(0xffD97706);
    }
  }

  IconData _statusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'ACCEPT':
        return Icons.check_circle_rounded;
      case 'DECLINE':
        return Icons.cancel_rounded;
      default:
        return Icons.schedule_rounded;
    }
  }

  String _formatDate(String s) {
    try {
      return DateFormat('dd MMM yyyy • HH:mm').format(DateTime.parse(s));
    } catch (_) {
      return s;
    }
  }

  // ─────────────────────────── WIDGETS ───────────────────────────

  Widget _summaryCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xffEA7000), Color(0xffF97316), Color(0xffFB923C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          _summaryTile("Total", _totalCount),
          _divider(),
          _summaryTile("Pending", _pendingCount),
          _divider(),
          _summaryTile("Approved", _approvedCount),
          _divider(),
          _summaryTile("Rejected", _rejectedCount),
        ],
      ),
    );
  }

  Widget _divider() => Container(
    width: 1,
    height: 40,
    color: Colors.white.withOpacity(0.2),
    margin: const EdgeInsets.symmetric(horizontal: 4),
  );

  Widget _summaryTile(String label, int count) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$count',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withOpacity(0.8),
              fontWeight: FontWeight.w500,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterBar() {
    final isFiltered = _selectedFilter != 'All';
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${_filteredRequests.length} request${_filteredRequests.length == 1 ? '' : 's'}',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xff111827),
              ),
            ),
          ),
          if (isFiltered)
            GestureDetector(
              onTap: _clearFilter,
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _primaryColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _activeFilterLabel(),
                      style: const TextStyle(
                        fontSize: 12,
                        color: _primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.close_rounded,
                      size: 14,
                      color: _primaryColor,
                    ),
                  ],
                ),
              ),
            ),
          GestureDetector(
            onTap: _showFilterSheet,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: _primaryColor,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: _primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.tune_rounded, color: Colors.white, size: 16),
                  SizedBox(width: 6),
                  Text(
                    'Filter',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _requestCard(TableRequestModel req) {
    final statusColor = _statusColor(req.status);
    final statusIcon = _statusIcon(req.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Header bar ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _lightOrange,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '#${req.id}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: statusColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, color: statusColor, size: 14),
                      const SizedBox(width: 5),
                      Text(
                        req.status.toUpperCase(),
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Body ──
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _infoCell(
                      icon: Icons.table_restaurant_rounded,
                      label: 'Table Code',
                      value: req.tableCode ?? 'N/A',
                    ),
                    const SizedBox(width: 12),
                    _infoCell(
                      icon: Icons.fastfood_rounded,
                      label: 'Item ID',
                      value: '#${req.itemId}',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _infoCell(
                      icon: Icons.category_rounded,
                      label: 'Request Type',
                      value: req.requestType,
                    ),
                    const SizedBox(width: 12),
                    _infoCell(
                      icon: Icons.production_quantity_limits_rounded,
                      label: 'Quantity',
                      value: req.removalQuantity?.toString() ?? '—',
                    ),
                  ],
                ),
                if (req.reason != null && req.reason!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xffFFFBEB),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xffFDE68A),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          size: 15,
                          color: Color(0xffD97706),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            req.reason!,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xff92400E),
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xffF3F4F6)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(
                      Icons.person_outline_rounded,
                      size: 14,
                      color: Color(0xff6B7280),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        req.name.isNotEmpty
                            ? req.name
                            : (req.userId?.toString() ?? 'N/A'),
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xff374151),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (req.createdAt != null) ...[
                      const Icon(
                        Icons.schedule_rounded,
                        size: 14,
                        color: Color(0xff9CA3AF),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(req.createdAt!),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xff9CA3AF),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCell({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xffF9FAFB),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: const Color(0xff6B7280)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xff9CA3AF),
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xff111827),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    final filtered = _selectedFilter != 'All';
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _lightOrange,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.inbox_rounded, size: 56, color: _primaryColor),
          ),
          const SizedBox(height: 20),
          Text(
            filtered
                ? 'No requests for ${_activeFilterLabel()}'
                : 'No requests yet',
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Color(0xff111827),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            filtered
                ? 'Try changing the filter or date range.'
                : 'New table requests will appear here.',
            style: const TextStyle(fontSize: 14, color: Color(0xff6B7280)),
            textAlign: TextAlign.center,
          ),
          if (filtered) ...[
            const SizedBox(height: 20),
            TextButton.icon(
              onPressed: _clearFilter,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Show All Requests'),
              style: TextButton.styleFrom(
                foregroundColor: _primaryColor,
                textStyle: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _errorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              size: 56,
              color: Color(0xffDC2626),
            ),
            const SizedBox(height: 16),
            const Text(
              'Failed to load requests',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xff111827),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Unknown error',
              style: const TextStyle(fontSize: 13, color: Color(0xff6B7280)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadRequests,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────── BUILD ───────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFFF8F0),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: _primaryColor,
                  strokeWidth: 3,
                ),
              )
            : _error != null
            ? _errorState()
            : FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Animated Summary Card with hide/show on scroll
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: _showSummaryCard ? 1.0 : 0.0,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: _showSummaryCard ? null : 0,
                        child: _showSummaryCard
                            ? _summaryCard()
                            : const SizedBox.shrink(),
                      ),
                    ),
                    _filterBar(),
                    Expanded(
                      child: _filteredRequests.isEmpty
                          ? _emptyState()
                          : RefreshIndicator(
                              onRefresh: _loadRequests,
                              color: _primaryColor,
                              child: ListView.builder(
                                controller: _scrollController,
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  4,
                                  16,
                                  24,
                                ),
                                physics: const AlwaysScrollableScrollPhysics(),
                                itemCount: _filteredRequests.length,
                                itemBuilder: (_, i) =>
                                    _requestCard(_filteredRequests[i]),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

// ─────────────────────────── FILTER BOTTOM SHEET ───────────────────────────

class _FilterBottomSheet extends StatelessWidget {
  const _FilterBottomSheet({
    required this.selectedFilter,
    required this.onSelect,
  });

  final String selectedFilter;
  final void Function(String) onSelect;

  static const _primaryColor = Color(0xffEA7000);

  @override
  Widget build(BuildContext context) {
    const options = [
      _FilterOption(
        label: 'All Requests',
        value: 'All',
        icon: Icons.format_list_bulleted_rounded,
        subtitle: 'Show everything',
      ),
      _FilterOption(
        label: 'Today',
        value: 'Today',
        icon: Icons.today_rounded,
        subtitle: "Today's requests only",
      ),
      _FilterOption(
        label: 'Yesterday',
        value: 'Yesterday',
        icon: Icons.history_rounded,
        subtitle: 'From yesterday',
      ),
      _FilterOption(
        label: 'Pick a Date',
        value: 'Select Date',
        icon: Icons.calendar_month_rounded,
        subtitle: 'Choose any specific date',
      ),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Text(
                'Filter Requests',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xff111827),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xffFFF7ED),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: Color(0xff6B7280),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...options.map((opt) {
            final isSelected = selectedFilter == opt.value;
            return GestureDetector(
              onTap: () => onSelect(opt.value),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xffFFF7ED)
                      : const Color(0xffF9FAFB),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? _primaryColor.withOpacity(0.4)
                        : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? _primaryColor.withOpacity(0.12)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        opt.icon,
                        color: isSelected
                            ? _primaryColor
                            : const Color(0xff6B7280),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            opt.label,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: isSelected
                                  ? _primaryColor
                                  : const Color(0xff111827),
                            ),
                          ),
                          Text(
                            opt.subtitle,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xff9CA3AF),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      const Icon(
                        Icons.check_circle_rounded,
                        color: _primaryColor,
                        size: 20,
                      ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _FilterOption {
  const _FilterOption({
    required this.label,
    required this.value,
    required this.icon,
    required this.subtitle,
  });

  final String label;
  final String value;
  final IconData icon;
  final String subtitle;
}
