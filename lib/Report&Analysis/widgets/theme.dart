import 'package:flutter/material.dart';

// ─── Design tokens — rp prefix avoids conflicts with main app ─────────────────
const Color rpAccent     = Color(0xFFE66D33);
const Color rpAccentL    = Color(0xFFFFF0E8);
const Color rpBg         = Color(0xFFF6F7FB);
const Color rpCard       = Color(0xFFFFFFFF);
const Color rpBorder     = Color(0xFFEAEBF2);
const Color rpText1      = Color(0xFF1A1A2E);
const Color rpText2      = Color(0xFF6B6B8A);
const Color rpText3      = Color(0xFFAAAAAC);
const Color rpGreen      = Color(0xFF2ECC71);
const Color rpGreenL     = Color(0xFFE8F8F0);
const Color rpBlue       = Color(0xFF3B82F6);
const Color rpBlueL      = Color(0xFFEFF6FF);
const Color rpRed        = Color(0xFFE74C3C);
const Color rpRedL       = Color(0xFFFEECEB);
const Color rpAmber      = Color(0xFFF59E0B);
const Color rpAmberL     = Color(0xFFFFFBEB);
const Color rpPurple     = Color(0xFF8B5CF6);
const Color rpPurpleL    = Color(0xFFF5F3FF);
const Color rpShadow     = Color(0x0F000000);

BoxDecoration rpCardDeco({double radius = 14, Color? border}) => BoxDecoration(
  color: rpCard,
  borderRadius: BorderRadius.circular(radius),
  border: Border.all(color: border ?? rpBorder),
  boxShadow: const [BoxShadow(color: rpShadow, blurRadius: 8, offset: Offset(0, 3))],
);

void rpSnack(BuildContext ctx, String msg, {bool error = false}) {
  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
    content: Text(msg, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
    backgroundColor: error ? rpRed : rpGreen,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    margin: const EdgeInsets.all(16),
  ));
}

// ─── Stat card ────────────────────────────────────────────────────────────────
class RpStatCard extends StatelessWidget {
  final String label;
  final String value;
  final String? sub;
  final IconData icon;
  final Color color;
  final Color colorLight;

  const RpStatCard({
    super.key,
    required this.label,
    required this.value,
    this.sub,
    required this.icon,
    required this.color,
    required this.colorLight,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: rpCardDeco(),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(color: colorLight, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 18),
        ),
        const Spacer(),
        if (sub != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: colorLight, borderRadius: BorderRadius.circular(20)),
            child: Text(sub!, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700)),
          ),
      ]),
      const SizedBox(height: 12),
      Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: rpText1, letterSpacing: -0.5)),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(fontSize: 12, color: rpText2, fontWeight: FontWeight.w500)),
    ]),
  );
}

// ─── Section header ───────────────────────────────────────────────────────────
class RpSectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  const RpSectionHeader({super.key, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(0, 4, 0, 12),
    child: Row(children: [
      Container(width: 4, height: 20, decoration: BoxDecoration(color: rpAccent, borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 10),
      Expanded(child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: rpText1))),
      if (trailing != null) trailing!,
    ]),
  );
}

// ─── Loading shimmer card ─────────────────────────────────────────────────────
class RpShimmerCard extends StatelessWidget {
  final double height;
  const RpShimmerCard({super.key, this.height = 80});

  @override
  Widget build(BuildContext context) => Container(
    height: height,
    decoration: rpCardDeco(),
    child: const Center(child: CircularProgressIndicator(color: rpAccent, strokeWidth: 2)),
  );
}

// ─── Empty state ──────────────────────────────────────────────────────────────
class RpEmpty extends StatelessWidget {
  final String message;
  final IconData icon;
  const RpEmpty({super.key, required this.message, this.icon = Icons.bar_chart_outlined});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(32),
    decoration: rpCardDeco(),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, color: rpText3, size: 48),
      const SizedBox(height: 12),
      Text(message, style: const TextStyle(color: rpText2, fontSize: 14), textAlign: TextAlign.center),
    ]),
  );
}

// ─── Data row ─────────────────────────────────────────────────────────────────
class RpDataRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;
  final Color? valueColor;

  const RpDataRow({super.key, required this.label, required this.value, this.isLast = false, this.valueColor});

  @override
  Widget build(BuildContext context) => Column(children: [
    Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(children: [
        Expanded(child: Text(label, style: const TextStyle(color: rpText2, fontSize: 13, fontWeight: FontWeight.w500))),
        Text(value, style: TextStyle(color: valueColor ?? rpText1, fontSize: 13, fontWeight: FontWeight.w700)),
      ]),
    ),
    if (!isLast) Divider(color: rpBorder, height: 1),
  ]);
}
