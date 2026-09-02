class AddOnPrice {
  final int addOnId;
  final double price;
  final String? addOnType;
  final int? quantity;

  AddOnPrice({
    required this.addOnId,
    required this.price,
    this.addOnType,
    this.quantity,
  });

  factory AddOnPrice.fromJson(Map<String, dynamic> json) {
    return AddOnPrice(
      addOnId: json['addOnId'] is int
          ? json['addOnId']
          : int.tryParse(json['addOnId']?.toString() ?? '') ?? 0,
      price: (json['price'] is num) ? (json['price'] as num).toDouble() : 0,
      addOnType: json['addOnType']?.toString(),
      quantity: json['quantity'] is int
          ? json['quantity']
          : int.tryParse(json['quantity']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() => {'addOnId': addOnId, 'price': price};
}

class QuotationModel {
  final int? id;
  final int? leadId;
  final String? status; // SUBMITTED, SELECTED, ACCEPTED, REJECTED
  final double vegPerPlatePrice;
  final double nonVegPerPlatePrice;
  final double mixedPerPlatePrice;
  final String quotationDetails;
  final List<AddOnPrice> addOnPrices;

  QuotationModel({
    this.id,
    this.leadId,
    this.status,
    this.vegPerPlatePrice = 0,
    this.nonVegPerPlatePrice = 0,
    this.mixedPerPlatePrice = 0,
    this.quotationDetails = '',
    this.addOnPrices = const [],
  });

  factory QuotationModel.fromJson(Map<String, dynamic> json) {
    return QuotationModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? ''),
      leadId: json['leadId'] is int
          ? json['leadId']
          : int.tryParse(json['leadId']?.toString() ?? ''),
      status: json['status']?.toString(),
      vegPerPlatePrice: (json['vegPerPlatePrice'] is num)
          ? (json['vegPerPlatePrice'] as num).toDouble()
          : 0,
      nonVegPerPlatePrice: (json['nonVegPerPlatePrice'] is num)
          ? (json['nonVegPerPlatePrice'] as num).toDouble()
          : 0,
      mixedPerPlatePrice: (json['mixedPerPlatePrice'] is num)
          ? (json['mixedPerPlatePrice'] as num).toDouble()
          : 0,
      quotationDetails: json['quotationDetails']?.toString() ?? '',
      addOnPrices: (json['addOnPrices'] as List<dynamic>? ?? [])
          .map((e) => AddOnPrice.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  Map<String, dynamic> toPayload() => {
        'vegPerPlatePrice': vegPerPlatePrice,
        'nonVegPerPlatePrice': nonVegPerPlatePrice,
        'mixedPerPlatePrice': mixedPerPlatePrice,
        'quotationDetails': quotationDetails,
        'addOnPrices':
            addOnPrices.where((a) => a.price > 0).map((a) => a.toJson()).toList(),
      };
}
