import 'dart:convert';

class VendorQuotation {
  final int quotationId;
  final int leadId;
  final String vendorName;
  final String status;
  final String? paymentStatus;

  final int totalPlates;
  final double vegPerPlatePrice;
  final double nonVegPerPlatePrice;
  final double mixedPerPlatePrice;
  final double quotedAmount;

  final List<AddOnPrice> addOnPrices;

  VendorQuotation({
    required this.quotationId,
    required this.leadId,
    required this.vendorName,
    required this.status,
    this.paymentStatus,
    required this.totalPlates,
    required this.vegPerPlatePrice,
    required this.nonVegPerPlatePrice,
    required this.mixedPerPlatePrice,
    required this.quotedAmount,
    required this.addOnPrices,
  });

  /// 🔹 CopyWith
  VendorQuotation copyWith({
    int? quotationId,
    int? leadId,
    String? vendorName,
    String? status,
    String? paymentStatus,
    int? totalPlates,
    double? vegPerPlatePrice,
    double? nonVegPerPlatePrice,
    double? mixedPerPlatePrice,
    double? quotedAmount,
    List<AddOnPrice>? addOnPrices,
  }) {
    return VendorQuotation(
      quotationId: quotationId ?? this.quotationId,
      leadId: leadId ?? this.leadId,
      vendorName: vendorName ?? this.vendorName,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      totalPlates: totalPlates ?? this.totalPlates,
      vegPerPlatePrice: vegPerPlatePrice ?? this.vegPerPlatePrice,
      nonVegPerPlatePrice:
      nonVegPerPlatePrice ?? this.nonVegPerPlatePrice,
      mixedPerPlatePrice:
      mixedPerPlatePrice ?? this.mixedPerPlatePrice,
      quotedAmount: quotedAmount ?? this.quotedAmount,
      addOnPrices: addOnPrices ?? this.addOnPrices,
    );
  }

  /// 🔹 From JSON
  factory VendorQuotation.fromJson(Map<String, dynamic> json) {
    return VendorQuotation(
      quotationId: json['quotationId'] ?? 0,
      leadId: json['leadId'] ?? 0,
      vendorName: json['vendorName'] ?? '',
      status: json['status'] ?? '',
      paymentStatus: json['paymentStatus'], // ✅ IMPORTANT

      totalPlates: json['totalPlates'] ?? 0,
      vegPerPlatePrice:
      (json['vegPerPlatePrice'] ?? 0).toDouble(),
      nonVegPerPlatePrice:
      (json['nonVegPerPlatePrice'] ?? 0).toDouble(),
      mixedPerPlatePrice:
      (json['mixedPerPlatePrice'] ?? 0).toDouble(),
      quotedAmount:
      (json['quotedAmount'] ?? 0).toDouble(),

      addOnPrices: json['addOnPrices'] != null
          ? List<AddOnPrice>.from(
        json['addOnPrices']
            .map((x) => AddOnPrice.fromJson(x)),
      )
          : [],
    );
  }

  /// 🔹 To JSON
  Map<String, dynamic> toJson() {
    return {
      'quotationId': quotationId,
      'leadId': leadId,
      'vendorName': vendorName,
      'status': status,
      'paymentStatus': paymentStatus,
      'totalPlates': totalPlates,
      'vegPerPlatePrice': vegPerPlatePrice,
      'nonVegPerPlatePrice': nonVegPerPlatePrice,
      'mixedPerPlatePrice': mixedPerPlatePrice,
      'quotedAmount': quotedAmount,
      'addOnPrices':
      addOnPrices.map((e) => e.toJson()).toList(),
    };
  }

  /// 🔹 From Raw JSON String
  static VendorQuotation fromRawJson(String str) =>
      VendorQuotation.fromJson(json.decode(str));

  /// 🔹 To Raw JSON String
  String toRawJson() => json.encode(toJson());
}






/// =======================================
/// 🔹 AddOnPrice Model
/// =======================================

class AddOnPrice {
  final String addOnType;
  final int quantity;
  final double totalAmount;

  AddOnPrice({
    required this.addOnType,
    required this.quantity,
    required this.totalAmount,
  });

  factory AddOnPrice.fromJson(Map<String, dynamic> json) {
    return AddOnPrice(
      addOnType: json['addOnType'] ?? '',
      quantity: json['quantity'] ?? 0,
      totalAmount:
      (json['totalAmount'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'addOnType': addOnType,
      'quantity': quantity,
      'totalAmount': totalAmount,
    };
  }
}
