// lib/Promotion&Marketing/MediumMediaWidget.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'Models.dart';

class MediumMediaWidget extends StatelessWidget {
  final CampaignData formData;
  final List<Map<String, String>> goals;
  final Map<String, List<Map<String, dynamic>>> subGoals;
  final Function(String, dynamic) onInputChange;
  final Function(String, String) onMultiSelect;
  final VoidCallback onImageUpload;
  final VoidCallback onVideoUpload;
  final VoidCallback onNext;
  final VoidCallback onBack;
  final List<Screen> screensData;
  final Map<String, List<Map<String, dynamic>>> placementsByMedium;

  const MediumMediaWidget({
    Key? key,
    required this.formData,
    required this.goals,
    required this.subGoals,
    required this.onInputChange,
    required this.onMultiSelect,
    required this.onImageUpload,
    required this.onVideoUpload,
    required this.onNext,
    required this.onBack,
    required this.screensData,
    required this.placementsByMedium,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mediumOptions = [
      {'value': 'app', 'label': 'App', 'icon': Icons.phone_android},
      {'value': 'digital', 'label': 'Digital', 'icon': Icons.public},
    ];

    final mediaTypeOptions = [
      {'value': 'image', 'label': 'Image', 'icon': Icons.image},
      {'value': 'video', 'label': 'Video', 'icon': Icons.videocam},
    ];

    final audienceOptions = [
      {'value': 'users', 'label': 'Users', 'icon': Icons.people},
      {'value': 'vendors', 'label': 'Vendors', 'icon': Icons.business},
      {'value': 'movers', 'label': 'Movers', 'icon': Icons.local_shipping},
    ];

    final appTypes = [
      {'value': 'FOOD_AND_BEVERAGES', 'label': 'Food & Beverages'},
      {'value': 'CATERINGS_SERVICES', 'label': 'Catering Services'},
    ];

    final callToActionOptions = [
      {'value': 'apply_now', 'label': 'Apply now'},
      {'value': 'book_now', 'label': 'Book now'},
      {'value': 'contact_us', 'label': 'Contact us'},
      {'value': 'shop_now', 'label': 'Shop now'},
      {'value': 'get_quote', 'label': 'Get quote'},
      {'value': 'order_now', 'label': 'Order Now'},
    ];

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Medium Selection
            const Text(
              'Medium',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              children: mediumOptions.map((option) {
                final isSelected = formData.mediums.contains(
                  option['value'] as String,
                );
                return FilterChip(
                  label: Text(option['label'] as String),
                  selected: isSelected,
                  onSelected: (selected) =>
                      onMultiSelect('mediums', option['value'] as String),
                  selectedColor: const Color(0xFF185FA5),
                  backgroundColor: Colors.grey[100],
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                );
              }).toList(),
            ),

            // Placements for each medium
            ...formData.mediums.map(
              (medium) => _buildPlacementsSection(medium),
            ),

            // App Types (hide for digital)
            if (!formData.mediums.contains('digital')) ...[
              const SizedBox(height: 20),
              const Text(
                'Business Vertical',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                children: appTypes.map((type) {
                  final isSelected = formData.appTypes.contains(
                    type['value'] as String,
                  );
                  return FilterChip(
                    label: Text(type['label'] as String),
                    selected: isSelected,
                    onSelected: (selected) =>
                        onMultiSelect('appTypes', type['value'] as String),
                    selectedColor: const Color(0xFF185FA5),
                    backgroundColor: Colors.grey[100],
                  );
                }).toList(),
              ),
            ],

            // App Audience
            if (formData.mediums.contains('app')) ...[
              const SizedBox(height: 20),
              const Text(
                'App Audience',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                children: audienceOptions.map((option) {
                  final isSelected = formData.audience.contains(
                    option['value'] as String,
                  );
                  return FilterChip(
                    label: Text(option['label'] as String),
                    selected: isSelected,
                    onSelected: (selected) =>
                        onMultiSelect('audience', option['value'] as String),
                    selectedColor: const Color(0xFF185FA5),
                    backgroundColor: Colors.grey[100],
                  );
                }).toList(),
              ),
            ],

            // Media Type
            const SizedBox(height: 20),
            const Text(
              'Media Type',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              children: mediaTypeOptions.map((option) {
                final isSelected = formData.mediaTypes.contains(
                  option['value'] as String,
                );
                return FilterChip(
                  label: Text(option['label'] as String),
                  selected: isSelected,
                  onSelected: (selected) =>
                      onMultiSelect('mediaTypes', option['value'] as String),
                  selectedColor: const Color(0xFF185FA5),
                  backgroundColor: Colors.grey[100],
                );
              }).toList(),
            ),

            // Media Upload based on selected type
            if (formData.mediaTypes.contains('image')) ...[
              const SizedBox(height: 16),
              _buildImageUploadSection(),
            ],
            if (formData.mediaTypes.contains('video')) ...[
              const SizedBox(height: 16),
              _buildVideoUploadSection(),
            ],

            // Call to Action
            if (formData.mediums.contains('app') &&
                formData.goal != 'discount') ...[
              const SizedBox(height: 20),
              const Text(
                'Call to Action',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: formData.callToAction,
                hint: const Text('Select call to action'),
                items: callToActionOptions.map((option) {
                  return DropdownMenuItem(
                    value: option['value'] as String,
                    child: Text(option['label'] as String),
                  );
                }).toList(),
                onChanged: (value) => onInputChange('callToAction', value),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],

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

  Widget _buildPlacementsSection(String medium) {
    final placements = placementsByMedium[medium] ?? [];
    if (placements.isEmpty) return const SizedBox();

    final mediumLabel = medium == 'app' ? 'App' : 'Digital';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(
          '$mediumLabel Placements',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          children: placements.map((placement) {
            final isSelected = formData.placements.contains(
              placement['value'] as String,
            );
            return FilterChip(
              label: Text(placement['label'] as String),
              selected: isSelected,
              onSelected: (selected) =>
                  onMultiSelect('placements', placement['value'] as String),
              selectedColor: const Color(0xFF185FA5),
              backgroundColor: Colors.grey[100],
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildImageUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Image',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onImageUpload,
          child: Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[50],
            ),
            child: formData.images.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(formData.images.first),
                      fit: BoxFit.cover,
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.cloud_upload,
                        size: 40,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap to upload image',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildVideoUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Video',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onVideoUpload,
          child: Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[50],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.videocam, size: 40, color: Colors.grey[400]),
                const SizedBox(height: 8),
                Text(
                  formData.videoFile != null
                      ? 'Video selected'
                      : 'Tap to upload video',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
