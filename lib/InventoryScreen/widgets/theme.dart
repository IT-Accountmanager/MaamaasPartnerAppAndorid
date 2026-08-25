import 'package:flutter/material.dart';

// inv = inventory module — unique prefix
const Color invAccent  = Color(0xFFE66D33);
const Color invAccentL = Color(0xFFFFF0E8);
const Color invBg      = Color(0xFFF6F7FB);
const Color invCard    = Color(0xFFFFFFFF);
const Color invBorder  = Color(0xFFE2E8F0);
const Color invText1   = Color(0xFF111827);
const Color invText2   = Color(0xFF6B7280);
const Color invText3   = Color(0xFF9CA3AF);
const Color invGreen   = Color(0xFF16A34A);
const Color invGreenL  = Color(0xFFD4EDDA);
const Color invAmber   = Color(0xFF856404);
const Color invAmberL  = Color(0xFFFFF3CD);
const Color invRed     = Color(0xFF721C24);
const Color invRedL    = Color(0xFFF8D7DA);
const Color invBlue    = Color(0xFF004085);
const Color invBlueL   = Color(0xFFCCE5FF);
const Color invOrange  = Color(0xFFE66D33);
const Color invShadow  = Color(0x0A000000);

BoxDecoration invCardDeco({double radius = 12, Color? border, Color? color}) => BoxDecoration(
  color: color ?? invCard,
  borderRadius: BorderRadius.circular(radius),
  border: Border.all(color: border ?? invBorder),
  boxShadow: const [BoxShadow(color: invShadow, blurRadius: 6, offset: Offset(0, 2))],
);

void invSnack(BuildContext ctx, String msg, {bool error = false, bool warn = false}) {
  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
    content: Text(msg, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
    backgroundColor: error ? const Color(0xFFDC3545) : warn ? const Color(0xFFF59E0B) : const Color(0xFF28A745),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    margin: const EdgeInsets.all(16),
  ));
}

Widget invStatusBadge(String status) {
  Color bg; Color fg;
  switch (status.toLowerCase()) {
    case 'in stock':   bg = invGreenL;  fg = invGreen;  break;
    case 'low stock':  bg = invAmberL;  fg = invAmber;  break;
    case 'out of stock': bg = invRedL;  fg = invRed;    break;
    case 'completed':  bg = invGreenL;  fg = invGreen;  break;
    case 'ordered':    bg = invBlueL;   fg = invBlue;   break;
    case 'pending':    bg = invAmberL;  fg = invAmber;  break;
    case 'delivered':  bg = invGreenL;  fg = invGreen;  break;
    default:           bg = invAmberL;  fg = invAmber;  break;
  }
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
    child: Text(status, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: fg)),
  );
}

Widget invSectionLabel(String t) => Padding(
  padding: const EdgeInsets.only(bottom: 6),
  child: Text(t, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: invText1)),
);

InputDecoration invInputDeco(String hint, {String? label, Widget? suffix}) => InputDecoration(
  labelText: label,
  hintText: hint,
  hintStyle: const TextStyle(color: invText3, fontSize: 13),
  labelStyle: const TextStyle(color: invText2, fontSize: 13),
  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: invBorder)),
  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: invBorder)),
  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: invAccent, width: 1.5)),
  filled: true, fillColor: invBg, isDense: true,
  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
  suffixIcon: suffix,
);
