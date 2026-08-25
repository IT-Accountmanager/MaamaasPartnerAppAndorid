// lib/Promotion&Marketing/GoalDetailsWidget.dart

import 'package:flutter/material.dart';
import 'Models.dart';

class GoalDetailsWidget extends StatelessWidget {
  final CampaignData formData;
  final List<Map<String, String>> goals;
  final Map<String, List<Map<String, dynamic>>> subGoals;
  final Function(String, dynamic) onInputChange;
  final Function(String, String, dynamic) onGoalConfigChange;
  final VoidCallback onNext;
  final List<MenuItem> menuItems;

  const GoalDetailsWidget({
    Key? key,
    required this.formData,
    required this.goals,
    required this.subGoals,
    required this.onInputChange,
    required this.onGoalConfigChange,
    required this.onNext,
    required this.menuItems,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Campaign Name
            const Text(
              'Campaign Name',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(
                hintText: 'Enter campaign name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
              onChanged: (value) => onInputChange('name', value),
            ),
            const SizedBox(height: 20),

            // Goal Selection
            const Text(
              'Goal',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              children: goals.map((goal) {
                final isSelected = formData.goal == goal['value'];
                return ChoiceChip(
                  label: Text(goal['label']!),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      onInputChange('goal', goal['value']);
                      onInputChange('subGoal', null);
                    }
                  },
                  selectedColor: const Color(0xFF185FA5),
                  backgroundColor: Colors.grey[100],
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                );
              }).toList(),
            ),

            // Sub Goal Selection (for non-discount)
            if (formData.goal != null && formData.goal != 'discount') ...[
              const SizedBox(height: 20),
              const Text(
                'Sub Goal',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              ..._buildSubGoals(),
            ],

            const SizedBox(height: 30),

            // Next Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF185FA5),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Next', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSubGoals() {
    final subs = subGoals[formData.goal] ?? [];
    return subs.map((sub) {
      final isSelected = formData.subGoal == sub['value'];
      return Card(
        margin: const EdgeInsets.only(bottom: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: isSelected ? const Color(0xFF185FA5) : Colors.transparent,
            width: 2,
          ),
        ),
        child: InkWell(
          onTap: () => onInputChange('subGoal', sub['value']),
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    sub['icon'] as IconData?,
                    size: 22,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sub['label'] as String,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      if (sub['description'] != null &&
                          sub['description'].toString().isNotEmpty)
                        Text(
                          sub['description'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_circle,
                    color: Color(0xFF185FA5),
                    size: 24,
                  ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }
}
