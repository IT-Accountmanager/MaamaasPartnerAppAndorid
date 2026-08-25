class ProfessionalTransaction {
  final int id;
  final String name;
  final String email;
  final String phoneNumber;
  final String empid;
  final int userId;
  final int professionalUserId;
  final String month;
  final int year;
  final String status;
  final String time;
  final bool postPaid;
  final double? usedAmount;
  final double? creditLimit;
  final String? restaurentName;

  ProfessionalTransaction({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.empid,
    required this.userId,
    required this.professionalUserId,
    required this.month,
    required this.year,
    required this.status,
    required this.time,
    required this.postPaid,
    this.usedAmount,
    this.creditLimit,
    this.restaurentName,
  });

  factory ProfessionalTransaction.fromJson(Map<String, dynamic> json) {
    return ProfessionalTransaction(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      empid: json['empid'],
      userId: json['userId'],
      professionalUserId: json['professionalUserId'],
      month: json['month'],
      year: json['year'],
      status: json['status'],
      time: json['time'],
      postPaid: json['postPaid'] ?? false,
      usedAmount: (json['usedAmount'] ?? 0).toDouble(),
      creditLimit: (json['creditLimit'] ?? 0).toDouble(),
      restaurentName: json['restaurentName'],
    );
  }
}
