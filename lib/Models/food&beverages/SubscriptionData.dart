class SubscriptionData {
  final int id;
  final VendorEnquiry vendorEnquiry;
  final SubscriptionPlan subscriptionPlan;
  final String status;
  final Payment payment;
  final DateTime startDate;
  final DateTime endDate;
  final String businessVertical;
  final int remainingDays;

  SubscriptionData({
    required this.id,
    required this.vendorEnquiry,
    required this.subscriptionPlan,
    required this.status,
    required this.payment,
    required this.startDate,
    required this.endDate,
    required this.businessVertical,
    required this.remainingDays,
  });

  factory SubscriptionData.fromJson(Map<String, dynamic> json) {
    return SubscriptionData(
      id: json['id'],
      vendorEnquiry: VendorEnquiry.fromJson(json['vendorEnquiry']),
      subscriptionPlan: SubscriptionPlan.fromJson(json['subscriptionPlan']),
      status: json['status'],
      payment: Payment.fromJson(json['payment']),
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      businessVertical: json['businessVertical'],
      remainingDays: json['remainingDays'],
    );
  }
}

class VendorEnquiry {
  final int vendorId;
  final String name;
  final String email;
  final String mobileNumber;
  final String? companyName;
  final List<String> businessVerticals;

  VendorEnquiry({
    required this.vendorId,
    required this.name,
    required this.email,
    required this.mobileNumber,
    required this.companyName,
    required this.businessVerticals,
  });

  factory VendorEnquiry.fromJson(Map<String, dynamic> json) {
    return VendorEnquiry(
      vendorId: json['vendorId'],
      name: json['name'],
      email: json['email'],
      mobileNumber: json['mobileNumber'],
      companyName: json['companyName'],
      businessVerticals: List<String>.from(json['businessVerticals'] ?? []),
    );
  }
}

class SubscriptionPlan {
  final int id;
  final String businessVerticals;
  final String planType;
  final double price;
  final int days;
  final List<String> businessModules;

  SubscriptionPlan({
    required this.id,
    required this.businessVerticals,
    required this.planType,
    required this.price,
    required this.days,
    required this.businessModules,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['id'],
      businessVerticals: json['businessVerticals'],
      planType: json['planType'],
      price: json['price'],
      days: json['days'],
      businessModules: List<String>.from(json['businessModules'] ?? []),
    );
  }
}

class Payment {
  final int id;
  final bool termsAndConditions;
  final double amount;
  final String status;
  final String? transactionId;
  final String approval;
  final DateTime paymentDate;

  Payment({
    required this.id,
    required this.termsAndConditions,
    required this.amount,
    required this.status,
    required this.transactionId,
    required this.approval,
    required this.paymentDate,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      termsAndConditions: json['termsAndConditions'],
      amount: (json['amount'] as num).toDouble(),
      status: json['status'],
      transactionId: json['transactionId'],
      approval: json['approval'],
      paymentDate: DateTime.parse(json['paymentDate']),
    );
  }
}
