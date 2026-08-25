// models/table_request_model.dart
class TableRequestModel {
  final int vendorId;
  final int? userId;
  final int? itemId;
  final int? cartId;
  final int? tableBookingId;
  final String? tableCode;
  final String requestType;
  final int? employeeId;
  final String? reason;
  final String? status;
  final String? itemName;
  final int? quantity;

  TableRequestModel({
    required this.vendorId,
    this.userId,
    this.itemId,
    this.cartId,
    this.tableBookingId,
    this.tableCode,
    required this.requestType,
    this.employeeId,
    this.reason,
    this.status,
    this.itemName,
    this.quantity,
  });

  Map<String, dynamic> toJson() {
    return {
      'vendorId': vendorId,
      if (userId != null) 'userId': userId,
      if (itemId != null) 'itemId': itemId,
      if (cartId != null) 'cartId': cartId,
      if (tableBookingId != null) 'tableBookingId': tableBookingId,
      if (tableCode != null) 'tableCode': tableCode,
      'requestType': requestType,
      if (employeeId != null) 'employeeId': employeeId,
      if (reason != null) 'reason': reason,
      if (status != null) 'status': status,
      if (itemName != null) 'itemName': itemName,
      if (quantity != null) 'quantity': quantity,
    };
  }
}