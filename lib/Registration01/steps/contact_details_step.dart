//
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import '../models/vendor_form_data.dart';
//
// class ContactDetailsStep extends StatefulWidget {
//   final VendorFormData formData;
//   final ValueChanged<VendorFormData> onChanged;
//   final VoidCallback onNext;
//   final VoidCallback onBack;
//
//   const ContactDetailsStep({
//     super.key,
//     required this.formData,
//     required this.onChanged,
//     required this.onNext,
//     required this.onBack,
//   });
//
//   @override
//   State<ContactDetailsStep> createState() => _ContactDetailsStepState();
// }
//
// class _ContactDetailsStepState extends State<ContactDetailsStep> {
//   final _picker = ImagePicker();
//
//   late TextEditingController _contactNameController;
//   late TextEditingController _phoneController;
//   late TextEditingController _emailController;
//   late TextEditingController _aadharController;
//
//   @override
//   void initState() {
//     super.initState();
//     _contactNameController = TextEditingController(
//       text: widget.formData.contactName ?? '',
//     );
//     _phoneController = TextEditingController(text: widget.formData.phone ?? '');
//     _emailController = TextEditingController(text: widget.formData.email ?? '');
//     _aadharController = TextEditingController(
//       text: widget.formData.aadhar ?? '',
//     );
//   }
//
//   @override
//   void didUpdateWidget(ContactDetailsStep oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (oldWidget.formData.contactName != widget.formData.contactName) {
//       _contactNameController.text = widget.formData.contactName ?? '';
//     }
//     if (oldWidget.formData.phone != widget.formData.phone) {
//       _phoneController.text = widget.formData.phone ?? '';
//     }
//     if (oldWidget.formData.email != widget.formData.email) {
//       _emailController.text = widget.formData.email ?? '';
//     }
//     if (oldWidget.formData.aadhar != widget.formData.aadhar) {
//       _aadharController.text = widget.formData.aadhar ?? '';
//     }
//   }
//
//   @override
//   void dispose() {
//     _contactNameController.dispose();
//     _phoneController.dispose();
//     _emailController.dispose();
//     _aadharController.dispose();
//     super.dispose();
//   }
//
//   void _update(VendorFormData updated) => widget.onChanged(updated);
//
//   Future<void> _pickAadharFile() async {
//     final picked = await _picker.pickImage(source: ImageSource.gallery);
//     if (picked != null) {
//       _update(widget.formData.copyWith(aadharFile: File(picked.path)));
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
//           Padding(
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Contact Name
//                 const Text(
//                   'Contact Name *',
//                   style: TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w500,
//                     color: Color(0xFF374151),
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//
//                 Container(
//                   decoration: BoxDecoration(
//                     color: const Color(0xFFF9FAFB),
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(
//                       color: const Color(0xFFE5E7EB),
//                     ),
//                   ),
//                   child: TextField(
//                     controller: _contactNameController,
//                     onChanged: (v) =>
//                         _update(f.copyWith(contactName: v)),
//                     decoration: const InputDecoration(
//                       hintText: 'Enter contact name',
//                       border: InputBorder.none,
//                       contentPadding: EdgeInsets.symmetric(
//                         horizontal: 16,
//                         vertical: 14,
//                       ),
//                     ),
//                   ),
//                 ),
//
//                 const SizedBox(height: 16),
//
//                 // Phone Number
//                 const Text(
//                   'Phone Number *',
//                   style: TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w500,
//                     color: Color(0xFF374151),
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//
//                 Container(
//                   decoration: BoxDecoration(
//                     color: const Color(0xFFF9FAFB),
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(
//                       color: const Color(0xFFE5E7EB),
//                     ),
//                   ),
//                   child: TextField(
//                     controller: _phoneController,
//                     keyboardType: TextInputType.phone,
//                     onChanged: (v) =>
//                         _update(f.copyWith(phone: v)),
//                     decoration: const InputDecoration(
//                       hintText: 'Enter phone number',
//                       border: InputBorder.none,
//                       contentPadding: EdgeInsets.symmetric(
//                         horizontal: 16,
//                         vertical: 14,
//                       ),
//                     ),
//                   ),
//                 ),
//
//                 const SizedBox(height: 16),
//
//                 // Email
//                 const Text(
//                   'Email *',
//                   style: TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w500,
//                     color: Color(0xFF374151),
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//
//                 Container(
//                   decoration: BoxDecoration(
//                     color: const Color(0xFFF9FAFB),
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(
//                       color: const Color(0xFFE5E7EB),
//                     ),
//                   ),
//                   child: TextField(
//                     controller: _emailController,
//                     keyboardType: TextInputType.emailAddress,
//                     onChanged: (v) =>
//                         _update(f.copyWith(email: v)),
//                     decoration: const InputDecoration(
//                       hintText: 'Enter email address',
//                       border: InputBorder.none,
//                       contentPadding: EdgeInsets.symmetric(
//                         horizontal: 16,
//                         vertical: 14,
//                       ),
//                     ),
//                   ),
//                 ),
//
//                 const SizedBox(height: 16),
//
//                 // Aadhaar Number
//                 const Text(
//                   'Aadhaar Number',
//                   style: TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w500,
//                     color: Color(0xFF374151),
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//
//                 Container(
//                   decoration: BoxDecoration(
//                     color: const Color(0xFFF9FAFB),
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(
//                       color: const Color(0xFFE5E7EB),
//                     ),
//                   ),
//                   child: TextField(
//                     controller: _aadharController,
//                     keyboardType: TextInputType.number,
//                     onChanged: (v) =>
//                         _update(f.copyWith(aadhar: v)),
//                     decoration: const InputDecoration(
//                       hintText: 'Enter Aadhaar number',
//                       border: InputBorder.none,
//                       contentPadding: EdgeInsets.symmetric(
//                         horizontal: 16,
//                         vertical: 14,
//                       ),
//                     ),
//                   ),
//                 ),
//
//                 const SizedBox(height: 16),
//
//                 // Aadhaar Document Upload
//                 const Text(
//                   'Aadhaar Document',
//                   style: TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w500,
//                     color: Color(0xFF374151),
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//
//                 InkWell(
//                   onTap: _pickAadharFile,
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 16,
//                       vertical: 14,
//                     ),
//                     decoration: BoxDecoration(
//                       color: const Color(0xFFF9FAFB),
//                       borderRadius: BorderRadius.circular(12),
//                       border: Border.all(
//                         color: const Color(0xFFE5E7EB),
//                       ),
//                     ),
//                     child: Row(
//                       children: [
//                         Icon(
//                           Icons.cloud_upload_outlined,
//                           color: f.aadharFile != null
//                               ? Colors.green
//                               : const Color(0xFF9CA3AF),
//                           size: 20,
//                         ),
//                         const SizedBox(width: 12),
//
//                         Expanded(
//                           child: Text(
//                             f.aadharFile != null
//                                 ? f.aadharFile!.path
//                                 .split('/')
//                                 .last
//                                 : 'Click to upload Aadhaar Document',
//                             style: TextStyle(
//                               fontSize: 14,
//                               color: f.aadharFile != null
//                                   ? Colors.green
//                                   : const Color(0xFF6B7280),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//
//                 if (f.aadharFile != null) ...[
//                   const SizedBox(height: 12),
//
//                   ClipRRect(
//                     borderRadius: BorderRadius.circular(8),
//                     child: Image.file(
//                       f.aadharFile!,
//                       height: 80,
//                       width: 80,
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                 ],
//               ],
//             ),
//           ),
//
//           const SizedBox(height: 28),
//
//           Row(
//             children: [
//               Expanded(
//                 child: SizedBox(
//                   height: 52,
//                   child: OutlinedButton(
//                     onPressed: widget.onBack,
//                     style: OutlinedButton.styleFrom(
//                       side: const BorderSide(
//                         color: Color(0xFFE5E7EB),
//                       ),
//                       shape: RoundedRectangleBorder(
//                         borderRadius:
//                         BorderRadius.circular(14),
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
//
//               const SizedBox(width: 12),
//
//               Expanded(
//                 child: SizedBox(
//                   height: 52,
//                   child: ElevatedButton(
//                     onPressed: widget.onNext,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor:
//                       const Color(0xFFE66D33),
//                       shape: RoundedRectangleBorder(
//                         borderRadius:
//                         BorderRadius.circular(14),
//                       ),
//                       elevation: 0,
//                     ),
//                     child: const Text(
//                       'Save & Next',
//                       style: TextStyle(
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
//
//           const SizedBox(height: 20),
//         ],
//       ),
//     );
//   }
// }
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../widgets_helper/ImageCompressor.dart';
import '../models/vendor_form_data.dart';

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

  late TextEditingController _contactNameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _aadharController;

  @override
  void initState() {
    super.initState();
    _contactNameController = TextEditingController(
      text: widget.formData.contactName ?? '',
    );
    _phoneController = TextEditingController(text: widget.formData.phone ?? '');
    _emailController = TextEditingController(text: widget.formData.email ?? '');
    _aadharController = TextEditingController(
      text: widget.formData.aadhar ?? '',
    );
  }

  @override
  void didUpdateWidget(ContactDetailsStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.formData.contactName != widget.formData.contactName) {
      _contactNameController.text = widget.formData.contactName ?? '';
    }
    if (oldWidget.formData.phone != widget.formData.phone) {
      _phoneController.text = widget.formData.phone ?? '';
    }
    if (oldWidget.formData.email != widget.formData.email) {
      _emailController.text = widget.formData.email ?? '';
    }
    if (oldWidget.formData.aadhar != widget.formData.aadhar) {
      _aadharController.text = widget.formData.aadhar ?? '';
    }
  }

  @override
  void dispose() {
    _contactNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _aadharController.dispose();
    super.dispose();
  }

  void _update(VendorFormData updated) => widget.onChanged(updated);

  Future<void> _pickAadharFile() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final compressed = await ImageCompressor.compress(File(picked.path));
      _update(widget.formData.copyWith(aadharFile: compressed));
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
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Contact Name
                const Text(
                  'Contact Name *',
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
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: TextField(
                    controller: _contactNameController,
                    onChanged: (v) => _update(f.copyWith(contactName: v)),
                    decoration: const InputDecoration(
                      hintText: 'Enter contact name',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Phone Number
                const Text(
                  'Phone Number *',
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
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    onChanged: (v) => _update(f.copyWith(phone: v)),
                    decoration: const InputDecoration(
                      hintText: 'Enter phone number',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Email
                const Text(
                  'Email *',
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
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (v) => _update(f.copyWith(email: v)),
                    decoration: const InputDecoration(
                      hintText: 'Enter email address',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Aadhaar Number
                const Text(
                  'Aadhaar Number',
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
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: TextField(
                    controller: _aadharController,
                    keyboardType: TextInputType.number,
                    onChanged: (v) => _update(f.copyWith(aadhar: v)),
                    decoration: const InputDecoration(
                      hintText: 'Enter Aadhaar number',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Aadhaar Document Upload
                const Text(
                  'Aadhaar Document',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF374151),
                  ),
                ),
                const SizedBox(height: 8),

                InkWell(
                  onTap: _pickAadharFile,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.cloud_upload_outlined,
                          color: f.aadharFile != null
                              ? Colors.green
                              : const Color(0xFF9CA3AF),
                          size: 20,
                        ),
                        const SizedBox(width: 12),

                        Expanded(
                          child: Text(
                            f.aadharFile != null
                                ? f.aadharFile!.path.split('/').last
                                : 'Click to upload Aadhaar Document',
                            style: TextStyle(
                              fontSize: 14,
                              color: f.aadharFile != null
                                  ? Colors.green
                                  : const Color(0xFF6B7280),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                if (f.aadharFile != null) ...[
                  const SizedBox(height: 12),

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
              ],
            ),
          ),

          const SizedBox(height: 28),

          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: OutlinedButton(
                    onPressed: widget.onBack,
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
                    onPressed: widget.onNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE66D33),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Save & Next',
                      style: TextStyle(
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
}
