class Ticket {
  final int id;
  final int vendorId;
  final int orderId;
  final String ticketType;
  final String status;
  final String message;
  final String? attachmentUrl;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final String? adminResponse;


  Ticket({
    required this.id,
    required this.vendorId,
    required this.orderId,
    required this.ticketType,
    required this.status,
    required this.message,
    required this.attachmentUrl,
    required this.createdAt,
    required this.resolvedAt,
    required this.adminResponse,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id'] as int? ?? 0,
      vendorId: json['vendorId'] as int? ?? 0,
      orderId: json['orderId'] as int? ?? 0,
      ticketType: json['ticketType'] as String? ?? '',
      status: json['status'] as String? ?? '',
      message: json['message'] as String? ?? '',
      attachmentUrl: json['attachmentUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt']),
      resolvedAt: json['resolvedAt'] != null
          ? DateTime.tryParse(json['resolvedAt'])
          : null,
      adminResponse: json['adminResponse'] as String?,
    );
  }

}
