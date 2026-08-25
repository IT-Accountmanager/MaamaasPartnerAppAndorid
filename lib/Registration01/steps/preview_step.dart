// import 'package:flutter/material.dart';
// import 'package:maamaaspartner/Registration01/models/vendor_form_data.dart';
// import '../../login_screen.dart' as login;
// import '../services/vendor_api_service.dart';
//
// class PreviewStep extends StatefulWidget {
//   final VendorFormData formData;
//   final VoidCallback onBack;
//   final String vendorId;
//   final bool isNewVendor;
//   final VoidCallback? onRegistrationComplete;
//
//   const PreviewStep({
//     super.key,
//     required this.formData,
//     required this.onBack,
//     required this.vendorId,
//     this.isNewVendor = false,
//     this.onRegistrationComplete,
//   });
//
//   @override
//   State<PreviewStep> createState() => _PreviewStepState();
// }
//
// class _PreviewStepState extends State<PreviewStep> {
//   bool _isLoading = false;
//   bool _isSaved = false;
//
//   Future<void> _handleSave() async {
//     setState(() => _isLoading = true);
//     try {
//       bool success = false;
//       String? serverError;
//
//       if (widget.isNewVendor) {
//         final result = await VendorApiService.registerVendorPublic(
//           widget.vendorId,
//           widget.formData,
//         );
//         success = result.success;
//         serverError = result.errorMessage;
//       } else {
//         success = await VendorApiService.registerVendor(
//           widget.vendorId,
//           widget.formData,
//         );
//       }
//
//       if (!mounted) return;
//
//       if (success) {
//         setState(() => _isSaved = true);
//
//         // Show success message with better styling
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Row(
//               children: const [
//                 Icon(Icons.check_circle, color: Colors.white, size: 20),
//                 SizedBox(width: 12),
//                 Expanded(
//                   child: Text(
//                     'Vendor Registered Successfully!',
//                     style: TextStyle(fontWeight: FontWeight.w600),
//                   ),
//                 ),
//               ],
//             ),
//             backgroundColor: Colors.green,
//             behavior: SnackBarBehavior.floating,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(10),
//             ),
//             duration: const Duration(seconds: 2),
//           ),
//         );
//
//         // Call the completion callback if provided
//         if (widget.onRegistrationComplete != null) {
//           Future.delayed(const Duration(milliseconds: 1500), () {
//             if (mounted) {
//               widget.onRegistrationComplete!();
//             }
//           });
//         } else {
//           // Fallback: Navigate to login after 2 seconds
//           Future.delayed(const Duration(seconds: 2), () {
//             if (mounted) {
//               Navigator.pushAndRemoveUntil(
//                 context,
//                 MaterialPageRoute(builder: (_) => const login.LoginPage1()),
//                     (route) => false,
//               );
//             }
//           });
//         }
//       } else {
//         // Show error message from server
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Row(
//               children: [
//                 const Icon(Icons.error_outline, color: Colors.white, size: 20),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Text(
//                     serverError ?? 'Failed to register vendor',
//                     style: const TextStyle(fontWeight: FontWeight.w500),
//                   ),
//                 ),
//               ],
//             ),
//             backgroundColor: Colors.red,
//             behavior: SnackBarBehavior.floating,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(10),
//             ),
//           ),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Row(
//               children: [
//                 const Icon(Icons.error_outline, color: Colors.white, size: 20),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Text(
//                     'Error: $e',
//                     style: const TextStyle(fontWeight: FontWeight.w500),
//                   ),
//                 ),
//               ],
//             ),
//             backgroundColor: Colors.red,
//             behavior: SnackBarBehavior.floating,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(10),
//             ),
//           ),
//         );
//       }
//     } finally {
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final f = widget.formData;
//
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Preview & Submit',
//             style: TextStyle(
//               fontSize: 24,
//               fontWeight: FontWeight.bold,
//               color: Color(0xFF1F2937),
//             ),
//           ),
//           const SizedBox(height: 20),
//
//           // Company Preview
//           _buildSection('Company Details', [
//             _buildInfoRow('Company Name', f.companyName),
//             _buildInfoRow('Brand Name', f.brandName),
//             _buildInfoRow('Position', f.position),
//             _buildInfoRow('Business Type', f.verticalType),
//           ]),
//
//           // Address Preview
//           _buildSection('Address Details', [
//             _buildInfoRow('Door No', f.doorNumber),
//             _buildInfoRow('Street/Address', f.addressLine),
//             _buildInfoRow('Landmark', f.landMark),
//             _buildInfoRow('City', f.city),
//             _buildInfoRow('State', f.state),
//             _buildInfoRow('Pincode', f.pincode),
//           ]),
//
//           // Contact Preview
//           _buildSection('Contact Details', [
//             _buildInfoRow('Contact Name', f.contactName),
//             _buildInfoRow('Phone Number', f.phone),
//             _buildInfoRow('Email', f.email),
//             _buildInfoRow('Aadhaar Number', f.aadhar),
//             if (f.aadharFile != null)
//               _buildInfoRow('Aadhaar Uploaded', f.aadharFile!.path.split('/').last),
//           ]),
//
//           // Documents Preview
//           _buildSection('Documents', [
//             _buildInfoRow('GST Number', f.gst),
//             if (f.gstFile != null)
//               _buildInfoRow('GST Certificate', f.gstFile!.path.split('/').last),
//             _buildInfoRow('PAN Number', f.pan),
//             if (f.panFile != null)
//               _buildInfoRow('PAN Card', f.panFile!.path.split('/').last),
//             _buildInfoRow('FSSAI License', f.fssaiNo),
//             if (f.fssaiFile != null)
//               _buildInfoRow('FSSAI Document', f.fssaiFile!.path.split('/').last),
//             _buildInfoRow('FSSAI Valid From', f.fssaiStart),
//             _buildInfoRow('FSSAI Valid To', f.fssaiEnd),
//             _buildInfoRow('Trade License', f.tradeLicenseNo),
//             if (f.tradeLicenseFile != null)
//               _buildInfoRow('Trade License Doc', f.tradeLicenseFile!.path.split('/').last),
//             _buildInfoRow('Labour License', f.labourLicenseNo),
//             if (f.labourFile != null)
//               _buildInfoRow('Labour License Doc', f.labourFile!.path.split('/').last),
//           ]),
//
//           // Location Preview
//           _buildSection('Location', [
//             _buildInfoRow('Latitude', f.latitude?.toString() ?? 'Not set'),
//             _buildInfoRow('Longitude', f.longitude?.toString() ?? 'Not set'),
//             _buildInfoRow('Full Address', f.address.isNotEmpty ? f.address : 'Not set'),
//           ]),
//
//           // Bank Preview
//           _buildSection('Bank Details', [
//             _buildInfoRow('Bank Name', f.bankName),
//             _buildInfoRow('IFSC Code', f.ifsc),
//             _buildInfoRow('Account Number', f.accountNumber),
//             if (f.passbookFile != null)
//               _buildInfoRow('Passbook', f.passbookFile!.path.split('/').last),
//           ]),
//
//           const SizedBox(height: 28),
//
//           // Buttons
//           Row(
//             children: [
//               Expanded(
//                 child: SizedBox(
//                   height: 52,
//                   child: OutlinedButton(
//                     onPressed: _isLoading ? null : widget.onBack,
//                     style: OutlinedButton.styleFrom(
//                       side: const BorderSide(color: Color(0xFFE5E7EB)),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(14),
//                       ),
//                     ),
//                     child: const Text(
//                       '← Back',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                         color: Color(0xFF6B7280),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: SizedBox(
//                   height: 52,
//                   child: ElevatedButton(
//                     onPressed: (_isSaved || _isLoading) ? null : _handleSave,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: _isSaved
//                           ? Colors.grey
//                           : const Color(0xFFE66D33),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(14),
//                       ),
//                       elevation: 0,
//                     ),
//                     child: _isLoading
//                         ? const SizedBox(
//                       height: 20,
//                       width: 20,
//                       child: CircularProgressIndicator(
//                         color: Colors.white,
//                         strokeWidth: 2.5,
//                       ),
//                     )
//                         : Text(
//                       _isSaved ? '✓ Submitted' : 'Save & Submit',
//                       style: const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 20),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSection(String title, List<Widget> children) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       margin: const EdgeInsets.only(bottom: 16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: const Color(0xFFEEF2F6)),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.02),
//             blurRadius: 4,
//             offset: const Offset(0, 1),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 width: 28,
//                 height: 28,
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFE66D33).withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: const Icon(
//                   Icons.check_circle_outline,
//                   size: 16,
//                   color: Color(0xFFE66D33),
//                 ),
//               ),
//               const SizedBox(width: 10),
//               Text(
//                 title,
//                 style: const TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                   color: Color(0xFF1F2937),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 14),
//           ...children,
//         ],
//       ),
//     );
//   }
//
//   Widget _buildInfoRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 6),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 120,
//             child: Text(
//               label,
//               style: const TextStyle(
//                 fontSize: 13,
//                 color: Color(0xFF6B7280),
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//           Expanded(
//             child: Text(
//               value.isEmpty ? '—' : value,
//               style: const TextStyle(
//                 fontSize: 13,
//                 color: Color(0xFF1F2937),
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:maamaaspartner/Registration01/models/vendor_form_data.dart';
import '../../login_screen.dart' as login;
import '../services/vendor_api_service.dart';

class PreviewStep extends StatefulWidget {
  final VendorFormData formData;
  final VoidCallback onBack;
  final String vendorId;
  final bool isNewVendor;
  final VoidCallback? onRegistrationComplete;

  const PreviewStep({
    super.key,
    required this.formData,
    required this.onBack,
    required this.vendorId,
    this.isNewVendor = false,
    this.onRegistrationComplete,
  });

  @override
  State<PreviewStep> createState() => _PreviewStepState();
}

class _PreviewStepState extends State<PreviewStep> {
  bool _isLoading = false;
  bool _isSaved = false;
  bool _termsAccepted = false;

  Future<void> _handleSave() async {
    setState(() => _isLoading = true);
    try {
      bool success = false;
      String? serverError;

      if (widget.isNewVendor) {
        final result = await VendorApiService.registerVendorPublic(
          widget.vendorId,
          widget.formData,
        );
        success = result.success;
        serverError = result.errorMessage;
      } else {
        success = await VendorApiService.registerVendor(
          widget.vendorId,
          widget.formData,
        );
      }

      if (!mounted) return;

      if (success) {
        setState(() => _isSaved = true);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Vendor Registered Successfully!',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 2),
          ),
        );

        // Always navigate to LoginPage1 after successful registration.
        // Also fire the optional callback if the parent provided one.
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            widget.onRegistrationComplete?.call();
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
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    serverError ?? 'Failed to register vendor',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Error: $e',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
          const Text(
            'Preview & Submit',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 20),

          _buildSection('Company Details', [
            _buildInfoRow('Company Name', f.companyName),
            _buildInfoRow('Brand Name', f.brandName),
            _buildInfoRow('Position', f.position),
            _buildInfoRow('Business Type', f.verticalType),
          ]),

          _buildSection('Address Details', [
            _buildInfoRow('Door No', f.doorNumber),
            _buildInfoRow('Street/Address', f.addressLine),
            _buildInfoRow('Landmark', f.landMark),
            _buildInfoRow('City', f.city),
            _buildInfoRow('State', f.state),
            _buildInfoRow('Pincode', f.pincode),
          ]),

          _buildSection('Contact Details', [
            _buildInfoRow('Contact Name', f.contactName),
            _buildInfoRow('Phone Number', f.phone),
            _buildInfoRow('Email', f.email),
            _buildInfoRow('Aadhaar Number', f.aadhar),
            if (f.aadharFile != null)
              _buildInfoRow(
                'Aadhaar Uploaded',
                f.aadharFile!.path.split('/').last,
              ),
          ]),

          _buildSection('Documents', [
            _buildInfoRow('GST Number', f.gst),
            if (f.gstFile != null)
              _buildInfoRow('GST Certificate', f.gstFile!.path.split('/').last),
            _buildInfoRow('PAN Number', f.pan),
            if (f.panFile != null)
              _buildInfoRow('PAN Card', f.panFile!.path.split('/').last),
            _buildInfoRow('FSSAI License', f.fssaiNo),
            if (f.fssaiFile != null)
              _buildInfoRow(
                'FSSAI Document',
                f.fssaiFile!.path.split('/').last,
              ),
            _buildInfoRow('FSSAI Valid From', f.fssaiStart),
            _buildInfoRow('FSSAI Valid To', f.fssaiEnd),
            _buildInfoRow('Trade License', f.tradeLicenseNo),
            if (f.tradeLicenseFile != null)
              _buildInfoRow(
                'Trade License Doc',
                f.tradeLicenseFile!.path.split('/').last,
              ),
            _buildInfoRow('Labour License', f.labourLicenseNo),
            if (f.labourFile != null)
              _buildInfoRow(
                'Labour License Doc',
                f.labourFile!.path.split('/').last,
              ),
          ]),

          _buildSection('Location', [
            _buildInfoRow('Latitude', f.latitude?.toString() ?? 'Not set'),
            _buildInfoRow('Longitude', f.longitude?.toString() ?? 'Not set'),
            _buildInfoRow(
              'Full Address',
              f.address.isNotEmpty ? f.address : 'Not set',
            ),
          ]),

          _buildSection('Bank Details', [
            _buildInfoRow('Bank Name', f.bankName),
            _buildInfoRow('IFSC Code', f.ifsc),
            _buildInfoRow('Account Number', f.accountNumber),
            if (f.passbookFile != null)
              _buildInfoRow('Passbook', f.passbookFile!.path.split('/').last),
          ]),

          const SizedBox(height: 28),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7F2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _termsAccepted
                    ? const Color(0xFFE66D33)
                    : const Color(0xFFE5E7EB),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: _termsAccepted,
                  activeColor: const Color(0xFFE66D33),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  onChanged: _isLoading
                      ? null
                      : (val) => setState(() => _termsAccepted = val ?? false),
                ),
                const SizedBox(width: 4),
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: Text(
                      'I agree to the Terms & Conditions and confirm that all the information provided is accurate.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF374151),
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : widget.onBack,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFE5E7EB)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      '← Back',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    // Disabled when: not accepted T&C, already saved, or loading
                    onPressed: (_isSaved || _isLoading || !_termsAccepted)
                        ? null
                        : _handleSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: (_isSaved || !_termsAccepted)
                          ? Colors.grey
                          : const Color(0xFFE66D33),
                      disabledBackgroundColor: Colors.grey.shade300,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
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
                            _isSaved ? '✓ Submitted' : 'Save & Submit',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
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

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEF2F6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFFE66D33).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  size: 16,
                  color: Color(0xFFE66D33),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '—' : value,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF1F2937),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
