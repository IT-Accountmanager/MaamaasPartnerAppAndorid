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
    return PackageModel(
      id: json['id'] as int?,
      vendorId: json['vendorId'] as int?,
      packageName: json['packageName']?.toString() ?? '',
      packageType: json['packageType']?.toString() ?? '',
      companyLogo: json['companyLogo']?.toString(),
      companyName: json['companyName']?.toString(),
      image: json['image']?.toString(),
      items: (json['items'] as List<dynamic>? ?? [])
          .map((item) => PackageItemModel.fromJson(item))
          .toList(),
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vendorId': vendorId,
      'packageName': packageName,
      'packageType': packageType,
      'companyLogo': companyLogo,
      'companyName': companyName,
      'image': image,
      'items': items.map((item) => item.toJson()).toList(),
      'totalPrice': totalPrice,
    };
  }
}

class PackageItemModel {
  final int? id;
  final String itemName;
  final double price;

  PackageItemModel({this.id, required this.itemName, required this.price});

  factory PackageItemModel.fromJson(Map<String, dynamic> json) {
    return PackageItemModel(
      id: json['id'] as int?,
      itemName: json['itemName']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'itemName': itemName, 'price': price};
  }
}
