import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:flutter_google_places_hoc081098/google_maps_webservice_places.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../food&beverages/Registration.dart';
import 'Home.dart';

// Status enum for field verification
enum FieldStatus { notVerified, verified, rejected, pending }

// Field status model
class FieldStatusInfo {
  final FieldStatus status;
  final String? message;
  final DateTime? lastUpdated;

  FieldStatusInfo({
    this.status = FieldStatus.notVerified,
    this.message,
    this.lastUpdated,
  });
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _CateringRegistrationState();
}

class _CateringRegistrationState extends State<ProfilePage> {
  int _currentStep = 0;
  bool _isVendorRegistered = false;
  bool _isLoadingData = true;

  // Personal Info Controllers
  final TextEditingController _ownerNameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  File? _logoFile;
  final ImagePicker _picker = ImagePicker();
  double? _latitude;
  double? _longitude;

  // Business Details Controllers
  final TextEditingController _regBusinessNameController =
      TextEditingController();
  final TextEditingController _businessPlanController = TextEditingController();
  final TextEditingController _businessVerticalController =
      TextEditingController();
  final TextEditingController _remarksController = TextEditingController();
  final TextEditingController _deliveryRadiusController =
      TextEditingController();
  final TextEditingController _avgDeliveryTimeController =
      TextEditingController();

  // Address Controllers
  final TextEditingController _fullAddressController = TextEditingController();
  final TextEditingController _doorNoController = TextEditingController();
  final TextEditingController _addressLineController = TextEditingController();
  final TextEditingController _landmarkController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();

  // Required Documents Controllers & Files
  final TextEditingController _aadhaarNumberController =
      TextEditingController();
  File? _aadhaarFront;
  File? _aadhaarBack;
  final TextEditingController _panNumberController = TextEditingController();
  File? _panCardDoc;
  final TextEditingController _gstNumberController = TextEditingController();
  File? _registerDocFront;
  File? _registerDocBack;
  final TextEditingController _tradeLicenseNumberController =
      TextEditingController();
  File? _tradeLicenseDoc;
  DateTime? _tradeLicenseStartDate;
  DateTime? _tradeLicenseEndDate;
  final TextEditingController _fssaiNumberController = TextEditingController();
  File? _fssaiLicenseDoc;
  DateTime? _fssaiStartDate;
  DateTime? _fssaiEndDate;
  final TextEditingController _labourLicenseNumberController =
      TextEditingController();
  File? _labourLicenseDoc;
  DateTime? _labourStartDate;
  DateTime? _labourEndDate;
  File? _blankChequeDoc;

  // Bank Account Details Controllers
  final TextEditingController _accountHolderNameController =
      TextEditingController();
  final TextEditingController _accountNumberController =
      TextEditingController();
  final TextEditingController _ifscCodeController = TextEditingController();
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _branchNameController = TextEditingController();

  // Additional Fields for Catering
  final TextEditingController _commissionController = TextEditingController();
  final TextEditingController _leadsController = TextEditingController();

  // Field Status Tracking
  final Map<String, FieldStatusInfo> _fieldStatus = {};

  // Step Titles
  final List<String> steps = [
    "Personal Info",
    "Business Details",
    "Address",
    "Required Documents",
    "Bank Account Details",
    "Review",
  ];

  @override
  void initState() {
    super.initState();
    _initializeFieldStatus();
    _loadVendorRegistrationData();
  }

  void _initializeFieldStatus() {
    // Personal Info
    _fieldStatus['ownerName'] = FieldStatusInfo();
    _fieldStatus['mobile'] = FieldStatusInfo();
    _fieldStatus['email'] = FieldStatusInfo();
    _fieldStatus['website'] = FieldStatusInfo();
    _fieldStatus['logo'] = FieldStatusInfo();

    // Business Details
    _fieldStatus['registeredBusinessName'] = FieldStatusInfo();
    _fieldStatus['businessPlan'] = FieldStatusInfo();
    _fieldStatus['businessVertical'] = FieldStatusInfo();
    _fieldStatus['remarks'] = FieldStatusInfo();
    _fieldStatus['deliveryRadius'] = FieldStatusInfo();
    _fieldStatus['avgDeliveryTime'] = FieldStatusInfo();

    // Address
    _fieldStatus['fullAddress'] = FieldStatusInfo();
    _fieldStatus['doorNo'] = FieldStatusInfo();
    _fieldStatus['addressLine'] = FieldStatusInfo();
    _fieldStatus['landmark'] = FieldStatusInfo();
    _fieldStatus['city'] = FieldStatusInfo();
    _fieldStatus['pincode'] = FieldStatusInfo();
    _fieldStatus['state'] = FieldStatusInfo();
    _fieldStatus['country'] = FieldStatusInfo();

    // Documents
    _fieldStatus['aadhaarNumber'] = FieldStatusInfo();
    _fieldStatus['aadhaarFront'] = FieldStatusInfo();
    _fieldStatus['aadhaarBack'] = FieldStatusInfo();
    _fieldStatus['panNumber'] = FieldStatusInfo();
    _fieldStatus['panCardDoc'] = FieldStatusInfo();
    _fieldStatus['gstNumber'] = FieldStatusInfo();
    _fieldStatus['registerDocFront'] = FieldStatusInfo();
    _fieldStatus['registerDocBack'] = FieldStatusInfo();
    _fieldStatus['tradeLicenseNumber'] = FieldStatusInfo();
    _fieldStatus['tradeLicenseDoc'] = FieldStatusInfo();
    _fieldStatus['tradeLicenseStartDate'] = FieldStatusInfo();
    _fieldStatus['tradeLicenseEndDate'] = FieldStatusInfo();
    _fieldStatus['fssaiNumber'] = FieldStatusInfo();
    _fieldStatus['fssaiLicenseDoc'] = FieldStatusInfo();
    _fieldStatus['fssaiStartDate'] = FieldStatusInfo();
    _fieldStatus['fssaiEndDate'] = FieldStatusInfo();
    _fieldStatus['labourLicenseNumber'] = FieldStatusInfo();
    _fieldStatus['labourLicenseDoc'] = FieldStatusInfo();
    _fieldStatus['labourStartDate'] = FieldStatusInfo();
    _fieldStatus['labourEndDate'] = FieldStatusInfo();
    _fieldStatus['blankChequeDoc'] = FieldStatusInfo();

    // Bank Details
    _fieldStatus['accountHolderName'] = FieldStatusInfo();
    _fieldStatus['accountNumber'] = FieldStatusInfo();
    _fieldStatus['ifscCode'] = FieldStatusInfo();
    _fieldStatus['bankName'] = FieldStatusInfo();
    _fieldStatus['branchName'] = FieldStatusInfo();

    // Additional
    _fieldStatus['commission'] = FieldStatusInfo();
    _fieldStatus['leads'] = FieldStatusInfo();
  }

  void _navigateBackToHome() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => CateringLandingPage()),
      );
    }
  }

  Future<void> _loadVendorRegistrationData() async {
    try {
      debugPrint("🔄 Loading catering vendor registration data...");
      setState(() {
        _isLoadingData = true;
      });
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final vendorId = prefs.getInt("vendorId");

      // const url = 'http://staging.maamaas.com:8080/catering/api/vendor/get/$vendorId';
      final url =
          'http://staging.maamaas.com:8080/catering/api/vendor/get/$vendorId';

      if (token == null) {
        debugPrint("❌ No token found");
        setState(() {
          _isLoadingData = false;
        });
        return;
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        bool hasEssentialData =
            data['ownerName']?.toString().isNotEmpty == true &&
            data['mobileNumber']?.toString().isNotEmpty == true &&
            data['email']?.toString().isNotEmpty == true;

        bool isRegistered =
            data['registrationStatus'] == 'COMPLETED' ||
            data['registrationStatus'] == 'APPROVED';

        setState(() {
          _isVendorRegistered = hasEssentialData || isRegistered;

          // Load data into controllers
          _ownerNameController.text = data['ownerName']?.toString() ?? '';
          _mobileController.text = data['mobileNumber']?.toString() ?? '';
          _emailController.text = data['email']?.toString() ?? '';
          _regBusinessNameController.text =
              data['registeredName']?.toString() ?? '';
          _websiteController.text = data['websiteName']?.toString() ?? '';
          _businessVerticalController.text =
              data['businessVertical']?.toString() ?? '';
          _remarksController.text = data['remarks']?.toString() ?? '';
          _deliveryRadiusController.text =
              data['deliveryRadius']?.toString() ?? '';
          _avgDeliveryTimeController.text =
              data['averageDeliveryTime']?.toString() ?? '';

          // Address
          _fullAddressController.text = data['fullAddress']?.toString() ?? '';
          _doorNoController.text = data['doorNumber']?.toString() ?? '';
          _addressLineController.text = data['addressLine']?.toString() ?? '';
          _landmarkController.text = data['landMark']?.toString() ?? '';
          _cityController.text = data['city']?.toString() ?? '';
          _pincodeController.text = data['pincode']?.toString() ?? '';
          _stateController.text = data['state']?.toString() ?? '';
          _countryController.text = data['country']?.toString() ?? 'India';
          _latitude = data['latitude']?.toDouble();
          _longitude = data['longitude']?.toDouble();

          // Documents
          _aadhaarNumberController.text =
              data['aadharNumber']?.toString() ?? '';
          _panNumberController.text = data['panCardNumber']?.toString() ?? '';
          _gstNumberController.text = data['gstNumber']?.toString() ?? '';
          _tradeLicenseNumberController.text =
              data['tradeLicenseNumber']?.toString() ?? '';
          _fssaiNumberController.text =
              data['fssaiLicenseNumber']?.toString() ?? '';
          _labourLicenseNumberController.text =
              data['labourLicenseNumber']?.toString() ?? '';

          // Dates
          _tradeLicenseStartDate = _safeParseDate(
            data['tradeLicenseStartDate'],
          );
          _tradeLicenseEndDate = _safeParseDate(data['tradeLicenseEndDate']);
          _fssaiStartDate = _safeParseDate(data['fssaiStartDate']);
          _fssaiEndDate = _safeParseDate(data['fssaiEndDate']);
          _labourStartDate = _safeParseDate(data['labourStartDate']);
          _labourEndDate = _safeParseDate(data['labourEndDate']);

          // Bank Details
          _accountHolderNameController.text =
              data['holderName']?.toString() ?? '';
          _accountNumberController.text =
              data['accountNumber']?.toString() ?? '';
          _ifscCodeController.text = data['ifscCode']?.toString() ?? '';
          _bankNameController.text = data['bankName']?.toString() ?? '';
          _branchNameController.text = data['branchName']?.toString() ?? '';

          // Additional
          _commissionController.text = data['commisition']?.toString() ?? '';
          _leadsController.text = data['leads']?.toString() ?? '';

          // Check if files exist on server
          if (data['companyLogo']?.toString().isNotEmpty == true) {
            _logoFile = File("provided");
          }
          if (data['aadharPhotoFront']?.toString().isNotEmpty == true) {
            _aadhaarFront = File("provided");
          }
          if (data['aadharPhotoBack']?.toString().isNotEmpty == true) {
            _aadhaarBack = File("provided");
          }
          if (data['panCard']?.toString().isNotEmpty == true) {
            _panCardDoc = File("provided");
          }
          if (data['registeredDocumentsFront']?.toString().isNotEmpty == true) {
            _registerDocFront = File("provided");
          }
          if (data['registeredDocumentsBack']?.toString().isNotEmpty == true) {
            _registerDocBack = File("provided");
          }
          if (data['tradeLicense']?.toString().isNotEmpty == true) {
            _tradeLicenseDoc = File("provided");
          }
          if (data['fssaiLicense']?.toString().isNotEmpty == true) {
            _fssaiLicenseDoc = File("provided");
          }
          if (data['labourLicense']?.toString().isNotEmpty == true) {
            _labourLicenseDoc = File("provided");
          }
          if (data['blankCheque']?.toString().isNotEmpty == true) {
            _blankChequeDoc = File("provided");
          }

          _isLoadingData = false;
        });

        debugPrint("✅ Catering vendor data loaded successfully");
      } else {
        debugPrint("❌ Failed to load vendor data: ${response.statusCode}");
        setState(() {
          _isLoadingData = false;
          _isVendorRegistered = false;
        });
      }
    } catch (e) {
      debugPrint("⚠️ Error loading vendor data: $e");
      setState(() {
        _isLoadingData = false;
        _isVendorRegistered = false;
      });
    }
  }

  DateTime? _safeParseDate(dynamic dateValue) {
    if (dateValue == null) return null;
    try {
      String dateStr = dateValue.toString();
      if (dateStr.contains('T')) {
        return DateTime.parse(dateStr);
      } else if (dateStr.contains('-') && dateStr.length == 10) {
        return DateTime.parse('${dateStr}T00:00:00Z');
      }
      return DateTime.parse(dateStr);
    } catch (e) {
      debugPrint("❌ Error parsing date '$dateValue': $e");
      return null;
    }
  }

  Future<void> _finalSubmitVendorDetails() async {
    try {
      debugPrint("🚀 SUBMIT CATERING VENDOR :: START");

      // Validation
      if (!_validateAllFields()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please fill all required fields"),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Prepare vendor data
      final Map<String, dynamic> vendorData = {
        "ownerName": _ownerNameController.text.trim(),
        "mobileNumber": _mobileController.text.trim(),
        "email": _emailController.text.trim(),
        "registeredName": _regBusinessNameController.text.trim(),
        "websiteName": _websiteController.text.trim(),
        "businessVertical": _businessVerticalController.text.trim(),
        "remarks": _remarksController.text.trim(),
        "deliveryRadius":
            double.tryParse(_deliveryRadiusController.text.trim()) ?? 0,
        "averageDeliveryTime":
            double.tryParse(_avgDeliveryTimeController.text.trim()) ?? 0,
        "fullAddress": _fullAddressController.text.trim(),
        "doorNumber": _doorNoController.text.trim(),
        "addressLine": _addressLineController.text.trim(),
        "landMark": _landmarkController.text.trim(),
        "city": _cityController.text.trim(),
        "pincode": int.tryParse(_pincodeController.text.trim()) ?? 0,
        "state": _stateController.text.trim(),
        "country": _countryController.text.trim(),
        "latitude": _latitude,
        "longitude": _longitude,
        "holderName": _accountHolderNameController.text.trim(),
        "accountNumber": _accountNumberController.text.trim(),
        "ifscCode": _ifscCodeController.text.trim(),
        "bankName": _bankNameController.text.trim(),
        "branchName": _branchNameController.text.trim(),
        "aadharNumber": _aadhaarNumberController.text.trim(),
        "panCardNumber": _panNumberController.text.trim(),
        "gstNumber": _gstNumberController.text.trim(),
        "tradeLicenseNumber": _tradeLicenseNumberController.text.trim(),
        "fssaiLicenseNumber": _fssaiNumberController.text.trim(),
        "labourLicenseNumber": _labourLicenseNumberController.text.trim(),
        "tradeLicenseStartDate": _tradeLicenseStartDate
            ?.toUtc()
            .toIso8601String(),
        "tradeLicenseEndDate": _tradeLicenseEndDate?.toUtc().toIso8601String(),
        "fssaiStartDate": _fssaiStartDate?.toUtc().toIso8601String(),
        "fssaiEndDate": _fssaiEndDate?.toUtc().toIso8601String(),
        "labourStartDate": _labourStartDate?.toUtc().toIso8601String(),
        "labourEndDate": _labourEndDate?.toUtc().toIso8601String(),
        "commisition": double.tryParse(_commissionController.text.trim()) ?? 0,
        "leads": int.tryParse(_leadsController.text.trim()) ?? 0,
      };

      // Prepare files
      final Map<String, File> files = {};
      if (_logoFile != null && _logoFile!.path != "provided")
        files["companyLogo"] = _logoFile!;
      if (_aadhaarFront != null && _aadhaarFront!.path != "provided")
        files["aadharPhotoFront"] = _aadhaarFront!;
      if (_aadhaarBack != null && _aadhaarBack!.path != "provided")
        files["aadharPhotoBack"] = _aadhaarBack!;
      if (_panCardDoc != null && _panCardDoc!.path != "provided")
        files["panCard"] = _panCardDoc!;
      if (_registerDocFront != null && _registerDocFront!.path != "provided")
        files["registeredDocumentsFront"] = _registerDocFront!;
      if (_registerDocBack != null && _registerDocBack!.path != "provided")
        files["registeredDocumentsBack"] = _registerDocBack!;
      if (_tradeLicenseDoc != null && _tradeLicenseDoc!.path != "provided")
        files["tradeLicense"] = _tradeLicenseDoc!;
      if (_fssaiLicenseDoc != null && _fssaiLicenseDoc!.path != "provided")
        files["fssaiLicense"] = _fssaiLicenseDoc!;
      if (_labourLicenseDoc != null && _labourLicenseDoc!.path != "provided")
        files["labourLicense"] = _labourLicenseDoc!;
      if (_blankChequeDoc != null && _blankChequeDoc!.path != "provided")
        files["blankCheque"] = _blankChequeDoc!;

      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Get vendor ID
      final prefs = await SharedPreferences.getInstance();
      final vendorId = prefs.getInt('vendorId') ?? 0;
      debugPrint("🆔 Vendor ID: $vendorId");

      // Make API call
      // final url = 'http://staging.maamaas.com:8080/catering/api/vendors/$vendorId';
      final url = 'http://staging.maamaas.com:8080/catering/api/vendors/$vendorId';
      final token = prefs.getString('token');

      final request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers['Authorization'] = 'Bearer $token';

      // Add form data
      request.fields['vendorData'] = jsonEncode(vendorData);

      // Add files
      files.forEach((key, file) async {
        request.files.add(await http.MultipartFile.fromPath(key, file.path));
      });

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      // Close loading
      if (context.mounted) Navigator.of(context).pop();

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          _isVendorRegistered = true;
        });

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Vendor details submitted successfully"),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Server error (${response.statusCode})"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("🔥 Exception: $e");
      if (context.mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  bool _validateAllFields() {
    // Basic validation
    if (_ownerNameController.text.isEmpty ||
        _mobileController.text.length != 10 ||
        _emailController.text.isEmpty ||
        !_emailController.text.contains('@') ||
        _regBusinessNameController.text.isEmpty ||
        _fullAddressController.text.isEmpty ||
        _cityController.text.isEmpty ||
        _pincodeController.text.isEmpty ||
        _stateController.text.isEmpty ||
        _countryController.text.isEmpty ||
        _aadhaarNumberController.text.isEmpty ||
        _panNumberController.text.isEmpty ||
        _gstNumberController.text.isEmpty ||
        _tradeLicenseNumberController.text.isEmpty ||
        _fssaiNumberController.text.isEmpty ||
        _labourLicenseNumberController.text.isEmpty ||
        _accountHolderNameController.text.isEmpty ||
        _accountNumberController.text.isEmpty ||
        _ifscCodeController.text.isEmpty ||
        _bankNameController.text.isEmpty ||
        _branchNameController.text.isEmpty) {
      return false;
    }
    return true;
  }

  void _updateFieldStatus(
    String fieldKey,
    FieldStatus status, {
    String? message,
  }) {
    setState(() {
      _fieldStatus[fieldKey] = FieldStatusInfo(
        status: status,
        message: message,
        lastUpdated: DateTime.now(),
      );
    });
  }

  Widget _buildStatusIndicator(String fieldKey) {
    final statusInfo = _fieldStatus[fieldKey] ?? FieldStatusInfo();

    Color color = Colors.grey;
    IconData icon = Icons.help_outline;
    String tooltip = 'Not Verified';

    switch (statusInfo.status) {
      case FieldStatus.verified:
        color = Colors.green;
        icon = Icons.check_circle;
        tooltip = 'Verified';
        break;
      case FieldStatus.rejected:
        color = Colors.red;
        icon = Icons.error;
        tooltip =
            'Rejected: ${statusInfo.message ?? "Please correct this field"}';
        break;
      case FieldStatus.pending:
        color = Colors.orange;
        icon = Icons.pending;
        tooltip = 'Pending: ${statusInfo.message ?? "Under review"}';
        break;
      case FieldStatus.notVerified:
      default:
        color = Colors.grey;
        icon = Icons.help_outline;
        tooltip = 'Not Verified';
    }

    return Tooltip(
      message: tooltip,
      child: Icon(icon, size: 16, color: color),
    );
  }

  Widget _buildTextFieldWithStatus({
    required TextEditingController controller,
    required String label,
    required String fieldKey,
    TextInputType? keyboardType,
    int? maxLength,
    bool isMandatory = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text("$label ${isMandatory ? '*' : ''}"),
            const SizedBox(width: 4),
            _buildStatusIndicator(fieldKey),
          ],
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLength: maxLength,
          onChanged: (value) {
            if (_fieldStatus[fieldKey]?.status != FieldStatus.notVerified) {
              _updateFieldStatus(fieldKey, FieldStatus.notVerified);
            }
          },
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintText: "Enter $label",
            counterText: "",
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildUploadContainerWithStatus({
    required File? file,
    required VoidCallback onTap,
    required String fieldKey,
    required String label,
    bool isMandatory = true,
  }) {
    final isProvided = file?.path == "provided";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text("$label ${isMandatory ? '*' : ''}"),
            const SizedBox(width: 4),
            _buildStatusIndicator(fieldKey),
          ],
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: isProvided ? null : onTap,
          child: Container(
            height: 100,
            width: 100,
            decoration: BoxDecoration(
              border: Border.all(
                color: isProvided ? Colors.green : Colors.grey,
                width: isProvided ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(8),
              color: isProvided ? Colors.green.shade50 : Colors.white,
            ),
            child: isProvided
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cloud_done, size: 40, color: Colors.green),
                        SizedBox(height: 8),
                        Text(
                          "Provided",
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )
                : file != null && file.path != "provided"
                ? Image.file(file, fit: BoxFit.cover)
                : const Center(
                    child: Icon(
                      Icons.upload_file,
                      size: 30,
                      color: Colors.grey,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildDropdownWithStatus({
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    required String label,
    required String fieldKey,
    bool isMandatory = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text("$label ${isMandatory ? '*' : ''}"),
            const SizedBox(width: 4),
            _buildStatusIndicator(fieldKey),
          ],
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(border: OutlineInputBorder()),
          dropdownColor: Colors.white,
          value: value,
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (val) {
            onChanged(val);
            if (_fieldStatus[fieldKey]?.status != FieldStatus.notVerified) {
              _updateFieldStatus(fieldKey, FieldStatus.notVerified);
            }
          },
          hint: Text("Select $label"),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildDatePickerWithStatus({
    required DateTime? date,
    required VoidCallback onTap,
    required String label,
    required String fieldKey,
    bool isMandatory = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text("$label ${isMandatory ? '*' : ''}"),
            const SizedBox(width: 4),
            _buildStatusIndicator(fieldKey),
          ],
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: () {
            onTap();
            if (_fieldStatus[fieldKey]?.status != FieldStatus.notVerified) {
              _updateFieldStatus(fieldKey, FieldStatus.notVerified);
            }
          },
          child: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.centerLeft,
            child: Text(
              date != null ? "${date.toLocal()}".split(' ')[0] : "Select Date",
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Future<void> _pickLogo() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _logoFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickFile(Function(File) setter) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        setter(File(pickedFile.path));
      });
    }
  }

  Future<void> _pickDate(
    BuildContext context,
    Function(DateTime) setter,
  ) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        setter(picked);
      });
    }
  }

  Widget _buildReviewItem(
    String label,
    String value, {
    bool isImage = false,
    File? file,
    String? fieldKey,
  }) {
    final statusWidget = fieldKey != null
        ? _buildStatusIndicator(fieldKey)
        : const SizedBox();

    if (isImage) {
      final isProvided = file?.path == "provided";

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 4),
              statusWidget,
            ],
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(
                color: isProvided || (file != null && file.path != "provided")
                    ? Colors.green
                    : Colors.grey,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  isProvided || (file != null && file.path != "provided")
                      ? Icons.check_circle
                      : Icons.image,
                  color: isProvided || (file != null && file.path != "provided")
                      ? Colors.green
                      : Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  isProvided
                      ? "Provided (from server)"
                      : file != null && file.path != "provided"
                      ? "Uploaded (new)"
                      : "Not Provided",
                  style: TextStyle(
                    color:
                        isProvided || (file != null && file.path != "provided")
                        ? Colors.green
                        : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 4),
              statusWidget,
            ],
          ),
          Text(
            value.isEmpty ? 'N/A' : value,
            style: const TextStyle(fontSize: 14),
          ),
          const Divider(),
        ],
      ),
    );
  }

  Widget _buildStepFields(int step) {
    if (_isLoadingData) {
      return const Center(child: CircularProgressIndicator());
    }

    switch (step) {
      case 0: // Personal Info
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextFieldWithStatus(
              controller: _ownerNameController,
              label: "Owner Name",
              fieldKey: 'ownerName',
            ),
            _buildTextFieldWithStatus(
              controller: _mobileController,
              label: "Mobile Number",
              fieldKey: 'mobile',
              keyboardType: TextInputType.number,
              maxLength: 10,
            ),
            _buildTextFieldWithStatus(
              controller: _emailController,
              label: "Email",
              fieldKey: 'email',
              keyboardType: TextInputType.emailAddress,
            ),
            _buildTextFieldWithStatus(
              controller: _websiteController,
              label: "Website",
              fieldKey: 'website',
              isMandatory: false,
            ),
            _buildUploadContainerWithStatus(
              file: _logoFile,
              onTap: _pickLogo,
              fieldKey: 'logo',
              label: "Company Logo",
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                  ),
                  onPressed: () {
                    if (_ownerNameController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Owner Name is required")),
                      );
                      return;
                    }
                    if (_mobileController.text.length != 10) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Mobile must be 10 digits"),
                        ),
                      );
                      return;
                    }
                    if (!_emailController.text.contains("@") ||
                        !_emailController.text.contains(".")) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please enter a valid email"),
                        ),
                      );
                      return;
                    }

                    setState(() => _currentStep = 1);
                  },
                  child: const Text("Next"),
                ),
              ],
            ),
          ],
        );

      case 1: // Business Details
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextFieldWithStatus(
                controller: _regBusinessNameController,
                label: "Registered Business Name",
                fieldKey: 'registeredBusinessName',
              ),
              _buildTextFieldWithStatus(
                controller: _businessVerticalController,
                label: "Business Vertical",
                fieldKey: 'businessVertical',
                isMandatory: false,
              ),
              _buildTextFieldWithStatus(
                controller: _remarksController,
                label: "Remarks",
                fieldKey: 'remarks',
                isMandatory: false,
              ),
              _buildTextFieldWithStatus(
                controller: _deliveryRadiusController,
                label: "Delivery Radius (km)",
                fieldKey: 'deliveryRadius',
                keyboardType: TextInputType.number,
                isMandatory: false,
              ),
              _buildTextFieldWithStatus(
                controller: _avgDeliveryTimeController,
                label: "Average Delivery Time (minutes)",
                fieldKey: 'avgDeliveryTime',
                keyboardType: TextInputType.number,
                isMandatory: false,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                    ),
                    onPressed: () {
                      setState(() {
                        _currentStep = 0;
                      });
                    },
                    child: const Text("Back"),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                    ),
                    onPressed: () {
                      if (_regBusinessNameController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Registered Business Name is required",
                            ),
                          ),
                        );
                        return;
                      }

                      setState(() {
                        _currentStep = 2;
                      });
                    },
                    child: const Text("Next"),
                  ),
                ],
              ),
            ],
          ),
        );

      case 2: // Address
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Select Location on Map *",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              // Google Map Container
              // Container(
              //   height: 300,
              //   child: GoogleMapsPage(
              //     onAddressSelected: (city, pincode, state, country, lat, lng) {
              //       setState(() {
              //         _cityController.text = city;
              //         _pincodeController.text = pincode;
              //         _stateController.text = state;
              //         _countryController.text = country;
              //         _latitude = lat;
              //         _longitude = lng;
              //       });
              //     },
              //   ),
              // ),
              const SizedBox(height: 12),
              _buildTextFieldWithStatus(
                controller: _fullAddressController,
                label: "Full Address",
                fieldKey: 'fullAddress',
              ),
              _buildTextFieldWithStatus(
                controller: _doorNoController,
                label: "Door No",
                fieldKey: 'doorNo',
              ),
              _buildTextFieldWithStatus(
                controller: _addressLineController,
                label: "Address Line",
                fieldKey: 'addressLine',
              ),
              _buildTextFieldWithStatus(
                controller: _landmarkController,
                label: "Landmark",
                fieldKey: 'landmark',
                isMandatory: false,
              ),
              _buildTextFieldWithStatus(
                controller: _cityController,
                label: "City",
                fieldKey: 'city',
              ),
              _buildTextFieldWithStatus(
                controller: _pincodeController,
                label: "Pincode",
                fieldKey: 'pincode',
                keyboardType: TextInputType.number,
              ),
              _buildTextFieldWithStatus(
                controller: _stateController,
                label: "State",
                fieldKey: 'state',
              ),
              _buildTextFieldWithStatus(
                controller: _countryController,
                label: "Country",
                fieldKey: 'country',
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                    ),
                    onPressed: () {
                      setState(() {
                        _currentStep = 1;
                      });
                    },
                    child: const Text("Back"),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                    ),
                    onPressed: () {
                      if (_fullAddressController.text.isEmpty ||
                          _cityController.text.isEmpty ||
                          _pincodeController.text.isEmpty ||
                          _stateController.text.isEmpty ||
                          _countryController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Please fill all mandatory address fields (*).",
                            ),
                          ),
                        );
                        return;
                      }
                      setState(() {
                        _currentStep = 3;
                      });
                    },
                    child: const Text("Next"),
                  ),
                ],
              ),
            ],
          ),
        );

      case 3: // Required Documents
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextFieldWithStatus(
                controller: _aadhaarNumberController,
                label: "Aadhaar Number",
                fieldKey: 'aadhaarNumber',
                keyboardType: TextInputType.number,
                maxLength: 12,
              ),
              _buildUploadContainerWithStatus(
                file: _aadhaarFront,
                onTap: () => _pickFile((file) => _aadhaarFront = file),
                fieldKey: 'aadhaarFront',
                label: "Aadhaar Front",
              ),
              _buildUploadContainerWithStatus(
                file: _aadhaarBack,
                onTap: () => _pickFile((file) => _aadhaarBack = file),
                fieldKey: 'aadhaarBack',
                label: "Aadhaar Back",
              ),
              _buildTextFieldWithStatus(
                controller: _panNumberController,
                label: "PAN Number",
                fieldKey: 'panNumber',
                maxLength: 10,
              ),
              _buildUploadContainerWithStatus(
                file: _panCardDoc,
                onTap: () => _pickFile((file) => _panCardDoc = file),
                fieldKey: 'panCardDoc',
                label: "PAN Document",
              ),
              _buildTextFieldWithStatus(
                controller: _gstNumberController,
                label: "GST Number",
                fieldKey: 'gstNumber',
              ),
              _buildUploadContainerWithStatus(
                file: _registerDocFront,
                onTap: () => _pickFile((file) => _registerDocFront = file),
                fieldKey: 'registerDocFront',
                label: "Register Document Front",
              ),
              _buildUploadContainerWithStatus(
                file: _registerDocBack,
                onTap: () => _pickFile((file) => _registerDocBack = file),
                fieldKey: 'registerDocBack',
                label: "Register Document Back",
              ),
              _buildTextFieldWithStatus(
                controller: _tradeLicenseNumberController,
                label: "Trade License Number",
                fieldKey: 'tradeLicenseNumber',
              ),
              _buildUploadContainerWithStatus(
                file: _tradeLicenseDoc,
                onTap: () => _pickFile((file) => _tradeLicenseDoc = file),
                fieldKey: 'tradeLicenseDoc',
                label: "Trade License Document",
              ),
              _buildDatePickerWithStatus(
                date: _tradeLicenseStartDate,
                onTap: () =>
                    _pickDate(context, (date) => _tradeLicenseStartDate = date),
                label: "Trade License Start Date",
                fieldKey: 'tradeLicenseStartDate',
              ),
              _buildDatePickerWithStatus(
                date: _tradeLicenseEndDate,
                onTap: () =>
                    _pickDate(context, (date) => _tradeLicenseEndDate = date),
                label: "Trade License End Date",
                fieldKey: 'tradeLicenseEndDate',
              ),
              _buildTextFieldWithStatus(
                controller: _fssaiNumberController,
                label: "FSSAI License Number",
                fieldKey: 'fssaiNumber',
              ),
              _buildUploadContainerWithStatus(
                file: _fssaiLicenseDoc,
                onTap: () => _pickFile((file) => _fssaiLicenseDoc = file),
                fieldKey: 'fssaiLicenseDoc',
                label: "FSSAI License Document",
              ),
              _buildDatePickerWithStatus(
                date: _fssaiStartDate,
                onTap: () =>
                    _pickDate(context, (date) => _fssaiStartDate = date),
                label: "FSSAI Start Date",
                fieldKey: 'fssaiStartDate',
              ),
              _buildDatePickerWithStatus(
                date: _fssaiEndDate,
                onTap: () => _pickDate(context, (date) => _fssaiEndDate = date),
                label: "FSSAI End Date",
                fieldKey: 'fssaiEndDate',
              ),
              _buildTextFieldWithStatus(
                controller: _labourLicenseNumberController,
                label: "Labour License Number",
                fieldKey: 'labourLicenseNumber',
              ),
              _buildUploadContainerWithStatus(
                file: _labourLicenseDoc,
                onTap: () => _pickFile((file) => _labourLicenseDoc = file),
                fieldKey: 'labourLicenseDoc',
                label: "Labour License Document",
              ),
              _buildDatePickerWithStatus(
                date: _labourStartDate,
                onTap: () =>
                    _pickDate(context, (date) => _labourStartDate = date),
                label: "Labour License Start Date",
                fieldKey: 'labourStartDate',
              ),
              _buildDatePickerWithStatus(
                date: _labourEndDate,
                onTap: () =>
                    _pickDate(context, (date) => _labourEndDate = date),
                label: "Labour License End Date",
                fieldKey: 'labourEndDate',
              ),
              _buildUploadContainerWithStatus(
                file: _blankChequeDoc,
                onTap: () => _pickFile((file) => _blankChequeDoc = file),
                fieldKey: 'blankChequeDoc',
                label: "Blank Cheque Document",
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                    ),
                    onPressed: () {
                      setState(() {
                        _currentStep = 2;
                      });
                    },
                    child: const Text("Back"),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                    ),
                    onPressed: () {
                      if (_aadhaarNumberController.text.isEmpty ||
                          _panNumberController.text.isEmpty ||
                          _aadhaarFront == null ||
                          _aadhaarBack == null ||
                          _panCardDoc == null ||
                          _gstNumberController.text.isEmpty ||
                          _registerDocFront == null ||
                          _registerDocBack == null ||
                          _tradeLicenseNumberController.text.isEmpty ||
                          _tradeLicenseDoc == null ||
                          _tradeLicenseStartDate == null ||
                          _tradeLicenseEndDate == null ||
                          _fssaiNumberController.text.isEmpty ||
                          _fssaiLicenseDoc == null ||
                          _fssaiStartDate == null ||
                          _fssaiEndDate == null ||
                          _labourLicenseNumberController.text.isEmpty ||
                          _labourLicenseDoc == null ||
                          _labourStartDate == null ||
                          _labourEndDate == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Please fill/upload all mandatory document fields (*).",
                            ),
                          ),
                        );
                        return;
                      }

                      setState(() {
                        _currentStep = 4;
                      });
                    },
                    child: const Text("Next"),
                  ),
                ],
              ),
            ],
          ),
        );

      case 4: // Bank Account Details
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextFieldWithStatus(
                controller: _accountHolderNameController,
                label: "Account Holder Name",
                fieldKey: 'accountHolderName',
              ),
              _buildTextFieldWithStatus(
                controller: _accountNumberController,
                label: "Account Number",
                fieldKey: 'accountNumber',
                keyboardType: TextInputType.number,
              ),
              _buildTextFieldWithStatus(
                controller: _ifscCodeController,
                label: "IFSC Code",
                fieldKey: 'ifscCode',
              ),
              _buildTextFieldWithStatus(
                controller: _bankNameController,
                label: "Bank Name",
                fieldKey: 'bankName',
              ),
              _buildTextFieldWithStatus(
                controller: _branchNameController,
                label: "Branch Name",
                fieldKey: 'branchName',
              ),
              _buildTextFieldWithStatus(
                controller: _commissionController,
                label: "Commission (%)",
                fieldKey: 'commission',
                keyboardType: TextInputType.number,
                isMandatory: false,
              ),
              _buildTextFieldWithStatus(
                controller: _leadsController,
                label: "Leads",
                fieldKey: 'leads',
                keyboardType: TextInputType.number,
                isMandatory: false,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                    ),
                    onPressed: () {
                      setState(() {
                        _currentStep = 3;
                      });
                    },
                    child: const Text("Back"),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                    ),
                    onPressed: () {
                      if (_accountHolderNameController.text.isEmpty ||
                          _accountNumberController.text.isEmpty ||
                          _ifscCodeController.text.isEmpty ||
                          _bankNameController.text.isEmpty ||
                          _branchNameController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Please fill all mandatory bank account details (*).",
                            ),
                          ),
                        );
                        return;
                      }

                      setState(() {
                        _currentStep = 5;
                      });
                    },
                    child: const Text("Review"),
                  ),
                ],
              ),
            ],
          ),
        );

      case 5: // Review
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: _isVendorRegistered
                      ? Colors.green.shade50
                      : Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isVendorRegistered ? Colors.green : Colors.orange,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isVendorRegistered ? Icons.check_circle : Icons.warning,
                      color: _isVendorRegistered ? Colors.green : Colors.orange,
                      size: 30,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isVendorRegistered
                                ? "Vendor Already Registered"
                                : "Vendor Not Registered Yet",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: _isVendorRegistered
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _isVendorRegistered
                                ? "Your registration details are already submitted. You can review but cannot submit again."
                                : "Please review and submit your registration details.",
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Text(
                "📋 Personal Info",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Divider(),
              _buildReviewItem(
                "Owner Name",
                _ownerNameController.text,
                fieldKey: 'ownerName',
              ),
              _buildReviewItem(
                "Mobile Number",
                _mobileController.text,
                fieldKey: 'mobile',
              ),
              _buildReviewItem(
                "Email",
                _emailController.text,
                fieldKey: 'email',
              ),
              _buildReviewItem(
                "Website",
                _websiteController.text,
                fieldKey: 'website',
              ),
              _buildReviewItem(
                "Company Logo",
                "",
                isImage: true,
                file: _logoFile,
                fieldKey: 'logo',
              ),

              const SizedBox(height: 10),
              const Text(
                "🏢 Business Details",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Divider(),
              _buildReviewItem(
                "Registered Business Name",
                _regBusinessNameController.text,
                fieldKey: 'registeredBusinessName',
              ),
              _buildReviewItem(
                "Business Vertical",
                _businessVerticalController.text,
                fieldKey: 'businessVertical',
              ),
              _buildReviewItem(
                "Remarks",
                _remarksController.text,
                fieldKey: 'remarks',
              ),
              _buildReviewItem(
                "Delivery Radius",
                _deliveryRadiusController.text,
                fieldKey: 'deliveryRadius',
              ),
              _buildReviewItem(
                "Avg Delivery Time",
                _avgDeliveryTimeController.text,
                fieldKey: 'avgDeliveryTime',
              ),

              const SizedBox(height: 10),
              const Text(
                "📍 Address",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Divider(),
              _buildReviewItem(
                "Full Address",
                _fullAddressController.text,
                fieldKey: 'fullAddress',
              ),
              _buildReviewItem(
                "Door No",
                _doorNoController.text,
                fieldKey: 'doorNo',
              ),
              _buildReviewItem(
                "Address Line",
                _addressLineController.text,
                fieldKey: 'addressLine',
              ),
              _buildReviewItem(
                "Landmark",
                _landmarkController.text,
                fieldKey: 'landmark',
              ),
              _buildReviewItem("City", _cityController.text, fieldKey: 'city'),
              _buildReviewItem(
                "Pincode",
                _pincodeController.text,
                fieldKey: 'pincode',
              ),
              _buildReviewItem(
                "State",
                _stateController.text,
                fieldKey: 'state',
              ),
              _buildReviewItem(
                "Country",
                _countryController.text,
                fieldKey: 'country',
              ),

              const SizedBox(height: 10),
              const Text(
                "🏦 Bank Account Details",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Divider(),
              _buildReviewItem(
                "Account Holder Name",
                _accountHolderNameController.text,
                fieldKey: 'accountHolderName',
              ),
              _buildReviewItem(
                "Account Number",
                _accountNumberController.text,
                fieldKey: 'accountNumber',
              ),
              _buildReviewItem(
                "IFSC Code",
                _ifscCodeController.text,
                fieldKey: 'ifscCode',
              ),
              _buildReviewItem(
                "Bank Name",
                _bankNameController.text,
                fieldKey: 'bankName',
              ),
              _buildReviewItem(
                "Branch Name",
                _branchNameController.text,
                fieldKey: 'branchName',
              ),
              _buildReviewItem(
                "Commission",
                _commissionController.text,
                fieldKey: 'commission',
              ),
              _buildReviewItem(
                "Leads",
                _leadsController.text,
                fieldKey: 'leads',
              ),

              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _currentStep = 4;
                      });
                    },
                    child: const Text("Back"),
                  ),
                  if (!_isVendorRegistered)
                    ElevatedButton(
                      onPressed: () async {
                        await _finalSubmitVendorDetails();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text("Final Submit"),
                    )
                  else
                    ElevatedButton(
                      onPressed: null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text("Already Submitted"),
                    ),
                ],
              ),
            ],
          ),
        );

      default:
        return Center(
          child: Text(
            "Fields for '${steps[step]}' will go here",
            style: const TextStyle(fontSize: 16),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _navigateBackToHome();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: _navigateBackToHome,
          ),
          title: Text(
            'Catering Vendor Registration',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        body: Row(
          children: [
            Container(
              width: 60,
              color: Colors.grey[200],
              child: ListView.builder(
                itemCount: steps.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _currentStep = index;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 8,
                      ),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: _currentStep == index
                                ? Colors.deepPurple
                                : Colors.grey,
                            child: Text(
                              "${index + 1}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            steps[index],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: _currentStep == index
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildStepFields(_currentStep),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
