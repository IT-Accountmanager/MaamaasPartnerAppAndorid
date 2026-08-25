import 'package:flutter/material.dart';

// ─── Design tokens — fn prefix avoids conflicts with main app ─────────────────
const Color fnAccent    = Color(0xFFE66D33);
const Color fnAccentL   = Color(0xFFFFF0E8);
const Color fnBg        = Color(0xFFF6F7FB);
const Color fnCard      = Color(0xFFFFFFFF);
const Color fnBorder    = Color(0xFFE2E8F0);
const Color fnText1     = Color(0xFF0F172A);
const Color fnText2     = Color(0xFF64748B);
const Color fnText3     = Color(0xFF94A3B8);
const Color fnGreen     = Color(0xFF10B981);
const Color fnGreenL    = Color(0xFFD1FAE5);
const Color fnGreenDk   = Color(0xFF059669);
const Color fnRed       = Color(0xFFDC2626);
const Color fnRedL      = Color(0xFFFEE2E2);
const Color fnAmber     = Color(0xFFF6F7FB);
const Color fnAmberL    = Color(0xFFFFF3E0);
const Color fnBlue      = Color(0xFF3B82F6);
const Color fnBlueL     = Color(0xFFDBEAFE);
const Color fnPurple    = Color(0xFF8B5CF6);
const Color fnPurpleL   = Color(0xFFEDE9FE);
const Color fnShadow    = Color(0x0A000000);

BoxDecoration fnCardDeco({double radius = 14, Color? borderColor}) => BoxDecoration(
  color: fnCard,
  borderRadius: BorderRadius.circular(radius),
  border: Border.all(color: borderColor ?? fnBorder),
  boxShadow: const [BoxShadow(color: fnShadow, blurRadius: 6, offset: Offset(0, 2))],
);

void fnSnack(BuildContext ctx, String msg, {bool error = false}) {
  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
    content: Text(msg, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
    backgroundColor: error ? fnRed : fnGreen,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    margin: const EdgeInsets.all(16),
  ));
}

// ─── Gradient Net Amount banner ───────────────────────────────────────────────
class FnNetBanner extends StatelessWidget {
  final String label;
  final String amount;
  final bool isLoading;
  const FnNetBanner({super.key, required this.label, required this.amount, this.isLoading = false});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
    decoration: BoxDecoration(
      gradient: const LinearGradient(colors: [fnAccent, Color(0xFFD45A2A)], begin: Alignment.topLeft, end: Alignment.bottomRight),
      borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: fnAccent.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
    ),
    child: isLoading
        ? const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)))
        : Column(children: [
            Text(label, style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            Text(amount, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
          ]),
  );
}

// ─── Filter chip row ──────────────────────────────────────────────────────────
class FnFilterBar extends StatelessWidget {
  final String selected;
  final List<String> options;
  final ValueChanged<String> onSelect;
  const FnFilterBar({super.key, required this.selected, required this.options, required this.onSelect});

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: options.map((o) {
        final active = o == selected;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () => onSelect(o),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: active ? fnAccent : fnCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: active ? fnAccent : fnBorder),
              ),
              child: Text(o, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: active ? Colors.white : fnText2)),
            ),
          ),
        );
      }).toList(),
    ),
  );
}

// ─── Empty state ──────────────────────────────────────────────────────────────
class FnEmpty extends StatelessWidget {
  final String message;
  const FnEmpty({super.key, required this.message});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(40),
    decoration: fnCardDeco(),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.inbox_outlined, color: fnText3, size: 48),
      const SizedBox(height: 12),
      Text(message, style: const TextStyle(color: fnText2, fontSize: 14), textAlign: TextAlign.center),
    ]),
  );
}

// ─── Section header ───────────────────────────────────────────────────────────
class FnSectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  const FnSectionHeader({super.key, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(0, 16, 0, 10),
    child: Row(children: [
      Container(width: 4, height: 20, decoration: BoxDecoration(color: fnAccent, borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 8),
      Expanded(child: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: fnText1))),
      if (trailing != null) trailing!,
    ]),
  );
}
