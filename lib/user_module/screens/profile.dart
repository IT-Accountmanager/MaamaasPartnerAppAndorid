// import 'dart:convert';
// import 'dart:io';
//
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:maamaas_app/screens/professional_user/companygetdetails.dart';
// import 'package:maamaas_app/screens/professional_user/professional_registration.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../API/Apiclient.dart';
// import '../API/Auth_service.dart';
// import '../widgets/media_utils.dart';
//
// class Profile_account extends StatefulWidget {
//   const Profile_account({super.key});
//
//   @override
//   State<Profile_account> createState() => _Profile_accountState();
// }
//
// class _Profile_accountState extends State<Profile_account> {
//   Future<bool> _checkRegistration() async {
//     return AuthService.isCompanyRegistered();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<bool>(
//       future: _checkRegistration(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         }
//
//         if (snapshot.hasError) {
//           return const ProfessionalUserRegistration();
//         }
//
//         return snapshot.data == true
//             ? const CompanyVerificationView()
//             : const ProfessionalUserRegistration();
//       },
//     );
//   }
// }
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
//   const ProfessionalUserRegistrationa({Key? key}) : super(key: key);
//
//   @override
//   State<ProfessionalUserRegistrationa> createState() =>
//       _ProfessionalUserRegistrationaState();
// }
//
// class _ProfessionalUserRegistrationaState
//     extends State<ProfessionalUserRegistrationa> {
//   int _currentStep = 0;
//
//   final TextEditingController _fullNameController = TextEditingController();
//   final TextEditingController _mobileController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _ownerAddressController = TextEditingController();
//   File? _ownerSelfieFile;
//   DateTime? _dobController;
//
//   // Business Details State & Controllers
//   String? _selectedCompanyType;
//   final TextEditingController _companyNameController = TextEditingController();
//   final TextEditingController _companyPanController = TextEditingController();
//   File? _companyPanDoc;
//   final TextEditingController _companyGstController = TextEditingController();
//   File? _companyGstDoc;
//   final TextEditingController _cinController = TextEditingController();
//
//   // These are ONLY text fields (numbers):
//   final TextEditingController _tradeLicenseNumberController =
//       TextEditingController();
//   final TextEditingController _incorporationNumberController =
//       TextEditingController();
//
//   // These are ONLY files:
//   File? _tradeLicenseDoc;
//   File? _incorporationCertificateDoc;
//
//   // Address Controllers
//   final TextEditingController _registeredAddressController =
//       TextEditingController();
//   final TextEditingController _cityController = TextEditingController();
//   final TextEditingController _pincodeController = TextEditingController();
//   final TextEditingController _stateController = TextEditingController();
//
//   // Owner Documents Controllers & Files
//   final TextEditingController _aadhaarNumberController =
//       TextEditingController();
//   File? _aadhaarFront;
//   final TextEditingController _panNumberController = TextEditingController();
//   File? _panCardDoc;
//
//   // Remove this duplicate controller:
//   // final TextEditingController _gstNumberController = TextEditingController();
//
//   // Field Status Tracking
//   final Map<String, FieldStatusInfo> _fieldStatus = {};
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
//   Future<void> _finalSubmitVendorDetails() async {
//     try {
//       // print("🔄 Starting submission process...");
//
//       // Validate all required fields
//       if (!_validateAllFields()) {
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
//
//       // Get user ID
//       final prefs = await SharedPreferences.getInstance();
//       final userId = prefs.getInt('userId') ?? 0;
//       // print("👤 User ID: $userId");
//
//       // Format DOB to YYYY-MM-DD
//       String? formattedDob;
//       if (_dobController != null) {
//         formattedDob =
//             "${_dobController!.year}-${_dobController!.month.toString().padLeft(2, '0')}-${_dobController!.day.toString().padLeft(2, '0')}";
//         // print("📅 Formatted DOB: $formattedDob");
//       }
//
//       // CORRECTED: ONLY include TEXT fields that should be sent as form data
//       final Map<String, dynamic> companyData = {
//         // Company Details - TEXT FIELDS ONLY
//         "companyName": _companyNameController.text.trim(),
//         "businessType": _selectedCompanyType ?? "",
//         "companyPan": _companyPanController.text.trim(),
//         "gstin": _companyGstController.text.trim(),
//         "cin": _cinController.text.trim(),
//         "registeredAddress": _registeredAddressController.text.trim(),
//         "city": _cityController.text.trim(),
//         "state": _stateController.text.trim(),
//         "pincode": _pincodeController.text.trim(),
//
//         // Owner Details - TEXT FIELDS ONLY
//         "ownerFullName": _fullNameController.text.trim(),
//         "ownerDob": formattedDob,
//         "ownerPan": _panNumberController.text.trim(),
//         "ownerAadhaar": _aadhaarNumberController.text.trim(),
//         "ownerMobile": _mobileController.text.trim(),
//         "ownerEmail": _emailController.text.trim(),
//         "ownerAddress": _ownerAddressController.text.trim(),
//
//         // Optional TEXT fields (only if they have values)
//         if (_tradeLicenseNumberController.text.isNotEmpty)
//           "tradeLicenseNumber": _tradeLicenseNumberController.text.trim(),
//         if (_incorporationNumberController.text.isNotEmpty)
//           "incorporationNumber": _incorporationNumberController.text.trim(),
//
//         // Metadata
//         "userId": userId,
//         "verificationStatus": "PENDING",
//         "submittedAt": DateTime.now().toUtc().toIso8601String(),
//       };
//
//       // Debug: Show what we're sending
//       // print("📊 TEXT FIELDS to send:");
//       companyData.forEach((key, value) {
//         // print("  ✅ $key: $value");
//       });
//
//       // Prepare files - ONLY files go here
//       final Map<String, File> files = {};
//
//       // Company documents - FILES ONLY
//       if (_companyPanDoc != null) {
//         files["companyPanDocument"] = _companyPanDoc!;
//         // print("✅ Added companyPanDocument FILE");
//       }
//       if (_companyGstDoc != null) {
//         files["gstCertificate"] = _companyGstDoc!;
//         // print("✅ Added gstCertificate FILE");
//       }
//       if (_incorporationCertificateDoc != null) {
//         files["incorporationCertificate"] = _incorporationCertificateDoc!;
//         // print("✅ Added incorporationCertificate FILE");
//       }
//       if (_tradeLicenseDoc != null) {
//         files["tradeLicense"] = _tradeLicenseDoc!;
//         // print("✅ Added tradeLicense FILE");
//       }
//
//       // Owner documents - FILES ONLY
//       if (_panCardDoc != null) {
//         files["ownerPanDocument"] = _panCardDoc!;
//         // print("✅ Added ownerPanDocument FILE");
//       }
//       if (_ownerSelfieFile != null) {
//         files["ownerSelfie"] = _ownerSelfieFile!;
//         // print("✅ Added ownerSelfie FILE");
//       }
//       if (_aadhaarFront != null) {
//         files["ownerAadhaarDocument"] = _aadhaarFront!;
//         // print("✅ Added ownerAadhaarDocument FILE");
//       }
//
//       // Debug totals
//       // print("📦 Total TEXT fields: ${companyData.length}");
//       // print("📦 Total FILES to send: ${files.length}");
//
//       // Show loading indicator
//       if (mounted) {
//         showDialog(
//           context: context,
//           barrierDismissible: false,
//           builder: (context) =>
//               const Center(child: CircularProgressIndicator()),
//         );
//       }
//
//       // print("🚀 Sending request to API...");
//
//       final response = await ApiClient.sendMultipartRequest(
//         service: "subscription",
//         endpoint: "api/user/company/verification",
//         method: "POST",
//         data: {
//           'companyData': jsonEncode(companyData), // 👈 full object
//         },
//         files: files,
//       );
//
//       // print("✅ Response received");
//       // print("📨 Status Code: ${response.statusCode}");
//
//       if (response.body.isNotEmpty) {
//         // print("📨 Response Body: ${response.body}");
//       } else {
//         // print("⚠️ Empty response body");
//       }
//
//       // Hide loading indicator
//       if (mounted && Navigator.of(context).canPop()) {
//         Navigator.of(context).pop();
//       }
//
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         final responseBody = jsonDecode(response.body);
//
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(
//                 responseBody['message'] ??
//                     "Company details submitted successfully",
//               ),
//               backgroundColor: Colors.green,
//               duration: const Duration(seconds: 3),
//             ),
//           );
//
//           // Navigate to verification view
//         }
//       } else {
//         String errorMessage = "Error ${response.statusCode}";
//         if (response.body.isNotEmpty) {
//           try {
//             final error = jsonDecode(response.body);
//             errorMessage = error['message'] ?? errorMessage;
//           } catch (e) {
//             // Ignore parse error
//           }
//         }
//
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
//           );
//         }
//       }
//     } catch (e) {
//       // print("❌ Exception: $e");
//
//       if (mounted && Navigator.of(context).canPop()) {
//         Navigator.of(context).pop();
//       }
//
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text("Error: ${e.toString()}"),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }
//
//   void _debugCheckEmptyFields() {
//     // print("🔍 DEBUG: Checking required fields...");
//
//     // API Required fields based on Swagger documentation
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
//     for (var field in requiredFields) {
//       // print(
//       //   "${fieldStatus[field] == true ? '✅' : '❌'} $field: ${fieldStatus[field] ?? false}",
//       // );
//     }
//
//     // print("\n📁 FILE STATUS:");
//     // ignore: unused_local_variable
//     for (var file in requiredFiles) {
//       // print(
//       //   "${fieldStatus[file] == true ? '✅' : '❌'} $file: ${fieldStatus[file] ?? false}",
//       // );
//     }
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
//
//   void _updateFieldStatus(
//     String fieldKey,
//     FieldStatus status, {
//     String? message,
//   }) {
//     setState(() {
//       _fieldStatus[fieldKey] = FieldStatusInfo(
//         status: status,
//         message: message,
//         lastUpdated: DateTime.now(),
//       );
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
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(children: [Text("$label ${isMandatory ? '*' : ''}")]),
//         const SizedBox(height: 4),
//         TextFormField(
//           controller: controller,
//           keyboardType: keyboardType,
//           maxLength: maxLength,
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
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(children: [Text("$label ${isMandatory ? '*' : ''}")]),
//         const SizedBox(height: 4),
//         InkWell(
//           onTap: () {
//             onTap();
//             if (_fieldStatus[fieldKey]?.status != FieldStatus.notVerified) {
//               _updateFieldStatus(fieldKey, FieldStatus.notVerified);
//             }
//           },
//           child: Container(
//             height: 120,
//             width: double.infinity,
//             decoration: BoxDecoration(
//               border: Border.all(color: Colors.grey),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: file != null
//                 ? kIsWeb
//                       ? Image.network(file.path, fit: BoxFit.cover)
//                       : Image.file(file, fit: BoxFit.cover)
//                 : Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       const Icon(
//                         Icons.upload_file,
//                         size: 40,
//                         color: Colors.grey,
//                       ),
//                       const SizedBox(height: 8),
//                       Text("Upload $label"),
//                     ],
//                   ),
//           ),
//         ),
//         const SizedBox(height: 12),
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
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(children: [Text("$label ${isMandatory ? '*' : ''}")]),
//         const SizedBox(height: 4),
//         DropdownButtonFormField<String>(
//           decoration: const InputDecoration(
//             border: OutlineInputBorder(),
//             contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
//           ),
//           initialValue: value,
//           items: items
//               .map((e) => DropdownMenuItem(value: e, child: Text(e)))
//               .toList(),
//           onChanged: (val) {
//             onChanged(val);
//             if (_fieldStatus[fieldKey]?.status != FieldStatus.notVerified) {
//               _updateFieldStatus(fieldKey, FieldStatus.notVerified);
//             }
//           },
//           hint: Text("Select $label"),
//           isExpanded: true,
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
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(children: [Text("$label ${isMandatory ? '*' : ''}")]),
//         const SizedBox(height: 4),
//         InkWell(
//           onTap: () async {
//             final DateTime? picked = await showDatePicker(
//               context: context,
//               initialDate: DateTime.now(),
//               firstDate: DateTime(1900),
//               lastDate: DateTime.now(),
//             );
//             if (picked != null) {
//               onDateSelected(picked);
//               if (_fieldStatus[fieldKey]?.status != FieldStatus.notVerified) {
//                 _updateFieldStatus(fieldKey, FieldStatus.notVerified);
//               }
//             }
//           },
//           child: Container(
//             height: 56,
//             padding: const EdgeInsets.symmetric(horizontal: 12),
//             decoration: BoxDecoration(
//               border: Border.all(color: Colors.grey),
//               borderRadius: BorderRadius.circular(8),
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
//                     color: date != null ? Colors.black : Colors.grey,
//                   ),
//                 ),
//                 const Icon(Icons.calendar_today, size: 20, color: Colors.grey),
//               ],
//             ),
//           ),
//         ),
//         const SizedBox(height: 12),
//       ],
//     );
//   }
//
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
//     // _gstNumberController.dispose();
//     // _tradeLicenseNumberController2.dispose();
//     // _fssaiNumberController.dispose();
//     // _labourLicenseNumberController.dispose();
//
//     super.dispose();
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
//           Row(
//             children: [
//               Text(
//                 label,
//                 style: const TextStyle(
//                   fontWeight: FontWeight.w600,
//                   fontSize: 14,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 4),
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
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Text(
//                 label,
//                 style: const TextStyle(
//                   fontWeight: FontWeight.w600,
//                   fontSize: 14,
//                 ),
//               ),
//             ],
//           ),
//           Text(
//             value.isEmpty ? 'N/A' : value,
//             style: const TextStyle(fontSize: 14),
//           ),
//           const Divider(),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildStepFields(int step) {
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
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(children: [const Text("Owner Selfie *")]),
//                   const SizedBox(height: 4),
//
//                   InkWell(
//                     onTap: () => _pickImage(
//                       purpose: "Owner Selfie",
//                       quality: 65, // adjust for compression
//                       maxWidth: 1200,
//                       maxHeight: 1200,
//                       onSelected: (file) => _ownerSelfieFile = file,
//                     ),
//                     child: Container(
//                       height: 120,
//                       width: 120,
//                       decoration: BoxDecoration(
//                         border: Border.all(color: Colors.grey),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: _ownerSelfieFile != null
//                           ? kIsWeb
//                                 ? Image.network(
//                                     _ownerSelfieFile!.path,
//                                     fit: BoxFit.cover,
//                                   )
//                                 : Image.file(
//                                     _ownerSelfieFile!,
//                                     fit: BoxFit.cover,
//                                   )
//                           : const Column(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Icon(
//                                   Icons.add_a_photo,
//                                   size: 40,
//                                   color: Colors.grey,
//                                 ),
//                                 SizedBox(height: 8),
//                                 Text("Upload Selfie"),
//                               ],
//                             ),
//                     ),
//                   ),
//
//                   const SizedBox(height: 12),
//                 ],
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
//                 onTap: () => _pickImage(
//                   purpose: "Company PAN Document",
//                   quality: 65, // adjust for compression
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
//                 onTap: () => _pickImage(
//                   purpose: "GST Certificate",
//                   quality: 65, // adjust for compression
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
//                 onTap: () => _pickImage(
//                   purpose: "Trade License Document",
//                   quality: 65, // adjust for compression
//                   maxWidth: 1200,
//                   maxHeight: 1200,
//                   onSelected: (file) => _tradeLicenseDoc = file,
//                 ),
//                 fieldKey: 'tradeLicense',
//                 label: "Trade License Document",
//               ),
//
//               _buildTextFieldWithStatus(
//                 controller: _incorporationNumberController,
//                 label: "Incorporation Number",
//                 fieldKey: 'incorporationNumber',
//               ),
//
//               _buildUploadContainerWithStatus(
//                 file: _incorporationCertificateDoc,
//                 onTap: () => _pickImage(
//                   purpose: "Incorporation Certificate",
//                   quality: 65, // adjust for compression
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
//                 onTap: () => _pickImage(
//                   purpose: "Aadhaar Document",
//                   quality: 65, // adjust for compression
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
//                 onTap: () => _pickImage(
//                   purpose: "PAN Document",
//                   quality: 65, // adjust for compression
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
//                       // Document validation
//                       if (_aadhaarNumberController.text.isEmpty ||
//                           _aadhaarFront == null ||
//                           _panNumberController.text.isEmpty ||
//                           _panCardDoc == null) {
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
//                       setState(() {
//                         _currentStep = 4;
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
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: const Center(child: Text("Company Registration")),
//         automaticallyImplyLeading: false,
//       ),
//       body: Row(
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
// }
