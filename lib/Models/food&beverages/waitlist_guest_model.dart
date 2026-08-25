class WaitlistRequest {
  final int id;
  final String floorName;
  final String phoneNumber;
  final int capacity;
  final int durationMinutes;
  final String requestTime;
  final String bookingDate;
  final String guestName;
  final String code;
  final String types;
  final int userId;
  final int vendorId;

  WaitlistRequest({
    required this.id,
    required this.floorName,
    required this.phoneNumber,
    required this.capacity,
    required this.durationMinutes,
    required this.requestTime,
    required this.bookingDate,
    required this.guestName,
    required this.code,
    required this.types,
    required this.userId,
    required this.vendorId,
  });

  Map<String, dynamic> toJson() => {
    "id": id,
    "floorName": floorName,
    "phoneNumber": phoneNumber,
    "capacity": capacity,
    "durationMinutes": durationMinutes,
    "requestTime": requestTime,
    "bookingDate": bookingDate,
    "guestName": guestName,
    "code": code,
    "types": types,
    "userId": userId,
    "vendorId": vendorId,
  };
}
