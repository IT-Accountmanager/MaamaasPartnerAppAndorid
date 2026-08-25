import 'package:flutter/material.dart';

const Color mlAccent  = Color(0xFFE66D33);
const Color mlAccentL = Color(0xFFFFF0E8);
const Color mlBg      = Color(0xFFF6F7FB);
const Color mlCard    = Color(0xFFFFFFFF);
const Color mlBorder  = Color(0xFFE2E8F0);
const Color mlText1   = Color(0xFF0F172A);
const Color mlText2   = Color(0xFF64748B);
const Color mlText3   = Color(0xFF94A3B8);

void mlSnack(BuildContext ctx, String msg, {bool error = false}) {
  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
    content: Text(msg, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
    backgroundColor: error ? const Color(0xFFDC2626) : const Color(0xFF10B981),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    margin: const EdgeInsets.all(16),
  ));
}
