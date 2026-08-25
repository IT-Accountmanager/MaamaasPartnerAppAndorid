// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../API/Apiclient.dart';
// import '../../widgets/media_utils.dart';
// import '../../Models/Profissional/companyverification_model.dart';
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
// class ProfessionalUserRegistrationa extends StatefulWidget {
//   final bool isEditing;
//   final CompanyVerificationModel? existingData;
//
//   const ProfessionalUserRegistrationa({
//     Key? key,
//     this.isEditing = false,
//     this.existingData,
//   }) : super(key: key);
//
//   @override
//   State<ProfessionalUserRegistrationa> createState() =>
//       _ProfessionalUserRegistrationState();
// }
//
// class _ProfessionalUserRegistrationState
//     extends State<ProfessionalUserRegistrationa> {
//   int _currentStep = 0;
//   bool _isLoading = false;
//   bool _isEditable = true; // Controls whether fields are editable
//   CompanyVerificationModel? _fetchedExistingData; // Store fetched data separately
//
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
//   final TextEditingController _cinController = TextEditingController();
//
//   // Text fields (numbers)
//   final TextEditingController _tradeLicenseNumberController =
//   TextEditingController();
//   final TextEditingController _incorporationNumberController =
//   TextEditingController();
//
//   // Files
//
//   // Address
//   final TextEditingController _registeredAddressController =
//   TextEditingController();
//   final TextEditingController _cityController = TextEditingController();
//   final TextEditingController _pincodeController = TextEditingController();
//   final TextEditingController _stateController = TextEditingController();
//
//   // Owner Documents
//   final TextEditingController _aadhaarNumberController =
//   TextEditingController();
//   final TextEditingController _panNumberController = TextEditingController();
//
//   // Field Status Tracking
//   final Map<String, FieldStatusInfo> _fieldStatus = {};
//
//   // Existing data status from API
//   String? _existingStatus;
//
//   // Step Titles
//   final List<String> steps = [
//     "Owner Info",
//     "Business Details",
//     "Address",
//     "Required Documents",
//     "Review",
//   ];
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
//     // Use the existing data passed from constructor
//     if (widget.isEditing && widget.existingData != null) {
//       await _populateFormData(widget.existingData!);
//     } else {
//       // Try to fetch existing data if user has already submitted
//       await _fetchExistingVerification();
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
//     _isEditable = data.verificationStatus == 'PENDING' ||
//         data.verificationStatus == 'REJECTED' ||
//         data.verificationStatus == 'RE_SUBMITTED';
//
//     // Load owner info
//     _fullNameController.text = data.ownerFullName;
//     _mobileController.text = data.ownerMobile;
//     _emailController.text = data.ownerEmail;
//     _ownerAddressController.text = data.ownerAddress;
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
//   Future<void> _fetchExistingVerification() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final userId = prefs.getInt('userId') ?? 0;
//
//       final response = await ApiClient.get(
//         "api/user/company/verification/$userId",
//         service: "subscription",
//       );
//
//       if (response.statusCode == 200) {
//         final json = jsonDecode(response.body);
//         final data = CompanyVerificationModel.fromJson(json);
//
//         // Store fetched data in state variable
//         setState(() {
//           _fetchedExistingData = data;
//         });
//
//         // Populate form with fetched data
//         await _populateFormData(data);
//       }
//     } catch (e) {
//       // No existing data, continue with fresh form
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text("No existing verification found: ${e.toString()}"),
//             backgroundColor: Colors.blue,
//           ),
//         );
//       }
//     }
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
//     final fieldStatus = _fieldStatus[fieldKey]?.status ?? FieldStatus.notVerified;
//     final isPending = fieldStatus == FieldStatus.pending;
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Expanded(
//               child: Text("$label ${isMandatory ? '*' : ''}"),
//             ),
//             if (showEditIcon && _isEditable && isPending)
//               IconButton(
//                 icon: const Icon(Icons.edit, size: 18),
//                 onPressed: () {
//                   // Enable editing for this field
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Text('Editing $label'),
//                       duration: const Duration(seconds: 1),
//                     ),
//                   );
//                 },
//               ),
//           ],
//         ),
//         const SizedBox(height: 4),
//         TextFormField(
//           controller: controller,
//           keyboardType: keyboardType,
//           maxLength: maxLength,
//           enabled: _isEditable, // Control editability based on overall status
//           readOnly: !_isEditable, // Make read-only if not editable
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
//             prefixIcon: !_isEditable ? const Icon(Icons.lock, size: 18) : null,
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
//     final fieldStatus = _fieldStatus[fieldKey]?.status ?? FieldStatus.notVerified;
//     final isPending = fieldStatus == FieldStatus.pending;
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Expanded(
//               child: Text("$label ${isMandatory ? '*' : ''}"),
//             ),
//             if (_isEditable && isPending)
//               IconButton(
//                 icon: const Icon(Icons.edit, size: 18),
//                 onPressed: () => onTap(),
//                 tooltip: 'Update $label',
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
//       return Stack(
//         fit: StackFit.expand,
//         children: [
//           Image.network(
//             'http://staging.maamaas.com:8080/$existingImageUrl',
//             fit: BoxFit.cover,
//             loadingBuilder: (context, child, loadingProgress) {
//               if (loadingProgress == null) return child;
//               return Center(
//                 child: CircularProgressIndicator(
//                   value: loadingProgress.expectedTotalBytes != null
//                       ? loadingProgress.cumulativeBytesLoaded /
//                       loadingProgress.expectedTotalBytes!
//                       : null,
//                 ),
//               );
//             },
//             errorBuilder: (context, error, stackTrace) {
//               return _buildUploadPlaceholder(isEditable: isEditable);
//             },
//           ),
//           if (!isEditable)
//             Container(
//               // ignore: deprecated_member_use
//               color: Colors.black.withOpacity(0.3),
//               child: const Center(
//                 child: Icon(
//                   Icons.lock,
//                   color: Colors.white,
//                   size: 32,
//                 ),
//               ),
//             ),
//         ],
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
//           isEditable ? Icons.upload_file : Icons.visibility,
//           size: 40,
//           color: isEditable ? Colors.grey : Colors.grey[300],
//         ),
//         const SizedBox(height: 8),
//         Text(
//           isEditable ? "Upload Document" : "View Document",
//           style: TextStyle(
//             color: isEditable ? Colors.grey : Colors.grey[400],
//           ),
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
//     final fieldStatus = _fieldStatus[fieldKey]?.status ?? FieldStatus.notVerified;
//     final isPending = fieldStatus == FieldStatus.pending;
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Expanded(
//               child: Text("$label ${isMandatory ? '*' : ''}"),
//             ),
//             if (_isEditable && isPending)
//               IconButton(
//                 icon: const Icon(Icons.edit, size: 18),
//                 onPressed: () {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Text('Editing $label'),
//                       duration: const Duration(seconds: 1),
//                     ),
//                   );
//                 },
//                 tooltip: 'Edit $label',
//               ),
//           ],
//         ),
//         const SizedBox(height: 4),
//         DropdownButtonFormField<String>(
//           decoration: InputDecoration(
//             border: const OutlineInputBorder(),
//             contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
//             filled: !_isEditable,
//             fillColor: !_isEditable ? Colors.grey[100] : null,
//             prefixIcon: !_isEditable ? const Icon(Icons.lock, size: 18) : null,
//           ),
//           initialValue: value,
//           items: items
//               .map((e) => DropdownMenuItem(value: e, child: Text(e)))
//               .toList(),
//           onChanged: _isEditable ? (val) {
//             onChanged(val);
//             if (_fieldStatus[fieldKey]?.status != FieldStatus.notVerified) {
//               _updateFieldStatus(fieldKey, FieldStatus.notVerified);
//             }
//           } : null,
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
//     final fieldStatus = _fieldStatus[fieldKey]?.status ?? FieldStatus.notVerified;
//     final isPending = fieldStatus == FieldStatus.pending;
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Expanded(
//               child: Text("$label ${isMandatory ? '*' : ''}"),
//             ),
//             if (_isEditable && isPending)
//               IconButton(
//                 icon: const Icon(Icons.edit, size: 18),
//                 onPressed: () async {
//                   final DateTime? picked = await showDatePicker(
//                     context: context,
//                     initialDate: date ?? DateTime.now(),
//                     firstDate: DateTime(1900),
//                     lastDate: DateTime.now(),
//                   );
//                   if (picked != null) {
//                     onDateSelected(picked);
//                   }
//                 },
//                 tooltip: 'Edit $label',
//               ),
//           ],
//         ),
//         const SizedBox(height: 4),
//         InkWell(
//           onTap: _isEditable ? () async {
//             final DateTime? picked = await showDatePicker(
//               context: context,
//               initialDate: date ?? DateTime.now(),
//               firstDate: DateTime(1900),
//               lastDate: DateTime.now(),
//             );
//             if (picked != null) {
//               onDateSelected(picked);
//               if (_fieldStatus[fieldKey]?.status != FieldStatus.notVerified) {
//                 _updateFieldStatus(fieldKey, FieldStatus.notVerified);
//               }
//             }
//           } : null,
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
//                 Row(
//                   children: [
//                     if (!_isEditable)
//                       const Icon(Icons.lock, size: 18, color: Colors.grey),
//                     const SizedBox(width: 8),
//                     Text(
//                       date != null
//                           ? "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}"
//                           : "Select Date",
//                       style: TextStyle(
//                         color: date != null
//                             ? (_isEditable ? Colors.black : Colors.grey[700])
//                             : Colors.grey,
//                       ),
//                     ),
//                   ],
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
//       String fieldKey,
//       FieldStatus status, {
//         String? message,
//       }) {
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
//   // Helper method to get existing image URL based on field key
//   String? _getExistingImageUrl(String fieldKey) {
//     final data = widget.existingData ?? _fetchedExistingData;
//     if (data == null) return null;
//
//     switch (fieldKey) {
//       case 'companyPanDocument':
//         return data.companyPanDocument;
//       case 'gstCertificate':
//         return data.gstCertificate;
//       case 'ownerPanDocument':
//         return data.ownerPanDocument;
//       case 'ownerAadhaarDocument':
//         return data.ownerAadhaarDocument;
//       case 'ownerSelfie':
//       // Assuming you have this field in your model
//         return null; // Add if you have this field
//       case 'tradeLicense':
//       // Assuming you have this field in your model
//         return null; // Add if you have this field
//       case 'incorporationCertificate':
//       // Assuming you have this field in your model
//         return null; // Add if you have this field
//       default:
//         return null;
//     }
//   }
//
//   Widget _buildStepFields(int step) {
//     if (_isLoading) {
//       return const Center(child: CircularProgressIndicator());
//     }
//
//     // Check overall status and show banner
//     Widget? statusBanner;
//     if (_existingStatus != null) {
//       Color bannerColor;
//       String bannerText;
//       IconData bannerIcon;
//
//       switch (_existingStatus) {
//         case 'PENDING':
//           bannerColor = Colors.orange[100]!;
//           bannerText = 'Your application is pending review. You can edit fields.';
//           bannerIcon = Icons.pending_actions;
//           break;
//         case 'REJECTED':
//           bannerColor = Colors.red[100]!;
//           bannerText = 'Your application was rejected. Please review and resubmit.';
//           bannerIcon = Icons.error_outline;
//           break;
//         case 'APPROVED':
//           bannerColor = Colors.green[100]!;
//           bannerText = 'Your application is approved. Most fields are locked.';
//           bannerIcon = Icons.check_circle;
//           break;
//         case 'RE_SUBMITTED':
//           bannerColor = Colors.blue[100]!;
//           bannerText = 'Your resubmitted application is under review.';
//           bannerIcon = Icons.refresh;
//           break;
//         default:
//           bannerColor = Colors.grey[100]!;
//           bannerText = 'Application Status: $_existingStatus';
//           bannerIcon = Icons.info;
//       }
//
//       statusBanner = Container(
//         padding: const EdgeInsets.all(12),
//         margin: const EdgeInsets.only(bottom: 16),
//         decoration: BoxDecoration(
//           color: bannerColor,
//           borderRadius: BorderRadius.circular(8),
//           // ignore: deprecated_member_use
//           border: Border.all(color: bannerColor.withOpacity(0.5)),
//         ),
//         child: Row(
//           children: [
//             Icon(
//               bannerIcon,
//               color: _existingStatus == 'APPROVED' ? Colors.green :
//               _existingStatus == 'REJECTED' ? Colors.red :
//               Colors.orange,
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Text(
//                 bannerText,
//                 style: TextStyle(
//                   fontSize: 14,
//                   color: Colors.grey[800],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       );
//     }
//
//     switch (step) {
//       case 0: // Owner Info
//         return SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               if (statusBanner != null) statusBanner,
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
//                 showEditIcon: true,
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
//                 showEditIcon: true,
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
//                 showEditIcon: true,
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
//                 showEditIcon: true,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Owner address is required';
//                   }
//                   return null;
//                 },
//               ),
//
//               // Owner Selfie Upload
//               _buildUploadContainerWithStatus(
//                 file: _ownerSelfieFile,
//                 onTap: () => _pickImage(
//                   purpose: "Owner Selfie",
//                   quality: 65,
//                   maxWidth: 1200,
//                   maxHeight: 1200,
//                   onSelected: (file) => _ownerSelfieFile = file,
//                 ),
//                 fieldKey: 'ownerSelfie',
//                 label: "Owner Selfie",
//                 existingImageUrl: _getExistingImageUrl('ownerSelfie'),
//               ),
//
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
//                           _ownerAddressController.text.isEmpty) {
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
//     // ... Continue with other steps (1, 2, 3, 4)
//     // Make sure to update all upload containers with existingImageUrl parameter
//     // Example for step 1 (Business Details):
//       case 1:
//         return SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               if (statusBanner != null) statusBanner,
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
//                 showEditIcon: true,
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
//                 showEditIcon: true,
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
//                 onTap: () => _pickImage(
//                   purpose: "Company PAN Document",
//                   quality: 65,
//                   maxWidth: 1200,
//                   maxHeight: 1200,
//                   onSelected: (file) => _companyPanDoc = file,
//                 ),
//                 fieldKey: 'companyPanDocument',
//                 label: "Company PAN Document",
//                 existingImageUrl: _getExistingImageUrl('companyPanDocument'),
//               ),
//
//               // ... Continue with other fields for step 1
//             ],
//           ),
//         );
//
//     // Add other steps (2, 3, 4) similarly...
//
//       default:
//         return const Center(child: Text("Invalid step"));
//     }
//   }
//
//   // Keep your existing _pickImage method
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
//   // Add your existing _finalSubmitVendorDetails, _validateAllFields, etc. methods
//   // ...
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: Text(
//           widget.isEditing ? "Edit Company Registration" : "Company Registration",
//         ),
//         automaticallyImplyLeading: true,
//         actions: [
//           if (_existingStatus != null && _existingStatus != 'APPROVED')
//             IconButton(
//               icon: const Icon(Icons.refresh),
//               onPressed: _fetchExistingVerification,
//               tooltip: 'Refresh',
//             ),
//         ],
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Side Navigation
//           Container(
//             width: 80,
//             color: Colors.grey[50],
//             child: ListView.builder(
//               itemCount: steps.length,
//               itemBuilder: (context, index) {
//                 return InkWell(
//                   onTap: () {
//                     setState(() {
//                       _currentStep = index;
//                     });
//                   },
//                   child: Container(
//                     margin: const EdgeInsets.symmetric(
//                       vertical: 4,
//                       horizontal: 4,
//                     ),
//                     decoration: BoxDecoration(
//                       color: _currentStep == index
//                           ? Colors.deepPurple
//                           : Colors.transparent,
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(
//                         vertical: 16,
//                         horizontal: 8,
//                       ),
//                       child: Column(
//                         children: [
//                           CircleAvatar(
//                             radius: 14,
//                             backgroundColor: _currentStep == index
//                                 ? Colors.white
//                                 : Colors.grey[300],
//                             child: Text(
//                               "${index + 1}",
//                               style: TextStyle(
//                                 color: _currentStep == index
//                                     ? Colors.black
//                                     : Colors.grey[700],
//                                 fontSize: 12,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                           const SizedBox(height: 8),
//                           Text(
//                             steps[index],
//                             textAlign: TextAlign.center,
//                             style: TextStyle(
//                               fontSize: 10,
//                               fontWeight: _currentStep == index
//                                   ? FontWeight.bold
//                                   : FontWeight.normal,
//                               color: _currentStep == index
//                                   ? Colors.white
//                                   : Colors.grey[700],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//
//           // Main Content
//           Expanded(
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: _buildStepFields(_currentStep),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // Dispose controllers
//   @override
//   void dispose() {
//     _fullNameController.dispose();
//     _mobileController.dispose();
//     _emailController.dispose();
//     _ownerAddressController.dispose();
//     _companyNameController.dispose();
//     _companyPanController.dispose();
//     _companyGstController.dispose();
//     _cinController.dispose();
//     _tradeLicenseNumberController.dispose();
//     _incorporationNumberController.dispose();
//     _registeredAddressController.dispose();
//     _cityController.dispose();
//     _pincodeController.dispose();
//     _stateController.dispose();
//     _aadhaarNumberController.dispose();
//     _panNumberController.dispose();
//     super.dispose();
//   }
// }