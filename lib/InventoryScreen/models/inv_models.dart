// ─── Inventory Item ───────────────────────────────────────────────────────────
// GET  http://staging.maamaas.com:8080/food/api/vendor/inventory/get/{vendorId}
// POST http://staging.maamaas.com:8080/food/api/vendor/inventory
// PUT  http://staging.maamaas.com:8080/food/api/vendor/inventory/update/{id}
// DEL  http://staging.maamaas.com:8080/food/api/vendor/inventory/delete/{id}
class InvItem {
  final int    id;
  final String category;
  final String itemName;
  final int    vendorId;
  final double qty;
  final String unit;       // KG | LITER | PACKET
  final double costPerUnit;
  final double totalValue;
  final String status;     // In Stock | Low Stock | Out of Stock  (mapped from IN_STOCK etc.)
  final String level;      // High | Medium | Low
  final String lastUpdated;

  const InvItem({
    this.id = 0, this.category = '', this.itemName = '', this.vendorId = 0,
    this.qty = 0, this.unit = 'KG', this.costPerUnit = 0, this.totalValue = 0,
    this.status = 'In Stock', this.level = 'Medium', this.lastUpdated = '',
  });

  factory InvItem.fromJson(Map<String, dynamic> j) {
    final rawStatus = j['status']?.toString() ?? 'IN_STOCK';
    final status = rawStatus == 'IN_STOCK'  ? 'In Stock'
                 : rawStatus == 'LOW_STOCK' ? 'Low Stock' : 'Out of Stock';
    final qty    = _d(j['qty']);
    final level  = qty > 20 ? 'High' : qty > 5 ? 'Medium' : 'Low';
    return InvItem(
      id:          _i(j['id']),
      category:    j['category']?.toString() ?? '',
      itemName:    j['itemName']?.toString() ?? '',
      vendorId:    _i(j['vendorId']),
      qty:         qty,
      unit:        j['unit']?.toString() ?? 'KG',
      costPerUnit: _d(j['costPerUnit']),
      totalValue:  _d(j['totalValue']),
      status:      status,
      level:       level,
      lastUpdated: j['lastUpdated']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson(int vendorId) => {
    'id':          id,
    'category':    category,
    'itemName':    itemName,
    'vendorId':    vendorId,
    'qty':         qty,
    'unit':        unit.toUpperCase(),
    'costPerUnit': costPerUnit,
    'totalValue':  qty * costPerUnit,
    'status':      'IN_STOCK',
    'lastUpdated': DateTime.now().toIso8601String().split('T')[0],
  };
}

// ─── Consumption Log ──────────────────────────────────────────────────────────
// GET  http://staging.maamaas.com:8080/food/api/vendor/inventory/consumption/{vendorId}
// POST http://staging.maamaas.com:8080/food/api/vendor/inventory/consumption
class ConsumptionLog {
  final int    id;
  final String date;
  final String category;
  final String item;
  final String requestedBy;
  final double qtyUsed;
  final String unit;
  final double before;
  final double after;
  final String remarks;
  final String status;

  const ConsumptionLog({
    this.id = 0, this.date = '', this.category = '', this.item = '',
    this.requestedBy = '', this.qtyUsed = 0, this.unit = '', this.before = 0,
    this.after = 0, this.remarks = '', this.status = 'Completed',
  });

  factory ConsumptionLog.fromJson(Map<String, dynamic> j) => ConsumptionLog(
    id:          _i(j['id']),
    date:        j['date']?.toString() ?? '',
    category:    j['category']?.toString() ?? '',
    item:        j['itemName']?.toString() ?? j['item']?.toString() ?? '',
    requestedBy: j['requestedBy']?.toString() ?? '',
    qtyUsed:     _d(j['qtyUsed']),
    unit:        j['unit']?.toString() ?? '',
    before:      _d(j['beforeQty'] ?? j['before']),
    after:       _d(j['afterQty']  ?? j['after']),
    remarks:     j['remarks']?.toString() ?? '',
    status:      j['status']?.toString() ?? 'Completed',
  );
}

// ─── Procurement Suggestion ───────────────────────────────────────────────────
// GET http://staging.maamaas.com:8080/food/api/vendor/procurement/{vendorId}
class ProcurementSuggestion {
  final int    id;
  final String category;
  final String item;
  final double current;
  final double threshold;
  final double suggestedQty;
  final String vendor;
  final String lastPurchase;
  final String status;
  final int    inventoryId;

  const ProcurementSuggestion({
    this.id = 0, this.category = '', this.item = '', this.current = 0,
    this.threshold = 0, this.suggestedQty = 0, this.vendor = '',
    this.lastPurchase = '', this.status = 'Pending', this.inventoryId = 0,
  });

  factory ProcurementSuggestion.fromJson(Map<String, dynamic> j, int idx) => ProcurementSuggestion(
    id:           idx + 1,
    category:     j['category']?.toString() ?? '',
    item:         j['item']?.toString() ?? '',
    current:      _d(j['current']),
    threshold:    _d(j['threshold']),
    suggestedQty: _d(j['suggestedQty']),
    vendor:       j['vendor']?.toString() ?? '',
    lastPurchase: j['lastPurchase']?.toString() ?? '',
    status:       j['status']?.toString() ?? 'Pending',
    inventoryId:  _i(j['inventoryId']),
  );
}

// ─── Purchase Order ───────────────────────────────────────────────────────────
// GET  http://staging.maamaas.com:8080/food/api/vendor/purchase-order/{vendorId}
// POST http://staging.maamaas.com:8080/food/api/vendor/purchase-order
// PUT  http://staging.maamaas.com:8080/food/api/vendor/purchase-order/accept/{poId}
class PurchaseOrder {
  final int    id;
  final String poNumber;
  final String vendor;
  final String items;
  final double qty;
  final String orderDate;
  final String expected;
  final String status;  // Ordered | Pending | Delivered
  final String category;

  const PurchaseOrder({
    this.id = 0, this.poNumber = '', this.vendor = 'Vendor',
    this.items = '', this.qty = 0, this.orderDate = '',
    this.expected = '', this.status = 'Pending', this.category = '',
  });

  factory PurchaseOrder.fromJson(Map<String, dynamic> j) {
    final rawStatus = j['status']?.toString() ?? 'PENDING';
    final status = rawStatus == 'ORDERED'   ? 'Ordered'
                 : rawStatus == 'PENDING'   ? 'Pending' : 'Delivered';
    return PurchaseOrder(
      id:        _i(j['id']),
      poNumber:  'PO-${_i(j['id'])}',
      vendor:    j['vendor']?.toString() ?? 'Vendor',
      items:     j['itemName']?.toString() ?? '',
      qty:       _d(j['orderedQty']),
      orderDate: j['orderDate']?.toString() ?? '',
      expected:  j['expectedDate']?.toString() ?? '',
      status:    status,
      category:  j['category']?.toString() ?? '',
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────
double _d(dynamic v) => (v is num) ? v.toDouble() : double.tryParse(v?.toString() ?? '') ?? 0.0;
int    _i(dynamic v) => (v is int) ? v : int.tryParse(v?.toString() ?? '') ?? 0;
