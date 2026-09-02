import 'package:intl/intl.dart';

/// Ports `formatDate()` — `new Date(x).toLocaleDateString('en-IN', {day:'2-digit', month:'short', year:'numeric'})`.
String formatDate(String? dateString) {
  if (dateString == null || dateString.isEmpty) return 'N/A';
  final parsed = DateTime.tryParse(dateString);
  if (parsed == null) return 'N/A';
  return DateFormat('dd MMM yyyy').format(parsed);
}

/// Ports `formatDateTime()`.
String formatDateTime(String? dateString) {
  if (dateString == null || dateString.isEmpty) return 'N/A';
  final parsed = DateTime.tryParse(dateString);
  if (parsed == null) return 'N/A';
  return DateFormat('dd MMM yyyy, hh:mm a').format(parsed);
}

/// Ports `formatTime()` — expects "HH:mm" (24h) and returns "h:mm AM/PM".
String formatTime(String? timeString) {
  if (timeString == null || timeString.isEmpty) return 'N/A';
  try {
    final parts = timeString.split(':');
    final hour = int.parse(parts[0]);
    final minute = parts[1];
    final ampm = hour >= 12 ? 'PM' : 'AM';
    final hour12 = (hour % 12 == 0) ? 12 : hour % 12;
    return '$hour12:$minute $ampm';
  } catch (_) {
    return timeString;
  }
}

/// Ports `₹{amount.toLocaleString()}` with Indian digit grouping.
String formatInr(num amount) {
  final formatter = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );
  return formatter.format(amount);
}
