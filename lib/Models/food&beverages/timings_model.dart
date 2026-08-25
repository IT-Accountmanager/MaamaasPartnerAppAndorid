class Timing {
  int id;
  String day;
  String startTime;
  String lastTime;

  Timing({
    required this.id,
    required this.day,
    required this.startTime,
    required this.lastTime,
  });

  factory Timing.fromJson(Map<String, dynamic> json) {
    String parseTime(dynamic time) {
      if (time == null) return "--:--";
      if (time is String) return time;
      if (time is Map<String, dynamic>) {
        final hour = time['hour']?.toString().padLeft(2, '0') ?? '00';
        final minute = time['minute']?.toString().padLeft(2, '0') ?? '00';
        return "$hour:$minute";
      }
      return "--:--";
    }

    return Timing(
      id: json['id'],
      day: json['day'] ?? "",
      startTime: parseTime(json['startTime']),
      lastTime: parseTime(json['lastTime'] ?? json['endTime']),
    );
  }
}