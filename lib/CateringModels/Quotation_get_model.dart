import 'Quotation_model.dart';

class QuotationData {
  final int quotationId;
  final int vendorId;
  final int leadId;
  final int? userId;
  final String? customerId;
  final String? vendorName;
  final double? quotedAmount;
  final int? totalPlates;
  final String? eventDate;
  final String? eventTime;
  final String? fromDate;
  final String? toDate;
  final String city;
  final String fullAddress;
  final String? companyName;
  final String state;
  final String country;
  final double latitude;
  final double longitude;
  final int pincode;
  final int addressId;
  final double vegPerPlatePrice;
  final double nonVegPerPlatePrice;
  final double mixedPerPlatePrice;
  final String quotationDetails;
  final String status;
  final String createdAt;
  final double? cgstAmount;
  final double? sgstAmount;
  final double? platformFee;
  final double? baseAmount;
  final double? grandTotal;
  final List<AddOnItem>? addOnPrices;
  final String? event;
  final String? eventType;
  final double? deliveryFee;
  final double? distanceInKm;
  final String? vendorCity;
  final String? vendorState;
  final String? vendorFullAddress;
  final double? vendorLatitude;
  final double? vendorLongitude;

  QuotationData({
    required this.quotationId,
    required this.vendorId,
    required this.leadId,
    this.userId,
    this.customerId,
    this.vendorName,
    this.quotedAmount,
    this.totalPlates,
    this.eventDate,
    this.eventTime,
    this.fromDate,
    this.toDate,
    required this.city,
    required this.fullAddress,
    this.companyName,
    required this.state,
    required this.country,
    required this.latitude,
    required this.longitude,
    required this.pincode,
    required this.addressId,
    required this.vegPerPlatePrice,
    required this.nonVegPerPlatePrice,
    required this.mixedPerPlatePrice,
    required this.quotationDetails,
    required this.status,
    required this.createdAt,
    this.cgstAmount,
    this.sgstAmount,
    this.platformFee,
    this.baseAmount,
    this.grandTotal,
    this.addOnPrices,
    this.event,
    this.eventType,
    this.deliveryFee,
    this.distanceInKm,
    this.vendorCity,
    this.vendorState,
    this.vendorFullAddress,
    this.vendorLatitude,
    this.vendorLongitude,
  });

  factory QuotationData.fromJson(Map<String, dynamic> json) {
    // Parse addOnPrices if present
    List<AddOnItem>? addOnItems;
    if (json['addOnPrices'] != null && json['addOnPrices'] is List) {
      addOnItems = (json['addOnPrices'] as List)
          .map((item) => AddOnItem.fromJson(item))
          .toList();
    }

    return QuotationData(
      quotationId: json['quotationId'] ?? 0,
      vendorId: json['vendorId'] ?? 0,
      leadId: json['leadId'] ?? 0,
      userId: json['userId'],
      customerId: json['customerId'],
      vendorName: json['vendorName'],
      quotedAmount: json['quotedAmount'] != null
          ? (json['quotedAmount'] is int
                ? (json['quotedAmount'] as int).toDouble()
                : json['quotedAmount'] as double)
          : null,
      totalPlates: json['totalPlates'],
      eventDate: json['eventDate'],
      eventTime: json['eventTime'],
      fromDate: json['fromDate'],
      toDate: json['toDate'],
      city: json['city'] ?? '',
      fullAddress: json['fullAddress'] ?? '',
      companyName: json['companyName'],
      state: json['state'] ?? '',
      country: json['country'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      pincode: json['pincode'] ?? 0,
      addressId: json['addressId'] ?? 0,
      vegPerPlatePrice: (json['vegPerPlatePrice'] ?? 0).toDouble(),
      nonVegPerPlatePrice: (json['nonVegPerPlatePrice'] ?? 0).toDouble(),
      mixedPerPlatePrice: (json['mixedPerPlatePrice'] ?? 0).toDouble(),
      quotationDetails: json['quotationDetails'] ?? '',
      status: json['status'] ?? '',
      createdAt: json['createdAt'] ?? '',
      cgstAmount: json['cgstAmount'] != null
          ? (json['cgstAmount'] is int
                ? (json['cgstAmount'] as int).toDouble()
                : json['cgstAmount'] as double)
          : null,
      sgstAmount: json['sgstAmount'] != null
          ? (json['sgstAmount'] is int
                ? (json['sgstAmount'] as int).toDouble()
                : json['sgstAmount'] as double)
          : null,
      platformFee: json['platformFee'] != null
          ? (json['platformFee'] is int
                ? (json['platformFee'] as int).toDouble()
                : json['platformFee'] as double)
          : null,
      baseAmount: json['baseAmount'] != null
          ? (json['baseAmount'] is int
                ? (json['baseAmount'] as int).toDouble()
                : json['baseAmount'] as double)
          : null,
      grandTotal: json['grandTotal'] != null
          ? (json['grandTotal'] is int
                ? (json['grandTotal'] as int).toDouble()
                : json['grandTotal'] as double)
          : null,
      addOnPrices: addOnItems,
      event: json['event'],
      eventType: json['eventType'],
      deliveryFee: json['deliveryFee'] != null
          ? (json['deliveryFee'] is int
                ? (json['deliveryFee'] as int).toDouble()
                : json['deliveryFee'] as double)
          : null,
      distanceInKm: json['distanceInKm'] != null
          ? (json['distanceInKm'] is int
                ? (json['distanceInKm'] as int).toDouble()
                : json['distanceInKm'] as double)
          : null,
      vendorCity: json['vendorCity'],
      vendorState: json['vendorState'],
      vendorFullAddress: json['vendorFullAddress'],
      vendorLatitude: json['vendorLatitude'] != null
          ? (json['vendorLatitude'] is int
                ? (json['vendorLatitude'] as int).toDouble()
                : json['vendorLatitude'] as double)
          : null,
      vendorLongitude: json['vendorLongitude'] != null
          ? (json['vendorLongitude'] is int
                ? (json['vendorLongitude'] as int).toDouble()
                : json['vendorLongitude'] as double)
          : null,
    );
  }
}
