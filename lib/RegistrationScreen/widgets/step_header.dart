import 'package:flutter/material.dart';
import 'common_widgets.dart';

class StepHeader extends StatelessWidget {
  final int currentStep;
  final ValueChanged<int>? onStepTap;

  const StepHeader({super.key, required this.currentStep, this.onStepTap});

  @override
  Widget build(BuildContext context) {
    final labels = ['Company', 'Contact', 'Documents', 'Preview'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: List.generate(labels.length * 2 - 1, (i) {
          if (i.isOdd) {
            // Connector line
            final stepBefore = i ~/ 2 + 1;
            return Expanded(
              child: Container(
                height: 2,
                color: stepBefore < currentStep ? kIndigo : kBorderColor,
              ),
            );
          }

          final stepIdx = i ~/ 2;
          final step = stepIdx + 1;
          final isActive = step <= currentStep;

          return GestureDetector(
            onTap: () => onStepTap?.call(step),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isActive ? kIndigo : kBorderColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$step',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  labels[stepIdx],
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isActive ? kIndigo : kGray,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}