// ─────────────────────────────────────────────────────────────────────────────
// Models/wallet_model.dart
// ─────────────────────────────────────────────────────────────────────────────

class WalletBalance {
  final int vendorId;
  final double selfLoadedAmount;
  final double cashbackAmount;
  final double totalBalance;
  final String createdAt;

  WalletBalance({
    required this.vendorId,
    required this.selfLoadedAmount,
    required this.cashbackAmount,
    required this.totalBalance,
    required this.createdAt,
  });

  factory WalletBalance.fromJson(Map<String, dynamic> json) {
    return WalletBalance(
      vendorId: json['vendorId'] ?? 0,
      selfLoadedAmount: (json['selfLoadedAmount'] ?? 0.0).toDouble(),
      cashbackAmount: (json['cashbackAmount'] ?? 0.0).toDouble(),
      totalBalance: (json['totalBalance'] ?? 0.0).toDouble(),
      createdAt: json['createdAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'vendorId': vendorId,
    'selfLoadedAmount': selfLoadedAmount,
    'cashbackAmount': cashbackAmount,
    'totalBalance': totalBalance,
    'createdAt': createdAt,
  };
}

// ─────────────────────────────────────────────────────────────────────────────

class WalletTransaction {
  final int transactionId;
  final int vendorId;
  final double amount;
  final double cashback;
  final double totalBalance;
  final String status;
  final String paymentId;
  final String orderId;
  final String time;

  WalletTransaction({
    required this.transactionId,
    required this.vendorId,
    required this.amount,
    required this.cashback,
    required this.totalBalance,
    required this.status,
    required this.paymentId,
    required this.orderId,
    required this.time,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      transactionId: json['transactionId'] ?? 0,
      vendorId: json['vendorId'] ?? 0,
      amount: (json['amount'] ?? 0.0).toDouble(),
      cashback: (json['cashback'] ?? 0.0).toDouble(),
      totalBalance: (json['totalBalance'] ?? 0.0).toDouble(),
      status: json['status'] ?? '',
      paymentId: json['paymentId'] ?? '',
      orderId: json['orderId'] ?? '',
      time: json['time'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'transactionId': transactionId,
    'vendorId': vendorId,
    'amount': amount,
    'cashback': cashback,
    'totalBalance': totalBalance,
    'status': status,
    'paymentId': paymentId,
    'orderId': orderId,
    'time': time,
  };

  /// Derive whether this is a credit or debit from the transaction data.
  /// Positive cashback or SUCCESS status credits are treated as credit.
  bool get isCredit => amount > 0;

  /// Returns a human-readable formatted date from ISO string.
  String get formattedDate {
    try {
      final dt = DateTime.parse(time);
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
      final amPm = dt.hour >= 12 ? 'PM' : 'AM';
      final minute = dt.minute.toString().padLeft(2, '0');
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}, $hour:$minute $amPm';
    } catch (_) {
      return time;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class CreateOrderResponse {
  final String orderId;
  final double amount;
  final String currency;
  final String receipt;

  CreateOrderResponse({
    required this.orderId,
    required this.amount,
    required this.currency,
    required this.receipt,
  });

  factory CreateOrderResponse.fromJson(Map<String, dynamic> json) {
    return CreateOrderResponse(
      orderId: json['id'] ?? json['orderId'] ?? '',
      amount: (json['amount'] ?? 0.0).toDouble(),
      currency: json['currency'] ?? 'INR',
      receipt: json['receipt'] ?? '',
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class AddCashResponse {
  final int transactionId;
  final int vendorId;
  final double amount;
  final double cashback;
  final double totalBalance;
  final String status;
  final String paymentId;
  final String orderId;
  final String time;

  AddCashResponse({
    required this.transactionId,
    required this.vendorId,
    required this.amount,
    required this.cashback,
    required this.totalBalance,
    required this.status,
    required this.paymentId,
    required this.orderId,
    required this.time,
  });

  factory AddCashResponse.fromJson(Map<String, dynamic> json) {
    return AddCashResponse(
      transactionId: json['transactionId'] ?? 0,
      vendorId: json['vendorId'] ?? 0,
      amount: (json['amount'] ?? 0.0).toDouble(),
      cashback: (json['cashback'] ?? 0.0).toDouble(),
      totalBalance: (json['totalBalance'] ?? 0.0).toDouble(),
      status: json['status'] ?? '',
      paymentId: json['paymentId'] ?? '',
      orderId: json['orderId'] ?? '',
      time: json['time'] ?? '',
    );
  }
}
