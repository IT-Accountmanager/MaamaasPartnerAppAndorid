import 'PackageItem.dart';

class PackageModel {
  final int? id;
  final int? vendorId;
  final String packageName;
  final String packageType;
  final String? companyLogo;
  final String? companyName;
  final String? image;
  final List<PackageItemModel> items;
  final double totalPrice;

  PackageModel({
    this.id,
    this.vendorId,
    required this.packageName,
    required this.packageType,
    this.companyLogo,
    this.companyName,
    this.image,
    required this.items,
    required this.totalPrice,
  });

  factory PackageModel.fromJson(Map<String, dynamic> json) {
    // Parse items list
    List<PackageItemModel> itemsList = [];
    if (json['items'] != null && json['items'] is List) {
      itemsList = (json['items'] as List<dynamic>)
          .map((item) => PackageItemModel.fromJson(item))
          .toList();
    }

    // Parse totalPrice
    double totalPrice = 0.0;
    if (json['totalPrice'] != null) {
      if (json['totalPrice'] is int) {
        totalPrice = (json['totalPrice'] as int).toDouble();
      } else if (json['totalPrice'] is double) {
        totalPrice = json['totalPrice'] as double;
      } else if (json['totalPrice'] is String) {
        totalPrice = double.tryParse(json['totalPrice']) ?? 0.0;
      }
    }

    return PackageModel(
      id: json['id'] as int?,
      vendorId: json['vendorId'] as int?,
      packageName: json['packageName']?.toString() ?? '',
      packageType: json['packageType']?.toString() ?? '',
      companyLogo: json['companyLogo'] as String?,
      companyName: json['companyName'] as String?,
      image: json['image'] as String?,
      items: itemsList,
      totalPrice: totalPrice,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (vendorId != null) 'vendorId': vendorId,
      'packageName': packageName,
      'packageType': packageType,
      if (companyLogo != null) 'companyLogo': companyLogo,
      if (companyName != null) 'companyName': companyName,
      if (image != null) 'image': image,
      'items': items.map((item) => item.toJson()).toList(),
      'totalPrice': totalPrice,
    };
  }
}
