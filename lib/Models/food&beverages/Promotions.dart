import 'dart:convert';
import 'dart:typed_data';

class FBPromotion {
  final int id;
  final String couponCode;
  final String couponType;
  final String description;
  final String goal;
  final double discount;
  final String startDate;
  final String endDate;
  final double amount;
  final String paymentStatus;
  final String? imageBase64; // base64 string from backend

  // ✅ Automatically decodes base64 for display in Image.memory
  Uint8List? get decodedImage =>
      imageBase64 != null && imageBase64!.isNotEmpty
          ? base64Decode(imageBase64!)
          : null;

  FBPromotion({
    required this.id,
    required this.couponCode,
    required this.couponType,
    required this.description,
    required this.goal,
    required this.discount,
    required this.startDate,
    required this.endDate,
    required this.amount,
    required this.paymentStatus,
    this.imageBase64,
  });

  factory FBPromotion.fromJson(Map<String, dynamic> json) {
    String? rawImage = json['image'];

    // ✅ if backend sends "data:image/png;base64,...."
    if (rawImage != null && rawImage.startsWith('data:image')) {
      rawImage = rawImage.split(',').last;
    }

    return FBPromotion(
      id: json['id'] ?? 0,
      couponCode: json['couponCode'] ?? '',
      couponType: json['couponType'] ?? '',
      description: json['description'] ?? '',
      goal: json['goal'] ?? json['gole'] ??'',
      discount: (json['discount'] ?? 0).toDouble(),
      startDate: json['startDate'] ?? '',
      endDate: json['endDate'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      paymentStatus: json['paymentStatus'] ?? 'PENDING',
      imageBase64: rawImage,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'couponCode': couponCode,
      'couponType': couponType,
      'description': description,
      'goal': goal,
      'discount': discount,
      'startDate': startDate,
      'endDate': endDate,
      'amount': amount,
      'paymentStatus': paymentStatus,
      'image': imageBase64, // send base64 string to backend
    };
  }
}
