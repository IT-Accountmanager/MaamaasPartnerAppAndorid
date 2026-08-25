import 'package:flutter/material.dart';

import 'CampaignConstants.dart';
import 'PromotionalModel.dart';
import 'StepProgressBar.dart';

class TargetingStep extends StatefulWidget {
  final CampaignFormData formData;
  final ValueChanged<LeadsConfig> onLeadsConfigChange;
  final ValueChanged<DiscountConfig> onDiscountConfigChange;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const TargetingStep({
    super.key,
    required this.formData,
    required this.onLeadsConfigChange,
    required this.onDiscountConfigChange,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<TargetingStep> createState() => _TargetingStepState();
}

class _TargetingStepState extends State<TargetingStep> {
  RangeValues _ageRange = const RangeValues(18, 60);

  @override
  void initState() {
    super.initState();
    final leads = widget.formData.goalConfig.leads;
    _ageRange = RangeValues(
      leads.ageRange[0].toDouble(),
      leads.ageRange[1].toDouble(),
    );
  }

  void _updateLeads({
    String? gender,
    List<String>? interests,
    String? contactMobile,
  }) {
    final current = widget.formData.goalConfig.leads;
    widget.onLeadsConfigChange(
      current.copyWith(
        gender: gender,
        interests: interests,
        contactMobile: contactMobile,
      ),
    );
  }

  void _updateDiscount({
    String? discountType,
    String? discountValue,
    String? startDate,
    String? endDate,
    String? timeCategory,
    String? startTime,
    String? endTime,
  }) {
    final current = widget.formData.goalConfig.discount;
    widget.onDiscountConfigChange(
      current.copyWith(
        discountType: discountType,
        discountValue: discountValue,
        startDate: startDate,
        endDate: endDate,
        timeCategory: timeCategory,
        startTime: startTime,
        endTime: endTime,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final goal = widget.formData.goal;
    final leads = widget.formData.goalConfig.leads;
    final discount = widget.formData.goalConfig.discount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // LEADS TARGETING
        if (goal == 'leads') ...[
          // Gender
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const FormLabel('Gender'),
                ChipGroup(
                  chips: [
                    ToggleChip(
                      label: 'All',
                      isSelected: leads.gender == '',
                      onTap: () => _updateLeads(gender: ''),
                    ),
                    ToggleChip(
                      label: 'Male',
                      isSelected: leads.gender == 'male',
                      onTap: () => _updateLeads(gender: 'male'),
                    ),
                    ToggleChip(
                      label: 'Female',
                      isSelected: leads.gender == 'female',
                      onTap: () => _updateLeads(gender: 'female'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Age Range
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FormLabel(
                  'Age Range: ${_ageRange.start.round()} - ${_ageRange.end.round()}',
                ),
                SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 4,
                    activeTrackColor: AppColors.primary,
                    inactiveTrackColor: AppColors.border,
                    thumbColor: AppColors.primary,
                    overlayColor: AppColors.primary.withOpacity(0.1),
                  ),
                  child: RangeSlider(
                    values: _ageRange,
                    min: 13,
                    max: 65,
                    divisions: 52,
                    labels: RangeLabels(
                      '${_ageRange.start.round()}',
                      '${_ageRange.end.round()}',
                    ),
                    onChanged: (v) {
                      setState(() => _ageRange = v);
                      widget.onLeadsConfigChange(
                        widget.formData.goalConfig.leads.copyWith(
                          ageRange: [v.start.round(), v.end.round()],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Interests
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const FormLabel('Audience Interests'),
                ChipGroup(
                  chips: CampaignConstants.interestOptions.map((opt) {
                    final isSelected = leads.interests.contains(opt['value']);
                    return ToggleChip(
                      label: opt['label']!,
                      isSelected: isSelected,
                      onTap: () {
                        final newInterests = List<String>.from(leads.interests);
                        if (isSelected) {
                          newInterests.remove(opt['value']);
                        } else {
                          newInterests.add(opt['value']!);
                        }
                        _updateLeads(interests: newInterests);
                      },
                      activeColor: AppColors.green,
                      activeBg: AppColors.greenBg,
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          // Contact Mobile (for more_calls / whatsapp)
          if (widget.formData.subGoal == 'more_calls' ||
              widget.formData.subGoal == 'whatsapp_messages')
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const FormLabel('Contact Mobile'),
                  TextField(
                    keyboardType: TextInputType.phone,
                    onChanged: (v) => _updateLeads(contactMobile: v),
                    decoration: InputDecoration(
                      hintText: '+91 98765 43210',
                      prefixIcon: const Icon(
                        Icons.phone,
                        size: 18,
                        color: AppColors.textSecondary,
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
        ],

        // DISCOUNT TARGETING
        if (goal == 'discount') ...[
          // Discount Type
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const FormLabel('Discount Type'),
                ChipGroup(
                  chips: [
                    ToggleChip(
                      label: '🍽️ Overall Menu',
                      isSelected: discount.discountTarget == 'overall',
                      onTap: () => _updateDiscount(discountType: 'overall'),
                      activeColor: const Color(0xFF0369a1),
                      activeBg: const Color(0xFFE0F2FE),
                    ),
                    ToggleChip(
                      label: '🎯 Specific Items',
                      isSelected: discount.discountTarget == 'specific',
                      onTap: () => _updateDiscount(discountType: 'specific'),
                      activeColor: const Color(0xFF92400e),
                      activeBg: const Color(0xFFFEF3C7),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Discount Value
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const FormLabel('Discount Value'),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        keyboardType: TextInputType.number,
                        onChanged: (v) => _updateDiscount(discountValue: v),
                        decoration: InputDecoration(
                          hintText: 'e.g. 20',
                          suffixText: discount.discountType == 'percentage'
                              ? '%'
                              : '₹',
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: AppColors.border,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: AppColors.border,
                            ),
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
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Date Range
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const FormLabel('Campaign Period'),
                Row(
                  children: [
                    Expanded(
                      child: _DatePickerField(
                        label: 'Start Date',
                        value: discount.startDate,
                        onPick: (d) => _updateDiscount(startDate: d),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _DatePickerField(
                        label: 'End Date',
                        value: discount.endDate,
                        onPick: (d) => _updateDiscount(endDate: d),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Time Category
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const FormLabel('Time Category'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _timeCategoryOptions
                      .map(
                        (opt) => ToggleChip(
                          label: opt['label']!,
                          isSelected: discount.timeCategory == opt['value'],
                          onTap: () =>
                              _updateDiscount(timeCategory: opt['value']),
                          activeColor: AppColors.green,
                          activeBg: AppColors.greenBg,
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ],

        // BRANDING TARGETING (minimal)
        if (goal == 'branding')
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const FormLabel('Campaign Period'),
                Row(
                  children: [
                    Expanded(
                      child: _DatePickerField(
                        label: 'Start Date',
                        value: widget.formData.startDate,
                        onPick: (d) {
                          // handled at parent
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _DatePickerField(
                        label: 'End Date',
                        value: widget.formData.endDate,
                        onPick: (d) {
                          // handled at parent
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

        NavButtonRow(
          onBack: widget.onBack,
          nextLabel: 'Next: Budget',
          nextEnabled: true,
          onNext: widget.onNext,
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

const _timeCategoryOptions = [
  {'value': 'PEAK_HOURS', 'label': '🔥 Peak Hours'},
  {'value': 'RAINING_TIME', 'label': '🌧️ Raining Time'},
  {'value': 'HAPPY_HOURS', 'label': '🎉 Happy Hours'},
  {'value': 'LUNCH_TIME', 'label': '🍽️ Lunch Time'},
  {'value': 'DINNER_TIME', 'label': '🌙 Dinner Time'},
  {'value': 'WEEKEND_SPECIAL', 'label': '🎊 Weekend Special'},
];

class _DatePickerField extends StatelessWidget {
  final String label;
  final String value;
  final ValueChanged<String> onPick;

  const _DatePickerField({
    required this.label,
    required this.value,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value.isNotEmpty
              ? DateTime.tryParse(value) ?? DateTime.now()
              : DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
          builder: (context, child) => Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(primary: AppColors.primary),
            ),
            child: child!,
          ),
        );
        if (picked != null) {
          onPick(
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}',
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: value.isNotEmpty ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              size: 16,
              color: value.isNotEmpty ? AppColors.primary : AppColors.textMuted,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                value.isNotEmpty ? value : label,
                style: TextStyle(
                  fontSize: 12,
                  color: value.isNotEmpty
                      ? AppColors.textPrimary
                      : AppColors.textMuted,
                  fontWeight: value.isNotEmpty
                      ? FontWeight.w600
                      : FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
