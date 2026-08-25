// lib/Promotion&Marketing/CampaignProgress.dart

import 'package:flutter/material.dart';

class CampaignProgress extends StatelessWidget {
  final int currentStep;
  final List<Map<String, dynamic>> steps;
  final Function(int) onStepTap;
  final bool isDiscount;

  const CampaignProgress({
    Key? key,
    required this.currentStep,
    required this.steps,
    required this.onStepTap,
    this.isDiscount = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      color: Colors.white,
      child: Row(
        children: steps.map((step) {
          final stepNumber = step['number'] as int;
          final isActive = currentStep == stepNumber;
          final isCompleted = currentStep > stepNumber;

          // Skip step 2 for discount
          if (isDiscount && stepNumber == 2) {
            return const SizedBox();
          }

          return Expanded(
            child: GestureDetector(
              onTap: () => onStepTap(stepNumber),
              child: Column(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isActive || isCompleted
                          ? const Color(0xFF185FA5)
                          : Colors.grey[200],
                    ),
                    child: Center(
                      child: Text(
                        stepNumber.toString(),
                        style: TextStyle(
                          color: isActive || isCompleted
                              ? Colors.white
                              : Colors.grey[600],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    step['label'] as String,
                    style: TextStyle(
                      fontSize: 11,
                      color: isActive
                          ? const Color(0xFF185FA5)
                          : Colors.grey[600],
                      fontWeight: isActive
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
