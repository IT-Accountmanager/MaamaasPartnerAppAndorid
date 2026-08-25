import 'package:flutter/material.dart';

// sub = subscription module — unique prefix, no conflicts
const Color subAccent  = Color(0xFFE66D33);  // Maamaas orange
const Color subAccentL = Color(0xFFFFF0E8);
const Color subBg      = Color(0xFFF6F7FB);
const Color subCard    = Color(0xFFFFFFFF);
const Color subBorder  = Color(0xFFE2E8F0);
const Color subText1   = Color(0xFF0F172A);
const Color subText2   = Color(0xFF64748B);
const Color subText3   = Color(0xFF94A3B8);
const Color subGreen   = Color(0xFF10B981);
const Color subGreenL  = Color(0xFFD1FAE5);
const Color subRed     = Color(0xFFEF4444);
const Color subRedL    = Color(0xFFFEE2E2);
const Color subAmber   = Color(0xFFF59E0B);
const Color subAmberL  = Color(0xFFFEF3C7);
const Color subPurple  = Color(0xFF8B5CF6);
const Color subPurpleL = Color(0xFFEDE9FE);
const Color subBlue    = Color(0xFF2563EB);
const Color subBlueL   = Color(0xFFEFF6FF);
const Color subOrange  = Color(0xFFF97316);
const Color subShadow  = Color(0x0A000000);

BoxDecoration subCardDeco({double radius = 14, Color? border, Color? color}) => BoxDecoration(
  color: color ?? subCard,
  borderRadius: BorderRadius.circular(radius),
  border: Border.all(color: border ?? subBorder),
  boxShadow: const [BoxShadow(color: subShadow, blurRadius: 6, offset: Offset(0, 2))],
);

void subSnack(BuildContext ctx, String msg, {bool error = false, bool warn = false}) {
  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
    content: Text(msg, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
    backgroundColor: error ? subRed : warn ? subAmber : subGreen,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    margin: const EdgeInsets.all(16),
  ));
}

Color subStatusColor(String? s) {
  switch ((s ?? '').toUpperCase()) {
    case 'ACTIVE':  return subGreen;
    case 'TRIAL':   return subAmber;
    case 'EXPIRED': return subRed;
    case 'NONE':    return subText3;
    default:        return subText3;
  }
}
