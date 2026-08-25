import 'dart:io';

import 'package:flutter/material.dart';

// ==================== COLORS ====================
const kPrimary = Color(0xFFE66D33);
const kPrimaryLight = Color(0xFFFFF0E8);
const kSuccess = Color(0xFF22C55E);
const kDanger = Color(0xFFEF4444);
const kWarning = Color(0xFFF59E0B);
const kInfo = Color(0xFF3B82F6);
const kBg = Color(0xFFF8F9FA);
const kCardBg = Colors.white;
const kTextPrimary = Color(0xFF1A1A1A);
const kTextSecondary = Color(0xFF6B7280);
const kBorder = Color(0xFFE5E7EB);

// ==================== BADGES ====================

class VegBadge extends StatelessWidget {
  final bool isVeg;
  const VegBadge({super.key, required this.isVeg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isVeg
            ? kSuccess.withOpacity(0.1)
            : kDanger.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isVeg ? kSuccess.withOpacity(0.3) : kDanger.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isVeg ? kSuccess : kDanger,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            isVeg ? 'Veg' : 'Non-Veg',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isVeg ? kSuccess : kDanger,
            ),
          ),
        ],
      ),
    );
  }
}

class StockBadge extends StatelessWidget {
  final int quantity;
  const StockBadge({super.key, required this.quantity});

  @override
  Widget build(BuildContext context) {
    final isInStock = quantity > 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isInStock
            ? kSuccess.withOpacity(0.1)
            : kDanger.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$quantity',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: isInStock ? kSuccess : kDanger,
        ),
      ),
    );
  }
}

class StatusSwitch extends StatelessWidget {
  final bool isEnabled;
  final VoidCallback onToggle;
  const StatusSwitch(
      {super.key, required this.isEnabled, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Switch(
            value: isEnabled,
            onChanged: (_) => onToggle(),
            activeColor: kPrimary,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          Text(
            isEnabled ? 'On' : 'Off',
            style: TextStyle(
              fontSize: 11,
              color: isEnabled ? kPrimary : kTextSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== APP BUTTON ====================
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color? color;
  final Color? textColor;
  final IconData? icon;
  final bool outlined;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.color,
    this.textColor,
    this.icon,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = color ?? kPrimary;
    if (outlined) {
      return OutlinedButton.icon(
        onPressed: onPressed,
        icon: icon != null ? Icon(icon, size: 14) : const SizedBox.shrink(),
        label: Text(label, style: const TextStyle(fontSize: 13)),
        style: OutlinedButton.styleFrom(
          foregroundColor: bg,
          side: BorderSide(color: bg),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: icon != null ? Icon(icon, size: 14) : const SizedBox.shrink(),
      label: Text(label, style: const TextStyle(fontSize: 13)),
      style: ElevatedButton.styleFrom(
        backgroundColor: bg,
        foregroundColor: textColor ?? Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

// ==================== SEARCH BAR ====================
class SearchBarWidget extends StatelessWidget {
  final String hint;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const SearchBarWidget({
    super.key,
    required this.hint,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 13, color: kTextSecondary),
        prefixIcon: const Icon(Icons.search, color: kTextSecondary, size: 20),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.close, size: 18, color: kTextSecondary),
                onPressed: () {
                  controller.clear();
                  onChanged('');
                },
              )
            : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: kBorder)),
        enabledBorder:
            OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: kBorder)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: kPrimary, width: 1.5)),
      ),
    );
  }
}

// ==================== FILTER CHIP ====================
class FilterChipWidget extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  final VoidCallback? onClear;
  final IconData? icon;
  final Color? activeColor;

  const FilterChipWidget({
    super.key,
    required this.label,
    required this.active,
    required this.onTap,
    this.onClear,
    this.icon,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = activeColor ?? kPrimary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: active ? color.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? color : kBorder,
            width: active ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 13, color: active ? color : kTextSecondary),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: active ? color : kTextSecondary,
                fontWeight: active ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            if (active && onClear != null) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onClear,
                child: Icon(Icons.close, size: 13, color: color),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ==================== DISH IMAGE ====================
class DishImage extends StatelessWidget {
  final String? url;
  final double size;
  final File? localFile; // shows locally picked image immediately

  const DishImage({super.key, this.url, this.size = 48, this.localFile});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: localFile != null
          ? Image.file(
              localFile!,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _placeholder(),
            )
          : (url != null && url!.isNotEmpty)
              ? Image.network(
                  url!,
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _placeholder(),
                )
              : _placeholder(),
    );
  }

  Widget _placeholder() => Container(
        width: size,
        height: size,
        color: const Color(0xFFF3F4F6),
        child: Icon(Icons.restaurant, color: kBorder, size: size * 0.5),
      );
}

// ==================== SECTION HEADER ====================
class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  const SectionHeader({super.key, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Text(title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: kTextPrimary,
              )),
          const Spacer(),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

// ==================== FORM FIELD WIDGET ====================
class FormFieldWidget extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final int maxLines;
  final bool required;

  const FormFieldWidget({
    super.key,
    required this.label,
    this.hint,
    required this.controller,
    this.keyboardType,
    this.maxLines = 1,
    this.required = false,
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
                color: kTextPrimary),
            children: required
                ? const [
                    TextSpan(
                        text: ' *', style: TextStyle(color: kDanger))
                  ]
                : [],
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                const TextStyle(fontSize: 13, color: kTextSecondary),
          ),
        ),
      ],
    );
  }
}

// ==================== EMPTY STATE ====================
class EmptyStateWidget extends StatelessWidget {
  final String message;
  final IconData icon;
  final VoidCallback? onRetry;

  const EmptyStateWidget({
    super.key,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: kPrimaryLight,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: kPrimary, size: 36),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(
                  fontSize: 15,
                  color: kTextSecondary,
                  fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              AppButton(label: 'Retry', onPressed: onRetry, icon: Icons.refresh),
            ]
          ],
        ),
      ),
    );
  }
}

// ==================== ALERT DIALOG HELPER ====================
Future<void> showAppDialog(
  BuildContext context, {
  required String title,
  required String message,
  bool isSuccess = false,
  bool isWarning = false,
}) {
  return showDialog(
    context: context,
    builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      title: Row(
        children: [
          Icon(
            isSuccess
                ? Icons.check_circle_rounded
                : isWarning
                    ? Icons.warning_rounded
                    : Icons.error_rounded,
            color: isSuccess ? kSuccess : isWarning ? kWarning : kDanger,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      content: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(message,
            style: const TextStyle(fontSize: 14, color: kTextSecondary)),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child:
              const Text('OK', style: TextStyle(color: kPrimary, fontWeight: FontWeight.w700)),
        ),
      ],
    ),
  );
}

Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      content: Text(message,
          style: const TextStyle(fontSize: 14, color: kTextSecondary)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel', style: TextStyle(color: kTextSecondary)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Delete', style: TextStyle(color: kDanger, fontWeight: FontWeight.w700)),
        ),
      ],
    ),
  );
  return result ?? false;
}
