import 'package:flutter/material.dart';

// sd = subscription-demo — unique prefix
const Color sdAccent   = Color(0xFFF97316); // orange
const Color sdAccentL  = Color(0xFFFFF7ED);
const Color sdAccentD  = Color(0xFFEA6B0E);
const Color sdGreen    = Color(0xFF22C55E);
const Color sdGreenL   = Color(0xFFD1FAE5);
const Color sdGreenD   = Color(0xFF16A34A);
const Color sdGray     = Color(0xFF6B7280);
const Color sdGrayL    = Color(0xFFF9FAFB);
const Color sdBorder   = Color(0xFFE5E7EB);
const Color sdCard     = Color(0xFFFFFFFF);
const Color sdBg       = Color(0xFFF9F6F2);
const Color sdText1    = Color(0xFF111827);
const Color sdText2    = Color(0xFF374151);
const Color sdText3    = Color(0xFF9CA3AF);
const Color sdRed      = Color(0xFFEF4444);
const Color sdRedL     = Color(0xFFFEE2E2);
const Color sdShadow   = Color(0x08000000);

BoxDecoration sdCardDeco({double radius = 14, Color? border, Color? bg}) => BoxDecoration(
  color: bg ?? sdCard,
  borderRadius: BorderRadius.circular(radius),
  border: Border.all(color: border ?? sdBorder),
  boxShadow: const [BoxShadow(color: sdShadow, blurRadius: 8, offset: Offset(0, 2))],
);

void sdSnack(BuildContext ctx, String msg, {bool error = false, bool success = false}) {
  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
    content: Text(msg, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
    backgroundColor: error ? sdRed : success ? sdGreen : sdAccent,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    margin: const EdgeInsets.all(16),
  ));
}

// Capitalise each word
String sdTitleCase(String s) => s
    .toLowerCase()
    .replaceAll('_', ' ')
    .split(' ')
    .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
    .join(' ');
