import 'package:flutter/material.dart';

// ─── Design tokens ─────────────────────────────────────────────────────────────
const kPrimary      = Color(0xFFE66D33);
const kPrimaryLight = Color(0xFFFFF0E8);
const kSuccess      = Color(0xFF22C55E);
const kDanger       = Color(0xFFEF4444);
const kWarning      = Color(0xFFF59E0B);
const kInfo         = Color(0xFF3B82F6);
const kNavy         = Color(0xFF1E3A8A);
const kSlate        = Color(0xFF334155);
const kBg           = Color(0xFFF8F9FA);
const kCard         = Colors.white;
const kText1        = Color(0xFF111827);
const kText2        = Color(0xFF6B7280);
const kBorder       = Color(0xFFE5E7EB);

// ─── Snackbar helpers ──────────────────────────────────────────────────────────
void showSuccess(BuildContext ctx, String msg) => _snack(ctx, msg, kSuccess);
void showError(BuildContext ctx, String msg)   => _snack(ctx, msg, kDanger);
void showWarn(BuildContext ctx, String msg)     => _snack(ctx, msg, kWarning);

void _snack(BuildContext ctx, String msg, Color bg) {
  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
    content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
    backgroundColor: bg,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    duration: const Duration(seconds: 3),
  ));
}

// ─── Card ──────────────────────────────────────────────────────────────────────
class KCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? leftBorder;
  const KCard({super.key, required this.child, this.padding, this.leftBorder});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(14),
          border: leftBorder != null
              ? Border(left: BorderSide(color: leftBorder!, width: 4))
              : Border.all(color: kBorder),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))
          ],
        ),
        child: Padding(padding: padding ?? const EdgeInsets.all(16), child: child),
      );
}

// ─── Primary button ────────────────────────────────────────────────────────────
class KBtn extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;
  final Color? color;
  const KBtn({super.key, required this.label, this.onPressed, this.loading = false, this.icon, this.color});

  @override
  Widget build(BuildContext context) => ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? kPrimary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 0,
        ),
        child: loading
            ? const SizedBox(width: 16, height: 16,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : Row(mainAxisSize: MainAxisSize.min, children: [
                if (icon != null) ...[Icon(icon, size: 15), const SizedBox(width: 5)],
                Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              ]),
      );
}

// ─── Outlined button ───────────────────────────────────────────────────────────
class KOutlineBtn extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? color;
  const KOutlineBtn({super.key, required this.label, this.onPressed, this.icon, this.color});

  @override
  Widget build(BuildContext context) => OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: color ?? kPrimary,
          side: BorderSide(color: color ?? kPrimary),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (icon != null) ...[Icon(icon, size: 15), const SizedBox(width: 5)],
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ]),
      );
}

// ─── Sheet handle ──────────────────────────────────────────────────────────────
class SheetHandle extends StatelessWidget {
  const SheetHandle({super.key});
  @override
  Widget build(BuildContext context) => Center(
        child: Container(
          width: 40, height: 4,
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(color: kBorder, borderRadius: BorderRadius.circular(2)),
        ),
      );
}

// ─── Stat Card ─────────────────────────────────────────────────────────────────
class StatCard extends StatelessWidget {
  final String title;
  final int value;
  final IconData icon;
  final Color color;
  const StatCard({super.key, required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: kBorder),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
        ),
        child: Row(children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(value.toString(),
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: kText1)),
            Text(title, style: const TextStyle(fontSize: 12, color: kText2)),
          ]),
        ]),
      );
}
