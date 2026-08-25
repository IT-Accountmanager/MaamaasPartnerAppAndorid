
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/inv_models.dart';
import '../services/inventory_service.dart';
import '../widgets/theme.dart';

class StockManagementScreen extends StatefulWidget {
  const StockManagementScreen({super.key});
  @override
  State<StockManagementScreen> createState() => _StockManagementScreenState();
}

class _StockManagementScreenState extends State<StockManagementScreen> {
  List<InvItem> _all = [], _filtered = [];
  bool _loading = false;
  String _search = '';
  String _statusFilter = 'All Status';
  String _dateFilter = 'All';

  // Modals
  bool _showAddModal = false;
  InvItem? _editing;

  // Form
  final _catCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController();
  final _costCtrl = TextEditingController();
  String _unit = 'KG';
  bool _saving = false;
  int _vendorId =
      1;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _catCtrl.dispose();
    _nameCtrl.dispose();
    _qtyCtrl.dispose();
    _costCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final items = await InventoryService.fetchItems();
    if (mounted)
      setState(() {
        _all = items;
        _loading = false;
        _applyFilters();
      });
  }

  void _applyFilters() {
    var list = List<InvItem>.from(_all);
    if (_search.isNotEmpty)
      list = list
          .where(
            (i) => i.itemName.toLowerCase().contains(_search.toLowerCase()),
          )
          .toList();
    if (_statusFilter != 'All Status')
      list = list.where((i) => i.status == _statusFilter).toList();
    // Date filter
    final now = DateTime.now();
    if (_dateFilter != 'All') {
      list = list.where((i) {
        try {
          final d = DateTime.parse(i.lastUpdated);
          switch (_dateFilter) {
            case 'Today':
              return _sameDay(d, now);
            case 'Yesterday':
              return _sameDay(d, now.subtract(const Duration(days: 1)));
            case 'Week':
              return d.isAfter(now.subtract(const Duration(days: 7)));
            case 'Month':
              return d.isAfter(now.subtract(const Duration(days: 30)));
            default:
              return true;
          }
        } catch (_) {
          return true;
        }
      }).toList();
    }
    setState(() => _filtered = list);
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  // Stats
  int get _totalItems => _all.length;
  int get _inStock => _all.where((i) => i.status == 'In Stock').length;
  int get _lowStock => _all.where((i) => i.status == 'Low Stock').length;
  int get _outOfStock => _all.where((i) => i.status == 'Out of Stock').length;

  void _openAdd() {
    _editing = null;
    _catCtrl.clear();
    _nameCtrl.clear();
    _qtyCtrl.clear();
    _costCtrl.clear();
    _unit = 'KG';
    setState(() => _showAddModal = true);
  }

  void _openEdit(InvItem item) {
    _editing = item;
    _catCtrl.text = item.category;
    _nameCtrl.text = item.itemName;
    _qtyCtrl.text = item.qty.toString();
    _costCtrl.text = item.costPerUnit.toString();
    _unit = item.unit;
    setState(() => _showAddModal = true);
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty || _qtyCtrl.text.trim().isEmpty) return;
    setState(() => _saving = true);
    final body = {
      'category': _catCtrl.text.trim(),
      'itemName': _nameCtrl.text.trim(),
      'vendorId': _vendorId,
      'qty': double.tryParse(_qtyCtrl.text.trim()) ?? 0,
      'unit': _unit.toUpperCase(),
      'costPerUnit': double.tryParse(_costCtrl.text.trim()) ?? 0,
      'totalValue':
          (double.tryParse(_qtyCtrl.text.trim()) ?? 0) *
          (double.tryParse(_costCtrl.text.trim()) ?? 0),
      'status': 'IN_STOCK',
      'lastUpdated': DateTime.now().toIso8601String().split('T')[0],
    };
    bool ok;
    if (_editing != null) {
      body['id'] = _editing!.id;
      ok = await InventoryService.updateItem(_editing!.id, body);
    } else {
      ok = await InventoryService.addItem(body);
    }
    if (mounted) {
      setState(() {
        _saving = false;
        _showAddModal = false;
      });
      invSnack(
        context,
        ok
            ? '✅ Item ${_editing != null ? "updated" : "added"} successfully!'
            : '❌ Failed to save item',
        error: !ok,
      );
      if (ok) _load();
    }
  }

  Future<void> _delete(InvItem item) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete Item',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Are you sure you want to delete "${item.itemName}"?',
          style: const TextStyle(color: invText2),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC3545),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final res = await InventoryService.deleteItem(item.id);
    if (mounted) {
      invSnack(
        context,
        res ? '✅ Item deleted!' : '❌ Delete failed',
        error: !res,
      );
      if (res) _load();
    }
  }

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      Column(
        children: [
          // Stats row
          SizedBox(
            height: 88,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
              children: [
                _statCard(
                  'Total Items',
                  '$_totalItems',
                  const Color(0xFF0078D4),
                ),
                _statCard('In Stock', '$_inStock', invGreen),
                _statCard('Low Stock', '$_lowStock', const Color(0xFFF59E0B)),
                _statCard(
                  'Out of Stock',
                  '$_outOfStock',
                  const Color(0xFFDC3545),
                ),
              ],
            ),
          ),
          // Filter bar
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search items...',
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
                _dropdownFilter(
                  ['All', 'Today', 'Yesterday', 'Week', 'Month'],
                  _dateFilter,
                  (v) {
                    _dateFilter = v;
                    _applyFilters();
                  },
                  w: 100,
                ),
                const SizedBox(width: 8),
                _dropdownFilter(
                  ['All Status', 'In Stock', 'Low Stock', 'Out of Stock'],
                  _statusFilter,
                  (v) {
                    _statusFilter = v;
                    _applyFilters();
                  },
                  w: 110,
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _openAdd,
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
                          'Add',
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
                      'No items found.',
                      style: TextStyle(color: invText2),
                    ),
                  )
                : RefreshIndicator(
                    color: invAccent,
                    onRefresh: _load,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 32),
                      itemCount: _filtered.length,
                      itemBuilder: (_, i) => _itemCard(_filtered[i], i + 1),
                    ),
                  ),
          ),
        ],
      ),
      if (_showAddModal) _buildAddModal(),
    ],
  );

  Widget _statCard(String label, String val, Color color) => Container(
    width: 100,
    margin: const EdgeInsets.only(right: 10),
    decoration: invCardDeco(radius: 12),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          val,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            color: invText2,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );

  Widget _dropdownFilter(
    List<String> opts,
    String val,
    void Function(String) onChanged, {
    double w = 120,
  }) => Container(
    height: 40,
    width: w,
    padding: const EdgeInsets.symmetric(horizontal: 8),
    decoration: BoxDecoration(
      color: invCard,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: invBorder),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: val,
        isExpanded: true,
        style: const TextStyle(fontSize: 11, color: invText1),
        items: opts
            .map(
              (o) => DropdownMenuItem(
                value: o,
                child: Text(o, overflow: TextOverflow.ellipsis),
              ),
            )
            .toList(),
        onChanged: (v) {
          if (v != null) onChanged(v);
          setState(() {});
        },
      ),
    ),
  );

  Widget _itemCard(InvItem item, int idx) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    decoration: invCardDeco(),
    padding: const EdgeInsets.all(14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: invAccentL,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '$idx',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: invAccent,
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
                    item.itemName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: invText1,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    item.category,
                    style: const TextStyle(fontSize: 11, color: invText2),
                  ),
                ],
              ),
            ),
            invStatusBadge(item.status),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            _infoChip(Icons.scale_outlined, '${item.qty} ${item.unit}'),
            _infoChip(Icons.currency_rupee_rounded, '${item.costPerUnit}/unit'),
            _infoChip(
              Icons.account_balance_wallet_outlined,
              'Total: ₹${item.totalValue.toStringAsFixed(0)}',
            ),
            _infoChip(
              Icons.calendar_today_outlined,
              _fmtDate(item.lastUpdated),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => _openEdit(item),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDBEAFE),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text(
                      'Edit',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1D4ED8),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: GestureDetector(
                onTap: () => _delete(item),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: invRedL,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text(
                      'Delete',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFDC3545),
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
  );

  Widget _infoChip(IconData icon, String label) => Container(
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
        Text(label, style: const TextStyle(fontSize: 11, color: invText2)),
      ],
    ),
  );

  String _fmtDate(String s) {
    if (s.isEmpty) return '—';
    try {
      return DateFormat('dd/MM/yy').format(DateTime.parse(s));
    } catch (_) {
      return s;
    }
  }

  // ── Add/Edit Modal ─────────────────────────────────────────────────────────
  Widget _buildAddModal() => Positioned.fill(
    child: GestureDetector(
      onTap: () => setState(() => _showAddModal = false),
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
                        Expanded(
                          child: Text(
                            _editing != null ? 'Edit Item' : 'Add New Item',
                            style: const TextStyle(
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
                          onPressed: () =>
                              setState(() => _showAddModal = false),
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: invBorder),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _modalField(
                            _catCtrl,
                            'Category',
                            'e.g. Grains & Rice',
                          ),
                          const SizedBox(height: 12),
                          _modalField(
                            _nameCtrl,
                            'Item Name *',
                            'e.g. Basmati Rice',
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    invSectionLabel('Unit'),
                                    Container(
                                      height: 44,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: invBg,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: invBorder),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          value: _unit,
                                          isExpanded: true,
                                          items:
                                              ['KG', 'LITER', 'PACKET', 'PIECE']
                                                  .map(
                                                    (u) => DropdownMenuItem(
                                                      value: u,
                                                      child: Text(
                                                        u,
                                                        style: const TextStyle(
                                                          fontSize: 13,
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                  .toList(),
                                          onChanged: (v) {
                                            if (v != null)
                                              setState(() => _unit = v);
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    invSectionLabel('Opening Qty *'),
                                    TextField(
                                      controller: _qtyCtrl,
                                      decoration: invInputDeco('e.g. 50'),
                                      keyboardType: TextInputType.number,
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              invSectionLabel('Cost / Unit (₹)'),
                              TextField(
                                controller: _costCtrl,
                                decoration: invInputDeco('e.g. 120'),
                                keyboardType: TextInputType.number,
                                style: const TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () =>
                                      setState(() => _showAddModal = false),
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
                                  onPressed: _saving ? null : _save,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: invAccent,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
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
                                      : Text(
                                          _editing != null
                                              ? 'Update Item'
                                              : 'Add Item',
                                          style: const TextStyle(
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

  Widget _modalField(TextEditingController ctrl, String label, String hint) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          invSectionLabel(label),
          TextField(
            controller: ctrl,
            decoration: invInputDeco(hint),
            style: const TextStyle(fontSize: 13),
          ),
        ],
      );
}
