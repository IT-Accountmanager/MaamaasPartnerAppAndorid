import 'package:flutter/material.dart';

// ─── Design tokens — all prefixed with FP to avoid conflicts ──────────────────
const Color fpAccent      = Color(0xFFE66D33);
const Color fpAccentLight = Color(0xFFFFF0E8);
const Color fpBg          = Color(0xFFF6F7FB);
const Color fpCard        = Color(0xFFFFFFFF);
const Color fpBorder      = Color(0xFFEAEBF2);
const Color fpText1       = Color(0xFF1A1A2E);
const Color fpText2       = Color(0xFF6B6B8A);
const Color fpText3       = Color(0xFFAAAAAC);
const Color fpGreen       = Color(0xFF2ECC71);
const Color fpGreenLight  = Color(0xFFE8F8F0);
const Color fpRed         = Color(0xFFE74C3C);
const Color fpRedLight    = Color(0xFFFEECEB);
const Color fpShadow      = Color(0x0F000000);

BoxDecoration fpCardDecoration({double radius = 16}) => BoxDecoration(
  color: fpCard,
  borderRadius: BorderRadius.circular(radius),
  border: Border.all(color: fpBorder),
  boxShadow: const [BoxShadow(color: fpShadow, blurRadius: 8, offset: Offset(0, 3))],
);

void fpSnack(BuildContext context, String msg, {bool error = false}) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(msg, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
    backgroundColor: error ? fpRed : fpGreen,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    margin: const EdgeInsets.all(16),
  ));
}

class FpBtn extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final bool loading;
  final Color? bg;

  const FpBtn({
    super.key,
    required this.label,
    this.onTap,
    this.icon,
    this.loading = false,
    this.bg,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null && !loading;
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
        decoration: BoxDecoration(
          color: disabled ? fpText3 : (bg ?? fpAccent),
          borderRadius: BorderRadius.circular(12),
          boxShadow: disabled
              ? []
              : [BoxShadow(color: (bg ?? fpAccent).withOpacity(0.35), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: loading
            ? const SizedBox(
                width: 18, height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[Icon(icon, color: Colors.white, size: 16), const SizedBox(width: 7)],
                  Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                ],
              ),
      ),
    );
  }
}

class FpSectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  const FpSectionHeader({super.key, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
        child: Row(
          children: [
            Container(
              width: 4, height: 22,
              decoration: BoxDecoration(color: fpAccent, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: fpText1, letterSpacing: -0.3)),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      );
}

class FpNetImage extends StatelessWidget {
  final String url;
  final double? width, height;
  final BoxFit fit;
  final BorderRadius? radius;

  const FpNetImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.radius, required Container placeholder,
  });

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return Container(
        width: width, height: height,
        decoration: BoxDecoration(color: fpBg, borderRadius: radius),
        child: const Center(child: Icon(Icons.image_outlined, color: fpText3, size: 32)),
      );
    }
    return ClipRRect(
      borderRadius: radius ?? BorderRadius.zero,
      child: Image.network(
        url, width: width, height: height, fit: fit,
        errorBuilder: (_, __, ___) => Container(
          width: width, height: height, color: fpBg,
          child: const Center(child: Icon(Icons.broken_image_outlined, color: fpText3, size: 28)),
        ),
        loadingBuilder: (_, child, prog) => prog == null
            ? child
            : Container(
                width: width, height: height, color: fpBg,
                child: const Center(child: CircularProgressIndicator(color: fpAccent, strokeWidth: 2)),
              ),
      ),
    );
  }
}
