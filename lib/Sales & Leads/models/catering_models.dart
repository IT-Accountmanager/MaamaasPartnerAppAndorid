// ─── Lead / Order ─────────────────────────────────────────────────────────────

class CateringLead {
  final int orderId;
  final String name;
  final String mobile;
  final String email;
  final String eventDate;
  final String? eventTime;
  final String? fromDate;
  final String? toDate;
  final int vegPlates;
  final int nonVegPlates;
  final int mixedPlates;
  final String eventType;
  final String city;
  final String state;
  final double leadPrice;
  final bool masked;
  final bool accessible;
  final String? accessMessage;
  final List<String> items;
  final List<AddOn> addOns;
  String? quotationStatus;

  CateringLead({
    required this.orderId,
    this.name = '',
    this.mobile = '',
    this.email = '',
    this.eventDate = '',
    this.eventTime,
    this.fromDate,
    this.toDate,
    this.vegPlates = 0,
    this.nonVegPlates = 0,
    this.mixedPlates = 0,
    this.eventType = '',
    this.city = '',
    this.state = '',
    this.leadPrice = 0,
    this.masked = false,
    this.accessible = true,
    this.accessMessage,
    this.items = const [],
    this.addOns = const [],
    this.quotationStatus,
  });

  factory CateringLead.fromJson(Map<String, dynamic> j) => CateringLead(
    orderId: _i(j['id'] ?? j['orderId']),
    name: j['fullName']?.toString() ?? j['name']?.toString() ?? '',
    mobile: j['phoneNumber']?.toString() ?? j['mobile']?.toString() ?? '',
    email: j['email']?.toString() ?? '',
    eventDate: j['eventDate']?.toString() ?? '',
    eventTime: j['eventTime']?.toString(),
    fromDate: j['fromDate']?.toString(),
    toDate: j['toDate']?.toString(),
    vegPlates: _i(j['vegPlates'] ?? j['veg'] ?? 0),
    nonVegPlates: _i(j['nonVegPlates'] ?? j['nonVeg'] ?? 0),
    mixedPlates: _i(j['mixedPlates'] ?? j['mixed'] ?? 0),
    eventType: j['eventType']?.toString() ?? '',
    city: j['city']?.toString() ?? '',
    state: j['state']?.toString() ?? 'N/A',
    leadPrice: _d(j['leadPrice'] ?? j['amount'] ?? 0),
    masked: j['masked'] as bool? ?? false,
    accessible: j['accessible'] as bool? ?? true,
    accessMessage: j['accessMessage']?.toString(),
    items: _parseItems(j['items']),
    addOns: _parseAddOns(j['addOns']),
  );
  static List<String> _parseItems(dynamic itemsData) {
    if (itemsData == null) return [];

    if (itemsData is List) {
      return itemsData.map((e) => e.toString()).toList();
    } else if (itemsData is Map) {
      // If items is a map, try to extract values
      return itemsData.values.map((e) => e.toString()).toList();
    } else if (itemsData is String) {
      // If items is a comma-separated string
      return itemsData
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    return [];
  }

  static List<AddOn> _parseAddOns(dynamic addOnsData) {
    if (addOnsData == null) return [];

    if (addOnsData is List) {
      return addOnsData
          .whereType<Map<String, dynamic>>()
          .map(AddOn.fromJson)
          .toList();
    } else if (addOnsData is Map) {
      // If addOns is a map with numeric keys
      return addOnsData.values
          .whereType<Map<String, dynamic>>()
          .map(AddOn.fromJson)
          .toList();
    }

    return [];
  }

  // Computed
  int get totalPlates => vegPlates + nonVegPlates + mixedPlates;
  String get clientLocation => '$city, $state';
  bool get needsPayment => accessMessage == 'Payment required for full details';
  bool get hasFullAccess => accessMessage == 'Full access - Payment verified';
  bool get isDailyType =>
      ['DAILY', 'WEEKLY', 'MONTHLY'].contains(eventType.toUpperCase());
}

// ─── AddOn ────────────────────────────────────────────────────────────────────
class AddOn {
  final int id;
  final String addOnType;
  final int quantity;

  AddOn({required this.id, required this.addOnType, required this.quantity});

  factory AddOn.fromJson(Map<String, dynamic> j) => AddOn(
    id: _i(j['id'] ?? j['addOnId']),
    addOnType: j['addOnType']?.toString() ?? j['type']?.toString() ?? '',
    quantity: _i(j['quantity'] ?? j['qty'] ?? 1),
  );

  String get displayName {
    const map = {
      'PAPER_PLATES': 'Paper Plates',
      'SERVICE_BOYS': 'Service Staff',
      'DISPOSABLE_CUPS': 'Disposable Cups',
      'WATER_BOTTLES': 'Water Bottles',
      'TISSUE_PAPER': 'Tissue Paper',
    };
    return map[addOnType] ??
        addOnType
            .replaceAll('_', ' ')
            .toLowerCase()
            .split(' ')
            .map((w) => w.isEmpty ? '' : w[0].toUpperCase() + w.substring(1))
            .join(' ');
  }
}

// ─── Quotation ────────────────────────────────────────────────────────────────
class Quotation {
  final int? leadId;
  final double vegPerPlatePrice;
  final double nonVegPerPlatePrice;
  final double mixedPerPlatePrice;
  final String quotationDetails;
  final List<AddOnPrice> addOnPrices;
  final String? status;

  Quotation({
    this.leadId,
    this.vegPerPlatePrice = 0,
    this.nonVegPerPlatePrice = 0,
    this.mixedPerPlatePrice = 0,
    this.quotationDetails = '',
    this.addOnPrices = const [],
    this.status,
  });
  factory Quotation.fromJson(Map<String, dynamic> j) => Quotation(
    leadId: _i(j['leadId']),
    vegPerPlatePrice: _d(j['vegPerPlatePrice']),
    nonVegPerPlatePrice: _d(j['nonVegPerPlatePrice']),
    mixedPerPlatePrice: _d(j['mixedPerPlatePrice']),
    quotationDetails: j['quotationDetails']?.toString() ?? '',
    addOnPrices: _parseAddOnPrices(j['addOnPrices']),
    status: j['status']?.toString(),
  );

  static List<AddOnPrice> _parseAddOnPrices(dynamic pricesData) {
    if (pricesData == null) return [];

    if (pricesData is List) {
      return pricesData
          .whereType<Map<String, dynamic>>()
          .map(AddOnPrice.fromJson)
          .toList();
    } else if (pricesData is Map) {
      return pricesData.values
          .whereType<Map<String, dynamic>>()
          .map(AddOnPrice.fromJson)
          .toList();
    }

    return [];
  }

  Map<String, dynamic> toJson() => {
    'vegPerPlatePrice': vegPerPlatePrice,
    'nonVegPerPlatePrice': nonVegPerPlatePrice,
    'mixedPerPlatePrice': mixedPerPlatePrice,
    'quotationDetails': quotationDetails,
    'addOnPrices': addOnPrices
        .where((a) => a.price > 0)
        .map((a) => a.toJson())
        .toList(),
  };
}

class AddOnPrice {
  final int addOnId;
  final double price;

  AddOnPrice({required this.addOnId, required this.price});

  factory AddOnPrice.fromJson(Map<String, dynamic> j) =>
      AddOnPrice(addOnId: _i(j['addOnId']), price: _d(j['price']));

  Map<String, dynamic> toJson() => {'addOnId': addOnId, 'price': price};
}

// ─── Helpers ──────────────────────────────────────────────────────────────────
double _d(dynamic v) =>
    (v is num) ? v.toDouble() : double.tryParse(v?.toString() ?? '') ?? 0.0;
int _i(dynamic v) => (v is int) ? v : int.tryParse(v?.toString() ?? '') ?? 0;
