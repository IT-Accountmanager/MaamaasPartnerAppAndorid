import 'package:flutter/material.dart';

// sp = support — unique prefix, no conflicts
const Color spAccent   = Color(0xFFE66D33);
const Color spAccentL  = Color(0xFFFFF0E8);
const Color spBg       = Color(0xFFF6F7FB);
const Color spCard     = Color(0xFFFFFFFF);
const Color spBorder   = Color(0xFFE2E8F0);
const Color spText1    = Color(0xFF0F172A);
const Color spText2    = Color(0xFF64748B);
const Color spText3    = Color(0xFF94A3B8);
const Color spBlue     = Color(0xFF3B82F6);
const Color spBlueL    = Color(0xFFDBEAFE);
const Color spGreen    = Color(0xFF10B981);
const Color spGreenL   = Color(0xFFD1FAE5);
const Color spRed      = Color(0xFFEF4444);
const Color spRedL     = Color(0xFFFEE2E2);
const Color spAmber    = Color(0xFFF59E0B);
const Color spAmberL   = Color(0xFFFEF3C7);
const Color spPurple   = Color(0xFF8B5CF6);
const Color spPurpleL  = Color(0xFFEDE9FE);
const Color spGray     = Color(0xFF9CA3AF);
const Color spGrayL    = Color(0xFFF1F5F9);
const Color spShadow   = Color(0x0A000000);
const Color spShadowMd = Color(0x1A000000);

BoxDecoration spCardDeco({double radius = 14, Color? border}) => BoxDecoration(
  color: spCard,
  borderRadius: BorderRadius.circular(radius),
  border: Border.all(color: border ?? spBorder),
  boxShadow: const [BoxShadow(color: spShadow, blurRadius: 6, offset: Offset(0, 2))],
);

void spSnack(BuildContext ctx, String msg, {bool error = false, bool warn = false}) {
  final color = error ? spRed : warn ? spAmber : spGreen;
  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
    content: Text(msg, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
    backgroundColor: color,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    margin: const EdgeInsets.all(16),
    duration: const Duration(seconds: 3),
  ));
}

Color spPriorityColor(String? p) {
  switch ((p ?? '').toUpperCase()) {
    case 'HIGH':     case 'CRITICAL': return spRed;
    case 'MEDIUM':                    return spAmber;
    default:                          return spBlue;
  }
}

Color spStatusColor(String? s) {
  switch ((s ?? '').toLowerCase()) {
    case 'open':        return spBlue;
    case 'in_progress': case 'in progress': case 'assigned': return spAmber;
    case 'resolved':    case 'closed':                        return spGreen;
    case 'escalated':   case 'rejected':                      return spRed;
    case 'new':         return const Color(0xFF6366F1);
    case 'reopened':    return spAccent;
    default:            return spGray;
  }
}
