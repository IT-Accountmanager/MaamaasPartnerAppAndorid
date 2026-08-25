import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReservationCard extends StatelessWidget {
  final Map<String, dynamic> reservation;
  final int index;
  final Function(Map<String, dynamic>, int) onEdit;
  final Function() onRefresh;

  const ReservationCard({
    super.key,
    required this.reservation,
    required this.index,
    required this.onEdit,
    required this.onRefresh,
  });

  // ── Design tokens ──────────────────────────────────────────────────────────
  static const Color _orange = Color(0xFFE87722);
  static const Color _orangeLight = Color(0xFFFFF4EC);
  static const Color _white = Color(0xFFFFFFFF);
  static const Color _border = Color(0xFFEEECEA);
  static const Color _textDark = Color(0xFF1A1A1A);
  static const Color _textMuted = Color(0xFF888888);
  static const Color _success = Color(0xFF4CAF50);
  static const Color _error = Color(0xFFE53935);
  static const Color _pending = Color(0xFFFFA726);

  @override
  Widget build(BuildContext context) {
    bool isOnline = reservation['userId'] != null;
    String reservationDate = reservation['date'] ?? '';
    String formattedReservationDate = '';
    if (reservationDate.isNotEmpty) {
      try {
        DateTime date = DateTime.parse(reservationDate);
        formattedReservationDate = DateFormat('dd/MM/yyyy').format(date);
      } catch (e) {
        formattedReservationDate = reservationDate;
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(isOnline, reservation),
          _buildBody(reservation, formattedReservationDate),
        ],
      ),
    );
  }

  // ── Card header ────────────────────────────────────────────────────────────
  Widget _buildHeader(bool isOnline, Map<String, dynamic> res) {
    final statusColor = res['status'] == 'ARRIVED'
        ? _success
        : res['status'] == 'Rejected'
        ? _error
        : _pending;

    final statusLabel = res['status'] == 'ARRIVED'
        ? 'ARRIVED'
        : (res['status'] ?? 'Pending');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: _orangeLight,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          // ── Booking number + online badge ──────────────────────────────
          Expanded(
            child: Row(
              children: [
                Text(
                  'Booking ${index + 1}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: _orange,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: isOnline ? _success : const Color(0xFFAAAAAA),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isOnline ? Icons.wifi_rounded : Icons.wifi_off_rounded,
                        size: 9,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        isOnline ? 'ONLINE' : 'OFFLINE',
                        style: const TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Edit + Status ──────────────────────────────────────────────
          Row(
            children: [
              GestureDetector(
                onTap: () => onEdit(res, index),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _orange,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: _orange.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.edit_rounded, color: Colors.white, size: 11),
                      SizedBox(width: 4),
                      Text(
                        'Edit',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusLabel,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Card body ──────────────────────────────────────────────────────────────
  Widget _buildBody(Map<String, dynamic> res, String formattedReservationDate) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top info row: Customer | Guests ────────────────────────────
          Row(
            children: [
              Expanded(
                child: _infoCell(
                  Icons.person_outline_rounded,
                  'Customer',
                  res['name'] ?? '',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _infoCell(
                  Icons.group_outlined,
                  'Guests',
                  '${res['guests'] ?? 0}',
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ── Second info row: Phone | Table Code ────────────────────────
          Row(
            children: [
              Expanded(
                child: _infoCell(
                  Icons.phone_outlined,
                  'Phone Number',
                  res['phone'] ?? '',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _infoCell(
                  Icons.table_restaurant_rounded,
                  'Table Code',
                  res['code'] ?? res['table'] ?? 'N/A',
                ),
              ),
            ],
          ),

          // ── Divider ────────────────────────────────────────────────────
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: _border),
          ),

          // ── Booking date row ───────────────────────────────────────────
          if (res['createdAt'] != null &&
              res['createdAt'].toString().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today_rounded,
                    size: 12,
                    color: _textMuted,
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Booking Date: ',
                    style: TextStyle(
                      fontSize: 10,
                      color: _textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    res['createdAt'],
                    style: const TextStyle(
                      fontSize: 10,
                      color: _textDark,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

          // ── Reservation date / time / duration row ─────────────────────
          Row(
            children: [
              Expanded(
                child: _dateCell(
                  'Reservation Date',
                  Icons.calendar_today_rounded,
                  formattedReservationDate,
                ),
              ),
              Expanded(
                child: _dateCell(
                  'Time',
                  Icons.access_time_rounded,
                  _formatTimeWithoutSeconds(res['time']),
                ),
              ),
              Expanded(
                child: _dateCell(
                  'Duration',
                  Icons.timer_outlined,
                  res['duration'] ?? '',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Helper widgets ─────────────────────────────────────────────────────────
  Widget _infoCell(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: _orangeLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 14, color: _orange),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 9, color: _textMuted),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _textDark,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _dateCell(String label, IconData icon, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 9, color: _textMuted)),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(icon, size: 11, color: _textMuted),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                value,
                style: const TextStyle(fontSize: 11, color: _textDark),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Unchanged logic ────────────────────────────────────────────────────────
  String _formatTimeWithoutSeconds(String? timeString) {
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
}
