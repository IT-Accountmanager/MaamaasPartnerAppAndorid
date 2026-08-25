// // import 'dart:io';
// // import 'package:flutter/material.dart';
// // import 'package:image_picker/image_picker.dart';
// // import '../models/vendor_form_data.dart';
// //
// // class LicenseDocumentsStep extends StatefulWidget {
// //   final VendorFormData formData;
// //   final ValueChanged<VendorFormData> onChanged;
// //   final VoidCallback onNext;
// //   final VoidCallback onBack;
// //
// //   const LicenseDocumentsStep({
// //     super.key,
// //     required this.formData,
// //     required this.onChanged,
// //     required this.onNext,
// //     required this.onBack,
// //   });
// //
// //   @override
// //   State<LicenseDocumentsStep> createState() => _LicenseDocumentsStepState();
// // }
// //
// // class _LicenseDocumentsStepState extends State<LicenseDocumentsStep>
// //     with AutomaticKeepAliveClientMixin {
// //   final ImagePicker _picker = ImagePicker();
// //
// //   // Text Controllers
// //   late TextEditingController _gstController;
// //   late TextEditingController _panController;
// //   late TextEditingController _fssaiNoController;
// //   late TextEditingController _tradeLicenseNoController;
// //   late TextEditingController _fssaiStartController;
// //   late TextEditingController _fssaiEndController;
// //   late TextEditingController _bankNameController;
// //   late TextEditingController _ifscController;
// //   late TextEditingController _accountNumberController;
// //
// //   @override
// //   bool get wantKeepAlive => true;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _initializeControllers();
// //   }
// //
// //   void _initializeControllers() {
// //     _gstController = TextEditingController(text: widget.formData.gst ?? '');
// //     _panController = TextEditingController(text: widget.formData.pan ?? '');
// //     _fssaiNoController = TextEditingController(
// //       text: widget.formData.fssaiNo ?? '',
// //     );
// //     _tradeLicenseNoController = TextEditingController(
// //       text: widget.formData.tradeLicenseNo ?? '',
// //     );
// //     _fssaiStartController = TextEditingController(
// //       text: widget.formData.fssaiStart ?? '',
// //     );
// //     _fssaiEndController = TextEditingController(
// //       text: widget.formData.fssaiEnd ?? '',
// //     );
// //     _bankNameController = TextEditingController(
// //       text: widget.formData.bankName ?? '',
// //     );
// //     _ifscController = TextEditingController(text: widget.formData.ifsc ?? '');
// //     _accountNumberController = TextEditingController(
// //       text: widget.formData.accountNumber ?? '',
// //     );
// //   }
// //
// //   @override
// //   void didUpdateWidget(LicenseDocumentsStep oldWidget) {
// //     super.didUpdateWidget(oldWidget);
// //     // Update controllers if formData changes externally
// //     if (oldWidget.formData.gst != widget.formData.gst) {
// //       _gstController.text = widget.formData.gst ?? '';
// //     }
// //     if (oldWidget.formData.pan != widget.formData.pan) {
// //       _panController.text = widget.formData.pan ?? '';
// //     }
// //     if (oldWidget.formData.fssaiNo != widget.formData.fssaiNo) {
// //       _fssaiNoController.text = widget.formData.fssaiNo ?? '';
// //     }
// //     if (oldWidget.formData.tradeLicenseNo != widget.formData.tradeLicenseNo) {
// //       _tradeLicenseNoController.text = widget.formData.tradeLicenseNo ?? '';
// //     }
// //     if (oldWidget.formData.fssaiStart != widget.formData.fssaiStart) {
// //       _fssaiStartController.text = widget.formData.fssaiStart ?? '';
// //     }
// //     if (oldWidget.formData.fssaiEnd != widget.formData.fssaiEnd) {
// //       _fssaiEndController.text = widget.formData.fssaiEnd ?? '';
// //     }
// //     if (oldWidget.formData.bankName != widget.formData.bankName) {
// //       _bankNameController.text = widget.formData.bankName ?? '';
// //     }
// //     if (oldWidget.formData.ifsc != widget.formData.ifsc) {
// //       _ifscController.text = widget.formData.ifsc ?? '';
// //     }
// //     if (oldWidget.formData.accountNumber != widget.formData.accountNumber) {
// //       _accountNumberController.text = widget.formData.accountNumber ?? '';
// //     }
// //   }
// //
// //   @override
// //   void dispose() {
// //     _gstController.dispose();
// //     _panController.dispose();
// //     _fssaiNoController.dispose();
// //     _tradeLicenseNoController.dispose();
// //     _fssaiStartController.dispose();
// //     _fssaiEndController.dispose();
// //     _bankNameController.dispose();
// //     _ifscController.dispose();
// //     _accountNumberController.dispose();
// //     super.dispose();
// //   }
// //
// //   void _update(VendorFormData updated) {
// //     widget.onChanged(updated);
// //   }
// //
// //   Future<File?> _pickFile() async {
// //     final picked = await _picker.pickImage(source: ImageSource.gallery);
// //     if (picked != null) {
// //       return File(picked.path);
// //     }
// //     return null;
// //   }
// //
// //   Widget _buildTextField({
// //     required String label,
// //     required String hint,
// //     required TextEditingController controller,
// //     required Function(String) onChanged,
// //     TextInputType keyboardType = TextInputType.text,
// //     bool isRequired = false,
// //   }) {
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         Text(
// //           isRequired ? '$label *' : label,
// //           style: const TextStyle(
// //             fontSize: 14,
// //             fontWeight: FontWeight.w500,
// //             color: Color(0xFF374151),
// //           ),
// //         ),
// //         const SizedBox(height: 8),
// //         Container(
// //           decoration: BoxDecoration(
// //             color: const Color(0xFFF9FAFB),
// //             borderRadius: BorderRadius.circular(12),
// //             border: Border.all(color: const Color(0xFFE5E7EB)),
// //           ),
// //           child: TextField(
// //             controller: controller,
// //             keyboardType: keyboardType,
// //             onChanged: onChanged,
// //             decoration: InputDecoration(
// //               hintText: hint,
// //               border: InputBorder.none,
// //               contentPadding: const EdgeInsets.symmetric(
// //                 horizontal: 16,
// //                 vertical: 14,
// //               ),
// //             ),
// //           ),
// //         ),
// //       ],
// //     );
// //   }
// //
// //   Widget _buildUploadField({
// //     required String title,
// //     required File? file,
// //     required VoidCallback onTap,
// //     bool isRequired = false,
// //   }) {
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         Text(
// //           isRequired ? '$title *' : title,
// //           style: const TextStyle(
// //             fontSize: 14,
// //             fontWeight: FontWeight.w500,
// //             color: Color(0xFF374151),
// //           ),
// //         ),
// //         const SizedBox(height: 8),
// //         InkWell(
// //           onTap: onTap,
// //           child: Container(
// //             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
// //             decoration: BoxDecoration(
// //               color: const Color(0xFFF9FAFB),
// //               borderRadius: BorderRadius.circular(12),
// //               border: Border.all(color: const Color(0xFFE5E7EB)),
// //             ),
// //             child: Row(
// //               children: [
// //                 Icon(
// //                   Icons.cloud_upload_outlined,
// //                   size: 20,
// //                   color: file != null ? Colors.green : const Color(0xFF9CA3AF),
// //                 ),
// //                 const SizedBox(width: 12),
// //                 Expanded(
// //                   child: Text(
// //                     file != null
// //                         ? file.path.split('/').last
// //                         : 'Click to upload $title',
// //                     style: TextStyle(
// //                       fontSize: 14,
// //                       color: file != null
// //                           ? Colors.green
// //                           : const Color(0xFF6B7280),
// //                     ),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ),
// //         if (file != null) ...[
// //           const SizedBox(height: 12),
// //           ClipRRect(
// //             borderRadius: BorderRadius.circular(8),
// //             child: Image.file(file, height: 80, width: 80, fit: BoxFit.cover),
// //           ),
// //         ],
// //       ],
// //     );
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     super.build(context);
// //
// //     final f = widget.formData;
// //
// //     return SingleChildScrollView(
// //       padding: const EdgeInsets.all(20),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           Padding(
// //             padding: const EdgeInsets.all(20),
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 // GST Section
// //                 _buildTextField(
// //                   label: 'GST Number',
// //                   hint: 'Enter GST Number',
// //                   controller: _gstController,
// //                   onChanged: (v) => _update(f.copyWith(gst: v)),
// //                   isRequired: true,
// //                 ),
// //
// //                 const SizedBox(height: 16),
// //
// //                 _buildUploadField(
// //                   title: 'GST Certificate',
// //                   file: f.gstFile,
// //                   onTap: () async {
// //                     final file = await _pickFile();
// //                     if (file != null) {
// //                       _update(f.copyWith(gstFile: file));
// //                     }
// //                   },
// //                   isRequired: true,
// //                 ),
// //
// //                 const SizedBox(height: 24),
// //
// //                 // PAN Section
// //                 _buildTextField(
// //                   label: 'PAN Number',
// //                   hint: 'Enter PAN Number',
// //                   controller: _panController,
// //                   onChanged: (v) => _update(f.copyWith(pan: v)),
// //                   isRequired: true,
// //                 ),
// //
// //                 const SizedBox(height: 16),
// //
// //                 _buildUploadField(
// //                   title: 'PAN Card',
// //                   file: f.panFile,
// //                   onTap: () async {
// //                     final file = await _pickFile();
// //                     if (file != null) {
// //                       _update(f.copyWith(panFile: file));
// //                     }
// //                   },
// //                   isRequired: true,
// //                 ),
// //
// //                 const SizedBox(height: 24),
// //
// //                 // FSSAI Section
// //                 _buildTextField(
// //                   label: 'FSSAI License Number',
// //                   hint: 'Enter FSSAI Number',
// //                   controller: _fssaiNoController,
// //                   onChanged: (v) => _update(f.copyWith(fssaiNo: v)),
// //                   isRequired: true,
// //                 ),
// //
// //                 const SizedBox(height: 16),
// //
// //                 _buildUploadField(
// //                   title: 'FSSAI License',
// //                   file: f.fssaiFile,
// //                   onTap: () async {
// //                     final file = await _pickFile();
// //                     if (file != null) {
// //                       _update(f.copyWith(fssaiFile: file));
// //                     }
// //                   },
// //                   isRequired: true,
// //                 ),
// //
// //                 const SizedBox(height: 16),
// //
// //                 // FSSAI Dates
// //                 Row(
// //                   children: [
// //                     Expanded(
// //                       child: _buildTextField(
// //                         label: 'FSSAI Valid From',
// //                         hint: 'DD-MM-YYYY',
// //                         controller: _fssaiStartController,
// //                         onChanged: (v) => _update(f.copyWith(fssaiStart: v)),
// //                         isRequired: true,
// //                       ),
// //                     ),
// //
// //                     const SizedBox(width: 12),
// //
// //                     Expanded(
// //                       child: _buildTextField(
// //                         label: 'FSSAI Valid To',
// //                         hint: 'DD-MM-YYYY',
// //                         controller: _fssaiEndController,
// //                         onChanged: (v) => _update(f.copyWith(fssaiEnd: v)),
// //                         isRequired: true,
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //
// //                 const SizedBox(height: 24),
// //
// //                 // Trade License Section
// //                 _buildTextField(
// //                   label: 'Trade License Number',
// //                   hint: 'Enter Trade License Number',
// //                   controller: _tradeLicenseNoController,
// //                   onChanged: (v) => _update(f.copyWith(tradeLicenseNo: v)),
// //                   isRequired: false,
// //                 ),
// //
// //                 const SizedBox(height: 16),
// //
// //                 _buildUploadField(
// //                   title: 'Trade License',
// //                   file: f.tradeLicenseFile,
// //                   onTap: () async {
// //                     final file = await _pickFile();
// //                     if (file != null) {
// //                       _update(f.copyWith(tradeLicenseFile: file));
// //                     }
// //                   },
// //                   isRequired: false,
// //                 ),
// //
// //                 const SizedBox(height: 24),
// //
// //                 const Divider(),
// //
// //                 const SizedBox(height: 20),
// //
// //                 // Bank Details
// //                 const Text(
// //                   'Bank Details',
// //                   style: TextStyle(
// //                     fontSize: 20,
// //                     fontWeight: FontWeight.w700,
// //                     color: Color(0xFF1F2937),
// //                   ),
// //                 ),
// //
// //                 const SizedBox(height: 20),
// //
// //                 _buildTextField(
// //                   label: 'Bank Name',
// //                   hint: 'Enter Bank Name',
// //                   controller: _bankNameController,
// //                   onChanged: (v) => _update(f.copyWith(bankName: v)),
// //                   isRequired: false,
// //                 ),
// //
// //                 const SizedBox(height: 16),
// //
// //                 _buildTextField(
// //                   label: 'IFSC Code',
// //                   hint: 'Enter IFSC Code',
// //                   controller: _ifscController,
// //                   onChanged: (v) => _update(f.copyWith(ifsc: v)),
// //                   isRequired: false,
// //                 ),
// //
// //                 const SizedBox(height: 16),
// //
// //                 _buildTextField(
// //                   label: 'Account Number',
// //                   hint: 'Enter Account Number',
// //                   controller: _accountNumberController,
// //                   keyboardType: TextInputType.number,
// //                   onChanged: (v) => _update(f.copyWith(accountNumber: v)),
// //                   isRequired: false,
// //                 ),
// //
// //                 const SizedBox(height: 16),
// //
// //                 _buildUploadField(
// //                   title: 'Passbook',
// //                   file: f.passbookFile,
// //                   onTap: () async {
// //                     final file = await _pickFile();
// //                     if (file != null) {
// //                       _update(f.copyWith(passbookFile: file));
// //                     }
// //                   },
// //                   isRequired: false,
// //                 ),
// //               ],
// //             ),
// //           ),
// //
// //           const SizedBox(height: 28),
// //
// //           Row(
// //             children: [
// //               Expanded(
// //                 child: SizedBox(
// //                   height: 52,
// //                   child: OutlinedButton(
// //                     onPressed: widget.onBack,
// //                     style: OutlinedButton.styleFrom(
// //                       side: const BorderSide(color: Color(0xFFE5E7EB)),
// //                       shape: RoundedRectangleBorder(
// //                         borderRadius: BorderRadius.circular(14),
// //                       ),
// //                     ),
// //                     child: const Text(
// //                       '← Back',
// //                       style: TextStyle(
// //                         fontSize: 16,
// //                         fontWeight: FontWeight.w600,
// //                         color: Color(0xFF6B7280),
// //                       ),
// //                     ),
// //                   ),
// //                 ),
// //               ),
// //
// //               const SizedBox(width: 12),
// //
// //               Expanded(
// //                 child: SizedBox(
// //                   height: 52,
// //                   child: ElevatedButton(
// //                     onPressed: widget.onNext,
// //                     style: ElevatedButton.styleFrom(
// //                       backgroundColor: const Color(0xFFE66D33),
// //                       elevation: 0,
// //                       shape: RoundedRectangleBorder(
// //                         borderRadius: BorderRadius.circular(14),
// //                       ),
// //                     ),
// //                     child: const Text(
// //                       'Save & Next',
// //                       style: TextStyle(
// //                         fontSize: 16,
// //                         fontWeight: FontWeight.w600,
// //                         color: Colors.white,
// //                       ),
// //                     ),
// //                   ),
// //                 ),
// //               ),
// //             ],
// //           ),
// //
// //           const SizedBox(height: 20),
// //         ],
// //       ),
// //     );
// //   }
// // }
//
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import '../../widgets_helper/ImageCompressor.dart';
// import '../models/vendor_form_data.dart';
//
// class LicenseDocumentsStep extends StatefulWidget {
//   final VendorFormData formData;
//   final ValueChanged<VendorFormData> onChanged;
//   final VoidCallback onNext;
//   final VoidCallback onBack;
//
//   const LicenseDocumentsStep({
//     super.key,
//     required this.formData,
//     required this.onChanged,
//     required this.onNext,
//     required this.onBack,
//   });
//
//   @override
//   State<LicenseDocumentsStep> createState() => _LicenseDocumentsStepState();
// }
//
// class _LicenseDocumentsStepState extends State<LicenseDocumentsStep>
//     with AutomaticKeepAliveClientMixin {
//   final ImagePicker _picker = ImagePicker();
//
//   // Text Controllers
//   late TextEditingController _gstController;
//   late TextEditingController _panController;
//   late TextEditingController _fssaiNoController;
//   late TextEditingController _tradeLicenseNoController;
//   late TextEditingController _fssaiStartController;
//   late TextEditingController _fssaiEndController;
//   late TextEditingController _bankNameController;
//   late TextEditingController _ifscController;
//   late TextEditingController _accountNumberController;
//
//   @override
//   bool get wantKeepAlive => true;
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeControllers();
//   }
//
//   void _initializeControllers() {
//     _gstController = TextEditingController(text: widget.formData.gst ?? '');
//     _panController = TextEditingController(text: widget.formData.pan ?? '');
//     _fssaiNoController = TextEditingController(
//       text: widget.formData.fssaiNo ?? '',
//     );
//     _tradeLicenseNoController = TextEditingController(
//       text: widget.formData.tradeLicenseNo ?? '',
//     );
//     _fssaiStartController = TextEditingController(
//       text: widget.formData.fssaiStart ?? '',
//     );
//     _fssaiEndController = TextEditingController(
//       text: widget.formData.fssaiEnd ?? '',
//     );
//     _bankNameController = TextEditingController(
//       text: widget.formData.bankName ?? '',
//     );
//     _ifscController = TextEditingController(text: widget.formData.ifsc ?? '');
//     _accountNumberController = TextEditingController(
//       text: widget.formData.accountNumber ?? '',
//     );
//   }
//
//   @override
//   void didUpdateWidget(LicenseDocumentsStep oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     // Update controllers if formData changes externally
//     if (oldWidget.formData.gst != widget.formData.gst) {
//       _gstController.text = widget.formData.gst ?? '';
//     }
//     if (oldWidget.formData.pan != widget.formData.pan) {
//       _panController.text = widget.formData.pan ?? '';
//     }
//     if (oldWidget.formData.fssaiNo != widget.formData.fssaiNo) {
//       _fssaiNoController.text = widget.formData.fssaiNo ?? '';
//     }
//     if (oldWidget.formData.tradeLicenseNo != widget.formData.tradeLicenseNo) {
//       _tradeLicenseNoController.text = widget.formData.tradeLicenseNo ?? '';
//     }
//     if (oldWidget.formData.fssaiStart != widget.formData.fssaiStart) {
//       _fssaiStartController.text = widget.formData.fssaiStart ?? '';
//     }
//     if (oldWidget.formData.fssaiEnd != widget.formData.fssaiEnd) {
//       _fssaiEndController.text = widget.formData.fssaiEnd ?? '';
//     }
//     if (oldWidget.formData.bankName != widget.formData.bankName) {
//       _bankNameController.text = widget.formData.bankName ?? '';
//     }
//     if (oldWidget.formData.ifsc != widget.formData.ifsc) {
//       _ifscController.text = widget.formData.ifsc ?? '';
//     }
//     if (oldWidget.formData.accountNumber != widget.formData.accountNumber) {
//       _accountNumberController.text = widget.formData.accountNumber ?? '';
//     }
//   }
//
//   @override
//   void dispose() {
//     _gstController.dispose();
//     _panController.dispose();
//     _fssaiNoController.dispose();
//     _tradeLicenseNoController.dispose();
//     _fssaiStartController.dispose();
//     _fssaiEndController.dispose();
//     _bankNameController.dispose();
//     _ifscController.dispose();
//     _accountNumberController.dispose();
//     super.dispose();
//   }
//
//   void _update(VendorFormData updated) {
//     widget.onChanged(updated);
//   }
//
//   Future<File?> _pickFile() async {
//     final picked = await _picker.pickImage(source: ImageSource.gallery);
//     if (picked != null) {
//       return await ImageCompressor.compress(File(picked.path));
//     }
//     return null;
//   }
//
//   Widget _buildTextField({
//     required String label,
//     required String hint,
//     required TextEditingController controller,
//     required Function(String) onChanged,
//     TextInputType keyboardType = TextInputType.text,
//     bool isRequired = false,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           isRequired ? '$label *' : label,
//           style: const TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.w500,
//             color: Color(0xFF374151),
//           ),
//         ),
//         const SizedBox(height: 8),
//         Container(
//           decoration: BoxDecoration(
//             color: const Color(0xFFF9FAFB),
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(color: const Color(0xFFE5E7EB)),
//           ),
//           child: TextField(
//             controller: controller,
//             keyboardType: keyboardType,
//             onChanged: onChanged,
//             decoration: InputDecoration(
//               hintText: hint,
//               border: InputBorder.none,
//               contentPadding: const EdgeInsets.symmetric(
//                 horizontal: 16,
//                 vertical: 14,
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   /// Shows a date picker and updates both the controller and formData.
//   Future<void> _pickDate({
//     required TextEditingController controller,
//     required Function(String) onChanged,
//     DateTime? firstDate,
//     DateTime? lastDate,
//   }) async {
//     // Parse existing value so the picker opens on the already-chosen date
//     DateTime initial = DateTime.now();
//     if (controller.text.isNotEmpty) {
//       final parts = controller.text.split('-');
//       if (parts.length == 3) {
//         final parsed = DateTime.tryParse('${parts[2]}-${parts[1]}-${parts[0]}');
//         if (parsed != null) initial = parsed;
//       }
//     }
//
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: initial,
//       firstDate: firstDate ?? DateTime(2000),
//       lastDate: lastDate ?? DateTime(2100),
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: const ColorScheme.light(
//               primary: Color(0xFFE66D33),
//               onPrimary: Colors.white,
//               onSurface: Color(0xFF1F2937),
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );
//
//     if (picked != null) {
//       final formatted =
//           '${picked.day.toString().padLeft(2, '0')}-'
//           '${picked.month.toString().padLeft(2, '0')}-'
//           '${picked.year}';
//       controller.text = formatted;
//       onChanged(formatted);
//     }
//   }
//
//   /// A read-only tappable field that opens the date picker.
//   Widget _buildDateField({
//     required String label,
//     required TextEditingController controller,
//     required Function(String) onChanged,
//     bool isRequired = false,
//     DateTime? firstDate,
//     DateTime? lastDate,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           isRequired ? '$label *' : label,
//           style: const TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.w500,
//             color: Color(0xFF374151),
//           ),
//         ),
//         const SizedBox(height: 8),
//         InkWell(
//           borderRadius: BorderRadius.circular(12),
//           onTap: () => _pickDate(
//             controller: controller,
//             onChanged: onChanged,
//             firstDate: firstDate,
//             lastDate: lastDate,
//           ),
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//             decoration: BoxDecoration(
//               color: const Color(0xFFF9FAFB),
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(color: const Color(0xFFE5E7EB)),
//             ),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: Text(
//                     controller.text.isEmpty ? 'DD-MM-YYYY' : controller.text,
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: controller.text.isEmpty
//                           ? const Color(0xFF9CA3AF)
//                           : const Color(0xFF1F2937),
//                     ),
//                   ),
//                 ),
//                 const Icon(
//                   Icons.calendar_today_outlined,
//                   size: 18,
//                   color: Color(0xFF6B7280),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildUploadField({
//     required String title,
//     required File? file,
//     required VoidCallback onTap,
//     bool isRequired = false,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           isRequired ? '$title *' : title,
//           style: const TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.w500,
//             color: Color(0xFF374151),
//           ),
//         ),
//         const SizedBox(height: 8),
//         InkWell(
//           onTap: onTap,
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//             decoration: BoxDecoration(
//               color: const Color(0xFFF9FAFB),
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(color: const Color(0xFFE5E7EB)),
//             ),
//             child: Row(
//               children: [
//                 Icon(
//                   Icons.cloud_upload_outlined,
//                   size: 20,
//                   color: file != null ? Colors.green : const Color(0xFF9CA3AF),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Text(
//                     file != null
//                         ? file.path.split('/').last
//                         : 'Click to upload $title',
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: file != null
//                           ? Colors.green
//                           : const Color(0xFF6B7280),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//         if (file != null) ...[
//           const SizedBox(height: 12),
//           ClipRRect(
//             borderRadius: BorderRadius.circular(8),
//             child: Image.file(file, height: 80, width: 80, fit: BoxFit.cover),
//           ),
//         ],
//       ],
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     super.build(context);
//
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
//                 // GST Section
//                 _buildTextField(
//                   label: 'GST Number',
//                   hint: 'Enter GST Number',
//                   controller: _gstController,
//                   onChanged: (v) => _update(f.copyWith(gst: v)),
//                   isRequired: true,
//                 ),
//
//                 const SizedBox(height: 16),
//
//                 _buildUploadField(
//                   title: 'GST Certificate',
//                   file: f.gstFile,
//                   onTap: () async {
//                     final file = await _pickFile();
//                     if (file != null) {
//                       _update(f.copyWith(gstFile: file));
//                     }
//                   },
//                   isRequired: true,
//                 ),
//
//                 const SizedBox(height: 24),
//
//                 // PAN Section
//                 _buildTextField(
//                   label: 'PAN Number',
//                   hint: 'Enter PAN Number',
//                   controller: _panController,
//                   onChanged: (v) => _update(f.copyWith(pan: v)),
//                   isRequired: true,
//                 ),
//
//                 const SizedBox(height: 16),
//
//                 _buildUploadField(
//                   title: 'PAN Card',
//                   file: f.panFile,
//                   onTap: () async {
//                     final file = await _pickFile();
//                     if (file != null) {
//                       _update(f.copyWith(panFile: file));
//                     }
//                   },
//                   isRequired: true,
//                 ),
//
//                 const SizedBox(height: 24),
//
//                 // FSSAI Section
//                 _buildTextField(
//                   label: 'FSSAI License Number',
//                   hint: 'Enter FSSAI Number',
//                   controller: _fssaiNoController,
//                   onChanged: (v) => _update(f.copyWith(fssaiNo: v)),
//                   isRequired: true,
//                 ),
//
//                 const SizedBox(height: 16),
//
//                 _buildUploadField(
//                   title: 'FSSAI License',
//                   file: f.fssaiFile,
//                   onTap: () async {
//                     final file = await _pickFile();
//                     if (file != null) {
//                       _update(f.copyWith(fssaiFile: file));
//                     }
//                   },
//                   isRequired: true,
//                 ),
//
//                 const SizedBox(height: 16),
//
//                 // FSSAI Dates
//                 Row(
//                   children: [
//                     Expanded(
//                       child: _buildDateField(
//                         label: 'FSSAI Valid From',
//                         controller: _fssaiStartController,
//                         onChanged: (v) => _update(f.copyWith(fssaiStart: v)),
//                         isRequired: true,
//                         // Can start from any past or future date
//                         firstDate: DateTime(2000),
//                         lastDate: DateTime(2100),
//                       ),
//                     ),
//
//                     const SizedBox(width: 12),
//
//                     Expanded(
//                       child: _buildDateField(
//                         label: 'FSSAI Valid To',
//                         controller: _fssaiEndController,
//                         onChanged: (v) => _update(f.copyWith(fssaiEnd: v)),
//                         isRequired: true,
//                         // "Valid To" should not be before today
//                         firstDate: DateTime.now(),
//                         lastDate: DateTime(2100),
//                       ),
//                     ),
//                   ],
//                 ),
//
//                 const SizedBox(height: 24),
//
//                 // Trade License Section
//                 _buildTextField(
//                   label: 'Trade License Number',
//                   hint: 'Enter Trade License Number',
//                   controller: _tradeLicenseNoController,
//                   onChanged: (v) => _update(f.copyWith(tradeLicenseNo: v)),
//                   isRequired: false,
//                 ),
//
//                 const SizedBox(height: 16),
//
//                 _buildUploadField(
//                   title: 'Trade License',
//                   file: f.tradeLicenseFile,
//                   onTap: () async {
//                     final file = await _pickFile();
//                     if (file != null) {
//                       _update(f.copyWith(tradeLicenseFile: file));
//                     }
//                   },
//                   isRequired: false,
//                 ),
//
//                 const SizedBox(height: 24),
//
//                 const Divider(),
//
//                 const SizedBox(height: 20),
//
//                 // Bank Details
//                 const Text(
//                   'Bank Details',
//                   style: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.w700,
//                     color: Color(0xFF1F2937),
//                   ),
//                 ),
//
//                 const SizedBox(height: 20),
//
//                 _buildTextField(
//                   label: 'Bank Name',
//                   hint: 'Enter Bank Name',
//                   controller: _bankNameController,
//                   onChanged: (v) => _update(f.copyWith(bankName: v)),
//                   isRequired: false,
//                 ),
//
//                 const SizedBox(height: 16),
//
//                 _buildTextField(
//                   label: 'IFSC Code',
//                   hint: 'Enter IFSC Code',
//                   controller: _ifscController,
//                   onChanged: (v) => _update(f.copyWith(ifsc: v)),
//                   isRequired: false,
//                 ),
//
//                 const SizedBox(height: 16),
//
//                 _buildTextField(
//                   label: 'Account Number',
//                   hint: 'Enter Account Number',
//                   controller: _accountNumberController,
//                   keyboardType: TextInputType.number,
//                   onChanged: (v) => _update(f.copyWith(accountNumber: v)),
//                   isRequired: false,
//                 ),
//
//                 const SizedBox(height: 16),
//
//                 _buildUploadField(
//                   title: 'Passbook',
//                   file: f.passbookFile,
//                   onTap: () async {
//                     final file = await _pickFile();
//                     if (file != null) {
//                       _update(f.copyWith(passbookFile: file));
//                     }
//                   },
//                   isRequired: false,
//                 ),
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
//
//               const SizedBox(width: 12),
//
//               Expanded(
//                 child: SizedBox(
//                   height: 52,
//                   child: ElevatedButton(
//                     onPressed: widget.onNext,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xFFE66D33),
//                       elevation: 0,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(14),
//                       ),
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

class _LicenseDocumentsStepState extends State<LicenseDocumentsStep>
    with AutomaticKeepAliveClientMixin {
  final ImagePicker _picker = ImagePicker();

  // Text Controllers
  late TextEditingController _gstController;
  late TextEditingController _panController;
  late TextEditingController _fssaiNoController;
  late TextEditingController _tradeLicenseNoController;
  late TextEditingController _fssaiStartController;
  late TextEditingController _fssaiEndController;
  late TextEditingController _bankNameController;
  late TextEditingController _ifscController;
  late TextEditingController _accountNumberController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _gstController = TextEditingController(text: widget.formData.gst ?? '');
    _panController = TextEditingController(text: widget.formData.pan ?? '');
    _fssaiNoController = TextEditingController(
      text: widget.formData.fssaiNo ?? '',
    );
    _tradeLicenseNoController = TextEditingController(
      text: widget.formData.tradeLicenseNo ?? '',
    );
    _fssaiStartController = TextEditingController(
      text: widget.formData.fssaiStart ?? '',
    );
    _fssaiEndController = TextEditingController(
      text: widget.formData.fssaiEnd ?? '',
    );
    _bankNameController = TextEditingController(
      text: widget.formData.bankName ?? '',
    );
    _ifscController = TextEditingController(text: widget.formData.ifsc ?? '');
    _accountNumberController = TextEditingController(
      text: widget.formData.accountNumber ?? '',
    );
  }

  @override
  void didUpdateWidget(LicenseDocumentsStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update controllers if formData changes externally
    if (oldWidget.formData.gst != widget.formData.gst) {
      _gstController.text = widget.formData.gst ?? '';
    }
    if (oldWidget.formData.pan != widget.formData.pan) {
      _panController.text = widget.formData.pan ?? '';
    }
    if (oldWidget.formData.fssaiNo != widget.formData.fssaiNo) {
      _fssaiNoController.text = widget.formData.fssaiNo ?? '';
    }
    if (oldWidget.formData.tradeLicenseNo != widget.formData.tradeLicenseNo) {
      _tradeLicenseNoController.text = widget.formData.tradeLicenseNo ?? '';
    }
    if (oldWidget.formData.fssaiStart != widget.formData.fssaiStart) {
      _fssaiStartController.text = widget.formData.fssaiStart ?? '';
    }
    if (oldWidget.formData.fssaiEnd != widget.formData.fssaiEnd) {
      _fssaiEndController.text = widget.formData.fssaiEnd ?? '';
    }
    if (oldWidget.formData.bankName != widget.formData.bankName) {
      _bankNameController.text = widget.formData.bankName ?? '';
    }
    if (oldWidget.formData.ifsc != widget.formData.ifsc) {
      _ifscController.text = widget.formData.ifsc ?? '';
    }
    if (oldWidget.formData.accountNumber != widget.formData.accountNumber) {
      _accountNumberController.text = widget.formData.accountNumber ?? '';
    }
  }

  @override
  void dispose() {
    _gstController.dispose();
    _panController.dispose();
    _fssaiNoController.dispose();
    _tradeLicenseNoController.dispose();
    _fssaiStartController.dispose();
    _fssaiEndController.dispose();
    _bankNameController.dispose();
    _ifscController.dispose();
    _accountNumberController.dispose();
    super.dispose();
  }

  void _update(VendorFormData updated) {
    widget.onChanged(updated);
  }

  Future<File?> _pickFile() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      return await ImageCompressor.compress(File(picked.path));
    }
    return null;
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required Function(String) onChanged,
    TextInputType keyboardType = TextInputType.text,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isRequired ? '$label *' : label,
          style: const TextStyle(
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
            controller: controller,
            keyboardType: keyboardType,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: hint,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Shows a date picker and updates both the controller and formData.
  Future<void> _pickDate({
    required TextEditingController controller,
    required Function(String) onChanged,
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    // Parse existing value so the picker opens on the already-chosen date
    DateTime initial = DateTime.now();
    if (controller.text.isNotEmpty) {
      final parts = controller.text.split('-');
      if (parts.length == 3) {
        final parsed = DateTime.tryParse('${parts[2]}-${parts[1]}-${parts[0]}');
        if (parsed != null) initial = parsed;
      }
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: firstDate ?? DateTime(2000),
      lastDate: lastDate ?? DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFE66D33),
              onPrimary: Colors.white,
              onSurface: Color(0xFF1F2937),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      // UI shows DD-MM-YYYY (user-friendly)
      final display =
          '${picked.day.toString().padLeft(2, '0')}-'
          '${picked.month.toString().padLeft(2, '0')}-'
          '${picked.year}';

      // Backend expects YYYY-MM-DD (Java LocalDate)
      final backendValue =
          '${picked.year}-'
          '${picked.month.toString().padLeft(2, '0')}-'
          '${picked.day.toString().padLeft(2, '0')}';

      controller.text = display; // what the user sees
      onChanged(backendValue); // what gets sent to the API
    }
  }

  /// A read-only tappable field that opens the date picker.
  Widget _buildDateField({
    required String label,
    required TextEditingController controller,
    required Function(String) onChanged,
    bool isRequired = false,
    DateTime? firstDate,
    DateTime? lastDate,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isRequired ? '$label *' : label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _pickDate(
            controller: controller,
            onChanged: onChanged,
            firstDate: firstDate,
            lastDate: lastDate,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    controller.text.isEmpty ? 'DD-MM-YYYY' : controller.text,
                    style: TextStyle(
                      fontSize: 14,
                      color: controller.text.isEmpty
                          ? const Color(0xFF9CA3AF)
                          : const Color(0xFF1F2937),
                    ),
                  ),
                ),
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 18,
                  color: Color(0xFF6B7280),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadField({
    required String title,
    required File? file,
    required VoidCallback onTap,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isRequired ? '$title *' : title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.cloud_upload_outlined,
                  size: 20,
                  color: file != null ? Colors.green : const Color(0xFF9CA3AF),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    file != null
                        ? file.path.split('/').last
                        : 'Click to upload $title',
                    style: TextStyle(
                      fontSize: 14,
                      color: file != null
                          ? Colors.green
                          : const Color(0xFF6B7280),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (file != null) ...[
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(file, height: 80, width: 80, fit: BoxFit.cover),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

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
                // GST Section
                _buildTextField(
                  label: 'GST Number',
                  hint: 'Enter GST Number',
                  controller: _gstController,
                  onChanged: (v) => _update(f.copyWith(gst: v)),
                  isRequired: true,
                ),

                const SizedBox(height: 16),

                _buildUploadField(
                  title: 'GST Certificate',
                  file: f.gstFile,
                  onTap: () async {
                    final file = await _pickFile();
                    if (file != null) {
                      _update(f.copyWith(gstFile: file));
                    }
                  },
                  isRequired: true,
                ),

                const SizedBox(height: 24),

                // PAN Section
                _buildTextField(
                  label: 'PAN Number',
                  hint: 'Enter PAN Number',
                  controller: _panController,
                  onChanged: (v) => _update(f.copyWith(pan: v)),
                  isRequired: true,
                ),

                const SizedBox(height: 16),

                _buildUploadField(
                  title: 'PAN Card',
                  file: f.panFile,
                  onTap: () async {
                    final file = await _pickFile();
                    if (file != null) {
                      _update(f.copyWith(panFile: file));
                    }
                  },
                  isRequired: true,
                ),

                const SizedBox(height: 24),

                // FSSAI Section
                _buildTextField(
                  label: 'FSSAI License Number',
                  hint: 'Enter FSSAI Number',
                  controller: _fssaiNoController,
                  onChanged: (v) => _update(f.copyWith(fssaiNo: v)),
                  isRequired: true,
                ),

                const SizedBox(height: 16),

                _buildUploadField(
                  title: 'FSSAI License',
                  file: f.fssaiFile,
                  onTap: () async {
                    final file = await _pickFile();
                    if (file != null) {
                      _update(f.copyWith(fssaiFile: file));
                    }
                  },
                  isRequired: true,
                ),

                const SizedBox(height: 16),

                // FSSAI Dates
                Row(
                  children: [
                    Expanded(
                      child: _buildDateField(
                        label: 'FSSAI Valid From',
                        controller: _fssaiStartController,
                        onChanged: (v) => _update(f.copyWith(fssaiStart: v)),
                        isRequired: true,
                        // Can start from any past or future date
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: _buildDateField(
                        label: 'FSSAI Valid To',
                        controller: _fssaiEndController,
                        onChanged: (v) => _update(f.copyWith(fssaiEnd: v)),
                        isRequired: true,
                        // "Valid To" should not be before today
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Trade License Section
                _buildTextField(
                  label: 'Trade License Number',
                  hint: 'Enter Trade License Number',
                  controller: _tradeLicenseNoController,
                  onChanged: (v) => _update(f.copyWith(tradeLicenseNo: v)),
                  isRequired: false,
                ),

                const SizedBox(height: 16),

                _buildUploadField(
                  title: 'Trade License',
                  file: f.tradeLicenseFile,
                  onTap: () async {
                    final file = await _pickFile();
                    if (file != null) {
                      _update(f.copyWith(tradeLicenseFile: file));
                    }
                  },
                  isRequired: false,
                ),

                const SizedBox(height: 24),

                const Divider(),

                const SizedBox(height: 20),

                // Bank Details
                const Text(
                  'Bank Details',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2937),
                  ),
                ),

                const SizedBox(height: 20),

                _buildTextField(
                  label: 'Bank Name',
                  hint: 'Enter Bank Name',
                  controller: _bankNameController,
                  onChanged: (v) => _update(f.copyWith(bankName: v)),
                  isRequired: false,
                ),

                const SizedBox(height: 16),

                _buildTextField(
                  label: 'IFSC Code',
                  hint: 'Enter IFSC Code',
                  controller: _ifscController,
                  onChanged: (v) => _update(f.copyWith(ifsc: v)),
                  isRequired: false,
                ),

                const SizedBox(height: 16),

                _buildTextField(
                  label: 'Account Number',
                  hint: 'Enter Account Number',
                  controller: _accountNumberController,
                  keyboardType: TextInputType.number,
                  onChanged: (v) => _update(f.copyWith(accountNumber: v)),
                  isRequired: false,
                ),

                const SizedBox(height: 16),

                _buildUploadField(
                  title: 'Passbook',
                  file: f.passbookFile,
                  onTap: () async {
                    final file = await _pickFile();
                    if (file != null) {
                      _update(f.copyWith(passbookFile: file));
                    }
                  },
                  isRequired: false,
                ),
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
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
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
