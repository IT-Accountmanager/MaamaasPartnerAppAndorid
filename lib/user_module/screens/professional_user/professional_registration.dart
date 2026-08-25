// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:maamaas_app/API/Auth_service.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../API/Apiclient.dart';
// import '../../Models/Profissional/companyverification_model.dart';
// import '../../widgets/media_utils.dart';
//
// // Status enum for field verification
// enum FieldStatus { notVerified, verified, rejected, pending }
//
// // Field status model
// class FieldStatusInfo {
//   final FieldStatus status;
//   final String? message; // Optional rejection message
//   final DateTime? lastUpdated;
//
//   FieldStatusInfo({
//     this.status = FieldStatus.notVerified,
//     this.message,
//     this.lastUpdated,
//   });
// }
//
// class ProfessionalUserRegistration extends StatefulWidget {
//   final bool isEditing;
//   final CompanyVerificationModel? existingData;
//
//   const ProfessionalUserRegistration({
//     Key? key,
//     this.isEditing = false,
//     this.existingData,
//   }) : super(key: key);
//
//   @override
//   State<ProfessionalUserRegistration> createState() =>
//       _ProfessionalUserRegistrationState();
// }
//
// class _ProfessionalUserRegistrationState
//     extends State<ProfessionalUserRegistration> {
//   int _currentStep = 0;
//   bool _isLoading = false;
//   bool _isEditable = true; // Controls whether fields are editable
//   // Controllers
//   final TextEditingController _fullNameController = TextEditingController();
//   final TextEditingController _mobileController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _ownerAddressController = TextEditingController();
//   File? _ownerSelfieFile;
//   DateTime? _dobController;
//
//   // Business Details
//   String? _selectedCompanyType;
//   final TextEditingController _companyNameController = TextEditingController();
//   final TextEditingController _companyPanController = TextEditingController();
//   File? _companyPanDoc;
//   final TextEditingController _companyGstController = TextEditingController();
//   File? _companyGstDoc;
//   final TextEditingController _cinController = TextEditingController();
//
//   // Text fields (numbers)
//   final TextEditingController _tradeLicenseNumberController =
//       TextEditingController();
//   final TextEditingController _incorporationNumberController =
//       TextEditingController();
//
//   // Files
//   File? _tradeLicenseDoc;
//   File? _incorporationCertificateDoc;
//
//   // Address
//   final TextEditingController _registeredAddressController =
//       TextEditingController();
//   final TextEditingController _cityController = TextEditingController();
//   final TextEditingController _pincodeController = TextEditingController();
//   final TextEditingController _stateController = TextEditingController();
//
//   // Owner Documents
//   final TextEditingController _aadhaarNumberController =
//       TextEditingController();
//   File? _aadhaarFront;
//   final TextEditingController _panNumberController = TextEditingController();
//   File? _panCardDoc;
//
//   // Field Status Tracking
//   final Map<String, FieldStatusInfo> _fieldStatus = {};
//
//   // Existing data status from API
//   String? _existingStatus;
//
//   String? _ownerSelfieUrl;
//   String? _companyPanUrl;
//   String? _companyGstUrl;
//   String? _tradeLicenseUrl;
//   String? _incorporationCertUrl;
//   String? _ownerPanUrl;
//   String? _ownerAadhaarUrl;
//
//   String _verificationStatus = "PENDING"; // PENDING / APPROVED / REJECTED
//   bool _isRefreshing = false;
//
//   // Step Titles
//   List<String> get steps => widget.existingData == null
//       ? [
//           "Owner Info",
//           "Business Details",
//           "Address",
//           "Required Documents",
//           "Review",
//         ]
//       : ["Owner Info", "Business Details", "Address", "Required Documents"];
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeFieldStatus();
//     _loadExistingData();
//   }
//
//   void _initializeFieldStatus() {
//     // Owner Info
//     _fieldStatus['ownerFullName'] = FieldStatusInfo();
//     _fieldStatus['ownerMobile'] = FieldStatusInfo();
//     _fieldStatus['ownerEmail'] = FieldStatusInfo();
//     _fieldStatus['ownerDob'] = FieldStatusInfo();
//     _fieldStatus['ownerAddress'] = FieldStatusInfo();
//     _fieldStatus['ownerSelfie'] = FieldStatusInfo();
//
//     // Business Details
//     _fieldStatus['companyName'] = FieldStatusInfo();
//     _fieldStatus['businessType'] = FieldStatusInfo();
//     _fieldStatus['companyPan'] = FieldStatusInfo();
//     _fieldStatus['companyPanDocument'] = FieldStatusInfo();
//     _fieldStatus['gstin'] = FieldStatusInfo();
//     _fieldStatus['gstCertificate'] = FieldStatusInfo();
//     _fieldStatus['cin'] = FieldStatusInfo();
//     _fieldStatus['tradeLicense'] = FieldStatusInfo();
//     _fieldStatus['incorporationCertificate'] = FieldStatusInfo();
//
//     // Address
//     _fieldStatus['registeredAddress'] = FieldStatusInfo();
//     _fieldStatus['city'] = FieldStatusInfo();
//     _fieldStatus['pincode'] = FieldStatusInfo();
//     _fieldStatus['state'] = FieldStatusInfo();
//
//     // Owner Documents
//     _fieldStatus['ownerPan'] = FieldStatusInfo();
//     _fieldStatus['ownerPanDocument'] = FieldStatusInfo();
//     _fieldStatus['ownerAadhaar'] = FieldStatusInfo();
//     _fieldStatus['ownerAadhaarDocument'] = FieldStatusInfo();
//   }
//
//   Future<void> _loadExistingData() async {
//     if (widget.isEditing && widget.existingData != null) {
//       setState(() {
//         _isLoading = true;
//       });
//
//       final data = widget.existingData!;
//       _existingStatus = data.verificationStatus;
//
//       // Determine if fields are editable based on status
//       _isEditable =
//           data.verificationStatus == 'PENDING' ||
//           data.verificationStatus == 'REJECTED' ||
//           data.verificationStatus == 'RE_SUBMITTED';
//
//       // Load owner info
//       _fullNameController.text = data.ownerFullName;
//       _mobileController.text = data.ownerMobile;
//       _emailController.text = data.ownerEmail;
//       _ownerAddressController.text = data.ownerAddress;
//
//       if (data.ownerDob != null && data.ownerDob!.isNotEmpty) {
//         final parts = data.ownerDob!.split('-');
//         if (parts.length == 3) {
//           _dobController = DateTime(
//             int.parse(parts[0]),
//             int.parse(parts[1]),
//             int.parse(parts[2]),
//           );
//         }
//       }
//
//       // Load business details
//       _companyNameController.text = data.companyName;
//       _selectedCompanyType = data.businessType;
//       _companyPanController.text = data.companyPan;
//       _companyGstController.text = data.gstin;
//       _cinController.text = data.cin;
//
//       // Load address
//       _registeredAddressController.text = data.registeredAddress;
//       _cityController.text = data.city;
//       _stateController.text = data.state;
//       _pincodeController.text = data.pincode;
//
//       // Load owner documents
//       _panNumberController.text = data.ownerPan;
//       _aadhaarNumberController.text = data.ownerAadhaar;
//
//       // You might want to load images from URLs if they exist
//       // This would require downloading images from URLs
//       // For now, we'll keep the existing file fields empty
//
//       setState(() {
//         _isLoading = false;
//       });
//     } else {
//       // Try to fetch existing data if user has already submitted
//       await _fetchExistingVerification();
//     }
//   }
//
//   Future<void> _fetchExistingVerification() async {
//     try {
//       final data = await AuthService.fetchCompanyVerification();
//
//       if (data == null) return;
//
//       setState(() {
//         _verificationStatus = data.verificationStatus;
//       });
//
//       await _populateFormData(data);
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text("Failed to load verification data"),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }
//
//   Future<void> _populateFormData(CompanyVerificationModel data) async {
//     setState(() {
//       _isLoading = true;
//     });
//
//     _existingStatus = data.verificationStatus;
//
//     // Determine if fields are editable based on status
//     _isEditable =
//         data.verificationStatus == 'PENDING' ||
//         data.verificationStatus == 'REJECTED' ||
//         data.verificationStatus == 'RE_SUBMITTED';
//
//     // Load owner info
//     _fullNameController.text = data.ownerFullName;
//     _mobileController.text = data.ownerMobile;
//     _emailController.text = data.ownerEmail;
//     _ownerAddressController.text = data.ownerAddress;
//     _ownerSelfieUrl = data.ownerSelfie;
//     _companyPanUrl = data.companyPanDocument;
//     _companyGstUrl = data.gstCertificate;
//     _tradeLicenseUrl = data.tradeLicense;
//     _incorporationCertUrl = data.incorporationCertificate;
//     _ownerPanUrl = data.ownerPanDocument;
//     _ownerAadhaarUrl = data.ownerAadhaarDocument;
//
//     if (data.ownerDob != null && data.ownerDob!.isNotEmpty) {
//       final parts = data.ownerDob!.split('-');
//       if (parts.length == 3) {
//         _dobController = DateTime(
//           int.parse(parts[0]),
//           int.parse(parts[1]),
//           int.parse(parts[2]),
//         );
//       }
//     }
//
//     // Load business details
//     _companyNameController.text = data.companyName;
//     _selectedCompanyType = data.businessType;
//     _companyPanController.text = data.companyPan;
//     _companyGstController.text = data.gstin;
//     _cinController.text = data.cin;
//
//     // Load address
//     _registeredAddressController.text = data.registeredAddress;
//     _cityController.text = data.city;
//     _stateController.text = data.state;
//     _pincodeController.text = data.pincode;
//
//     // Load owner documents
//     _panNumberController.text = data.ownerPan;
//     _aadhaarNumberController.text = data.ownerAadhaar;
//
//     setState(() {
//       _isLoading = false;
//     });
//   }
//
//   Widget _buildTextFieldWithStatus({
//     required TextEditingController controller,
//     required String label,
//     required String fieldKey,
//     TextInputType? keyboardType,
//     int? maxLength,
//     bool isMandatory = true,
//     String? Function(String?)? validator,
//     bool showEditIcon = false,
//   }) {
//     final fieldStatus =
//         _fieldStatus[fieldKey]?.status ?? FieldStatus.notVerified;
//     final isPending = fieldStatus == FieldStatus.pending;
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Expanded(child: Text("$label ${isMandatory ? '*' : ''}")),
//             if (showEditIcon && _isEditable && isPending)
//               IconButton(
//                 icon: const Icon(Icons.edit, size: 18),
//                 onPressed: () {
//                   // Enable editing for this field
//                   // You might want to track which fields are being edited
//                 },
//               ),
//           ],
//         ),
//         const SizedBox(height: 4),
//         TextFormField(
//           controller: controller,
//           keyboardType: keyboardType,
//           maxLength: maxLength,
//           enabled: _isEditable,
//           // Control editability based on overall status
//           readOnly: !_isEditable,
//           // Make read-only if not editable
//           style: TextStyle(
//             color: _isEditable ? Colors.black : Colors.grey[700],
//           ),
//           onChanged: (value) {
//             if (_fieldStatus[fieldKey]?.status != FieldStatus.notVerified) {
//               _updateFieldStatus(fieldKey, FieldStatus.notVerified);
//             }
//           },
//           validator: validator,
//           decoration: InputDecoration(
//             border: const OutlineInputBorder(),
//             hintText: "Enter $label",
//             counterText: "",
//             filled: !_isEditable,
//             fillColor: !_isEditable ? Colors.grey[100] : null,
//           ),
//         ),
//         const SizedBox(height: 12),
//       ],
//     );
//   }
//
//   Widget _buildUploadContainerWithStatus({
//     required File? file,
//     required VoidCallback onTap,
//     required String fieldKey,
//     required String label,
//     bool isMandatory = true,
//     String? existingImageUrl,
//   }) {
//     final fieldStatus =
//         _fieldStatus[fieldKey]?.status ?? FieldStatus.notVerified;
//     final isPending = fieldStatus == FieldStatus.pending;
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Expanded(child: Text("$label ${isMandatory ? '*' : ''}")),
//             if (_isEditable && isPending)
//               IconButton(
//                 icon: const Icon(Icons.edit, size: 18),
//                 onPressed: () => onTap(),
//               ),
//           ],
//         ),
//         const SizedBox(height: 4),
//         InkWell(
//           onTap: _isEditable ? onTap : null,
//           child: Container(
//             height: 120,
//             width: double.infinity,
//             decoration: BoxDecoration(
//               border: Border.all(
//                 color: _isEditable ? Colors.grey : Colors.grey[300]!,
//               ),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: _buildImageContent(
//               file: file,
//               existingImageUrl: existingImageUrl,
//               isEditable: _isEditable,
//             ),
//           ),
//         ),
//         const SizedBox(height: 12),
//       ],
//     );
//   }
//
//   Widget _buildImageContent({
//     required File? file,
//     required String? existingImageUrl,
//     required bool isEditable,
//   }) {
//     if (file != null) {
//       return kIsWeb
//           ? Image.network(file.path, fit: BoxFit.cover)
//           : Image.file(file, fit: BoxFit.cover);
//     } else if (existingImageUrl != null && existingImageUrl.isNotEmpty) {
//       return Image.network(
//         existingImageUrl,
//         fit: BoxFit.cover,
//         loadingBuilder: (context, child, loadingProgress) {
//           if (loadingProgress == null) return child;
//           return Center(
//             child: CircularProgressIndicator(
//               value: loadingProgress.expectedTotalBytes != null
//                   ? loadingProgress.cumulativeBytesLoaded /
//                         loadingProgress.expectedTotalBytes!
//                   : null,
//             ),
//           );
//         },
//         errorBuilder: (context, error, stackTrace) {
//           return _buildUploadPlaceholder(isEditable: isEditable);
//         },
//       );
//     } else {
//       return _buildUploadPlaceholder(isEditable: isEditable);
//     }
//   }
//
//   Widget _buildUploadPlaceholder({required bool isEditable}) {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Icon(
//           Icons.upload_file,
//           size: 40,
//           color: isEditable ? Colors.grey : Colors.grey[300],
//         ),
//         const SizedBox(height: 8),
//         Text(
//           "Upload ${isEditable ? 'or View' : 'View'}",
//           style: TextStyle(color: isEditable ? Colors.grey : Colors.grey[400]),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildDropdownWithStatus({
//     required String? value,
//     required List<String> items,
//     required Function(String?) onChanged,
//     required String label,
//     required String fieldKey,
//     bool isMandatory = true,
//   }) {
//     final fieldStatus =
//         _fieldStatus[fieldKey]?.status ?? FieldStatus.notVerified;
//     final isPending = fieldStatus == FieldStatus.pending;
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Expanded(child: Text("$label ${isMandatory ? '*' : ''}")),
//             if (_isEditable && isPending)
//               IconButton(
//                 icon: const Icon(Icons.edit, size: 18),
//                 onPressed: () {
//                   // Enable editing for dropdown
//                 },
//               ),
//           ],
//         ),
//         const SizedBox(height: 4),
//         DropdownButtonFormField<String>(
//           decoration: InputDecoration(
//             border: const OutlineInputBorder(),
//             contentPadding: const EdgeInsets.symmetric(
//               horizontal: 12,
//               vertical: 16,
//             ),
//             filled: !_isEditable,
//             fillColor: !_isEditable ? Colors.grey[100] : null,
//           ),
//           initialValue: value,
//           items: items
//               .map((e) => DropdownMenuItem(value: e, child: Text(e)))
//               .toList(),
//           onChanged: _isEditable
//               ? (val) {
//                   onChanged(val);
//                   if (_fieldStatus[fieldKey]?.status !=
//                       FieldStatus.notVerified) {
//                     _updateFieldStatus(fieldKey, FieldStatus.notVerified);
//                   }
//                 }
//               : null,
//           hint: Text("Select $label"),
//           isExpanded: true,
//           style: TextStyle(
//             color: _isEditable ? Colors.black : Colors.grey[700],
//           ),
//         ),
//         const SizedBox(height: 12),
//       ],
//     );
//   }
//
//   Widget _buildDatePickerWithStatus({
//     required DateTime? date,
//     required Function(DateTime) onDateSelected,
//     required String label,
//     required String fieldKey,
//     bool isMandatory = true,
//   }) {
//     final fieldStatus =
//         _fieldStatus[fieldKey]?.status ?? FieldStatus.notVerified;
//     final isPending = fieldStatus == FieldStatus.pending;
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Expanded(child: Text("$label ${isMandatory ? '*' : ''}")),
//             if (_isEditable && isPending)
//               IconButton(
//                 icon: const Icon(Icons.edit, size: 18),
//                 onPressed: () async {
//                   final DateTime? picked = await showDatePicker(
//                     context: context,
//                     initialDate: DateTime.now(),
//                     firstDate: DateTime(1900),
//                     lastDate: DateTime.now(),
//                   );
//                   if (picked != null) {
//                     onDateSelected(picked);
//                   }
//                 },
//               ),
//           ],
//         ),
//         const SizedBox(height: 4),
//         InkWell(
//           onTap: _isEditable
//               ? () async {
//                   final DateTime? picked = await showDatePicker(
//                     context: context,
//                     initialDate: date ?? DateTime.now(),
//                     firstDate: DateTime(1900),
//                     lastDate: DateTime.now(),
//                   );
//                   if (picked != null) {
//                     onDateSelected(picked);
//                     if (_fieldStatus[fieldKey]?.status !=
//                         FieldStatus.notVerified) {
//                       _updateFieldStatus(fieldKey, FieldStatus.notVerified);
//                     }
//                   }
//                 }
//               : null,
//           child: Container(
//             height: 56,
//             padding: const EdgeInsets.symmetric(horizontal: 12),
//             decoration: BoxDecoration(
//               border: Border.all(
//                 color: _isEditable ? Colors.grey : Colors.grey[300]!,
//               ),
//               borderRadius: BorderRadius.circular(8),
//               color: !_isEditable ? Colors.grey[100] : null,
//             ),
//             alignment: Alignment.centerLeft,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   date != null
//                       ? "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}"
//                       : "Select Date",
//                   style: TextStyle(
//                     color: date != null
//                         ? (_isEditable ? Colors.black : Colors.grey[700])
//                         : Colors.grey,
//                   ),
//                 ),
//                 Icon(
//                   Icons.calendar_today,
//                   size: 20,
//                   color: _isEditable ? Colors.grey : Colors.grey[400],
//                 ),
//               ],
//             ),
//           ),
//         ),
//         const SizedBox(height: 12),
//       ],
//     );
//   }
//
//   void _updateFieldStatus(
//     String fieldKey,
//     FieldStatus status, {
//     String? message,
//   }) {
//     if (_isEditable) {
//       setState(() {
//         _fieldStatus[fieldKey] = FieldStatusInfo(
//           status: status,
//           message: message,
//           lastUpdated: DateTime.now(),
//         );
//       });
//     }
//   }
//
//   Future<void> _pickImage({
//     required void Function(File) onSelected,
//     required String purpose,
//     ImageSource source = ImageSource.gallery,
//     int quality = 75,
//     int maxWidth = 1200,
//     int maxHeight = 1200,
//   }) async {
//     final file = await MediaUtils.pickAndCompressImage(
//       purpose: purpose,
//       source: source,
//       quality: quality,
//       maxWidth: maxWidth,
//       maxHeight: maxHeight,
//     );
//
//     if (file != null && mounted) {
//       setState(() => onSelected(file));
//     }
//   }
//
//   Widget _buildReviewItem(
//     String label,
//     String value, {
//     bool isImage = false,
//     File? file,
//     String? fieldKey,
//   }) {
//     if (isImage) {
//       return Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
//           const SizedBox(height: 6),
//           file != null
//               ? Container(
//                   height: 100,
//                   width: 100,
//                   decoration: BoxDecoration(
//                     border: Border.all(color: Colors.grey),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: kIsWeb
//                       ? Image.network(file.path, fit: BoxFit.cover)
//                       : Image.file(file, fit: BoxFit.cover),
//                 )
//               : const Text(
//                   "No file uploaded",
//                   style: TextStyle(color: Colors.red),
//                 ),
//           const Divider(),
//         ],
//       );
//     }
//
//     // ✅ THIS WAS MISSING
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
//         const SizedBox(height: 4),
//         Text(value.isNotEmpty ? value : "N/A"),
//         const Divider(),
//       ],
//     );
//   }
//
//   // Update the Step 1 builder to include edit icons for pending fields
//   Widget _buildStepFields(int step) {
//     if (_isLoading) {
//       return const Center(child: CircularProgressIndicator());
//     }
//
//     // Check overall status and show banner
//     if (_existingStatus != null) {
//       switch (_existingStatus) {
//         case 'PENDING':
//           break;
//         case 'REJECTED':
//           break;
//         case 'APPROVED':
//           break;
//         case 'RE_SUBMITTED':
//           break;
//         default:
//       }
//     }
//
//     if (step == 4 && widget.existingData != null) {
//       return const Center(
//         child: Text("Review step not available for existing submission"),
//       );
//     }
//
//     switch (step) {
//       case 0: // Owner Info
//         return SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 "Owner Information",
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 20),
//
//               _buildTextFieldWithStatus(
//                 controller: _fullNameController,
//                 label: "Owner Full Name",
//                 fieldKey: 'ownerFullName',
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Full name is required';
//                   }
//                   if (value.length < 3) {
//                     return 'Name must be at least 3 characters';
//                   }
//                   return null;
//                 },
//               ),
//
//               _buildTextFieldWithStatus(
//                 controller: _mobileController,
//                 label: "Owner Mobile Number",
//                 fieldKey: 'ownerMobile',
//                 keyboardType: TextInputType.phone,
//                 maxLength: 10,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Mobile number is required';
//                   }
//                   if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value)) {
//                     return 'Enter valid 10-digit mobile number';
//                   }
//                   return null;
//                 },
//               ),
//
//               _buildTextFieldWithStatus(
//                 controller: _emailController,
//                 label: "Owner Email",
//                 fieldKey: 'ownerEmail',
//                 keyboardType: TextInputType.emailAddress,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Email is required';
//                   }
//                   if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value)) {
//                     return 'Enter valid email address';
//                   }
//                   return null;
//                 },
//               ),
//
//               _buildDatePickerWithStatus(
//                 date: _dobController,
//                 onDateSelected: (date) {
//                   setState(() {
//                     _dobController = date;
//                   });
//                 },
//                 label: "Date of Birth",
//                 fieldKey: 'ownerDob',
//               ),
//
//               _buildTextFieldWithStatus(
//                 controller: _ownerAddressController,
//                 label: "Owner Address",
//                 fieldKey: 'ownerAddress',
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Owner address is required';
//                   }
//                   return null;
//                 },
//               ),
//
//               // Owner Selfie Upload
//               // Column(
//               //   crossAxisAlignment: CrossAxisAlignment.start,
//               //   children: [
//               //     Row(children: [const Text("Owner Selfie *")]),
//               //     const SizedBox(height: 4),
//
//               // InkWell(
//               //   onTap: () => _pickImage(
//               //     purpose: "Owner Selfie",
//               //     quality: 65,
//               //     // adjust for compression
//               //     maxWidth: 1200,
//               //     maxHeight: 1200,
//               //     onSelected: (file) => _ownerSelfieFile = file,
//               //   ),
//               //   child: Container(
//               //     height: 120,
//               //     width: 120,
//               //     decoration: BoxDecoration(
//               //       border: Border.all(color: Colors.grey),
//               //       borderRadius: BorderRadius.circular(8),
//               //     ),
//               //     child: _ownerSelfieFile != null
//               //         ? kIsWeb
//               //               ? Image.network(
//               //                   _ownerSelfieFile!.path,
//               //                   fit: BoxFit.cover,
//               //                 )
//               //               : Image.file(
//               //                   _ownerSelfieFile!,
//               //                   fit: BoxFit.cover,
//               //                 )
//               //         : const Column(
//               //             mainAxisAlignment: MainAxisAlignment.center,
//               //             children: [
//               //               Icon(
//               //                 Icons.add_a_photo,
//               //                 size: 40,
//               //                 color: Colors.grey,
//               //               ),
//               //               SizedBox(height: 8),
//               //               Text("Upload Selfie"),
//               //             ],
//               //           ),
//               //   ),
//               // ),
//               _buildUploadContainerWithStatus(
//                 file: _ownerSelfieFile,
//                 existingImageUrl: _ownerSelfieUrl,
//                 onTap: () => _pickImage(
//                   purpose: "Owner Selfie",
//                   quality: 65,
//                   // adjust for compression
//                   maxWidth: 1200,
//                   maxHeight: 1200,
//                   onSelected: (file) => _ownerSelfieFile = file,
//                 ),
//                 fieldKey: 'Owner Selfie',
//                 label: "Owner Selfie",
//               ),
//
//               //     const SizedBox(height: 12),
//               //   ],
//               // ),
//               const SizedBox(height: 20),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.green,
//                       foregroundColor: Colors.white,
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 32,
//                         vertical: 14,
//                       ),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       elevation: 3,
//                     ),
//                     onPressed: () {
//                       // Validate step 0
//                       if (_fullNameController.text.isEmpty ||
//                           _mobileController.text.length != 10 ||
//                           !RegExp(
//                             r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
//                           ).hasMatch(_emailController.text) ||
//                           _dobController == null ||
//                           _ownerAddressController.text.isEmpty ||
//                           _ownerSelfieFile == null) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(
//                             content: Text("Please fill all required fields"),
//                           ),
//                         );
//                         return;
//                       }
//
//                       setState(() => _currentStep = 1);
//                     },
//                     child: const Text("Next"),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         );
//
//       case 1: // Business Details
//         return SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 "Business Details",
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 20),
//
//               _buildTextFieldWithStatus(
//                 controller: _companyNameController,
//                 label: "Company Name",
//                 fieldKey: 'companyName',
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Company name is required';
//                   }
//                   return null;
//                 },
//               ),
//
//               _buildDropdownWithStatus(
//                 value: _selectedCompanyType,
//                 items: const [
//                   "PROPRIETORSHIP",
//                   "PARTNERSHIP",
//                   "LLP",
//                   "PRIVATE_LIMITED",
//                 ],
//                 onChanged: (val) {
//                   setState(() {
//                     _selectedCompanyType = val;
//                   });
//                 },
//                 label: "Company Type",
//                 fieldKey: 'businessType',
//               ),
//
//               _buildTextFieldWithStatus(
//                 controller: _companyPanController,
//                 label: "Company PAN",
//                 fieldKey: 'companyPan',
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Company PAN is required';
//                   }
//                   if (!RegExp(
//                     r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$',
//                   ).hasMatch(value.toUpperCase())) {
//                     return 'Enter valid PAN number (Format: ABCDE1234F)';
//                   }
//                   return null;
//                 },
//               ),
//
//               _buildUploadContainerWithStatus(
//                 file: _companyPanDoc,
//                 existingImageUrl: _companyPanUrl,
//                 onTap: () => _pickImage(
//                   purpose: "Company PAN Document",
//                   quality: 65,
//                   // adjust for compression
//                   maxWidth: 1200,
//                   maxHeight: 1200,
//                   onSelected: (file) => _companyPanDoc = file,
//                 ),
//                 fieldKey: 'companyPanDocument',
//                 label: "Company PAN Document",
//               ),
//               _buildTextFieldWithStatus(
//                 controller: _companyGstController,
//                 label: "GSTIN",
//                 fieldKey: 'gstin',
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'GSTIN is required';
//                   }
//                   return null;
//                 },
//               ),
//
//               _buildUploadContainerWithStatus(
//                 file: _companyGstDoc,
//                 existingImageUrl: _companyGstUrl,
//                 onTap: () => _pickImage(
//                   purpose: "GST Certificate",
//                   quality: 65,
//                   // adjust for compression
//                   maxWidth: 1200,
//                   maxHeight: 1200,
//                   onSelected: (file) => _companyGstDoc = file,
//                 ),
//                 fieldKey: 'gstCertificate',
//                 label: "GST Certificate",
//               ),
//
//               _buildTextFieldWithStatus(
//                 controller: _cinController,
//                 label: "CIN",
//                 fieldKey: 'cin',
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'CIN is required';
//                   }
//                   return null;
//                 },
//               ),
//
//               _buildTextFieldWithStatus(
//                 controller: _tradeLicenseNumberController,
//                 label: "Trade License Number",
//                 fieldKey: 'tradeLicenseNumber',
//               ),
//
//               _buildUploadContainerWithStatus(
//                 file: _tradeLicenseDoc,
//                 existingImageUrl: _tradeLicenseUrl,
//                 onTap: () => _pickImage(
//                   purpose: "Trade License Document",
//                   quality: 65,
//                   // adjust for compression
//                   maxWidth: 1200,
//                   maxHeight: 1200,
//                   onSelected: (file) => _tradeLicenseDoc = file,
//                 ),
//                 fieldKey: 'tradeLicense',
//                 label: "Trade License Document",
//               ),
//
//               // _buildTextFieldWithStatus(
//               //   controller: _incorporationNumberController,
//               //   label: "Incorporation Number",
//               //   fieldKey: 'incorporationNumber',
//               // ),
//               _buildUploadContainerWithStatus(
//                 file: _incorporationCertificateDoc,
//                 existingImageUrl: _incorporationCertUrl,
//                 onTap: () => _pickImage(
//                   purpose: "Incorporation Certificate",
//                   quality: 65,
//                   // adjust for compression
//                   maxWidth: 1200,
//                   maxHeight: 1200,
//                   onSelected: (file) => _incorporationCertificateDoc = file,
//                 ),
//                 fieldKey: 'incorporationCertificate',
//                 label: "Incorporation Certificate",
//               ),
//
//               const SizedBox(height: 20),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.blueAccent,
//                       foregroundColor: Colors.white,
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 32,
//                         vertical: 14,
//                       ),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       elevation: 3,
//                     ),
//                     onPressed: () {
//                       setState(() {
//                         _currentStep = 0;
//                       });
//                     },
//                     child: const Text("Back"),
//                   ),
//                   ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.green,
//                       foregroundColor: Colors.white,
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 32,
//                         vertical: 14,
//                       ),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       elevation: 3,
//                     ),
//                     onPressed: () {
//                       // Validate step 1
//                       if (_companyNameController.text.isEmpty ||
//                           _selectedCompanyType == null ||
//                           _companyPanController.text.isEmpty ||
//                           _companyPanDoc == null ||
//                           _companyGstController.text.isEmpty ||
//                           _companyGstDoc == null ||
//                           _cinController.text.isEmpty) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(
//                             content: Text(
//                               "Please fill all required business details",
//                             ),
//                           ),
//                         );
//                         return;
//                       }
//
//                       setState(() {
//                         _currentStep = 2;
//                       });
//                     },
//                     child: const Text("Next"),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         );
//
//       case 2: // Address
//         return SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 "Business Address",
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 20),
//
//               _buildTextFieldWithStatus(
//                 controller: _registeredAddressController,
//                 label: "Registered Address",
//                 fieldKey: 'registeredAddress',
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Registered address is required';
//                   }
//                   return null;
//                 },
//               ),
//
//               _buildTextFieldWithStatus(
//                 controller: _cityController,
//                 label: "City",
//                 fieldKey: 'city',
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'City is required';
//                   }
//                   return null;
//                 },
//               ),
//
//               _buildTextFieldWithStatus(
//                 controller: _pincodeController,
//                 label: "Pincode",
//                 fieldKey: 'pincode',
//                 keyboardType: TextInputType.number,
//                 maxLength: 6,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Pincode is required';
//                   }
//                   if (!RegExp(r'^\d{6}$').hasMatch(value)) {
//                     return 'Enter valid 6-digit pincode';
//                   }
//                   return null;
//                 },
//               ),
//
//               _buildTextFieldWithStatus(
//                 controller: _stateController,
//                 label: "State",
//                 fieldKey: 'state',
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'State is required';
//                   }
//                   return null;
//                 },
//               ),
//
//               const SizedBox(height: 20),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.blueAccent,
//                       foregroundColor: Colors.white,
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 32,
//                         vertical: 14,
//                       ),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       elevation: 3,
//                     ),
//                     onPressed: () {
//                       setState(() {
//                         _currentStep = 1;
//                       });
//                     },
//                     child: const Text("Back"),
//                   ),
//                   ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.green,
//                       foregroundColor: Colors.white,
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 32,
//                         vertical: 14,
//                       ),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       elevation: 3,
//                     ),
//                     onPressed: () {
//                       if (_registeredAddressController.text.isEmpty ||
//                           _cityController.text.isEmpty ||
//                           _pincodeController.text.length != 6 ||
//                           _stateController.text.isEmpty) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(
//                             content: Text(
//                               "Please fill all mandatory address fields",
//                             ),
//                           ),
//                         );
//                         return;
//                       }
//                       setState(() {
//                         _currentStep = 3;
//                       });
//                     },
//                     child: const Text("Next"),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         );
//
//       case 3: // Required Documents
//         return SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 "Required Documents",
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 20),
//
//               const Text(
//                 "Aadhaar Details",
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 10),
//
//               _buildTextFieldWithStatus(
//                 controller: _aadhaarNumberController,
//                 label: "Aadhaar Number",
//                 fieldKey: 'ownerAadhaar',
//                 keyboardType: TextInputType.number,
//                 maxLength: 12,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Aadhaar number is required';
//                   }
//                   if (!RegExp(r'^\d{12}$').hasMatch(value)) {
//                     return 'Enter valid 12-digit Aadhaar number';
//                   }
//                   return null;
//                 },
//               ),
//
//               _buildUploadContainerWithStatus(
//                 file: _aadhaarFront,
//                 existingImageUrl: _ownerAadhaarUrl,
//                 onTap: () => _pickImage(
//                   purpose: "Aadhaar Document",
//                   quality: 65,
//                   // adjust for compression
//                   maxWidth: 1200,
//                   maxHeight: 1200,
//                   onSelected: (file) => _aadhaarFront = file,
//                 ),
//                 fieldKey: 'ownerAadhaarDocument',
//                 label: "Aadhaar Document",
//               ),
//
//               const SizedBox(height: 20),
//               const Text(
//                 "PAN Details",
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 10),
//
//               _buildTextFieldWithStatus(
//                 controller: _panNumberController,
//                 label: "PAN Number",
//                 fieldKey: 'ownerPan',
//                 maxLength: 10,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'PAN number is required';
//                   }
//                   if (!RegExp(
//                     r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$',
//                   ).hasMatch(value.toUpperCase())) {
//                     return 'Enter valid PAN number (Format: ABCDE1234F)';
//                   }
//                   return null;
//                 },
//               ),
//
//               _buildUploadContainerWithStatus(
//                 file: _panCardDoc,
//                 existingImageUrl: _ownerPanUrl,
//                 onTap: () => _pickImage(
//                   purpose: "PAN Document",
//                   quality: 65,
//                   // adjust for compression
//                   maxWidth: 1200,
//                   maxHeight: 1200,
//                   onSelected: (file) => _panCardDoc = file,
//                 ),
//                 fieldKey: 'ownerPanDocument',
//                 label: "PAN Document",
//               ),
//
//               const SizedBox(height: 20),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.blueAccent,
//                       foregroundColor: Colors.white,
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 32,
//                         vertical: 14,
//                       ),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       elevation: 3,
//                     ),
//                     onPressed: () {
//                       setState(() {
//                         _currentStep = 2;
//                       });
//                     },
//                     child: const Text("Back"),
//                   ),
//                   ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.green,
//                       foregroundColor: Colors.white,
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 32,
//                         vertical: 14,
//                       ),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       elevation: 3,
//                     ),
//                     onPressed: () {
//                       if (_aadhaarNumberController.text.isEmpty ||
//                           _aadhaarFront == null && _ownerAadhaarUrl == null ||
//                           _panNumberController.text.isEmpty ||
//                           _panCardDoc == null && _ownerPanUrl == null) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(
//                             content: Text(
//                               "Please fill/upload all mandatory document fields",
//                             ),
//                           ),
//                         );
//                         return;
//                       }
//
//                       if (widget.existingData == null) {
//                         // NEW SUBMISSION → REVIEW
//                         setState(() => _currentStep = 4);
//                       } else {
//                         // EXISTING → SUBMIT DIRECTLY
//                         _finalSubmitVendorDetails();
//                       }
//                     },
//
//                     child: const Text("Next"),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         );
//       case 4: // Review
//         return SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 "Review All Details",
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 10),
//               const Text(
//                 "Please review all details before final submission.",
//                 style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
//               ),
//               const SizedBox(height: 20),
//
//               // Owner Info
//               const Text(
//                 "📋 Owner Information",
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//               ),
//               const Divider(),
//               _buildReviewItem(
//                 "Full Name",
//                 _fullNameController.text,
//                 fieldKey: 'ownerFullName',
//               ),
//               _buildReviewItem(
//                 "Mobile",
//                 _mobileController.text,
//                 fieldKey: 'ownerMobile',
//               ),
//               _buildReviewItem(
//                 "Email",
//                 _emailController.text,
//                 fieldKey: 'ownerEmail',
//               ),
//               _buildReviewItem(
//                 "Date of Birth",
//                 _dobController != null
//                     ? "${_dobController!.day.toString().padLeft(2, '0')}/${_dobController!.month.toString().padLeft(2, '0')}/${_dobController!.year}"
//                     : 'N/A',
//               ),
//               _buildReviewItem(
//                 "Address",
//                 _ownerAddressController.text,
//                 fieldKey: 'ownerAddress',
//               ),
//               _buildReviewItem(
//                 "Owner Selfie",
//                 "",
//                 isImage: true,
//                 file: _ownerSelfieFile,
//                 fieldKey: 'ownerSelfie',
//               ),
//
//               // Business Details
//               const SizedBox(height: 20),
//               const Text(
//                 "🏢 Business Details",
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//               ),
//               const Divider(),
//               _buildReviewItem(
//                 "Company Name",
//                 _companyNameController.text,
//                 fieldKey: 'companyName',
//               ),
//               _buildReviewItem(
//                 "Business Type",
//                 _selectedCompanyType ?? 'N/A',
//                 fieldKey: 'businessType',
//               ),
//               _buildReviewItem(
//                 "Company PAN",
//                 _companyPanController.text,
//                 fieldKey: 'companyPan',
//               ),
//               _buildReviewItem(
//                 "Company PAN Document",
//                 "",
//                 isImage: true,
//                 file: _companyPanDoc,
//                 fieldKey: 'companyPanDocument',
//               ),
//               _buildReviewItem(
//                 "GSTIN",
//                 _companyGstController.text,
//                 fieldKey: 'gstin',
//               ),
//               _buildReviewItem(
//                 "GST Certificate",
//                 "",
//                 isImage: true,
//                 file: _companyGstDoc,
//                 fieldKey: 'gstCertificate',
//               ),
//               _buildReviewItem("CIN", _cinController.text, fieldKey: 'cin'),
//               _buildReviewItem(
//                 "Trade License Document",
//                 "",
//                 isImage: true,
//                 file: _tradeLicenseDoc,
//                 fieldKey: 'tradeLicense',
//               ),
//               _buildReviewItem(
//                 "Incorporation Certificate",
//                 "",
//                 isImage: true,
//                 file: _incorporationCertificateDoc,
//                 fieldKey: 'incorporationCertificate',
//               ),
//
//               // Address
//               const SizedBox(height: 20),
//               const Text(
//                 "📍 Business Address",
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//               ),
//               const Divider(),
//               _buildReviewItem(
//                 "Registered Address",
//                 _registeredAddressController.text,
//                 fieldKey: 'registeredAddress',
//               ),
//               _buildReviewItem("City", _cityController.text, fieldKey: 'city'),
//               _buildReviewItem(
//                 "State",
//                 _stateController.text,
//                 fieldKey: 'state',
//               ),
//               _buildReviewItem(
//                 "Pincode",
//                 _pincodeController.text,
//                 fieldKey: 'pincode',
//               ),
//
//               // Owner Documents
//               const SizedBox(height: 20),
//               const Text(
//                 "📄 Owner Documents",
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//               ),
//               const Divider(),
//               _buildReviewItem(
//                 "Owner PAN",
//                 _panNumberController.text,
//                 fieldKey: 'ownerPan',
//               ),
//               _buildReviewItem(
//                 "Owner PAN Document",
//                 "",
//                 isImage: true,
//                 file: _panCardDoc,
//                 fieldKey: 'ownerPanDocument',
//               ),
//               _buildReviewItem(
//                 "Owner Aadhaar",
//                 _aadhaarNumberController.text,
//                 fieldKey: 'ownerAadhaar',
//               ),
//               _buildReviewItem(
//                 "Owner Aadhaar Document",
//                 "",
//                 isImage: true,
//                 file: _aadhaarFront,
//                 fieldKey: 'ownerAadhaarDocument',
//               ),
//
//               const SizedBox(height: 20),
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: Colors.orange[50],
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(color: Colors.orange),
//                 ),
//                 child: const Text(
//                   "Note: All required fields must be filled before submission.\nOptional documents can be uploaded later if needed.",
//                   style: TextStyle(fontSize: 12, color: Colors.orange),
//                 ),
//               ),
//
//               const SizedBox(height: 20),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.blueAccent,
//                       foregroundColor: Colors.white,
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 32,
//                         vertical: 14,
//                       ),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       elevation: 3,
//                     ),
//                     onPressed: () {
//                       setState(() {
//                         _currentStep = 3;
//                       });
//                     },
//                     child: const Text("Back"),
//                   ),
//                   ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.green,
//                       foregroundColor: Colors.white,
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 32,
//                         vertical: 14,
//                       ),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       elevation: 3,
//                     ),
//                     onPressed: () async {
//                       // First run debug check
//                       _debugCheckEmptyFields();
//
//                       if (!_validateAllFields()) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(
//                             content: Text(
//                               "Please fill all required fields correctly",
//                             ),
//                             backgroundColor: Colors.orange,
//                           ),
//                         );
//                         return;
//                       }
//
//                       await _finalSubmitVendorDetails();
//                     },
//                     child: const Text("Final Submit"),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 20),
//             ],
//           ),
//         );
//
//       default:
//         return const Center(child: Text("Invalid step"));
//     }
//   }
//
//   // Future<void> _finalSubmitVendorDetails() async {
//   //   try {
//   //     if (!_validateAllFields()) {
//   //       ScaffoldMessenger.of(context).showSnackBar(
//   //         const SnackBar(
//   //           content: Text("Please fill all required fields correctly"),
//   //           backgroundColor: Colors.orange,
//   //         ),
//   //       );
//   //       return;
//   //     }
//   //
//   //     final prefs = await SharedPreferences.getInstance();
//   //     final userId = prefs.getInt('userId') ?? 0;
//   //
//   //     String? formattedDob;
//   //     if (_dobController != null) {
//   //       formattedDob =
//   //           "${_dobController!.year}-${_dobController!.month.toString().padLeft(2, '0')}-${_dobController!.day.toString().padLeft(2, '0')}";
//   //     }
//   //
//   //     // Determine if this is an update or new submission
//   //     final isUpdate = widget.existingData != null;
//   //     final Map<String, dynamic> companyData = {
//   //       // Company Details
//   //       "companyName": _companyNameController.text.trim(),
//   //       "businessType": _selectedCompanyType ?? "",
//   //       "companyPan": _companyPanController.text.trim(),
//   //       "gstin": _companyGstController.text.trim(),
//   //       "cin": _cinController.text.trim(),
//   //       "registeredAddress": _registeredAddressController.text.trim(),
//   //       "city": _cityController.text.trim(),
//   //       "state": _stateController.text.trim(),
//   //       "pincode": _pincodeController.text.trim(),
//   //
//   //       // Owner Details
//   //       "ownerFullName": _fullNameController.text.trim(),
//   //       "ownerDob": formattedDob,
//   //       "ownerPan": _panNumberController.text.trim(),
//   //       "ownerAadhaar": _aadhaarNumberController.text.trim(),
//   //       "ownerMobile": _mobileController.text.trim(),
//   //       "ownerEmail": _emailController.text.trim(),
//   //       "ownerAddress": _ownerAddressController.text.trim(),
//   //
//   //       // Optional fields
//   //       if (_tradeLicenseNumberController.text.isNotEmpty)
//   //         "tradeLicense": _tradeLicenseNumberController.text.trim(),
//   //       if (_incorporationNumberController.text.isNotEmpty)
//   //         "incorporationNumber": _incorporationNumberController.text.trim(),
//   //
//   //       // Metadata
//   //       "userId": userId,
//   //       "verificationStatus": isUpdate ? "RE_SUBMITTED" : "PENDING",
//   //       "submittedAt": DateTime.now().toUtc().toIso8601String(),
//   //     };
//   //
//   //     // Prepare files
//   //     final Map<String, File> files = {};
//   //     if (_companyPanDoc != null) files["companyPanDocument"] = _companyPanDoc!;
//   //     if (_companyGstDoc != null) files["gstCertificate"] = _companyGstDoc!;
//   //     if (_incorporationCertificateDoc != null)
//   //       files["incorporationCertificate"] = _incorporationCertificateDoc!;
//   //     if (_tradeLicenseDoc != null) files["tradeLicense"] = _tradeLicenseDoc!;
//   //     if (_panCardDoc != null) files["ownerPanDocument"] = _panCardDoc!;
//   //     if (_ownerSelfieFile != null) files["ownerSelfie"] = _ownerSelfieFile!;
//   //     if (_aadhaarFront != null) files["ownerAadhaarDocument"] = _aadhaarFront!;
//   //
//   //     // Show loading
//   //     showDialog(
//   //       context: context,
//   //       barrierDismissible: false,
//   //       builder: (context) => const Center(child: CircularProgressIndicator()),
//   //     );
//   //
//   //     final response = await ApiClient.sendMultipartRequest(
//   //       service: "subscription",
//   //       endpoint: isUpdate
//   //           ? "api/company/verification/$userId" // Update endpoint
//   //           : "api/user/company/verification",
//   //       // Create endpoint
//   //       method: isUpdate ? "PUT" : "POST",
//   //       data: isUpdate
//   //           ? {'updateData': jsonEncode(companyData)}
//   //           : {'companyData': jsonEncode(companyData)},
//   //       files: files,
//   //     );
//   //
//   //     if (mounted && Navigator.of(context).canPop()) {
//   //       Navigator.of(context).pop();
//   //     }
//   //
//   //     if (response.statusCode == 200 || response.statusCode == 201) {
//   //       final responseBody = jsonDecode(response.body);
//   //
//   //       ScaffoldMessenger.of(context).showSnackBar(
//   //         SnackBar(
//   //           content: Text(
//   //             responseBody['message'] ??
//   //                 (isUpdate
//   //                     ? "Details updated successfully"
//   //                     : "Company details submitted successfully"),
//   //           ),
//   //           backgroundColor: Colors.green,
//   //           duration: const Duration(seconds: 3),
//   //         ),
//   //       );
//   //
//   //       // Refresh the data
//   //       await _fetchExistingVerification();
//   //
//   //       // Navigate back or to verification view
//   //       if (mounted) {
//   //         Navigator.pop(context);
//   //       }
//   //     } else {
//   //       String errorMessage = "Error ${response.statusCode}";
//   //       if (response.body.isNotEmpty) {
//   //         try {
//   //           final error = jsonDecode(response.body);
//   //           errorMessage = error['message'] ?? errorMessage;
//   //         } catch (e) {
//   //           // Ignore parse error
//   //         }
//   //       }
//   //
//   //       ScaffoldMessenger.of(context).showSnackBar(
//   //         SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
//   //       );
//   //     }
//   //   } catch (e) {
//   //     if (mounted && Navigator.of(context).canPop()) {
//   //       Navigator.of(context).pop();
//   //     }
//   //
//   //     ScaffoldMessenger.of(context).showSnackBar(
//   //       SnackBar(
//   //         content: Text("Error: ${e.toString()}"),
//   //         backgroundColor: Colors.red,
//   //       ),
//   //     );
//   //   }
//   // }
//   Future<void> _finalSubmitVendorDetails() async {
//     debugLog("🚀 ===== SUBMISSION STARTED =====");
//
//     try {
//       // 1️⃣ VALIDATION
//       debugLog("🧪 Validating fields...");
//       if (!_validateAllFields()) {
//         debugLog("❌ Validation failed");
//
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text("Please fill all required fields correctly"),
//               backgroundColor: Colors.orange,
//             ),
//           );
//         }
//         return;
//       }
//       debugLog("✅ Validation passed");
//
//       // 2️⃣ USER ID
//       final prefs = await SharedPreferences.getInstance();
//       final userId = prefs.getInt('userId') ?? 0;
//       debugLog("👤 User ID: $userId");
//
//       // 3️⃣ DOB FORMAT
//       String? formattedDob;
//       if (_dobController != null) {
//         formattedDob =
//             "${_dobController!.year}-${_dobController!.month.toString().padLeft(2, '0')}-${_dobController!.day.toString().padLeft(2, '0')}";
//       }
//       debugLog("📅 DOB: $formattedDob");
//
//       // 4️⃣ TEXT DATA
//       final Map<String, dynamic> companyData = {
//         "companyName": _companyNameController.text.trim(),
//         "businessType": _selectedCompanyType ?? "",
//         "companyPan": _companyPanController.text.trim(),
//         "gstin": _companyGstController.text.trim(),
//         "cin": _cinController.text.trim(),
//         "registeredAddress": _registeredAddressController.text.trim(),
//         "city": _cityController.text.trim(),
//         "state": _stateController.text.trim(),
//         "pincode": _pincodeController.text.trim(),
//         "ownerFullName": _fullNameController.text.trim(),
//         "ownerDob": formattedDob,
//         "ownerPan": _panNumberController.text.trim(),
//         "ownerAadhaar": _aadhaarNumberController.text.trim(),
//         "ownerMobile": _mobileController.text.trim(),
//         "ownerEmail": _emailController.text.trim(),
//         "ownerAddress": _ownerAddressController.text.trim(),
//         if (_tradeLicenseNumberController.text.isNotEmpty)
//           "tradeLicenseNumber": _tradeLicenseNumberController.text.trim(),
//         if (_incorporationNumberController.text.isNotEmpty)
//           "incorporationNumber": _incorporationNumberController.text.trim(),
//         "userId": userId,
//         "verificationStatus": "PENDING",
//         "submittedAt": DateTime.now().toUtc().toIso8601String(),
//       };
//
//       debugLog("📊 TEXT FIELDS:");
//       companyData.forEach((k, v) => debugLog("   $k => $v"));
//
//       // 5️⃣ FILES
//       final Map<String, File> files = {};
//
//       void addFile(String key, File? file) {
//         if (file != null) {
//           files[key] = file;
//           debugLog("📎 File attached: $key → ${file.path}");
//         } else {
//           debugLog("⚠️ File missing: $key");
//         }
//       }
//
//       addFile("companyPanDocument", _companyPanDoc);
//       addFile("gstCertificate", _companyGstDoc);
//       addFile("incorporationCertificate", _incorporationCertificateDoc);
//       addFile("tradeLicense", _tradeLicenseDoc);
//       addFile("ownerPanDocument", _panCardDoc);
//       addFile("ownerSelfie", _ownerSelfieFile);
//       addFile("ownerAadhaarDocument", _aadhaarFront);
//
//       debugLog("📦 TOTAL FILES: ${files.length}");
//
//       // 6️⃣ LOADER
//       if (mounted) {
//         showDialog(
//           context: context,
//           barrierDismissible: false,
//           builder: (_) => const Center(child: CircularProgressIndicator()),
//         );
//       }
//
//       // 7️⃣ API CALL
//       debugLog("🌐 Sending multipart request...");
//
//       final response = await ApiClient.sendMultipartRequest(
//         service: "subscription",
//         endpoint: "api/user/company/verification",
//         method: "POST",
//         data: {'companyData': jsonEncode(companyData)},
//         files: files,
//       );
//
//       debugLog("📨 RESPONSE CODE: ${response.statusCode}");
//       debugLog("📨 RESPONSE BODY: ${response.body}");
//
//       // 8️⃣ HIDE LOADER
//       if (mounted && Navigator.of(context).canPop()) {
//         Navigator.of(context).pop();
//       }
//
//       // 9️⃣ SUCCESS
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         final responseBody = jsonDecode(response.body);
//         debugLog("✅ SUBMISSION SUCCESS");
//
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(
//                 responseBody['message'] ??
//                     "Company details submitted successfully",
//               ),
//               backgroundColor: Colors.green,
//             ),
//           );
//         }
//       } else {
//         String errorMessage = "Error ${response.statusCode}";
//         try {
//           errorMessage = jsonDecode(response.body)['message'] ?? errorMessage;
//         } catch (_) {}
//
//         debugLog("❌ API ERROR: $errorMessage");
//
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
//           );
//         }
//       }
//     } catch (e, stack) {
//       debugLog("🔥 EXCEPTION: $e");
//       debugLog("📍 STACKTRACE: $stack");
//
//       if (mounted && Navigator.of(context).canPop()) {
//         Navigator.of(context).pop();
//       }
//
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
//         );
//       }
//     } finally {
//       debugLog("🏁 ===== SUBMISSION FINISHED =====");
//     }
//   }
//
//   void debugLog(String message) {
//     if (kDebugMode) {
//       // ignore: avoid_print
//       print(message);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         title: Text(
//           widget.isEditing
//               ? " Corporate Registration"
//               : "Corporate Account Details",
//         ),
//         automaticallyImplyLeading: true,
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : Column(
//               children: [
//                 // 🔹 TOP STEP BAR (fixed height)
//                 SizedBox(
//                   height: 100, // 🔥 IMPORTANT: give height
//                   child: ListView.builder(
//                     scrollDirection: Axis.horizontal,
//                     itemCount: steps.length,
//                     itemBuilder: (context, index) {
//                       return GestureDetector(
//                         onTap: () {
//                           setState(() {
//                             _currentStep = index;
//                           });
//                         },
//                         child: Container(
//                           width: 90,
//                           margin: const EdgeInsets.symmetric(
//                             horizontal: 6,
//                             vertical: 12,
//                           ),
//                           decoration: BoxDecoration(
//                             color: _currentStep == index
//                                 ? Colors.deepPurple
//                                 : Colors.grey[200],
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               CircleAvatar(
//                                 radius: 16,
//                                 backgroundColor: _currentStep == index
//                                     ? Colors.white
//                                     : Colors.grey[300],
//                                 child: Text(
//                                   "${index + 1}",
//                                   style: TextStyle(
//                                     color: _currentStep == index
//                                         ? Colors.black
//                                         : Colors.grey[700],
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ),
//                               const SizedBox(height: 6),
//                               Text(
//                                 steps[index],
//                                 textAlign: TextAlign.center,
//                                 style: TextStyle(
//                                   fontSize: 11,
//                                   fontWeight: _currentStep == index
//                                       ? FontWeight.bold
//                                       : FontWeight.normal,
//                                   color: _currentStep == index
//                                       ? Colors.white
//                                       : Colors.grey[800],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//
//                 // 🔹 EXPANDED CONTENT
//                 Expanded(
//                   child: Padding(
//                     padding: const EdgeInsets.all(16),
//                     child: _buildStepFields(_currentStep),
//                   ),
//                 ),
//               ],
//             ),
//     );
//   }
//
//   Widget _buildStatusBanner() {
//     Color bgColor;
//     IconData icon;
//     String text;
//
//     switch (_verificationStatus.toUpperCase()) {
//       case "VERIFIED":
//         bgColor = Colors.green.shade50;
//         icon = Icons.check_circle;
//         text = "VERIFIED";
//         break;
//       case "REJECTED":
//         bgColor = Colors.red.shade50;
//         icon = Icons.cancel;
//         text = "Rejected";
//         break;
//       default:
//         bgColor = Colors.orange.shade50;
//         icon = Icons.hourglass_bottom;
//         text = "Pending Verification";
//     }
//
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       margin: const EdgeInsets.only(bottom: 12),
//       decoration: BoxDecoration(
//         color: bgColor,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Row(
//         children: [
//           Icon(icon, color: Colors.black),
//           const SizedBox(width: 8),
//           Expanded(
//             child: Text(
//               "Status: $text",
//               style: const TextStyle(fontWeight: FontWeight.bold),
//             ),
//           ),
//           _isRefreshing
//               ? const SizedBox(
//                   height: 20,
//                   width: 20,
//                   child: CircularProgressIndicator(strokeWidth: 2),
//                 )
//               : IconButton(
//                   icon: const Icon(Icons.refresh),
//                   tooltip: "Refresh Status",
//                   onPressed: _refreshVerificationStatus,
//                 ),
//         ],
//       ),
//     );
//   }
//
//   Future<void> _refreshVerificationStatus() async {
//     setState(() => _isRefreshing = true);
//
//     try {
//       await _fetchExistingVerification(); // your existing API method
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("Failed to refresh status"),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//
//     if (mounted) {
//       setState(() => _isRefreshing = false);
//     }
//   }
//
//   void _debugCheckEmptyFields() {
//     final requiredFields = [
//       'companyName',
//       'businessType',
//       'companyPan',
//       'gstin',
//       'cin',
//       'registeredAddress',
//       'city',
//       'state',
//       'pincode',
//       'ownerFullName',
//       'ownerDob',
//       'ownerPan',
//       'ownerAadhaar',
//       'ownerMobile',
//       'ownerEmail',
//       'ownerAddress',
//     ];
//
//     final fieldStatus = <String, bool>{};
//
//     // Check each required field
//     fieldStatus['companyName'] = _companyNameController.text.isNotEmpty;
//     fieldStatus['businessType'] = _selectedCompanyType != null;
//     fieldStatus['companyPan'] = _companyPanController.text.isNotEmpty;
//     fieldStatus['gstin'] = _companyGstController.text.isNotEmpty;
//     fieldStatus['cin'] = _cinController.text.isNotEmpty;
//     fieldStatus['registeredAddress'] =
//         _registeredAddressController.text.isNotEmpty;
//     fieldStatus['city'] = _cityController.text.isNotEmpty;
//     fieldStatus['state'] = _stateController.text.isNotEmpty;
//     fieldStatus['pincode'] = _pincodeController.text.isNotEmpty;
//     fieldStatus['ownerFullName'] = _fullNameController.text.isNotEmpty;
//     fieldStatus['ownerDob'] = _dobController != null;
//     fieldStatus['ownerPan'] = _panNumberController.text.isNotEmpty;
//     fieldStatus['ownerAadhaar'] = _aadhaarNumberController.text.isNotEmpty;
//     fieldStatus['ownerMobile'] = _mobileController.text.isNotEmpty;
//     fieldStatus['ownerEmail'] = _emailController.text.isNotEmpty;
//     fieldStatus['ownerAddress'] = _ownerAddressController.text.isNotEmpty;
//
//     // Check required files
//     final requiredFiles = [
//       'companyPanDocument',
//       'ownerPanDocument',
//       'ownerAadhaarDocument',
//       'ownerSelfie',
//     ];
//
//     fieldStatus['companyPanDocument'] = _companyPanDoc != null;
//     fieldStatus['ownerPanDocument'] = _panCardDoc != null;
//     fieldStatus['ownerAadhaarDocument'] = _aadhaarFront != null;
//     fieldStatus['ownerSelfie'] = _ownerSelfieFile != null;
//
//     // Print results
//     // print("\n📋 FIELD STATUS:");
//     // ignore: unused_local_variable
//     for (var field in requiredFields) {}
//
//     // print("\n📁 FILE STATUS:");
//     // ignore: unused_local_variable
//     for (var file in requiredFiles) {}
//
//     // Show missing fields
//     final missingFields = fieldStatus.entries
//         .where((entry) => !entry.value)
//         .map((entry) => entry.key)
//         .toList();
//
//     if (missingFields.isNotEmpty) {
//       // print("\n🚫 MISSING FIELDS: $missingFields");
//     } else {
//       // print("\n🎉 All fields are filled!");
//     }
//   }
//
//   bool _validateAllFields() {
//     // Validate according to API requirements
//     bool isValid = true;
//
//     // Company details validation
//     isValid = isValid && _companyNameController.text.isNotEmpty;
//     isValid = isValid && _selectedCompanyType != null;
//     isValid = isValid && _companyPanController.text.isNotEmpty;
//     isValid = isValid && _companyGstController.text.isNotEmpty;
//     isValid = isValid && _cinController.text.isNotEmpty;
//     isValid = isValid && _registeredAddressController.text.isNotEmpty;
//     isValid = isValid && _cityController.text.isNotEmpty;
//     isValid = isValid && _stateController.text.isNotEmpty;
//     isValid = isValid && _pincodeController.text.isNotEmpty;
//     isValid = isValid && RegExp(r'^\d{6}$').hasMatch(_pincodeController.text);
//
//     // Owner details validation
//     isValid = isValid && _fullNameController.text.isNotEmpty;
//     isValid = isValid && _dobController != null;
//     isValid = isValid && _panNumberController.text.isNotEmpty;
//     isValid = isValid && _aadhaarNumberController.text.isNotEmpty;
//     isValid =
//         isValid && RegExp(r'^\d{12}$').hasMatch(_aadhaarNumberController.text);
//     isValid = isValid && _mobileController.text.isNotEmpty;
//     isValid =
//         isValid && RegExp(r'^[6-9]\d{9}$').hasMatch(_mobileController.text);
//     isValid = isValid && _emailController.text.isNotEmpty;
//     isValid =
//         isValid &&
//         RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(_emailController.text);
//     isValid = isValid && _ownerAddressController.text.isNotEmpty;
//
//     // File validation
//     isValid = isValid && _companyPanDoc != null;
//     isValid = isValid && _panCardDoc != null;
//     isValid = isValid && _aadhaarFront != null;
//     isValid = isValid && _ownerSelfieFile != null;
//
//     if (!isValid) {
//       // print("❌ Validation failed - calling debug check");
//       _debugCheckEmptyFields();
//     } else {
//       // print("✅ All validations passed");
//     }
//
//     return isValid;
//   }
// }
