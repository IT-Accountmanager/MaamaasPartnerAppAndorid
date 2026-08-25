// // import 'dart:convert';
// // import 'dart:io';
// // import 'package:flutter/foundation.dart';
// // import 'package:flutter/gestures.dart';
// // import 'package:flutter/material.dart';
// // import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
// // import 'package:flutter_google_places_hoc081098/google_maps_webservice_places.dart';
// // import 'package:geocoding/geocoding.dart';
// // import 'package:geolocator/geolocator.dart';
// // import 'package:google_api_headers/google_api_headers.dart';
// // import 'package:google_maps_flutter/google_maps_flutter.dart';
// // import 'package:image_picker/image_picker.dart';
// // import 'package:maamaaspartner/Api/APIclient.dart';
// // import 'package:shared_preferences/shared_preferences.dart';
// //
// // import '../Api/food_authservice.dart';
// // import '../widgets_helper/Home_screen_1.dart';
// //
// // // Status enum for field verification
// // enum FieldStatus { notVerified, verified, rejected, pending }
// //
// // // Field status model
// // class FieldStatusInfo {
// //   final FieldStatus status;
// //   final String? message; // Optional rejection message
// //   final DateTime? lastUpdated;
// //
// //   FieldStatusInfo({
// //     this.status = FieldStatus.notVerified,
// //     this.message,
// //     this.lastUpdated,
// //   });
// // }
// //
// // class Registration extends StatefulWidget {
// //   const Registration({Key? key}) : super(key: key);
// //
// //   @override
// //   State<Registration> createState() => _RegistrationState();
// // }
// //
// // class _RegistrationState extends State<Registration> {
// //   int _currentStep = 0;
// //   bool _isVendorRegistered = false; // Track if vendor is already registered
// //   bool _isLoadingData = true; // Track loading state
// //
// //   // Personal Info Controllers
// //   final TextEditingController _fullNameController = TextEditingController();
// //   final TextEditingController _mobileController = TextEditingController();
// //   final TextEditingController _emailController = TextEditingController();
// //   File? _logoFile;
// //   final ImagePicker _picker = ImagePicker();
// //   double? _latitude;
// //   double? _longitude;
// //
// //   // Business Details State & Controllers
// //   String? _selectedtype;
// //   String? _selectedVendorType;
// //   List<String> _selectedOrderTypes = []; // Changed from String? to List<String>
// //   final TextEditingController _regBusinessNameController =
// //       TextEditingController();
// //   final TextEditingController _businessPlanController = TextEditingController();
// //
// //   // Address Controllers
// //   final TextEditingController _latitudeController = TextEditingController();
// //   final TextEditingController _longitudeController = TextEditingController();
// //   final TextEditingController _fullAddressController = TextEditingController();
// //   final TextEditingController _doorNoController = TextEditingController();
// //   final TextEditingController _addressLineController = TextEditingController();
// //   final TextEditingController _landmarkController = TextEditingController();
// //   final TextEditingController _cityController = TextEditingController();
// //   final TextEditingController _pincodeController = TextEditingController();
// //   final TextEditingController _stateController = TextEditingController();
// //   final TextEditingController _countryController = TextEditingController();
// //
// //   // Required Documents Controllers & Files
// //   final TextEditingController _aadhaarNumberController =
// //       TextEditingController();
// //   File? _aadhaarFront;
// //   File? _aadhaarBack;
// //   final TextEditingController _panNumberController = TextEditingController();
// //   File? _panCardDoc;
// //   final TextEditingController _gstNumberController = TextEditingController();
// //   File? _registerDocFront;
// //   File? _registerDocBack;
// //   final TextEditingController _tradeLicenseNumberController =
// //       TextEditingController();
// //   File? _tradeLicenseDoc;
// //   DateTime? _tradeLicenseStartDate;
// //   DateTime? _tradeLicenseEndDate;
// //   final TextEditingController _fssaiNumberController = TextEditingController();
// //   File? _fssaiLicenseDoc;
// //   DateTime? _fssaiStartDate;
// //   DateTime? _fssaiEndDate;
// //   final TextEditingController _labourLicenseNumberController =
// //       TextEditingController();
// //   File? _labourLicenseDoc;
// //   DateTime? _labourStartDate;
// //   DateTime? _labourEndDate;
// //   File? _blankChequeDoc;
// //
// //   // Bank Account Details Controllers
// //   final TextEditingController _accountHolderNameController =
// //       TextEditingController();
// //   final TextEditingController _accountNumberController =
// //       TextEditingController();
// //   final TextEditingController _ifscCodeController = TextEditingController();
// //   final TextEditingController _bankNameController = TextEditingController();
// //   final TextEditingController _branchNameController = TextEditingController();
// //
// //   // Field Status Tracking
// //   final Map<String, FieldStatusInfo> _fieldStatus = {};
// //
// //   // Step Titles
// //   final List<String> steps = [
// //     "Personal Info",
// //     "Business Details",
// //     "Address",
// //     "Required Documents",
// //     "Bank Account Details",
// //     "Review",
// //   ];
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _initializeFieldStatus();
// //     _loadVendorRegistrationData();
// //   }
// //
// //   void _initializeFieldStatus() {
// //     // Personal Info
// //     _fieldStatus['fullName'] = FieldStatusInfo();
// //     _fieldStatus['mobile'] = FieldStatusInfo();
// //     _fieldStatus['email'] = FieldStatusInfo();
// //     _fieldStatus['logo'] = FieldStatusInfo();
// //
// //     // Business Details
// //     _fieldStatus['businessType'] = FieldStatusInfo();
// //     _fieldStatus['vendorType'] = FieldStatusInfo();
// //     _fieldStatus['orderTypes'] = FieldStatusInfo();
// //     _fieldStatus['registeredBusinessName'] = FieldStatusInfo();
// //     _fieldStatus['businessPlan'] = FieldStatusInfo();
// //
// //     // Address
// //     _fieldStatus['fullAddress'] = FieldStatusInfo();
// //     _fieldStatus['doorNo'] = FieldStatusInfo();
// //     _fieldStatus['addressLine'] = FieldStatusInfo();
// //     _fieldStatus['landmark'] = FieldStatusInfo();
// //     _fieldStatus['city'] = FieldStatusInfo();
// //     _fieldStatus['pincode'] = FieldStatusInfo();
// //     _fieldStatus['state'] = FieldStatusInfo();
// //     _fieldStatus['country'] = FieldStatusInfo();
// //     _fieldStatus['location'] = FieldStatusInfo();
// //
// //     // Documents
// //     _fieldStatus['aadhaarNumber'] = FieldStatusInfo();
// //     _fieldStatus['aadhaarFront'] = FieldStatusInfo();
// //     _fieldStatus['aadhaarBack'] = FieldStatusInfo();
// //     _fieldStatus['panNumber'] = FieldStatusInfo();
// //     _fieldStatus['panCardDoc'] = FieldStatusInfo();
// //     _fieldStatus['gstNumber'] = FieldStatusInfo();
// //     _fieldStatus['registerDocFront'] = FieldStatusInfo();
// //     _fieldStatus['registerDocBack'] = FieldStatusInfo();
// //     _fieldStatus['tradeLicenseNumber'] = FieldStatusInfo();
// //     _fieldStatus['tradeLicenseDoc'] = FieldStatusInfo();
// //     _fieldStatus['tradeLicenseStartDate'] = FieldStatusInfo();
// //     _fieldStatus['tradeLicenseEndDate'] = FieldStatusInfo();
// //     _fieldStatus['fssaiNumber'] = FieldStatusInfo();
// //     _fieldStatus['fssaiLicenseDoc'] = FieldStatusInfo();
// //     _fieldStatus['fssaiStartDate'] = FieldStatusInfo();
// //     _fieldStatus['fssaiEndDate'] = FieldStatusInfo();
// //     _fieldStatus['labourLicenseNumber'] = FieldStatusInfo();
// //     _fieldStatus['labourLicenseDoc'] = FieldStatusInfo();
// //     _fieldStatus['labourStartDate'] = FieldStatusInfo();
// //     _fieldStatus['labourEndDate'] = FieldStatusInfo();
// //     _fieldStatus['blankChequeDoc'] = FieldStatusInfo();
// //
// //     // Bank Details
// //     _fieldStatus['accountHolderName'] = FieldStatusInfo();
// //     _fieldStatus['accountNumber'] = FieldStatusInfo();
// //     _fieldStatus['ifscCode'] = FieldStatusInfo();
// //     _fieldStatus['bankName'] = FieldStatusInfo();
// //     _fieldStatus['branchName'] = FieldStatusInfo();
// //   }
// //
// //   // Method to navigate back to home screen
// //   void _navigateBackToHome() {
// //     if (Navigator.canPop(context)) {
// //       Navigator.pop(context);
// //     } else {
// //       Navigator.pushReplacement(
// //         context,
// //         MaterialPageRoute(builder: (context) => HomeWrapper()),
// //       );
// //     }
// //   }
// //
// //   Future<void> _loadVendorRegistrationData() async {
// //     try {
// //       debugPrint("🔄 Loading vendor registration data...");
// //       setState(() {
// //         _isLoadingData = true;
// //       });
// //
// //       final vendorDetails = await food_authservice
// //           .fetchVendorRegistrationDetails();
// //
// //       if (vendorDetails != null && mounted) {
// //         debugPrint(
// //           "✅ Vendor registration data loaded: ${vendorDetails.length} fields",
// //         );
// //
// //         bool hasEssentialData =
// //             vendorDetails['ownerName']?.toString().isNotEmpty == true &&
// //             vendorDetails['mobileNumber']?.toString().isNotEmpty == true &&
// //             vendorDetails['email']?.toString().isNotEmpty == true &&
// //             vendorDetails['registeredName']?.toString().isNotEmpty == true;
// //
// //         bool isRegistered =
// //             vendorDetails['isRegistered'] == true ||
// //             vendorDetails['registrationStatus'] == 'COMPLETED' ||
// //             vendorDetails['registrationStatus'] == 'APPROVED';
// //
// //         setState(() {
// //           _isVendorRegistered = hasEssentialData || isRegistered;
// //           debugPrint("📋 Vendor registration status: $_isVendorRegistered");
// //         });
// //
// //         setState(() {
// //           // ================== PERSONAL INFO ==================
// //           _fullNameController.text =
// //               vendorDetails['ownerName']?.toString() ?? '';
// //           _mobileController.text =
// //               vendorDetails['mobileNumber']?.toString() ?? '';
// //           _emailController.text = vendorDetails['email']?.toString() ?? '';
// //
// //           // Check if logo exists on server
// //           if (vendorDetails['companyLogo']?.toString().isNotEmpty == true) {
// //             _logoFile = File("provided");
// //           }
// //
// //           // ================== BUSINESS DETAILS ==================
// //           _selectedtype = vendorDetails['type']?.toString();
// //           _selectedVendorType = vendorDetails['vendorType']?.toString();
// //
// //           // Load order types as List
// //           final orderTypes = vendorDetails['orderTypes'];
// //           if (orderTypes is List) {
// //             _selectedOrderTypes = List<String>.from(
// //               orderTypes.map((e) => e.toString()),
// //             );
// //           } else if (vendorDetails['orderType'] != null) {
// //             // For backward compatibility with single order type
// //             _selectedOrderTypes = [vendorDetails['orderType'].toString()];
// //           }
// //
// //           _regBusinessNameController.text =
// //               vendorDetails['registeredName']?.toString() ?? '';
// //           _businessPlanController.text =
// //               vendorDetails['businessPlan']?.toString() ?? '';
// //
// //           // ================== ADDRESS ==================
// //           _latitude = vendorDetails['latitude']?.toDouble();
// //           _longitude = vendorDetails['longitude']?.toDouble();
// //           _fullAddressController.text =
// //               vendorDetails['fullAddress']?.toString() ?? '';
// //           _doorNoController.text =
// //               vendorDetails['doorNumber']?.toString() ?? '';
// //           _addressLineController.text =
// //               vendorDetails['addressLine']?.toString() ?? '';
// //           _landmarkController.text =
// //               vendorDetails['landMark']?.toString() ?? '';
// //           _cityController.text = vendorDetails['city']?.toString() ?? '';
// //           _pincodeController.text = vendorDetails['pincode']?.toString() ?? '';
// //           _stateController.text = vendorDetails['state']?.toString() ?? '';
// //           _countryController.text =
// //               vendorDetails['country']?.toString() ?? 'India';
// //
// //           // ================== DOCUMENT DETAILS ==================
// //           _aadhaarNumberController.text =
// //               vendorDetails['aadharNumber']?.toString() ?? '';
// //
// //           // Check if Aadhaar front exists
// //           if (vendorDetails['aadharPhotoFront']?.toString().isNotEmpty ==
// //               true) {
// //             _aadhaarFront = File("provided");
// //           }
// //
// //           // Check if Aadhaar back exists
// //           if (vendorDetails['aadharPhotoBack']?.toString().isNotEmpty == true) {
// //             _aadhaarBack = File("provided");
// //           }
// //
// //           _panNumberController.text =
// //               vendorDetails['panCardNumber']?.toString() ?? '';
// //
// //           // Check if PAN document exists
// //           if (vendorDetails['panCard']?.toString().isNotEmpty == true) {
// //             _panCardDoc = File("provided");
// //           }
// //
// //           _gstNumberController.text =
// //               vendorDetails['gstNumber']?.toString() ?? '';
// //
// //           // Check if register documents exist
// //           if (vendorDetails['registeredDocumentsFront']
// //                   ?.toString()
// //                   .isNotEmpty ==
// //               true) {
// //             _registerDocFront = File("provided");
// //           }
// //
// //           if (vendorDetails['registeredDocumentsBack']?.toString().isNotEmpty ==
// //               true) {
// //             _registerDocBack = File("provided");
// //           }
// //
// //           _tradeLicenseNumberController.text =
// //               vendorDetails['tradeLicenseNumber']?.toString() ?? '';
// //
// //           // Check if trade license document exists
// //           if (vendorDetails['tradeLicense']?.toString().isNotEmpty == true) {
// //             _tradeLicenseDoc = File("provided");
// //           }
// //
// //           _tradeLicenseStartDate = _safeParseDate(
// //             vendorDetails['tradeLicenseStartDate'],
// //           );
// //           _tradeLicenseEndDate = _safeParseDate(
// //             vendorDetails['tradeLicenseEndDate'],
// //           );
// //
// //           _fssaiNumberController.text =
// //               vendorDetails['fssaiLicenseNumber']?.toString() ?? '';
// //
// //           // Check if FSSAI license document exists
// //           if (vendorDetails['fssaiLicense']?.toString().isNotEmpty == true) {
// //             _fssaiLicenseDoc = File("provided");
// //           }
// //
// //           _fssaiStartDate = _safeParseDate(vendorDetails['fssaiStartDate']);
// //           _fssaiEndDate = _safeParseDate(vendorDetails['fssaiEndDate']);
// //
// //           _labourLicenseNumberController.text =
// //               vendorDetails['labourLicenseNumber']?.toString() ?? '';
// //
// //           // Check if labour license document exists
// //           if (vendorDetails['labourLicense']?.toString().isNotEmpty == true) {
// //             _labourLicenseDoc = File("provided");
// //           }
// //
// //           _labourStartDate = _safeParseDate(vendorDetails['labourStartDate']);
// //           _labourEndDate = _safeParseDate(vendorDetails['labourEndDate']);
// //
// //           // Check if blank cheque document exists
// //           if (vendorDetails['blankCheque']?.toString().isNotEmpty == true) {
// //             _blankChequeDoc = File("provided");
// //           }
// //
// //           // ================== BANK DETAILS ==================
// //           _accountHolderNameController.text =
// //               vendorDetails['holderName']?.toString() ?? '';
// //           _accountNumberController.text =
// //               vendorDetails['accountNumber']?.toString() ?? '';
// //           _ifscCodeController.text =
// //               vendorDetails['ifscCode']?.toString() ?? '';
// //           _bankNameController.text =
// //               vendorDetails['bankName']?.toString() ?? '';
// //           _branchNameController.text =
// //               vendorDetails['branchName']?.toString() ?? '';
// //
// //           _isLoadingData = false;
// //           debugPrint("📋 Data loaded into form successfully");
// //           debugPrint(
// //             "🖼️ Images marked as 'Provided' where available from server",
// //           );
// //           debugPrint("📊 Vendor is already registered: $_isVendorRegistered");
// //         });
// //       } else {
// //         debugPrint("❌ No vendor registration data found");
// //         setState(() {
// //           _isVendorRegistered = false;
// //           _isLoadingData = false;
// //         });
// //         if (mounted) {
// //           ScaffoldMessenger.of(context).showSnackBar(
// //             const SnackBar(
// //               content: Text(
// //                 "No vendor registration data found. Please fill the form.",
// //               ),
// //               backgroundColor: Colors.orange,
// //             ),
// //           );
// //         }
// //       }
// //     } catch (e) {
// //       debugPrint("⚠️ Error loading vendor registration data: $e");
// //       setState(() {
// //         _isLoadingData = false;
// //         _isVendorRegistered = false;
// //       });
// //       if (mounted) {
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           SnackBar(
// //             content: Text("Error loading data: $e"),
// //             backgroundColor: Colors.red,
// //           ),
// //         );
// //       }
// //     }
// //   }
// //
// //   // Safe date parser
// //   DateTime? _safeParseDate(dynamic dateValue) {
// //     if (dateValue == null) return null;
// //     try {
// //       // Handle different date formats
// //       String dateStr = dateValue.toString();
// //
// //       // If it's already in ISO format
// //       if (dateStr.contains('T')) {
// //         return DateTime.parse(dateStr);
// //       }
// //       // If it's just date (YYYY-MM-DD)
// //       else if (dateStr.contains('-') && dateStr.length == 10) {
// //         return DateTime.parse('${dateStr}T00:00:00Z');
// //       }
// //       // Try parsing as is
// //       return DateTime.parse(dateStr);
// //     } catch (e) {
// //       debugPrint("❌ Error parsing date '$dateValue': $e");
// //       return null;
// //     }
// //   }
// //
// //   Future<void> _finalSubmitVendorDetails() async {
// //     try {
// //       debugPrint("🚀 SUBMIT VENDOR :: START");
// //
// //       // ================== VALIDATION ==================
// //       debugPrint("🔍 Validating all required fields...");
// //       if (!_validateAllFields()) {
// //         debugPrint("❌ Validation failed – missing required fields");
// //
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           const SnackBar(
// //             content: Text("Please fill all required fields"),
// //             backgroundColor: Colors.orange,
// //           ),
// //         );
// //         return;
// //       }
// //       debugPrint("✅ Validation success");
// //
// //       // ================== VENDOR DATA ==================
// //       debugPrint("📦 Preparing vendor data");
// //
// //       final Map<String, dynamic> vendorData = {
// //         "ownerName": _fullNameController.text.trim(),
// //         "mobileNumber": _mobileController.text.trim(),
// //         "email": _emailController.text.trim(),
// //         "latitude": _latitude,
// //         "longitude": _longitude,
// //
// //         "type": _selectedtype ?? "",
// //         "vendorType": _selectedVendorType ?? "",
// //         "orderTypes": _selectedOrderTypes,
// //         "registeredName": _regBusinessNameController.text.trim(),
// //         "businessPlan": _businessPlanController.text.trim(),
// //
// //         // Address - corrected field names
// //         "fullAddress": _fullAddressController.text.trim(),
// //         "doorNumber": _doorNoController.text.trim(),
// //         "addressLine": _addressLineController.text.trim(),
// //         "landMark": _landmarkController.text.trim(),
// //         "city": _cityController.text.trim(),
// //         "pincode": int.tryParse(_pincodeController.text.trim()) ?? 0,
// //         "state": _stateController.text.trim(),
// //         "country": _countryController.text.trim(),
// //
// //         "holderName": _accountHolderNameController.text.trim(),
// //         "accountNumber": _accountNumberController.text.trim(),
// //         "ifscCode": _ifscCodeController.text.trim(),
// //         "bankName": _bankNameController.text.trim(),
// //         "branchName": _branchNameController.text.trim(),
// //
// //         "aadharNumber": _aadhaarNumberController.text.trim(),
// //         "panCardNumber": _panNumberController.text.trim(),
// //         "gstNumber": _gstNumberController.text.trim(),
// //         "tradeLicenseNumber": _tradeLicenseNumberController.text.trim(),
// //         "fssaiLicenseNumber": _fssaiNumberController.text.trim(),
// //         "labourLicenseNumber": _labourLicenseNumberController.text.trim(),
// //
// //         "tradeLicenseStartDate": _tradeLicenseStartDate
// //             ?.toUtc()
// //             .toIso8601String(),
// //         "tradeLicenseEndDate": _tradeLicenseEndDate?.toUtc().toIso8601String(),
// //         "fssaiStartDate": _fssaiStartDate?.toUtc().toIso8601String(),
// //         "fssaiEndDate": _fssaiEndDate?.toUtc().toIso8601String(),
// //         "labourStartDate": _labourStartDate?.toUtc().toIso8601String(),
// //         "labourEndDate": _labourEndDate?.toUtc().toIso8601String(),
// //       };
// //
// //       vendorData.removeWhere(
// //         (key, value) => value == null || value.toString().isEmpty,
// //       );
// //
// //       debugPrint("📄 Vendor fields count: ${vendorData.length}");
// //       debugPrint("📏 Vendor JSON size: ${jsonEncode(vendorData).length} bytes");
// //
// //       // ================== FILES ==================
// //       debugPrint("📎 Preparing files");
// //
// //       final Map<String, File> files = {};
// //       if (_logoFile != null && _logoFile!.path != "provided")
// //         files["companyLogo"] = _logoFile!;
// //       if (_aadhaarFront != null && _aadhaarFront!.path != "provided")
// //         files["aadharPhotoFront"] = _aadhaarFront!;
// //       if (_aadhaarBack != null && _aadhaarBack!.path != "provided")
// //         files["aadharPhotoBack"] = _aadhaarBack!;
// //       if (_panCardDoc != null && _panCardDoc!.path != "provided")
// //         files["panCard"] = _panCardDoc!;
// //       if (_registerDocFront != null && _registerDocFront!.path != "provided")
// //         files["registeredDocumentsFront"] = _registerDocFront!;
// //       if (_registerDocBack != null && _registerDocBack!.path != "provided")
// //         files["registeredDocumentsBack"] = _registerDocBack!;
// //       if (_tradeLicenseDoc != null && _tradeLicenseDoc!.path != "provided")
// //         files["tradeLicense"] = _tradeLicenseDoc!;
// //       if (_fssaiLicenseDoc != null && _fssaiLicenseDoc!.path != "provided")
// //         files["fssaiLicense"] = _fssaiLicenseDoc!;
// //       if (_labourLicenseDoc != null && _labourLicenseDoc!.path != "provided")
// //         files["labourLicense"] = _labourLicenseDoc!;
// //       if (_blankChequeDoc != null && _blankChequeDoc!.path != "provided")
// //         files["blankCheque"] = _blankChequeDoc!;
// //
// //       debugPrint("📂 Total files attached: ${files.length}");
// //
// //       // ================== VENDOR ID ==================
// //       final prefs = await SharedPreferences.getInstance();
// //       final vendorId = prefs.getInt('vendorId') ?? 0;
// //       debugPrint("🆔 Vendor ID: $vendorId");
// //
// //       // ================== LOADER ==================
// //       showDialog(
// //         context: context,
// //         barrierDismissible: false,
// //         builder: (context) => const Center(child: CircularProgressIndicator()),
// //       );
// //
// //       // ================== API CALL ==================
// //       debugPrint("🌐 Sending multipart request...");
// //       final response = await ApiClient.sendMultipartRequest(
// //         service: "food",
// //         endpoint: "api/vendors/$vendorId",
// //         method: "POST",
// //         data: {"vendorData": jsonEncode(vendorData)},
// //         files: files,
// //       );
// //
// //       // ================== RESPONSE ==================
// //       if (context.mounted) Navigator.of(context).pop();
// //
// //       debugPrint("📡 Status Code: ${response.statusCode}");
// //       debugPrint("📡 Response Body:\n${response.body}");
// //
// //       dynamic responseBody;
// //
// //       if (response.body.trim().startsWith('<')) {
// //         debugPrint("⚠️ HTML response received (NGINX / 413 error)");
// //         responseBody = null;
// //       } else {
// //         responseBody = jsonDecode(response.body);
// //       }
// //
// //       if (response.statusCode == 200 || response.statusCode == 201) {
// //         // Update registration status after successful submission
// //         setState(() {
// //           _isVendorRegistered = true;
// //         });
// //
// //         if (context.mounted) {
// //           ScaffoldMessenger.of(context).showSnackBar(
// //             SnackBar(
// //               content: Text(
// //                 responseBody?['message'] ??
// //                     "Vendor details submitted successfully",
// //               ),
// //               backgroundColor: Colors.green,
// //             ),
// //           );
// //         }
// //       } else {
// //         String errorMessage =
// //             responseBody?['message'] ??
// //             responseBody?['error'] ??
// //             "Server error (${response.statusCode})";
// //
// //         if (context.mounted) {
// //           ScaffoldMessenger.of(context).showSnackBar(
// //             SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
// //           );
// //         }
// //       }
// //     } catch (e, stackTrace) {
// //       debugPrint("🔥 Exception occurred");
// //       debugPrint("❌ Error: $e");
// //       debugPrint("📌 StackTrace: $stackTrace");
// //
// //       if (context.mounted && Navigator.of(context).canPop()) {
// //         Navigator.of(context).pop();
// //       }
// //
// //       if (context.mounted) {
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           SnackBar(
// //             content: Text("Network error: ${e.toString()}"),
// //             backgroundColor: Colors.red,
// //           ),
// //         );
// //       }
// //     }
// //   }
// //
// //   // Add validation method
// //   bool _validateAllFields() {
// //     // Check all mandatory fields
// //     if (_fullNameController.text.isEmpty ||
// //         _mobileController.text.length != 10 ||
// //         _emailController.text.isEmpty ||
// //         !_emailController.text.contains('@') ||
// //         (_logoFile == null || _logoFile?.path == "provided") ||
// //         _selectedtype == null ||
// //         _selectedVendorType == null ||
// //         _selectedOrderTypes.isEmpty ||
// //         _regBusinessNameController.text.isEmpty ||
// //         _fullAddressController.text.isEmpty ||
// //         _cityController.text.isEmpty ||
// //         _pincodeController.text.isEmpty ||
// //         _stateController.text.isEmpty ||
// //         _countryController.text.isEmpty ||
// //         _aadhaarNumberController.text.isEmpty ||
// //         _panNumberController.text.isEmpty ||
// //         _gstNumberController.text.isEmpty ||
// //         _tradeLicenseNumberController.text.isEmpty ||
// //         _fssaiNumberController.text.isEmpty ||
// //         _labourLicenseNumberController.text.isEmpty ||
// //         _accountHolderNameController.text.isEmpty ||
// //         _accountNumberController.text.isEmpty ||
// //         _ifscCodeController.text.isEmpty ||
// //         _bankNameController.text.isEmpty ||
// //         _branchNameController.text.isEmpty) {
// //       return false;
// //     }
// //
// //     // Check document files (skip if already provided from server)
// //     if ((_aadhaarFront == null || _aadhaarFront?.path == "provided") ||
// //         (_aadhaarBack == null || _aadhaarBack?.path == "provided") ||
// //         (_panCardDoc == null || _panCardDoc?.path == "provided") ||
// //         (_registerDocFront == null || _registerDocFront?.path == "provided") ||
// //         (_registerDocBack == null || _registerDocBack?.path == "provided") ||
// //         (_tradeLicenseDoc == null || _tradeLicenseDoc?.path == "provided") ||
// //         (_fssaiLicenseDoc == null || _fssaiLicenseDoc?.path == "provided") ||
// //         (_labourLicenseDoc == null || _labourLicenseDoc?.path == "provided") ||
// //         (_blankChequeDoc == null || _blankChequeDoc?.path == "provided")) {
// //       return false;
// //     }
// //
// //     // Check dates
// //     if (_tradeLicenseStartDate == null ||
// //         _tradeLicenseEndDate == null ||
// //         _fssaiStartDate == null ||
// //         _fssaiEndDate == null ||
// //         _labourStartDate == null ||
// //         _labourEndDate == null) {
// //       return false;
// //     }
// //
// //     return true;
// //   }
// //
// //   // Method to update field status (you can call this after verification)
// //   void _updateFieldStatus(
// //     String fieldKey,
// //     FieldStatus status, {
// //     String? message,
// //   }) {
// //     setState(() {
// //       _fieldStatus[fieldKey] = FieldStatusInfo(
// //         status: status,
// //         message: message,
// //         lastUpdated: DateTime.now(),
// //       );
// //     });
// //   }
// //
// //   // Status indicator widget
// //   Widget _buildStatusIndicator(String fieldKey) {
// //     final statusInfo = _fieldStatus[fieldKey] ?? FieldStatusInfo();
// //
// //     Color color;
// //     IconData icon;
// //     String tooltip;
// //
// //     switch (statusInfo.status) {
// //       case FieldStatus.verified:
// //         color = Colors.green;
// //         icon = Icons.check_circle;
// //         tooltip = 'Verified';
// //         break;
// //       case FieldStatus.rejected:
// //         color = Colors.red;
// //         icon = Icons.error;
// //         tooltip =
// //             'Rejected: ${statusInfo.message ?? "Please correct this field"}';
// //         break;
// //       case FieldStatus.pending:
// //         color = Colors.orange;
// //         icon = Icons.pending;
// //         tooltip = 'Pending: ${statusInfo.message ?? "Under review"}';
// //         break;
// //       case FieldStatus.notVerified:
// //       default:
// //         color = Colors.grey;
// //         tooltip = 'Not Verified';
// //     }
// //
// //     return Tooltip(message: tooltip);
// //   }
// //
// //   // Enhanced text field with status indicator
// //   Widget _buildTextFieldWithStatus({
// //     required TextEditingController controller,
// //     required String label,
// //     required String fieldKey,
// //     TextInputType? keyboardType,
// //     int? maxLength,
// //     bool isMandatory = true,
// //   }) {
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         Row(
// //           children: [
// //             Text("$label ${isMandatory ? '*' : ''}"),
// //             const SizedBox(width: 4),
// //             _buildStatusIndicator(fieldKey),
// //           ],
// //         ),
// //         const SizedBox(height: 4),
// //         TextFormField(
// //           controller: controller,
// //           keyboardType: keyboardType,
// //           maxLength: maxLength,
// //           onChanged: (value) {
// //             // Reset status when user edits the field
// //             if (_fieldStatus[fieldKey]?.status != FieldStatus.notVerified) {
// //               _updateFieldStatus(fieldKey, FieldStatus.notVerified);
// //             }
// //           },
// //           decoration: InputDecoration(
// //             border: const OutlineInputBorder(),
// //             hintText: "Enter $label",
// //             counterText: "",
// //           ),
// //         ),
// //         const SizedBox(height: 12),
// //       ],
// //     );
// //   }
// //
// //   // Enhanced upload container with status
// //   Widget _buildUploadContainerWithStatus({
// //     required File? file,
// //     required VoidCallback onTap,
// //     required String fieldKey,
// //     required String label,
// //     bool isMandatory = true,
// //   }) {
// //     final isProvided = file?.path == "provided";
// //
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         Row(
// //           children: [
// //             Text("$label ${isMandatory ? '*' : ''}"),
// //             const SizedBox(width: 4),
// //             _buildStatusIndicator(fieldKey),
// //           ],
// //         ),
// //         const SizedBox(height: 4),
// //         InkWell(
// //           onTap: isProvided ? null : onTap,
// //           child: Container(
// //             height: 100,
// //             width: 100,
// //             decoration: BoxDecoration(
// //               border: Border.all(
// //                 color: isProvided ? Colors.green : Colors.grey,
// //                 width: isProvided ? 2 : 1,
// //               ),
// //               borderRadius: BorderRadius.circular(8),
// //               color: isProvided ? Colors.green.shade50 : Colors.white,
// //             ),
// //             child: isProvided
// //                 ? const Center(
// //                     child: Column(
// //                       mainAxisAlignment: MainAxisAlignment.center,
// //                       children: [
// //                         Icon(Icons.cloud_done, size: 40, color: Colors.green),
// //                         SizedBox(height: 8),
// //                         Text(
// //                           "Provided",
// //                           style: TextStyle(
// //                             color: Colors.green,
// //                             fontSize: 12,
// //                             fontWeight: FontWeight.bold,
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   )
// //                 : file != null && file.path != "provided"
// //                 ? Image.file(file, fit: BoxFit.cover)
// //                 : const Center(
// //                     child: Icon(
// //                       Icons.upload_file,
// //                       size: 30,
// //                       color: Colors.grey,
// //                     ),
// //                   ),
// //           ),
// //         ),
// //         const SizedBox(height: 12),
// //       ],
// //     );
// //   }
// //
// //   // Enhanced dropdown with status
// //   Widget _buildDropdownWithStatus({
// //     required String? value,
// //     required List<String> items,
// //     required Function(String?) onChanged,
// //     required String label,
// //     required String fieldKey,
// //     bool isMandatory = true,
// //   }) {
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         Row(
// //           children: [
// //             Text("$label ${isMandatory ? '*' : ''}"),
// //             const SizedBox(width: 4),
// //             _buildStatusIndicator(fieldKey),
// //           ],
// //         ),
// //         const SizedBox(height: 4),
// //         DropdownButtonFormField<String>(
// //           decoration: const InputDecoration(border: OutlineInputBorder()),
// //           dropdownColor: Colors.white,
// //           value: value,
// //           items: items
// //               .map((e) => DropdownMenuItem(value: e, child: Text(e)))
// //               .toList(),
// //           onChanged: (val) {
// //             onChanged(val);
// //             // Reset status when user changes selection
// //             if (_fieldStatus[fieldKey]?.status != FieldStatus.notVerified) {
// //               _updateFieldStatus(fieldKey, FieldStatus.notVerified);
// //             }
// //           },
// //           hint: Text("Select $label"),
// //         ),
// //         const SizedBox(height: 12),
// //       ],
// //     );
// //   }
// //
// //   // Enhanced date picker with status
// //   Widget _buildDatePickerWithStatus({
// //     required DateTime? date,
// //     required VoidCallback onTap,
// //     required String label,
// //     required String fieldKey,
// //     bool isMandatory = true,
// //   }) {
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         Row(
// //           children: [
// //             Text("$label ${isMandatory ? '*' : ''}"),
// //             const SizedBox(width: 4),
// //             _buildStatusIndicator(fieldKey),
// //           ],
// //         ),
// //         const SizedBox(height: 4),
// //         InkWell(
// //           onTap: () {
// //             onTap();
// //             // Reset status when user picks new date
// //             if (_fieldStatus[fieldKey]?.status != FieldStatus.notVerified) {
// //               _updateFieldStatus(fieldKey, FieldStatus.notVerified);
// //             }
// //           },
// //           child: Container(
// //             height: 50,
// //             padding: const EdgeInsets.symmetric(horizontal: 8),
// //             decoration: BoxDecoration(
// //               border: Border.all(color: Colors.grey),
// //               borderRadius: BorderRadius.circular(8),
// //             ),
// //             alignment: Alignment.centerLeft,
// //             child: Text(
// //               date != null ? "${date.toLocal()}".split(' ')[0] : "Select Date",
// //             ),
// //           ),
// //         ),
// //         const SizedBox(height: 12),
// //       ],
// //     );
// //   }
// //
// //   // Order Type Checkbox Widget
// //   Widget _buildOrderTypeCheckbox(String value, String label) {
// //     return FilterChip(
// //       label: Text(label),
// //       selected: _selectedOrderTypes.contains(value),
// //       onSelected: (selected) {
// //         setState(() {
// //           if (selected) {
// //             _selectedOrderTypes.add(value);
// //           } else {
// //             _selectedOrderTypes.remove(value);
// //           }
// //           // Reset status when user changes selection
// //           if (_fieldStatus['orderTypes']?.status != FieldStatus.notVerified) {
// //             _updateFieldStatus('orderTypes', FieldStatus.notVerified);
// //           }
// //         });
// //       },
// //       checkmarkColor: Colors.white,
// //       selectedColor: Colors.green,
// //       backgroundColor: Colors.grey[200],
// //       shape: RoundedRectangleBorder(
// //         borderRadius: BorderRadius.circular(20),
// //         side: BorderSide(color: Colors.grey.shade300),
// //       ),
// //     );
// //   }
// //
// //   @override
// //   void dispose() {
// //     // Dispose all controllers...
// //     _fullNameController.dispose();
// //     _mobileController.dispose();
// //     _emailController.dispose();
// //     _regBusinessNameController.dispose();
// //     _businessPlanController.dispose();
// //     _latitudeController.dispose();
// //     _longitudeController.dispose();
// //     _fullAddressController.dispose();
// //     _doorNoController.dispose();
// //     _addressLineController.dispose();
// //     _landmarkController.dispose();
// //     _cityController.dispose();
// //     _pincodeController.dispose();
// //     _stateController.dispose();
// //     _countryController.dispose();
// //     _aadhaarNumberController.dispose();
// //     _panNumberController.dispose();
// //     _gstNumberController.dispose();
// //     _tradeLicenseNumberController.dispose();
// //     _fssaiNumberController.dispose();
// //     _labourLicenseNumberController.dispose();
// //     _accountHolderNameController.dispose();
// //     _accountNumberController.dispose();
// //     _ifscCodeController.dispose();
// //     _bankNameController.dispose();
// //     _branchNameController.dispose();
// //     super.dispose();
// //   }
// //
// //   // Pick Logo
// //   Future<void> _pickLogo() async {
// //     final XFile? pickedFile = await _picker.pickImage(
// //       source: ImageSource.gallery,
// //     );
// //     if (pickedFile != null) {
// //       setState(() {
// //         _logoFile = File(pickedFile.path);
// //       });
// //     }
// //   }
// //
// //   // Pick File
// //   Future<void> _pickFile(Function(File) setter) async {
// //     final XFile? pickedFile = await _picker.pickImage(
// //       source: ImageSource.gallery,
// //     );
// //     if (pickedFile != null) {
// //       setState(() {
// //         setter(File(pickedFile.path));
// //       });
// //     }
// //   }
// //
// //   // Pick Date
// //   Future<void> _pickDate(
// //     BuildContext context,
// //     Function(DateTime) setter,
// //   ) async {
// //     DateTime? picked = await showDatePicker(
// //       context: context,
// //       initialDate: DateTime.now(),
// //       firstDate: DateTime(2000),
// //       lastDate: DateTime(2100),
// //     );
// //     if (picked != null) {
// //       setState(() {
// //         setter(picked);
// //       });
// //     }
// //   }
// //
// //   // Display Uploaded File Name/Placeholder for Review
// //   Widget _buildFileDisplay(File? file, String label) {
// //     final isProvided = file?.path == "provided";
// //
// //     return Padding(
// //       padding: const EdgeInsets.symmetric(vertical: 4.0),
// //       child: Row(
// //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //         children: [
// //           Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
// //           Text(
// //             isProvided
// //                 ? "Provided ✓"
// //                 : file != null && file.path != "provided"
// //                 ? 'Uploaded'
// //                 : 'Not Uploaded',
// //             style: TextStyle(
// //               color: isProvided
// //                   ? Colors.green
// //                   : file != null && file.path != "provided"
// //                   ? Colors.green
// //                   : Colors.red,
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   // Review Item Widget with status
// //   Widget _buildReviewItem(
// //     String label,
// //     String value, {
// //     bool isImage = false,
// //     File? file,
// //     String? fieldKey,
// //   }) {
// //     final statusWidget = fieldKey != null
// //         ? _buildStatusIndicator(fieldKey)
// //         : const SizedBox();
// //
// //     if (isImage) {
// //       final isProvided = file?.path == "provided";
// //
// //       return Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           Row(
// //             children: [
// //               Text(
// //                 label,
// //                 style: const TextStyle(
// //                   fontWeight: FontWeight.w600,
// //                   fontSize: 14,
// //                 ),
// //               ),
// //               const SizedBox(width: 4),
// //               statusWidget,
// //             ],
// //           ),
// //           const SizedBox(height: 4),
// //           Container(
// //             padding: const EdgeInsets.all(8),
// //             decoration: BoxDecoration(
// //               border: Border.all(
// //                 color: isProvided || (file != null && file.path != "provided")
// //                     ? Colors.green
// //                     : Colors.grey,
// //               ),
// //               borderRadius: BorderRadius.circular(8),
// //             ),
// //             child: Row(
// //               children: [
// //                 Icon(
// //                   isProvided || (file != null && file.path != "provided")
// //                       ? Icons.check_circle
// //                       : Icons.image,
// //                   color: isProvided || (file != null && file.path != "provided")
// //                       ? Colors.green
// //                       : Colors.grey,
// //                 ),
// //                 const SizedBox(width: 8),
// //                 Text(
// //                   isProvided
// //                       ? "Provided (from server)"
// //                       : file != null && file.path != "provided"
// //                       ? "Uploaded (new)"
// //                       : "Not Provided",
// //                   style: TextStyle(
// //                     color:
// //                         isProvided || (file != null && file.path != "provided")
// //                         ? Colors.green
// //                         : Colors.grey,
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //           const Divider(),
// //         ],
// //       );
// //     }
// //
// //     return Padding(
// //       padding: const EdgeInsets.only(bottom: 8.0),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           Row(
// //             children: [
// //               Text(
// //                 label,
// //                 style: const TextStyle(
// //                   fontWeight: FontWeight.w600,
// //                   fontSize: 14,
// //                 ),
// //               ),
// //               const SizedBox(width: 4),
// //               statusWidget,
// //             ],
// //           ),
// //           Text(
// //             value.isEmpty ? 'N/A' : value,
// //             style: const TextStyle(fontSize: 14),
// //           ),
// //           const Divider(),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   // Render Step Fields with status indicators
// //   Widget _buildStepFields(int step) {
// //     if (_isLoadingData) {
// //       return const Center(child: CircularProgressIndicator());
// //     }
// //
// //     switch (step) {
// //       // Step 0: Personal Info
// //       case 0:
// //         return Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             _buildTextFieldWithStatus(
// //               controller: _fullNameController,
// //               label: "Full Name",
// //               fieldKey: 'fullName',
// //             ),
// //             _buildTextFieldWithStatus(
// //               controller: _mobileController,
// //               label: "Mobile Number",
// //               fieldKey: 'mobile',
// //               keyboardType: TextInputType.number,
// //               maxLength: 10,
// //             ),
// //             _buildTextFieldWithStatus(
// //               controller: _emailController,
// //               label: "Email",
// //               fieldKey: 'email',
// //               keyboardType: TextInputType.emailAddress,
// //             ),
// //             _buildUploadContainerWithStatus(
// //               file: _logoFile,
// //               onTap: _pickLogo,
// //               fieldKey: 'logo',
// //               label: "Logo",
// //             ),
// //             const SizedBox(height: 20),
// //             Row(
// //               mainAxisAlignment: MainAxisAlignment.end,
// //               children: [
// //                 ElevatedButton(
// //                   style: ElevatedButton.styleFrom(
// //                     backgroundColor: Colors.green,
// //                     foregroundColor: Colors.white,
// //                     padding: const EdgeInsets.symmetric(
// //                       horizontal: 32,
// //                       vertical: 14,
// //                     ),
// //                     shape: RoundedRectangleBorder(
// //                       borderRadius: BorderRadius.circular(12),
// //                     ),
// //                     elevation: 3,
// //                   ),
// //                   onPressed: () {
// //                     if (_fullNameController.text.isEmpty) {
// //                       ScaffoldMessenger.of(context).showSnackBar(
// //                         const SnackBar(content: Text("Full Name is required")),
// //                       );
// //                       return;
// //                     }
// //                     if (_mobileController.text.length != 10) {
// //                       ScaffoldMessenger.of(context).showSnackBar(
// //                         const SnackBar(
// //                           content: Text("Mobile must be 10 digits"),
// //                         ),
// //                       );
// //                       return;
// //                     }
// //                     if (!_emailController.text.contains("@") ||
// //                         !_emailController.text.contains(".")) {
// //                       ScaffoldMessenger.of(context).showSnackBar(
// //                         const SnackBar(
// //                           content: Text("Please enter a valid email"),
// //                         ),
// //                       );
// //                       return;
// //                     }
// //                     if (_logoFile == null) {
// //                       ScaffoldMessenger.of(context).showSnackBar(
// //                         const SnackBar(content: Text("Please upload a logo")),
// //                       );
// //                       return;
// //                     }
// //
// //                     setState(() => _currentStep = 1);
// //                   },
// //                   child: const Text("Next"),
// //                 ),
// //               ],
// //             ),
// //           ],
// //         );
// //
// //       // Step 1: Business Details
// //       case 1:
// //         return SingleChildScrollView(
// //           child: Column(
// //             crossAxisAlignment: CrossAxisAlignment.start,
// //             children: [
// //               _buildDropdownWithStatus(
// //                 value: _selectedtype,
// //                 items: const [
// //                   "HOTEL",
// //                   "RESTAURANT",
// //                   "CAFE",
// //                   "CLOUD_KITCHEN",
// //                   "FOOD_COURT",
// //                   "STREET_FOOD",
// //                   "BAKERY",
// //                 ],
// //                 onChanged: (val) {
// //                   setState(() {
// //                     _selectedtype = val;
// //                   });
// //                 },
// //                 label: "Business Type",
// //                 fieldKey: 'businessType',
// //               ),
// //               _buildDropdownWithStatus(
// //                 value: _selectedVendorType,
// //                 items: ["Restaurant", "FashionStore", "Hotel", "BanquetHall"],
// //                 onChanged: (val) {
// //                   setState(() {
// //                     _selectedVendorType = val;
// //                   });
// //                 },
// //                 label: "Vendor Type",
// //                 fieldKey: 'vendorType',
// //               ),
// //               // Order Types Checkboxes
// //               Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   Row(
// //                     children: [
// //                       Text("Order Types *"),
// //                       const SizedBox(width: 4),
// //                       _buildStatusIndicator('orderTypes'),
// //                     ],
// //                   ),
// //                   const SizedBox(height: 8),
// //                   Wrap(
// //                     spacing: 12,
// //                     runSpacing: 8,
// //                     children: [
// //                       _buildOrderTypeCheckbox("DINE_IN", "Dine In"),
// //                       _buildOrderTypeCheckbox("DELIVERY", "Delivery"),
// //                       _buildOrderTypeCheckbox("TAKEAWAY", "Takeaway"),
// //                       _buildOrderTypeCheckbox("TABLE_DINE_IN", "Table Dine In"),
// //                     ],
// //                   ),
// //                   const SizedBox(height: 12),
// //                 ],
// //               ),
// //               _buildTextFieldWithStatus(
// //                 controller: _regBusinessNameController,
// //                 label: "Registered Business Name",
// //                 fieldKey: 'registeredBusinessName',
// //               ),
// //               _buildTextFieldWithStatus(
// //                 controller: _businessPlanController,
// //                 label: "Business Plan",
// //                 fieldKey: 'businessPlan',
// //               ),
// //               const SizedBox(height: 20),
// //               Row(
// //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                 children: [
// //                   ElevatedButton(
// //                     style: ElevatedButton.styleFrom(
// //                       backgroundColor: Colors.blueAccent,
// //                       foregroundColor: Colors.white,
// //                       padding: const EdgeInsets.symmetric(
// //                         horizontal: 32,
// //                         vertical: 14,
// //                       ),
// //                       shape: RoundedRectangleBorder(
// //                         borderRadius: BorderRadius.circular(12),
// //                       ),
// //                       elevation: 3,
// //                     ),
// //                     onPressed: () {
// //                       setState(() {
// //                         _currentStep = 0;
// //                       });
// //                     },
// //                     child: const Text("Back"),
// //                   ),
// //                   ElevatedButton(
// //                     style: ElevatedButton.styleFrom(
// //                       backgroundColor: Colors.green,
// //                       foregroundColor: Colors.white,
// //                       padding: const EdgeInsets.symmetric(
// //                         horizontal: 32,
// //                         vertical: 14,
// //                       ),
// //                       shape: RoundedRectangleBorder(
// //                         borderRadius: BorderRadius.circular(12),
// //                       ),
// //                       elevation: 3,
// //                     ),
// //                     onPressed: () {
// //                       if (_selectedtype == null ||
// //                           _selectedVendorType == null ||
// //                           _selectedOrderTypes.isEmpty ||
// //                           _regBusinessNameController.text.isEmpty ||
// //                           _businessPlanController.text.isEmpty) {
// //                         ScaffoldMessenger.of(context).showSnackBar(
// //                           const SnackBar(
// //                             content: Text(
// //                               "All Business Detail fields are required",
// //                             ),
// //                           ),
// //                         );
// //                         return;
// //                       }
// //
// //                       setState(() {
// //                         _currentStep = 2;
// //                       });
// //                     },
// //                     child: const Text("Next"),
// //                   ),
// //                 ],
// //               ),
// //             ],
// //           ),
// //         );
// //
// //       // Step 2: Address
// //       case 2:
// //         return SingleChildScrollView(
// //           child: Column(
// //             crossAxisAlignment: CrossAxisAlignment.start,
// //             children: [
// //               const Text(
// //                 "Select Location on Map *",
// //                 style: TextStyle(fontWeight: FontWeight.bold),
// //               ),
// //               const SizedBox(height: 8),
// //               // Google Map Container
// //               GoogleMapsPage(
// //                 onAddressSelected: (city, pincode, state, country, lat, lng) {
// //                   setState(() {
// //                     _cityController.text = city;
// //                     _pincodeController.text = pincode;
// //                     _stateController.text = state;
// //                     _countryController.text = country;
// //                     _latitude = lat;
// //                     _longitude = lng;
// //                   });
// //                 },
// //               ),
// //               const SizedBox(height: 12),
// //               _buildTextFieldWithStatus(
// //                 controller: _fullAddressController,
// //                 label: "Full Address",
// //                 fieldKey: 'fullAddress',
// //               ),
// //               _buildTextFieldWithStatus(
// //                 controller: _doorNoController,
// //                 label: "Door No",
// //                 fieldKey: 'doorNo',
// //               ),
// //               _buildTextFieldWithStatus(
// //                 controller: _addressLineController,
// //                 label: "Address Line",
// //                 fieldKey: 'addressLine',
// //               ),
// //               _buildTextFieldWithStatus(
// //                 controller: _landmarkController,
// //                 label: "Landmark",
// //                 fieldKey: 'landmark',
// //                 isMandatory: false,
// //               ),
// //               _buildTextFieldWithStatus(
// //                 controller: _cityController,
// //                 label: "City",
// //                 fieldKey: 'city',
// //               ),
// //               _buildTextFieldWithStatus(
// //                 controller: _pincodeController,
// //                 label: "Pincode",
// //                 fieldKey: 'pincode',
// //                 keyboardType: TextInputType.number,
// //               ),
// //               _buildTextFieldWithStatus(
// //                 controller: _stateController,
// //                 label: "State",
// //                 fieldKey: 'state',
// //               ),
// //               _buildTextFieldWithStatus(
// //                 controller: _countryController,
// //                 label: "Country",
// //                 fieldKey: 'country',
// //               ),
// //               const SizedBox(height: 20),
// //               Row(
// //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                 children: [
// //                   ElevatedButton(
// //                     style: ElevatedButton.styleFrom(
// //                       backgroundColor: Colors.blueAccent,
// //                       foregroundColor: Colors.white,
// //                       padding: const EdgeInsets.symmetric(
// //                         horizontal: 32,
// //                         vertical: 14,
// //                       ),
// //                       shape: RoundedRectangleBorder(
// //                         borderRadius: BorderRadius.circular(12),
// //                       ),
// //                       elevation: 3,
// //                     ),
// //                     onPressed: () {
// //                       setState(() {
// //                         _currentStep = 1;
// //                       });
// //                     },
// //                     child: const Text("Back"),
// //                   ),
// //                   ElevatedButton(
// //                     style: ElevatedButton.styleFrom(
// //                       backgroundColor: Colors.green,
// //                       foregroundColor: Colors.white,
// //                       padding: const EdgeInsets.symmetric(
// //                         horizontal: 32,
// //                         vertical: 14,
// //                       ),
// //                       shape: RoundedRectangleBorder(
// //                         borderRadius: BorderRadius.circular(12),
// //                       ),
// //                       elevation: 3,
// //                     ),
// //                     onPressed: () {
// //                       if (_fullAddressController.text.isEmpty ||
// //                           _doorNoController.text.isEmpty ||
// //                           _addressLineController.text.isEmpty ||
// //                           _cityController.text.isEmpty ||
// //                           _pincodeController.text.isEmpty ||
// //                           _stateController.text.isEmpty ||
// //                           _countryController.text.isEmpty) {
// //                         ScaffoldMessenger.of(context).showSnackBar(
// //                           const SnackBar(
// //                             content: Text(
// //                               "Please fill all mandatory address fields (*).",
// //                             ),
// //                           ),
// //                         );
// //                         return;
// //                       }
// //                       setState(() {
// //                         _currentStep = 3;
// //                       });
// //                     },
// //                     child: const Text("Next"),
// //                   ),
// //                 ],
// //               ),
// //             ],
// //           ),
// //         );
// //
// //       // Step 3: Required Documents
// //       case 3:
// //         return SingleChildScrollView(
// //           child: Column(
// //             crossAxisAlignment: CrossAxisAlignment.start,
// //             children: [
// //               _buildTextFieldWithStatus(
// //                 controller: _aadhaarNumberController,
// //                 label: "Aadhaar Number",
// //                 fieldKey: 'aadhaarNumber',
// //                 keyboardType: TextInputType.number,
// //                 maxLength: 12,
// //               ),
// //               _buildUploadContainerWithStatus(
// //                 file: _aadhaarFront,
// //                 onTap: () => _pickFile((file) => _aadhaarFront = file),
// //                 fieldKey: 'aadhaarFront',
// //                 label: "Aadhaar Front",
// //               ),
// //               _buildUploadContainerWithStatus(
// //                 file: _aadhaarBack,
// //                 onTap: () => _pickFile((file) => _aadhaarBack = file),
// //                 fieldKey: 'aadhaarBack',
// //                 label: "Aadhaar Back",
// //               ),
// //               _buildTextFieldWithStatus(
// //                 controller: _panNumberController,
// //                 label: "PAN Number",
// //                 fieldKey: 'panNumber',
// //                 maxLength: 10,
// //               ),
// //               _buildUploadContainerWithStatus(
// //                 file: _panCardDoc,
// //                 onTap: () => _pickFile((file) => _panCardDoc = file),
// //                 fieldKey: 'panCardDoc',
// //                 label: "PAN Document",
// //               ),
// //               _buildTextFieldWithStatus(
// //                 controller: _gstNumberController,
// //                 label: "GST Number",
// //                 fieldKey: 'gstNumber',
// //               ),
// //               _buildUploadContainerWithStatus(
// //                 file: _registerDocFront,
// //                 onTap: () => _pickFile((file) => _registerDocFront = file),
// //                 fieldKey: 'registerDocFront',
// //                 label: "Register Document Front",
// //               ),
// //               _buildUploadContainerWithStatus(
// //                 file: _registerDocBack,
// //                 onTap: () => _pickFile((file) => _registerDocBack = file),
// //                 fieldKey: 'registerDocBack',
// //                 label: "Register Document Back",
// //               ),
// //               _buildTextFieldWithStatus(
// //                 controller: _tradeLicenseNumberController,
// //                 label: "Trade License Number",
// //                 fieldKey: 'tradeLicenseNumber',
// //               ),
// //               _buildUploadContainerWithStatus(
// //                 file: _tradeLicenseDoc,
// //                 onTap: () => _pickFile((file) => _tradeLicenseDoc = file),
// //                 fieldKey: 'tradeLicenseDoc',
// //                 label: "Trade License Document",
// //               ),
// //               _buildDatePickerWithStatus(
// //                 date: _tradeLicenseStartDate,
// //                 onTap: () =>
// //                     _pickDate(context, (date) => _tradeLicenseStartDate = date),
// //                 label: "Trade License Start Date",
// //                 fieldKey: 'tradeLicenseStartDate',
// //               ),
// //               _buildDatePickerWithStatus(
// //                 date: _tradeLicenseEndDate,
// //                 onTap: () =>
// //                     _pickDate(context, (date) => _tradeLicenseEndDate = date),
// //                 label: "Trade License End Date",
// //                 fieldKey: 'tradeLicenseEndDate',
// //               ),
// //               _buildTextFieldWithStatus(
// //                 controller: _fssaiNumberController,
// //                 label: "FSSAI License Number",
// //                 fieldKey: 'fssaiNumber',
// //               ),
// //               _buildUploadContainerWithStatus(
// //                 file: _fssaiLicenseDoc,
// //                 onTap: () => _pickFile((file) => _fssaiLicenseDoc = file),
// //                 fieldKey: 'fssaiLicenseDoc',
// //                 label: "FSSAI License Document",
// //               ),
// //               _buildDatePickerWithStatus(
// //                 date: _fssaiStartDate,
// //                 onTap: () =>
// //                     _pickDate(context, (date) => _fssaiStartDate = date),
// //                 label: "FSSAI Start Date",
// //                 fieldKey: 'fssaiStartDate',
// //               ),
// //               _buildDatePickerWithStatus(
// //                 date: _fssaiEndDate,
// //                 onTap: () => _pickDate(context, (date) => _fssaiEndDate = date),
// //                 label: "FSSAI End Date",
// //                 fieldKey: 'fssaiEndDate',
// //               ),
// //               _buildTextFieldWithStatus(
// //                 controller: _labourLicenseNumberController,
// //                 label: "Labour License Number",
// //                 fieldKey: 'labourLicenseNumber',
// //               ),
// //               _buildUploadContainerWithStatus(
// //                 file: _labourLicenseDoc,
// //                 onTap: () => _pickFile((file) => _labourLicenseDoc = file),
// //                 fieldKey: 'labourLicenseDoc',
// //                 label: "Labour License Document",
// //               ),
// //               _buildDatePickerWithStatus(
// //                 date: _labourStartDate,
// //                 onTap: () =>
// //                     _pickDate(context, (date) => _labourStartDate = date),
// //                 label: "Labour License Start Date",
// //                 fieldKey: 'labourStartDate',
// //               ),
// //               _buildDatePickerWithStatus(
// //                 date: _labourEndDate,
// //                 onTap: () =>
// //                     _pickDate(context, (date) => _labourEndDate = date),
// //                 label: "Labour License End Date",
// //                 fieldKey: 'labourEndDate',
// //               ),
// //               _buildUploadContainerWithStatus(
// //                 file: _blankChequeDoc,
// //                 onTap: () => _pickFile((file) => _blankChequeDoc = file),
// //                 fieldKey: 'blankChequeDoc',
// //                 label: "Blank Cheque Document",
// //               ),
// //               const SizedBox(height: 20),
// //               Row(
// //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                 children: [
// //                   ElevatedButton(
// //                     style: ElevatedButton.styleFrom(
// //                       backgroundColor: Colors.blueAccent,
// //                       foregroundColor: Colors.white,
// //                       padding: const EdgeInsets.symmetric(
// //                         horizontal: 32,
// //                         vertical: 14,
// //                       ),
// //                       shape: RoundedRectangleBorder(
// //                         borderRadius: BorderRadius.circular(12),
// //                       ),
// //                       elevation: 3,
// //                     ),
// //                     onPressed: () {
// //                       setState(() {
// //                         _currentStep = 2;
// //                       });
// //                     },
// //                     child: const Text("Back"),
// //                   ),
// //                   ElevatedButton(
// //                     style: ElevatedButton.styleFrom(
// //                       backgroundColor: Colors.green,
// //                       foregroundColor: Colors.white,
// //                       padding: const EdgeInsets.symmetric(
// //                         horizontal: 32,
// //                         vertical: 14,
// //                       ),
// //                       shape: RoundedRectangleBorder(
// //                         borderRadius: BorderRadius.circular(12),
// //                       ),
// //                       elevation: 3,
// //                     ),
// //                     onPressed: () {
// //                       // ALL Document Validation Check
// //                       if (_aadhaarNumberController.text.isEmpty ||
// //                           _panNumberController.text.isEmpty ||
// //                           _aadhaarFront == null ||
// //                           _aadhaarBack == null ||
// //                           _panCardDoc == null ||
// //                           _blankChequeDoc == null ||
// //                           _gstNumberController.text.isEmpty ||
// //                           _registerDocFront == null ||
// //                           _registerDocBack == null ||
// //                           _tradeLicenseNumberController.text.isEmpty ||
// //                           _tradeLicenseDoc == null ||
// //                           _tradeLicenseStartDate == null ||
// //                           _tradeLicenseEndDate == null ||
// //                           _fssaiNumberController.text.isEmpty ||
// //                           _fssaiLicenseDoc == null ||
// //                           _fssaiStartDate == null ||
// //                           _fssaiEndDate == null ||
// //                           _labourLicenseNumberController.text.isEmpty ||
// //                           _labourLicenseDoc == null ||
// //                           _labourStartDate == null ||
// //                           _labourEndDate == null) {
// //                         ScaffoldMessenger.of(context).showSnackBar(
// //                           const SnackBar(
// //                             content: Text(
// //                               "Please fill/upload all mandatory document fields (*).",
// //                             ),
// //                           ),
// //                         );
// //                         return;
// //                       }
// //
// //                       setState(() {
// //                         _currentStep = 4;
// //                       });
// //                     },
// //                     child: const Text("Next"),
// //                   ),
// //                 ],
// //               ),
// //             ],
// //           ),
// //         );
// //
// //       // Step 4: Bank Account Details
// //       case 4:
// //         return SingleChildScrollView(
// //           child: Column(
// //             crossAxisAlignment: CrossAxisAlignment.start,
// //             children: [
// //               _buildTextFieldWithStatus(
// //                 controller: _accountHolderNameController,
// //                 label: "Account Holder Name",
// //                 fieldKey: 'accountHolderName',
// //               ),
// //               _buildTextFieldWithStatus(
// //                 controller: _accountNumberController,
// //                 label: "Account Number",
// //                 fieldKey: 'accountNumber',
// //                 keyboardType: TextInputType.number,
// //               ),
// //               _buildTextFieldWithStatus(
// //                 controller: _ifscCodeController,
// //                 label: "IFSC Code",
// //                 fieldKey: 'ifscCode',
// //               ),
// //               _buildTextFieldWithStatus(
// //                 controller: _bankNameController,
// //                 label: "Bank Name",
// //                 fieldKey: 'bankName',
// //               ),
// //               _buildTextFieldWithStatus(
// //                 controller: _branchNameController,
// //                 label: "Branch Name",
// //                 fieldKey: 'branchName',
// //               ),
// //               const SizedBox(height: 20),
// //               Row(
// //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                 children: [
// //                   ElevatedButton(
// //                     style: ElevatedButton.styleFrom(
// //                       backgroundColor: Colors.blueAccent,
// //                       foregroundColor: Colors.white,
// //                       padding: const EdgeInsets.symmetric(
// //                         horizontal: 32,
// //                         vertical: 14,
// //                       ),
// //                       shape: RoundedRectangleBorder(
// //                         borderRadius: BorderRadius.circular(12),
// //                       ),
// //                       elevation: 3,
// //                     ),
// //                     onPressed: () {
// //                       setState(() {
// //                         _currentStep = 3;
// //                       });
// //                     },
// //                     child: const Text("Back"),
// //                   ),
// //                   ElevatedButton(
// //                     style: ElevatedButton.styleFrom(
// //                       backgroundColor: Colors.green,
// //                       foregroundColor: Colors.white,
// //                       padding: const EdgeInsets.symmetric(
// //                         horizontal: 32,
// //                         vertical: 14,
// //                       ),
// //                       shape: RoundedRectangleBorder(
// //                         borderRadius: BorderRadius.circular(12),
// //                       ),
// //                       elevation: 3,
// //                     ),
// //                     onPressed: () {
// //                       // Bank Details Validation
// //                       if (_accountHolderNameController.text.isEmpty ||
// //                           _accountNumberController.text.isEmpty ||
// //                           _ifscCodeController.text.isEmpty ||
// //                           _bankNameController.text.isEmpty ||
// //                           _branchNameController.text.isEmpty) {
// //                         ScaffoldMessenger.of(context).showSnackBar(
// //                           const SnackBar(
// //                             content: Text(
// //                               "Please fill all mandatory bank account details (*).",
// //                             ),
// //                           ),
// //                         );
// //                         return;
// //                       }
// //
// //                       // Navigate to Review page (Step 5)
// //                       setState(() {
// //                         _currentStep = 5;
// //                       });
// //                     },
// //                     child: const Text("Review"),
// //                   ),
// //                 ],
// //               ),
// //             ],
// //           ),
// //         );
// //
// //       // Step 5: Review
// //       case 5:
// //         return SingleChildScrollView(
// //           child: Column(
// //             crossAxisAlignment: CrossAxisAlignment.start,
// //             children: [
// //               // Show registration status banner
// //               Container(
// //                 padding: const EdgeInsets.all(16),
// //                 margin: const EdgeInsets.only(bottom: 20),
// //                 decoration: BoxDecoration(
// //                   color: _isVendorRegistered
// //                       ? Colors.green.shade50
// //                       : Colors.orange.shade50,
// //                   borderRadius: BorderRadius.circular(12),
// //                   border: Border.all(
// //                     color: _isVendorRegistered ? Colors.green : Colors.orange,
// //                   ),
// //                 ),
// //                 child: Row(
// //                   children: [
// //                     Icon(
// //                       _isVendorRegistered ? Icons.check_circle : Icons.warning,
// //                       color: _isVendorRegistered ? Colors.green : Colors.orange,
// //                       size: 30,
// //                     ),
// //                     const SizedBox(width: 12),
// //                     Expanded(
// //                       child: Column(
// //                         crossAxisAlignment: CrossAxisAlignment.start,
// //                         children: [
// //                           Text(
// //                             _isVendorRegistered
// //                                 ? "Vendor Already Registered"
// //                                 : "Vendor Not Registered Yet",
// //                             style: TextStyle(
// //                               fontSize: 16,
// //                               fontWeight: FontWeight.bold,
// //                               color: _isVendorRegistered
// //                                   ? Colors.green
// //                                   : Colors.orange,
// //                             ),
// //                           ),
// //                           const SizedBox(height: 4),
// //                           Text(
// //                             _isVendorRegistered
// //                                 ? "Your registration details are already submitted. You can review but cannot submit again."
// //                                 : "Please review and submit your registration details.",
// //                             style: const TextStyle(fontSize: 14),
// //                           ),
// //                         ],
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //
// //               const Text(
// //                 "Review all details before final submission.",
// //                 style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
// //               ),
// //               const SizedBox(height: 20),
// //
// //               // --- Personal Info Review ---
// //               const Text(
// //                 "📋 Personal Info",
// //                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
// //               ),
// //               const Divider(),
// //               _buildReviewItem(
// //                 "Full Name",
// //                 _fullNameController.text,
// //                 fieldKey: 'fullName',
// //               ),
// //               _buildReviewItem(
// //                 "Mobile Number",
// //                 _mobileController.text,
// //                 fieldKey: 'mobile',
// //               ),
// //               _buildReviewItem(
// //                 "Email",
// //                 _emailController.text,
// //                 fieldKey: 'email',
// //               ),
// //               _buildReviewItem(
// //                 "Logo",
// //                 "",
// //                 isImage: true,
// //                 file: _logoFile,
// //                 fieldKey: 'logo',
// //               ),
// //
// //               // --- Business Details Review ---
// //               const SizedBox(height: 10),
// //               const Text(
// //                 "🏢 Business Details",
// //                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
// //               ),
// //               const Divider(),
// //               _buildReviewItem(
// //                 "Business Type",
// //                 _selectedtype ?? 'N/A',
// //                 fieldKey: 'businessType',
// //               ),
// //               _buildReviewItem(
// //                 "Vendor Type",
// //                 _selectedVendorType ?? 'N/A',
// //                 fieldKey: 'vendorType',
// //               ),
// //               _buildReviewItem(
// //                 "Order Types",
// //                 _selectedOrderTypes.isNotEmpty
// //                     ? _selectedOrderTypes.join(', ')
// //                     : 'N/A',
// //                 fieldKey: 'orderTypes',
// //               ),
// //               _buildReviewItem(
// //                 "Registered Business Name",
// //                 _regBusinessNameController.text,
// //                 fieldKey: 'registeredBusinessName',
// //               ),
// //               _buildReviewItem(
// //                 "Business Plan",
// //                 _businessPlanController.text,
// //                 fieldKey: 'businessPlan',
// //               ),
// //
// //               // --- Address Review ---
// //               const SizedBox(height: 10),
// //               const Text(
// //                 "📍 Address",
// //                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
// //               ),
// //               const Divider(),
// //               _buildReviewItem(
// //                 "Full Address",
// //                 _fullAddressController.text,
// //                 fieldKey: 'fullAddress',
// //               ),
// //               _buildReviewItem(
// //                 "Door No",
// //                 _doorNoController.text,
// //                 fieldKey: 'doorNo',
// //               ),
// //               _buildReviewItem(
// //                 "Address Line",
// //                 _addressLineController.text,
// //                 fieldKey: 'addressLine',
// //               ),
// //               _buildReviewItem(
// //                 "Landmark",
// //                 _landmarkController.text,
// //                 fieldKey: 'landmark',
// //               ),
// //               _buildReviewItem("City", _cityController.text, fieldKey: 'city'),
// //               _buildReviewItem(
// //                 "Pincode",
// //                 _pincodeController.text,
// //                 fieldKey: 'pincode',
// //               ),
// //               _buildReviewItem(
// //                 "State",
// //                 _stateController.text,
// //                 fieldKey: 'state',
// //               ),
// //               _buildReviewItem(
// //                 "Country",
// //                 _countryController.text,
// //                 fieldKey: 'country',
// //               ),
// //
// //               // --- Bank Account Details Review ---
// //               const SizedBox(height: 10),
// //               const Text(
// //                 "🏦 Bank Account Details",
// //                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
// //               ),
// //               const Divider(),
// //               _buildReviewItem(
// //                 "Account Holder Name",
// //                 _accountHolderNameController.text,
// //                 fieldKey: 'accountHolderName',
// //               ),
// //               _buildReviewItem(
// //                 "Account Number",
// //                 _accountNumberController.text,
// //                 fieldKey: 'accountNumber',
// //               ),
// //               _buildReviewItem(
// //                 "IFSC Code",
// //                 _ifscCodeController.text,
// //                 fieldKey: 'ifscCode',
// //               ),
// //               _buildReviewItem(
// //                 "Bank Name",
// //                 _bankNameController.text,
// //                 fieldKey: 'bankName',
// //               ),
// //               _buildReviewItem(
// //                 "Branch Name",
// //                 _branchNameController.text,
// //                 fieldKey: 'branchName',
// //               ),
// //
// //               // --- Required Documents Review ---
// //               const SizedBox(height: 10),
// //               const Text(
// //                 "📄 Required Documents",
// //                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
// //               ),
// //               const Divider(),
// //               _buildReviewItem(
// //                 "Aadhaar Number",
// //                 _aadhaarNumberController.text,
// //                 fieldKey: 'aadhaarNumber',
// //               ),
// //               _buildFileDisplay(_aadhaarFront, 'Aadhaar Front'),
// //               _buildFileDisplay(_aadhaarBack, 'Aadhaar Back'),
// //               _buildReviewItem(
// //                 "PAN Number",
// //                 _panNumberController.text,
// //                 fieldKey: 'panNumber',
// //               ),
// //               _buildFileDisplay(_panCardDoc, 'PAN Document'),
// //               _buildReviewItem(
// //                 "GST Number",
// //                 _gstNumberController.text,
// //                 fieldKey: 'gstNumber',
// //               ),
// //               _buildFileDisplay(_registerDocFront, 'Register Doc Front'),
// //               _buildFileDisplay(_registerDocBack, 'Register Doc Back'),
// //               _buildReviewItem(
// //                 "Trade License Number",
// //                 _tradeLicenseNumberController.text,
// //                 fieldKey: 'tradeLicenseNumber',
// //               ),
// //               _buildFileDisplay(_tradeLicenseDoc, 'Trade License Doc'),
// //               _buildReviewItem(
// //                 "Trade License Dates",
// //                 "${_tradeLicenseStartDate?.toLocal().toString().split(' ')[0] ?? 'N/A'} to ${_tradeLicenseEndDate?.toLocal().toString().split(' ')[0] ?? 'N/A'}",
// //               ),
// //               _buildReviewItem(
// //                 "FSSAI Number",
// //                 _fssaiNumberController.text,
// //                 fieldKey: 'fssaiNumber',
// //               ),
// //               _buildFileDisplay(_fssaiLicenseDoc, 'FSSAI License Doc'),
// //               _buildReviewItem(
// //                 "FSSAI Dates",
// //                 "${_fssaiStartDate?.toLocal().toString().split(' ')[0] ?? 'N/A'} to ${_fssaiEndDate?.toLocal().toString().split(' ')[0] ?? 'N/A'}",
// //               ),
// //               _buildReviewItem(
// //                 "Labour License Number",
// //                 _labourLicenseNumberController.text,
// //                 fieldKey: 'labourLicenseNumber',
// //               ),
// //               _buildFileDisplay(_labourLicenseDoc, 'Labour License Doc'),
// //               _buildReviewItem(
// //                 "Labour Dates",
// //                 "${_labourStartDate?.toLocal().toString().split(' ')[0] ?? 'N/A'} to ${_labourEndDate?.toLocal().toString().split(' ')[0] ?? 'N/A'}",
// //               ),
// //               _buildFileDisplay(_blankChequeDoc, 'Blank Cheque'),
// //
// //               const SizedBox(height: 20),
// //               Row(
// //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                 children: [
// //                   ElevatedButton(
// //                     onPressed: () {
// //                       setState(() {
// //                         _currentStep = 4;
// //                       });
// //                     },
// //                     child: const Text("Back"),
// //                   ),
// //                   // Conditionally show Submit button only if vendor is not registered
// //                   if (!_isVendorRegistered)
// //                     ElevatedButton(
// //                       onPressed: () async {
// //                         await _finalSubmitVendorDetails();
// //                       },
// //                       style: ElevatedButton.styleFrom(
// //                         backgroundColor: Colors.green,
// //                         foregroundColor: Colors.white,
// //                       ),
// //                       child: const Text("Final Submit"),
// //                     )
// //                   else
// //                     ElevatedButton(
// //                       onPressed: null,
// //                       style: ElevatedButton.styleFrom(
// //                         backgroundColor: Colors.grey,
// //                         foregroundColor: Colors.white,
// //                       ),
// //                       child: const Text("Already Submitted"),
// //                     ),
// //                 ],
// //               ),
// //             ],
// //           ),
// //         );
// //
// //       default:
// //         return Center(
// //           child: Text(
// //             "Fields for '${steps[step]}' will go here",
// //             style: const TextStyle(fontSize: 16),
// //           ),
// //         );
// //     }
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return WillPopScope(
// //       onWillPop: () async {
// //         _navigateBackToHome();
// //         return false;
// //       },
// //       child: Scaffold(
// //         // appBar: AppBar(
// //         //   backgroundColor: Colors.transparent,
// //         //   elevation: 0,
// //         //   automaticallyImplyLeading: true,
// //         //   leading: IconButton(
// //         //     icon: Icon(Icons.arrow_back, color: Colors.black),
// //         //     onPressed: _navigateBackToHome,
// //         //   ),
// //         //   title: Text(
// //         //     'Vendor Registration',
// //         //     style: TextStyle(
// //         //       color: Colors.black,
// //         //       fontWeight: FontWeight.bold,
// //         //       fontSize: 20,
// //         //     ),
// //         //   ),
// //         // ),
// //         body: Row(
// //           children: [
// //             Container(
// //               width: 60,
// //               color: Colors.grey[200],
// //               child: ListView.builder(
// //                 itemCount: steps.length,
// //                 itemBuilder: (context, index) {
// //                   return InkWell(
// //                     onTap: () {
// //                       setState(() {
// //                         _currentStep = index;
// //                       });
// //                     },
// //                     child: Padding(
// //                       padding: const EdgeInsets.symmetric(
// //                         vertical: 16,
// //                         horizontal: 8,
// //                       ),
// //                       child: Column(
// //                         children: [
// //                           CircleAvatar(
// //                             radius: 12,
// //                             backgroundColor: _currentStep == index
// //                                 ? Colors.deepPurple
// //                                 : Colors.grey,
// //                             child: Text(
// //                               "${index + 1}",
// //                               style: const TextStyle(
// //                                 color: Colors.white,
// //                                 fontSize: 12,
// //                               ),
// //                             ),
// //                           ),
// //                           const SizedBox(height: 4),
// //                           Text(
// //                             steps[index],
// //                             textAlign: TextAlign.center,
// //                             style: TextStyle(
// //                               fontSize: 10,
// //                               fontWeight: _currentStep == index
// //                                   ? FontWeight.bold
// //                                   : FontWeight.normal,
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                     ),
// //                   );
// //                 },
// //               ),
// //             ),
// //             Expanded(
// //               child: Padding(
// //                 padding: const EdgeInsets.all(16.0),
// //                 child: _buildStepFields(_currentStep),
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }
// //
// // // GoogleMapsPage class remains the same
// // class GoogleMapsPage extends StatefulWidget {
// //   final Function(
// //     String city,
// //     String pincode,
// //     String state,
// //     String county,
// //     double latitude,
// //     double longitude,
// //   )?
// //   onAddressSelected;
// //
// //   const GoogleMapsPage({super.key, this.onAddressSelected});
// //
// //   @override
// //   State<GoogleMapsPage> createState() => _GoogleMapsPageState();
// // }
// //
// // class _GoogleMapsPageState extends State<GoogleMapsPage> {
// //   GoogleMapController? mapController;
// //
// //   static const LatLng _initialPosition = LatLng(17.385044, 78.486671);
// //   static const CameraPosition _initialCameraPosition = CameraPosition(
// //     target: _initialPosition,
// //     zoom: 14,
// //   );
// //
// //   final String _googleApiKey = "AIzaSyCf7bYn7iDIs2T6-sDnmr7qWy9oFZOPOuc";
// //   LatLng _currentLatLng = _initialPosition;
// //   String _city = "";
// //   String _pincode = "";
// //   String _state = "";
// //   String _country = " ";
// //
// //   bool _isLoading = false;
// //   bool _hasPermission = true;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _getCurrentLocation();
// //   }
// //
// //   Future<void> _getCurrentLocation() async {
// //     try {
// //       bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
// //       if (!serviceEnabled) {
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           const SnackBar(content: Text("Location services are disabled.")),
// //         );
// //         return;
// //       }
// //
// //       LocationPermission permission = await Geolocator.checkPermission();
// //       if (permission == LocationPermission.denied) {
// //         permission = await Geolocator.requestPermission();
// //       }
// //
// //       if (permission == LocationPermission.denied) {
// //         setState(() => _hasPermission = false);
// //         return;
// //       }
// //
// //       if (permission == LocationPermission.deniedForever) {
// //         setState(() => _hasPermission = false);
// //         return;
// //       }
// //
// //       setState(() => _hasPermission = true);
// //
// //       final position = await Geolocator.getCurrentPosition(
// //         desiredAccuracy: LocationAccuracy.high,
// //       );
// //
// //       _updateLocation(LatLng(position.latitude, position.longitude));
// //       mapController?.animateCamera(
// //         CameraUpdate.newLatLngZoom(
// //           LatLng(position.latitude, position.longitude),
// //           16,
// //         ),
// //       );
// //     } catch (e) {
// //       ScaffoldMessenger.of(
// //         context,
// //       ).showSnackBar(SnackBar(content: Text("Error: $e")));
// //     }
// //   }
// //
// //   Future<void> _updateLocation(LatLng latLng) async {
// //     setState(() {
// //       _currentLatLng = latLng;
// //       _isLoading = true;
// //     });
// //
// //     try {
// //       final placemarks = await placemarkFromCoordinates(
// //         latLng.latitude,
// //         latLng.longitude,
// //       );
// //
// //       if (placemarks.isNotEmpty) {
// //         final place = placemarks.first;
// //         _city = place.locality ?? "";
// //         _pincode = place.postalCode ?? "";
// //         _state = place.administrativeArea ?? "";
// //         _country = place.country ?? "";
// //
// //         widget.onAddressSelected?.call(
// //           _city,
// //           _pincode,
// //           _state,
// //           _country,
// //           latLng.latitude,
// //           latLng.longitude,
// //         );
// //       }
// //     } catch (e) {
// //       debugPrint("Reverse geocoding failed: $e");
// //     }
// //
// //     setState(() => _isLoading = false);
// //   }
// //
// //   Future<void> _handleSearch() async {
// //     Prediction? p = await PlacesAutocomplete.show(
// //       context: context,
// //       apiKey: _googleApiKey,
// //       mode: Mode.overlay,
// //       language: "en",
// //       components: [Component(Component.country, "in")],
// //       logo: const SizedBox.shrink(),
// //     );
// //
// //     if (p != null) {
// //       final places = GoogleMapsPlaces(
// //         apiKey: _googleApiKey,
// //         apiHeaders: await const GoogleApiHeaders().getHeaders(),
// //       );
// //
// //       final detail = await places.getDetailsByPlaceId(p.placeId!);
// //       final location = detail.result.geometry!.location;
// //
// //       _updateLocation(LatLng(location.lat, location.lng));
// //       mapController?.animateCamera(
// //         CameraUpdate.newLatLngZoom(LatLng(location.lat, location.lng), 16),
// //       );
// //     }
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Container(
// //       height: 400,
// //       decoration: BoxDecoration(
// //         borderRadius: BorderRadius.circular(8),
// //         border: Border.all(color: Colors.grey.shade300),
// //       ),
// //       child: Stack(
// //         alignment: Alignment.center,
// //         children: [
// //           ClipRRect(
// //             borderRadius: BorderRadius.circular(8),
// //             child: GoogleMap(
// //               initialCameraPosition: _initialCameraPosition,
// //               onMapCreated: (controller) => mapController = controller,
// //               myLocationEnabled: true,
// //               myLocationButtonEnabled: false,
// //               zoomControlsEnabled: false,
// //               onCameraMove: (pos) {
// //                 _currentLatLng = pos.target;
// //               },
// //               onCameraIdle: () {
// //                 _updateLocation(_currentLatLng);
// //               },
// //               gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
// //                 Factory<OneSequenceGestureRecognizer>(
// //                   () => EagerGestureRecognizer(),
// //                 ),
// //               },
// //             ),
// //           ),
// //           const Icon(Icons.location_pin, size: 50, color: Colors.red),
// //           Positioned(
// //             top: 10,
// //             left: 10,
// //             right: 10,
// //             child: InkWell(
// //               onTap: _handleSearch,
// //               child: Container(
// //                 height: 50,
// //                 padding: const EdgeInsets.symmetric(horizontal: 12),
// //                 decoration: BoxDecoration(
// //                   color: Colors.white,
// //                   borderRadius: BorderRadius.circular(8),
// //                   boxShadow: [
// //                     BoxShadow(
// //                       color: Colors.black26,
// //                       blurRadius: 4,
// //                       offset: const Offset(0, 2),
// //                     ),
// //                   ],
// //                 ),
// //                 child: Row(
// //                   children: const [
// //                     Icon(Icons.search, color: Colors.grey),
// //                     SizedBox(width: 8),
// //                     Text(
// //                       "Search location...",
// //                       style: TextStyle(color: Colors.grey),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //             ),
// //           ),
// //           Positioned(
// //             bottom: 80,
// //             right: 10,
// //             child: FloatingActionButton(
// //               mini: true,
// //               backgroundColor: Colors.blue,
// //               onPressed: _getCurrentLocation,
// //               child: const Icon(Icons.my_location, color: Colors.white),
// //             ),
// //           ),
// //           if (_isLoading)
// //             const Positioned(bottom: 10, child: CircularProgressIndicator()),
// //           if (!_hasPermission)
// //             Positioned.fill(
// //               child: Container(
// //                 color: Colors.white.withOpacity(0.9),
// //                 child: Center(
// //                   child: Column(
// //                     mainAxisSize: MainAxisSize.min,
// //                     children: [
// //                       const Icon(
// //                         Icons.location_off,
// //                         size: 60,
// //                         color: Colors.red,
// //                       ),
// //                       const SizedBox(height: 16),
// //                       const Text(
// //                         "Location permission required",
// //                         style: TextStyle(
// //                           fontSize: 18,
// //                           fontWeight: FontWeight.bold,
// //                         ),
// //                       ),
// //                       const SizedBox(height: 8),
// //                       const Text(
// //                         "Please enable location access to use the map.",
// //                         textAlign: TextAlign.center,
// //                       ),
// //                       const SizedBox(height: 20),
// //                       ElevatedButton.icon(
// //                         onPressed: () async {
// //                           await Geolocator.openAppSettings();
// //                         },
// //                         icon: const Icon(Icons.settings),
// //                         label: const Text("Open Settings"),
// //                         style: ElevatedButton.styleFrom(
// //                           backgroundColor: Colors.blue,
// //                           foregroundColor: Colors.white,
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //               ),
// //             ),
// //         ],
// //       ),
// //     );
// //   }
// // }
// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
// import 'package:flutter_google_places_hoc081098/google_maps_webservice_places.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:google_api_headers/google_api_headers.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:maamaaspartner/Api/APIclient.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../Api/food_authservice.dart';
// import '../widgets_helper/Home_screen_1.dart';
//
// // ─── Design tokens ─────────────────────────────────────────────────────────────
// const _cPrimary = Color(0xFFE66D33);
// const _cPrimaryLt = Color(0xFFFFF0E8);
// const _cSurface = Color(0xFFFFFFFF);
// const _cBg = Color(0xFFF6F7FA);
// const _cBorder = Color(0xFFECEDF2);
// const _cText = Color(0xFF111827);
// const _cSub = Color(0xFF6B7280);
// const _cMuted = Color(0xFFB0B3C1);
// const _cSuccess = Color(0xFF10B981);
// const _cSuccessLt = Color(0xFFD1FAE5);
// const _cDanger = Color(0xFFEF4444);
// const _cDangerLt = Color(0xFFFEE2E2);
// const _cInfo = Color(0xFF3B82F6);
// const _cInfoLt = Color(0xFFDBEAFE);
//
// enum FieldStatus { notVerified, verified, rejected, pending }
//
// class FieldStatusInfo {
//   final FieldStatus status;
//   final String? message;
//   final DateTime? lastUpdated;
//   FieldStatusInfo({
//     this.status = FieldStatus.notVerified,
//     this.message,
//     this.lastUpdated,
//   });
// }
//
// class Registration extends StatefulWidget {
//   const Registration({Key? key}) : super(key: key);
//   @override
//   State<Registration> createState() => _RegistrationState();
// }
//
// class _RegistrationState extends State<Registration> {
//   int _currentStep = 0;
//   bool _isVendorRegistered = false;
//   bool _isLoadingData = true;
//
//   final _fullNameCtrl = TextEditingController();
//   final _mobileCtrl = TextEditingController();
//   final _emailCtrl = TextEditingController();
//   File? _logoFile;
//   final _picker = ImagePicker();
//   double? _latitude, _longitude;
//
//   String? _selectedType, _selectedVendorType;
//   List<String> _selectedOrderTypes = [];
//   final _bizNameCtrl = TextEditingController();
//   final _bizPlanCtrl = TextEditingController();
//
//   final _fullAddrCtrl = TextEditingController();
//   final _doorNoCtrl = TextEditingController();
//   final _addrLineCtrl = TextEditingController();
//   final _landmarkCtrl = TextEditingController();
//   final _cityCtrl = TextEditingController();
//   final _pincodeCtrl = TextEditingController();
//   final _stateCtrl = TextEditingController();
//   final _countryCtrl = TextEditingController();
//
//   final _aadhaarNoCtrl = TextEditingController();
//   File? _aadhaarFront, _aadhaarBack;
//   final _panNoCtrl = TextEditingController();
//   File? _panDoc;
//   final _gstNoCtrl = TextEditingController();
//   File? _regDocFront, _regDocBack;
//   final _tradeLicNoCtrl = TextEditingController();
//   File? _tradeLicDoc;
//   DateTime? _tradeLicStart, _tradeLicEnd;
//   final _fssaiNoCtrl = TextEditingController();
//   File? _fssaiDoc;
//   DateTime? _fssaiStart, _fssaiEnd;
//   final _labourLicNoCtrl = TextEditingController();
//   File? _labourDoc;
//   DateTime? _labourStart, _labourEnd;
//   File? _blankChequeDoc;
//
//   final _acHolderCtrl = TextEditingController();
//   final _acNoCtrl = TextEditingController();
//   final _ifscCtrl = TextEditingController();
//   final _bankNameCtrl = TextEditingController();
//   final _branchCtrl = TextEditingController();
//
//   final Map<String, FieldStatusInfo> _fieldStatus = {};
//
//   static const _stepMeta = [
//     _StepMeta('Personal', Icons.person_rounded, _cInfo),
//     _StepMeta('Business', Icons.store_rounded, _cPrimary),
//     _StepMeta('Address', Icons.location_on_rounded, _cSuccess),
//     _StepMeta('Documents', Icons.description_rounded, Color(0xFF8B5CF6)),
//     _StepMeta('Bank', Icons.account_balance_rounded, Color(0xFFF59E0B)),
//     _StepMeta('Review', Icons.fact_check_rounded, _cDanger),
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     _loadVendorData();
//   }
//
//   Future<void> _loadVendorData() async {
//     try {
//       setState(() => _isLoadingData = true);
//       final data = await food_authservice.fetchVendorRegistrationDetails();
//       if (data != null && mounted) {
//         final hasEssential =
//             data['ownerName']?.toString().isNotEmpty == true &&
//             data['mobileNumber']?.toString().isNotEmpty == true;
//         setState(() {
//           _isVendorRegistered =
//               hasEssential ||
//               data['isRegistered'] == true ||
//               data['registrationStatus'] == 'COMPLETED';
//
//           _fullNameCtrl.text = data['ownerName']?.toString() ?? '';
//           _mobileCtrl.text = data['mobileNumber']?.toString() ?? '';
//           _emailCtrl.text = data['email']?.toString() ?? '';
//           if (data['companyLogo']?.toString().isNotEmpty == true)
//             _logoFile = File('provided');
//
//           _selectedType = data['type']?.toString();
//           _selectedVendorType = data['vendorType']?.toString();
//           final ot = data['orderTypes'];
//           if (ot is List)
//             _selectedOrderTypes = List<String>.from(
//               ot.map((e) => e.toString()),
//             );
//
//           _bizNameCtrl.text = data['registeredName']?.toString() ?? '';
//           _bizPlanCtrl.text = data['businessPlan']?.toString() ?? '';
//
//           _latitude = data['latitude']?.toDouble();
//           _longitude = data['longitude']?.toDouble();
//           _fullAddrCtrl.text = data['fullAddress']?.toString() ?? '';
//           _doorNoCtrl.text = data['doorNumber']?.toString() ?? '';
//           _addrLineCtrl.text = data['addressLine']?.toString() ?? '';
//           _landmarkCtrl.text = data['landMark']?.toString() ?? '';
//           _cityCtrl.text = data['city']?.toString() ?? '';
//           _pincodeCtrl.text = data['pincode']?.toString() ?? '';
//           _stateCtrl.text = data['state']?.toString() ?? '';
//           _countryCtrl.text = data['country']?.toString() ?? 'India';
//
//           _aadhaarNoCtrl.text = data['aadharNumber']?.toString() ?? '';
//           if (data['aadharPhotoFront']?.toString().isNotEmpty == true)
//             _aadhaarFront = File('provided');
//           if (data['aadharPhotoBack']?.toString().isNotEmpty == true)
//             _aadhaarBack = File('provided');
//           _panNoCtrl.text = data['panCardNumber']?.toString() ?? '';
//           if (data['panCard']?.toString().isNotEmpty == true)
//             _panDoc = File('provided');
//           _gstNoCtrl.text = data['gstNumber']?.toString() ?? '';
//           if (data['registeredDocumentsFront']?.toString().isNotEmpty == true)
//             _regDocFront = File('provided');
//           if (data['registeredDocumentsBack']?.toString().isNotEmpty == true)
//             _regDocBack = File('provided');
//
//           _tradeLicNoCtrl.text = data['tradeLicenseNumber']?.toString() ?? '';
//           if (data['tradeLicense']?.toString().isNotEmpty == true)
//             _tradeLicDoc = File('provided');
//           _tradeLicStart = _parseDate(data['tradeLicenseStartDate']);
//           _tradeLicEnd = _parseDate(data['tradeLicenseEndDate']);
//
//           _fssaiNoCtrl.text = data['fssaiLicenseNumber']?.toString() ?? '';
//           if (data['fssaiLicense']?.toString().isNotEmpty == true)
//             _fssaiDoc = File('provided');
//           _fssaiStart = _parseDate(data['fssaiStartDate']);
//           _fssaiEnd = _parseDate(data['fssaiEndDate']);
//
//           _labourLicNoCtrl.text = data['labourLicenseNumber']?.toString() ?? '';
//           if (data['labourLicense']?.toString().isNotEmpty == true)
//             _labourDoc = File('provided');
//           _labourStart = _parseDate(data['labourStartDate']);
//           _labourEnd = _parseDate(data['labourEndDate']);
//
//           if (data['blankCheque']?.toString().isNotEmpty == true)
//             _blankChequeDoc = File('provided');
//
//           _acHolderCtrl.text = data['holderName']?.toString() ?? '';
//           _acNoCtrl.text = data['accountNumber']?.toString() ?? '';
//           _ifscCtrl.text = data['ifscCode']?.toString() ?? '';
//           _bankNameCtrl.text = data['bankName']?.toString() ?? '';
//           _branchCtrl.text = data['branchName']?.toString() ?? '';
//
//           _isLoadingData = false;
//         });
//       } else {
//         setState(() {
//           _isLoadingData = false;
//           _isVendorRegistered = false;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _isLoadingData = false;
//       });
//     }
//   }
//
//   DateTime? _parseDate(dynamic v) {
//     if (v == null) return null;
//     try {
//       return DateTime.parse(v.toString());
//     } catch (_) {
//       return null;
//     }
//   }
//
//   Future<void> _submitVendor() async {
//     final vendorData = {
//       "ownerName": _fullNameCtrl.text.trim(),
//       "mobileNumber": _mobileCtrl.text.trim(),
//       "email": _emailCtrl.text.trim(),
//       "latitude": _latitude,
//       "longitude": _longitude,
//       "type": _selectedType ?? "",
//       "vendorType": _selectedVendorType ?? "",
//       "orderTypes": _selectedOrderTypes,
//       "registeredName": _bizNameCtrl.text.trim(),
//       "businessPlan": _bizPlanCtrl.text.trim(),
//       "fullAddress": _fullAddrCtrl.text.trim(),
//       "doorNumber": _doorNoCtrl.text.trim(),
//       "addressLine": _addrLineCtrl.text.trim(),
//       "landMark": _landmarkCtrl.text.trim(),
//       "city": _cityCtrl.text.trim(),
//       "pincode": int.tryParse(_pincodeCtrl.text.trim()) ?? 0,
//       "state": _stateCtrl.text.trim(),
//       "country": _countryCtrl.text.trim(),
//       "holderName": _acHolderCtrl.text.trim(),
//       "accountNumber": _acNoCtrl.text.trim(),
//       "ifscCode": _ifscCtrl.text.trim(),
//       "bankName": _bankNameCtrl.text.trim(),
//       "branchName": _branchCtrl.text.trim(),
//       "aadharNumber": _aadhaarNoCtrl.text.trim(),
//       "panCardNumber": _panNoCtrl.text.trim(),
//       "gstNumber": _gstNoCtrl.text.trim(),
//       "tradeLicenseNumber": _tradeLicNoCtrl.text.trim(),
//       "fssaiLicenseNumber": _fssaiNoCtrl.text.trim(),
//       "labourLicenseNumber": _labourLicNoCtrl.text.trim(),
//       "tradeLicenseStartDate": _tradeLicStart?.toUtc().toIso8601String(),
//       "tradeLicenseEndDate": _tradeLicEnd?.toUtc().toIso8601String(),
//       "fssaiStartDate": _fssaiStart?.toUtc().toIso8601String(),
//       "fssaiEndDate": _fssaiEnd?.toUtc().toIso8601String(),
//       "labourStartDate": _labourStart?.toUtc().toIso8601String(),
//       "labourEndDate": _labourEnd?.toUtc().toIso8601String(),
//     }..removeWhere((k, v) => v == null || v.toString().isEmpty);
//
//     final files = <String, File>{};
//     void addFile(String key, File? f) {
//       if (f != null && f.path != 'provided') files[key] = f;
//     }
//
//     addFile('companyLogo', _logoFile);
//     addFile('aadharPhotoFront', _aadhaarFront);
//     addFile('aadharPhotoBack', _aadhaarBack);
//     addFile('panCard', _panDoc);
//     addFile('registeredDocumentsFront', _regDocFront);
//     addFile('registeredDocumentsBack', _regDocBack);
//     addFile('tradeLicense', _tradeLicDoc);
//     addFile('fssaiLicense', _fssaiDoc);
//     addFile('labourLicense', _labourDoc);
//     addFile('blankCheque', _blankChequeDoc);
//
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (_) =>
//           const Center(child: CircularProgressIndicator(color: _cPrimary)),
//     );
//
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final vendorId = prefs.getInt('vendorId') ?? 0;
//       final response = await ApiClient.sendMultipartRequest(
//         service: 'food',
//         endpoint: 'api/vendors/$vendorId',
//         method: 'POST',
//         data: {'vendorData': jsonEncode(vendorData)},
//         files: files,
//       );
//       if (mounted && Navigator.canPop(context)) Navigator.pop(context);
//       final body = jsonDecode(response.body);
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         setState(() => _isVendorRegistered = true);
//         _snack(body['message'] ?? 'Submitted successfully!', success: true);
//       } else {
//         _snack(body['message'] ?? 'Submission failed');
//       }
//     } catch (e) {
//       if (mounted && Navigator.canPop(context)) Navigator.pop(context);
//       _snack('Error: $e');
//     }
//   }
//
//   void _snack(String msg, {bool success = false}) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(msg),
//         backgroundColor: success ? _cSuccess : _cDanger,
//       ),
//     );
//   }
//
//   Future<void> _pickImage(Function(File) setter) async {
//     final f = await _picker.pickImage(source: ImageSource.gallery);
//     if (f != null) setState(() => setter(File(f.path)));
//   }
//
//   Future<void> _pickDate(Function(DateTime) setter) async {
//     final d = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2100),
//       builder: (_, child) => Theme(
//         data: Theme.of(
//           context,
//         ).copyWith(colorScheme: const ColorScheme.light(primary: _cPrimary)),
//         child: child!,
//       ),
//     );
//     if (d != null) setState(() => setter(d));
//   }
//
//   @override
//   void dispose() {
//     [
//       _fullNameCtrl,
//       _mobileCtrl,
//       _emailCtrl,
//       _bizNameCtrl,
//       _bizPlanCtrl,
//       _fullAddrCtrl,
//       _doorNoCtrl,
//       _addrLineCtrl,
//       _landmarkCtrl,
//       _cityCtrl,
//       _pincodeCtrl,
//       _stateCtrl,
//       _countryCtrl,
//       _aadhaarNoCtrl,
//       _panNoCtrl,
//       _gstNoCtrl,
//       _tradeLicNoCtrl,
//       _fssaiNoCtrl,
//       _labourLicNoCtrl,
//       _acHolderCtrl,
//       _acNoCtrl,
//       _ifscCtrl,
//       _bankNameCtrl,
//       _branchCtrl,
//     ].forEach((c) => c.dispose());
//     super.dispose();
//   }
//
//   // ── Build ──────────────────────────────────────────────────────────────────
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         if (Navigator.canPop(context)) Navigator.pop(context);
//         return false;
//       },
//       child: Scaffold(
//         backgroundColor: _cBg,
//         body: Row(
//           children: [
//             // ── Sidebar stepper ──────────────────────────────────────────────
//             Container(
//               width: 62,
//               color: _cSurface,
//               child: Column(
//                 children: [
//                   const SizedBox(height: 12),
//                   ..._stepMeta.asMap().entries.map((e) {
//                     final i = e.key;
//                     final s = e.value;
//                     final done = i < _currentStep;
//                     final active = i == _currentStep;
//                     return GestureDetector(
//                       onTap: () => setState(() => _currentStep = i),
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(vertical: 10),
//                         child: Column(
//                           children: [
//                             AnimatedContainer(
//                               duration: const Duration(milliseconds: 220),
//                               width: 36,
//                               height: 36,
//                               decoration: BoxDecoration(
//                                 color: done
//                                     ? _cSuccess
//                                     : active
//                                     ? s.color
//                                     : _cBg,
//                                 shape: BoxShape.circle,
//                                 border: Border.all(
//                                   color: done
//                                       ? _cSuccess
//                                       : active
//                                       ? s.color
//                                       : _cBorder,
//                                   width: active ? 2 : 1,
//                                 ),
//                                 boxShadow: active
//                                     ? [
//                                         BoxShadow(
//                                           color: s.color.withOpacity(0.3),
//                                           blurRadius: 8,
//                                           offset: const Offset(0, 2),
//                                         ),
//                                       ]
//                                     : null,
//                               ),
//                               child: Icon(
//                                 done ? Icons.check_rounded : s.icon,
//                                 size: 16,
//                                 color: (done || active)
//                                     ? Colors.white
//                                     : _cMuted,
//                               ),
//                             ),
//                             const SizedBox(height: 4),
//                             Text(
//                               s.label,
//                               textAlign: TextAlign.center,
//                               style: TextStyle(
//                                 fontSize: 9,
//                                 fontWeight: active
//                                     ? FontWeight.w800
//                                     : FontWeight.w500,
//                                 color: active ? s.color : _cMuted,
//                               ),
//                             ),
//                             // Connector
//                             if (i < _stepMeta.length - 1)
//                               Container(
//                                 width: 2,
//                                 height: 14,
//                                 margin: const EdgeInsets.only(top: 4),
//                                 color: done ? _cSuccess : _cBorder,
//                               ),
//                           ],
//                         ),
//                       ),
//                     );
//                   }),
//                 ],
//               ),
//             ),
//             const VerticalDivider(width: 1, color: _cBorder),
//             // ── Step content ────────────────────────────────────────────────
//             Expanded(
//               child: _isLoadingData
//                   ? const Center(
//                       child: CircularProgressIndicator(
//                         color: _cPrimary,
//                         strokeWidth: 2.5,
//                       ),
//                     )
//                   : SingleChildScrollView(
//                       padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           // Step header
//                           _StepHeader(
//                             step: _currentStep,
//                             meta: _stepMeta[_currentStep],
//                           ),
//                           const SizedBox(height: 16),
//                           _buildStep(_currentStep),
//                         ],
//                       ),
//                     ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildStep(int step) {
//     switch (step) {
//       case 0:
//         return _step0();
//       case 1:
//         return _step1();
//       case 2:
//         return _step2();
//       case 3:
//         return _step3();
//       case 4:
//         return _step4();
//       case 5:
//         return _step5();
//       default:
//         return const SizedBox();
//     }
//   }
//
//   // ── Step 0: Personal Info ───────────────────────────────────────────────────
//   Widget _step0() => Column(
//     children: [
//       _Field(
//         ctrl: _fullNameCtrl,
//         label: 'Full Name',
//         icon: Icons.person_rounded,
//       ),
//       _Field(
//         ctrl: _mobileCtrl,
//         label: 'Mobile Number',
//         icon: Icons.phone_rounded,
//         type: TextInputType.number,
//         maxLen: 10,
//       ),
//       _Field(
//         ctrl: _emailCtrl,
//         label: 'Email Address',
//         icon: Icons.email_rounded,
//         type: TextInputType.emailAddress,
//       ),
//       _UploadBox(
//         label: 'Company Logo',
//         file: _logoFile,
//         onTap: () => _pickImage((f) => _logoFile = f),
//       ),
//       const SizedBox(height: 20),
//       _NavButtons(
//         onNext: () {
//           if (_fullNameCtrl.text.isEmpty) return _snack('Full name required');
//           if (_mobileCtrl.text.length != 10)
//             return _snack('Enter 10-digit mobile');
//           if (!_emailCtrl.text.contains('@'))
//             return _snack('Enter valid email');
//           if (_logoFile == null) return _snack('Please upload logo');
//           setState(() => _currentStep = 1);
//         },
//         showBack: false,
//       ),
//     ],
//   );
//
//   // ── Step 1: Business ───────────────────────────────────────────────────────
//   Widget _step1() => Column(
//     children: [
//       _Dropdown(
//         value: _selectedType,
//         label: 'Business Type',
//         icon: Icons.store_rounded,
//         items: const [
//           'HOTEL',
//           'RESTAURANT',
//           'CAFE',
//           'CLOUD_KITCHEN',
//           'FOOD_COURT',
//           'STREET_FOOD',
//           'BAKERY',
//         ],
//         onChanged: (v) => setState(() => _selectedType = v),
//       ),
//       _Dropdown(
//         value: _selectedVendorType,
//         label: 'Vendor Type',
//         icon: Icons.category_rounded,
//         items: const ['Restaurant', 'FashionStore', 'Hotel', 'BanquetHall'],
//         onChanged: (v) => setState(() => _selectedVendorType = v),
//       ),
//       // Order types
//       _FieldCard(
//         label: 'Order Types',
//         icon: Icons.receipt_long_rounded,
//         child: Wrap(
//           spacing: 8,
//           runSpacing: 8,
//           children: [
//             _OrderChip('DINE_IN', 'Dine In'),
//             _OrderChip('DELIVERY', 'Delivery'),
//             _OrderChip('TAKEAWAY', 'Takeaway'),
//             _OrderChip('TABLE_DINE_IN', 'Table Dine In'),
//           ],
//         ),
//       ),
//       const SizedBox(height: 10),
//       _Field(
//         ctrl: _bizNameCtrl,
//         label: 'Registered Business Name',
//         icon: Icons.business_rounded,
//       ),
//       _Field(
//         ctrl: _bizPlanCtrl,
//         label: 'Business Plan',
//         icon: Icons.description_rounded,
//       ),
//       const SizedBox(height: 20),
//       _NavButtons(
//         onBack: () => setState(() => _currentStep = 0),
//         onNext: () {
//           if (_selectedType == null ||
//               _selectedVendorType == null ||
//               _selectedOrderTypes.isEmpty ||
//               _bizNameCtrl.text.isEmpty)
//             return _snack('Fill all business details');
//           setState(() => _currentStep = 2);
//         },
//       ),
//     ],
//   );
//
//   Widget _OrderChip(String value, String label) {
//     final sel = _selectedOrderTypes.contains(value);
//     return GestureDetector(
//       onTap: () => setState(() {
//         sel
//             ? _selectedOrderTypes.remove(value)
//             : _selectedOrderTypes.add(value);
//       }),
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 180),
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
//         decoration: BoxDecoration(
//           color: sel ? _cPrimaryLt : _cBg,
//           borderRadius: BorderRadius.circular(9),
//           border: Border.all(
//             color: sel ? _cPrimary : _cBorder,
//             width: sel ? 1.5 : 1,
//           ),
//         ),
//         child: Text(
//           label,
//           style: TextStyle(
//             fontSize: 12,
//             fontWeight: FontWeight.w600,
//             color: sel ? _cPrimary : _cSub,
//           ),
//         ),
//       ),
//     );
//   }
//
//   // ── Step 2: Address ────────────────────────────────────────────────────────
//   Widget _step2() => Column(
//     children: [
//       _SectionLabel('Pick Location on Map'),
//       const SizedBox(height: 8),
//       ClipRRect(
//         borderRadius: BorderRadius.circular(14),
//         child: GoogleMapsPage(
//           onAddressSelected: (city, pin, state, country, lat, lng) {
//             setState(() {
//               _cityCtrl.text = city;
//               _pincodeCtrl.text = pin;
//               _stateCtrl.text = state;
//               _countryCtrl.text = country;
//               _latitude = lat;
//               _longitude = lng;
//             });
//           },
//         ),
//       ),
//       const SizedBox(height: 14),
//       _Field(
//         ctrl: _fullAddrCtrl,
//         label: 'Full Address',
//         icon: Icons.home_rounded,
//       ),
//       _Field(
//         ctrl: _doorNoCtrl,
//         label: 'Door Number',
//         icon: Icons.door_front_door_rounded,
//       ),
//       _Field(
//         ctrl: _addrLineCtrl,
//         label: 'Address Line',
//         icon: Icons.map_rounded,
//       ),
//       _Field(
//         ctrl: _landmarkCtrl,
//         label: 'Landmark (Optional)',
//         icon: Icons.place_rounded,
//         required: false,
//       ),
//       Row(
//         children: [
//           Expanded(
//             child: _Field(
//               ctrl: _cityCtrl,
//               label: 'City',
//               icon: Icons.location_city_rounded,
//             ),
//           ),
//           const SizedBox(width: 10),
//           Expanded(
//             child: _Field(
//               ctrl: _pincodeCtrl,
//               label: 'Pincode',
//               icon: Icons.pin_rounded,
//               type: TextInputType.number,
//             ),
//           ),
//         ],
//       ),
//       Row(
//         children: [
//           Expanded(
//             child: _Field(
//               ctrl: _stateCtrl,
//               label: 'State',
//               icon: Icons.map_outlined,
//             ),
//           ),
//           const SizedBox(width: 10),
//           Expanded(
//             child: _Field(
//               ctrl: _countryCtrl,
//               label: 'Country',
//               icon: Icons.public_rounded,
//             ),
//           ),
//         ],
//       ),
//       const SizedBox(height: 20),
//       _NavButtons(
//         onBack: () => setState(() => _currentStep = 1),
//         onNext: () {
//           if ([
//             _fullAddrCtrl,
//             _doorNoCtrl,
//             _addrLineCtrl,
//             _cityCtrl,
//             _pincodeCtrl,
//             _stateCtrl,
//             _countryCtrl,
//           ].any((c) => c.text.isEmpty))
//             return _snack('Fill all address fields');
//           setState(() => _currentStep = 3);
//         },
//       ),
//     ],
//   );
//
//   // ── Step 3: Documents ──────────────────────────────────────────────────────
//   Widget _step3() => Column(
//     children: [
//       _DocSection(
//         label: 'Aadhaar',
//         children: [
//           _Field(
//             ctrl: _aadhaarNoCtrl,
//             label: 'Aadhaar Number',
//             icon: Icons.credit_card_rounded,
//             type: TextInputType.number,
//             maxLen: 12,
//           ),
//           Row(
//             children: [
//               Expanded(
//                 child: _UploadBox(
//                   label: 'Front',
//                   file: _aadhaarFront,
//                   onTap: () => _pickImage((f) => _aadhaarFront = f),
//                 ),
//               ),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: _UploadBox(
//                   label: 'Back',
//                   file: _aadhaarBack,
//                   onTap: () => _pickImage((f) => _aadhaarBack = f),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//       _DocSection(
//         label: 'PAN Card',
//         children: [
//           _Field(
//             ctrl: _panNoCtrl,
//             label: 'PAN Number',
//             icon: Icons.badge_rounded,
//             maxLen: 10,
//           ),
//           _UploadBox(
//             label: 'PAN Document',
//             file: _panDoc,
//             onTap: () => _pickImage((f) => _panDoc = f),
//           ),
//         ],
//       ),
//       _DocSection(
//         label: 'GST & Registration',
//         children: [
//           _Field(
//             ctrl: _gstNoCtrl,
//             label: 'GST Number',
//             icon: Icons.receipt_rounded,
//           ),
//           Row(
//             children: [
//               Expanded(
//                 child: _UploadBox(
//                   label: 'Reg Doc Front',
//                   file: _regDocFront,
//                   onTap: () => _pickImage((f) => _regDocFront = f),
//                 ),
//               ),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: _UploadBox(
//                   label: 'Reg Doc Back',
//                   file: _regDocBack,
//                   onTap: () => _pickImage((f) => _regDocBack = f),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//       _DocSection(
//         label: 'Trade License',
//         children: [
//           _Field(
//             ctrl: _tradeLicNoCtrl,
//             label: 'Trade License Number',
//             icon: Icons.assignment_rounded,
//           ),
//           _UploadBox(
//             label: 'Document',
//             file: _tradeLicDoc,
//             onTap: () => _pickImage((f) => _tradeLicDoc = f),
//           ),
//           Row(
//             children: [
//               Expanded(
//                 child: _DatePicker(
//                   label: 'Start Date',
//                   date: _tradeLicStart,
//                   onTap: () => _pickDate((d) => _tradeLicStart = d),
//                 ),
//               ),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: _DatePicker(
//                   label: 'End Date',
//                   date: _tradeLicEnd,
//                   onTap: () => _pickDate((d) => _tradeLicEnd = d),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//       _DocSection(
//         label: 'FSSAI License',
//         children: [
//           _Field(
//             ctrl: _fssaiNoCtrl,
//             label: 'FSSAI Number',
//             icon: Icons.verified_rounded,
//           ),
//           _UploadBox(
//             label: 'Document',
//             file: _fssaiDoc,
//             onTap: () => _pickImage((f) => _fssaiDoc = f),
//           ),
//           Row(
//             children: [
//               Expanded(
//                 child: _DatePicker(
//                   label: 'Start',
//                   date: _fssaiStart,
//                   onTap: () => _pickDate((d) => _fssaiStart = d),
//                 ),
//               ),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: _DatePicker(
//                   label: 'End',
//                   date: _fssaiEnd,
//                   onTap: () => _pickDate((d) => _fssaiEnd = d),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//       _DocSection(
//         label: 'Labour License',
//         children: [
//           _Field(
//             ctrl: _labourLicNoCtrl,
//             label: 'Labour License Number',
//             icon: Icons.work_rounded,
//           ),
//           _UploadBox(
//             label: 'Document',
//             file: _labourDoc,
//             onTap: () => _pickImage((f) => _labourDoc = f),
//           ),
//           Row(
//             children: [
//               Expanded(
//                 child: _DatePicker(
//                   label: 'Start',
//                   date: _labourStart,
//                   onTap: () => _pickDate((d) => _labourStart = d),
//                 ),
//               ),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: _DatePicker(
//                   label: 'End',
//                   date: _labourEnd,
//                   onTap: () => _pickDate((d) => _labourEnd = d),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//       _DocSection(
//         label: 'Blank Cheque',
//         children: [
//           _UploadBox(
//             label: 'Blank Cheque Document',
//             file: _blankChequeDoc,
//             onTap: () => _pickImage((f) => _blankChequeDoc = f),
//           ),
//         ],
//       ),
//       const SizedBox(height: 20),
//       _NavButtons(
//         onBack: () => setState(() => _currentStep = 2),
//         onNext: () {
//           if (_aadhaarNoCtrl.text.isEmpty ||
//               _panNoCtrl.text.isEmpty ||
//               _gstNoCtrl.text.isEmpty ||
//               _tradeLicNoCtrl.text.isEmpty ||
//               _fssaiNoCtrl.text.isEmpty ||
//               _labourLicNoCtrl.text.isEmpty)
//             return _snack('Fill all document fields');
//           setState(() => _currentStep = 4);
//         },
//       ),
//     ],
//   );
//
//   // ── Step 4: Bank ───────────────────────────────────────────────────────────
//   Widget _step4() => Column(
//     children: [
//       _Field(
//         ctrl: _acHolderCtrl,
//         label: 'Account Holder Name',
//         icon: Icons.person_rounded,
//       ),
//       _Field(
//         ctrl: _acNoCtrl,
//         label: 'Account Number',
//         icon: Icons.numbers_rounded,
//         type: TextInputType.number,
//       ),
//       _Field(ctrl: _ifscCtrl, label: 'IFSC Code', icon: Icons.code_rounded),
//       _Field(
//         ctrl: _bankNameCtrl,
//         label: 'Bank Name',
//         icon: Icons.account_balance_rounded,
//       ),
//       _Field(
//         ctrl: _branchCtrl,
//         label: 'Branch Name',
//         icon: Icons.location_city_rounded,
//       ),
//       const SizedBox(height: 20),
//       _NavButtons(
//         onBack: () => setState(() => _currentStep = 3),
//         nextLabel: 'Review',
//         onNext: () {
//           if ([
//             _acHolderCtrl,
//             _acNoCtrl,
//             _ifscCtrl,
//             _bankNameCtrl,
//             _branchCtrl,
//           ].any((c) => c.text.isEmpty))
//             return _snack('Fill all bank details');
//           setState(() => _currentStep = 5);
//         },
//       ),
//     ],
//   );
//
//   // ── Step 5: Review ─────────────────────────────────────────────────────────
//   Widget _step5() => Column(
//     children: [
//       // Status banner
//       AnimatedContainer(
//         duration: const Duration(milliseconds: 300),
//         padding: const EdgeInsets.all(14),
//         decoration: BoxDecoration(
//           color: _isVendorRegistered ? _cSuccessLt : const Color(0xFFFFF7ED),
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(
//             color: _isVendorRegistered
//                 ? _cSuccess.withOpacity(0.3)
//                 : _cPrimary.withOpacity(0.3),
//           ),
//         ),
//         child: Row(
//           children: [
//             Icon(
//               _isVendorRegistered
//                   ? Icons.verified_rounded
//                   : Icons.pending_rounded,
//               color: _isVendorRegistered ? _cSuccess : _cPrimary,
//               size: 24,
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     _isVendorRegistered
//                         ? 'Already Registered'
//                         : 'Ready to Submit',
//                     style: TextStyle(
//                       fontWeight: FontWeight.w800,
//                       fontSize: 13,
//                       color: _isVendorRegistered ? _cSuccess : _cPrimary,
//                     ),
//                   ),
//                   const SizedBox(height: 2),
//                   Text(
//                     _isVendorRegistered
//                         ? 'Your details have been submitted.'
//                         : 'Review your information before submitting.',
//                     style: const TextStyle(fontSize: 11, color: _cSub),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//       const SizedBox(height: 16),
//       _ReviewGroup(
//         title: 'Personal Info',
//         icon: Icons.person_rounded,
//         iconColor: _cInfo,
//         iconBg: _cInfoLt,
//         rows: [
//           _RRow('Name', _fullNameCtrl.text),
//           _RRow('Mobile', _mobileCtrl.text),
//           _RRow('Email', _emailCtrl.text),
//           _RRow(
//             'Logo',
//             _logoFile != null ? '✓ Provided' : '✗ Missing',
//             isFile: true,
//             hasFile: _logoFile != null,
//           ),
//         ],
//       ),
//       _ReviewGroup(
//         title: 'Business',
//         icon: Icons.store_rounded,
//         iconColor: _cPrimary,
//         iconBg: _cPrimaryLt,
//         rows: [
//           _RRow('Type', _selectedType ?? '—'),
//           _RRow('Vendor Type', _selectedVendorType ?? '—'),
//           _RRow('Order Types', _selectedOrderTypes.join(', ')),
//           _RRow('Business Name', _bizNameCtrl.text),
//           _RRow('Plan', _bizPlanCtrl.text),
//         ],
//       ),
//       _ReviewGroup(
//         title: 'Address',
//         icon: Icons.location_on_rounded,
//         iconColor: _cSuccess,
//         iconBg: _cSuccessLt,
//         rows: [
//           _RRow('Full Address', _fullAddrCtrl.text),
//           _RRow('City', _cityCtrl.text),
//           _RRow('State/Pincode', '${_stateCtrl.text} - ${_pincodeCtrl.text}'),
//           _RRow('Country', _countryCtrl.text),
//         ],
//       ),
//       _ReviewGroup(
//         title: 'Bank',
//         icon: Icons.account_balance_rounded,
//         iconColor: const Color(0xFFF59E0B),
//         iconBg: const Color(0xFFFEF3C7),
//         rows: [
//           _RRow('Holder', _acHolderCtrl.text),
//           _RRow('Account', _acNoCtrl.text),
//           _RRow('IFSC', _ifscCtrl.text),
//           _RRow('Bank', _bankNameCtrl.text),
//         ],
//       ),
//       const SizedBox(height: 24),
//       Row(
//         children: [
//           Expanded(
//             child: _OutlineBtn(
//               label: 'Back',
//               icon: Icons.arrow_back_rounded,
//               onTap: () => setState(() => _currentStep = 4),
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: _isVendorRegistered
//                 ? Container(
//                     height: 48,
//                     decoration: BoxDecoration(
//                       color: const Color(0xFFF3F4F6),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: const Center(
//                       child: Text(
//                         'Already Submitted',
//                         style: TextStyle(
//                           color: _cMuted,
//                           fontWeight: FontWeight.w600,
//                           fontSize: 13,
//                         ),
//                       ),
//                     ),
//                   )
//                 : _PrimaryBtn(
//                     label: 'Final Submit',
//                     icon: Icons.send_rounded,
//                     onTap: _submitVendor,
//                   ),
//           ),
//         ],
//       ),
//     ],
//   );
// }
//
// class _StepMeta {
//   final String label;
//   final IconData icon;
//   final Color color;
//   const _StepMeta(this.label, this.icon, this.color);
// }
//
// class _StepHeader extends StatelessWidget {
//   final int step;
//   final _StepMeta meta;
//   const _StepHeader({required this.step, required this.meta});
//   @override
//   Widget build(BuildContext context) => Row(
//     children: [
//       Container(
//         width: 40,
//         height: 40,
//         decoration: BoxDecoration(
//           color: meta.color.withOpacity(0.12),
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Icon(meta.icon, color: meta.color, size: 20),
//       ),
//       const SizedBox(width: 12),
//       Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Step ${step + 1} of 6',
//             style: const TextStyle(
//               fontSize: 11,
//               color: _cMuted,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           Text(
//             meta.label,
//             style: const TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w800,
//               color: _cText,
//             ),
//           ),
//         ],
//       ),
//     ],
//   );
// }
//
// class _Field extends StatelessWidget {
//   final TextEditingController ctrl;
//   final String label;
//   final IconData icon;
//   final TextInputType type;
//   final int? maxLen;
//   final bool required;
//
//   const _Field({
//     required this.ctrl,
//     required this.label,
//     required this.icon,
//     this.type = TextInputType.text,
//     this.maxLen,
//     this.required = true,
//   });
//
//   @override
//   Widget build(BuildContext context) => Padding(
//     padding: const EdgeInsets.only(bottom: 10),
//     child: TextField(
//       controller: ctrl,
//       keyboardType: type,
//       maxLength: maxLen,
//       style: const TextStyle(fontSize: 13, color: _cText),
//       decoration: InputDecoration(
//         labelText: required ? '$label *' : label,
//         labelStyle: const TextStyle(fontSize: 12, color: _cSub),
//         prefixIcon: Icon(icon, color: _cPrimary, size: 18),
//         counterText: '',
//         filled: true,
//         fillColor: _cSurface,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: const BorderSide(color: _cBorder),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: const BorderSide(color: _cBorder),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: const BorderSide(color: _cPrimary, width: 2),
//         ),
//         contentPadding: const EdgeInsets.symmetric(
//           horizontal: 12,
//           vertical: 13,
//         ),
//       ),
//     ),
//   );
// }
//
// class _Dropdown extends StatelessWidget {
//   final String? value;
//   final String label;
//   final IconData icon;
//   final List<String> items;
//   final ValueChanged<String?> onChanged;
//
//   const _Dropdown({
//     required this.value,
//     required this.label,
//     required this.icon,
//     required this.items,
//     required this.onChanged,
//   });
//
//   @override
//   Widget build(BuildContext context) => Padding(
//     padding: const EdgeInsets.only(bottom: 10),
//     child: DropdownButtonFormField<String>(
//       value: value,
//       items: items
//           .map(
//             (e) => DropdownMenuItem(
//               value: e,
//               child: Text(e, style: const TextStyle(fontSize: 13)),
//             ),
//           )
//           .toList(),
//       onChanged: onChanged,
//       decoration: InputDecoration(
//         labelText: '$label *',
//         labelStyle: const TextStyle(fontSize: 12, color: _cSub),
//         prefixIcon: Icon(icon, color: _cPrimary, size: 18),
//         filled: true,
//         fillColor: _cSurface,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: const BorderSide(color: _cBorder),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: const BorderSide(color: _cBorder),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: const BorderSide(color: _cPrimary, width: 2),
//         ),
//         contentPadding: const EdgeInsets.symmetric(
//           horizontal: 12,
//           vertical: 13,
//         ),
//       ),
//       dropdownColor: _cSurface,
//       icon: const Icon(
//         Icons.keyboard_arrow_down_rounded,
//         color: _cPrimary,
//         size: 20,
//       ),
//     ),
//   );
// }
//
// class _UploadBox extends StatelessWidget {
//   final String label;
//   final File? file;
//   final VoidCallback onTap;
//
//   const _UploadBox({
//     required this.label,
//     required this.file,
//     required this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final provided = file?.path == 'provided';
//     final hasNew = file != null && !provided;
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 10),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             label,
//             style: const TextStyle(
//               fontSize: 12,
//               fontWeight: FontWeight.w600,
//               color: _cSub,
//             ),
//           ),
//           const SizedBox(height: 6),
//           GestureDetector(
//             onTap: provided ? null : onTap,
//             child: AnimatedContainer(
//               duration: const Duration(milliseconds: 200),
//               height: 90,
//               width: double.infinity,
//               decoration: BoxDecoration(
//                 color: provided
//                     ? _cSuccessLt
//                     : hasNew
//                     ? _cBg
//                     : _cBg,
//                 borderRadius: BorderRadius.circular(10),
//                 border: Border.all(
//                   color: provided
//                       ? _cSuccess
//                       : hasNew
//                       ? _cPrimary
//                       : _cBorder,
//                   width: (provided || hasNew) ? 1.5 : 1,
//                 ),
//               ),
//               child: provided
//                   ? Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: const [
//                         Icon(
//                           Icons.cloud_done_rounded,
//                           color: _cSuccess,
//                           size: 28,
//                         ),
//                         SizedBox(height: 4),
//                         Text(
//                           'Provided ✓',
//                           style: TextStyle(
//                             color: _cSuccess,
//                             fontSize: 11,
//                             fontWeight: FontWeight.w700,
//                           ),
//                         ),
//                       ],
//                     )
//                   : hasNew
//                   ? ClipRRect(
//                       borderRadius: BorderRadius.circular(10),
//                       child: Image.file(
//                         file!,
//                         fit: BoxFit.cover,
//                         width: double.infinity,
//                       ),
//                     )
//                   : Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: const [
//                         Icon(
//                           Icons.upload_file_rounded,
//                           color: _cMuted,
//                           size: 28,
//                         ),
//                         SizedBox(height: 4),
//                         Text(
//                           'Tap to upload',
//                           style: TextStyle(color: _cMuted, fontSize: 11),
//                         ),
//                       ],
//                     ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _DatePicker extends StatelessWidget {
//   final String label;
//   final DateTime? date;
//   final VoidCallback onTap;
//   const _DatePicker({
//     required this.label,
//     required this.date,
//     required this.onTap,
//   });
//   @override
//   Widget build(BuildContext context) => Padding(
//     padding: const EdgeInsets.only(bottom: 10),
//     child: GestureDetector(
//       onTap: onTap,
//       child: Container(
//         height: 50,
//         padding: const EdgeInsets.symmetric(horizontal: 12),
//         decoration: BoxDecoration(
//           color: _cSurface,
//           borderRadius: BorderRadius.circular(10),
//           border: Border.all(
//             color: date != null ? _cPrimary : _cBorder,
//             width: date != null ? 1.5 : 1,
//           ),
//         ),
//         child: Row(
//           children: [
//             Icon(
//               Icons.calendar_month_rounded,
//               color: date != null ? _cPrimary : _cMuted,
//               size: 16,
//             ),
//             const SizedBox(width: 8),
//             Text(
//               date != null
//                   ? '${date!.day}/${date!.month}/${date!.year}'
//                   : label,
//               style: TextStyle(
//                 fontSize: 12,
//                 color: date != null ? _cText : _cMuted,
//                 fontWeight: date != null ? FontWeight.w600 : FontWeight.w400,
//               ),
//             ),
//           ],
//         ),
//       ),
//     ),
//   );
// }
//
// class _FieldCard extends StatelessWidget {
//   final String label;
//   final IconData icon;
//   final Widget child;
//   const _FieldCard({
//     required this.label,
//     required this.icon,
//     required this.child,
//   });
//   @override
//   Widget build(BuildContext context) => Padding(
//     padding: const EdgeInsets.only(bottom: 10),
//     child: Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: _cSurface,
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(color: _cBorder),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(icon, color: _cPrimary, size: 16),
//               const SizedBox(width: 6),
//               Text(
//                 '$label *',
//                 style: const TextStyle(
//                   fontSize: 12,
//                   color: _cSub,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 10),
//           child,
//         ],
//       ),
//     ),
//   );
// }
//
// class _DocSection extends StatelessWidget {
//   final String label;
//   final List<Widget> children;
//   const _DocSection({required this.label, required this.children});
//   @override
//   Widget build(BuildContext context) => Padding(
//     padding: const EdgeInsets.only(bottom: 14),
//     child: Container(
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: _cSurface,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: _cBorder),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             label,
//             style: const TextStyle(
//               fontWeight: FontWeight.w700,
//               fontSize: 13,
//               color: _cText,
//             ),
//           ),
//           const SizedBox(height: 2),
//           const Divider(color: _cBorder),
//           ...children,
//         ],
//       ),
//     ),
//   );
// }
//
// class _SectionLabel extends StatelessWidget {
//   final String text;
//   const _SectionLabel(this.text);
//   @override
//   Widget build(BuildContext context) => Text(
//     text,
//     style: const TextStyle(
//       fontWeight: FontWeight.w700,
//       fontSize: 13,
//       color: _cText,
//     ),
//   );
// }
//
// class _NavButtons extends StatelessWidget {
//   final VoidCallback? onBack;
//   final VoidCallback onNext;
//   final String nextLabel;
//   final bool showBack;
//
//   const _NavButtons({
//     this.onBack,
//     required this.onNext,
//     this.nextLabel = 'Next',
//     this.showBack = true,
//   });
//
//   @override
//   Widget build(BuildContext context) => Row(
//     children: [
//       if (showBack && onBack != null) ...[
//         Expanded(
//           child: _OutlineBtn(
//             label: 'Back',
//             icon: Icons.arrow_back_rounded,
//             onTap: onBack!,
//           ),
//         ),
//         const SizedBox(width: 12),
//       ],
//       Expanded(
//         child: _PrimaryBtn(
//           label: nextLabel,
//           icon: Icons.arrow_forward_rounded,
//           onTap: onNext,
//         ),
//       ),
//     ],
//   );
// }
//
// class _PrimaryBtn extends StatelessWidget {
//   final String label;
//   final IconData icon;
//   final VoidCallback onTap;
//   const _PrimaryBtn({
//     required this.label,
//     required this.icon,
//     required this.onTap,
//   });
//   @override
//   Widget build(BuildContext context) => GestureDetector(
//     onTap: onTap,
//     child: Container(
//       height: 48,
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           colors: [Color(0xFFE66D33), Color(0xFFCC5A20)],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: _cPrimary.withOpacity(0.3),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Text(
//             label,
//             style: const TextStyle(
//               color: Colors.white,
//               fontSize: 13,
//               fontWeight: FontWeight.w700,
//             ),
//           ),
//           const SizedBox(width: 6),
//           Icon(icon, color: Colors.white, size: 16),
//         ],
//       ),
//     ),
//   );
// }
//
// class _OutlineBtn extends StatelessWidget {
//   final String label;
//   final IconData icon;
//   final VoidCallback onTap;
//   const _OutlineBtn({
//     required this.label,
//     required this.icon,
//     required this.onTap,
//   });
//   @override
//   Widget build(BuildContext context) => GestureDetector(
//     onTap: onTap,
//     child: Container(
//       height: 48,
//       decoration: BoxDecoration(
//         color: _cSurface,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: _cBorder),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(icon, color: _cSub, size: 16),
//           const SizedBox(width: 6),
//           Text(
//             label,
//             style: const TextStyle(
//               color: _cSub,
//               fontSize: 13,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ],
//       ),
//     ),
//   );
// }
//
// class _RRow {
//   final String k, v;
//   final bool isFile, hasFile;
//   const _RRow(this.k, this.v, {this.isFile = false, this.hasFile = false});
// }
//
// class _ReviewGroup extends StatelessWidget {
//   final String title;
//   final IconData icon;
//   final Color iconColor, iconBg;
//   final List<_RRow> rows;
//   const _ReviewGroup({
//     required this.title,
//     required this.icon,
//     required this.iconColor,
//     required this.iconBg,
//     required this.rows,
//   });
//   @override
//   Widget build(BuildContext context) => Padding(
//     padding: const EdgeInsets.only(bottom: 12),
//     child: Container(
//       decoration: BoxDecoration(
//         color: _cSurface,
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(color: _cBorder),
//       ),
//       child: Column(
//         children: [
//           Container(
//             padding: const EdgeInsets.fromLTRB(14, 11, 14, 11),
//             decoration: BoxDecoration(
//               color: iconBg.withOpacity(0.5),
//               borderRadius: const BorderRadius.vertical(
//                 top: Radius.circular(14),
//               ),
//             ),
//             child: Row(
//               children: [
//                 Container(
//                   width: 28,
//                   height: 28,
//                   decoration: BoxDecoration(
//                     color: iconBg,
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Icon(icon, color: iconColor, size: 14),
//                 ),
//                 const SizedBox(width: 8),
//                 Text(
//                   title,
//                   style: const TextStyle(
//                     fontWeight: FontWeight.w800,
//                     fontSize: 13,
//                     color: _cText,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const Divider(height: 1, color: _cBorder),
//           ...rows.asMap().entries.map((e) {
//             final r = e.value;
//             final isLast = e.key == rows.length - 1;
//             return Column(
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 14,
//                     vertical: 9,
//                   ),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         flex: 4,
//                         child: Text(
//                           r.k,
//                           style: const TextStyle(
//                             fontSize: 11,
//                             color: _cSub,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ),
//                       Expanded(
//                         flex: 6,
//                         child: r.isFile
//                             ? Align(
//                                 alignment: Alignment.centerRight,
//                                 child: Container(
//                                   padding: const EdgeInsets.symmetric(
//                                     horizontal: 8,
//                                     vertical: 3,
//                                   ),
//                                   decoration: BoxDecoration(
//                                     color: r.hasFile ? _cSuccessLt : _cDangerLt,
//                                     borderRadius: BorderRadius.circular(6),
//                                   ),
//                                   child: Text(
//                                     r.hasFile ? '✓ Provided' : '✗ Missing',
//                                     style: TextStyle(
//                                       fontSize: 11,
//                                       fontWeight: FontWeight.w700,
//                                       color: r.hasFile ? _cSuccess : _cDanger,
//                                     ),
//                                   ),
//                                 ),
//                               )
//                             : Text(
//                                 r.v.isEmpty ? '—' : r.v,
//                                 style: const TextStyle(
//                                   fontSize: 12,
//                                   color: _cText,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                                 textAlign: TextAlign.end,
//                               ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 if (!isLast)
//                   const Divider(height: 1, color: _cBorder, indent: 14),
//               ],
//             );
//           }),
//         ],
//       ),
//     ),
//   );
// }
//
//
// class GoogleMapsPage extends StatefulWidget {
//   final Function(String, String, String, String, double, double)?
//   onAddressSelected;
//   const GoogleMapsPage({super.key, this.onAddressSelected});
//   @override
//   State<GoogleMapsPage> createState() => _GoogleMapsPageState();
// }
//
// class _GoogleMapsPageState extends State<GoogleMapsPage> {
//   GoogleMapController? _mapCtrl;
//   static const _init = LatLng(17.385044, 78.486671);
//   final _apiKey = 'AIzaSyCf7bYn7iDIs2T6-sDnmr7qWy9oFZOPOuc';
//   LatLng _pos = _init;
//   bool _loading = false, _hasPermission = true;
//
//   @override
//   void initState() {
//     super.initState();
//     _locate();
//   }
//
//   Future<void> _locate() async {
//     try {
//       bool svc = await Geolocator.isLocationServiceEnabled();
//       if (!svc) return;
//       var perm = await Geolocator.checkPermission();
//       if (perm == LocationPermission.denied)
//         perm = await Geolocator.requestPermission();
//       if (perm == LocationPermission.denied ||
//           perm == LocationPermission.deniedForever) {
//         setState(() => _hasPermission = false);
//         return;
//       }
//       final p = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );
//       _updatePos(LatLng(p.latitude, p.longitude));
//       _mapCtrl?.animateCamera(
//         CameraUpdate.newLatLngZoom(LatLng(p.latitude, p.longitude), 16),
//       );
//     } catch (_) {}
//   }
//
//   Future<void> _updatePos(LatLng latlng) async {
//     setState(() {
//       _pos = latlng;
//       _loading = true;
//     });
//     try {
//       final pm = await placemarkFromCoordinates(
//         latlng.latitude,
//         latlng.longitude,
//       );
//       if (pm.isNotEmpty) {
//         final p = pm.first;
//         widget.onAddressSelected?.call(
//           p.locality ?? '',
//           p.postalCode ?? '',
//           p.administrativeArea ?? '',
//           p.country ?? '',
//           latlng.latitude,
//           latlng.longitude,
//         );
//       }
//     } catch (_) {}
//     setState(() => _loading = false);
//   }
//
//   Future<void> _search() async {
//     final pred = await PlacesAutocomplete.show(
//       context: context,
//       apiKey: _apiKey,
//       mode: Mode.overlay,
//       language: 'en',
//       components: [Component(Component.country, 'in')],
//       logo: const SizedBox.shrink(),
//     );
//     if (pred != null) {
//       final places = GoogleMapsPlaces(
//         apiKey: _apiKey,
//         apiHeaders: await const GoogleApiHeaders().getHeaders(),
//       );
//       final det = await places.getDetailsByPlaceId(pred.placeId!);
//       final loc = det.result.geometry!.location;
//       final latlng = LatLng(loc.lat, loc.lng);
//       _updatePos(latlng);
//       _mapCtrl?.animateCamera(CameraUpdate.newLatLngZoom(latlng, 16));
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) => Container(
//     height: 360,
//     decoration: BoxDecoration(
//       borderRadius: BorderRadius.circular(14),
//       border: Border.all(color: _cBorder),
//     ),
//     child: Stack(
//       children: [
//         ClipRRect(
//           borderRadius: BorderRadius.circular(14),
//           child: GoogleMap(
//             initialCameraPosition: const CameraPosition(
//               target: _init,
//               zoom: 14,
//             ),
//             onMapCreated: (c) => _mapCtrl = c,
//             myLocationEnabled: true,
//             myLocationButtonEnabled: false,
//             zoomControlsEnabled: false,
//             onCameraMove: (p) => _pos = p.target,
//             onCameraIdle: () => _updatePos(_pos),
//             gestureRecognizers: {
//               Factory<OneSequenceGestureRecognizer>(
//                 () => EagerGestureRecognizer(),
//               ),
//             },
//           ),
//         ),
//         const Center(
//           child: Icon(Icons.location_pin, size: 44, color: _cPrimary),
//         ),
//         // Search bar
//         Positioned(
//           top: 10,
//           left: 10,
//           right: 10,
//           child: GestureDetector(
//             onTap: _search,
//             child: Container(
//               height: 44,
//               padding: const EdgeInsets.symmetric(horizontal: 12),
//               decoration: BoxDecoration(
//                 color: _cSurface,
//                 borderRadius: BorderRadius.circular(10),
//                 border: Border.all(color: _cBorder),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.1),
//                     blurRadius: 6,
//                     offset: const Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: const Row(
//                 children: [
//                   Icon(Icons.search_rounded, color: _cMuted, size: 18),
//                   SizedBox(width: 8),
//                   Text(
//                     'Search location...',
//                     style: TextStyle(color: _cMuted, fontSize: 13),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//         // My location button
//         Positioned(
//           bottom: 56,
//           right: 10,
//           child: GestureDetector(
//             onTap: _locate,
//             child: Container(
//               width: 40,
//               height: 40,
//               decoration: BoxDecoration(
//                 color: _cSurface,
//                 shape: BoxShape.circle,
//                 border: Border.all(color: _cBorder),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.1),
//                     blurRadius: 6,
//                   ),
//                 ],
//               ),
//               child: const Icon(
//                 Icons.my_location_rounded,
//                 color: _cInfo,
//                 size: 18,
//               ),
//             ),
//           ),
//         ),
//         if (_loading)
//           const Positioned(
//             bottom: 12,
//             left: 0,
//             right: 0,
//             child: Center(
//               child: SizedBox(
//                 width: 20,
//                 height: 20,
//                 child: CircularProgressIndicator(
//                   color: _cPrimary,
//                   strokeWidth: 2.5,
//                 ),
//               ),
//             ),
//           ),
//         if (!_hasPermission)
//           Positioned.fill(
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(14),
//               child: Container(
//                 color: Colors.white.withOpacity(0.95),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Container(
//                       width: 56,
//                       height: 56,
//                       decoration: const BoxDecoration(
//                         color: _cDangerLt,
//                         shape: BoxShape.circle,
//                       ),
//                       child: const Icon(
//                         Icons.location_off_rounded,
//                         color: _cDanger,
//                         size: 28,
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     const Text(
//                       'Location access required',
//                       style: TextStyle(
//                         fontWeight: FontWeight.w700,
//                         fontSize: 14,
//                         color: _cText,
//                       ),
//                     ),
//                     const SizedBox(height: 6),
//                     const Text(
//                       'Enable location to use the map.',
//                       style: TextStyle(color: _cSub, fontSize: 12),
//                     ),
//                     const SizedBox(height: 16),
//                     ElevatedButton.icon(
//                       onPressed: () => Geolocator.openAppSettings(),
//                       icon: const Icon(Icons.settings_rounded, size: 16),
//                       label: const Text('Open Settings'),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: _cPrimary,
//                         foregroundColor: Colors.white,
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 20,
//                           vertical: 10,
//                         ),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         elevation: 0,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//       ],
//     ),
//   );
// }
