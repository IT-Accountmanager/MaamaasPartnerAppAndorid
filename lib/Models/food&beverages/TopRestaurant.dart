class TopRestaurant {
  int topratedId;
  String description;
  double amount;
  DateTime startDate;
  DateTime endDate;
  int vendorId;
  String paymentStatus;
  String transactionId;
  String orderId;

  TopRestaurant({
    this.topratedId = 0,
    required this.description,
    required this.amount,
    required this.startDate,
    required this.endDate,
    required this.vendorId,
    this.paymentStatus = "PENDING",
    this.transactionId = "",
    this.orderId = "",
  });

  Map<String, dynamic> toJson() {
    return {
      "topratedId": topratedId,
      "description": description,
      "amount": amount,
      "startDate": startDate.toUtc().toIso8601String(),
      "endDate": endDate.toUtc().toIso8601String(),
      "vendorId": vendorId,
      "paymentStatus": paymentStatus,
      "transactionId": transactionId,
      "orderId": orderId,
    };
  }

  factory TopRestaurant.fromJson(Map<String, dynamic> json) {
    return TopRestaurant(
      topratedId: json["topratedId"] ?? 0,
      description: json["description"] ?? "",
      amount: (json["amount"] ?? 0).toDouble(),
      startDate: DateTime.parse(json["startDate"]),
      endDate: DateTime.parse(json["endDate"]),
      vendorId: json["vendorId"] ?? 0,
      paymentStatus: json["paymentStatus"] ?? "PENDING",
      transactionId: json["transactionId"] ?? "",
      orderId: json["orderId"] ?? "",
    );
  }
}
