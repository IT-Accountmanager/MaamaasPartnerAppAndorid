class TableRequestModel {
  final int id;
  final int vendorId;
  final int? userId;
  final String name;
  final int itemId;
  final int? removalQuantity;
  final int? customerId;
  final int cartId;
  final int? tableBookingId;
  final String? tableCode;
  final String status;
  final String requestType;
  final String? reason;
  final String? createdAt;

  TableRequestModel({
    required this.id,
    required this.vendorId,
    this.userId,
    required this.name,
    required this.itemId,
    this.removalQuantity,
    this.customerId,
    required this.cartId,
    this.tableBookingId,
    this.tableCode,
    required this.status,
    required this.requestType,
    this.reason,
    this.createdAt,
  });

  factory TableRequestModel.fromJson(Map<String, dynamic> json) {
    return TableRequestModel(
      id: json['id'] ?? 0,
      vendorId: json['vendorId'] ?? 0,
      userId: json['userId'],
      name: json['name'] ?? '',
      itemId: json['itemId'] ?? 0,
      removalQuantity: json['removalQuantity'],
      customerId: json['customerId'],
      cartId: json['cartId'] ?? 0,
      tableBookingId: json['tableBookingId'],
      tableCode: json['tableCode'],
      status: json['status'] ?? '',
      requestType: json['requestType'] ?? '',
      reason: json['reason'],
      createdAt: json['createdAt'],
    );
  }
}
