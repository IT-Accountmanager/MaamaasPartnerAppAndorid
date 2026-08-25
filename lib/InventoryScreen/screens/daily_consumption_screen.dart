
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/inv_models.dart';
import '../services/inventory_service.dart';
import '../widgets/theme.dart';

class DailyConsumptionScreen extends StatefulWidget {
  const DailyConsumptionScreen({super.key});
  @override
  State<DailyConsumptionScreen> createState() => _DailyConsumptionScreenState();
}

class _DailyConsumptionScreenState extends State<DailyConsumptionScreen> {
  List<ConsumptionLog> _logs = [], _filtered = [];
  List<InvItem> _invItems = [];
  bool _loading = false;
  String _search = '';

  // Modal
  bool _showModal = false;
  bool _saving = false;
  String _logDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  String _requestedBy = '';
  String _selCategory = '';
  String _selItem = '';
  String _qtyUsed = '';
  String _remarks = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final results = await Future.wait([
      InventoryService.fetchConsumptionLogs(),
      InventoryService.fetchItems(),
    ]);
    if (mounted)
      setState(() {
        _logs = results[0] as List<ConsumptionLog>;
        _invItems = results[1] as List<InvItem>;
        _loading = false;
        _applyFilters();
      });
  }

  void _applyFilters() {
    var list = List<ConsumptionLog>.from(_logs);
    if (_search.isNotEmpty)
      list = list
          .where((l) => l.item.toLowerCase().contains(_search.toLowerCase()))
          .toList();
    setState(() => _filtered = list);
  }

  // Stats
  final String _today = DateFormat('yyyy-MM-dd').format(DateTime.now());
  double get _totalQtyToday =>
      _logs.where((l) => l.date == _today).fold(0, (s, l) => s + l.qtyUsed);
  int get _totalEntries => _logs.length;
  int get _todayEntries => _logs.where((l) => l.date == _today).length;

  List<String> get _categories =>
      _invItems.map((i) => i.category).toSet().toList();
  List<InvItem> get _itemsForCat =>
      _invItems.where((i) => i.category == _selCategory).toList();
  InvItem? get _selItemDetails => _invItems.firstWhere(
    (i) => i.itemName == _selItem,
    orElse: () => const InvItem(),
  );

  Future<void> _logConsumption() async {
    if (_requestedBy.isEmpty ||
        _selCategory.isEmpty ||
        _selItem.isEmpty ||
        _qtyUsed.isEmpty)
      return;
    setState(() => _saving = true);

    final item = _selItemDetails;
    if (item == null || item.id == 0) {
      setState(() => _saving = false);
      return;
    }
    final before = item.qty;
    final qty = double.tryParse(_qtyUsed) ?? 0;
    final after = (before - qty).clamp(0, double.infinity);
    final payload = {
      'inventoryId': item.id,
      'vendorId': item.vendorId,
      'requestedBy': _requestedBy,
      'qtyUsed': qty,
      'unit': item.unit,
      'beforeQty': before,
      'afterQty': after,
      'remarks': _remarks,
      'date': _logDate,
      'status': 'IN_STOCK',
      'category': item.category,
      'itemName': item.itemName,
    };
    final ok = await InventoryService.addConsumptionLog(payload);
    if (mounted) {
      setState(() {
        _saving = false;
        _showModal = false;
      });
      invSnack(
        context,
        ok ? '✅ Consumption logged!' : '❌ Failed to log',
        error: !ok,
      );
      if (ok) {
        _selCategory = '';
        _selItem = '';
        _requestedBy = '';
        _qtyUsed = '';
        _remarks = '';
        _load();
      }
    }
  }

  String _fmtDate(String s) {
    if (s.isEmpty) return '—';
    try {
      return DateFormat('dd-MM-yyyy').format(DateTime.parse(s));
    } catch (_) {
      return s;
    }
  }

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      Column(
        children: [
          // Stats
          SizedBox(
            height: 88,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
              children: [
                _statCard(
                  'Total Qty\nToday',
                  _totalQtyToday.toStringAsFixed(1),
                  invAccent,
                ),
                _statCard(
                  'Total Entries',
                  '$_totalEntries',
                  const Color(0xFF0078D4),
                ),
                _statCard("Today's Entries", '$_todayEntries', invGreen),
              ],
            ),
          ),
          // Search + Log button
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search logs...',
                        hintStyle: const TextStyle(
                          color: invText3,
                          fontSize: 12,
                        ),
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          size: 16,
                          color: invText3,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: invBorder),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: invBorder),
                        ),
                        filled: true,
                        fillColor: invCard,
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                      ),
                      style: const TextStyle(fontSize: 12),
                      onChanged: (v) {
                        _search = v;
                        _applyFilters();
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => setState(() => _showModal = true),
                  child: Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: invAccent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add_rounded, size: 16, color: Colors.white),
                        SizedBox(width: 4),
                        Text(
                          'Log',
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
          const SizedBox(height: 10),
          // List
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: invAccent,
                      strokeWidth: 2,
                    ),
                  )
                : _filtered.isEmpty
                ? const Center(
                    child: Text(
                      'No consumption entries found.',
                      style: TextStyle(color: invText2),
                    ),
                  )
                : RefreshIndicator(
                    color: invAccent,
                    onRefresh: _load,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 32),
                      itemCount: _filtered.length,
                      itemBuilder: (_, i) => _logCard(_filtered[i]),
                    ),
                  ),
          ),
        ],
      ),
      if (_showModal) _buildModal(),
    ],
  );

  Widget _statCard(String label, String val, Color color) => Container(
    width: 110,
    margin: const EdgeInsets.only(right: 10),
    decoration: invCardDeco(radius: 12),
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
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(fontSize: 9, color: invText2),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );

  Widget _logCard(ConsumptionLog l) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    decoration: invCardDeco(),
    padding: const EdgeInsets.all(14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.item,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: invText1,
                    ),
                  ),
                  Text(
                    '${l.category} • ${_fmtDate(l.date)}',
                    style: const TextStyle(fontSize: 11, color: invText2),
                  ),
                ],
              ),
            ),
            invStatusBadge(l.status.isEmpty ? 'Completed' : l.status),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            _chip(Icons.person_outline_rounded, l.requestedBy),
            _chip(Icons.straighten_rounded, '${l.qtyUsed} ${l.unit} used'),
            _chip(Icons.arrow_forward_rounded, '${l.before} → ${l.after}'),
            if (l.remarks.isNotEmpty) _chip(Icons.notes_rounded, l.remarks),
          ],
        ),
      ],
    ),
  );

  Widget _chip(IconData icon, String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: invBg,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: invBorder),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: invText3),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: invText2),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    ),
  );

  // ── Log Consumption Modal ──────────────────────────────────────────────────
  Widget _buildModal() => Positioned.fill(
    child: GestureDetector(
      onTap: () => setState(() => _showModal = false),
      child: Container(
        color: Colors.black54,
        child: Center(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              decoration: BoxDecoration(
                color: invCard,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 18, 12, 0),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Log Consumption',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: invText1,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.close_rounded,
                            color: invText2,
                          ),
                          onPressed: () => setState(() => _showModal = false),
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: invBorder),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(18, 4, 18, 18),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Date
                          invSectionLabel('Date'),
                          GestureDetector(
                            onTap: () async {
                              final d = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2023),
                                lastDate: DateTime.now(),
                                builder: (ctx, child) => Theme(
                                  data: ThemeData.light().copyWith(
                                    colorScheme: const ColorScheme.light(
                                      primary: invAccent,
                                    ),
                                  ),
                                  child: child!,
                                ),
                              );
                              if (d != null)
                                setState(
                                  () => _logDate = DateFormat(
                                    'yyyy-MM-dd',
                                  ).format(d),
                                );
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: invBg,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: invBorder),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today_outlined,
                                    size: 14,
                                    color: invText3,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _logDate,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: invText1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Requested By
                          invSectionLabel('Requested By'),
                          TextFormField(
                            decoration: invInputDeco('Enter name'),
                            style: const TextStyle(fontSize: 13),
                            onChanged: (v) => _requestedBy = v,
                          ),
                          const SizedBox(height: 12),
                          // Category
                          invSectionLabel('Category'),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: invBg,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: invBorder),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selCategory.isEmpty
                                    ? null
                                    : _selCategory,
                                hint: const Text(
                                  'Select',
                                  style: TextStyle(
                                    color: invText3,
                                    fontSize: 13,
                                  ),
                                ),
                                isExpanded: true,
                                items: _categories
                                    .map(
                                      (c) => DropdownMenuItem(
                                        value: c,
                                        child: Text(
                                          c,
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (v) => setState(() {
                                  _selCategory = v ?? '';
                                  _selItem = '';
                                }),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Item
                          invSectionLabel('Item'),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: _selCategory.isEmpty
                                  ? const Color(0xFFF3F4F6)
                                  : invBg,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: invBorder),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selItem.isEmpty ? null : _selItem,
                                hint: const Text(
                                  'Select',
                                  style: TextStyle(
                                    color: invText3,
                                    fontSize: 13,
                                  ),
                                ),
                                isExpanded: true,
                                disabledHint: const Text(
                                  'Select category first',
                                  style: TextStyle(
                                    color: invText3,
                                    fontSize: 13,
                                  ),
                                ),
                                onChanged: _selCategory.isEmpty
                                    ? null
                                    : (v) => setState(() => _selItem = v ?? ''),
                                items: _itemsForCat
                                    .map(
                                      (i) => DropdownMenuItem(
                                        value: i.itemName,
                                        child: Text(
                                          i.itemName,
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Qty
                          invSectionLabel('Quantity Used'),
                          TextFormField(
                            decoration: invInputDeco(
                              'Enter quantity',
                              suffix: _selItem.isNotEmpty
                                  ? Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: Text(
                                        'Avail: ${_selItemDetails?.qty ?? 0}',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: invText3,
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                            style: const TextStyle(fontSize: 13),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            onChanged: (v) => _qtyUsed = v,
                          ),
                          const SizedBox(height: 12),
                          // Remarks
                          invSectionLabel('Remarks'),
                          TextFormField(
                            decoration: invInputDeco(
                              'e.g. Lunch prep - Biryani',
                            ),
                            style: const TextStyle(fontSize: 13),
                            maxLines: 2,
                            onChanged: (v) => _remarks = v,
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () =>
                                      setState(() => _showModal = false),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: invText2,
                                    side: const BorderSide(color: invBorder),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                  ),
                                  child: const Text(
                                    'Cancel',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed:
                                      (_saving ||
                                          _requestedBy.isEmpty ||
                                          _selCategory.isEmpty ||
                                          _selItem.isEmpty ||
                                          _qtyUsed.isEmpty)
                                      ? null
                                      : _logConsumption,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: invAccent,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    disabledBackgroundColor: invBorder,
                                  ),
                                  child: _saving
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Text(
                                          'Log Entry',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
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
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
