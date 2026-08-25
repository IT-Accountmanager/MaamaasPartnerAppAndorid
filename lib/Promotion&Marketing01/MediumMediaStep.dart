import 'package:flutter/material.dart';

import 'CampaignConstants.dart';
import 'PromotionalModel.dart';
import 'StepProgressBar.dart';

class MediumMediaStep extends StatelessWidget {
  final CampaignFormData formData;
  final ValueChanged<String> onToggleMedium;
  final ValueChanged<String> onTogglePlacement;
  final ValueChanged<String> onToggleAudience;
  final ValueChanged<String> onToggleMediaType;
  final ValueChanged<String> onToggleAppType;
  final ValueChanged<int> onDurationSelect;
  final ValueChanged<String> onCallToActionChange;
  final ValueChanged<String?> onImageUpload; // path
  final ValueChanged<String?> onVideoUpload; // path
  final ValueChanged<String> onDescriptionChange;
  final ValueChanged<String> onWebsiteUrlChange;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const MediumMediaStep({
    super.key,
    required this.formData,
    required this.onToggleMedium,
    required this.onTogglePlacement,
    required this.onToggleAudience,
    required this.onToggleMediaType,
    required this.onToggleAppType,
    required this.onDurationSelect,
    required this.onCallToActionChange,
    required this.onImageUpload,
    required this.onVideoUpload,
    required this.onDescriptionChange,
    required this.onWebsiteUrlChange,
    required this.onNext,
    required this.onBack,
  });

  bool get _canProceed {
    if (formData.mediaTypes.isEmpty) return false;
    if (formData.mediums.isEmpty) return false;
    if (formData.mediums.contains('app') && formData.audience.isEmpty)
      return false;
    return true;
  }

  List<Map<String, dynamic>> get _filteredMediums {
    return CampaignConstants.mediumOptions.where((m) {
      if (formData.goal == 'leads') return m['value'] == 'app';
      if (formData.goal == 'discount') return m['value'] == 'app';
      return true;
    }).toList();
  }

  List<Map<String, String>> get _filteredCTA {
    switch (formData.subGoal) {
      case 'more_leads':
        return CampaignConstants.callToActionOptions
            .where(
              (c) => [
                'get_quote',
                'contact_us',
                'send_message',
              ].contains(c['value']),
            )
            .toList();
      case 'whatsapp_messages':
        return CampaignConstants.callToActionOptions
            .where((c) => ['send_message', 'contact_us'].contains(c['value']))
            .toList();
      case 'website_visitors':
        return CampaignConstants.callToActionOptions
            .where(
              (c) => [
                'apply_now',
                'book_now',
                'watch_more',
                'shop_now',
              ].contains(c['value']),
            )
            .toList();
      case 'more_calls':
        return CampaignConstants.callToActionOptions
            .where((c) => ['contact_us'].contains(c['value']))
            .toList();
      default:
        return CampaignConstants.callToActionOptions;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Medium
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const FormLabel('Medium'),
              ChipGroup(
                chips: _filteredMediums
                    .map(
                      (m) => ToggleChip(
                        label: m['label'] as String,
                        isSelected: formData.mediums.contains(m['value']),
                        onTap: () => onToggleMedium(m['value'] as String),
                        icon: m['icon'] as IconData,
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),

        // App Placements
        if (formData.mediums.contains('app'))
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const FormLabel('App Placements'),
                ChipGroup(
                  chips: CampaignConstants.placementsApp.map((p) {
                    final isLeadsGoal = formData.goal == 'leads';
                    if (isLeadsGoal && p['value'] != 'adds')
                      return const SizedBox.shrink();
                    return ToggleChip(
                      label: p['label'] as String,
                      isSelected: formData.placements.contains(p['value']),
                      onTap: () => onTogglePlacement(p['value'] as String),
                      icon: p['icon'] as IconData,
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

        // Digital Duration
        if (formData.mediums.contains('digital'))
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const FormLabel('Ad Duration'),
                ChipGroup(
                  chips: CampaignConstants.durationOptions
                      .map(
                        (sec) => ToggleChip(
                          label: '$sec sec',
                          isSelected: formData.durationSeconds == sec,
                          onTap: () => onDurationSelect(sec),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),

        // Business Vertical (hide for digital)
        if (!formData.mediums.contains('digital'))
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const FormLabel('Business Vertical'),
                ChipGroup(
                  chips: CampaignConstants.appTypes
                      .map(
                        (t) => ToggleChip(
                          label: t['label']!,
                          isSelected: formData.appTypes.contains(t['value']),
                          onTap: () => onToggleAppType(t['value']!),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),

        // App Audience
        if (formData.mediums.contains('app'))
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const FormLabel('App Audience'),
                ChipGroup(
                  chips: CampaignConstants.audienceOptions
                      .map(
                        (a) => ToggleChip(
                          label: a['label'] as String,
                          isSelected: formData.audience.contains(a['value']),
                          onTap: () => onToggleAudience(a['value'] as String),
                          icon: a['icon'] as IconData,
                          activeColor: AppColors.green,
                          activeBg: AppColors.greenLight,
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),

        // Media Type
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const FormLabel('Media Type'),
              ChipGroup(
                chips: [
                  ToggleChip(
                    label: 'Image',
                    isSelected: formData.mediaTypes.contains('image'),
                    onTap: () => onToggleMediaType('image'),
                    icon: Icons.image_outlined,
                  ),
                  ToggleChip(
                    label: 'Video',
                    isSelected: formData.mediaTypes.contains('video'),
                    onTap: () => onToggleMediaType('video'),
                    icon: Icons.videocam_outlined,
                  ),
                ],
              ),
            ],
          ),
        ),

        // Upload Area
        if (formData.mediaTypes.contains('image'))
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const FormLabel('Upload Image'),
                _UploadButton(
                  label: 'Choose Image',
                  icon: Icons.image_outlined,
                  isUploaded: formData.images.isNotEmpty,
                  uploadedLabel: '${formData.images.length} image(s) uploaded',
                  onTap: () => onImageUpload(null), // trigger file picker
                ),
              ],
            ),
          ),

        if (formData.mediaTypes.contains('video'))
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const FormLabel('Upload Video'),
                _UploadButton(
                  label: 'Choose Video',
                  icon: Icons.videocam_outlined,
                  isUploaded: formData.videoFile != null,
                  uploadedLabel: 'Video uploaded',
                  onTap: () => onVideoUpload(null),
                ),
              ],
            ),
          ),

        // Media Description
        if (formData.mediaTypes.isNotEmpty)
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const FormLabel('Ad Description'),
                TextField(
                  onChanged: onDescriptionChange,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Describe your ad content or message...',
                    hintStyle: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13,
                    ),
                    contentPadding: const EdgeInsets.all(14),
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

        // Call to Action
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const FormLabel('Call to Action'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _filteredCTA
                    .map(
                      (cta) => ToggleChip(
                        label: cta['label']!,
                        isSelected: formData.callToAction == cta['value'],
                        onTap: () => onCallToActionChange(cta['value']!),
                        activeColor: AppColors.purple,
                        activeBg: AppColors.purpleLight,
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),

        // Website URL (for website_visitors)
        if (formData.subGoal == 'website_visitors')
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const FormLabel('Website URL'),
                TextField(
                  onChanged: onWebsiteUrlChange,
                  keyboardType: TextInputType.url,
                  decoration: InputDecoration(
                    hintText: 'https://yourwebsite.com',
                    hintStyle: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13,
                    ),
                    prefixIcon: const Icon(
                      Icons.language,
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

        NavButtonRow(
          onBack: onBack,
          nextLabel: 'Next: Targeting',
          nextEnabled: _canProceed,
          onNext: onNext,
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _UploadButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isUploaded;
  final String uploadedLabel;
  final VoidCallback onTap;

  const _UploadButton({
    required this.label,
    required this.icon,
    required this.isUploaded,
    required this.uploadedLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.primary),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (isUploaded) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.greenBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFBBF7D0)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle,
                  size: 14,
                  color: AppColors.green,
                ),
                const SizedBox(width: 6),
                Text(
                  uploadedLabel,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.green,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
