/// Minimal subscription model used by [Authservice.fetchSubscriptionData].
class SubscriptionData {
  final int? id;
  final String? planType;
  final String? status;
  final DateTime? startDate;
  final DateTime? endDate;
  final Map<String, dynamic> raw;

  SubscriptionData({
    this.id,
    this.planType,
    this.status,
    this.startDate,
    this.endDate,
    required this.raw,
  });

  factory SubscriptionData.fromJson(Map<String, dynamic> json) {
    return SubscriptionData(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? ''),
      planType: json['planType']?.toString(),
      status: json['status']?.toString(),
      startDate: DateTime.tryParse(json['startDate']?.toString() ?? ''),
      endDate: DateTime.tryParse(json['endDate']?.toString() ?? ''),
      raw: json,
    );
  }
}
