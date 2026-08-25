// models/schedule_model.dart
class ScheduleItem {
  final String serviceDate;
  final int vegCount;
  final int nonVegCount;
  final double dailyAmount;
  final String status;
  final int userId;
  final String companyName;
  final int vendorId;

  ScheduleItem({
    required this.serviceDate,
    required this.vegCount,
    required this.nonVegCount,
    required this.dailyAmount,
    required this.status,
    required this.userId,
    required this.companyName,
    required this.vendorId,
  });

  factory ScheduleItem.fromJson(Map<String, dynamic> json) {
    return ScheduleItem(
      serviceDate: json['serviceDate'] ?? '',
      vegCount: json['vegCount'] ?? 0,
      nonVegCount: json['nonVegCount'] ?? 0,
      dailyAmount: (json['dailyAmount'] ?? 0).toDouble(),
      status: json['status'] ?? '',
      userId: json['userId'] ?? 0,
      companyName: json['companyName'] ?? '',
      vendorId: json['vendorId'] ?? 0,
    );
  }
}

class MonthlyScheduleSummary {
  final String month;
  final int year;
  final int totalDays;
  final int totalVegMeals;
  final int totalNonVegMeals;
  final double totalAmount;
  final int pendingCount;
  final int completedCount;
  final List<ScheduleItem> items;

  MonthlyScheduleSummary({
    required this.month,
    required this.year,
    required this.totalDays,
    required this.totalVegMeals,
    required this.totalNonVegMeals,
    required this.totalAmount,
    required this.pendingCount,
    required this.completedCount,
    required this.items,
  });
}
