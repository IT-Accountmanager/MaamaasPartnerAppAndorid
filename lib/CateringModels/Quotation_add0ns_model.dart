class QuotationResponse {
  final bool success;
  final String message;
  final List<QuotationData> data;
  final String timestamp;
  final String? errorCode;

  QuotationResponse({
    required this.success,
    required this.message,
    required this.data,
    required this.timestamp,
    this.errorCode,
  });

  factory QuotationResponse.fromJson(Map<String, dynamic> json) {
    return QuotationResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data:
          (json['data'] as List?)
              ?.map((e) => QuotationData.fromJson(e))
              .toList() ??
          [],
      timestamp: json['timestamp'] ?? '',
      errorCode: json['errorCode'],
    );
  }
}

class QuotationData {
  final int quotationId;
  final int vendorId;
  final int leadId;
  final int userId;
  final String customerId;
  final String vendorName;
  final double quotedAmount;
  final int totalPlates;
  final String eventDate;
  final EventTime eventTime;
  final String fromDate;
  final String toDate;
  final String city;
  final String fullAddress;
  final String companyName;
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
  final double cgstAmount;
  final double sgstAmount;
  final double platformFee;
  final double baseAmount;
  final double grandTotal;
  final List<AddOnPrice> addOnPrices;
  final String event;
  final String eventType;
  final double deliveryFee;
  final double distanceInKm;
  final String vendorCity;
  final String vendorState;
  final String vendorFullAddress;
  final double vendorLatitude;
  final double vendorLongitude;

  QuotationData({
    required this.quotationId,
    required this.vendorId,
    required this.leadId,
    required this.userId,
    required this.customerId,
    required this.vendorName,
    required this.quotedAmount,
    required this.totalPlates,
    required this.eventDate,
    required this.eventTime,
    required this.fromDate,
    required this.toDate,
    required this.city,
    required this.fullAddress,
    required this.companyName,
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
    required this.cgstAmount,
    required this.sgstAmount,
    required this.platformFee,
    required this.baseAmount,
    required this.grandTotal,
    required this.addOnPrices,
    required this.event,
    required this.eventType,
    required this.deliveryFee,
    required this.distanceInKm,
    required this.vendorCity,
    required this.vendorState,
    required this.vendorFullAddress,
    required this.vendorLatitude,
    required this.vendorLongitude,
  });

  factory QuotationData.fromJson(Map<String, dynamic> json) {
    return QuotationData(
      quotationId: json['quotationId'] ?? 0,
      vendorId: json['vendorId'] ?? 0,
      leadId: json['leadId'] ?? 0,
      userId: json['userId'] ?? 0,
      customerId: json['customerId'] ?? '',
      vendorName: json['vendorName'] ?? '',
      quotedAmount: (json['quotedAmount'] ?? 0).toDouble(),
      totalPlates: json['totalPlates'] ?? 0,
      eventDate: json['eventDate'] ?? '',
      eventTime: EventTime.fromJson(json['eventTime'] ?? {}),
      fromDate: json['fromDate'] ?? '',
      toDate: json['toDate'] ?? '',
      city: json['city'] ?? '',
      fullAddress: json['fullAddress'] ?? '',
      companyName: json['companyName'] ?? '',
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
      cgstAmount: (json['cgstAmount'] ?? 0).toDouble(),
      sgstAmount: (json['sgstAmount'] ?? 0).toDouble(),
      platformFee: (json['platformFee'] ?? 0).toDouble(),
      baseAmount: (json['baseAmount'] ?? 0).toDouble(),
      grandTotal: (json['grandTotal'] ?? 0).toDouble(),
      addOnPrices:
          (json['addOnPrices'] as List?)
              ?.map((e) => AddOnPrice.fromJson(e))
              .toList() ??
          [],
      event: json['event'] ?? '',
      eventType: json['eventType'] ?? '',
      deliveryFee: (json['deliveryFee'] ?? 0).toDouble(),
      distanceInKm: (json['distanceInKm'] ?? 0).toDouble(),
      vendorCity: json['vendorCity'] ?? '',
      vendorState: json['vendorState'] ?? '',
      vendorFullAddress: json['vendorFullAddress'] ?? '',
      vendorLatitude: (json['vendorLatitude'] ?? 0).toDouble(),
      vendorLongitude: (json['vendorLongitude'] ?? 0).toDouble(),
    );
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
    required this.second,
    required this.nano,
  });

  factory EventTime.fromJson(Map<String, dynamic> json) {
    return EventTime(
      hour: json['hour'] ?? 0,
      minute: json['minute'] ?? 0,
      second: json['second'] ?? 0,
      nano: json['nano'] ?? 0,
    );
  }

  String get formattedTime {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
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

  factory AddOnPrice.fromJson(Map<String, dynamic> json) {
    return AddOnPrice(
      addOnId: json['addOnId'] ?? 0,
      addOnType: json['addOnType'] ?? '',
      quantity: json['quantity'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'addOnId': addOnId,
      'addOnType': addOnType,
      'quantity': quantity,
      'price': price,
      'totalAmount': totalAmount,
    };
  }
}
