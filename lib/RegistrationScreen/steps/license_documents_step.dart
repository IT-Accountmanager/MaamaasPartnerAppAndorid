import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/vendor_form_data.dart';
import '../widgets/common_widgets.dart';

class LicenseDocumentsStep extends StatefulWidget {
  final VendorFormData formData;
  final ValueChanged<VendorFormData> onChanged;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const LicenseDocumentsStep({
    super.key,
    required this.formData,
    required this.onChanged,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<LicenseDocumentsStep> createState() => _LicenseDocumentsStepState();
}

class _LicenseDocumentsStepState extends State<LicenseDocumentsStep> {
  final _picker = ImagePicker();

  void _update(VendorFormData updated) => widget.onChanged(updated);

  Future<File?> _pickFile() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    return picked != null ? File(picked.path) : null;
  }

  Widget _filePickRow({
    required String fieldLabel,
    required File? file,
    required VoidCallback onPick,
  }) {
    return GestureDetector(
      onTap: onPick,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: kBgLight,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: kBorderColor),
        ),
        child: Row(
          children: [
            Icon(
              Icons.upload_file,
              color: file != null ? Colors.green : kGray,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                file != null ? file.path.split('/').last : 'Upload $fieldLabel',
                style: TextStyle(
                  fontSize: 12,
                  color: file != null ? Colors.green : const Color(0xFF9CA3AF),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _licenseSection({
    required String title,
    required String numberValue,
    required ValueChanged<String> onNumberChanged,
    required String numberPlaceholder,
    required File? file,
    required VoidCallback onFilePick,
    String? startDate,
    ValueChanged<String>? onStartDateChanged,
    String? endDate,
    ValueChanged<String>? onEndDateChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: kTextDark,
            ),
          ),
          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: LabeledInput(
                  label: '',
                  placeholder: numberPlaceholder,
                  value: numberValue,
                  onChanged: onNumberChanged,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _filePickRow(
                  fieldLabel: title,
                  file: file,
                  onPick: onFilePick,
                ),
              ),
            ],
          ),

          if (startDate != null && endDate != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: LabeledInput(
                    label: 'Start Date',
                    placeholder: 'YYYY-MM-DD',
                    value: startDate,
                    onChanged: onStartDateChanged ?? (_) {},
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: LabeledInput(
                    label: 'End Date',
                    placeholder: 'YYYY-MM-DD',
                    value: endDate,
                    onChanged: onEndDateChanged ?? (_) {},
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  @override
  @override
  Widget build(BuildContext context) {
    final f = widget.formData;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle('License & Documents'),

          _licenseSection(
            title: 'GST Details',
            numberValue: f.gst,
            onNumberChanged: (v) => _update(f.copyWith(gst: v)),
            numberPlaceholder: 'Enter GST number',
            file: f.gstFile,
            onFilePick: () async {
              final file = await _pickFile();
              if (file != null) _update(f.copyWith(gstFile: file));
            },
          ),

          _licenseSection(
            title: 'Company PAN Details',
            numberValue: f.pan,
            onNumberChanged: (v) => _update(f.copyWith(pan: v)),
            numberPlaceholder: 'Enter PAN number',
            file: f.panFile,
            onFilePick: () async {
              final file = await _pickFile();
              if (file != null) _update(f.copyWith(panFile: file));
            },
          ),

          _licenseSection(
            title: 'FSSAI License',
            numberValue: f.fssaiNo,
            onNumberChanged: (v) => _update(f.copyWith(fssaiNo: v)),
            numberPlaceholder: 'Enter FSSAI No',
            file: f.fssaiFile,
            onFilePick: () async {
              final file = await _pickFile();
              if (file != null) _update(f.copyWith(fssaiFile: file));
            },
            startDate: f.fssaiStart,
            onStartDateChanged: (v) => _update(f.copyWith(fssaiStart: v)),
            endDate: f.fssaiEnd,
            onEndDateChanged: (v) => _update(f.copyWith(fssaiEnd: v)),
          ),

          _licenseSection(
            title: 'Trade License',
            numberValue: f.tradeLicenseNo,
            onNumberChanged: (v) => _update(f.copyWith(tradeLicenseNo: v)),
            numberPlaceholder: 'Enter Trade License No',
            file: f.tradeLicenseFile,
            onFilePick: () async {
              final file = await _pickFile();
              if (file != null) {
                _update(f.copyWith(tradeLicenseFile: file));
              }
            },
            startDate: f.tradeStart,
            onStartDateChanged: (v) => _update(f.copyWith(tradeStart: v)),
            endDate: f.tradeEnd,
            onEndDateChanged: (v) => _update(f.copyWith(tradeEnd: v)),
          ),

          _licenseSection(
            title: 'Labour License',
            numberValue: f.labourLicenseNo,
            onNumberChanged: (v) => _update(f.copyWith(labourLicenseNo: v)),
            numberPlaceholder: 'Enter Labour License No',
            file: f.labourFile,
            onFilePick: () async {
              final file = await _pickFile();
              if (file != null) {
                _update(f.copyWith(labourFile: file));
              }
            },
            startDate: f.labourStart,
            onStartDateChanged: (v) => _update(f.copyWith(labourStart: v)),
            endDate: f.labourEnd,
            onEndDateChanged: (v) => _update(f.copyWith(labourEnd: v)),
          ),

          /// ✅ Bank Details (Flat UI)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bank Details',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: kTextDark,
                  ),
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: LabeledInput(
                        label: 'Bank Name',
                        placeholder: 'Enter Bank Name',
                        value: f.bankName,
                        onChanged: (v) => _update(f.copyWith(bankName: v)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: LabeledInput(
                        label: 'IFSC Code',
                        placeholder: 'Enter IFSC Code',
                        value: f.ifsc,
                        onChanged: (v) => _update(f.copyWith(ifsc: v)),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                LabeledInput(
                  label: 'Account Number',
                  placeholder: 'Enter Account Number',
                  value: f.accountNumber,
                  keyboardType: TextInputType.number,
                  onChanged: (v) => _update(f.copyWith(accountNumber: v)),
                ),

                const SizedBox(height: 12),

                const Text(
                  'Upload Passbook',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: kTextMid,
                  ),
                ),

                const SizedBox(height: 6),

                _filePickRow(
                  fieldLabel: 'Passbook',
                  file: f.passbookFile,
                  onPick: () async {
                    final file = await _pickFile();
                    if (file != null) {
                      _update(f.copyWith(passbookFile: file));
                    }
                  },
                ),
              ],
            ),
          ), // ✅ <-- IMPORTANT: comma added here

          const SizedBox(height: 28),

          NavButtonRow(onBack: widget.onBack, onNext: widget.onNext),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
