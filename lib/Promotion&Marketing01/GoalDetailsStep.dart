import 'package:flutter/material.dart';

import 'CampaignConstants.dart';
import 'PromotionalModel.dart';
import 'StepProgressBar.dart';


class GoalDetailsStep extends StatelessWidget {
  final CampaignFormData formData;
  final ValueChanged<String> onGoalChange;
  final ValueChanged<String> onSubGoalChange;
  final ValueChanged<String> onNameChange;
  final VoidCallback onNext;

  const GoalDetailsStep({
    super.key,
    required this.formData,
    required this.onGoalChange,
    required this.onSubGoalChange,
    required this.onNameChange,
    required this.onNext,
  });

  bool get _canProceed {
    if (formData.goal == 'discount') return formData.goal.isNotEmpty;
    return formData.goal.isNotEmpty && formData.subGoal.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final subGoalsList = CampaignConstants.subGoals[formData.goal] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Campaign Name
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const FormLabel('Campaign Name'),
              TextField(
                onChanged: onNameChange,
                controller: TextEditingController(text: formData.name)
                  ..selection = TextSelection.fromPosition(
                    TextPosition(offset: formData.name.length),
                  ),
                decoration: InputDecoration(
                  hintText: 'e.g. Summer Sale Campaign',
                  hintStyle: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Goal Selection
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const FormLabel('Campaign Goal'),
              const SizedBox(height: 4),
              GoalCard(
                value: 'leads',
                label: 'Leads',
                isSelected: formData.goal == 'leads',
                onTap: () => onGoalChange('leads'),
                icon: Icons.contact_page_outlined,
                color: AppColors.primary,
                bgColor: AppColors.primaryLight,
              ),
              const SizedBox(height: 10),
              GoalCard(
                value: 'branding',
                label: 'Branding',
                isSelected: formData.goal == 'branding',
                onTap: () => onGoalChange('branding'),
                icon: Icons.campaign_outlined,
                color: AppColors.green,
                bgColor: AppColors.greenLight,
              ),
              const SizedBox(height: 10),
              GoalCard(
                value: 'discount',
                label: 'Discount',
                isSelected: formData.goal == 'discount',
                onTap: () => onGoalChange('discount'),
                icon: Icons.local_offer_outlined,
                color: AppColors.amber,
                bgColor: AppColors.amberLight,
              ),
            ],
          ),
        ),

        // Sub Goal
        if (formData.goal.isNotEmpty && subGoalsList.isNotEmpty)
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const FormLabel('Sub Goal'),
                const SizedBox(height: 4),
                ...subGoalsList.map(
                  (sg) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: SubGoalCard(
                      value: sg.value,
                      label: sg.label,
                      description: sg.description,
                      isSelected: formData.subGoal == sg.value,
                      onTap: () => onSubGoalChange(sg.value),
                      icon: sg.icon,
                      iconColor: sg.iconColor,
                      iconBg: sg.iconBg,
                    ),
                  ),
                ),
              ],
            ),
          ),

        NavButtonRow(
          nextLabel: 'Next: Medium & Media',
          nextEnabled: _canProceed,
          onNext: onNext,
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
