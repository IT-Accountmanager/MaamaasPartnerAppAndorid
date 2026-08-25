// lib/Promotion&Marketing/TargetingConfigWidget.dart

import 'package:flutter/material.dart';
import 'Models.dart';

class TargetingConfigWidget extends StatelessWidget {
  final CampaignData formData;
  final GoalConfig goalConfig;
  final Function(String, String, dynamic) onGoalConfigChange;
  final VoidCallback onNext;
  final VoidCallback onBack;
  final List<MenuItem> menuItems;

  const TargetingConfigWidget({
    Key? key,
    required this.formData,
    required this.goalConfig,
    required this.onGoalConfigChange,
    required this.onNext,
    required this.onBack,
    required this.menuItems,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final interestOptions = [
      {'value': 'food', 'label': 'Food Lovers', 'icon': Icons.restaurant},
      {'value': 'veg', 'label': 'Veg Lovers', 'icon': Icons.eco},
      {'value': 'students', 'label': 'Students', 'icon': Icons.school},
      {'value': 'families', 'label': 'Families', 'icon': Icons.family_restroom},
      {
        'value': 'office',
        'label': 'Office Crowd',
        'icon': Icons.business_center,
      },
    ];

    final genderOptions = ['Male', 'Female', 'All'];

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Targeting Configuration',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Interests
            const Text(
              'Interests',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: interestOptions.map((interest) {
                final isSelected = (goalConfig.leads?.interests ?? []).contains(
                  interest['value'] as String,
                );
                return FilterChip(
                  label: Text(interest['label'] as String),
                  selected: isSelected,
                  onSelected: (selected) {
                    final currentInterests = List<String>.from(
                      goalConfig.leads?.interests ?? [],
                    );
                    final updatedInterests = selected
                        ? [...currentInterests, interest['value'] as String]
                        : currentInterests
                              .where((i) => i != interest['value'])
                              .toList();
                    onGoalConfigChange('leads', 'interests', updatedInterests);
                  },
                  selectedColor: const Color(0xFF185FA5),
                  backgroundColor: Colors.grey[100],
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // Gender
            const Text(
              'Gender',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: genderOptions.map((gender) {
                final isSelected =
                    goalConfig.leads?.gender?.toLowerCase() ==
                    gender.toLowerCase();
                return ChoiceChip(
                  label: Text(gender),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      onGoalConfigChange('leads', 'gender', gender);
                    }
                  },
                  selectedColor: const Color(0xFF185FA5),
                  backgroundColor: Colors.grey[100],
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // Age Range
            const Text(
              'Age Range',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildAgeDropdown(
                    'Min',
                    0,
                    goalConfig.leads?.ageRange?[0] ?? 18,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildAgeDropdown(
                    'Max',
                    1,
                    goalConfig.leads?.ageRange?[1] ?? 60,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Navigation Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onBack,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Back'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF185FA5),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Next'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgeDropdown(String label, int index, int currentValue) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13)),
        const SizedBox(height: 4),
        DropdownButtonFormField<int>(
          value: currentValue,
          items: List.generate(100, (i) => i + 1).map((age) {
            return DropdownMenuItem(value: age, child: Text(age.toString()));
          }).toList(),
          onChanged: (value) {
            final currentRange = List<int>.from(
              goalConfig.leads?.ageRange ?? [18, 60],
            );
            currentRange[index] = value ?? 18;
            onGoalConfigChange('leads', 'ageRange', currentRange);
          },
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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
