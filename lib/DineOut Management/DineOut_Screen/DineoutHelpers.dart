import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DineoutHelpers {
  static const Color _orange = Color(0xFFE87722);
  static const Color _orangeLight = Color(0xFFFFF4EC);
  static const Color _white = Color(0xFFFFFFFF);
  static const Color _border = Color(0xFFEEECEA);
  static const Color _textDark = Color(0xFF1A1A1A);
  static const Color _textMuted = Color(0xFF888888);
  static const Color _bg = Color(0xFFF7F6F3);

  static String convertTo24HourFormat(String time12hr) {
    try {
      DateFormat inputFormat = DateFormat('h:mm a');
      DateTime date = inputFormat.parse(time12hr.toUpperCase());
      return DateFormat('HH:mm:ss').format(date);
    } catch (e) {
      return DateFormat('HH:mm:ss').format(DateTime.now());
    }
  }

  static String formatTimeWithoutSeconds(String? timeString) {
    if (timeString == null || timeString.isEmpty) return '';
    try {
      if (timeString.contains(':')) {
        List<String> parts = timeString.split(':');
        if (parts.length >= 2) {
          String hourMinute = '${parts[0]}:${parts[1]}';
          try {
            DateTime parsedTime = DateFormat('HH:mm').parse(hourMinute);
            return DateFormat('h:mm a').format(parsedTime);
          } catch (e) {
            return hourMinute;
          }
        }
      }
      return timeString;
    } catch (e) {
      return timeString;
    }
  }

  static Widget fieldLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: _textMuted,
        letterSpacing: 0.5,
      ),
    );
  }

  static Widget inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 13, color: _textDark),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: _textMuted.withOpacity(0.55), fontSize: 12),
        prefixIcon: Icon(icon, size: 17, color: _textMuted),
        filled: true,
        fillColor: _bg,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 13,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _orange, width: 1.5),
        ),
      ),
    );
  }

  static Widget cancelButton({required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: _white,
          border: Border.all(color: _border, width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text(
            'Cancel',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _textMuted,
            ),
          ),
        ),
      ),
    );
  }

  static Widget primaryButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: _orange,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: _orange.withOpacity(0.28),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
