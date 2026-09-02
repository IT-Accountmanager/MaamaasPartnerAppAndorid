class AddOnModel {
  final int? id;
  final String addOnType;
  final int quantity;
  final double? price;

  AddOnModel({
    this.id,
    required this.addOnType,
    required this.quantity,
    this.price,
  });

  factory AddOnModel.fromJson(Map<String, dynamic> json) {
    return AddOnModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? ''),
      addOnType: json['addOnType']?.toString() ?? 'OTHER',
      quantity: json['quantity'] is int
          ? json['quantity']
          : int.tryParse(json['quantity']?.toString() ?? '') ?? 0,
      price: (json['price'] is num) ? (json['price'] as num).toDouble() : null,
    );
  }

  /// e.g. "EXTRA_CHAIRS" -> "EXTRA CHAIRS"
  String get displayType => addOnType.replaceAll('_', ' ');
}
