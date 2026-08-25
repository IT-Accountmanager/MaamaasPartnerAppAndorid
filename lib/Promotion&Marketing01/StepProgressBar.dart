import 'package:flutter/material.dart';

// ─── COLOR PALETTE ──────────────────────────────────────────────
class AppColors {
  static const primary = Color(0xFF185FA5);
  static const primaryLight = Color(0xFFEFF6FF);
  static const primaryText = Color(0xFF185FA5);
  static const green = Color(0xFF3B6D11);
  static const greenLight = Color(0xFFEAF3DE);
  static const greenBg = Color(0xFFF0FDF4);
  static const amber = Color(0xFF854F0B);
  static const amberLight = Color(0xFFFAEEDA);
  static const purple = Color(0xFF533AB7);
  static const purpleLight = Color(0xFFEDE9FF);
  static const border = Color(0xFFE5E7EB);
  static const textPrimary = Color(0xFF111827);
  static const textSecondary = Color(0xFF6B7280);
  static const textMuted = Color(0xFF9CA3AF);
  static const bgGray = Color(0xFFF9FAFB);
  static const bgLight = Color(0xFFF1F5F9);
  static const success = Color(0xFF16a34a);
  static const blue = Color(0xFF2563eb);
}

// ─── STEP PROGRESS BAR ──────────────────────────────────────────
class StepProgressBar extends StatelessWidget {
  final int currentStep;
  final List<Map<String, dynamic>> steps;
  final ValueChanged<int>? onStepTap;

  const StepProgressBar({
    super.key,
    required this.currentStep,
    required this.steps,
    this.onStepTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: List.generate(steps.length, (i) {
          final step = steps[i];
          final num = step['number'] as int;
          final label = step['label'] as String;
          final isCompleted = num < currentStep;
          final isActive = num == currentStep;
          final isLast = i == steps.length - 1;

          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => onStepTap?.call(num),
                    child: Column(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isCompleted
                                ? AppColors.success
                                : isActive
                                ? AppColors.primary
                                : AppColors.bgLight,
                            border: Border.all(
                              color: isActive
                                  ? AppColors.primary
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: isCompleted
                                ? const Icon(
                                    Icons.check,
                                    size: 14,
                                    color: Colors.white,
                                  )
                                : Text(
                                    '$num',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: isActive
                                          ? Colors.white
                                          : AppColors.textMuted,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isActive
                                ? FontWeight.w700
                                : FontWeight.w400,
                            color: isActive
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
                if (!isLast)
                  Container(
                    height: 2,
                    width: 16,
                    color: isCompleted ? AppColors.success : AppColors.border,
                    margin: const EdgeInsets.only(bottom: 18),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// ─── SECTION CARD ───────────────────────────────────────────────
class SectionCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;

  const SectionCard({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ─── FORM LABEL ─────────────────────────────────────────────────
class FormLabel extends StatelessWidget {
  final String text;
  const FormLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

// ─── TOGGLE CHIP BUTTON ─────────────────────────────────────────
class ToggleChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;
  final Color? activeColor;
  final Color? activeBg;

  const ToggleChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
    this.activeColor,
    this.activeBg,
  });

  @override
  Widget build(BuildContext context) {
    final ac = activeColor ?? AppColors.primary;
    final abg = activeBg ?? AppColors.primaryLight;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? abg : AppColors.bgGray,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? ac : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 15,
                color: isSelected ? ac : AppColors.textSecondary,
              ),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? ac : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── CHIP GROUP (wrapping row of toggles) ───────────────────────
class ChipGroup extends StatelessWidget {
  final List<Widget> chips;

  const ChipGroup({super.key, required this.chips});

  @override
  Widget build(BuildContext context) {
    return Wrap(spacing: 8, runSpacing: 8, children: chips);
  }
}

// ─── GOAL CARD ──────────────────────────────────────────────────
class GoalCard extends StatelessWidget {
  final String value;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData icon;
  final Color color;
  final Color bgColor;

  const GoalCard({
    super.key,
    required this.value,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.icon,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? bgColor : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? color : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isSelected ? color.withOpacity(0.15) : AppColors.bgLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 20,
                color: isSelected ? color : AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: isSelected ? color : AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? color : AppColors.textMuted,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── SUBGOAL CARD ───────────────────────────────────────────────
class SubGoalCard extends StatelessWidget {
  final String value;
  final String label;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;

  const SubGoalCard({
    super.key,
    required this.value,
    required this.label,
    required this.description,
    required this.isSelected,
    required this.onTap,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 20, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle : Icons.radio_button_off,
              color: isSelected ? AppColors.primary : AppColors.textMuted,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── BADGE PILL ─────────────────────────────────────────────────
class BadgePill extends StatelessWidget {
  final String text;
  final Color color;
  final Color bgColor;

  const BadgePill({
    super.key,
    required this.text,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

// ─── NAV BUTTON ROW ─────────────────────────────────────────────
class NavButtonRow extends StatelessWidget {
  final String backLabel;
  final String nextLabel;
  final VoidCallback? onBack;
  final VoidCallback? onNext;
  final bool nextEnabled;
  final bool isLastStep;

  const NavButtonRow({
    super.key,
    this.backLabel = 'Back',
    this.nextLabel = 'Next',
    this.onBack,
    this.onNext,
    this.nextEnabled = true,
    this.isLastStep = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          if (onBack != null) ...[
            OutlinedButton.icon(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_ios, size: 14),
              label: Text(backLabel),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                side: const BorderSide(color: AppColors.border),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: ElevatedButton.icon(
              onPressed: nextEnabled ? onNext : null,
              icon: Icon(
                isLastStep ? Icons.payment : Icons.arrow_forward_ios,
                size: 14,
              ),
              label: Text(nextLabel),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.border,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── INFO ROW (label + badge) ───────────────────────────────────
class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final Color valueBg;

  const InfoRow({
    super.key,
    required this.label,
    required this.value,
    this.valueColor = AppColors.primaryText,
    this.valueBg = AppColors.primaryLight,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: valueBg,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: valueColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
