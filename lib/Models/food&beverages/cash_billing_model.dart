class CashBilling {
  final int id;
  final int orderId;
  final int oneRupee;
  final int twoRupee;
  final int fiveRupee;
  final int tenRupee;
  final int twentyRupee;
  final int fiftyRupee;
  final int hundredRupee;
  final int twoHundredRupee;
  final int fiveHundredRupee;
  final int twoThousandRupee;
  final num grandTotal;
  final num paid;
  final num returnMoney;
  final String? paymentStatus;

  CashBilling({
    required this.id,
    required this.orderId,
    required this.oneRupee,
    required this.twoRupee,
    required this.fiveRupee,
    required this.tenRupee,
    required this.twentyRupee,
    required this.fiftyRupee,
    required this.hundredRupee,
    required this.twoHundredRupee,
    required this.fiveHundredRupee,
    required this.twoThousandRupee,
    required this.grandTotal,
    required this.paid,
    required this.returnMoney,
    this.paymentStatus,
  });

  factory CashBilling.fromJson(Map<String, dynamic> json) {
    int _toInt(dynamic v) => (v ?? 0).toDouble().toInt();

    return CashBilling(
      id: _toInt(json['id']),
      orderId: _toInt(json['orderId']),
      oneRupee: _toInt(json['oneRupee']),
      twoRupee: _toInt(json['twoRupee']),
      fiveRupee: _toInt(json['fiveRupee']),
      tenRupee: _toInt(json['tenRupee']),
      twentyRupee: _toInt(json['twentyRupee']),
      fiftyRupee: _toInt(json['fiftyRupee']),
      hundredRupee: _toInt(json['hundredRupee']),
      twoHundredRupee: _toInt(json['twoHundredRupee']),
      fiveHundredRupee: _toInt(json['fiveHundredRupee']),
      twoThousandRupee: _toInt(json['twoThousandRupee']),
      grandTotal: (json['grandTotal'] ?? 0).toDouble(),
      paid: (json['paid'] ?? 0).toDouble(),
      returnMoney: (json['returnMoney'] ?? 0).toDouble(),
      paymentStatus: json['paymentStatus'],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "orderId": orderId,
    "oneRupee": oneRupee,
    "twoRupee": twoRupee,
    "fiveRupee": fiveRupee,
    "tenRupee": tenRupee,
    "twentyRupee": twentyRupee,
    "fiftyRupee": fiftyRupee,
    "hundredRupee": hundredRupee,
    "twoHundredRupee": twoHundredRupee,
    "fiveHundredRupee": fiveHundredRupee,
    "twoThousandRupee": twoThousandRupee,
    "grandTotal": grandTotal,
    "paid": paid,
    "returnMoney": returnMoney,
    "paymentStatus": paymentStatus,
  };
}
