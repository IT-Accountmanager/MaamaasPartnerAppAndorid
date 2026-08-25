class CouponStats {
  final int campaignId;
  final int totalUsers;
  final double totalDiscount;
  final List<CouponUser> users;

  CouponStats({
    required this.campaignId,
    required this.totalUsers,
    required this.totalDiscount,
    required this.users,
  });

  factory CouponStats.fromJson(Map<String, dynamic> json) {
    return CouponStats(
      campaignId: json['campaignId'] ?? 0,
      totalUsers: json['totalUsers'] ?? 0,
      totalDiscount: (json['totalDiscount'] ?? 0).toDouble(),
      users:
          (json['users'] as List?)
              ?.map((e) => CouponUser.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'campaignId': campaignId,
      'totalUsers': totalUsers,
      'totalDiscount': totalDiscount,
      'users': users.map((e) => e.toJson()).toList(),
    };
  }
}

class CouponUser {
  final int userId;
  final String userName;
  final double discountAmount;
  final int campaignId;
  final String code;
  final String couponType;
  final String discountType;

  CouponUser({
    required this.userId,
    required this.userName,
    required this.discountAmount,
    required this.campaignId,
    required this.code,
    required this.couponType,
    required this.discountType,
  });

  factory CouponUser.fromJson(Map<String, dynamic> json) {
    return CouponUser(
      userId: json['userId'] ?? 0,
      userName: json['userName'] ?? '',
      discountAmount: (json['discountAmount'] ?? 0).toDouble(),
      campaignId: json['campaignId'] ?? 0,
      code: json['code'] ?? '',
      couponType: json['couponType'] ?? 'FLAT',
      discountType: json['discountType'] ?? 'PERCENTAGE',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'discountAmount': discountAmount,
      'campaignId': campaignId,
      'code': code,
      'couponType': couponType,
      'discountType': discountType,
    };
  }
}
