// // // // // // // // // import 'dart:convert';
// // // // // // // // // import '../../API/Apiclient.dart';
// // // // // // // // // import '../models/vendor_form_data.dart';
// // // // // // // // //
// // // // // // // // // class VendorApiService {
// // // // // // // // //   /// 🔹 GET Vendor Details
// // // // // // // // //   static Future<Map<String, dynamic>?> getVendor(String vendorId) async {
// // // // // // // // //     try {
// // // // // // // // //       final response = await ApiClient.get(
// // // // // // // // //         'api/vendors/$vendorId',
// // // // // // // // //         service: 'food',
// // // // // // // // //       );
// // // // // // // // //
// // // // // // // // //       if (response.statusCode == 200) {
// // // // // // // // //         return jsonDecode(response.body) as Map<String, dynamic>;
// // // // // // // // //       }
// // // // // // // // //
// // // // // // // // //       return null;
// // // // // // // // //     } catch (e) {
// // // // // // // // //       print('❌ GET Vendor Error: $e');
// // // // // // // // //       return null;
// // // // // // // // //     }
// // // // // // // // //   }
// // // // // // // // //
// // // // // // // // //   /// 🔹 REGISTER / UPDATE Vendor (Multipart)
// // // // // // // // //   static Future<bool> registerVendor(
// // // // // // // // //     String vendorId,
// // // // // // // // //     VendorFormData formData,
// // // // // // // // //   ) async {
// // // // // // // // //     try {
// // // // // // // // //       /// 🔥 Prepare JSON payload
// // // // // // // // //       final vendorDataJson = {
// // // // // // // // //         'vendorId': int.tryParse(vendorId) ?? 0,
// // // // // // // // //         'latitude': formData.latitude ?? 0,
// // // // // // // // //         'longitude': formData.longitude ?? 0,
// // // // // // // // //         'fullAddress': formData.address,
// // // // // // // // //         'addressLine': formData.addressLine,
// // // // // // // // //         'doorNumber': formData.doorNumber,
// // // // // // // // //         'landMark': formData.landMark,
// // // // // // // // //         'city': formData.city,
// // // // // // // // //         'state': formData.state.isEmpty ? 'Telangana' : formData.state,
// // // // // // // // //         'pincode': int.tryParse(formData.pincode) ?? 0,
// // // // // // // // //
// // // // // // // // //         // Company Info
// // // // // // // // //         'companyName': formData.companyName,
// // // // // // // // //         'registeredName': formData.companyName,
// // // // // // // // //         'ownerName': formData.companyName,
// // // // // // // // //         'businessVertical': 'FOOD_AND_BEVERAGES',
// // // // // // // // //         'position': formData.position,
// // // // // // // // //         'vendorType': formData.verticalType.isNotEmpty
// // // // // // // // //             ? formData.verticalType
// // // // // // // // //             : 'Restaurant',
// // // // // // // // //
// // // // // // // // //         // Contact Info
// // // // // // // // //         'holderName': formData.contactName,
// // // // // // // // //         'mobileNumber': formData.phone,
// // // // // // // // //         'email': formData.email,
// // // // // // // // //
// // // // // // // // //         // Documents
// // // // // // // // //         'aadharNumber': formData.aadhar,
// // // // // // // // //         'panCardNumber': formData.pan,
// // // // // // // // //         'gstNumber': formData.gst,
// // // // // // // // //
// // // // // // // // //         // Trade License
// // // // // // // // //         'tradeLicenseNumber': formData.tradeLicenseNo,
// // // // // // // // //         'tradeLicenseStartDate': formData.tradeStart,
// // // // // // // // //         'tradeLicenseEndDate': formData.tradeEnd,
// // // // // // // // //
// // // // // // // // //         // FSSAI
// // // // // // // // //         'fssaiLicenseNumber': formData.fssaiNo,
// // // // // // // // //         'fssaiStartDate': formData.fssaiStart,
// // // // // // // // //         'fssaiEndDate': formData.fssaiEnd,
// // // // // // // // //
// // // // // // // // //         // Labour License
// // // // // // // // //         'labourLicenseNumber': formData.labourLicenseNo,
// // // // // // // // //         'labourStartDate': formData.labourStart,
// // // // // // // // //         'labourEndDate': formData.labourEnd,
// // // // // // // // //
// // // // // // // // //         // Bank Details
// // // // // // // // //         'accountNumber': formData.accountNumber,
// // // // // // // // //         'ifscCode': formData.ifsc,
// // // // // // // // //         'bankName': formData.bankName,
// // // // // // // // //         'branchName': formData.bankName,
// // // // // // // // //
// // // // // // // // //         // Status Flags
// // // // // // // // //         'aadharNumberStatus': false,
// // // // // // // // //         'panCardStatus': false,
// // // // // // // // //         'gstNumberStatus': false,
// // // // // // // // //         'tradeLicenseStatus': false,
// // // // // // // // //         'labourLicenseStatus': false,
// // // // // // // // //         'fssaiLicenseStatus': false,
// // // // // // // // //
// // // // // // // // //         'online': false,
// // // // // // // // //       };
// // // // // // // // //
// // // // // // // // //       /// 🔥 Call centralized API client
// // // // // // // // //       final response = await ApiClient.sendMultipartRequest(
// // // // // // // // //         endpoint: 'api/vendors/$vendorId',
// // // // // // // // //         method: 'POST',
// // // // // // // // //         service: 'food',
// // // // // // // // //
// // // // // // // // //         /// IMPORTANT: send JSON as string
// // // // // // // // //         data: {'vendorData': jsonEncode(vendorDataJson)},
// // // // // // // // //
// // // // // // // // //         /// Attach files safely
// // // // // // // // //         files: {
// // // // // // // // //           if (formData.aadharFile != null)
// // // // // // // // //             'aadharPhotoFront': formData.aadharFile!,
// // // // // // // // //           if (formData.panFile != null) 'panCard': formData.panFile!,
// // // // // // // // //           if (formData.passbookFile != null) 'passbook': formData.passbookFile!,
// // // // // // // // //           if (formData.labourFile != null)
// // // // // // // // //             'labourLicense': formData.labourFile!,
// // // // // // // // //           if (formData.fssaiFile != null) 'fssaiLicense': formData.fssaiFile!,
// // // // // // // // //           if (formData.tradeLicenseFile != null)
// // // // // // // // //             'tradeLicense': formData.tradeLicenseFile!,
// // // // // // // // //           if (formData.gstFile != null) 'gstFile': formData.gstFile!,
// // // // // // // // //         },
// // // // // // // // //       );
// // // // // // // // //
// // // // // // // // //       if (response.statusCode == 200 || response.statusCode == 201) {
// // // // // // // // //         print('✅ Vendor registered successfully');
// // // // // // // // //         return true;
// // // // // // // // //       } else {
// // // // // // // // //         print('❌ Vendor registration failed: ${response.statusCode}');
// // // // // // // // //         print('📦 Response: ${response.body}');
// // // // // // // // //         return false;
// // // // // // // // //       }
// // // // // // // // //     } catch (e) {
// // // // // // // // //       print('❌ POST Vendor Error: $e');
// // // // // // // // //       return false;
// // // // // // // // //     }
// // // // // // // // //   }
// // // // // // // // // }
// // // // // // // // import 'dart:convert';
// // // // // // // //
// // // // // // // // import 'package:maamaaspartner/RegistrationScreen/models/vendor_form_data.dart';
// // // // // // // //
// // // // // // // // import '../../API/Apiclient.dart';
// // // // // // // //
// // // // // // // // class VendorApiService {
// // // // // // // //   static const String _endpoint = 'api/vendors';
// // // // // // // //
// // // // // // // //   // GET vendor
// // // // // // // //   static Future<Map<String, dynamic>?> getVendor(String vendorId) async {
// // // // // // // //     try {
// // // // // // // //       final response = await ApiClient.get(
// // // // // // // //         '$_endpoint/$vendorId',
// // // // // // // //         service: 'food',
// // // // // // // //       );
// // // // // // // //
// // // // // // // //       if (response.statusCode == 200) {
// // // // // // // //         return jsonDecode(response.body);
// // // // // // // //       }
// // // // // // // //
// // // // // // // //       return null;
// // // // // // // //     } catch (e) {
// // // // // // // //       print('GET Error: $e');
// // // // // // // //       return null;
// // // // // // // //     }
// // // // // // // //   }
// // // // // // // //
// // // // // // // //   // POST vendor (multipart via ApiClient)
// // // // // // // //   static Future<bool> registerVendor(
// // // // // // // //     String vendorId,
// // // // // // // //     VendorFormData formData,
// // // // // // // //   ) async {
// // // // // // // //     try {
// // // // // // // //       final vendorDataJson = {
// // // // // // // //         'vendorId': int.tryParse(vendorId) ?? 0,
// // // // // // // //         'latitude': formData.latitude ?? 0,
// // // // // // // //         'longitude': formData.longitude ?? 0,
// // // // // // // //         'fullAddress': formData.address,
// // // // // // // //         'addressLine': formData.addressLine,
// // // // // // // //         'doorNumber': formData.doorNumber,
// // // // // // // //         'landMark': formData.landMark,
// // // // // // // //         'city': formData.city,
// // // // // // // //         'state': formData.state.isEmpty ? 'Telangana' : formData.state,
// // // // // // // //         'pincode': int.tryParse(formData.pincode) ?? 0,
// // // // // // // //         'companyName': formData.companyName,
// // // // // // // //         'registeredName': formData.companyName,
// // // // // // // //         'ownerName': formData.companyName,
// // // // // // // //         'businessVertical': 'FOOD_AND_BEVERAGES',
// // // // // // // //         'position': formData.position,
// // // // // // // //         'vendorType': formData.verticalType.isNotEmpty
// // // // // // // //             ? formData.verticalType
// // // // // // // //             : 'Restaurant',
// // // // // // // //         'holderName': formData.contactName,
// // // // // // // //         'mobileNumber': formData.phone,
// // // // // // // //         'email': formData.email,
// // // // // // // //         'aadharNumber': formData.aadhar,
// // // // // // // //         'panCardNumber': formData.pan,
// // // // // // // //         'gstNumber': formData.gst,
// // // // // // // //         'tradeLicenseNumber': formData.tradeLicenseNo,
// // // // // // // //         'tradeLicenseStartDate': formData.tradeStart,
// // // // // // // //         'tradeLicenseEndDate': formData.tradeEnd,
// // // // // // // //         'fssaiLicenseNumber': formData.fssaiNo,
// // // // // // // //         'fssaiStartDate': formData.fssaiStart,
// // // // // // // //         'fssaiEndDate': formData.fssaiEnd,
// // // // // // // //         'labourLicenseNumber': formData.labourLicenseNo,
// // // // // // // //         'labourStartDate': formData.labourStart,
// // // // // // // //         'labourEndDate': formData.labourEnd,
// // // // // // // //         'accountNumber': formData.accountNumber,
// // // // // // // //         'ifscCode': formData.ifsc,
// // // // // // // //         'bankName': formData.bankName,
// // // // // // // //         'branchName': formData.bankName,
// // // // // // // //         'aadharNumberStatus': false,
// // // // // // // //         'panCardStatus': false,
// // // // // // // //         'gstNumberStatus': false,
// // // // // // // //         'tradeLicenseStatus': false,
// // // // // // // //         'labourLicenseStatus': false,
// // // // // // // //         'fssaiLicenseStatus': false,
// // // // // // // //         'online': false,
// // // // // // // //       };
// // // // // // // //
// // // // // // // //       final response = await ApiClient.sendMultipartRequest(
// // // // // // // //         endpoint: '$_endpoint/$vendorId',
// // // // // // // //         method: 'POST',
// // // // // // // //         service: 'food',
// // // // // // // //         data: {
// // // // // // // //           // 🔥 Important: send JSON as STRING
// // // // // // // //           'vendorData': jsonEncode(vendorDataJson),
// // // // // // // //         },
// // // // // // // //         files: {
// // // // // // // //           if (formData.aadharFile != null)
// // // // // // // //             'aadharPhotoFront': formData.aadharFile!,
// // // // // // // //           if (formData.panFile != null) 'panCard': formData.panFile!,
// // // // // // // //           if (formData.passbookFile != null) 'passbook': formData.passbookFile!,
// // // // // // // //           if (formData.labourFile != null)
// // // // // // // //             'labourLicense': formData.labourFile!,
// // // // // // // //           if (formData.fssaiFile != null) 'fssaiLicense': formData.fssaiFile!,
// // // // // // // //           if (formData.tradeLicenseFile != null)
// // // // // // // //             'tradeLicense': formData.tradeLicenseFile!,
// // // // // // // //           if (formData.gstFile != null) 'gstFile': formData.gstFile!,
// // // // // // // //         },
// // // // // // // //       );
// // // // // // // //
// // // // // // // //       return response.statusCode == 200 || response.statusCode == 201;
// // // // // // // //     } catch (e) {
// // // // // // // //       print('POST Error: $e');
// // // // // // // //       return false;
// // // // // // // //     }
// // // // // // // //   }
// // // // // // // //
// // // // // // // //   // vendor_api_service.dart - Add this method
// // // // // // // //   static Future<VendorFormData?> getVendorFormData(String vendorId) async {
// // // // // // // //     try {
// // // // // // // //       final response = await ApiClient.get(
// // // // // // // //         '$_endpoint/$vendorId',
// // // // // // // //         service: 'food',
// // // // // // // //       );
// // // // // // // //
// // // // // // // //       if (response.statusCode == 200) {
// // // // // // // //         final data = jsonDecode(response.body);
// // // // // // // //         return _parseVendorDataToFormData(data);
// // // // // // // //       }
// // // // // // // //       return null;
// // // // // // // //     } catch (e) {
// // // // // // // //       print('GET Error: $e');
// // // // // // // //       return null;
// // // // // // // //     }
// // // // // // // //   }
// // // // // // // //
// // // // // // // //   // Helper method to parse API response to VendorFormData
// // // // // // // //   static VendorFormData _parseVendorDataToFormData(Map<String, dynamic> data) {
// // // // // // // //     return VendorFormData(
// // // // // // // //       // Company Details
// // // // // // // //       companyName: data['registeredName'] ?? '',
// // // // // // // //       businessVertical: 'Food & Beverages',
// // // // // // // //       position: data['position'] ?? '',
// // // // // // // //       verticalType: data['vendorType'] ?? '',
// // // // // // // //
// // // // // // // //       // Address
// // // // // // // //       doorNumber: data['doorNumber'] ?? '',
// // // // // // // //       addressLine: data['addressLine'] ?? '',
// // // // // // // //       landMark: data['landMark'] ?? '',
// // // // // // // //       city: data['city'] ?? '',
// // // // // // // //       state: data['state'] ?? '',
// // // // // // // //       pincode: data['pincode']?.toString() ?? '',
// // // // // // // //       latitude: data['latitude']?.toDouble(),
// // // // // // // //       longitude: data['longitude']?.toDouble(),
// // // // // // // //       address: data['fullAddress'] ?? '',
// // // // // // // //
// // // // // // // //       // Contact
// // // // // // // //       contactName: data['holderName'] ?? '',
// // // // // // // //       phone: data['mobileNumber'] ?? '',
// // // // // // // //       email: data['email'] ?? '',
// // // // // // // //       aadhar: data['aadharNumber'] ?? '',
// // // // // // // //       aadharFile: null, // You'll need to download these if needed
// // // // // // // //       // Documents
// // // // // // // //       gst: data['gstNumber'] ?? '',
// // // // // // // //       gstFile: null,
// // // // // // // //       pan: data['panCardNumber'] ?? '',
// // // // // // // //       panFile: null,
// // // // // // // //       fssaiNo: data['fssaiLicenseNumber'] ?? '',
// // // // // // // //       fssaiStart: data['fssaiStartDate'] ?? '',
// // // // // // // //       fssaiEnd: data['fssaiEndDate'] ?? '',
// // // // // // // //       fssaiFile: null,
// // // // // // // //       tradeLicenseNo: data['tradeLicenseNumber'] ?? '',
// // // // // // // //       tradeStart: data['tradeLicenseStartDate'] ?? '',
// // // // // // // //       tradeEnd: data['tradeLicenseEndDate'] ?? '',
// // // // // // // //       tradeLicenseFile: null,
// // // // // // // //       labourLicenseNo: data['labourLicenseNumber'] ?? '',
// // // // // // // //       labourStart: data['labourStartDate'] ?? '',
// // // // // // // //       labourEnd: data['labourEndDate'] ?? '',
// // // // // // // //       labourFile: null,
// // // // // // // //
// // // // // // // //       // Bank
// // // // // // // //       bankName: data['bankName'] ?? data['branchName'] ?? '',
// // // // // // // //       ifsc: data['ifscCode'] ?? '',
// // // // // // // //       accountNumber: data['accountNumber'] ?? '',
// // // // // // // //       passbookFile: null,
// // // // // // // //     );
// // // // // // // //   }
// // // // // // // // }
// // // // // // // import 'dart:convert';
// // // // // // // import 'package:maamaaspartner/RegistrationScreen/models/vendor_form_data.dart';
// // // // // // // import '../../API/Apiclient.dart';
// // // // // // //
// // // // // // // class VendorApiService {
// // // // // // //   static const String _endpoint = 'api/vendors';
// // // // // // //
// // // // // // //   // GET vendor
// // // // // // //   static Future<Map<String, dynamic>?> getVendor(String vendorId) async {
// // // // // // //     try {
// // // // // // //       final response = await ApiClient.get(
// // // // // // //         '$_endpoint/$vendorId',
// // // // // // //         service: 'food',
// // // // // // //       );
// // // // // // //
// // // // // // //       if (response.statusCode == 200) {
// // // // // // //         return jsonDecode(response.body);
// // // // // // //       }
// // // // // // //       return null;
// // // // // // //     } catch (e) {
// // // // // // //       print('GET Error: $e');
// // // // // // //       return null;
// // // // // // //     }
// // // // // // //   }
// // // // // // //
// // // // // // //   // POST vendor (multipart via ApiClient)
// // // // // // //   static Future<bool> registerVendor(
// // // // // // //     String vendorId,
// // // // // // //     VendorFormData formData,
// // // // // // //   ) async {
// // // // // // //     try {
// // // // // // //       final vendorDataJson = {
// // // // // // //         'vendorId': int.tryParse(vendorId) ?? 0,
// // // // // // //         'latitude': formData.latitude ?? 0,
// // // // // // //         'longitude': formData.longitude ?? 0,
// // // // // // //         'fullAddress': formData.address,
// // // // // // //         'addressLine': formData.addressLine,
// // // // // // //         'doorNumber': formData.doorNumber,
// // // // // // //         'landMark': formData.landMark,
// // // // // // //         'city': formData.city,
// // // // // // //         'state': formData.state.isEmpty ? 'Telangana' : formData.state,
// // // // // // //         'pincode': int.tryParse(formData.pincode) ?? 0,
// // // // // // //         'companyName': formData.companyName,
// // // // // // //         'registeredName': formData.companyName,
// // // // // // //         'ownerName': formData.companyName,
// // // // // // //         'businessVertical': 'FOOD_AND_BEVERAGES',
// // // // // // //         'position': formData.position,
// // // // // // //         'vendorType': formData.verticalType.isNotEmpty
// // // // // // //             ? formData.verticalType
// // // // // // //             : 'Restaurant',
// // // // // // //         'holderName': formData.contactName,
// // // // // // //         'mobileNumber': formData.phone,
// // // // // // //         'email': formData.email,
// // // // // // //         'aadharNumber': formData.aadhar,
// // // // // // //         'panCardNumber': formData.pan,
// // // // // // //         'gstNumber': formData.gst,
// // // // // // //         'tradeLicenseNumber': formData.tradeLicenseNo,
// // // // // // //         'tradeLicenseStartDate': formData.tradeStart,
// // // // // // //         'tradeLicenseEndDate': formData.tradeEnd,
// // // // // // //         'fssaiLicenseNumber': formData.fssaiNo,
// // // // // // //         'fssaiStartDate': formData.fssaiStart,
// // // // // // //         'fssaiEndDate': formData.fssaiEnd,
// // // // // // //         'labourLicenseNumber': formData.labourLicenseNo,
// // // // // // //         'labourStartDate': formData.labourStart,
// // // // // // //         'labourEndDate': formData.labourEnd,
// // // // // // //         'accountNumber': formData.accountNumber,
// // // // // // //         'ifscCode': formData.ifsc,
// // // // // // //         'bankName': formData.bankName,
// // // // // // //         'branchName': formData.bankName,
// // // // // // //         'aadharNumberStatus': false,
// // // // // // //         'panCardStatus': false,
// // // // // // //         'gstNumberStatus': false,
// // // // // // //         'tradeLicenseStatus': false,
// // // // // // //         'labourLicenseStatus': false,
// // // // // // //         'fssaiLicenseStatus': false,
// // // // // // //         'online': false,
// // // // // // //       };
// // // // // // //
// // // // // // //       final response = await ApiClient.sendMultipartRequest(
// // // // // // //         endpoint: '$_endpoint/$vendorId',
// // // // // // //         method: 'POST',
// // // // // // //         service: 'food',
// // // // // // //         data: {'vendorData': jsonEncode(vendorDataJson)},
// // // // // // //         files: {
// // // // // // //           if (formData.aadharFile != null)
// // // // // // //             'aadharPhotoFront': formData.aadharFile!,
// // // // // // //           if (formData.panFile != null) 'panCard': formData.panFile!,
// // // // // // //           if (formData.passbookFile != null) 'passbook': formData.passbookFile!,
// // // // // // //           if (formData.labourFile != null)
// // // // // // //             'labourLicense': formData.labourFile!,
// // // // // // //           if (formData.fssaiFile != null) 'fssaiLicense': formData.fssaiFile!,
// // // // // // //           if (formData.tradeLicenseFile != null)
// // // // // // //             'tradeLicense': formData.tradeLicenseFile!,
// // // // // // //           if (formData.gstFile != null) 'gstFile': formData.gstFile!,
// // // // // // //         },
// // // // // // //       );
// // // // // // //
// // // // // // //       return response.statusCode == 200 || response.statusCode == 201;
// // // // // // //     } catch (e) {
// // // // // // //       print('POST Error: $e');
// // // // // // //       return false;
// // // // // // //     }
// // // // // // //   }
// // // // // // //
// // // // // // //   // GET vendor and parse to FormData
// // // // // // //   static Future<VendorFormData?> getVendorFormData(String vendorId) async {
// // // // // // //     try {
// // // // // // //       final response = await ApiClient.get(
// // // // // // //         '$_endpoint/$vendorId',
// // // // // // //         service: 'food',
// // // // // // //       );
// // // // // // //
// // // // // // //       if (response.statusCode == 200) {
// // // // // // //         final data = jsonDecode(response.body);
// // // // // // //         return _parseVendorDataToFormData(data);
// // // // // // //       }
// // // // // // //       return null;
// // // // // // //     } catch (e) {
// // // // // // //       print('GET Error: $e');
// // // // // // //       return null;
// // // // // // //     }
// // // // // // //   }
// // // // // // //
// // // // // // //   // Helper method to parse API response to VendorFormData
// // // // // // //   static VendorFormData _parseVendorDataToFormData(Map<String, dynamic> data) {
// // // // // // //     return VendorFormData(
// // // // // // //       // Company Details - Using correct field names from API response
// // // // // // //       companyName: data['registeredName'] ?? data['companyName'] ?? '',
// // // // // // //       businessVertical:
// // // // // // //           data['businessVertical']?.toLowerCase().replaceAll('_', ' ') ??
// // // // // // //           'Food & Beverages',
// // // // // // //       position: data['position'] ?? '',
// // // // // // //       verticalType: data['vendorType'] ?? '',
// // // // // // //
// // // // // // //       // Address - Using correct field names
// // // // // // //       doorNumber: data['doorNumber'] ?? '',
// // // // // // //       addressLine: data['addressLine'] ?? '',
// // // // // // //       landMark: data['landMark'] ?? '',
// // // // // // //       city: data['city'] ?? '',
// // // // // // //       state: data['state'] ?? '',
// // // // // // //       pincode: data['pincode']?.toString() ?? '',
// // // // // // //       latitude: data['latitude']?.toDouble(),
// // // // // // //       longitude: data['longitude']?.toDouble(),
// // // // // // //       address: data['fullAddress'] ?? '',
// // // // // // //
// // // // // // //       // Contact - Using correct field names
// // // // // // //       contactName: data['holderName'] ?? '',
// // // // // // //       phone: data['mobileNumber']?.toString() ?? '',
// // // // // // //       email: data['email'] ?? '',
// // // // // // //       aadhar: data['aadharNumber']?.toString() ?? '',
// // // // // // //       aadharFile: null, // Can't download file automatically
// // // // // // //       // Documents - Using correct field names
// // // // // // //       gst: data['gstNumber'] ?? '',
// // // // // // //       gstFile: null,
// // // // // // //       pan: data['panCardNumber'] ?? '',
// // // // // // //       panFile: null,
// // // // // // //       fssaiNo: data['fssaiLicenseNumber'] ?? '',
// // // // // // //       fssaiStart: data['fssaiStartDate'] ?? '',
// // // // // // //       fssaiEnd: data['fssaiEndDate'] ?? '',
// // // // // // //       fssaiFile: null,
// // // // // // //       tradeLicenseNo: data['tradeLicenseNumber'] ?? '',
// // // // // // //       tradeStart: data['tradeLicenseStartDate'] ?? '',
// // // // // // //       tradeEnd: data['tradeLicenseEndDate'] ?? '',
// // // // // // //       tradeLicenseFile: null,
// // // // // // //       labourLicenseNo: data['labourLicenseNumber'] ?? '',
// // // // // // //       labourStart: data['labourStartDate'] ?? '',
// // // // // // //       labourEnd: data['labourEndDate'] ?? '',
// // // // // // //       labourFile: null,
// // // // // // //
// // // // // // //       // Bank - Using correct field names
// // // // // // //       bankName: data['bankName'] ?? data['branchName'] ?? '',
// // // // // // //       ifsc: data['ifscCode'] ?? '',
// // // // // // //       accountNumber: data['accountNumber']?.toString() ?? '',
// // // // // // //       passbookFile: null,
// // // // // // //     );
// // // // // // //   }
// // // // // // // }
// // // // // // import 'dart:convert';
// // // // // // import 'dart:io';
// // // // // // import 'package:flutter/foundation.dart';
// // // // // // import 'package:http/http.dart' as http;
// // // // // // import 'package:http_parser/http_parser.dart';
// // // // // // import 'package:maamaaspartner/RegistrationScreen/models/vendor_form_data.dart';
// // // // // // import '../../API/Apiclient.dart';
// // // // // //
// // // // // // class VendorApiService {
// // // // // //   static const String _endpoint = 'api/vendors';
// // // // // //
// // // // // //   // ── Base URL for direct (no-auth) calls ─────────────────────────────────────
// // // // // //   // Same host as the Book-a-Demo enquiry URL already used in BookDemoScreen.
// // // // // //   static const String _foodBaseUrl = 'http://staging.maamaas.com:8080/food/';
// // // // // //
// // // // // //   // ── GET vendor ───────────────────────────────────────────────────────────────
// // // // // //   static Future<Map<String, dynamic>?> getVendor(String vendorId) async {
// // // // // //     try {
// // // // // //       final response = await ApiClient.get(
// // // // // //         '$_endpoint/$vendorId',
// // // // // //         service: 'food',
// // // // // //       );
// // // // // //       if (response.statusCode == 200) return jsonDecode(response.body);
// // // // // //       return null;
// // // // // //     } catch (e) {
// // // // // //       debugPrint('GET Vendor Error: $e');
// // // // // //       return null;
// // // // // //     }
// // // // // //   }
// // // // // //
// // // // // //   // ── GET vendor parsed to FormData (returning / logged-in vendors) ────────────
// // // // // //   static Future<VendorFormData?> getVendorFormData(String vendorId) async {
// // // // // //     try {
// // // // // //       final response = await ApiClient.get(
// // // // // //         '$_endpoint/$vendorId',
// // // // // //         service: 'food',
// // // // // //       );
// // // // // //       if (response.statusCode == 200) {
// // // // // //         final data = jsonDecode(response.body);
// // // // // //         return _parseVendorDataToFormData(data);
// // // // // //       }
// // // // // //       return null;
// // // // // //     } catch (e) {
// // // // // //       debugPrint('GET VendorFormData Error: $e');
// // // // // //       return null;
// // // // // //     }
// // // // // //   }
// // // // // //
// // // // // //   // ── AUTHENTICATED registration (logged-in vendor, token present) ─────────────
// // // // // //   static Future<bool> registerVendor(
// // // // // //     String vendorId,
// // // // // //     VendorFormData formData,
// // // // // //   ) async {
// // // // // //     try {
// // // // // //       final response = await ApiClient.sendMultipartRequest(
// // // // // //         endpoint: '$_endpoint/$vendorId',
// // // // // //         method: 'POST',
// // // // // //         service: 'food',
// // // // // //         data: {'vendorData': jsonEncode(_buildVendorJson(vendorId, formData))},
// // // // // //         files: _buildFileMap(formData),
// // // // // //       );
// // // // // //       debugPrint('registerVendor → ${response.statusCode}: ${response.body}');
// // // // // //       return response.statusCode == 200 || response.statusCode == 201;
// // // // // //     } catch (e) {
// // // // // //       debugPrint('registerVendor Error: $e');
// // // // // //       return false;
// // // // // //     }
// // // // // //   }
// // // // // //
// // // // // //   // ── PUBLIC registration (new vendor from Book-a-Demo — NO auth token) ────────
// // // // // //   //
// // // // // //   // The Book-a-Demo enquiry API returns only a vendorId, never a JWT.
// // // // // //   // ApiClient.sendMultipartRequest() throws "Authentication token not found"
// // // // // //   // when there is no token in SharedPreferences.
// // // // // //   //
// // // // // //   // This method uses a plain http.MultipartRequest so it bypasses ApiClient's
// // // // // //   // token guard entirely.  Use this from PreviewStep for isNewVendor == true.
// // // // // //   static Future<PublicRegisterResult> registerVendorPublic(
// // // // // //     String vendorId,
// // // // // //     VendorFormData formData,
// // // // // //   ) async {
// // // // // //     try {
// // // // // //       final uri = Uri.parse('$_foodBaseUrl$_endpoint/$vendorId');
// // // // // //       final request = http.MultipartRequest('POST', uri)
// // // // // //         ..headers['Accept'] = 'application/json';
// // // // // //
// // // // // //       // JSON payload
// // // // // //       request.fields['vendorData'] = jsonEncode(
// // // // // //         _buildVendorJson(vendorId, formData),
// // // // // //       );
// // // // // //
// // // // // //       // File attachments — must declare contentType explicitly.
// // // // // //       // Sending application/octet-stream causes a 500 on the server.
// // // // // //       for (final entry in _buildFileMap(formData).entries) {
// // // // // //         final mimeType = _mimeTypeForFile(entry.value);
// // // // // //         request.files.add(
// // // // // //           await http.MultipartFile.fromPath(
// // // // // //             entry.key,
// // // // // //             entry.value.path,
// // // // // //             contentType: MediaType.parse(mimeType),
// // // // // //           ),
// // // // // //         );
// // // // // //       }
// // // // // //
// // // // // //       debugPrint('📤 registerVendorPublic → POST $uri');
// // // // // //
// // // // // //       final streamed = await request.send().timeout(
// // // // // //         const Duration(seconds: 30),
// // // // // //         onTimeout: () => throw Exception('Request timed out'),
// // // // // //       );
// // // // // //       final response = await http.Response.fromStream(streamed);
// // // // // //
// // // // // //       debugPrint(
// // // // // //         '📨 registerVendorPublic ← ${response.statusCode}: ${response.body}',
// // // // // //       );
// // // // // //
// // // // // //       if (response.statusCode == 200 || response.statusCode == 201) {
// // // // // //         return PublicRegisterResult(success: true);
// // // // // //       }
// // // // // //
// // // // // //       // Parse server error message to show to the user
// // // // // //       String errorMessage = 'Registration failed (${response.statusCode})';
// // // // // //       try {
// // // // // //         final body = jsonDecode(response.body) as Map<String, dynamic>;
// // // // // //         errorMessage =
// // // // // //             (body['message'] ?? body['error'] ?? body['msg'] ?? errorMessage)
// // // // // //                 .toString();
// // // // // //       } catch (_) {
// // // // // //         if (response.body.isNotEmpty) errorMessage = response.body;
// // // // // //       }
// // // // // //
// // // // // //       return PublicRegisterResult(success: false, errorMessage: errorMessage);
// // // // // //     } catch (e) {
// // // // // //       debugPrint('registerVendorPublic Error: $e');
// // // // // //       return PublicRegisterResult(
// // // // // //         success: false,
// // // // // //         errorMessage: 'Network error: ${e.toString()}',
// // // // // //       );
// // // // // //     }
// // // // // //   }
// // // // // //
// // // // // //   // ── Shared helpers ────────────────────────────────────────────────────────────
// // // // // //
// // // // // //   static Map<String, dynamic> _buildVendorJson(
// // // // // //     String vendorId,
// // // // // //     VendorFormData f,
// // // // // //   ) => {
// // // // // //     'vendorId': int.tryParse(vendorId) ?? 0,
// // // // // //     'latitude': f.latitude ?? 0,
// // // // // //     'longitude': f.longitude ?? 0,
// // // // // //     'fullAddress': f.address,
// // // // // //     'addressLine': f.addressLine,
// // // // // //     'doorNumber': f.doorNumber,
// // // // // //     'landMark': f.landMark,
// // // // // //     'city': f.city,
// // // // // //     'state': f.state.isEmpty ? 'Telangana' : f.state,
// // // // // //     'pincode': int.tryParse(f.pincode) ?? 0,
// // // // // //     'companyName': f.companyName,
// // // // // //     'registeredName': f.companyName,
// // // // // //     'ownerName': f.companyName,
// // // // // //     'businessVertical': 'FOOD_AND_BEVERAGES',
// // // // // //     'position': f.position,
// // // // // //     'vendorType': f.verticalType.isNotEmpty ? f.verticalType : 'Restaurant',
// // // // // //     'holderName': f.contactName,
// // // // // //     'mobileNumber': f.phone,
// // // // // //     'email': f.email,
// // // // // //     'aadharNumber': f.aadhar,
// // // // // //     'panCardNumber': f.pan,
// // // // // //     'gstNumber': f.gst,
// // // // // //     'tradeLicenseNumber': f.tradeLicenseNo,
// // // // // //     'tradeLicenseStartDate': f.tradeStart,
// // // // // //     'tradeLicenseEndDate': f.tradeEnd,
// // // // // //     'fssaiLicenseNumber': f.fssaiNo,
// // // // // //     'fssaiStartDate': f.fssaiStart,
// // // // // //     'fssaiEndDate': f.fssaiEnd,
// // // // // //     'labourLicenseNumber': f.labourLicenseNo,
// // // // // //     'labourStartDate': f.labourStart,
// // // // // //     'labourEndDate': f.labourEnd,
// // // // // //     'accountNumber': f.accountNumber,
// // // // // //     'ifscCode': f.ifsc,
// // // // // //     'bankName': f.bankName,
// // // // // //     'branchName': f.bankName,
// // // // // //     'aadharNumberStatus': false,
// // // // // //     'panCardStatus': false,
// // // // // //     'gstNumberStatus': false,
// // // // // //     'tradeLicenseStatus': false,
// // // // // //     'labourLicenseStatus': false,
// // // // // //     'fssaiLicenseStatus': false,
// // // // // //     'online': false,
// // // // // //   };
// // // // // //
// // // // // //   static Map<String, File> _buildFileMap(VendorFormData f) => {
// // // // // //     if (f.aadharFile != null) 'aadharPhotoFront': f.aadharFile!,
// // // // // //     if (f.panFile != null) 'panCard': f.panFile!,
// // // // // //     if (f.passbookFile != null) 'passbook': f.passbookFile!,
// // // // // //     if (f.labourFile != null) 'labourLicense': f.labourFile!,
// // // // // //     if (f.fssaiFile != null) 'fssaiLicense': f.fssaiFile!,
// // // // // //     if (f.tradeLicenseFile != null) 'tradeLicense': f.tradeLicenseFile!,
// // // // // //     if (f.gstFile != null) 'gstFile': f.gstFile!,
// // // // // //   };
// // // // // //
// // // // // //   /// Returns the correct MIME type based on file extension.
// // // // // //   /// Falls back to image/jpeg for any image file the user picked from gallery,
// // // // // //   /// which is what the server actually expects for document uploads.
// // // // // //   static String _mimeTypeForFile(File file) {
// // // // // //     final ext = file.path.split('.').last.toLowerCase();
// // // // // //     switch (ext) {
// // // // // //       case 'jpg':
// // // // // //       case 'jpeg':
// // // // // //         return 'image/jpeg';
// // // // // //       case 'png':
// // // // // //         return 'image/png';
// // // // // //       case 'pdf':
// // // // // //         return 'application/pdf';
// // // // // //       case 'webp':
// // // // // //         return 'image/webp';
// // // // // //       case 'heic':
// // // // // //         return 'image/heic';
// // // // // //       default:
// // // // // //         // ImagePicker always returns jpg/png on Android — safe default
// // // // // //         return 'image/jpeg';
// // // // // //     }
// // // // // //   }
// // // // // //
// // // // // //   static VendorFormData _parseVendorDataToFormData(Map<String, dynamic> data) =>
// // // // // //       VendorFormData(
// // // // // //         companyName: data['registeredName'] ?? data['companyName'] ?? '',
// // // // // //         businessVertical:
// // // // // //             data['businessVertical']?.toLowerCase().replaceAll('_', ' ') ??
// // // // // //             'Food & Beverages',
// // // // // //         position: data['position'] ?? '',
// // // // // //         verticalType: data['vendorType'] ?? '',
// // // // // //         doorNumber: data['doorNumber'] ?? '',
// // // // // //         addressLine: data['addressLine'] ?? '',
// // // // // //         landMark: data['landMark'] ?? '',
// // // // // //         city: data['city'] ?? '',
// // // // // //         state: data['state'] ?? '',
// // // // // //         pincode: data['pincode']?.toString() ?? '',
// // // // // //         latitude: data['latitude']?.toDouble(),
// // // // // //         longitude: data['longitude']?.toDouble(),
// // // // // //         address: data['fullAddress'] ?? '',
// // // // // //         contactName: data['holderName'] ?? '',
// // // // // //         phone: data['mobileNumber']?.toString() ?? '',
// // // // // //         email: data['email'] ?? '',
// // // // // //         aadhar: data['aadharNumber']?.toString() ?? '',
// // // // // //         aadharFile: null,
// // // // // //         gst: data['gstNumber'] ?? '',
// // // // // //         gstFile: null,
// // // // // //         pan: data['panCardNumber'] ?? '',
// // // // // //         panFile: null,
// // // // // //         fssaiNo: data['fssaiLicenseNumber'] ?? '',
// // // // // //         fssaiStart: data['fssaiStartDate'] ?? '',
// // // // // //         fssaiEnd: data['fssaiEndDate'] ?? '',
// // // // // //         fssaiFile: null,
// // // // // //         tradeLicenseNo: data['tradeLicenseNumber'] ?? '',
// // // // // //         tradeStart: data['tradeLicenseStartDate'] ?? '',
// // // // // //         tradeEnd: data['tradeLicenseEndDate'] ?? '',
// // // // // //         tradeLicenseFile: null,
// // // // // //         labourLicenseNo: data['labourLicenseNumber'] ?? '',
// // // // // //         labourStart: data['labourStartDate'] ?? '',
// // // // // //         labourEnd: data['labourEndDate'] ?? '',
// // // // // //         labourFile: null,
// // // // // //         bankName: data['bankName'] ?? data['branchName'] ?? '',
// // // // // //         ifsc: data['ifscCode'] ?? '',
// // // // // //         accountNumber: data['accountNumber']?.toString() ?? '',
// // // // // //         passbookFile: null,
// // // // // //       );
// // // // // // }
// // // // // //
// // // // // // // Result wrapper for public registration
// // // // // // class PublicRegisterResult {
// // // // // //   final bool success;
// // // // // //   final String? errorMessage;
// // // // // //   const PublicRegisterResult({required this.success, this.errorMessage});
// // // // // // }
// // // // // // // // import 'dart:convert';
// // // // // // // // import '../../API/Apiclient.dart';
// // // // // // // // import '../models/vendor_form_data.dart';
// // // // // // // //
// // // // // // // // class VendorApiService {
// // // // // // // //   /// 🔹 GET Vendor Details
// // // // // // // //   static Future<Map<String, dynamic>?> getVendor(String vendorId) async {
// // // // // // // //     try {
// // // // // // // //       final response = await ApiClient.get(
// // // // // // // //         'api/vendors/$vendorId',
// // // // // // // //         service: 'food',
// // // // // // // //       );
// // // // // // // //
// // // // // // // //       if (response.statusCode == 200) {
// // // // // // // //         return jsonDecode(response.body) as Map<String, dynamic>;
// // // // // // // //       }
// // // // // // // //
// // // // // // // //       return null;
// // // // // // // //     } catch (e) {
// // // // // // // //       print('❌ GET Vendor Error: $e');
// // // // // // // //       return null;
// // // // // // // //     }
// // // // // // // //   }
// // // // // // // //
// // // // // // // //   /// 🔹 REGISTER / UPDATE Vendor (Multipart)
// // // // // // // //   static Future<bool> registerVendor(
// // // // // // // //     String vendorId,
// // // // // // // //     VendorFormData formData,
// // // // // // // //   ) async {
// // // // // // // //     try {
// // // // // // // //       /// 🔥 Prepare JSON payload
// // // // // // // //       final vendorDataJson = {
// // // // // // // //         'vendorId': int.tryParse(vendorId) ?? 0,
// // // // // // // //         'latitude': formData.latitude ?? 0,
// // // // // // // //         'longitude': formData.longitude ?? 0,
// // // // // // // //         'fullAddress': formData.address,
// // // // // // // //         'addressLine': formData.addressLine,
// // // // // // // //         'doorNumber': formData.doorNumber,
// // // // // // // //         'landMark': formData.landMark,
// // // // // // // //         'city': formData.city,
// // // // // // // //         'state': formData.state.isEmpty ? 'Telangana' : formData.state,
// // // // // // // //         'pincode': int.tryParse(formData.pincode) ?? 0,
// // // // // // // //
// // // // // // // //         // Company Info
// // // // // // // //         'companyName': formData.companyName,
// // // // // // // //         'registeredName': formData.companyName,
// // // // // // // //         'ownerName': formData.companyName,
// // // // // // // //         'businessVertical': 'FOOD_AND_BEVERAGES',
// // // // // // // //         'position': formData.position,
// // // // // // // //         'vendorType': formData.verticalType.isNotEmpty
// // // // // // // //             ? formData.verticalType
// // // // // // // //             : 'Restaurant',
// // // // // // // //
// // // // // // // //         // Contact Info
// // // // // // // //         'holderName': formData.contactName,
// // // // // // // //         'mobileNumber': formData.phone,
// // // // // // // //         'email': formData.email,
// // // // // // // //
// // // // // // // //         // Documents
// // // // // // // //         'aadharNumber': formData.aadhar,
// // // // // // // //         'panCardNumber': formData.pan,
// // // // // // // //         'gstNumber': formData.gst,
// // // // // // // //
// // // // // // // //         // Trade License
// // // // // // // //         'tradeLicenseNumber': formData.tradeLicenseNo,
// // // // // // // //         'tradeLicenseStartDate': formData.tradeStart,
// // // // // // // //         'tradeLicenseEndDate': formData.tradeEnd,
// // // // // // // //
// // // // // // // //         // FSSAI
// // // // // // // //         'fssaiLicenseNumber': formData.fssaiNo,
// // // // // // // //         'fssaiStartDate': formData.fssaiStart,
// // // // // // // //         'fssaiEndDate': formData.fssaiEnd,
// // // // // // // //
// // // // // // // //         // Labour License
// // // // // // // //         'labourLicenseNumber': formData.labourLicenseNo,
// // // // // // // //         'labourStartDate': formData.labourStart,
// // // // // // // //         'labourEndDate': formData.labourEnd,
// // // // // // // //
// // // // // // // //         // Bank Details
// // // // // // // //         'accountNumber': formData.accountNumber,
// // // // // // // //         'ifscCode': formData.ifsc,
// // // // // // // //         'bankName': formData.bankName,
// // // // // // // //         'branchName': formData.bankName,
// // // // // // // //
// // // // // // // //         // Status Flags
// // // // // // // //         'aadharNumberStatus': false,
// // // // // // // //         'panCardStatus': false,
// // // // // // // //         'gstNumberStatus': false,
// // // // // // // //         'tradeLicenseStatus': false,
// // // // // // // //         'labourLicenseStatus': false,
// // // // // // // //         'fssaiLicenseStatus': false,
// // // // // // // //
// // // // // // // //         'online': false,
// // // // // // // //       };
// // // // // // // //
// // // // // // // //       /// 🔥 Call centralized API client
// // // // // // // //       final response = await ApiClient.sendMultipartRequest(
// // // // // // // //         endpoint: 'api/vendors/$vendorId',
// // // // // // // //         method: 'POST',
// // // // // // // //         service: 'food',
// // // // // // // //
// // // // // // // //         /// IMPORTANT: send JSON as string
// // // // // // // //         data: {'vendorData': jsonEncode(vendorDataJson)},
// // // // // // // //
// // // // // // // //         /// Attach files safely
// // // // // // // //         files: {
// // // // // // // //           if (formData.aadharFile != null)
// // // // // // // //             'aadharPhotoFront': formData.aadharFile!,
// // // // // // // //           if (formData.panFile != null) 'panCard': formData.panFile!,
// // // // // // // //           if (formData.passbookFile != null) 'passbook': formData.passbookFile!,
// // // // // // // //           if (formData.labourFile != null)
// // // // // // // //             'labourLicense': formData.labourFile!,
// // // // // // // //           if (formData.fssaiFile != null) 'fssaiLicense': formData.fssaiFile!,
// // // // // // // //           if (formData.tradeLicenseFile != null)
// // // // // // // //             'tradeLicense': formData.tradeLicenseFile!,
// // // // // // // //           if (formData.gstFile != null) 'gstFile': formData.gstFile!,
// // // // // // // //         },
// // // // // // // //       );
// // // // // // // //
// // // // // // // //       if (response.statusCode == 200 || response.statusCode == 201) {
// // // // // // // //         print('✅ Vendor registered successfully');
// // // // // // // //         return true;
// // // // // // // //       } else {
// // // // // // // //         print('❌ Vendor registration failed: ${response.statusCode}');
// // // // // // // //         print('📦 Response: ${response.body}');
// // // // // // // //         return false;
// // // // // // // //       }
// // // // // // // //     } catch (e) {
// // // // // // // //       print('❌ POST Vendor Error: $e');
// // // // // // // //       return false;
// // // // // // // //     }
// // // // // // // //   }
// // // // // // // // }
// // // // // // // import 'dart:convert';
// // // // // // //
// // // // // // // import 'package:maamaaspartner/RegistrationScreen/models/vendor_form_data.dart';
// // // // // // //
// // // // // // // import '../../API/Apiclient.dart';
// // // // // // //
// // // // // // // class VendorApiService {
// // // // // // //   static const String _endpoint = 'api/vendors';
// // // // // // //
// // // // // // //   // GET vendor
// // // // // // //   static Future<Map<String, dynamic>?> getVendor(String vendorId) async {
// // // // // // //     try {
// // // // // // //       final response = await ApiClient.get(
// // // // // // //         '$_endpoint/$vendorId',
// // // // // // //         service: 'food',
// // // // // // //       );
// // // // // // //
// // // // // // //       if (response.statusCode == 200) {
// // // // // // //         return jsonDecode(response.body);
// // // // // // //       }
// // // // // // //
// // // // // // //       return null;
// // // // // // //     } catch (e) {
// // // // // // //       print('GET Error: $e');
// // // // // // //       return null;
// // // // // // //     }
// // // // // // //   }
// // // // // // //
// // // // // // //   // POST vendor (multipart via ApiClient)
// // // // // // //   static Future<bool> registerVendor(
// // // // // // //     String vendorId,
// // // // // // //     VendorFormData formData,
// // // // // // //   ) async {
// // // // // // //     try {
// // // // // // //       final vendorDataJson = {
// // // // // // //         'vendorId': int.tryParse(vendorId) ?? 0,
// // // // // // //         'latitude': formData.latitude ?? 0,
// // // // // // //         'longitude': formData.longitude ?? 0,
// // // // // // //         'fullAddress': formData.address,
// // // // // // //         'addressLine': formData.addressLine,
// // // // // // //         'doorNumber': formData.doorNumber,
// // // // // // //         'landMark': formData.landMark,
// // // // // // //         'city': formData.city,
// // // // // // //         'state': formData.state.isEmpty ? 'Telangana' : formData.state,
// // // // // // //         'pincode': int.tryParse(formData.pincode) ?? 0,
// // // // // // //         'companyName': formData.companyName,
// // // // // // //         'registeredName': formData.companyName,
// // // // // // //         'ownerName': formData.companyName,
// // // // // // //         'businessVertical': 'FOOD_AND_BEVERAGES',
// // // // // // //         'position': formData.position,
// // // // // // //         'vendorType': formData.verticalType.isNotEmpty
// // // // // // //             ? formData.verticalType
// // // // // // //             : 'Restaurant',
// // // // // // //         'holderName': formData.contactName,
// // // // // // //         'mobileNumber': formData.phone,
// // // // // // //         'email': formData.email,
// // // // // // //         'aadharNumber': formData.aadhar,
// // // // // // //         'panCardNumber': formData.pan,
// // // // // // //         'gstNumber': formData.gst,
// // // // // // //         'tradeLicenseNumber': formData.tradeLicenseNo,
// // // // // // //         'tradeLicenseStartDate': formData.tradeStart,
// // // // // // //         'tradeLicenseEndDate': formData.tradeEnd,
// // // // // // //         'fssaiLicenseNumber': formData.fssaiNo,
// // // // // // //         'fssaiStartDate': formData.fssaiStart,
// // // // // // //         'fssaiEndDate': formData.fssaiEnd,
// // // // // // //         'labourLicenseNumber': formData.labourLicenseNo,
// // // // // // //         'labourStartDate': formData.labourStart,
// // // // // // //         'labourEndDate': formData.labourEnd,
// // // // // // //         'accountNumber': formData.accountNumber,
// // // // // // //         'ifscCode': formData.ifsc,
// // // // // // //         'bankName': formData.bankName,
// // // // // // //         'branchName': formData.bankName,
// // // // // // //         'aadharNumberStatus': false,
// // // // // // //         'panCardStatus': false,
// // // // // // //         'gstNumberStatus': false,
// // // // // // //         'tradeLicenseStatus': false,
// // // // // // //         'labourLicenseStatus': false,
// // // // // // //         'fssaiLicenseStatus': false,
// // // // // // //         'online': false,
// // // // // // //       };
// // // // // // //
// // // // // // //       final response = await ApiClient.sendMultipartRequest(
// // // // // // //         endpoint: '$_endpoint/$vendorId',
// // // // // // //         method: 'POST',
// // // // // // //         service: 'food',
// // // // // // //         data: {
// // // // // // //           // 🔥 Important: send JSON as STRING
// // // // // // //           'vendorData': jsonEncode(vendorDataJson),
// // // // // // //         },
// // // // // // //         files: {
// // // // // // //           if (formData.aadharFile != null)
// // // // // // //             'aadharPhotoFront': formData.aadharFile!,
// // // // // // //           if (formData.panFile != null) 'panCard': formData.panFile!,
// // // // // // //           if (formData.passbookFile != null) 'passbook': formData.passbookFile!,
// // // // // // //           if (formData.labourFile != null)
// // // // // // //             'labourLicense': formData.labourFile!,
// // // // // // //           if (formData.fssaiFile != null) 'fssaiLicense': formData.fssaiFile!,
// // // // // // //           if (formData.tradeLicenseFile != null)
// // // // // // //             'tradeLicense': formData.tradeLicenseFile!,
// // // // // // //           if (formData.gstFile != null) 'gstFile': formData.gstFile!,
// // // // // // //         },
// // // // // // //       );
// // // // // // //
// // // // // // //       return response.statusCode == 200 || response.statusCode == 201;
// // // // // // //     } catch (e) {
// // // // // // //       print('POST Error: $e');
// // // // // // //       return false;
// // // // // // //     }
// // // // // // //   }
// // // // // // //
// // // // // // //   // vendor_api_service.dart - Add this method
// // // // // // //   static Future<VendorFormData?> getVendorFormData(String vendorId) async {
// // // // // // //     try {
// // // // // // //       final response = await ApiClient.get(
// // // // // // //         '$_endpoint/$vendorId',
// // // // // // //         service: 'food',
// // // // // // //       );
// // // // // // //
// // // // // // //       if (response.statusCode == 200) {
// // // // // // //         final data = jsonDecode(response.body);
// // // // // // //         return _parseVendorDataToFormData(data);
// // // // // // //       }
// // // // // // //       return null;
// // // // // // //     } catch (e) {
// // // // // // //       print('GET Error: $e');
// // // // // // //       return null;
// // // // // // //     }
// // // // // // //   }
// // // // // // //
// // // // // // //   // Helper method to parse API response to VendorFormData
// // // // // // //   static VendorFormData _parseVendorDataToFormData(Map<String, dynamic> data) {
// // // // // // //     return VendorFormData(
// // // // // // //       // Company Details
// // // // // // //       companyName: data['registeredName'] ?? '',
// // // // // // //       businessVertical: 'Food & Beverages',
// // // // // // //       position: data['position'] ?? '',
// // // // // // //       verticalType: data['vendorType'] ?? '',
// // // // // // //
// // // // // // //       // Address
// // // // // // //       doorNumber: data['doorNumber'] ?? '',
// // // // // // //       addressLine: data['addressLine'] ?? '',
// // // // // // //       landMark: data['landMark'] ?? '',
// // // // // // //       city: data['city'] ?? '',
// // // // // // //       state: data['state'] ?? '',
// // // // // // //       pincode: data['pincode']?.toString() ?? '',
// // // // // // //       latitude: data['latitude']?.toDouble(),
// // // // // // //       longitude: data['longitude']?.toDouble(),
// // // // // // //       address: data['fullAddress'] ?? '',
// // // // // // //
// // // // // // //       // Contact
// // // // // // //       contactName: data['holderName'] ?? '',
// // // // // // //       phone: data['mobileNumber'] ?? '',
// // // // // // //       email: data['email'] ?? '',
// // // // // // //       aadhar: data['aadharNumber'] ?? '',
// // // // // // //       aadharFile: null, // You'll need to download these if needed
// // // // // // //       // Documents
// // // // // // //       gst: data['gstNumber'] ?? '',
// // // // // // //       gstFile: null,
// // // // // // //       pan: data['panCardNumber'] ?? '',
// // // // // // //       panFile: null,
// // // // // // //       fssaiNo: data['fssaiLicenseNumber'] ?? '',
// // // // // // //       fssaiStart: data['fssaiStartDate'] ?? '',
// // // // // // //       fssaiEnd: data['fssaiEndDate'] ?? '',
// // // // // // //       fssaiFile: null,
// // // // // // //       tradeLicenseNo: data['tradeLicenseNumber'] ?? '',
// // // // // // //       tradeStart: data['tradeLicenseStartDate'] ?? '',
// // // // // // //       tradeEnd: data['tradeLicenseEndDate'] ?? '',
// // // // // // //       tradeLicenseFile: null,
// // // // // // //       labourLicenseNo: data['labourLicenseNumber'] ?? '',
// // // // // // //       labourStart: data['labourStartDate'] ?? '',
// // // // // // //       labourEnd: data['labourEndDate'] ?? '',
// // // // // // //       labourFile: null,
// // // // // // //
// // // // // // //       // Bank
// // // // // // //       bankName: data['bankName'] ?? data['branchName'] ?? '',
// // // // // // //       ifsc: data['ifscCode'] ?? '',
// // // // // // //       accountNumber: data['accountNumber'] ?? '',
// // // // // // //       passbookFile: null,
// // // // // // //     );
// // // // // // //   }
// // // // // // // }
// // // // // // import 'dart:convert';
// // // // // // import 'package:maamaaspartner/RegistrationScreen/models/vendor_form_data.dart';
// // // // // // import '../../API/Apiclient.dart';
// // // // // //
// // // // // // class VendorApiService {
// // // // // //   static const String _endpoint = 'api/vendors';
// // // // // //
// // // // // //   // GET vendor
// // // // // //   static Future<Map<String, dynamic>?> getVendor(String vendorId) async {
// // // // // //     try {
// // // // // //       final response = await ApiClient.get(
// // // // // //         '$_endpoint/$vendorId',
// // // // // //         service: 'food',
// // // // // //       );
// // // // // //
// // // // // //       if (response.statusCode == 200) {
// // // // // //         return jsonDecode(response.body);
// // // // // //       }
// // // // // //       return null;
// // // // // //     } catch (e) {
// // // // // //       print('GET Error: $e');
// // // // // //       return null;
// // // // // //     }
// // // // // //   }
// // // // // //
// // // // // //   // POST vendor (multipart via ApiClient)
// // // // // //   static Future<bool> registerVendor(
// // // // // //     String vendorId,
// // // // // //     VendorFormData formData,
// // // // // //   ) async {
// // // // // //     try {
// // // // // //       final vendorDataJson = {
// // // // // //         'vendorId': int.tryParse(vendorId) ?? 0,
// // // // // //         'latitude': formData.latitude ?? 0,
// // // // // //         'longitude': formData.longitude ?? 0,
// // // // // //         'fullAddress': formData.address,
// // // // // //         'addressLine': formData.addressLine,
// // // // // //         'doorNumber': formData.doorNumber,
// // // // // //         'landMark': formData.landMark,
// // // // // //         'city': formData.city,
// // // // // //         'state': formData.state.isEmpty ? 'Telangana' : formData.state,
// // // // // //         'pincode': int.tryParse(formData.pincode) ?? 0,
// // // // // //         'companyName': formData.companyName,
// // // // // //         'registeredName': formData.companyName,
// // // // // //         'ownerName': formData.companyName,
// // // // // //         'businessVertical': 'FOOD_AND_BEVERAGES',
// // // // // //         'position': formData.position,
// // // // // //         'vendorType': formData.verticalType.isNotEmpty
// // // // // //             ? formData.verticalType
// // // // // //             : 'Restaurant',
// // // // // //         'holderName': formData.contactName,
// // // // // //         'mobileNumber': formData.phone,
// // // // // //         'email': formData.email,
// // // // // //         'aadharNumber': formData.aadhar,
// // // // // //         'panCardNumber': formData.pan,
// // // // // //         'gstNumber': formData.gst,
// // // // // //         'tradeLicenseNumber': formData.tradeLicenseNo,
// // // // // //         'tradeLicenseStartDate': formData.tradeStart,
// // // // // //         'tradeLicenseEndDate': formData.tradeEnd,
// // // // // //         'fssaiLicenseNumber': formData.fssaiNo,
// // // // // //         'fssaiStartDate': formData.fssaiStart,
// // // // // //         'fssaiEndDate': formData.fssaiEnd,
// // // // // //         'labourLicenseNumber': formData.labourLicenseNo,
// // // // // //         'labourStartDate': formData.labourStart,
// // // // // //         'labourEndDate': formData.labourEnd,
// // // // // //         'accountNumber': formData.accountNumber,
// // // // // //         'ifscCode': formData.ifsc,
// // // // // //         'bankName': formData.bankName,
// // // // // //         'branchName': formData.bankName,
// // // // // //         'aadharNumberStatus': false,
// // // // // //         'panCardStatus': false,
// // // // // //         'gstNumberStatus': false,
// // // // // //         'tradeLicenseStatus': false,
// // // // // //         'labourLicenseStatus': false,
// // // // // //         'fssaiLicenseStatus': false,
// // // // // //         'online': false,
// // // // // //       };
// // // // // //
// // // // // //       final response = await ApiClient.sendMultipartRequest(
// // // // // //         endpoint: '$_endpoint/$vendorId',
// // // // // //         method: 'POST',
// // // // // //         service: 'food',
// // // // // //         data: {'vendorData': jsonEncode(vendorDataJson)},
// // // // // //         files: {
// // // // // //           if (formData.aadharFile != null)
// // // // // //             'aadharPhotoFront': formData.aadharFile!,
// // // // // //           if (formData.panFile != null) 'panCard': formData.panFile!,
// // // // // //           if (formData.passbookFile != null) 'passbook': formData.passbookFile!,
// // // // // //           if (formData.labourFile != null)
// // // // // //             'labourLicense': formData.labourFile!,
// // // // // //           if (formData.fssaiFile != null) 'fssaiLicense': formData.fssaiFile!,
// // // // // //           if (formData.tradeLicenseFile != null)
// // // // // //             'tradeLicense': formData.tradeLicenseFile!,
// // // // // //           if (formData.gstFile != null) 'gstFile': formData.gstFile!,
// // // // // //         },
// // // // // //       );
// // // // // //
// // // // // //       return response.statusCode == 200 || response.statusCode == 201;
// // // // // //     } catch (e) {
// // // // // //       print('POST Error: $e');
// // // // // //       return false;
// // // // // //     }
// // // // // //   }
// // // // // //
// // // // // //   // GET vendor and parse to FormData
// // // // // //   static Future<VendorFormData?> getVendorFormData(String vendorId) async {
// // // // // //     try {
// // // // // //       final response = await ApiClient.get(
// // // // // //         '$_endpoint/$vendorId',
// // // // // //         service: 'food',
// // // // // //       );
// // // // // //
// // // // // //       if (response.statusCode == 200) {
// // // // // //         final data = jsonDecode(response.body);
// // // // // //         return _parseVendorDataToFormData(data);
// // // // // //       }
// // // // // //       return null;
// // // // // //     } catch (e) {
// // // // // //       print('GET Error: $e');
// // // // // //       return null;
// // // // // //     }
// // // // // //   }
// // // // // //
// // // // // //   // Helper method to parse API response to VendorFormData
// // // // // //   static VendorFormData _parseVendorDataToFormData(Map<String, dynamic> data) {
// // // // // //     return VendorFormData(
// // // // // //       // Company Details - Using correct field names from API response
// // // // // //       companyName: data['registeredName'] ?? data['companyName'] ?? '',
// // // // // //       businessVertical:
// // // // // //           data['businessVertical']?.toLowerCase().replaceAll('_', ' ') ??
// // // // // //           'Food & Beverages',
// // // // // //       position: data['position'] ?? '',
// // // // // //       verticalType: data['vendorType'] ?? '',
// // // // // //
// // // // // //       // Address - Using correct field names
// // // // // //       doorNumber: data['doorNumber'] ?? '',
// // // // // //       addressLine: data['addressLine'] ?? '',
// // // // // //       landMark: data['landMark'] ?? '',
// // // // // //       city: data['city'] ?? '',
// // // // // //       state: data['state'] ?? '',
// // // // // //       pincode: data['pincode']?.toString() ?? '',
// // // // // //       latitude: data['latitude']?.toDouble(),
// // // // // //       longitude: data['longitude']?.toDouble(),
// // // // // //       address: data['fullAddress'] ?? '',
// // // // // //
// // // // // //       // Contact - Using correct field names
// // // // // //       contactName: data['holderName'] ?? '',
// // // // // //       phone: data['mobileNumber']?.toString() ?? '',
// // // // // //       email: data['email'] ?? '',
// // // // // //       aadhar: data['aadharNumber']?.toString() ?? '',
// // // // // //       aadharFile: null, // Can't download file automatically
// // // // // //       // Documents - Using correct field names
// // // // // //       gst: data['gstNumber'] ?? '',
// // // // // //       gstFile: null,
// // // // // //       pan: data['panCardNumber'] ?? '',
// // // // // //       panFile: null,
// // // // // //       fssaiNo: data['fssaiLicenseNumber'] ?? '',
// // // // // //       fssaiStart: data['fssaiStartDate'] ?? '',
// // // // // //       fssaiEnd: data['fssaiEndDate'] ?? '',
// // // // // //       fssaiFile: null,
// // // // // //       tradeLicenseNo: data['tradeLicenseNumber'] ?? '',
// // // // // //       tradeStart: data['tradeLicenseStartDate'] ?? '',
// // // // // //       tradeEnd: data['tradeLicenseEndDate'] ?? '',
// // // // // //       tradeLicenseFile: null,
// // // // // //       labourLicenseNo: data['labourLicenseNumber'] ?? '',
// // // // // //       labourStart: data['labourStartDate'] ?? '',
// // // // // //       labourEnd: data['labourEndDate'] ?? '',
// // // // // //       labourFile: null,
// // // // // //
// // // // // //       // Bank - Using correct field names
// // // // // //       bankName: data['bankName'] ?? data['branchName'] ?? '',
// // // // // //       ifsc: data['ifscCode'] ?? '',
// // // // // //       accountNumber: data['accountNumber']?.toString() ?? '',
// // // // // //       passbookFile: null,
// // // // // //     );
// // // // // //   }
// // // // // // }
// // // // // import 'dart:convert';
// // // // // import 'dart:io';
// // // // // import 'package:flutter/foundation.dart';
// // // // // import 'package:http/http.dart' as http;
// // // // // import 'package:http_parser/http_parser.dart';
// // // // // import 'package:maamaaspartner/RegistrationScreen/models/vendor_form_data.dart';
// // // // // import '../../API/Apiclient.dart';
// // // // //
// // // // // class VendorApiService {
// // // // //   static const String _endpoint = 'api/vendors';
// // // // //
// // // // //   // ── Base URL for direct (no-auth) calls ─────────────────────────────────────
// // // // //   // Same host as the Book-a-Demo enquiry URL already used in BookDemoScreen.
// // // // //   static const String _foodBaseUrl = 'http://staging.maamaas.com:8080/food/';
// // // // //
// // // // //   // ── GET vendor ───────────────────────────────────────────────────────────────
// // // // //   static Future<Map<String, dynamic>?> getVendor(String vendorId) async {
// // // // //     try {
// // // // //       final response = await ApiClient.get(
// // // // //         '$_endpoint/$vendorId',
// // // // //         service: 'food',
// // // // //       );
// // // // //       if (response.statusCode == 200) return jsonDecode(response.body);
// // // // //       return null;
// // // // //     } catch (e) {
// // // // //       debugPrint('GET Vendor Error: $e');
// // // // //       return null;
// // // // //     }
// // // // //   }
// // // // //
// // // // //   // ── GET vendor parsed to FormData (returning / logged-in vendors) ────────────
// // // // //   static Future<VendorFormData?> getVendorFormData(String vendorId) async {
// // // // //     try {
// // // // //       final response = await ApiClient.get(
// // // // //         '$_endpoint/$vendorId',
// // // // //         service: 'food',
// // // // //       );
// // // // //       if (response.statusCode == 200) {
// // // // //         final data = jsonDecode(response.body);
// // // // //         return _parseVendorDataToFormData(data);
// // // // //       }
// // // // //       return null;
// // // // //     } catch (e) {
// // // // //       debugPrint('GET VendorFormData Error: $e');
// // // // //       return null;
// // // // //     }
// // // // //   }
// // // // //
// // // // //   // ── AUTHENTICATED registration (logged-in vendor, token present) ─────────────
// // // // //   static Future<bool> registerVendor(
// // // // //     String vendorId,
// // // // //     VendorFormData formData,
// // // // //   ) async {
// // // // //     // ApiClient.sendMultipartRequest resolves MIME type via lookupMimeType(path),
// // // // //     // which returns null for Android image-picker cache files that have no
// // // // //     // extension (e.g. /data/user/0/.../cache/picker_12345).  The ApiClient
// // // // //     // fallback is `application/octet-stream`, which the server rejects (500).
// // // // //     //
// // // // //     // Fix: copy each file to a temp path with the correct extension so that
// // // // //     // lookupMimeType always finds a match.  The copies are deleted in `finally`.
// // // // //     final normalised = await _normaliseFileExtensions(_buildFileMap(formData));
// // // // //     try {
// // // // //       final response = await ApiClient.sendMultipartRequest(
// // // // //         endpoint: '$_endpoint/$vendorId',
// // // // //         method: 'POST',
// // // // //         service: 'food',
// // // // //         data: {'vendorData': jsonEncode(_buildVendorJson(vendorId, formData))},
// // // // //         files: normalised,
// // // // //       );
// // // // //       debugPrint('registerVendor → ${response.statusCode}: ${response.body}');
// // // // //       return response.statusCode == 200 || response.statusCode == 201;
// // // // //     } catch (e) {
// // // // //       debugPrint('registerVendor Error: $e');
// // // // //       return false;
// // // // //     } finally {
// // // // //       _deleteTempFiles(normalised);
// // // // //     }
// // // // //   }
// // // // //
// // // // //   // ── PUBLIC registration (new vendor from Book-a-Demo — NO auth token) ────────
// // // // //   //
// // // // //   // The Book-a-Demo enquiry API returns only a vendorId, never a JWT.
// // // // //   // ApiClient.sendMultipartRequest() throws "Authentication token not found"
// // // // //   // when there is no token in SharedPreferences.
// // // // //   //
// // // // //   // This method uses a plain http.MultipartRequest so it bypasses ApiClient's
// // // // //   // token guard entirely.  Use this from PreviewStep for isNewVendor == true.
// // // // //   static Future<PublicRegisterResult> registerVendorPublic(
// // // // //     String vendorId,
// // // // //     VendorFormData formData,
// // // // //   ) async {
// // // // //     try {
// // // // //       final uri = Uri.parse('$_foodBaseUrl$_endpoint/$vendorId');
// // // // //       final request = http.MultipartRequest('POST', uri)
// // // // //         ..headers['Accept'] = 'application/json';
// // // // //
// // // // //       // JSON payload
// // // // //       request.fields['vendorData'] = jsonEncode(
// // // // //         _buildVendorJson(vendorId, formData),
// // // // //       );
// // // // //
// // // // //       // File attachments — must declare contentType explicitly.
// // // // //       // Sending application/octet-stream causes a 500 on the server.
// // // // //       for (final entry in _buildFileMap(formData).entries) {
// // // // //         final mimeType = _mimeTypeForFile(entry.value);
// // // // //         request.files.add(
// // // // //           await http.MultipartFile.fromPath(
// // // // //             entry.key,
// // // // //             entry.value.path,
// // // // //             contentType: MediaType.parse(mimeType),
// // // // //           ),
// // // // //         );
// // // // //       }
// // // // //
// // // // //       debugPrint('📤 registerVendorPublic → POST $uri');
// // // // //
// // // // //       final streamed = await request.send().timeout(
// // // // //         const Duration(seconds: 30),
// // // // //         onTimeout: () => throw Exception('Request timed out'),
// // // // //       );
// // // // //       final response = await http.Response.fromStream(streamed);
// // // // //
// // // // //       debugPrint(
// // // // //         '📨 registerVendorPublic ← ${response.statusCode}: ${response.body}',
// // // // //       );
// // // // //
// // // // //       if (response.statusCode == 200 || response.statusCode == 201) {
// // // // //         return PublicRegisterResult(success: true);
// // // // //       }
// // // // //
// // // // //       // Parse server error message to show to the user
// // // // //       String errorMessage = 'Registration failed (${response.statusCode})';
// // // // //       try {
// // // // //         final body = jsonDecode(response.body) as Map<String, dynamic>;
// // // // //         errorMessage =
// // // // //             (body['message'] ?? body['error'] ?? body['msg'] ?? errorMessage)
// // // // //                 .toString();
// // // // //       } catch (_) {
// // // // //         if (response.body.isNotEmpty) errorMessage = response.body;
// // // // //       }
// // // // //
// // // // //       return PublicRegisterResult(success: false, errorMessage: errorMessage);
// // // // //     } catch (e) {
// // // // //       debugPrint('registerVendorPublic Error: $e');
// // // // //       return PublicRegisterResult(
// // // // //         success: false,
// // // // //         errorMessage: 'Network error: ${e.toString()}',
// // // // //       );
// // // // //     }
// // // // //   }
// // // // //
// // // // //   // ── Shared helpers ────────────────────────────────────────────────────────────
// // // // //
// // // // //   static Map<String, dynamic> _buildVendorJson(
// // // // //     String vendorId,
// // // // //     VendorFormData f,
// // // // //   ) => {
// // // // //     'vendorId': int.tryParse(vendorId) ?? 0,
// // // // //     'latitude': f.latitude ?? 0,
// // // // //     'longitude': f.longitude ?? 0,
// // // // //     'fullAddress': f.address,
// // // // //     'addressLine': f.addressLine,
// // // // //     'doorNumber': f.doorNumber,
// // // // //     'landMark': f.landMark,
// // // // //     'city': f.city,
// // // // //     'state': f.state.isEmpty ? 'Telangana' : f.state,
// // // // //     'pincode': int.tryParse(f.pincode) ?? 0,
// // // // //     'companyName': f.companyName,
// // // // //     'registeredName': f.companyName,
// // // // //     'ownerName': f.companyName,
// // // // //     'businessVertical': 'FOOD_AND_BEVERAGES',
// // // // //     'position': f.position,
// // // // //     'vendorType': f.verticalType.isNotEmpty ? f.verticalType : 'Restaurant',
// // // // //     'holderName': f.contactName,
// // // // //     'mobileNumber': f.phone,
// // // // //     'email': f.email,
// // // // //     'aadharNumber': f.aadhar,
// // // // //     'panCardNumber': f.pan,
// // // // //     'gstNumber': f.gst,
// // // // //     'tradeLicenseNumber': f.tradeLicenseNo,
// // // // //     'tradeLicenseStartDate': f.tradeStart,
// // // // //     'tradeLicenseEndDate': f.tradeEnd,
// // // // //     'fssaiLicenseNumber': f.fssaiNo,
// // // // //     'fssaiStartDate': f.fssaiStart,
// // // // //     'fssaiEndDate': f.fssaiEnd,
// // // // //     'labourLicenseNumber': f.labourLicenseNo,
// // // // //     'labourStartDate': f.labourStart,
// // // // //     'labourEndDate': f.labourEnd,
// // // // //     'accountNumber': f.accountNumber,
// // // // //     'ifscCode': f.ifsc,
// // // // //     'bankName': f.bankName,
// // // // //     'branchName': f.bankName,
// // // // //     'aadharNumberStatus': false,
// // // // //     'panCardStatus': false,
// // // // //     'gstNumberStatus': false,
// // // // //     'tradeLicenseStatus': false,
// // // // //     'labourLicenseStatus': false,
// // // // //     'fssaiLicenseStatus': false,
// // // // //     'online': false,
// // // // //   };
// // // // //
// // // // //   static Map<String, File> _buildFileMap(VendorFormData f) => {
// // // // //     if (f.aadharFile != null) 'aadharPhotoFront': f.aadharFile!,
// // // // //     if (f.panFile != null) 'panCard': f.panFile!,
// // // // //     if (f.passbookFile != null) 'passbook': f.passbookFile!,
// // // // //     if (f.labourFile != null) 'labourLicense': f.labourFile!,
// // // // //     if (f.fssaiFile != null) 'fssaiLicense': f.fssaiFile!,
// // // // //     if (f.tradeLicenseFile != null) 'tradeLicense': f.tradeLicenseFile!,
// // // // //     if (f.gstFile != null) 'gstFile': f.gstFile!,
// // // // //   };
// // // // //
// // // // //   /// Returns the correct MIME type based on file extension.
// // // // //   /// Falls back to image/jpeg for any image file the user picked from gallery,
// // // // //   /// which is what the server actually expects for document uploads.
// // // // //   static String _mimeTypeForFile(File file) {
// // // // //     final ext = file.path.split('.').last.toLowerCase();
// // // // //     switch (ext) {
// // // // //       case 'jpg':
// // // // //       case 'jpeg':
// // // // //         return 'image/jpeg';
// // // // //       case 'png':
// // // // //         return 'image/png';
// // // // //       case 'pdf':
// // // // //         return 'application/pdf';
// // // // //       case 'webp':
// // // // //         return 'image/webp';
// // // // //       case 'heic':
// // // // //         return 'image/heic';
// // // // //       default:
// // // // //         // ImagePicker always returns jpg/png on Android — safe default
// // // // //         return 'image/jpeg';
// // // // //     }
// // // // //   }
// // // // //
// // // // //   /// Copies each file in [fileMap] to a temp path whose extension matches its
// // // // //   /// real MIME type (derived by [_mimeTypeForFile]).  This ensures that
// // // // //   /// `lookupMimeType` inside ApiClient always resolves to the correct type
// // // // //   /// and never falls back to `application/octet-stream`.
// // // // //   ///
// // // // //   /// Only files whose current path lacks the correct extension are copied;
// // // // //   /// files that already have the right extension are returned as-is so we
// // // // //   /// avoid unnecessary I/O.
// // // // //   static Future<Map<String, File>> _normaliseFileExtensions(
// // // // //     Map<String, File> fileMap,
// // // // //   ) async {
// // // // //     final result = <String, File>{};
// // // // //     for (final entry in fileMap.entries) {
// // // // //       final file = entry.value;
// // // // //       final mime = _mimeTypeForFile(file);
// // // // //
// // // // //       // Derive the expected extension from the MIME type.
// // // // //       final expectedExt =
// // // // //           const {
// // // // //             'image/jpeg': 'jpg',
// // // // //             'image/png': 'png',
// // // // //             'application/pdf': 'pdf',
// // // // //             'image/webp': 'webp',
// // // // //             'image/heic': 'heic',
// // // // //           }[mime] ??
// // // // //           'jpg';
// // // // //
// // // // //       final currentExt = file.path.contains('.')
// // // // //           ? file.path.split('.').last.toLowerCase()
// // // // //           : '';
// // // // //
// // // // //       if (currentExt == expectedExt ||
// // // // //           currentExt == 'jpeg' && expectedExt == 'jpg') {
// // // // //         // Extension is already correct — no copy needed.
// // // // //         result[entry.key] = file;
// // // // //       } else {
// // // // //         // Copy to a temp file with the right extension so lookupMimeType works.
// // // // //         final tmpDir = Directory.systemTemp;
// // // // //         final tmpPath =
// // // // //             '${tmpDir.path}/vendor_upload_${entry.key}_${DateTime.now().millisecondsSinceEpoch}.$expectedExt';
// // // // //         final tmpFile = await file.copy(tmpPath);
// // // // //         debugPrint(
// // // // //           '🔄 Normalised ${entry.key}: ${file.path} → $tmpPath ($mime)',
// // // // //         );
// // // // //         result[entry.key] = tmpFile;
// // // // //       }
// // // // //     }
// // // // //     return result;
// // // // //   }
// // // // //
// // // // //   /// Deletes any temp files that were created by [_normaliseFileExtensions].
// // // // //   /// Only removes files inside [Directory.systemTemp] to avoid touching
// // // // //   /// the original user-selected files.
// // // // //   static void _deleteTempFiles(Map<String, File> normalised) {
// // // // //     final tmpDir = Directory.systemTemp.path;
// // // // //     for (final file in normalised.values) {
// // // // //       if (file.path.startsWith(tmpDir)) {
// // // // //         try {
// // // // //           file.deleteSync();
// // // // //         } catch (_) {
// // // // //           // Best-effort cleanup — ignore errors.
// // // // //         }
// // // // //       }
// // // // //     }
// // // // //   }
// // // // //
// // // // //   static VendorFormData _parseVendorDataToFormData(Map<String, dynamic> data) =>
// // // // //       VendorFormData(
// // // // //         companyName: data['registeredName'] ?? data['companyName'] ?? '',
// // // // //         businessVertical:
// // // // //             data['businessVertical']?.toLowerCase().replaceAll('_', ' ') ??
// // // // //             'Food & Beverages',
// // // // //         position: data['position'] ?? '',
// // // // //         verticalType: data['vendorType'] ?? '',
// // // // //         doorNumber: data['doorNumber'] ?? '',
// // // // //         addressLine: data['addressLine'] ?? '',
// // // // //         landMark: data['landMark'] ?? '',
// // // // //         city: data['city'] ?? '',
// // // // //         state: data['state'] ?? '',
// // // // //         pincode: data['pincode']?.toString() ?? '',
// // // // //         latitude: data['latitude']?.toDouble(),
// // // // //         longitude: data['longitude']?.toDouble(),
// // // // //         address: data['fullAddress'] ?? '',
// // // // //         contactName: data['holderName'] ?? '',
// // // // //         phone: data['mobileNumber']?.toString() ?? '',
// // // // //         email: data['email'] ?? '',
// // // // //         aadhar: data['aadharNumber']?.toString() ?? '',
// // // // //         aadharFile: null,
// // // // //         gst: data['gstNumber'] ?? '',
// // // // //         gstFile: null,
// // // // //         pan: data['panCardNumber'] ?? '',
// // // // //         panFile: null,
// // // // //         fssaiNo: data['fssaiLicenseNumber'] ?? '',
// // // // //         fssaiStart: data['fssaiStartDate'] ?? '',
// // // // //         fssaiEnd: data['fssaiEndDate'] ?? '',
// // // // //         fssaiFile: null,
// // // // //         tradeLicenseNo: data['tradeLicenseNumber'] ?? '',
// // // // //         tradeStart: data['tradeLicenseStartDate'] ?? '',
// // // // //         tradeEnd: data['tradeLicenseEndDate'] ?? '',
// // // // //         tradeLicenseFile: null,
// // // // //         labourLicenseNo: data['labourLicenseNumber'] ?? '',
// // // // //         labourStart: data['labourStartDate'] ?? '',
// // // // //         labourEnd: data['labourEndDate'] ?? '',
// // // // //         labourFile: null,
// // // // //         bankName: data['bankName'] ?? data['branchName'] ?? '',
// // // // //         ifsc: data['ifscCode'] ?? '',
// // // // //         accountNumber: data['accountNumber']?.toString() ?? '',
// // // // //         passbookFile: null,
// // // // //       );
// // // // // }
// // // // //
// // // // // class PublicRegisterResult {
// // // // //   final bool success;
// // // // //   final String? errorMessage;
// // // // //   const PublicRegisterResult({required this.success, this.errorMessage});
// // // // // }
// // // // // // // import 'dart:convert';
// // // // // // // import '../../API/Apiclient.dart';
// // // // // // // import '../models/vendor_form_data.dart';
// // // // // // //
// // // // // // // class VendorApiService {
// // // // // // //   /// 🔹 GET Vendor Details
// // // // // // //   static Future<Map<String, dynamic>?> getVendor(String vendorId) async {
// // // // // // //     try {
// // // // // // //       final response = await ApiClient.get(
// // // // // // //         'api/vendors/$vendorId',
// // // // // // //         service: 'food',
// // // // // // //       );
// // // // // // //
// // // // // // //       if (response.statusCode == 200) {
// // // // // // //         return jsonDecode(response.body) as Map<String, dynamic>;
// // // // // // //       }
// // // // // // //
// // // // // // //       return null;
// // // // // // //     } catch (e) {
// // // // // // //       print('❌ GET Vendor Error: $e');
// // // // // // //       return null;
// // // // // // //     }
// // // // // // //   }
// // // // // // //
// // // // // // //   /// 🔹 REGISTER / UPDATE Vendor (Multipart)
// // // // // // //   static Future<bool> registerVendor(
// // // // // // //     String vendorId,
// // // // // // //     VendorFormData formData,
// // // // // // //   ) async {
// // // // // // //     try {
// // // // // // //       /// 🔥 Prepare JSON payload
// // // // // // //       final vendorDataJson = {
// // // // // // //         'vendorId': int.tryParse(vendorId) ?? 0,
// // // // // // //         'latitude': formData.latitude ?? 0,
// // // // // // //         'longitude': formData.longitude ?? 0,
// // // // // // //         'fullAddress': formData.address,
// // // // // // //         'addressLine': formData.addressLine,
// // // // // // //         'doorNumber': formData.doorNumber,
// // // // // // //         'landMark': formData.landMark,
// // // // // // //         'city': formData.city,
// // // // // // //         'state': formData.state.isEmpty ? 'Telangana' : formData.state,
// // // // // // //         'pincode': int.tryParse(formData.pincode) ?? 0,
// // // // // // //
// // // // // // //         // Company Info
// // // // // // //         'companyName': formData.companyName,
// // // // // // //         'registeredName': formData.companyName,
// // // // // // //         'ownerName': formData.companyName,
// // // // // // //         'businessVertical': 'FOOD_AND_BEVERAGES',
// // // // // // //         'position': formData.position,
// // // // // // //         'vendorType': formData.verticalType.isNotEmpty
// // // // // // //             ? formData.verticalType
// // // // // // //             : 'Restaurant',
// // // // // // //
// // // // // // //         // Contact Info
// // // // // // //         'holderName': formData.contactName,
// // // // // // //         'mobileNumber': formData.phone,
// // // // // // //         'email': formData.email,
// // // // // // //
// // // // // // //         // Documents
// // // // // // //         'aadharNumber': formData.aadhar,
// // // // // // //         'panCardNumber': formData.pan,
// // // // // // //         'gstNumber': formData.gst,
// // // // // // //
// // // // // // //         // Trade License
// // // // // // //         'tradeLicenseNumber': formData.tradeLicenseNo,
// // // // // // //         'tradeLicenseStartDate': formData.tradeStart,
// // // // // // //         'tradeLicenseEndDate': formData.tradeEnd,
// // // // // // //
// // // // // // //         // FSSAI
// // // // // // //         'fssaiLicenseNumber': formData.fssaiNo,
// // // // // // //         'fssaiStartDate': formData.fssaiStart,
// // // // // // //         'fssaiEndDate': formData.fssaiEnd,
// // // // // // //
// // // // // // //         // Labour License
// // // // // // //         'labourLicenseNumber': formData.labourLicenseNo,
// // // // // // //         'labourStartDate': formData.labourStart,
// // // // // // //         'labourEndDate': formData.labourEnd,
// // // // // // //
// // // // // // //         // Bank Details
// // // // // // //         'accountNumber': formData.accountNumber,
// // // // // // //         'ifscCode': formData.ifsc,
// // // // // // //         'bankName': formData.bankName,
// // // // // // //         'branchName': formData.bankName,
// // // // // // //
// // // // // // //         // Status Flags
// // // // // // //         'aadharNumberStatus': false,
// // // // // // //         'panCardStatus': false,
// // // // // // //         'gstNumberStatus': false,
// // // // // // //         'tradeLicenseStatus': false,
// // // // // // //         'labourLicenseStatus': false,
// // // // // // //         'fssaiLicenseStatus': false,
// // // // // // //
// // // // // // //         'online': false,
// // // // // // //       };
// // // // // // //
// // // // // // //       /// 🔥 Call centralized API client
// // // // // // //       final response = await ApiClient.sendMultipartRequest(
// // // // // // //         endpoint: 'api/vendors/$vendorId',
// // // // // // //         method: 'POST',
// // // // // // //         service: 'food',
// // // // // // //
// // // // // // //         /// IMPORTANT: send JSON as string
// // // // // // //         data: {'vendorData': jsonEncode(vendorDataJson)},
// // // // // // //
// // // // // // //         /// Attach files safely
// // // // // // //         files: {
// // // // // // //           if (formData.aadharFile != null)
// // // // // // //             'aadharPhotoFront': formData.aadharFile!,
// // // // // // //           if (formData.panFile != null) 'panCard': formData.panFile!,
// // // // // // //           if (formData.passbookFile != null) 'passbook': formData.passbookFile!,
// // // // // // //           if (formData.labourFile != null)
// // // // // // //             'labourLicense': formData.labourFile!,
// // // // // // //           if (formData.fssaiFile != null) 'fssaiLicense': formData.fssaiFile!,
// // // // // // //           if (formData.tradeLicenseFile != null)
// // // // // // //             'tradeLicense': formData.tradeLicenseFile!,
// // // // // // //           if (formData.gstFile != null) 'gstFile': formData.gstFile!,
// // // // // // //         },
// // // // // // //       );
// // // // // // //
// // // // // // //       if (response.statusCode == 200 || response.statusCode == 201) {
// // // // // // //         print('✅ Vendor registered successfully');
// // // // // // //         return true;
// // // // // // //       } else {
// // // // // // //         print('❌ Vendor registration failed: ${response.statusCode}');
// // // // // // //         print('📦 Response: ${response.body}');
// // // // // // //         return false;
// // // // // // //       }
// // // // // // //     } catch (e) {
// // // // // // //       print('❌ POST Vendor Error: $e');
// // // // // // //       return false;
// // // // // // //     }
// // // // // // //   }
// // // // // // // }
// // // // // // import 'dart:convert';
// // // // // //
// // // // // // import 'package:maamaaspartner/RegistrationScreen/models/vendor_form_data.dart';
// // // // // //
// // // // // // import '../../API/Apiclient.dart';
// // // // // //
// // // // // // class VendorApiService {
// // // // // //   static const String _endpoint = 'api/vendors';
// // // // // //
// // // // // //   // GET vendor
// // // // // //   static Future<Map<String, dynamic>?> getVendor(String vendorId) async {
// // // // // //     try {
// // // // // //       final response = await ApiClient.get(
// // // // // //         '$_endpoint/$vendorId',
// // // // // //         service: 'food',
// // // // // //       );
// // // // // //
// // // // // //       if (response.statusCode == 200) {
// // // // // //         return jsonDecode(response.body);
// // // // // //       }
// // // // // //
// // // // // //       return null;
// // // // // //     } catch (e) {
// // // // // //       print('GET Error: $e');
// // // // // //       return null;
// // // // // //     }
// // // // // //   }
// // // // // //
// // // // // //   // POST vendor (multipart via ApiClient)
// // // // // //   static Future<bool> registerVendor(
// // // // // //     String vendorId,
// // // // // //     VendorFormData formData,
// // // // // //   ) async {
// // // // // //     try {
// // // // // //       final vendorDataJson = {
// // // // // //         'vendorId': int.tryParse(vendorId) ?? 0,
// // // // // //         'latitude': formData.latitude ?? 0,
// // // // // //         'longitude': formData.longitude ?? 0,
// // // // // //         'fullAddress': formData.address,
// // // // // //         'addressLine': formData.addressLine,
// // // // // //         'doorNumber': formData.doorNumber,
// // // // // //         'landMark': formData.landMark,
// // // // // //         'city': formData.city,
// // // // // //         'state': formData.state.isEmpty ? 'Telangana' : formData.state,
// // // // // //         'pincode': int.tryParse(formData.pincode) ?? 0,
// // // // // //         'companyName': formData.companyName,
// // // // // //         'registeredName': formData.companyName,
// // // // // //         'ownerName': formData.companyName,
// // // // // //         'businessVertical': 'FOOD_AND_BEVERAGES',
// // // // // //         'position': formData.position,
// // // // // //         'vendorType': formData.verticalType.isNotEmpty
// // // // // //             ? formData.verticalType
// // // // // //             : 'Restaurant',
// // // // // //         'holderName': formData.contactName,
// // // // // //         'mobileNumber': formData.phone,
// // // // // //         'email': formData.email,
// // // // // //         'aadharNumber': formData.aadhar,
// // // // // //         'panCardNumber': formData.pan,
// // // // // //         'gstNumber': formData.gst,
// // // // // //         'tradeLicenseNumber': formData.tradeLicenseNo,
// // // // // //         'tradeLicenseStartDate': formData.tradeStart,
// // // // // //         'tradeLicenseEndDate': formData.tradeEnd,
// // // // // //         'fssaiLicenseNumber': formData.fssaiNo,
// // // // // //         'fssaiStartDate': formData.fssaiStart,
// // // // // //         'fssaiEndDate': formData.fssaiEnd,
// // // // // //         'labourLicenseNumber': formData.labourLicenseNo,
// // // // // //         'labourStartDate': formData.labourStart,
// // // // // //         'labourEndDate': formData.labourEnd,
// // // // // //         'accountNumber': formData.accountNumber,
// // // // // //         'ifscCode': formData.ifsc,
// // // // // //         'bankName': formData.bankName,
// // // // // //         'branchName': formData.bankName,
// // // // // //         'aadharNumberStatus': false,
// // // // // //         'panCardStatus': false,
// // // // // //         'gstNumberStatus': false,
// // // // // //         'tradeLicenseStatus': false,
// // // // // //         'labourLicenseStatus': false,
// // // // // //         'fssaiLicenseStatus': false,
// // // // // //         'online': false,
// // // // // //       };
// // // // // //
// // // // // //       final response = await ApiClient.sendMultipartRequest(
// // // // // //         endpoint: '$_endpoint/$vendorId',
// // // // // //         method: 'POST',
// // // // // //         service: 'food',
// // // // // //         data: {
// // // // // //           // 🔥 Important: send JSON as STRING
// // // // // //           'vendorData': jsonEncode(vendorDataJson),
// // // // // //         },
// // // // // //         files: {
// // // // // //           if (formData.aadharFile != null)
// // // // // //             'aadharPhotoFront': formData.aadharFile!,
// // // // // //           if (formData.panFile != null) 'panCard': formData.panFile!,
// // // // // //           if (formData.passbookFile != null) 'passbook': formData.passbookFile!,
// // // // // //           if (formData.labourFile != null)
// // // // // //             'labourLicense': formData.labourFile!,
// // // // // //           if (formData.fssaiFile != null) 'fssaiLicense': formData.fssaiFile!,
// // // // // //           if (formData.tradeLicenseFile != null)
// // // // // //             'tradeLicense': formData.tradeLicenseFile!,
// // // // // //           if (formData.gstFile != null) 'gstFile': formData.gstFile!,
// // // // // //         },
// // // // // //       );
// // // // // //
// // // // // //       return response.statusCode == 200 || response.statusCode == 201;
// // // // // //     } catch (e) {
// // // // // //       print('POST Error: $e');
// // // // // //       return false;
// // // // // //     }
// // // // // //   }
// // // // // //
// // // // // //   // vendor_api_service.dart - Add this method
// // // // // //   static Future<VendorFormData?> getVendorFormData(String vendorId) async {
// // // // // //     try {
// // // // // //       final response = await ApiClient.get(
// // // // // //         '$_endpoint/$vendorId',
// // // // // //         service: 'food',
// // // // // //       );
// // // // // //
// // // // // //       if (response.statusCode == 200) {
// // // // // //         final data = jsonDecode(response.body);
// // // // // //         return _parseVendorDataToFormData(data);
// // // // // //       }
// // // // // //       return null;
// // // // // //     } catch (e) {
// // // // // //       print('GET Error: $e');
// // // // // //       return null;
// // // // // //     }
// // // // // //   }
// // // // // //
// // // // // //   // Helper method to parse API response to VendorFormData
// // // // // //   static VendorFormData _parseVendorDataToFormData(Map<String, dynamic> data) {
// // // // // //     return VendorFormData(
// // // // // //       // Company Details
// // // // // //       companyName: data['registeredName'] ?? '',
// // // // // //       businessVertical: 'Food & Beverages',
// // // // // //       position: data['position'] ?? '',
// // // // // //       verticalType: data['vendorType'] ?? '',
// // // // // //
// // // // // //       // Address
// // // // // //       doorNumber: data['doorNumber'] ?? '',
// // // // // //       addressLine: data['addressLine'] ?? '',
// // // // // //       landMark: data['landMark'] ?? '',
// // // // // //       city: data['city'] ?? '',
// // // // // //       state: data['state'] ?? '',
// // // // // //       pincode: data['pincode']?.toString() ?? '',
// // // // // //       latitude: data['latitude']?.toDouble(),
// // // // // //       longitude: data['longitude']?.toDouble(),
// // // // // //       address: data['fullAddress'] ?? '',
// // // // // //
// // // // // //       // Contact
// // // // // //       contactName: data['holderName'] ?? '',
// // // // // //       phone: data['mobileNumber'] ?? '',
// // // // // //       email: data['email'] ?? '',
// // // // // //       aadhar: data['aadharNumber'] ?? '',
// // // // // //       aadharFile: null, // You'll need to download these if needed
// // // // // //       // Documents
// // // // // //       gst: data['gstNumber'] ?? '',
// // // // // //       gstFile: null,
// // // // // //       pan: data['panCardNumber'] ?? '',
// // // // // //       panFile: null,
// // // // // //       fssaiNo: data['fssaiLicenseNumber'] ?? '',
// // // // // //       fssaiStart: data['fssaiStartDate'] ?? '',
// // // // // //       fssaiEnd: data['fssaiEndDate'] ?? '',
// // // // // //       fssaiFile: null,
// // // // // //       tradeLicenseNo: data['tradeLicenseNumber'] ?? '',
// // // // // //       tradeStart: data['tradeLicenseStartDate'] ?? '',
// // // // // //       tradeEnd: data['tradeLicenseEndDate'] ?? '',
// // // // // //       tradeLicenseFile: null,
// // // // // //       labourLicenseNo: data['labourLicenseNumber'] ?? '',
// // // // // //       labourStart: data['labourStartDate'] ?? '',
// // // // // //       labourEnd: data['labourEndDate'] ?? '',
// // // // // //       labourFile: null,
// // // // // //
// // // // // //       // Bank
// // // // // //       bankName: data['bankName'] ?? data['branchName'] ?? '',
// // // // // //       ifsc: data['ifscCode'] ?? '',
// // // // // //       accountNumber: data['accountNumber'] ?? '',
// // // // // //       passbookFile: null,
// // // // // //     );
// // // // // //   }
// // // // // // }
// // // // // import 'dart:convert';
// // // // // import 'package:maamaaspartner/RegistrationScreen/models/vendor_form_data.dart';
// // // // // import '../../API/Apiclient.dart';
// // // // //
// // // // // class VendorApiService {
// // // // //   static const String _endpoint = 'api/vendors';
// // // // //
// // // // //   // GET vendor
// // // // //   static Future<Map<String, dynamic>?> getVendor(String vendorId) async {
// // // // //     try {
// // // // //       final response = await ApiClient.get(
// // // // //         '$_endpoint/$vendorId',
// // // // //         service: 'food',
// // // // //       );
// // // // //
// // // // //       if (response.statusCode == 200) {
// // // // //         return jsonDecode(response.body);
// // // // //       }
// // // // //       return null;
// // // // //     } catch (e) {
// // // // //       print('GET Error: $e');
// // // // //       return null;
// // // // //     }
// // // // //   }
// // // // //
// // // // //   // POST vendor (multipart via ApiClient)
// // // // //   static Future<bool> registerVendor(
// // // // //     String vendorId,
// // // // //     VendorFormData formData,
// // // // //   ) async {
// // // // //     try {
// // // // //       final vendorDataJson = {
// // // // //         'vendorId': int.tryParse(vendorId) ?? 0,
// // // // //         'latitude': formData.latitude ?? 0,
// // // // //         'longitude': formData.longitude ?? 0,
// // // // //         'fullAddress': formData.address,
// // // // //         'addressLine': formData.addressLine,
// // // // //         'doorNumber': formData.doorNumber,
// // // // //         'landMark': formData.landMark,
// // // // //         'city': formData.city,
// // // // //         'state': formData.state.isEmpty ? 'Telangana' : formData.state,
// // // // //         'pincode': int.tryParse(formData.pincode) ?? 0,
// // // // //         'companyName': formData.companyName,
// // // // //         'registeredName': formData.companyName,
// // // // //         'ownerName': formData.companyName,
// // // // //         'businessVertical': 'FOOD_AND_BEVERAGES',
// // // // //         'position': formData.position,
// // // // //         'vendorType': formData.verticalType.isNotEmpty
// // // // //             ? formData.verticalType
// // // // //             : 'Restaurant',
// // // // //         'holderName': formData.contactName,
// // // // //         'mobileNumber': formData.phone,
// // // // //         'email': formData.email,
// // // // //         'aadharNumber': formData.aadhar,
// // // // //         'panCardNumber': formData.pan,
// // // // //         'gstNumber': formData.gst,
// // // // //         'tradeLicenseNumber': formData.tradeLicenseNo,
// // // // //         'tradeLicenseStartDate': formData.tradeStart,
// // // // //         'tradeLicenseEndDate': formData.tradeEnd,
// // // // //         'fssaiLicenseNumber': formData.fssaiNo,
// // // // //         'fssaiStartDate': formData.fssaiStart,
// // // // //         'fssaiEndDate': formData.fssaiEnd,
// // // // //         'labourLicenseNumber': formData.labourLicenseNo,
// // // // //         'labourStartDate': formData.labourStart,
// // // // //         'labourEndDate': formData.labourEnd,
// // // // //         'accountNumber': formData.accountNumber,
// // // // //         'ifscCode': formData.ifsc,
// // // // //         'bankName': formData.bankName,
// // // // //         'branchName': formData.bankName,
// // // // //         'aadharNumberStatus': false,
// // // // //         'panCardStatus': false,
// // // // //         'gstNumberStatus': false,
// // // // //         'tradeLicenseStatus': false,
// // // // //         'labourLicenseStatus': false,
// // // // //         'fssaiLicenseStatus': false,
// // // // //         'online': false,
// // // // //       };
// // // // //
// // // // //       final response = await ApiClient.sendMultipartRequest(
// // // // //         endpoint: '$_endpoint/$vendorId',
// // // // //         method: 'POST',
// // // // //         service: 'food',
// // // // //         data: {'vendorData': jsonEncode(vendorDataJson)},
// // // // //         files: {
// // // // //           if (formData.aadharFile != null)
// // // // //             'aadharPhotoFront': formData.aadharFile!,
// // // // //           if (formData.panFile != null) 'panCard': formData.panFile!,
// // // // //           if (formData.passbookFile != null) 'passbook': formData.passbookFile!,
// // // // //           if (formData.labourFile != null)
// // // // //             'labourLicense': formData.labourFile!,
// // // // //           if (formData.fssaiFile != null) 'fssaiLicense': formData.fssaiFile!,
// // // // //           if (formData.tradeLicenseFile != null)
// // // // //             'tradeLicense': formData.tradeLicenseFile!,
// // // // //           if (formData.gstFile != null) 'gstFile': formData.gstFile!,
// // // // //         },
// // // // //       );
// // // // //
// // // // //       return response.statusCode == 200 || response.statusCode == 201;
// // // // //     } catch (e) {
// // // // //       print('POST Error: $e');
// // // // //       return false;
// // // // //     }
// // // // //   }
// // // // //
// // // // //   // GET vendor and parse to FormData
// // // // //   static Future<VendorFormData?> getVendorFormData(String vendorId) async {
// // // // //     try {
// // // // //       final response = await ApiClient.get(
// // // // //         '$_endpoint/$vendorId',
// // // // //         service: 'food',
// // // // //       );
// // // // //
// // // // //       if (response.statusCode == 200) {
// // // // //         final data = jsonDecode(response.body);
// // // // //         return _parseVendorDataToFormData(data);
// // // // //       }
// // // // //       return null;
// // // // //     } catch (e) {
// // // // //       print('GET Error: $e');
// // // // //       return null;
// // // // //     }
// // // // //   }
// // // // //
// // // // //   // Helper method to parse API response to VendorFormData
// // // // //   static VendorFormData _parseVendorDataToFormData(Map<String, dynamic> data) {
// // // // //     return VendorFormData(
// // // // //       // Company Details - Using correct field names from API response
// // // // //       companyName: data['registeredName'] ?? data['companyName'] ?? '',
// // // // //       businessVertical:
// // // // //           data['businessVertical']?.toLowerCase().replaceAll('_', ' ') ??
// // // // //           'Food & Beverages',
// // // // //       position: data['position'] ?? '',
// // // // //       verticalType: data['vendorType'] ?? '',
// // // // //
// // // // //       // Address - Using correct field names
// // // // //       doorNumber: data['doorNumber'] ?? '',
// // // // //       addressLine: data['addressLine'] ?? '',
// // // // //       landMark: data['landMark'] ?? '',
// // // // //       city: data['city'] ?? '',
// // // // //       state: data['state'] ?? '',
// // // // //       pincode: data['pincode']?.toString() ?? '',
// // // // //       latitude: data['latitude']?.toDouble(),
// // // // //       longitude: data['longitude']?.toDouble(),
// // // // //       address: data['fullAddress'] ?? '',
// // // // //
// // // // //       // Contact - Using correct field names
// // // // //       contactName: data['holderName'] ?? '',
// // // // //       phone: data['mobileNumber']?.toString() ?? '',
// // // // //       email: data['email'] ?? '',
// // // // //       aadhar: data['aadharNumber']?.toString() ?? '',
// // // // //       aadharFile: null, // Can't download file automatically
// // // // //       // Documents - Using correct field names
// // // // //       gst: data['gstNumber'] ?? '',
// // // // //       gstFile: null,
// // // // //       pan: data['panCardNumber'] ?? '',
// // // // //       panFile: null,
// // // // //       fssaiNo: data['fssaiLicenseNumber'] ?? '',
// // // // //       fssaiStart: data['fssaiStartDate'] ?? '',
// // // // //       fssaiEnd: data['fssaiEndDate'] ?? '',
// // // // //       fssaiFile: null,
// // // // //       tradeLicenseNo: data['tradeLicenseNumber'] ?? '',
// // // // //       tradeStart: data['tradeLicenseStartDate'] ?? '',
// // // // //       tradeEnd: data['tradeLicenseEndDate'] ?? '',
// // // // //       tradeLicenseFile: null,
// // // // //       labourLicenseNo: data['labourLicenseNumber'] ?? '',
// // // // //       labourStart: data['labourStartDate'] ?? '',
// // // // //       labourEnd: data['labourEndDate'] ?? '',
// // // // //       labourFile: null,
// // // // //
// // // // //       // Bank - Using correct field names
// // // // //       bankName: data['bankName'] ?? data['branchName'] ?? '',
// // // // //       ifsc: data['ifscCode'] ?? '',
// // // // //       accountNumber: data['accountNumber']?.toString() ?? '',
// // // // //       passbookFile: null,
// // // // //     );
// // // // //   }
// // // // // }
// // // // import 'dart:convert';
// // // // import 'dart:io';
// // // // import 'package:flutter/foundation.dart';
// // // // import 'package:http/http.dart' as http;
// // // // import 'package:http_parser/http_parser.dart';
// // // // import 'package:maamaaspartner/RegistrationScreen/models/vendor_form_data.dart';
// // // // import '../../API/Apiclient.dart';
// // // //
// // // // class VendorApiService {
// // // //   static const String _endpoint = 'api/vendors';
// // // //
// // // //   // ── Base URL for direct (no-auth) calls ─────────────────────────────────────
// // // //   // Same host as the Book-a-Demo enquiry URL already used in BookDemoScreen.
// // // //   static const String _foodBaseUrl = 'http://staging.maamaas.com:8080/food/';
// // // //
// // // //   // ── GET vendor ───────────────────────────────────────────────────────────────
// // // //   static Future<Map<String, dynamic>?> getVendor(String vendorId) async {
// // // //     try {
// // // //       final response = await ApiClient.get(
// // // //         '$_endpoint/$vendorId',
// // // //         service: 'food',
// // // //       );
// // // //       if (response.statusCode == 200) return jsonDecode(response.body);
// // // //       return null;
// // // //     } catch (e) {
// // // //       debugPrint('GET Vendor Error: $e');
// // // //       return null;
// // // //     }
// // // //   }
// // // //
// // // //   // ── GET vendor parsed to FormData (returning / logged-in vendors) ────────────
// // // //   // ── GET vendor parsed to FormData (returning / logged-in vendors) ────────────
// // // //   static Future<VendorFormData?> getVendorFormData(String vendorId) async {
// // // //     try {
// // // //       final response = await ApiClient.get(
// // // //         '$_endpoint/$vendorId',
// // // //         service: 'food',
// // // //       );
// // // //       if (response.statusCode == 200) {
// // // //         final data = jsonDecode(response.body);
// // // //         // The API returns data directly, not wrapped in a data field
// // // //         return _parseVendorDataToFormData(data);
// // // //       }
// // // //       return null;
// // // //     } catch (e) {
// // // //       debugPrint('GET VendorFormData Error: $e');
// // // //       return null;
// // // //     }
// // // //   }
// // // //
// // // //   // ── AUTHENTICATED registration (logged-in vendor, token present) ─────────────
// // // //   static Future<bool> registerVendor(
// // // //     String vendorId,
// // // //     VendorFormData formData,
// // // //   ) async {
// // // //     // ApiClient.sendMultipartRequest resolves MIME type via lookupMimeType(path),
// // // //     // which returns null for Android image-picker cache files that have no
// // // //     // extension (e.g. /data/user/0/.../cache/picker_12345).  The ApiClient
// // // //     // fallback is `application/octet-stream`, which the server rejects (500).
// // // //     //
// // // //     // Fix: copy each file to a temp path with the correct extension so that
// // // //     // lookupMimeType always finds a match.  The copies are deleted in `finally`.
// // // //     final normalised = await _normaliseFileExtensions(_buildFileMap(formData));
// // // //     try {
// // // //       final response = await ApiClient.sendMultipartRequest(
// // // //         endpoint: '$_endpoint/$vendorId',
// // // //         method: 'POST',
// // // //         service: 'food',
// // // //         data: {'vendorData': jsonEncode(_buildVendorJson(vendorId, formData))},
// // // //         files: normalised,
// // // //       );
// // // //       debugPrint('registerVendor → ${response.statusCode}: ${response.body}');
// // // //       return response.statusCode == 200 || response.statusCode == 201;
// // // //     } catch (e) {
// // // //       debugPrint('registerVendor Error: $e');
// // // //       return false;
// // // //     } finally {
// // // //       _deleteTempFiles(normalised);
// // // //     }
// // // //   }
// // // //
// // // //   // ── PUBLIC registration (new vendor from Book-a-Demo — NO auth token) ────────
// // // //   //
// // // //   // The Book-a-Demo enquiry API returns only a vendorId, never a JWT.
// // // //   // ApiClient.sendMultipartRequest() throws "Authentication token not found"
// // // //   // when there is no token in SharedPreferences.
// // // //   //
// // // //   // This method uses a plain http.MultipartRequest so it bypasses ApiClient's
// // // //   // token guard entirely.  Use this from PreviewStep for isNewVendor == true.
// // // //   static Future<PublicRegisterResult> registerVendorPublic(
// // // //     String vendorId,
// // // //     VendorFormData formData,
// // // //   ) async {
// // // //     try {
// // // //       final uri = Uri.parse('$_foodBaseUrl$_endpoint/$vendorId');
// // // //       final request = http.MultipartRequest('POST', uri)
// // // //         ..headers['Accept'] = 'application/json';
// // // //
// // // //       // JSON payload — must be sent as application/json multipart part.
// // // //       // Using request.fields[] defaults to text/plain; charset=utf-8,
// // // //       // which the server rejects with a 500.
// // // //       request.files.add(
// // // //         http.MultipartFile.fromString(
// // // //           'vendorData',
// // // //           jsonEncode(_buildVendorJson(vendorId, formData)),
// // // //           contentType: MediaType('application', 'json'),
// // // //         ),
// // // //       );
// // // //
// // // //       // File attachments — must declare contentType explicitly.
// // // //       // Sending application/octet-stream causes a 500 on the server.
// // // //       for (final entry in _buildFileMap(formData).entries) {
// // // //         final mimeType = _mimeTypeForFile(entry.value);
// // // //         request.files.add(
// // // //           await http.MultipartFile.fromPath(
// // // //             entry.key,
// // // //             entry.value.path,
// // // //             contentType: MediaType.parse(mimeType),
// // // //           ),
// // // //         );
// // // //       }
// // // //
// // // //       debugPrint('📤 registerVendorPublic → POST $uri');
// // // //
// // // //       final streamed = await request.send().timeout(
// // // //         const Duration(seconds: 30),
// // // //         onTimeout: () => throw Exception('Request timed out'),
// // // //       );
// // // //       final response = await http.Response.fromStream(streamed);
// // // //
// // // //       debugPrint(
// // // //         '📨 registerVendorPublic ← ${response.statusCode}: ${response.body}',
// // // //       );
// // // //
// // // //       if (response.statusCode == 200 || response.statusCode == 201) {
// // // //         return PublicRegisterResult(success: true);
// // // //       }
// // // //
// // // //       // Parse server error message to show to the user
// // // //       String errorMessage = 'Registration failed (${response.statusCode})';
// // // //       try {
// // // //         final body = jsonDecode(response.body) as Map<String, dynamic>;
// // // //         errorMessage =
// // // //             (body['message'] ?? body['error'] ?? body['msg'] ?? errorMessage)
// // // //                 .toString();
// // // //       } catch (_) {
// // // //         if (response.body.isNotEmpty) errorMessage = response.body;
// // // //       }
// // // //
// // // //       return PublicRegisterResult(success: false, errorMessage: errorMessage);
// // // //     } catch (e) {
// // // //       debugPrint('registerVendorPublic Error: $e');
// // // //       return PublicRegisterResult(
// // // //         success: false,
// // // //         errorMessage: 'Network error: ${e.toString()}',
// // // //       );
// // // //     }
// // // //   }
// // // //
// // // //   // ── Shared helpers ────────────────────────────────────────────────────────────
// // // //
// // // //   static Map<String, dynamic> _buildVendorJson(
// // // //     String vendorId,
// // // //     VendorFormData f,
// // // //   ) => {
// // // //     'vendorId': int.tryParse(vendorId) ?? 0,
// // // //     'latitude': f.latitude ?? 0,
// // // //     'longitude': f.longitude ?? 0,
// // // //     'fullAddress': f.address,
// // // //     'addressLine': f.addressLine,
// // // //     'doorNumber': f.doorNumber,
// // // //     'landMark': f.landMark,
// // // //     'city': f.city,
// // // //     'state': f.state.isEmpty ? 'Telangana' : f.state,
// // // //     'pincode': int.tryParse(f.pincode) ?? 0,
// // // //     'companyName': f.companyName,
// // // //     'registeredName': f.companyName,
// // // //     'ownerName': f.companyName,
// // // //     'businessVertical': 'FOOD_AND_BEVERAGES',
// // // //     'position': f.position,
// // // //     'vendorType': _normalizeVendorType(f.verticalType),
// // // //     'holderName': f.contactName,
// // // //     'mobileNumber': f.phone,
// // // //     'email': f.email,
// // // //     'aadharNumber': f.aadhar,
// // // //     'panCardNumber': f.pan,
// // // //     'gstNumber': f.gst,
// // // //     'tradeLicenseNumber': f.tradeLicenseNo,
// // // //     'tradeLicenseStartDate': f.tradeStart,
// // // //     'tradeLicenseEndDate': f.tradeEnd,
// // // //     'fssaiLicenseNumber': f.fssaiNo,
// // // //     'fssaiStartDate': f.fssaiStart,
// // // //     'fssaiEndDate': f.fssaiEnd,
// // // //     'labourLicenseNumber': f.labourLicenseNo,
// // // //     'labourStartDate': f.labourStart,
// // // //     'labourEndDate': f.labourEnd,
// // // //     'accountNumber': f.accountNumber,
// // // //     'ifscCode': f.ifsc,
// // // //     'bankName': f.bankName,
// // // //     'branchName': f.bankName,
// // // //     'aadharNumberStatus': false,
// // // //     'panCardStatus': false,
// // // //     'gstNumberStatus': false,
// // // //     'tradeLicenseStatus': false,
// // // //     'labourLicenseStatus': false,
// // // //     'fssaiLicenseStatus': false,
// // // //     'online': false,
// // // //   };
// // // //
// // // //   static Map<String, File> _buildFileMap(VendorFormData f) => {
// // // //     if (f.aadharFile != null) 'aadharPhotoFront': f.aadharFile!,
// // // //     if (f.panFile != null) 'panCard': f.panFile!,
// // // //     if (f.passbookFile != null) 'passbook': f.passbookFile!,
// // // //     if (f.labourFile != null) 'labourLicense': f.labourFile!,
// // // //     if (f.fssaiFile != null) 'fssaiLicense': f.fssaiFile!,
// // // //     if (f.tradeLicenseFile != null) 'tradeLicense': f.tradeLicenseFile!,
// // // //     if (f.gstFile != null) 'gstFile': f.gstFile!,
// // // //   };
// // // //
// // // //   /// Returns the correct MIME type based on file extension.
// // // //   /// Falls back to image/jpeg for any image file the user picked from gallery,
// // // //   /// which is what the server actually expects for document uploads.
// // // //   static String _mimeTypeForFile(File file) {
// // // //     final ext = file.path.split('.').last.toLowerCase();
// // // //     switch (ext) {
// // // //       case 'jpg':
// // // //       case 'jpeg':
// // // //         return 'image/jpeg';
// // // //       case 'png':
// // // //         return 'image/png';
// // // //       case 'pdf':
// // // //         return 'application/pdf';
// // // //       case 'webp':
// // // //         return 'image/webp';
// // // //       case 'heic':
// // // //         return 'image/heic';
// // // //       default:
// // // //         // ImagePicker always returns jpg/png on Android — safe default
// // // //         return 'image/jpeg';
// // // //     }
// // // //   }
// // // // // Add this helper method to normalize vendorType to match backend enum
// // // //   static String _normalizeVendorType(String type) {
// // // //     if (type.isEmpty) return 'Restaurant';
// // // //
// // // //     // Convert to lowercase for case-insensitive comparison
// // // //     final lowerType = type.toLowerCase().trim();
// // // //
// // // //     // Map to exact backend enum values
// // // //     switch (lowerType) {
// // // //       case 'restaurant':
// // // //         return 'Restaurant';  // Capital R only, not all caps
// // // //       case 'hotel':
// // // //         return 'Hotel';       // Capital H only
// // // //       case 'cafe':
// // // //         return 'CAFE';        // All uppercase
// // // //       case 'cloud_kitchen':
// // // //       case 'cloud kitchen':   // Handle space vs underscore
// // // //         return 'CLOUD_KITCHEN';
// // // //       case 'food_court':
// // // //       case 'food court':      // Handle space vs underscore
// // // //         return 'FOOD_COURT';
// // // //       case 'street_food':
// // // //       case 'street food':     // Handle space vs underscore
// // // //         return 'STREET_FOOD';
// // // //       case 'bakery':
// // // //         return 'BAKERY';
// // // //       default:
// // // //       // If unknown, default to Restaurant
// // // //         return 'Restaurant';
// // // //     }
// // // //   }
// // // //   /// Copies each file in [fileMap] to a temp path whose extension matches its
// // // //   /// real MIME type (derived by [_mimeTypeForFile]).  This ensures that
// // // //   /// `lookupMimeType` inside ApiClient always resolves to the correct type
// // // //   /// and never falls back to `application/octet-stream`.
// // // //   ///
// // // //   /// Only files whose current path lacks the correct extension are copied;
// // // //   /// files that already have the right extension are returned as-is so we
// // // //   /// avoid unnecessary I/O.
// // // //   static Future<Map<String, File>> _normaliseFileExtensions(
// // // //     Map<String, File> fileMap,
// // // //   ) async {
// // // //     final result = <String, File>{};
// // // //     for (final entry in fileMap.entries) {
// // // //       final file = entry.value;
// // // //       final mime = _mimeTypeForFile(file);
// // // //
// // // //       // Derive the expected extension from the MIME type.
// // // //       final expectedExt =
// // // //           const {
// // // //             'image/jpeg': 'jpg',
// // // //             'image/png': 'png',
// // // //             'application/pdf': 'pdf',
// // // //             'image/webp': 'webp',
// // // //             'image/heic': 'heic',
// // // //           }[mime] ??
// // // //           'jpg';
// // // //
// // // //       final currentExt = file.path.contains('.')
// // // //           ? file.path.split('.').last.toLowerCase()
// // // //           : '';
// // // //
// // // //       if (currentExt == expectedExt ||
// // // //           currentExt == 'jpeg' && expectedExt == 'jpg') {
// // // //         // Extension is already correct — no copy needed.
// // // //         result[entry.key] = file;
// // // //       } else {
// // // //         // Copy to a temp file with the right extension so lookupMimeType works.
// // // //         final tmpDir = Directory.systemTemp;
// // // //         final tmpPath =
// // // //             '${tmpDir.path}/vendor_upload_${entry.key}_${DateTime.now().millisecondsSinceEpoch}.$expectedExt';
// // // //         final tmpFile = await file.copy(tmpPath);
// // // //         debugPrint(
// // // //           '🔄 Normalised ${entry.key}: ${file.path} → $tmpPath ($mime)',
// // // //         );
// // // //         result[entry.key] = tmpFile;
// // // //       }
// // // //     }
// // // //     return result;
// // // //   }
// // // //
// // // //   /// Deletes any temp files that were created by [_normaliseFileExtensions].
// // // //   /// Only removes files inside [Directory.systemTemp] to avoid touching
// // // //   /// the original user-selected files.
// // // //   static void _deleteTempFiles(Map<String, File> normalised) {
// // // //     final tmpDir = Directory.systemTemp.path;
// // // //     for (final file in normalised.values) {
// // // //       if (file.path.startsWith(tmpDir)) {
// // // //         try {
// // // //           file.deleteSync();
// // // //         } catch (_) {
// // // //           // Best-effort cleanup — ignore errors.
// // // //         }
// // // //       }
// // // //     }
// // // //   }
// // // //
// // // //   static VendorFormData _parseVendorDataToFormData(Map<String, dynamic> data) =>
// // // //       VendorFormData(
// // // //         companyName: data['registeredName'] ?? data['companyName'] ?? '',
// // // //         businessVertical:
// // // //             data['businessVertical']?.toLowerCase().replaceAll('_', ' ') ??
// // // //             'Food & Beverages',
// // // //         position: data['position'] ?? '',
// // // //         verticalType: data['vendorType'] ?? '',
// // // //         doorNumber: data['doorNumber'] ?? '',
// // // //         addressLine: data['addressLine'] ?? '',
// // // //         landMark: data['landMark'] ?? '',
// // // //         city: data['city'] ?? '',
// // // //         state: data['state'] ?? '',
// // // //         pincode: data['pincode']?.toString() ?? '',
// // // //         latitude: data['latitude']?.toDouble(),
// // // //         longitude: data['longitude']?.toDouble(),
// // // //         address: data['fullAddress'] ?? '',
// // // //         contactName: data['holderName'] ?? '',
// // // //         phone: data['mobileNumber']?.toString() ?? '',
// // // //         email: data['email'] ?? '',
// // // //         aadhar: data['aadharNumber']?.toString() ?? '',
// // // //         aadharFile: null,
// // // //         gst: data['gstNumber'] ?? '',
// // // //         gstFile: null,
// // // //         pan: data['panCardNumber'] ?? '',
// // // //         panFile: null,
// // // //         fssaiNo: data['fssaiLicenseNumber'] ?? '',
// // // //         fssaiStart: data['fssaiStartDate'] ?? '',
// // // //         fssaiEnd: data['fssaiEndDate'] ?? '',
// // // //         fssaiFile: null,
// // // //         tradeLicenseNo: data['tradeLicenseNumber'] ?? '',
// // // //         tradeStart: data['tradeLicenseStartDate'] ?? '',
// // // //         tradeEnd: data['tradeLicenseEndDate'] ?? '',
// // // //         tradeLicenseFile: null,
// // // //         labourLicenseNo: data['labourLicenseNumber'] ?? '',
// // // //         labourStart: data['labourStartDate'] ?? '',
// // // //         labourEnd: data['labourEndDate'] ?? '',
// // // //         labourFile: null,
// // // //         bankName: data['bankName'] ?? data['branchName'] ?? '',
// // // //         ifsc: data['ifscCode'] ?? '',
// // // //         accountNumber: data['accountNumber']?.toString() ?? '',
// // // //         passbookFile: null,
// // // //       );
// // // // }
// // // //
// // // // // Result wrapper for public registration
// // // // class PublicRegisterResult {
// // // //   final bool success;
// // // //   final String? errorMessage;
// // // //   const PublicRegisterResult({required this.success, this.errorMessage});
// // // // }
// // // import 'dart:convert';
// // // import 'dart:io';
// // // import 'package:flutter/foundation.dart';
// // // import 'package:http/http.dart' as http;
// // // import 'package:http_parser/http_parser.dart';
// // // import 'package:maamaaspartner/RegistrationScreen/models/vendor_form_data.dart';
// // // import '../../API/Apiclient.dart';
// // //
// // // class VendorApiService {
// // //   static const String _endpoint = 'api/vendors';
// // //
// // //   // ── Base URL for direct (no-auth) calls ─────────────────────────────────────
// // //   static const String _foodBaseUrl = 'http://staging.maamaas.com:8080/food/';
// // //
// // //   // ── GET vendor ───────────────────────────────────────────────────────────────
// // //   static Future<Map<String, dynamic>?> getVendor(String vendorId) async {
// // //     try {
// // //       final response = await ApiClient.get(
// // //         '$_endpoint/$vendorId',
// // //         service: 'food',
// // //       );
// // //       if (response.statusCode == 200) return jsonDecode(response.body);
// // //       return null;
// // //     } catch (e) {
// // //       debugPrint('GET Vendor Error: $e');
// // //       return null;
// // //     }
// // //   }
// // //
// // //   // ── GET vendor parsed to FormData ────────────────────────────────────────────
// // //   static Future<VendorFormData?> getVendorFormData(String vendorId) async {
// // //     try {
// // //       final response = await ApiClient.get(
// // //         '$_endpoint/$vendorId',
// // //         service: 'food',
// // //       );
// // //       if (response.statusCode == 200) {
// // //         final data = jsonDecode(response.body);
// // //         return _parseVendorDataToFormData(data);
// // //       }
// // //       debugPrint('GET VendorFormData failed: ${response.statusCode}');
// // //       return null;
// // //     } catch (e) {
// // //       debugPrint('GET VendorFormData Error: $e');
// // //       return null;
// // //     }
// // //   }
// // //
// // //   // ── AUTHENTICATED registration (logged-in vendor, token present) ─────────────
// // //   static Future<bool> registerVendor(
// // //     String vendorId,
// // //     VendorFormData formData,
// // //   ) async {
// // //     final normalised = await _normaliseFileExtensions(_buildFileMap(formData));
// // //     try {
// // //       final response = await ApiClient.sendMultipartRequest(
// // //         endpoint: '$_endpoint/$vendorId',
// // //         method: 'POST',
// // //         service: 'food',
// // //         data: {'vendorData': jsonEncode(_buildVendorJson(vendorId, formData))},
// // //         files: normalised,
// // //       );
// // //       debugPrint('registerVendor → ${response.statusCode}: ${response.body}');
// // //       return response.statusCode == 200 || response.statusCode == 201;
// // //     } catch (e) {
// // //       debugPrint('registerVendor Error: $e');
// // //       return false;
// // //     } finally {
// // //       _deleteTempFiles(normalised);
// // //     }
// // //   }
// // //
// // //   // ── PUBLIC registration (new vendor from Book-a-Demo — NO auth token) ────────
// // //   static Future<PublicRegisterResult> registerVendorPublic(
// // //     String vendorId,
// // //     VendorFormData formData,
// // //   ) async {
// // //     try {
// // //       final uri = Uri.parse('$_foodBaseUrl$_endpoint/$vendorId');
// // //       final request = http.MultipartRequest('POST', uri)
// // //         ..headers['Accept'] = 'application/json';
// // //
// // //       // JSON payload
// // //       request.files.add(
// // //         http.MultipartFile.fromString(
// // //           'vendorData',
// // //           jsonEncode(_buildVendorJson(vendorId, formData)),
// // //           contentType: MediaType('application', 'json'),
// // //         ),
// // //       );
// // //
// // //       // File attachments
// // //       for (final entry in _buildFileMap(formData).entries) {
// // //         final mimeType = _mimeTypeForFile(entry.value);
// // //         request.files.add(
// // //           await http.MultipartFile.fromPath(
// // //             entry.key,
// // //             entry.value.path,
// // //             contentType: MediaType.parse(mimeType),
// // //           ),
// // //         );
// // //       }
// // //
// // //       debugPrint('📤 registerVendorPublic → POST $uri');
// // //
// // //       final streamed = await request.send().timeout(
// // //         const Duration(seconds: 30),
// // //         onTimeout: () => throw Exception('Request timed out'),
// // //       );
// // //       final response = await http.Response.fromStream(streamed);
// // //
// // //       debugPrint(
// // //         '📨 registerVendorPublic ← ${response.statusCode}: ${response.body}',
// // //       );
// // //
// // //       if (response.statusCode == 200 || response.statusCode == 201) {
// // //         return PublicRegisterResult(success: true);
// // //       }
// // //
// // //       String errorMessage = 'Registration failed (${response.statusCode})';
// // //       try {
// // //         final body = jsonDecode(response.body) as Map<String, dynamic>;
// // //         errorMessage =
// // //             body['message']?.toString() ??
// // //             body['error']?.toString() ??
// // //             body['msg']?.toString() ??
// // //             errorMessage;
// // //       } catch (_) {
// // //         if (response.body.isNotEmpty) errorMessage = response.body;
// // //       }
// // //
// // //       return PublicRegisterResult(success: false, errorMessage: errorMessage);
// // //     } catch (e) {
// // //       debugPrint('registerVendorPublic Error: $e');
// // //       return PublicRegisterResult(
// // //         success: false,
// // //         errorMessage: 'Network error: ${e.toString()}',
// // //       );
// // //     }
// // //   }
// // //
// // //   // ── Shared helpers ────────────────────────────────────────────────────────────
// // //   static Map<String, dynamic> _buildVendorJson(
// // //     String vendorId,
// // //     VendorFormData f,
// // //   ) => {
// // //     'vendorId': int.tryParse(vendorId) ?? 0,
// // //     'latitude': f.latitude ?? 0,
// // //     'longitude': f.longitude ?? 0,
// // //     'fullAddress': f.address,
// // //     'addressLine': f.addressLine,
// // //     'doorNumber': f.doorNumber,
// // //     'landMark': f.landMark,
// // //     'city': f.city,
// // //     'state': f.state.isEmpty ? 'Telangana' : f.state,
// // //     'pincode': int.tryParse(f.pincode) ?? 0,
// // //     'companyName': f.companyName,
// // //     'registeredName': f.companyName,
// // //     'ownerName': f.companyName,
// // //     'businessVertical': 'FOOD_AND_BEVERAGES',
// // //     'position': f.position,
// // //     'vendorType': _normalizeVendorType(f.verticalType),
// // //     'holderName': f.contactName,
// // //     'mobileNumber': f.phone,
// // //     'email': f.email,
// // //     'aadharNumber': f.aadhar,
// // //     'panCardNumber': f.pan,
// // //     'gstNumber': f.gst,
// // //     'tradeLicenseNumber': f.tradeLicenseNo,
// // //     'tradeLicenseStartDate': f.tradeStart,
// // //     'tradeLicenseEndDate': f.tradeEnd,
// // //     'fssaiLicenseNumber': f.fssaiNo,
// // //     'fssaiStartDate': f.fssaiStart,
// // //     'fssaiEndDate': f.fssaiEnd,
// // //     'labourLicenseNumber': f.labourLicenseNo,
// // //     'labourStartDate': f.labourStart,
// // //     'labourEndDate': f.labourEnd,
// // //     'accountNumber': f.accountNumber,
// // //     'ifscCode': f.ifsc,
// // //     'bankName': f.bankName,
// // //     'branchName': f.bankName,
// // //     'aadharNumberStatus': false,
// // //     'panCardStatus': false,
// // //     'gstNumberStatus': false,
// // //     'tradeLicenseStatus': false,
// // //     'labourLicenseStatus': false,
// // //     'fssaiLicenseStatus': false,
// // //     'online': false,
// // //   };
// // //
// // //   static Map<String, File> _buildFileMap(VendorFormData f) => {
// // //     if (f.aadharFile != null) 'aadharPhotoFront': f.aadharFile!,
// // //     if (f.panFile != null) 'panCard': f.panFile!,
// // //     if (f.passbookFile != null) 'passbook': f.passbookFile!,
// // //     if (f.labourFile != null) 'labourLicense': f.labourFile!,
// // //     if (f.fssaiFile != null) 'fssaiLicense': f.fssaiFile!,
// // //     if (f.tradeLicenseFile != null) 'tradeLicense': f.tradeLicenseFile!,
// // //     if (f.gstFile != null) 'gstFile': f.gstFile!,
// // //   };
// // //
// // //   static String _mimeTypeForFile(File file) {
// // //     final ext = file.path.split('.').last.toLowerCase();
// // //     switch (ext) {
// // //       case 'jpg':
// // //       case 'jpeg':
// // //         return 'image/jpeg';
// // //       case 'png':
// // //         return 'image/png';
// // //       case 'pdf':
// // //         return 'application/pdf';
// // //       case 'webp':
// // //         return 'image/webp';
// // //       case 'heic':
// // //         return 'image/heic';
// // //       default:
// // //         return 'image/jpeg';
// // //     }
// // //   }
// // //
// // //   static String _normalizeVendorType(String type) {
// // //     if (type.isEmpty) return 'Restaurant';
// // //
// // //     final lowerType = type.toLowerCase().trim();
// // //
// // //     switch (lowerType) {
// // //       case 'restaurant':
// // //         return 'Restaurant';
// // //       case 'hotel':
// // //         return 'Hotel';
// // //       case 'cafe':
// // //         return 'CAFE';
// // //       case 'cloud_kitchen':
// // //       case 'cloud kitchen':
// // //         return 'CLOUD_KITCHEN';
// // //       case 'food_court':
// // //       case 'food court':
// // //         return 'FOOD_COURT';
// // //       case 'street_food':
// // //       case 'street food':
// // //         return 'STREET_FOOD';
// // //       case 'bakery':
// // //         return 'BAKERY';
// // //       default:
// // //         return 'Restaurant';
// // //     }
// // //   }
// // //
// // //   static Future<Map<String, File>> _normaliseFileExtensions(
// // //     Map<String, File> fileMap,
// // //   ) async {
// // //     final result = <String, File>{};
// // //     for (final entry in fileMap.entries) {
// // //       final file = entry.value;
// // //       final mime = _mimeTypeForFile(file);
// // //
// // //       final expectedExt =
// // //           {
// // //             'image/jpeg': 'jpg',
// // //             'image/png': 'png',
// // //             'application/pdf': 'pdf',
// // //             'image/webp': 'webp',
// // //             'image/heic': 'heic',
// // //           }[mime] ??
// // //           'jpg';
// // //
// // //       final currentExt = file.path.contains('.')
// // //           ? file.path.split('.').last.toLowerCase()
// // //           : '';
// // //
// // //       if (currentExt == expectedExt ||
// // //           (currentExt == 'jpeg' && expectedExt == 'jpg')) {
// // //         result[entry.key] = file;
// // //       } else {
// // //         final tmpDir = Directory.systemTemp;
// // //         final tmpPath =
// // //             '${tmpDir.path}/vendor_upload_${entry.key}_${DateTime.now().millisecondsSinceEpoch}.$expectedExt';
// // //         final tmpFile = await file.copy(tmpPath);
// // //         debugPrint(
// // //           '🔄 Normalised ${entry.key}: ${file.path} → $tmpPath ($mime)',
// // //         );
// // //         result[entry.key] = tmpFile;
// // //       }
// // //     }
// // //     return result;
// // //   }
// // //
// // //   static void _deleteTempFiles(Map<String, File> normalised) {
// // //     final tmpDir = Directory.systemTemp.path;
// // //     for (final file in normalised.values) {
// // //       if (file.path.startsWith(tmpDir)) {
// // //         try {
// // //           file.deleteSync();
// // //         } catch (_) {
// // //           // Best-effort cleanup
// // //         }
// // //       }
// // //     }
// // //   }
// // //
// // //   static VendorFormData _parseVendorDataToFormData(Map<String, dynamic> data) {
// // //     return VendorFormData(
// // //       // Basic Info
// // //       companyName: data['registeredName'] ?? data['companyName'] ?? '',
// // //       businessVertical:
// // //           data['businessVertical']?.toString() ?? 'FOOD_AND_BEVERAGES',
// // //       position: data['position'] ?? '',
// // //       verticalType: _normalizeVendorType(data['vendorType'] ?? ''),
// // //
// // //       // Address Info
// // //       doorNumber: data['doorNumber'] ?? '',
// // //       addressLine: data['addressLine'] ?? '',
// // //       landMark: data['landMark'] ?? '',
// // //       city: data['city'] ?? '',
// // //       state: data['state'] ?? '',
// // //       pincode: data['pincode']?.toString() ?? '',
// // //       latitude: data['latitude']?.toDouble(),
// // //       longitude: data['longitude']?.toDouble(),
// // //       address: data['fullAddress'] ?? '',
// // //
// // //       // Contact Info
// // //       contactName: data['holderName'] ?? data['ownerName'] ?? '',
// // //       phone: data['mobileNumber']?.toString() ?? '',
// // //       email: data['email'] ?? '',
// // //
// // //       // Document Numbers
// // //       aadhar: data['aadharNumber']?.toString() ?? '',
// // //       aadharFile: null,
// // //
// // //       gst: data['gstNumber'] ?? '',
// // //       gstFile: null,
// // //
// // //       pan: data['panCardNumber'] ?? '',
// // //       panFile: null,
// // //
// // //       fssaiNo: data['fssaiLicenseNumber'] ?? '',
// // //       fssaiStart: data['fssaiStartDate'] ?? '',
// // //       fssaiEnd: data['fssaiEndDate'] ?? '',
// // //       fssaiFile: null,
// // //
// // //       tradeLicenseNo: data['tradeLicenseNumber'] ?? '',
// // //       tradeStart: data['tradeLicenseStartDate'] ?? '',
// // //       tradeEnd: data['tradeLicenseEndDate'] ?? '',
// // //       tradeLicenseFile: null,
// // //
// // //       labourLicenseNo: data['labourLicenseNumber'] ?? '',
// // //       labourStart: data['labourStartDate'] ?? '',
// // //       labourEnd: data['labourEndDate'] ?? '',
// // //       labourFile: null,
// // //
// // //       // Bank Info
// // //       bankName: data['branchName'] ?? data['bankName'] ?? '',
// // //       ifsc: data['ifscCode'] ?? '',
// // //       accountNumber: data['accountNumber']?.toString() ?? '',
// // //       passbookFile: null,
// // //     );
// // //   }
// // // }
// // //
// // // // Result wrapper for public registration
// // // class PublicRegisterResult {
// // //   final bool success;
// // //   final String? errorMessage;
// // //
// // //   const PublicRegisterResult({required this.success, this.errorMessage});
// // // }
// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/foundation.dart';
// import 'package:http/http.dart' as http;
// import 'package:http_parser/http_parser.dart';
// import 'package:maamaaspartner/Registration01/models/vendor_form_data.dart';
// import '../../API/Apiclient.dart';
//
// class VendorApiService {
//   static const String _endpoint = 'api/vendors';
//   static const String _foodBaseUrl = 'http//testing.maamaas.com/food/';
//
//   // ── GET vendor ───────────────────────────────────────────────────────────────
//   static Future<Map<String, dynamic>?> getVendor(String vendorId) async {
//     try {
//       final response = await ApiClient.get(
//         '$_endpoint/$vendorId',
//         service: 'food',
//       );
//       if (response.statusCode == 200) return jsonDecode(response.body);
//       return null;
//     } catch (e) {
//       debugPrint('GET Vendor Error: $e');
//       return null;
//     }
//   }
//
//   // ── GET vendor parsed to FormData ────────────────────────────────────────────
//   static Future<VendorFormData?> getVendorFormData(String vendorId) async {
//     try {
//       debugPrint('🟢 Fetching vendor data for ID: $vendorId');
//       final response = await ApiClient.get(
//         '$_endpoint/$vendorId',
//         service: 'food',
//       );
//
//       debugPrint('🟢 Response status: ${response.statusCode}');
//
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         debugPrint('🟢 Response keys: ${data.keys}');
//         debugPrint('🟢 Company name from API: ${data['registeredName']}');
//
//         final parsed = _parseVendorDataToFormData(data);
//         debugPrint('🟢 Parsed company name: ${parsed.companyName}');
//         return parsed;
//       }
//       debugPrint('🔴 GET failed with status: ${response.statusCode}');
//       return null;
//     } catch (e) {
//       debugPrint('🔴 GET VendorFormData Error: $e');
//       return null;
//     }
//   }
//
//   // ── AUTHENTICATED registration ─────────────────────────────────────────────
//   static Future<bool> registerVendor(
//     String vendorId,
//     VendorFormData formData,
//   ) async {
//     final normalised = await _normaliseFileExtensions(_buildFileMap(formData));
//     try {
//       final response = await ApiClient.sendMultipartRequest(
//         endpoint: '$_endpoint/$vendorId',
//         method: 'POST',
//         service: 'food',
//         data: {'vendorData': jsonEncode(_buildVendorJson(vendorId, formData))},
//         files: normalised,
//       );
//       debugPrint('registerVendor → ${response.statusCode}: ${response.body}');
//       return response.statusCode == 200 || response.statusCode == 201;
//     } catch (e) {
//       debugPrint('registerVendor Error: $e');
//       return false;
//     } finally {
//       _deleteTempFiles(normalised);
//     }
//   }
//
//   // ── PUBLIC registration (no auth token) ─────────────────────────────────────
//   static Future<PublicRegisterResult> registerVendorPublic(
//     String vendorId,
//     VendorFormData formData,
//   ) async {
//     try {
//       final uri = Uri.parse('$_foodBaseUrl$_endpoint/$vendorId');
//       final request = http.MultipartRequest('POST', uri)
//         ..headers['Accept'] = 'application/json';
//
//       request.files.add(
//         http.MultipartFile.fromString(
//           'vendorData',
//           jsonEncode(_buildVendorJson(vendorId, formData)),
//           contentType: MediaType('application', 'json'),
//         ),
//       );
//
//       for (final entry in _buildFileMap(formData).entries) {
//         final mimeType = _mimeTypeForFile(entry.value);
//         request.files.add(
//           await http.MultipartFile.fromPath(
//             entry.key,
//             entry.value.path,
//             contentType: MediaType.parse(mimeType),
//           ),
//         );
//       }
//
//       debugPrint('📤 registerVendorPublic → POST $uri');
//       final streamed = await request.send().timeout(
//         const Duration(seconds: 30),
//         onTimeout: () => throw Exception('Request timed out'),
//       );
//       final response = await http.Response.fromStream(streamed);
//       debugPrint(
//         '📨 registerVendorPublic ← ${response.statusCode}: ${response.body}',
//       );
//
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         return PublicRegisterResult(success: true);
//       }
//
//       String errorMessage = 'Registration failed (${response.statusCode})';
//       try {
//         final body = jsonDecode(response.body) as Map<String, dynamic>;
//         errorMessage =
//             body['message']?.toString() ??
//             body['error']?.toString() ??
//             body['msg']?.toString() ??
//             errorMessage;
//       } catch (_) {
//         if (response.body.isNotEmpty) errorMessage = response.body;
//       }
//       return PublicRegisterResult(success: false, errorMessage: errorMessage);
//     } catch (e) {
//       debugPrint('registerVendorPublic Error: $e');
//       return PublicRegisterResult(
//         success: false,
//         errorMessage: 'Network error: ${e.toString()}',
//       );
//     }
//   }
//
//   // ── Shared helpers ────────────────────────────────────────────────────────────
//   static Map<String, dynamic> _buildVendorJson(
//     String vendorId,
//     VendorFormData f,
//   ) => {
//     'vendorId': int.tryParse(vendorId) ?? 0,
//     'latitude': f.latitude ?? 0,
//     'longitude': f.longitude ?? 0,
//     'fullAddress': f.address,
//     'addressLine': f.addressLine,
//     'doorNumber': f.doorNumber,
//     'landMark': f.landMark,
//     'city': f.city,
//     'state': f.state.isEmpty ? 'Telangana' : f.state,
//     'pincode': int.tryParse(f.pincode) ?? 0,
//     'companyName': f.companyName,
//     'registeredName': f.companyName,
//     'ownerName': f.companyName,
//     'businessVertical': 'FOOD_AND_BEVERAGES',
//     'position': f.position,
//     'vendorType': _normalizeVendorType(f.verticalType),
//     'holderName': f.contactName,
//     'mobileNumber': f.phone,
//     'email': f.email,
//     'aadharNumber': f.aadhar,
//     'panCardNumber': f.pan,
//     'gstNumber': f.gst,
//     'tradeLicenseNumber': f.tradeLicenseNo,
//     'tradeLicenseStartDate': f.tradeStart,
//     'tradeLicenseEndDate': f.tradeEnd,
//     'fssaiLicenseNumber': f.fssaiNo,
//     'fssaiStartDate': f.fssaiStart,
//     'fssaiEndDate': f.fssaiEnd,
//     'labourLicenseNumber': f.labourLicenseNo,
//     'labourStartDate': f.labourStart,
//     'labourEndDate': f.labourEnd,
//     'accountNumber': f.accountNumber,
//     'ifscCode': f.ifsc,
//     'bankName': f.bankName,
//     'branchName': f.bankName,
//     'aadharNumberStatus': false,
//     'panCardStatus': false,
//     'gstNumberStatus': false,
//     'tradeLicenseStatus': false,
//     'labourLicenseStatus': false,
//     'fssaiLicenseStatus': false,
//     'online': false,
//   };
//
//   static Map<String, File> _buildFileMap(VendorFormData f) => {
//     if (f.aadharFile != null) 'aadharPhotoFront': f.aadharFile!,
//     if (f.panFile != null) 'panCard': f.panFile!,
//     if (f.passbookFile != null) 'passbook': f.passbookFile!,
//     if (f.labourFile != null) 'labourLicense': f.labourFile!,
//     if (f.fssaiFile != null) 'fssaiLicense': f.fssaiFile!,
//     if (f.tradeLicenseFile != null) 'tradeLicense': f.tradeLicenseFile!,
//     if (f.gstFile != null) 'gstFile': f.gstFile!,
//   };
//
//   static String _mimeTypeForFile(File file) {
//     final ext = file.path.split('.').last.toLowerCase();
//     switch (ext) {
//       case 'jpg':
//       case 'jpeg':
//         return 'image/jpeg';
//       case 'png':
//         return 'image/png';
//       case 'pdf':
//         return 'application/pdf';
//       case 'webp':
//         return 'image/webp';
//       case 'heic':
//         return 'image/heic';
//       default:
//         return 'image/jpeg';
//     }
//   }
//
//   static String _normalizeVendorType(String type) {
//     if (type.isEmpty) return 'Restaurant';
//     final lowerType = type.toLowerCase().trim();
//     switch (lowerType) {
//       case 'restaurant':
//         return 'Restaurant';
//       case 'hotel':
//         return 'Hotel';
//       case 'cafe':
//         return 'CAFE';
//       case 'cloud_kitchen':
//       case 'cloud kitchen':
//         return 'CLOUD_KITCHEN';
//       case 'food_court':
//       case 'food court':
//         return 'FOOD_COURT';
//       case 'street_food':
//       case 'street food':
//         return 'STREET_FOOD';
//       case 'bakery':
//         return 'BAKERY';
//       default:
//         return 'Restaurant';
//     }
//   }
//
//   static Future<Map<String, File>> _normaliseFileExtensions(
//     Map<String, File> fileMap,
//   ) async {
//     final result = <String, File>{};
//     for (final entry in fileMap.entries) {
//       final file = entry.value;
//       final mime = _mimeTypeForFile(file);
//       final expectedExt =
//           {
//             'image/jpeg': 'jpg',
//             'image/png': 'png',
//             'application/pdf': 'pdf',
//             'image/webp': 'webp',
//             'image/heic': 'heic',
//           }[mime] ??
//           'jpg';
//       final currentExt = file.path.contains('.')
//           ? file.path.split('.').last.toLowerCase()
//           : '';
//       if (currentExt == expectedExt ||
//           (currentExt == 'jpeg' && expectedExt == 'jpg')) {
//         result[entry.key] = file;
//       } else {
//         final tmpDir = Directory.systemTemp;
//         final tmpPath =
//             '${tmpDir.path}/vendor_upload_${entry.key}_${DateTime.now().millisecondsSinceEpoch}.$expectedExt';
//         final tmpFile = await file.copy(tmpPath);
//         debugPrint(
//           '🔄 Normalised ${entry.key}: ${file.path} → $tmpPath ($mime)',
//         );
//         result[entry.key] = tmpFile;
//       }
//     }
//     return result;
//   }
//
//   static void _deleteTempFiles(Map<String, File> normalised) {
//     final tmpDir = Directory.systemTemp.path;
//     for (final file in normalised.values) {
//       if (file.path.startsWith(tmpDir)) {
//         try {
//           file.deleteSync();
//         } catch (_) {}
//       }
//     }
//   }
//
//   static VendorFormData _parseVendorDataToFormData(Map<String, dynamic> data) {
//     debugPrint('🟢 Parsing vendor data...');
//     return VendorFormData(
//       // Basic Info
//       companyName: data['registeredName'] ?? data['companyName'] ?? '',
//       businessVertical:
//           data['businessVertical']?.toString() ?? 'FOOD_AND_BEVERAGES',
//       position: data['position'] ?? '',
//       verticalType: _normalizeVendorType(data['vendorType'] ?? ''),
//
//       // Address Info
//       doorNumber: data['doorNumber'] ?? '',
//       addressLine: data['addressLine'] ?? '',
//       landMark: data['landMark'] ?? '',
//       city: data['city'] ?? '',
//       state: data['state'] ?? '',
//       pincode: data['pincode']?.toString() ?? '',
//       latitude: data['latitude']?.toDouble(),
//       longitude: data['longitude']?.toDouble(),
//       address: data['fullAddress'] ?? '',
//
//       // Contact Info
//       contactName: data['holderName'] ?? data['ownerName'] ?? '',
//       phone: data['mobileNumber']?.toString() ?? '',
//       email: data['email'] ?? '',
//
//       // Document Numbers
//       aadhar: data['aadharNumber']?.toString() ?? '',
//       aadharFile: null,
//       gst: data['gstNumber'] ?? '',
//       gstFile: null,
//       pan: data['panCardNumber'] ?? '',
//       panFile: null,
//       fssaiNo: data['fssaiLicenseNumber'] ?? '',
//       fssaiStart: data['fssaiStartDate'] ?? '',
//       fssaiEnd: data['fssaiEndDate'] ?? '',
//       fssaiFile: null,
//       tradeLicenseNo: data['tradeLicenseNumber'] ?? '',
//       tradeStart: data['tradeLicenseStartDate'] ?? '',
//       tradeEnd: data['tradeLicenseEndDate'] ?? '',
//       tradeLicenseFile: null,
//       labourLicenseNo: data['labourLicenseNumber'] ?? '',
//       labourStart: data['labourStartDate'] ?? '',
//       labourEnd: data['labourEndDate'] ?? '',
//       labourFile: null,
//
//       // Bank Info
//       bankName: data['branchName'] ?? data['bankName'] ?? '',
//       ifsc: data['ifscCode'] ?? '',
//       accountNumber: data['accountNumber']?.toString() ?? '',
//       passbookFile: null,
//     );
//   }
// }
//
// class PublicRegisterResult {
//   final bool success;
//   final String? errorMessage;
//   const PublicRegisterResult({required this.success, this.errorMessage});
// }
// // import 'dart:convert';
// // import 'dart:io';
// //
// // import 'package:flutter/foundation.dart';
// // import 'package:maamaaspartner/API/Apiclient.dart';
// // import 'package:maamaaspartner/Registration01/models/vendor_form_data.dart';
// //
// // class VendorApiService {
// //   static const String _endpoint = 'api/vendors';
// //
// //   // ───────────────── GET VENDOR ─────────────────
// //
// //   static Future<Map<String, dynamic>?> getVendor(String vendorId) async {
// //     try {
// //       final response = await ApiClient.get(
// //         '$_endpoint/$vendorId',
// //         service: 'food',
// //       );
// //
// //       debugPrint('🟢 GET Vendor Status: ${response.statusCode}');
// //
// //       if (response.statusCode == 200) {
// //         return jsonDecode(response.body);
// //       }
// //
// //       return null;
// //     } catch (e) {
// //       debugPrint('🔴 GET Vendor Error: $e');
// //       return null;
// //     }
// //   }
// //
// //   // ───────────────── GET VENDOR FORM DATA ─────────────────
// //
// //   static Future<VendorFormData?> getVendorFormData(String vendorId) async {
// //     try {
// //       debugPrint('🟢 Fetching vendor data for ID: $vendorId');
// //
// //       final response = await ApiClient.get(
// //         '$_endpoint/$vendorId',
// //         service: 'food',
// //       );
// //
// //       debugPrint('🟢 Response status: ${response.statusCode}');
// //
// //       if (response.statusCode == 200) {
// //         final data = jsonDecode(response.body);
// //
// //         debugPrint('🟢 Company name: ${data['registeredName']}');
// //
// //         return _parseVendorDataToFormData(data);
// //       }
// //
// //       return null;
// //     } catch (e) {
// //       debugPrint('🔴 GET VendorFormData Error: $e');
// //
// //       return null;
// //     }
// //   }
// //
// //   // ───────────────── AUTH REGISTER ─────────────────
// //
// //   static Future<bool> registerVendor(
// //     String vendorId,
// //     VendorFormData formData,
// //   ) async {
// //     final normalisedFiles = await _normaliseFileExtensions(
// //       _buildFileMap(formData),
// //     );
// //
// //     try {
// //       final response = await ApiClient.sendMultipartRequest(
// //         endpoint: '$_endpoint/$vendorId',
// //         method: 'POST',
// //         service: 'food',
// //
// //         data: {'vendorData': jsonEncode(_buildVendorJson(vendorId, formData))},
// //
// //         files: normalisedFiles,
// //       );
// //
// //       debugPrint('🟢 registerVendor → ${response.statusCode}');
// //
// //       debugPrint(response.body);
// //
// //       return response.statusCode == 200 || response.statusCode == 201;
// //     } catch (e) {
// //       debugPrint('🔴 registerVendor Error: $e');
// //
// //       return false;
// //     } finally {
// //       _deleteTempFiles(normalisedFiles);
// //     }
// //   }
// //
// //   // ───────────────── PUBLIC REGISTER ─────────────────
// //
// //   static Future<PublicRegisterResult> registerVendorPublic(
// //     String vendorId,
// //     VendorFormData formData,
// //   ) async {
// //     final normalisedFiles = await _normaliseFileExtensions(
// //       _buildFileMap(formData),
// //     );
// //
// //     try {
// //       final response = await ApiClient.sendMultipartRequest(
// //         endpoint: '$_endpoint/$vendorId',
// //         method: 'POST',
// //         service: 'food',
// //
// //         data: {'vendorData': jsonEncode(_buildVendorJson(vendorId, formData))},
// //
// //         files: normalisedFiles,
// //       );
// //
// //       debugPrint('📨 registerVendorPublic ← ${response.statusCode}');
// //
// //       debugPrint(response.body);
// //
// //       if (response.statusCode == 200 || response.statusCode == 201) {
// //         return const PublicRegisterResult(success: true);
// //       }
// //
// //       String errorMessage = 'Registration failed (${response.statusCode})';
// //
// //       try {
// //         final body = jsonDecode(response.body) as Map<String, dynamic>;
// //
// //         errorMessage =
// //             body['message']?.toString() ??
// //             body['error']?.toString() ??
// //             body['msg']?.toString() ??
// //             errorMessage;
// //       } catch (_) {
// //         if (response.body.isNotEmpty) {
// //           errorMessage = response.body;
// //         }
// //       }
// //
// //       return PublicRegisterResult(success: false, errorMessage: errorMessage);
// //     } catch (e) {
// //       debugPrint('🔴 registerVendorPublic Error: $e');
// //
// //       return PublicRegisterResult(
// //         success: false,
// //         errorMessage: 'Network error: ${e.toString()}',
// //       );
// //     } finally {
// //       _deleteTempFiles(normalisedFiles);
// //     }
// //   }
// //
// //   // ───────────────── BUILD JSON ─────────────────
// //
// //   static Map<String, dynamic> _buildVendorJson(
// //     String vendorId,
// //     VendorFormData f,
// //   ) {
// //     return {
// //       'vendorId': int.tryParse(vendorId) ?? 0,
// //       'latitude': f.latitude ?? 0,
// //       'longitude': f.longitude ?? 0,
// //       'fullAddress': f.address,
// //       'addressLine': f.addressLine,
// //       'doorNumber': f.doorNumber,
// //       'landMark': f.landMark,
// //       'city': f.city,
// //       'state': f.state.isEmpty ? 'Telangana' : f.state,
// //       'pincode': int.tryParse(f.pincode) ?? 0,
// //       'companyName': f.companyName,
// //       'registeredName': f.companyName,
// //       'ownerName': f.companyName,
// //       'businessVertical': 'FOOD_AND_BEVERAGES',
// //       'position': f.position,
// //       'vendorType': _normalizeVendorType(f.verticalType),
// //       'holderName': f.contactName,
// //       'mobileNumber': f.phone,
// //       'email': f.email,
// //       'aadharNumber': f.aadhar,
// //       'panCardNumber': f.pan,
// //       'gstNumber': f.gst,
// //       'tradeLicenseNumber': f.tradeLicenseNo,
// //       'tradeLicenseStartDate': f.tradeStart,
// //       'tradeLicenseEndDate': f.tradeEnd,
// //       'fssaiLicenseNumber': f.fssaiNo,
// //       'fssaiStartDate': f.fssaiStart,
// //       'fssaiEndDate': f.fssaiEnd,
// //       'labourLicenseNumber': f.labourLicenseNo,
// //       'labourStartDate': f.labourStart,
// //       'labourEndDate': f.labourEnd,
// //       'accountNumber': f.accountNumber,
// //       'ifscCode': f.ifsc,
// //       'bankName': f.bankName,
// //       'branchName': f.bankName,
// //       'aadharNumberStatus': false,
// //       'panCardStatus': false,
// //       'gstNumberStatus': false,
// //       'tradeLicenseStatus': false,
// //       'labourLicenseStatus': false,
// //       'fssaiLicenseStatus': false,
// //       'online': false,
// //     };
// //   }
// //
// //   // ───────────────── FILE MAP ─────────────────
// //
// //   static Map<String, File> _buildFileMap(VendorFormData f) {
// //     return {
// //       if (f.aadharFile != null) 'aadharPhotoFront': f.aadharFile!,
// //       if (f.panFile != null) 'panCard': f.panFile!,
// //       if (f.passbookFile != null) 'passbook': f.passbookFile!,
// //       if (f.labourFile != null) 'labourLicense': f.labourFile!,
// //       if (f.fssaiFile != null) 'fssaiLicense': f.fssaiFile!,
// //       if (f.tradeLicenseFile != null) 'tradeLicense': f.tradeLicenseFile!,
// //       if (f.gstFile != null) 'gstFile': f.gstFile!,
// //     };
// //   }
// //
// //   // ───────────────── MIME TYPE ─────────────────
// //
// //   static String _mimeTypeForFile(File file) {
// //     final ext = file.path.split('.').last.toLowerCase();
// //
// //     switch (ext) {
// //       case 'jpg':
// //       case 'jpeg':
// //         return 'image/jpeg';
// //
// //       case 'png':
// //         return 'image/png';
// //
// //       case 'pdf':
// //         return 'application/pdf';
// //
// //       case 'webp':
// //         return 'image/webp';
// //
// //       case 'heic':
// //         return 'image/heic';
// //
// //       default:
// //         return 'image/jpeg';
// //     }
// //   }
// //
// //   // ───────────────── NORMALIZE TYPE ─────────────────
// //
// //   static String _normalizeVendorType(String type) {
// //     if (type.isEmpty) {
// //       return 'Restaurant';
// //     }
// //
// //     switch (type.toLowerCase().trim()) {
// //       case 'restaurant':
// //         return 'Restaurant';
// //
// //       case 'hotel':
// //         return 'Hotel';
// //
// //       case 'cafe':
// //         return 'CAFE';
// //
// //       case 'cloud_kitchen':
// //       case 'cloud kitchen':
// //         return 'CLOUD_KITCHEN';
// //
// //       case 'food_court':
// //       case 'food court':
// //         return 'FOOD_COURT';
// //
// //       case 'street_food':
// //       case 'street food':
// //         return 'STREET_FOOD';
// //
// //       case 'bakery':
// //         return 'BAKERY';
// //
// //       default:
// //         return 'Restaurant';
// //     }
// //   }
// //
// //   // ───────────────── NORMALIZE FILE EXT ─────────────────
// //
// //   static Future<Map<String, File>> _normaliseFileExtensions(
// //     Map<String, File> fileMap,
// //   ) async {
// //     final result = <String, File>{};
// //
// //     for (final entry in fileMap.entries) {
// //       final file = entry.value;
// //
// //       final mime = _mimeTypeForFile(file);
// //
// //       final expectedExt =
// //           {
// //             'image/jpeg': 'jpg',
// //             'image/png': 'png',
// //             'application/pdf': 'pdf',
// //             'image/webp': 'webp',
// //             'image/heic': 'heic',
// //           }[mime] ??
// //           'jpg';
// //
// //       final currentExt = file.path.contains('.')
// //           ? file.path.split('.').last.toLowerCase()
// //           : '';
// //
// //       if (currentExt == expectedExt ||
// //           (currentExt == 'jpeg' && expectedExt == 'jpg')) {
// //         result[entry.key] = file;
// //       } else {
// //         final tmpDir = Directory.systemTemp;
// //
// //         final tmpPath =
// //             '${tmpDir.path}/vendor_upload_${entry.key}_${DateTime.now().millisecondsSinceEpoch}.$expectedExt';
// //
// //         final tmpFile = await file.copy(tmpPath);
// //
// //         result[entry.key] = tmpFile;
// //       }
// //     }
// //
// //     return result;
// //   }
// //
// //   // ───────────────── DELETE TEMP FILES ─────────────────
// //
// //   static void _deleteTempFiles(Map<String, File> normalised) {
// //     final tmpDir = Directory.systemTemp.path;
// //
// //     for (final file in normalised.values) {
// //       if (file.path.startsWith(tmpDir)) {
// //         try {
// //           file.deleteSync();
// //         } catch (_) {}
// //       }
// //     }
// //   }
// //
// //   // ───────────────── PARSER ─────────────────
// //
// //   static VendorFormData _parseVendorDataToFormData(Map<String, dynamic> data) {
// //     return VendorFormData(
// //       companyName: data['registeredName'] ?? data['companyName'] ?? '',
// //
// //       businessVertical:
// //           data['businessVertical']?.toString() ?? 'FOOD_AND_BEVERAGES',
// //
// //       position: data['position'] ?? '',
// //
// //       verticalType: _normalizeVendorType(data['vendorType'] ?? ''),
// //
// //       doorNumber: data['doorNumber'] ?? '',
// //
// //       addressLine: data['addressLine'] ?? '',
// //
// //       landMark: data['landMark'] ?? '',
// //
// //       city: data['city'] ?? '',
// //
// //       state: data['state'] ?? '',
// //
// //       pincode: data['pincode']?.toString() ?? '',
// //
// //       latitude: data['latitude']?.toDouble(),
// //
// //       longitude: data['longitude']?.toDouble(),
// //
// //       address: data['fullAddress'] ?? '',
// //
// //       contactName: data['holderName'] ?? data['ownerName'] ?? '',
// //
// //       phone: data['mobileNumber']?.toString() ?? '',
// //
// //       email: data['email'] ?? '',
// //
// //       aadhar: data['aadharNumber']?.toString() ?? '',
// //
// //       gst: data['gstNumber'] ?? '',
// //
// //       pan: data['panCardNumber'] ?? '',
// //
// //       fssaiNo: data['fssaiLicenseNumber'] ?? '',
// //
// //       fssaiStart: data['fssaiStartDate'] ?? '',
// //
// //       fssaiEnd: data['fssaiEndDate'] ?? '',
// //
// //       tradeLicenseNo: data['tradeLicenseNumber'] ?? '',
// //
// //       tradeStart: data['tradeLicenseStartDate'] ?? '',
// //
// //       tradeEnd: data['tradeLicenseEndDate'] ?? '',
// //
// //       labourLicenseNo: data['labourLicenseNumber'] ?? '',
// //
// //       labourStart: data['labourStartDate'] ?? '',
// //
// //       labourEnd: data['labourEndDate'] ?? '',
// //
// //       bankName: data['branchName'] ?? data['bankName'] ?? '',
// //
// //       ifsc: data['ifscCode'] ?? '',
// //
// //       accountNumber: data['accountNumber']?.toString() ?? '',
// //     );
// //   }
// // }
// //
// // class PublicRegisterResult {
// //   final bool success;
// //   final String? errorMessage;
// //
// //   const PublicRegisterResult({required this.success, this.errorMessage});
// // }
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:maamaaspartner/Registration01/models/vendor_form_data.dart';
import '../../API/Apiclient.dart';

class VendorApiService {
  static const String _endpoint = 'api/vendors';
  static const String _foodBaseUrl = 'https://backend.maamaas.com/food/';
  // static const String _foodBaseUrl = 'http://staging.maamaas.com:8080/food/';

  static Future<Map<String, dynamic>?> getVendor(String vendorId) async {
    try {
      final response = await ApiClient.get(
        '$_endpoint/$vendorId',
        service: 'food',
      );
      if (response.statusCode == 200) return jsonDecode(response.body);

      return null;
    } catch (e) {
      debugPrint('GET Vendor Error: $e');
      return null;
    }
  }

  static Future<VendorFormData?> getVendorFormData(String vendorId) async {
    final raw = await getVendor(vendorId);
    if (raw == null) return null;
    return parseVendorData(raw);
  }

  static VendorFormData parseVendorData(Map<String, dynamic> data) {
    debugPrint('🟢 Parsing vendor data for ID: ${data['vendorId']}');
    return VendorFormData(
      companyName: data['registeredName'] ?? data['companyName'] ?? '',
      brandName: data['brandName']?.toString() ?? '',
      position: data['position'] ?? '',
      verticalType: _normalizeVendorType(data['vendorType'] ?? ''),
      doorNumber: data['doorNumber'] ?? '',
      addressLine: data['addressLine'] ?? '',
      landMark: data['landMark'] ?? '',
      city: data['city'] ?? '',
      state: data['state'] ?? '',
      pincode: data['pincode']?.toString() ?? '',
      latitude: data['latitude']?.toDouble(),
      longitude: data['longitude']?.toDouble(),
      address: data['fullAddress'] ?? '',
      contactName: data['holderName'] ?? data['ownerName'] ?? '',
      phone: data['mobileNumber']?.toString() ?? '',
      email: data['email'] ?? '',
      aadhar: data['aadharNumber']?.toString() ?? '',
      aadharFile: null,
      gst: data['gstNumber'] ?? '',
      gstFile: null,
      pan: data['panCardNumber'] ?? '',
      panFile: null,
      fssaiNo: data['fssaiLicenseNumber'] ?? '',
      fssaiStart: data['fssaiStartDate'] ?? '',
      fssaiEnd: data['fssaiEndDate'] ?? '',
      fssaiFile: null,
      tradeLicenseNo: data['tradeLicenseNumber'] ?? '',
      tradeStart: data['tradeLicenseStartDate'] ?? '',
      tradeEnd: data['tradeLicenseEndDate'] ?? '',
      tradeLicenseFile: null,
      labourLicenseNo: data['labourLicenseNumber'] ?? '',
      labourStart: data['labourStartDate'] ?? '',
      labourEnd: data['labourEndDate'] ?? '',
      labourFile: null,
      bankName: data['branchName'] ?? data['bankName'] ?? '',
      ifsc: data['ifscCode'] ?? '',
      accountNumber: data['accountNumber']?.toString() ?? '',
      passbookFile: null,
    );
  }

  static Future<bool> registerVendor(
    String vendorId,
    VendorFormData formData,
  ) async {
    final normalised = await _normaliseFileExtensions(_buildFileMap(formData));
    try {
      final response = await ApiClient.sendMultipartRequest(
        endpoint: '$_endpoint/$vendorId',
        method: 'POST',
        service: 'food',
        data: {'vendorData': jsonEncode(_buildVendorJson(vendorId, formData))},
        files: normalised,
      );
      debugPrint('registerVendor → ${response.statusCode}: ${response.body}');
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('registerVendor Error: $e');
      return false;
    } finally {
      _deleteTempFiles(normalised);
    }
  }

  static Future<PublicRegisterResult> registerVendorPublic(
    String vendorId,
    VendorFormData formData,
  ) async {
    try {
      final uri = Uri.parse('$_foodBaseUrl$_endpoint/$vendorId');
      final request = http.MultipartRequest('POST', uri)
        ..headers['Accept'] = 'application/json';

      request.files.add(
        http.MultipartFile.fromString(
          'vendorData',
          jsonEncode(_buildVendorJson(vendorId, formData)),
          contentType: MediaType('application', 'json'),
        ),
      );

      for (final entry in _buildFileMap(formData).entries) {
        final mimeType = _mimeTypeForFile(entry.value);
        request.files.add(
          await http.MultipartFile.fromPath(
            entry.key,
            entry.value.path,
            contentType: MediaType.parse(mimeType),
          ),
        );
      }

      final streamed = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Request timed out'),
      );
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return const PublicRegisterResult(success: true);
      }

      String errorMessage = 'Registration failed (${response.statusCode})';
      try {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        errorMessage =
            body['message']?.toString() ??
            body['error']?.toString() ??
            body['msg']?.toString() ??
            errorMessage;
      } catch (_) {
        if (response.body.isNotEmpty) errorMessage = response.body;
      }
      return PublicRegisterResult(success: false, errorMessage: errorMessage);
    } catch (e) {
      debugPrint('registerVendorPublic Error: $e');
      return PublicRegisterResult(
        success: false,
        errorMessage: 'Network error: ${e.toString()}',
      );
    }
  }

  // ── Shared Helpers ─────────────────────────────────────────────────────────
  static Map<String, dynamic> _buildVendorJson(
    String vendorId,
    VendorFormData f,
  ) => {
    'vendorId': int.tryParse(vendorId) ?? 0,
    'latitude': f.latitude ?? 0,
    'longitude': f.longitude ?? 0,
    'fullAddress': f.address,
    'addressLine': f.addressLine,
    'doorNumber': f.doorNumber,
    'landMark': f.landMark,
    'city': f.city,
    'state': f.state.isEmpty ? 'Telangana' : f.state,
    'pincode': int.tryParse(f.pincode) ?? 0,
    'companyName': f.companyName,
    'registeredName': f.companyName,
    'ownerName': f.companyName,
    'brandName': f.brandName,
    'position': f.position,
    'vendorType': _normalizeVendorType(f.verticalType),
    'holderName': f.contactName,
    'mobileNumber': f.phone,
    'email': f.email,
    'aadharNumber': f.aadhar,
    'panCardNumber': f.pan,
    'gstNumber': f.gst,
    'tradeLicenseNumber': f.tradeLicenseNo,
    'tradeLicenseStartDate': f.tradeStart,
    'tradeLicenseEndDate': f.tradeEnd,
    'fssaiLicenseNumber': f.fssaiNo,
    'fssaiStartDate': f.fssaiStart,
    'fssaiEndDate': f.fssaiEnd,
    'labourLicenseNumber': f.labourLicenseNo,
    'labourStartDate': f.labourStart,
    'labourEndDate': f.labourEnd,
    'accountNumber': f.accountNumber,
    'ifscCode': f.ifsc,
    'bankName': f.bankName,
    'branchName': f.bankName,
    'aadharNumberStatus': false,
    'panCardStatus': false,
    'gstNumberStatus': false,
    'tradeLicenseStatus': false,
    'labourLicenseStatus': false,
    'fssaiLicenseStatus': false,
    'online': false,
    'termsAndConditions': true,
  };

  static Map<String, File> _buildFileMap(VendorFormData f) => {
    if (f.aadharFile != null) 'aadharPhotoFront': f.aadharFile!,
    if (f.panFile != null) 'panCard': f.panFile!,
    if (f.passbookFile != null) 'passbook': f.passbookFile!,
    if (f.labourFile != null) 'labourLicense': f.labourFile!,
    if (f.fssaiFile != null) 'fssaiLicense': f.fssaiFile!,
    if (f.tradeLicenseFile != null) 'tradeLicense': f.tradeLicenseFile!,
    if (f.gstFile != null) 'gstFile': f.gstFile!,
  };

  static String _mimeTypeForFile(File file) {
    final ext = file.path.split('.').last.toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'pdf':
        return 'application/pdf';
      case 'webp':
        return 'image/webp';
      case 'heic':
        return 'image/heic';
      default:
        return 'image/jpeg';
    }
  }

  static String _normalizeVendorType(String type) {
    if (type.isEmpty) return 'Restaurant';
    switch (type.toLowerCase().trim()) {
      case 'restaurant':
        return 'Restaurant';
      case 'hotel':
        return 'Hotel';
      case 'cafe':
        return 'CAFE';
      case 'cloud_kitchen':
      case 'cloud kitchen':
        return 'CLOUD_KITCHEN';
      case 'food_court':
      case 'food court':
        return 'FOOD_COURT';
      case 'street_food':
      case 'street food':
        return 'STREET_FOOD';
      case 'bakery':
        return 'BAKERY';
      default:
        return 'Restaurant';
    }
  }

  static Future<Map<String, File>> _normaliseFileExtensions(
    Map<String, File> fileMap,
  ) async {
    final result = <String, File>{};
    for (final entry in fileMap.entries) {
      final file = entry.value;
      final mime = _mimeTypeForFile(file);
      final expectedExt =
          {
            'image/jpeg': 'jpg',
            'image/png': 'png',
            'application/pdf': 'pdf',
            'image/webp': 'webp',
            'image/heic': 'heic',
          }[mime] ??
          'jpg';
      final currentExt = file.path.contains('.')
          ? file.path.split('.').last.toLowerCase()
          : '';
      if (currentExt == expectedExt ||
          (currentExt == 'jpeg' && expectedExt == 'jpg')) {
        result[entry.key] = file;
      } else {
        final tmpDir = Directory.systemTemp;
        final tmpPath =
            '${tmpDir.path}/vendor_upload_${entry.key}_${DateTime.now().millisecondsSinceEpoch}.$expectedExt';
        final tmpFile = await file.copy(tmpPath);
        result[entry.key] = tmpFile;
      }
    }
    return result;
  }

  static void _deleteTempFiles(Map<String, File> normalised) {
    final tmpDir = Directory.systemTemp.path;
    for (final file in normalised.values) {
      if (file.path.startsWith(tmpDir)) {
        try {
          file.deleteSync();
        } catch (_) {}
      }
    }
  }
}

class PublicRegisterResult {
  final bool success;
  final String? errorMessage;
  const PublicRegisterResult({required this.success, this.errorMessage});
}
