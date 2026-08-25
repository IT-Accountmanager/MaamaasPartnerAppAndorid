import 'package:flutter/cupertino.dart';

class Dish {
  final int dishId;
  final double price;
  final String dishName;
  final String? tag;
  final String? stock;
  final String? code;
  final int parentId;
  final String? menuStatus;
  final String? chefType;
  final String? dishImage;
  final double? discount;
  final String? description;
  final int stockQuantity;
  final int consumedQuantity;
  final int balanceQuantity;
  final double effectivePrice;
  final double? gst;
  final double? packingCharges;
  final int vendorId;
  final String? approvalStatus;

  Dish({
    required this.dishId,
    required this.price,
    required this.dishName,
    this.tag,
    this.stock,
    this.code,
    required this.parentId,
    this.menuStatus,
    this.chefType,
    this.dishImage,
    this.discount,
    this.description,
    required this.stockQuantity,
    required this.consumedQuantity,
    required this.balanceQuantity,
    required this.effectivePrice,
    this.gst,
    this.packingCharges,
    required this.vendorId,
    this.approvalStatus,
  });

  factory Dish.fromJson(Map<String, dynamic> json) {
    try {
      num _toNum(dynamic value) {
        if (value == null) return 0;
        if (value is num) return value;
        return num.tryParse(value.toString()) ?? 0;
      }

      return Dish(
        dishId: _toNum(json['dishId']).toInt(),
        price: _toNum(json['price']).toDouble(),
        dishName: json['dishName']?.toString() ?? '',
        tag: json['tag']?.toString(),
        stock: json['stock']?.toString(),
        parentId: _toNum(json['parentId']).toInt(),
        menuStatus: json['menuStatus']?.toString(),
        chefType: json['chefType']?.toString(),
        dishImage: json['dishImage']?.toString(),
        discount: _toNum(json['discount']).toDouble(),
        description: json['description']?.toString(),
        stockQuantity: _toNum(json['stockQuantity']).toInt(),
        consumedQuantity: _toNum(json['consumedQuantity']).toInt(),
        balanceQuantity: _toNum(json['balanceQuantity']).toInt(),
        effectivePrice: _toNum(json['effectivePrice']).toDouble(),
        gst: _toNum(json['gst']).toDouble(),
        packingCharges: _toNum(json['packingCharges']).toDouble(),
        vendorId: _toNum(json['vendorId']).toInt(),
        code: json['code']?.toString(),
        approvalStatus: json['approvalStatus']?.toString(),
      );
    } catch (e, stack) {
      debugPrint("❌ Dish.fromJson failed → $e");
      debugPrint("⚙️ Offending JSON: $json");
      debugPrintStack(stackTrace: stack);
      rethrow;
    }
  }
}
