import 'package:flutter/material.dart';

class TableCard extends StatelessWidget {
  final Map<String, dynamic> table;
  final List<Map<String, dynamic>> reservations;
  final Function(int?, String?) onTableTap;
  final Function(int?, String?) onCartTap;

  const TableCard({
    super.key,
    required this.table,
    required this.reservations,
    required this.onTableTap,
    required this.onCartTap,
  });

  @override
  Widget build(BuildContext context) {
    final String tableName = table['name'] ?? '';
    final String tableCode = table['code'] ?? tableName;
    final String status = table['status'] ?? 'Available';
    final String displayName = tableCode.isNotEmpty ? tableCode : tableName;

    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // ── Table Card ──────────────────────────────────────────
        Expanded(
          child: GestureDetector(
            onTap: () {
              int? foundBookingId;
              String? bookingTableCode;
              for (var booking in reservations) {
                if (booking['code'] == tableCode) {
                  foundBookingId = booking['id'];
                  bookingTableCode = booking['code'];
                  break;
                }
              }
              onTableTap(foundBookingId, bookingTableCode);
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _getStatusColor(status), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Left: Status Icon
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: _getStatusBgColor(status),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getStatusIcon(status),
                      color: _getStatusColor(status),
                      size: 15,
                    ),
                  ),
                  const SizedBox(width: 6),

                  // Right: Name + seats/time
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          displayName,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A1A),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        _buildTimeOrSeats(status, tableCode),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // ── Cart Button BELOW the card ───────────────────────────
        _buildCartButton(status, tableCode),
      ],
    );
  }

  Widget _buildTimeOrSeats(String status, String tableCode) {
    if (status == 'Reserved') {
      String? bookingTime;
      for (var booking in reservations) {
        if (booking['code'] == tableCode) {
          bookingTime = _formatTimeWithoutSeconds(booking['time']);
          break;
        }
      }
      if (bookingTime != null) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFFE87722).withOpacity(0.12),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.access_time, size: 9, color: Color(0xFFE87722)),
              const SizedBox(width: 2),
              Flexible(
                child: Text(
                  bookingTime,
                  style: const TextStyle(
                    fontSize: 8,
                    color: Color(0xFFE87722),
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      }
    }
    return Text(
      '${table['seats'] ?? 2} seats',
      style: const TextStyle(fontSize: 8, color: Color(0xFF888888)),
    );
  }

  Widget _buildCartButton(String status, String tableCode) {
    if (status == 'Reserved' || status == 'Occupied') {
      double? cartTotal;
      int? bookingId;

      for (var booking in reservations) {
        if (booking['code'] == tableCode) {
          bookingId = booking['id'];
          if (booking['cartTotal'] != null) {
            cartTotal = (booking['cartTotal'] as num).toDouble();
          }
          break;
        }
      }

      return GestureDetector(
        onTap: () => onCartTap(bookingId, tableCode),
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 3),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFF4CAF50).withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.shopping_cart_outlined,
                size: 11,
                color: Color(0xFF4CAF50),
              ),
              const SizedBox(width: 4),
              if (cartTotal != null && cartTotal > 0)
                Text(
                  '₹${cartTotal.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 9,
                    color: Color(0xFF4CAF50),
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
        ),
      );
    }

    return const SizedBox(height: 18);
  }

  String _formatTimeWithoutSeconds(String? timeString) {
    if (timeString == null) return '';
    try {
      if (timeString.contains(':')) {
        final parts = timeString.split(':');
        if (parts.length >= 2) return '${parts[0]}:${parts[1]}';
      }
      return timeString;
    } catch (e) {
      return timeString;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Available':
        return const Color(0xFF4CAF50);
      case 'Reserved':
        return const Color(0xFFE87722);
      case 'Vacant':
        return Colors.teal;
      case 'Occupied':
        return const Color(0xFFE53935);
      case 'Cleaning':
        return Colors.blue;
      case 'Maintenance':
        return const Color(0xFF888888);
      default:
        return const Color(0xFFEEECEA);
    }
  }

  Color _getStatusBgColor(String status) {
    switch (status) {
      case 'Available':
        return const Color(0xFF4CAF50).withOpacity(0.1);
      case 'Reserved':
        return const Color(0xFFE87722).withOpacity(0.1);
      case 'Vacant':
        return Colors.teal.withOpacity(0.1);
      case 'Occupied':
        return const Color(0xFFE53935).withOpacity(0.1);
      case 'Cleaning':
        return Colors.blue.withOpacity(0.1);
      case 'Maintenance':
        return const Color(0xFF888888).withOpacity(0.1);
      default:
        return const Color(0xFFFFF4EC);
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Available':
        return Icons.check_circle_outline;
      case 'Reserved':
        return Icons.event_seat;
      case 'Vacant':
        return Icons.chair_outlined;
      case 'Occupied':
        return Icons.person;
      case 'Cleaning':
        return Icons.cleaning_services;
      case 'Maintenance':
        return Icons.build;
      default:
        return Icons.table_restaurant_rounded;
    }
  }
}
