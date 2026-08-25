import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/support_models.dart';
import '../services/support_service.dart';
import '../widgets/theme.dart';

class InternalTicketsScreen extends StatefulWidget {
  const InternalTicketsScreen({super.key});
  @override
  State<InternalTicketsScreen> createState() => _InternalTicketsScreenState();
}

class _InternalTicketsScreenState extends State<InternalTicketsScreen> {
  List<InternalIssue> _all = [];
  bool _loading = false;

  // Filters & search
  final _searchCtrl = TextEditingController();
  String _searchTerm = '';
  String _filterPriority = '';
  String _filterStatus = '';
  String _filterDate =
      'This Month'; // All | Today | Yesterday | This Week | This Month | Last Month
  bool _filterOpen = false;
  DateTime? _customFrom;
  DateTime? _customTo;
  bool _showCustomDate = false;

  // Create/Edit modal
  bool _showModal = false;
  int? _editId;
  bool _saving = false;
  final _descCtrl = TextEditingController();
  final _raisedCtrl = TextEditingController();
  String _formPriority = 'LOW';
  String _formStatus = 'OPEN';

  // Stats
  List<InternalIssue> get _filtered {
    var list = _all.where((p) {
      final q = _searchTerm.toLowerCase();
      if (q.isNotEmpty &&
          !p.description.toLowerCase().contains(q) &&
          !p.raisedBy.toLowerCase().contains(q))
        return false;
      if (_filterPriority.isNotEmpty && p.priority != _filterPriority)
        return false;
      if (_filterStatus.isNotEmpty && p.status != _filterStatus) return false;
      return true;
    }).toList();

    // Date filter
    if (_filterDate != 'All') {
      final range = _dateRange(_filterDate);
      if (range != null) {
        list = list.where((p) {
          if (p.createdAt.isEmpty) return false;
          try {
            final d = DateTime.parse(p.createdAt);
            final day = DateTime(d.year, d.month, d.day);
            return !day.isBefore(range.$1) && !day.isAfter(range.$2);
          } catch (_) {
            return false;
          }
        }).toList();
      }
    }
    return list;
  }

  (DateTime, DateTime)? _dateRange(String key) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    switch (key) {
      case 'Today':
        return (today, today);
      case 'Yesterday':
        final y = today.subtract(const Duration(days: 1));
        return (y, y);
      case 'This Week':
        final wd = today.weekday;
        final mon = today.subtract(Duration(days: wd - 1));
        return (mon, mon.add(const Duration(days: 6)));
      case 'This Month':
        return (
          DateTime(now.year, now.month, 1),
          DateTime(now.year, now.month + 1, 0),
        );
      case 'Last Month':
        return (
          DateTime(now.year, now.month - 1, 1),
          DateTime(now.year, now.month, 0),
        );
      case 'Custom':
        return _customFrom != null && _customTo != null
            ? (_customFrom!, _customTo!)
            : null;
      default:
        return null;
    }
  }

  int get _statTotal => _filtered.length;
  int get _statOpen => _filtered.where((p) => p.status == 'OPEN').length;
  int get _statProgress =>
      _filtered.where((p) => p.status == 'IN_PROGRESS').length;
  int get _statClosed => _filtered.where((p) => p.status == 'CLOSED').length;
  int get _statLow => _filtered.where((p) => p.priority == 'LOW').length;
  int get _statMedium => _filtered.where((p) => p.priority == 'MEDIUM').length;
  int get _statHigh => _filtered.where((p) => p.priority == 'HIGH').length;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _descCtrl.dispose();
    _raisedCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final list = await SupportService.getIssues();
    if (mounted)
      setState(() {
        _all = list;
        _loading = false;
      });
  }

  void _openCreate() {
    _editId = null;
    _descCtrl.clear();
    _raisedCtrl.clear();
    setState(() {
      _formPriority = 'LOW';
      _formStatus = 'OPEN';
      _showModal = true;
    });
  }

  void _openEdit(InternalIssue issue) {
    if (issue.status == 'CLOSED') {
      spSnack(context, 'Closed issues cannot be edited', warn: true);
      return;
    }
    _editId = issue.id;
    _descCtrl.text = issue.description;
    _raisedCtrl.text = issue.raisedBy;
    setState(() {
      _formPriority = issue.priority;
      _formStatus = issue.status;
      _showModal = true;
    });
  }

  Future<void> _save() async {
    if (_descCtrl.text.trim().isEmpty || _raisedCtrl.text.trim().isEmpty) {
      spSnack(context, 'Fill all required fields', warn: true);
      return;
    }
    setState(() => _saving = true);
    final issue = InternalIssue(
      id: _editId ?? 0,
      description: _descCtrl.text.trim(),
      raisedBy: _raisedCtrl.text.trim(),
      priority: _formPriority,
      status: _editId != null ? _formStatus : 'OPEN',
    );
    final ok = _editId != null
        ? await SupportService.updateIssue(_editId!, issue)
        : await SupportService.createIssue(issue);
    if (mounted) {
      setState(() {
        _saving = false;
        _showModal = false;
      });
      if (ok) {
        spSnack(
          context,
          _editId != null ? '✅ Ticket updated!' : '✅ Ticket created!',
        );
        _load();
      } else {
        spSnack(context, '❌ Server error', error: true);
      }
    }
  }

  Future<void> _delete(int id) async {
    final ok =
        await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('Delete Ticket'),
            content: const Text('Are you sure you want to delete this issue?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete', style: TextStyle(color: spRed)),
              ),
            ],
          ),
        ) ??
        false;
    if (!ok) return;
    final done = await SupportService.deleteIssue(id);
    if (mounted) {
      spSnack(context, done ? '🗑️ Deleted!' : '❌ Delete failed', error: !done);
      if (done) _load();
    }
  }

  String _fmtDate(String d) {
    if (d.isEmpty) return '-';
    try {
      return DateFormat('dd-MM-yyyy').format(DateTime.parse(d));
    } catch (_) {
      return d;
    }
  }

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      Column(
        children: [
          // Stats row
          SizedBox(
            height: 82,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
              children: [
                _statCard('Total', '$_statTotal', spBlue),
                _statCard('Open', '$_statOpen', spBlue),
                _statCard('Progress', '$_statProgress', spAmber),
                _statCard('Closed', '$_statClosed', spGreen),
                _statCard('Low', '$_statLow', const Color(0xFFF59E0B)),
                _statCard('Medium', '$_statMedium', spAccent),
                _statCard('High', '$_statHigh', spRed),
              ],
            ),
          ),

          // Search + Filter + Create
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 42,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: spBorder),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.search_rounded,
                          size: 16,
                          color: spText3,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _searchCtrl,
                            decoration: const InputDecoration(
                              hintText: 'Search ticket...',
                              hintStyle: TextStyle(
                                color: spText3,
                                fontSize: 12,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                              isDense: true,
                            ),
                            style: const TextStyle(
                              fontSize: 13,
                              color: spText1,
                            ),
                            onChanged: (v) => setState(() => _searchTerm = v),
                          ),
                        ),
                        if (_searchTerm.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              _searchCtrl.clear();
                              setState(() => _searchTerm = '');
                            },
                            child: const Icon(
                              Icons.close_rounded,
                              size: 14,
                              color: spText3,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _activeFilters > 0
                    ? GestureDetector(
                        onTap: () => setState(() => _filterOpen = !_filterOpen),
                        child: Container(
                          height: 42,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: spAccent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.filter_list_rounded,
                                size: 14,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$_activeFilters',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : GestureDetector(
                        onTap: () => setState(() => _filterOpen = !_filterOpen),
                        child: Container(
                          height: 42,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: spBorder),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.filter_list_rounded,
                                size: 14,
                                color: spText2,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Filter',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: spText2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _openCreate,
                  child: Container(
                    height: 42,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: spAccent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add_rounded, size: 15, color: Colors.white),
                        SizedBox(width: 4),
                        Text(
                          'Create',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Filter panel
          if (_filterOpen) _buildFilterPanel(),

          // List
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: spAccent,
                      strokeWidth: 2,
                    ),
                  )
                : _filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.inbox_rounded,
                          size: 48,
                          color: spText3,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _searchTerm.isNotEmpty
                              ? 'No issues found for "$_searchTerm"'
                              : 'No issues found',
                          style: const TextStyle(color: spText2, fontSize: 13),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    color: spAccent,
                    onRefresh: _load,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 32),
                      itemCount: _filtered.length,
                      itemBuilder: (_, i) => _issueCard(_filtered[i], i + 1),
                    ),
                  ),
          ),
        ],
      ),

      // Modal
      if (_showModal) _buildModal(),
    ],
  );

  int get _activeFilters {
    int n = 0;
    if (_filterPriority.isNotEmpty) n++;
    if (_filterStatus.isNotEmpty) n++;
    if (_filterDate != 'This Month') n++;
    return n;
  }

  Widget _buildFilterPanel() => Padding(
    padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
    child: Container(
      decoration: spCardDeco(radius: 14),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Filter Issues',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: spText1,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => setState(() {
                  _filterPriority = '';
                  _filterStatus = '';
                  _filterDate = 'This Month';
                  _filterOpen = false;
                  _showCustomDate = false;
                }),
                child: const Text(
                  'Clear all',
                  style: TextStyle(
                    color: spRed,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _miniDropdown(
                  'Priority',
                  _filterPriority,
                  {'': 'All', 'LOW': 'Low', 'MEDIUM': 'Medium', 'HIGH': 'High'},
                  (v) => setState(() => _filterPriority = v),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _miniDropdown('Status', _filterStatus, {
                  '': 'All',
                  'OPEN': 'Open',
                  'IN_PROGRESS': 'In Progress',
                  'CLOSED': 'Closed',
                }, (v) => setState(() => _filterStatus = v)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _miniDropdown(
                  'Date',
                  _filterDate,
                  {
                    'All': 'All',
                    'Today': 'Today',
                    'Yesterday': 'Yesterday',
                    'This Week': 'This Week',
                    'This Month': 'This Month',
                    'Last Month': 'Last Month',
                    'Custom': 'Custom',
                  },
                  (v) {
                    setState(() {
                      _filterDate = v;
                      _showCustomDate = v == 'Custom';
                    });
                  },
                ),
              ),
            ],
          ),
          if (_showCustomDate) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _datePicker(
                    'From',
                    _customFrom,
                    (d) => setState(() => _customFrom = d),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text('to', style: TextStyle(color: spText2)),
                ),
                Expanded(
                  child: _datePicker(
                    'To',
                    _customTo,
                    (d) => setState(() => _customTo = d),
                  ),
                ),
              ],
            ),
          ],
        ],
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
      );
      if (d != null) onPick(d);
    },
    child: Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: spBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: spBorder),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today_rounded, size: 12, color: spText3),
          const SizedBox(width: 6),
          Text(
            val != null ? DateFormat('dd/MM/yy').format(val) : label,
            style: TextStyle(
              fontSize: 11,
              color: val != null ? spText1 : spText3,
            ),
          ),
        ],
      ),
    ),
  );

  Widget _miniDropdown(
    String hint,
    String val,
    Map<String, String> opts,
    ValueChanged<String> onChanged,
  ) => Container(
    height: 38,
    padding: const EdgeInsets.symmetric(horizontal: 8),
    decoration: BoxDecoration(
      color: spBg,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: spBorder),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: val,
        isExpanded: true,
        style: const TextStyle(fontSize: 11, color: spText1),
        items: opts.entries
            .map(
              (e) => DropdownMenuItem(
                value: e.key,
                child: Text(e.value, style: const TextStyle(fontSize: 11)),
              ),
            )
            .toList(),
        onChanged: (v) => v != null ? onChanged(v) : null,
      ),
    ),
  );

  Widget _issueCard(InternalIssue issue, int idx) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    decoration: spCardDeco(),
    padding: const EdgeInsets.all(14),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Index + priority dot
        Column(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: spAccentL,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '$idx',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: spAccent,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: spPriorityColor(issue.priority),
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
        const SizedBox(width: 12),
        // Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                issue.description,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: spText1,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  if (issue.raisedBy.isNotEmpty) ...[
                    const Icon(
                      Icons.person_outline_rounded,
                      size: 11,
                      color: spText3,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      issue.raisedBy,
                      style: const TextStyle(fontSize: 11, color: spText2),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    _fmtDate(issue.createdAt),
                    style: const TextStyle(fontSize: 10, color: spText3),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _badge(issue.priority, spPriorityColor(issue.priority), true),
                  const SizedBox(width: 6),
                  _badge(
                    issue.status.replaceAll('_', ' '),
                    spStatusColor(issue.status),
                    false,
                  ),
                ],
              ),
            ],
          ),
        ),
        // Actions
        Column(
          children: [
            GestureDetector(
              onTap: () => _openEdit(issue),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: issue.status == 'CLOSED' ? spGrayL : spAccentL,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.edit_rounded,
                  size: 15,
                  color: issue.status == 'CLOSED' ? spText3 : spAccent,
                ),
              ),
            ),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: () => _delete(issue.id),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: spRedL,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  size: 15,
                  color: spRed,
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _badge(String label, Color color, bool filled) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: filled ? color : color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(20),
      border: filled ? null : Border.all(color: color.withOpacity(0.4)),
    ),
    child: Text(
      label,
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: filled ? Colors.white : color,
      ),
    ),
  );

  Widget _statCard(String label, String val, Color color) => Container(
    width: 70,
    margin: const EdgeInsets.only(right: 8),
    decoration: spCardDeco(radius: 12),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          val,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            color: spText2,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );

  Widget _buildModal() => Positioned.fill(
    child: Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: spCard,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 12, 0),
                child: Row(
                  children: [
                    Text(
                      _editId != null ? 'Edit Ticket' : 'Create Ticket',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: spText1,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: spText2),
                      onPressed: () => setState(() => _showModal = false),
                    ),
                  ],
                ),
              ),
              const Divider(color: spBorder),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: Column(
                  children: [
                    // Description — readonly when editing
                    Container(
                      decoration: BoxDecoration(
                        color: _editId != null ? spBg : spCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: spBorder),
                      ),
                      child: TextField(
                        controller: _descCtrl,
                        enabled: _editId == null,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Description *',
                          hintStyle: const TextStyle(
                            color: spText3,
                            fontSize: 13,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(14),
                          fillColor: _editId != null ? spBg : null,
                          filled: _editId != null,
                        ),
                        style: const TextStyle(fontSize: 13, color: spText1),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Raised by — readonly when editing
                    Container(
                      decoration: BoxDecoration(
                        color: _editId != null ? spBg : spCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: spBorder),
                      ),
                      child: TextField(
                        controller: _raisedCtrl,
                        enabled: _editId == null,
                        decoration: InputDecoration(
                          hintText: 'Raised By *',
                          hintStyle: const TextStyle(
                            color: spText3,
                            fontSize: 13,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(14),
                          fillColor: _editId != null ? spBg : null,
                          filled: _editId != null,
                        ),
                        style: const TextStyle(fontSize: 13, color: spText1),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Priority
                    _modalDropdown(
                      'Priority',
                      _formPriority,
                      {'LOW': 'Low', 'MEDIUM': 'Medium', 'HIGH': 'High'},
                      (v) => setState(() => _formPriority = v),
                    ),
                    // Status — only in edit mode
                    if (_editId != null) ...[
                      const SizedBox(height: 12),
                      _modalDropdown('Status', _formStatus, {
                        'OPEN': 'Open',
                        'IN_PROGRESS': 'In Progress',
                        'CLOSED': 'Closed',
                      }, (v) => setState(() => _formStatus = v)),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _showModal = false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: spBg,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: spBorder),
                              ),
                              child: const Center(
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: spText2,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: _saving ? null : _save,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: spAccent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: _saving
                                  ? const Center(
                                      child: SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    )
                                  : const Center(
                                      child: Text(
                                        'Save',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
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
            ],
          ),
        ),
      ),
    ),
  );

  Widget _modalDropdown(
    String label,
    String val,
    Map<String, String> opts,
    ValueChanged<String> onChanged,
  ) => Container(
    decoration: BoxDecoration(
      color: spBg,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: spBorder),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 14),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: val,
        isExpanded: true,
        hint: Text(label, style: const TextStyle(color: spText3, fontSize: 13)),
        style: const TextStyle(fontSize: 13, color: spText1),
        items: opts.entries
            .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
            .toList(),
        onChanged: (v) => v != null ? onChanged(v) : null,
      ),
    ),
  );
}
