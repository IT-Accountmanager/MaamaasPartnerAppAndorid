
import 'package:flutter/material.dart';
import '../models/vendor_form_data.dart';

class CompanyProfileStep extends StatefulWidget {
  final VendorFormData formData;
  final ValueChanged<VendorFormData> onChanged;
  final VoidCallback onNext;

  const CompanyProfileStep({
    super.key,
    required this.formData,
    required this.onChanged,
    required this.onNext,
  });

  @override
  State<CompanyProfileStep> createState() => _CompanyProfileStepState();
}

class _CompanyProfileStepState extends State<CompanyProfileStep> {
  final _businessTypes = [
    {'value': 'HOTEL', 'label': 'Hotel'},
    {'value': 'RESTAURANT', 'label': 'Restaurant'},
    {'value': 'CAFE', 'label': 'Cafe'},
    {'value': 'CLOUD_KITCHEN', 'label': 'Cloud Kitchen'},
    {'value': 'FOOD_COURT', 'label': 'Food Court'},
    {'value': 'STREET_FOOD', 'label': 'Street Food'},
    {'value': 'BAKERY', 'label': 'Bakery'},
  ];

  // Create controllers
  late TextEditingController _companyNameController;
  late TextEditingController _positionController;
  late TextEditingController _brandNameController;

  @override
  void initState() {
    super.initState();
    _companyNameController = TextEditingController(
      text: widget.formData.companyName ?? '',
    );
    _positionController = TextEditingController(
      text: widget.formData.position ?? '',
    );
    _brandNameController = TextEditingController(
      text: widget.formData.brandName,
    );
  }

  @override
  void didUpdateWidget(CompanyProfileStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.formData.companyName != widget.formData.companyName) {
      _companyNameController.text = widget.formData.companyName ?? '';
    }
    if (oldWidget.formData.position != widget.formData.position) {
      _positionController.text = widget.formData.position ?? '';
    }
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _positionController.dispose();
    _brandNameController.dispose();
    super.dispose();
  }

  void _update(VendorFormData updated) => widget.onChanged(updated);

  String? _getValidBusinessTypeValue(String? currentValue) {
    if (currentValue == null || currentValue.isEmpty) {
      return null;
    }
    final exists = _businessTypes.any((type) => type['value'] == currentValue);
    return exists ? currentValue : null;
  }

  @override
  Widget build(BuildContext context) {
    final f = widget.formData;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Company Name
                const Text(
                  'Company Name *',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF374151),
                  ),
                ),
                const SizedBox(height: 8),

                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFE5E7EB),
                    ),
                  ),
                  child: TextField(
                    controller: _companyNameController,
                    onChanged: (v) =>
                        _update(f.copyWith(companyName: v)),
                    decoration: const InputDecoration(
                      hintText: 'Enter company name',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Position
                const Text(
                  'Position *',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF374151),
                  ),
                ),

                const SizedBox(height: 8),

                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFE5E7EB),
                    ),
                  ),
                  child: TextField(
                    controller: _positionController,
                    onChanged: (v) =>
                        _update(f.copyWith(position: v)),
                    decoration: const InputDecoration(
                      hintText: 'Enter your position',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                const Text(
                  'Brand Name *',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF374151),
                  ),
                ),

                const SizedBox(height: 8),

                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFE5E7EB),
                    ),
                  ),
                  child: TextField(
                    readOnly: true,
                    controller: _brandNameController,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Business Type
                const Text(
                  'Business Type *',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF374151),
                  ),
                ),

                const SizedBox(height: 8),

                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFE5E7EB),
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value:
                      _getValidBusinessTypeValue(f.verticalType),
                      hint: const Text(
                        'Select Business Type',
                        style: TextStyle(
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                      isExpanded: true,
                      items: _businessTypes
                          .map(
                            (type) => DropdownMenuItem(
                          value: type['value'],
                          child: Text(type['label']!),
                        ),
                      )
                          .toList(),
                      onChanged: (v) => _update(
                        f.copyWith(verticalType: v ?? ''),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: widget.onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE66D33),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Next →',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
