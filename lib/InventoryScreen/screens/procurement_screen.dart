
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/inv_models.dart';
import '../services/inventory_service.dart';
import '../widgets/theme.dart';

class ProcurementScreen extends StatefulWidget {
  const ProcurementScreen({super.key});
  @override
  State<ProcurementScreen> createState() => _ProcurementScreenState();
}

class _ProcurementScreenState extends State<ProcurementScreen> {
  List<ProcurementSuggestion> _suggestions = [], _filtSuggestions = [];
  List<PurchaseOrder> _orders = [], _filtOrders = [];
  bool _loading = false;
  String _search = '';
  String _statusFilter = 'All Status';

  // Create PO Modal
  bool _showCreateModal = false;
  bool _savingPO = false;
  String _poCategory = '',
      _poItem = '',
      _poVendor = '',
      _poQty = '',
      _poExpected = '';
  int? _poInventoryId;

  // Accept Delivery Modal
  bool _showAcceptModal = false;
  PurchaseOrder? _acceptTarget;
  bool _accepting = false;
  String _recvQty = '', _quality = 'Pass', _acceptRemarks = '';

  static const _vendors = [
    'Fresh Farms Co.',
    'Dairy Fresh',
    'Spice World Ltd.',
    'Poultry Hub',
    'Organic Valley',
    'Grain Suppliers Inc.',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final results = await Future.wait([
      InventoryService.fetchProcurementSuggestions(),
      InventoryService.fetchPurchaseOrders(),
    ]);
    if (mounted)
      setState(() {
        _suggestions = results[0] as List<ProcurementSuggestion>;
        _orders = results[1] as List<PurchaseOrder>;
        _loading = false;
        _applyFilters();
      });
  }

  void _applyFilters() {
    final q = _search.toLowerCase();
    _filtSuggestions = _suggestions
        .where(
          (s) =>
              q.isEmpty ||
              s.item.toLowerCase().contains(q) ||
              s.category.toLowerCase().contains(q) ||
              s.vendor.toLowerCase().contains(q),
        )
        .toList();
    _filtOrders = _orders.where((o) {
      final matchSearch =
          q.isEmpty ||
          o.poNumber.toLowerCase().contains(q) ||
          o.items.toLowerCase().contains(q);
      final matchStatus =
          _statusFilter == 'All Status' || o.status == _statusFilter;
      return matchSearch && matchStatus;
    }).toList();
    setState(() {});
  }

  void _openCreateFromSuggestion(ProcurementSuggestion s) {
    setState(() {
      _poCategory = s.category;
      _poItem = s.item;
      _poVendor = s.vendor;
      _poQty = s.suggestedQty.toString();
      _poExpected = '';
      _poInventoryId = s.inventoryId;
      _showCreateModal = true;
    });
  }

  Future<void> _createPO() async {
    if (_poVendor.isEmpty ||
        _poItem.isEmpty ||
        _poQty.isEmpty ||
        _poExpected.isEmpty)
      return;
    setState(() => _savingPO = true);
    final body = {
      'inventoryId': _poInventoryId,
      'orderedQty': double.tryParse(_poQty) ?? 0,
      'orderDate': DateFormat('yyyy-MM-dd').format(DateTime.now()),
      'expectedDate': _poExpected,
      'status': 'ORDERED',
      'itemName': _poItem,
      'category': _poCategory,
    };
    final ok = await InventoryService.createPurchaseOrder(body);
    if (mounted) {
      setState(() {
        _savingPO = false;
        _showCreateModal = false;
      });
      invSnack(
        context,
        ok ? '✅ Purchase Order created!' : '❌ Failed to create PO',
        error: !ok,
      );
      if (ok) {
        _poCategory = '';
        _poItem = '';
        _poVendor = '';
        _poQty = '';
        _poExpected = '';
        _poInventoryId = null;
        _load();
      }
    }
  }

  void _openAccept(PurchaseOrder po) => setState(() {
    _acceptTarget = po;
    _recvQty = po.qty.toString();
    _quality = 'Pass';
    _acceptRemarks = '';
    _showAcceptModal = true;
  });

  Future<void> _confirmAccept() async {
    final po = _acceptTarget;
    if (po == null) return;

    final double? receivedQty = double.tryParse(_recvQty);
    if (receivedQty == null) {
      invSnack(context, 'Please enter a valid quantity', error: true);
      return;
    }

    setState(() => _accepting = true);
    final ok = await InventoryService.acceptPurchaseOrder(
      po.id,
      receivedQty: receivedQty,
      quality: _quality,
      remarks: _acceptRemarks,
    );
    if (mounted) {
      setState(() {
        _accepting = false;
        _showAcceptModal = false;
      });
      invSnack(
        context,
        ok ? '✅ Delivery accepted!' : '❌ Accept failed',
        error: !ok,
      );
      if (ok) _load();
    }
  }

  List<String> get _categoriesForPO =>
      _suggestions.map((s) => s.category).toSet().toList();
  List<ProcurementSuggestion> get _itemsForCategory =>
      _suggestions.where((s) => s.category == _poCategory).toList();

  String _fmtDate(String s) {
    if (s.isEmpty) return '—';
    try {
      return DateFormat('dd/MM/yy').format(DateTime.parse(s));
    } catch (_) {
      return s;
    }
  }

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      _loading
          ? const Center(
              child: CircularProgressIndicator(
                color: invAccent,
                strokeWidth: 2,
              ),
            )
          : RefreshIndicator(
              color: invAccent,
              onRefresh: _load,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search + filter bar
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 40,
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Search...',
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
                                  borderSide: const BorderSide(
                                    color: invBorder,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: invBorder,
                                  ),
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
                          ['All Status', 'Ordered', 'Pending', 'Delivered'],
                          _statusFilter,
                          (v) {
                            _statusFilter = v;
                            _applyFilters();
                          },
                          w: 110,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ── SUGGESTIONS ──────────────────────────────────────────────
                    const Text(
                      'Auto Reorder Suggestions',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: invText1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _filtSuggestions.isEmpty
                        ? _emptyState('No procurement suggestions')
                        : Column(
                            children: _filtSuggestions
                                .map(_suggestionCard)
                                .toList(),
                          ),

                    const SizedBox(height: 16),
                    const Divider(color: invBorder),
                    const SizedBox(height: 8),

                    // ── PURCHASE ORDERS ──────────────────────────────────────────
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Purchase Orders',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: invText1,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => setState(() {
                            _poCategory = '';
                            _poItem = '';
                            _poVendor = '';
                            _poQty = '';
                            _poExpected = '';
                            _showCreateModal = true;
                          }),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: invAccent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.add_rounded,
                                  size: 14,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'New PO',
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
                    const SizedBox(height: 8),
                    _filtOrders.isEmpty
                        ? _emptyState('No purchase orders')
                        : Column(children: _filtOrders.map(_poCard).toList()),
                  ],
                ),
              ),
            ),
      if (_showCreateModal) _buildCreatePOModal(),
      if (_showAcceptModal) _buildAcceptModal(),
    ],
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

  Widget _suggestionCard(ProcurementSuggestion s) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    decoration: invCardDeco(),
    padding: const EdgeInsets.all(14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: invAmberL,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                size: 18,
                color: Color(0xFF856404),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.item,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: invText1,
                    ),
                  ),
                  Text(
                    '${s.category} • ${s.vendor}',
                    style: const TextStyle(fontSize: 11, color: invText2),
                  ),
                ],
              ),
            ),
            invStatusBadge(s.status),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            _chip('Current: ${s.current}', invBg, invText2),
            _chip('Threshold: ${s.threshold}', invAmberL, invAmber),
            _chip('Suggested: ${s.suggestedQty}', invGreenL, invGreen),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: GestureDetector(
            onTap: () => _openCreateFromSuggestion(s),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: invAccentL,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text(
                  'Create Purchase Order',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: invAccent,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _poCard(PurchaseOrder po) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    decoration: invCardDeco(),
    padding: const EdgeInsets.all(14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: invAccentL,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                po.poNumber,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: invAccent,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    po.items,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: invText1,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${po.vendor} • Qty: ${po.qty}',
                    style: const TextStyle(fontSize: 11, color: invText2),
                  ),
                ],
              ),
            ),
            invStatusBadge(po.status),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            _chip('Ordered: ${_fmtDate(po.orderDate)}', invBg, invText2),
            _chip('Expected: ${_fmtDate(po.expected)}', invBlueL, invBlue),
          ],
        ),
        if (po.status != 'Delivered') ...[
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: () => _openAccept(po),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: invGreenL,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    'Accept Delivery',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: invGreen,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    ),
  );

  Widget _chip(String label, Color bg, Color fg) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: invBorder),
    ),
    child: Text(
      label,
      style: TextStyle(fontSize: 11, color: fg, fontWeight: FontWeight.w600),
    ),
  );

  Widget _emptyState(String msg) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(24),
    decoration: invCardDeco(radius: 12),
    child: Text(
      msg,
      style: const TextStyle(color: invText2, fontSize: 13),
      textAlign: TextAlign.center,
    ),
  );

  // ── Create PO Modal ─────────────────────────────────────────────────────────
  Widget _buildCreatePOModal() => Positioned.fill(
    child: GestureDetector(
      onTap: () => setState(() => _showCreateModal = false),
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
                            'Create Purchase Order',
                            style: TextStyle(
                              fontSize: 15,
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
                              setState(() => _showCreateModal = false),
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
                          // Category
                          invSectionLabel('Category'),
                          _dropdown(
                            _categoriesForPO,
                            _poCategory,
                            (v) => setState(() {
                              _poCategory = v;
                              _poItem = '';
                              _poInventoryId = null;
                            }),
                            hint: 'Select Category',
                          ),
                          const SizedBox(height: 12),
                          // Item
                          invSectionLabel('Item'),
                          _dropdown(
                            _itemsForCategory.map((i) => i.item).toList(),
                            _poItem,
                            (v) {
                              final found = _itemsForCategory.firstWhere(
                                (i) => i.item == v,
                                orElse: () => const ProcurementSuggestion(),
                              );
                              setState(() {
                                _poItem = v;
                                _poQty = found.suggestedQty.toString();
                                _poInventoryId = found.inventoryId;
                              });
                            },
                            hint: 'Select Item',
                            disabled: _poCategory.isEmpty,
                          ),
                          const SizedBox(height: 12),
                          // Vendor
                          invSectionLabel('Vendor'),
                          _dropdown(
                            _vendors,
                            _poVendor,
                            (v) => setState(() => _poVendor = v),
                            hint: 'Select Vendor',
                          ),
                          const SizedBox(height: 12),
                          // Quantity
                          invSectionLabel('Total Quantity'),
                          TextFormField(
                            initialValue: _poQty,
                            decoration: invInputDeco('Enter quantity'),
                            keyboardType: TextInputType.number,
                            style: const TextStyle(fontSize: 13),
                            onChanged: (v) => _poQty = v,
                          ),
                          const SizedBox(height: 12),
                          // Expected Delivery
                          invSectionLabel('Expected Delivery'),
                          GestureDetector(
                            onTap: () async {
                              final d = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now().add(
                                  const Duration(days: 1),
                                ),
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2030),
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
                                  () => _poExpected = DateFormat(
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
                                    _poExpected.isEmpty
                                        ? 'Select date'
                                        : _poExpected,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: _poExpected.isEmpty
                                          ? invText3
                                          : invText1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () =>
                                      setState(() => _showCreateModal = false),
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
                                  child: const Text('Cancel'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed:
                                      (_savingPO ||
                                          _poVendor.isEmpty ||
                                          _poItem.isEmpty ||
                                          _poQty.isEmpty ||
                                          _poExpected.isEmpty)
                                      ? null
                                      : _createPO,
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
                                  child: _savingPO
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Text(
                                          'Create PO',
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

  // ── Accept Delivery Modal ───────────────────────────────────────────────────
  Widget _buildAcceptModal() {
    final po = _acceptTarget!;
    return Positioned.fill(
      child: GestureDetector(
        onTap: () => setState(() => _showAcceptModal = false),
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
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Accept Delivery — ${po.poNumber}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: invText1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${po.vendor} • ${po.items}',
                        style: const TextStyle(fontSize: 12, color: invText2),
                      ),
                      const Divider(color: invBorder, height: 20),
                      // Received Qty
                      invSectionLabel('Received Quantity'),
                      TextFormField(
                        initialValue: _recvQty,
                        decoration: invInputDeco('Enter quantity'),
                        keyboardType: TextInputType.number,
                        style: const TextStyle(fontSize: 13),
                        onChanged: (v) => _recvQty = v,
                      ),
                      const SizedBox(height: 12),
                      // Quality
                      invSectionLabel('Quality Check'),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: invBg,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: invBorder),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _quality,
                            isExpanded: true,
                            items: ['Pass', 'Fail']
                                .map(
                                  (q) => DropdownMenuItem(
                                    value: q,
                                    child: Row(
                                      children: [
                                        Icon(
                                          q == 'Pass'
                                              ? Icons.check_circle_rounded
                                              : Icons.cancel_rounded,
                                          size: 14,
                                          color: q == 'Pass'
                                              ? invGreen
                                              : const Color(0xFFDC3545),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          q,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: q == 'Pass'
                                                ? invGreen
                                                : const Color(0xFFDC3545),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) => setState(() => _quality = v!),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Remarks
                      invSectionLabel('Remarks'),
                      TextFormField(
                        decoration: invInputDeco('Any notes...'),
                        maxLines: 2,
                        style: const TextStyle(fontSize: 13),
                        onChanged: (v) => _acceptRemarks = v,
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () =>
                                  setState(() => _showAcceptModal = false),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFFDC3545),
                                side: const BorderSide(
                                  color: Color(0xFFDC3545),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                              child: const Text(
                                'Reject',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _accepting ? null : _confirmAccept,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: invGreen,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                              child: _accepting
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'Accept',
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
            ),
          ),
        ),
      ),
    );
  }

  Widget _dropdown(
    List<String> opts,
    String val,
    void Function(String) onChanged, {
    String hint = 'Select',
    bool disabled = false,
  }) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
      color: disabled ? const Color(0xFFF3F4F6) : invBg,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: invBorder),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: val.isEmpty ? null : val,
        hint: Text(hint, style: const TextStyle(color: invText3, fontSize: 13)),
        isExpanded: true,
        disabledHint: Text(
          'Select category first',
          style: const TextStyle(color: invText3, fontSize: 13),
        ),
        onChanged: disabled
            ? null
            : (v) {
                if (v != null) onChanged(v);
              },
        items: opts
            .map(
              (o) => DropdownMenuItem(
                value: o,
                child: Text(o, style: const TextStyle(fontSize: 13)),
              ),
            )
            .toList(),
      ),
    ),
  );
}
