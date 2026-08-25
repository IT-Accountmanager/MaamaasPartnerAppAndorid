import 'package:flutter/material.dart';
import '../../login_screen.dart' as login; // Alias to fix SectionTitle conflict
import '../models/vendor_form_data.dart';
import '../services/vendor_api_service.dart';
import '../widgets/common_widgets.dart';

class PreviewStep extends StatefulWidget {
  final VendorFormData formData;
  final VoidCallback onBack;
  final String vendorId;
  final bool isNewVendor;

  const PreviewStep({
    super.key,
    required this.formData,
    required this.onBack,
    required this.vendorId,
    this.isNewVendor = false,
  });

  @override
  State<PreviewStep> createState() => _PreviewStepState();
}

class _PreviewStepState extends State<PreviewStep> {
  bool _isLoading = false;
  bool _isSaved = false;

  Future<void> _handleSave() async {
    setState(() => _isLoading = true);
    try {
      bool success = false;
      String? serverError;

      if (widget.isNewVendor) {
        // ── New vendor from Book-a-Demo: no JWT token exists yet ─────────────
        // Use the public endpoint that doesn't require Authorization header.
        final result = await VendorApiService.registerVendorPublic(
          widget.vendorId,
          widget.formData,
        );
        success = result.success;
        serverError = result.errorMessage;
      } else {
        // ── Returning / logged-in vendor: token is present ───────────────────
        success = await VendorApiService.registerVendor(
          widget.vendorId,
          widget.formData,
        );
      }

      if (!mounted) return;

      if (success) {
        setState(() => _isSaved = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Vendor Registered Successfully'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to LoginPage1 after successful registration
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            // Navigate to LoginPage1 (your first page) and clear all previous routes
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const login.LoginPage1()),
              (route) => false,
            );
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(serverError ?? '❌ Failed to register vendor'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _section(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: kTextDark,
          ),
        ),
        const SizedBox(height: 10),
        ...children,
        const FormDivider(),
      ],
    );
  }

  Widget _row(List<Widget> fields) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: fields
            .map(
              (f) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: f,
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final f = widget.formData;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Use a simple Text widget instead of SectionTitle to avoid the conflict
          const Text(
            'Preview & Submit',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          // COMPANY
          _section('Company Details', [
            _row([
              PreviewField(label: 'Company', value: f.companyName),
              PreviewField(label: 'Vertical', value: f.businessVertical),
            ]),
            _row([
              PreviewField(label: 'Position', value: f.position),
              PreviewField(label: 'Business Type', value: f.verticalType),
            ]),
            _row([
              PreviewField(label: 'Door No', value: f.doorNumber),
              PreviewField(label: 'City', value: f.city),
            ]),
            _row([
              PreviewField(label: 'State', value: f.state),
              PreviewField(label: 'Pincode', value: f.pincode),
            ]),
            _row([
              PreviewField(label: 'Landmark', value: f.landMark),
              PreviewField(
                label: 'Lat / Lng',
                value: '${f.latitude ?? ''} / ${f.longitude ?? ''}',
              ),
            ]),
          ]),

          // CONTACT
          _section('Contact Details', [
            _row([
              PreviewField(label: 'Name', value: f.contactName),
              PreviewField(label: 'Phone', value: f.phone),
            ]),
            _row([
              PreviewField(label: 'Email', value: f.email),
              PreviewField(label: 'Aadhar', value: f.aadhar),
            ]),
            if (f.aadharFile != null)
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Aadhar File',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: kTextMid,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        f.aadharFile!,
                        height: 60,
                        width: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
              ),
          ]),

          // LICENSES
          _section('Licenses & Documents', [
            _row([
              PreviewField(label: 'GST No', value: f.gst),
              PreviewField(label: 'PAN No', value: f.pan),
            ]),
            _row([
              PreviewField(label: 'FSSAI No', value: f.fssaiNo),
              PreviewField(
                label: 'FSSAI Validity',
                value: '${f.fssaiStart} → ${f.fssaiEnd}',
              ),
            ]),
            _row([
              PreviewField(label: 'Trade License', value: f.tradeLicenseNo),
              PreviewField(
                label: 'Trade Validity',
                value: '${f.tradeStart} → ${f.tradeEnd}',
              ),
            ]),
            _row([
              PreviewField(label: 'Labour License', value: f.labourLicenseNo),
              PreviewField(
                label: 'Labour Validity',
                value: '${f.labourStart} → ${f.labourEnd}',
              ),
            ]),
          ]),

          // BANK
          _section('Bank Details', [
            _row([
              PreviewField(label: 'Bank Name', value: f.bankName),
              PreviewField(label: 'IFSC', value: f.ifsc),
            ]),
            _row([
              PreviewField(label: 'Account No', value: f.accountNumber),
              const SizedBox(),
            ]),
          ]),

          // VENDOR ID (for debugging - optional)
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Vendor ID: ${widget.vendorId}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),

          // BUTTONS
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    onPressed: widget.onBack,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: kGray,
                      side: const BorderSide(color: kBorderColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      '← Back',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: (_isSaved || _isLoading) ? null : _handleSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isSaved ? Colors.grey : Colors.green,
                      disabledBackgroundColor: _isSaved
                          ? Colors.grey.shade300
                          : null,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            _isSaved ? 'Saved ✓' : 'Save & Submit',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
