import 'package:flutter/material.dart';

const Color ctAccent   = Color(0xFFE66D33);
const Color ctAccentL  = Color(0xFFFFF0E8);
const Color ctBg       = Color(0xFFF6F7FB);
const Color ctCard     = Color(0xFFFFFFFF);
const Color ctBorder   = Color(0xFFE2E8F0);
const Color ctText1    = Color(0xFF0F172A);
const Color ctText2    = Color(0xFF64748B);
const Color ctText3    = Color(0xFF94A3B8);
const Color ctGreen    = Color(0xFF28A745);
const Color ctGreenL   = Color(0xFFD1FAE5);
const Color ctRed      = Color(0xFFDC3545);
const Color ctRedL     = Color(0xFFFEE2E2);
const Color ctAmber    = Color(0xFFFFC107);
const Color ctAmberL   = Color(0xFFFFF3CD);
const Color ctBlue     = Color(0xFF007BFF);
const Color ctBlueL    = Color(0xFFDBEAFE);
const Color ctPurple   = Color(0xFF6C757D);
const Color ctShadow   = Color(0x0A000000);

BoxDecoration ctCardDeco({double radius = 14, Color? border}) => BoxDecoration(
  color: ctCard,
  borderRadius: BorderRadius.circular(radius),
  border: Border.all(color: border ?? ctBorder),
  boxShadow: const [BoxShadow(color: ctShadow, blurRadius: 6, offset: Offset(0, 2))],
);

void ctSnack(BuildContext ctx, String msg, {bool error = false, bool warning = false}) {
  final color = error ? ctRed : warning ? ctAmber : ctGreen;
  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
    content: Text(msg, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
    backgroundColor: color,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    margin: const EdgeInsets.all(16),
    duration: const Duration(seconds: 3),
  ));
}
