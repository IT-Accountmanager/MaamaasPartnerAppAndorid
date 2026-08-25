import 'package:flutter/material.dart';

const kPrimary = Color(0xFFE66D33);
const kPrimaryLight = Color(0xFFFFF0E8);
const kSuccess = Color(0xFF22C55E);
const kDanger = Color(0xFFEF4444);
const kWarning = Color(0xFFF59E0B);
const kInfo = Color(0xFF22C55E);
const kBg = Color(0xFFF8F9FA);
const kText1 = Color(0xFF1A1A1A);
const kText2 = Color(0xFF6B7280);
const kBorder = Color(0xFFE5E7EB);

void showSuccess(BuildContext ctx, String msg) => _snack(ctx, msg, kSuccess);
void showError(BuildContext ctx, String msg) => _snack(ctx, msg, kDanger);
void showWarning(BuildContext ctx, String msg) => _snack(ctx, msg, kWarning);

void _snack(BuildContext ctx, String msg, Color bg) {
  ScaffoldMessenger.of(ctx).showSnackBar(
    SnackBar(
      content: Text(
        msg,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      backgroundColor: bg,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      duration: const Duration(seconds: 3),
    ),
  );
}

class KCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? leftBorderColor;
  const KCard({
    super.key,
    required this.child,
    this.padding,
    this.leftBorderColor,
  });

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: leftBorderColor != null
          ? Border(left: BorderSide(color: leftBorderColor!, width: 4))
          : Border.all(color: kBorder),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Padding(padding: padding ?? const EdgeInsets.all(16), child: child),
  );
}

class KSectionTitle extends StatelessWidget {
  final String title;
  final Color dotColor;
  const KSectionTitle(this.title, {super.key, this.dotColor = kPrimary});
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(shape: BoxShape.circle, color: dotColor),
      ),
      const SizedBox(width: 8),
      Flexible(
        // ← add this
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: kText1,
          ),
        ),
      ),
    ],
  );
}

class KBtn extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;
  final Color? color;
  const KBtn({
    super.key,
    required this.label,
    this.onPressed,
    this.loading = false,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) => ElevatedButton(
    onPressed: loading ? null : onPressed,
    style: ElevatedButton.styleFrom(
      backgroundColor: color ?? kPrimary,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 0,
    ),
    child: loading
        ? const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 14),
                const SizedBox(width: 5),
              ],
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
  );
}

class KOutlineBtn extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  const KOutlineBtn({super.key, required this.label, this.onPressed});
  @override
  Widget build(BuildContext context) => OutlinedButton(
    onPressed: onPressed,
    style: OutlinedButton.styleFrom(
      foregroundColor: kText2,
      side: const BorderSide(color: kBorder),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
    child: Text(
      label,
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
    ),
  );
}

class SheetHandle extends StatelessWidget {
  const SheetHandle({super.key});
  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      width: 40,
      height: 4,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: kBorder,
        borderRadius: BorderRadius.circular(2),
      ),
    ),
  );
}
