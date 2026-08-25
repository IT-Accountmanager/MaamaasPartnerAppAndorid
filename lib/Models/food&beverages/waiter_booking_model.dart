class WaiterBooking {
  final String guestName;
  final String bookingDate;
  final String time;
  final String tableNumber;
  final int capacity;
  final String arrivalStatus;
  final String phoneNumber;
  final int seatingId;

  WaiterBooking({
    required this.guestName,
    required this.bookingDate,
    required this.time,
    required this.tableNumber,
    required this.capacity,
    required this.arrivalStatus,
    required this.phoneNumber,
    required this.seatingId,
  });

  factory WaiterBooking.fromJson(Map<String, dynamic> json) {
    return WaiterBooking(
      guestName: json['guestName'] ?? '-',
      bookingDate: json['bookingDate'] ?? '-',
      time: json['startTime'] ?? '-',
      tableNumber: json['seating']?['name'] ?? json['code'] ?? '-',
      capacity: json['capacity'] ?? 0,
      arrivalStatus: json['arrivalStatus'] ?? '-',
      phoneNumber: json['phoneNumber'] ?? '-',
      seatingId: json['seatingId'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'guestName': guestName,
      'bookingDate': bookingDate,
      'time': time,
      'tableNumber': tableNumber,
      'capacity': capacity,
      'arrivalStatus': arrivalStatus,
      'phoneNumber': phoneNumber,
      'seatingId': seatingId,
    };
  }
}
