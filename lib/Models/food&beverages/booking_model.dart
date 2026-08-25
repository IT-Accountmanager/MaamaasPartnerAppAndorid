// booking_model.dart
class Booking {
  final String guestName;
  final String phone;
  final String date;
  final String time;
  final String duration;
  final String floor;
  final String table;

  Booking({
    required this.guestName,
    required this.phone,
    required this.date,
    required this.time,
    required this.duration,
    required this.floor,
    required this.table,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    final seating = json["seating"] ?? {};

    return Booking(
      guestName: json["guestName"] ?? json["userName"] ?? json["name"] ?? "-",
      phone: json["phoneNumber"] ?? json["phone"] ?? "-",
      date: json["bookingDate"] ?? json["date"] ?? "-",
      time: json["startTime"] ?? json["time"] ?? "-",
      duration: (json["durationMinutes"] != null)
          ? "${json["durationMinutes"]} min"
          : (json["duration"]?.toString() ?? "-"),
      floor: seating["name"]?.toString() ?? "-",
      table: seating["code"]?.toString() ??
          json["tableNumber"]?.toString() ??
          "-", // fallback if table info appears later
    );
  }
}
