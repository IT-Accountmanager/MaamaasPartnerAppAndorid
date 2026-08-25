import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/vendor_form_data.dart';
import '../widgets/common_widgets.dart';

class ContactDetailsStep extends StatefulWidget {
  final VendorFormData formData;
  final ValueChanged<VendorFormData> onChanged;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const ContactDetailsStep({
    super.key,
    required this.formData,
    required this.onChanged,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<ContactDetailsStep> createState() => _ContactDetailsStepState();
}

class _ContactDetailsStepState extends State<ContactDetailsStep> {
  final _picker = ImagePicker();

  void _update(VendorFormData updated) => widget.onChanged(updated);

  Future<void> _pickAadharFile() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      _update(widget.formData.copyWith(aadharFile: File(picked.path)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final f = widget.formData;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle('Contact Information'),

          LabeledInput(
            label: 'Contact Name *',
            placeholder: 'Enter name',
            value: f.contactName,
            onChanged: (v) => _update(f.copyWith(contactName: v)),
          ),
          const SizedBox(height: 14),

          LabeledInput(
            label: 'Phone No. *',
            placeholder: 'Enter phone number',
            value: f.phone,
            keyboardType: TextInputType.phone,
            onChanged: (v) => _update(f.copyWith(phone: v)),
          ),
          const SizedBox(height: 14),

          LabeledInput(
            label: 'Email ID *',
            placeholder: 'Enter email',
            value: f.email,
            keyboardType: TextInputType.emailAddress,
            onChanged: (v) => _update(f.copyWith(email: v)),
          ),
          const SizedBox(height: 20),

          const Text(
            'Aadhar Card No. *',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: kTextMid,
            ),
          ),
          const SizedBox(height: 8),

          LabeledInput(
            label: '',
            placeholder: 'Enter Aadhar number',
            value: f.aadhar,
            keyboardType: TextInputType.number,
            onChanged: (v) => _update(f.copyWith(aadhar: v)),
          ),
          const SizedBox(height: 10),

          // File pick
          GestureDetector(
            onTap: _pickAadharFile,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: kBgLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: kBorderColor),
              ),
              child: Row(
                children: [
                  const Icon(Icons.upload_file, color: kGray, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      f.aadharFile != null
                          ? f.aadharFile!.path.split('/').last
                          : 'Upload Aadhar file',
                      style: TextStyle(
                        fontSize: 13,
                        color: f.aadharFile != null
                            ? Colors.green
                            : const Color(0xFF9CA3AF),
                      ),
                    ),
                  ),
                  if (f.aadharFile != null)
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 18,
                    ),
                ],
              ),
            ),
          ),

          if (f.aadharFile != null) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                f.aadharFile!,
                height: 80,
                width: 80,
                fit: BoxFit.cover,
              ),
            ),
          ],

          const SizedBox(height: 28),

          NavButtonRow(onBack: widget.onBack, onNext: widget.onNext),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
