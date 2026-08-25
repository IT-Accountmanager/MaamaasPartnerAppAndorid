enum PaymentStatus {
  PENDING,
  PAID,
}

extension PaymentStatusExtension on PaymentStatus {
  String get name => toString().split('.').last; // converts enum to string
  static PaymentStatus fromString(String? value) {
    switch (value?.toUpperCase()) {
      case 'PAID':
        return PaymentStatus.PAID;
      case 'PENDING':
      default:
        return PaymentStatus.PENDING;
    }
  }
}



class Coupon {
  final String vendorRequirementCouponId;
  final String couponCode;
  final double discount;
  final String description;
  final String image;
  final String startDate;
  final String endDate;
  final String gole;
  final double amount;
  final PaymentStatus paymentStatus;

  Coupon({
    required this.vendorRequirementCouponId,
    required this.couponCode,
    required this.discount,
    required this.description,
    required this.image,
    required this.startDate,
    required this.endDate,
    required this.gole,
    required this.amount,
    required this.paymentStatus,
  });

  factory Coupon.fromJson(Map<String, dynamic> json) {
    return Coupon(
      vendorRequirementCouponId: json['vendorRequirementCouponId'].toString(),
      couponCode: json['couponCode'] ?? '',
      discount: json['discount']?? 0,
      gole: json['gole']?? '',
      description: json['description'] ?? '',
      image: json['image'] ?? 'assets/images/default_coupon.jpg',
      startDate: json['startDate'] ?? '',
      endDate: json['endDate'] ?? '',
      amount: json['amount']?? 0,
      paymentStatus: PaymentStatusExtension.fromString(json['paymentStatus']), // ✅ parse enum
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'vendorRequirementCouponId': vendorRequirementCouponId,
      'couponCode': couponCode,
      'discount': discount,
      'gole': gole,
      'description': description,
      'image': image,
      'startDate': startDate,
      'endDate': endDate,
      'amount': amount,
      'paymentStatus': paymentStatus.name, // ✅ serialize enum
    };
  }
}
