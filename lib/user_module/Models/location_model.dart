class UserLocationModel {
  final int id;
  // final int userId;
  final String customerId;
  final double latitude;
  final double longitude;
  final String address;

  UserLocationModel({
    required this.id,
    // required this.userId,
    required this.customerId,
    required this.latitude,
    required this.longitude,
    required this.address,
  });

  factory UserLocationModel.fromJson(Map<String, dynamic> json) {
    return UserLocationModel(
      id: json["id"],
      // userId: json["userId"],
      customerId:json['customerId'],
      latitude: json["latitude"],
      longitude: json["longitude"],
      address: json["address"],
    );
  }
}
