class PackageItemModel {
  final int? id;
  final String itemName;
  final double price;

  PackageItemModel({this.id, required this.itemName, required this.price});

  factory PackageItemModel.fromJson(Map<String, dynamic> json) {
    return PackageItemModel(
      id: json['id'] as int?,
      itemName: json['itemName']?.toString() ?? '',
      price: (json['price'] is int
          ? (json['price'] as int).toDouble()
          : json['price'] as double? ?? 0.0),
    );
  }

  Map<String, dynamic> toJson() {
    return {if (id != null) 'id': id, 'itemName': itemName, 'price': price};
  }
}
