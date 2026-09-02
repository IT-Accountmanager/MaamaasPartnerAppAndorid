import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Ports `.leads-table-badge` / `.assigned-leads-status-badge` / etc. —
/// a small rounded-pill label used for event types and statuses.
class StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final Color background;
  final bool solid;

  const StatusChip({
    super.key,
    required this.label,
    required this.color,
    required this.background,
    this.solid = false,
  });

  /// Solid background + white text, matching the event-type badges which
  /// use `background: eventColor, color: white` in the JSX.
  factory StatusChip.solid({required String label, required Color color}) {
    return StatusChip(label: label, color: Colors.white, background: color, solid: true);
  }

  factory StatusChip.status(StatusBadgeStyle style) {
    return StatusChip(label: style.label, color: style.color, background: style.background);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
          color: color,
        ),
      ),
    );
  }
}
