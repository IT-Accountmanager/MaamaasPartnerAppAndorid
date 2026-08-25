import 'dart:convert';

class QuotationRequest {
  final int vendorId;
  final int leadId;
  final double vegPerPlatePrice;
  final double nonVegPerPlatePrice;
  final double mixedPerPlatePrice;
  final String quotationDetails;
  final int totalPlates;
  final String eventDate;
  final EventTime eventTime;
  final String city;
  final String fullAddress;
  final String state;
  final String country;
  final int pincode;
  final int addressId;
  final List<AddOnPrice> addOnPrices;
  final String status;
  final double cgstAmount;
  final double sgstAmount;
  final double platformFee;
  final double baseAmount;
  final double grandTotal;
  final double deliveryFee;
  final double distanceInKm;

  QuotationRequest({
    required this.vendorId,
    required this.leadId,
    required this.vegPerPlatePrice,
    required this.nonVegPerPlatePrice,
    required this.mixedPerPlatePrice,
    required this.quotationDetails,
    required this.totalPlates,
    required this.eventDate,
    required this.eventTime,
    required this.city,
    required this.fullAddress,
    required this.state,
    required this.country,
    required this.pincode,
    required this.addressId,
    required this.addOnPrices,
    required this.status,
    required this.cgstAmount,
    required this.sgstAmount,
    required this.platformFee,
    required this.baseAmount,
    required this.grandTotal,
    required this.deliveryFee,
    required this.distanceInKm,
  });

  Map<String, dynamic> toJson() {
    return {
      'vendorId': vendorId,
      'leadId': leadId,
      'vegPerPlatePrice': vegPerPlatePrice,
      'nonVegPerPlatePrice': nonVegPerPlatePrice,
      'mixedPerPlatePrice': mixedPerPlatePrice,
      'quotationDetails': quotationDetails,
      'totalPlates': totalPlates,
      'eventDate': eventDate,
      'eventTime': eventTime.toJson(),
      'city': city,
      'fullAddress': fullAddress,
      'state': state,
      'country': country,
      'pincode': pincode,
      'addressId': addressId,
      'addOnPrices': addOnPrices.map((e) => e.toJson()).toList(),
      'status': status,
      'cgstAmount': cgstAmount,
      'sgstAmount': sgstAmount,
      'platformFee': platformFee,
      'baseAmount': baseAmount,
      'grandTotal': grandTotal,
      'deliveryFee': deliveryFee,
      'distanceInKm': distanceInKm,
    };
  }
}

class EventTime {
  final int hour;
  final int minute;
  final int second;
  final int nano;

  EventTime({
    required this.hour,
    required this.minute,
    this.second = 0,
    this.nano = 0,
  });

  Map<String, dynamic> toJson() {
    return {'hour': hour, 'minute': minute, 'second': second, 'nano': nano};
  }

  factory EventTime.fromJson(Map<String, dynamic> json) {
    return EventTime(
      hour: json['hour'] ?? 0,
      minute: json['minute'] ?? 0,
      second: json['second'] ?? 0,
      nano: json['nano'] ?? 0,
    );
  }
}

class AddOnPrice {
  final int addOnId;
  final String addOnType;
  final int quantity;
  final double price;
  final double totalAmount;

  AddOnPrice({
    required this.addOnId,
    required this.addOnType,
    required this.quantity,
    required this.price,
    required this.totalAmount,
  });

  Map<String, dynamic> toJson() {
    return {
      'addOnId': addOnId,
      'addOnType': addOnType,
      'quantity': quantity,
      'price': price,
      'totalAmount': totalAmount,
    };
  }

  factory AddOnPrice.fromJson(Map<String, dynamic> json) {
    return AddOnPrice(
      addOnId: json['addOnId'] ?? 0,
      addOnType: json['addOnType'] ?? '',
      quantity: json['quantity'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
    );
  }
}

class QuotationResponse {
  final bool success;
  final String message;
  final List<QuotationData>? data;
  final String timestamp;
  final String? errorCode;

  QuotationResponse({
    required this.success,
    required this.message,
    this.data,
    required this.timestamp,
    this.errorCode,
  });

  factory QuotationResponse.fromJson(Map<String, dynamic> json) {
    return QuotationResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? List<QuotationData>.from(
              json['data'].map((x) => QuotationData.fromJson(x)),
            )
          : null,
      timestamp: json['timestamp'] ?? '',
      errorCode: json['errorCode'],
    );
  }
}

class QuotationData {
  final int quotationId;
  final int vendorId;
  final int leadId;
  final int? userId;
  final int? customerId;
  final String? vendorName;
  final double quotedAmount;
  final int totalPlates;
  final String? eventDate;
  final String? eventTime;
  final String? fromDate;
  final String? toDate;
  final String? city;
  final String? fullAddress;
  final String? state;
  final String? country;
  final double? latitude;
  final double? longitude;
  final int? pincode;
  final int? addressId;
  final double vegPerPlatePrice;
  final double nonVegPerPlatePrice;
  final double mixedPerPlatePrice;
  final String quotationDetails;
  final String status;
  final String createdAt;
  final double cgstAmount;
  final double sgstAmount;
  final double platformFee;
  final double? baseAmount;
  final double grandTotal;
  final List<AddOnPrice>? addOnPrices;
  final String? event;
  final double deliveryFee;
  final double distanceInKm;
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
    required this.quotedAmount,
    required this.totalPlates,
    this.eventDate,
    this.eventTime,
    this.fromDate,
    this.toDate,
    this.city,
    this.fullAddress,
    this.state,
    this.country,
    this.latitude,
    this.longitude,
    this.pincode,
    this.addressId,
    required this.vegPerPlatePrice,
    required this.nonVegPerPlatePrice,
    required this.mixedPerPlatePrice,
    required this.quotationDetails,
    required this.status,
    required this.createdAt,
    required this.cgstAmount,
    required this.sgstAmount,
    required this.platformFee,
    this.baseAmount,
    required this.grandTotal,
    this.addOnPrices,
    this.event,
    required this.deliveryFee,
    required this.distanceInKm,
    this.vendorCity,
    this.vendorState,
    this.vendorFullAddress,
    this.vendorLatitude,
    this.vendorLongitude,
  });

  factory QuotationData.fromJson(Map<String, dynamic> json) {
    return QuotationData(
      quotationId: json['quotationId'] ?? 0,
      vendorId: json['vendorId'] ?? 0,
      leadId: json['leadId'] ?? 0,
      userId: json['userId'],
      customerId: json['customerId'],
      vendorName: json['vendorName'],
      quotedAmount: (json['quotedAmount'] ?? 0).toDouble(),
      totalPlates: json['totalPlates'] ?? 0,
      eventDate: json['eventDate'],
      eventTime: json['eventTime'],
      fromDate: json['fromDate'],
      toDate: json['toDate'],
      city: json['city'],
      fullAddress: json['fullAddress'],
      state: json['state'],
      country: json['country'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      pincode: json['pincode'],
      addressId: json['addressId'],
      vegPerPlatePrice: (json['vegPerPlatePrice'] ?? 0).toDouble(),
      nonVegPerPlatePrice: (json['nonVegPerPlatePrice'] ?? 0).toDouble(),
      mixedPerPlatePrice: (json['mixedPerPlatePrice'] ?? 0).toDouble(),
      quotationDetails: json['quotationDetails'] ?? '',
      status: json['status'] ?? '',
      createdAt: json['createdAt'] ?? '',
      cgstAmount: (json['cgstAmount'] ?? 0).toDouble(),
      sgstAmount: (json['sgstAmount'] ?? 0).toDouble(),
      platformFee: (json['platformFee'] ?? 0).toDouble(),
      baseAmount: json['baseAmount']?.toDouble(),
      grandTotal: (json['grandTotal'] ?? 0).toDouble(),
      addOnPrices: json['addOnPrices'] != null
          ? List<AddOnPrice>.from(
              json['addOnPrices'].map((x) => AddOnPrice.fromJson(x)),
            )
          : [],
      event: json['event'],
      deliveryFee: (json['deliveryFee'] ?? 0).toDouble(),
      distanceInKm: (json['distanceInKm'] ?? 0).toDouble(),
      vendorCity: json['vendorCity'],
      vendorState: json['vendorState'],
      vendorFullAddress: json['vendorFullAddress'],
      vendorLatitude: json['vendorLatitude']?.toDouble(),
      vendorLongitude: json['vendorLongitude']?.toDouble(),
    );
  }
}

// Add-on item for UI (separate from API model)
class AddOnItem {
  final int addOnId;
  final String addOnType;
  final double price;
  final double totalAmount;

  AddOnItem({
    required this.addOnId,
    required this.addOnType,
    required this.price,
    required this.totalAmount,
  });

  factory AddOnItem.fromJson(Map<String, dynamic> json) {
    return AddOnItem(
      addOnId: json['addOnId'] ?? 0,
      addOnType: json['addOnType'] ?? 'VEG',
      price: (json['price'] ?? 0).toDouble(),
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
    );
  }
}
