import 'package:flutter/material.dart';

// ─── Design Tokens ────────────────────────────────────────────────────────────
const kPrimary = Color(0xFFE66D33);
const kPrimaryLight = Color(0xFFFFF0E8);
const kPrimaryDark = Color(0xFFB85520);
const kSuccess = Color(0xFF22C55E);
const kDanger = Color(0xFFEF4444);
const kWarning = Color(0xFFF59E0B);
const kInfo = Color(0xFF3B82F6);
const kBg = Color(0xFFF8F9FA);
const kCard = Colors.white;
const kText1 = Color(0xFF1A1A1A);
const kText2 = Color(0xFF6B7280);
const kBorder = Color(0xFFE5E7EB);

// ─── fp* Aliases ──────────────────────────────────────────────────────────────
const Color fpAccent = kPrimary;
const Color fpAccentLight = kPrimaryLight;
const Color fpRed = kDanger;
const Color fpBg = kBg;
const Color fpCard = kCard;
const Color fpBorder = kBorder;
const Color fpText1 = kText1;
const Color fpText2 = kText2;
const Color fpText3 = Color(0xFFB0B6BF);

// ─── fpCardDecoration ─────────────────────────────────────────────────────────
BoxDecoration fpCardDecoration({double radius = 16}) => BoxDecoration(
  color: kCard,
  borderRadius: BorderRadius.circular(radius),
  boxShadow: [
    BoxShadow(
      color: Colors.black.withOpacity(0.06),
      blurRadius: 10,
      offset: const Offset(0, 3),
    ),
  ],
);

// ─── SectionHeader ────────────────────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? action;
  const SectionHeader({super.key, required this.title, this.action});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 24, 0, 12),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 22,
            decoration: BoxDecoration(
              color: kPrimary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: kText1,
                letterSpacing: 0.3,
              ),
            ),
          ),
          if (action != null) action!,
        ],
      ),
    );
  }
}

// ─── FpSectionHeader ──────────────────────────────────────────────────────────
class FpSectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final Widget? action;

  const FpSectionHeader({
    super.key,
    required this.title,
    this.trailing,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final right = trailing ?? action;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 22,
            decoration: BoxDecoration(
              color: kPrimary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: kText1,
                letterSpacing: 0.3,
              ),
            ),
          ),
          if (right != null) right,
        ],
      ),
    );
  }
}

// ─── StatusBadge ──────────────────────────────────────────────────────────────
class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge({super.key, required this.status});

  Color get _color {
    switch (status.toLowerCase()) {
      case 'verified':
      case 'uploaded':
      case 'submitted':
      case 'provided':
        return kSuccess;
      case 'pending':
      case 'not uploaded':
      case 'not verified':
        return kWarning;
      case 'rejected':
        return kDanger;
      default:
        return kText2;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color.withOpacity(0.3)),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: _color,
        ),
      ),
    );
  }
}

// ─── PrimaryButton ────────────────────────────────────────────────────────────
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;
  final Color? color;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.loading = false,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? kPrimary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ),
        child: loading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 16),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// ─── SecondaryButton ──────────────────────────────────────────────────────────
class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  const SecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: kPrimary,
        side: const BorderSide(color: kPrimary),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 15), const SizedBox(width: 6)],
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

// ─── FpBtn ────────────────────────────────────────────────────────────────────
class FpBtn extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final bool loading;
  final Color? color;

  const FpBtn({
    super.key,
    required this.label,
    this.onTap,
    this.icon,
    this.loading = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final bg = color ?? kPrimary;
    final bool disabled = loading || onTap == null;
    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
        decoration: BoxDecoration(
          color: disabled ? bg.withOpacity(0.55) : bg,
          borderRadius: BorderRadius.circular(12),
          boxShadow: disabled
              ? []
              : [
                  BoxShadow(
                    color: bg.withOpacity(0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (loading)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            else ...[
              if (icon != null) ...[
                Icon(icon, color: Colors.white, size: 16),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── NetImage ─────────────────────────────────────────────────────────────────
class NetImage extends StatelessWidget {
  final String? url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? radius;
  final Widget? placeholder;

  const NetImage({
    super.key,
    this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.radius,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    Widget img = (url != null && url!.isNotEmpty)
        ? Image.network(
            url!,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (_, __, ___) => placeholder ?? _fallback(),
          )
        : (placeholder ?? _fallback());

    if (radius != null) {
      img = ClipRRect(borderRadius: radius!, child: img);
    }
    return img;
  }

  Widget _fallback() => Container(
    width: width,
    height: height,
    color: const Color(0xFFF3F4F6),
    child: const Icon(Icons.image_outlined, color: Color(0xFFD1D5DB), size: 32),
  );
}

// ─── FpNetImage ───────────────────────────────────────────────────────────────
class FpNetImage extends StatelessWidget {
  final String? url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? radius;
  final Widget? placeholder;

  const FpNetImage({
    super.key,
    this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.radius,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    final Widget fallback =
        placeholder ??
        Container(
          width: width,
          height: height,
          color: kBg,
          child: const Icon(Icons.image_outlined, color: kBorder, size: 32),
        );

    if (url == null || url!.isEmpty) return fallback;

    Widget img = Image.network(
      url!,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, __, ___) => fallback,
    );

    if (radius != null) {
      img = ClipRRect(borderRadius: radius!, child: img);
    }
    return img;
  }
}

// ─── FormTile ─────────────────────────────────────────────────────────────────
class FormTile extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final int maxLines;
  final bool required;
  final String? hint;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;

  const FormTile({
    super.key,
    required this.label,
    required this.controller,
    this.keyboardType,
    this.maxLines = 1,
    this.required = false,
    this.hint,
    this.readOnly = false,
    this.onTap,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: kText1,
            ),
            children: required
                ? const [
                    TextSpan(
                      text: ' *',
                      style: TextStyle(color: kDanger),
                    ),
                  ]
                : [],
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          readOnly: readOnly,
          onTap: onTap,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 13, color: kText2),
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: kBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: kBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: kPrimary, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── DropdownTile ─────────────────────────────────────────────────────────────
class DropdownTile extends StatelessWidget {
  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String?>? onChanged;

  const DropdownTile({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: kText1,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: options.contains(value) ? value : null,
          onChanged: onChanged,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: kBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: kBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: kPrimary, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
          items: options
              .map(
                (o) => DropdownMenuItem(
                  value: o,
                  child: Text(o, style: const TextStyle(fontSize: 13)),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

// ─── InfoRow ──────────────────────────────────────────────────────────────────
class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final String? status;
  final VoidCallback? onEdit;

  const InfoRow({
    super.key,
    required this.label,
    required this.value,
    this.status,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: kCard,
        border: Border(bottom: BorderSide(color: kBorder.withOpacity(0.5))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: kText2,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: const TextStyle(
                fontSize: 13,
                color: kText1,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (status != null) StatusBadge(status: status!),
          if (onEdit != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onEdit,
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: kPrimaryLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.edit_outlined,
                  size: 14,
                  color: kPrimary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── SheetHandle ──────────────────────────────────────────────────────────────
class SheetHandle extends StatelessWidget {
  const SheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
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
}

// ══════════════════════════════════════════════════════════════════════════════
// HELPERS
// ══════════════════════════════════════════════════════════════════════════════

// ─── showSuccess / showError ──────────────────────────────────────────────────
// Used by sections.dart, banner_section.dart, registration_screen.dart
void showSuccess(BuildContext ctx, String msg) {
  ScaffoldMessenger.of(ctx).showSnackBar(
    SnackBar(
      content: Text(msg),
      backgroundColor: kSuccess,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );
}

void showError(BuildContext ctx, String msg) {
  ScaffoldMessenger.of(ctx).showSnackBar(
    SnackBar(
      content: Text(msg),
      backgroundColor: kDanger,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );
}

// ─── fpSnack ──────────────────────────────────────────────────────────────────
void fpSnack(BuildContext context, String message, {bool error = false}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              error
                  ? Icons.error_outline_rounded
                  : Icons.check_circle_outline_rounded,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: error ? kDanger : kSuccess,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 3),
      ),
    );
}

// ─── confirmDialog ────────────────────────────────────────────────────────────
Future<bool> confirmDialog(BuildContext ctx, String title, String msg) async {
  return await showDialog<bool>(
        context: ctx,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          content: Text(msg, style: const TextStyle(color: kText2)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel', style: TextStyle(color: kText2)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text(
                'Confirm',
                style: TextStyle(color: kDanger, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ) ??
      false;
}
